# Repository-only equivalence and timing experiment; see the companion plan.
source('inst/validation/local-testlet-estimation-0.2.4.R')

run_testlet_speed <- function() {
  output <- 'validation-results/local-testlet-speed-20260917'
  prefix <- 'inst/validation/local-testlet-speed-0.2.4'
  baseline <- new.env(parent = environment())
  # Saved before editing, with the original function environments rebound here
  # so the old evaluator calls the old reference and old boundary derivative.
  sys.source(file.path(output, 'baseline.R'), envir = baseline)
  baseline_provenance <- readRDS(file.path(output, 'baseline-provenance.rds'))
  stopifnot(unname(tools::md5sum(file.path(output, 'baseline.R'))) ==
    unname(tail(baseline_provenance$sources, 1)))
  evidence <- readRDS('inst/validation/local-testlet-information-0.2.4-evidence.rds')
  fitted_cases <- evidence$plan$cases
  repeated <- lapply(c(1, 7, 17, 120), function(n)
    readRDS(sprintf('validation-results/local-testlet-information-20260917/N%d.rds', n)))
  names(repeated) <- paste0('N', c(1, 7, 17, 120))
  heterogeneous <- fitted_cases$original$fixture
  patterns <- as.matrix(expand.grid(rep(list(0:2), 6)))
  heterogeneous$response <- patterns[round(seq(1, nrow(patterns), length.out = 120)), ]
  dimnames(heterogeneous$response) <- list(paste0('H', 1:120), colnames(heterogeneous$response))
  missing <- heterogeneous
  missing$response[seq(13L, length(missing$response), by = 13L)] <- NA_real_
  benchmark_cases <- list(repeated = repeated$N120$fixture,
    heterogeneous = heterogeneous, heterogeneous_missing = missing)
  parameters <- fitted_cases$original$fit$par
  sources <- tools::md5sum(c(paste0(prefix, '.R'),
    'inst/validation/local-testlet-estimation-0.2.4.R',
    'inst/validation/local-testlet-stress-0.2.4.R',
    'inst/validation/local-testlet-tam-reference-0.2.4.R'))
  inputs <- tools::md5sum(c('inst/validation/local-testlet-information-0.2.4-evidence.rds',
    sprintf('validation-results/local-testlet-information-20260917/N%d.rds', c(1, 7, 17, 120))))
  plan <- list(sources = sources, inputs = inputs, baseline_provenance = baseline_provenance,
    baseline_source = readLines(file.path(output, 'baseline.R')),
    fitted_cases = fitted_cases, benchmark_cases = benchmark_cases,
    parameters = parameters, design = readLines(paste0(prefix, '.md')),
    started = Sys.time(), session = sessionInfo())
  saveRDS(plan, file.path(output, 'plan.rds'))
  checks <- comparisons <- timings <- fits <- list()
  check <- function(id, quantity, error, tolerance) {
    checks[[length(checks) + 1L]] <<- data.frame(Case = id, Quantity = quantity,
      Error = error, Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
    write.csv(do.call(rbind, checks), paste0(prefix, '-checks.csv'), row.names = FALSE)
  }
  compare <- function(id, fixture, par, order, saved = NULL) {
    old <- if (is.null(saved)) stress_capture(baseline$testlet_estimation_evaluate(fixture, par, order))
      else saved
    new <- stress_capture(testlet_estimation_evaluate(fixture, par, order))
    comparisons[[id]] <<- list(fixture = fixture, par = par, order = order, old = old, new = new)
    saveRDS(comparisons[[id]], file.path(output, paste0(id, '.rds')))
    ok <- !is.null(old$value) && !is.null(new$value) &&
      !length(old$warnings) && !length(new$warnings)
    check(id, 'capture', if (ok) 0 else Inf, 0)
    if (!ok) return(invisible(NULL))
    a <- old$value
    b <- new$value
    shape <- identical(names(a), names(b)) && identical(names(a$gradient), names(b$gradient)) &&
      identical(dimnames(a$moments), dimnames(b$moments)) &&
      identical(dim(a$moments), dim(b$moments)) && length(a$person_loglik) == length(b$person_loglik)
    check(id, 'shape_and_order', if (shape) 0 else Inf, 0)
    check(id, 'log_likelihood', max(abs(c(a$loglik - b$loglik,
      a$person_loglik - b$person_loglik))), 1e-9)
    check(id, 'moments', max(abs(a$moments - b$moments)), 1e-9)
    check(id, 'structural_and_log_variance_score', max(abs(c(a$gradient[1:5] - b$gradient[1:5],
      (a$gradient[6] - b$gradient[6]) * par[6]))), 1e-9)
    check(id, 'direct_variance_score', abs(a$gradient[6] - b$gradient[6]),
      if (par[6] == 0) 1e-9 else 1e-6)
    cat('COMPARE', id, 'old', old$elapsed, 'new', new$elapsed, '\n')
  }
  for (case in fitted_cases) compare(paste0('fitted_', case$id), case$fixture, case$fit$par, 181L)
  for (case in stress_cases()) compare(case$id, case$fixture,
    c(case$parameters, variance = case$variance), 241L)
  for (id in names(repeated)) compare(id, repeated[[id]]$fixture, parameters, 181L, repeated[[id]]$evaluated)
  for (id in c('heterogeneous', 'heterogeneous_missing'))
    compare(id, benchmark_cases[[id]], parameters, 181L)
  stopifnot(all(do.call(rbind, checks)$Pass))

  # Warmup comparisons above are excluded. Alternate which implementation runs
  # first, and run GC before each timed call; reported call times include any
  # garbage collection triggered during evaluation itself.
  for (id in names(benchmark_cases)) for (replicate in 1:3) {
    engines <- if (replicate %% 2L) c('old', 'new') else c('new', 'old')
    for (engine in engines) {
      gc()
      evaluate <- if (engine == 'old') baseline$testlet_estimation_evaluate else testlet_estimation_evaluate
      result <- stress_capture(evaluate(benchmark_cases[[id]], parameters, 181L))
      timings[[length(timings) + 1L]] <- data.frame(Case = id, Replicate = replicate,
        Engine = engine, Seconds = result$elapsed, Error = result$error,
        Warnings = paste(result$warnings, collapse = ' | '))
      check(paste(id, replicate, engine, sep = '_'), 'timing_capture',
        if (!is.null(result$value) && !length(result$warnings)) 0 else Inf, 0)
      write.csv(do.call(rbind, timings), paste0(prefix, '-timings.csv'), row.names = FALSE)
      cat('TIMING', id, replicate, engine, result$elapsed, '\n')
    }
  }
  timings <- do.call(rbind, timings)
  timing_summary <- do.call(rbind, lapply(names(benchmark_cases), function(id) {
    values <- timings[timings$Case == id, ]
    old <- median(values$Seconds[values$Engine == 'old'])
    new <- median(values$Seconds[values$Engine == 'new'])
    check(id, 'speedup_at_least_2', if (old / new >= 2) 0 else Inf, 0)
    data.frame(Case = id, Persons = nrow(benchmark_cases[[id]]$response),
      UniqueRows = nrow(unique(benchmark_cases[[id]]$response)),
      OldMedianSeconds = old, NewMedianSeconds = new, Speedup = old / new)
  }))
  write.csv(timing_summary, paste0(prefix, '-summary.csv'), row.names = FALSE)
  for (case in fitted_cases) {
    start <- if (case$id == 'original') c(case$fixture$parameters, variance = .49) else case$fit$par
    result <- testlet_bounded_fit(case$fixture, start)
    fits[[case$id]] <- list(case = case, result = result)
    saveRDS(fits[[case$id]], file.path(output, paste0('fit-', case$id, '.rds')))
    value <- result$captured$value
    check(paste0('fit_', case$id), 'capture',
      if (!is.null(value) && !length(result$captured$warnings)) 0 else Inf, 0)
    if (is.null(value)) next
    check(paste0('fit_', case$id), 'convergence', value$convergence, 0)
    check(paste0('fit_', case$id), 'projected_score', value$projected_score, 1e-5)
    check(paste0('fit_', case$id), 'parameters', max(abs(value$par - case$fit$par)), 1e-4)
    check(paste0('fit_', case$id), 'log_likelihood', abs(value$loglik - case$fit$loglik), 1e-7)
    check(paste0('fit_', case$id), 'moments', max(abs(value$moments - case$fit$moments)), 1e-5)
    cat('FIT', case$id, 'code', value$convergence, 'score', value$projected_score,
      'elapsed', result$captured$elapsed, '\n')
  }
  check('provenance', 'sources_unchanged_during_run',
    if (identical(sources, tools::md5sum(names(sources)))) 0 else Inf, 0)
  completed <- list(plan = plan, comparisons = comparisons, timings = timings,
    timing_summary = timing_summary, fits = fits, checks = do.call(rbind, checks), finished = Sys.time())
  saveRDS(completed, file.path(output, 'completed.rds'))
  saveRDS(completed, paste0(prefix, '-evidence.rds'))
  print(timing_summary)
  print(table(completed$checks$Pass))
  stopifnot(all(completed$checks$Pass))
}

if (sys.nframe() == 0L) run_testlet_speed()
