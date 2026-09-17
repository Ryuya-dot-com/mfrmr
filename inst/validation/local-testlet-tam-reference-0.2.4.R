# Repository-only fixed-point qualification, not a fitted random-effects API.
# Rscript inst/validation/local-testlet-tam-reference-0.2.4.R
# See the companion record for the model, limits, and prespecified tolerances.

local_testlet_fixture <- function() {
  response <- rbind(c(0, 1, 2, 2, 1, 0), c(2, 2, 1, 1, 0, 0),
                    c(1, 0, 1, 2, 2, 1), rep(0, 6), rep(2, 6),
                    c(NA, NA, NA, 1, 2, 0))
  map <- expand.grid(Criterion = 1:3, Rater = 1:2)
  dimnames(response) <- list(paste0('P', 1:6),
                             paste0('R', map$Rater, 'C', map$Criterion))
  list(response = response, map = map,
       parameters = c(alpha = .2, beta1 = -.4, beta2 = .1,
                      rater1 = -.25, tau1 = -.6),
       criterion_contrasts = rbind(c(1, 0), c(0, 1), c(-1, -1)),
       rater_contrasts = c(1, -1))
}

local_testlet_probabilities <- function(eta, tau1) {
  logits <- cbind(0, eta - tau1, 2 * eta)
  logits <- logits - apply(logits, 1, max)
  probabilities <- exp(logits)
  probabilities / rowSums(probabilities)
}

local_testlet_tam <- function(fixture, parameters, variance, nodes = 41L,
                              local_signs = c(1, 1)) {
  stopifnot(length(variance) == 1L, is.finite(variance), variance >= 0)
  stopifnot(length(local_signs) == 2L, all(abs(local_signs) == 1))
  # At zero, drop the absent random effects exactly; no variance floor.
  dimension <- if (variance == 0) 1L else 3L
  A <- array(0, c(6L, 3L, 5L), dimnames = list(
    colnames(fixture$response), as.character(0:2), names(parameters)))
  B <- array(0, c(6L, 3L, dimension))
  for (i in 1:6) for (k in 0:2) {
    j <- fixture$map$Criterion[i]
    r <- fixture$map$Rater[i]
    A[i, k + 1L, ] <- c(k, -k * fixture$criterion_contrasts[j, ],
                        -k * fixture$rater_contrasts[r], -as.numeric(k == 1))
    B[i, k + 1L, 1L] <- k
    if (dimension == 3L)
      B[i, k + 1L, r + 1L] <- k * sqrt(variance) * local_signs[r]
  }
  covariance <- diag(dimension)
  index <- which(upper.tri(covariance, diag = TRUE), arr.ind = TRUE)
  fit <- TAM::tam.mml(
    fixture$response, pid = rownames(fixture$response), A = A, B = B,
    xsi.fixed = cbind(1:5, parameters),
    beta.fixed = cbind(1L, seq_len(dimension), 0),
    variance.fixed = cbind(index, covariance[index]), variance.inits = covariance,
    # This retains the identity covariance after TAM's M-step diagonal jitter.
    est.variance = FALSE, item.elim = FALSE, verbose = FALSE,
    control = list(nodes = seq(-7, 7, length.out = nodes), snodes = 0,
                   maxiter = 1L, progress = FALSE)
  )
  stopifnot(max(abs(fit$xsi$xsi - parameters)) == 0,
            max(abs(fit$variance - covariance)) == 0, all(fit$beta == 0),
            identical(fit$resp, fixture$response),
            identical(as.character(fit$pid), rownames(fixture$response)),
            max(abs(fit$A - A)) == 0, max(abs(fit$B - B)) == 0,
            qr(matrix(A, nrow = 18L))$rank == 5L)
  fit
}

local_testlet_normal_rule <- function(n) {
  # Independent base-R Jacobi construction for standard-normal quadrature.
  jacobi <- matrix(0, n, n)
  jacobi[cbind(1:(n - 1L), 2:n)] <- sqrt(1:(n - 1L))
  eig <- eigen(jacobi + t(jacobi), symmetric = TRUE)
  list(nodes = eig$values, weights = eig$vectors[1, ]^2)
}

