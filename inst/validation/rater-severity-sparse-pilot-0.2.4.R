# Repository-only paired pilot. Run from package root with preflight, pilot or summarize.
pkgload::load_all('.',quiet=TRUE)
out <- 'validation-results/rater-severity-sparse-20260922'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
designs <- c('complete','cycle','weak_bridge')
truth <- setNames(c(-.8,-.4,-.1,.1,.4,.8),paste0('R',1:6))
targets <- c(names(truth),'PanelMeanDifference')
truth_all <- c(truth,PanelMeanDifference=mean(truth[1:3])-mean(truth[4:6]))

generate <- function(seed) {
  set.seed(seed)
  d <- expand.grid(Person=sprintf('P%03d',1:120),Rater=names(truth),
    Criterion=paste0('C',1:3),stringsAsFactors=FALSE)
  p <- match(d$Person,sprintf('P%03d',1:120)); r <- match(d$Rater,names(truth))
  theta <- rnorm(120)
  eta <- theta[p]-truth[r]-c(-.3,0,.3)[match(d$Criterion,paste0('C',1:3))]
  # Independent RSM generator, thresholds (-1,0,1), categories 0:3.
  logw <- cbind(0,eta+1,2*eta+1,3*eta)
  prob <- exp(logw-apply(logw,1,max)); prob <- prob/rowSums(prob)
  u <- runif(nrow(d))
  d$Score <- rowSums(u>t(apply(prob,1,cumsum)))
  first <- (p-1L) %% 6L+1L; second <- first %% 6L+1L
  cycle <- r==first | r==second
  # Alternate panels, cycle pairs within each panel; four fixed bridge Persons.
  panel <- (p-1L) %% 2L
  first <- ((p-1L) %/% 2L) %% 3L+1L
  second <- first %% 3L+1L
  first <- first+3L*panel; second <- second+3L*panel
  first[p<=4L] <- 3L; second[p<=4L] <- 4L
  weak <- r==first | r==second
  result <- list(complete=d,cycle=d[cycle,],weak_bridge=d[weak,])
  stopifnot(all(d$Score %in% 0:3),nrow(result$cycle)==720,nrow(result$weak_bridge)==720)
  result
}

one <- function(d,design,seed,public_check=FALSE) {
  started <- proc.time()[['elapsed']]
  res <- list(Design=design,Seed=seed,Rows=nrow(d),FitReady=FALSE,
    CovarianceStatus='not_computed',NumericalOK=FALSE,Error='',Warnings=character(),
    Estimate=setNames(rep(NA_real_,7),targets),SE=setNames(rep(NA_real_,7),targets),
    Available=setNames(rep(FALSE,7),targets))
  f <- NULL
  error <- tryCatch(withCallingHandlers({
    f <- fit_mfrm(d,'Person',c('Rater','Criterion'),'Score',model='RSM',method='MML',
      rating_min=0,rating_max=3,quad_points=61,maxit=400,reltol=1e-10,mml_engine='direct')
    res$FitReady <- isTRUE(f$summary$InferenceReady)
    res$FitReadiness <- f$summary$FitReadiness
    res$Gradient <- f$summary$TerminalGradientSupNorm
    res$Readiness <- f$readiness
    cov <- compute_mml_parameter_covariance(f)
    res$CovarianceStatus <- cov$status
    slices <- build_param_slices(build_param_sizes(f$config))
    stopifnot(identical(as.character(f$config$facet_levels$Rater),names(truth)))
    map <- matrix(0,6,length(f$opt$par))
    map[,slices$Rater] <- rbind(diag(5),rep(-1,5))
    map <- rbind(map,colMeans(map[1:3,,drop=FALSE])-colMeans(map[4:6,,drop=FALSE]))
    res$Estimate <- setNames(as.vector(map %*% f$opt$par),targets)
    if(cov$status!='ok') stop('Unregularized covariance unavailable')
    res$SE <- setNames(sqrt(diag(map %*% cov$cov %*% t(map))),targets)
    res$Available <- res$FitReady & is.finite(res$SE) & res$SE>0 & is.finite(res$Estimate)
    facet_se <- compute_mml_facet_model_se(f,cov)$table
    at <- match(names(truth),facet_se$Level[facet_se$Facet=='Rater'])
    stopifnot(max(abs(res$SE[1:6]-facet_se$ModelSE[facet_se$Facet=='Rater'][at]))<1e-10)
    high <- f; high$config$estimation_control$quad_points <- 121L
    hc <- compute_mml_parameter_covariance(high)
    if(hc$status!='ok') stop('q121 unregularized covariance unavailable')
    idx <- build_indices(f$prep,step_facet=f$config$step_facet)
    quad <- gauss_hermite_normal(121)
    grad <- mfrm_grad_mml(f$opt$par,idx,f$config,cov$sizes,quad)
    res$ObjectiveChange <- mfrm_loglik_mml(f$opt$par,idx,f$config,cov$sizes,quad)-f$opt$value
    res$RelativeSEChange <- max(abs(sqrt(diag(map %*% hc$cov %*% t(map)))/res$SE-1))
    res$NewtonInSEUnits <- max(abs(hc$cov %*% grad)/sqrt(diag(cov$cov)))
    res$NumericalOK <- res$RelativeSEChange<=.001 && res$NewtonInSEUnits<=.001
    # Unavailable/numerically discordant outputs are retained, never replaced.
    if(public_check) {
      dx <- diagnose_mfrm(f,residual_pca='none')
      plot <- plot_rater_severity_profile(f,diagnostics=dx,facet='Rater',show_bands=FALSE,draw=FALSE)
      tab <- plot$data$data; at <- match(names(truth),tab$Level)
      stopifnot(!anyNA(at),max(abs(tab$Estimate[at]-res$Estimate[1:6]))<1e-10,
        max(abs(tab$SE[at]-res$SE[1:6]))<1e-10,
        max(abs(tab$CI_Lower[at]-(res$Estimate[1:6]-qnorm(.975)*res$SE[1:6])))<1e-10)
      res$PublicIntervalCheck <- TRUE
    }
    NULL
  },warning=function(w) {res$Warnings <<- c(res$Warnings,conditionMessage(w));invokeRestart('muffleWarning')}),error=identity)
  if(inherits(error,'error')) res$Error <- conditionMessage(error)
  if(public_check || nzchar(res$Error) || !res$NumericalOK || !res$FitReady) {
    saveRDS(list(fit=f,data=d),file.path(out,paste0('detail-',seed,'-',design,'.rds')))
  }
  res$Seconds <- proc.time()[['elapsed']]-started
  res
}

