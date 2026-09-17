# Run from the development root; see the frozen companion plan.
source('inst/validation/mml-structural-coverage-0.2.4.R')
source('inst/validation/adaptive-quadrature-review-0.2.4.R')

pec_keys <- function(data) {
  do.call(rbind,lapply(split(data,data$Person),function(x) {
    x <- x[order(x$Rater,x$Criterion),]
    data.frame(Person=x$Person[1],Assignment=paste(x$Rater,x$Criterion,collapse='|'),
      Total=sum(x$Score),Ratings=nrow(x),stringsAsFactors=FALSE)
  }))
}

pec_profiles <- function() {
  full <- expand.grid(Rater=paste0('R',1:3),Criterion=c('C1','C2'),stringsAsFactors=FALSE)
  patterns <- lapply(1:2,function(i) full[(i+match(full$Rater,paste0('R',1:3)))%%2 ==
    match(full$Criterion,c('C1','C2'))-1L,])
  patterns[[3]] <- full
  do.call(rbind,lapply(seq_along(patterns),function(i) {
    x <- patterns[[i]]; x <- x[order(x$Rater,x$Criterion),]
    do.call(rbind,lapply(0:(2*nrow(x)),function(total) {
      data.frame(Person=sprintf('A%dT%02d',i,total),x,
        Score=as.integer(pmin(2,pmax(0,total-2*(seq_len(nrow(x))-1)))),row.names=NULL)
    }))
  }))
}

pec_new_cohort <- function(model,seed,n=512L) {
  x <- mml_information_fixture(model,'baseline',3L,seed,n,6L)
  # Reuse the actual latent draw retained by the unchanged generator.
  theta <- get('theta',envir=environment(x$objective),inherits=FALSE)
  truth <- data.frame(Person=paste0('NEW',x$persons$Person),Theta=theta)
  x$data$Person <- paste0('NEW',x$data$Person)
  pi <- match(x$data$Person,truth$Person)
  keep <- (pi+match(x$data$Rater,paste0('R',1:3)))%%2 ==
    match(x$data$Criterion,c('C1','C2'))-1L
  stopifnot(length(theta)==n,all(table(x$data$Person)==6L),all(table(x$data$Person[keep])==3L))
  list(truth=truth,data=x$data,three=x$data[keep,])
}

pec_reference <- function(rows,model,par,maps,interval=FALSE) {
  facets <- as.vector(maps$facet_map %*% par)
  ri <- match(rows$Rater,paste0('R',1:3)); ci <- match(rows$Criterion,c('C1','C2'))
  base <- -facets[ri]-facets[3+ci]
  steps <- matrix(maps$step_map %*% par,ncol=2,byrow=TRUE)
  steps <- steps[if(model=='RSM') rep(1L,nrow(rows)) else ci,,drop=FALSE]
  moments <- aq_continuous_reference(rows$Score,base,steps,rep(1,nrow(rows)),rep(1,nrow(rows)))
  cumulative <- cbind(0,t(apply(steps,1,cumsum)))
  density <- function(theta) vapply(theta,function(value) {
    logits <- outer(value+base,0:2)-cumulative
    high <- apply(logits,1,max)
    loglik <- sum(logits[cbind(seq_len(nrow(rows)),rows$Score+1)]-high-
      log(rowSums(exp(logits-high))))
    exp(loglik+dnorm(value,log=TRUE)-moments['log_marginal'])
  },0)
  tail_bound <- 2*pnorm(-16)*exp(-moments['log_marginal'])
  stopifnot(tail_bound<1e-12,moments['relative_error']<1e-9)
  cdf <- function(theta) vapply(theta,function(value) {
    if(value<=-16) return(0)
    if(value>=16) return(1)
    integrate(density,-16,value,rel.tol=1e-10,abs.tol=1e-12,subdivisions=1000L)$value
  },0)
  bounds <- if(interval) vapply(c(.025,.975),function(p)
    uniroot(function(z) cdf(z)-p,c(-16,16),tol=1e-10)$root,0) else c(NA_real_,NA_real_)
  list(estimates=c(Estimate=unname(moments['eap']),SD=unname(moments['sd']),
    Lower=bounds[1],Upper=bounds[2]),cdf=cdf,tail_bound=tail_bound)
}

