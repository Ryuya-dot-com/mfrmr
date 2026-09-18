# Diagnosis on saved cases; never writes to the completed main-study directory.
source('inst/validation/local-testlet-main-coverage-0.2.4.R')

testlet_failure_integrals <- function(density, center, sd, truth, tolerance, partition) {
  bounds <- list(c(-Inf, center), c(center, Inf),
    if (truth <= center) c(-Inf, truth) else c(truth, Inf))
  integrals <- lapply(bounds, function(b) {
    cuts <- if (partition) center + c(-2, 0, 2) * sd else numeric()
    cuts <- sort(unique(c(b, cuts[cuts > b[1] & cuts < b[2]])))
    pieces <- lapply(seq_len(length(cuts) - 1L), function(j) {
      z <- integrate(density, cuts[j], cuts[j + 1L], rel.tol = tolerance,
        abs.tol = tolerance / (length(cuts) - 1L), subdivisions = 200L)
      list(bounds = cuts[c(j, j + 1L)], value = z$value, error = z$abs.error,
        subdivisions = z$subdivisions, message = z$message)
    })
    list(value = sum(vapply(pieces, `[[`, numeric(1), 'value')),
      error = sum(vapply(pieces, `[[`, numeric(1), 'error')), pieces = pieces)
  })
  mass <- integrals[[1]]$value + integrals[[2]]$value
  tail <- integrals[[3]]$value / mass
  cdf <- if (truth <= center) tail else 1 - tail
  list(mass = mass, cdf = cdf,
    integration_error = sum(vapply(integrals, `[[`, numeric(1), 'error')) / mass,
    integrals = integrals)
}

