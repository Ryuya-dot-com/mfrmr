# Frozen same-sample calibration pilot; see the prespecified companion.
source('inst/validation/local-testlet-posterior-quantiles-0.2.4.R')

testlet_pilot_generate <- function(n, variance, seed) {
  RNGkind('Mersenne-Twister', 'Inversion', 'Rejection')
  set.seed(seed)
  fixture <- local_testlet_fixture()
  par <- c(fixture$parameters, variance = variance)
  theta <- rnorm(n)
  local_normals <- matrix(rnorm(2 * n), n, 2)
  gamma <- sqrt(variance) * local_normals
  uniforms <- matrix(runif(6 * n), n, 6)
  response <- eta <- matrix(0, n, 6)
  probabilities <- array(0, c(n, 3, 6))
  ownership_error <- adjacent_error <- 0
  for (i in 1:6) {
    r <- fixture$map$Rater[i]
    beta <- sum(fixture$criterion_contrasts[fixture$map$Criterion[i], ] * par[2:3])
    severity <- fixture$rater_contrasts[r] * par[4]
    eta[, i] <- par[1] + theta - beta - severity + gamma[, r]
    probabilities[, , i] <- local_testlet_probabilities(eta[, i], par[5])
    p <- probabilities[, , i]
    response[, i] <- as.integer(uniforms[, i] > p[, 1]) + as.integer(uniforms[, i] > p[, 1] + p[, 2])
    ownership_error <- max(ownership_error, abs(eta[, i] - theta + beta + severity - par[1] - gamma[, r]))
    adjacent_error <- max(adjacent_error, abs(log(p[, 2] / p[, 1]) - eta[, i] + par[5]),
      abs(log(p[, 3] / p[, 2]) - eta[, i] - par[5]))
  }
  dimnames(response) <- list(paste0('P', seq_len(n)), colnames(fixture$response))
  fixture$response <- response
  list(fixture = fixture, par = par, theta = theta, local_normals = local_normals, gamma = gamma,
    uniforms = uniforms, eta = eta, probabilities = probabilities, seed = seed,
    audit = c(normalization = max(abs(apply(probabilities, c(1, 3), sum) - 1)),
      ownership = ownership_error, adjacent_logits = adjacent_error))
}

testlet_pilot_targets <- function(generated) {
  people <- lapply(seq_along(generated$theta), function(p) p)
  pairs <- lapply(1:4, function(k) c(2L * k - 1L, 2L * k))
  groups <- c(people, pairs)
  data.frame(Target = c(paste0('P', seq_along(people)),
      vapply(pairs, function(p) paste0('P', p[1], '_minus_P', p[2]), character(1))),
    Kind = c(rep('person', length(people)), rep('difference', 4)),
    P1 = vapply(groups, `[`, integer(1), 1),
    P2 = vapply(groups, function(p) if (length(p) == 1) NA_integer_ else p[2], integer(1)),
    Truth = vapply(groups, function(p) if (length(p) == 1) generated$theta[p]
      else generated$theta[p[1]] - generated$theta[p[2]], numeric(1)))
}

