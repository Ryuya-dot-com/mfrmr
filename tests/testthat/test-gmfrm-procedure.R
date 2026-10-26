procedure_problem <- function(fixed = integer()) {
  center <- c(.2,-.3,log(2)); H <- matrix(c(4,1,.5,1,3,.4,.5,.4,2),3)
  evaluate <- function(p) {
    d <- p-center
    list(value=10+drop(crossprod(d,H%*%d))/2, gradient=drop(H%*%d),
      score_error=list(rule=numeric(3),tail=numeric(3)))
  }
  natural <- list(lower=c(-Inf,-Inf,0),optimization_scale=20,
    from_native=function(p) c(p[1:2],exp(p[3])),
    target=function(z,C) list(value=sum(C*c(z[1:2],log(z[3]))),gradient=c(C[1:2],C[3]/z[3])),
    evaluate=function(z) {
      a <- evaluate(c(z[1:2],log(z[3]))); a$gradient[3] <- a$gradient[3]/z[3]; a
    })
  starts <- list(first=center+c(.02,-.03,.04),second=center+c(-.05,.01,-.02))
  starts <- lapply(starts,function(p) {
    if(length(fixed)) p[fixed] <- .7
    natural$from_native(p)
  })
  list(starts=starts,native=list(evaluate=evaluate,optimization_scale=20),natural=natural,
    reference=function(z,p) {
      a <- evaluate(p)
      list(reference=list(nll=a$value,qualified=TRUE),native_gradient=a$gradient,score_error=a$score_error)
    },fixed=fixed)
}

test_that("one procedure performs real search, finish, checks and full-information selection", {
  x <- procedure_problem(); a <- do.call(mfrm_gmfrm_procedure,x)
  expect_identical(a$status,"local_candidate_selected")
  expect_named(a$attempts,c("first","second"))
  expect_equal(a$candidate$native_parameters,c(.2,-.3,log(2)),tolerance=1e-9)
  H <- matrix(c(4,1,.5,1,3,.4,.5,.4,2),3)
  expect_equal(a$candidate$information$covariance,solve(H),tolerance=1e-9)
  expect_identical(a$candidate$information_scope,"joint_unrestricted")
  for(attempt in a$attempts) {
    expect_length(attempt$failed_stages,0)
    expect_identical(attempt$candidate$search,attempt$stages$search$value)
    expect_identical(attempt$candidate$information,attempt$stages$finish$value$information)
    expect_true(attempt$stages$chart$value$passed)
    expect_true(attempt$stages$reference$value$passed)
  }
  path <- tempfile(); on.exit(unlink(path)); saveRDS(a,path)
  expect_identical(readRDS(path),a)
  expect_identical(a$interval_qualification,"not assessed")
  expect_identical(a$global_optimality,"not assessed")
})

test_that("original constrained nuisance information stays conditional throughout the procedure", {
  x <- procedure_problem(1L); a <- do.call(mfrm_gmfrm_procedure,x)
  expect_identical(a$status,"local_candidate_selected")
  H <- matrix(c(4,1,.5,1,3,.4,.5,.4,2),3)
  answer <- c(.7,c(-.3,log(2))-drop(solve(H[2:3,2:3],H[2:3,1]*.5)))
  expect_equal(a$candidate$native_parameters,answer,tolerance=1e-9)
  expect_identical(a$candidate$information_scope,"conditional_nuisance")
  for(attempt in a$attempts) {
    expect_identical(attempt$candidate$selected$parameters[1],.7)
    expect_identical(attempt$candidate$information$free,2:3)
  }
  target <- mfrm_gmfrm_candidate_target(a$candidate,x$natural,c(0,1,-1))
  expect_true(target$defined); expect_true(is.na(target$local_variance))
})

test_that("boundary results bypass native inverse and Hessian and retain reference failures", {
  x <- procedure_problem()
  x$natural$evaluate <- function(z) list(value=sum((z-c(.2,-.3,-1))^2),gradient=2*(z-c(.2,-.3,-1)))
  x$native$evaluate <- x$natural$target <- x$natural$from_native <- function(...) stop("Native work forbidden")
  x$reference <- function(z,p) {
    expect_null(p)
    list(reference=list(nll=x$natural$evaluate(z)$value))
  }
  a <- do.call(mfrm_gmfrm_procedure,x)
  expect_identical(a$status,"no_qualified_candidate")
  expect_true(all(is.finite(a$reference_nll)))
  for(attempt in a$attempts) {
    expect_identical(attempt$candidate$status,"boundary_review_required")
    expect_null(attempt$candidate$information)
    expect_false("finish" %in% names(attempt$stages))
  }
  x$reference <- function(...) stop("Independent integral refused")
  b <- do.call(mfrm_gmfrm_procedure,x)
  expect_true(all(is.na(b$reference_nll)))
  expect_identical(b$status,"no_qualified_candidate")
  expect_identical(b$attempts$first$failed_stages,"reference")
  expect_match(conditionMessage(b$attempts$first$stages$reference$error),"integral refused")
})

