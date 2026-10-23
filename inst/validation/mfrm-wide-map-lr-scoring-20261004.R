# Gaussian D-LR same-population scoring. Reuse A/B future responses and the
# separately reserved D-LR future-covariate stream; never refit calibration.
# Source mml-stages, recovery-20261002 and f-scoring-20261002 first.
dlr_f_panels <- function(input, lr_path, rho, future) {
  lr <- readRDS(lr_path)
  stopifnot(rho %in% c(0,.5),
    identical(unname(input$provenance$bundle),lr$unit$ABBundleMD5),
    identical(future$calibration_input,input$InputId),
    future$parent$ParentId == lr$unit$ParentId)
  # One normal covariate primitive per future Person, shared by rho and L1/L2.
  # No training/response/assignment stream or global RNG state is advanced.
  kind <- RNGkind(); had <- exists('.Random.seed',.GlobalEnv,inherits=FALSE)
  if (had) old <- get('.Random.seed',.GlobalEnv)
  on.exit({do.call(RNGkind,as.list(kind)); if(had) assign('.Random.seed',old,.GlobalEnv)
    else if(exists('.Random.seed',.GlobalEnv,inherits=FALSE)) rm('.Random.seed',envir=.GlobalEnv)},add=TRUE)
  RNGkind("L'Ecuyer-CMRG",normal.kind='Inversion',sample.kind='Rejection')
  seed <- lr$rng$future_covariate_first_unused
  assign('.Random.seed',seed,.GlobalEnv); z <- rnorm(60L)
  panels <- future$panels[startsWith(names(future$panels),'population_')]
  stopifnot(length(panels)>0L)
  for (name in names(panels)) {
    p <- panels[[name]]; stopifnot(nrow(p$planned)==60L,
      p$distribution$mean==0,p$distribution$sd==lr$unit$SD,
      identical(p$planned$Person,panels[[1]]$planned$Person))
    p$ABPanelId <- p$PanelId
    p$person_data <- data.frame(Person=p$planned$Person,
      X=rho*p$planned$Theta/lr$unit$SD+sqrt(1-rho^2)*z)
    p$population_truth <- lr$population_truth[[paste0('rho',rho)]]
    p$covariate_seed <- seed; p$covariate_input <- tools::md5sum(lr_path)
    p$contract <- 'DLR_joint_normal_future_v1'
    # DataId continues to name the shared A/B responses. PanelId also binds X.
    p$PanelId <- wide_mml_hash(p[setdiff(names(p),'PanelId')]); panels[[name]] <- p
  }
  list(panels=panels,seed=seed,next_unused_substream=parallel::nextRNGSubStream(seed),
    calibration_input=input$InputId,covariate_input=tools::md5sum(lr_path),
    scope='M=60 same-population Persons, shared rho/exposure responses; no shift or fixed-ability covariate law.')
}

