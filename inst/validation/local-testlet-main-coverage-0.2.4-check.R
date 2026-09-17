# One bounded runner check; uses saved evidence, never fits or scores.
source('inst/validation/local-testlet-main-coverage-0.2.4.R')
source('inst/validation/local-testlet-calibration-pilot-0.2.4-summary.R')

check_testlet_main_runner <- function() {
  directory <- tempfile('testlet-main-check-')
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  x <- readRDS('inst/validation/local-testlet-independent-pilot-0.2.4-evidence.rds')
  allocation <- readRDS('inst/validation/local-testlet-pair-allocation-0.2.4-evidence.rds')
  stopifnot(all(vapply(seq_along(x$records), function(i) {
    r <- x$records[[i]]
    identical(r$status, testlet_main_status(r$spec, r$fit, r$reference))
  }, logical(1))))
  for (i in seq_along(x$generated)) {
    targets <- testlet_main_targets(x$generated[[i]], 12L)
    expected <- rbind(x$records[[i]]$oracle$rows[x$records[[i]]$oracle$rows$Kind == 'person', names(targets)],
      allocation$plan$targets[[i]][1:12, ])
    rownames(targets) <- rownames(expected) <- NULL
    stopifnot(identical(targets, expected))
  }
  failures <- readRDS('inst/validation/local-testlet-calibration-pilot-0.2.4-evidence.rds')
  stopifnot(all(vapply(failures$records[!failures$status$FitReady], function(r)
    !testlet_main_status(r$spec, r$fit, NULL)$FitReady, logical(1))))
  r <- x$records[[1]]
  bad <- r$reference; bad$warnings <- 'reference warning'
  stopifnot(!testlet_main_status(r$spec, r$fit, bad)$FitReady,
    !testlet_main_status(r$spec, r$fit, NULL)$FitReady)
  bad <- r$reference; bad$value$gradient[1] <- bad$value$gradient[1] + .01
  stopifnot(!testlet_main_status(r$spec, r$fit, bad)$FitReady)
  path <- file.path(directory, 'failed-stage.rds'); calls <- 0L
  first <- testlet_main_checkpoint(path, list(version = 1L), { calls <- calls + 1L; list(error = 'retained failure') })
  second <- testlet_main_checkpoint(path, list(version = 1L), { calls <- calls + 1L; stop('unexpected retry') })
  rejected <- tryCatch({testlet_main_checkpoint(path, list(version = 2L), stop('must not execute')); FALSE}, error = function(e) TRUE)
  stopifnot(identical(first, second), calls == 1L, rejected, !file.exists(paste0(path, '.tmp')))
  invisible(capture.output(bridge <- testlet_pilot_summarize(file.path(directory, 'pilot'),
    'validation-results/local-testlet-independent-pilot-20260917')))
  tables <- c('status', 'rows', 'counts', 'summaries', 'paired', 'replicate_rows', 'scoring')
  stopifnot(all(vapply(tables, function(name) identical(bridge[[name]], x[[name]]), logical(1))),
    all(bridge$audit$Pass), identical(x$plan$sources, tools::md5sum(names(x$plan$sources))))
  cat('PASS: 40 saved status/target bridges; retained failures; reference gates; checkpoint reuse/mismatch; seven unchanged aggregate tables\n')
  invisible(TRUE)
}

if (sys.nframe() == 0L) { options(warn = 2); check_testlet_main_runner() }
