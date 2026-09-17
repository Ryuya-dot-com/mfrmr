# Shared aggregation plus independent-study provenance and replication planning.
source('inst/validation/local-testlet-calibration-pilot-0.2.4-summary.R')

summarize_testlet_independent_pilot <- function() {
  prefix <- 'inst/validation/local-testlet-independent-pilot-0.2.4'
  output <- 'validation-results/local-testlet-independent-pilot-20260917'
  x <- testlet_pilot_summarize(prefix, output)
  check <- function(label, condition) data.frame(Check = label, Pass = isTRUE(condition))
  additional <- do.call(rbind, list(
    check('earlier evidence remains unchanged', identical(x$plan$inputs, tools::md5sum(names(x$plan$inputs)))),
    check('new seeds unique and disjoint from optimizer development data',
      !anyDuplicated(x$plan$manifest$Seed) && !any(x$plan$manifest$Seed %in% x$plan$prior_seeds)),
    check('all records retain input-evidence provenance', all(vapply(x$records, function(r)
      identical(r$inputs, x$plan$inputs), logical(1)))),
    check('selected optimizer controls fixed for every dataset', all(vapply(x$records, function(r)
      identical(r$control, list(maxit = 250L, fnscale = r$spec$N, factr = 0, pgtol = 5e-6 / r$spec$N)), logical(1)))),
    check('original common starting point retained', all(vapply(x$records, function(r)
      is.null(r$fit$value) || identical(r$fit$value$start, x$plan$start), logical(1)))),
    check('readiness agrees with all fit and higher-order requirements', all(vapply(x$records, function(r) {
      v <- r$fit$value$captured$value
      ref <- r$reference$value
      errors <- c(r$fit$error, r$fit$value$captured$error, r$reference$error)
      warnings <- c(r$fit$warnings, r$fit$value$captured$warnings, r$reference$warnings)
      ready <- !is.null(v) && !is.null(ref) && !any(nzchar(errors)) && !length(warnings) &&
        v$convergence == 0 && is.finite(v$projected_score) && v$projected_score <= 1e-5 && !v$search_boundary &&
        abs(v$loglik - ref$loglik) <= 1e-7 && max(abs(v$moments - ref$moments)) <= 1e-7 &&
        max(abs(v$gradient - ref$gradient)) <= 1e-6 && r$status$ReferenceProjectedScore <= 1e-5
      identical(r$status$FitReady, isTRUE(ready))
    }, logical(1)))),
    check('all returned points retain a higher-order reference attempt', all(vapply(x$records, function(r)
      is.null(r$fit$value$captured$value) || (!is.null(r$reference) &&
        r$status$ReferenceOrder == tail(r$fit$value$history[, 'Order'], 1) + 60L), logical(1))))))
  x$audit <- rbind(x$audit, additional)
  coverage <- x$summaries[x$summaries$Stratum %in% c('all_persons', 'pairs'), ]
  paired <- x$paired[x$paired$Stratum %in% c('all_persons', 'pairs'), ]
  planning <- rbind(data.frame(Cell = coverage$Cell, N = coverage$N, Variance = coverage$Variance,
    Stratum = coverage$Stratum, Metric = paste0(coverage$Method, '_coverage'),
    Estimate = coverage$CoverageAmongAvailable, MCSE = coverage$CoverageMCSE),
    data.frame(Cell = paired$Cell, N = paired$N, Variance = paired$Variance,
      Stratum = paired$Stratum, Metric = 'plugin_minus_oracle', Estimate = paired$PluginMinusOracle, MCSE = paired$DifferenceMCSE))
  planning$PilotDatasets <- 10L
  planning$TargetMCSE <- .005
  planning$ProjectedDatasets <- ifelse(is.finite(planning$MCSE) & planning$MCSE > 0,
    ceiling(planning$PilotDatasets * (planning$MCSE / planning$TargetMCSE)^2), NA_real_)
  planning$Disposition <- ifelse(is.na(planning$ProjectedDatasets), 'variance_not_informed', 'pilot_variance_projection')
  replication <- do.call(rbind, lapply(1:4, function(cell) {
    p <- planning[planning$Cell == cell, ]
    finite <- is.finite(p$ProjectedDatasets)
    maximum <- if (any(finite)) max(p$ProjectedDatasets[finite]) else NA_real_
    numerical_review <- any(!x$status$FitReady[x$status$Cell == cell]) ||
      any(!x$rows$Available[x$rows$Cell == cell])
    data.frame(Cell = cell, N = p$N[1], Variance = p$Variance[1],
      MaximumProjectedDatasets = maximum, UninformedMetrics = sum(!finite), PlanningFloor = 200L,
      ProvisionalDatasets = if (is.finite(maximum)) max(200L, maximum) else NA_real_,
      NumericalReviewRequired = numerical_review,
      Disposition = if (numerical_review) 'review_numerical_results_before_main' else 'provisional_planning_only')
  }))
  x$planning <- planning
  x$replication <- replication
  x$completed <- Sys.time()
  write.csv(x$audit, paste0(prefix, '-audit.csv'), row.names = FALSE)
  write.csv(planning, paste0(prefix, '-planning.csv'), row.names = FALSE)
  write.csv(replication, paste0(prefix, '-replication.csv'), row.names = FALSE)
  saveRDS(x, paste0(prefix, '-evidence.rds'))
  print(additional)
  print(replication)
  stopifnot(all(x$audit$Pass))
  invisible(x)
}

if (sys.nframe() == 0L) summarize_testlet_independent_pilot()
