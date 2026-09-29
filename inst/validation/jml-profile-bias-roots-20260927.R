# Population estimating-equation roots using the exact retained response space.
# Not finite-sample calibration bias, coverage, or a public estimator.
# Rscript inst/validation/jml-profile-bias-roots-20260927.R [output-directory]
source('inst/validation/jml-profile-bias-exact-20260927.R')
if (!requireNamespace('nleqslv', quietly = TRUE)) stop('Install nleqslv for this local validation.')
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else 'validation-results/jml-profile-bias-roots-20260927'
# Existing initial checkpoints are reused; follow-ups retain the failed attempts.
dir.create(out, recursive = TRUE, showWarnings = FALSE)
conditions <- expand.grid(Owner = c('Criterion','Rater'), Repeats = 1:2,
  stringsAsFactors = FALSE)
# Same truth, response designs and ability locations as the exact-score review.
# Fix the population distribution before solving; it is not fitted by JML.
ability <- c(-1, 0, 1); mixing <- c(.25, .5, .25)
starts <- list(truth = c(.3,-.4,-.6,-.9,.25),
  neutral = c(0,0,-.8,-.8,0), opposing = c(-.3,.4,-.3,-1.1,-.25))
jacobian <- function(fn, par, h) vapply(seq_along(par), function(j) {
  lo <- hi <- par; lo[j] <- lo[j] - h; hi[j] <- hi[j] + h
  (fn(hi)-fn(lo))/(2*h)
}, numeric(length(fn(par))))
results <- list(); rows <- list()
for (i in seq_len(nrow(conditions))) {
  owner <- conditions$Owner[i]; repeats <- conditions$Repeats[i]
  p <- make_jml_exact_problem(owner,repeats)
  weights <- drop(p$mass(p$truth,ability) %*% mixing)
  stopifnot(abs(sum(weights)-1)<1e-12)
  # The factory refactor must reproduce the original saved per-pattern gradients
  # and one-step correction before any root result is trusted.
  old <- readRDS('validation-results/jml-profile-bias-exact-20260927-plugin/results.rds')[[i]]
  for (adjusted in c(FALSE,TRUE)) {
    original <- if(adjusted) old$plugin_adjusted_gradient else old$profile_gradient
    stopifnot(max(abs(p$mean_score(p$truth,weights,adjusted) -
      drop(crossprod(weights,original)))) < 1e-12)
    fn <- function(beta) p$mean_score(beta,weights,adjusted)
    method <- if(adjusted) 'one_step' else 'raw'
    for (start in names(starts)) {
      id <- paste(owner,4*repeats,method,start,sep='-')
      checkpoint <- file.path(out,paste0(id,'.rds'))
      if (file.exists(checkpoint)) {
        results[[id]] <- readRDS(checkpoint)
        rows[[id]] <- results[[id]]$summary
        next
      }
      elapsed <- system.time({
        z <- tryCatch(nleqslv::nleqslv(starts[[start]],fn,method='Newton',
          global='dbldog',control=list(ftol=1e-9,xtol=1e-10,maxit=100,stepmax=1)),
          error=function(e) list(error=conditionMessage(e)))
      })[['elapsed']]
      if (is.null(z$error)) {
        value <- fn(z$x)
        J1 <- jacobian(fn,z$x,1e-4); J2 <- jacobian(fn,z$x,5e-5)
        singular <- svd(J2,nu=0,nv=0)$d
        jac_error <- max(abs(J1-J2))/max(1,max(abs(J2)))
        alpha <- z$x[5]; slope <- exp(c(alpha,-alpha))
        truth_slopes <- exp(c(p$truth[5],-p$truth[5]))
        row <- data.frame(Owner=owner,Ratings=4*repeats,Method=method,Start=start,
          Termination=z$termcd,ScoreSupNorm=max(abs(value)),
          MinJacobianSingularValue=min(singular),
          JacobianCondition=max(singular)/min(singular),JacobianStepError=jac_error,
          JacobianAsymmetry=max(abs(J2-t(J2))),
          MinSymmetricJacobianEigenvalue=min(eigen((J2+t(J2))/2,symmetric=TRUE)$values),
          RootReviewed=max(abs(value))<1e-7 && min(singular)>1e-6 && jac_error<1e-5,
          Rater=z$x[1],Criterion=z$x[2],Step1=z$x[3],Step2=z$x[4],LogSlope=alpha,
          LogSlopeDisplacement=alpha-p$truth[5],
          MaxRelativeSlopeDisplacement=max(abs(slope-truth_slopes)),
          MaxStructuralDisplacement=max(abs(z$x-p$truth)),
          Iterations=z$iter,Seconds=elapsed,Error=NA_character_)
        z$independent_jacobians <- list(h1e4=J1,h5e5=J2)
      } else {
        row <- data.frame(Owner=owner,Ratings=4*repeats,Method=method,Start=start,
          Termination=NA_integer_,ScoreSupNorm=NA_real_,MinJacobianSingularValue=NA_real_,
          JacobianCondition=NA_real_,JacobianStepError=NA_real_,JacobianAsymmetry=NA_real_,
          MinSymmetricJacobianEigenvalue=NA_real_,RootReviewed=FALSE,
          Rater=NA_real_,Criterion=NA_real_,Step1=NA_real_,Step2=NA_real_,LogSlope=NA_real_,
          LogSlopeDisplacement=NA_real_,MaxRelativeSlopeDisplacement=NA_real_,
          MaxStructuralDisplacement=NA_real_,Iterations=NA_integer_,Seconds=elapsed,Error=z$error)
      }
      results[[id]] <- list(solver=z,summary=row,truth=p$truth,
        ability=ability,mixing=mixing)
      rows[[id]] <- row
      saveRDS(results[[id]],file.path(out,paste0(id,'.rds')))
      cat(id,': reviewed =',row$RootReviewed,'score =',row$ScoreSupNorm,'\n')
      flush.console()
    }
  }
}
summary <- do.call(rbind,rows); rownames(summary) <- NULL
saveRDS(results,file.path(out,'results.rds'))
write.csv(summary,file.path(out,'summary.csv'),row.names=FALSE)
writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
paths <- c('inst/validation/jml-profile-bias-exact-20260927.R',
  'inst/validation/jml-profile-bias-roots-20260927.R',
  'validation-results/jml-profile-bias-exact-20260927-plugin/results.rds')
