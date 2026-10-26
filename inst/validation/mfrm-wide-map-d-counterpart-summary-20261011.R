# Summary-only continuation of the frozen D point-calibration driver.
# Its grid comparison retains expand.grid display metadata on only one side.
# Remove that metadata from the reference frame; numerical values stay exact.
expressions <- as.list(parse('inst/validation/mfrm-wide-map-d-counterparts-20261011.R'))
entry <- which(vapply(expressions, function(x) is.call(x) &&
  identical(x[[1L]], as.name('<-')) && identical(x[[2L]], as.name('arguments')), TRUE))
stopifnot(length(entry) == 1L)
for (x in expressions[seq_len(entry-1L)]) eval(x, environment())
summary_script <- 'inst/validation/mfrm-wide-map-d-counterpart-summary-20261011.R'
reference_grid <- function(...) base::expand.grid(..., KEEP.OUT.ATTRS=FALSE)
collect_display <- collect
environment(collect_display) <- list2env(list(expand.grid=reference_grid), parent=environment(collect))
stopifnot(identical(body(collect_display), body(collect)), identical(formals(collect_display),formals(collect)))
if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly=TRUE)
  stopifnot(length(arguments)==1L, arguments %in% c('summarize','replay'))
  manifest <- readRDS(file.path(out,'dispatch.rds'))
  check_hashes(manifest$source); check_hashes(manifest$inputs)
  stopifnot(identical(wide_mml_runtime(),manifest$runtime))
  for (name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm_data'))
    trace(name, quote(stop('No numerical recomputation in summary/replay.')),
      where=asNamespace('mfrmr'), print=FALSE)
  result <- collect_display(manifest)
  result$summary_source <- tools::md5sum(summary_script)
  file <- file.path(out,'comparison.rds')
  if (arguments=='replay') {
    stopifnot(identical(readRDS(file),result))
    cat('Fresh replay reproduced all rows and paired summaries without fitting.\n')
  } else {
    stopifnot(!file.exists(file)); wide_mml_save(result,file)
    for (n in c('rows','summary','paired')) write.csv(result[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
    print(result$summary[,c('ConditionId','Arm','Selection','Returned','ProbabilityMSE')],row.names=FALSE)
  }
  check_hashes(manifest$source); check_hashes(manifest$inputs)
}
