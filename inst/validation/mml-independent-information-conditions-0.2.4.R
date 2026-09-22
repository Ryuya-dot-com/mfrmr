# Repository-only numerical checks; see the companion prespecified record.
# From package root: Rscript inst/validation/mml-independent-information-conditions-0.2.4.R /tmp/mml-information
source('inst/validation/mml-independent-rsm-information-0.2.4.R')

mml_information_fixture <- function(model, condition, categories, seed,
                                    n_person = 80L, exposure = 6L) {
  stopifnot(length(n_person)==1L,n_person>=1L,n_person==as.integer(n_person),
            length(exposure)==1L,exposure %in% c(3L,6L))
  set.seed(seed)
  d <- expand.grid(Person=sprintf('P%03d',seq_len(n_person)), Rater=paste0('R',1:3),
                   Criterion=c('C1','C2'), stringsAsFactors=FALSE)
  persons <- data.frame(Person=sprintf('P%03d',seq_len(n_person)), x=seq(-1,1,length.out=n_person))
  if(exposure==3L) {
    keep <- (match(d$Person,persons$Person)+match(d$Rater,paste0('R',1:3))) %% 2L ==
      match(d$Criterion,c('C1','C2'))-1L
    d <- d[keep,,drop=FALSE]
  }
  ri <- match(d$Rater,paste0('R',1:3)); ci <- match(d$Criterion,c('C1','C2'))
  pi <- match(d$Person,persons$Person)
  rmap <- rbind(c(1,0),c(0,1),c(-1,-1)); roffset <- numeric(3)
  rtruth <- c(0.3,-0.1)
  extra <- list()
  if(condition=='anchor') {
    rmap <- matrix(c(0,1,-1),3,1); roffset <- c(0.25,0,0); rtruth <- 0.2
    extra$anchors <- data.frame(Facet='Rater',Level='R1',Anchor=0.25)
  }
  if(condition=='group') {
    rmap <- matrix(c(1,-1,0),3,1); roffset <- c(0,0.2,0); rtruth <- 0.3
    extra$group_anchors <- data.frame(Facet='Rater',Level=c('R1','R2'),
                                      Group='G',GroupValue=0.1)
  }
  nstep <- categories-1L
  smap <- rbind(diag(nstep-1L),rep(-1,nstep-1L))
  smap <- if(model=='RSM') smap else kronecker(diag(2),smap)
  struth <- if(model=='RSM') -0.6 else if(categories==3L) c(-0.7,-0.2) else c(-0.8,0.1,-0.3,-0.2)
  sizes <- c(Rater=ncol(rmap),Criterion=1L,
             if(condition=='interaction') c(interactions=2L), steps=ncol(smap),
             if(condition=='population') c(beta=2L,log_sigma2=1L))
  slices <- split(seq_len(sum(sizes)),rep(names(sizes),sizes))
  n <- sum(sizes)
  facet_map <- matrix(0,5,n)
  facet_map[1:3,slices$Rater] <- rmap
  facet_map[4:5,slices$Criterion] <- c(1,-1)
  step_map <- matrix(0,nrow(smap),n); step_map[,slices$steps] <- smap
  rownames(facet_map) <- c(paste0('Rater:R',1:3),'Criterion:C1','Criterion:C2')
  rownames(step_map) <- paste0(if(model=='RSM') 'shared' else rep(c('C1','C2'),each=nstep),
                              ':Step_',rep(seq_len(nstep),if(model=='RSM') 1 else 2))
  shift_map <- -facet_map[ri,,drop=FALSE]-facet_map[3L+ci,,drop=FALSE]
  if(condition=='interaction') {
    shift_map[,slices$interactions] <- rbind(c(1,0),c(0,1),c(-1,-1))[ri,]*c(1,-1)[ci]
    extra$facet_interactions <- 'Rater:Criterion'
  }
  if(condition=='population') {
    extra$population_formula <- ~ x; extra$person_data <- persons
  }
  d$Weight <- if(condition=='weights') rep(c(0.5,1,1.5,2),length.out=nrow(d)) else 1
  if(condition=='weights') extra$weight <- 'Weight'
  truth <- c(rtruth,0.4,if(condition=='interaction') c(0.15,-0.1),struth,
             if(condition=='population') c(0.2,0.5,log(0.7)))
  # Explicit expanded-coordinate maps; no package constraint helper is used.
  log_probability <- function(z, ix, par) {
    eta <- outer(z,as.vector(shift_map[ix,,drop=FALSE] %*% par)-roffset[ri[ix]],'+')
    thresholds <- matrix(step_map %*% par,ncol=nstep,byrow=TRUE)
    cum <- t(apply(thresholds,1,cumsum))
    owners <- if(model=='RSM') rep(1L,length(ix)) else ci[ix]
    logits <- lapply(0:nstep,function(k) {
      if(k==0L) matrix(0,length(z),length(ix)) else sweep(k*eta,2,cum[owners,k],'-')
    })
    hi <- Reduce(pmax,logits)
    normalizer <- hi+log(Reduce('+',lapply(logits,function(lp) exp(lp-hi))))
    lapply(logits,function(lp) lp-normalizer)
  }
  theta <- if(condition=='population') 0.2+0.5*persons$x+sqrt(0.7)*rnorm(n_person) else rnorm(n_person)
  d$Score <- vapply(seq_len(nrow(d)),function(i) {
    sample(0:nstep,1,prob=exp(vapply(log_probability(theta[pi[i]],i,truth),as.numeric,numeric(1))))
  },integer(1))
  groups <- split(seq_len(nrow(d)),d$Person)
  objective <- function(par) {
    -sum(vapply(groups,function(ix) {
      mu <- if(condition=='population') sum(c(1,persons$x[pi[ix[1]]])*par[slices$beta]) else 0
      sd <- if(condition=='population') exp(par[slices$log_sigma2]/2) else 1
      density <- function(z) {
        lp <- log_probability(z,ix,par)
        observed <- matrix(0,length(z),length(ix))
        for(k in 0:nstep) {
          selected <- which(d$Score[ix]==k)
          observed[,selected] <- lp[[k+1L]][,selected,drop=FALSE]
        }
        exp(as.vector(observed %*% d$Weight[ix]))*dnorm(z,mu,sd)
      }
      value <- integrate(density,-Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)$value
      stopifnot(is.finite(value),value>0)
      log(value)
    },numeric(1)))
  }
  list(data=d,persons=persons,extra=extra,truth=truth,sizes=sizes,slices=slices,
       objective=objective,facet_map=facet_map,facet_offset=c(roffset,0,0),step_map=step_map)
}