pec_oracle <- function(model,profiles) {
  maps <- mml_information_fixture(model,'baseline',3L,94000001L,2L,6L)
  result <- lapply(split(profiles,profiles$Person),function(rows) {
    r <- pec_reference(rows,model,maps$truth,maps,TRUE)
    data.frame(Person=rows$Person[1],as.list(r$estimates),row.names=NULL)
  })
  do.call(rbind,result)
}

pec_lookup <- function(scores,profiles,data) {
  profile_keys <- pec_keys(profiles); keys <- pec_keys(data)
  key <- function(x) paste(x$Assignment,x$Total,sep=';')
  index <- match(key(keys),key(profile_keys))
  stopifnot(!anyNA(index))
  index <- match(profile_keys$Person[index],scores$Person)
  stopifnot(!anyNA(index))
  out <- scores[index,c('Estimate','SD','Lower','Upper')]
  data.frame(Person=keys$Person,out,Ratings=keys$Ratings,Total=keys$Total,row.names=NULL)
}

pec_measures <- function(scores,truth,method,exposure) {
  theta <- truth$Theta[match(scores$Person,truth$Person)]
  stopifnot(!anyNA(theta))
  covered <- theta>=scores$Lower & theta<=scores$Upper
  error <- scores$Estimate-theta
  strata <- as.character(cut(theta,c(-Inf,-2,-1,0,1,2,Inf)))
  groups <- c(list(All=seq_along(theta)),split(seq_along(theta),strata))
  do.call(rbind,lapply(names(groups),function(name) {
    i <- groups[[name]]
    data.frame(Method=method,NewRatings=exposure,Stratum=name,Persons=length(i),
      Coverage=mean(covered[i]),MeanWidth=mean(scores$Upper[i]-scores$Lower[i]),
      Bias=mean(error[i]),MSE=mean(error[i]^2),MeanSD=mean(scores$SD[i]),
      ExtremeRate=mean(scores$Total[i] %in% c(0,2*exposure)),row.names=NULL)
  }))
}

