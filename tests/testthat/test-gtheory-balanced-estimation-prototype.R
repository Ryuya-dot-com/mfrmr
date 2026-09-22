gtheory_estimation_paths <- function() {
  root <- testthat::test_path("..", "..", "inst", "validation")
  c(
    design = file.path(root, "gtheory-design-algebra-prototype-0.2.3.R"),
    estimation = file.path(
      root, "gtheory-balanced-estimation-prototype-0.2.3.R"
    )
  )
}

load_gtheory_estimation_prototype <- function(require_lme4 = FALSE) {
  paths <- gtheory_estimation_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  if (isTRUE(require_lme4)) skip_if_not_installed("lme4")
  env <- new.env(parent = globalenv())
  sys.source(paths[["design"]], envir = env)
  sys.source(paths[["estimation"]], envir = env)
  env
}

test_that("Draft.82 p x i MoM recovers the frozen component oracle", {
  env <- load_gtheory_estimation_prototype()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  fit <- env$mfrmr_gte_mom(fixture$Spec, fixture$Data)

  expect_s3_class(fit, "mfrmr_gte_fit")
  expect_equal(
    setNames(fit$Components$Estimate, fit$Components$ComponentId),
    fixture$ExpectedComponents,
    tolerance = 1e-12
  )
  expect_true(fit$DecompositionAudit$DecompositionPassed)
  expect_lt(
    abs(fit$DecompositionAudit$DecompositionDifference),
    fit$DecompositionAudit$DecompositionTolerance
  )
  expect_true(all(fit$Components$BoundaryState == "interior_raw"))
  expect_identical(
    unique(fit$Components$ConstraintIdentity),
    "unconstrained_raw_moment_equations"
  )
  expect_true(fit$EstimationReady)
  expect_false(fit$InferenceReady)
  expect_false(fit$DecisionReady)

  d_study <- env$mfrmr_gte_d_study(
    fit, data.frame(Scenario = "n_item_4", n_Item = 4L)
  )
  expect_equal(d_study$Scenarios$G, 5 / 6, tolerance = 1e-12)
  expect_equal(d_study$Scenarios$Phi, 4 / 5, tolerance = 1e-12)
  expect_true(d_study$Scenarios$AlgebraReady)
  expect_false(d_study$DecisionReady)
  expect_identical(d_study$SourceEstimationHash, fit$ResultHash)
  expect_false(identical(d_study$ResultHash, d_study$AlgebraResultHash))
})

test_that("Draft.82 p x r x i EMS inversion is component-specific", {
  env <- load_gtheory_estimation_prototype()
  fixture <- env$mfrmr_gte_fixture("pxrxi", "interior")
  fit <- env$mfrmr_gte_mom(fixture$Spec, fixture$Data)

  expect_equal(
    setNames(fit$Components$Estimate, fit$Components$ComponentId),
    fixture$ExpectedComponents,
    tolerance = 1e-12
  )
  person_equation <- fit$EMSEquations[
    fit$EMSEquations$MeanSquareId == "Person",
    c("ComponentId", "EMSCoefficient"),
    drop = FALSE
  ]
  expect_identical(
    person_equation$ComponentId,
    c("Residual", "Person:Rater", "Person:Item", "Person")
  )
  expect_equal(person_equation$EMSCoefficient, c(1, 5, 4, 20))
  expect_equal(
    fit$MeanSquares$MeanSquare[fit$MeanSquares$EffectId == "Person"],
    22.88,
    tolerance = 1e-12
  )

  lm_reference <- suppressWarnings(stats::anova(stats::lm(
    Score ~ Person * Rater * Item, data = fixture$Data
  )))
  lm_reference <- lm_reference[rownames(lm_reference) != "Residuals", ]
  reference_index <- match(
    fit$MeanSquares$EffectId, rownames(lm_reference)
  )
  expect_equal(
    fit$MeanSquares$SumSquares,
    lm_reference$`Sum Sq`[reference_index],
    tolerance = 1e-10
  )
  expect_equal(
    fit$MeanSquares$MeanSquare,
    lm_reference$`Mean Sq`[reference_index],
    tolerance = 1e-10
  )

  d_study <- env$mfrmr_gte_d_study(
    fit, data.frame(n_Rater = 2L, n_Item = 3L)
  )
  expect_equal(d_study$Scenarios$RelativeErrorVariance, 0.30,
               tolerance = 1e-12)
  expect_equal(d_study$Scenarios$AbsoluteErrorVariance, 13 / 30,
               tolerance = 1e-12)
  expect_equal(d_study$Scenarios$G, 10 / 13, tolerance = 1e-12)
  expect_equal(d_study$Scenarios$Phi, 30 / 43, tolerance = 1e-12)
})

test_that("Draft.82 lme4 REML reduces to interior balanced MoM", {
  env <- load_gtheory_estimation_prototype(require_lme4 = TRUE)
  for (design in c("pxi", "pxrxi")) {
    fixture <- env$mfrmr_gte_fixture(design, "interior")
    mom <- env$mfrmr_gte_mom(fixture$Spec, fixture$Data)
    reml <- env$mfrmr_gte_lme4(
      fixture$Spec, fixture$Data, reml = TRUE
    )
    ml <- env$mfrmr_gte_lme4(
      fixture$Spec, fixture$Data, reml = FALSE
    )

    expect_equal(
      reml$Components$Estimate, mom$Components$Estimate,
      tolerance = 2e-5,
      info = design
    )
    expect_identical(reml$EstimatorIdentity$Family, "lme4_reml")
    expect_identical(ml$EstimatorIdentity$Family, "lme4_ml")
    expect_identical(reml$FitDiagnostics$FitStatus, "identified")
    expect_identical(ml$FitDiagnostics$FitStatus, "identified")
    expect_true(all(reml$Components$Estimate >= 0))
    expect_true(all(ml$Components$Estimate >= 0))
    expect_gt(
      max(abs(reml$Components$Estimate - ml$Components$Estimate)),
      1e-3
    )
    expect_false(reml$InferenceReady)
    expect_false(reml$DecisionReady)
  }
})

