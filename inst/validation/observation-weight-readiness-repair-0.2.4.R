# Repository-only replay of the retained use-condition audit; no new simulation.
source('inst/validation/mml-use-condition-audit-0.2.4.R')

observation_weight_readiness_repair <- function() {
  pkgload::load_all('.', quiet = TRUE)
  prior_path <- 'inst/validation/mml-use-condition-audit-evidence-0.2.4.rds'
  source_paths <- c(list.files('R', pattern = '[.]R$', full.names = TRUE),
    'inst/validation/observation-weight-readiness-repair-0.2.4.R', prior_path,
    'inst/validation/mml-use-condition-audit-0.2.4.R')
  payload <- tools::md5sum(source_paths)
  prior <- readRDS(prior_path)
  rejected <- function(expr) inherits(tryCatch(force(expr), error = identity), 'error')
  migration <- lapply(names(prior$results), function(id) {
    old <- prior$results[[id]]$result
    stopifnot(!inherits(old, 'error'))
    eq <- old$equivalence
    bundle <- inherits(eq, 'mfrm_facet_equivalence')
    row <- data.frame(Id = id, OldInferenceReady = old$metrics$InferenceReady,
      SavedFitRestricted = !mfrmr:::mfrm_inference_ready(old$fit),
      SavedSummaryRestricted = !mfrmr:::mfrm_inference_ready(old$fit$summary),
      EquivalenceRestricted = rejected(analyze_facet_equivalence(old$fit)),
      HadBundle = bundle,
      BundleSummaryRestricted = if (bundle) rejected(summary(eq)) else NA,
      BundlePrintRestricted = if (bundle) rejected(print(eq)) else NA,
      BundlePlotRestricted = if (bundle) rejected(plot(eq, draw = FALSE)) else NA)
    stopifnot(row$SavedFitRestricted, row$SavedSummaryRestricted, row$EquivalenceRestricted)
    if (bundle) stopifnot(row$BundleSummaryRestricted, row$BundlePrintRestricted,
                         row$BundlePlotRestricted)
    row
  })
  ids <- c('RSM-weights', 'PCM-weights', 'coverage-1', 'coverage-5')
  results <- list()
  rows <- list()
  for (id in ids) {
    case <- prior$cases[[id]]
    weighted <- case$Source == 'weights'
    grids <- if (weighted) case$Grids else 61L
    for (q in grids) for (mode in if (weighted) 'nonunit' else c('omitted', 'explicit_unit')) {
      candidate <- case
      if (mode == 'explicit_unit') {
        candidate$Data$Weight <- 1
        candidate$Extra$weight <- 'Weight'
      }
      warnings <- character()
      start <- proc.time()[['elapsed']]
      current <- withCallingHandlers(mml_use_fit(candidate, q), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')
      })
      old <- prior$results[[paste0(id, '-q', q)]]$result
      row <- data.frame(Id = id, Q = q, WeightMode = mode,
        ParameterChange = max(abs(current$fit$opt$par - old$fit$opt$par)),
        ObjectiveChange = abs(current$fit$opt$value - old$fit$opt$value),
        CovarianceChange = max(abs(current$covariance$cov - old$covariance$cov)),
        StructuralSEChange = max(abs(mml_use_se(current$fit, current$covariance) -
          mml_use_se(old$fit, old$covariance))),
        InferenceReady = current$metrics$InferenceReady,
        FormalInference = current$metrics$FormalInference,
        EquivalenceAvailable = current$metrics$EquivalenceAvailable,
        ReasonCodes = current$fit$readiness$fit$ReasonCodes,
        Warnings = length(warnings), Seconds = proc.time()[['elapsed']] - start)
      stopifnot(row$ParameterChange < 1e-12, row$ObjectiveChange < 1e-12,
        row$CovarianceChange < 1e-12, row$StructuralSEChange < 1e-12,
        identical(row$InferenceReady, !weighted),
        identical(row$FormalInference, !weighted),
        identical(row$EquivalenceAvailable, !weighted))
      if (weighted) stopifnot(grepl('nonunit_observation_weights_inference_unvalidated', row$ReasonCodes))
      key <- paste(id, q, mode, sep = '-')
      rows[[key]] <- row
      results[[key]] <- list(result = current, warnings = warnings)
      cat(key, ': numerical changes', row$ParameterChange, row$ObjectiveChange,
          row$CovarianceChange, row$StructuralSEChange, '; inference', row$InferenceReady, '\n')
      flush.console()
    }
  }
  stopifnot(identical(payload, tools::md5sum(source_paths)))
  evidence <- list(summary = do.call(rbind, rows), migration = do.call(rbind, migration),
    results = results, payload = payload,
    source = lapply(source_paths[endsWith(source_paths, '.R')], readLines),
    session = sessionInfo(), completed = Sys.time())
  names(evidence$source) <- source_paths[endsWith(source_paths, '.R')]
  prefix <- 'inst/validation/observation-weight-readiness-repair'
  write.csv(evidence$summary, paste0(prefix, '-summary-0.2.4.csv'), row.names = FALSE)
  write.csv(evidence$migration, paste0(prefix, '-migration-0.2.4.csv'), row.names = FALSE)
  saveRDS(evidence, paste0(prefix, '-evidence-0.2.4.rds'), compress = 'xz')
  invisible(evidence)
}

if (sys.nframe() == 0L) observation_weight_readiness_repair()
