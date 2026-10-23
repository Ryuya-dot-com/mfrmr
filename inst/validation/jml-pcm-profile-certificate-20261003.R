# Design-based profile bounds from saved ordinary-PCM derivatives only.
# The theorem uses exact arithmetic; this is a floating-point evaluation, not
# outward-rounded interval certification or a structural inference procedure.
jml_pcm_profile_certificate <- function(ctx, profile) {
  stopifnot(ctx$fit$config$model=='PCM',ncol(ctx$slope)==0L,
    length(profile$persons)==ctx$np,nrow(profile$scores)==ctx$np)
  norm2 <- function(x)sqrt(sum(x^2))
  op <- function(x)max(abs(eigen(x,symmetric=TRUE,only.values=TRUE)$values))
  pairs <- combn(seq_len(ctx$K),2L);K <- ctx$K-1L
  distance <- sapply(seq_len(ncol(pairs)),function(j) {
    a <- pairs[1,j];b <- pairs[2,j]
    sqrt(rowSums((ctx$lin[[a]]-ctx$lin[[b]])^2))
  })
  gap <- pairs[2,]-pairs[1,]
  rowC <- apply(sweep(distance,2L,gap,'/'),1L,max)
  C <- vapply(ctx$groups,function(ix)max(rowC[ix]),0)
  L <- vapply(seq_along(ctx$groups),function(i)
    max(sweep(distance[ctx$groups[[i]],,drop=FALSE],2L,gap*C[i],'+')),0)
  p <- length(ctx$beta);zero <- matrix(0,p,p)
  S <- lapply(profile$persons,function(x)if(is.null(x))zero else {
    H <- x$hessian;stopifnot(H[1,1]>0)
    H[-1,-1,drop=FALSE]-tcrossprod(H[-1,1])/H[1,1]
  })
  H <- Reduce('+',S);U <- profile$scores
  stopifnot(isTRUE(all.equal(H,profile$hessian,tolerance=1e-12)),
    isTRUE(all.equal(colSums(U),profile$gradient,tolerance=1e-12)))
  lambda <- min(eigen(H,symmetric=TRUE,only.values=TRUE)$values)
  if(lambda<=0)return(list(available=FALSE,reason='Profile curvature is not positive definite'))
  residual <- vapply(profile$persons,function(x)if(is.null(x))0 else abs(x$gradient[1]),0)
  person_ratio <- vapply(seq_along(profile$persons),function(i) {
    x <- profile$persons[[i]];if(is.null(x))0 else K*residual[i]/x$hessian[1,1]
  },0)
  if(any(person_ratio>=1))return(list(available=FALSE,reason='Scalar nuisance bound is inconclusive'))
  delta <- -log1p(-person_ratio)/K
  lambda_lower <- exp(-K*max(delta))*lambda
  gradient_upper <- norm2(profile$gradient)+sum(C*residual)
  rate <- max(L);ratio <- rate*gradient_upper/lambda_lower
  if(ratio>=1)return(list(available=FALSE,reason='Root-existence bound is inconclusive',ratio=ratio))
  radius <- if(rate==0)gradient_upper/lambda_lower else -log1p(-ratio)/rate
  transport <- exp(max(K*delta+L*radius))
  # Stability of the existing empirical fixed-roster matrix, not consistency
  # for the population covariance or replacement by inverse curvature.
  variation <- covariance_bound <- covariance <- NULL
  if(all(table(ctx$roster)>=2L)) {
    shift <- C*residual+exp(K*delta)*vapply(S,op,0)*
      vapply(L,function(l)if(l==0)radius else expm1(l*radius)/l,0)
    centered <- U;centered_shift <- shift
    for(g in unique(ctx$roster)) {
      ix <- which(ctx$roster==g)
      centered[ix,] <- sweep(U[ix,,drop=FALSE],2L,colMeans(U[ix,,drop=FALSE]))
      centered_shift[ix] <- shift[ix]+mean(shift[ix])
    }
    meat <- crossprod(centered)
    variation <- sum(2*sqrt(rowSums(centered^2))*centered_shift+centered_shift^2)
    inverse <- solve(H);covariance <- inverse%*%meat%*%inverse
    covariance_bound <- (transport/lambda)^2*variation+
      (transport+1)/lambda*op(meat)*(transport-1)/lambda
  }
  list(available=TRUE,reason='',summary=data.frame(N=ctx$np,Coordinates=p,
    DesignC=max(C),TransportRate=rate,GradientNorm=norm2(profile$gradient),
    GradientUpper=gradient_upper,MinStoredCurvature=lambda,CurvatureLower=lambda_lower,
    MaximumNuisanceDistance=max(delta),ExistenceRatio=ratio,StructuralRadius=radius,
    ObjectiveGapUpper=gradient_upper*radius,CurvatureTransport=transport,
    EmpiricalCovarianceChangeUpper=if(is.null(covariance_bound))NA_real_ else covariance_bound),
    person=list(C=C,L=L,residual=residual,nuisance_radius=delta),
    covariance=covariance,covariance_change_upper=covariance_bound,
    interpretation='Exact-arithmetic sufficient bound evaluated from saved floating-point derivatives; not interval arithmetic, truth-bias control or covariance qualification.')
}

jml_pcm_certificate_run <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
  source('inst/validation/jml-public-profile-bridge-20261002.R')
  fit_path <- 'validation-results/mfrm-wide-map-recovery-20261002/PCM-JML/q0-fit.rds'
  bridge_path <- 'validation-results/jml-public-profile-bridge-20261002/AB20-PCM.rds'
  fit <- readRDS(fit_path);bridge <- readRDS(bridge_path)
  stopifnot(identical(fit$checksum,wide_mml_hash(fit$payload)),
    identical(bridge$checksum,wide_mml_hash(bridge$payload)),
    identical(bridge$binding$input,tools::md5sum(fit_path)))
  # Construct the fixed design map; never call an evaluator or solve a root.
  ctx <- jml_bridge_context(fit$payload$value)
  value <- jml_pcm_profile_certificate(ctx,bridge$payload$profile)
  stopifnot(value$available,isTRUE(all.equal(value$covariance,
    bridge$payload$fixed_roster_root_covariance,tolerance=1e-12)))
  script <- 'inst/validation/jml-pcm-profile-certificate-20261003.R'
  binding <- list(inputs=tools::md5sum(c(fit_path,bridge_path)),
    source=tools::md5sum(c(script,'inst/validation/jml-public-profile-bridge-20261002.R')),
    runtime=wide_mml_runtime())
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  saved <- wide_mml_phase(file.path(out,'saved-pcm.rds'),binding,function()value)
  stopifnot(identical(saved,value))
  write.csv(value$summary,file.path(out,'summary.csv'),row.names=FALSE)
  print(value$summary,row.names=FALSE)
  invisible(value)
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE);stopifnot(length(args)==1L)
  jml_pcm_certificate_run(args[1])
}
