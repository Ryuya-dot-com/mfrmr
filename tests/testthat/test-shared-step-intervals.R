test_that('a locally empty category retains independently verified shared-step intervals', {
  skip_if_not_installed('numDeriv')
  set.seed(761)
  d <- expand.grid(Person=paste0('p',1:60),Rater=c('a','b','c'),
    Criterion=c('c1','c2'),stringsAsFactors=FALSE)
  theta <- rnorm(60); rater <- c(a=2.3,b=0,c=-2.3); criterion <- c(c1=-.2,c2=.2)
  d$Score <- vapply(seq_len(nrow(d)),function(i) {
    eta <- theta[match(d$Person[i],paste0('p',1:60))]-rater[d$Rater[i]]-criterion[d$Criterion[i]]
    v <- c(0,cumsum(eta-c(-.4,.4)))
    sample(0:2,1,prob=exp(v-max(v)))
  },integer(1))
  d$Score[d$Rater=='a' & d$Score==2L] <- 1L
  fit <- suppressWarnings(fit_mfrm(d,spec=list(person='Person',facets=c('Rater','Criterion'),
    score='Score',model='RSM',method='MML',rating_min=0,rating_max=2,noncenter_facet='Person'),
    control=list(mml_integration='auto',quad_points=31,maxit=1000,reltol=1e-10)))
  ci <- suppressWarnings(mfrm_facet_intervals(fit,'Rater'))
  expect_true(all(ci$table$CIEligible))
  audit <- audit_mfrm_category_support(fit$prep,fit$config,build_param_sizes(fit$config))
  expect_identical(audit$readiness$CategoryState,'weak_information')
  expect_true(any(nzchar(audit$local_support$MissingCategories)))
  expect_true(all(audit$category_table$WithinScopeCount>0))

  # Independent normal quadrature and RSM likelihood, with four explicit
  # sum-to-zero coordinates; no package likelihood/gradient/unpacking helper.
  jacobi <- matrix(0,81,81)
  jacobi[cbind(1:80,2:81)] <- jacobi[cbind(2:81,1:80)] <- sqrt(1:80)
  eig <- eigen(jacobi,symmetric=TRUE)
  nodes <- eig$values; weights <- eig$vectors[1,]^2
  groups <- split(seq_len(nrow(d)),d$Person)
  nll <- function(p) {
    r <- c(a=p[1],b=p[2],c=-p[1]-p[2]); c <- c(c1=p[3],c2=-p[3])
    eta <- outer(-r[d$Rater]-c[d$Criterion],nodes,'+')
    u1 <- eta-p[4]; u2 <- 2*eta
    offset <- pmax(0,u1,u2)
    denominator <- offset+log(exp(-offset)+exp(u1-offset)+exp(u2-offset))
    logp <- eta*d$Score-ifelse(d$Score==1,p[4],0)-denominator
    -sum(vapply(groups,function(i) {
      v <- colSums(logp[i,,drop=FALSE]); m <- max(v)
      m+log(sum(weights*exp(v-m)))
    },numeric(1)))
  }
  expect_length(fit$opt$par,4)
  expect_equal(nll(fit$opt$par),fit$opt$value,tolerance=1e-9)
  hessian <- numDeriv::hessian(nll,fit$opt$par)
  expect_equal(unname(ci$parameter_covariance),solve(hessian),tolerance=2e-6)
  transform <- rbind(c(1,0,0,0),c(0,1,0,0),c(-1,-1,0,0))
  expect_equal(unname(ci$covariance),transform%*%solve(hessian)%*%t(transform),tolerance=2e-6)
  bad <- fit
  bad$config$boundary_audit$gpcm_slope_boundary <- list(state='certified_monotone_boundary_path')
  rejected <- suppressWarnings(mfrm_facet_intervals(bad,'Rater'))
  expect_false(any(rejected$table$CIEligible))
})
