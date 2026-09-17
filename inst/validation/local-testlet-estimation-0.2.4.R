# Repository-only bounded joint-estimation prototype, not a public API.
# Rscript inst/validation/local-testlet-estimation-0.2.4.R
source('inst/validation/local-testlet-stress-0.2.4.R')

testlet_estimation_input <- function(fixture) {
  y <- fixture$response
  if (!is.matrix(y) || !is.numeric(y) || ncol(y) != 6L ||
      !all(y[!is.na(y)] %in% 0:2)) return('unsupported_response')
  observed <- y[!is.na(y)]
  if (!length(observed)) return('no_observations')
  if (all(observed == 0) || all(observed == 2)) return('no_finite_location_mle')
  design <- do.call(rbind, lapply(which(colSums(!is.na(y)) > 0), function(i)
    t(vapply(1:2, function(k) c(k, -k * fixture$criterion_contrasts[fixture$map$Criterion[i], ],
      -k * fixture$rater_contrasts[fixture$map$Rater[i]], -as.numeric(k == 1)), numeric(5)))))
  if (qr(design)$rank < 5L) return('fixed_effect_rank_deficient')
  'ready_for_bounded_search'
}

testlet_zero_variance_score <- function(fixture, parameters, order) {
  rule <- stress_normal_rule(order)
  items <- lapply(seq_len(ncol(fixture$response)), function(i) {
    eta <- rule$nodes + parameters[1] -
      sum(fixture$criterion_contrasts[fixture$map$Criterion[i], ] * parameters[2:3]) -
      fixture$rater_contrasts[fixture$map$Rater[i]] * parameters[4]
    logits <- cbind(0, eta - parameters[5], 2 * eta)
    logits <- logits - pmax(0, logits[, 2], logits[, 3])
    logp <- logits - log(rowSums(exp(logits)))
    probabilities <- exp(logp)
    list(logp = logp, probabilities = probabilities,
      mean = probabilities[, 2] + 2 * probabilities[, 3])
  })
  total <- 0
  for (p in seq_len(nrow(fixture$response))) {
    logconditional <- numeric(order)
    curvature <- numeric(order)
    for (r in 1:2) {
      residual_sum <- variance_sum <- numeric(order)
      for (i in which(fixture$map$Rater == r & !is.na(fixture$response[p, ]))) {
        item <- items[[i]]
        probabilities <- item$probabilities
        mean <- item$mean
        y <- fixture$response[p, i]
        logconditional <- logconditional + item$logp[, y + 1L]
        residual_sum <- residual_sum + y - mean
        variance_sum <- variance_sum + probabilities[, 2] + 4 * probabilities[, 3] - mean^2
      }
      curvature <- curvature + .5 * (residual_sum^2 - variance_sum)
    }
    logweight <- log(rule$weights) + logconditional
    total <- total + sum(exp(logweight - stress_logsum(logweight)) * curvature)
  }
  total
}

testlet_estimation_evaluate <- function(fixture, par, order) {
  stopifnot(length(par) == 6L, all(is.finite(par)), par[6] >= 0)
  result <- stress_reference(fixture, par[1:5], par[6], order)
  result$gradient[6] <- if (par[6] == 0)
    testlet_zero_variance_score(fixture, par[1:5], order) else result$gradient[6] / par[6]
  names(result$gradient)[6] <- 'variance'
  result
}

testlet_projected_score <- function(par, score) {
  lower <- c(rep(-8, 5), 0)
  upper <- c(rep(8, 5), 16)
  score[par == lower] <- pmax(0, score[par == lower])
  score[par == upper] <- pmin(0, score[par == upper])
  max(abs(score))
}

testlet_bounded_fit <- function(fixture, start, fixed_variance = NULL,
                                orders = c(61L, 121L, 181L, 241L)) {
  input <- testlet_estimation_input(fixture)
  if (input != 'ready_for_bounded_search') stop(input)
  history <- list()
  last_par <- last_value <- NULL
  evaluate <- function(par) {
    if (identical(par, last_par)) return(last_value)
    prior <- NULL
    converged <- FALSE
    for (order in orders) {
      current <- testlet_estimation_evaluate(fixture, par, order)
      differences <- rep(NA_real_, 3)
      if (!is.null(prior)) {
        differences <- c(abs(current$loglik - prior$loglik),
          max(abs(current$moments - prior$moments)), max(abs(current$gradient - prior$gradient)))
        converged <- all(is.finite(differences)) && all(differences <= c(1e-7, 1e-7, 1e-6))
      }
      history[[length(history) + 1L]] <<- c(par, Order = order, LogLik = current$loglik,
        LogLikDifference = differences[1], MomentDifference = differences[2],
        ScoreDifference = differences[3], Qualified = as.numeric(converged))
      if (converged) break
      prior <- current
    }
    if (!converged) stop('quadrature_unresolved_at_trial')
    last_par <<- par
    last_value <<- current
    current
  }
  free <- if (is.null(fixed_variance)) 1:6 else 1:5
  expand <- function(x) if (is.null(fixed_variance)) x else c(x, variance = fixed_variance)
  captured <- stress_capture({
    fit <- stats::optim(start[free], function(x) -evaluate(expand(x))$loglik,
      function(x) -evaluate(expand(x))$gradient[free], method = 'L-BFGS-B',
      lower = c(rep(-8, 5), 0)[free], upper = c(rep(8, 5), 16)[free],
      # Match the checked integration-score accuracy; final KKT tolerance is 1e-5.
      control = list(maxit = 250L, factr = 1e3, pgtol = 1e-6))
    par <- expand(fit$par)
    value <- evaluate(par)
    list(par = par, loglik = value$loglik, gradient = value$gradient, moments = value$moments,
      projected_score = testlet_projected_score(par, value$gradient),
      nuisance_score = max(abs(value$gradient[1:5])), convergence = fit$convergence,
      message = fit$message, counts = fit$counts,
      search_boundary = any(abs(par[1:5]) >= 8 - 1e-8) || par[6] >= 16 - 1e-8)
  })
  list(captured = captured, history = do.call(rbind, history), start = start,
    fixed_variance = fixed_variance, orders = orders)
}

