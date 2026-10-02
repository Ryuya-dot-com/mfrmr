# Research-only population roots and full response covariance under exposure growth.
# Generating conditional moments stay fixed while the evaluation beta changes.
source('inst/validation/jml-exposure-expansion-20260930.R')
source('inst/validation/jml-design-adjustment-20260927.R')

jml_count_moments <- function(owner, exposure, beta) {
  cells <- expand.grid(Rater=1:2, Criterion=1:2)
  own <- cells[[owner]]; sr <- c(1,-1)[cells$Rater]; sc <- c(1,-1)[cells$Criterion]
  pairs <- expand.grid(i=1:8,j=1:8)
  lapply(1:2, function(g) {
    probability <- 1; first <- matrix(0,1,8); second <- matrix(0,1,64)
    for (j in which(own==g)) for (r in seq_len(exposure[j])) {
      a <- exp(c(1,-1)[g]*beta[5])
      z <- a*(-(sr[j]*beta[1]+sc[j]*beta[2])*(0:2)-c(0,beta[2+g],0))
      p <- exp(z-max(z)); p <- p/sum(p)
      n <- length(probability)
      np <- numeric(n+2); nf <- matrix(0,n+2,8); ns <- matrix(0,n+2,64)
      for (k in 0:2) {
        v <- numeric(8); v[j] <- k; v[4+j] <- as.integer(k==1)
        ix <- seq_len(n)+k
        delta <- first[,pairs$i,drop=FALSE]*rep(v[pairs$j],each=n) +
          first[,pairs$j,drop=FALSE]*rep(v[pairs$i],each=n) +
          outer(probability,v[pairs$i]*v[pairs$j])
        np[ix] <- np[ix]+p[k+1]*probability
        nf[ix,] <- nf[ix,,drop=FALSE]+p[k+1]*(first+outer(probability,v))
        ns[ix,] <- ns[ix,,drop=FALSE]+p[k+1]*(second+delta)
      }
      probability <- np; first <- nf; second <- ns
    }
    stopifnot(all(is.finite(probability)),all(probability>0))
    mean <- first/probability
    covariance <- second/probability-mean[,pairs$i,drop=FALSE]*mean[,pairs$j,drop=FALSE]
    list(probability=probability,mean=mean,covariance=covariance)
  })
}

jml_count_derivative <- function(owner,beta) {
  cells <- expand.grid(Rater=1:2,Criterion=1:2); own <- cells[[owner]]
  sr <- c(1,-1)[cells$Rater]; sc <- c(1,-1)[cells$Criterion]
  sa <- c(1,-1)[own]; a <- exp(sa*beta[5])
  D <- matrix(0,8,5)
  D[1:4,1] <- -sr*a; D[1:4,2] <- -sc*a
  D[1:4,5] <- -sa*a*(sr*beta[1]+sc*beta[2])
  D[cbind(5:8,2+own)] <- -a; D[5:8,5] <- -sa*a*beta[2+own]
  D
}

