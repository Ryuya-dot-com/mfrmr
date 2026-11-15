test_that("ordinary MML separates finite Person EAPs from an extreme rater path", {
  set.seed(111021)
  d <- expand.grid(Person = paste0("P", 1:24), Rater = paste0("R", 1:3),
    Task = paste0("T", 1:2), stringsAsFactors = FALSE)
  d$Score <- sample(1:5, nrow(d), replace = TRUE)
  d$Score[d$Rater == "R3"] <- 5L
  for (model in c("RSM", "PCM")) {
  f <- suppressWarnings(fit_mfrm(d, person = "Person",
    facets = c("Rater", "Task"), score = "Score", model = model, method = "MML",
    step_facet = if (model == "PCM") "Task" else NULL,
    rating_min = 1, rating_max = 5, noncenter_facet = "Rater", keep_original = TRUE,
    mml_integration = "fixed", quad_points = 31L, maxit = 500L))
  expect_true(all(is.finite(f$facets$person$Estimate)))
  expect_identical(f$readiness$fit$BoundaryState, "nonfinite_maximum")
  expect_false(f$readiness$fit$InferenceReady)
  expect_match(f$readiness$fit$ReasonCodes, "mml_extreme_free_facet_location")
  # Emulate a saved result from the former Person-only boundary classification.
  old <- f
  old$readiness$fit$BoundaryState <- "finite"
  old$readiness$fit$InferenceReady <- TRUE
  original <- serialize(old, NULL)
  expect_identical(mfrmr_get_readiness_record(old)$fit$BoundaryState, "nonfinite_maximum")
  expect_match(summary(old)$estimation_note, "not ordinary maximum-likelihood estimates")
  ci <- suppressWarnings(mfrm_facet_intervals(old, "Rater"))
  expect_false(any(ci$table$CIEligible))
  expect_true(all(is.na(ci$table$Lower) & is.na(ci$table$Upper)))
  expect_true(all(grepl("no finite maximum", ci$table$InferenceReview)))
  expect_identical(serialize(old, NULL), original)
  expect_identical(old$opt, f$opt)

  for (change in c("anchor", "group", "center", "penalty", "zero_sign")) {
    cfg <- f$config
    if (change == "anchor") cfg$facet_specs$Rater$anchors["R3"] <- .5
    if (change == "group") cfg$facet_specs$Rater$groups["R3"] <- "fixed_group"
    if (change == "center") cfg$facet_specs$Rater$centered <- TRUE
    if (change == "penalty") cfg$facet_shrinkage <- "ridge"
    if (change == "zero_sign") cfg$facet_signs["Rater"] <- 0
    expect_length(mfrmr_mml_additive_boundary_evidence(cfg), 0)
  }
  }
})

test_that("ordinary MML detects free endpoint paths without treating local zeros alike", {
  set.seed(111022)
  d <- expand.grid(Person = paste0("P", 1:24), Rater = paste0("R", 1:3),
    Task = paste0("T", 1:2), stringsAsFactors = FALSE)
  d$Score <- sample(1:4, nrow(d), replace = TRUE)
  f <- suppressWarnings(fit_mfrm(d, person = "Person",
    facets = c("Rater", "Task"), score = "Score", model = "PCM", method = "MML",
    step_facet = "Rater", rating_min = 1, rating_max = 5, noncenter_facet = "Rater", keep_original = TRUE,
    mml_integration = "fixed", quad_points = 31L, maxit = 500L))
  expect_identical(f$readiness$fit$BoundaryState, "nonfinite_maximum")
  expect_match(f$readiness$fit$ReasonCodes, "mml_unobserved_global_endpoint")
  expect_match(f$readiness$fit$ReasonCodes, "mml_unobserved_owner_endpoint")
  expect_equal(f$prep$rating_max, 5L)
  cfg <- f$config
  for (owner in names(cfg$step_specs)) cfg$step_specs[[owner]]$anchors[] <- 0
  expect_length(mfrmr_mml_additive_boundary_evidence(cfg), 0)
  cfg <- f$config
  cfg$category_support_audit$category_table$WithinScopeWeightedN <- 1
  cfg$category_support_audit$category_table$GlobalWeightedN <- 1
  expect_length(mfrmr_mml_additive_boundary_evidence(cfg), 0)
})

test_that("centered MML paths require compensation and respect direct anchors", {
  set.seed(111023)
  d <- expand.grid(Person = paste0("P", 1:24), Rater = paste0("R", 1:3),
    Task = paste0("T", 1:2), stringsAsFactors = FALSE)
  d$Score <- sample(1:5, nrow(d), replace = TRUE)
  d$Score[d$Rater == "R3"] <- 5L
  base <- list(data = d, person = "Person", facets = c("Rater", "Task"),
    score = "Score", model = "RSM", method = "MML", rating_min = 1,
    rating_max = 5, keep_original = TRUE, mml_engine = "direct",
    mml_integration = "fixed", quad_points = 61L, maxit = 1000L, reltol = 1e-10)
  settings <- list(
    fixed = list(noncenter_facet = "Person"),
    task = list(noncenter_facet = "Task"),
    mean = list(noncenter_facet = "Person", population_formula = ~1,
      person_data = data.frame(Person = unique(d$Person)), population_sd = 1),
    anchor_extreme = list(noncenter_facet = "Rater", anchors = data.frame(
      Facet = "Rater", Level = "R3", Anchor = .6)),
    anchor_other = list(noncenter_facet = "Rater", anchors = data.frame(
      Facet = "Rater", Level = "R1", Anchor = -.6)))
  for (setting in names(settings)) {
    f <- suppressWarnings(do.call(fit_mfrm, c(base, settings[[setting]])))
    boundary <- setting %in% c("task", "mean", "anchor_other")
    expect_identical(f$readiness$fit$BoundaryState,
      if (boundary) "nonfinite_maximum" else "finite", info = setting)
    expect_true(all(is.finite(f$facets$person$Estimate)))
    ci <- suppressWarnings(mfrm_facet_intervals(f, "Rater"))
    if (boundary) {
      expect_false(any(ci$table$CIEligible))
      expect_match(summary(f)$estimation_note, "no finite maximum")
    } else {
      free <- ci$table$Status != "fixed"
      expect_true(all(ci$table$CIEligible[free]))
      if (setting == "anchor_extreme") {
        expect_equal(ci$table$Estimate[ci$table$Target == "R3"], .6)
        expect_equal(ci$table$SE[ci$table$Target == "R3"], 0)
      }
    }
    if (setting == "mean") {
      cfg <- f$config
      cfg$population_spec$design_columns <- "slope_without_intercept"
      expect_length(mfrmr_mml_additive_boundary_evidence(cfg), 0)
      cfg <- f$config
      cfg$population_spec$design_matrix[,] <- 0
      expect_length(mfrmr_mml_additive_boundary_evidence(cfg), 0)
      cfg <- f$config
      cfg$facet_specs$Rater$anchors["R1"] <- -.6
      expect_length(mfrmr_mml_additive_boundary_evidence(cfg), 0)
    }
  }
  # A centered owner can still lose its last category if Task absorbs the mean.
  d$Score <- sample(1:5, nrow(d), replace = TRUE)
  d$Score[d$Rater == "R3" & d$Score == 5] <- 4L
  base$data <- d; base$model <- "PCM"; base$step_facet <- "Rater"
  f <- suppressWarnings(do.call(fit_mfrm, c(base, list(noncenter_facet = "Task"))))
  expect_match(f$readiness$fit$ReasonCodes, "mml_unobserved_owner_endpoint")
  expect_identical(f$readiness$fit$BoundaryState, "nonfinite_maximum")
})
