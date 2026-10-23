# A convex upper bound on every GPCM boundary with all scaled loadings zero.
# Allows independent adjacent-step, rater and X effects for each Criterion;
# hence covers the finite v=0 model and its singular slope-ratio limits.
# It does not bound faces on which some a_g*sqrt(v) stay positive.
dlr_gpcm_zero_context <- function(fit) {
  cfg <- fit$config; dat <- fit$prep$data
  stopifnot(cfg$model=='GPCM',cfg$method=='MML',cfg$n_cat==4L,
    identical(cfg$facet_names,c('Rater','Criterion')),cfg$slope_facet=='Criterion',
    cfg$step_facet=='Criterion',all(cfg$facet_signs==-1),all(dat$Weight==1),
    !length(cfg$interaction_specs),length(fit$opt$par)==15L,
    identical(fit$population$design_columns,c('(Intercept)','X')))
  for (f in cfg$facet_specs) stopifnot(f$centered,identical(f$levels,as.character(1:3)),
    all(is.na(f$anchors)),all(is.na(f$groups)))
  for (s in cfg$step_specs) stopifnot(s$n_steps==3,s$target==0,all(is.na(s$anchors)))
  slices <- mfrmr:::build_param_slices(mfrmr:::build_param_sizes(cfg))
  stopifnot(identical(unname(slices[c('Rater','Criterion','steps','log_slopes','beta','log_sigma2')]),
    list(1:2,3:4,5:10,11:12,13:14,15L)))
  person <- match(as.character(dat$Person),fit$population$included_persons)
  stopifnot(!anyNA(person),all(tabulate(person)==6L))
  x <- fit$population$design_matrix[person,'X']; r <- as.integer(dat$Rater); g <- as.integer(dat$Criterion)
  C <- rbind(diag(2),c(-1,-1)); D <- lapply(0:3,function(k) {
    d <- matrix(0,nrow(dat),18L)
    for (owner in 1:3) {
      ix <- g==owner
      d[ix,(owner-1L)*6L+1:6] <- cbind(matrix(as.numeric(1:3<=k),sum(ix),3L,byrow=TRUE),
        -k*C[r[ix],,drop=FALSE],k*x[ix])
    }
    d
  })
  b <- fit$opt$par; slope <- exp(C%*%b[11:12])
  rater <- drop(C%*%b[1:2]); criterion <- drop(C%*%b[3:4])
  steps <- t(vapply(1:3,function(j)drop(C%*%b[4L+(2L*j-1L):(2L*j)]),numeric(3)))
  start <- unlist(lapply(1:3,function(j)c(slope[j]*(b[13]-criterion[j]-steps[j,]),
    slope[j]*b[1:2],slope[j]*b[14])),use.names=FALSE)
  logits <- vapply(D,function(d)drop(d%*%start),numeric(nrow(dat)))
  list(design=D,y=dat$score_k,groups=split(seq_len(nrow(dat)),person),
    start=start,logits=logits,loading=drop(slope[g])*exp(b[15]/2),fit=fit)
}

dlr_gpcm_zero_eval <- function(ctx,par) {
  logits <- vapply(ctx$design,function(d)drop(d%*%par),numeric(length(ctx$y)))
  peak <- apply(logits,1L,max); logp <- logits-peak-log(rowSums(exp(logits-peak)))
  p <- exp(logp); mu <- Reduce('+',lapply(1:4,function(k)ctx$design[[k]]*p[,k]))
  centered <- lapply(ctx$design,function(d)d-mu)
  observed <- Reduce('+',lapply(1:4,function(k)ctx$design[[k]]*(ctx$y==k-1L)))
  list(value=-sum(logp[cbind(seq_along(ctx$y),ctx$y+1L)]),gradient=colSums(mu-observed),
    hessian=Reduce('+',lapply(1:4,function(k)crossprod(centered[[k]]*sqrt(p[,k])))),
    probability=p,centered=centered,observed=observed)
}

