gtheory_covariance_information_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R"
    )
  )
}

load_gtheory_covariance_information <- function() {
  paths <- gtheory_covariance_information_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  skip_if_not_installed("lme4")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("Draft.83c1 separates covariance rank from expected information", {
  env <- load_gtheory_covariance_information()
  fixture <- env$mfrmr_gte_fixture("pxrxi", "interior")
  audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)
  covariance <- env$mfrmr_gtc_covariance_design(
    fixture$Spec, fixture$Data, audit
  )
  information <- env$mfrmr_gtc_information(
    covariance, fixture$ExpectedComponents
  )

  expect_s3_class(covariance, "mfrmr_gtc_covariance_design")
  expect_true(audit$IncidenceScreenPassed)
  expect_equal(covariance$StructuralRank, 7L)
  expect_equal(covariance$StructuralDimension, 7L)
  expect_true(covariance$StructuralRankFull)
  expect_equal(nrow(covariance$NullSpace), 0L)
  expect_true(all(
    covariance$ComponentAudit$StructuralStatus ==
      "structurally_independent"
  ))
  expect_equal(information$InformationSummary$Method, c("ML", "REML"))
  expect_equal(information$InformationSummary$InformationRank, c(7L, 7L))
  expect_true(all(information$InformationSummary$InformationRankFull))
  expect_true(information$RegularInterior)
  expect_true(information$InformationScreenPassed)
  expect_false(information$InferenceReady)
  expect_false(information$CoefficientEligible)
  expect_false(information$DecisionReady)
  expect_match(covariance$ResultHash, "^[0-9a-f]{64}$")
  expect_match(information$ResultHash, "^[0-9a-f]{64}$")
})

test_that("Draft.83c1 detects highest-order and residual covariance alias", {
  env <- load_gtheory_covariance_information()
  spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Item) + (1 | Person:Item),
    object = "Person", facets = "Item", residual_scale_by = "Item"
  )
  data <- expand.grid(
    Person = paste0("P", seq_len(3L)),
    Item = paste0("I", seq_len(3L)),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data))
  audit <- env$mfrmr_gti_audit(spec, data)
  covariance <- env$mfrmr_gtc_covariance_design(spec, data, audit)

  expect_false(spec$DStudyEligible)
  expect_false(audit$IncidenceScreenPassed)
  expect_equal(covariance$StructuralRank, 3L)
  expect_equal(covariance$StructuralDimension, 4L)
  expect_false(covariance$StructuralRankFull)
  expect_equal(unique(covariance$NullSpace$NullVector), "C1")
  alias <- covariance$NullSpace[
    abs(covariance$NullSpace$Loading) > 0.99, , drop = FALSE
  ]
  expect_setequal(alias$ComponentId, c("Person:Item", "Residual"))
  expect_equal(abs(alias$Loading), c(1, 1))
  expect_true(all(
    covariance$ComponentAudit$StructuralStatus[
      covariance$ComponentAudit$ComponentId %in%
        c("Person:Item", "Residual")
    ] == "structurally_confounded"
  ))
  expect_identical(
    covariance$EstimationEligibility,
    "structural_covariance_confounding"
  )
  expect_false(covariance$CoefficientEligible)
  expect_false(covariance$DecisionReady)
})

test_that("Draft.83c1 exposes the REML intercept-information loss", {
  env <- load_gtheory_covariance_information()
  spec <- env$mfrmr_gta_fixture("pxi")$spec
  data <- expand.grid(
    Person = paste0("P", seq_len(4L)),
    Replicate = seq_len(2L),
    stringsAsFactors = FALSE
  )
  data$Item <- "I1"
  data$Score <- seq_len(nrow(data))
  audit <- env$mfrmr_gti_audit(spec, data)
  covariance <- env$mfrmr_gtc_covariance_design(spec, data, audit)
  information <- env$mfrmr_gtc_information(
    covariance, c(Person = 1, Item = 0.2, Residual = 0.8)
  )

  expect_true(covariance$StructuralRankFull)
  expect_equal(covariance$StructuralRank, 3L)
  expect_equal(
    information$InformationSummary$InformationRank,
    c(ML = 3L, REML = 2L), ignore_attr = TRUE
  )
  expect_equal(
    information$InformationSummary$InformationRankFull,
    c(TRUE, FALSE), ignore_attr = TRUE
  )
  expect_equal(information$InformationSummary$MinimumEigenvalue[[2L]],
               0, tolerance = 1e-12)
  reml_null <- information$NullSpaces$REML
  expect_equal(reml_null$ComponentId[abs(reml_null$Loading) > 0.99],
               "Item")
  expect_equal(abs(reml_null$Loading[reml_null$ComponentId == "Item"]), 1)
  expect_false(information$InformationScreenPassed)
  expect_false(information$DecisionReady)
})

