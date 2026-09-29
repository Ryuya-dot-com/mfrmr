# Replay retained fits only: no optimization, simulation, or readiness changes.
run_gpcm_population_scoring_audit <- function(output_dir) {
  input <- 'validation-results/portable-gpcm-development-probe.rds'
  review <- readRDS(input)$review
  rows <- lapply(names(review$fits), function(id) {
    f <- review$fits[[id]]
    scoring <- prediction_source_scoring_readiness(f)
    inference <- mfrm_gpcm_inference(f)
    data.frame(Fit = id, Model = f$config$model,
      StepOwner = f$config$step_facet, SlopeOwner = f$config$slope_facet,
      Mean = unname(f$population$coefficients[1]), Variance = f$population$sigma2,
      MinSlope = min(f$slopes$Estimate), MaxSlope = max(f$slopes$Estimate),
      NumericalState = f$readiness$fit$NumericalState,
      InformationStatus = inference$information$status,
      LocalSlopeInferenceEligible = isTRUE(inference$check$eligible),
      ScoringReady = isTRUE(scoring$ready),
      ScoringReasons = paste(scoring$reason_codes, collapse = ';'),
      stringsAsFactors = FALSE)
  })
  rows <- do.call(rbind, rows)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  write.csv(rows, file.path(output_dir, 'readiness-replay.csv'), row.names = FALSE)
  saveRDS(list(input_md5 = tools::md5sum(input),
    source_commit = system2('git', c('rev-parse', 'HEAD'), stdout = TRUE),
    source_md5 = tools::md5sum(c(list.files('R', '[.]R$', full.names = TRUE),
      'inst/validation/gpcm-population-scoring-audit-20260926.R')),
    session = sessionInfo()), file.path(output_dir, 'manifest.rds'))
  print(rows)
  invisible(rows)
}
