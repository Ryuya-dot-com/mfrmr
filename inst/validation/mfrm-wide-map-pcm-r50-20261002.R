# The existing 36-condition PCM-truth unit, with all eight calibration arms
# and all required output stages. Serial, atomic/resumable; no wall-clock cap.
wide_pcm_setup <- function() {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  for(n in c('mml-stages-20261001','jml-stages-20261001','output-summary-20261001',
    'multi-output-20261001','recovery-20261002','interval-recovery-20261002','f-scoring-20261002'))
    source(paste0('inst/validation/mfrm-wide-map-',n,'.R'))
}

wide_pcm_specs <- function(input) {
  # This template fixes estimator settings, not results or starting values.
  path <- 'validation-results/mfrm-wide-map-recovery-20261002/witness-manifest.rds'
  specs <- wide_f_read(path)$payload$specs
  lapply(specs,function(spec) {
    spec$ConditionId <- input$ConditionId;spec$Replicate <- input$Replicate
    spec$InputId <- input$InputId;spec$args$data <- input$data
    spec$purpose <- 'R50_descriptive_comparison'
    # The frozen L2 generator draws distinct independent rating events.
    # This declaration changes input provenance/admission, never the rows.
    if(identical(input$provenance$view,'paired-L2'))
      spec$args$repeated_ratings <- 'independent'
    if(!is.null(spec$args$population_formula))
      spec$args$person_data <- data.frame(Person=sort(unique(input$data$Person)))
    wide_interval_spec(input,spec)
  })
}

wide_pcm_prepare <- function(out) {
  wide_pcm_setup()
  root <- 'validation-results/mfrm-wide-map-r50-20261001/ab-inputs'
  index_path <- file.path(root,'inputs.csv'); index <- read.csv(index_path)
  cells <- index[index$Truth=='S-PCM',]
  stopifnot(nrow(cells)==1800L,length(unique(cells$ConditionId))==36L,
    all(table(cells$ConditionId)==50L),setequal(cells$N,c(20,30,40,60,120,240,480)),
    setequal(cells$SD,c(.5,1)))
  # Qualify every condition's method/output plan before spending on fitting.
  conditions <- unique(cells$ConditionId)
  plans <- lapply(conditions,function(id) {
    input <- wide_recovery_ab_input(root,id,1L); specs <- wide_pcm_specs(input)
    list(initial=lapply(specs,function(s)wide_recovery_plan(input,s)),
      intervals=lapply(specs,function(s)wide_interval_plan(input,s)))
  });names(plans) <- conditions
  arms <- names(plans[[1]]$initial)
  jobs <- merge(cells[c('ConditionId','Replicate','N','SD','View','Bundle','BundleMD5')],
    data.frame(Arm=arms),by=NULL,sort=FALSE)
  jobs <- jobs[order(match(jobs$ConditionId,conditions),jobs$Replicate,match(jobs$Arm,arms)),]
  rownames(jobs) <- NULL;jobs$JobId <- sprintf('job-%05d',seq_len(nrow(jobs)))
  stopifnot(nrow(jobs)==14400L,!anyDuplicated(jobs[c('ConditionId','Replicate','Arm')]))
  runtime <- wide_multi_runtime()
  scripts <- paste0('inst/validation/mfrm-wide-map-',c('pcm-r50-20261002','recovery-20261002',
    'interval-recovery-20261002','f-scoring-20261002'),'.R')
  paths <- unique(c(names(runtime$source)[!startsWith(names(runtime$source),'loaded:')],scripts))
  manifest <- list(root=root,input=tools::md5sum(index_path),jobs=jobs,plans=plans,
    runtime=runtime,source=tools::md5sum(paths),source_code=setNames(lapply(paths,readLines),paths),
    template=tools::md5sum('validation-results/mfrm-wide-map-recovery-20261002/witness-manifest.rds'),
    protocol=list(R=50L,initial_slots=14400L,new_conditions=0L,calibration_orders=c(31L,61L,121L),
      scoring_orders=c(31L,61L,121L),priors=c('reference','retained'),
      corrected_scoring='Public frozen calibration, extracted once per source and scoring order; identical batch integration checks',
      repeated_ratings='Explicit conditional independence for the prespecified paired-L2 generator',
      outputs=c('initial_recovery','source_reviewed_intervals','corrected_research_candidate',
        'native_training','training_rescore','prespecified_future_panels'),
      timing='All stages retained; initial slots are not the full compute workload.',
      interpretation='Descriptive R50 comparison; no formal JML truth-CI promotion or universal coverage claim.'))
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  sealed <- wide_mml_phase(file.path(out,'manifest.rds'),'PCM-R50-complete-output-v1',function()manifest)
  stopifnot(identical(sealed,manifest))
  write.csv(jobs,file.path(out,'jobs.csv'),row.names=FALSE)
  invisible(manifest)
}

