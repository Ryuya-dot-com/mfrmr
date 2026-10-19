# Local ordinary-JML root bounds from retained joint/profile derivatives.
# Exact-arithmetic sufficient inequalities evaluated in floating point:
# not outward-rounded certification, global branch selection or truth CIs.
jml_local_contraction <- function(eta, third_bound) {
  stopifnot(is.finite(eta), eta>=0, is.finite(third_bound), third_bound>=0)
  ratio <- 2*eta*third_bound
  if(ratio>=1) return(list(available=FALSE,ratio=ratio))
  radius <- 2*eta/(1+sqrt(1-ratio))
  list(available=TRUE,ratio=ratio,radius=radius,curvature_change=third_bound*radius)
}

jml_gpcm_local_root_bound <- function(ctx, profile, reference_covariance=NULL) {
  norm2 <- function(x)sqrt(sum(x*x))
  op <- function(x)max(abs(eigen(x,symmetric=TRUE,only.values=TRUE)$values))
  p <- length(ctx$beta); nl <- ncol(ctx$lin[[1]])
  active <- which(!vapply(profile$persons,is.null,FALSE))
  if(!length(active)) return(list(available=FALSE,reason='No nonextreme Person information'))
  zero <- matrix(0,p,p)
  S <- lapply(profile$persons,function(z)if(is.null(z))zero else {
    H <- z$hessian; stopifnot(H[1,1]>0)
    H[-1,-1,drop=FALSE]-tcrossprod(H[-1,1])/H[1,1]
  })
  H <- Reduce('+',S)
  stopifnot(isTRUE(all.equal(H,profile$hessian,tolerance=1e-12)))
  eigenvalues <- eigen(H,symmetric=TRUE,only.values=TRUE)$values
  if(min(eigenvalues)<=0) return(list(available=FALSE,reason='Nonpositive reference profile curvature'))
  B <- backsolve(chol(H),diag(p))
  stopifnot(max(abs(crossprod(B,H%*%B)-diag(p)))<1e-10)
  transformed_S <- lapply(S,function(z)crossprod(B,z%*%B))
  gv <- numeric(ctx$np); gt <- numeric(p); nuisance_error <- numeric(ctx$np)
  for(i in active) {
    z <- profile$persons[[i]]; h <- z$hessian[1,1]; c <- z$hessian[-1,1]
    gv[i] <- z$gradient[1]/sqrt(h)
    gt <- gt+drop(crossprod(B,z$gradient[-1]-c*z$gradient[1]/h))
    nuisance_error[i] <- norm2(crossprod(B,c/h))*abs(z$gradient[1])
    # Complete the nuisance square; the local mixed Hessian must vanish.
    D <- rbind(c(1/sqrt(h),-drop(crossprod(c/h,B))),cbind(0,B))
    target <- rbind(c(1,rep(0,p)),cbind(0,transformed_S[[i]]))
    stopifnot(max(abs(crossprod(D,z$hessian%*%D)-target))<1e-10)
  }
  eta <- sqrt(sum(gv^2)+sum(gt^2)); trial_radius <- 2*eta
  third <- matrix(0,ctx$np,4,dimnames=list(NULL,c('vvv','vvt','vtt','ttt')))
  category_pairs <- combn(seq_len(ctx$K),2)
  for(i in active) {
    z <- profile$persons[[i]]; h <- z$hessian[1,1]; c <- z$hessian[-1,1]
    for(row in ctx$groups[[i]]) {
      s <- ctx$slope[row,]
      gamma <- drop(crossprod(B,c(rep(0,nl),s))); slope_norm <- norm2(gamma)
      a0 <- exp(sum(s*if(p>nl)ctx$beta[(nl+1):p] else numeric(0)))
      amax <- a0*exp(trial_radius*slope_norm)
      ranges <- apply(category_pairs,2,function(pair) {
        gap <- pair[2]-pair[1]
        d <- ctx$lin[[pair[2]]][row,]-ctx$lin[[pair[1]]][row,]
        fv <- gap/sqrt(h)
        ft <- drop(crossprod(B,c(d,rep(0,p-nl))-gap*c/h))
        f <- norm2(ft)
        h0 <- gap*profile$theta[i]+sum(d*ctx$beta[seq_len(nl)])
        height <- abs(h0)+trial_radius*sqrt(fv^2+f^2)
        amax*c(Av=abs(fv),At=f+height*slope_norm,
          Hvt=abs(fv)*slope_norm,Htt=2*f*slope_norm+height*slope_norm^2,
          Tvtt=abs(fv)*slope_norm^2,Tttt=3*f*slope_norm^2+height*slope_norm^3)
      })
      r <- apply(ranges,1,max)
      third[i,] <- third[i,]+c(r['Av']^3/4,
        r['Av']^2*r['At']/4+r['Av']*r['Hvt']/2,
        r['Av']*r['At']^2/4+(r['Av']*r['Htt']+2*r['At']*r['Hvt'])/4+r['Tvtt'],
        r['At']^3/4+3*r['At']*r['Htt']/4+r['Tttt'])
    }
  }
  # Independent nuisance coordinates are aggregated by max / l2 / sum,
  # according to the number of common structural directions in the tensor.
  M <- max(third[,1])+3*max(third[,2])+3*norm2(third[,3])+sum(third[,4])
  result <- jml_local_contraction(eta,M)
  if(!result$available) return(c(result,list(reason='Local contraction bound is inconclusive',third=third)))
  radius <- result$radius; q <- result$curvature_change
  covariance <- covariance_change <- relative_change <- all_contrast_sd <- NULL
  if(all(table(ctx$roster)>=2L)) {
    U <- profile$scores%*%B
    shift <- vapply(transformed_S,op,0)*radius+
      (third[,2]+2*third[,3]+third[,4])*radius^2/2+nuisance_error
    Z <- U; centered_shift <- shift
    for(g in unique(ctx$roster)) {
      ix <- which(ctx$roster==g)
      Z[ix,] <- sweep(U[ix,,drop=FALSE],2,colMeans(U[ix,,drop=FALSE]))
      centered_shift[ix] <- shift[ix]+mean(shift[ix])
    }
    meat <- crossprod(Z); spectrum <- eigen(meat,symmetric=TRUE,only.values=TRUE)$values
    meat_change <- sum(2*sqrt(rowSums(Z^2))*centered_shift+centered_shift^2)
    transformed_change <- (meat_change+max(spectrum)*q*(2-q))/(1-q)^2
    covariance_change <- transformed_change/min(eigenvalues)
    covariance <- B%*%meat%*%t(B)
    if(!is.null(reference_covariance)) stopifnot(isTRUE(all.equal(covariance,reference_covariance,tolerance=1e-10)))
    if(min(spectrum)>0) {
      all_contrast_sd <- radius/sqrt(min(spectrum))
      relative_change <- transformed_change/min(spectrum)
    }
  }
  summary <- data.frame(N=ctx$np,Facets=length(ctx$fit$config$facet_names),
    Levels=paste(lengths(ctx$fit$prep$levels[ctx$fit$config$facet_names]),collapse='/'),
    Model=ctx$fit$config$model,Coordinates=p,Extremes=ctx$np-length(active),
    GradientInJointMetric=eta,ThirdDerivativeUpper=M,TrialContraction=result$ratio,
    RootMetricRadius=radius,StructuralEuclideanRadius=radius/sqrt(min(eigenvalues)),
    RelativeCurvatureChange=q,ObjectiveGapUpper=eta^2/(2*(1-q)),
    AllContrastDistanceInStoredRootSD=if(is.null(all_contrast_sd))NA_real_ else all_contrast_sd,
    EmpiricalCovarianceChangeUpper=if(is.null(covariance_change))NA_real_ else covariance_change,
    AllContrastRelativeVarianceChangeUpper=if(is.null(relative_change))NA_real_ else relative_change)
  list(available=TRUE,summary=summary,third=third,transform=B,
    coordinate_distance=radius*sqrt(rowSums(B^2)),covariance=covariance,
    interpretation='Exact-arithmetic sufficient local-root inequalities evaluated in floating point from saved derivatives; not a global branch, outward-rounded certificate, truth-bias bound or sampling-covariance qualification.')
}

