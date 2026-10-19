# Independent observed-pattern derivatives for the ordinary public JML bridge.
# No response simulation, structural refitting, correction-order enumeration
# or public inference promotion. Independently free Persons, centered facets.
jml_bridge_context <- function(fit) {
  cfg <- fit$config; dat <- fit$prep$data; sizes <- mfrmr:::build_param_sizes(cfg)
  stopifnot(cfg$method=='JML',cfg$model %in% c('PCM','GPCM'),
    !mfrmr:::mfrm_has_jml_adjustment(fit),all(dat$Weight==1),
    !length(cfg$interaction_specs),!cfg$theta_spec$centered,
    all(is.na(cfg$theta_spec$anchors)),all(is.na(cfg$theta_spec$groups)),
    sizes$theta==length(fit$prep$levels$Person),all(cfg$facet_signs==-1))
  for (f in cfg$facet_names) stopifnot(isTRUE(all.equal(cfg$facet_specs[[f]],
    mfrmr:::build_facet_constraint(fit$prep$levels[[f]]))))
  for (s in cfg$step_specs) stopifnot(s$target==0,all(is.na(s$anchors)))
  contrast <- function(n) rbind(diag(n-1L),rep(-1,n-1L))
  loc <- do.call(cbind,lapply(cfg$facet_names,function(f)
    contrast(length(fit$prep$levels[[f]]))[as.integer(dat[[f]]),,drop=FALSE]))
  K <- cfg$n_cat; owner <- as.integer(dat[[cfg$step_facet]])
  G <- length(fit$prep$levels[[cfg$step_facet]])
  cum <- rbind(rep(0,K-2L),apply(contrast(K-1L),2L,cumsum))
  lin <- lapply(0:(K-1L),function(k) {
    step <- matrix(0,nrow(dat),G*(K-2L))
    if(K>2L) for(g in seq_len(G)) step[owner==g,(g-1L)*(K-2L)+seq_len(K-2L)] <-
      matrix(-cum[k+1L,],sum(owner==g),K-2L,byrow=TRUE)
    cbind(-k*loc,step)
  })
  slope <- if(cfg$model=='GPCM') {
    stopifnot(identical(cfg$slope_facet,cfg$step_facet),
      cfg$gpcm_spec$identification=='sum_to_zero_log_slopes')
    contrast(G)[owner,,drop=FALSE]
  } else matrix(0,nrow(dat),0L)
  np <- sizes$theta; beta <- fit$opt$par[-seq_len(np)]
  stopifnot(ncol(lin[[1]])+ncol(slope)==length(beta))
  person <- as.integer(dat$Person); groups <- split(seq_len(nrow(dat)),person)
  cell <- interaction(dat[cfg$facet_names],drop=TRUE)
  roster <- vapply(groups,function(ix) paste(tabulate(as.integer(cell[ix]),nlevels(cell)),collapse=':'),'')
  list(fit=fit,lin=lin,slope=slope,K=K,groups=groups,y=dat$score_k,np=np,
    beta=beta,theta=fit$opt$par[seq_len(np)],roster=roster,sizes=sizes)
}

jml_bridge_person <- function(ctx,beta,theta,rows) {
  nl <- ncol(ctx$lin[[1]]); p <- length(beta); b <- beta[seq_len(nl)]
  sl <- if(p>nl) beta[(nl+1L):p] else numeric(0)
  value <- 0; gradient <- numeric(p+1L); H <- matrix(0,p+1L,p+1L)
  for (row in rows) {
    D <- do.call(rbind,lapply(ctx$lin,function(x)x[row,]))
    s <- ctx$slope[row,]; a <- exp(sum(s*sl))
    base <- (0:(ctx$K-1L))*theta+drop(D%*%b); utility <- a*base
    logp <- utility-max(utility)-log(sum(exp(utility-max(utility))))
    prob <- exp(logp); y <- ctx$y[row]+1L
    J <- cbind(a*(0:(ctx$K-1L)),a*D,outer(utility,s))
    mean <- drop(crossprod(prob,J)); centered <- sweep(J,2L,mean)
    g <- mean-J[y,]; h <- crossprod(centered*sqrt(prob))
    if(length(s)) {
      si <- 1L+nl+seq_along(s); li <- seq_len(nl+1L)
      # The utility Hessian is zero except slope/linear and slope/slope blocks.
      h[li,si] <- h[li,si]+outer(g[li],s)
      h[si,li] <- h[si,li]+outer(s,g[li])
      h[si,si] <- h[si,si]+(sum(prob*utility)-utility[y])*outer(s,s)
    }
    value <- value-logp[y]; gradient <- gradient+g; H <- H+h
  }
  list(value=value,gradient=gradient,hessian=H)
}

