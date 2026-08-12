facets_gpcm_jml_role_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    contract = file.path(
      validation, "facets-gpcm-jml-comparison-role-contract-0.2.3.R"
    ),
    record = file.path(
      validation, "facets-gpcm-jml-comparison-role-contract-record-0.2.3.md"
    )
  )
}

facets_gpcm_jml_role_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- facets_gpcm_jml_role_paths()
    testthat::skip_if_not(file.exists(paths[["contract"]]))
    value <<- new.env(parent = globalenv())
    sys.source(paths[["contract"]], envir = value)
    value
  }
})

test_that("FACETS comparison roles keep PCM direct and GPCM indirect", {
  env <- facets_gpcm_jml_role_environment()
  result <- env$mfrmr_facets_gpcm_jml_comparison_role_contract()

  expect_s3_class(
    result, "mfrmr_facets_gpcm_jml_comparison_role_contract"
  )
  expect_true(result$StructuralRoleContractComplete)
  expect_true(result$FacetsPcmJmlDirectLaneDefined)
  expect_false(result$FacetsDirectFreeSlopeGpcmRouteExists)
  expect_identical(result$ExternalFitsRun, 0L)

  direct <- result$LaneRegistry[
    result$LaneRegistry$LaneId == "FACETS-PCM-JML-DIRECT", , drop = FALSE
  ]
  expect_identical(direct$PrimaryRouteId, "MFRMR-PCM-JML")
  expect_identical(direct$ComparatorRouteId, "FACETS-PCM-JMLE")
  expect_identical(
    direct$EstimandRelation, "direct_common_estimand_after_contract"
  )
  expect_match(direct$ForbiddenClaim, "free_slope_GPCM", fixed = TRUE)
})

test_that("FACETS Table 7 discrimination remains diagnostic only", {
  env <- facets_gpcm_jml_role_environment()
  result <- env$mfrmr_facets_gpcm_jml_comparison_role_contract()
  estimators <- result$EstimatorRegistry

  facets <- estimators[estimators$Program == "FACETS", , drop = FALSE]
  expect_true(all(!facets$FreeSlopeEstimatedInLikelihood))
  expect_true(all(!facets$ExactFullMfrmrGpcmIdentity))

  discrm <- estimators[
    estimators$RouteId == "FACETS-T7-DISCRM", , drop = FALSE
  ]
  expect_identical(discrm$EstimatorFamily, "postfit_diagnostic")
  expect_identical(
    discrm$SlopeRole,
    "postfit_diagnostic_does_not_update_other_estimates"
  )
  lane <- result$LaneRegistry[
    result$LaneRegistry$LaneId == "FACETS-DISCRM-DIAGNOSTIC", , drop = FALSE
  ]
  expect_identical(
    lane$EstimandRelation, "postfit_diagnostic_association_only"
  )
  expect_match(lane$ForbiddenClaim, "slope_estimate_equality", fixed = TRUE)
})

test_that("unpenalized JML is separated from neighbouring estimators", {
  env <- facets_gpcm_jml_role_environment()
  result <- env$mfrmr_facets_gpcm_jml_comparison_role_contract()
  estimators <- result$EstimatorRegistry

  mfrmr <- estimators[
    estimators$RouteId == "MFRMR-GPCM-JML", , drop = FALSE
  ]
  pjml <- estimators[
    estimators$RouteId == "WIJAYANTO-GPCM-PJML", , drop = FALSE
  ]
  box <- estimators[
    estimators$RouteId == "RIRT-GPCM-BOX-JML", , drop = FALSE
  ]
  mml <- estimators[
    estimators$RouteId == "MURAKI-GPCM-MML-EM", , drop = FALSE
  ]

  expect_identical(mfrmr$StatisticalPenalty, "none")
  expect_identical(mfrmr$FiniteParameterBox, "none")
  expect_identical(
    pjml$StatisticalPenalty, "ridge_on_person_and_log_discrimination"
  )
  expect_match(box$FiniteParameterBox, "ability_discrimination", fixed = TRUE)
  expect_identical(mml$PersonTreatment, "integrated_random_effect")
  expect_true(result$MfrmrUnpenalizedJmlSeparatedFromPjml)
  expect_true(result$MfrmrUnpenalizedJmlSeparatedFromFiniteBoxJml)
})

test_that("comparison-role mutations fail closed", {
  env <- facets_gpcm_jml_role_environment()
  make <- function() env$mfrmr_facets_gpcm_jml_comparison_role_contract()

  slope <- make()
  slope$EstimatorRegistry$FreeSlopeEstimatedInLikelihood[
    slope$EstimatorRegistry$RouteId == "FACETS-T7-DISCRM"
  ] <- TRUE
  expect_error(
    env$mfrmr_fgjc_validate_result(slope),
    "cannot be classified as a fitted GPCM slope"
  )

  direct <- make()
  direct$LaneRegistry$PrimaryRouteId[
    direct$LaneRegistry$LaneId == "FACETS-PCM-JML-DIRECT"
  ] <- "MFRMR-GPCM-JML"
  expect_error(
    env$mfrmr_fgjc_validate_result(direct),
    "only direct FACETS lane"
  )

  authority <- make()
  authority$LaneRegistry$CurrentExternalExecutionAuthorized[[1L]] <- TRUE
  expect_error(
    env$mfrmr_fgjc_validate_result(authority),
    "cannot authorize execution or promotion"
  )
})

test_that("comparison-role record binds the executable contract", {
  skip_if_not_installed("digest")
  paths <- facets_gpcm_jml_role_paths()
  skip_if_not(all(file.exists(paths)))
  contract_hash <- digest::digest(
    paths[["contract"]], algo = "sha256", file = TRUE, serialize = FALSE
  )
  test_hash <- digest::digest(
    testthat::test_path("test-facets-gpcm-jml-comparison-role-contract.R"),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, contract_hash, fixed = TRUE)
  expect_match(record, test_hash, fixed = TRUE)
  expect_match(record, "FacetsDirectFreeSlopeGpcmRouteExists = FALSE",
               fixed = TRUE)
  expect_match(record, "ExternalFitsRun = 0", fixed = TRUE)
  expect_match(record, "GpcmCorePromotionAuthorized = FALSE", fixed = TRUE)
})