mml_information_case <- function(model,condition,categories,seed) {
  x <- mml_information_fixture(model,condition,categories,seed)
  fit <- do.call(fit_mfrm,c(list(data=x$data,person='Person',facets=c('Rater','Criterion'),
    score='Score',model=model,method='MML',step_facet=if(model=='PCM') 'Criterion' else NULL,
    rating_min=0,rating_max=categories-1L,quad_points=61L,maxit=200L,reltol=1e-10),x$extra))
  package <- mfrmr:::compute_mml_parameter_covariance(fit)
  actual_sizes <- unlist(package$sizes); actual_sizes <- actual_sizes[actual_sizes>0L]
  stopifnot(identical(names(actual_sizes),names(x$sizes)),all(actual_sizes==x$sizes),
            identical(package$status,'ok'))
  p <- fit$opt$par; objective <- x$objective
  h1 <- mml_independent_central_hessian(objective,p,0.001)
  h2 <- mml_independent_central_hessian(objective,p,0.0005)
  chol(h2)
  v <- solve(h2)
  directions <- diag(length(p))*0.0005
  reference_score <- vapply(seq_along(p),function(i) {
    (objective(p+directions[i,])-objective(p-directions[i,]))/0.001
  },numeric(1))
  idx <- mfrmr:::build_indices(fit$prep,step_facet=fit$config$step_facet,
                              interaction_specs=fit$config$interaction_specs)
  score <- mfrmr:::mfrm_grad_mml(p,idx,fit$config,package$sizes,mfrmr:::gauss_hermite_normal(61L))
  diagnostics <- diagnose_mfrm(fit,residual_pca='none')
  measures <- diagnostics$measures
  at <- match(rownames(x$facet_map),paste(measures$Facet,measures$Level,sep=':'))
  stopifnot(!anyNA(at))
  steps <- diagnostics$parameter_uncertainty$steps
  map <- rbind(x$facet_map,x$step_map)
  expected_estimate <- as.vector(map %*% p)+c(x$facet_offset,rep(0,nrow(x$step_map)))
  expanded <- data.frame(Coordinate=rownames(map),ReferenceEstimate=expected_estimate,
    PackageEstimate=c(measures$Estimate[at],steps$Estimate),
    ReferenceSE=sqrt(pmax(0,diag(map %*% v %*% t(map)))),
    PackageSE=c(measures$ModelSE[at],steps$SE))
  fixed <- expanded$ReferenceSE==0
  pair_maps <- rbind(x$facet_map[1,]-x$facet_map[2,],x$facet_map[1,]-x$facet_map[3,],
                    x$facet_map[2,]-x$facet_map[3,],x$facet_map[4,]-x$facet_map[5,])
  pairs <- data.frame(Facet=c(rep('Rater',3),'Criterion'),
    A=c('R1','R1','R2','C1'),B=c('R2','R3','R3','C2'),
    ReferenceSE=sqrt(diag(pair_maps %*% v %*% t(pair_maps))),
    PackageSE=sqrt(diag(pair_maps %*% package$cov %*% t(pair_maps))),PublicSE=NA_real_,Reason='')
  availability_ok <- TRUE
  for(facet in c('Rater','Criterion')) {
    eq <- tryCatch(analyze_facet_equivalence(fit,facet=facet),error=identity)
    take <- pairs$Facet==facet
    if(inherits(eq,'error')) pairs$Reason[take] <- conditionMessage(eq) else {
      at_pair <- match(paste(pairs$A[take],pairs$B[take]),paste(eq$pairwise$ElementA,eq$pairwise$ElementB))
      stopifnot(!anyNA(at_pair)); pairs$PublicSE[take] <- eq$pairwise$SE_Diff[at_pair]
    }
    if(facet=='Rater' && condition %in% c('anchor','group')) {
      availability_ok <- availability_ok && inherits(eq,'error')
    }
    if(mfrmr:::mfrm_inference_ready(fit) && !(facet=='Rater' && condition %in% c('anchor','group'))) {
      availability_ok <- availability_ok && !inherits(eq,'error')
    }
  }
  hscale <- max(1,max(abs(h2)))
  metrics <- c(ObjectiveDifference=abs(objective(p)-fit$opt$value),
    HessianStepRelativeChange=max(abs(h1-h2))/hscale,
    HessianRelativeDifference=max(abs(package$hessian-h2))/hscale,
    HessianEntryScaledDifference=max(abs(package$hessian-h2)/pmax(1,sqrt(abs(outer(diag(h2),diag(h2)))))),
    ScoreDifference=max(abs(score-reference_score)),
    CovarianceEntryScaledDifference=max(abs(package$cov-v)/sqrt(outer(diag(v),diag(v)))),
    MaxRelativeSEDifference=max(abs(sqrt(diag(package$cov)/diag(v))-1)),
    ExpandedRelativeSEDifference=max(abs(expanded$PackageSE[!fixed]/expanded$ReferenceSE[!fixed]-1)),
    FixedSEAbsoluteDifference=if(any(fixed)) max(abs(expanded$PackageSE[fixed])) else 0,
    EstimateDifference=max(abs(expanded$ReferenceEstimate-expanded$PackageEstimate)),
    PairRelativeSEDifference=max(abs(pairs$PackageSE/pairs$ReferenceSE-1)),
    PublicPairRelativeSEDifference=if(any(is.finite(pairs$PublicSE))) max(abs(pairs$PublicSE/pairs$ReferenceSE-1),na.rm=TRUE) else NA_real_)
  tolerances <- rep(1e-5,length(metrics)); names(tolerances) <- names(metrics)
  tolerances['ObjectiveDifference'] <- 1e-6
  tolerances[c('FixedSEAbsoluteDifference','EstimateDifference')] <- 1e-10
  checks <- metrics<tolerances
  checks['PublicPairRelativeSEDifference'] <- isTRUE(checks['PublicPairRelativeSEDifference']) ||
    all(is.na(pairs$PublicSE) & nzchar(pairs$Reason))
  checks <- c(checks,Availability=availability_ok)
  list(metrics=metrics,checks=checks,
    fit=fit,data=x$data,persons=x$persons,truth=x$truth,map=map,expanded=expanded,pairs=pairs,
    package=package,reference_hessian=h2,reference_hessian_coarse=h1,reference_covariance=v,
    reference_score=reference_score,package_score=score,
    inference_ready=mfrmr:::mfrm_inference_ready(fit),
    formal_inference=diagnostics$precision_profile$SupportsFormalInference)
}

