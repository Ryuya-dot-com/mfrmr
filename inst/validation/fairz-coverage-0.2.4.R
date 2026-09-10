# Repository-only confirmation; see fairz-coverage-protocol-0.2.4.md.
# Rscript inst/validation/fairz-coverage-0.2.4.R preflight /tmp/fairz-study
# Rscript inst/validation/fairz-coverage-0.2.4.R summarize /tmp/fairz-study/preflight
# Rscript inst/validation/fairz-coverage-0.2.4.R confirmation /tmp/fairz-study 1,4,7
source('inst/validation/mml-structural-coverage-0.2.4.R')
# Load the existing oracle alone, without executing its archived pilot.
for(expr in parse('inst/validation/fair-score-refit-0.2.4.R'))
  if(is.call(expr) && identical(expr[[1]],as.name('<-')) &&
     identical(expr[[2]],as.name('fair_reference'))) eval(expr)

fairz_coverage_payload <- function() tools::md5sum(c(
  list.files('R','[.]R$',full.names=TRUE),
  list.files('src','[.](cpp|h|hpp|cc|c)$|^Makevars',full.names=TRUE),
  'DESCRIPTION','NAMESPACE',
  paste0('inst/validation/',c('fairz-coverage-0.2.4.R','fairz-coverage-protocol-0.2.4.md',
    'fair-score-refit-0.2.4.R','mml-structural-coverage-0.2.4.R',
    'mml-structural-coverage-protocol-0.2.4.md',
    'mml-independent-information-conditions-0.2.4.R','mml-independent-rsm-information-0.2.4.R'))))
fairz_coverage_backend <- function() {
  stopifnot(mfrmr:::mfrm_cpp11_backend_available(),isTRUE(getOption('mfrmr.use_cpp11_backend',TRUE)))
  dll <- getLoadedDLLs()[['mfrmr']][['path']]
  list(UseCPP11=TRUE,DLLMD5=unname(tools::md5sum(dll)),
       RVersion=as.character(getRversion()),Platform=R.version$platform)
}
fairz_coverage_n <- function(stage) {
  stopifnot(stage %in% c('preflight','confirmation'))
  if(stage=='preflight') 5L else 2500L
}
fairz_coverage_seed <- function(cell,replicate,stage)
  (if(stage=='preflight') 76000000L else 77000000L)+10000L*cell+replicate

fairz_coverage_intervals <- function(estimate,se,ready) {
  estimate <- matrix(estimate,nrow(se),ncol(se),dimnames=dimnames(se))
  available <- ready & is.finite(estimate) & estimate>=0 & estimate<=2 & is.finite(se) & se>0
  lower <- estimate-qnorm(.975)*se; upper <- estimate+qnorm(.975)*se
  lower[!available] <- upper[!available] <- NA_real_
  list(Available=available,UnclippedLower=lower,UnclippedUpper=upper,
       Lower=pmax(lower,0),Upper=pmin(upper,2))
}
fairz_coverage_se <- function(values,x,covariance) {
  g <- do.call(rbind,lapply(values,`[[`,'gradient'))
  stopifnot(all(is.finite(g)))
  cbind(joint_structural_candidate=sqrt(diag(g%*%covariance%*%t(g))),
    conditional_measure=vapply(values,`[[`,numeric(1),'variance') *
      sqrt(diag(x$facet_map%*%covariance%*%t(x$facet_map))))
}

