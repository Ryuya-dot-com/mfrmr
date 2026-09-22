# Repository replay; estimation and historical evidence remain unchanged.
source('inst/validation/population-identifiability-review-0.2.4.R')

population_output_replay <- function(stage, directory) {
  stopifnot(stage %in% c('before', 'after'))
  pkgload::load_all('.', quiet = TRUE)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  inputs <- c('inst/validation/population-variance-profile-evidence-0.2.4.rds',
    'inst/validation/population-variance-profile-refinement-evidence-0.2.4.rds',
    'inst/validation/observation-weight-readiness-repair-evidence-0.2.4.rds')
  paths <- c(list.files('R', pattern = '[.]R$', full.names = TRUE), inputs,
    'inst/validation/population-output-contract-0.2.4.R')
  payload <- tools::md5sum(paths)
  main <- readRDS(inputs[1]); weights <- readRDS(inputs[3])
  fits <- lapply(main$cases, `[[`, 'fit')
  unit_ids <- names(weights$results)[grepl('coverage-', names(weights$results))]
  fits <- c(fits, setNames(lapply(unit_ids, function(id) weights$results[[id]]$result$fit), unit_ids))
  before <- if (stage == 'after') readRDS(file.path(directory, 'before.rds')) else NULL
  if (!is.null(before)) stopifnot(identical(before$payload[inputs], payload[inputs]))
  results <- rows <- list(); started <- Sys.time()
  capture <- function(expr) tryCatch(force(expr), error = identity)
  for (id in names(fits)) {
    fit <- fits[[id]]
    data <- fit$prep$data[fit$prep$data$Person == fit$prep$data$Person[1], , drop = FALSE]
    original <- as.character(data$Person[1]); data$Person <- 'NEW'
    pd <- fit$population$person_table
    if (is.data.frame(pd)) {pd <- pd[pd$Person == original, , drop = FALSE]; pd$Person <- 'NEW'}
    args <- list(fit = fit, new_data = data, person_data = pd,
      scoring_quad_points = 121L, n_draws = 3L, seed = 20260910L)
    prediction <- capture(do.call(predict_mfrm_units, args))
    pv <- capture(do.call(sample_mfrm_plausible_values, args))
    args$readiness_policy <- 'review'
    review <- do.call(predict_mfrm_units, args)
    review_pv <- do.call(sample_mfrm_plausible_values, args)
    active <- isTRUE(fit$config$population_spec$active) || isTRUE(fit$config$population_active)
    row <- data.frame(Case = id, PopulationActive = active,
      DefaultPredictionReturned = !inherits(prediction, 'error'),
      DefaultPVReturned = !inherits(pv, 'error'),
      SourceScoringReady = review$settings$source_scoring_ready,
      InferenceReady = mfrmr:::mfrm_inference_ready(fit),
      NumericalValuesUnchanged = NA, DrawsUnchanged = NA)
    if (!is.null(before)) {
      old <- before$results[[id]]
      numeric <- vapply(old$review$estimates, is.numeric, logical(1))
      row$NumericalValuesUnchanged <- identical(old$review$estimates[numeric], review$estimates[numeric])
      row$DrawsUnchanged <- identical(old$review$draws, review$draws) &&
        identical(old$review_pv$values, review_pv$values)
      stopifnot(row$NumericalValuesUnchanged, row$DrawsUnchanged,
        identical(row$DefaultPredictionReturned, !active),
        identical(row$DefaultPVReturned, !active), identical(row$SourceScoringReady, !active))
    }
    results[[id]] <- list(fit = fit, prediction = prediction, pv = pv,
      review = review, review_pv = review_pv)
    rows[[id]] <- row
    cat(id, 'default', row$DefaultPredictionReturned, 'ready', row$SourceScoringReady, '\n')
  }
  ridge <- do.call(rbind, lapply(c(1e-6, .1, 1, 4), function(v) {
    b <- uniroot(function(b) population_review_binary_prob(c(b, 0, log(v)), FALSE)[2] - .3,
      c(0, 10), tol = 1e-12)$root
    p <- population_review_binary_prob(c(b, 0, log(v)), FALSE)[2]
    moments <- vapply(1:2, function(k) integrate(function(z)
      (sqrt(v) * z)^k * plogis(sqrt(v) * z - b) * dnorm(z),
      -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-13)$value / p, numeric(1))
    stopifnot(abs(p - .3) < 1e-10)
    data.frame(Variance = v, RaterDifficulty = b, PositiveProbability = p,
      PositiveResponseEAP = moments[1], PosteriorSD = sqrt(moments[2] - moments[1]^2))
  }))
  stopifnot(identical(payload, tools::md5sum(paths)))
  evidence <- list(summary = do.call(rbind, rows), results = results, ridge = ridge,
    payload = payload, source = setNames(lapply(paths[endsWith(paths, '.R')], readLines),
      paths[endsWith(paths, '.R')]),
    design = readLines('inst/validation/population-output-contract-record-0.2.4.md'),
    started = started, completed = Sys.time(), session = sessionInfo())
  saveRDS(evidence, file.path(directory, paste0(stage, '.rds')), compress = 'xz')
  write.csv(evidence$summary, file.path(directory, paste0(stage, '.csv')), row.names = FALSE)
  invisible(evidence)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 2L)
  population_output_replay(args[1], args[2])
}