make_jml_growth_roster <- function(owner,exposure,truth,ability,max_states=10000L) {
  dummy <- lapply(exposure,function(n) matrix(c(n,0,0),1,3))
  p <- make_jml_total_problem(owner,exposure,dummy,max_states=max_states)
  own <- expand.grid(Rater=1:2,Criterion=1:2)[[owner]]
  mom <- jml_count_moments(owner,exposure,truth)
  weight <- Reduce(`+`,Map(function(t,w) w*jml_total_mass(p,truth,t),ability,c(.25,.5,.25)))
  mean <- mom[[1]]$mean[p$totals[,1]+1,,drop=FALSE] +
    mom[[2]]$mean[p$totals[,2]+1,,drop=FALSE]
  omega <- matrix(0,8,8)
  for (g in 1:2) {
    # rowsum retains all integer states; arrange explicitly in numeric order.
    marginal <- rowsum(weight,p$totals[,g]+1,reorder=TRUE)[,1]
    omega <- omega+matrix(drop(crossprod(marginal,mom[[g]]$covariance)),8,8)
  }
  # Independently check the law of total covariance for cell totals/middle counts
  # against direct multinomial moments, including between-ability variation.
  cells <- expand.grid(Rater=1:2,Criterion=1:2)
  literal <- lapply(ability,function(t) {
    mu <- numeric(8); V <- matrix(0,8,8)
    for(j in 1:4) {
      a <- exp(c(1,-1)[own[j]]*truth[5])
      z <- a*((t-c(1,-1)[cells$Rater[j]]*truth[1]-c(1,-1)[cells$Criterion[j]]*truth[2])*(0:2)-c(0,truth[2+own[j]],0))
      prob <- exp(z-max(z)); prob <- prob/sum(prob)
      value <- cbind(0:2,c(0,1,0)); m <- drop(crossprod(prob,value))
      centered <- sweep(value,2,m); ix <- c(j,j+4)
      mu[ix] <- exposure[j]*m; V[ix,ix] <- exposure[j]*crossprod(centered,prob*centered)
    }
    list(mean=mu,covariance=V)
  })
  mu <- Reduce(`+`,Map(function(x,w) w*x$mean,literal,c(.25,.5,.25)))
  V <- Reduce(`+`,Map(function(x,w) w*(x$covariance+tcrossprod(x$mean-mu)),literal,c(.25,.5,.25)))
  centered <- sweep(mean,2,drop(crossprod(weight,mean)))
  covariance_error <- max(abs(omega+crossprod(centered,weight*centered)-V))/max(1,max(abs(V)))
  stopifnot(max(abs(mu-drop(crossprod(weight,mean))))<1e-9,covariance_error<1e-9)
  counts_mean <- function(table) {
    result <- matrix(0,p$total_states,8)
    for(j in 1:4) {
      count <- table[[own[j]]]$counts[p$totals[,own[j]]+1,3*(j-1)+(1:3),drop=FALSE]
      result[,j] <- drop(count %*% (0:2)); result[,4+j] <- count[,2]
    }
    result
  }
  stopifnot(max(abs(mean-counts_mean(p$conditional(truth))))<1e-9)
  evaluate <- function(beta,order) {
    z <- p$scores(beta,order)
    stopifnot(z$root_residual<1e-8,z$max_omitted_mass==0)
    D <- jml_count_derivative(owner,beta)
    # The theta part of the log-slope count derivative is fixed given owner
    # totals, so it cancels both in this difference and in the within-total meat.
    U <- z$conditional_raw-z$adjustment-(mean-counts_mean(p$conditional(beta)))%*%D
    U[c(1,nrow(U)),] <- 0
    mu <- drop(crossprod(weight,U)); centered <- sweep(U,2,mu)
    within <- crossprod(D,omega%*%D)
    between <- crossprod(centered,weight*centered)
    list(mean=mu,within=within,between=between,meat=within+between,
      conditional_score=U,profile_error=z$root_residual)
  }
  list(evaluate=evaluate,weight=weight,states=p$total_states,mean=mean,omega=omega,
    covariance_error=covariance_error)
}

make_jml_growth_equation <- function(owner,design,L,truth,order) {
  rosters <- lapply(seq_along(design$exposure),function(g)
    make_jml_growth_roster(owner,L*design$exposure[[g]],truth,design$ability[[g]]))
  components <- function(beta) lapply(rosters,function(p) p$evaluate(beta,order))
  average <- function(z,field) Reduce(`+`,Map(function(x,w) w*x[[field]],z,design$proportions))
  list(mean_score=function(beta) average(components(beta),'mean'),
    evaluate=function(beta) {
      z <- components(beta)
      list(mean=average(z,'mean'),meat=average(z,'meat'),within=average(z,'within'),
        between=average(z,'between'),rosters=z)
    },rosters=rosters)
}

