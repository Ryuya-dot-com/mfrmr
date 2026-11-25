test_that("constrained steps survive fitting, inference and reporting", {
  ratings <- subset(load_mfrmr_data("example_core"), Criterion %in% c("Accuracy", "Content"))
  declarations <- data.frame(Level = c("Accuracy", "Content"),
                             From = 1, To = 2, Group = "first")
  fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "PCM", step_facet = "Criterion", spec = list(step_constraints = declarations), fast = FALSE)
  expect_equal(length(coef(fit)), length(fit$config$facet_levels$Rater) - 1L + 1L + 3L)
  steps <- confint(fit, parm = "steps")
  shared <- steps[steps$Step == "Step_1", ]
  expect_identical(shared$Estimate[1], shared$Estimate[2])
  expect_true(all(is.finite(shared$SE)))
  expect_equal(shared$SE[1], shared$SE[2], tolerance = 1e-12)

  saved <- tempfile(fileext = ".rds")
  on.exit(unlink(saved), add = TRUE)
  saveRDS(fit, saved)
  reloaded <- readRDS(saved)
  p_fit <- predict(fit, type = "prob")
  p_rel <- predict(reloaded, type = "prob")
  expect_identical(dimnames(p_fit), dimnames(p_rel))
  expect_equal(p_fit, p_rel, tolerance = 1e-12)
  root <- find.package("mfrmr")
  if (isTRUE(as.logical(Sys.getenv("NOT_CRAN"))) &&
      requireNamespace("callr", quietly = TRUE) &&
      file.exists(file.path(root, "Meta", "package.rds"))) {
    actual <- callr::r(function(file, lib) {
      library("mfrmr", lib.loc = lib)
      fit <- readRDS(file)
      list(probability = predict(fit, type = "prob"), steps = confint(fit, parm = "steps"))
    }, args = list(saved, dirname(root)), libpath = .libPaths())
    expect_equal(actual$probability, p_fit, tolerance = 1e-12)
    expect_equal(actual$steps, steps, tolerance = 1e-12)
  }
  expect_identical(fit$config$replay_inputs$step_constraints, declarations)

  declarations$Value <- c(-0.7, NA)
  fixed <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "PCM", step_facet = "Criterion", spec = list(step_constraints = declarations), fast = FALSE)
  steps <- confint(fixed, parm = "steps")
  expect_equal(nrow(steps), 6L)
  expect_equal(steps$Estimate[steps$Step == "Step_1"], rep(-0.7, 2))
  expect_true(all(is.na(steps$SE[steps$Step == "Step_1"])))
  expect_false(any(steps$CIEligible[steps$Step == "Step_1"]))
})

test_that("contradictory or unsupported step declarations fail before fitting", {
  ratings <- load_mfrmr_data("example_core")
  fixed <- data.frame(Level = "shared", From = 1:3, To = 2:4, Value = c(-1, 0, 2))
  expect_error(fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    spec = list(step_constraints = fixed)), "sum-to-zero")
  expect_error(fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score", method = "JML",
    spec = list(step_constraints = fixed)), "sum-to-zero")
  expect_error(fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    spec = list(step_constraints = fixed[c(1, 1), ])), "only once")
})

test_that("step_constraints support estimated normal populations and affine-subspace nested LRTs", {
  skip_on_cran()
  ratings <- load_mfrmr_data("example_core")
  crit_lvls <- sort(unique(as.character(ratings$Criterion)))
  pdata <- data.frame(Person = sort(unique(as.character(ratings$Person))), stringsAsFactors = FALSE)
  pdata$Group <- rep(c(0, 1), length.out = nrow(pdata))

  decl_12 <- data.frame(Level = crit_lvls[1:2], From = c(1, 1), To = c(2, 2), Group = c("g1", "g1"))
  decl_23 <- data.frame(Level = crit_lvls[2:3], From = c(1, 1), To = c(2, 2), Group = c("g2", "g2"))

  fit_rsm <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", method = "MML", population_formula = ~ Group, person_data = pdata, fast = FALSE)
  fit_hyb <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "PCM", step_facet = "Criterion", method = "MML",
    population_formula = ~ Group, person_data = pdata,
    spec = list(step_constraints = decl_12), fast = FALSE)
  fit_pcm <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "PCM", step_facet = "Criterion", method = "MML",
    population_formula = ~ Group, person_data = pdata, fast = FALSE)

  cmp1 <- compare_mfrm(fit_rsm, fit_hyb, nested = TRUE)
  cmp2 <- compare_mfrm(fit_hyb, fit_pcm, nested = TRUE)
  expect_identical(cmp1$comparison_basis$lrt_status, "computed")
  expect_identical(cmp2$comparison_basis$lrt_status, "computed")
  expect_equal(cmp1$lrt$df + cmp2$lrt$df, length(fit_pcm$opt$par) - length(fit_rsm$opt$par))
  expect_equal(cmp1$lrt$ChiSq + cmp2$lrt$ChiSq,
               2 * (fit_pcm$summary$LogLik - fit_rsm$summary$LogLik), tolerance = 1e-10)

  # Reversing model order gives the identical test.
  cmp1_rev <- compare_mfrm(fit_hyb, fit_rsm, nested = TRUE)
  expect_equal(cmp1_rev$lrt$ChiSq, cmp1$lrt$ChiSq, tolerance = 1e-12)
  expect_equal(cmp1_rev$lrt$df, cmp1$lrt$df)

  # Non-nested crossing step-group partitions and equivalent subspaces are rejected.
  fit_hyb_alt <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
    model = "PCM", step_facet = "Criterion", method = "MML",
    population_formula = ~ Group, person_data = pdata,
    spec = list(step_constraints = decl_23), fast = FALSE)
  expect_warning(cmp_cross <- compare_mfrm(fit_hyb, fit_hyb_alt, nested = TRUE), "not nested")
  expect_null(cmp_cross$lrt)
  expect_identical(cmp_cross$comparison_basis$nesting_review$relation, "step_constraints_not_nested")

  rev_eq <- mfrmr:::audit_compare_mfrm_nesting(list(fit_hyb, fit_hyb), c("a", "b"))
  expect_false(rev_eq$eligible)
  expect_identical(rev_eq$relation, "step_constraints_equivalent")
})
