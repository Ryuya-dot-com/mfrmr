region_contrast_source <- function(nested = FALSE) {
  x <- if (nested) mfrmr_example_gtheory_nested else mfrmr_example_gtheory_crossed
  g <- mfrm_g_study(x, c("Content", "Organization"),
    nesting = if (nested) c(Rater = "Task"))
  mfrm_d_study(g, data.frame(Raters = c(2, 3, 4, 2), Tasks = c(6, 4, 3, 6)),
    weights = c(Content = .5, Organization = .5))
}

region_contrast_ci <- function(d, metric = "G", reference = 1, ...) {
  confint(d, parm = metric, composite = "Composite", reference = reference,
    method = "mean_square_region", assumption = "normal", ...)
}

test_that("signed linear projections preserve extrema and zero on an independent box", {
  skip_if_not_installed("lpSolve")
  lo <- c(0.2, 0.4, 0.1); hi <- c(1.2, 2, 3)
  setup <- list(units = rep(1, 3), B = diag(3), low = lo, high = hi, tail = .01)
  for (w in list(c(1, -2, .5), c(-1, -2, -.5), c(0, 0, 0), c(0, 2, 1))) {
    expected <- c(sum(pmin(w*lo, w*hi)), sum(pmax(w*lo, w*hi)))
    ans <- .mfrm_mvgt_ms_region(rep(1, 3), setup, w, ratio = FALSE)
    expect_equal(ans$bounds, expected, tolerance = 1e-12)
    expect_equal(ans$solver_status, c(0L, 0L))
  }
})

test_that("product bounds enclose direct differences including zero universe variance", {
  z <- expand.grid(u = c(0, .01, .2, 1, 4), a = seq(.2, 3, length.out = 11),
    b = seq(.1, 2, length.out = 11))
  for (sem in c(FALSE, TRUE)) {
    delta <- if (sem) z$b-z$a else z$a-z$b
    ans <- .mfrm_mvgt_shared_difference(range(z$a), range(z$b), range(delta),
      if (!sem) range(z$u))
    truth <- if (sem) sqrt(z$b)-sqrt(z$a) else z$u/(z$u+z$b)-z$u/(z$u+z$a)
    expect_true(all(truth >= ans$bounds[1] & truth <= ans$bounds[2]))
    for (scale in c(1e-200, 1e200)) {
      scaled <- .mfrm_mvgt_shared_difference(scale*range(z$a), scale*range(z$b),
        scale*range(delta), if (!sem) scale*range(z$u))
      expect_equal(scaled$bounds/if (sem) sqrt(scale) else 1, ans$bounds,
        tolerance = 1e-12)
    }
  }
  positive <- .mfrm_mvgt_shared_difference(c(2, 3), c(.1, 1), c(1, 2.9), c(0, 4))
  expect_identical(positive$bounds[1], 0)
  for (bad in list(c(NA_real_, 1), c(0, 1), c(1e-320, 1e300))) {
    ans <- .mfrm_mvgt_shared_difference(bad, c(.1, 1), c(-1, 1), c(.1, 4))
    expect_true(all(is.na(ans$bounds)))
  }
})

test_that("shared crossed and nested enclosures retain targets, reversal and source state", {
  skip_if_not_installed("lpSolve")
  for (nested in c(FALSE, TRUE)) {
    d <- region_contrast_source(nested); before <- serialize(d, NULL)
    for (metric in c("G", "Phi", "RelativeSEM", "AbsoluteSEM")) {
      ci <- region_contrast_ci(d, metric)
      single <- region_contrast_ci(d, metric, reference = NULL)
      expect_true(all(ci$Available))
      expect_identical(ci$Estimate, single$Estimate[-1]-single$Estimate[1])
      expect_equal(ci$Lower[3], 0); expect_equal(ci$Upper[3], 0)
      expect_true(all(ci$Lower >= single$Lower[-1]-single$Upper[1]-1e-12))
      expect_true(all(ci$Upper <= single$Upper[-1]-single$Lower[1]+1e-12))
      reverse <- region_contrast_ci(d, metric, reference = 2)
      expect_equal(c(ci$Lower[1], ci$Upper[1]),
        -c(reverse$Upper[1], reverse$Lower[1]), tolerance = 1e-10)
      expect_identical(attr(ci, "individual_intervals")$Lower, single$Lower)
      if (!nested && metric == "G") {
        # Independent HiGHS optimization of the raw expected-MS inequalities.
        expect_equal(ci$Lower[1:2], c(.005981622825322456, -.003927518009946386),
          tolerance = 1e-10)
        expect_equal(ci$Upper[1:2], c(.07856672586367394, .10652777972053878),
          tolerance = 1e-10)
      }
      scaled <- mfrm_d_study(d$gstudy, d$design_grid,
        weights = c(Content = -.5e60, Organization = -.5e60))
      scaled_ci <- region_contrast_ci(scaled, metric)
      divisor <- if (grepl("SEM", metric)) 1e60 else 1
      expect_equal(scaled_ci$Lower/divisor, ci$Lower, tolerance = 1e-10)
      expect_equal(scaled_ci$Upper/divisor, ci$Upper, tolerance = 1e-10)
    }
    expect_identical(serialize(d, NULL), before)
  }
})