mml_information_conditions <- function(output_directory) {
  pkgload::load_all('.',quiet=TRUE)
  dir.create(output_directory,recursive=TRUE,showWarnings=FALSE)
  stopifnot(dir.exists(output_directory))
  files <- c(list.files('R',pattern='[.]R$',full.names=TRUE),
    'inst/validation/mml-independent-rsm-information-0.2.4.R',
    'inst/validation/mml-independent-information-conditions-0.2.4.R')
  write.csv(data.frame(File=files,MD5=unname(tools::md5sum(files))),
            file.path(output_directory,'source-md5.csv'),row.names=FALSE)
  cases <- data.frame(Model=rep(c('RSM','PCM'),each=6),
    Condition=rep(c('baseline','population','anchor','group','interaction','weights'),2),Categories=3L)
  cases <- rbind(cases,data.frame(Model='PCM',Condition='baseline',Categories=4L))
  cases$Seed <- 20260909L+seq_len(nrow(cases))
  rows <- list()
  for(i in seq_len(nrow(cases))) {
    case <- cases[i,]; id <- paste(case$Model,case$Condition,case$Categories,sep='-')
    cat('Starting',id,'\n'); flush.console()
    warnings <- character(); started <- proc.time()[['elapsed']]
    result <- tryCatch(withCallingHandlers(
      mml_information_case(case$Model,case$Condition,case$Categories,case$Seed),
      warning=function(w) { warnings <<- c(warnings,conditionMessage(w)); invokeRestart('muffleWarning') }),error=identity)
    seconds <- proc.time()[['elapsed']]-started
    failed <- inherits(result,'error')
    saveRDS(list(case=case,result=result,warnings=warnings,seconds=seconds,session_info=sessionInfo()),
            file.path(output_directory,paste0(id,'.rds')))
    row <- data.frame(case,Seconds=seconds,Error=if(failed) conditionMessage(result) else '',
      Pass=!failed && isTRUE(all(result$checks)),
      InferenceReady=if(failed) NA else result$inference_ready,
      FormalInference=if(failed) NA else result$formal_inference,
      MaxAbsScore=if(failed) NA_real_ else max(abs(result$reference_score)),Warnings=length(warnings))
    if(!failed) row <- cbind(row,as.data.frame(as.list(result$metrics)))
    rows[[i]] <- row
    all_names <- unique(unlist(lapply(rows,names)))
    combined <- do.call(rbind,lapply(rows,function(r) { r[setdiff(all_names,names(r))] <- NA; r[all_names] }))
    write.csv(combined,file.path(output_directory,'metrics.csv'),row.names=FALSE)
    print(row,row.names=FALSE); flush.console()
  }
  stopifnot(all(combined$Pass))
  invisible(combined)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L)
  mml_information_conditions(args[[1L]])
}
