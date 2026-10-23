test_that("natural search distinguishes a boundary minimum from an outward descent direction", {
  for (a in c(-1, 1)) {
    ev <- list(evaluate = function(p) list(value = (p[1] - a)^2 + (p[2] - 2)^2,
      gradient = 2 * (p - c(a, 2))), lower = c(0, -Inf), optimization_scale = 1)
    ev$gradient <- function(p) ev$evaluate(p)$gradient
    fit <- mfrm_gmfrm_natural_search(c(0, -3), ev, boundary = 1L)
    expect_equal(fit$selected$parameters, c(0, 2), tolerance = 1e-7)
    expect_true(unname(fit$nuisance_stationary))
    expect_identical(unname(fit$first_order_feasible), a < 0)
    expect_identical(fit$global_optimality, "not assessed")
    full <- mfrm_gmfrm_natural_search(c(0, -3), ev)
    expect_equal(full$selected$parameters, c(max(a, 0), 2), tolerance = 1e-7)
  }
})

test_that("natural search keeps target coordinates and numerical failures explicit", {
  ev <- list(evaluate = function(p) list(value = sum((p - 2)^2), gradient = 2*(p - 2)),
    lower = c(-Inf, -Inf), optimization_scale = 1)
  ev$gradient <- function(p) ev$evaluate(p)$gradient
  fit <- mfrm_gmfrm_natural_search(c(.4, -3), ev, fixed = 1L)
  expect_equal(fit$selected$parameters, c(.4, 2), tolerance = 1e-7)
  expect_equal(unname(fit$checks["FixedError"]), 0)
  expect_gt(abs(fit$selected$evaluation$gradient[1]), 1)
  expect_true(unname(fit$first_order_feasible))
  ev$evaluate <- function(p) { if (any(p != c(.4, -3))) stop("unavailable trial"); list(value = 1, gradient = c(1, 1)) }
  failed <- mfrm_gmfrm_natural_search(c(.4, -3), ev)
  expect_identical(failed$error, "unavailable trial")
  expect_identical(failed$selected$parameters, c(.4, -3))
  expect_false(unname(failed$first_order_feasible))
  expect_error(mfrm_gmfrm_natural_search(c(.4, -3), ev, boundary = 1L), "Invalid")
  expect_error(mfrm_gmfrm_natural_search(c(.4, -3), ev, fixed = 1:2), "at least one")
})

test_that("distinct starts can retain different optima without a global certificate", {
  ev <- list(evaluate = function(p) list(value = (p^2 - 1)^2,
    gradient = 4*p*(p^2 - 1)), lower = -Inf, optimization_scale = 1)
  ev$gradient <- function(p) ev$evaluate(p)$gradient
  fits <- lapply(c(-1.2, 1.2), function(x) mfrm_gmfrm_natural_search(x, ev))
  expect_equal(vapply(fits, function(x) x$selected$parameters, 0), c(-1, 1), tolerance = 1e-6)
  expect_true(all(vapply(fits, function(x) unname(x$first_order_feasible), TRUE)))
  expect_true(all(vapply(fits, function(x) identical(x$global_optimality, "not assessed"), TRUE)))
  # A zero gradient can occur at a local maximum of the minimized objective.
  saddle <- mfrm_gmfrm_natural_search(0, ev)
  expect_true(unname(saddle$first_order_feasible))
  expect_gt(saddle$selected$evaluation$value, fits[[1]]$selected$evaluation$value)
  expect_identical(saddle$global_optimality, "not assessed")
})
