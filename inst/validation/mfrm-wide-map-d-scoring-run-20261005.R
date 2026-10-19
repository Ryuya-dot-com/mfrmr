# Complete D scoring only for calibration-output jobs already finished.
# prepare OUTPUT from development; run OUTPUT [ROW ...] from OUTPUT/source.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (n in c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-', n, '-20261001.R'))
extra <- c('inst/validation/mfrm-wide-map-f-scoring-20261002.R',
  'inst/validation/mfrm-wide-map-d-response-20261005.R',
  'inst/validation/mfrm-wide-map-d-scoring-20261005.R')
for (path in extra) source(path)
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) >= 2L, arguments[1L] %in% c('prepare', 'run'))
mode <- arguments[1L]; out <- arguments[2L]
script <- 'inst/validation/mfrm-wide-map-d-scoring-run-20261005.R'
calibrations <- 'validation-results/mfrm-wide-map-d-retained-output-20261005'
qualification <- 'validation-results/mfrm-wide-map-d-scoring-r461-20261005'
dispatch_path <- file.path(calibrations, 'dispatch.rds'); dispatch <- readRDS(dispatch_path)
stopifnot(identical(R.version.string, dispatch$runtime$R))
runtime <- wide_multi_runtime()
runtime$source <- c(runtime$source, tools::md5sum(c(extra, script,
  'inst/validation/mfrm-wide-map-d-inputs-20261001.R')))
paths <- unique(c(names(runtime$source)[names(runtime$source) != 'loaded:mfrmr'],
  'src/mfrmr.so', 'LICENSE', 'inst/validation/mfrm-wide-map-d-output-20261005.R'))
