# Repository-only execution of mml-structural-coverage-protocol-0.2.4.md.
# Rscript inst/validation/mml-structural-coverage-0.2.4.R preflight /tmp/mml-preflight
# Rscript inst/validation/mml-structural-coverage-0.2.4.R confirmation /tmp/mml-coverage 1,4,7
# Rscript inst/validation/mml-structural-coverage-0.2.4.R summarize /tmp/mml-coverage
source('inst/validation/mml-independent-information-conditions-0.2.4.R')

mml_coverage_cells <- function() {
  data.frame(Cell=1:8,Model=rep(c('RSM','PCM'),each=4),
    Persons=rep(c(80L,80L,320L,320L),2),Exposure=rep(c(3L,6L),4))
}

mml_coverage_one <- function(cell,replicate,stage) {
  seed <- (if(stage=='preflight') 51000000L else 61000000L)+10000L*cell$Cell+replicate
  started <- proc.time()[['elapsed']]
  x <- mml_information_fixture(cell$Model,'baseline',3L,seed,cell$Persons,cell$Exposure)
  stopifnot(all(table(x$data$Person)==cell$Exposure),nrow(x$data)==cell$Persons*cell$Exposure,
            all(table(x$data$Rater,x$data$Criterion)>0L),all(x$data$Weight==1))
  pairs <- rbind(x$facet_map[1,]-x$facet_map[2,],x$facet_map[1,]-x$facet_map[3,],
                 x$facet_map[2,]-x$facet_map[3,],x$facet_map[4,]-x$facet_map[5,])
  rownames(pairs) <- c('Rater:R1-R2','Rater:R1-R3','Rater:R2-R3','Criterion:C1-C2')
  map <- rbind(x$facet_map,x$step_map,pairs)
  truth <- setNames(as.vector(map %*% x$truth),rownames(map))
  empty <- setNames(rep(NA_real_,length(truth)),names(truth))
  out <- list(Replicate=replicate,Seed=seed,Truth=truth,Estimate=empty,SE=empty,
    Available=setNames(rep(FALSE,length(truth)),names(truth)),FitReady=FALSE,
    CovarianceStatus='not_computed',HighCovarianceStatus='not_computed',
    NumericalOK=FALSE,ReadyNumericalConflict=FALSE,ObjectiveChange=NA_real_,
    RelativeSEChange=NA_real_,ScaledNewtonDisplacement=NA_real_,
    Error='',Warnings=character(),Seconds=NA_real_)
  fit <- NULL
  error <- tryCatch(withCallingHandlers({
    fit <- fit_mfrm(x$data,'Person',c('Rater','Criterion'),'Score',model=cell$Model,
      step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,method='MML',
      rating_min=0,rating_max=2,quad_points=61L,maxit=200L,reltol=1e-10)
    out$FitReady <- mfrmr:::mfrm_inference_ready(fit)
    out$ReadinessReasons <- fit$readiness$fit$ReasonCodes
    out$Estimate <- setNames(as.vector(map %*% fit$opt$par),names(truth))
    cov <- mfrmr:::compute_mml_parameter_covariance(fit)
    out$CovarianceStatus <- cov$status
    if(!identical(cov$status,'ok')) stop('q61 covariance is not unregularized',call.=FALSE)
    facet_se <- mfrmr:::compute_mml_facet_model_se(fit,covariance=cov)$table
    at <- match(rownames(x$facet_map),paste(facet_se$Facet,facet_se$Level,sep=':'))
    steps <- mfrmr:::compute_mml_structural_parameter_se(fit,covariance=cov)$steps
    out$SE <- setNames(c(facet_se$ModelSE[at],steps$SE,
      sqrt(diag(pairs %*% cov$cov %*% t(pairs)))),names(truth))
    stopifnot(!anyNA(at),length(out$SE)==length(truth),
      max(abs(out$SE-sqrt(diag(map %*% cov$cov %*% t(map)))))<1e-10)
    out$Available <- out$FitReady & is.finite(out$Estimate) & is.finite(out$SE) & out$SE>0
    high <- fit; high$config$estimation_control$quad_points <- 121L
    high_cov <- mfrmr:::compute_mml_parameter_covariance(high)
    out$HighCovarianceStatus <- high_cov$status
    if(!identical(high_cov$status,'ok')) stop('q121 covariance is not unregularized',call.=FALSE)
    idx <- mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet)
    quad <- mfrmr:::gauss_hermite_normal(121L)
    value <- mfrmr:::mfrm_loglik_mml(fit$opt$par,idx,fit$config,cov$sizes,quad)
    score <- mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,cov$sizes,quad)
    out$ObjectiveChange <- abs(value-fit$opt$value)
    out$RelativeSEChange <- max(abs(sqrt(diag(map %*% high_cov$cov %*% t(map)))/out$SE-1))
    out$ScaledNewtonDisplacement <- max(abs(high_cov$cov %*% score)/sqrt(diag(cov$cov)))
    out$NumericalOK <- isTRUE(out$ObjectiveChange<=1e-6 && out$RelativeSEChange<=0.001 &&
                               out$ScaledNewtonDisplacement<=0.001)
    out$CoreSeconds <- proc.time()[['elapsed']]-started
    if(stage=='preflight') {
      diagnostic <- diagnose_mfrm(fit,residual_pca='none')
      at <- match(rownames(x$facet_map),paste(diagnostic$measures$Facet,diagnostic$measures$Level,sep=':'))
      public_se <- c(diagnostic$measures$SE[at],diagnostic$parameter_uncertainty$steps$SE)
      stopifnot(max(abs(public_se-out$SE[seq_along(public_se)]))<1e-10,
        identical(isTRUE(diagnostic$precision_profile$SupportsFormalInference),out$FitReady))
      if(out$FitReady) {
        eq <- analyze_facet_equivalence(fit,facet='Rater')
        at <- match(c('R1 R2','R1 R3','R2 R3'),paste(eq$pairwise$ElementA,eq$pairwise$ElementB))
        stopifnot(max(abs(eq$pairwise$SE_Diff[at]-tail(out$SE,4)[1:3]))<1e-10)
        eq <- analyze_facet_equivalence(fit,facet='Criterion')
        stopifnot(abs(eq$pairwise$SE_Diff-tail(out$SE,1))<1e-10)
      }
    }
    NULL
  },warning=function(w) {
    out$Warnings <<- c(out$Warnings,conditionMessage(w)); invokeRestart('muffleWarning')
  }),error=identity)
  if(inherits(error,'error')) out$Error <- conditionMessage(error)
  out$ReadyNumericalConflict <- out$FitReady && !out$NumericalOK
  out$Seconds <- proc.time()[['elapsed']]-started
  if(nzchar(out$Error) || out$ReadyNumericalConflict) {
    out$FailureDetail <- list(fit=fit,data=x$data)
  }
  out
}

