# Targeted failure review; preserve the initial failed two-start gate.
source('inst/validation/jml-design-adjustment-20260927.R')
out <- 'validation-results/jml-design-adjustment-20260927'
if(file.exists(file.path(out,'unequal-followup.rds'))) stop('Refusing to overwrite evidence.')
x <- readRDS(file.path(out,'unequal.rds'))
ps <- list(make_jml_roster_problem('Criterion',c(2,1,0,1)),
           make_jml_roster_problem('Criterion',c(0,2,2,2)))
results <- list(); rows <- list(); checks <- c()
for(k in c(1L,4L)) {
  eq <- make_jml_design_equation(ps,x$weights,x$proportions,k)
  # The failed original start takes large steps towards weak-slope regions.
  # Try a smaller trust-region step; no truth or successful-root warm start.
  z <- nleqslv::nleqslv(c(-.3,.4,-.3,-1.1,-.25),eq$mean_score,
    method='Newton',global='dbldog',
    control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=.25))
  A1 <- jml_sample_jacobian(eq$mean_score,z$x,1e-4)
  A <- jml_sample_jacobian(eq$mean_score,z$x,5e-5)
  residual <- max(abs(eq$mean_score(z$x)))
  singular <- min(svd(A,nu=0,nv=0)$d)
  error <- max(abs(A1-A))/max(1,max(abs(A)))
  neutral <- x$results[[as.character(k)]]$attempts$neutral$fit
  spread <- max(abs(z$x-neutral$beta))
  ok <- residual<1e-7 && singular>1e-6 && error<1e-5 && neutral$reviewed && spread<1e-6
  row <- data.frame(Order=k,Reviewed=ok,Residual=residual,MinSingular=singular,
    JacobianError=error,StartSpread=spread,LogSlope=z$x[5],LogSlopeSE=NA_real_,
    InfluenceError=NA_real_)
  record <- list(solver=z,A=A)
  if(ok) {
    covariance <- jml_design_covariance(eq,z$x,400,A,'fixed_rosters')
    expanded <- do.call(rbind,lapply(1:2,function(i)
      covariance$centered[[i]][x$ids[[i]],,drop=FALSE]))
    IF <- -t(solve(A,t(expanded)))
    checks <- c(checks,max(abs(crossprod(IF)/400^2-covariance$vcov))<1e-10)
    for(p in ps) checks <- c(checks,max(abs(jml_sample_jacobian(
      function(b) p$evaluate(b)$q,z$x,1e-5)-p$evaluate(z$x)$gradient))<1e-7)
    influence <- -t(solve(A,t(covariance$centered[[1]])))
    ix <- which.max(rowSums(influence^2)*(x$weights[[1]]>0))
    direction <- -x$weights[[1]]; direction[ix] <- direction[ix]+1
    refits <- list()
    for(h in c(1e-5,5e-6)) {
      plus <- minus <- x$weights
      plus[[1]] <- plus[[1]]+h*direction; minus[[1]] <- minus[[1]]-h*direction
      fp <- jml_design_root(make_jml_design_equation(ps,plus,x$proportions,k),k,z$x)
      fm <- jml_design_root(make_jml_design_equation(ps,minus,x$proportions,k),k,z$x)
      predicted <- x$proportions[1]*influence[ix,]
      discrepancy <- max(abs((fp$fit$beta-fm$fit$beta)/(2*h)-predicted))/max(1,max(abs(predicted)))
      checks <- c(checks,fp$fit$reviewed,fm$fit$reviewed,discrepancy<1e-3)
      refits[[as.character(h)]] <- list(plus=fp,minus=fm,error=discrepancy)
    }
    row$LogSlopeSE <- sqrt(covariance$vcov[5,5])
    row$InfluenceError <- max(vapply(refits,`[[`,numeric(1),'error'))
    record$covariance <- covariance; record$refits <- refits
  }
  record$summary <- row; results[[as.character(k)]] <- record; rows[[as.character(k)]] <- row
  saveRDS(record,file.path(out,paste0('unequal-followup-',k,'.rds')))
  print(row,row.names=FALSE); flush.console()
}
saveRDS(list(results=results,checks=checks),file.path(out,'unequal-followup.rds'))
write.csv(do.call(rbind,rows),file.path(out,'unequal-followup.csv'),row.names=FALSE)
stopifnot(all(checks),all(vapply(results,function(x)x$summary$Reviewed,logical(1))))