test_that("failure before any finite endpoint does not disappear from the prescribed roster", {
  x <- procedure_problem(); original <- x$natural$evaluate
  x$starts$first[1] <- 6
  x$natural$evaluate <- function(z) {
    if(z[1]>5) { warning("initial diagnostic"); stop("initial integral refused") }
    original(z)
  }
  a <- do.call(mfrm_gmfrm_procedure,x)
  expect_identical(a$status,"incomplete_start_execution")
  expect_named(a$attempts,c("first","second"))
  expect_null(a$candidate); expect_null(a$selection)
  expect_null(a$attempts$first$candidate)
  expect_identical(a$attempts$first$status,"search_error")
  expect_identical(a$attempts$first$stages$search$warnings,"initial diagnostic")
  expect_identical(a$attempts$second$candidate$status,"reference_qualified_local_candidate")
})

test_that("failed finish and contradictory chart or reference cannot expose information", {
  x <- procedure_problem()
  testthat::local_mocked_bindings(mfrm_gmfrm_finish_interior=function(...) stop("finish refused"))
  a <- do.call(mfrm_gmfrm_procedure,x)
  expect_identical(a$status,"no_qualified_candidate")
  expect_identical(a$attempts$first$failed_stages,"finish")
  expect_null(a$attempts$first$candidate$information)
  expect_false("reference" %in% names(a$attempts$first$stages))
})

test_that("reference criteria are computed from its values rather than trusting passed flags", {
  for(field in c("nll","gradient","error")) {
    x <- procedure_problem(); reference <- x$reference
    x$reference <- function(z,p) {
      a <- reference(z,p); a$passed <- TRUE; a$checks <- rep(0,12)
      if(field=="nll") a$reference$nll <- a$reference$nll+.01
      if(field=="gradient") a$native_gradient[1] <- .1
      if(field=="error") a$score_error$rule[1] <- .1
      a
    }
    a <- do.call(mfrm_gmfrm_procedure,x)
    expect_identical(a$status,"no_qualified_candidate")
    expect_null(a$attempts$first$candidate$information)
    expect_false(a$attempts$first$stages$reference$value$passed)
  }
  x <- procedure_problem(); x$reference <- function(...) stop("reference refused")
  a <- do.call(mfrm_gmfrm_procedure,x)
  expect_identical(a$attempts$first$failed_stages,"reference")
  expect_identical(a$attempts$first$candidate$status,"reference_unresolved")
})

test_that("incompatible fixed coordinates and differing nulls are rejected before fitting", {
  x <- procedure_problem(3L)
  x$natural$evaluate <- function(...) stop("should not fit")
  expect_error(do.call(mfrm_gmfrm_procedure,x),"transformed constraint")
  x <- procedure_problem(1L); x$starts$second[1] <- .8
  expect_error(do.call(mfrm_gmfrm_procedure,x),"same original constraint")
  x <- procedure_problem(); names(x$starts) <- c("first","first")
  expect_error(do.call(mfrm_gmfrm_procedure,x),"Invalid private")
})

test_that("generic inverse and Jacobian use actual model targets across ladders and charts", {
  for(K in c(1L,3L)) {
    d <- expand.grid(Examinee=paste0("p",1:3),Item=c("i1","i2"),Judge=paste0("j",1:3))
    d <- d[-1,]; d$Rating <- rep(0:K,length.out=nrow(d))
    problem <- mfrm_gmfrm_problem(d,K,gauss_hermite_normal(15L),c("Item","Judge"),"Examinee","Rating")
    x <- problem$common; par <- .1*sin(seq_along(problem$start))
    for(chart in c("rater_intercepts","common_scale")) {
      ev <- mfrm_gmfrm_natural_evaluator(x$idx,x$config,x$sizes,chart)
      z <- ev$from_native(par); map <- mfrm_gmfrm_procedure_map(z,ev)
      expect_equal(map$parameters,par,tolerance=1e-12)
      numerical <- vapply(seq_along(par),function(j) {
        delta <- par*0; delta[j] <- 1e-6
        (ev$from_native(par+delta)-ev$from_native(par-delta))/(2e-6)
      },numeric(length(par)))
      expect_equal(map$jacobian%*%numerical,diag(length(par)),tolerance=1e-8)
      expect_identical(ev$diagnostics()$Evaluations,0L)
    }
  }
})
