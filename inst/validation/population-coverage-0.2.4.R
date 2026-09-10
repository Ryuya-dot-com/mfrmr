# Repository-only diagnostic intervals; see population-coverage-protocol-0.2.4.md.
# Rscript inst/validation/population-coverage-0.2.4.R preflight /tmp/pop-coverage [1,2]
# Rscript inst/validation/population-coverage-0.2.4.R summarize /tmp/pop-coverage
source('inst/validation/mml-structural-coverage-0.2.4.R')
source('inst/validation/numerical-stationarity-pilot-0.2.3.R')

population_coverage_interval <- function(estimate, se, candidate) {
  lower <- estimate-qnorm(.975)*se; upper <- estimate+qnorm(.975)*se
  available <- candidate & is.finite(estimate) & is.finite(se) & se>0 &
    is.finite(lower) & is.finite(upper)
  list(SE=se,Lower=lower,Upper=upper,Available=available,
    VarianceLogLower=unname(exp(lower['LogVariance'])),
    VarianceLogUpper=unname(exp(upper['LogVariance'])))
}

population_coverage_one <- function(cell, replicate, stage) {
  seed <- (if(stage=='preflight') 71000000L else 81000000L)+100000L*cell$Cell+replicate
  started <- proc.time()[['elapsed']]
  truth <- c(Intercept=.2,Slope=.5,LogVariance=log(.7),Variance=.7)
  empty <- setNames(rep(NA_real_,length(truth)),names(truth))
  out <- c(list(Replicate=replicate,Seed=seed,Truth=truth,Estimate=empty),
    population_coverage_interval(empty,empty,FALSE),
    list(Returned=FALSE,NativePass=FALSE,InferenceReady=FALSE,ScoringReady=FALSE,
      CovarianceStatus='not_computed',HighCovarianceStatus='not_computed',
      AvailabilityReason='fit_error',BoundaryQualification='not_evaluated',
      NumericalOK=FALSE,NumericalConflict=FALSE,Independent=NULL,
      ObjectiveChange=NA_real_,RelativeSEChange=NA_real_,ScaledNewtonDisplacement=NA_real_,
      FullGradient=NA_real_,HighFullGradient=NA_real_,MinEigenvalue=NA_real_,
      Error='',Warnings=character(),CoreSeconds=NA_real_,Seconds=NA_real_))
  x <- fit <- NULL
  error <- tryCatch(withCallingHandlers({
    x <- mml_information_fixture(cell$Model,'population',3L,seed,cell$Persons,cell$Exposure)
    stopifnot(all(table(x$data$Person)==cell$Exposure),all(x$data$Weight==1),
      nrow(x$data)==cell$Persons*cell$Exposure,all(table(x$data$Rater,x$data$Criterion)>0))
    fit <- do.call(fit_mfrm,c(list(data=x$data,person='Person',facets=c('Rater','Criterion'),
      score='Score',model=cell$Model,step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,
      method='MML',rating_min=0,rating_max=2,quad_points=61L,maxit=300L,reltol=1e-10,
      mml_engine='direct'),x$extra))
    out$Returned <- TRUE; out$BoundaryQualification <- 'global_and_boundary_not_certified'
    out$NativePass <- identical(fit$opt$optimizer_diagnostics$ConvergenceSeverity,'pass')
    out$NativeDiagnostics <- fit$opt$optimizer_diagnostics
    out$InferenceReady <- mfrmr:::mfrm_inference_ready(fit)
    out$ScoringReady <- mfrmr:::prediction_source_scoring_readiness(fit)$ready
    out$ReadinessReasons <- fit$readiness$fit$ReasonCodes
    context <- mfrmr_num_fit_context(fit); p <- fit$opt$par
    take <- c(x$slices$beta,x$slices$log_sigma2)
    out$Parameters <- p
    out$Estimate <- setNames(c(p[take],exp(p[x$slices$log_sigma2])),names(truth))
    if(!all(is.finite(p)) || !is.finite(out$Estimate['Variance']) || out$Estimate['Variance']<=0) {
      out$AvailabilityReason <- 'nonfinite_or_nonpositive_variance'
      stop('Nonfinite parameters or nonpositive residual variance',call.=FALSE)
    }
    stopifnot(identical(context$coordinates$ParameterClass,rep(names(x$sizes),x$sizes)),
      max(abs(p[c(x$slices$beta,x$slices$log_sigma2)]-
        c(fit$population$coefficients,log(fit$population$sigma2))))<1e-10)
    out$FullGradient <- max(abs(context$gr(p)))
    out$AvailabilityReason <- if(!out$NativePass) 'native_convergence' else if(
      !all(is.finite(p)) || !is.finite(out$Estimate['Variance']) || out$Estimate['Variance']<=0
    ) 'nonfinite_or_nonpositive_variance' else 'covariance_unavailable'
    cov <- mfrmr:::compute_mml_parameter_covariance(fit)
    out$CovarianceStatus <- cov$status; out$Covariance <- cov$cov
    out$MinEigenvalue <- min(eigen(cov$hessian,symmetric=TRUE,only.values=TRUE)$values)
    if(!identical(cov$status,'ok')) stop('q61 covariance is not unregularized',call.=FALSE)
    se <- sqrt(diag(cov$cov))[take]
    se <- setNames(c(se,exp(p[x$slices$log_sigma2])*tail(se,1)),names(truth))
    candidate <- out$NativePass && all(is.finite(p)) &&
      is.finite(out$Estimate['Variance']) && out$Estimate['Variance']>0
    interval <- population_coverage_interval(out$Estimate,se,candidate)
    out[names(interval)] <- interval
    if(candidate) out$AvailabilityReason <- if(all(out$Available)) 'computable' else 'target_arithmetic'
    high <- fit; high$config$estimation_control$quad_points <- 121L
    high_context <- mfrmr_num_fit_context(high)
    high_cov <- mfrmr:::compute_mml_parameter_covariance(high)
    out$HighCovarianceStatus <- high_cov$status
    if(!identical(high_cov$status,'ok')) stop('q121 covariance is not unregularized',call.=FALSE)
    high_score <- high_context$gr(p)
    out$HighFullGradient <- max(abs(high_score))
    out$ObjectiveChange <- abs(high_context$fn(p)-context$fn(p))
    out$RelativeSEChange <- max(abs(sqrt(diag(high_cov$cov)/diag(cov$cov))-1))
    out$ScaledNewtonDisplacement <- max(abs(high_cov$cov %*% high_score)/sqrt(diag(cov$cov)))
    out$NumericalOK <- isTRUE(out$ObjectiveChange<=1e-6 && out$RelativeSEChange<=.001 &&
      out$ScaledNewtonDisplacement<=.001 && out$FullGradient<=1e-4 && out$HighFullGradient<=1e-4)
    out$CoreSeconds <- proc.time()[['elapsed']]-started
    if(stage=='preflight' && replicate==1L) {
      g1 <- mfrmr_num_central_gradient(x$objective,p,1e-4)
      g2 <- mfrmr_num_central_gradient(x$objective,p,5e-5)
      metrics <- c(ObjectiveDifference=abs(x$objective(p)-context$fn(p)),
        GradientStepDifference=max(abs(g1-g2)),GradientDifference=max(abs(g2-context$gr(p))),
        FullGradient=max(abs(g2)))
      out$Independent <- list(Metrics=metrics,Pass=metrics<=c(1e-6,1e-7,1e-7,1e-4))
    }
    NULL
  },warning=function(w) {out$Warnings <<- c(out$Warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=identity)
  if(inherits(error,'error')) out$Error <- conditionMessage(error)
  out$NumericalConflict <- any(out$Available) && !out$NumericalOK
  out$Seconds <- proc.time()[['elapsed']]-started
  if(stage=='preflight' || nzchar(out$Error) || !all(out$Available) || out$NumericalConflict)
    out$Detail <- list(fit=fit,data=x$data,persons=x$persons)
  out
}

population_coverage_summary <- function(results, planned, stage) {
  stopifnot(length(results)>0L,!anyDuplicated(vapply(results,`[[`,integer(1),'Seed')),
    all(vapply(results,function(x) identical(x$Truth,results[[1]]$Truth),logical(1))))
  rows <- lapply(names(results[[1]]$Truth),function(target) {
    errors <- vapply(results,function(x) x$Estimate[target]-x$Truth[target],numeric(1))
    se <- vapply(results,function(x) x$SE[target],numeric(1))
    available <- vapply(results,function(x) isTRUE(x$Available[target]),logical(1))
    conflict <- vapply(results,function(x) isTRUE(x$Available[target]) && !x$NumericalOK,logical(1))
    row <- mml_coverage_coordinate(errors,se,available,conflict,planned)
    names(row)[names(row)=='ReadyNumericalConflicts'] <- 'ComputableNumericalConflicts'
    # Coverage is identical under exponentiation; never use the normal width on the variance scale.
    row$MeanVarianceLogWidth <- if(target=='LogVariance' && any(available)) mean(vapply(
      results[available],function(x) x$VarianceLogUpper-x$VarianceLogLower,numeric(1))) else NA_real_
    row$BackTransformEndpointLimits <- if(target=='LogVariance') sum(vapply(results[available],
      function(x) x$VarianceLogLower==0 || !is.finite(x$VarianceLogUpper),logical(1))) else NA_integer_
    row$NonpositiveLowerRate <- if(target=='Variance' && any(available)) mean(vapply(
      results[available],function(x) x$Lower['Variance']<=0,logical(1))) else NA_real_
    if(stage=='preflight') row$Disposition <- 'preflight_only'
    cbind(Target=target,Role=if(target=='Variance') 'secondary_delta' else 'primary',row)
  })
  do.call(rbind,rows)
}

population_coverage_self_check <- function() {
  mml_coverage_self_check()
  n <- 2500L; errors <- qnorm((seq_len(n)-.5)/n)
  results <- lapply(seq_len(n),function(i) {
    truth <- c(Intercept=.2,Slope=.5,LogVariance=log(.7),Variance=.7)
    estimate <- truth+errors[i]; estimate['Variance'] <- exp(estimate['LogVariance'])
    se <- c(Intercept=1,Slope=1,LogVariance=1,Variance=unname(estimate['Variance']))
    c(list(Seed=i,Truth=truth,Estimate=estimate,InferenceReady=FALSE,NumericalOK=TRUE),
      population_coverage_interval(estimate,se,TRUE))
  })
  good <- population_coverage_summary(results,n,'confirmation')
  stopifnot(all(good$Available==n),all(good$Disposition[good$Role=='primary']=='supported'),
    all(vapply(results,function(x) identical(abs(x$Estimate['LogVariance']-log(.7))<=qnorm(.975),
      setNames(x$VarianceLogLower<=.7 && .7<=x$VarianceLogUpper,'LogVariance')),logical(1))),
    good$NonpositiveLowerRate[good$Target=='Variance']==1)
  results[[1]]$Available[] <- FALSE
  results[[2]]$NumericalOK <- FALSE
  mixed <- population_coverage_summary(results,n+1L,'confirmation')
  stopifnot(all(mixed$Available==n-1L),all(mixed$FiniteEstimates==n),
    all(mixed$ComputableNumericalConflicts==1L),all(mixed$Disposition=='incomplete'),
    all(mixed$AvailableAndCoveredPerAssigned<=mixed$Available/(n+1L)),
    all(population_coverage_summary(results,n,'preflight')$Disposition=='preflight_only'),
    !any(population_coverage_interval(c(LogVariance=0),c(LogVariance=Inf),TRUE)$Available))
  invisible(TRUE)
}

population_coverage_run <- function(stage,directory,cells=1:8) {
  stopifnot(stage %in% c('preflight','confirmation'),length(cells)>0L,
    all(cells %in% 1:8),!anyDuplicated(cells))
  population_coverage_self_check()
  dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  paths <- c(list.files('R',pattern='[.]R$',full.names=TRUE),paste0('inst/validation/',
    c('mml-independent-rsm-information-0.2.4.R','mml-independent-information-conditions-0.2.4.R',
      'mml-structural-coverage-0.2.4.R','numerical-stationarity-pilot-0.2.3.R',
      'population-coverage-0.2.4.R','population-coverage-protocol-0.2.4.md')))
  payload <- tools::md5sum(paths)
  snapshot <- setNames(lapply(paths,readLines),paths)
  n <- if(stage=='preflight') 5L else 10000L
  plan <- mml_coverage_cells(); started <- proc.time()[['elapsed']]
  for(id in cells) {
    cell <- plan[id,]; path <- file.path(directory,sprintf('cell-%02d.rds',id))
    state <- list(Cell=cell,Stage=stage,Planned=n,Payload=payload,Source=snapshot,
      Results=list(),Session=sessionInfo(),Started=Sys.time())
    if(file.exists(path)) {
      state <- readRDS(path)
      stopifnot(identical(state$Cell,cell),identical(state$Stage,stage),
        identical(state$Planned,n),identical(state$Payload,payload))
    }
    checkpoint <- function() {
      stopifnot(identical(payload,tools::md5sum(paths)))
      state$CheckpointTime <- Sys.time()
      saveRDS(state,paste0(path,'.tmp'),compress=FALSE)
      stopifnot(file.rename(paste0(path,'.tmp'),path))
    }
    done <- length(state$Results)
    if(done>=n) next
    for(rep in seq.int(done+1L,n)) {
      state$Results[[rep]] <- population_coverage_one(cell,rep,stage)
      if(rep %% 50L==0L || stage=='preflight' || rep==n) {
        checkpoint(); recent <- tail(state$Results,min(50L,rep))
        cat(stage,'cell',id,rep,'/',n,'mean seconds',mean(vapply(recent,`[[`,numeric(1),'Seconds')),
          'unavailable',sum(vapply(recent,function(x) !all(x$Available),logical(1))),
          'conflicts',sum(vapply(recent,`[[`,logical(1),'NumericalConflict')),'\n');flush.console()
      }
      if(proc.time()[['elapsed']]-started>4*3600) {
        checkpoint(); stop('Resource ceiling reached; incomplete',call.=FALSE)
      }
    }
  }
  invisible(TRUE)
}

population_coverage_summarize <- function(directory) {
  states <- lapply(1:8,function(id) readRDS(file.path(directory,sprintf('cell-%02d.rds',id))))
  stopifnot(all(vapply(states,function(s) identical(s$Payload,states[[1]]$Payload) &&
    identical(s$Stage,states[[1]]$Stage) && identical(s$Planned,states[[1]]$Planned),logical(1))))
  summary <- do.call(rbind,lapply(states,function(s) data.frame(s$Cell,
    population_coverage_summary(s$Results,s$Planned,s$Stage),row.names=NULL)))
  runs <- do.call(rbind,lapply(states,function(s) {
    r <- s$Results
    cbind(s$Cell,Stage=s$Stage,Assigned=s$Planned,Attempted=length(r),
      NativePass=sum(vapply(r,`[[`,logical(1),'NativePass')),
      InferenceReady=sum(vapply(r,`[[`,logical(1),'InferenceReady')),
      ScoringReady=sum(vapply(r,`[[`,logical(1),'ScoringReady')),
      Computable=sum(vapply(r,function(x) all(x$Available),logical(1))),
      NumericalConflicts=sum(vapply(r,`[[`,logical(1),'NumericalConflict')),
      Errors=sum(vapply(r,function(x) nzchar(x$Error),logical(1))),
      Warnings=sum(vapply(r,function(x) length(x$Warnings),integer(1))),
      CoreSeconds=sum(vapply(r,`[[`,numeric(1),'CoreSeconds'),na.rm=TRUE),
      Seconds=sum(vapply(r,`[[`,numeric(1),'Seconds'))
    )
  }))
  write.csv(summary,file.path(directory,'summary.csv'),row.names=FALSE)
  write.csv(runs,file.path(directory,'runs.csv'),row.names=FALSE)
  print(runs,row.names=FALSE)
  invisible(list(summary=summary,runs=runs))
}

population_coverage_refine <- function(directory) {
  rows <- gradients <- list()
  for(id in 1:8) {
    s <- readRDS(file.path(directory,sprintf('cell-%02d.rds',id)))
    stopifnot(s$Stage=='preflight',!is.null(s$Results[[1]]$Independent))
    if(all(s$Results[[1]]$Independent$Pass)) next
    r <- s$Results[[1]]; cell <- s$Cell
    x <- mml_information_fixture(cell$Model,'population',3L,r$Seed,cell$Persons,cell$Exposure)
    stopifnot(identical(x$data,r$Detail$data))
    p <- r$Parameters; context <- mfrmr_num_fit_context(r$Detail$fit)
    steps <- c(1e-4,5e-5,2.5e-5,1.25e-5)
    g <- vapply(steps,function(h) mfrmr_num_central_gradient(x$objective,p,h),numeric(length(p)))
    rows[[as.character(id)]] <- data.frame(Cell=id,RelativeStep=steps,
      ObjectiveDifference=abs(x$objective(p)-context$fn(p)),
      GradientStepDifference=c(NA_real_,vapply(2:4,function(j) max(abs(g[,j]-g[,j-1])),numeric(1))),
      GradientDifference=apply(abs(g-context$gr(p)),2,max),FullGradient=apply(abs(g),2,max))
    gradients[[as.character(id)]] <- g
  }
  result <- list(summary=do.call(rbind,rows),gradients=gradients,completed=Sys.time())
  saveRDS(result,file.path(directory,'refinement.rds'))
  result
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args) %in% 2:3)
  pkgload::load_all('.',quiet=TRUE)
  if(args[1]=='summarize') population_coverage_summarize(args[2]) else
    population_coverage_run(args[1],args[2],if(length(args)==3L)
      as.integer(strsplit(args[3],',',fixed=TRUE)[[1]]) else 1:8)
}