jml_bridge_profile <- function(ctx,beta) {
  p <- length(beta); persons <- vector('list',ctx$np)
  U <- matrix(0,ctx$np,p); H <- matrix(0,p,p); value <- 0
  theta <- numeric(ctx$np)
  for(i in seq_along(ctx$groups)) {
    rows <- ctx$groups[[i]]; y <- ctx$y[rows]
    extreme <- all(y==0) || all(y==ctx$K-1L)
    if(extreme) { theta[i] <- if(all(y==0))-Inf else Inf; next }
    score <- function(t) jml_bridge_person(ctx,beta,t,rows)$gradient[1]
    lo <- -1; hi <- 1
    while(score(lo)>0) {lo <- 2*lo;stopifnot(is.finite(lo))}
    while(score(hi)<0) {hi <- 2*hi;stopifnot(is.finite(hi))}
    theta[i] <- uniroot(score,c(lo,hi),tol=1e-12)$root
    z <- jml_bridge_person(ctx,beta,theta[i],rows); persons[[i]] <- z
    stopifnot(abs(z$gradient[1])<1e-9,z$hessian[1,1]>0)
    U[i,] <- z$gradient[-1L]; value <- value+z$value
    H <- H+z$hessian[-1L,-1L]-tcrossprod(z$hessian[-1L,1])/z$hessian[1,1]
  }
  list(value=value,gradient=colSums(U),hessian=H,persons=persons,theta=theta,scores=U)
}