if (mode == 'prepare') {
  stopifnot(!dir.exists(out))
  q <- wide_f_read(file.path(qualification, 'qualification.rds'))
  common <- intersect(names(runtime$source), names(q$binding$runtime$source))
  stopifnot(identical(runtime$source[common], q$binding$runtime$source[common]),
    identical(runtime$R, q$binding$runtime$R), identical(runtime$dependencies, q$binding$runtime$dependencies),
    identical(runtime$threads, q$binding$runtime$threads))
  proof_paths <- file.path(qualification, c('qualification.rds', 'qualification-manifest.rds',
    'fresh-replay.rds', 'panel-check.rds', 'job-203-panels.rds', 'job-102-panels.rds'))
  proofs <- tools::md5sum(proof_paths); stopifnot(!anyNA(proofs))
  sources <- tools::md5sum(paths); stopifnot(!anyNA(sources))
  dir.create(file.path(out, 'source'), recursive = TRUE)
  for (path in paths) {
    target <- file.path(out, 'source', path)
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(path, target), unname(tools::md5sum(target)) == unname(sources[path]))
  }
  stopifnot(file.symlink(normalizePath('validation-results'), file.path(out, 'source/validation-results')))
  wide_mml_save(list(rows = dispatch$rows, dispatch = tools::md5sum(dispatch_path),
    runtime = runtime, sources = sources, qualification = proofs,
    protocol = 'Retained prior; population-relative z; unchanged 31/61/121 batch integration retry; all declared F-pop/F-grid panels.',
    scope = 'Admitted historical two-family cases only. Other D arms, training scores, portability and full D scope remain separate.',
    unfinished_calibrations = 'Pending, never classified as statistical failures.'), file.path(out, 'dispatch.rds'))
  stopifnot(file.copy('inst/validation/internal-roadmap-0.2.4.md', file.path(out, 'protocol-before-execution.md')))
  cat('D scoring source frozen for 208 retained calibration jobs.\n')
} else {
  manifest <- readRDS(file.path(out, 'dispatch.rds'))
  stopifnot(identical(normalizePath('.'), normalizePath(file.path(out, 'source'))),
    identical(runtime, manifest$runtime))
  for (h in list(manifest$sources, manifest$dispatch, manifest$qualification))
    stopifnot(identical(tools::md5sum(names(h)), h))
  lock <- file.path(out, 'RUNNING'); stopifnot(dir.create(lock, showWarnings = FALSE))
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  run_ready <- function() {
    on.exit(unlink(lock, recursive = TRUE))
    ids <- if (length(arguments) > 2L) as.integer(arguments[-c(1L, 2L)]) else seq_len(nrow(manifest$rows))
    stopifnot(!anyNA(ids), !anyDuplicated(ids), all(ids %in% seq_len(nrow(manifest$rows))))
    # Snapshot readiness once: no polling, new calibrations or outcome-based selection.
    available <- file.exists(file.path(calibrations, manifest$rows$Job[ids], 'd-outputs.rds'))
    pending <- manifest$rows$Job[ids[!available]]; completed <- character()
    for (i in ids[available]) {
      row <- manifest$rows[i, ]; input <- wide_d_f_input(row$ConditionId, row$Replicate)
      source <- wide_d_f_source(file.path(calibrations, row$Job), input)
      model <- source$model_source; common <- intersect(names(model), names(runtime$source))
      stopifnot(identical(model[common], runtime$source[common]))
      path <- file.path(out, row$Job); dir.create(path, recursive = TRUE, showWarnings = FALSE)
      qualified_panels <- file.path(qualification, paste0(row$Job, '-panels.rds'))
      future <- wide_mml_phase(file.path(path, 'panels.rds'),
        list(input = input$provenance, runtime = runtime), function()
          if (row$Job %in% c('job-203','job-102')) wide_f_read(qualified_panels)$payload else wide_d_f_panels(input))
      stopifnot(identical(future$calibration_provenance, input$provenance))
      records <- phases <- list()
      for (panel in future$panels) {
        key <- panel$Panel
        if (row$Job %in% c('job-203','job-102')) {
          reused <- file.path(qualification, paste(row$Job, key, sep = '--'))
          selected <- wide_f_read(file.path(reused, 'selected.rds'))$payload
          qm <- wide_f_read(file.path(reused, 'manifest.rds'))$payload
          stopifnot(identical(qm$SourceId, source$SourceId), identical(qm$PanelId, panel$PanelId),
            identical(qm$data, panel$data[c('Person', panel$facets, 'Score')]),
            identical(selected$identity, wide_mml_hash(qm)), qm$prior == 'retained',
            identical(qm$orders, c(31L,61L,121L)))
          phases[[key]] <- tools::md5sum(list.files(reused, '^(score-q[0-9]+|selected|manifest)[.]rds$', full.names = TRUE))
        } else {
          scoring <- file.path(path, 'scoring', key)
          selected <- wide_d_f_run(source, panel, scoring, runtime)
          phases[[key]] <- tools::md5sum(list.files(scoring, '^(score-q[0-9]+|selected|manifest)[.]rds$', full.names = TRUE))
        }
        records[[key]] <- wide_d_f_records(source, panel, selected)
      }
      value <- list(job = row, records = do.call(rbind, records), source_ready = isTRUE(source$review$ready),
        scoring_phases = phases, source_files = source$files, completed = TRUE)
      binding <- list(dispatch = tools::md5sum(file.path(out, 'dispatch.rds')),
        calibration = source$files, panels = tools::md5sum(file.path(path, 'panels.rds')), phases = phases)
      saved <- wide_mml_phase(file.path(path, 'outputs.rds'), binding, function() value)
      stopifnot(identical(saved, value))
      z <- value$records[value$records$Rule == 'refinement', ]
      cat('Completed', row$Job, 'panels', length(records), 'scores', sum(z$ScoreAvailable),
        'intervals', sum(z$IntervalAvailable), 'of', nrow(z), '\n'); flush.console()
      completed <- c(completed, row$Job)
    }
    stopifnot(identical(tools::md5sum(names(manifest$sources)), manifest$sources))
    cat('Pass completed:', length(completed), 'ready jobs;', length(pending), 'pending calibration jobs.\n')
  }
  run_ready()
}
