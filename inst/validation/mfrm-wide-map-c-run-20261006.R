# C numerical output qualification using the unchanged stage and scoring rules.
wide_c_job <- function(input, spec, future_path, out, runtime, sources) {
  stopifnot(spec$args$model %in% c("RSM","PCM","GPCM"),
    identical(spec, wide_c_specs(input)[[spec$Arm]]),
    identical(wide_multi_runtime(), runtime), identical(tools::md5sum(names(sources)), sources))
  future <- wide_f_read(future_path)$payload
  manifest <- list(InputId = input$InputId, spec = spec, runtime = runtime,
    sources = sources, future = tools::md5sum(future_path))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saved <- wide_mml_phase(file.path(out, 'c-manifest.rds'), 'C-numerical-output-qualification-v1', function() manifest)
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
    wide_jml_candidate(input, spec, first$payload, stage) else NULL
  native <- wide_c_training_native(input, spec, first$payload, stage)
  panels <- list(training = wide_c_training_panel(input), population = wide_c_future_panel(input, future))
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
  cat('Completed', spec$ConditionId, spec$Replicate, spec$Arm, 'all C output stages\n')
  flush.console(); result
}

wide_c_qualification <- function(mode) {
  root <- 'validation-results/mfrm-wide-map-c-output-bridge-20261006'
  stopifnot(mode %in% c('prepare','run'),
    identical(normalizePath('.'),normalizePath(file.path(root,'source'))))
  pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
  helpers <- paste0('inst/validation/mfrm-wide-map-',c('mml-stages-20261001',
    'jml-stages-20261001','output-summary-20261001','multi-output-20261001',
    'recovery-20261002','interval-recovery-20261002','f-scoring-20261002',
    'facet-outputs-20261006','c-output-20261006'),'.R')
  for(f in helpers)sys.source(f,envir=globalenv())
  script <- sub('^--file=','',grep('^--file=',commandArgs(),value=TRUE))
  sources <- tools::md5sum(c(helpers,script))
  proof_path <- file.path(root,'check.rds');proof <- readRDS(proof_path)
  fresh_path <- file.path(root,'fresh-replay.rds');fresh <- readRDS(fresh_path)
  stopifnot(isTRUE(proof$ChecksPassed),isTRUE(fresh$ChecksPassed),
    identical(wide_multi_runtime(),proof$Runtime),identical(fresh$Runtime,proof$Runtime))
  for(h in list(proof$Sources,proof$Inputs,fresh$Proof,fresh$FreshSource))
    stopifnot(identical(tools::md5sum(names(h)),h))
  out <- file.path(root,'numerical');path <- file.path(out,'dispatch.rds')
  if(mode=='prepare') {
    stopifnot(!dir.exists(out));dir.create(out)
    cases <- data.frame(Design=c('three-categories','five-categories','six-raters-paired',
      'four-tasks-two-observed','five-criteria-two-tasks-changing-pair','five-categories',
      'three-categories','five-categories'),N=c(rep(20L,5),480L,60L,240L),
      Truth=c(rep('S-PCM',6),'S-RSM','S-GPCM'),FutureParent=c(rep(1L,5),2L,3L,4L))
    inputs <- specs <- futures <- list()
    for(i in seq_len(nrow(cases))) {
      row <- cases[i,];condition <- paste('C',row$Design,paste0('N',row$N),'SD1',row$Truth,sep=':')
      inputs[[i]] <- wide_c_input(condition,1L);specs[[i]] <- wide_c_specs(inputs[[i]])
      futures[[i]] <- file.path(root,paste0('future-parent-',row$FutureParent),'future.rds')
      wide_c_future_panel(inputs[[i]],wide_f_read(futures[[i]])$payload)
    }
    jobs <- list()
    for(corrected in c(FALSE,TRUE))for(i in seq_along(inputs))for(spec in specs[[i]])
      if(identical(!is.null(spec$args$jml_correction_order),corrected))
        jobs[[length(jobs)+1L]] <- list(input=inputs[[i]],spec=spec,future=futures[[i]])
    stopifnot(length(jobs)==40L)
    d <- list(jobs=jobs,runtime=wide_multi_runtime(),sources=sources,
      qualification=tools::md5sum(c(proof_path,fresh_path)),inputs=proof$Inputs,
      scope='Forty C numerical bridge jobs on eight saved category/facet templates, including all four N anchors and three truths. Planned capacity exclusions and fixed-roster covariance limitations are retained. This is not the full C study or a coverage result.')
    wide_mml_save(d,path)
    cat('Prepared forty C jobs on eight existing templates; no fitting or data generation.\n')
    return(invisible(NULL))
  }
  d <- readRDS(path)
  stopifnot(identical(d$runtime,wide_multi_runtime()),identical(d$sources,sources))
  for(h in list(d$inputs,d$qualification))stopifnot(identical(tools::md5sum(names(h)),h))
  lock <- file.path(out,'RUNNING');stopifnot(dir.create(lock,showWarnings=FALSE))
  on.exit(unlink(lock,recursive=TRUE),add=TRUE)
  writeLines(as.character(Sys.getpid()),file.path(lock,'pid'))
  for(i in seq_along(d$jobs)) {
    j <- d$jobs[[i]]
    wide_c_job(j$input,j$spec,j$future,file.path(out,sprintf('job-%03d',i)),d$runtime,d$sources)
  }
  invisible(NULL)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  wide_c_qualification(args)
}
