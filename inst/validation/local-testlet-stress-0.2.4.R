# Repository-only numerical stress experiment; see the prespecified companion.
# Run from development/: Rscript inst/validation/local-testlet-stress-0.2.4.R
source('inst/validation/local-testlet-tam-reference-0.2.4.R')

stress_normal_rule <- function(n) {
  rule <- local_testlet_normal_rule(n)
  # Eigenvectors lose small tail entries. Orthonormal Hermite recurrence gives
  # w_i = 1 / (n * p_{n-1}(x_i)^2), retaining those positive weights.
  previous <- rep(1, n)
  current <- rule$nodes
  for (k in 2:(n - 1L)) {
    next_value <- (rule$nodes * current - sqrt(k - 1) * previous) / sqrt(k)
    previous <- current
    current <- next_value
  }
  list(nodes = rule$nodes, weights = 1 / (n * current^2))
}

stress_logsum <- function(x) {
  m <- max(x)
  m + log(sum(exp(x - m)))
}

stress_reference <- function(fixture, parameters, variance, order) {
  n_person <- nrow(fixture$response)
  rule <- stress_normal_rule(order)
  theta <- rule$nodes
  gamma <- if (variance == 0) 0 else sqrt(variance) * theta
  gamma_weights <- if (variance == 0) 1 else rule$weights
  ng <- length(gamma)
  loglik <- numeric(n_person)
  gradient <- matrix(0, n_person, 6)
  moments <- matrix(0, n_person, 6, dimnames = list(rownames(fixture$response),
    c('ThetaMean', 'ThetaSD', 'Gamma1Mean', 'Gamma1SD', 'Gamma2Mean', 'Gamma2SD')))
  for (p in seq_len(n_person)) {
    factors <- scores <- means <- seconds <- vector('list', 2)
    for (r in 1:2) {
      conditional <- matrix(0, order, ng)
      score <- array(0, c(order, ng, 6))
      for (i in which(fixture$map$Rater == r & !is.na(fixture$response[p, ]))) {
        contrast <- fixture$criterion_contrasts[fixture$map$Criterion[i], ]
        eta <- as.vector(outer(theta, gamma, '+') + parameters[1] -
          sum(contrast * parameters[2:3]) - fixture$rater_contrasts[r] * parameters[4])
        logits <- cbind(0, eta - parameters[5], 2 * eta)
        logits <- logits - apply(logits, 1, max)
        logp <- logits - log(rowSums(exp(logits)))
        probs <- exp(logp)
        y <- fixture$response[p, i]
        conditional <- conditional + matrix(logp[, y + 1L], order, ng)
        residual <- matrix(y - probs[, 2] - 2 * probs[, 3], order, ng)
        derivative <- c(1, -contrast, -fixture$rater_contrasts[r])
        for (a in 1:4) score[, , a] <- score[, , a] + derivative[a] * residual
        score[, , 5] <- score[, , 5] + matrix(probs[, 2] - (y == 1), order, ng)
        score[, , 6] <- score[, , 6] + sweep(residual, 2, gamma / 2, '*')
      }
      weighted <- sweep(conditional, 2, log(gamma_weights), '+')
      factors[[r]] <- apply(weighted, 1, stress_logsum)
      weighted <- exp(weighted - factors[[r]])
      scores[[r]] <- vapply(1:6, function(a) rowSums(weighted * score[, , a]), numeric(order))
      means[[r]] <- as.vector(weighted %*% gamma)
      seconds[[r]] <- as.vector(weighted %*% gamma^2)
    }
    weight <- log(rule$weights) + factors[[1]] + factors[[2]]
    loglik[p] <- stress_logsum(weight)
    weight <- exp(weight - loglik[p])
    gradient[p, ] <- colSums((scores[[1]] + scores[[2]]) * weight)
    m <- sum(weight * theta)
    moments[p, 1:2] <- c(m, sqrt(max(0, sum(weight * theta^2) - m^2)))
    for (r in 1:2) {
      m <- sum(weight * means[[r]])
      moments[p, 2 * r + (1:2)] <- c(m, sqrt(max(0, sum(weight * seconds[[r]]) - m^2)))
    }
  }
  list(loglik = sum(loglik), person_loglik = loglik, moments = moments,
       gradient = setNames(colSums(gradient), c(names(parameters), 'log_variance')))
}

