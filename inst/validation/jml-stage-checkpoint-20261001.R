# Development-only observation of the existing corrected-JML solver.
# No estimator changes, continuation from partial iterates, or public API hooks.
# Rscript THIS_FILE SAVED_PILOT_INPUT ORDER NEW_OUTPUT_DIRECTORY [SAVED_FIT]

jml_checkpoint_function <- function(original, out) {
  journal <- new.env(parent = emptyenv())
  journal$started <- proc.time()[['elapsed']]
  journal$last_write <- -Inf; journal$evaluations <- 0L
  journal$context <- list(); journal$io_error <- NULL
  record <- function(event, values = list()) {
    if (event == 'solver_enter') journal$context <- list()
    journal$context[names(values)] <- values
    elapsed <- proc.time()[['elapsed']] - journal$started
    payload <- list(event = event, elapsed = elapsed,
      score_evaluations = journal$evaluations, context = journal$context,
      diagnostic_only = TRUE, partial_iterate_is_not_a_fit = TRUE)
    tryCatch({
      temporary <- file.path(out, 'latest.rds.tmp')
      saveRDS(payload, temporary)
      stopifnot(file.rename(temporary, file.path(out, 'latest.rds')))
      row <- data.frame(Event = event, Elapsed = elapsed,
        ScoreEvaluations = journal$evaluations,
        Start = if (is.null(journal$context$start)) '' else journal$context$start,
        Stage = if (is.null(journal$context$stage)) NA_integer_ else journal$context$stage)
      path <- file.path(out, 'events.tsv')
      write.table(row, path, sep = '\t', row.names = FALSE, quote = FALSE,
        append = file.exists(path), col.names = !file.exists(path))
    }, error = function(e) {
      journal$io_error <- conditionMessage(e); stop(e)
    })
    journal$last_write <- elapsed
    invisible(NULL)
  }
  score <- function(beta, value) {
    journal$evaluations <- journal$evaluations + 1L
    if (proc.time()[['elapsed']] - journal$started - journal$last_write >= 5)
      record('score_evaluated', list(last_beta = beta, last_residual = max(abs(value))))
    invisible(NULL)
  }
  counts <- setNames(integer(4L), c('fn', 'solver', 'attempt', 'covariance'))
  instrument <- function(x) {
    if (!is.call(x)) return(x)
    if (identical(x[[1L]], quote(`<-`))) {
      if (identical(x[[2L]], quote(fn))) {
        stopifnot(identical(x[[3L]][[1L]], quote(`function`)),
          identical(x[[3L]][[2L]], as.pairlist(alist(b = ))),
          identical(x[[3L]][[3L]], quote(problem$mean_score(b, order))))
        counts['fn'] <<- counts['fn'] + 1L
        return(quote(fn <- function(b) {
          value <- problem$mean_score(b, order)
          checkpoint_score(b, value)
          value
        }))
      }
      if (identical(x[[2L]], quote(z)) && is.call(x[[3L]]) &&
          identical(x[[3L]][[1L]], quote(nleqslv::nleqslv))) {
        counts['solver'] <<- counts['solver'] + 1L
        return(substitute({
          checkpoint_record('solver_enter', list(start = names(starts)[s],
            stage = stage, settings = setting, policy = policy, attempts = attempts,
            initial_beta = starts[[s]]))
          EXPR
          checkpoint_record('solver_return', list(solver = z))
        }, list(EXPR = x)))
      }
      if (identical(x[[2L]], quote(attempts[[length(attempts) + 1L]]))) {
        counts['attempt'] <<- counts['attempt'] + 1L
        return(substitute({
          EXPR
          checkpoint_record('attempt_reviewed', list(attempts = attempts))
        }, list(EXPR = x)))
      }
      if (identical(x[[2L]], quote(covariance)) && is.call(x[[3L]]) &&
          identical(x[[3L]][[1L]], quote(tryCatch))) {
        counts['covariance'] <<- counts['covariance'] + 1L
        return(substitute({
          checkpoint_record('covariance_enter', list(point = point, attempts = attempts))
          EXPR
          checkpoint_record('covariance_return', list(covariance = covariance))
        }, list(EXPR = x)))
      }
    }
    # Preserve missing call arguments (e.g. policy$stages[stage, ]).
    for (i in seq_along(x)) if (!identical(x[[i]], quote(expr = ))) x[i] <- list(instrument(x[[i]]))
    x
  }
  logged <- original; body(logged) <- instrument(body(original))
  stopifnot(all(counts == 1L))
  environment(logged) <- list2env(list(checkpoint_record = record,
    checkpoint_score = score), parent = environment(original))
  list(fit = logged, record = record, journal = journal, hook_counts = counts)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) %in% 3:4, !dir.exists(args[3L]))
  input <- args[1L]; order <- as.integer(args[2L]); out <- args[3L]
  stopifnot(order %in% c(2L, 4L))
  pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
  x <- readRDS(input)
  prep <- mfrmr:::prepare_mfrm_data(x$data, 'Person', x$facets, 'Score',
    rating_min = 0, rating_max = 2, keep_original = FALSE)
  problem <- mfrmr:::mfrm_jml_adjustment_problem(prep$data, 'Person', x$facets,
    'score_k', 'Criterion', 2L)
  dir.create(file.path(out, 'source'), recursive = TRUE)
  sources <- c('inst/validation/jml-stage-checkpoint-20261001.R',
    list.files('R', full.names = TRUE), list.files('src', pattern = '\\.(cpp|h|so)$', full.names = TRUE))
  for (source in sources) {
    dest <- file.path(out, 'source', source)
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(source, dest))
  }
  logger <- jml_checkpoint_function(mfrmr:::mfrm_jml_adjustment_fit, out)
  saveRDS(list(input = normalizePath(input), input_md5 = tools::md5sum(input),
    source_md5 = tools::md5sum(sources), hook_counts = logger$hook_counts,
    order = order, maxit = 400L, sampling = 'fixed_rosters',
    scope = 'Instrumentation replay of a retained input; not a new replication or public resume API.',
    session = capture.output(sessionInfo())), file.path(out, 'manifest.rds'))
  logger$record('started')
  result <- logger$fit(problem, order, maxit = 400L, sampling = 'fixed_rosters')
  stopifnot(is.null(logger$journal$io_error))
  saveRDS(result, file.path(out, 'completed-result.rds'))
  logger$record('completed', list(point = result$point, covariance = result$covariance))
  if (length(args) == 4L) {
    retained <- readRDS(args[4L])$fit$jml_adjustment
    comparison <- all.equal(result, retained, tolerance = 0, check.attributes = TRUE)
    saveRDS(list(identical = identical(result, retained), comparison = comparison,
      retained_md5 = tools::md5sum(args[4L])), file.path(out, 'replay-check.rds'))
    stopifnot(isTRUE(comparison))
    cat('All saved solver, point and covariance fields match the retained result exactly.\n')
  }
}
