# Frozen public-route bridge and cost pilot; no public interval API is added.
source('inst/validation/jml-design-adjustment-20260927.R')
source('inst/validation/jml-total-expectation-20260927.R')

jml_observed_designs <- function() {
  contract <- readRDS('validation-results/jml-scope-challenge-20260927/contract.rds')
  truth <- c(Rater=.3,Criterion=-.4,Step1=-.6,Step2=-.9,LogSlope=.25)
  a <- contract$designs$unequal; a$owner <- 'Criterion'
  b <- contract$designs$sparse; b$owner <- 'Rater'
  prototype <- lapply(list(a,b),function(x) {
    x$truth <- truth; x$rating_max <- 2L
    x$cells <- expand.grid(Rater=1:2,Criterion=1:2); x$normal <- FALSE
    x
  })
  c <- list(owner='Criterion',rating_max=3L,normal=TRUE,
    truth=c(.2,-.1,.3,-.6,.2,-.8,.1,.18),
    cells=expand.grid(Rater=1:3,Criterion=1:2),proportions=c(.5,.5),
    exposure=list(c(2,2,0,0,0,2),c(0,0,2,2,2,0)))
  list(criterion_unequal=prototype[[1]],rater_sparse=prototype[[2]],three_judge=c)
}

jml_observed_expand <- function(levels,owner,K) {
  sizes <- c(lengths(levels),rep(K,length(levels[[owner]])),length(levels[[owner]]))
  H <- matrix(0,sum(sizes),sum(sizes-1)); ir <- ic <- 0L
  for (n in sizes) {
    H[ir+seq_len(n),ic+seq_len(n-1)] <- rbind(diag(n-1),rep(-1,n-1))
    ir <- ir+n; ic <- ic+n-1
  }
  keys <- c(unlist(Map(function(f,l) paste('location',f,l,sep=':'),names(levels),levels)),
    unlist(lapply(levels[[owner]],function(l) paste('step',owner,l,seq_len(K),sep=':'))),
    paste('slope',owner,levels[[owner]],sep=':'))
  list(H=H,keys=unname(keys),slope=seq_len(nrow(H))>nrow(H)-length(levels[[owner]]))
}

jml_observed_long <- function(counts,cells) {
  pieces <- list()
  for (j in seq_along(counts)) for (k in seq_len(ncol(counts[[j]]))) {
    ids <- rep(seq_len(nrow(counts[[j]])),counts[[j]][,k])
    if (!length(ids)) next
    pieces[[length(pieces)+1L]] <- data.frame(Person=sprintf('p%04d',ids),
      Rater=cells$Rater[j],Criterion=cells$Criterion[j],Score=k-1L)
  }
  do.call(rbind,pieces)
}

jml_observed_generate <- function(d,seed) {
  set.seed(seed); N <- 400L; K <- d$rating_max
  roster <- rep(seq_along(d$proportions),N*d$proportions)
  theta <- if(d$normal) rnorm(N) else unlist(lapply(seq_along(d$proportions),function(g)
    sample(d$ability[[g]],N*d$proportions[g],replace=TRUE,prob=c(.25,.5,.25))))
  levels <- list(Rater=as.character(seq_len(max(d$cells$Rater))),Criterion=c('1','2'))
  map <- jml_observed_expand(levels,d$owner,K)
  expanded <- drop(map$H%*%d$truth); nr <- length(levels$Rater); nc <- 2L
  ng <- length(levels[[d$owner]])
  locations <- expanded[seq_len(nr+nc)]
  steps <- matrix(expanded[nr+nc+seq_len(ng*K)],ng,K,byrow=TRUE)
  slopes <- exp(tail(expanded,ng)); own <- d$cells[[d$owner]]
  probability <- lapply(seq_len(nrow(d$cells)),function(j) {
    eta <- theta-locations[d$cells$Rater[j]]-locations[nr+d$cells$Criterion[j]]
    z <- slopes[own[j]]*(outer(eta,0:K)-matrix(c(0,cumsum(steps[own[j],])),N,K+1,byrow=TRUE))
    z <- z-apply(z,1,max); p <- exp(z); p/rowSums(p)
  })
  cumulative <- lapply(probability,function(p) matrix(0L,N,K+1))
  arms <- list()
  for (block in 1:4) {
    for (j in seq_along(probability)) for (i in seq_len(N)) {
      n <- d$exposure[[roster[i]]][j]
      if(n) cumulative[[j]][i,] <- cumulative[[j]][i,]+drop(rmultinom(1,n,probability[[j]][i,]))
    }
    if(block %in% c(1L,4L)) arms[[as.character(block)]] <- cumulative
  }
  list(seed=seed,roster=roster,theta=theta,counts=arms)
}