stress_cases <- function() {
  base <- local_testlet_fixture()
  cases <- list()
  add <- function(id, variance = .49, parameters = base$parameters, response = base$response) {
    fixture <- base
    fixture$response <- response
    cases[[id]] <<- list(id = id, fixture = fixture, parameters = parameters, variance = variance)
  }
  for (v in c(1e-10, 1e-6, .049, .05, .051, 1, 4, 9, 16)) add(paste0('variance_', v), v)
  for (a in c(-40, -8, 8, 40)) {
    parameters <- base$parameters
    parameters[1] <- a
    add(paste0('alpha_', a), parameters = parameters)
  }
  for (t in c(-8, 8)) {
    parameters <- base$parameters
    parameters[5] <- t
    add(paste0('tau_', t), parameters = parameters)
  }
  parameters <- base$parameters
  parameters[2:4] <- c(-6, 0, 4)
  add('large_fixed_effects', parameters = parameters)
  response <- base$response
  response[, c(2, 3, 5, 6)] <- NA
  add('one_criterion_per_pair', response = response)
  response <- base$response
  response[1:3, 4:6] <- NA
  response[4:6, 1:3] <- NA
  add('disconnected', response = response)
  response <- base$response
  response[, 1:3] <- NA
  add('unobserved_rater', response = response)
  response <- base$response
  response[6, ] <- NA
  add('empty_person', response = response)
  response[] <- NA_real_
  add('empty_all', response = response)
  response[] <- 0
  add('all_zero', response = response)
  response[] <- 2
  add('all_two', response = response)
  response[, 1:3] <- 0
  add('opposed_raters', response = response)
  cases
}

stress_tam <- function(case, nodes, template) {
  dimension <- if (case$variance == 0) 1L else 3L
  A <- template$A
  B <- template$B
  B[, , 2:3] <- B[, , 2:3] * sqrt(case$variance / .49)
  B <- B[, , seq_len(dimension), drop = FALSE]
  covariance <- diag(dimension)
  index <- which(upper.tri(covariance, diag = TRUE), arr.ind = TRUE)
  fit <- TAM::tam.mml(case$fixture$response, pid = rownames(case$fixture$response),
    A = A, B = B, xsi.fixed = cbind(1:5, case$parameters),
    beta.fixed = cbind(1L, seq_len(dimension), 0),
    variance.fixed = cbind(index, covariance[index]), variance.inits = covariance,
    est.variance = FALSE, item.elim = FALSE, verbose = FALSE,
    control = list(nodes = nodes, snodes = 0, maxiter = 1L, progress = FALSE))
  stopifnot(max(abs(fit$xsi$xsi - case$parameters)) == 0,
    max(abs(fit$variance - covariance)) == 0, all(fit$beta == 0),
    identical(fit$resp, case$fixture$response),
    identical(as.character(fit$pid), rownames(case$fixture$response)),
    identical(dim(fit$A), dim(A)), identical(dim(fit$B), dim(B)),
    max(abs(fit$A - A)) == 0, max(abs(fit$B - B)) == 0)
  moments <- matrix(0, nrow(case$fixture$response), 6)
  if (dimension == 1) moments[, 1:2] <- as.matrix(fit$person[, c('EAP', 'SD.EAP')])
  else for (d in 1:3) moments[, 2 * d - (1:0)] <-
    as.matrix(fit$person[, c(paste0('EAP.Dim', d), paste0('SD.EAP.Dim', d))]) *
    if (d == 1) 1 else sqrt(case$variance)
  probability_error <- 0
  for (i in 1:6) {
    j <- case$fixture$map$Criterion[i]
    r <- case$fixture$map$Rater[i]
    eta <- fit$theta[, 1] + case$parameters[1] -
      sum(case$fixture$criterion_contrasts[j, ] * case$parameters[2:3]) -
      case$fixture$rater_contrasts[r] * case$parameters[4]
    if (dimension == 3) eta <- eta + sqrt(case$variance) * fit$theta[, r + 1]
    expected <- local_testlet_probabilities(eta, case$parameters[5])
    probability_error <- max(probability_error, abs(t(expected) - fit$rprobs[i, , ]))
  }
  list(loglik = -fit$deviance / 2, moments = moments, probability_error = probability_error)
}