dlr_f_review <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  for(n in c('mml-stages-20261001','recovery-20261002','f-scoring-20261002'))
    source(paste0('inst/validation/mfrm-wide-map-',n,'.R'))
  ns <- asNamespace('mfrmr'); unlockBinding('fit_mfrm',ns)
  assign('fit_mfrm',function(...) stop('Saved calibration only; no refitting'),envir=ns)
  lockBinding('fit_mfrm',ns)
  saved_path <- 'validation-results/mfrm-wide-map-lr-population-intervals-20261004/qualified.rds'
  jobs_path <- 'validation-results/mfrm-wide-map-lr-witness-20261002/manifest.rds'
  saved <- readRDS(saved_path); jobs <- readRDS(jobs_path)$payload$jobs
  runtime <- wide_mml_runtime()
  scripts <- c('inst/validation/mfrm-wide-map-lr-scoring-20261004.R',
    'inst/validation/mfrm-wide-map-recovery-20261002.R','inst/validation/mfrm-wide-map-f-scoring-20261002.R')
  runtime$scoring_sources <- tools::md5sum(scripts)
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  manifest <- list(inputs=tools::md5sum(c(saved_path,jobs_path)),runtime=runtime,
    rule='Four retained PCM fits; M60 same-population and L1/L2 scoring, retained conditional prior; no refits.',
    new_calibration_datasets=0L,independent_calibration_cohorts=2L)
  old <- wide_mml_phase(file.path(out,'manifest.rds'),'DLR_scoring_output_v1',function()manifest)
  stopifnot(identical(old,manifest))
  for(path in unique(c(names(runtime$source)[!startsWith(names(runtime$source),'loaded:')],scripts))) {
    target <- file.path(out,'source',path);dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    if(!file.exists(target)) stopifnot(file.copy(path,target))
    stopifnot(identical(unname(tools::md5sum(path)),unname(tools::md5sum(target))))
  }
  records <- results <- list()
  for(id in names(saved$results)) {
    job <- jobs[[id]]; row <- job$input; fit <- saved$results[[id]]$fit
    dir <- file.path(out,id);dir.create(dir,showWarnings=FALSE)
    input <- wide_recovery_ab_input('validation-results/mfrm-wide-map-r50-20261001/ab-inputs',
      row$ControlConditionId,row$Replicate)
    panel_path <- file.path('validation-results/mfrm-wide-map-pcm-r50-portable-20261003/panels',
      paste0(gsub('[^a-zA-Z0-9]','_',input$ConditionId),'-',input$Replicate,'.rds'))
    # Reuse completed A/B panels where present; generation otherwise uses the
    # same frozen future stream and leaves global/training RNG untouched.
    future <- if(file.exists(panel_path)) wide_f_read(panel_path)$payload else wide_f_ab_panels(input)
    stopifnot(identical(future$calibration_input,input$InputId))
    lr_path <- file.path('validation-results/mfrm-wide-map-r50-20261001/lr-inputs',row$Bundle)
    stopifnot(unname(tools::md5sum(lr_path))==row$BundleMD5)
    kind <- RNGkind(); had <- exists('.Random.seed',.GlobalEnv,inherits=FALSE)
    if(had) seed <- get('.Random.seed',.GlobalEnv)
    panels <- wide_mml_phase(file.path(dir,'panels.rds'),
      list(input=input$InputId,lr=tools::md5sum(lr_path),rho=row$Rho,source=runtime$scoring_sources),
      function()dlr_f_panels(input,lr_path,row$Rho,future))
    stopifnot(identical(kind,RNGkind()),identical(had,exists('.Random.seed',.GlobalEnv,inherits=FALSE)),
      !had || identical(seed,get('.Random.seed',.GlobalEnv)))
    review <- wide_mml_phase(file.path(dir,'source-review.rds'),
      list(fit=mfrmr:::mfrm_native_location_identity(fit),runtime=runtime),
      function()mfrmr:::prediction_source_scoring_readiness(fit))
    source <- list(fit=fit,review=review,error='',stage=paste0('retained_public:',id),
      spec=list(ConditionId=row$ConditionId,Replicate=row$Replicate,Arm='PCM-MML-LR',args=job$args),
      files=manifest$inputs)
    source$SourceId <- wide_mml_hash(source)
    for(panel in panels$panels) {
      key <- paste(id,panel$Panel,sep=':');cat('Scoring',key,'\n');flush.console()
      selected <- wide_f_run(source,panel,'retained',file.path(dir,panel$Panel),runtime)
      z <- wide_f_records(source,panel,selected)
      z$X <- panel$person_data$X[match(z$Person,panel$person_data$Person)]
      records[[key]] <- z
      results[[key]] <- list(source=source,panel=panel,selected=selected)
      cat('Delivered',sum(z$ScoreAvailable[z$Rule=='refinement']),'of 60 at q',
        selected$selected_order,'\n');flush.console()
    }
  }
  records <- do.call(rbind,records);rownames(records) <- NULL
  save <- list(records=records,results=results,manifest=manifest,session=sessionInfo(),
    scope='Source/scoring/output qualification on four saved fits and two future cohorts, not sampling coverage.')
  wide_mml_save(save,file.path(out,'verified.rds'))
  write.csv(records,file.path(out,'records.csv'),row.names=FALSE)
  invisible(save)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  dlr_f_review(if(length(args))args[1] else 'validation-results/mfrm-wide-map-lr-scoring-20261004')
}