dlr_gpcm_zero_check <- function(ctx,opt) {
  z <- dlr_gpcm_zero_eval(ctx,opt$estimate)
  delta <- solve(z$hessian,z$gradient)
  # Numerical feasibility of the entropy dual supplies a global bound for
  # this convex relaxation, even though it is larger than the actual model.
  dual <- z$probability
  for(k in 1:4) dual[,k] <- dual[,k]*(1-drop(z$centered[[k]]%*%delta))
  residual <- colSums(Reduce('+',lapply(1:4,function(k)ctx$design[[k]]*dual[,k]))-z$observed)
  stopifnot(min(dual)>0,max(abs(rowSums(dual)-1))<1e-12,max(abs(residual))<1e-9)
  entropy <- -sum(dual*log(dual)); gap <- z$value-entropy
  stopifnot(abs(gap)<1e-7,max(abs(z$gradient))<1e-5)
  pattern <- function(nodes,rows) {
    value <- numeric(length(nodes))
    for(row in rows) {
      logits <- matrix(ctx$logits[row,],length(nodes),4L,byrow=TRUE)+
        outer(nodes*ctx$loading[row],0:3)
      peak <- apply(logits,1L,max)
      value <- value+logits[,ctx$y[row]+1L]-peak-log(rowSums(exp(logits-peak)))
    }
    value
  }
  details <- lapply(ctx$groups,function(rows) {
    center <- pattern(0,rows)
    z <- integrate(function(x)exp(pattern(x,rows)-center+dnorm(x,log=TRUE)),
      -Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)
    stopifnot(z$message=='OK',z$value>0,z$abs.error/z$value<1e-10)
    c(log_probability=center+log(z$value),relative_error=z$abs.error/z$value)
  })
  details <- do.call(rbind,details); nll <- -sum(details[,'log_probability'])
  list(summary=data.frame(N=length(ctx$groups),RelaxedZeroNLL=z$value,DualNLLBound=entropy,
    DualGap=gap,DualResidual=max(abs(residual)),BoundaryGradient=max(abs(z$gradient)),
    InteriorContinuousNLL=nll,InteriorImprovementOverBoundaryBound=entropy-nll,
    AllZeroLoadingsExcluded=entropy-nll>1e-6,
    SurvivingLoadingFacesExcluded=FALSE),opt=opt,relaxation=z,dual=dual,
    interior_details=details,scope='All scaled loadings zero; surviving-loading faces remain separate.')
}

dlr_gpcm_zero_run <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
  root <- 'validation-results/mfrm-wide-map-lr-witness-20261002'
  ids <- c('N20-rho0-GPCM','N20-rho0.5-GPCM','N240-rho0-GPCM','N240-rho0.5-GPCM')
  runtime <- wide_mml_runtime(); script <- 'inst/validation/mfrm-wide-map-lr-gpcm-zero-bound-20261002.R'
  dir.create(out,recursive=TRUE,showWarnings=FALSE); results <- list()
  for(id in ids) {
    path <- file.path(root,id,'fit.rds'); fit <- readRDS(path)$payload$value
    ctx <- dlr_gpcm_zero_context(fit)
    binding <- list(fit=tools::md5sum(path),runtime=runtime,source=tools::md5sum(script))
    cat('GPCM all-zero loading bound:',id,'\n');flush.console()
    opt <- wide_mml_phase(file.path(out,paste0(id,'-fit.rds')),binding,function() {
      fn <- function(par) {
        z <- dlr_gpcm_zero_eval(ctx,par); N <- length(ctx$groups)
        value <- z$value/N;attr(value,'gradient') <- z$gradient/N;attr(value,'hessian') <- z$hessian/N
        value
      }
      nlm(fn,ctx$start,gradtol=1e-11,steptol=1e-12,iterlim=1000L,check.analyticals=TRUE)
    })
    results[[id]] <- wide_mml_phase(file.path(out,paste0(id,'-check.rds')),
      c(binding,list(opt=wide_mml_hash(opt))),function()dlr_gpcm_zero_check(ctx,opt))
    print(results[[id]]$summary,row.names=FALSE)
  }
  summary <- do.call(rbind,lapply(ids,function(id)cbind(Job=id,results[[id]]$summary)))
  wide_mml_save(list(summary=summary,details=results,runtime=runtime,source=tools::md5sum(script),
    source_code=readLines(script)),file.path(out,'verified.rds'))
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  invisible(results)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE)
  dlr_gpcm_zero_run(if(length(args))args[1] else 'validation-results/mfrm-wide-map-lr-gpcm-zero-bound-20261002')
}