stress_capture <- function(expr) {
  warnings <- character()
  start <- proc.time()[['elapsed']]
  value <- tryCatch(withCallingHandlers(expr, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w))
    invokeRestart('muffleWarning')
  }), error = function(e) e)
  list(value = if (!inherits(value, 'error')) value else NULL,
    error = if (inherits(value, 'error')) conditionMessage(value) else '',
    warnings = unique(warnings), elapsed = proc.time()[['elapsed']] - start)
}

run_local_testlet_stress <- function() {
  stopifnot(as.character(packageVersion('TAM')) == '4.3.25')
  output <- 'validation-results/local-testlet-stress-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  previous <- readRDS('validation-results/local-testlet-tam-reference-20260917/evidence.rds')
  template <- previous$fits[['variance_0.49']]
  cases <- stress_cases()
  grids <- list(n41_r7 = seq(-7, 7, length.out = 41), n81_r7 = seq(-7, 7, length.out = 81),
                n81_r14 = seq(-14, 14, length.out = 81), n121_r14 = seq(-14, 14, length.out = 121))
  provenance <- list(started = Sys.time(), R = R.version.string, TAM = as.character(packageVersion('TAM')),
    parent = system2('git', 'rev-parse HEAD', stdout = TRUE),
    sources = tools::md5sum(c('inst/validation/local-testlet-stress-0.2.4.R',
      'inst/validation/local-testlet-tam-reference-0.2.4.R')),
    plan = readLines('inst/validation/local-testlet-stress-0.2.4.md'),
    previous_provenance = previous$provenance, session = sessionInfo())
  saveRDS(list(cases = cases, grids = grids, provenance = provenance), file.path(output, 'plan.rds'))
  qualification <- list()
  qualify <- function(id, error, tolerance) {
    qualification[[length(qualification) + 1L]] <<- data.frame(Check = id, Error = error,
      Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
  }
  for (n in c(81L, 121L, 181L, 241L)) {
    rule <- stress_normal_rule(n)
    qualify(paste0('normal_moments_', n), max(abs(c(sum(rule$weights),
      sum(rule$weights * rule$nodes), sum(rule$weights * rule$nodes^2),
      sum(rule$weights * rule$nodes^4)) - c(1, 0, 1, 3))), 1e-10)
  }
  rule <- stress_normal_rule(241L)
  for (shift in c(-16, -12, 12, 16)) qualify(paste0('normal_tilt_', shift),
    abs(stress_logsum(log(rule$weights) + shift * rule$nodes) - shift^2 / 2), 1e-10)
  for (v in c(0, .01, .49)) {
    current <- stress_reference(previous$fixture, previous$fixture$parameters, v, 81L)
    old <- previous$references[[paste0('variance_', v)]]
    qualify(paste0('saved_reference_', v), max(abs(c(current$loglik - old$loglik,
      current$moments - old$moments, current$gradient - old$gradient))), 1e-9)
  }
  qualification <- do.call(rbind, qualification)
  write.csv(qualification, 'inst/validation/local-testlet-stress-0.2.4-qualification.csv', row.names = FALSE)
  stopifnot(all(qualification$Pass))
  results <- attempts <- gradients <- list()
  for (case in cases) {
    cat('CASE', case$id, '\n')
    reference_attempts <- list()
    converged <- FALSE
    prior <- NULL
    for (order in c(81L, 121L, 181L, 241L)) {
      captured <- stress_capture(stress_reference(case$fixture, case$parameters, case$variance, order))
      reference_attempts[[as.character(order)]] <- captured
      current <- captured$value
      if (!is.null(current) && !is.null(prior)) {
        differences <- c(abs(current$loglik - prior$loglik),
          max(abs(current$moments - prior$moments)), max(abs(current$gradient - prior$gradient)))
        converged <- all(is.finite(differences)) && all(differences <= c(1e-7, 1e-7, 1e-6))
      }
      prior <- current
      if (converged) break
    }
    tam_attempts <- list()
    matched <- FALSE
    for (grid in names(grids)) {
      captured <- stress_capture(stress_tam(case, grids[[grid]], template))
      tam_attempts[[grid]] <- captured
      value <- captured$value
      ll_error <- moment_error <- probability_error <- NA_real_
      if (!is.null(value) && !is.null(current)) {
        ll_error <- abs(value$loglik - current$loglik)
        moment_error <- max(abs(value$moments - current$moments))
        probability_error <- value$probability_error
        matched <- converged && all(is.finite(c(ll_error, moment_error, probability_error))) &&
          ll_error <= 1e-6 && moment_error <= 1e-6 && probability_error <= 1e-12
      }
      attempts[[length(attempts) + 1L]] <- data.frame(Case = case$id, Grid = grid,
        LogLikError = ll_error, MomentError = moment_error, ProbabilityError = probability_error,
        ReferenceConverged = converged, Matched = matched, Error = captured$error,
        Warnings = paste(captured$warnings, collapse = ' | '), Seconds = captured$elapsed)
      if (matched || nzchar(captured$error) || !converged) break
    }
    status <- if (nzchar(captured$error)) 'tam_error' else if (!converged) 'reference_unresolved'
      else if (!matched) 'grid_unresolved' else if (grid == 'n41_r7') 'initial_match' else 'refined_match'
    results[[length(results) + 1L]] <- data.frame(Case = case$id, Observations = sum(!is.na(case$fixture$response)),
      Variance = case$variance, Alpha = case$parameters[1], ReferenceOrder = order,
      ReferenceConverged = converged, FinalGrid = grid, Status = status,
      LogLikError = ll_error, MomentError = moment_error, Error = captured$error)
    selected <- c('variance_1e-10', 'variance_9', 'alpha_8', 'one_criterion_per_pair')
    if (case$id %in% selected && matched) for (a in 1:6) {
      values <- vapply(c(1e-4, 5e-5), function(h) {
        plus <- minus <- case
        if (a <= 5) {
          plus$parameters[a] <- plus$parameters[a] + h
          minus$parameters[a] <- minus$parameters[a] - h
        } else {
          plus$variance <- plus$variance * exp(h)
          minus$variance <- minus$variance * exp(-h)
        }
        fp <- stress_capture(stress_tam(plus, grids[[grid]], template))
        fm <- stress_capture(stress_tam(minus, grids[[grid]], template))
        saveRDS(list(plus = fp, minus = fm), file.path(output, paste0(case$id, '-gradient-', a, '-', h, '.rds')))
        if (is.null(fp$value) || is.null(fm$value)) return(NA_real_)
        (fp$value$loglik - fm$value$loglik) / (2 * h)
      }, numeric(1))
      error <- max(abs(values - current$gradient[a]), abs(diff(values)))
      gradients[[length(gradients) + 1L]] <- data.frame(Case = case$id,
        Parameter = names(current$gradient)[a], Analytic = current$gradient[a],
        Step1 = values[1], Step2 = values[2], Error = error,
        Pass = is.finite(error) && error <= 1e-5)
    }
    saveRDS(list(case = case, references = reference_attempts, tam = tam_attempts),
      file.path(output, paste0(case$id, '.rds')))
    write.csv(do.call(rbind, results), 'inst/validation/local-testlet-stress-0.2.4-cases.csv', row.names = FALSE)
    write.csv(do.call(rbind, attempts), 'inst/validation/local-testlet-stress-0.2.4-attempts.csv', row.names = FALSE)
    if (length(gradients)) write.csv(do.call(rbind, gradients),
      'inst/validation/local-testlet-stress-0.2.4-gradients.csv', row.names = FALSE)
    cat('RESULT', case$id, status, 'reference', order, 'grid', grid, '\n')
  }
  print(table(do.call(rbind, results)$Status))
  if (length(gradients)) print(table(do.call(rbind, gradients)$Pass))
}

if (sys.nframe() == 0L) run_local_testlet_stress()