jml_growth_root_case <- function(job,contract,growth) {
  id <- paste(job$Owner,job$Design,sep='-'); d <- contract$designs[[job$Design]]
  old <- readRDS(paste0('validation-results/jml-scope-challenge-20260927/',id,'-',job$Order,'.rds'))
  truth <- old$truth; k <- job$Order; L <- job$L
  eq <- make_jml_growth_equation(job$Owner,d,L,truth,k)
  checks <- c(count_covariance=max(vapply(eq$rosters,`[[`,0,'covariance_error')))
  if (L==1L) {
    attempts <- old$attempts # Reuse both reviewed roots; no original root refit.
    reference <- lapply(d$exposure,function(e) make_jml_roster_problem(job$Owner,e))
    exact <- make_jml_design_equation(reference,old$weights,d$proportions,k)
    for(beta in list(truth,contract$starts$opposing,attempts[[1]]$fit$beta)) {
      z <- eq$evaluate(beta)
      c <- jml_design_covariance(exact,beta,400,diag(5),'fixed_rosters')
      checks <- c(checks,mean=max(abs(z$mean-exact$mean_score(beta))),
        meat=max(abs(z$meat-c$meat)))
    }
    stopifnot(max(checks)<1e-8)
  } else {
    # Same declared starts and solver/fallbacks as the retained scope challenge.
    attempts <- lapply(contract$starts,function(start) {
      record <- jml_design_root(eq,k,start)
      if (!isTRUE(record$fit$reviewed)) {
        record$small_step <- tryCatch({
          z <- nleqslv::nleqslv(start,eq$mean_score,method='Newton',global='dbldog',
            control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=.25))
          A <- jml_sample_jacobian(eq$mean_score,z$x,5e-5)
          A1 <- jml_sample_jacobian(eq$mean_score,z$x,1e-4)
          residual <- max(abs(eq$mean_score(z$x))); singular <- min(svd(A,nu=0,nv=0)$d)
          error <- max(abs(A1-A))/max(1,max(abs(A)))
          list(beta=z$x,A=A,solver=z,residual=residual,min_singular=singular,
            jacobian_error=error,reviewed=residual<1e-7 && singular>1e-6 && error<1e-5)
        },error=function(e) list(reviewed=FALSE,error=conditionMessage(e)))
        record$fit <- record$small_step
      }
      record
    })
  }
  fits <- lapply(attempts,`[[`,'fit')
  reviewed <- all(vapply(fits,function(x) isTRUE(x$reviewed),TRUE))
  spread <- if(reviewed) max(abs(fits[[1]]$beta-fits[[2]]$beta)) else NA_real_
  reviewed <- reviewed && spread<1e-6
  status <- data.frame(job,Reviewed=reviewed,Spread=spread,row.names=NULL)
  result <- list(status=status,attempts=attempts,checks=checks)
  if (!reviewed) return(result)
  beta <- fits[[1]]$beta; A <- fits[[1]]$A
  if (L==1L) {
    Ac <- jml_sample_jacobian(eq$mean_score,beta,5e-5)
    result$checks <- c(result$checks,jacobian=max(abs(A-Ac))/max(1,max(abs(A))))
    stopifnot(tail(result$checks,1)<1e-5)
  }
  z <- eq$evaluate(beta); inverse <- solve(A)
  V <- inverse%*%z$meat%*%t(inverse)/400
  Vbetween <- inverse%*%z$between%*%t(inverse)/400
  if (L==1L) {
    result$checks <- c(result$checks,saved_covariance=max(abs(V-old$covariance$vcov))/max(abs(V)))
    stopifnot(tail(result$checks,1)<1e-8)
  }
  stopifnot(min(eigen(V,symmetric=TRUE)$values)>0,max(abs(z$mean))<1e-7)
  J <- growth[[id]]$information; limit <- solve(J)
  coefficients <- lapply(seq_along(d$exposure),function(g)
    lapply(d$ability[[g]],function(t) jml_expansion_coefficients(job$Owner,d$exposure[[g]],truth,t)))
  leading <- if(k==1L) -drop(solve(J,Reduce(`+`,lapply(seq_along(coefficients),function(g)
    d$proportions[g]*Reduce(`+`,Map(function(x,w) w*x$c1,coefficients[[g]],c(.25,.5,.25))))))) else rep(NA_real_,5)
  result$root <- beta; result$jacobian <- A; result$vcov <- V
  result$meat <- z[c('mean','meat','within','between')]
  result$rows <- data.frame(job,Parameter=names(truth),Truth=unname(truth),Root=unname(beta),
    Bias=unname(beta-truth),SE=sqrt(diag(V)),BiasOverSE=unname(abs(beta-truth)/sqrt(diag(V))),
    ScaledBias=unname(L^(k+1)*(beta-truth)),PredictedLeading=leading,
    ScaledVariance=400*L*diag(V),LimitVariance=diag(limit),
    MeanOnlySERatio=sqrt(diag(Vbetween)/diag(V)),row.names=NULL)
  result$diagnostics <- c(JacobianLimitError=max(abs(A/L-J))/max(abs(J)),
    MeatLimitError=max(abs(z$meat/L-J))/max(abs(J)),
    CovarianceLimitError=max(abs(400*L*V-limit))/max(abs(limit)),
    JacobianAsymmetry=max(abs(A-t(A)))/max(abs(A)),Residual=max(abs(z$mean)),
    JacobianRefinement=max(vapply(fits,`[[`,0,'jacobian_error')))
  result
}

