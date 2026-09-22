# Repository-only numerical pilot: one balanced, three-parameter RSM MML fit.
# Independent whole-line adaptive integration and central-difference Hessian.
# The fixed checks below were chosen before the first run; they are numerical
# checks for this fixture, not statistical coverage or release criteria.
# Run from the package root, e.g.:
# Rscript inst/validation/mml-independent-rsm-information-0.2.4.R /tmp/rsm-information.rds

mml_independent_central_hessian <- function(objective, par, h) {
  n <- length(par); out <- matrix(0,n,n); mid <- objective(par)
  for(i in seq_len(n)) for(j in i:n) {
    a <- b <- numeric(n); a[i] <- h; b[j] <- h
    out[i,j] <- out[j,i] <- if(i==j) {
      (objective(par+a)-2*mid+objective(par-a))/h^2
    } else {
      (objective(par+a+b)-objective(par+a-b)-objective(par-a+b)+objective(par-a-b))/(4*h^2)
    }
  }
  out
}

mml_independent_rsm_information <- function(output_file) {
  pkgload::load_all('.', quiet = TRUE)
  set.seed(20260909)
  d <- expand.grid(Person=sprintf('P%03d',1:80), Rater=c('R1','R2'), Criterion=c('C1','C2'), stringsAsFactors=FALSE)
  theta <- rnorm(80)
  r <- ifelse(d$Rater=='R1',1,-1)
  c <- ifelse(d$Criterion=='C1',1,-1)
  eta <- theta[match(d$Person,unique(d$Person))] - r*0.3 - c*0.4
  lp <- cbind(0,eta+0.6,2*eta)
  prob <- exp(lp-apply(lp,1,max)); prob <- prob/rowSums(prob)
  d$Score <- vapply(seq_len(nrow(d)),function(i)sample(0:2,1,prob=prob[i,]),integer(1))
  f <- fit_mfrm(d,'Person',c('Rater','Criterion'),'Score',model='RSM',method='MML',rating_min=0,rating_max=2,quad_points=61,maxit=200,reltol=1e-10)
  slices <- mfrmr:::build_param_slices(mfrmr:::build_param_sizes(f$config))
  stopifnot(mfrmr:::mfrm_inference_ready(f),length(f$opt$par)==3L,
            identical(slices$Rater,1L),identical(slices$Criterion,2L),
            identical(slices$steps,3L))
  groups <- split(seq_len(nrow(d)),d$Person)
  # Independent adjacent logits are (0, eta - step, 2 * eta), with
  # Rater=(r,-r), Criterion=(c,-c), and thresholds=(step,-step).
  # Adaptive integration over the whole real line does not reuse package grids.
  objective <- function(par) {
    -sum(vapply(groups,function(ix){
      density <- function(z) {
        e <- outer(z,r[ix]*par[1]+c[ix]*par[2],'-')
        hi <- pmax(0,e-par[3],2*e)
        logz <- hi + log(exp(-hi)+exp(e-par[3]-hi)+exp(2*e-hi))
        numerator <- sweep(e,2,d$Score[ix],'*') -
          matrix(par[3]*(d$Score[ix]==1),nrow(e),length(ix),byrow=TRUE)
        exp(rowSums(numerator-logz))*dnorm(z)
      }
      log(integrate(density,-Inf,Inf,rel.tol=1e-11,abs.tol=1e-13,subdivisions=200L)$value)
    },numeric(1)))
  }
  h1 <- mml_independent_central_hessian(objective,f$opt$par,0.001)
  h2 <- mml_independent_central_hessian(objective,f$opt$par,0.0005)
  package <- mfrmr:::compute_mml_parameter_covariance(f)
  reference <- solve(h2)
  metrics <- c(ObjectiveDifference=objective(f$opt$par)-f$opt$value,
   HessianStepRelativeChange=max(abs(h1-h2))/max(1,max(abs(h2))),
   HessianRelativeDifference=max(abs(package$hessian-h2))/max(1,max(abs(h2))),
   MaxRelativeSEDifference=max(abs(sqrt(diag(package$cov)/diag(reference))-1)))
  print(metrics)
  stopifnot(identical(package$status,'ok'),abs(metrics[1])<1e-6,
            all(abs(metrics[-1])<1e-5))
  saveRDS(list(metrics=metrics,fit=f,hessian=package$hessian,reference_hessian=h2,
               reference_hessian_coarse=h1,reference_covariance=reference,
               package_covariance=package$cov,session_info=sessionInfo()),output_file)
  invisible(metrics)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) == 1L)
  mml_independent_rsm_information(args[[1L]])
}
