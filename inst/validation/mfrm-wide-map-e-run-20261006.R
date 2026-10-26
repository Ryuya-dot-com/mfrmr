# A bounded numerical output qualification on original E inputs. This does
# not launch the R50 study or qualify statistical coverage. Frozen source only.
wide_e_job <- function(input, spec, future_path, out, runtime, sources) {
  stopifnot(is.null(spec$args$jml_correction_order),
    identical(spec, wide_e_specs(input)[[spec$Arm]]),
    identical(wide_multi_runtime(), runtime), identical(tools::md5sum(names(sources)), sources))
  future <- wide_f_read(future_path)$payload
  manifest <- list(InputId = input$InputId, spec = spec, runtime = runtime,
    sources = sources, future = tools::md5sum(future_path))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saved <- wide_mml_phase(file.path(out, 'e-manifest.rds'), 'E-numerical-output-qualification-v1', function() manifest)
  stopifnot(identical(saved, manifest))
  binding <- wide_mml_hash(manifest)
  output_path <- file.path(out, 'outputs.rds')
  if (file.exists(output_path)) return(wide_mml_phase(output_path, binding, function() stop('Unreachable')))
  cat('Starting', spec$ConditionId, spec$Replicate, spec$Arm, '\n'); flush.console()
  calibration <- file.path(out, 'calibration')
  selected <- wide_multi_run(spec, calibration)
  source <- wide_f_source(calibration, input)
  q <- if (spec$args$method == 'MML') 31L else 0L
  first <- wide_f_read(file.path(calibration, paste0('q', q, '-fit.rds')))
  stage <- paste0('initial:q', q, ':', first$checksum)
  initial <- wide_recovery_collect(input, spec, first$payload, stage)
  intervals <- wide_interval_recovery(input, spec, selected)
  native <- wide_e_training_native(input, spec, first$payload, stage)
  panels <- list(training = wide_e_training_panel(input), population = wide_e_future_panel(input, future))
  records <- attempts <- list()
  for (panel in panels) for (prior in c('reference', 'retained')) {
    key <- paste(panel$Panel, prior, sep = '--')
    scored <- wide_f_run(source, panel, prior, file.path(out, 'scoring', key), runtime)
    records[[key]] <- wide_f_records(source, panel, scored)
    attempts[[key]] <- lapply(scored$attempts, function(a) a[c('elapsed', 'error', 'warnings')])
  }
  value <- list(initial = initial, intervals = intervals, native = native,
    scoring = do.call(rbind, records), scoring_attempts = attempts,
    source_stage = source$stage, calibration_stages = selected$stages,
    completed = TRUE, scope = 'Numerical bridge qualification; no R50 or coverage conclusion.')
  stopifnot(identical(wide_multi_runtime(), runtime), identical(tools::md5sum(names(sources)), sources))
  result <- wide_mml_phase(output_path, binding, function() value)
  cat('Completed', spec$ConditionId, spec$Replicate, spec$Arm, 'all ordinary-arm output stages\n')
  flush.console(); result
}

wide_e_qualification <- function(mode) {
  root <- 'validation-results/mfrm-wide-map-e-output-bridge-20261006'
  source_root <- file.path(root, 'numerical-source')
  stopifnot(identical(normalizePath('.'), normalizePath(source_root)),
    mode %in% c('prepare', 'run', 'replay'))
  pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
  helpers <- paste0('inst/validation/mfrm-wide-map-', c('mml-stages-20261001',
    'jml-stages-20261001', 'output-summary-20261001', 'multi-output-20261001',
    'recovery-20261002', 'interval-recovery-20261002', 'f-scoring-20261002',
    'e-output-20261006'), '.R')
  for (file in helpers) sys.source(file, envir = globalenv())
  qualification <- readRDS(file.path(root, 'check.rds'))
  stopifnot(isTRUE(qualification$ChecksPassed), isTRUE(qualification$FreshReplayWithoutGeneration),
    identical(wide_multi_runtime(), qualification$Runtime))
  sources <- tools::md5sum(c(helpers, 'inst/validation/mfrm-wide-map-e-run-20261006.R'))
  stopifnot(!anyNA(sources))
  out <- file.path(root, 'numerical'); path <- file.path(out, 'dispatch.rds')
  if (mode == 'prepare') {
    stopifnot(!dir.exists(out)); dir.create(out)
    cases <- data.frame(ConditionId = c('E:E0:N20:SD1:S-PCM', 'E:E0:N240:SD1:S-PCM',
      'E:E6-missing0.30:N240:SD1:S-PCM'), Replicate = c(1L, 5L, 5L),
      Future = file.path(root, c('future-parent-2.rds', 'future-parent-17.rds', 'future-parent-17.rds')))
    jobs <- list()
    for (i in seq_len(nrow(cases))) {
      row <- cases[i, ]; input <- wide_e_input(row$ConditionId, row$Replicate)
      specs <- wide_e_specs(input)
      for (arm in c('PCM-MML-free-population', 'PCM-JML'))
        jobs[[length(jobs)+1L]] <- list(input = input, spec = specs[[arm]], future = row$Future)
    }
    stopifnot(length(jobs) == 6L)
    for (job in jobs) wide_e_future_panel(job$input, wide_f_read(job$future)$payload)
    dispatch <- list(jobs = jobs, runtime = wide_multi_runtime(), sources = sources,
      qualification = tools::md5sum(file.path(root, 'check.rds')),
      inputs = tools::md5sum(unique(c(cases$Future, unlist(lapply(jobs,
        function(j) names(j$input$provenance$bundle)))))),
      scope = 'Six numerical output qualifications on three existing inputs; all broader E conditions/arms and statistical confirmation remain required.')
    wide_mml_save(dispatch, path)
    cat('Prepared six ordinary PCM jobs; no fitting.\n'); return(invisible(dispatch))
  }
  d <- readRDS(path)
  stopifnot(identical(d$runtime, wide_multi_runtime()), identical(d$sources, sources),
    identical(tools::md5sum(names(d$inputs)), d$inputs),
    identical(tools::md5sum(names(d$qualification)), d$qualification))
  if (mode == 'replay') {
    for (i in seq_along(d$jobs)) stopifnot(file.exists(file.path(out, sprintf('job-%03d', i), 'outputs.rds')))
    for (name in c('wide_mml_fit', 'wide_f_predict', 'wide_mml_score', 'wide_multi_consume'))
      assign(name, function(...) stop('Fresh output replay must not fit, score or recompute inference'),
        envir = globalenv())
  }
  lock <- file.path(out, 'RUNNING')
  stopifnot(dir.create(lock, showWarnings = FALSE))
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  results <- lapply(seq_along(d$jobs), function(i) {
    j <- d$jobs[[i]]
    wide_e_job(j$input, j$spec, j$future, file.path(out, sprintf('job-%03d', i)), d$runtime, d$sources)
  })
  if (mode == 'replay') {
    stopifnot(all(vapply(results, function(x) isTRUE(x$completed), TRUE)))
    wide_mml_phase(file.path(out, 'fresh-replay.rds'), tools::md5sum(path), function()
      list(ChecksPassed = TRUE, Jobs = length(results), Fits = 0L, Scores = 0L,
        Sources = sources, Dispatch = tools::md5sum(path), Session = capture.output(sessionInfo())))
  }
  invisible(results)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 1L)
  wide_e_qualification(args)
}
