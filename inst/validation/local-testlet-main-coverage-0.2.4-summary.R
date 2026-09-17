# Final-only aggregation: outcome summaries are never used to change this run.
source('inst/validation/local-testlet-calibration-pilot-0.2.4-summary.R')
source('inst/validation/local-testlet-main-coverage-0.2.4.R')

summarize_testlet_main_coverage <- function() {
  output <- 'validation-results/local-testlet-main-coverage-20260917'
  prefix <- file.path(output, 'summary', 'local-testlet-main-coverage-0.2.4')
  plan <- readRDS(file.path(output, 'plan.rds'))
  stopifnot(file.exists(file.path(output, 'execution-complete.rds')),
    identical(plan$inputs, tools::md5sum(names(plan$inputs))),
    identical(plan$reporting_sources, tools::md5sum(names(plan$reporting_sources))))
  dir.create(dirname(prefix), recursive = TRUE, showWarnings = FALSE)
  x <- testlet_pilot_summarize(prefix, output, pilot_only = FALSE)
  additional <- data.frame(Check = c('all 1200 fixed main datasets retained',
      'all 201600 assigned method targets retained', 'fixed controls and start retained',
      'saved readiness agrees with fitting and reference gates', 'reporting sources unchanged'),
    Pass = c(nrow(x$status) == 1200L && all(table(x$status$Cell) == 300L),
      nrow(x$rows) == 201600L,
      all(vapply(seq_along(x$records), function(i) {
        r <- x$records[[i]]
        identical(r$control, plan$controls[[i]]) && identical(r$inputs, plan$inputs) &&
          (is.null(r$fit$value) || identical(r$fit$value$start, plan$start))
      }, logical(1))),
      all(vapply(x$records, function(r) identical(r$status, testlet_main_status(r$spec, r$fit, r$reference)), logical(1))),
      identical(plan$reporting_sources, tools::md5sum(names(plan$reporting_sources)))))
  x$audit <- rbind(x$audit, additional)
  x$summary_sources <- plan$reporting_sources
  x$summaries$CoverageMCLower <- x$summaries$CoverageAmongAvailable -
    qt(.975, x$summaries$Replicates - 1) * x$summaries$CoverageMCSE
  x$summaries$CoverageMCUpper <- x$summaries$CoverageAmongAvailable +
    qt(.975, x$summaries$Replicates - 1) * x$summaries$CoverageMCSE
  x$summaries$CoverageZeroEmpiricalVariance <- is.finite(x$summaries$CoverageMCSE) & x$summaries$CoverageMCSE == 0
  x$paired$DifferenceMCLower <- x$paired$PluginMinusOracle - qt(.975, x$paired$Replicates - 1) * x$paired$DifferenceMCSE
  x$paired$DifferenceMCUpper <- x$paired$PluginMinusOracle + qt(.975, x$paired$Replicates - 1) * x$paired$DifferenceMCSE
  x$paired$DifferenceZeroEmpiricalVariance <- is.finite(x$paired$DifferenceMCSE) & x$paired$DifferenceMCSE == 0
  coverage <- x$summaries[x$summaries$Stratum %in% c('all_persons', 'pairs'), ]
  paired <- x$paired[x$paired$Stratum %in% c('all_persons', 'pairs'), ]
  x$precision <- rbind(data.frame(Cell = coverage$Cell, Stratum = coverage$Stratum,
      Metric = paste0(coverage$Method, '_coverage'), MCSE = coverage$CoverageMCSE),
    data.frame(Cell = paired$Cell, Stratum = paired$Stratum, Metric = 'plugin_minus_oracle', MCSE = paired$DifferenceMCSE))
  x$precision$TargetMCSE <- .005
  x$precision$PrecisionStatus <- ifelse(!is.finite(x$precision$MCSE), 'unavailable',
    ifelse(x$precision$MCSE == 0, 'zero_empirical_variance_not_certified',
      ifelse(x$precision$MCSE <= .005, 'observed_goal_met', 'observed_goal_unmet')))
  x$completed <- Sys.time()
  for (name in c('audit', 'summaries', 'paired', 'precision'))
    write.csv(x[[name]], paste0(prefix, '-', name, '.csv'), row.names = FALSE)
  testlet_main_save(x, paste0(prefix, '-evidence.rds'))
  print(additional); print(x$precision)
  stopifnot(all(x$audit$Pass))
  testlet_main_save(list(completed = x$completed, audit = x$audit,
    evidence = tools::md5sum(paste0(prefix, '-evidence.rds'))), file.path(output, 'summary-complete.rds'))
  cat('MAIN SUMMARY COMPLETE: fixed denominators, final precision and evidence saved\n')
  invisible(x)
}

if (sys.nframe() == 0L) summarize_testlet_main_coverage()