testlet_pilot_score <- function(generated, par, method, unavailable = '') {
  targets <- testlet_pilot_targets(generated)
  rows <- attempts <- list()
  rules <- rbind(c(61L, 41L), c(121L, 81L), c(181L, 121L), c(241L, 181L))
  values <- list()
  get_value <- function(order) {
    key <- as.character(order)
    if (is.null(values[[key]])) values[[key]] <<- testlet_estimation_evaluate(generated$fixture, par, order)
    values[[key]]
  }
  for (i in seq_len(nrow(targets))) {
    target_row <- targets[i, ]
    members <- na.omit(c(target_row$P1, target_row$P2))
    previous <- chosen <- NULL
    target_attempts <- list()
    if (!nzchar(unavailable)) for (k in seq_len(nrow(rules))) {
      captured <- stress_capture({
        point <- get_value(rules[k, 1])
        moments <- point$moments[members, 1:2, drop = FALSE]
        center <- if (length(members) == 1) moments[1, 1] else moments[1, 1] - moments[2, 1]
        target <- list(fixture = generated$fixture, par = par, persons = members,
          lognormalizer = sum(point$person_loglik[members]))
        density <- testlet_posterior_density_function(target, rules[k, 1], rules[k, 2])
        integrals <- lapply(list(c(-Inf, center), c(center, Inf),
          if (target_row$Truth <= center) c(-Inf, target_row$Truth) else c(target_row$Truth, Inf)),
          function(bounds) {
            z <- integrate(density, bounds[1], bounds[2], rel.tol = 1e-8, abs.tol = 1e-8, subdivisions = 200L)
            list(bounds = bounds, value = z$value, error = z$abs.error,
              subdivisions = z$subdivisions, message = z$message)
          })
        mass <- integrals[[1]]$value + integrals[[2]]$value
        stopifnot(is.finite(mass), mass > 0)
        tail <- integrals[[3]]$value / mass
        cdf <- if (target_row$Truth <= center) tail else 1 - tail
        integration_error <- (integrals[[3]]$error + integrals[[1]]$error + integrals[[2]]$error) / mass
        changes <- if (is.null(previous)) c(Inf, Inf) else c(abs(cdf - previous$cdf), abs(center - previous$mean))
        ambiguous <- min(abs(cdf - c(.025, .975))) <= 1e-6
        list(cdf = cdf, mass = mass, mean = center, sd = sqrt(sum(moments[, 2]^2)),
          integration_error = integration_error, changes = changes, ambiguous = ambiguous, integrals = integrals,
          ready = all(is.finite(c(cdf, center, changes, integration_error))) &&
            cdf >= 0 && cdf <= 1 && abs(mass - 1) <= 1e-7 &&
            all(changes <= 1e-6) && integration_error <= 1e-6 && !ambiguous)
      })
      target_attempts[[k]] <- list(rule = rules[k, ], captured = captured)
      if (!is.null(captured$value) && !length(captured$warnings)) {
        if (captured$value$ready) { chosen <- target_attempts[[k]]; break }
        previous <- captured$value
      }
    }
    ready <- !is.null(chosen)
    rows[[i]] <- cbind(target_row, Method = method, Available = ready,
      CDF = if (ready) chosen$captured$value$cdf else NA_real_,
      Mean = if (ready) chosen$captured$value$mean else NA_real_,
      SD = if (ready) chosen$captured$value$sd else NA_real_,
      Covered = if (ready) chosen$captured$value$cdf >= .025 && chosen$captured$value$cdf <= .975 else NA,
      LocalOrder = if (ready) chosen$rule[1] else NA_integer_,
      MidpointOrder = if (ready && length(members) == 2) chosen$rule[2] else NA_integer_,
      Reason = if (ready) '' else if (nzchar(unavailable)) unavailable else 'cdf_unresolved')
    attempts[[target_row$Target]] <- target_attempts
  }
  list(rows = do.call(rbind, rows), attempts = attempts)
}

