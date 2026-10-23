test_that("profile search backtracks instead of accepting a finite-penalty plateau", {
  ev <- list(start = 0, lower = -Inf, optimization_scale = 1)
  ev$evaluate <- function(x) {
    if (x > .5) stop(new_adaptive_quadrature_numeric_error("test: inner calculation unavailable"))
    list(value = 100*(x - .2)^2, gradient = 200*(x - .2))
  }
  ev$value <- function(x) ev$evaluate(x)$value
  ev$gradient <- function(x) ev$evaluate(x)$gradient
  old <- mfrm_gmfrm_natural_search(ev$start, ev)
  expect_identical(old$optimizer$convergence, 0L)
  expect_gt(old$checks[1], 1)
  expect_gt(old$rejections["quadrature"], 0)
  fit <- mfrm_gmfrm_zero_profile_search(ev)
  expect_equal(fit$selected$parameters, .2, tolerance = 1e-7)
  expect_lt(fit$checks[1], 1e-5)
  expect_gt(fit$rejected_points, 0L)
  expect_identical(fit$error, "")
  expect_identical(fit$global_optimality, "not assessed")
})

test_that("unexpected profile errors retain the last evaluable point and remain visible", {
  ev <- list(start = 0, lower = -Inf)
  ev$evaluate <- function(x) {
    if (x > 0) stop("unexpected implementation failure")
    list(value = (x - 1)^2, gradient = 2*(x - 1))
  }
  fit <- mfrm_gmfrm_zero_profile_search(ev)
  expect_match(fit$error, "unexpected implementation failure")
  expect_identical(fit$selected$parameters, 0)
  expect_false(fit$nuisance_stationary)
  expect_identical(fit$rejected_points, 0L)
  expect_error(mfrm_gmfrm_zero_profile_search(ev, maxit = NA_real_), "Invalid")
  ev$lower <- 0
  expect_error(mfrm_gmfrm_zero_profile_search(ev), "Invalid")
})
