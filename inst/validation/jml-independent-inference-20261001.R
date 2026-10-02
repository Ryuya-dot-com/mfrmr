# Independent paired sampling evaluation of the frozen public order-2 procedure.
# No public structural interval is enabled by this research runner.
jml_study_save <- function(x,path) {
  saveRDS(x,paste0(path,'.tmp'));stopifnot(file.rename(paste0(path,'.tmp'),path))
}
jml_study_bounds <- function(k,n) if(n) unname(stats::binom.test(k,n)$conf.int) else c(NA_real_,NA_real_)
jml_study_average <- function(x) if(length(x)) mean(x) else NA_real_

jml_study_summarize <- function(rows,expected) {
  groups <- split(rows,interaction(rows$Design,rows$L,rows$Parameter,drop=TRUE))
  summary <- do.call(rbind,lapply(groups,function(x) {
    stopifnot(nrow(x)==expected,!anyDuplicated(x$Replicate))
    point <- x[x$PointAvailable,]; available <- x[x$IntervalAvailable,]
    covered <- available$Lower<=available$Truth & available$Upper>=available$Truth
    a <- jml_study_bounds(nrow(available),nrow(x)); c <- jml_study_bounds(sum(covered),nrow(available))
    d <- jml_study_bounds(sum(covered),nrow(x)); err <- point$Estimate-point$Truth
    data.frame(Design=x$Design[1],L=x$L[1],Parameter=x$Parameter[1],LogScale=x$LogScale[1],
      Attempted=nrow(x),PointAvailable=nrow(point),IntervalAvailable=nrow(available),
      Availability=nrow(available)/nrow(x),AvailabilityLow=a[1],AvailabilityHigh=a[2],
      Bias=jml_study_average(err),BiasMCSE=sd(err)/sqrt(length(err)),RMSE=sqrt(jml_study_average(err^2)),
      PointEmpiricalSD=sd(point$Estimate),EligibleBias=jml_study_average(available$Estimate-available$Truth),
      EmpiricalSD=sd(available$Estimate),RootMeanVariance=sqrt(jml_study_average(available$SE^2)),
      SD_to_SE=sd(available$Estimate)/sqrt(jml_study_average(available$SE^2)),
      MeanCoordinateWidth=jml_study_average(available$Upper-available$Lower),
      MeanDisplayWidth=jml_study_average(available$DisplayWidth),Coverage=jml_study_average(covered),
      CoverageLow=c[1],CoverageHigh=c[2],Delivery=sum(covered)/nrow(x),DeliveryLow=d[1],DeliveryHigh=d[2],
      TruthBelow=sum(available$Lower>available$Truth),TruthAbove=sum(available$Upper<available$Truth),
      LimitedMarginsPass=isTRUE(nrow(available)/nrow(x)>=.95 && a[1]>=.90 && c[1]>=.92 && c[2]<=.98))
  }))
  paired <- do.call(rbind,lapply(split(rows,interaction(rows$Design,rows$Parameter,drop=TRUE)),function(x) {
    a <- x[x$L==4,]; b <- x[x$L==1,];a<-a[order(a$Replicate),];b<-b[order(b$Replicate),]
    stopifnot(nrow(a)==expected,identical(a$Replicate,b$Replicate))
    included <- function(z) z$IntervalAvailable & !is.na(z$Lower) & z$Lower<=z$Truth & z$Upper>=z$Truth
    av <- as.integer(a$IntervalAvailable)-as.integer(b$IntervalAvailable)
    delivery <- as.integer(included(a))-as.integer(included(b))
    point <- a$PointAvailable & b$PointAvailable
    mse <- (a$Estimate[point]-a$Truth[point])^2-(b$Estimate[point]-b$Truth[point])^2
    interval <- a$IntervalAvailable & b$IntervalAvailable
    width <- (a$Upper[interval]-a$Lower[interval])-(b$Upper[interval]-b$Lower[interval])
    data.frame(Design=x$Design[1],Parameter=x$Parameter[1],Attempted=expected,
      L4MinusL1Availability=mean(av),AvailabilityMCSE=sd(av)/sqrt(expected),
      L4MinusL1Delivery=mean(delivery),DeliveryMCSE=sd(delivery)/sqrt(expected),
      DeliveryLow=mean(delivery)-qnorm(.975)*sd(delivery)/sqrt(expected),
      DeliveryHigh=mean(delivery)+qnorm(.975)*sd(delivery)/sqrt(expected),
      PointPairs=sum(point),L4MinusL1MSE=jml_study_average(mse),MSE_MCSE=sd(mse)/sqrt(length(mse)),
      IntervalPairs=sum(interval),L4MinusL1Width=jml_study_average(width),WidthMCSE=sd(width)/sqrt(length(width)))
  }))
  list(summary=summary,paired=paired)
}

