# prepare OUTPUT; run OUTPUT CONDITION [REPLICATE ...] from OUTPUT/source.
# Retain all 3,600 PCM calibration attempts and their selected point sources.
pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
helpers <- paste0('inst/validation/mfrm-wide-map-',c('mml-stages-20261001',
  'recovery-20261002','f-scoring-20261002','lr-scoring-20261004','lr-scoring-source-20261005'),'.R')
for(path in helpers)source(path)
arguments <- commandArgs(trailingOnly=TRUE)
stopifnot(length(arguments)>=2L,arguments[1L] %in% c('prepare','run'))
mode <- arguments[1L];out <- arguments[2L]
script <- 'inst/validation/mfrm-wide-map-lr-scoring-run-20261005.R'
runtime <- wide_mml_runtime();base_runtime <- runtime
runtime$scoring_sources <- tools::md5sum(c(helpers,script))
calibrations <- 'validation-results/mfrm-wide-map-lr-pcm-r50-20261004'
qualification <- 'validation-results/mfrm-wide-map-lr-scoring-stage-qualification-20261005'
qpath <- file.path(qualification,'one-results.rds');q <- wide_f_read(qpath)$payload
stopifnot(identical(base_runtime,q$runtime[setdiff(names(q$runtime),'scoring_sources')]))
shared <- intersect(names(runtime$scoring_sources),names(q$runtime$scoring_sources))
stopifnot(identical(runtime$scoring_sources[shared],q$runtime$scoring_sources[shared]))
if(mode=='prepare') {
  stopifnot(!dir.exists(out))
  proof_path <- file.path(qualification,'fresh-replay.rds');proof <- readRDS(proof_path)
  stopifnot(identical(tools::md5sum(names(proof$phase_hashes)),proof$phase_hashes),
    proof$new_fits==0L,proof$new_scoring_calls==0L)
  final_path <- file.path(calibrations,'summary-completed-20261005-final.rds');final <- readRDS(final_path)
  map_path <- file.path(calibrations,'event-epoch-map.rds');map <- readRDS(map_path)
  stopifnot(identical(tools::md5sum(names(final$inputs)),final$inputs),
    identical(tools::md5sum(names(final$epoch_map)),final$epoch_map),
    identical(tools::md5sum(names(map$source)),map$source),
    all(final$counts$Completed==50L),nrow(final$counts)==72L)
  jobs <- wide_f_read(file.path(calibrations,'manifest.rds'))$payload$jobs
  for(folder in names(final$manifest_checksums)) {
    saved <- wide_f_read(file.path(folder,'manifest.rds'));m <- saved$payload
    stopifnot(identical(saved$checksum,final$manifest_checksums[[folder]]),identical(m$jobs,jobs),
      identical(unname(tools::md5sum(file.path(folder,'source',names(m$source)))),unname(m$source)),
      identical(m$runtime,base_runtime))
  }
  jobs$CalibrationRoot <- map$conditions$Root[match(jobs$ConditionId,map$conditions$ConditionId)]
  jobs$JobId <- paste0(gsub('[^a-zA-Z0-9]','_',jobs$ConditionId),'-',jobs$Replicate)
  jobs$Path <- file.path(jobs$CalibrationRoot,'jobs',jobs$JobId)
  stopifnot(nrow(jobs)==3600L,!anyNA(jobs$CalibrationRoot),!anyDuplicated(jobs$JobId),
    setequal(file.path(jobs$Path,'records.rds'),names(final$inputs)),
    all(table(jobs$ConditionId)==50L))
  source_paths <- unique(c(names(base_runtime$source)[names(base_runtime$source)!='loaded:mfrmr'],
    helpers,script,'src/mfrmr.so','LICENSE'))
  sources <- tools::md5sum(source_paths);stopifnot(!anyNA(sources),
    unname(sources['src/mfrmr.so'])==unname(base_runtime$source['loaded:mfrmr']))
  dir.create(file.path(out,'source'),recursive=TRUE)
  for(path in source_paths) {
    target <- file.path(out,'source',path);dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(path,target),unname(tools::md5sum(target))==unname(sources[path]))
  }
  stopifnot(file.symlink(normalizePath('validation-results'),file.path(out,'source/validation-results')))
  wide_mml_save(list(jobs=jobs,runtime=runtime,sources=sources,
    allocation=tools::md5sum(c(final_path,map_path,names(map$source))),
    calibration_records=final$inputs,
    qualification=tools::md5sum(c(qpath,proof_path,file.path(qualification,'environment-check.rds'))),
    protocol='Frozen selected point source, including the original zero-variance gate; M60 same-population conditional-X scoring on all declared population exposure panels; retained prior and unchanged 31/61/121 scoring retry.',
    scope='All 72 original PCM conditions and 3600 attempts; reused development responses and reserved future streams. Other regression models, missing-X/shift and independent confirmation remain separate.'),
    file.path(out,'dispatch.rds'))
  cat('Prepared all 72 PCM regression conditions and 3600 scoring jobs.\n')
} else {
  stopifnot(length(arguments)>=3L)
  manifest <- readRDS(file.path(out,'dispatch.rds'))
  stopifnot(identical(normalizePath('.'),normalizePath(file.path(out,'source'))),
    identical(runtime,manifest$runtime))
  for(h in list(manifest$sources,manifest$allocation,manifest$qualification))
    stopifnot(identical(tools::md5sum(names(h)),h))
  condition <- arguments[3L];replicates <- if(length(arguments)>3L)as.integer(arguments[-(1:3)]) else 1:50
  stopifnot(condition %in% manifest$jobs$ConditionId,length(replicates)>0L,
    !anyNA(replicates),!anyDuplicated(replicates),all(replicates %in% 1:50))
  rows <- manifest$jobs[manifest$jobs$ConditionId==condition & manifest$jobs$Replicate %in% replicates,]
  rows <- rows[order(rows$Replicate),];stopifnot(nrow(rows)==length(replicates))
  lock <- file.path(out,'RUNNING');stopifnot(dir.create(lock,showWarnings=FALSE))
  writeLines(as.character(Sys.getpid()),file.path(lock,'pid'))
  fit_calls <- 0L
  trace('fit_mfrm',tracer=quote({fit_calls <<- fit_calls+1L;stop('Reuse saved PCM regression calibration.')}),
    where=asNamespace('mfrmr'),print=FALSE)
  run <- function() {
    on.exit(unlink(lock,recursive=TRUE))
    for(i in seq_len(nrow(rows))) {
      row <- rows[i,,drop=FALSE];record_path <- file.path(row$Path,'records.rds')
      stopifnot(identical(tools::md5sum(record_path),manifest$calibration_records[record_path]))
      source <- dlr_f_saved_source(row$Path,row,base_runtime)
      input <- wide_recovery_ab_input('validation-results/mfrm-wide-map-r50-20261001/ab-inputs',row$ControlConditionId,row$Replicate)
      stopifnot(identical(wide_recovery_data(input$data),wide_recovery_data(source$spec$args$data)))
      lr_path <- file.path('validation-results/mfrm-wide-map-r50-20261001/lr-inputs',row$Bundle)
      stopifnot(unname(tools::md5sum(lr_path))==row$BundleMD5,
        identical(source$spec$args$person_data,readRDS(lr_path)$person_data[[row$CovariateView]]))
      path <- file.path(out,'jobs',row$JobId);dir.create(path,recursive=TRUE,showWarnings=FALSE)
      panels <- wide_mml_phase(file.path(path,'panels.rds'),
        list(input=input$InputId,lr=tools::md5sum(lr_path),rho=row$Rho,source=runtime$scoring_sources),function() {
          ab_path <- file.path('validation-results/mfrm-wide-map-pcm-r50-portable-20261003/panels',
            paste0(gsub('[^a-zA-Z0-9]','_',input$ConditionId),'-',input$Replicate,'.rds'))
          future <- if(file.exists(ab_path))wide_f_read(ab_path)$payload else wide_f_ab_panels(input)
          dlr_f_panels(input,lr_path,row$Rho,future)
        })
      records <- phases <- list()
      for(panel in panels$panels) {
        scoring <- file.path(path,panel$Panel)
        if(row$JobId %in% q$selection$rows$JobId) {
          scoring <- file.path(qualification,'one',row$JobId,panel$Panel)
          saved <- wide_f_read(file.path(scoring,'manifest.rds'))$payload
          selected <- wide_f_read(file.path(scoring,'selected.rds'))$payload
          stopifnot(identical(saved$SourceId,source$SourceId),identical(saved$PanelId,panel$PanelId),
            identical(saved$person_data,panel$person_data),identical(saved$orders,c(31L,61L,121L)),
            saved$prior=='retained',identical(selected$identity,wide_mml_hash(saved)))
        } else selected <- wide_f_run(source,panel,'retained',scoring,runtime)
        records[[panel$Panel]] <- wide_f_records(source,panel,selected)
        phases[[panel$Panel]] <- tools::md5sum(list.files(scoring,
          '^(manifest|selected|score-q[0-9]+)[.]rds$',full.names=TRUE))
      }
      records <- do.call(rbind,records);rownames(records) <- NULL
      if(row$JobId %in% q$selection$rows$JobId) {
        old <- q$records[q$records$ConditionId==row$ConditionId & q$records$Replicate==row$Replicate,]
        rownames(old) <- NULL;stopifnot(identical(records,old))
      }
      value <- list(job=row,records=records,source_ready=source$review$ready,
        source_files=source$files,scoring_phases=phases,completed=TRUE)
      saved <- wide_mml_phase(file.path(path,'outputs.rds'),list(
        dispatch=tools::md5sum(file.path(out,'dispatch.rds')),calibration=source$files,
        panels=tools::md5sum(file.path(path,'panels.rds')),phases=phases),function()value)
      stopifnot(identical(saved,value),fit_calls==0L)
      z <- records[records$Rule=='refinement',]
      cat('Completed',row$JobId,'source ready',source$review$ready,'scores',sum(z$ScoreAvailable),
        'intervals',sum(z$IntervalAvailable),'of',nrow(z),'\n');flush.console()
    }
    stopifnot(identical(tools::md5sum(names(manifest$sources)),manifest$sources))
  }
  run()
}