local_testlet_reference <- function(fixture, parameters, variance, order = 61L) {
  rule <- local_testlet_normal_rule(order)
  theta <- rule$nodes
  gamma <- if (variance == 0) 0 else sqrt(variance) * rule$nodes
  gamma_weights <- if (variance == 0) 1 else rule$weights
  ng <- length(gamma)
  gradient_names <- c(names(parameters), 'log_variance')
  gradient <- matrix(0, 6L, 6L, dimnames = list(rownames(fixture$response), gradient_names))
  moments <- matrix(0, 6L, 6L, dimnames = list(rownames(fixture$response),
    c('ThetaMean', 'ThetaSD', 'Gamma1Mean', 'Gamma1SD', 'Gamma2Mean', 'Gamma2SD')))
  loglik <- numeric(6L)
  for (p in 1:6) {
    factors <- scores <- means <- seconds <- vector('list', 2L)
    for (r in 1:2) {
      logconditional <- matrix(0, order, ng)
      score <- array(0, c(order, ng, 6L))
      for (i in which(fixture$map$Rater == r & !is.na(fixture$response[p, ]))) {
        j <- fixture$map$Criterion[i]
        contrast <- fixture$criterion_contrasts[j, ]
        location <- parameters[1] - sum(contrast * parameters[2:3]) -
          fixture$rater_contrasts[r] * parameters[4]
        eta <- as.vector(outer(theta, gamma, '+') + location)
        probs <- local_testlet_probabilities(eta, parameters[5])
        y <- fixture$response[p, i]
        logconditional <- logconditional + matrix(log(probs[, y + 1L]), order, ng)
        residual <- matrix(y - probs[, 2L] - 2 * probs[, 3L], order, ng)
        derivative <- c(1, -contrast, -fixture$rater_contrasts[r])
        for (a in 1:4) score[, , a] <- score[, , a] + derivative[a] * residual
        score[, , 5L] <- score[, , 5L] + matrix(probs[, 2L] - (y == 1), order, ng)
        score[, , 6L] <- score[, , 6L] + sweep(residual, 2, gamma / 2, '*')
      }
      weighted <- sweep(exp(logconditional), 2, gamma_weights, '*')
      factors[[r]] <- rowSums(weighted)
      scores[[r]] <- vapply(1:6, function(a)
        rowSums(weighted * score[, , a]) / factors[[r]], numeric(order))
      means[[r]] <- rowSums(sweep(weighted, 2, gamma, '*')) / factors[[r]]
      seconds[[r]] <- rowSums(sweep(weighted, 2, gamma^2, '*')) / factors[[r]]
    }
    weight <- rule$weights * factors[[1]] * factors[[2]]
    loglik[p] <- log(sum(weight))
    weight <- weight / sum(weight)
    gradient[p, ] <- colSums((scores[[1]] + scores[[2]]) * weight)
    m <- sum(weight * theta)
    moments[p, 1:2] <- c(m, sqrt(max(0, sum(weight * theta^2) - m^2)))
    for (r in 1:2) {
      m <- sum(weight * means[[r]])
      moments[p, 2 * r + (1:2)] <- c(m, sqrt(max(0, sum(weight * seconds[[r]]) - m^2)))
    }
  }
  list(loglik = sum(loglik), person_loglik = loglik,
       gradient = colSums(gradient), moments = moments)
}