jml_study_preflight <- function() {
  x <- expand.grid(Replicate=1:3,L=c(1L,4L),Parameter=c('location','slope'),stringsAsFactors=FALSE)
  x$Design <- 'fixture';x$LogScale <- x$Parameter=='slope';x$Truth <- 0
  x$PointAvailable <- TRUE;x$IntervalAvailable <- x$Replicate!=3
  x$Estimate <- ifelse(x$Replicate==2 & x$L==1,2,0)
  x$SE <- 1;x$Lower<-x$Estimate-1;x$Upper<-x$Estimate+1;x$DisplayWidth<-2
  x[x$Replicate==3,c('SE','Lower','Upper','DisplayWidth')] <- NA_real_
  z <- jml_study_summarize(x,3)
  stopifnot(all(z$summary$Attempted==3),all(z$summary$IntervalAvailable==2),
    all(z$summary$Coverage[z$summary$L==1]==.5),all(z$summary$Delivery[z$summary$L==1]==1/3),
    all(z$summary$Coverage[z$summary$L==4]==1),all(z$paired$L4MinusL1Delivery==1/3),
    all(z$paired$L4MinusL1Availability==0),!any(z$summary$LimitedMarginsPass))
  x$PointAvailable <- FALSE;x$IntervalAvailable <- FALSE
  empty <- jml_study_summarize(x,3)
  stopifnot(all(is.na(empty$summary$Coverage)),all(empty$summary$Delivery==0),
    all(is.na(empty$summary$Bias)),!any(empty$summary$LimitedMarginsPass))
  list(paired_fixture=z,all_unavailable=empty)
}

jml_study_prepare <- function(pilot,out) {
  stopifnot(!dir.exists(out));pilot<-normalizePath(pilot)
  pm <- readRDS(file.path(pilot,'manifest.rds'))
  stopifnot(isTRUE(readRDS(file.path(pilot,'pilot-completion.rds'))$complete))
  for(i in 1:2) {
    r<-readRDS(file.path(pilot,paste0('replay-',i,'.rds')))
    p<-readRDS(file.path(pilot,paste0('pilot-',i,'-4.rds')))
    stopifnot(max(r$check$errors)<1e-7,max(p$check$errors)<1e-7)
  }
  timings<-read.csv(file.path(pilot,'pilot-summary.csv'))
  stopifnot(nrow(timings)==6,all(timings$IntervalAvailable))
  dir.create(out,recursive=TRUE)
  script<-'inst/validation/jml-independent-inference-20261001.R'
  stopifnot(file.copy(script,file.path(out,'runner.R')),
    file.copy('inst/validation/jml-inference-review-20260927.md',file.path(out,'protocol-before-launch.md')))
  manifest<-list(pilot=pilot,pilot_manifest_hash=tools::md5sum(file.path(pilot,'manifest.rds')),
    designs=pm$designs,repetitions=500L,seed_base=100100000L,
    jobs=expand.grid(L=c(1L,4L),Design=1:3,Replicate=1:500),
    runner_hash=unname(tools::md5sum(script)),
    protocol_hash=unname(tools::md5sum(file.path(out,'protocol-before-launch.md'))),
    estimated_fit_hours=500*sum(timings$Seconds)/3600,created=Sys.time())
  jml_study_save(manifest,file.path(out,'manifest.rds'))
  jml_study_save(jml_study_preflight(),file.path(out,'preflight.rds'))
  cat('Prepared 1,500 independent inputs / 3,000 fits; summary failure accounting passed.\n')
}

