# Saved-output diagnosis of bias versus log-Wald uncertainty; no interval tuning.
# Run from D/scoring-source-v2 under its qualified runtime, with build or replay.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L, args %in% c('build', 'replay'))
helpers <- paste0('inst/validation/mfrm-wide-map-',
                  c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'), '-20261001.R')
for (path in helpers) source(path)
for (name in c('fit_mfrm', 'predict_mfrm_units', 'mfrm_gpcm_product_inference',
               'compute_mml_parameter_covariance'))
  trace(name, tracer = quote(stop('Reuse saved uncertainty outputs.')),
        where = asNamespace('mfrmr'), print = FALSE)
root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
stopifnot(identical(normalizePath('.'), normalizePath(file.path(root, 'scoring-source-v2'))))
runtime <- wide_multi_runtime()
check_hashes <- function(h) {
  stopifnot(length(h) > 0L, !anyNA(h))
  paths <- names(h)
  # Same exact-prefix relocation as the qualified D retained-input readers.
  paths <- sub('^/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/', '', paths)
  paths[paths == 'loaded:mfrmr'] <- getLoadedDLLs()[['mfrmr']][['path']]
  stopifnot(identical(unname(tools::md5sum(paths)), unname(h)))
}
folders <- file.path(root, c('complete-n30-summary/source-bound-replay',
                            'complete-n60-summary', 'complete-n120-summary'))
input_paths <- character()
metrics <- refusals <- vector('list', length(folders))
for (j in seq_along(folders)) {
  summary_path <- file.path(folders[j], 'summary.rds')
  proof_path <- file.path(folders[j], 'fresh-replay.rds')
  summary <- readRDS(summary_path); proof <- readRDS(proof_path)
  stopifnot(identical(summary$checksum, wide_mml_hash(summary$payload)),
            proof$ChecksPassed, identical(proof$Runtime, summary$binding$runtime))
  for (h in summary$binding[names(summary$binding) != 'runtime']) check_hashes(h)
  for (h in proof[c('SummaryAndTables', 'Outputs', 'Source')]) check_hashes(h)
  prior_runtime <- summary$binding$runtime
  stopifnot(identical(runtime[names(runtime) != 'source'],
                      prior_runtime[names(runtime) != 'source']))
  check_hashes(prior_runtime$source)
  stopifnot(identical(unname(runtime$source),
                      unname(prior_runtime$source[names(runtime$source)])))
  paths <- names(summary$binding$outputs)
  paths <- paths[grepl('/d-outputs[.]rds$', paths)]
  stopifnot(length(paths) == 50L, !anyDuplicated(paths))
  input_paths <- c(input_paths, summary_path, proof_path, paths)
  values <- lapply(paths, function(path) {
    value <- readRDS(path)
    stopifnot(identical(value$checksum, wide_mml_hash(value$payload)))
    value$payload
  })
  plan <- do.call(rbind, lapply(values, `[[`, 'plan'))
  records <- do.call(rbind, lapply(values, `[[`, 'records'))
  prior <- summary$payload$tables$structural
  stopifnot(identical(wide_output_summary(plan, records), prior),
            all(prior$Complete), all(prior$Planned == 50L))
  rows <- wide_output_records(plan, records)
  rows <- rows[grepl('^slopes:', rows$Target), ]
  stopifnot(length(unique(rows$Target)) == 9L,
            all(rows$Eligibility == 'eligible'),
            all(rows$Reference == 'generating_parameter'),
            all(rows$Status %in% c('returned', 'error')))
  metrics[[j]] <- do.call(rbind, lapply(split(rows, rows$Target), function(x) {
    a <- x[x$Output == 'point', ]; b <- x[x$Output == 'interval', ]
    a <- a[order(a$Replicate), ]; b <- b[order(b$Replicate), ]
    stopifnot(identical(a$Replicate, 1:50), identical(a$Replicate, b$Replicate),
              identical(a$ReferenceValue, b$ReferenceValue), identical(a$InputId, b$InputId))
    # Intervals may use an earlier source than the final point/scoring source.
    ok <- b$Available; n <- sum(ok); stopifnot(n >= 2L)
    all_error <- a$Estimate[a$Available] - a$ReferenceValue[a$Available]
    error <- b$Estimate[ok] - b$ReferenceValue[ok]; se <- b$SE[ok]
    low <- b$Lower[ok]; high <- b$Upper[ok]; truth <- b$ReferenceValue[ok]
    z <- error / se; mse <- mean(error^2); variance <- var(error)
    stopifnot(max(abs((high - low) / (2 * qnorm(.975)) - se)) < 1e-10,
              max(abs((high + low) / 2 - b$Estimate[ok])) < 1e-10,
              abs(mse - (n - 1) / n * variance - mean(error)^2) < 1e-12)
    covered <- sum(low <= truth & truth <= high)
    s <- prior[prior$Target == b$Target[1] & prior$Output == 'interval', ]
    stopifnot(nrow(s) == 1L, s$Available == n, s$Covered == covered,
              abs(s$MeanError - mean(error)) < 1e-12, abs(s$RMSE - sqrt(mse)) < 1e-12)
    cbind(b[1, c('ConditionId', 'Target', 'Owner', 'Level', 'Coordinate', 'ScaleReference')],
      data.frame(Planned = 50L, Points = length(all_error), Intervals = n,
        AllPointBias = mean(all_error), AllPointSD = sd(all_error),
        AllPointRMSE = sqrt(mean(all_error^2)), ReturnedBias = mean(error),
        BiasMCSE = sd(error) / sqrt(n), ReturnedSD = sqrt(variance),
        RMSModelSE = sqrt(mean(se^2)), SEtoSD = sqrt(mean(se^2) / variance),
        MSE = mse, SquaredBias = mean(error)^2, BiasFraction = mean(error)^2 / mse,
        CenteredMSE = (n - 1) / n * variance, MeanModelVariance = mean(se^2),
        MSEminusModelVariance = mean(error^2 - se^2),
        GapMCSE = sd(error^2 - se^2) / sqrt(n),
        StandardizedMean = mean(z), StandardizedSD = sd(z),
        ErrorSECorrelation = cor(error, se), Covered = covered,
        MissBelow = sum(high < truth), MissAbove = sum(low > truth),
        ConditionalCoverage = covered / n, ReturnedAndCovered = covered / 50,
        CIWithAdmittedPoint = sum(a$Available[ok]),
        MatchingReturnedSource = sum(a$SourceStage[ok] == b$SourceStage[ok])))
  }))
  refusals[[j]] <- rows[!rows$Available, ]
}
metrics <- do.call(rbind, metrics); rownames(metrics) <- NULL
refusals <- do.call(rbind, refusals); rownames(refusals) <- NULL
stopifnot(nrow(metrics) == 27L)
# Retain the already verified N240/R100 component summaries without redoing them.
old_root <- 'validation-results/gmfrm-adaptive-matched-20260930'
old_path <- file.path(old_root, 'summary.rds'); old <- readRDS(old_path)
manifest_path <- file.path(old_root, 'manifest.rds'); manifest <- readRDS(manifest_path)
stopifnot(identical(unname(tools::md5sum(manifest_path)), old$manifest_md5))
check_hashes(old$result_hashes); check_hashes(manifest$input_hashes)
frozen <- manifest$source_hashes; names(frozen) <- file.path(old_root, 'source', names(frozen))
check_hashes(frozen)
old_metrics <- old$summaries[old$summaries$Arm == 'adaptive', ]
stopifnot(nrow(old_metrics) == 36L, all(old_metrics$Attempted == 100L))
script <- sub('^--file=', '', grep('^--file=', commandArgs(), value = TRUE))
stopifnot(length(script) == 1L, file.exists(script))
binding <- list(inputs = tools::md5sum(c(input_paths, old_path, manifest_path,
  file.path(old_root, c('review-20261001.R', 'review-20261001.log')))),
  source = tools::md5sum(c(script, helpers)), runtime = runtime)
out <- file.path(root, 'slope-uncertainty-review-20261007')
target <- file.path(out, 'review.rds')
if (args == 'build') dir.create(out, recursive = TRUE, showWarnings = FALSE)
if (args == 'replay') stopifnot(file.exists(target))
before <- if (file.exists(target)) tools::md5sum(target) else NULL
result <- wide_mml_phase(target, binding, function() {
  stopifnot(args == 'build')
  list(metrics = metrics, refusals = refusals, prior_n240 = old_metrics,
    new_fits = 0L, new_information = 0L, new_intervals = 0L,
    scope = paste('Development diagnosis for all nine log-slope components in completed',
      'N30/60/120 common-Person SD1 cells; reuse four N240/R100 cells separately.',
      'Preserve original source stages and refusal denominators. No SE correction,',
      'new inference procedure, pooling across cells or independent coverage claim.'),
    session = capture.output(sessionInfo()))
})
stopifnot(identical(result$metrics, metrics), identical(result$refusals, refusals),
          identical(result$prior_n240, old_metrics))
check_hashes(binding$inputs); check_hashes(binding$source)
if (args == 'replay') {
  check_hashes(before)
  proof <- file.path(out, 'fresh-replay.rds'); stopifnot(!file.exists(proof))
  wide_mml_save(list(ChecksPassed = TRUE, Review = before, Binding = binding,
                    NewFits = 0L, NewInformation = 0L, NewIntervals = 0L), proof)
}
print(metrics[metrics$Owner == 'Task', c('ConditionId', 'Target', 'Intervals',
  'ReturnedBias', 'BiasMCSE', 'SEtoSD', 'BiasFraction', 'MSEminusModelVariance',
  'GapMCSE', 'StandardizedSD', 'Covered', 'MissBelow', 'MissAbove',
  'CIWithAdmittedPoint', 'MatchingReturnedSource')], row.names = FALSE)
cat('27 completed-cell decompositions reconcile; 36 prior N240 rows reused unchanged.\n')