run_local_testlet_reference <- function() {
  stopifnot(as.character(utils::packageVersion('TAM')) == '4.3.25')
  pkgload::load_all('.', quiet = TRUE)
  output <- 'validation-results/local-testlet-tam-reference-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  fixture <- local_testlet_fixture()
  parameters <- fixture$parameters
  checks <- list()
  check <- function(case, quantity, error, tolerance) {
    checks[[length(checks) + 1L]] <<- data.frame(
      Case = case, Quantity = quantity, Error = as.numeric(error),
      Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
  }
  fits <- references <- list()
  gradient_rows <- list()
  for (variance in c(0, .01, .49)) {
    case <- paste0('variance_', variance)
    reference <- local_testlet_reference(fixture, parameters, variance, 61L)
    higher <- local_testlet_reference(fixture, parameters, variance, 81L)
    check(case, 'reference_order_loglik', abs(reference$loglik - higher$loglik), 1e-6)
    check(case, 'reference_order_moments', max(abs(reference$moments - higher$moments)), 1e-6)
    check(case, 'reference_order_gradient', max(abs(reference$gradient - higher$gradient)), 1e-5)
    fit <- local_testlet_tam(fixture, parameters, variance)
    fits[[case]] <- fit
    references[[case]] <- higher
    check(case, 'tam_continuous_reference_loglik', abs(-fit$deviance / 2 - higher$loglik), 1e-6)

    # Independently reconstruct all node probabilities and the raw grid integral.
    conditional <- matrix(1, 6L, nrow(fit$theta))
    maximum_probability_error <- 0
    for (i in 1:6) {
      j <- fixture$map$Criterion[i]
      r <- fixture$map$Rater[i]
      eta <- fit$theta[, 1L] + parameters[1] -
        sum(fixture$criterion_contrasts[j, ] * parameters[2:3]) -
        fixture$rater_contrasts[r] * parameters[4]
      if (variance > 0) eta <- eta + sqrt(variance) * fit$theta[, r + 1L]
      probs <- local_testlet_probabilities(eta, parameters[5])
      maximum_probability_error <- max(maximum_probability_error,
        max(abs(t(probs) - fit$rprobs[i, , ])))
      for (p in which(!is.na(fixture$response[, i])))
        conditional[p, ] <- conditional[p, ] * probs[, fixture$response[p, i] + 1L]
    }
    density <- apply(dnorm(fit$theta), 1, prod)
    grid_width <- (14 / 40)^ncol(fit$theta)
    grid_loglik <- sum(log(as.vector(conditional %*% density) * grid_width))
    check(case, 'tam_node_probabilities', maximum_probability_error, 1e-12)
    check(case, 'tam_raw_grid_loglik', abs(-fit$deviance / 2 - grid_loglik), 1e-10)
    moments <- higher$moments * 0
    if (variance == 0) {
      moments[, 1:2] <- as.matrix(fit$person[, c('EAP', 'SD.EAP')])
    } else for (d in 1:3) {
      columns <- c(paste0('EAP.Dim', d), paste0('SD.EAP.Dim', d))
      moments[, 2 * d - (1:0)] <- as.matrix(fit$person[, columns]) *
        if (d == 1) 1 else sqrt(variance)
    }
    check(case, 'tam_posterior_moments', max(abs(moments - higher$moments)), 1e-6)
    check(case, 'unobserved_pair_mean', abs(higher$moments[6, 'Gamma1Mean']), 1e-12)
    check(case, 'unobserved_pair_sd', abs(higher$moments[6, 'Gamma1SD'] - sqrt(variance)), 1e-12)

    # Differentiate the public TAM fixed-point likelihood, not the oracle code.
    for (a in seq_len(if (variance == 0) 5L else 6L)) {
      estimates <- vapply(c(1e-4, 5e-5), function(h) {
        plus <- minus <- parameters
        vp <- vm <- variance
        if (a <= 5L) { plus[a] <- plus[a] + h; minus[a] <- minus[a] - h }
        else { vp <- variance * exp(h); vm <- variance * exp(-h) }
        fp <- local_testlet_tam(fixture, plus, vp)
        fm <- local_testlet_tam(fixture, minus, vm)
        (fm$deviance - fp$deviance) / (4 * h)
      }, numeric(1))
      gradient_rows[[length(gradient_rows) + 1L]] <- data.frame(
        Case = case, Parameter = names(higher$gradient)[a],
        Analytic = higher$gradient[a], TAMStep1 = estimates[1], TAMStep2 = estimates[2])
      check(case, paste0('gradient_', names(higher$gradient)[a]),
            max(abs(estimates - higher$gradient[a]), abs(diff(estimates))), 1e-5)
    }
  }

  # Relabel owners together with their data and fixed effects.
  swapped <- fixture
  swapped$response <- fixture$response[, c(4:6, 1:3)]
  colnames(swapped$response) <- colnames(fixture$response)
  swapped_parameters <- parameters
  swapped_parameters[4] <- -parameters[4]
  swapped_fit <- local_testlet_tam(swapped, swapped_parameters, .49)
  base_fit <- fits[['variance_0.49']]
  check('owner_relabeling', 'loglik', abs(swapped_fit$deviance - base_fit$deviance) / 2, 1e-10)
  check('owner_relabeling', 'local_posterior_means', max(abs(
    as.matrix(swapped_fit$person[, c('EAP.Dim2', 'EAP.Dim3')]) -
      as.matrix(base_fit$person[, c('EAP.Dim3', 'EAP.Dim2')]))), 1e-10)
  reflected_fit <- local_testlet_tam(fixture, parameters, .49, local_signs = c(-1, 1))
  check('basis_reflection', 'loglik', abs(reflected_fit$deviance - base_fit$deviance) / 2, 1e-10)
  check('basis_reflection', 'local_posterior_mean',
        max(abs(reflected_fit$person$EAP.Dim2 + base_fit$person$EAP.Dim2)), 1e-10)
  fits$owner_relabeling <- swapped_fit
  fits$basis_reflection <- reflected_fit

  # Zero variance preserves the existing fixed-facet RSM, including location.
  eta <- seq(-4, 4, length.out = 41L)
  check('zero_reduction', 'mfrmr_probability_kernel', max(abs(
    local_testlet_probabilities(eta + parameters[1], parameters[5]) -
      mfrmr:::category_prob_rsm(eta, c(0, cumsum(c(parameters[5], -parameters[5]) -
                                                parameters[1]))))), 1e-12)

  # Verify the installed TAM covariance adjustment at the density layer.
  requested <- diag(c(1, .01, .01))
  effective <- TAM:::tam_ginv(requested, eps = .05)
  points <- rbind(c(0, 0, 0), c(1, .2, -.2), c(-.5, -.3, .1))
  prior <- as.numeric(TAM:::tam_stud_prior(
    theta = points, Y = matrix(1, 1, 1), beta = matrix(0, 1, 3),
    variance = requested, nstud = 1L, nnodes = 3L, ndim = 3L,
    YSD = FALSE, unidim_simplify = FALSE))
  expected <- apply(sweep(points, 2, sqrt(diag(effective)), '/'), 1,
                    function(z) prod(dnorm(z))) / sqrt(det(effective))
  declared <- apply(sweep(points, 2, sqrt(diag(requested)), '/'), 1,
                    function(z) prod(dnorm(z))) / sqrt(det(requested))
  check('tam_covariance_adjustment', 'effective_covariance',
        max(abs(effective - diag(c(1, .05, .05) * 1.02 / 1.1))), 1e-12)
  check('tam_covariance_adjustment', 'effective_density', max(abs(prior - expected)), 1e-12)
  stopifnot(max(abs(prior - declared)) > 1)

  results <- do.call(rbind, checks)
  gradients <- do.call(rbind, gradient_rows)
  source_functions <- c('tam.mml', 'tam_stud_prior', 'tam_ginv',
                        'tam_mml_mstep_regression', 'tam_mml_compute_deviance')
  source_files <- file.path(output, paste0(source_functions, '.R'))
  for (i in seq_along(source_functions))
    writeLines(deparse(get(source_functions[i], asNamespace('TAM'))), source_files[i])
  provenance <- list(TAMVersion = as.character(utils::packageVersion('TAM')),
    ParentCommit = system2('git', c('rev-parse', 'HEAD'), stdout = TRUE),
    SourceMD5 = tools::md5sum(source_files),
    RunnerMD5 = tools::md5sum('inst/validation/local-testlet-tam-reference-0.2.4.R'),
    Session = sessionInfo())
  saveRDS(list(fixture = fixture, fits = fits, references = references,
               results = results, gradients = gradients, provenance = provenance,
               covariance_audit = list(requested = requested, effective = effective,
                 points = points, actual_density = prior, declared_density = declared)),
          file.path(output, 'evidence.rds'))
  write.csv(results, file.path(output, 'checks.csv'), row.names = FALSE)
  write.csv(gradients, file.path(output, 'gradients.csv'), row.names = FALSE)
  print(results, row.names = FALSE)
  stopifnot(all(results$Pass))
  invisible(results)
}

if (sys.nframe() == 0L) run_local_testlet_reference()
