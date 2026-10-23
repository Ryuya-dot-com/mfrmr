candidate_stages <- function(fixed = integer()) {
  p <- c(.2, -.3, log(2)); free <- setdiff(1:3, fixed)
  natural <- list(lower=c(-Inf,-Inf,0), from_native=function(p) c(p[1:2],exp(p[3])),
    target=function(z,C) {
      if (z[3]==0 && C[3]!=0) stop("This native target is not supported at this boundary.")
      positive <- if(z[3]==0) 1 else z[3]
      list(value=sum(C*c(z[1:2],log(positive))),
        gradient=c(C[1:2],if(z[3]==0) 0 else C[3]/z[3]))
    })
  z <- natural$from_native(p); g <- p*0; g[fixed] <- .7
  gn <- g; gn[3] <- gn[3]/z[3]
  H <- matrix(c(4,1,.5,1,3,.4,.5,.4,2),3)[free,free,drop=FALSE]
  ev <- list(value=10,gradient=g)
  finish <- list(initial=list(parameters=p,evaluation=ev),selected=list(parameters=p,evaluation=ev),
    status="interior_numerical_candidate",fixed=fixed,free=free,
    checks=c(RawScore=0,MeanScore=0,FixedError=0,StandardizedScore=0,
      InverseResidual=0,CovarianceChange=0,IntegrationDiagnostic=0),
    information=list(parameters=p,free=free,hessian=H,covariance=solve(H),regularized=FALSE))
  search <- list(selected=list(parameters=z,evaluation=list(value=10,gradient=gn)),
    fixed=fixed,free=free,optimizer=list(convergence=1L),error="historical stop")
  chart <- list(parameters=z,evaluation=list(value=10,gradient=gn),passed=TRUE,
    checks=c(NLL=0,Gradient=0,RawNatural=0,Target=0,Roundtrip=0,IntegrationDiagnostic=0))
  reference <- list(passed=TRUE,reference=list(qualified=TRUE,nll=10),native_gradient=g,natural_gradient=gn,
    checks=c(NLLNative=0,NLLNatural=0,GradientNative=0,GradientNatural=0,
      RawNative=0,MeanNative=0,StandardizedNative=0,RawNatural=0,NaturalRule=0,
      NaturalTail=0,IntegrationDiagnostic=0,Target=0))
  list(search=search,natural=natural,finish=finish,chart=chart,reference=reference)
}

test_that("completed stages share full joint information without rewriting search history", {
  x <- candidate_stages(); a <- do.call(mfrm_gmfrm_candidate,x)
  expect_identical(a$status,"reference_qualified_local_candidate")
  expect_identical(a$search,x$search)
  expect_identical(a$information,x$finish$information)
  expect_identical(a$information_scope,"joint_unrestricted")
  C <- c(1,-1,.4); target <- mfrm_gmfrm_candidate_target(a,x$natural,C)
  expect_true(target$defined)
  expect_equal(target$value,sum(C*x$finish$selected$parameters))
  expect_equal(target$local_variance,drop(crossprod(C,solve(x$finish$information$hessian,C))))
  expect_gt(abs(target$local_variance-sum(C^2*diag(a$information$covariance))),.01)
  expect_identical(target$variance_scope,"local_model_based")
  expect_identical(a$global_optimality,"not assessed")
  expect_identical(a$interval_qualification,"not assessed")
  path <- tempfile(); on.exit(unlink(path)); saveRDS(a,path)
  expect_identical(mfrm_gmfrm_candidate_target(readRDS(path),x$natural,C),target)
})

test_that("a null-fit nuisance inverse never supplies unrestricted target variance", {
  x <- candidate_stages(1L); a <- do.call(mfrm_gmfrm_candidate,x)
  expect_identical(a$status,"reference_qualified_local_candidate")
  expect_identical(a$information_scope,"conditional_nuisance")
  expect_identical(a$information,x$finish$information)
  for(C in list(c(1,0,0),c(0,1,-1))) {
    target <- mfrm_gmfrm_candidate_target(a,x$natural,C)
    expect_true(target$defined)
    expect_true(is.na(target$local_variance))
    expect_match(target$detail,"Constrained nuisance")
  }
  x <- candidate_stages(3L)
  expect_error(do.call(mfrm_gmfrm_candidate,x),"transformed constraint")
})

