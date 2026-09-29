source('inst/validation/jml-design-adjustment-20260927.R')
source('inst/validation/jml-total-expectation-20260927.R')
out <- 'validation-results/jml-total-expectation-20260927'
if(file.exists(file.path(out,'equivalence.rds'))) stop('Refusing to overwrite evidence.')
dir.create(out,recursive=TRUE,showWarnings=FALSE)
rows <- list(); checks <- c(); details <- list()
exposures <- list(complete4=rep(1,4),complete8=rep(2,4),sparse5=c(2,1,0,2),unequal4=c(2,1,0,1))
for(owner in c('Criterion','Rater')) for(d in names(exposures)) {
  old <- make_jml_roster_problem(owner,exposures[[d]])
  total <- make_jml_total_problem(owner,exposures[[d]],old$counts)
  for(point in c('benchmark','opposing')) {
    beta <- if(point=='benchmark') old$truth else c(-.3,.4,-.3,-1.1,-.25)
    a <- old$evaluate(beta); b <- total$evaluate(beta)
    checks <- c(checks,max(abs(a$q-b$q))<1e-8,max(abs(a$gradient-b$gradient))<1e-8)
    # Independent grouping of the full response masses checks the theta cancellation.
    conditional_error <- 0
    for(theta in c(-1,0,1)) {
      mass <- drop(old$mass(beta,theta))
      numerator <- rowsum(mass*a$gradient,total$group,reorder=FALSE)
      denominator <- rowsum(mass,total$group,reorder=FALSE)
      mean <- numerator/drop(denominator)
      grouped <- total$scores(beta,0L)$conditional_raw[as.integer(rownames(mean)),,drop=FALSE]
      conditional_error <- max(conditional_error,max(abs(mean-grouped)))
    }
    for(k in c(0L,1L,2L,4L)) {
      a <- old$scores(beta,k)$value; b <- total$scores(beta,k)$value
      error <- max(abs(a-b))
      row <- data.frame(Owner=owner,Design=d,Point=point,Order=k,
        ResponsePatterns=old$n,TotalStates=total$total_states,
        ScoreError=error,ConditionalError=conditional_error)
      rows[[paste(owner,d,point,k)]] <- row
      checks <- c(checks,error<1e-8,conditional_error<1e-8,all(b[total$extreme,]==0))
    }
  }
}
print(do.call(rbind,rows),row.names=FALSE); flush.console()
# Source-identical existing roots: preserve actual observed counts, not mean counts.
input <- 'validation-results/jml-design-adjustment-20260927'
original <- readRDS(file.path(input,'results.rds'))
unequal <- readRDS(file.path(input,'unequal.rds'))
repaired <- readRDS(file.path(input,'unequal-followup.rds'))
comparisons <- list()
for(d in c('complete','sparse','unequal')) {
  exposures <- switch(d,complete=list(rep(2,4)),sparse=list(c(2,1,0,2),c(0,2,2,1)),
    unequal=list(c(2,1,0,1),c(0,2,2,2)))
  ps <- lapply(exposures,function(e) make_jml_roster_problem('Criterion',e))
  cs <- lapply(ps,function(p) make_jml_total_problem('Criterion',p$exposure,p$counts))
  for(k in c(1L,4L)) {
    if(d=='unequal') {
      record <- repaired$results[[as.character(k)]]
      beta <- record$solver$x; weights <- unequal$weights; prop <- unequal$proportions
    } else {
      record <- original[[paste(d,'sample',k,sep='-')]]
      beta <- record$attempts[[1]]$fit$beta; weights <- record$weights; prop <- record$proportions
    }
    exact <- make_jml_design_equation(ps,weights,prop,k)
    compressed <- make_jml_design_equation(cs,weights,prop,k)
    error <- max(abs(exact$mean_score(beta)-compressed$mean_score(beta)))
    jacobian_errors <- c()
    for(h in c(1e-4,5e-5)) {
      A <- jml_sample_jacobian(exact$mean_score,beta,h)
      Ac <- jml_sample_jacobian(compressed$mean_score,beta,h)
      jacobian_errors <- c(jacobian_errors,max(abs(A-Ac))/max(1,max(abs(A))))
    }
    cov <- jml_design_covariance(exact,beta,400,A,'fixed_rosters')
    ccov <- jml_design_covariance(compressed,beta,400,Ac,'fixed_rosters')
    covariance_error <- max(abs(cov$vcov-ccov$vcov))/max(abs(cov$vcov))
    comparisons[[paste(d,k)]] <- data.frame(Design=d,Order=k,ScoreError=error,
      JacobianError=max(jacobian_errors),CovarianceError=covariance_error)
    checks <- c(checks,error<1e-8,all(jacobian_errors<1e-5),covariance_error<1e-5)
  }
}
# Timing comparison at one identical complete 8-rating problem; no extrapolation.
p <- make_jml_roster_problem('Criterion',rep(2,4))
c <- make_jml_total_problem('Criterion',rep(2,4),p$counts)
timings <- data.frame(Repeat=1:3,Enumeration=NA_real_,Totals=NA_real_)
for(i in 1:3) {
  timings$Enumeration[i] <- system.time(p$scores(p$truth,4L))[['elapsed']]
  timings$Totals[i] <- system.time(c$scores(p$truth,4L))[['elapsed']]
}
saveRDS(list(rows=rows,comparisons=comparisons,checks=checks,timings=timings),file.path(out,'equivalence.rds'))
write.csv(do.call(rbind,rows),file.path(out,'equivalence.csv'),row.names=FALSE)
write.csv(do.call(rbind,comparisons),file.path(out,'covariance-equivalence.csv'),row.names=FALSE)
write.csv(timings,file.path(out,'timings.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
print(do.call(rbind,comparisons),row.names=FALSE); print(timings,row.names=FALSE)
stopifnot(all(checks))