write.csv(data.frame(Path=paths,SHA256=vapply(paths,function(f)
  digest::digest(file=f,algo='sha256'),character(1))),file.path(out,'sources.csv'),row.names=FALSE)
print(summary[,c('Owner','Ratings','Method','Start','RootReviewed','LogSlopeDisplacement',
  'MaxStructuralDisplacement')],row.names=FALSE)
# Availability is a result, not an assertion: unresolved attempts stay visible.
stopifnot(nrow(summary)==24)

# Adaptive follow-up only for unresolved initial attempts. Raw JML has a
# likelihood objective; adjusted scores do not inherit that objective.
followups <- list()
for (id in names(results)[!summary$RootReviewed]) {
  checkpoint <- file.path(out,paste0('followup-',id,'.rds'))
  if (file.exists(checkpoint)) { followups[[id]] <- readRDS(checkpoint); next }
  row <- results[[id]]$summary
  p <- make_jml_exact_problem(row$Owner,row$Ratings/4)
  weights <- drop(p$mass(p$truth,ability) %*% mixing)
  adjusted <- row$Method == 'one_step'
  fn <- function(x) p$mean_score(x,weights,adjusted)
  q <- function(x) sum(weights*p$evaluate(x)$q)
  z <- tryCatch({
    if (!adjusted) {
      opt <- optim(starts[[row$Start]],q,fn,method='BFGS',
        control=list(reltol=1e-12,maxit=500))
      root <- nleqslv::nleqslv(opt$par,fn,method='Newton',global='dbldog',
        control=list(ftol=1e-10,xtol=1e-11,maxit=100,stepmax=1))
      root$likelihood_optimization <- opt
    } else {
      root <- nleqslv::nleqslv(starts[[row$Start]],fn,method='Broyden',global='cline',
        control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=1))
    }
    root
  },error=function(e) list(error=conditionMessage(e)))
  detail <- data.frame(OriginalAttempt=id,Algorithm=if(adjusted) 'Broyden-cline' else 'BFGS-Newton',
    RootReviewed=FALSE,ScoreSupNorm=NA_real_,MinJacobianSingularValue=NA_real_,
    JacobianStepError=NA_real_,MinSymmetricEigenvalue=NA_real_,LogSlope=NA_real_,
    MaxStructuralDisplacement=NA_real_,Error=NA_character_)
  if(is.null(z$error)) {
    J1 <- jacobian(fn,z$x,1e-4); J2 <- jacobian(fn,z$x,5e-5)
    detail$ScoreSupNorm <- max(abs(fn(z$x)))
    detail$MinJacobianSingularValue <- min(svd(J2,nu=0,nv=0)$d)
    detail$JacobianStepError <- max(abs(J1-J2))/max(1,max(abs(J2)))
    detail$MinSymmetricEigenvalue <- min(eigen((J2+t(J2))/2,symmetric=TRUE)$values)
    detail$RootReviewed <- detail$ScoreSupNorm < 1e-7 &&
      detail$MinJacobianSingularValue > 1e-6 && detail$JacobianStepError < 1e-5 &&
      (adjusted || detail$MinSymmetricEigenvalue > 0)
    detail$LogSlope <- z$x[5]
    detail$MaxStructuralDisplacement <- max(abs(z$x-p$truth))
    z$independent_jacobians <- list(h1e4=J1,h5e5=J2)
    if(!adjusted) {
      objective_gradient <- drop(jacobian(function(x) q(x),z$x,1e-5))
      z$objective_gradient_error <- max(abs(objective_gradient-fn(z$x)))
      stopifnot(z$objective_gradient_error < 1e-7)
    }
  } else detail$Error <- z$error
  followups[[id]] <- list(summary=detail,solver=z)
  saveRDS(followups[[id]],checkpoint)
  print(detail,row.names=FALSE)
  flush.console()
}
if(length(followups)) write.csv(do.call(rbind,lapply(followups,`[[`,'summary')),
  file.path(out,'followups.csv'),row.names=FALSE)

