zero_profile_fixture <- function(K) {
  d <- expand.grid(Person = paste0("p", seq_len(2L*(K + 1L))),
    Task = c("a", "b"), Rater = c("x", "y", "z"))
  d$Score <- rep(0:K, length.out = nrow(d)); d$Score[c(2, 7, 17)] <- 0L
  d <- d[-nrow(d), ]
  mfrm_gmfrm_problem(d, K, gauss_hermite_normal(15L), c("Task", "Rater"), "Person", "Score")
}

test_that("analytic profile scores and Schur curvature agree with reoptimized differences", {
  for (K in c(1L, 3L)) {
    problem <- zero_profile_fixture(K); c <- problem$common
    z <- .2*cos(seq_along(problem$start)); z[length(z)] <- 0
    ev <- mfrm_gmfrm_zero_profile_evaluator(z, c$idx, c$config, c$sizes)
    x <- ev$start; a <- ev$evaluate(x)
    direct <- mfrm_gmfrm_natural_evaluator(c$idx, c$config, c$sizes, "common_scale")
    ref <- direct$evaluate(a$parameters)
    expect_equal(a$value, ref$value, tolerance = 1e-11)
    expect_equal(a$gradient, ref$gradient[ev$free], tolerance = 1e-10)
    expect_lt(max(abs(a$inner$evaluation$gradient)), 1e-6)
    expect_lt(max(abs(a$gradient_correction)), 1e-6)
    differences <- lapply(c(1e-4, 5e-5), function(h) vapply(seq_along(x), function(j) {
      step <- replace(x*0, j, h)
      (ev$value(x + step) - ev$value(x - step))/(2*h)
    }, 0))
    expect_lt(max(abs(a$gradient - (4*differences[[2]] - differences[[1]])/3)), 1e-6)
    h <- 2e-4
    H <- vapply(seq_along(x), function(j) {
      step <- replace(x*0, j, h)
      (ev$gradient(x + step) - ev$gradient(x - step))/(2*h)
    }, numeric(length(x)))
    expect_lt(max(abs(a$hessian - H)), 3e-5)
    expect_equal(a$hessian, t(a$hessian), tolerance = 1e-10)
    # Returning after other inner solves must give the same profile, within precision.
    b <- ev$evaluate(x)
    expect_equal(b$value, a$value, tolerance = 1e-11)
    expect_lt(max(abs(b$gradient - a$gradient)), 1e-6)
    expect_match(a$optimality, "not assessed")
  }
})

test_that("profile keeps original null coordinates and invalidates failed cache entries", {
  problem <- zero_profile_fixture(3L); c <- problem$common
  z <- .2*cos(seq_along(problem$start)); z[length(z)] <- 0
  fixed <- build_param_slices(c$sizes)$log_slopes[1L]
  ev <- mfrm_gmfrm_zero_profile_evaluator(z, c$idx, c$config, c$sizes, fixed)
  x <- ev$start; a <- ev$evaluate(x); before <- ev$diagnostics()$inner_solves
  expect_identical(ev$evaluate(x), a)
  expect_identical(ev$diagnostics()$inner_solves, before)
  expect_false(fixed %in% ev$free)
  expect_identical(a$parameters[fixed], z[fixed])
  expect_identical(tail(a$parameters, 1L), 0)
  b <- ev$evaluate(x + .01)
  expect_identical(b$parameters[fixed], z[fixed])
  expect_error(ev$value(x + 1i), "finite real")
  expect_error(ev$value(replace(x, 1L, 1000)), class = "mfrmr_adaptive_quadrature_numeric_error")
  expect_gte(ev$diagnostics()$failed_points, 1L)
  again <- ev$evaluate(x)
  expect_equal(again$value, a$value, tolerance = 1e-11)
  expect_lt(max(abs(again$gradient - a$gradient)), 1e-6)
  expect_error(mfrm_gmfrm_zero_profile_evaluator(z, c$idx, c$config, c$sizes, 1L), "discrimination")
})

test_that("unqualified inner problems cannot masquerade as profile points", {
  problem <- zero_profile_fixture(1L); c <- problem$common
  idx <- c$idx; idx$score_k[] <- 0L; z <- problem$start*0
  ev <- mfrm_gmfrm_zero_profile_evaluator(z, idx, c$config, c$sizes)
  error <- tryCatch(ev$evaluate(ev$start), error = identity)
  expect_s3_class(error, "mfrmr_adaptive_quadrature_numeric_error")
  expect_match(conditionMessage(error), "no profile value or gradient")
  expect_length(error$inner_attempts, 2L)
  expect_true(all(vapply(error$inner_attempts, function(x) x$status == "finite_optimum_not_certified", TRUE)))
  expect_error(ev$gradient(ev$start), "did not qualify")
  expect_equal(ev$diagnostics()$inner_solves, 4L)
  expect_equal(ev$diagnostics()$cache_hits, 0L)
})