test_that("Draft.83c1 keeps incidence connectivity and covariance rank distinct", {
  env <- load_gtheory_covariance_information()
  spec <- env$mfrmr_gta_fixture("pxi")$spec
  connected <- data.frame(
    Person = c("P1", "P1", "P2", "P2", "P3", "P3", "P4", "P4"),
    Item = c("I1", "I2", "I2", "I3", "I3", "I4", "I4", "I1"),
    Score = seq_len(8L), stringsAsFactors = FALSE
  )
  disconnected <- data.frame(
    Person = rep(paste0("P", seq_len(4L)), each = 2L),
    Item = c("I1", "I2", "I1", "I2", "I3", "I4", "I3", "I4"),
    Score = seq_len(8L), stringsAsFactors = FALSE
  )
  run <- function(data) {
    audit <- env$mfrmr_gti_audit(spec, data)
    covariance <- env$mfrmr_gtc_covariance_design(spec, data, audit)
    information <- env$mfrmr_gtc_information(
      covariance, c(Person = 1, Item = 0.2, Residual = 0.8)
    )
    list(audit = audit, covariance = covariance, information = information)
  }
  connected_result <- run(connected)
  disconnected_result <- run(disconnected)

  expect_true(connected_result$audit$IncidenceScreenPassed)
  expect_false(disconnected_result$audit$IncidenceScreenPassed)
  expect_true(connected_result$covariance$StructuralRankFull)
  expect_true(disconnected_result$covariance$StructuralRankFull)
  expect_true(all(
    connected_result$information$InformationSummary$InformationRankFull
  ))
  expect_true(all(
    disconnected_result$information$InformationSummary$InformationRankFull
  ))
  expect_false(disconnected_result$audit$GlobalConnectivity$IsConnected)
  expect_true("non_nested_object_facet_disconnected:Item" %in%
                disconnected_result$audit$Issues)
  expect_false(disconnected_result$information$DecisionReady)
})

test_that("Draft.83c1 uses conditional grouping identities for nesting", {
  env <- load_gtheory_covariance_information()
  spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Site/Rater),
    object = "Person", facets = c("Site", "Rater"),
    nesting = data.frame(Parent = "Site", Child = "Rater"),
    residual_scale_by = c("Site", "Rater")
  )
  data <- expand.grid(
    Person = paste0("P", seq_len(4L)),
    Site = paste0("S", seq_len(2L)),
    Rater = paste0("R", seq_len(2L)),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data)) / 10
  audit <- env$mfrmr_gti_audit(spec, data)
  covariance <- env$mfrmr_gtc_covariance_design(spec, data, audit)
  information <- env$mfrmr_gtc_information(
    covariance,
    c(Person = 1, Site = 0.3, `Site:Rater` = 0.2, Residual = 0.8)
  )

  expect_true(audit$IncidenceScreenPassed)
  expect_false(spec$DStudyEligible)
  expect_equal(covariance$ComponentAudit$ComponentId,
               c("Person", "Site", "Site:Rater", "Residual"))
  expect_equal(
    covariance$ComponentAudit$GroupingLevels,
    c(Person = 4L, Site = 2L, `Site:Rater` = 4L, Residual = 16L),
    ignore_attr = TRUE
  )
  expect_true(covariance$StructuralRankFull)
  expect_equal(covariance$StructuralRank, 4L)
  expect_true(all(information$InformationSummary$InformationRankFull))
  expect_true(information$RegularInterior)
  expect_false(information$CoefficientEligible)
  expect_false(information$DecisionReady)
})

test_that("Draft.83c1 binds lme4 to the exact retained-row identity", {
  env <- load_gtheory_covariance_information()
  fixture <- env$mfrmr_gte_fixture("pxi", "interior")
  audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)
  draft82 <- env$mfrmr_gte_lme4(
    fixture$Spec, fixture$Data, reml = TRUE
  )
  fit <- env$mfrmr_gtc_lme4(
    fixture$Spec, fixture$Data, audit, reml = TRUE
  )

  expect_s3_class(fit, "mfrmr_gtc_lme4_fit")
  expect_true(fit$PointEstimateAvailable)
  expect_true(fit$EstimationGatePassed)
  expect_identical(fit$FitQualification,
                   "point_estimation_gate_passed")
  expect_identical(fit$FitDiagnostics$FitStatus, "identified")
  expect_false(fit$FitDiagnostics$Singular)
  expect_equal(fit$Components$Estimate, draft82$Components$Estimate,
               tolerance = 1e-8)
  expect_identical(fit$RetainedDataHash, audit$RetainedDataHash)
  expect_identical(fit$IncidenceAuditHash, audit$AuditHash)
  expect_identical(
    fit$EstimatorIdentity$RowContract,
    "draft83a_retained_rows_exact"
  )
  expect_identical(
    fit$EstimatorIdentity$RandomEffects,
    "independent_exchangeable_random_intercepts"
  )
  expect_identical(fit$EstimatorIdentity$Control$Optimizer, "nloptwrap")
  expect_true(fit$EstimatorIdentity$Control$RestartEdge)
  expect_equal(fit$EstimatorIdentity$Control$BoundaryTolerance, 1e-5)
  expect_true(all(grepl(
    "^[0-9a-f]{64}$", fit$EstimatorIdentity$BackendFunctionHashes
  )))
  expect_true(fit$SelectedInformation$InformationRankFull)
  expect_true(fit$ExpectedInformation$RegularInterior)
  expect_false(fit$InferenceReady)
  expect_false(fit$CoefficientEligible)
  expect_false(fit$DecisionReady)
  expect_match(fit$ResultHash, "^[0-9a-f]{64}$")
})