run_testlet_main_failures <- function() {
  prefix <- 'inst/validation/local-testlet-main-failures-0.2.4'
  main_prefix <- 'inst/validation/local-testlet-main-coverage-0.2.4'
  main <- 'validation-results/local-testlet-main-coverage-20260917'
  output <- 'validation-results/local-testlet-main-failures-20260918'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  original_plan <- readRDS(file.path(main, 'plan.rds'))
  marker <- readRDS(file.path(main, 'summary-complete.rds'))
  stopifnot(all(marker$audit$Pass),
    identical(marker$evidence, tools::md5sum(names(marker$evidence))))
  status <- read.csv(paste0(main_prefix, '-status.csv'))
  controls <- vapply(1:4, function(k) status$ID[status$Cell == k & status$FitReady][1], character(1))
  selected <- status[!status$FitReady | status$ID %in% controls, ]
  score_ids <- c('cell-04-rep-0237', 'cell-04-rep-0282')
  score_targets <- c('P90', 'P19_minus_P20')
  ids <- unique(c(selected$ID, score_ids))
  paths <- c(file.path(main, 'plan.rds'), file.path(main, 'summary-complete.rds'),
    names(marker$evidence), paste0(main_prefix, c('-status.csv', '-summaries.csv', '-paired.csv')),
    file.path(main, paste0(rep(ids, each = 2), rep(c('-data.rds', '-result.rds'), length(ids)))))
  inputs <- tools::md5sum(paths)
  sources <- tools::md5sum(unique(c(paste0(prefix, '.R'), names(original_plan$sources))))
  stopifnot(nrow(selected) == 12L, sum(!selected$FitReady) == 8L,
    !anyNA(c(inputs, sources)),
    identical(original_plan$sources, tools::md5sum(names(original_plan$sources))),
    identical(original_plan$inputs, tools::md5sum(names(original_plan$inputs))))
  identity <- list(inputs = inputs, sources = sources)
  plan <- testlet_main_checkpoint(file.path(output, 'plan.rds'), identity,
    list(selected = selected, controls = controls, start = original_plan$start,
      score_ids = score_ids, score_targets = score_targets,
      total_pgtol = 1e-5, tolerances = c(1e-10, 1e-12, 1e-12),
      partition = c(FALSE, FALSE, TRUE), design = readLines(paste0(prefix, '.md')),
      session = sessionInfo(), parent = system2('git', 'rev-parse HEAD', stdout = TRUE)))
  originals <- generated <- records <- score_records <- list()
  fit_rows <- score_rows <- list()
  for (id in ids) {
    old <- readRDS(file.path(main, paste0(id, '-result.rds')))
    originals[[id]] <- old[c('spec', 'status', 'fit', 'reference', 'control')]
    generated[[id]] <- readRDS(file.path(main, paste0(id, '-data.rds')))
    if (!id %in% selected$ID) next
    control <- old$control
    control$pgtol <- plan$total_pgtol / old$spec$N
    key <- c(identity, list(id = id, control = control))
    cat('FIT', id, '\n')
    fit <- testlet_main_checkpoint(file.path(output, paste0(id, '-fit.rds')), key,
      stress_capture(testlet_controlled_fit(generated[[id]]$fixture, plan$start, control)))
    value <- fit$value$captured$value
    reference <- testlet_main_checkpoint(file.path(output, paste0(id, '-reference.rds')), key,
      if (is.null(value)) NULL else stress_capture(testlet_estimation_evaluate(
        generated[[id]]$fixture, value$par, as.integer(tail(fit$value$history[, 'Order'], 1)) + 60L)))
    new_status <- testlet_main_status(old$spec, fit, reference)
    old_value <- old$fit$value$captured$value
    comparison <- if (is.null(value)) rep(NA_real_, 3) else c(
      value$loglik - old_value$loglik, max(abs(value$par - old_value$par)),
      max(abs(value$moments - old_value$moments)))
    same_boundary <- !is.null(value) && (value$par[6] == 0) == (old_value$par[6] == 0)
    close <- all(is.finite(comparison)) && all(abs(comparison) <= c(1e-7, 1e-4, 1e-5)) && same_boundary
    fit_rows[[id]] <- cbind(new_status, OriginalReady = old$status$FitReady,
      OriginalScore = old_value$projected_score, OriginalNativeCode = old_value$convergence,
      LogLikChange = comparison[1], ParameterChange = comparison[2], MomentChange = comparison[3],
      SameBoundary = same_boundary, SameSolution = close,
      Message = if (is.null(value)) '' else value$message)
    records[[id]] <- list(control = control, fit = fit, reference = reference, status = fit_rows[[id]])
    cat('DONE', id, 'ready', new_status$FitReady, 'same_solution', close, '\n')
  }
  for (j in seq_along(score_ids)) {
    id <- score_ids[j]; target_name <- score_targets[j]
    old <- readRDS(file.path(main, paste0(id, '-result.rds')))
    row <- old$plugin$rows[old$plugin$rows$Target == target_name, ]
    saved <- tail(old$plugin$attempts[[target_name]], 1)[[1]]$captured$value
    members <- na.omit(c(row$P1, row$P2))
    fixture <- generated[[id]]$fixture
    fixture$response <- fixture$response[members, , drop = FALSE]
    par <- old$fit$value$captured$value$par
    point <- testlet_main_checkpoint(file.path(output, paste0(id, '-score-point.rds')), identity,
      stress_capture(testlet_estimation_evaluate(fixture, par, 241L)))
    stopifnot(!nzchar(point$error), !length(point$warnings), !is.null(point$value))
    m <- point$value$moments[, 1:2, drop = FALSE]
    center <- if (nrow(m) == 1L) m[1, 1] else m[1, 1] - m[2, 1]
    sd <- sqrt(sum(m[, 2]^2))
    stopifnot(abs(center - saved$mean) <= 1e-12, abs(sd - saved$sd) <= 1e-12)
    target <- list(fixture = fixture, par = par, persons = seq_along(members),
      lognormalizer = sum(point$value$person_loglik))
    density <- testlet_posterior_density_function(target, 241L, 181L)
    probes <- list()
    for (k in seq_along(plan$tolerances)) {
      cat('SCORE PROBE', id, target_name, k, '\n')
      probes[[k]] <- testlet_main_checkpoint(file.path(output, paste0(id, '-probe-', k, '.rds')), identity,
        stress_capture(testlet_failure_integrals(density, center, sd, row$Truth,
          plan$tolerances[k], plan$partition[k])))
      z <- probes[[k]]$value
      clean <- !is.null(z) && !nzchar(probes[[k]]$error) && !length(probes[[k]]$warnings)
      score_rows[[length(score_rows) + 1L]] <- data.frame(ID = id, Target = target_name,
        Tolerance = plan$tolerances[k], Partition = plan$partition[k], CaptureReady = clean,
        OriginalCDF = saved$cdf, OriginalMassError = abs(saved$mass - 1),
        CDF = if (is.null(z)) NA_real_ else z$cdf,
        MassError = if (is.null(z)) NA_real_ else abs(z$mass - 1),
        IntegrationError = if (is.null(z)) NA_real_ else z$integration_error,
        CutoffDistance = if (is.null(z)) NA_real_ else min(abs(z$cdf - c(.025, .975))),
        Error = probes[[k]]$error, Warnings = paste(probes[[k]]$warnings, collapse = ' | '))
    }
    score_records[[id]] <- list(row = row, saved_attempts = old$plugin$attempts[[target_name]],
      target = target, point = point, probes = probes)
  }
  fits <- do.call(rbind, fit_rows)
  scores <- do.call(rbind, score_rows)
  scores$CDFSpread <- ave(scores$CDF, scores$ID, FUN = function(x) diff(range(x)))
  scores$NumericalAgreement <- with(scores, CaptureReady & is.finite(CDF) & CDF >= 0 & CDF <= 1 &
    MassError <= 1e-7 & IntegrationError <= 1e-6 & CDFSpread <= 1e-9)
  scores$OutsideOriginalAmbiguityBand <- scores$CutoffDistance > 1e-6
  unchanged <- identical(inputs, tools::md5sum(names(inputs))) &&
    identical(sources, tools::md5sum(names(sources)))
  result <- list(plan = plan, identity = identity, originals = originals, generated = generated,
    records = records, score_records = score_records, fits = fits, scores = scores,
    original_inputs_unchanged = unchanged, completed = Sys.time())
  testlet_main_save(result, file.path(output, 'completed.rds'))
  testlet_main_save(result, paste0(prefix, '-evidence.rds'))
  write.csv(fits, paste0(prefix, '-fits.csv'), row.names = FALSE)
  write.csv(scores, paste0(prefix, '-scoring.csv'), row.names = FALSE)
  print(fits[, c('ID', 'OriginalReady', 'NativeCode', 'ProjectedScore', 'FitReady', 'SameSolution')])
  print(scores)
  # Keep evidence even if the candidate fails; do not retry or relax these checks.
  stopifnot(unchanged, all(fits$FitReady), all(fits$SameSolution), all(scores$NumericalAgreement))
  invisible(result)
}

if (sys.nframe() == 0L) run_testlet_main_failures()