pec_one <- function(cell,replicate,stage,profiles,oracle) {
  seed <- (if(stage=='preflight') 94000000L else 104000000L)+10000L*cell$Cell+replicate
  started <- proc.time()[['elapsed']]
  x <- mml_information_fixture(cell$Model,'baseline',3L,seed,cell$Persons,cell$Exposure)
  cohort <- pec_new_cohort(cell$Model,seed+2000L)
  stopifnot(!any(cohort$truth$Person %in% x$data$Person),all(table(x$data$Person)==cell$Exposure),
    all(table(x$data$Rater,x$data$Criterion)>0),all(x$data$Weight==1))
  metrics <- do.call(rbind,lapply(c(3L,6L),function(exposure) {
    data <- if(exposure==3L) cohort$three else cohort$data
    pec_measures(pec_lookup(oracle,profiles,data),cohort$truth,'known',exposure)
  }))
  status <- data.frame(Cell=cell$Cell,Replicate=replicate,Seed=seed,Stage=stage,
    FitReady=FALSE,ScoringReady=FALSE,Available=FALSE,NumericalOK=FALSE,
    ObjectiveChange=NA_real_,Gradient61=NA_real_,Gradient121=NA_real_,
    IndependentObjectiveError=NA_real_,ScoringOrderError=NA_real_,
    MaxTailError=NA_real_,ReferenceMomentError=NA_real_,DirectLookupError=NA_real_,
    ArtifactError=NA_real_,Error='',Warnings='',Seconds=NA_real_)
  fit <- scores <- artifact <- review <- NULL
  warnings <- character()
  condition <- tryCatch(withCallingHandlers({
    fit <- fit_mfrm(x$data,'Person',c('Rater','Criterion'),'Score',model=cell$Model,
      method='MML',step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,
      rating_min=0,rating_max=2,quad_points=61L,maxit=200L,reltol=1e-10)
    sizes <- mfrmr:::build_param_sizes(fit$config)
    active <- unlist(sizes); active <- active[active>0L]
    stopifnot(identical(names(active),names(x$sizes)),all(active==x$sizes))
    status$FitReady <- mfrmr:::mfrm_inference_ready(fit)
    status$ScoringReady <- isTRUE(mfrmr:::prediction_source_scoring_readiness(fit)$ready)
    idx <- mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet)
    q61 <- mfrmr:::gauss_hermite_normal(61L); q121 <- mfrmr:::gauss_hermite_normal(121L)
    value <- mfrmr:::mfrm_loglik_mml(fit$opt$par,idx,fit$config,sizes,q121)
    status$ObjectiveChange <- abs(value-fit$opt$value)
    status$Gradient61 <- max(abs(mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,sizes,q61)))
    status$Gradient121 <- max(abs(mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,sizes,q121)))
    status$NumericalOK <- status$ObjectiveChange<=1e-6 &&
      max(status$Gradient61,status$Gradient121)<=1e-4
    scores <- predict_mfrm_units(fit,profiles,scoring_quad_points=61L)
    estimates <- scores$estimates
    status$Available <- all(is.finite(as.matrix(estimates[c('Estimate','SD','Lower','Upper')])))
    if(!status$Available) stop('Non-finite public prediction')
    for(exposure in c(3L,6L)) {
      data <- if(exposure==3L) cohort$three else cohort$data
      looked <- pec_lookup(estimates,profiles,data)
      metrics <- rbind(metrics,pec_measures(looked,cohort$truth,'estimated',exposure))
    }
    if(stage=='preflight') {
      high <- predict_mfrm_units(fit,profiles,scoring_quad_points=121L)$estimates
      fields <- c('Estimate','SD','Lower','Upper')
      status$ScoringOrderError <- max(abs(as.matrix(high[fields])-as.matrix(estimates[fields])))
      checks <- lapply(split(profiles,profiles$Person),function(rows) {
        ref <- pec_reference(rows,cell$Model,fit$opt$par,x)
        actual <- estimates[match(rows$Person[1],estimates$Person),]
        c(tail=max(abs(ref$cdf(c(actual$Lower,actual$Upper))-c(.025,.975))),
          moment=max(abs(c(actual$Estimate,actual$SD)-ref$estimates[1:2])))
      })
      status$MaxTailError <- max(vapply(checks,`[[`,0,'tail'))
      status$ReferenceMomentError <- max(vapply(checks,`[[`,0,'moment'))
      status$NumericalOK <- status$NumericalOK && max(status$ScoringOrderError,
        status$MaxTailError,status$ReferenceMomentError)<=1e-6
      if(replicate==1L) {
        status$IndependentObjectiveError <- abs(x$objective(fit$opt$par)-fit$opt$value)
        lookup_errors <- vapply(c(3L,6L),function(exposure) {
          data <- if(exposure==3L) cohort$three else cohort$data
          data <- data[data$Person %in% cohort$truth$Person[1:48],]
          direct <- predict_mfrm_units(fit,data,scoring_quad_points=61L)$estimates
          looked <- pec_lookup(estimates,profiles,data)
          looked <- looked[match(direct$Person,looked$Person),]
          max(abs(as.matrix(direct[fields])-as.matrix(looked[fields])))
        },0)
        status$DirectLookupError <- max(lookup_errors)
        review <- mml_quadrature_sensitivity(fit,x$data,quad_points=c(61L,121L))
        artifact <- freeze_mfrm_calibration(validate_mfrm_calibration(
          extract_mfrm_calibration(review$fits$q121,quadrature_review=review)))
        path <- tempfile(fileext='.rds'); on.exit(unlink(path),add=TRUE)
        save_mfrm_calibration(artifact,path); restored <- load_mfrm_calibration(path)
        stopifnot(identical(artifact,restored))
        portable <- score_mfrm_calibration(restored,profiles)$estimates
        from_fit <- predict_mfrm_units(review$fits$q121,profiles,
          scoring_quad_points=length(artifact$scoring_basis$nodes))$estimates
        portable <- portable[match(from_fit$Person,portable$Person),]
        status$ArtifactError <- max(abs(as.matrix(portable[fields])-as.matrix(from_fit[fields])))
        status$NumericalOK <- status$NumericalOK && status$IndependentObjectiveError<=1e-6 &&
          status$DirectLookupError<=1e-8 && status$ArtifactError<=1e-8
      }
    }
    NULL
  },warning=function(w) {
    warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning')
  }),error=identity)
  if(inherits(condition,'error')) { status$Error <- conditionMessage(condition); status$NumericalOK <- FALSE }
  status$Warnings <- paste(unique(warnings),collapse='; ')
  status$Seconds <- proc.time()[['elapsed']]-started
  list(status=status,metrics=metrics,fit=fit,scores=scores,calibration_data=x$data,
    calibration_truth=x$truth,cohort=cohort,artifact=artifact,review=review)
}