run_testlet_calibration_pilot <- function(generate_only = FALSE) {
  prefix <- 'inst/validation/local-testlet-calibration-pilot-0.2.4'
  output <- 'validation-results/local-testlet-calibration-pilot-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  sources <- tools::md5sum(c(paste0(prefix, '.R'),
    'inst/validation/local-testlet-posterior-quantiles-0.2.4.R',
    'inst/validation/local-testlet-estimation-0.2.4.R', 'inst/validation/local-testlet-stress-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R'))
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$sources, sources), identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  } else {
    cells <- data.frame(Cell = 1:4, N = c(24L, 120L, 24L, 120L), Variance = c(0, 0, .49, .49))
    manifest <- do.call(rbind, lapply(1:4, function(k)
      data.frame(Cell = cells$Cell[k], N = cells$N[k], Variance = cells$Variance[k], Replicate = 1:10)))
    manifest$Seed <- 260917000L + 1000L * manifest$Cell + manifest$Replicate
    manifest$ID <- sprintf('cell-%02d-rep-%02d', manifest$Cell, manifest$Replicate)
    data_paths <- character(nrow(manifest))
    for (j in seq_len(nrow(manifest))) {
      spec <- manifest[j, ]
      generated <- testlet_pilot_generate(spec$N, spec$Variance, spec$Seed)
      stopifnot(max(generated$audit) <= 1e-12,
        identical(generated, testlet_pilot_generate(spec$N, spec$Variance, spec$Seed)))
      data_paths[j] <- file.path(output, paste0(spec$ID, '-data.rds'))
      saveRDS(generated, data_paths[j])
    }
    plan <- list(manifest = manifest, sources = sources, data_hashes = tools::md5sum(data_paths),
      start = setNames(c(0, 0, 0, 0, -.5, .25), c(names(local_testlet_fixture()$parameters), 'variance')),
      design = readLines(paste0(prefix, '.md')), created = Sys.time(),
      parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo())
    saveRDS(plan, plan_path)
    write.csv(manifest, paste0(prefix, '-manifest.csv'), row.names = FALSE)
  }
  if (generate_only) { cat('FROZEN', nrow(plan$manifest), 'datasets\n'); return(invisible(plan)) }
  for (j in seq_len(nrow(plan$manifest))) {
    spec <- plan$manifest[j, ]
    path <- file.path(output, paste0(spec$ID, '-result.rds'))
    if (file.exists(path)) {
      old <- readRDS(path)
      stopifnot(identical(old$sources, sources), identical(old$data_hash, plan$data_hashes[j]))
      cat('REUSE', spec$ID, '\n'); next
    }
    generated <- readRDS(names(plan$data_hashes)[j])
    cat('FIT', spec$ID, 'N', spec$N, 'variance', spec$Variance, '\n')
    fit_path <- file.path(output, paste0(spec$ID, '-fit.rds'))
    if (file.exists(fit_path)) {
      fit_record <- readRDS(fit_path)
      stopifnot(identical(fit_record$sources, sources), identical(fit_record$data_hash, plan$data_hashes[j]))
      fit <- fit_record$fit
    } else {
      fit <- stress_capture(testlet_bounded_fit(generated$fixture, plan$start))
      saveRDS(list(fit = fit, sources = sources, data_hash = plan$data_hashes[j]), fit_path)
    }
    value <- if (!is.null(fit$value)) fit$value$captured$value else NULL
    reasons <- character()
    if (is.null(value)) reasons <- c(reasons, 'fit_error') else {
      if (value$convergence != 0) reasons <- c(reasons, paste0('native_code_', value$convergence))
      if (!is.finite(value$projected_score) || value$projected_score > 1e-5) reasons <- c(reasons, 'projected_score')
      if (value$search_boundary) reasons <- c(reasons, 'search_boundary')
    }
    warning_text <- c(fit$warnings, if (!is.null(fit$value)) fit$value$captured$warnings)
    error_text <- c(fit$error, if (!is.null(fit$value)) fit$value$captured$error)
    if (length(warning_text)) reasons <- c(reasons, 'fit_warning')
    ready <- !length(reasons)
    status <- cbind(spec, FitReady = ready, Reason = paste(reasons, collapse = ' | '),
      NativeCode = if (is.null(value)) NA_integer_ else value$convergence,
      ProjectedScore = if (is.null(value)) NA_real_ else value$projected_score,
      EstimatedVariance = if (is.null(value)) NA_real_ else value$par[6],
      BoundaryZero = if (is.null(value)) NA else value$par[6] == 0,
      Error = paste(error_text[nzchar(error_text)], collapse = ' | '),
      Warnings = paste(warning_text, collapse = ' | '), FitSeconds = fit$elapsed)
    cat('SCORE', spec$ID, 'ready', ready, 'reason', paste(reasons, collapse = ' | '), '\n')
    oracle <- testlet_pilot_score(generated, generated$par, 'oracle')
    plugin <- testlet_pilot_score(generated, if (ready) value$par else generated$par,
      'plugin', if (ready) '' else paste(reasons, collapse = ' | '))
    result <- list(spec = spec, sources = sources, data_hash = plan$data_hashes[j], status = status,
      fit = fit, oracle = oracle, plugin = plugin, finished = Sys.time())
    saveRDS(result, path)
    cat('DONE', spec$ID, 'oracle', sum(oracle$rows$Available), 'plugin', sum(plugin$rows$Available), '\n')
  }
  stopifnot(identical(sources, tools::md5sum(names(sources))),
    identical(plan$data_hashes, tools::md5sum(names(plan$data_hashes))))
  cat('PILOT COMPLETE: 40 datasets retained\n')
}

if (sys.nframe() == 0L) run_testlet_calibration_pilot('generate' %in% commandArgs(TRUE))