fairz_coverage_one <- function(cell,replicate,stage) {
  started <- proc.time()[['elapsed']]
  targets <- c(paste0('Rater:R',1:3),'Criterion:C1','Criterion:C2')
  empty <- setNames(rep(NA_real_,5L),targets)
  se <- matrix(NA_real_,5L,2L,dimnames=list(targets,c('joint_structural_candidate','conditional_measure')))
  out <- c(list(Replicate=replicate,Seed=fairz_coverage_seed(cell$Cell,replicate,stage),
    Truth=empty,Estimate=empty,SE=se,FairCIEligible=FALSE,FitReady=FALSE,
    ReadinessReasons='',CovarianceStatus='not_computed',HighCovarianceStatus='not_computed',
    NumericalOK=FALSE,VerificationOK=FALSE,ObjectiveChange=NA_real_,RelativeSEChange=NA_real_,
    ScaledNewtonDisplacement=NA_real_,Error='',Warnings=character(),
    GenerationSeconds=NA_real_,FitSeconds=NA_real_,ScoreCovarianceSeconds=NA_real_,
    HighEvaluationSeconds=NA_real_,CoreSeconds=NA_real_,VerificationSeconds=0),
    fairz_coverage_intervals(empty,se,FALSE))
  fit <- x <- NULL
  error <- tryCatch(withCallingHandlers({
    x <- mml_information_fixture(cell$Model,'baseline',3L,out$Seed,cell$Persons,cell$Exposure)
    stopifnot(nrow(x$data)==cell$Persons*cell$Exposure,all(table(x$data$Person)==cell$Exposure),
      all(x$data$Weight==1),all(table(x$data$Rater,x$data$Criterion)>0),
      max(abs(colSums(x$facet_map[1:3,,drop=FALSE])))==0,
      max(abs(colSums(x$facet_map[4:5,,drop=FALSE])))==0)
    values <- function(p) lapply(1:5,function(j) fair_reference(p,x,cell$Model,j))
    out$Truth <- setNames(vapply(values(x$truth),`[[`,numeric(1),'value'),targets)
    out$GenerationSeconds <- proc.time()[['elapsed']]-started
    timer <- proc.time()[['elapsed']]
    fit <- fit_mfrm(x$data,'Person',c('Rater','Criterion'),'Score',model=cell$Model,
      step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,method='MML',mml_engine='direct',
      rating_min=0,rating_max=2,quad_points=61L,maxit=200L,reltol=1e-10)
    out$FitSeconds <- proc.time()[['elapsed']]-timer
    timer <- proc.time()[['elapsed']]
    out$FitReady <- mfrmr:::mfrm_inference_ready(fit)
    out$ReadinessReasons <- fit$readiness$fit$ReasonCodes
    out$Parameters <- fit$opt$par
    actual <- values(fit$opt$par)
    out$Estimate <- setNames(vapply(actual,`[[`,numeric(1),'value'),targets)
    covariance <- mfrmr:::compute_mml_parameter_covariance(fit)
    out$CovarianceStatus <- covariance$status
    if(!identical(covariance$status,'ok')) stop('q61 covariance is not unregularized')
    chol(covariance$cov)
    sizes <- unlist(covariance$sizes); sizes <- sizes[sizes>0L]
    stopifnot(identical(names(sizes),names(x$sizes)),all(sizes==x$sizes))
    out$SE <- fairz_coverage_se(actual,x,covariance$cov); rownames(out$SE) <- targets
    interval <- fairz_coverage_intervals(out$Estimate,out$SE,out$FitReady)
    out[names(interval)] <- interval
    out$ScoreCovarianceSeconds <- proc.time()[['elapsed']]-timer
    timer <- proc.time()[['elapsed']]
    high <- fit; high$config$estimation_control$quad_points <- 121L
    hc <- mfrmr:::compute_mml_parameter_covariance(high)
    out$HighCovarianceStatus <- hc$status
    if(!identical(hc$status,'ok')) stop('q121 covariance is not unregularized')
    chol(hc$cov)
    idx <- mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet)
    quad <- mfrmr:::gauss_hermite_normal(121L)
    objective <- mfrmr:::mfrm_loglik_mml(fit$opt$par,idx,fit$config,covariance$sizes,quad)
    gradient <- mfrmr:::mfrm_grad_mml(fit$opt$par,idx,fit$config,covariance$sizes,quad)
    out$ObjectiveChange <- abs(objective-fit$opt$value)
    out$RelativeSEChange <- max(abs(fairz_coverage_se(actual,x,hc$cov)/out$SE-1))
    out$ScaledNewtonDisplacement <- max(abs(hc$cov%*%gradient)/sqrt(diag(covariance$cov)))
    out$NumericalOK <- isTRUE(out$ObjectiveChange<=1e-6 && out$RelativeSEChange<=.001 &&
      out$ScaledNewtonDisplacement<=.001)
    out$HighEvaluationSeconds <- proc.time()[['elapsed']]-timer
    out$CoreSeconds <- proc.time()[['elapsed']]-started
    out$VerificationOK <- TRUE
    if(stage=='preflight' && replicate==1L) {
      timer <- proc.time()[['elapsed']]; out$VerificationOK <- FALSE
      fa <- fair_average_table(fit,reference='zero')
      plot <- plot_fair_average(fit,facet=c('Rater','Criterion'),metric='FairZ',show_ci=TRUE,draw=FALSE)$data$data
      raw <- mfrmr:::stack_fair_raw_tables(fa$raw_by_facet)
      at <- match(targets,paste(raw$Facet,raw$Level,sep=':'))
      pat <- match(targets,paste(plot$Facet,plot$Level,sep=':'))
      out$TableError <- max(abs(raw$FairZ[at]-out$Estimate))
      out$ConditionalSEError <- max(abs(plot$CI_SE[pat]-out$SE[,'conditional_measure']))
      out$GradientError <- max(vapply(1:5,function(j) max(abs(actual[[j]]$gradient-
        mfrmr:::finite_difference_gradient(function(p) fair_reference(p,x,cell$Model,j)$value,fit$opt$par))),numeric(1)))
      refit <- fit_mfrm(x$data,'Person',c('Rater','Criterion'),'Score',model=cell$Model,
        step_facet=if(cell$Model=='PCM') 'Criterion' else NULL,method='MML',mml_engine='direct',
        rating_min=0,rating_max=2,quad_points=121L,maxit=200L,reltol=1e-10)
      rc <- mfrmr:::compute_mml_parameter_covariance(refit)
      rv <- values(refit$opt$par); re <- vapply(rv,`[[`,numeric(1),'value')
      rs <- fairz_coverage_se(rv,x,rc$cov); ri <- fairz_coverage_intervals(re,rs,TRUE)
      out$FullRefit <- c(ScoreChange=max(abs(re-out$Estimate)),RelativeSEChange=max(abs(rs/out$SE-1)),
        EndpointChange=max(abs(c(ri$Lower-out$Lower,ri$Upper-out$Upper))),
        ParameterChange=max(abs(refit$opt$par-fit$opt$par)),ObjectiveChange=abs(refit$opt$value-fit$opt$value),
        PersonEAPChange=max(abs(refit$facets$person$Estimate-fit$facets$person$Estimate)))
      out$VerificationOK <- isTRUE(out$TableError<1e-9 && out$ConditionalSEError<1e-8 &&
        out$GradientError<1e-7 && !any(plot$CI_Eligible) && mfrmr:::mfrm_inference_ready(refit) &&
        identical(rc$status,'ok') && out$FullRefit['ScoreChange']<=1e-5 &&
        out$FullRefit['EndpointChange']<=1e-5 && out$FullRefit['RelativeSEChange']<=.001)
      out$Refit <- refit
      out$VerificationSeconds <- proc.time()[['elapsed']]-timer
    }
    NULL
  },warning=function(w) {out$Warnings <<- c(out$Warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=identity)
  if(inherits(error,'error')) out$Error <- conditionMessage(error)
  out$ReadyNumericalConflict <- out$FitReady && !out$NumericalOK
  out$Seconds <- proc.time()[['elapsed']]-started
  if(!is.finite(out$CoreSeconds)) out$CoreSeconds <- out$Seconds
  if(stage=='preflight' || nzchar(out$Error) || !all(out$Available) || out$ReadyNumericalConflict)
    out$Detail <- list(fit=fit,data=x$data)
  out
}

fairz_coverage_validate <- function(state,cell,stage,payload) {
  stopifnot(identical(state$Cell,cell),identical(state$Stage,stage),
    identical(state$Planned,fairz_coverage_n(stage)),identical(state$Payload,payload),
    identical(state$Backend,fairz_coverage_backend()),length(state$Results)<=state$Planned)
  for(i in seq_along(state$Results)) {
    r <- state$Results[[i]]
    stopifnot(identical(r$Replicate,as.integer(i)),identical(r$Seed,fairz_coverage_seed(cell$Cell,i,stage)),
      length(r$Truth)==5L,identical(names(r$Truth),names(r$Estimate)),identical(r$FairCIEligible,FALSE))
    for(nm in c('SE','Available','Lower','Upper','UnclippedLower','UnclippedUpper'))
      stopifnot(identical(dim(r[[nm]]),c(5L,2L)),identical(rownames(r[[nm]]),names(r$Truth)),
        identical(colnames(r[[nm]]),c('joint_structural_candidate','conditional_measure')))
    stopifnot(!anyNA(r$Available),all(is.finite(r$Lower[r$Available])),
      all(is.finite(r$Upper[r$Available])))
  }
  invisible(TRUE)
}
fairz_coverage_preflight_ready <- function(directory,payload) {
  for(id in 1:8) {
    path <- file.path(directory,'preflight',sprintf('cell-%02d.rds',id))
    if(!file.exists(path)) return(FALSE)
    state <- readRDS(path)
    fairz_coverage_validate(state,mml_coverage_cells()[id,],'preflight',payload)
    if(length(state$Results)!=5L || !all(vapply(state$Results,function(r)
      !nzchar(r$Error) && r$FitReady && r$NumericalOK && r$VerificationOK && all(r$Available),logical(1)))) return(FALSE)
  }
  TRUE
}

fairz_coverage_run <- function(stage,directory,cells=1:8,max_seconds=4*3600) {
  n <- fairz_coverage_n(stage)
  stopifnot(length(cells)>0L,all(cells %in% 1:8),!anyDuplicated(cells),
    length(max_seconds)==1L,is.finite(max_seconds),max_seconds>=0)
  mml_coverage_self_check()
  payload <- fairz_coverage_payload(); backend <- fairz_coverage_backend()
  if(stage=='confirmation' && !fairz_coverage_preflight_ready(directory,payload))
    stop('Matching-source preflight is incomplete or failed; confirmation was not started.')
  root <- file.path(directory,stage); dir.create(root,recursive=TRUE,showWarnings=FALSE)
  snapshot <- setNames(lapply(names(payload),readLines),names(payload))
  started <- proc.time()[['elapsed']]
  run_cell <- function(id) {
    cell <- mml_coverage_cells()[id,]; path <- file.path(root,sprintf('cell-%02d.rds',id))
    lock <- paste0(path,'.lock')
    if(!dir.create(lock,showWarnings=FALSE)) stop('Cell already locked: ',lock)
    on.exit(unlink(lock,recursive=TRUE),add=TRUE)
    state <- if(file.exists(path)) readRDS(path) else list(Cell=cell,Stage=stage,Planned=n,
      Payload=payload,Backend=backend,Source=snapshot,Results=list(),Session=sessionInfo(),Started=Sys.time())
    fairz_coverage_validate(state,cell,stage,payload)
    checkpoint <- function() {
      stopifnot(identical(payload,fairz_coverage_payload()),identical(backend,fairz_coverage_backend()))
      state$CheckpointTime <- Sys.time()
      saveRDS(state,paste0(path,'.tmp'),compress=FALSE)
      stopifnot(file.rename(paste0(path,'.tmp'),path))
    }
    done <- length(state$Results)
    if(done>=n) return(TRUE)
    for(rep in seq.int(done+1L,n)) {
      state$Results[[rep]] <- fairz_coverage_one(cell,rep,stage)
      if(stage=='preflight' || rep %% 50L==0L || rep==n) {
        checkpoint()
        cat(stage,'cell',id,rep,'/',n,'seconds',round(state$Results[[rep]]$Seconds,3),
          'error:',state$Results[[rep]]$Error,'\n');flush.console()
      }
      if(proc.time()[['elapsed']]-started>=max_seconds) {checkpoint();return(FALSE)}
    }
    TRUE
  }
  for(id in cells) if(!run_cell(id)) {
    message('Resource ceiling reached; checkpoint saved, results remain incomplete.')
    return(invisible(FALSE))
  }
  invisible(TRUE)
}

fairz_coverage_summarize <- function(directory) {
  stage <- basename(normalizePath(directory)); n <- fairz_coverage_n(stage)
  payload <- fairz_coverage_payload(); rows <- runs <- paired <- list()
  target_names <- c(paste0('Rater:R',1:3),'Criterion:C1','Criterion:C2')
  methods <- c('joint_structural_candidate','conditional_measure')
  for(id in 1:8) {
    cell <- mml_coverage_cells()[id,]; path <- file.path(directory,sprintf('cell-%02d.rds',id))
    r <- list()
    if(file.exists(path)) {
      state <- readRDS(path); fairz_coverage_validate(state,cell,stage,payload); r <- state$Results
      truth <- Filter(function(x) all(is.finite(x$Truth)),r)
      stopifnot(!length(truth) || all(vapply(truth,function(x) identical(x$Truth,truth[[1]]$Truth),logical(1))))
    }
    conflict <- vapply(r,`[[`,logical(1),'ReadyNumericalConflict')
    for(target in target_names) for(method in methods) {
      errors <- vapply(r,function(x) x$Estimate[target]-x$Truth[target],numeric(1))
      se <- vapply(r,function(x) x$SE[target,method],numeric(1))
      available <- vapply(r,function(x) x$Available[target,method],logical(1))
      row <- mml_coverage_coordinate(errors,se,available,conflict,n)
      row$MeanUnclippedWidth <- row$MeanWidth
      row$MeanWidth <- if(any(available)) mean(vapply(r[available],function(x) x$Upper[target,method]-x$Lower[target,method],numeric(1))) else NA_real_
      row$Clipped <- sum(vapply(r,function(x) x$Available[target,method] &&
        (x$UnclippedLower[target,method]<0 || x$UnclippedUpper[target,method]>2),logical(1)))
      row$ClippingRate <- if(any(available)) row$Clipped/sum(available) else NA_real_
      row$Covered <- sum(vapply(r,function(x) x$Available[target,method] &&
        x$Lower[target,method]<=x$Truth[target] && x$Truth[target]<=x$Upper[target,method],logical(1)))
      stopifnot(row$Covered==sum(abs(errors[available])<=qnorm(.975)*se[available]))
      if(stage=='preflight') row$Disposition <- 'preflight_only'
      rows[[length(rows)+1L]] <- cbind(cell,Target=target,Method=method,
        Role=if(method==methods[1]) 'primary' else 'secondary',FairCIEligible=FALSE,row)
    }
    for(target in target_names) {
      both <- vapply(r,function(x) all(x$Available[target,]),logical(1))
      dc <- vapply(r[both],function(x) {
        covered <- x$Lower[target,]<=x$Truth[target] & x$Truth[target]<=x$Upper[target,]
        as.numeric(covered[1])-as.numeric(covered[2])
      },numeric(1))
      dw <- vapply(r[both],function(x) {
        width <- x$Upper[target,]-x$Lower[target,]; width[1]-width[2]
      },numeric(1))
      paired[[length(paired)+1L]] <- cbind(cell,Target=target,CommonAvailable=sum(both),
        CoverageDifference=if(length(dc)) mean(dc) else NA_real_,CoverageDifferenceMCSE=mfrmr:::simulation_mcse_mean(dc),
        WidthDifference=if(length(dw)) mean(dw) else NA_real_,WidthDifferenceMCSE=mfrmr:::simulation_mcse_mean(dw))
    }
    core <- vapply(r,`[[`,numeric(1),'CoreSeconds')
    runs[[id]] <- cbind(cell,Stage=stage,Assigned=n,Attempted=length(r),
      FitReady=sum(vapply(r,`[[`,logical(1),'FitReady')),NumericalConflicts=sum(conflict),
      Errors=sum(vapply(r,function(x) nzchar(x$Error),logical(1))),Warnings=sum(vapply(r,function(x) length(x$Warnings),integer(1))),
      VerificationFailures=sum(vapply(r,function(x) !x$VerificationOK,logical(1))),
      CoreSeconds=sum(core),MeanCoreSeconds=if(length(core)) mean(core) else NA_real_,
      MinCoreSeconds=if(length(core)) min(core) else NA_real_,MaxCoreSeconds=if(length(core)) max(core) else NA_real_,
      Seconds=sum(vapply(r,`[[`,numeric(1),'Seconds')))
  }
  summary <- do.call(rbind,rows); runs <- do.call(rbind,runs); paired <- do.call(rbind,paired)
  runs$PrimaryDisposition <- vapply(1:8,function(id) {
    d <- summary$Disposition[summary$Cell==id & summary$Role=='primary']
    if(stage=='preflight') 'preflight_only' else if(any(d=='incomplete')) 'incomplete' else
      if(any(d=='concern')) 'concern' else if(all(d=='supported')) 'supported' else 'review'
  },character(1))
  for(name in c('summary','runs','paired')) write.csv(get(name),file.path(directory,paste0(name,'.csv')),row.names=FALSE)
  print(runs,row.names=FALSE)
  invisible(list(summary=summary,runs=runs,paired=paired))
}

if(sys.nframe()==0L) {
  args <- commandArgs(TRUE); stopifnot(length(args) %in% 2:3)
  pkgload::load_all('.',quiet=TRUE)
  if(args[1]=='summarize') fairz_coverage_summarize(args[2]) else {
    cells <- if(length(args)==3L) as.integer(strsplit(args[3],',',fixed=TRUE)[[1]]) else 1:8
    fairz_coverage_run(args[1],args[2],cells)
  }
}
