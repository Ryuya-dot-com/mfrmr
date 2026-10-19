test_that("MLS null inversion reduces to exact one-facet F limits", {
  map <- .mfrm_mvgt_anova_interval_design(list(counts = c(Person = 10, Task = 6)))
  for (future in c(1, 6, 12)) for (ratio in c(.01, .8, 1, 5, 100)) {
    problem <- .mfrm_mvgt_mls_prepare(map, c(0, 0, 1/future))
    fit <- .mfrm_mvgt_mls_invert(c(ratio, 2, 1), problem)
    exact <- .mfrm_mvgt_g_f_interval(ratio, 1, map$df[c(1, 3)], 6, future, .95)
    expect_true(fit$valid)
    expect_equal(fit$bounds, c(exact$lower, exact$upper), tolerance = 1e-9)
    expect_identical(fit$empty, all(is.na(exact$lower)))
  }
})

test_that("MLS polynomial pieces match direct signed null intervals and units", {
  map <- .mfrm_mvgt_anova_interval_design(list(counts = c(Person = 5, Rater = 2, Task = 2)))
  ms <- c(3.03016772755561, 23.5742852321426, 7.34687735260113,
    1.10343867919122, 1.65247042838395, .0332467431914948, .270178060331463)
  error <- c(0, .5, .5, .5, .5, .25, .25)
  problem <- .mfrm_mvgt_mls_prepare(map, error)
  fit <- .mfrm_mvgt_mls_invert(ms, problem)
  expect_false(fit$valid)
  expect_equal(unlist(fit$unresolved), c(.917611254276185, .983186501622429), tolerance = 1e-8)
  expect_true(anyNA(.mfrm_mvgt_mls_null_interval(ms, problem, .95)))
  ci <- .mfrm_mvgt_mls_complete(fit, ms, problem)
  expect_true(ci$available); expect_false(ci$formula_complete)
  expect_match(ci$status, "undefined MLS widths")
  expect_equal(ci$bounds, c(0, .983186501622429), tolerance = 1e-8)
  for (scale in c(1e-200, 1e200)) {
    other <- .mfrm_mvgt_mls_invert(ms*scale, problem)
    completed <- .mfrm_mvgt_mls_complete(other, ms*scale, problem)
    expect_equal(completed$bounds, ci$bounds, tolerance = 1e-9)
    expect_equal(completed$undefined, ci$undefined, tolerance = 1e-9)
  }
  for (r in seq(.005, .995, length.out = 75)) {
    direct <- .mfrm_mvgt_mls_null_interval(ms, problem, r)
    retained <- any(r > fit$pieces[, 1] & r < fit$pieces[, 2])
    if (all(is.finite(direct))) expect_identical(retained, direct[1] <= 0 && direct[2] >= 0)
    else expect_true(any(r >= ci$undefined[, 1] & r <= ci$undefined[, 2]))
  }
  broken <- fit; broken$polynomials <- NULL
  expect_false(.mfrm_mvgt_mls_complete(broken, ms, problem)$available)
})

test_that("MLS empty sets remain distinct from failed computations", {
  map <- .mfrm_mvgt_anova_interval_design(list(counts = c(Person = 10, Rater = 2, Task = 4)))
  problem <- .mfrm_mvgt_mls_prepare(map, c(0, 0, 0, .5, .25, 0, .125))
  ms <- c(.954918552918331, 6.1962132904315, 1.04819512975179,
    2.10836010041136, 2.51197656866879, 1.71790404651423, .757726888757608)
  fit <- .mfrm_mvgt_mls_invert(ms, problem)
  ci <- .mfrm_mvgt_mls_complete(fit, ms, problem)
  expect_true(fit$valid); expect_true(fit$empty)
  expect_false(ci$available); expect_true(ci$formula_complete)
  expect_true(all(is.na(ci$bounds)))
})

test_that("public coefficient MLS preserves targets, comparison and saved plots", {
  g <- mfrm_multivariate_gstudy(mfrmr_example_gtheory_crossed, c("Content", "Organization"))
  d <- mfrm_multivariate_d_study(g, data.frame(Raters = c(2, 4, 2), Tasks = c(6, 12, 6)),
    weights = c(Content = .4, Organization = .6))
  original <- d
  for (metric in c("G", "Phi")) {
    ci <- confint(d, parm = metric, assumption = "normal")
    expect_identical(ci, confint(d, parm = metric, assumption = "normal", method = "mls"))
    expect_identical(ci$MethodCode, rep("mls", 3))
    expect_true(all(ci$Available & ci$NumericalComplete & ci$FormulaComplete))
    expect_equal(ci$Estimate, subset(d$coefficients, Kind == "Composite")[[metric]])
    expect_equal(ci$Lower[1], ci$Lower[3]); expect_equal(ci$Upper[1], ci$Upper[3])
    expect_identical(attr(ci, "diagnostics")[[1]], attr(ci, "diagnostics")[[3]])
    scaled <- mfrm_multivariate_d_study(g, d$design_grid, weights = -7*d$weights)
    z <- confint(scaled, parm = metric, assumption = "normal")
    expect_equal(z$Lower, ci$Lower, tolerance = 1e-9)
    expect_equal(z$Upper, ci$Upper, tolerance = 1e-9)
    wide <- confint(d, parm = metric, assumption = "normal", level = .99)
    expect_true(all(wide$Lower <= ci$Lower)); expect_true(all(wide$Upper >= ci$Upper))
    both <- confint(d, parm = metric, assumption = "normal", method = c("mls", "approximate_f"))
    expect_equal(both$Lower[1:3], ci$Lower)
    expect_equal(both$MethodCode, rep(c("mls", "approximate_f"), each = 3))
    expect_length(attr(both, "diagnostics"), 6)
    path <- tempfile(fileext = ".rds"); on.exit(unlink(path), add = TRUE)
    saveRDS(ci, path); expect_identical(readRDS(path), ci)
    expect_s3_class(plot(ci, draw = FALSE), "mfrm_plot_data")
    expect_s3_class(plot(d, metric = metric, intervals = ci, draw = FALSE), "mfrm_plot_data")
    expect_error(confint(d, parm = metric, assumption = "normal", method = "mls", reference = 1), "plan-difference")
    expect_error(confint(d, parm = metric, assumption = "normal", reference = 1), "'mean_square_region' or 'reml_profile'")
  }
  expect_identical(d, original)
  d$gstudy$data <- NULL
  expect_identical(confint(d, assumption = "normal"), confint(original, assumption = "normal"))
  local_mocked_bindings(.mfrm_mvgt_mls_invert = function(...) stop("Unresolved polynomial test"))
  failed <- confint(d, assumption = "normal")
  expect_false(any(failed$Available | failed$NumericalComplete))
  expect_true(all(grepl("Unresolved polynomial", failed$Status)))
  expect_true(all(is.na(failed$Lower) & is.na(failed$Upper)))
})