mml_coverage_run <- function(stage,directory,cells=1:8) {
  stopifnot(stage %in% c('preflight','confirmation'),all(cells %in% 1:8),!anyDuplicated(cells))
  mml_coverage_self_check()
  dir.create(directory,recursive=TRUE,showWarnings=FALSE)
  files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
    paste0('inst/validation/',c('mml-independent-rsm-information-0.2.4.R',
      'mml-independent-information-conditions-0.2.4.R','mml-structural-coverage-0.2.4.R',
      'mml-structural-coverage-protocol-0.2.4.md')))
  payload <- tools::md5sum(files)
  n <- if(stage=='preflight') 5L else 2500L
  plan <- mml_coverage_cells()
  started <- proc.time()[['elapsed']]
  for(id in cells) {
    cell <- plan[id,]; path <- file.path(directory,sprintf('cell-%02d.rds',id))
    state <- list(Cell=cell,Stage=stage,Planned=n,Payload=payload,Results=list(),Session=sessionInfo())
    if(file.exists(path)) {
      state <- readRDS(path)
      stopifnot(identical(state$Cell,cell),identical(state$Stage,stage),
        identical(state$Planned,n),identical(state$Payload,payload))
    }
    checkpoint <- function() {
      saveRDS(state,paste0(path,'.tmp'),compress=FALSE)
      stopifnot(file.rename(paste0(path,'.tmp'),path))
    }
    done <- length(state$Results)
    if(done>=n) next
    for(rep in seq.int(done+1L,n)) {
      state$Results[[rep]] <- mml_coverage_one(cell,rep,stage)
      if(rep %% 50L==0L || stage=='preflight' || rep==n) {
        checkpoint()
        recent <- tail(state$Results,min(50L,rep))
        cat(sprintf('%s cell %d: %d/%d; mean %.3fs; errors %d; numerical conflicts %d\n',
          stage,id,rep,n,mean(vapply(recent,`[[`,numeric(1),'Seconds')),
          sum(vapply(recent,function(x) nzchar(x$Error),logical(1))),
          sum(vapply(recent,`[[`,logical(1),'ReadyNumericalConflict'))))
        flush.console()
      }
      if(proc.time()[['elapsed']]-started>4*3600) {
        checkpoint(); stop('Resource ceiling reached; results are incomplete',call.=FALSE)
      }
    }
  }
  invisible(TRUE)
}

