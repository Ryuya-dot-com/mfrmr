facets_mfc_design_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "facets-multifacet-confirmation-design-0.2.3.R"
)
facets_mfc_design_env <- new.env(parent = globalenv())
sys.source(facets_mfc_design_path, envir = facets_mfc_design_env)

test_that("confirmation registry freezes complete semantic denominators", {
  env <- facets_mfc_design_env
  registry <- env$mfrmr_facets_mfc_registry()

  expect_true(env$mfrmr_facets_mfc_validate(registry))
  expect_equal(nrow(registry), 180L)
  expect_equal(length(unique(registry$BaseSeed)), 30L)
  expect_equal(
    vapply(c("RSM", "PCM"), function(x) sum(registry$Model == x), integer(1)),
    c(RSM = 90L, PCM = 90L)
  )
  expect_equal(
    vapply(3:5, function(x) sum(registry$TotalFacets == x), integer(1)),
    rep(60L, 3L)
  )
  cell_counts <- vapply(c("RSM", "PCM"), function(model) {
    vapply(3:5, function(total) {
      sum(registry$Model == model & registry$TotalFacets == total)
    }, integer(1))
  }, integer(3))
  expect_equal(unname(cell_counts), matrix(30L, nrow = 3L, ncol = 2L))
  expect_false(any(
    c(registry$BaseSeed, registry$DesignSeed) %in%
      env$mfrmr_facets_mfc_protected_seed_range()
  ))
  expect_true(all(!registry$ResponseDataOpened))
  expect_true(all(!registry$FitOpened))
  expect_true(all(!registry$ResultOpened))
})

test_that("confirmation MCSE rules are fixed without an acceptance tolerance", {
  env <- facets_mfc_design_env
  mcse <- env$mfrmr_facets_mfc_mcse_contract()
  decision <- env$mfrmr_facets_mfc_decision()

  expect_equal(nrow(mcse), 4L)
  expect_equal(mcse$MCSETarget, c(0.0001, 0.0001, 0.06, 0.06))
  expect_true(all(!mcse$AdaptiveExtensionAllowed))
  expect_true(all(is.na(mcse$AcceptanceTolerance)))
  expect_true(all(!mcse$AcceptanceRuleFrozen))
  expect_equal(decision$ExpectedCaseRows, 180L)
  expect_equal(decision$ExpectedElementCoordinateRows, 9120L)
  expect_equal(decision$ExpectedStepCoordinateRows, 1350L)
  expect_equal(decision$ExpectedFacetBlockRows, 720L)
  expect_false(decision$ProtectedSeedOverlap)
  expect_false(decision$ScientificByteEqualityRequired)
  expect_false(decision$FileHashRequired)
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$ConfirmationAuthorized)
  expect_false(decision$EquivalenceClaimAuthorized)
})

test_that("confirmation design fails closed under semantic drift", {
  env <- facets_mfc_design_env
  missing <- env$mfrmr_facets_mfc_registry()[-1L, ]
  overlap <- env$mfrmr_facets_mfc_registry()
  overlap$BaseSeed[1L] <- 451001L
  opened <- env$mfrmr_facets_mfc_registry()
  opened$ResultOpened[1L] <- TRUE

  expect_error(env$mfrmr_facets_mfc_validate(missing), "semantic contract")
  expect_error(env$mfrmr_facets_mfc_validate(overlap), "semantic contract")
  expect_error(env$mfrmr_facets_mfc_validate(opened), "semantic contract")
})

test_that("confirmation design is no-fit and environment-independent", {
  text <- paste(readLines(facets_mfc_design_path, warn = FALSE), collapse = "\n")
  design <- facets_mfc_design_env$mfrmr_facets_mfc_design()

  expect_s3_class(design, "mfrmr_facets_mfc_design")
  expect_false(grepl("fit_mfrm\\s*\\(", text, perl = TRUE))
  expect_false(grepl("system2\\s*\\(", text, perl = TRUE))
  expect_false(grepl("digest::|sha256|SHA-256", text, perl = TRUE))
  expect_match(
    design$decision$Status,
    "design_frozen_execution_blocked_no_acceptance_rule",
    fixed = TRUE
  )
})
