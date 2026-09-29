source('inst/validation/jml-design-adjustment-20260927.R')
source('inst/validation/jml-total-expectation-20260927.R')
out <- 'validation-results/jml-total-expectation-20260927'
if(file.exists(file.path(out,'sample.rds'))) stop('Refusing to overwrite evidence.')
equivalence <- readRDS(file.path(out,'equivalence.rds'))
stopifnot(all(equivalence$checks))
N <- 400L; exposure <- rep(8L,4L)
truth <- c(.3,-.4,-.6,-.9,.25)
cells <- expand.grid(Rater=1:2,Criterion=1:2)
sr <- c(1,-1)[cells$Rater]; sc <- c(1,-1)[cells$Criterion]; owner <- cells$Criterion
set.seed(272001L)
theta <- sample(c(-1,0,1),N,replace=TRUE,prob=c(.25,.5,.25))
counts <- lapply(1:4,function(j) {
  a <- exp(c(1,-1)[owner[j]]*truth[5])
  t(vapply(theta,function(t) {
    z <- a*((t-sr[j]*truth[1]-sc[j]*truth[2])*(0:2)-c(0,truth[2+owner[j]],0))
    p <- exp(z-max(z)); p <- p/sum(p)
    as.numeric(rmultinom(1,exposure[j],p))
  },numeric(3)))
})
saveRDS(list(exposure=exposure,counts=counts,seed=272001L),file.path(out,'observed-counts.rds'))
# Generating abilities and truth are never passed to the problem, solver or covariance.
p <- make_jml_total_problem('Criterion',exposure,counts)
weights <- list(rep(1/N,N))
starts <- list(neutral=c(0,0,-.8,-.8,0),opposing=c(-.3,.4,-.3,-1.1,-.25))
checks <- c(inherits(try(make_jml_roster_problem('Criterion',exposure),silent=TRUE),'try-error'),
  p$total_states==1089L,all(vapply(counts,function(x)all(rowSums(x)==8),logical(1))))
results <- list(); rows <- list()
for(k in c(1L,4L)) {
  eq <- make_jml_design_equation(list(p),weights,1,k)
  attempts <- list()
  elapsed <- system.time({
    for(s in names(starts)) {
      initial <- jml_design_root(eq,k,starts[[s]])
      attempt <- list(initial=initial,fit=initial$fit)
      if(!initial$fit$reviewed) {
        fallback <- tryCatch({
          z <- nleqslv::nleqslv(starts[[s]],eq$mean_score,method='Newton',global='dbldog',
            control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=.25))
          A <- jml_sample_jacobian(eq$mean_score,z$x,5e-5)
          A1 <- jml_sample_jacobian(eq$mean_score,z$x,1e-4)
          residual <- max(abs(eq$mean_score(z$x)))
          singular <- min(svd(A,nu=0,nv=0)$d)
          error <- max(abs(A1-A))/max(1,max(abs(A)))
          list(beta=z$x,A=A,residual=residual,min_singular=singular,
            jacobian_error=error,solver=z,
            reviewed=residual<1e-7 && singular>1e-6 && error<1e-5)
        },error=function(e)list(reviewed=FALSE,error=conditionMessage(e)))
        attempt$smaller_step <- fallback; attempt$fit <- fallback
      }
      attempts[[s]] <- attempt
      saveRDS(attempt,file.path(out,paste0('sample-order-',k,'-',s,'.rds')))
      cat('Order',k,s,'reviewed',attempt$fit$reviewed,'\n'); flush.console()
    }
  })[['elapsed']]
  fits <- lapply(attempts,`[[`,'fit')
  ok <- all(vapply(fits,`[[`,logical(1),'reviewed'))
  spread <- if(ok)max(abs(fits[[1]]$beta-fits[[2]]$beta)) else NA_real_
  ok <- ok && spread<1e-6
  row <- data.frame(Order=k,Reviewed=ok,StartSpread=spread,Persons=N,Ratings=32L,
    TotalStates=p$total_states,CountPatterns=45^4,Seconds=elapsed,
    LogSlope=NA_real_,LogSlopeSE=NA_real_,GradientError=NA_real_,InfluenceError=NA_real_)
  record <- list(attempts=attempts)
  if(ok) {
    fit <- fits[[1]]
    covariance <- jml_design_covariance(eq,fit$beta,N,fit$A,'fixed_rosters')
    numerical <- jml_sample_jacobian(function(b)p$evaluate(b)$q,fit$beta,1e-5)
    gradient_error <- max(abs(numerical-p$evaluate(fit$beta)$gradient))
    checks <- c(checks,gradient_error<1e-7)
    influence <- -t(solve(fit$A,t(covariance$centered[[1]])))
    checks <- c(checks,max(abs(crossprod(influence)/N^2-covariance$vcov))<1e-10,
      all(covariance$scores[[1]]$value[p$extreme,]==0))
    ix <- which.max(rowSums(influence^2))
    direction <- -weights[[1]]; direction[ix] <- direction[ix]+1
    refits <- list()
    for(h in c(1e-5,5e-6)) {
      plus <- minus <- weights
      plus[[1]] <- plus[[1]]+h*direction; minus[[1]] <- minus[[1]]-h*direction
      ep <- make_jml_design_equation(list(p),plus,1,k)
      em <- make_jml_design_equation(list(p),minus,1,k)
      fp <- jml_design_root(ep,k,fit$beta); fm <- jml_design_root(em,k,fit$beta)
      delta <- (fp$fit$beta-fm$fit$beta)/(2*h)
      error <- max(abs(delta-influence[ix,]))/max(1,max(abs(influence[ix,])))
      checks <- c(checks,fp$fit$reviewed,fm$fit$reviewed,error<1e-3)
      refits[[as.character(h)]] <- list(plus=fp,minus=fm,error=error)
    }
    row$LogSlope <- fit$beta[5]; row$LogSlopeSE <- sqrt(covariance$vcov[5,5])
    row$GradientError <- gradient_error
    row$InfluenceError <- max(vapply(refits,`[[`,numeric(1),'error'))
    record$covariance <- covariance; record$refits <- refits
  }
  record$summary <- row; results[[as.character(k)]] <- record; rows[[as.character(k)]] <- row
  saveRDS(record,file.path(out,paste0('sample-order-',k,'.rds')))
  print(row,row.names=FALSE); flush.console()
}
saveRDS(list(results=results,checks=checks,weights=weights),file.path(out,'sample.rds'))
write.csv(do.call(rbind,rows),file.path(out,'sample.csv'),row.names=FALSE)
stopifnot(all(checks),all(vapply(results,function(x)x$summary$Reviewed,logical(1))))
