# Research-only population challenge; contract fixed in the companion Markdown.
source('inst/validation/jml-design-adjustment-20260927.R')
source('inst/validation/jml-total-expectation-20260927.R')

run_jml_scope_challenge <- function(out) {
  if(dir.exists(out)) stop('Refusing to overwrite a challenge directory.')
  dir.create(out,recursive=TRUE)
  designs <- list(
    sparse=list(exposure=list(c(2,1,0,2),c(0,2,2,1)),proportions=c(.5,.5),
      ability=list(c(-2,-1,0),c(0,1,2))),
    unequal=list(exposure=list(c(2,1,0,1),c(0,2,2,2)),proportions=c(.6,.4),
      ability=list(c(0,1,2),c(-2,-1,0))))
  starts <- list(neutral=c(0,0,-.8,-.8,0),opposing=c(-.3,.4,-.3,-1.1,-.25))
  source_files <- c('inst/validation/jml-scope-challenge-20260927.R',
    'inst/validation/jml-scope-challenge-20260927.md',
    'inst/validation/jml-design-adjustment-20260927.R',
    'inst/validation/jml-total-expectation-20260927.R',
    'inst/validation/jml-profile-bias-sample-20260927.R')
  saveRDS(list(designs=designs,starts=starts,orders=c(0L,1L,2L,4L),
    hashes=tools::md5sum(source_files)),file.path(out,'contract.rds'))
  summary <- detail <- list()
  for(owner in c('Criterion','Rater')) for(design in names(designs)) {
    d <- designs[[design]]
    reference <- lapply(d$exposure,function(e) make_jml_roster_problem(owner,e))
    truth <- reference[[1]]$truth
    ps <- lapply(reference,function(p) make_jml_total_problem(owner,p$exposure,p$counts))
    weights <- Map(function(p,a) drop(p$mass(truth,a)%*%c(.25,.5,.25)),reference,d$ability)
    stopifnot(all(vapply(weights,function(w) abs(sum(w)-1)<1e-12,logical(1))))
    equivalence <- vapply(seq_along(ps),function(i) max(abs(
      ps[[i]]$scores(truth,4L)$value-reference[[i]]$scores(truth,4L)$value)),numeric(1))
    stopifnot(all(equivalence<1e-10))
    for(k in c(0L,1L,2L,4L)) {
      id <- paste(owner,design,k,sep='-')
      eq <- make_jml_design_equation(ps,weights,d$proportions,k)
      attempts <- lapply(starts,function(start) {
        record <- jml_design_root(eq,k,start)
        if(!isTRUE(record$fit$reviewed)) {
          record$small_step <- tryCatch({
            z <- nleqslv::nleqslv(start,eq$mean_score,method='Newton',global='dbldog',
              control=list(ftol=1e-10,xtol=1e-11,maxit=150,stepmax=.25))
            A <- jml_sample_jacobian(eq$mean_score,z$x,5e-5)
            A1 <- jml_sample_jacobian(eq$mean_score,z$x,1e-4)
            residual <- max(abs(eq$mean_score(z$x)))
            singular <- min(svd(A,nu=0,nv=0)$d)
            error <- max(abs(A1-A))/max(1,max(abs(A)))
            list(beta=z$x,A=A,solver=z,residual=residual,min_singular=singular,
              jacobian_error=error,reviewed=residual<1e-7 && singular>1e-6 &&
                error<1e-5 && (k>0 || min(eigen((A+t(A))/2,symmetric=TRUE)$values)>0))
          },error=function(e) list(reviewed=FALSE,error=conditionMessage(e)))
          record$fit <- record$small_step
        }
        record
      })
      fits <- lapply(attempts,`[[`,'fit')
      ok <- all(vapply(fits,function(f) isTRUE(f$reviewed),logical(1)))
      spread <- if(ok) max(abs(fits[[1]]$beta-fits[[2]]$beta)) else NA_real_
      ok <- ok && spread<1e-6
      covariance <- if(ok) tryCatch(jml_design_covariance(eq,fits[[1]]$beta,400,
        fits[[1]]$A,'fixed_rosters'),error=function(e) list(error=conditionMessage(e))) else NULL
      available <- ok && is.null(covariance$error)
      summary[[id]] <- data.frame(Owner=owner,Design=design,Order=k,Reviewed=ok,
        CovarianceAvailable=available,StartSpread=spread,
        FallbackStarts=sum(vapply(attempts,function(a) length(a$attempts)>1L ||
          !is.null(a$small_step),logical(1))),EquivalenceError=max(equivalence))
      if(available) {
        beta <- fits[[1]]$beta
        # Independent influence outer-product form, with within-roster centering.
        influence <- lapply(covariance$centered,function(U) -t(solve(fits[[1]]$A,t(U))))
        V <- Reduce(`+`,lapply(seq_along(ps),function(i) d$proportions[i]*
          crossprod(influence[[i]],weights[[i]]*influence[[i]])))/400
        stopifnot(max(abs(V-covariance$vcov))<1e-10)
        detail[[id]] <- do.call(rbind,lapply(c(400L,1600L),function(N) {
          variance <- diag(covariance$vcov)*400/N; bias <- beta-truth
          data.frame(Owner=owner,Design=design,Order=k,N=N,Parameter=names(truth),
            Truth=unname(truth),PopulationRoot=unname(beta),Bias=unname(bias),
            LocalSE=sqrt(variance),BiasOverSE=unname(abs(bias)/sqrt(variance)),
            AsymptoticMSEProxy=unname(bias^2+variance),
            MinSingular=fits[[1]]$min_singular,row.names=NULL)
        }))
      }
      saveRDS(list(attempts=attempts,covariance=covariance,weights=weights,
        proportions=d$proportions,truth=truth,summary=summary[[id]],detail=detail[[id]]),
        file.path(out,paste0(id,'.rds')))
      write.csv(do.call(rbind,summary),file.path(out,'summary.csv'),row.names=FALSE)
      if(length(detail)) write.csv(do.call(rbind,detail),file.path(out,'parameters.csv'),row.names=FALSE)
      print(summary[[id]],row.names=FALSE); flush.console()
    }
  }
  writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
  stopifnot(length(summary)==16L)
}
if(sys.nframe()==0L) run_jml_scope_challenge('validation-results/jml-scope-challenge-20260927')
