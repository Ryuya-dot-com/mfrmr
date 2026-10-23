test_that("bounded search reaches a coupled active solution and preserves its fixed target", {
  Q <- matrix(c(4,1,1,2),2)
  ev <- list(lower = c(0,-Inf,-Inf), optimization_scale = 1000,
    evaluate = function(z) {
      d <- z[1:2] - c(-1,2)
      list(value = drop(crossprod(d,Q %*% d))/2 + (z[3]-6)^2,
        gradient = c(drop(Q %*% d), 2*(z[3]-6)))
    })
  fit <- mfrm_gmfrm_bounded_search(c(8,-9,7), ev, fixed = 3L)
  expect_equal(fit$selected$parameters, c(0,1.5,7), tolerance = 1e-6)
  expect_identical(fit$selected$parameters[1], 0)
  expect_identical(fit$active, 1L)
  expect_equal(fit$outward, 3.5, tolerance = 1e-6)
  expect_lt(fit$checks["ProjectedScore"], 1e-5)
  expect_identical(unname(fit$checks["FixedError"]), 0)
  expect_true(fit$candidate)
  expect_identical(fit$global_optimality, "not assessed")
})

test_that("a negative outward derivative releases a zero coordinate", {
  ev <- list(lower = 0, evaluate = function(x) list(value = (x-2)^2, gradient = 2*(x-2)))
  fit <- mfrm_gmfrm_bounded_search(0,ev)
  expect_equal(fit$selected$parameters, 2, tolerance = 1e-7)
  expect_length(fit$active, 0L)
  expect_true(fit$candidate)
})

test_that("typed rejected objectives backtrack without a fabricated gradient", {
  evaluated <- numeric()
  ev <- list(lower = 0, evaluate = function(x) {
    if (x > .5) stop(new_adaptive_quadrature_numeric_error("test: unavailable integral"))
    evaluated <<- c(evaluated,x)
    list(value = 100*(x-.2)^2, gradient = 200*(x-.2))
  })
  fit <- mfrm_gmfrm_bounded_search(0,ev)
  expect_equal(fit$selected$parameters, .2, tolerance = 1e-8)
  expect_true(fit$candidate)
  expect_gt(fit$rejected_points, 0L)
  expect_match(fit$last_rejection$message,"unavailable integral")
  expect_gt(fit$last_rejection$parameters, .5)
  expect_true(all(evaluated <= .5))
  expect_identical(fit$error, "")
})

test_that("optimizer code zero cannot qualify a false boundary or an excessive score", {
  local_mocked_bindings(nlminb = function(start,...) list(par=start,convergence=0L), .package="stats")
  ev <- list(lower = 0, evaluate = function(x) list(value = (x+1)^2, gradient = 2*(x+1)))
  positive <- mfrm_gmfrm_bounded_search(1e-12,ev)
  expect_length(positive$active,0L)
  expect_gt(positive$checks["ProjectedScore"],1)
  expect_false(positive$candidate)
  ev$evaluate <- function(x) list(value=(x-2)^2,gradient=2*(x-2))
  zero <- mfrm_gmfrm_bounded_search(0,ev)
  expect_equal(unname(zero$checks["OutwardViolation"]),4)
  expect_false(zero$candidate)
})

test_that("unexpected and gradient-only errors remain failures with the best point retained", {
  ev <- list(lower = 0, evaluate = function(x) {
    if (x > 0) stop("unexpected evaluator defect")
    list(value = (x-1)^2, gradient = 2*(x-1))
  })
  fit <- mfrm_gmfrm_bounded_search(0,ev)
  expect_identical(fit$selected$parameters,0)
  expect_match(fit$error,"unexpected evaluator defect")
  expect_identical(fit$rejected_points,0L)
  expect_false(fit$candidate)
  local_mocked_bindings(nlminb = function(start,objective,gradient,...) {
    gradient(start+1); list(par=start,convergence=0L)
  }, .package="stats")
  ev$evaluate <- function(x) {
    if (x > 0) stop(new_adaptive_quadrature_numeric_error("gradient unavailable"))
    list(value=1,gradient=-2)
  }
  fit <- mfrm_gmfrm_bounded_search(0,ev)
  expect_match(fit$error,"gradient unavailable")
  expect_false(fit$candidate)
  expect_identical(fit$rejected_points,0L)
})

test_that("an iteration stop is retained even when the selected point is stationary", {
  local_mocked_bindings(nlminb = function(start,...) list(par=start,convergence=1L,
    message="iteration limit reached"), .package="stats")
  ev <- list(lower=0, evaluate=function(x) list(value=(x-1)^2,gradient=2*(x-1)))
  fit <- mfrm_gmfrm_bounded_search(1,ev)
  expect_true(fit$nuisance_stationary)
  expect_false(fit$candidate)
  expect_identical(fit$optimizer$convergence,1L)
  expect_match(fit$optimizer$message,"iteration limit")
})

test_that("initial numerical failures and invalid controls are not hidden", {
  ev <- list(lower = 0, evaluate = function(x) stop(new_adaptive_quadrature_numeric_error("initial failure")))
  expect_error(mfrm_gmfrm_bounded_search(0,ev),"initial failure")
  expect_error(mfrm_gmfrm_bounded_search(-1,ev),"Invalid")
  expect_error(mfrm_gmfrm_bounded_search(0,ev,maxit=NA_real_),"Invalid")
  expect_error(mfrm_gmfrm_bounded_search(0,ev,fixed=1L),"free coordinate")
  expect_error(mfrm_gmfrm_bounded_search(0,ev,fixed=c(1,1)),"Invalid")
  ev$optimization_scale <- 0
  expect_error(mfrm_gmfrm_bounded_search(0,ev),"Invalid")
})