# Resolve each attempt without erasing its initial disposition.
resolved <- lapply(names(results),function(id) {
  initial <- results[[id]]
  z <- if(initial$summary$RootReviewed) initial$solver else followups[[id]]$solver
  ok <- if(initial$summary$RootReviewed) TRUE else followups[[id]]$summary$RootReviewed
  par <- if(is.null(z$x)) rep(NA_real_,5) else z$x
  J <- if(is.null(z$independent_jacobians)) matrix(NA_real_,5,5) else z$independent_jacobians$h5e5
  data.frame(Owner=initial$summary$Owner,Ratings=initial$summary$Ratings,
    Method=initial$summary$Method,Start=initial$summary$Start,
    InitialReviewed=initial$summary$RootReviewed,Resolved=ok,
    Rater=par[1],Criterion=par[2],Step1=par[3],Step2=par[4],LogSlope=par[5],
    FirstSlope=exp(par[5]),SecondSlope=exp(-par[5]),
    MaxStructuralDisplacement=max(abs(par-initial$truth)),
    JacobianAsymmetry=max(abs(J-t(J))))
})
resolved <- do.call(rbind,resolved); rownames(resolved) <- NULL
write.csv(resolved,file.path(out,'resolved-roots.csv'),row.names=FALSE)
groups <- split(resolved,interaction(resolved$Owner,resolved$Ratings,resolved$Method,drop=TRUE))
spread <- vapply(groups,function(x) {
  values <- as.matrix(x[c('Rater','Criterion','Step1','Step2','LogSlope')])
  max(apply(values,2,function(v) diff(range(v))))
},numeric(1))
write.csv(data.frame(Condition=names(spread),MaxStartDifference=unname(spread)),
  file.path(out,'start-agreement.csv'),row.names=FALSE)
cat('Initial reviewed:',sum(resolved$InitialReviewed),'of',nrow(resolved),
  '; resolved:',sum(resolved$Resolved),'; maximum start difference:',max(spread),'\n')
stopifnot(all(resolved$Resolved),max(spread)<1e-6)