mml_coverage_binomial <- function(success,n) {
  if(n==0L) return(c(Estimate=NA_real_,Lower=NA_real_,Upper=NA_real_))
  c(Estimate=success/n,setNames(unname(binom.test(success,n)$conf.int),c('Lower','Upper')))
}

mml_coverage_range <- function(lower,upper,acceptable) {
  if(!all(is.finite(c(lower,upper)))) return('review')
  if(lower>=acceptable[1] && upper<=acceptable[2]) return('supported')
  if(upper<acceptable[1] || lower>acceptable[2]) 'concern' else 'review'
}

mml_coverage_coordinate <- function(error,se,available,conflict,planned) {
  n <- length(error); finite <- is.finite(error)
  a <- mml_coverage_binomial(sum(available),n)
  d <- error[available]; s <- se[available]; m <- length(d)
  covered <- abs(d)<=qnorm(0.975)*s
  coverage <- mml_coverage_binomial(sum(covered),m)
  f <- mml_coverage_binomial(sum(conflict),n)
  out <- c(Assigned=planned,Attempted=n,FiniteEstimates=sum(finite),Available=m,
    BiasAll=if(any(finite)) mean(error[finite]) else NA_real_,
    MCSEBiasAll=mfrmr:::simulation_mcse_mean(error[finite]),
    RMSEAll=if(any(finite)) sqrt(mean(error[finite]^2)) else NA_real_,
    MCSERMSEAll=mfrmr:::recovery_mcse_rmse(error[finite]),
    Availability=a[1],AvailabilityLower=a[2],AvailabilityUpper=a[3],
    Coverage=coverage[1],CoverageLower=coverage[2],CoverageUpper=coverage[3],
    CoverageMCSE=if(m) sqrt(mean(covered)*(1-mean(covered))/m) else NA_real_,
    AvailableAndCoveredPerAssigned=sum(covered)/planned,
    ReadyNumericalConflicts=sum(conflict),ConflictRate=f[1],ConflictLower=f[2],ConflictUpper=f[3])
  names(out) <- sub('[.](Estimate|Lower|Upper)$','',names(out))
  if(m>1L && sd(d)>0) {
    bias <- mean(d); v <- var(d); sd_error <- sqrt(v); ms <- mean(s^2)
    ratio <- sqrt(ms/v); standardized <- bias/sd_error
    ratio_if <- ratio/2*((s^2-ms)/ms-((d-bias)^2-v)/v)
    bias_if <- (d-bias)/sd_error-bias*((d-bias)^2-v)/(2*sd_error^3)
    ratio_mc <- mfrmr:::simulation_mcse_mean(ratio_if)
    bias_mc <- mfrmr:::simulation_mcse_mean(bias_if)
    z <- qnorm(0.975)
    out <- c(out,BiasAvailable=bias,EmpiricalSD=sd_error,MeanSE=mean(s),RMSSE=sqrt(ms),
      MeanWidth=mean(2*z*s),StandardizedBias=standardized,StandardizedBiasMCSE=bias_mc,
      BiasLower=standardized-z*bias_mc,BiasUpper=standardized+z*bias_mc,
      SERatio=ratio,SERatioMCSE=ratio_mc,RatioLower=ratio-z*ratio_mc,RatioUpper=ratio+z*ratio_mc,
      ErrorSkewness=mean(((d-bias)/sd_error)^3),MaxAbsoluteStandardizedError=max(abs(d))/sd_error)
  } else {
    extra <- c('BiasAvailable','EmpiricalSD','MeanSE','RMSSE','MeanWidth','StandardizedBias',
      'StandardizedBiasMCSE','BiasLower','BiasUpper','SERatio','SERatioMCSE','RatioLower',
      'RatioUpper','ErrorSkewness','MaxAbsoluteStandardizedError')
    out <- c(out,setNames(rep(NA_real_,length(extra)),extra))
  }
  states <- c(Coverage=mml_coverage_range(out['CoverageLower'],out['CoverageUpper'],c(0.93,0.97)),
    SE=mml_coverage_range(out['RatioLower'],out['RatioUpper'],c(0.9,1.1)),
    Bias=mml_coverage_range(out['BiasLower'],out['BiasUpper'],c(-0.1,0.1)),
    Availability=mml_coverage_range(out['AvailabilityLower'],out['AvailabilityUpper'],c(0.99,1)),
    Numerical=if(any(conflict)) 'concern' else mml_coverage_range(out['ConflictLower'],out['ConflictUpper'],c(0,0.002)))
  overall <- if(n<planned) 'incomplete' else if(any(states=='concern')) 'concern' else
    if(all(states=='supported')) 'supported' else 'review'
  data.frame(as.list(out),as.list(setNames(states,paste0(names(states),'Status'))),Disposition=overall)
}

