# Deterministic approximation audit against the design-aware exact reference.
source('inst/validation/jml-design-adjustment-20260927.R')
args <- commandArgs(trailingOnly=TRUE)
out <- if(length(args)) args[[1]] else 'validation-results/jml-design-adjustment-20260927'
if(file.exists(file.path(out,'approximation.rds'))) stop('Refusing to overwrite evidence.')
results <- readRDS(file.path(out,'results.rds'))
design <- list(complete=list(make_jml_roster_problem('Criterion',rep(2,4))),
  sparse=list(make_jml_roster_problem('Criterion',c(2,1,0,2)),
              make_jml_roster_problem('Criterion',c(0,2,2,1))))
checks <- c(); rows <- list(); details <- list()
for(d in names(design)) for(k in c(1L,4L)) {
  record <- results[[paste(d,'sample',k,sep='-')]]
  if(!record$summary$Reviewed) stop('No reviewed exact root for approximation audit.')
  beta <- record$attempts[[1]]$fit$beta
  ps <- design[[d]]; weights <- record$weights; prop <- record$proportions
  exact <- make_jml_design_equation(ps,weights,prop,k)
  A <- jml_sample_jacobian(exact$mean_score,beta,5e-5)
  V <- jml_design_covariance(exact,beta,400,A,'fixed_rosters')$vcov
  se <- sqrt(diag(V)); inverse <- solve(A)
  # Direct response-pattern derivative against analytic profile gradient, sparse too.
  for(p in ps) {
    numerical <- jml_sample_jacobian(function(b) p$evaluate(b)$q,beta,1e-5)
    checks <- c(checks,max(abs(numerical-p$evaluate(beta)$gradient))<1e-7)
    checks <- c(checks,max(abs(p$scores(beta,k,block_size=1)$value-
      p$scores(beta,k,block_size=16)$value))<1e-11)
    # Count patterns reconstruct the ordered-response likelihood mass.
    checks <- c(checks,abs(sum(exp(p$log_multiplicity))-3^sum(p$exposure))<1e-7)
  }
  for(epsilon in c(1e-3,1e-6,1e-10,1e-14)) {
    approximate <- make_jml_design_equation(ps,weights,prop,k,epsilon)
    ap <- approximate$components(beta); ex <- exact$components(beta)
    for(i in seq_along(ps)) checks <- c(checks,all(apply(abs(
      ap[[i]]$value-ex[[i]]$value),2,max)<=ap[[i]]$error_bound+1e-10))
    score_error <- abs(approximate$mean_score(beta)-exact$mean_score(beta))
    score_bound <- approximate$bound(beta)
    jacobians <- list(); jacobian_bounds <- list()
    for(h in c(1e-4,5e-5)) {
      Aa <- jml_sample_jacobian(approximate$mean_score,beta,h)
      Ae <- jml_sample_jacobian(exact$mean_score,beta,h)
      bound <- vapply(seq_along(beta),function(j) {
        lo <- hi <- beta; lo[j] <- lo[j]-h; hi[j] <- hi[j]+h
        (approximate$bound(lo)+approximate$bound(hi))/(2*h)
      },numeric(length(beta)))
      checks <- c(checks,all(abs(Aa-Ae)<=bound+1e-10))
      jacobians[[as.character(h)]] <- Aa
      jacobian_bounds[[as.character(h)]] <- bound
    }
    Aa <- jacobians[['5e-05']]; Da <- jacobian_bounds[['5e-05']]
    Va <- try(jml_design_covariance(approximate,beta,400,Aa,'fixed_rosters')$vcov,silent=TRUE)
    covariance_error <- if(inherits(Va,'try-error')) Inf else max(abs(Va-V))/max(abs(V))
    sensitivity <- max(rowSums(abs(inverse)%*%Da))
    score_se <- max(drop(abs(inverse)%*%score_bound)/se)
    error <- max(abs(Aa-A)); bound <- max(Da)
    row <- data.frame(Design=d,Order=k,OmitMass=epsilon,
      ActualMaxOmittedMass=max(vapply(ap,`[[`,numeric(1),'max_omitted_mass')),
      ScoreError=max(score_error),ScoreBound=max(score_bound),
      JacobianError=error,JacobianBound=bound,
      JacobianStepDifference=max(abs(jacobians[['1e-04']]-Aa))/max(1,max(abs(Aa))),
      RelativeJacobianBound=sensitivity,ScoreBoundOverSE=score_se,
      RelativeCovarianceError=covariance_error,
      Eligible=sensitivity<.01 && score_se<.01 && covariance_error<.01)
    id <- paste(d,k,epsilon,sep='-'); rows[[id]] <- row
    details[[id]] <- list(summary=row,beta=beta,approximate_covariance=Va,
      exact_covariance=V,jacobians=jacobians,jacobian_bounds=jacobian_bounds,
      score_bound=score_bound,score_error=score_error)
    print(row,row.names=FALSE); flush.console()
  }
}
# Perturb actual within-roster empirical frequencies and re-solve (sparse k=4).
record <- results[['sparse-sample-4']]; ps <- design$sparse
beta <- record$attempts[[1]]$fit$beta
exact <- make_jml_design_equation(ps,record$weights,record$proportions,4L)
fit <- record$attempts[[1]]$fit
cov <- jml_design_covariance(exact,beta,400,fit$A,'fixed_rosters')
i <- 1L; weights <- record$weights; U <- cov$scores[[i]]$value
influence <- -t(solve(fit$A,t(sweep(U,2,cov$means[[i]]))))
ix <- which.max(rowSums(influence^2)*(weights[[i]]>0))
direction <- -weights[[i]]; direction[ix] <- direction[ix]+1
perturbations <- list()
for(h in c(1e-5,5e-6)) {
  plus <- minus <- weights
  plus[[i]] <- plus[[i]]+h*direction; minus[[i]] <- minus[[i]]-h*direction
  ep <- make_jml_design_equation(ps,plus,record$proportions,4L)
  em <- make_jml_design_equation(ps,minus,record$proportions,4L)
  fp <- jml_design_root(ep,4L,beta); fm <- jml_design_root(em,4L,beta)
  predicted <- record$proportions[i]*influence[ix,]
  error <- max(abs((fp$fit$beta-fm$fit$beta)/(2*h)-predicted))/max(1,max(abs(predicted)))
  checks <- c(checks,fp$fit$reviewed,fm$fit$reviewed,error<1e-3)
  perturbations[[as.character(h)]] <- list(plus=fp,minus=fm,error=error,predicted=predicted)
}
saveRDS(list(details=details,perturbations=perturbations,checks=checks),file.path(out,'approximation.rds'))
write.csv(do.call(rbind,rows),file.path(out,'approximation.csv'),row.names=FALSE)
stopifnot(all(checks))