pec_run <- function(stage,directory,cells=1:8) {
  stopifnot(stage %in% c('preflight','main'),all(cells %in% 1:8),!anyDuplicated(cells))
  dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
    list.files('src',pattern='[.](cpp|h|hpp)$',full.names=TRUE),paste0('inst/validation/',c(
      'person-estimated-calibration-0.2.4.R','person-estimated-calibration-0.2.4-plan.md',
      'mml-structural-coverage-0.2.4.R','mml-independent-information-conditions-0.2.4.R',
      'mml-independent-rsm-information-0.2.4.R','adaptive-quadrature-review-0.2.4.R')))
  payload <- tools::md5sum(files)
  n <- if(stage=='preflight') 5L else 256L
  all_seeds <- unlist(lapply(c(94000000L,104000000L),function(base)
    unlist(lapply(1:8,function(cell) c(base+10000L*cell+1:256,base+10000L*cell+2000L+1:256)))))
  stopifnot(!anyDuplicated(all_seeds))
  profiles <- pec_profiles(); stopifnot(length(unique(profiles$Person))==27L)
  oracle <- lapply(setNames(c('RSM','PCM'),c('RSM','PCM')),pec_oracle,profiles=profiles)
  metadata <- file.path(directory,'metadata.rds')
  meta <- list(Stage=stage,Planned=n,Payload=payload,Profiles=profiles,Oracle=oracle)
  if(file.exists(metadata)) stopifnot(identical(readRDS(metadata),meta)) else saveRDS(meta,metadata)
  plan <- mml_coverage_cells()
  for(id in cells) for(rep in seq_len(n)) {
    path <- file.path(directory,sprintf('cell-%02d-rep-%04d.rds',id,rep))
    if(file.exists(path)) {
      existing <- readRDS(path)
      stopifnot(identical(existing$payload,payload),existing$status$Cell==id,
        existing$status$Replicate==rep,existing$status$Stage==stage)
      next
    }
    value <- pec_one(plan[id,],rep,stage,profiles,oracle[[plan$Model[id]]])
    value$payload <- payload; value$session <- sessionInfo()
    saveRDS(value,paste0(path,'.tmp'))
    stopifnot(file.rename(paste0(path,'.tmp'),path))
    cat(sprintf('%s cell %d: %d/%d %.2fs available=%s numerical=%s error=%s\n',
      stage,id,rep,n,value$status$Seconds,value$status$Available,value$status$NumericalOK,value$status$Error))
    flush.console()
  }
  invisible(TRUE)
}

if(sys.nframe()==0L) {
  library_path <- Sys.getenv('PEC_LIBRARY')
  if(nzchar(library_path)) .libPaths(c(library_path,.libPaths()))
  library(mfrmr)
  args <- commandArgs(TRUE)
  stopifnot(length(args)>=2L)
  pec_run(args[1],args[2],if(length(args)>2L) as.integer(strsplit(args[3],',',fixed=TRUE)[[1]]) else 1:8)
}