run <- function(stage) {
  seeds <- if(stage=='preflight') 202609220L else 202610001:202610040
  files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
    'inst/validation/rater-severity-sparse-pilot-0.2.4.R')
  hashes <- tools::md5sum(files)
  writeLines(capture.output(sessionInfo()),file.path(out,'session-info.txt'))
  start <- proc.time()[['elapsed']]
  for(seed in seeds) {
    datasets <- generate(seed)
    for(design in designs) {
      path <- file.path(out,paste0(stage,'-',seed,'-',design,'.rds'))
      if(file.exists(path)) {stopifnot(identical(readRDS(path)$Hashes,hashes));next}
      res <- one(datasets[[design]],design,seed,stage=='preflight')
      res$Hashes <- hashes
      saveRDS(res,path)
      cat(stage,seed,design,'ready',res$FitReady,'numerical',res$NumericalOK,
        'seconds',round(res$Seconds,2),'error',res$Error,'\n');flush.console()
      if(stage=='preflight' && (nzchar(res$Error) || !res$NumericalOK || !res$FitReady)) stop('Preflight requires review')
      if(proc.time()[['elapsed']]-start>900) stop('15-minute process budget reached; retain incomplete attempts')
    }
  }
}

summarize <- function() {
  paths <- list.files(out,pattern='^pilot-[0-9]+-.*[.]rds$',full.names=TRUE)
  results <- lapply(paths,readRDS)
  stopifnot(length(results)>0)
  intervals <- function(n,k) if(n) binom.test(k,n)$conf.int else c(NA_real_,NA_real_)
  detail <- do.call(rbind,lapply(results,function(x) {
    e <- x$Estimate-truth_all; z <- qnorm(.975)
    data.frame(Design=x$Design,Seed=x$Seed,Target=targets,Truth=truth_all,
      Estimate=x$Estimate,Error=e,SE=x$SE,Available=x$Available,
      Covered=x$Available & abs(e)<=z*x$SE,LowerMiss=x$Available & e>z*x$SE,
      UpperMiss=x$Available & e< -z*x$SE,Width=2*z*x$SE,
      FitReady=x$FitReady,NumericalOK=x$NumericalOK,Failure=x$Error)
  }))
  summary <- do.call(rbind,lapply(split(detail,list(detail$Design,detail$Target),drop=TRUE),function(x) {
    n <- nrow(x); a <- sum(x$Available); k <- sum(x$Covered,na.rm=TRUE)
    ci <- intervals(a,k); aci <- intervals(n,a)
    e <- x$Error[is.finite(x$Error)]; ok <- x$Available
    p <- if(a) k/a else NA_real_
    data.frame(Design=x$Design[1],Target=x$Target[1],Attempts=n,Available=a,
      Availability=a/n,AvailabilityLower=aci[1],AvailabilityUpper=aci[2],
      Coverage=p,CoverageMCSE=if(a) sqrt(p*(1-p)/a) else NA_real_,
      CoverageLower=ci[1],CoverageUpper=ci[2],AvailableAndCovered=k/n,
      LowerMiss=if(a) sum(x$LowerMiss,na.rm=TRUE)/a else NA_real_,
      UpperMiss=if(a) sum(x$UpperMiss,na.rm=TRUE)/a else NA_real_,
      FiniteEstimates=length(e),Bias=mean(e),BiasMCSE=sd(e)/sqrt(length(e)),RMSE=sqrt(mean(e^2)),
      MeanWidth=mean(x$Width[ok]),EmpiricalSD=sd(x$Error[ok]),RMSSE=sqrt(mean(x$SE[ok]^2)),
      NumericalConflicts=sum(x$FitReady & !x$NumericalOK))
  }))
  write.csv(detail,file.path(out,'intervals.csv'),row.names=FALSE)
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  run_rows <- do.call(rbind,lapply(results,function(x) data.frame(Design=x$Design,Seed=x$Seed,
    Rows=x$Rows,FitReady=x$FitReady,CovarianceStatus=x$CovarianceStatus,NumericalOK=x$NumericalOK,
    ObjectiveChange=x$ObjectiveChange %||% NA_real_,RelativeSEChange=x$RelativeSEChange %||% NA_real_,
    NewtonInSEUnits=x$NewtonInSEUnits %||% NA_real_,Seconds=x$Seconds,
    Error=x$Error,Warnings=paste(x$Warnings,collapse=' | '))))
  write.csv(run_rows,file.path(out,'runs.csv'),row.names=FALSE)
  print(summary[,c('Design','Target','Attempts','Available','Coverage','CoverageLower','CoverageUpper','Bias','MeanWidth')],row.names=FALSE)
}
action <- commandArgs(trailingOnly=TRUE)[1]
if(action %in% c('preflight','pilot')) run(action) else if(action=='summarize') summarize() else stop('Use preflight, pilot or summarize')
