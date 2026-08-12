gpcm_grsd_p1p_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    p1o = file.path(
      validation, "gpcm-reflected-finite-grid-registry-p1o-0.2.3.R"
    ),
    p1p = file.path(
      validation, "gpcm-release-scope-disposition-p1p-0.2.3.R"
    ),
    checklist = file.path(
      validation, "release-evidence-checklist-0.2.3.csv"
    ),
    disposition = file.path(
      validation, "claim-disposition-profile-0.2.3.csv"
    ),
    record = file.path(
      validation, "gpcm-release-scope-disposition-p1p-record-0.2.3.md"
    )
  )
}

gpcm_grsd_p1p_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_grsd_p1p_paths()
    testthat::skip_if_not(all(file.exists(paths)), "validation artifacts excluded")
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["p1o"]], envir = value)
    sys.source(paths[["p1p"]], envir = value)
    value
  }
})

test_that("P1p freezes P1o and the current release tables", {
  env <- gpcm_grsd_p1p_environment()
  paths <- gpcm_grsd_p1p_paths()
  expect_identical(
    env$mfrmr_grsd_p1p_contract,
    "mfrmr_gpcm_release_scope_disposition_p1p_v1"
  )
  expect_identical(
    digest::digest(paths[["p1o"]], "sha256", file = TRUE, serialize = FALSE),
    env$mfrmr_grsd_p1p_dependency_sha256
  )
  expect_identical(
    digest::digest(paths[["p1p"]], "sha256", file = TRUE, serialize = FALSE),
    "3859a0f9275928d034a100d2653d548780f751bebaae9f8b7a1f3b75e5271323"
  )
  tables <- env$mfrmr_grsd_p1p_release_tables(dirname(paths[["checklist"]]))
  expect_equal(nrow(tables$checklist), 106L)
  expect_equal(nrow(tables$disposition), 106L)
  expect_identical(tables$checklist$Item, tables$disposition$Item)
})

test_that("P1p selects owner partition and preserves conditional fallbacks", {
  env <- gpcm_grsd_p1p_environment()
  paths <- gpcm_grsd_p1p_paths()
  tables <- env$mfrmr_grsd_p1p_release_tables(dirname(paths[["checklist"]]))
  rows <- env$mfrmr_grsd_p1p_release_rows(tables)
  owner <- rows$Item == "gpcm_owner_evidence_partition"
  fit <- rows$Item == "gpcm_fit_operating_characteristics"
  dff <- rows$Item == "gpcm_dff_estimand_specificity"

  expect_equal(sum(owner), 1L)
  expect_identical(rows$PortfolioClass[owner], "release_spine")
  expect_identical(rows$EvidenceStatus[owner], "review")
  expect_identical(
    rows$FallbackCode[fit],
    "retain_gpcm_fit_as_exploratory_no_decision"
  )
  expect_identical(
    rows$FallbackCode[dff],
    "disable_gpcm_dff_inferential_promotion"
  )
})

test_that("P1p audits the public GPCM capability boundary", {
  env <- gpcm_grsd_p1p_environment()
  capabilities <- env$mfrmr_grsd_p1p_public_capabilities()
  expect_identical(
    capabilities$CapabilityID,
    c(
      "core_fit_summary", "exploratory_diagnostics", "dff_screening",
      "mcmc_backends", "facets_score_review"
    )
  )
  expect_identical(
    capabilities$Status,
    c(
      "supported_with_caveat", "supported_with_caveat",
      "supported_with_caveat", "deferred", "blocked"
    )
  )
})

test_that("P1p retains the finite claim without promoting GPCM", {
  env <- gpcm_grsd_p1p_environment()
  paths <- gpcm_grsd_p1p_paths()
  p1o <- list(
    contract = env$mfrmr_grsd_p1p_dependency_contract,
    FullFourFixtureFiniteGridRegistryCompleted = TRUE,
    RefitFallbackRequired = FALSE,
    ContinuousGlobalProfileCertified = FALSE
  )
  result <- env$mfrmr_run_gpcm_release_scope_disposition_p1p(
    p1o, validation_dir = dirname(paths[["checklist"]])
  )

  expect_s3_class(result, "mfrmr_gpcm_release_scope_disposition_p1p")
  expect_true(result$FiniteGridClaimRetained)
  expect_true(result$ContinuousRatioWorkDeferred)
  expect_identical(
    result$NextReleaseSpineItem, "gpcm_owner_evidence_partition"
  )
  expect_true(result$ReleaseScopeDispositionComplete)
  expect_false(result$GPCMCorePromotionAuthorized)
  expect_false(result$ContinuousGlobalProfileCertified)
  expect_false(result$HessianInferenceAuthorized)
  expect_false(result$DFFFitRankAuthorized)
  expect_false(result$BroadSimulationAuthorized)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1p stored-result audit remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1P_PILOT"), "true"),
    "set MFRMR_RUN_P1P_PILOT=true and MFRMR_P1O_RESULT to a P1o RDS"
  )
  path <- Sys.getenv("MFRMR_P1O_RESULT")
  testthat::skip_if_not(file.exists(path), "MFRMR_P1O_RESULT does not exist")
  env <- gpcm_grsd_p1p_environment()
  result <- env$mfrmr_run_gpcm_release_scope_disposition_p1p(readRDS(path))
  expect_true(result$ReleaseScopeDispositionComplete)
  expect_true(result$FiniteGridClaimRetained)
  expect_true(result$ContinuousRatioWorkDeferred)
  expect_identical(
    result$NextReleaseSpineItem, "gpcm_owner_evidence_partition"
  )
  expect_false(result$GPCMCorePromotionAuthorized)
  expect_false(result$BroadSimulationAuthorized)
})

test_that("P1p record preserves the bounded disposition", {
  text <- paste(
    readLines(gpcm_grsd_p1p_paths()[["record"]], warn = FALSE),
    collapse = "\n"
  )
  expect_match(text, "FiniteGridClaimRetained = TRUE", fixed = TRUE)
  expect_match(text, "ContinuousRatioWorkDeferred = TRUE", fixed = TRUE)
  expect_match(
    text, "NextReleaseSpineItem = gpcm_owner_evidence_partition", fixed = TRUE
  )
  expect_match(text, "GPCMCorePromotionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "BroadSimulationAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "SelectionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
