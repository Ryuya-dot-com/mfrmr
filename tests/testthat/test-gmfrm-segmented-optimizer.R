test_that("curvature continuation resolves a scaled quadratic without altering its objective", {
  Q <- matrix(c(cos(.4), sin(.4), -sin(.4), cos(.4)), 2)
  H <- Q %*% diag(c(1e-4, 30)) %*% t(Q)
  evaluator <- list(value = function(p) 100 + sum(p * (H %*% p)) / 2,
    gradient = function(p) drop(H %*% p))
  recorded <- list()
  fit <- mfrm_gmfrm_segmented_continue(c(20, -10), evaluator,
    function(stages) recorded <<- stages)
  expect_identical(fit$status, "stationary_local_candidate")
  expect_lt(max(abs(fit$selected$gradient)), 1e-4)
  expect_lt(fit$curvature$predicted_decrease, 1e-6)
  expect_lt(abs(fit$selected$value - 100), 1e-8)
  expect_identical(recorded, fit$stages)
  expect_lte(length(fit$stages), 3L)
})

test_that("a tiny raw score cannot qualify a flat or unresolved direction", {
  for (curvature in c(0, 1e-14, -1e-8)) {
    ev <- list(value = function(p) 100 + (curvature * p[1]^2 + p[2]^2) / 2,
      gradient = function(p) c(curvature * p[1], p[2]))
    fit <- mfrm_gmfrm_segmented_continue(c(0, 0), ev)
    expect_false(identical(fit$status, "stationary_local_candidate"))
    expect_lte(length(fit$stages), 3L)
    expect_identical(fit$selected$par, c(0, 0))
  }
})

test_that("the scale-aware check detects unfinished work behind a small native score", {
  ev <- list(value = function(p) 100 + (1e-9 * p[1]^2 + p[2]^2) / 2,
    gradient = function(p) c(1e-9 * p[1], p[2]))
  fit <- mfrm_gmfrm_segmented_continue(c(1e4, 0), ev)
  expect_lt(max(abs(ev$gradient(c(1e4, 0)))), 1e-4)
  expect_gt(length(fit$stages), 0L)
  expect_identical(fit$status, "stationary_local_candidate")
  expect_lt(abs(fit$selected$value - 100), 1e-8)
})

test_that("invalid starts remain errors and failed searches retain a valid point", {
  ev <- list(value = function(p) {
    if (p[1] < 0) stop("invalid trial")
    (p[1] + 1)^2
  }, gradient = function(p) 2 * (p + 1))
  expect_error(mfrm_gmfrm_segmented_continue(-1, ev), "invalid trial")
  fit <- mfrm_gmfrm_segmented_continue(1, ev)
  expect_identical(fit$status, "numerical_refusal")
  expect_identical(fit$selected$par, 1)
  expect_identical(fit$stages[[1]]$error, "invalid trial")
})
