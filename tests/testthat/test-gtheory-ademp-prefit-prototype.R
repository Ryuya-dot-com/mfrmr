gtheory_ademp_prefit_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R"
    )
  )
}

load_gtheory_ademp_prefit <- function() {
  paths <- gtheory_ademp_prefit_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtd3_generation <- function(env, scenario_id) {
  env$mfrmr_gtd2_generate(env$mfrmr_gtd_registry(), scenario_id)
}

gtd3_brute_equality_masks <- function(data, factors) {
  if (nrow(data) < 2L) return(integer())
  pairs <- utils::combn(seq_len(nrow(data)), 2L)
  unique(apply(pairs, 2L, function(index) {
    equal <- vapply(
      factors,
      function(factor) data[[factor]][index[[1L]]] ==
        data[[factor]][index[[2L]]],
      logical(1L)
    )
    sum(bitwShiftL(1L, which(equal) - 1L))
  }))
}

test_that("Draft.83d2b0 equality patterns match exhaustive row pairs", {
  env <- load_gtheory_ademp_prefit()
  effective <- data.frame(
    Person = c("P1", "P1", "P2", "P2", "P3", "P3"),
    Rater = c("R1", "R2", "R1", "R3", "R2", "R3"),
    Criterion = c("C1", "C2", "C2", "C1", "C1", "C2"),
    stringsAsFactors = FALSE
  )
  factors <- names(effective)
  audit <- env$mfrmr_gtd3_equality_patterns(effective, factors)
  brute <- sort(gtd3_brute_equality_masks(effective, factors))

  expect_equal(
    sort(audit$EqualityMask[audit$OffDiagonalPairExists]), brute
  )
  expect_equal(nrow(audit), 2^length(factors))
  expect_true(all(audit$MaximumWitnessCount >= 0))
  expect_false(audit$OffDiagonalPairExists[
    audit$EqualityMask == 2^length(factors) - 1L
  ])

  repeated <- rbind(effective, effective[1L, , drop = FALSE])
  repeated_audit <- env$mfrmr_gtd3_equality_patterns(repeated, factors)
  expect_true(repeated_audit$OffDiagonalPairExists[
    repeated_audit$EqualityMask == 2^length(factors) - 1L
  ])
})

test_that("Draft.83d2b0 scalable rank agrees with the dense oracle", {
  env <- load_gtheory_ademp_prefit()
  ids <- c(
    "GT-EXACT-N030", "GT-EXACT-R02-C02",
    "GT-SPARSE-CYCLE-LOW", "GT-NEG-DISCONNECTED"
  )
  expected_rank <- c(7L, 7L, 6L, 6L)
  for (index in seq_along(ids)) {
    generation <- gtd3_generation(env, ids[[index]])
    missingness <- env$mfrmr_gtd3_missingness(
      generation$Scenario$MissingnessMechanism[[1L]]
    )
    incidence <- env$mfrmr_gti_audit(
      generation$Spec, generation$AnalysisData,
      missingness = missingness, max_matrix_cells = 5e6
    )
    dense <- env$mfrmr_gtc_covariance_design(
      generation$Spec, generation$AnalysisData, incidence,
      missingness = missingness, max_matrix_cells = 5e6
    )
    scalable <- env$mfrmr_gtd3_structural_rank(
      generation$Spec, generation$AnalysisData, missingness
    )

    expect_identical(dense$CapacityStatus, "evaluated")
    expect_equal(scalable$StructuralRank, expected_rank[[index]])
    expect_identical(scalable$StructuralRank, dense$StructuralRank)
    expect_identical(scalable$StructuralRankFull, dense$StructuralRankFull)
    expect_lte(nrow(scalable$SignatureMatrix), 2^3)
  }
})

test_that("Draft.83d2b0 exposes exact null directions", {
  env <- load_gtheory_ademp_prefit()
  low <- gtd3_generation(env, "GT-SPARSE-CYCLE-LOW")
  low_rank <- env$mfrmr_gtd3_structural_rank(
    low$Spec, low$AnalysisData, "complete"
  )
  alias <- gtd3_generation(env, "GT-NEG-ALIASED")
  alias_rank <- env$mfrmr_gtd3_structural_rank(
    alias$Spec, alias$AnalysisData, "complete"
  )

  expect_equal(low_rank$StructuralRank, 6L)
  expect_equal(low_rank$StructuralDimension, 7L)
  expect_true(all(c("Person:Rater", "Residual") %in%
                    low_rank$ComponentAudit$ComponentId[
                      low_rank$ComponentAudit$StructuralStatus ==
                        "structurally_confounded"
                    ]))
  expect_equal(alias_rank$StructuralRank, 7L)
  expect_equal(alias_rank$StructuralDimension, 8L)
  expect_true(all(c("Person:Rater:Criterion", "Residual") %in%
                    alias_rank$ComponentAudit$ComponentId[
                      alias_rank$ComponentAudit$StructuralStatus ==
                        "structurally_confounded"
                    ]))
  expect_equal(
    max(abs(low_rank$SignatureMatrix %*% matrix(
      low_rank$NullSpace$Loading,
      nrow = low_rank$StructuralDimension
    ))),
    0, tolerance = 1e-12
  )
})

test_that("Draft.83d2b0 audits the N300 cell without a dense matrix", {
  env <- load_gtheory_ademp_prefit()
  generation <- gtd3_generation(env, "GT-EXACT-N300")
  scalable <- env$mfrmr_gtd3_structural_rank(
    generation$Spec, generation$AnalysisData, "complete"
  )

  expect_equal(scalable$RetainedRows, 19200L)
  expect_equal(scalable$StructuralRank, 7L)
  expect_true(scalable$StructuralRankFull)
  expect_equal(nrow(scalable$EqualityPatterns), 8L)
  expect_lte(nrow(scalable$SignatureMatrix), 8L)
  expect_null(scalable$DerivativeMatrices)
  expect_false(scalable$EstimationReady)
  expect_false(scalable$DecisionReady)
})

test_that("Draft.83d2b0 classifies diagnostic and blocking issues", {
  env <- load_gtheory_ademp_prefit()
  classified <- env$mfrmr_gtd3_classify_issues(c(
    "fixed_equivalent_rank_deficiency:Person:Rater",
    "rank_audit_not_evaluated_capacity",
    "declared_levels_without_retained_rows:Person",
    "unknown_missingness_with_omissions",
    "non_nested_object_facet_disconnected:Rater",
    "highest_order_residual_not_separable",
    "future_unrecognized_issue"
  ))

  expect_equal(sum(classified$Blocking), 3L)
  expect_identical(
    classified$IssueClass[[1L]], "diagnostic_not_covariance_rank"
  )
  expect_identical(
    classified$IssueClass[[2L]], "capacity_superseded_by_scalable_rank"
  )
  expect_identical(
    classified$IssueClass[[3L]], "metric_availability_limited"
  )
  expect_identical(
    classified$IssueClass[[4L]], "missingness_sensitivity"
  )
  expect_identical(
    classified$IssueClass[[7L]], "unclassified_fail_closed"
  )
})

test_that("Draft.83d2b0 freezes all scenario and manifest pre-fit routes", {
  env <- load_gtheory_ademp_prefit()
  result <- env$mfrmr_gtd3_prefit_registry()
  blocked <- result$ScenarioSummary$ScenarioId[
    !result$ScenarioSummary$PreFitEligible
  ]

  expect_s3_class(result, "mfrmr_gtd3_prefit_registry")
  expect_equal(result$GeneratedScenarioCount, 22L)
  expect_equal(result$EligibleScenarioCount, 19L)
  expect_equal(result$BlockedScenarioCount, 3L)
  expect_equal(result$PlannedFitUnits, 89L)
  expect_equal(result$EligibleFitUnits, 77L)
  expect_identical(blocked, c(
    "GT-SPARSE-CYCLE-LOW", "GT-NEG-DISCONNECTED", "GT-NEG-ALIASED"
  ))
  expect_true(all(result$ScenarioSummary$NegativeControlBlockSatisfied))
  expect_false(any(result$ManifestPlan$FitAttemptAuthorized))
  expect_false(any(result$ManifestPlan$AtomicResultRecorded))
  expect_identical(
    result$PreFitPlanHash,
    "022ae8b01eb9febc3b1648bd232066fd11a56609e483e9e8b64d4a526ff94986"
  )
  expect_false(result$FitAttempted)
  expect_false(result$RecoveryEvidenceReady)
  expect_false(result$DecisionReady)
})

test_that("Draft.83d2b0 keeps missingness semantics and metric limits", {
  env <- load_gtheory_ademp_prefit()
  result <- env$mfrmr_gtd3_prefit_registry()
  expect_identical(
    vapply(
      c("none", "MCAR", "MAR_rater_load", "MNAR_score", "unknown"),
      env$mfrmr_gtd3_missingness, character(1L)
    ),
    c(
      none = "complete", MCAR = "MCAR",
      MAR_rater_load = "MAR_covariate",
      MNAR_score = "MNAR_sensitivity", unknown = "unknown"
    )
  )
  mnar <- result$PreFitResults[["GT-MISS-MNAR"]]
  unknown <- result$PreFitResults[["GT-MISS-UNKNOWN"]]
  expect_true(mnar$PreFitEligible)
  expect_true(any(
    mnar$IncidenceIssues$IssueClass == "metric_availability_limited"
  ))
  expect_true(unknown$PreFitEligible)
  expect_true(any(
    unknown$IncidenceIssues$IssueClass == "missingness_sensitivity"
  ))
  expect_false(mnar$EstimationReady)
  expect_false(unknown$CoefficientEligible)
})

test_that("Draft.83d2b0 rejects malformed and blocked inputs", {
  env <- load_gtheory_ademp_prefit()
  registry <- env$mfrmr_gtd_registry()
  anchor <- env$mfrmr_gtd2_generate(registry, "GT-ANCHOR-025")
  generated <- env$mfrmr_gtd2_generate(registry, "GT-EXACT-N030")

  expect_error(
    env$mfrmr_gtd3_missingness("not_registered"),
    "no Draft.83a mapping"
  )
  expect_error(
    env$mfrmr_gtd3_prefit_one(anchor),
    "requires an executable generated scenario"
  )
  expect_error(
    env$mfrmr_gtd3_prefit_one(generated, rank_tolerance = 0),
    "finite positive"
  )
  expect_error(
    env$mfrmr_gtd3_equality_patterns(
      data.frame(Person = character()), "Person"
    ),
    "nonempty effective factor identities"
  )
})