jml_observed_candidate <- function(result) {
  spec <- result$specification
  map <- jml_observed_expand(result$levels[spec$facets],spec$owner,spec$rating_max)
  point <- isTRUE(result$point$available)
  estimate <- if(point) drop(map$H%*%result$point$beta) else rep(NA_real_,nrow(map$H))
  eligible <- point && identical(result$point$status,'consistent_roots') && isTRUE(result$covariance$available)
  se <- if(eligible) sqrt(rowSums((map$H%*%result$covariance$result$vcov)*map$H)) else rep(NA_real_,nrow(map$H))
  lower <- estimate-qnorm(.975)*se; upper <- estimate+qnorm(.975)*se
  display_estimate <- estimate; display_lower <- lower; display_upper <- upper
  display_estimate[map$slope] <- exp(estimate[map$slope])
  display_lower[map$slope] <- exp(lower[map$slope]); display_upper[map$slope] <- exp(upper[map$slope])
  available <- eligible & is.finite(se) & se>0 & is.finite(display_lower) & is.finite(display_upper)
  data.frame(Parameter=map$keys,LogScale=map$slope,PointAvailable=point,
    Available=available,Estimate=estimate,SE=se,Lower=lower,Upper=upper,
    DisplayEstimate=display_estimate,DisplayLower=display_lower,DisplayUpper=display_upper)
}