test_that("Draft.83c1 treats a finite boundary fit as nonregular", {
  env <- load_gtheory_covariance_information()
  fixture <- env$mfrmr_gte_fixture("pxi", "negative_raw")
  audit <- env$mfrmr_gti_audit(fixture$Spec, fixture$Data)
  fit <- env$mfrmr_gtc_lme4(
    fixture$Spec, fixture$Data, audit, reml = TRUE
  )

  expect_true(fit$PointEstimateAvailable)
  expect_false(fit$EstimationGatePassed)
  expect_identical(fit$FitQualification, "boundary_nonregular")
  expect_identical(fit$FitDiagnostics$FitStatus,
                   "boundary_or_singular")
  expect_true(fit$FitDiagnostics$Singular)
  expect_equal(fit$FitDiagnostics$OptimizerCode, 0L)
  expect_gte(fit$FitDiagnostics$ZeroComponentCount, 1L)
  expect_true(any(
    fit$Components$BoundaryState == "constrained_zero_boundary"
  ))
  expect_false(fit$ExpectedInformation$RegularInterior)
  expect_true(fit$SelectedInformation$InformationRankFull)
  expect_false(fit$InferenceReady)
  expect_false(fit$CoefficientEligible)
  expect_false(fit$DecisionReady)
})

test_that("Draft.83c1 fails closed on identity, capacity, and variance maps", {
  env <- load_gtheory_covariance_information()
  spec <- env$mfrmr_gta_fixture("pxi")$spec
  data <- expand.grid(
    Person = paste0("P", seq_len(4L)),
    Item = paste0("I", seq_len(3L)),
    stringsAsFactors = FALSE
  )
  data$Score <- seq_len(nrow(data)) / 10
  data$Score[[2L]] <- NA_real_
  audit <- env$mfrmr_gti_audit(
    spec, data, missingness = "MAR_covariate"
  )
  replay <- data[rev(seq_len(nrow(data))), , drop = FALSE]
  replay_audit <- env$mfrmr_gti_audit(
    spec, replay, missingness = "MAR_covariate"
  )
  first <- env$mfrmr_gtc_covariance_design(
    spec, data, audit, missingness = "MAR_covariate"
  )
  second <- env$mfrmr_gtc_covariance_design(
    spec, replay, replay_audit, missingness = "MAR_covariate"
  )

  expect_identical(first$RetainedDataHash, second$RetainedDataHash)
  expect_identical(first$CovarianceDesignHash,
                   second$CovarianceDesignHash)
  expect_identical(first$ResultHash, second$ResultHash)
  changed <- replay
  changed$Score[[1L]] <- changed$Score[[1L]] + 0.01
  expect_error(
    env$mfrmr_gtc_covariance_design(
      spec, changed, audit, missingness = "MAR_covariate"
    ),
    "do not match"
  )
  expect_error(
    env$mfrmr_gtc_covariance_design(
      spec, data, audit, missingness = "complete"
    ),
    "missingness mechanism"
  )
  capacity <- env$mfrmr_gtc_covariance_design(
    spec, data, audit, missingness = "MAR_covariate",
    max_matrix_cells = 1
  )
  expect_identical(capacity$CapacityStatus,
                   "not_evaluated_capacity")
  expect_false(capacity$StructuralRankFull)
  expect_false(capacity$CoefficientEligible)
  expect_false(capacity$DecisionReady)
  expect_error(
    env$mfrmr_gtc_information(
      capacity, c(Person = 1, Item = 0.2, Residual = 0.8)
    ),
    "evaluated covariance design"
  )
  expect_error(
    env$mfrmr_gtc_information(
      first, c(Person = 1, Residual = 0.8)
    ),
    "match every covariance component"
  )
  expect_error(
    env$mfrmr_gtc_information(
      first, c(Person = 1, Item = -0.2, Residual = 0.8)
    ),
    "finite and nonnegative"
  )
})
