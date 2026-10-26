# Repository-only zero-variance review for ordinary RSM latent regression.
# Independent categorical likelihood; no positive-variance fitting or public API.
# The PCM source epochs and their saved selection rules remain unchanged.
rsm_lr_boundary_rule <- function() list(
  version='RSM-LR-zero-v1', gradtol=1e-11, steptol=1e-12, iterlim=1000L,
  score=1e-6, scaled_score=1e-7, moment=1e-9, mass=1e-12, gap=1e-8,
  polish_step=1e-5, likelihood_margin=1e-6)

rsm_lr_boundary_context <- function(fit) {
  cfg <- fit$config; dat <- fit$prep$data; pop <- fit$population
  stopifnot(inherits(fit,'mfrm_fit'),cfg$model=='RSM',cfg$method=='MML',
    cfg$n_cat %in% c(3L,4L),identical(cfg$facet_names,c('Rater','Criterion')),
    all(cfg$facet_signs==-1),is.null(cfg$step_facet),length(cfg$interaction_specs)==0L,
    isTRUE(cfg$population_spec$active),all(dat$Weight==1),all(dat$Score==dat$score_k),
    !anyDuplicated(dat[c('Person','Rater','Criterion')]),
    length(pop$design_columns)==2L,pop$design_columns[1]=='(Intercept)',
    pop$design_columns[2] %in% c('x','X'),all(is.finite(pop$design_matrix)))
  K <- cfg$n_cat; steps <- cfg$step_specs$shared
  stopifnot(length(cfg$step_specs)==1L,steps$n_steps==K-1L,steps$target==0,
    steps$reference_index==K-1L,identical(steps$free_index,seq_len(K-1L)),
    steps$n_params==K-2L,all(is.na(steps$anchors)))
  sizes <- mfrmr:::build_param_sizes(cfg); slices <- mfrmr:::build_param_slices(sizes)
  stopifnot(length(slices$log_sigma2)==1L,slices$log_sigma2==length(fit$opt$par),
    length(slices$beta)==2L)
  p <- length(fit$opt$par)-1L; person <- match(as.character(dat$Person),pop$included_persons)
  stopifnot(!anyNA(person),all(tabulate(person,nbins=nrow(pop$design_matrix))>0L))
  X <- pop$design_matrix[person,,drop=FALSE]
  stopifnot(all(X[,1L]==1))
  facet_design <- lapply(cfg$facet_names,function(name) {
    spec <- cfg$facet_specs[[name]]; n <- length(spec$levels)
    stopifnot(n>=2L,spec$centered,spec$n_params==n-1L,
      all(is.na(spec$anchors)),all(is.na(spec$groups)))
    idx <- match(as.character(dat[[name]]),spec$levels); stopifnot(!anyNA(idx))
    rbind(diag(n-1L),rep(-1,n-1L))[idx,,drop=FALSE]
  })
  step_map <- rbind(diag(K-2L),rep(-1,K-2L))
  cumulative <- rbind(rep(0,K-2L),apply(step_map,2,cumsum))
  design <- lapply(0:(K-1L),function(k) {
    D <- matrix(0,nrow(dat),p)
    for(j in seq_along(cfg$facet_names)) D[,slices[[cfg$facet_names[j]]]] <- -k*facet_design[[j]]
    D[,slices$steps] <- matrix(-cumulative[k+1L,],nrow(dat),K-2L,byrow=TRUE)
    D[,slices$beta] <- k*X
    D
  })
  stopifnot(all(is.finite(unlist(design))),qr(do.call(rbind,design[-1L]))$rank==p)
  observed <- Reduce('+',lapply(seq_len(K),function(k) design[[k]]*(dat$score_k==k-1L)))
  list(design=design,observed=observed,y=dat$score_k,K=K,p=p,
    groups=split(seq_len(nrow(dat)),person),persons=length(unique(person)),
    fit=fit,sizes=sizes,slices=slices)
}

rsm_lr_boundary_eval <- function(ctx,eta) {
  stopifnot(length(eta)==ctx$p,all(is.finite(eta)))
  logits <- vapply(ctx$design,function(D) as.vector(D %*% eta),numeric(length(ctx$y)))
  peak <- apply(logits,1L,max)
  logp <- logits-peak-log(rowSums(exp(logits-peak)))
  probability <- exp(logp)
  expected <- Reduce('+',lapply(seq_len(ctx$K),function(k) ctx$design[[k]]*probability[,k]))
  centered <- lapply(ctx$design,function(D) D-expected)
  information <- Reduce('+',lapply(seq_len(ctx$K),function(k)
    crossprod(centered[[k]]*sqrt(probability[,k]))))
  means <- as.vector(probability %*% (0:(ctx$K-1L)))
  variance <- rowSums(probability*(matrix(0:(ctx$K-1L),nrow(probability),ctx$K,byrow=TRUE)-means)^2)
  score_v <- sum(vapply(ctx$groups,function(ix)
    (sum(ctx$y[ix]-means[ix])^2-sum(variance[ix]))/2,0.))
  list(value=-sum(logp[cbind(seq_along(ctx$y),ctx$y+1L)]),
    gradient=colSums(expected-ctx$observed),hessian=information,
    probability=probability,logits=logits,centered=centered,
    natural_variance_score=score_v)
}

