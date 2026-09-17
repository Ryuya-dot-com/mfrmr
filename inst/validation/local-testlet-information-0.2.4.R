# Repository-only curvature and person-count qualification; see companion plan.
source('inst/validation/local-testlet-estimation-0.2.4.R')
source('inst/validation/mml-independent-rsm-information-0.2.4.R')

testlet_score_information <- function(fixture, par, order, h) {
  free <- if (par[6] == 0) 1:5 else 1:6
  out <- vapply(free, function(a) {
    plus <- minus <- par
    plus[a] <- plus[a] + h
    minus[a] <- minus[a] - h
    -(testlet_estimation_evaluate(fixture, plus, order)$gradient[free] -
      testlet_estimation_evaluate(fixture, minus, order)$gradient[free]) / (2 * h)
  }, numeric(length(free)))
  dimnames(out) <- list(names(par)[free], names(par)[free])
  out
}

run_testlet_information <- function() {
  output <- 'validation-results/local-testlet-information-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  saved <- 'validation-results/local-testlet-estimation-20260917'
  cases <- lapply(c('original', 'clustered', 'boundary'), function(id) {
    bridge <- readRDS(file.path(saved, paste0('stop-bridge-', id, '_saved.rds')))
    list(id = id, fixture = bridge$entry$fixture, fit = bridge$result$captured$value)
  })
  names(cases) <- vapply(cases, function(x) x$id, character(1))
  sources <- tools::md5sum(c('inst/validation/local-testlet-information-0.2.4.R',
    'inst/validation/local-testlet-estimation-0.2.4.R', 'inst/validation/local-testlet-stress-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R', 'inst/validation/mml-independent-rsm-information-0.2.4.R'))
  inputs <- tools::md5sum(c(file.path(saved, 'plan.rds'), file.path(saved, 'boundary-completed.rds'),
    file.path(saved, paste0('stop-bridge-', names(cases), '_saved.rds'))))
  saveRDS(list(cases = cases, sources = sources, inputs = inputs, started = Sys.time(),
    parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo(),
    design = readLines('inst/validation/local-testlet-information-0.2.4.md')), file.path(output, 'plan.rds'))
  checks <- list()
  check <- function(id, quantity, error, tolerance) {
    checks[[length(checks) + 1L]] <<- data.frame(Case = id, Quantity = quantity,
      Error = error, Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
    write.csv(do.call(rbind, checks), 'inst/validation/local-testlet-information-0.2.4-checks.csv', row.names = FALSE)
  }
  template <- readRDS('validation-results/local-testlet-tam-reference-20260917/evidence.rds')$fits[['variance_0.49']]
  summary <- targets <- profiles <- list()
  completed <- list()
  for (case in cases) {
    id <- case$id
    par <- case$fit$par
    fixture <- case$fixture
    free <- if (par[6] == 0) 1:5 else 1:6
    cat('INFORMATION', id, '\n')
    bridge <- testlet_estimation_evaluate(fixture, par, 181L)
    check(id, 'saved_point_bridge', max(abs(c(bridge$loglik - case$fit$loglik,
      bridge$gradient - case$fit$gradient, bridge$moments - case$fit$moments))), 1e-9)
    reference <- list()
    for (q in c(121L, 181L)) for (h in c(.001, .0005))
      reference[[paste(q, h)]] <- testlet_score_information(fixture, par, q, h)
    raw <- reference[['181 5e-04']]
    if (is.null(raw)) raw <- reference[[length(reference)]]
    H <- (raw + t(raw)) / 2
    scale <- pmax(1, sqrt(abs(outer(diag(H), diag(H)))))
    for (label in names(reference)) {
      check(id, paste0('score_asymmetry_', label), max(abs(reference[[label]] - t(reference[[label]])) / scale), 1e-5)
      check(id, paste0('score_information_', label), max(abs(reference[[label]] - H) / scale), 1e-5)
    }
    eigenvalues <- eigen(H, symmetric = TRUE, only.values = TRUE)$values
    external_history <- list()
    external_objective <- function(x) {
      current <- par
      current[free] <- x
      result <- stress_capture(stress_tam(list(fixture = fixture, parameters = current[1:5], variance = current[6]),
        seq(-7, 7, length.out = 41), template))
      external_history[[length(external_history) + 1L]] <<- list(par = current, result = result)
      if (is.null(result$value)) stop(result$error)
      -result$value$loglik
    }
    external <- stress_capture(lapply(c(.001, .0005), function(h)
      mml_independent_central_hessian(external_objective, par[free], h)))
    saveRDS(list(case = case, reference = reference, H = H, eigenvalues = eigenvalues,
      external = external, external_history = external_history, sources = sources), file.path(output, paste0(id, '-information.rds')))
    if (is.null(external$value)) {
      check(id, 'tam_information_error', Inf, 1e-5)
      next
    }
    for (i in 1:2) check(id, paste0('tam_information_step_', i), max(abs(external$value[[i]] - H) / scale), 1e-5)
    positive <- min(eigenvalues) > 0 && all(vapply(external$value, function(x)
      min(eigen(x, symmetric = TRUE, only.values = TRUE)$values) > 0, logical(1)))
    check(id, 'positive_definite', if (positive) 0 else Inf, 0)
    if (!positive) next
    covariance <- chol2inv(chol(H))
    dimnames(covariance) <- dimnames(H)
    map <- diag(length(free))
    rownames(map) <- names(par)[free]
    extra <- matrix(0, 4, length(free), dimnames = list(c('beta3', 'rater2', 'tau2', 'rater1_minus_rater2'), NULL))
    extra[1, 2:3] <- -1
    extra[2, 4] <- -1
    extra[3, 5] <- -1
    extra[4, 4] <- 2
    map <- rbind(map, extra)
    se <- sqrt(diag(map %*% covariance %*% t(map)))
    for (i in 1:2) {
      other <- chol2inv(chol(external$value[[i]]))
      check(id, paste0('covariance_step_', i), max(abs(other - covariance) / sqrt(outer(diag(covariance), diag(covariance)))), 1e-5)
      other_se <- sqrt(diag(map %*% other %*% t(map)))
      check(id, paste0('expanded_se_step_', i), max(abs(other_se / se - 1)), 1e-5)
    }
    conditional <- matrix(0, length(free), length(free))
    conditional[1:5, 1:5] <- chol2inv(chol(H[1:5, 1:5]))
    fixed_se <- sqrt(diag(map %*% conditional %*% t(map)))
    if (length(free) == 6) fixed_se[rownames(map) == 'variance'] <- NA_real_
    targets[[id]] <- data.frame(Case = id, Target = rownames(map), Estimate = as.vector(map %*% par[free]),
      JointCurvatureSE = if (par[6] > 0) se else NA_real_, VarianceFixedCurvatureSE = fixed_se,
      IntervalAvailable = FALSE)
    if (par[6] == 0) targets[[id]] <- rbind(targets[[id]], data.frame(Case = id, Target = 'variance',
      Estimate = 0, JointCurvatureSE = NA_real_, VarianceFixedCurvatureSE = NA_real_, IntervalAvailable = FALSE))
    schur <- if (length(free) == 6) as.numeric(H[6,6] - H[6,1:5] %*% conditional[1:5,1:5] %*% H[1:5,6]) else NA_real_
    if (length(free) == 6) check(id, 'schur_covariance_identity', abs(schur * covariance[6,6] - 1), 1e-10)
    # New nuisance fits are only at the prespecified nearby variances.
    if (par[6] > 0) {
      curvatures <- numeric(2)
      deltas <- c(.01, .005) * max(1, par[6])
      for (i in 1:2) {
        likelihoods <- numeric(2)
        for (side in 1:2) {
          v <- par[6] + c(-1,1)[side] * deltas[i]
          fit <- testlet_bounded_fit(fixture, par, v, orders = c(121L, 181L, 241L))
          saveRDS(fit, file.path(output, paste0(id, '-profile-', i, '-', side, '.rds')))
          value <- fit$captured$value
          likelihoods[side] <- if (is.null(value)) NA_real_ else value$loglik
          check(id, paste0('profile_nuisance_', i, '_', side),
            if (is.null(value)) Inf else value$nuisance_score, 1e-5)
          profiles[[length(profiles)+1L]] <- data.frame(Case = id, Variance = v,
            LogLik = likelihoods[side], Convergence = if (is.null(value)) NA_integer_ else value$convergence,
            Error = fit$captured$error)
        }
        curvatures[i] <- -(sum(likelihoods) - 2 * bridge$loglik) / deltas[i]^2
        check(id, paste0('profile_schur_', i), abs(curvatures[i] / schur - 1), 1e-3)
      }
    } else {
      h <- c(1e-4, 5e-5)
      slopes <- vapply(h, function(v) {
        fit <- testlet_bounded_fit(fixture, par, v, orders = c(121L, 181L, 241L))
        saveRDS(fit, file.path(output, paste0(id, '-profile-', v, '.rds')))
        value <- fit$captured$value
        check(id, paste0('profile_nuisance_', v), if (is.null(value)) Inf else value$nuisance_score, 1e-5)
        profiles[[length(profiles)+1L]] <<- data.frame(Case = id, Variance = v,
          LogLik = if (is.null(value)) NA_real_ else value$loglik,
          Convergence = if (is.null(value)) NA_integer_ else value$convergence, Error = fit$captured$error)
        if (is.null(value)) return(NA_real_)
        (value$loglik - bridge$loglik) / v
      }, numeric(1))
      check(id, 'boundary_profile_right_score', abs(2 * slopes[2] - slopes[1] - bridge$gradient[6]), 1e-4)
    }
    summary[[id]] <- data.frame(Case = id, Variance = par[6], InformationDimension = length(free),
      MinimumEigenvalue = min(eigenvalues), ConditionNumber = max(eigenvalues) / min(eigenvalues),
      JointVarianceSE = if (par[6] > 0) sqrt(covariance[6,6]) else NA_real_,
      VarianceSEWithStructureFixed = if (par[6] > 0) 1 / sqrt(H[6,6]) else NA_real_,
      ProfileInformation = schur, BoundaryRightScore = if (par[6] == 0) bridge$gradient[6] else NA_real_,
      IntervalAvailable = FALSE)
    completed[[id]] <- list(H = H, covariance = covariance, summary = summary[[id]])
    write.csv(do.call(rbind, summary), 'inst/validation/local-testlet-information-0.2.4-summary.csv', row.names = FALSE)
    write.csv(do.call(rbind, targets), 'inst/validation/local-testlet-information-0.2.4-se.csv', row.names = FALSE)
    write.csv(do.call(rbind, profiles), 'inst/validation/local-testlet-information-0.2.4-profiles.csv', row.names = FALSE)
  }
  # Person partitioning and repeated-table arithmetic; no new population draws.
  case <- cases$original
  single <- lapply(1:6, function(i) {
    fixture <- case$fixture
    fixture$response <- fixture$response[i,,drop = FALSE]
    testlet_estimation_evaluate(fixture, case$fit$par, 181L)
  })
  scale_rows <- list()
  for (n in c(1L,7L,17L,120L)) {
    index <- rep(1:6, length.out = n)
    fixture <- case$fixture
    fixture$response <- fixture$response[index,,drop = FALSE]
    rownames(fixture$response) <- paste0('P', seq_len(n))
    evaluated <- stress_capture(testlet_estimation_evaluate(fixture, case$fit$par, 181L))
    stopifnot(!is.null(evaluated$value))
    expected_score <- Reduce('+', lapply(index, function(i) single[[i]]$gradient))
    expected_loglik <- sum(vapply(index, function(i) single[[i]]$loglik, numeric(1)))
    expected_moments <- do.call(rbind, lapply(index, function(i) single[[i]]$moments))
    error <- max(abs(c(evaluated$value$loglik - expected_loglik,
      evaluated$value$gradient - expected_score, evaluated$value$moments - expected_moments)))
    check(paste0('N',n), 'partition_invariance', error, 1e-9)
    scale_rows[[as.character(n)]] <- data.frame(Persons = n, LogLik = evaluated$value$loglik,
      PartitionError = error, Seconds = evaluated$elapsed,
      InputStatus = testlet_estimation_input(fixture))
    saveRDS(list(fixture = fixture, evaluated = evaluated), file.path(output, paste0('N', n, '.rds')))
    if (n == 120L && !is.null(completed$original)) {
      H <- testlet_score_information(fixture, case$fit$par, 181L, .0005)
      H <- (H + t(H)) / 2
      reference <- completed$original$H
      check('N120', 'information_times_20', max(abs(H / 20 - reference) / pmax(1, abs(reference))), 1e-8)
      covariance <- chol2inv(chol(H))
      check('N120', 'se_divided_by_sqrt20', max(abs(sqrt(diag(covariance) / diag(completed$original$covariance)) * sqrt(20) - 1)), 1e-8)
      external <- stress_capture(stress_tam(list(fixture = fixture, parameters = case$fit$par[1:5],
        variance = case$fit$par[6]), seq(-7, 7, length.out = 41), template))
      saveRDS(list(H = H, covariance = covariance, external = external), file.path(output, 'N120-information.rds'))
      check('N120', 'tam_likelihood_moments', if (is.null(external$value)) Inf else
        max(abs(c(external$value$loglik - evaluated$value$loglik,
          external$value$moments - evaluated$value$moments))), 1e-6)
    }
  }
  write.csv(do.call(rbind, scale_rows), 'inst/validation/local-testlet-information-0.2.4-persons.csv', row.names = FALSE)
  saveRDS(list(completed = completed, checks = checks, sources = sources, inputs = inputs, finished = Sys.time()),
    file.path(output, 'completed.rds'))
  print(do.call(rbind, summary))
  print(table(do.call(rbind, checks)$Pass))
}

if (sys.nframe() == 0L) run_testlet_information()