test_that("boundary targets remain separate from an interior covariance", {
  x <- candidate_stages(); x$search$selected$parameters[3] <- 0
  a <- do.call(mfrm_gmfrm_candidate,x) # A supplied interior finish cannot override the boundary.
  expect_identical(a$status,"boundary_review_required")
  expect_identical(a$search,x$search)
  expect_null(a$information)
  available <- mfrm_gmfrm_candidate_target(a,x$natural,c(1,-1,0))
  unavailable <- mfrm_gmfrm_candidate_target(a,x$natural,c(0,0,1))
  expect_true(available$defined); expect_true(is.na(available$local_variance))
  expect_false(unavailable$defined); expect_true(is.na(unavailable$value))
})

test_that("missing, failed and contradictory stage checks cannot expose information", {
  x <- candidate_stages()
  for(stage in c("finish","chart","reference")) {
    bad <- x; bad[[stage]] <- NULL
    a <- do.call(mfrm_gmfrm_candidate,bad)
    expect_null(a$information)
    expect_false(identical(a$status,"reference_qualified_local_candidate"))
  }
  for(stage in c("finish","chart","reference")) {
    bad <- x; bad[[stage]]$checks[1] <- Inf
    expect_null(do.call(mfrm_gmfrm_candidate,bad)$information)
  }
  bad <- x; bad$reference$checks[1] <- -1
  expect_null(do.call(mfrm_gmfrm_candidate,bad)$information)
  bad <- x; bad$finish$status <- "precision_unresolved"
  expect_identical(do.call(mfrm_gmfrm_candidate,bad)$status,"precision_unresolved")
})

test_that("information and references cannot be transferred to a changed point", {
  x <- candidate_stages()
  bad <- x; bad$finish$information$parameters[1] <- .4
  expect_error(do.call(mfrm_gmfrm_candidate,bad),"Information must belong")
  bad <- x; bad$finish$information$covariance <- diag(3)
  expect_error(do.call(mfrm_gmfrm_candidate,bad),"Information must belong")
  bad <- x; bad$search$selected$parameters[1] <- .4
  expect_error(do.call(mfrm_gmfrm_candidate,bad),"saved endpoint")
  bad <- x; bad$chart$parameters[1] <- .4
  expect_error(do.call(mfrm_gmfrm_candidate,bad),"different point")
  bad <- x; bad$reference$native_gradient[1] <- 1
  expect_error(do.call(mfrm_gmfrm_candidate,bad),"Reference check")
  bad <- x; bad$reference$reference$nll <- NA_real_
  expect_error(do.call(mfrm_gmfrm_candidate,bad),"Reference check")
  a <- do.call(mfrm_gmfrm_candidate,x); a$selected$parameters[1] <- .4
  expect_error(mfrm_gmfrm_candidate_target(a,x$natural,c(1,0,0)),"no longer matches")
  expect_error(mfrm_gmfrm_candidate_target(a,x$natural,c(1,NA,0)),"finite real")
})

test_that("target routing uses actual model coordinates across score ladders and charts", {
  for(K in c(1L,3L)) {
    d <- expand.grid(Examinee=paste0("p",1:3),Item=c("i1","i2"),Judge=paste0("j",1:3))
    d <- d[-1,]; d$Rating <- rep(0:K,length.out=nrow(d))
    problem <- mfrm_gmfrm_problem(d,K,gauss_hermite_normal(15L),c("Item","Judge"),"Examinee","Rating")
    x <- problem$common; par <- .1*sin(seq_along(problem$start)); sl <- build_param_slices(x$sizes)
    for(chart in c("rater_intercepts","common_scale")) {
      ev <- mfrm_gmfrm_natural_evaluator(x$idx,x$config,x$sizes,chart)
      z <- ev$from_native(par)
      search <- list(selected=list(parameters=z,evaluation=list(value=10,gradient=z*0)),
        fixed=integer(),free=seq_along(z))
      a <- mfrm_gmfrm_candidate(search,ev)
      C <- sin(seq_along(z)); target <- mfrm_gmfrm_candidate_target(a,ev,C)
      expect_equal(target$value,sum(C*par),tolerance=1e-12)
      expect_true(is.na(target$local_variance))
      search$selected$parameters[ev$natural[1]] <- 0
      a <- mfrm_gmfrm_candidate(search,ev)
      expect_identical(a$status,"boundary_review_required")
      C[] <- 0; C[sl$log_slopes[1]] <- 1
      expect_true(mfrm_gmfrm_candidate_target(a,ev,C)$defined)
      C[] <- 0; C[sl$Judge[1]] <- 1
      expect_false(mfrm_gmfrm_candidate_target(a,ev,C)$defined)
      expect_identical(ev$diagnostics()$Evaluations,0L)
    }
  }
})
