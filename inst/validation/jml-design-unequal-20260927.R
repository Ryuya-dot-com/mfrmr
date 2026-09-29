source('inst/validation/jml-design-adjustment-20260927.R')
out <- 'validation-results/jml-design-adjustment-20260927'
if(file.exists(file.path(out,'unequal.rds'))) stop('Refusing to overwrite evidence.')
ps <- list(make_jml_roster_problem('Criterion',c(2,1,0,1)),
           make_jml_roster_problem('Criterion',c(0,2,2,2)))
N <- c(240L,160L); prop <- N/sum(N)
set.seed(271903L)
ids <- lapply(seq_along(ps),function(i) sample.int(ps[[i]]$n,N[i],replace=TRUE,
  prob=drop(ps[[i]]$mass(ps[[i]]$truth,c(-1,0,1))%*%c(.25,.5,.25))))
weights <- lapply(seq_along(ps),function(i) tabulate(ids[[i]],ps[[i]]$n)/N[i])
# Expand actual observed scores, with no synthetic entries for unassigned cells.
cells <- expand.grid(Rater=1:2,Criterion=1:2)
responses <- do.call(rbind,lapply(seq_along(ps),function(i) do.call(rbind,
  lapply(seq_along(ids[[i]]),function(person) do.call(rbind,lapply(1:4,function(j) {
    score <- rep(0:2,ps[[i]]$counts[[j]][ids[[i]][person],])
    if(!length(score)) return(NULL)
    data.frame(Roster=i,Person=person+if(i==1L) 0L else N[1],
      Rater=cells$Rater[j],Criterion=cells$Criterion[j],Score=score)
  }))))))
write.csv(responses,file.path(out,'unequal-responses.csv'),row.names=FALSE)
checks <- c(nrow(responses)==sum(N*c(4L,6L)),
  all(as.numeric(table(responses$Person))==rep(c(4L,6L),N)))
starts <- list(neutral=c(0,0,-.8,-.8,0),opposing=c(-.3,.4,-.3,-1.1,-.25))
results <- list(); rows <- list()
for(k in c(1L,4L)) {
  eq <- make_jml_design_equation(ps,weights,prop,k)
  attempts <- lapply(starts,function(start) jml_design_root(eq,k,start))
  fits <- lapply(attempts,`[[`,'fit')
  ok <- all(vapply(fits,`[[`,logical(1),'reviewed'))
  spread <- if(ok) max(abs(fits[[1]]$beta-fits[[2]]$beta)) else NA_real_
  ok <- ok && spread<1e-6
  row <- data.frame(Order=k,Reviewed=ok,StartSpread=spread,
    LogSlope=NA_real_,LogSlopeSE=NA_real_,InfluenceError=NA_real_)
  result <- list(attempts=attempts)
  if(ok) {
    fit <- fits[[1]]
    cov <- jml_design_covariance(eq,fit$beta,sum(N),fit$A,'fixed_rosters')
    expanded <- do.call(rbind,lapply(seq_along(ps),function(i)
      cov$centered[[i]][ids[[i]],,drop=FALSE]))
    IF <- -t(solve(fit$A,t(expanded)))
    checks <- c(checks,max(abs(crossprod(IF)/sum(N)^2-cov$vcov))<1e-10)
    for(p in ps) checks <- c(checks,max(abs(jml_sample_jacobian(
      function(b) p$evaluate(b)$q,fit$beta,1e-5)-p$evaluate(fit$beta)$gradient))<1e-7)
    # Move empirical frequency within the first roster; roster proportions stay fixed.
    influence <- -t(solve(fit$A,t(cov$centered[[1]])))
    ix <- which.max(rowSums(influence^2)*(weights[[1]]>0))
    direction <- -weights[[1]]; direction[ix] <- direction[ix]+1
    refits <- list()
    for(h in c(1e-5,5e-6)) {
      plus <- minus <- weights
      plus[[1]] <- plus[[1]]+h*direction; minus[[1]] <- minus[[1]]-h*direction
      fp <- jml_design_root(make_jml_design_equation(ps,plus,prop,k),k,fit$beta)
      fm <- jml_design_root(make_jml_design_equation(ps,minus,prop,k),k,fit$beta)
      predicted <- prop[1]*influence[ix,]
      error <- max(abs((fp$fit$beta-fm$fit$beta)/(2*h)-predicted))/max(1,max(abs(predicted)))
      checks <- c(checks,fp$fit$reviewed,fm$fit$reviewed,error<1e-3)
      refits[[as.character(h)]] <- list(plus=fp,minus=fm,error=error)
    }
    row$LogSlope <- fit$beta[5]; row$LogSlopeSE <- sqrt(cov$vcov[5,5])
    row$InfluenceError <- max(vapply(refits,`[[`,numeric(1),'error'))
    result$covariance <- cov; result$refits <- refits
  }
  rownames(row) <- NULL
  result$summary <- row; results[[as.character(k)]] <- result
  rows[[as.character(k)]] <- row
  print(row,row.names=FALSE); flush.console()
}
saveRDS(list(results=results,checks=checks,weights=weights,ids=ids,proportions=prop),
  file.path(out,'unequal.rds'))
write.csv(do.call(rbind,rows),file.path(out,'unequal.csv'),row.names=FALSE)
stopifnot(all(checks),all(vapply(results,function(x) x$summary$Reviewed,logical(1))))