jml_local_root_run <- function(out) {
  pkgload::load_all('.',quiet=TRUE,compile=FALSE)
  source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
  source('inst/validation/jml-public-profile-bridge-20261002.R')
  # This evaluation must only use the retained derivatives and fixed design.
  for(name in c('optim','optimHess','uniroot')) trace(name,
    tracer=quote(stop('New numerical estimation is forbidden in this replay')),
    print=FALSE,where=asNamespace('stats'))
  for(name in c('jml_bridge_check','jml_bridge_profile','jml_bridge_person'))
    trace(name,tracer=quote(stop('Derivative reevaluation is forbidden in this replay')),
          print=FALSE,where=.GlobalEnv)
  base <- 'validation-results/mfrm-wide-map-recovery-20261002'
  pilot <- 'validation-results/mfrm-facet-structure-pilot-20261001/fits'
  paths <- c(setNames(file.path(base,c('PCM-JML','GPCM-JML'),'q0-fit.rds'),c('AB20-PCM','AB20-GPCM')),
    setNames(file.path(pilot,paste0(c('240-base_two_facet','20-four_tasks','240-six_raters'),'-JML.rds')),
      c('pilot240-base','pilot20-task4','pilot240-rater6')))
  script <- 'inst/validation/jml-gpcm-local-root-bound-20261003.R'
  bridge_script <- 'inst/validation/jml-public-profile-bridge-20261002.R'
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  results <- list()
  for(id in names(paths)) {
    f <- readRDS(paths[[id]])
    if(startsWith(id,'AB')) stopifnot(identical(f$checksum,wide_mml_hash(f$payload)))
    fit <- if(startsWith(id,'AB'))f$payload$value else f$fit
    bridge_path <- file.path('validation-results/jml-public-profile-bridge-20261002',paste0(id,'.rds'))
    z <- readRDS(bridge_path)
    stopifnot(identical(z$checksum,wide_mml_hash(z$payload)),
      identical(z$binding$input,tools::md5sum(paths[[id]])),
      identical(z$binding$source,tools::md5sum(bridge_script)))
    value <- jml_gpcm_local_root_bound(jml_bridge_context(fit),z$payload$profile,
                                     z$payload$fixed_roster_root_covariance)
    binding <- list(inputs=tools::md5sum(c(paths[[id]],bridge_path)),
                    source=tools::md5sum(c(script,bridge_script)),runtime=wide_mml_runtime())
    saved <- wide_mml_phase(file.path(out,paste0(id,'.rds')),binding,function()value)
    stopifnot(identical(saved,value)); results[[id]] <- value
    print(if(value$available)value$summary else value)
  }
  rows <- lapply(names(results),function(id) {
    z <- results[[id]]
    if(z$available)cbind(Job=id,Available=TRUE,Reason='',z$summary) else
      data.frame(Job=id,Available=FALSE,Reason=z$reason)
  })
  columns <- unique(unlist(lapply(rows,names)))
  summary <- do.call(rbind,lapply(rows,function(row) {
    row[setdiff(columns,names(row))] <- NA
    row[columns]
  }))
  write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
  invisible(results)
}

if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==1L)
  jml_local_root_run(args[1])
}