jml_observed_public <- function(data,owner,rating_max) {
  warnings <- character()
  seconds <- system.time(fit <- tryCatch(withCallingHandlers(
    mfrmr::fit_mfrm(data,person='Person',facets=c('Rater','Criterion'),score='Score',
      model='GPCM',method='JML',step_facet=owner,slope_facet=owner,
      rating_min=0,rating_max=rating_max,category_policy='preserve',maxit=400L,
      jml_correction_order=2L,jml_correction_sampling='fixed_rosters'),
    warning=function(w) {warnings<<-c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),
    error=function(e) list(error=conditionMessage(e))))[['elapsed']]
  if(!is.null(fit$error)) return(list(error=fit$error,warnings=warnings,seconds=seconds))
  result <- fit$jml_adjustment
  rows <- jml_observed_candidate(result)
  # Independently expanded constrained coordinates must reproduce public tables.
  if(isTRUE(result$point$available)) {
    actual <- c(fit$facets$others$Estimate,fit$steps$Estimate,fit$slopes$Estimate)
    stopifnot(max(abs(actual-rows$DisplayEstimate))<1e-10)
    if(isTRUE(result$covariance$available) && identical(result$point$status,'consistent_roots')) {
      actual_se <- c(fit$facets$others$RootSE,fit$steps$RootSE,fit$slopes$LogRootSE)
      stopifnot(max(abs(actual_se-rows$SE))<1e-10)
    }
  }
  list(result=result,rows=rows,summary=fit$summary,warnings=warnings,seconds=seconds)
}

jml_observed_reference <- function(d,counts,fit) {
  if(!isTRUE(fit$result$point$available) || !isTRUE(fit$result$covariance$available)) return(list(unavailable=TRUE))
  N <- nrow(counts[[1]])
  roster <- rep(seq_along(d$proportions),N*d$proportions)
  ps <- lapply(seq_along(d$proportions),function(g)
    make_jml_total_problem(d$owner,vapply(counts,function(x)sum(x[which(roster==g)[1],]),0),
      lapply(counts,function(x)x[roster==g,,drop=FALSE])))
  eq <- make_jml_design_equation(ps,lapply(d$proportions,function(w)rep(1/(N*w),N*w)),d$proportions,2L)
  data <- jml_observed_long(counts,d$cells)
  native <- mfrmr:::mfrm_jml_adjustment_problem(data,'Person',c('Rater','Criterion'),'Score',d$owner,2L)
  beta <- fit$result$point$beta; cv <- fit$result$covariance$result
  errors <- c()
  for(b in list(beta,c(-.3,.4,-.3,-1.1,-.25))) {
    reference <- do.call(rbind,lapply(ps,function(p)p$scores(b,2L)$value))
    errors <- c(errors,score=max(abs(native$evaluate(b,2L)$value-reference)))
  }
  A <- jml_sample_jacobian(eq$mean_score,beta,5e-5)
  V <- jml_design_covariance(eq,beta,N,A,'fixed_rosters')
  errors <- c(errors,jacobian=max(abs(A-cv$jacobian))/max(1,max(abs(A))),
    meat=max(abs(V$meat-cv$meat)),covariance=max(abs(V$vcov-cv$vcov))/max(abs(V$vcov)),
    influence=max(abs(crossprod(cv$influence)/N^2-cv$vcov)))
  stopifnot(max(errors)<1e-7)
  list(errors=errors)
}

jml_observed_prepare <- function(out) {
  stopifnot(!dir.exists(out)); dir.create(out,recursive=TRUE)
  files <- c('DESCRIPTION','NAMESPACE','LICENSE',
    list.files(c('R','data','man','inst/extdata'),recursive=TRUE,full.names=TRUE),
    list.files('src','[.](cpp|h|so)$',full.names=TRUE),
    paste0('inst/validation/',c('jml-observed-inference-20261001.R','jml-design-adjustment-20260927.R',
      'jml-total-expectation-20260927.R','jml-profile-bias-sample-20260927.R','jml-profile-bias-exact-20260927.R')),
    'validation-results/jml-scope-challenge-20260927/contract.rds',
    paste0('validation-results/jml-order-sampling-20260927/case-',1:2,'-rep-001.rds'))
  hashes <- tools::md5sum(files); stopifnot(!anyNA(hashes))
  for(file in files) {
    dest <- file.path(out,'source',file);dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
    stopifnot(file.copy(file,dest))
  }
  stopifnot(file.copy('inst/validation/jml-inference-review-20260927.md',file.path(out,'protocol-before-pilot.md')))
  saveRDS(list(hashes=hashes,designs=jml_observed_designs(),order=2L,maxit=400L,
    pilot_seeds=100190000L+1:3,planned_replicates=500L,
    study_seed_family='100100000 + 10000 * design_index + replicate',
    session=capture.output(sessionInfo())),file.path(out,'manifest.rds'))
}

jml_observed_load <- function(out) {
  out <- normalizePath(out); m <- readRDS(file.path(out,'manifest.rds')); frozen <- file.path(out,'source')
  stopifnot(identical(unname(m$hashes),unname(tools::md5sum(file.path(frozen,names(m$hashes))))))
  setwd(frozen); pkgload::load_all('.',quiet=TRUE,compile=FALSE,helpers=FALSE)
  stopifnot(unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']]))==unname(m$hashes['src/mfrmr.so']))
  m
}

jml_observed_pilot <- function(out) {
  out <- normalizePath(out); m <- jml_observed_load(out); rows <- list()
  for(i in 1:2) {
    saved <- readRDS(paste0('validation-results/jml-order-sampling-20260927/case-',i,'-rep-001.rds'))
    d <- m$designs[[i]]; counts <- lapply(1:4,function(j) matrix(0,400,3)); offset <- 0L
    for(g in seq_along(d$proportions)) {
      p <- make_jml_roster_problem(d$owner,d$exposure[[g]])
      ids <- rep(seq_len(p$n),saved$counts[[g]])
      for(j in 1:4) counts[[j]][offset+seq_along(ids),] <- p$counts[[j]][ids,,drop=FALSE]
      offset <- offset+length(ids)
    }
    path <- file.path(out,paste0('replay-',i,'.rds')); stopifnot(!file.exists(path))
    fit <- jml_observed_public(jml_observed_long(counts,d$cells),d$owner,d$rating_max)
    check <- jml_observed_reference(d,counts,fit)
    check$root <- max(abs(fit$result$point$beta-saved$fit[['2']]$beta))
    check$old_covariance <- max(abs(fit$result$covariance$result$vcov-saved$fit[['2']]$covariance$vcov))
    stopifnot(all(fit$rows$Available),check$root<1e-6,check$old_covariance<1e-7)
    saveRDS(list(fit=fit,check=check,counts=counts,hashes=m$hashes),path)
    cat('Replay',i,'seconds',fit$seconds,'maximum equation/covariance error',max(check$errors),'\n');flush.console()
  }
  for(i in seq_along(m$designs)) {
    d <- m$designs[[i]]; input <- jml_observed_generate(d,m$pilot_seeds[i])
    input_path <- file.path(out,paste0('pilot-input-',i,'.rds')); stopifnot(!file.exists(input_path))
    saveRDS(input,input_path)
    for(L in c(1L,4L)) {
      path <- file.path(out,paste0('pilot-',i,'-',L,'.rds'));stopifnot(!file.exists(path))
      counts <- input$counts[[as.character(L)]]
      fit <- jml_observed_public(jml_observed_long(counts,d$cells),d$owner,d$rating_max)
      check <- if(i<=2 && L==4 && is.null(fit$error)) jml_observed_reference(d,counts,fit) else NULL
      stopifnot(identical(unname(m$hashes),unname(tools::md5sum(names(m$hashes)))))
      saveRDS(list(fit=fit,check=check,input_hash=tools::md5sum(input_path),hashes=m$hashes),path)
      rows[[paste(i,L)]] <- data.frame(Design=names(m$designs)[i],L=L,Seconds=fit$seconds,
        PointStatus=if(is.null(fit$error))fit$result$point$status else 'error',
        IntervalAvailable=if(is.null(fit$error))all(fit$rows$Available) else FALSE)
      print(rows[[paste(i,L)]],row.names=FALSE);flush.console()
    }
  }
  write.csv(do.call(rbind,rows),file.path(out,'pilot-summary.csv'),row.names=FALSE)
  saveRDS(list(complete=TRUE,hashes=m$hashes,session=capture.output(sessionInfo())),file.path(out,'pilot-completion.rds'))
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==2L)
  if(args[1]=='prepare') jml_observed_prepare(args[2]) else if(args[1]=='pilot') jml_observed_pilot(args[2]) else stop('Choose prepare or pilot.')
}
