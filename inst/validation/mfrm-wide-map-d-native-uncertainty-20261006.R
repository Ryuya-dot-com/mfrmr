# Read-only decomposition of the new D native location/contrast intervals.
# Run from the qualified retained-output source with its recorded R runtime.
# Reuses complete cells; no fitting, information calculation or interval tuning.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (n in c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-', n, '-20261001.R'))
source('inst/validation/mfrm-wide-map-d-output-20261005.R')
for (n in c('fit_mfrm', 'predict_mfrm_units', 'mfrm_gpcm_product_inference',
            'compute_mml_parameter_covariance'))
  trace(n, tracer = quote(stop('Read-only uncertainty review must reuse saved outputs.')),
        where = asNamespace('mfrmr'), print = FALSE)
out <- 'validation-results/mfrm-wide-map-d-retained-output-20261005'
manifest <- readRDS(file.path(out, 'dispatch.rds'))
stopifnot(identical(wide_d_runtime(), manifest$runtime),
          !dir.exists(file.path(out, 'RUNNING')))
for (h in list(manifest$sources, manifest$bridge, manifest$contracts, manifest$qualification))
  stopifnot(identical(tools::md5sum(names(h)), h))
summary_path <- file.path(out, 'complete-n240-summary.rds')
summary <- readRDS(summary_path)
stopifnot(identical(summary$checksum, wide_mml_hash(summary$payload)))
for (h in summary$binding) stopifnot(identical(tools::md5sum(names(h)), h))
paths <- names(summary$binding$outputs)
before <- tools::md5sum(paths)
values <- lapply(paths, function(path) {
  z <- readRDS(path)
  stopifnot(identical(z$checksum, wide_mml_hash(z$payload)),
            identical(z$binding$contracts, manifest$contracts))
  wide_output_records(z$payload$plan, z$payload$records)
})
rows <- do.call(rbind, values)
rows <- rows[rows$ConditionId %in% summary$payload$complete_cells &
               rows$Coordinate %in% c('location', 'location_contrast'), ]
stopifnot(length(unique(rows$ConditionId)) == 4L,
          all(rows$Eligibility == 'eligible'),
          all(rows$Reference == 'generating_parameter'),
          all(rows$Status == 'returned'))
groups <- split(rows, paste(rows$ConditionId, rows$Target, sep = '\r'))
metrics <- do.call(rbind, lapply(groups, function(x) {
  a <- x[x$Output == 'point', ]; b <- x[x$Output == 'interval', ]
  a <- a[order(a$Replicate), ]; b <- b[order(b$Replicate), ]
  stopifnot(identical(a$Replicate, 1:50), identical(a$Replicate, b$Replicate),
            identical(a$ReferenceValue, b$ReferenceValue),
            identical(a$InputId, b$InputId), length(unique(b$ReferenceValue)) == 1L)
  ok <- b$Available; n <- sum(ok)
  stopifnot(n >= 2L, all(a$Available[ok]),
            all(a$SourceStage[ok] == b$SourceStage[ok]),
            max(abs(a$Estimate[ok] - b$Estimate[ok])) < 1e-12)
  all_error <- a$Estimate[a$Available] - a$ReferenceValue[a$Available]
  error <- b$Estimate[ok] - b$ReferenceValue[ok]; se <- b$SE[ok]
  low <- b$Lower[ok]; high <- b$Upper[ok]; truth <- b$ReferenceValue[ok]
  z <- error / se; mse <- mean(error^2); variance <- var(error)
  stopifnot(max(abs((high - low) / (2 * qnorm(.975)) - se)) < 1e-10,
            abs(mse - (n - 1) / n * variance - mean(error)^2) < 1e-12)
  covered <- sum(low <= truth & truth <= high)
  prior <- summary$payload$structural
  prior <- prior[prior$ConditionId == b$ConditionId[1] &
                   prior$Target == b$Target[1] & prior$Output == 'interval', ]
  stopifnot(nrow(prior) == 1L, prior$Available == n, prior$Covered == covered,
            abs(prior$MeanError - mean(error)) < 1e-12,
            abs(prior$RMSE - sqrt(mse)) < 1e-12)
  cbind(b[1, c('ConditionId', 'Target', 'Owner', 'Level', 'Coordinate', 'ScaleReference')],
    data.frame(Planned = 50L, Points = length(all_error), Intervals = n,
      AllPointBias = mean(all_error), AllPointSD = sd(all_error),
      AllPointRMSE = sqrt(mean(all_error^2)), ReturnedBias = mean(error),
      BiasMCSE = sd(error) / sqrt(n), ReturnedSD = sqrt(variance),
      RMSModelSE = sqrt(mean(se^2)), SEtoSD = sqrt(mean(se^2) / variance),
      MSE = mse, SquaredBias = mean(error)^2,
      CenteredMSE = (n - 1) / n * variance, MeanModelVariance = mean(se^2),
      MSEminusModelVariance = mean(error^2 - se^2),
      GapMCSE = sd(error^2 - se^2) / sqrt(n),
      StandardizedMean = mean(z), StandardizedSD = sd(z),
      ErrorSECorrelation = cor(error, se), Covered = covered,
      MissBelow = sum(high < truth), MissAbove = sum(low > truth),
      ConditionalCoverage = covered / n, ReturnedAndCovered = covered / 50,
      MatchingReturnedSource = sum(a$SourceStage[ok] == b$SourceStage[ok])))
}))
rownames(metrics) <- NULL
stopifnot(nrow(metrics) == 44L, identical(tools::md5sum(paths), before))
refusals <- rows[rows$Output == 'interval' & !rows$Available, ]
script <- sub('^--file=', '', grep('^--file=', commandArgs(), value = TRUE))
binding <- list(summary = tools::md5sum(summary_path), outputs = before,
                source = tools::md5sum(script), runtime = manifest$runtime)
result <- wide_mml_phase(file.path(out, 'native-uncertainty-review.rds'), binding,
  function() list(metrics = metrics, refusals = refusals, new_fits = 0L,
    new_information = 0L, new_intervals = 0L, original_denominator = 400L,
    independent_datasets_per_cell = 50L,
    scope = 'Development decomposition for 11 native location/contrast targets in four complete retained cells. No component-slope reanalysis, SE inflation, interval change or independent coverage claim.',
    session = capture.output(sessionInfo())))
stopifnot(identical(result$metrics, metrics), identical(result$refusals, refusals),
          identical(tools::md5sum(paths), before))
csv <- file.path(out, 'native-uncertainty-review.csv')
if (!file.exists(csv)) write.csv(metrics, csv, row.names = FALSE)
copy <- file.path(out, basename(script))
if (!file.exists(copy)) stopifnot(file.copy(script, copy))
stopifnot(identical(unname(tools::md5sum(script)), unname(tools::md5sum(copy))))
print(metrics[grepl('common:N240:SD1:', metrics$ConditionId) & metrics$Owner == 'Task',
              c('Target', 'ReturnedBias', 'ReturnedSD', 'RMSModelSE', 'SEtoSD',
                'MSEminusModelVariance', 'GapMCSE', 'Covered', 'MissBelow', 'MissAbove')],
      row.names = FALSE)
cat('44 native location/contrast decompositions reconcile with saved complete-cell summaries.\n')