jml_study_load <- function(out) {
  out<-normalizePath(out);m<-readRDS(file.path(out,'manifest.rds'))
  stopifnot(identical(m$pilot_manifest_hash,tools::md5sum(names(m$pilot_manifest_hash))),
    identical(m$runner_hash,unname(tools::md5sum(file.path(out,'runner.R')))),
    identical(m$protocol_hash,unname(tools::md5sum(file.path(out,'protocol-before-launch.md')))))
  setwd(file.path(m$pilot,'source'))
  source('inst/validation/jml-observed-inference-20261001.R')
  jml_observed_load(m$pilot)
  m
}

jml_study_name <- function(job) sprintf('fit-%d-%03d-L%d.rds',job$Design,job$Replicate,job$L)

jml_study_rows <- function(record,m) {
  d<-m$designs[[record$Design]]
  levels<-lapply(d$cells,function(x)as.character(sort(unique(x))))
  map<-jml_observed_expand(levels,d$owner,d$rating_max)
  fit<-record$fit;ok<-is.null(fit$error)
  if(ok) {
    x<-fit$rows;stopifnot(identical(x$Parameter,map$keys))
    reason<-if(!isTRUE(fit$result$point$available)) paste0('point:',fit$result$point$status) else
      if(!identical(fit$result$point$status,'consistent_roots')) 'unresolved_starts' else
        if(!isTRUE(fit$result$covariance$available)) fit$result$covariance$reason else ''
    reason<-rep(reason,nrow(x));reason[!x$Available & reason=='']<-'nonfinite_or_nonpositive_interval'
    warning_count<-length(fit$warnings)+sum(vapply(fit$result$attempts,function(a)length(a$warnings),0L))
  } else {
    x<-data.frame(Parameter=map$keys,LogScale=map$slope,PointAvailable=FALSE,Available=FALSE,
      Estimate=NA_real_,SE=NA_real_,Lower=NA_real_,Upper=NA_real_,DisplayLower=NA_real_,DisplayUpper=NA_real_)
    reason<-fit$error;warning_count<-length(fit$warnings)
  }
  data.frame(Design=names(m$designs)[record$Design],Replicate=record$Replicate,L=record$L,
    Parameter=x$Parameter,LogScale=x$LogScale,PointAvailable=x$PointAvailable,IntervalAvailable=x$Available,
    PointStatus=if(ok)fit$result$point$status else 'fit_error',
    CovarianceStatus=if(ok)fit$result$covariance$status else 'not_evaluated',
    Reason=reason,
    Estimate=x$Estimate,SE=x$SE,Truth=drop(map$H%*%d$truth),Lower=x$Lower,Upper=x$Upper,
    DisplayWidth=x$DisplayUpper-x$DisplayLower,WarningCount=warning_count,row.names=NULL)
}

jml_study_summary <- function(out,m) {
  paths<-vapply(seq_len(nrow(m$jobs)),function(i)file.path(out,jml_study_name(m$jobs[i,])), '')
  stopifnot(all(file.exists(paths)))
  manifest_hash<-unname(tools::md5sum(file.path(out,'manifest.rds')))
  rows<-list();status<-list()
  for(i in seq_along(paths)) {
    r<-readRDS(paths[i]);job<-m$jobs[i,]
    stopifnot(!isTRUE(r$fit$unexpected_validation_error))
    stopifnot(identical(r$manifest_hash,manifest_hash),r$Design==job$Design,
      r$Replicate==job$Replicate,r$L==job$L,
      identical(r$input_hash,tools::md5sum(names(r$input_hash))))
    rows[[i]]<-jml_study_rows(r,m)
    status[[i]]<-data.frame(job,PointStatus=rows[[i]]$PointStatus[1],
      CovarianceStatus=rows[[i]]$CovarianceStatus[1],Available=sum(rows[[i]]$IntervalAvailable),
      Coordinates=nrow(rows[[i]]),Reason=rows[[i]]$Reason[1],WarningCount=rows[[i]]$WarningCount[1],Seconds=r$seconds)
  }
  rows<-do.call(rbind,rows);status<-do.call(rbind,status)
  z<-jml_study_summarize(rows,m$repetitions)
  write.csv(rows,file.path(out,'rows.csv'),row.names=FALSE)
  write.csv(status,file.path(out,'dispositions.csv'),row.names=FALSE)
  write.csv(z$summary,file.path(out,'summary.csv'),row.names=FALSE)
  write.csv(z$paired,file.path(out,'paired.csv'),row.names=FALSE)
  jml_study_save(list(summary=z$summary,paired=z$paired,attempted=nrow(status),
    manifest_hash=manifest_hash,result_hashes=tools::md5sum(paths),seconds=sum(status$Seconds),
    completed=Sys.time()),file.path(out,'summary.rds'))
  cat('All 3,000 attempts and pointwise/paired summaries saved.\n')
}