run_jml_growth_roots <- function(out,mode) {
  stopifnot(mode %in% c('preflight','pilot','run'))
  scope <- 'validation-results/jml-scope-challenge-20260927'
  contract <- readRDS(file.path(scope,'contract.rds'))
  growth_file <- 'validation-results/jml-centering-identification-20260930-final/results.rds'
  growth <- readRDS(growth_file)$growth
  jobs <- expand.grid(Owner=c('Criterion','Rater'),Design=c('sparse','unequal'),
    Order=1:2,L=c(1L,2L,4L,8L,16L),stringsAsFactors=FALSE)
  sources <- paste0('inst/validation/',c('jml-exposure-roots-20261001.R',
    'jml-exposure-expansion-20260930.R','jml-total-expectation-20260927.R',
    'jml-design-adjustment-20260927.R','jml-profile-bias-sample-20260927.R',
    'jml-profile-bias-exact-20260927.R'))
  inputs <- c(file.path(scope,'contract.rds'),growth_file,unique(file.path(scope,
    paste0(jobs$Owner,'-',jobs$Design,'-',jobs$Order,'.rds'))))
  hashes <- tools::md5sum(c(inputs,sources))
  manifest <- list(jobs=jobs,N=400L,hashes=hashes,session=capture.output(sessionInfo()),
    policy='Two saved starts; same solver/fallbacks and review gates; fixed roster covariance; no state pruning')
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  if(file.exists(file.path(out,'manifest.rds'))) {
    stopifnot(identical(readRDS(file.path(out,'manifest.rds'))$hashes,hashes))
  } else {
    saveRDS(manifest,file.path(out,'manifest.rds'))
    for(file in names(hashes)) {
      dest <- file.path(out,'source',file); dir.create(dirname(dest),recursive=TRUE,showWarnings=FALSE)
      stopifnot(file.copy(file,dest))
    }
  }
  selected <- if(mode=='preflight') which(jobs$L==1) else if(mode=='pilot')
    which(jobs$Owner=='Criterion' & jobs$Design=='unequal' & jobs$Order==2 & jobs$L==8) else seq_len(nrow(jobs))
  for(i in selected) {
    job <- jobs[i,]; name <- paste(job,collapse='-'); path <- file.path(out,paste0(name,'.rds'))
    if(file.exists(path)) {stopifnot(identical(readRDS(path)$hashes,hashes)); next}
    time <- system.time(z <- jml_growth_root_case(job,contract,growth))[['elapsed']]
    z$seconds <- time; z$hashes <- hashes
    stopifnot(identical(hashes,tools::md5sum(names(hashes))))
    saveRDS(z,paste0(path,'.tmp')); stopifnot(file.rename(paste0(path,'.tmp'),path))
    cat(name,'reviewed',z$status$Reviewed,'seconds',time,'\n'); flush.console()
  }
  if(mode=='run') {
    saved <- lapply(seq_len(nrow(jobs)),function(i) readRDS(file.path(out,paste0(paste(jobs[i,],collapse='-'),'.rds'))))
    status <- do.call(rbind,lapply(saved,`[[`,'status')); rows <- do.call(rbind,lapply(saved,`[[`,'rows'))
    write.csv(status,file.path(out,'status.csv'),row.names=FALSE)
    write.csv(rows,file.path(out,'parameters.csv'),row.names=FALSE)
    saveRDS(list(status=status,seconds=sum(vapply(saved,`[[`,0,'seconds')),hashes=hashes),file.path(out,'completion.rds'))
    print(status,row.names=FALSE)
  }
}
if(sys.nframe()==0L) {
  args <- commandArgs(trailingOnly=TRUE); stopifnot(length(args)==2L)
  run_jml_growth_roots(args[1],args[2])
}
