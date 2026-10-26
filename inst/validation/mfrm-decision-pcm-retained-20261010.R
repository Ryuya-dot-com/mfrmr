# Unit-1 retained PCM comparison. Run from package root: prepare | preflight | run [N,N,...].
# Reuse the preceding study's sealed-file, runtime and numerical-summary helpers.
source('inst/validation/mfrm-decision-probability-summary-20261010.R')
mfp_root <- 'validation-results/mfrm-decision-pcm-retained-20261010'
mfp_old <- 'validation-results/mfrm-wide-map-pcm-r50-portable-20261003'
mfp_script <- 'inst/validation/mfrm-decision-pcm-retained-20261010.R'
mfp_ns <- c(20L,30L,60L,240L,480L)
mfp_laws <- list(population_L1=c(0,1),shift_mean_L1=c(.75,1),shift_sd_L1=c(0,.5))
mfp_hash <- function(x) digest::digest(serialize(x,NULL,version=3),algo='md5',serialize=FALSE)
mfp_phase <- function(path) {
  x <- readRDS(path); stopifnot(identical(x$checksum,mfp_hash(x$payload))); x
}
mfp_profiles <- function() do.call(rbind,lapply(1:3,function(k) {
  pairs <- list(c('1','2'),c('2','3'),c('3','1'))
  rows <- expand.grid(Rater=pairs[[k]],Criterion=as.character(1:3),stringsAsFactors=FALSE)
  do.call(rbind,lapply(0:18,function(total) data.frame(Person=sprintf('P%dT%02d',k,total),
    rows,Score=as.integer(pmin(3,pmax(0,total-3*(0:5)))),row.names=NULL)))
}))
mfp_keys <- function(data) {
  slot <- as.integer(data$Rater)+3L*(as.integer(data$Criterion)-1L)
  stopifnot(all(slot %in% 1:9),!anyDuplicated(paste(data$Person,slot)),all(data$Score %in% 0:3))
  groups <- split(seq_len(nrow(data)),data$Person)
  stopifnot(all(lengths(groups)==6L))
  data.frame(Person=names(groups),Mask=vapply(groups,function(i)sum(2^(slot[i]-1)),0),
    Total=vapply(groups,function(i)sum(data$Score[i]),0),row.names=NULL)
}
mfp_coordinates <- function(fit) {
  f <- fit$facets$others; s <- fit$steps
  get_f <- function(name) {
    x <- f[f$Facet==name,]; stopifnot(setequal(x$Level,as.character(1:3)))
    x$Estimate[match(as.character(1:3),x$Level)]
  }
  step <- matrix(s$Estimate[match(as.vector(t(outer(as.character(1:3),paste0('Step_',1:3),paste))),
    paste(s$StepFacet,s$Step))],3L,3L,byrow=TRUE)
  stopifnot(all(is.finite(step)),fit$config$model=='PCM')
  list(Rater=get_f('Rater'),Criterion=get_f('Criterion'),steps=step,log_slopes=rep(0,3))
}
mfp_category <- function(theta,rows,truth) {
  r <- as.integer(rows$Rater); c <- as.integer(rows$Criterion)
  eta <- outer(theta,-truth$Rater[r]-truth$Criterion[c],'+')
  cumulative <- cbind(0,t(apply(truth$steps,1,cumsum)))
  logits <- lapply(0:3,function(k) sweep(k*eta,2,cumulative[c,k+1L],'-'))
  high <- Reduce(pmax,logits); values <- lapply(logits,function(x)exp(x-high))
  normalizer <- Reduce('+',values); lapply(values,function(x)x/normalizer)
}
mfp_integral <- function(f,a,b) {
  if(a==b) return(0)
  x <- integrate(f,a,b,rel.tol=1e-11,abs.tol=0,subdivisions=1000L)
  stopifnot(x$message=='OK'); x$value
}
mfp_reference <- function(rows,truth,prior) {
  density <- function(z) {
    p <- mfp_category(prior[1]+prior[2]*z,rows,truth)
    value <- rep(1,length(z))
    for(j in seq_len(nrow(rows))) value <- value*p[[rows$Score[j]+1L]][,j]
    value*dnorm(z)
  }
  edges <- pmax(-12,pmin(12,c(-12,(mde_cuts-prior[1])/prior[2],12)))
  mass <- vapply(1:4,function(k)mfp_integral(density,edges[k],edges[k+1L]),0)
  stopifnot(sum(mass)>0,2*pnorm(-12)/sum(mass)<1e-12)
  band <- mass/sum(mass)
  setNames(c(rev(cumsum(rev(band)))[2:4],band),mde_events)
}
mfp_oracle <- function(profiles,truth,prior) {
  keys <- mfp_keys(profiles)
  p <- matrix(NA_real_,nrow(keys),7L,dimnames=list(keys$Person,mde_events))
  weight <- numeric(nrow(keys)); pattern_error <- 0
  for(mask in unique(keys$Mask)) {
    ix <- which(keys$Mask==mask)
    rows <- profiles[profiles$Person==keys$Person[ix[1]],]
    density <- function(z,total) {
      category <- mfp_category(prior[1]+prior[2]*z,rows,truth)
      law <- matrix(1,length(z),1L)
      for(j in seq_len(nrow(rows))) {
        next_law <- matrix(0,length(z),ncol(law)+3L)
        for(k in 0:3) next_law[,seq_len(ncol(law))+k] <-
          next_law[,seq_len(ncol(law))+k]+law*category[[k+1L]][,j]
        law <- next_law
      }
      law[,total+1L]*dnorm(z)
    }
    edges <- c(-12,(unname(mde_cuts)-prior[1])/prior[2],12)
    for(i in ix) {
      joint <- vapply(1:4,function(k)mfp_integral(function(z)density(z,keys$Total[i]),
        edges[k],edges[k+1L]),0)
      weight[i] <- sum(joint); band <- joint/weight[i]
      p[i,] <- c(rev(cumsum(rev(band)))[2:4],band)
      pattern_error <- max(pattern_error,abs(p[i,]-mfp_reference(
        profiles[profiles$Person==keys$Person[i],],truth,prior)))
    }
    pi <- c(pnorm(mde_cuts,prior[1],prior[2],lower.tail=FALSE),
      diff(pnorm(c(-Inf,mde_cuts,Inf),prior[1],prior[2])))
    stopifnot(abs(sum(weight[ix])-1)<1e-9,max(abs(colSums(p[ix,]*weight[ix])-pi))<1e-9)
  }
  stopifnot(pattern_error<1e-9)
  list(keys=keys,p=p,weight=weight/3,prior=pi,law=prior,PatternError=pattern_error)
}
mfp_verify_inputs <- function(meta,paths) {
  stopifnot(!anyNA(meta$Inputs[paths]),identical(mde_sha(paths),meta$Inputs[paths]))
}
mfp_guard <- function(meta) {
  stopifnot(identical(mde_sha(names(meta$Source)),meta$Source),identical(mde_runtime(),meta$Runtime))
}
mfp_prepare <- function() {
  path <- file.path(mfp_root,'metadata.rds')
  if(file.exists(path)) {mfp_guard(mde_read(path)); return(invisible(TRUE))}
  jobs <- read.csv(file.path(mfp_old,'jobs.csv'),stringsAsFactors=FALSE)
  jobs <- jobs[jobs$N %in% mfp_ns & jobs$SD==1 & jobs$View=='paired-L1' &
    jobs$Arm %in% c('PCM-MML-fixed','PCM-MML-free','PCM-JML'),]
  stopifnot(nrow(jobs)==750L,all(table(jobs$N,jobs$Arm)==50L))
  input_paths <- file.path(mfp_old,'jobs.csv'); output_rows <- list(); truth <- NULL
  for(n in mfp_ns) {
    summary_path <- file.path(mfp_old,paste0('summary-n',n),'summary.rds')
    old <- mfp_phase(summary_path)
    paths <- old$binding$outputs
    selected_outputs <- file.path(mfp_old,jobs$JobId[jobs$N==n],'outputs.rds')
    stopifnot(!anyNA(paths[selected_outputs]),
      identical(tools::md5sum(selected_outputs),paths[selected_outputs]))
    input_paths <- c(input_paths,summary_path,selected_outputs)
  }
  for(i in seq_len(nrow(jobs))) {
    job <- jobs[i,]; cal <- file.path(mfp_old,job$JobId,'calibration')
    sel_path <- file.path(cal,'selected.rds'); manifest_path <- file.path(cal,'manifest.rds')
    sel <- mfp_phase(sel_path); manifest <- mfp_phase(manifest_path)
    point <- sel$payload$point
    fit_path <- file.path(cal,paste0(sub(':.*','',point$stage),'-fit.rds'))
    fit <- mfp_phase(fit_path)
    stopifnot(identical(sel$binding,mfp_hash(manifest$payload)),
      identical(sel$payload$spec_hash,mfp_hash(manifest$payload$spec)),
      identical(fit$checksum,point$fit_hash))
    panel_path <- file.path(mfp_old,'panels',paste0(gsub('[^A-Za-z0-9]','_',job$ConditionId),'-',job$Replicate,'.rds'))
    panels <- mfp_phase(panel_path)$payload
    parent_path <- names(panels$panels$population_L1$provenance)
    stopifnot(identical(tools::md5sum(parent_path),panels$panels$population_L1$provenance))
    parent <- readRDS(parent_path)
    stopifnot(parent$unit$N==job$N,parent$unit$Replicate==job$Replicate,
      identical(parent$views[['paired-L1']],manifest$payload$input$data) ||
        is.null(manifest$payload$input$data))
    if(is.null(truth)) truth <- parent$truth else stopifnot(identical(truth,parent$truth))
    for(p in panels$panels) stopifnot(identical(p$PanelId,mfp_hash(p[setdiff(names(p),'PanelId')])) )
    input_paths <- c(input_paths,sel_path,manifest_path,fit_path,panel_path,parent_path)
    priors <- if(job$Arm=='PCM-MML-free') c('retained','reference') else 'retained'
    for(prior in priors) output_rows[[length(output_rows)+1L]] <- data.frame(job,
      Prior=prior,Id=paste(job$JobId,prior,sep='-'),FitPath=fit_path,PanelPath=panel_path,
      SelectedPath=sel_path,ManifestPath=manifest_path,ParentPath=parent_path,
      SourceStage=point$stage,HistoricalReady=isTRUE(point$value$ready),stringsAsFactors=FALSE)
  }
  plan <- do.call(rbind,output_rows); rownames(plan) <- NULL
  stopifnot(nrow(plan)==1000L,!anyDuplicated(plan$Id),all(truth$log_slopes==0))
  profiles <- mfp_profiles()
  oracle <- lapply(mfp_laws,function(prior)mfp_oracle(profiles,truth,prior))
  sources <- unique(c(list.files('R',pattern='[.]R$',full.names=TRUE),
    list.files('src',pattern='[.](cpp|hpp|h|so)$',full.names=TRUE),'DESCRIPTION','NAMESPACE',
    mde_script,'inst/validation/mfrm-decision-probability-summary-20261010.R',mfp_script))
  roadmap <- readLines('inst/validation/internal-roadmap-0.2.4.md')
  begin <- which(startsWith(roadmap,'**October 10 small-to-large-N PCM probability contract'))
  end <- grep('^### 2[.] Complete existing population inference',roadmap)
  stopifnot(length(begin)==1L,length(end)==1L,end>begin)
  dir.create(mfp_root,recursive=TRUE,showWarnings=FALSE)
  for(f in sources) {
    target <- file.path(mfp_root,'source',f); dir.create(dirname(target),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(f,target,overwrite=TRUE),identical(unname(mde_sha(f)),unname(mde_sha(target))))
  }
  mde_save(list(Plan=plan,Profiles=profiles,Truth=truth,Oracle=oracle,
    Inputs=mde_sha(unique(input_paths)),Source=mde_sha(sources),Runtime=mde_runtime(),
    Contract=roadmap[begin:(end-1L)],Created=as.character(Sys.time()),Session=sessionInfo()),path)
  cat('Prepared 750 sources, 250 calibration bundles and 1000 profile jobs; no fitting or generation.\n')
}
mfp_matrix <- function(y,persons,prior) {
  d <- y$decisions
  stopifnot(nrow(d)==length(persons)*7,!anyDuplicated(paste(d$Person,d$Label)),
    all(d$Status=='available_conditional'),max(abs(d$PriorMean-prior[1]))<1e-12,
    max(abs(d$PriorSD-prior[2]))<1e-12)
  at <- match(as.vector(t(outer(persons,mde_events,paste))),paste(d$Person,d$Label))
  stopifnot(!anyNA(at))
  p <- matrix(d$Probability[at],ncol=7,byrow=TRUE,dimnames=list(persons,mde_events))
  stopifnot(all(is.finite(p)),all(p>=0 & p<=1),max(abs(rowSums(p[,4:7])-1))<1e-9)
  p
}
mfp_public <- function(fit,data,prior,cuts=mde_cuts) {
  warnings <- character()
  value <- tryCatch(withCallingHandlers(predict_mfrm_units(fit,data,
    scoring_prior=if(prior=='reference')list(mean=0,sd=1) else NULL,
    scoring_quad_points=121L,cut_scores=cuts),warning=function(w) {
      warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')}),error=identity)
  list(value=value,warnings=unique(warnings))
}
mfp_metrics <- function(p,prior,panels,meta,n) {
  pi <- c(pnorm(mde_cuts,prior[1],prior[2],lower.tail=FALSE),
    diff(pnorm(c(-Inf,mde_cuts,Inf),prior[1],prior[2])))
  laws <- if(n==30) 'population_L1' else names(mfp_laws)
  metrics <- bins <- list()
  for(law in laws) {
    o <- meta$Oracle[[law]]; w <- o$weight; q <- o$p; error <- p-q
    panel <- panels[[law]]; stopifnot(!is.null(panel),nrow(panel$planned)==60L)
    keys <- mfp_keys(panel$data); at <- mde_lookup(keys,o$keys)
    theta <- panel$planned$Theta[match(keys$Person,panel$planned$Person)]
    stopifnot(nrow(keys)==60L,all(table(keys$Mask)==20L),!anyNA(theta))
    z <- cbind(outer(theta,mde_cuts,'>'),outer(theta,c(-Inf,mde_cuts),'>') &
      outer(theta,c(mde_cuts,Inf),'<=') )*1
    observed <- p[at,]; known <- q[at,]
    bayes <- colSums(q*(1-q)*w); risk <- colSums(error^2*w)
    target <- o$prior*(1-o$prior); actual <- target+(pi-o$prior)^2
    metrics[[law]] <- data.frame(Law=law,Event=mde_events,ExpectedBias=colSums(error*w),
      ExcessBrier=risk,OracleBrier=bayes,ExpectedBrier=bayes+risk,TargetPriorBrier=target,
      ScoringPriorBrier=actual,TargetPriorDifference=bayes+risk-target,
      ScoringPriorDifference=bayes+risk-actual,RealizedBias=colMeans(observed-z),
      RealizedBrier=colMeans((observed-z)^2),RealizedOracleBrier=colMeans((known-z)^2),
      RealizedExcess=colMeans((observed-z)^2-(known-z)^2),row.names=NULL)
    bins[[law]] <- do.call(rbind,lapply(1:7,function(j) do.call(rbind,lapply(1:5,function(b) {
      take <- pmin(5,floor(p[,j]*5)+1)==b
      data.frame(Law=law,Event=mde_events[j],Bin=b,Mass=sum(w[take]),
        ErrorSum=sum(w[take]*error[take,j]),PredictionSum=sum(w[take]*p[take,j]),
        TruthSum=sum(w[take]*q[take,j]))
    }))))
  }
  list(metrics=do.call(rbind,metrics),bins=do.call(rbind,bins))
}
mfp_one <- function(row,meta,preflight=FALSE) {
  files <- unlist(row[c('FitPath','PanelPath','SelectedPath','ManifestPath','ParentPath')],use.names=FALSE)
  mfp_verify_inputs(meta,files)
  fit_phase <- mfp_phase(row$FitPath)$payload
  panels <- mfp_phase(row$PanelPath)$payload$panels
  started <- proc.time()[['elapsed']]
  fit <- fit_phase$value; error <- fit_phase$error
  prediction <- NULL; p <- NULL; prior <- c(NA_real_,NA_real_); warnings <- character()
  checks <- c(Reference=NA_real_,Legacy=NA_real_,RawLookup=NA_real_)
  if(!nzchar(error)) {
    stopifnot(fit$config$model=='PCM')
    prior <- if(row$Prior=='retained' && isTRUE(fit$population$active))
      c(unname(fit$population$coefficients),sqrt(fit$population$sigma2)) else c(0,1)
    stopifnot(length(prior)==2L)
    result <- mfp_public(fit,meta$Profiles,row$Prior); warnings <- result$warnings
    prediction <- result$value
    if(inherits(prediction,'error')) error <- conditionMessage(prediction) else
      p <- mfp_matrix(prediction,meta$Oracle$population_L1$keys$Person,prior)
  }
  if(preflight && !is.null(p)) {
    reference <- t(vapply(rownames(p),function(person)mfp_reference(
      meta$Profiles[meta$Profiles$Person==person,],mfp_coordinates(fit),prior),numeric(7)))
    no_cuts <- mfp_public(fit,meta$Profiles,row$Prior,NULL)
    stopifnot(!inherits(no_cuts$value,'error'))
    fields <- c('Estimate','SD','Lower','Upper')
    checks['Reference'] <- max(abs(p-reference))
    checks['Legacy'] <- max(abs(as.matrix(prediction$estimates[fields])-
      as.matrix(no_cuts$value$estimates[fields])))
    data <- panels$population_L1$data
    data <- data[data$Person %in% panels$population_L1$planned$Person[1:12],]
    direct <- mfp_public(fit,data,row$Prior); stopifnot(!inherits(direct$value,'error'))
    keys <- mfp_keys(data)
    checks['RawLookup'] <- max(abs(mfp_matrix(direct$value,keys$Person,prior)-
      p[mde_lookup(keys,meta$Oracle$population_L1$keys),]))
    stopifnot(max(checks)<1e-8)
  }
  measures <- if(is.null(p)) NULL else mfp_metrics(p,prior,panels,meta,row$N)
  list(Job=row,Available=!is.null(p),Error=error,Warnings=warnings,Prior=prior,
    Prediction=prediction,Probabilities=p,Metrics=measures,Checks=checks,
    Seconds=proc.time()[['elapsed']]-started,
    MetadataSHA256=mde_sha(file.path(mfp_root,'metadata.rds')))
}
mfp_preflight <- function(meta) {
  path <- file.path(mfp_root,'preflight.rds')
  if(file.exists(path)) return(invisible(mde_read(path)))
  plan <- meta$Plan[meta$Plan$Replicate==1L,]; results <- list()
  for(i in seq_len(nrow(plan))) {
    row <- plan[i,]; results[[row$Id]] <- mfp_one(row,meta,TRUE)
    r <- results[[row$Id]]
    cat(sprintf('Preflight N%d %s %s: available=%s %.2fs %s\n',
      row$N,row$Arm,row$Prior,r$Available,r$Seconds,r$Error)); flush.console()
  }
  stopifnot(length(results)==20L)
  for(arm in unique(plan$Arm)) stopifnot(any(vapply(results,function(r)
    r$Job$Arm==arm && r$Available,TRUE)))
  mfp_guard(meta); mde_save(results,path)
}
mfp_run <- function(meta,ns) {
  preflight <- mde_read(file.path(mfp_root,'preflight.rds'))
  stopifnot(all(ns %in% mfp_ns),!anyDuplicated(ns))
  plan <- meta$Plan[meta$Plan$N %in% ns,]
  dir.create(file.path(mfp_root,'jobs'),showWarnings=FALSE)
  for(i in seq_len(nrow(plan))) {
    row <- plan[i,]; path <- file.path(mfp_root,'jobs',paste0(row$Id,'.rds'))
    if(file.exists(path)) {
      old <- mde_read(path)
      stopifnot(identical(old$MetadataSHA256,mde_sha(file.path(mfp_root,'metadata.rds'))),
        identical(old$Job,row)); next
    }
    if(i%%50L==1L) mfp_guard(meta)
    result <- if(row$Id %in% names(preflight)) preflight[[row$Id]] else mfp_one(row,meta)
    mde_save(result,path)
    if(i%%25L==0L) {
      cat(sprintf('Completed %d/%d; N%d %s %s available=%s\n',i,nrow(plan),row$N,row$Arm,row$Prior,
        result$Available)); flush.console()
    }
  }
  mfp_guard(meta)
}
if(sys.nframe()==0L) {
  args <- commandArgs(TRUE); stopifnot(length(args)>=1L,args[1] %in% c('prepare','preflight','run'))
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  requireNamespace('digest'); requireNamespace('jsonlite')
  if(args[1]=='prepare') mfp_prepare() else {
    meta <- mde_read(file.path(mfp_root,'metadata.rds')); mfp_guard(meta)
    if(args[1]=='preflight') mfp_preflight(meta) else
      mfp_run(meta,if(length(args)>1L)as.integer(strsplit(args[2],',',fixed=TRUE)[[1]]) else mfp_ns)
  }
}