jml_study_run <- function(out) {
  out<-normalizePath(out);m<-jml_study_load(out)
  lock<-file.path(out,'RUNNING')
  if(!dir.create(lock,showWarnings=FALSE)) stop('RUNNING exists; verify the prior process before resuming.')
  saveRDS(list(pid=Sys.getpid(),started=Sys.time()),file.path(lock,'owner.rds'))
  on.exit(unlink(lock,recursive=TRUE),add=TRUE)
  manifest_hash<-unname(tools::md5sum(file.path(out,'manifest.rds')))
  for(i in seq_len(nrow(m$jobs))) {
    job<-m$jobs[i,];path<-file.path(out,jml_study_name(job))
    if(file.exists(path)) {
      r<-readRDS(path);stopifnot(identical(r$manifest_hash,manifest_hash),
        identical(r$input_hash,tools::md5sum(names(r$input_hash))),
        !isTRUE(r$fit$unexpected_validation_error))
      next
    }
    d<-m$designs[[job$Design]]
    input_path<-file.path(out,sprintf('input-%d-%03d.rds',job$Design,job$Replicate))
    seed<-m$seed_base+10000L*job$Design+job$Replicate
    if(file.exists(input_path)) {
      input<-readRDS(input_path)
      stopifnot(identical(input$manifest_hash,manifest_hash),input$seed==seed,
        input$Design==job$Design,input$Replicate==job$Replicate)
    } else {
      input<-jml_observed_generate(d,seed)
      input$Design<-job$Design;input$Replicate<-job$Replicate;input$manifest_hash<-manifest_hash
      jml_study_save(input,input_path)
    }
    seconds<-system.time(fit<-tryCatch(jml_observed_public(
      jml_observed_long(input$counts[[as.character(job$L)]],d$cells),d$owner,d$rating_max),
      error=function(e)list(error=conditionMessage(e),unexpected_validation_error=TRUE)))[['elapsed']]
    record<-list(Design=job$Design,Replicate=job$Replicate,L=job$L,seed=seed,
      fit=fit,seconds=seconds,manifest_hash=manifest_hash,input_hash=tools::md5sum(input_path))
    jml_study_save(record,path)
    if(isTRUE(fit$unexpected_validation_error)) stop('Unexpected validation error retained in ',path,
      '; investigate before continuing the study.')
    cat(format(Sys.time()),jml_study_name(job),'point',
      if(is.null(fit$error))fit$result$point$status else 'fit_error','intervals',
      if(is.null(fit$error))sum(fit$rows$Available) else 0,'seconds',seconds,'\n');flush.console()
  }
  jml_study_summary(out,m)
}

if(sys.nframe()==0L) {
  args<-commandArgs(trailingOnly=TRUE)
  if(length(args)==3L && args[1]=='prepare') jml_study_prepare(args[2],args[3]) else
    if(length(args)==2L && args[1]=='run') jml_study_run(args[2]) else
      if(length(args)==2L && args[1]=='summary') {
        out<-normalizePath(args[2]);m<-jml_study_load(out);jml_study_summary(out,m)
      } else stop('Choose prepare PILOT OUT, run OUT, or summary OUT.')
}