test_that("Draft.82 separates raw negative MoM from lme4 boundary zero", {
  env <- load_gtheory_estimation_prototype(require_lme4 = TRUE)
  fixture <- env$mfrmr_gte_fixture("pxi", "negative_raw")
  mom <- env$mfrmr_gte_mom(fixture$Spec, fixture$Data)
  reml <- env$mfrmr_gte_lme4(fixture$Spec, fixture$Data, reml = TRUE)

  expect_equal(
    setNames(mom$Components$Estimate, mom$Components$ComponentId),
    fixture$ExpectedComponents,
    tolerance = 1e-12
  )
  item_mom <- mom$Components[mom$Components$ComponentId == "Item", ]
  item_reml <- reml$Components[reml$Components$ComponentId == "Item", ]
  expect_lt(item_mom$Estimate, 0)
  expect_identical(item_mom$BoundaryState, "negative_raw")
  expect_gte(item_reml$Estimate, 0)
  expect_lte(item_reml$Estimate, 1e-10)
  expect_identical(
    item_reml$BoundaryState, "constrained_zero_boundary"
  )
  expect_identical(
    unique(reml$Components$ConstraintIdentity),
    "nonnegative_variance_parameterization"
  )
  expect_identical(reml$FitDiagnostics$FitStatus,
                   "boundary_or_singular")
  expect_true(reml$FitDiagnostics$Singular)
  expect_false(identical(mom$ResultHash, reml$ResultHash))

  raw_d <- env$mfrmr_gte_d_study(mom, data.frame(n_Item = 4L))
  expect_identical(
    raw_d$Scenarios$AlgebraStatus, "raw_negative_component"
  )
  expect_false(raw_d$Scenarios$AlgebraReady)
  expect_false(raw_d$DecisionReady)
})

test_that("Draft.82 canonical data identity ignores row order", {
  env <- load_gtheory_estimation_prototype()
  fixture <- env$mfrmr_gte_fixture("pxrxi", "interior")
  reference <- env$mfrmr_gte_mom(fixture$Spec, fixture$Data)
  set.seed(82)
  shuffled_data <- fixture$Data[sample(nrow(fixture$Data)), , drop = FALSE]
  row.names(shuffled_data) <- paste0("row-", seq_len(nrow(shuffled_data)))
  shuffled <- env$mfrmr_gte_mom(fixture$Spec, shuffled_data)

  expect_identical(shuffled$DataHash, reference$DataHash)
  expect_identical(shuffled$ResultHash, reference$ResultHash)
  expect_equal(shuffled$Components$Estimate, reference$Components$Estimate)
})

test_that("Draft.82 rejects incomplete, duplicated, and malformed cells", {
  env <- load_gtheory_estimation_prototype()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  expect_error(
    env$mfrmr_gte_mom(fixture$Spec, fixture$Data[-1L, ]),
    "one finite observation in every complete crossed cell"
  )
  duplicated <- rbind(fixture$Data, fixture$Data[1L, ])
  expect_error(
    env$mfrmr_gte_mom(fixture$Spec, duplicated),
    "one finite observation in every complete crossed cell"
  )
  nonnumeric <- fixture$Data
  nonnumeric$Score <- as.character(nonnumeric$Score)
  expect_error(
    env$mfrmr_gte_mom(fixture$Spec, nonnumeric),
    "finite numeric data"
  )
  missing <- fixture$Data
  missing$Score[1L] <- NA_real_
  expect_error(
    env$mfrmr_gte_mom(fixture$Spec, missing),
    "finite numeric data"
  )
})

test_that("Draft.82 collapsed lme4 identity reproduces current helper", {
  env <- load_gtheory_estimation_prototype(require_lme4 = TRUE)
  skip_if_not(exists("mfrm_generalizability", mode = "function"),
              "package public API is not loaded")
  fixture <- env$mfrmr_gte_fixture("pxrxi", "interior")
  collapsed <- env$mfrmr_gte_lme4(
    fixture$Spec, fixture$Data, reml = TRUE,
    decomposition = "main_effects_collapsed_residual_v1"
  )
  public_fit <- structure(
    list(
      prep = list(data = fixture$Data),
      config = list(facet_names = c("Rater", "Item"))
    ),
    class = "mfrm_fit"
  )
  public <- mfrm_generalizability(
    public_fit, data = fixture$Data,
    object_facet = "Person", random_facets = c("Rater", "Item"),
    reml = TRUE
  )

  expect_identical(
    collapsed$ModelIdentity, "main_effects_collapsed_residual_v1"
  )
  public_estimate <- setNames(
    public$variance_components$Variance,
    public$variance_components$Source
  )[collapsed$Components$ComponentId]
  expect_equal(
    round(collapsed$Components$Estimate, 6),
    as.numeric(public_estimate),
    tolerance = 1e-12
  )
  expect_equal(nrow(collapsed$Components), 4L)
  expect_error(
    env$mfrmr_gte_d_study(collapsed, data.frame(n_Rater = 2L, n_Item = 3L)),
    "existing sensitivity contract"
  )

  typed <- env$mfrmr_gte_lme4(
    fixture$Spec, fixture$Data, reml = TRUE,
    decomposition = "typed_complete_crossed"
  )
  expect_equal(nrow(typed$Components), 7L)
  expect_false(identical(typed$ResultHash, collapsed$ResultHash))
})
