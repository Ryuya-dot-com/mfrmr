# Retained-data stationarity continuation; prepare | run [N,N,...].
source('inst/validation/mfrm-decision-pcm-summary-20261010.R')
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
mpr_root <- 'validation-results/mfrm-decision-pcm-repair-20261010'
mpr_script <- 'inst/validation/mfrm-decision-pcm-repair-20261010.R'
mpr_reuse <- 'validation-results/mfrm-mml-population-stationarity-20261007/qualification'
mpr_guard <- function(m) {
  stopifnot(identical(mde_sha(names(m$Source)),m$Source),identical(mde_runtime(),m$Runtime))
}
mpr_prepare <- function() {
  path <- file.path(mpr_root,'metadata.rds')
  if(file.exists(path)) {mpr_guard(mde_read(path)); return(invisible(NULL))}
  old <- mde_read(file.path(mfp_root,'metadata.rds')); mfp_guard(old)
  summary <- mde_read(file.path(mfp_root,'summary.rds'))
  mfp_verify_inputs(old,names(old$Inputs))
  stopifnot(identical(mde_sha(names(summary$RecordSHA256)),summary$RecordSHA256))
  plan <- old$Plan[old$Plan$Arm=='PCM-MML-free' & old$Plan$Prior=='retained',]
  diagnosis <- do.call(rbind,lapply(seq_len(nrow(plan)),function(i) {
    j <- plan[i,]; f <- mfp_phase(j$FitPath)$payload$value; d <- f$opt$optimizer_diagnostics
    data.frame(JobId=j$JobId,N=j$N,Replicate=j$Replicate,Ready=j$HistoricalReady,
      Code=f$opt$convergence,Reason=d$ConvergenceReason,Gradient=d$TerminalGradientSupNorm,
      Q=f$config$estimation_control$quad_points,
      Restart=any(f$opt$optimizer_polish$Stages$StageLabel=='curvature_restart'))
  }))
  repair <- diagnosis$Code==0L & diagnosis$Reason=='code_zero_large_gradient'
  plan <- plan[repair,]; rownames(plan) <- NULL
  plan$InitialOrder <- diagnosis$Q[repair]
  stopifnot(nrow(plan)==44L,all(!diagnosis$Ready[repair]),all(plan$InitialOrder %in% c(31L,61L)),
    all(!diagnosis$Restart[repair]),sum(plan$N==240L)==5L,sum(plan$N==480L)==39L)
  earlier <- character()
  for(i in which(plan$InitialOrder==61L)) {
    selected <- mfp_phase(plan$SelectedPath[i])$payload
    stopifnot(isTRUE(selected$stages[['31']]$retry_point))
    earlier <- c(earlier,file.path(dirname(plan$FitPath[i]),c('q31-fit.rds','q31-scoring-source.rds')))
  }
  reuse_paths <- file.path(mpr_reuse,'job-13617',
    c('manifest.rds','selected.rds','q31-fit.rds','q61-fit.rds'))
  old_spec <- mfp_phase(plan$ManifestPath[plan$JobId=='job-13617'])$payload$spec
  reused_spec <- mfp_phase(reuse_paths[1])$payload$spec
  stopifnot(identical(old_spec,reused_spec),
    isTRUE(mfp_phase(reuse_paths[2])$payload$point$value$ready))
  sources <- unique(c(names(old$Source),mpr_script,
    'inst/validation/mfrm-decision-pcm-summary-20261010.R',
    'inst/validation/mfrm-wide-map-mml-stages-20261001.R'))
  inputs <- unique(c(names(old$Inputs),names(summary$RecordSHA256),reuse_paths,earlier,
    file.path(mfp_root,c('metadata.rds','summary.rds'))))
  roadmap <- readLines('inst/validation/internal-roadmap-0.2.4.md')
  begin <- which(startsWith(roadmap,'**October 10 PCM stationarity continuation contract'))
  end <- grep('^### 2[.] Complete existing population inference',roadmap)
  stopifnot(length(begin)==1L,length(end)==1L,end>begin)
  dir.create(mpr_root,recursive=TRUE,showWarnings=FALSE)
  for(f in sources) {
    target <- file.path(mpr_root,'source',f); dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,target),identical(unname(mde_sha(f)),unname(mde_sha(target))))
  }
  mde_save(list(Plan=plan,CheckJobs=plan$JobId[!duplicated(plan$N)],Diagnosis=diagnosis,
    Original=old,Source=mde_sha(sources),
    Inputs=mde_sha(inputs),Runtime=mde_runtime(),Contract=roadmap[begin:(end-1L)],
    Created=as.character(Sys.time()),Session=sessionInfo()),path)
  write.csv(diagnosis,file.path(mpr_root,'source-diagnosis.csv'),row.names=FALSE)
  cat('Frozen 44 numerical repairs, 88 profile jobs; all other original results retained.\n')
}
mpr_phase <- function(path,compute) {
  if(file.exists(path)) return(mde_read(path))
  value <- compute(); mde_save(value,path); value
}
mpr_initial_check <- function(old,new) {
  a <- old$opt$optimizer_polish$Stages; b <- new$opt$optimizer_polish$Stages
  fields <- c('Stage','StageLabel','Method','Reltol','ConvergenceCode','StopReason',
    'TerminalGradientSupNorm','TerminalGradientRMS','Objective','MaxParameterChange')
  stopifnot(nrow(b)>nrow(a),identical(a[fields],b[seq_len(nrow(a)),fields]),
    any(b$StageLabel=='curvature_restart'))
  slack <- 64*.Machine$double.eps*max(1,abs(old$opt$value))
  stopifnot(new$opt$value<=old$opt$value+slack)
  c(ObjectiveChange=new$opt$value-old$opt$value,
    OldGradient=old$opt$optimizer_diagnostics$TerminalGradientSupNorm,
    NewGradient=new$opt$optimizer_diagnostics$TerminalGradientSupNorm)
}
mpr_score <- function(fit,job,meta,check=FALSE) {
  start <- proc.time()[['elapsed']]
  prior <- if(job$Prior=='reference') c(0,1) else
    c(unname(fit$population$coefficients),sqrt(fit$population$sigma2))
  x <- mfp_public(fit,meta$Original$Profiles,job$Prior)
  available <- !inherits(x$value,'error'); checks <- c(Reference=NA,Legacy=NA,RawLookup=NA)
  p <- if(available)mfp_matrix(x$value,meta$Original$Oracle$population_L1$keys$Person,prior) else NULL
  panels <- mfp_phase(job$PanelPath)$payload$panels
  if(check && available) {
    independent <- t(vapply(rownames(p),function(id)mfp_reference(
      meta$Original$Profiles[meta$Original$Profiles$Person==id,],mfp_coordinates(fit),prior),numeric(7)))
    plain <- mfp_public(fit,meta$Original$Profiles,job$Prior,NULL)
    data <- panels$population_L1$data
    data <- data[data$Person %in% panels$population_L1$planned$Person[1:12],]
    raw <- mfp_public(fit,data,job$Prior); keys <- mfp_keys(data)
    fields <- c('Estimate','SD','Lower','Upper')
    stopifnot(!inherits(plain$value,'error'),!inherits(raw$value,'error'))
    checks <- c(Reference=max(abs(p-independent)),
      Legacy=max(abs(as.matrix(x$value$estimates[fields])-as.matrix(plain$value$estimates[fields]))),
      RawLookup=max(abs(mfp_matrix(raw$value,keys$Person,prior)-
        p[mde_lookup(keys,meta$Original$Oracle$population_L1$keys),])))
    stopifnot(max(checks)<1e-8)
  }
  list(Job=job,Available=available,Error=if(available)'' else conditionMessage(x$value),
    Warnings=x$warnings,Prior=prior,Prediction=x$value,Probabilities=p,
    Metrics=if(available)mfp_metrics(p,prior,panels,meta$Original,job$N) else NULL,
    Checks=checks,Seconds=proc.time()[['elapsed']]-start,
    MetadataSHA256=mde_sha(file.path(mpr_root,'metadata.rds')))
}
mpr_run <- function(meta,ns) {
  stopifnot(all(ns %in% c(240L,480L)),!anyDuplicated(ns)); mpr_guard(meta)
  stopifnot(identical(mde_sha(names(meta$Inputs)),meta$Inputs))
  plan <- meta$Plan[meta$Plan$N %in% ns,]
  for(i in seq_len(nrow(plan))) {
    job <- plan[i,]; dir <- file.path(mpr_root,'jobs',job$JobId)
    dir.create(dir,recursive=TRUE,showWarnings=FALSE)
    if(file.exists(file.path(dir,'completed.rds'))) {mde_read(file.path(dir,'completed.rds')); next}
    spec <- mfp_phase(job$ManifestPath)$payload$spec
    old_fit <- mfp_phase(job$FitPath)$payload$value
    stages <- list(); initial_check <- NULL
    for(q in c(31L,61L,121L)[c(31L,61L,121L)>=job$InitialOrder]) {
      fitting <- mpr_phase(file.path(dir,paste0('q',q,'-fit.rds')),function() {
        reuse <- file.path(mpr_reuse,job$JobId,paste0('q',q,'-fit.rds'))
        if(job$JobId=='job-13617' && file.exists(reuse)) {
          saved <- mfp_phase(reuse)$payload
          saved$Origin <- 'retained_October_7_repair'; saved$OriginalSHA256 <- mde_sha(reuse)
          return(saved)
        }
        value <- wide_mml_capture(function()do.call(mfrmr::fit_mfrm,c(spec$args,list(quad_points=q))))
        value$Origin <- 'current_public_fit'; value
      })
      fit <- fitting$value
      if(nzchar(fitting$error)) {
        review <- list(value=NULL,error=fitting$error); stages[[as.character(q)]] <- list(Error=fitting$error)
        break
      }
      if(q==job$InitialOrder) initial_check <- mpr_initial_check(old_fit,fit)
      review <- mpr_phase(file.path(dir,paste0('q',q,'-source.rds')),function()
        wide_mml_capture(function()mfrmr:::prediction_source_scoring_readiness(fit)))
      retry <- !nzchar(review$error) && wide_mml_scoring_retry(review$value)
      stages[[as.character(q)]] <- list(Ready=isTRUE(review$value$ready),Retry=retry,
        Gradient=fit$opt$optimizer_diagnostics$TerminalGradientSupNorm,
        Review=review$value,Error=review$error,Origin=fitting$Origin)
      if(!retry) break
    }
    records <- list()
    rows <- meta$Original$Plan[meta$Original$Plan$JobId==job$JobId,]
    stopifnot(nrow(rows)==2L)
    for(k in 1:2) {
      row <- rows[k,]; path <- file.path(dir,paste0(row$Prior,'-probabilities.rds'))
      records[[row$Prior]] <- mpr_phase(path,function() {
        if(!is.null(fit)) return(mpr_score(fit,row,meta,
          job$JobId %in% meta$CheckJobs))
        list(Job=row,Available=FALSE,Error=fitting$error,Warnings=fitting$warnings,
          Prior=c(NA_real_,NA_real_),Metrics=NULL,Checks=c(Reference=NA,Legacy=NA,RawLookup=NA),Seconds=0,
          MetadataSHA256=mde_sha(file.path(mpr_root,'metadata.rds')))
      })
    }
    files <- list.files(dir,'[.]rds$',full.names=TRUE)
    mde_save(list(Job=job,SelectedOrder=q,Stages=stages,InitialCheck=initial_check,
      SourceReady=isTRUE(review$value$ready),ProbabilityReady=vapply(records,`[[`,TRUE,'Available'),
      PhaseSHA256=mde_sha(files),MetadataSHA256=mde_sha(file.path(mpr_root,'metadata.rds'))),
      file.path(dir,'completed.rds'))
    mpr_guard(meta)
    cat(sprintf('Completed %d/%d N%d rep%d q%d: source=%s, profiles=%s\n',
      i,nrow(plan),job$N,job$Replicate,q,isTRUE(review$value$ready),
      paste(vapply(records,`[[`,TRUE,'Available'),collapse='/'))); flush.console()
  }
}

if(sys.nframe()==0L) {
  args <- commandArgs(TRUE); stopifnot(length(args)>=1L,args[1] %in% c('prepare','run'))
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  requireNamespace('digest'); requireNamespace('jsonlite')
  if(args[1]=='prepare') mpr_prepare() else {
    meta <- mde_read(file.path(mpr_root,'metadata.rds'))
    mpr_run(meta,if(length(args)>1L)as.integer(strsplit(args[2],',',fixed=TRUE)[[1]]) else c(240L,480L))
  }
}