jml_bridge_check <- function(fit) {
  ctx <- jml_bridge_context(fit); beta <- ctx$beta; p <- length(beta)
  profile <- jml_bridge_profile(ctx,beta)
  joint <- lapply(seq_along(ctx$groups),function(i)
    jml_bridge_person(ctx,beta,ctx$theta[i],ctx$groups[[i]]))
  gt <- vapply(joint,function(z)z$gradient[1],0)
  gb <- Reduce('+',lapply(joint,function(z)z$gradient[-1L]))
  value <- sum(vapply(joint,`[[`,0,'value'))
  idx <- mfrmr:::build_indices(fit$prep,fit$config$step_facet,fit$config$slope_facet)
  ev <- mfrmr:::make_mfrm_direct_evaluator('JML',
    mfrmr:::make_param_cache(ctx$sizes,fit$config,idx,is_mml=FALSE),
    idx,fit$config,ctx$sizes,NULL)
  delta <- c(value=abs(value-ev$value(fit$opt$par)),
    gradient=max(abs(c(gt,gb)-ev$gradient(fit$opt$par))))
  stopifnot(max(delta)<1e-8,value+1e-8>=profile$value)
  extreme <- is.infinite(profile$theta)
  eb <- if(any(extreme)) Reduce('+',lapply(joint[extreme],function(z)z$gradient[-1L])) else numeric(p)
  correction <- numeric(p); path_error <- numeric(0)
  for(i in which(!extreme)) {
    d <- ctx$theta[i]-profile$theta[i]
    h <- vapply(seq_len(p+1L),function(j) integrate(function(s)
      vapply(s,function(t)jml_bridge_person(ctx,beta,profile$theta[i]+t*d,
        ctx$groups[[i]])$hessian[j,1],0),0,1,rel.tol=1e-9,abs.tol=1e-11)$value,0)
    path_error <- c(path_error,abs(h[1]*d-gt[i]))
    correction <- correction+h[-1]/h[1]*gt[i]
  }
  bridge_error <- max(abs(profile$gradient-(gb-eb-correction)))
  stopifnot(bridge_error<1e-8,max(path_error)<1e-8)
  finite_difference <- lapply(c(1e-4,5e-5),function(step) {
    H <- matrix(0,p,p); gradient <- numeric(p)
    for(j in seq_len(p)) {
      a <- b <- beta; a[j] <- a[j]+step; b[j] <- b[j]-step
      za <- jml_bridge_profile(ctx,a); zb <- jml_bridge_profile(ctx,b)
      gradient[j] <- (za$value-zb$value)/(2*step)
      H[,j] <- (za$gradient-zb$gradient)/(2*step)
    }
    c(step=step,gradient=max(abs(gradient-profile$gradient)),
      hessian=max(abs(H-profile$hessian))/max(1,max(abs(profile$hessian))))
  })
  stopifnot(finite_difference[[2]]['gradient']<1e-5,finite_difference[[2]]['hessian']<1e-6)
  min_eigen <- min(eigen(profile$hessian,symmetric=TRUE,only.values=TRUE)$values)
  covariance <- inverse <- shift <- NULL
  if(min_eigen>0) {
    inverse <- chol2inv(chol(profile$hessian)); shift <- drop(inverse%*%profile$gradient)
    if(all(table(ctx$roster)>=2L)) {
      U <- profile$scores
      for(g in unique(ctx$roster)) {ix <- which(ctx$roster==g);U[ix,] <- sweep(U[ix,,drop=FALSE],2L,colMeans(U[ix,,drop=FALSE]))}
      covariance <- inverse%*%crossprod(U)%*%inverse
    }
  }
  summary <- data.frame(N=ctx$np,Facets=length(fit$config$facet_names),
    Levels=paste(lengths(fit$prep$levels[fit$config$facet_names]),collapse='/'),
    Model=fit$config$model,StructuralCoordinates=p,Extremes=sum(extreme),
    PackageValueDifference=delta['value'],PackageGradientDifference=delta['gradient'],
    JointToProfileNLL=value-profile$value,ProfileGradient=max(abs(profile$gradient)),
    ExtremeStructuralGradient=max(abs(eb)),BridgeError=bridge_error,
    MinProfileEigenvalue=min_eigen,
    NewtonShift=if(length(shift))max(abs(shift)) else NA_real_,
    ShiftInRootSD=if(length(covariance))max(abs(shift)/sqrt(diag(covariance))) else NA_real_)
  list(summary=summary,profile=profile,joint_gradient=c(gt,gb),bridge=list(extreme=eb,
    displacement=correction,path_error=path_error),finite_difference=finite_difference,
    inverse_profile_information=inverse,fixed_roster_root_covariance=covariance,
    interpretation='Observed-pattern numerical bridge and diagnostic root sandwich; not structural-truth interval qualification.')
}

jml_public_bridge_run <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
  base <- 'validation-results/mfrm-wide-map-recovery-20261002'
  pilot <- 'validation-results/mfrm-facet-structure-pilot-20261001/fits'
  paths <- c(setNames(file.path(base,c('PCM-JML','GPCM-JML'),'q0-fit.rds'),c('AB20-PCM','AB20-GPCM')),
    setNames(file.path(pilot,paste0(c('240-base_two_facet','20-four_tasks','240-six_raters'),'-JML.rds')),
      c('pilot240-base','pilot20-task4','pilot240-rater6')))
  runtime <- wide_mml_runtime(); script <- 'inst/validation/jml-public-profile-bridge-20261002.R'
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  results <- list()
  for(id in names(paths)) {
    f <- readRDS(paths[[id]])
    fit <- if(startsWith(id,'AB'))f$payload$value else f$fit
    cat('Profile bridge:',id,'\n');flush.console()
    results[[id]] <- wide_mml_phase(file.path(out,paste0(id,'.rds')),
      list(input=tools::md5sum(paths[[id]]),runtime=runtime,source=tools::md5sum(script)),
      function()jml_bridge_check(fit))
    print(results[[id]]$summary,row.names=FALSE)
  }
  summary <- do.call(rbind,lapply(names(results),function(id)cbind(Job=id,results[[id]]$summary)))
  wide_mml_save(list(summary=summary,details=results,runtime=runtime,
    inputs=tools::md5sum(paths),source=tools::md5sum(script),source_code=readLines(script)),file.path(out,'verified.rds'))
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  invisible(results)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  jml_public_bridge_run(if(length(args))args[1] else 'validation-results/jml-public-profile-bridge-20261002')
}