mml_coverage_self_check <- function() {
  n <- 2500L; e <- qnorm((seq_len(n)-0.5)/n); se <- rep(1,n)
  available <- rep(TRUE,n); conflict <- rep(FALSE,n)
  # Known normal errors with correct, too-small, and too-large reported SEs.
  good <- mml_coverage_coordinate(e,se,available,conflict,n)
  stopifnot(good$Disposition=='supported',good$ConflictUpper>0,
    mml_coverage_coordinate(e,se*0.7,available,conflict,n)$Disposition=='concern',
    mml_coverage_coordinate(e,se*1.3,available,conflict,n)$Disposition=='concern',
    mml_coverage_coordinate(e+0.5,se,available,conflict,n)$Disposition=='concern',
    mml_coverage_coordinate(rep(NA_real_,n),se,!available,conflict,n)$Disposition=='concern',
    mml_coverage_coordinate(e,se,available,c(TRUE,conflict[-1]),n)$Disposition=='concern',
    mml_coverage_coordinate(e[1:100],se[1:100],available[1:100],conflict[1:100],n)$Disposition=='incomplete')
  invisible(TRUE)
}

mml_coverage_summarize <- function(directory) {
  rows <- list(); run_rows <- list()
  for(id in 1:8) {
    path <- file.path(directory,sprintf('cell-%02d.rds',id))
    if(!file.exists(path)) next
    state <- readRDS(path); results <- state$Results
    if(!length(results)) next
    coordinates <- names(results[[1]]$Truth)
    stopifnot(!anyDuplicated(vapply(results,`[[`,integer(1),'Seed')),
      all(vapply(results,function(x) identical(x$Truth,results[[1]]$Truth),logical(1))))
    for(coordinate in coordinates) {
      error <- vapply(results,function(x) x$Estimate[coordinate]-x$Truth[coordinate],numeric(1))
      se <- vapply(results,function(x) x$SE[coordinate],numeric(1))
      available <- vapply(results,function(x) isTRUE(x$Available[coordinate]),logical(1))
      conflict <- vapply(results,`[[`,logical(1),'ReadyNumericalConflict')
      summary <- mml_coverage_coordinate(error,se,available,conflict,state$Planned)
      if(state$Stage=='preflight') summary$Disposition <- 'preflight_only'
      rows[[length(rows)+1L]] <- cbind(state$Cell,Coordinate=coordinate,summary)
    }
    run_rows[[length(run_rows)+1L]] <- cbind(state$Cell,Stage=state$Stage,Planned=state$Planned,
      Attempted=length(results),Errors=sum(vapply(results,function(x) nzchar(x$Error),logical(1))),
      Warnings=sum(vapply(results,function(x) length(x$Warnings),integer(1))),
      Ready=sum(vapply(results,`[[`,logical(1),'FitReady')),
      NumericalConflicts=sum(vapply(results,`[[`,logical(1),'ReadyNumericalConflict')),
      Seconds=sum(vapply(results,`[[`,numeric(1),'Seconds')))
  }
  summary <- do.call(rbind,rows); runs <- do.call(rbind,run_rows)
  write.csv(summary,file.path(directory,'summary.csv'),row.names=FALSE)
  write.csv(runs,file.path(directory,'runs.csv'),row.names=FALSE)
  print(runs,row.names=FALSE)
  if(nrow(summary)) print(table(summary$Disposition))
  invisible(list(summary=summary,runs=runs))
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args) %in% 2:3)
  pkgload::load_all('.',quiet=TRUE)
  if(args[1]=='summarize') mml_coverage_summarize(args[2]) else {
    cells <- if(length(args)==3L) as.integer(strsplit(args[3],',',fixed=TRUE)[[1]]) else 1:8
    mml_coverage_run(args[1],args[2],cells)
  }
}