test_that("unavailable refinement retains the preceding enclosure and contradictory bounds fail", {
  skip_if_not_installed("lpSolve")
  d <- region_contrast_source()
  original <- .mfrm_mvgt_ms_region
  local_mocked_bindings(.mfrm_mvgt_ms_region = function(ms, setup, error, ratio = TRUE) {
    ans <- original(ms, setup, error, ratio)
    if (!ratio && any(error < 0)) {
      ans$bounds[] <- NA_real_; ans$status <- "Linear-program solver failure"
    }
    ans
  })
  ci <- region_contrast_ci(d)
  diag <- attr(ci, "diagnostics")[[1]]$shared_difference
  expect_identical(c(ci$Lower[1], ci$Upper[1]), diag$previous_bounds)
  expect_false(diag$used)
  expect_identical(diag$linear_projections$difference$status, "Linear-program solver failure")
  expect_true(ci$Available[1])
  local_mocked_bindings(.mfrm_mvgt_shared_difference = function(...)
    list(bounds = c(.8, .9), status = "Computed shared-difference enclosure"))
  failed <- region_contrast_ci(d)
  expect_true(all(is.na(failed$Lower[1:2]) & !failed$Available[1:2]))
  expect_true(all(failed$Status[1:2] == "Inconsistent numerical projections"))
})

test_that("degenerate regions never turn identical plans into a zero interval", {
  skip_if_not_installed("lpSolve")
  ci <- region_contrast_ci(region_contrast_source(), level = 1e-100)
  expect_true(all(is.na(ci$Lower) & is.na(ci$Upper) & !ci$Available))
  expect_true(all(grepl("Reference interval unavailable", ci$Status, fixed = TRUE)))
})

test_that("negative source Person estimates are preserved when the population region is available", {
  skip_if_not_installed("lpSolve")
  g <- mfrm_g_study(mfrmr_example_gtheory_crossed, "Content")
  n <- unname(g$design$counts); p <- n[1]; r <- n[2]; t <- n[3]
  L <- rbind(c(r*t,0,0,t,r,0,1), c(0,p*t,0,t,0,p,1),
    c(0,0,p*r,0,r,p,1), c(0,0,0,t,0,0,1), c(0,0,0,0,r,0,1),
    c(0,0,0,0,0,p,1), c(0,0,0,0,0,0,1))
  theta <- c(-.001, .2, .3, .1, .1, .1, .8)
  ms <- drop(L %*% theta); g$data <- NULL
  for (i in seq_along(theta)) {
    g$components[[i]][1, 1] <- theta[i]
    g$mean_products[[i]][1, 1] <- ms[i]
  }
  d <- mfrm_d_study(g, data.frame(Raters = c(2, 3), Tasks = c(6, 4)))
  before <- serialize(d, NULL)
  ci <- confint(d, reference = 1, method = "mean_square_region", assumption = "normal")
  expect_true(ci$Available)
  expect_true(is.na(ci$Estimate))
  expect_lte(ci$Lower, 0); expect_gte(ci$Upper, 0)
  expect_equal(attr(ci, "diagnostics")[[1]]$shared_difference$linear_projections$universe$bounds[1], 0)
  expect_identical(serialize(d, NULL), before)
})

test_that("refined intervals survive summary, plots and saved reuse without recomputation", {
  skip_if_not_installed("lpSolve")
  d <- region_contrast_source(); ci <- region_contrast_ci(d)
  path <- tempfile(fileext = ".rds"); on.exit(unlink(path), add = TRUE)
  saveRDS(list(d = d, ci = ci), path); saved <- readRDS(path)
  local_mocked_bindings(confint.mfrm_multivariate_d_study = function(...) stop("Unexpected recalculation"))
  expect_identical(summary(saved$d, intervals = saved$ci)$intervals[[1]], ci)
  pd <- plot_data(plot(saved$ci, draw = FALSE), "table")
  expect_identical(pd$Lower, ci$Lower)
  expect_identical(pd$Upper, ci$Upper)
  expect_identical(attr(saved$ci, "diagnostics"), attr(ci, "diagnostics"))
})
