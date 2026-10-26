zero_location_fixture <- function(K, uniform = FALSE) {
  d <- expand.grid(Candidate = paste0("p", seq_len(2L*(K + 1L))),
    Item = c("i1", "i2"), Judge = paste0("j", 1:3))
  d$Rating <- rep(0:K, length.out = nrow(d))
  if (!uniform) d$Rating[c(2, 7, 17)] <- 0L
  names(d)[2:3] <- c("Item name", "Judge name")
  mfrm_gmfrm_problem(d, K, gauss_hermite_normal(15L),
    c("Item name", "Judge name"), "Candidate", "Rating")
}

test_that("aggregated convex derivatives agree with the observation-level engine", {
  for (K in c(1L, 3L)) {
    problem <- zero_location_fixture(K); x <- problem$common
    z <- .2*sin(seq_along(problem$start)); z[length(z)] <- 0
    ev <- mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes, "common_scale")
    loc <- mfrm_gmfrm_zero_location_problem(z, x$idx, x$config, x$sizes)
    a <- loc$evaluate(loc$start); old <- ev$evaluate(z); at <- loc$location
    expect_true(loc$support$finite_unique)
    expect_equal(a$value, old$value, tolerance = 1e-12)
    expect_equal(a$gradient, old$gradient[at], tolerance = 1e-11)
    h <- 1e-5
    H <- vapply(at, function(j) {
      step <- replace(z*0, j, h)
      (ev$gradient(z + step)[at] - ev$gradient(z - step)[at])/(2*h)
    }, numeric(length(at)))
    expect_lt(max(abs(a$hessian - H)), 1e-7)
    expect_gt(min(eigen(a$hessian, symmetric = TRUE)$values), 0)
    left <- loc$start - .1; right <- loc$start + .2
    expect_lte(loc$evaluate(.4*left + .6*right)$value,
      .4*loc$evaluate(left)$value + .6*loc$evaluate(right)$value)
    # At zero variance, regrouping Persons cannot alter the location problem.
    idx <- x$idx; idx$person <- rev(idx$person)
    other <- mfrm_gmfrm_zero_location_problem(z, idx, x$config, x$sizes)
    expect_identical(other$evaluate(loc$start), a)
    # Removing one observation exercises incomplete cell counts.
    idx$score_k <- idx$score_k[-1L]; idx$slope_idx <- idx$slope_idx[-1L]
    idx$person <- idx$person[-1L]; idx$weight <- rep(1, length(idx$score_k))
    sparse <- mfrm_gmfrm_zero_location_problem(z, idx, x$config, x$sizes)
    ref <- mfrm_gmfrm_natural_evaluator(idx, x$config, x$sizes, "common_scale")
    expect_equal(sparse$evaluate(loc$start)$value, ref$value(z), tolerance = 1e-12)
  }
})

test_that("Newton search recovers the known finite optimum with fixed unequal slopes", {
  for (K in c(1L, 3L)) {
    problem <- zero_location_fixture(K, uniform = TRUE); x <- problem$common
    z <- .4*cos(seq_along(problem$start)); z[length(z)] <- 0
    loc <- mfrm_gmfrm_zero_location_problem(z, x$idx, x$config, x$sizes)
    for (start in list(loc$start, -loc$start, loc$start*0)) {
      fit <- mfrm_gmfrm_zero_location_search(loc, start)
      expect_identical(fit$status, "stationary_convex_candidate")
      expect_lt(max(abs(fit$parameters)), 1e-7)
      expect_equal(fit$evaluation$value, nrow(problem$specification$data)*log(K + 1L), tolerance = 1e-12)
      expect_lt(max(abs(fit$evaluation$gradient)), 1e-6)
      expect_true(all(diff(fit$history) <= 1e-10))
      expect_match(fit$scope, "outer optimality not assessed")
    }
  }
})

test_that("nonuniform inner solution agrees with a separate quasi-Newton search", {
  problem <- zero_location_fixture(3L); x <- problem$common
  z <- .2*sin(seq_along(problem$start)); z[length(z)] <- 0
  loc <- mfrm_gmfrm_zero_location_problem(z, x$idx, x$config, x$sizes)
  fit <- mfrm_gmfrm_zero_location_search(loc)
  ev <- mfrm_gmfrm_natural_evaluator(x$idx, x$config, x$sizes, "common_scale")
  embed <- function(l) replace(z, loc$location, l)
  reference <- optim(loc$start*0, function(l) ev$value(embed(l)),
    function(l) ev$gradient(embed(l))[loc$location], method = "BFGS",
    control = list(reltol = 1e-14, maxit = 200))
  expect_identical(fit$status, "stationary_convex_candidate")
  expect_equal(fit$evaluation$value, reference$value, tolerance = 1e-10)
  expect_lt(max(abs(fit$parameters - reference$par)), 1e-5)
  expect_identical(embed(fit$parameters)[-loc$location], z[-loc$location])
})

test_that("missing finite-solution evidence and invalid inputs are explicit", {
  problem <- zero_location_fixture(1L); x <- problem$common; z <- problem$start*0
  idx <- x$idx; idx$score_k[] <- 0L
  loc <- mfrm_gmfrm_zero_location_problem(z, idx, x$config, x$sizes)
  expect_false(loc$support$finite_unique)
  fit <- mfrm_gmfrm_zero_location_search(loc)
  expect_identical(fit$status, "finite_optimum_not_certified")
  expect_identical(fit$parameters, z[loc$location])
  expect_gt(max(abs(fit$evaluation$gradient)), 1)
  expect_error(mfrm_gmfrm_zero_location_search(loc, maxit = 0), "positive integer")
  expect_error(mfrm_gmfrm_zero_location_problem(replace(z, length(z), 1), idx, x$config, x$sizes), "common-zero")
  expect_error(mfrm_gmfrm_zero_location_problem(z + 1i, idx, x$config, x$sizes), "common-zero")
  expect_error(loc$evaluate(loc$start + NA_real_), "finite real")
  idx$weight <- 2
  expect_error(mfrm_gmfrm_zero_location_problem(z, idx, x$config, x$sizes), "unweighted")
})