rsm_lr_boundary_zero <- function(ctx,rule=rsm_lr_boundary_rule()) {
  objective <- function(eta) {
    z <- rsm_lr_boundary_eval(ctx,eta)
    value <- z$value/ctx$persons
    attr(value,'gradient') <- z$gradient/ctx$persons
    attr(value,'hessian') <- z$hessian/ctx$persons
    value
  }
  opt <- nlm(objective,rep(0,ctx$p),gradtol=rule$gradtol,steptol=rule$steptol,
    iterlim=rule$iterlim,check.analyticals=TRUE)
  eta <- opt$estimate; z <- rsm_lr_boundary_eval(ctx,eta)
  correction <- solve(z$hessian,z$gradient)
  candidate <- rsm_lr_boundary_eval(ctx,eta-correction)
  polished <- max(abs(correction))<rule$polish_step && all(is.finite(candidate$gradient)) &&
    max(abs(candidate$gradient))<max(abs(z$gradient)) && candidate$value<=z$value+rule$gap
  if(polished) {eta <- eta-correction; z <- candidate}
  direction <- solve(z$hessian,z$gradient)
  dual <- z$probability
  for(k in seq_len(ctx$K)) dual[,k] <- dual[,k]*(1-as.vector(z$centered[[k]] %*% direction))
  residual <- colSums(Reduce('+',lapply(seq_len(ctx$K),function(k)
    ctx$design[[k]]*dual[,k]))-ctx$observed)
  entropy <- if(all(is.finite(dual)) && all(dual>0)) -sum(dual*log(dual)) else NA_real_
  checks <- c(optimizer_or_refinement=opt$code %in% c(1L,2L) || (opt$code==3L && polished),
    information=!is.null(tryCatch(chol(z$hessian),error=function(e) NULL)),
    stationarity=max(abs(z$gradient))<=rule$score &&
      sqrt(abs(sum(z$gradient*direction)))<=rule$scaled_score,
    dual=all(is.finite(dual)) && all(dual>0) && max(abs(residual))<=rule$moment &&
      max(abs(rowSums(dual)-1))<=rule$mass && is.finite(entropy) && abs(z$value-entropy)<=rule$gap)
  list(qualified=all(checks),checks=checks,opt=opt,eta=eta,polished=polished,
    newton_step=max(abs(correction)),nll=z$value,entropy_nll=entropy,
    score=max(abs(z$gradient)),scaled_score=sqrt(abs(sum(z$gradient*direction))),
    moment_residual=max(abs(residual)),mass_residual=max(abs(rowSums(dual)-1)),
    dual_gap=z$value-entropy,minimum_probability=min(dual),dual=dual,
    natural_variance_score=z$natural_variance_score,
    reason=if(all(checks)) '' else paste(names(checks)[!checks],collapse='; '))
}

rsm_lr_continuous_value <- function(ctx,eta,variance) {
  stopifnot(length(variance)==1L,is.finite(variance),variance>=0)
  z <- rsm_lr_boundary_eval(ctx,eta)
  log_pattern <- function(nodes,rows) {
    value <- numeric(length(nodes))
    for(row in rows) {
      logits <- outer(sqrt(variance)*nodes,0:(ctx$K-1L))+
        matrix(z$logits[row,],length(nodes),ctx$K,byrow=TRUE)
      peak <- apply(logits,1L,max)
      value <- value+logits[,ctx$y[row]+1L]-peak-log(rowSums(exp(logits-peak)))
    }
    value
  }
  details <- lapply(ctx$groups,function(rows) {
    reference <- log_pattern(0,rows)
    integral <- integrate(function(nodes) exp(log_pattern(nodes,rows)-reference+dnorm(nodes,log=TRUE)),
      -Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)
    stopifnot(integral$message=='OK',integral$value>0,integral$abs.error/integral$value<1e-10)
    c(log_probability=reference+log(integral$value),relative_error=integral$abs.error/integral$value)
  })
  details <- do.call(rbind,details)
  list(value=-sum(details[,'log_probability']),details=details,
    summed_relative_error=sum(details[,'relative_error']))
}

rsm_lr_boundary_decision <- function(zero,interior,rule=rsm_lr_boundary_rule()) {
  if(!isTRUE(zero$qualified)) return(list(eligible=FALSE,status='boundary_unresolved',
    gain=NA_real_,reason=paste('Zero-variance nuisance qualification failed:',zero$reason)))
  # These are floating-point feasibility and integration checks, not enclosures
  # proving a global maximum over the positive-variance parameter space.
  error <- interior$summed_relative_error
  gain <- min(zero$nll,zero$entropy_nll)-interior$value
  eligible <- is.finite(gain) && is.finite(error) && error>=0 && gain>rule$likelihood_margin+error
  list(eligible=eligible,status=if(eligible) 'zero_variance_dominated' else 'boundary_unresolved',
    gain=gain,continuous_error=error,
    reason=if(eligible) '' else paste('The retained interior point has not numerically excluded',
      'the zero-variance likelihood optimum; no interior interval/source is selected.'))
}
