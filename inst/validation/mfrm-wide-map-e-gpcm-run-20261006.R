# Complete the four declared GPCM arms on the same retained E inputs.
# Correction orders and random-roster law are fixed before outcomes; research
# candidate intervals remain distinct from unsupported formal JML intervals.
wide_e_gpcm_job <- function(input, spec, future_path, out, runtime, sources) {
  stopifnot(spec$args$model == "GPCM",
    identical(spec, wide_e_specs(input)[[spec$Arm]]),
    identical(wide_multi_runtime(), runtime), identical(tools::md5sum(names(sources)), sources))
  future <- wide_f_read(future_path)$payload
  manifest <- list(InputId = input$InputId, spec = spec, runtime = runtime,
    sources = sources, future = tools::md5sum(future_path))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saved <- wide_mml_phase(file.path(out, 'e-manifest.rds'), 'E-GPCM-numerical-output-qualification-v1', function() manifest)
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
  candidate <- if (!is.null(spec$args$jml_correction_order))
    wide_e_jml_candidate(input, spec, first$payload, stage) else NULL
  native <- wide_e_training_native(input, spec, first$payload, stage)
  panels <- list(training = wide_e_training_panel(input), population = wide_e_future_panel(input, future))
  records <- attempts <- artifacts <- list()
  artifact_dir <- if (!is.null(spec$args$jml_correction_order)) file.path(out, 'scoring-artifacts') else NULL
  for (panel in panels) for (prior in c('reference', 'retained')) {
    key <- paste(panel$Panel, prior, sep = '--')
    scored <- wide_f_run(source, panel, prior, file.path(out, 'scoring', key), runtime, artifact_dir)
    records[[key]] <- wide_f_records(source, panel, scored)
    attempts[[key]] <- lapply(scored$attempts, function(a) a[c('elapsed', 'error', 'warnings')])
    for (order in names(scored$artifacts)) {
      ref <- scored$artifacts[[order]]
      if (!is.null(artifacts[[order]])) stopifnot(identical(artifacts[[order]]$reference, ref)) else {
        saved_artifact <- wide_f_read(ref$path)
        stopifnot(identical(saved_artifact$checksum, ref$checksum))
        artifacts[[order]] <- list(reference = ref,
          extraction = saved_artifact$payload[c('elapsed', 'error', 'warnings')])
      }
    }
  }
  value <- list(initial = initial, intervals = intervals, candidate = candidate, native = native,
    scoring = do.call(rbind, records), scoring_attempts = attempts, scoring_artifacts = artifacts,
    source_stage = source$stage, calibration_stages = selected$stages,
    completed = TRUE, scope = 'Numerical bridge qualification; no R50 or coverage conclusion.')
  stopifnot(identical(wide_multi_runtime(), runtime), identical(tools::md5sum(names(sources)), sources))
  result <- wide_mml_phase(output_path, binding, function() value)
  cat('Completed', spec$ConditionId, spec$Replicate, spec$Arm, 'all GPCM output stages\n')
  flush.console(); result
}

wide_e_gpcm_qualification <- function(mode) {
  root <- 'validation-results/mfrm-wide-map-e-output-bridge-20261006'
  stopifnot(identical(normalizePath('.'), normalizePath(file.path(root, 'gpcm-source'))),
    mode %in% c('prepare', 'run'))
  pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
  helpers <- paste0('inst/validation/mfrm-wide-map-', c('mml-stages-20261001',
    'jml-stages-20261001', 'output-summary-20261001', 'multi-output-20261001',
    'recovery-20261002', 'interval-recovery-20261002', 'f-scoring-20261002',
    'e-output-20261006', 'e-jml-candidate-20261006'), '.R')
  for (file in helpers) sys.source(file, envir = globalenv())
  previous_path <- file.path(root, 'numerical', 'dispatch.rds')
  previous <- readRDS(previous_path)
  proof_path <- file.path(root, 'numerical', 'independent-output-replay.rds')
  proof <- readRDS(proof_path)
  stopifnot(isTRUE(proof$ChecksPassed), identical(wide_multi_runtime(), previous$runtime))
  for (h in list(previous$sources, previous$inputs, previous$qualification,
    proof$Dispatch, proof$Phases, proof$Sources)) stopifnot(identical(tools::md5sum(names(h)), h))
  sources <- tools::md5sum(c(helpers, 'inst/validation/mfrm-wide-map-e-gpcm-run-20261006.R'))
  stopifnot(!anyNA(sources))
  out <- file.path(root, 'gpcm'); path <- file.path(out, 'dispatch.rds')
  if (mode == 'prepare') {
    stopifnot(!dir.exists(out)); dir.create(out)
    cases <- previous$jobs[c(1L, 3L, 5L)]
    jobs <- list()
    for (case in cases) {
      specs <- wide_e_specs(case$input)
      # Execute the newly connected correction first; all four arms stay in
      # the immutable plan regardless of its availability or numerical result.
      for (arm in c('GPCM-JML-order2', 'GPCM-JML-order4', 'GPCM-JML', 'GPCM-MML-free-population'))
        jobs[[length(jobs)+1L]] <- list(input = case$input, spec = specs[[arm]], future = case$future)
    }
    stopifnot(length(jobs) == 12L)
    for (job in jobs) {
      stopifnot(!is.null(job$spec), job$spec$args$model == 'GPCM')
      wide_e_future_panel(job$input, wide_f_read(job$future)$payload)
      if (!is.null(job$spec$args$jml_correction_order)) {
        candidate <- wide_e_jml_candidate(job$input, job$spec,
          list(error = 'Preflight: fitting not executed', value = NULL), 'not_executed')
        stopifnot(all(!candidate$plan$FormalStructuralInference), all(!candidate$records$Available),
          candidate$sampling$law == 'random_rosters',
          candidate$sampling$PlannedPersons == job$input$provenance$row$N,
          candidate$sampling$ObservedPersons == job$input$provenance$row$ObservedPersons)
      }
    }
    dispatch <- list(jobs = jobs, runtime = wide_multi_runtime(), sources = sources,
      inputs = previous$inputs, ordinary_reuse = tools::md5sum(c(previous_path, proof_path)),
      scope = 'All four additional GPCM arms on the three qualified E inputs. Six ordinary PCM jobs remain reused; no new data, model-dependent redraw or formal coverage claim.')
    wide_mml_save(dispatch, path)
    cat('Prepared twelve GPCM jobs; six completed ordinary PCM jobs retained without recomputation.\n')
    return(invisible(dispatch))
  }
  d <- readRDS(path)
  stopifnot(identical(d$runtime, wide_multi_runtime()), identical(d$sources, sources))
  for (h in list(d$inputs, d$ordinary_reuse)) stopifnot(identical(tools::md5sum(names(h)), h))
  lock <- file.path(out, 'RUNNING')
  stopifnot(dir.create(lock, showWarnings = FALSE))
  on.exit(unlink(lock, recursive = TRUE), add = TRUE)
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  for (i in seq_along(d$jobs)) {
    j <- d$jobs[[i]]
    wide_e_gpcm_job(j$input, j$spec, j$future, file.path(out, sprintf('job-%03d', i)), d$runtime, d$sources)
  }
  invisible(NULL)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 1L)
  wide_e_gpcm_qualification(args)
}