testlet_estimation_fixtures <- function() {
  original <- local_testlet_fixture()
  clustered <- original
  clustered$response[] <- rbind(c(0,0,1,2,2,1), c(2,2,1,0,0,1), c(1,1,0,2,2,2),
                                c(0,1,0,0,0,1), c(2,1,2,1,2,2), c(1,2,1,1,0,1))
  list(original = original, clustered = clustered)
}

run_testlet_estimation <- function() {
  stopifnot(as.character(packageVersion('TAM')) == '4.3.25')
  output <- 'validation-results/local-testlet-estimation-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  fixtures <- testlet_estimation_fixtures()
  names6 <- c(names(fixtures$original$parameters), 'variance')
  starts <- list(previous = c(fixtures$original$parameters, variance = .49),
    zero = setNames(rep(0, 6), names6), shifted = setNames(c(-.3, .3, -.2, .2, .2, 4), names6))
  sources <- tools::md5sum(c('inst/validation/local-testlet-estimation-0.2.4.R',
    'inst/validation/local-testlet-stress-0.2.4.R', 'inst/validation/local-testlet-tam-reference-0.2.4.R'))
  saveRDS(list(fixtures = fixtures, starts = starts, sources = sources, started = Sys.time(),
    parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo(),
    plan = readLines('inst/validation/local-testlet-estimation-0.2.4.md')), file.path(output, 'plan.rds'))
  qualification <- list()
  for (id in names(fixtures)) {
    fixture <- fixtures[[id]]
    parameters <- fixture$parameters
    value <- stress_reference(fixture, parameters, 0, 121L)$loglik
    differences <- vapply(c(1e-4, 5e-5), function(h)
      (stress_reference(fixture, parameters, h, 121L)$loglik - value) / h, numeric(1))
    analytic <- testlet_zero_variance_score(fixture, parameters, 121L)
    extrapolated <- 2 * differences[2] - differences[1]
    qualification[[id]] <- data.frame(Check = paste0('zero_score_', id), Value = analytic,
      Comparison = extrapolated, Pass = abs(analytic - extrapolated) <= 1e-5)
  }
  controls <- stress_cases()[c('empty_all', 'all_zero', 'all_two', 'unobserved_rater')]
  expected <- c('no_observations', 'no_finite_location_mle', 'no_finite_location_mle', 'fixed_effect_rank_deficient')
  for (i in seq_along(controls)) {
    actual <- testlet_estimation_input(controls[[i]]$fixture)
    qualification[[names(controls)[i]]] <- data.frame(Check = names(controls)[i], Value = actual,
      Comparison = expected[i], Pass = identical(actual, expected[i]))
  }
  qualification <- do.call(rbind, qualification)
  write.csv(qualification, 'inst/validation/local-testlet-estimation-0.2.4-qualification.csv', row.names = FALSE)
  stopifnot(all(qualification$Pass))
  previous <- readRDS('validation-results/local-testlet-tam-reference-20260917/evidence.rds')
  template <- previous$fits[['variance_0.49']]
  summaries <- gradient_rows <- external_rows <- list()
  for (id in names(fixtures)) {
    fixture <- fixtures[[id]]
    runs <- list()
    record <- function(label, start, fixed_variance = NULL, orders = c(61L, 121L, 181L, 241L)) {
      cat('FIT', id, label, '\n')
      result <- testlet_bounded_fit(fixture, start, fixed_variance, orders)
      runs[[label]] <<- result
      saveRDS(list(fixture = fixture, sources = sources, result = result),
        file.path(output, paste0(id, '-', label, '.rds')))
      x <- result$captured$value
      cat('RESULT', id, label, if (is.null(x)) result$captured$error else
        paste('v', signif(x$par[6], 7), 'loglik', signif(x$loglik, 9), 'score', signif(x$projected_score, 3)), '\n')
      summaries[[length(summaries) + 1L]] <<- data.frame(Case = id, Run = label,
        FixedVariance = if (is.null(fixed_variance)) NA_real_ else fixed_variance,
        Variance = if (is.null(x)) NA_real_ else x$par[6], LogLik = if (is.null(x)) NA_real_ else x$loglik,
        ProjectedScore = if (is.null(x)) NA_real_ else x$projected_score,
        NuisanceScore = if (is.null(x)) NA_real_ else x$nuisance_score,
        Convergence = if (is.null(x)) NA_integer_ else x$convergence,
        SearchBoundary = if (is.null(x)) NA else x$search_boundary,
        Seconds = result$captured$elapsed, Error = result$captured$error,
        Warnings = paste(result$captured$warnings, collapse = ' | '))
      write.csv(do.call(rbind, summaries), 'inst/validation/local-testlet-estimation-0.2.4-runs.csv', row.names = FALSE)
      result
    }
    for (label in names(starts)) record(paste0('joint_', label), starts[[label]])
    retained <- Filter(function(x) !is.null(x$captured$value), runs)
    if (!length(retained)) next
    best <- retained[[which.max(vapply(retained, function(x) x$captured$value$loglik, numeric(1)))]]$captured$value
    start <- best$par
    for (v in c(0, .01, .1, .49, 1, 4, 9, 16)) {
      fit <- record(paste0('profile_', v), start, v)
      if (!is.null(fit$captured$value)) start <- fit$captured$value$par
    }
    retained <- Filter(function(x) !is.null(x$captured$value), runs)
    best <- retained[[which.max(vapply(retained, function(x) x$captured$value$loglik, numeric(1)))]]$captured$value
    refined <- record('fine_joint', best$par, orders = c(121L, 181L, 241L))$captured$value
    if (is.null(refined)) next
    case <- list(id = id, fixture = fixture, parameters = refined$par[1:5], variance = refined$par[6])
    grids <- list(n41_r7 = seq(-7, 7, length.out = 41), n81_r7 = seq(-7, 7, length.out = 81),
      n81_r14 = seq(-14, 14, length.out = 81), n121_r20 = seq(-20, 20, length.out = 121))
    matched <- FALSE
    for (grid in names(grids)) {
      external <- stress_capture(stress_tam(case, grids[[grid]], template))
      saveRDS(external, file.path(output, paste0(id, '-tam-', grid, '.rds')))
      error <- if (is.null(external$value)) rep(NA_real_, 3) else c(
        abs(external$value$loglik - refined$loglik), max(abs(external$value$moments - refined$moments)),
        external$value$probability_error)
      matched <- all(is.finite(error)) && all(error <= c(1e-6, 1e-6, 1e-12))
      external_rows[[length(external_rows) + 1L]] <- data.frame(Case = id, Grid = grid,
        LogLikError = error[1], MomentError = error[2], ProbabilityError = error[3],
        Pass = matched, Error = external$error, Warnings = paste(external$warnings, collapse = ' | '))
      if (matched || nzchar(external$error)) break
    }
    if (matched) for (a in 1:6) {
      differences <- vapply(c(1e-4, 5e-5), function(h) {
        plus <- minus <- case
        step <- if (a == 6 && case$variance > 0) min(h, case$variance / 2) else h
        if (a <= 5) {
          plus$parameters[a] <- plus$parameters[a] + step
          minus$parameters[a] <- minus$parameters[a] - step
        } else {
          plus$variance <- plus$variance + step
          minus$variance <- max(0, minus$variance - step)
        }
        fp <- stress_capture(stress_tam(plus, grids[[grid]], template))
        fm <- if (a == 6 && case$variance == 0) external else
          stress_capture(stress_tam(minus, grids[[grid]], template))
        saveRDS(list(plus = fp, minus = fm, step = step), file.path(output, paste0(id, '-gradient-', a, '-', h, '.rds')))
        if (is.null(fp$value) || is.null(fm$value)) return(NA_real_)
        (fp$value$loglik - fm$value$loglik) / if (a == 6 && case$variance == 0) step else 2 * step
      }, numeric(1))
      compared <- if (a == 6 && case$variance == 0) 2 * differences[2] - differences[1] else differences
      error <- max(abs(compared - refined$gradient[a]))
      gradient_rows[[length(gradient_rows) + 1L]] <- data.frame(Case = id, Parameter = names6[a],
        Analytic = refined$gradient[a], Step1 = differences[1], Step2 = differences[2],
        Error = error, Pass = is.finite(error) && error <= 1e-5)
    }
    saveRDS(list(case = id, runs = runs, best_before_refinement = best, refined = refined,
      refinement_parameter_difference = max(abs(best$par - refined$par)),
      refinement_loglik_difference = abs(best$loglik - refined$loglik), sources = sources),
      file.path(output, paste0(id, '-completed.rds')))
    write.csv(do.call(rbind, external_rows), 'inst/validation/local-testlet-estimation-0.2.4-tam.csv', row.names = FALSE)
    if (length(gradient_rows)) write.csv(do.call(rbind, gradient_rows),
      'inst/validation/local-testlet-estimation-0.2.4-gradients.csv', row.names = FALSE)
  }
  cat('Bounded estimation run complete; inspect failures and numerical qualification.\n')
}

if (sys.nframe() == 0L) run_testlet_estimation()
