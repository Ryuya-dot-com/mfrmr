# Read saved GMFRM development evidence; no package loading or numerical fitting.
# Rscript --vanilla inst/validation/gmfrm-interval-disposition-20261010.R [replay]
script <- 'inst/validation/gmfrm-interval-disposition-20261010.R'
helper <- 'inst/validation/mfrm-wide-map-output-summary-20261001.R'
source(helper)
root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
retained <- 'validation-results/mfrm-wide-map-d-retained-output-20261005'
out <- 'validation-results/gmfrm-interval-disposition-20261010'
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) <= 1L, !length(args) || identical(args, 'replay'))
replay <- length(args) == 1L
inputs <- character()
verify <- function(h) {
  stopifnot(length(h) > 0L, !anyNA(h))
  paths <- sub('^/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/', '', names(h))
  stopifnot(identical(unname(tools::md5sum(paths)), unname(h)))
  inputs <<- union(inputs, paths)
}
read <- function(path) { inputs <<- union(inputs, path); readRDS(path) }
cp <- function(k, n) {
  if (!n) return(c(NA_real_, NA_real_))
  x <- c(if (k == 0) 0 else qbeta(.025, k, n-k+1),
         if (k == n) 1 else qbeta(.975, k+1, n-k))
  stopifnot(max(abs(x - binom.test(k, n)$conf.int)) < 1e-12)
  x
}
summaries <- c(setNames(file.path(root, paste0('complete-n', c(20,30,40,60,120,480),
  '-summary'), 'summary.rds'), c(20,30,40,60,120,480)),
  '240' = file.path(retained, 'complete-n240-summary.rds'))
summaries['30'] <- file.path(root, 'complete-n30-summary/source-bound-replay/summary.rds')
metrics <- refusals <- list()
for (key in names(summaries)) {
  s <- read(summaries[[key]])
  verify(s$binding$outputs)
  if (key != '240') {
    proof <- read(file.path(dirname(summaries[[key]]), 'fresh-replay.rds'))
    stopifnot(isTRUE(proof$ChecksPassed), proof$NewFits == 0L,
      proof$NewScores == 0L, proof$NewInformation == 0L)
    verify(proof$SummaryAndTables); verify(proof$Outputs)
  } else {
    # The completed native review binds the same summary and all 208 outputs.
    proof <- read(file.path(retained, 'native-uncertainty-review.rds'))
    verify(proof$binding$summary); verify(proof$binding$outputs)
    stopifnot(proof$payload$new_fits == 0L, proof$payload$new_information == 0L)
  }
  paths <- names(s$binding$outputs)
  paths <- paths[grepl('/d-outputs[.]rds$', paths)]
  values <- lapply(paths, read)
  plan <- do.call(rbind, lapply(values, function(x) x$payload$plan))
  records <- do.call(rbind, lapply(values, function(x) x$payload$records))
  prior <- if (key == '240') s$payload$structural else s$payload$tables$structural
  if (key == '240') {
    plan <- plan[plan$ConditionId %in% s$payload$complete_cells, ]
    records <- records[records$ConditionId %in% s$payload$complete_cells, ]
    prior <- prior[prior$ConditionId %in% s$payload$complete_cells, ]
  }
  stopifnot(identical(wide_output_summary(plan, records), prior),
    all(prior$Complete), all(prior$Planned == 50L))
  rows <- wide_output_records(plan, records)
  rows <- rows[rows$Output == 'interval', ]
  for (x in split(rows, paste(rows$ConditionId, rows$Target))) {
    stopifnot(nrow(x) == 50L, identical(sort(x$Replicate), 1:50))
    ok <- x$Available; n <- sum(ok); excluded <- sum(x$Eligibility != 'eligible')
    covered <- sum(x$Lower[ok] <= x$ReferenceValue[ok] & x$ReferenceValue[ok] <= x$Upper[ok])
    ai <- cp(n, 50L); ci <- cp(covered, n)
    error <- x$Estimate[ok] - x$ReferenceValue[ok]; se <- x$SE[ok]
    if (n) stopifnot(max(abs((x$Upper[ok] - x$Lower[ok])/(2*qnorm(.975)) - se)) < 1e-9)
    m <- cbind(x[1, c('ConditionId','Target','Owner','Level','Coordinate','ScaleReference')],
      data.frame(N=as.integer(key), Planned=50L, Excluded=excluded, Available=n,
        Availability=n/50, AvailabilityLower=ai[1], AvailabilityUpper=ai[2],
        Covered=if (n) covered else NA_integer_,
        ConditionalCoverage=if (n) covered/n else NA_real_,
        CoverageLower=ci[1], CoverageUpper=ci[2], ReturnedAndCovered=covered/50,
        Bias=if (n) mean(error) else NA_real_,
        EmpiricalSD=if (n>1) sd(error) else NA_real_,
        RMSModelSE=if (n) sqrt(mean(se^2)) else NA_real_,
        SEtoSD=if (n>1) sqrt(mean(se^2))/sd(error) else NA_real_,
        BiasFraction=if (n) mean(error)^2/mean(error^2) else NA_real_,
        MissBelow=sum(x$Upper[ok] < x$ReferenceValue[ok]),
        MissAbove=sum(x$Lower[ok] > x$ReferenceValue[ok]),
        MeanWidth=if (n) mean(x$Upper[ok]-x$Lower[ok]) else NA_real_))
    # Descriptive signals, not post hoc qualification or simultaneous tests.
    m$DeliverySignal <- if (excluded) 'design_excluded' else if (ai[2] < .95)
      'upper_MC_limit_below_delivery_target' else 'precision_or_method_unresolved'
    m$CoverageSignal <- if (!n) 'undefined' else if (ci[2] < .92)
      'upper_MC_limit_below_practical_band' else if (ci[1] > .98)
      'lower_MC_limit_above_practical_band' else 'precision_or_method_unresolved'
    metrics[[length(metrics)+1L]] <- m
  }
  for (j in seq_along(values)) {
    v <- values[[j]]$payload
    if (!any(v$plan$ConditionId %in% rows$ConditionId)) next
    x <- wide_output_records(v$plan, v$records)
    a <- x[x$Output == 'interval' & x$Target == 'slopes:"Task":"t1"', ]
    stopifnot(nrow(a) == 1L)
    if (a$Available || a$Eligibility != 'eligible') next
    selected <- read(file.path(dirname(paths[j]), 'selected.rds'))$payload
    z <- selected$intervals$slopes
    checks <- attr(z$value, 'checks'); d <- attr(z$value, 'numerical_checks')
    stage <- sub(':.*$', '', z$stage)
    fit <- read(file.path(dirname(paths[j]), paste0(stage, '-fit.rds')))$payload$value
    diag <- fit$opt$optimizer_diagnostics
    failed <- if (is.null(checks)) 'no_check_object' else paste(checks$Check[!checks$Passed], collapse=';')
    get <- function(k) if (is.data.frame(d) && nrow(d) == 1L && k %in% names(d)) d[[k]] else NA_real_
    refusals[[length(refusals)+1L]] <- data.frame(N=as.integer(key),
      ConditionId=a$ConditionId, Replicate=a$Replicate, FirstFailedCheck=failed,
      Source=stage, FitPath=file.path(dirname(paths[j]), paste0(stage, '-fit.rds')),
      SelectedPath=file.path(dirname(paths[j]), 'selected.rds'),
      OptimizerPass=identical(diag$ConvergenceSeverity,'pass'),
      OptimizerGradient=diag$TerminalGradientSupNorm,
      OptimizerTolerance=diag$GradientReviewTolerance,
      MeanScore=get('MaximumMeanScore'),
      StandardizedDisplacement=get('CurvatureScaledGradient'),
      Reason=a$Reason)
  }
}
metrics <- do.call(rbind, metrics); rownames(metrics) <- NULL
refusals <- do.call(rbind, refusals); rownames(refusals) <- NULL
stopifnot(nrow(metrics) == 200L, length(unique(metrics$ConditionId)) == 10L,
  !anyDuplicated(paste(metrics$ConditionId,metrics$Target)),
  !anyDuplicated(paste(refusals$ConditionId,refusals$Replicate)), nrow(refusals) == 54L)
