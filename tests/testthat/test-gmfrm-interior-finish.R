finish_quadratic <- function(H, center, n) list(optimization_scale=n,
  evaluate=function(p) {
    d <- p-center
    list(value=86000 + drop(crossprod(d, H %*% d))/2, gradient=drop(H %*% d),
      score_error=list(rule=p*0, tail=p*0))
  })

test_that("one common finish retains the original constraint and full nuisance curvature", {
  H0 <- matrix(c(4, 1, .5, 1, 3, .4, .5, .4, 2), 3)
  for (n in c(20, 60, 240)) {
    H <- n*H0; start <- c(.3, .8, -.7); center <- c(.1, -.2, .4)
    ev <- finish_quadratic(H, center, n)
    expected <- center[2:3] - solve(H[2:3, 2:3], H[2:3, 1]*(start[1]-center[1]))
    a <- mfrm_gmfrm_finish_interior(start, ev, fixed=1)
    expect_identical(a$status, "interior_numerical_candidate")
    expect_identical(a$error, "")
    expect_identical(a$selected$parameters[1], start[1])
    expect_equal(a$selected$parameters[2:3], expected, tolerance=1e-9)
    expect_equal(a$information$hessian, H[2:3, 2:3], tolerance=1e-8)
    expect_equal(a$information$covariance, solve(H[2:3, 2:3]), tolerance=1e-8)
    expect_identical(a$information$parameters, a$selected$parameters)
    expect_false(a$information$regularized)
    expect_lte(a$evaluations, 6*2+3)
    expect_gt(abs(a$selected$evaluation$gradient[1]), 1) # Fixed score is not a nuisance score.
  }
})

test_that("the finish does not retry a nonlinear proposal that remains nonstationary", {
  calls <- 0L
  ev <- list(optimization_scale=20, evaluate=function(p) {
    calls <<- calls+1L
    list(value=sum(p^4), gradient=4*p^3, score_error=list(rule=p*0, tail=p*0))
  })
  a <- mfrm_gmfrm_finish_interior(1, ev)
  expect_identical(a$status, "score_unresolved")
  expect_equal(a$selected$parameters, 2/3, tolerance=1e-6)
  expect_null(a$information)
  expect_lte(calls, 5L)
  expect_identical(a$evaluations, calls)
})

test_that("zero scores cannot qualify a saddle or singular curvature", {
  for (H in list(diag(c(1, -1)), diag(c(1, 0)))) {
    a <- mfrm_gmfrm_finish_interior(c(0, 0), finish_quadratic(H, c(0, 0), 20))
    expect_identical(a$status, "numerical_refusal")
    expect_true(nzchar(a$error))
    expect_null(a$information)
    expect_equal(a$selected$parameters, c(0, 0))
  }
})

test_that("integration uncertainty is measured in the full information metric", {
  ev <- finish_quadratic(diag(c(1e-8, 1)), c(0, 0), 1)
  good <- mfrm_gmfrm_finish_interior(c(0, 0), ev)
  expect_identical(good$status, "interior_numerical_candidate") # No N > p veto.
  plain <- ev$evaluate
  ev$evaluate <- function(p) {
    x <- plain(p); x$score_error$rule <- c(1e-7, 0); x
  }
  bad <- mfrm_gmfrm_finish_interior(c(0, 0), ev)
  expect_identical(bad$status, "precision_unresolved")
  expect_equal(unname(bad$checks["IntegrationDiagnostic"]), .001)
  expect_equal(unname(bad$checks["RawScore"]), 0)
})

test_that("a small raw score does not override a material standardized correction", {
  ev <- list(optimization_scale=20, evaluate=function(p)
    list(value=1e-6*sum(p^4), gradient=4e-6*p^3,
      score_error=list(rule=p*0, tail=p*0)))
  a <- mfrm_gmfrm_finish_interior(1, ev)
  expect_identical(a$status, "precision_unresolved")
  expect_lt(unname(a$checks["RawScore"]), 1e-4)
  expect_lt(unname(a$checks["MeanScore"]), 1e-6)
  expect_gt(unname(a$checks["StandardizedScore"]), 1e-4)
  expect_lt(unname(a$checks["CovarianceChange"]), .01)
  expect_identical(dim(a$information$hessians[[1]]$raw), c(1L, 1L))
})

test_that("positive curvature at both steps still requires numerical stability", {
  ev <- list(optimization_scale=20, evaluate=function(p)
    list(value=sum(p^2)/2+1e7*sum(p^4)/4, gradient=p+1e7*p^3,
      score_error=list(rule=p*0, tail=p*0)))
  a <- mfrm_gmfrm_finish_interior(0, ev)
  expect_identical(a$status, "precision_unresolved")
  expect_gt(a$information$hessians[[1]]$symmetric[1, 1], 0)
  expect_gt(a$information$hessians[[2]]$symmetric[1, 1], 0)
  expect_gt(unname(a$checks["CovarianceChange"]), .01)
  expect_equal(unname(a$checks["RawScore"]), 0)
})

test_that("a rejected curvature trial preserves the point and original error", {
  ev <- finish_quadratic(diag(2), c(0, 0), 20)
  ev$evaluate <- function(p) {
    if (!identical(p, c(1, 1))) stop("integration refused this trial")
    list(value=1, gradient=c(1, 1), score_error=list(rule=c(0, 0), tail=c(0, 0)))
  }
  a <- mfrm_gmfrm_finish_interior(c(1, 1), ev)
  expect_identical(a$status, "proposal_unavailable")
  expect_match(a$error, "integration refused this trial", fixed=TRUE)
  expect_identical(a$selected$parameters, c(1, 1))
  expect_null(a$information)
})

test_that("invalid inputs and missing componentwise diagnostics are refused", {
  ev <- finish_quadratic(diag(2), c(0, 0), 20)
  expect_error(mfrm_gmfrm_finish_interior(c(0, 0), ev, fixed=c(1, 1)), "Invalid")
  expect_error(mfrm_gmfrm_finish_interior(c(0, 0), ev, fixed=c(1, 2)), "1-64")
  expect_error(mfrm_gmfrm_finish_interior(rep(0, 65), ev), "1-64")
  ev$optimization_scale <- 0
  expect_error(mfrm_gmfrm_finish_interior(c(0, 0), ev), "Invalid")
  ev$optimization_scale <- 20
  ev$evaluate <- function(p) list(value=0, gradient=p)
  a <- mfrm_gmfrm_finish_interior(c(0, 0), ev)
  expect_identical(a$status, "numerical_refusal")
  expect_match(a$error, "componentwise", fixed=TRUE)
})
