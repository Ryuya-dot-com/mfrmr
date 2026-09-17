# Repository-only scoring-sensitivity experiment; no corrected SE or interval.
source('inst/validation/local-testlet-estimation-0.2.4.R')

testlet_person_mean_jacobian <- function(fixture, par, order, h, log_variance = FALSE) {
  free <- if (par[6] == 0) 1:5 else 1:6
  stopifnot(!log_variance || par[6] > 0)
  coordinate <- par
  if (log_variance) coordinate[6] <- log(par[6])
  mean_at <- function(x) {
    if (log_variance) x[6] <- exp(x[6])
    testlet_estimation_evaluate(fixture, x, order)$moments[, 'ThetaMean']
  }
  out <- vapply(free, function(a) {
    plus <- minus <- coordinate
    plus[a] <- plus[a] + h
    minus[a] <- minus[a] - h
    (mean_at(plus) - mean_at(minus)) / (2 * h)
  }, numeric(nrow(fixture$response)))
  matrix(out, nrow(fixture$response), length(free),
    dimnames = list(rownames(fixture$response), names(par)[free]))
}

run_testlet_person_uncertainty <- function() {
  prefix <- 'inst/validation/local-testlet-person-uncertainty-0.2.4'
  output <- 'validation-results/local-testlet-person-uncertainty-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  input <- 'inst/validation/local-testlet-information-0.2.4-evidence.rds'
  saved <- readRDS(input)
  sources <- tools::md5sum(c(paste0(prefix, '.R'),
    'inst/validation/local-testlet-estimation-0.2.4.R',
    'inst/validation/local-testlet-stress-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R'))
  plan <- list(cases = saved$plan$cases, information = saved$completed$completed,
    sources = sources, input = tools::md5sum(input), design = readLines(paste0(prefix, '.md')),
    started = Sys.time(), parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo())
  saveRDS(plan, file.path(output, 'plan.rds'))
  checks <- results <- persons <- pairs <- summaries <- list()
  check <- function(id, quantity, error, tolerance) {
    checks[[length(checks) + 1L]] <<- data.frame(Case = id, Quantity = quantity,
      Error = error, Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
    write.csv(do.call(rbind, checks), paste0(prefix, '-checks.csv'), row.names = FALSE)
  }
  for (case in plan$cases) {
    id <- case$id
    cat('PERSON SENSITIVITY', id, '\n')
    captured <- stress_capture({
      par <- case$fit$par
      free <- if (par[6] == 0) 1:5 else 1:6
      C <- plan$information[[id]]$covariance
      stopifnot(identical(colnames(C), names(par)[free]))
      anchor <- testlet_estimation_evaluate(case$fixture, par, 181L)$moments[, 1:2, drop = FALSE]
      reference <- list()
      for (q in c(121L, 181L)) for (h in c(.001, .0005))
        reference[[paste(q, h)]] <- testlet_person_mean_jacobian(case$fixture, par, q, h)
      J <- tail(reference, 1)[[1]]
      for (label in names(reference)) check(id, paste0('mean_jacobian_', label),
        max(abs(reference[[label]] - J)), 1e-6)
      V <- anchor[, 2]^2
      check(id, 'alpha_integration_by_parts', max(abs(J[, 1] - (V - 1))), 1e-7)
      K <- J %*% C %*% t(J)
      check(id, 'calibration_covariance_symmetry', max(abs(K - t(K))), 1e-10)
      check(id, 'calibration_covariance_psd', max(0, -min(eigen(K, symmetric = TRUE)$values)), 1e-10)
      pair <- t(combn(nrow(J), 2))
      pair_J <- J[pair[, 1], , drop = FALSE] - J[pair[, 2], , drop = FALSE]
      pair_variance <- rowSums((pair_J %*% C) * pair_J)
      pair_from_K <- diag(K)[pair[, 1]] + diag(K)[pair[, 2]] - 2 * K[pair]
      check(id, 'pair_contrast_identity', max(abs(pair_variance - pair_from_K)), 1e-10)
      scope <- if (par[6] > 0) 'six_parameter_local_sensitivity' else 'variance_fixed_zero_sensitivity'
      persons[[id]] <- data.frame(Case = id, Person = rownames(J), Scope = scope,
        Mean = anchor[, 1], ConditionalPosteriorSD = anchor[, 2],
        CalibrationSensitivityVariance = diag(K), RatioToConditionalVariance = diag(K) / V,
        SensitivityVarianceAt20TimesInformation = diag(K) / 20,
        FullModelSensitivityVariance = if (par[6] > 0) diag(K) else NA_real_, IntervalAvailable = FALSE)
      pairs[[id]] <- data.frame(Case = id, Person1 = rownames(J)[pair[, 1]], Person2 = rownames(J)[pair[, 2]],
        Scope = scope, MeanDifference = anchor[pair[, 1], 1] - anchor[pair[, 2], 1],
        ConditionalDifferenceVariance = V[pair[, 1]] + V[pair[, 2]],
        CalibrationDifferenceVariance = pair_variance, CalibrationCovariance = K[pair],
        DiagonalOnlyCalibrationVariance = diag(K)[pair[, 1]] + diag(K)[pair[, 2]], IntervalAvailable = FALSE)
      log_J <- NULL
      if (par[6] > 0) {
        log_J <- testlet_person_mean_jacobian(case$fixture, par, 181L, .0005, TRUE)
        transform <- diag(c(rep(1, 5), 1 / par[6]))
        log_C <- transform %*% C %*% transform
        check(id, 'log_variance_coordinate_invariance', max(abs(log_J %*% log_C %*% t(log_J) - K)), 1e-6)
      }
      missing <- NULL
      if (id == 'original') {
        fixture <- case$fixture
        fixture$response <- rbind(fixture$response, MissingPerson = rep(NA_real_, 6))
        missing <- list(moments = testlet_estimation_evaluate(fixture, par, 121L)$moments,
          J = testlet_person_mean_jacobian(fixture, par, 121L, .0005))
        n <- nrow(fixture$response)
        check(id, 'missing_person_prior_and_sensitivity', max(abs(c(missing$moments[n, 1],
          missing$moments[n, 2] - 1, missing$J[n, ], missing$J[n, ] %*% C %*% missing$J[n, ]))), 1e-9)
        check(id, 'existing_person_mean_and_jacobian', max(abs(c(missing$moments[-n, 1] - anchor[, 1],
          missing$J[-n, ] - reference[[paste(121L, .0005)]]))), 1e-9)
      }
      mixtures <- list()
      for (rho in c(.01, .005)) {
        L <- t(chol(C))
        shifts <- rho * sqrt(length(free)) * cbind(L, -L)
        support <- matrix(par, 6, ncol(shifts), dimnames = list(names(par), NULL))
        support[free, ] <- support[free, ] + shifts
        stopifnot(all(is.finite(support)), all(support[6, ] >= 0))
        check(id, paste0('probe_covariance_', rho),
          max(abs(tcrossprod(shifts) / ncol(shifts) - rho^2 * C)), 1e-10)
        moments <- lapply(seq_len(ncol(support)), function(i)
          testlet_estimation_evaluate(case$fixture, support[, i], 181L)$moments[, 1:2, drop = FALSE])
        means <- vapply(moments, function(x) x[, 1], numeric(nrow(J)))
        variances <- vapply(moments, function(x) x[, 2]^2, numeric(nrow(J)))
        centered <- means - rowMeans(means)
        between <- tcrossprod(centered) / ncol(means)
        within <- rowMeans(variances)
        total <- rowMeans(variances + means^2) - rowMeans(means)^2
        check(id, paste0('total_variance_identity_', rho), max(abs(total - within - diag(between))), 1e-10)
        check(id, paste0('probe_linearized_mean_covariance_', rho), max(abs(between / rho^2 - K)), 1e-4)
        mixtures[[as.character(rho)]] <- list(rho = rho, support = support, means = means,
          variances = variances, within = within, between = between, total = total,
          scaled_within_change = (within - V) / rho^2)
      }
      check(id, 'probe_within_variance_change_stability',
        max(abs(mixtures[[1]]$scaled_within_change - mixtures[[2]]$scaled_within_change)), 1e-4)
      summaries[[id]] <- data.frame(Case = id, Scope = scope, Variance = par[6],
        MinCalibrationRatio = min(diag(K) / V), MaxCalibrationRatio = max(diag(K) / V),
        MinPairCovariance = min(K[pair]), MaxPairCovariance = max(K[pair]),
        HypotheticalNormalNegativeVarianceMass = if (par[6] > 0) pnorm(-par[6] / sqrt(C[6, 6])) else NA_real_,
        MinScaledWithinChange = min(mixtures[[2]]$scaled_within_change),
        MaxScaledWithinChange = max(mixtures[[2]]$scaled_within_change), IntervalAvailable = FALSE)
      list(J = J, C = C, K = K, anchor = anchor, reference = reference, log_J = log_J,
        missing = missing, mixtures = mixtures)
    })
    results[[id]] <- captured
    saveRDS(list(case = case, captured = captured, sources = sources), file.path(output, paste0(id, '.rds')))
    check(id, 'capture', if (!is.null(captured$value) && !length(captured$warnings)) 0 else Inf, 0)
    cat('COMPLETE', id, 'seconds', captured$elapsed, 'error', captured$error, '\n')
  }
  check('provenance', 'source_and_input_identity',
    if (identical(sources, tools::md5sum(names(sources))) && identical(plan$input, tools::md5sum(input))) 0 else Inf, 0)
  persons <- do.call(rbind, persons)
  pairs <- do.call(rbind, pairs)
  summaries <- do.call(rbind, summaries)
  write.csv(persons, paste0(prefix, '-persons.csv'), row.names = FALSE)
  write.csv(pairs, paste0(prefix, '-pairs.csv'), row.names = FALSE)
  write.csv(summaries, paste0(prefix, '-summary.csv'), row.names = FALSE)
  completed <- list(plan = plan, results = results, persons = persons, pairs = pairs,
    summaries = summaries, checks = do.call(rbind, checks), finished = Sys.time())
  saveRDS(completed, file.path(output, 'completed.rds'))
  saveRDS(completed, paste0(prefix, '-evidence.rds'))
  print(summaries)
  print(table(completed$checks$Pass))
  stopifnot(all(completed$checks$Pass))
}

if (sys.nframe() == 0L) run_testlet_person_uncertainty()