counts <- aggregate(list(Datasets=refusals$Replicate),
  refusals[c('N','FirstFailedCheck')], length)
stationary <- refusals[refusals$FirstFailedCheck == 'Stationary local maximum', ]
stopifnot(nrow(stationary) == 32L, all(stationary$OptimizerPass),
  all(stationary$OptimizerGradient <= stationary$OptimizerTolerance))
decision <- list(
  scope='Development evidence only: 500 condition-datasets; matched conditions and targets are not independent replications.',
  source='Original frozen producers and their saved replay proofs; current package fitting/inference is not executed.',
  candidate='Keep full-information log-Wald as an experimental reference. No broad independent confirmation of unchanged small-N delivery.',
  delivery='N20 rank exclusion and N30/N40 availability are distinct from conditional coverage. Failed checks name the first encountered gate, not a proof of the sole cause.',
  coverage='N60 Task t1 has a pointwise upper MC limit below .92. This is inspected development evidence, not an independent or multiplicity-adjusted test.',
  repair='The 32 stationarity refusals passed the optimizer criterion. Qualify any alignment of fitting and inference precision without weakening inference gates; changed returned samples need new performance evaluation.',
  alternatives='No universal SE inflation, sample-size cutoff, profile superiority or bootstrap validity follows from this review.',
  new_fits=0L, new_information=0L, new_draws=0L)
binding <- tools::md5sum(c(inputs, script, helper)); stopifnot(!anyNA(binding))
result <- list(metrics=metrics, refusals=refusals, refusal_counts=counts,
  decision=decision, inputs_and_source=binding)
target <- file.path(out, 'review.rds')
if (replay || file.exists(target)) {
  old <- readRDS(target); verify(old$inputs_and_source)
  stopifnot(identical(old, result))
} else {
  dir.create(out, recursive=TRUE, showWarnings=FALSE)
  saveRDS(result, target)
  write.csv(metrics, file.path(out,'metrics.csv'), row.names=FALSE)
  write.csv(refusals, file.path(out,'refusals.csv'), row.names=FALSE)
}
verify(binding)
print(counts, row.names=FALSE)
print(metrics[metrics$CoverageSignal == 'upper_MC_limit_below_practical_band',
  c('N','ConditionId','Target','Available','Covered','CoverageUpper')], row.names=FALSE)
cat('200 target/cell rows reconcile; 54 unavailable datasets classified; no new numerical estimation.\n')