wide_pcm_job <- function(m,job,out) {
  stopifnot(identical(m$source,tools::md5sum(names(m$source))),
    identical(m$input,tools::md5sum(names(m$input))),
    identical(m$template,tools::md5sum(names(m$template))))
  input <- wide_recovery_ab_input(m$root,job$ConditionId,job$Replicate)
  spec <- wide_pcm_specs(input)[[job$Arm]]
  dir <- file.path(out,job$JobId);dir.create(dir,showWarnings=FALSE)
  path <- file.path(dir,'outputs.rds');binding <- list(job=job,source=m$source,input=input$InputId)
  if(file.exists(path)) return(wide_mml_phase(path,binding,function()stop('Unreachable')))
  cat('Starting',job$JobId,job$ConditionId,'rep',job$Replicate,job$Arm,'\n');flush.console()
  selected <- wide_multi_run(spec,file.path(dir,'calibration'))
  source <- wide_f_source(file.path(dir,'calibration'),input)
  q <- if(spec$args$method=='MML')31L else 0L
  f <- wide_f_read(file.path(dir,'calibration',paste0('q',q,'-fit.rds')))
  stage <- paste0('initial:q',q,':',f$checksum)
  initial <- wide_recovery_collect(input,spec,f$payload,stage)
  intervals <- wide_interval_recovery(input,spec,selected)
  candidate <- if(!is.null(spec$args$jml_correction_order)) wide_jml_candidate(input,spec,f$payload,stage) else NULL
  native <- wide_training_native(input,spec,f$payload,stage)
  panel_path <- file.path(out,'panels',paste0(gsub('[^a-zA-Z0-9]','_',input$ConditionId),'-',input$Replicate,'.rds'))
  dir.create(dirname(panel_path),recursive=TRUE,showWarnings=FALSE)
  panel_binding <- list(input=input$InputId,source=m$source)
  if(file.exists(panel_path)) {
    saved <- wide_f_read(panel_path)
    # Assembly-only runner edits do not regenerate a completed panel. Every
    # generator/package source and the input must still be byte-identical.
    generator <- setdiff(names(m$source),'inst/validation/mfrm-wide-map-pcm-r50-20261002.R')
    stopifnot(identical(saved$binding$input,input$InputId),
      identical(saved$binding$source[generator],m$source[generator]))
    panel_binding <- saved$binding
  }
  future <- wide_mml_phase(panel_path,panel_binding,
    function()wide_f_ab_panels(input))
  panels <- c(list(training=wide_training_panel(input)),future$panels)
  records <- attempts <- artifacts <- list()
  artifact_dir <- if(!is.null(spec$args$jml_correction_order)) file.path(dir,'scoring-artifacts') else NULL
  for(panel in panels) for(prior in m$protocol$priors) {
    key <- paste(panel$Panel,prior,sep='--')
    z <- wide_f_run(source,panel,prior,file.path(dir,'scoring',key),m$runtime,artifact_dir)
    records[[key]] <- wide_f_records(source,panel,z)
    attempts[[key]] <- lapply(z$attempts,function(a) a[c('elapsed','error','warnings')])
    for(q in names(z$artifacts)) {
      ref <- z$artifacts[[q]]
      if(!is.null(artifacts[[q]])) stopifnot(identical(artifacts[[q]]$reference,ref)) else {
        a <- wide_f_read(ref$path);stopifnot(identical(a$checksum,ref$checksum))
        artifacts[[q]] <- list(reference=ref,extraction=a$payload[c('elapsed','error','warnings')])
      }
    }
  }
  columns <- unique(unlist(lapply(records,names),use.names=FALSE))
  records <- lapply(records,function(x) {
    for(n in setdiff(columns,names(x))) x[[n]] <- NA
    x[columns]
  })
  value <- list(job=job,initial=initial,intervals=intervals,candidate=candidate,native=native,
    scoring=do.call(rbind,records),scoring_attempts=attempts,scoring_artifacts=artifacts,source_stage=source$stage,
    calibration_stages=selected$stages,completed=TRUE)
  result <- wide_mml_phase(path,binding,function()value)
  stopifnot(identical(m$source,tools::md5sum(names(m$source))))
  cat('Completed',job$JobId,'all output stages\n');flush.console()
  result
}

wide_pcm_run <- function(out,condition=NULL,replicates=1:50,arms=NULL) {
  wide_pcm_setup();m <- wide_f_read(file.path(out,'manifest.rds'))$payload
  stopifnot(length(replicates)>0L,all(replicates %in% 1:50),!anyDuplicated(replicates))
  jobs <- m$jobs
  if(!is.null(condition)) {stopifnot(all(condition %in% jobs$ConditionId));jobs <- jobs[jobs$ConditionId %in% condition,]}
  if(!is.null(arms)) {stopifnot(all(arms %in% jobs$Arm));jobs <- jobs[jobs$Arm %in% arms,]}
  jobs <- jobs[jobs$Replicate %in% replicates,]
  for(i in seq_len(nrow(jobs))) wide_pcm_job(m,jobs[i,,drop=FALSE],out)
  invisible(NULL)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)>=2L)
  if(args[1]=='prepare') wide_pcm_prepare(args[2]) else if(args[1]=='run')
    wide_pcm_run(args[2],if(length(args)>=3L)args[3] else NULL,
      if(length(args)>=4L)as.integer(strsplit(args[4],',',fixed=TRUE)[[1]]) else 1:50) else stop('Choose prepare or run')
}
