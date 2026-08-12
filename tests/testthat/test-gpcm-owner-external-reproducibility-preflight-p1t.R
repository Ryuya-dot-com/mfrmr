gpcm_goer_p1t_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    p1r = file.path(
      validation, "gpcm-owner-current-default-contract-p1r-0.2.3.R"
    ),
    p1t = file.path(
      validation,
      "gpcm-owner-external-reproducibility-preflight-p1t-0.2.3.R"
    ),
    source_audit = file.path(
      validation, "conquest-tam-immer-tolerance-source-audit-0.2.3.md"
    ),
    sirt_source_audit = file.path(
      validation, "external-comparison-eligibility-contract-record-0.2.3.md"
    ),
    record = file.path(
      validation,
      "gpcm-owner-external-reproducibility-preflight-p1t-record-0.2.3.md"
    )
  )
}

gpcm_goer_p1t_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_goer_p1t_paths()
    testthat::skip_if_not(all(file.exists(paths[c("p1r", "p1t")])))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["p1r"]], envir = value)
    sys.source(paths[["p1t"]], envir = value)
    value
  }
})

gpcm_goer_p1t_manifest <- function(env = gpcm_goer_p1t_environment()) {
  env$mfrmr_gocd_p1r_manifest(
    "429a3d880d0535704f72a497277ce23175c9e8435a6dda385d9f845dce1ab829",
    "b1b096dd137f3f9fdf9f30db24fd3dd6cf3d6fe2acfd59b7d1c218868326800f",
    "e029a4cd8b0a42bd593fa4a1d56b539389de20af1c8f766592d7954e1222b75e"
  )
}

test_that("P1t binds exactly the admitted P1s denominator", {
  env <- gpcm_goer_p1t_environment()
  manifest <- gpcm_goer_p1t_manifest(env)
  result <-
    env$mfrmr_run_gpcm_owner_external_reproducibility_preflight_p1t(manifest)

  expect_s3_class(
    result, "mfrmr_gpcm_owner_external_reproducibility_preflight_p1t"
  )
  expect_identical(
    result$P1sManifestSHA256,
    "c7e51e7e166286dc690593921e661827f049252ec5859ea8928b129ab1e34f4f"
  )
  expect_identical(
    digest::digest(
      gpcm_goer_p1t_paths()[["source_audit"]], algo = "sha256",
      file = TRUE, serialize = FALSE
    ),
    result$SourceAuditSHA256
  )
  expect_identical(
    digest::digest(
      gpcm_goer_p1t_paths()[["sirt_source_audit"]], algo = "sha256",
      file = TRUE, serialize = FALSE
    ),
    result$SirtSourceAuditSHA256
  )
  expect_identical(result$PlannedFullRouteProgramPairs, 32L)
  expect_identical(nrow(result$RouteLedger), 32L)
  expect_identical(as.integer(table(result$RouteLedger$RouteId)), rep(4L, 8L))
})

test_that("P1t rejects every full P1s route before numerical comparison", {
  env <- gpcm_goer_p1t_environment()
  result <- env$mfrmr_run_gpcm_owner_external_reproducibility_preflight_p1t(
    gpcm_goer_p1t_manifest(env)
  )
  dispositions <- table(result$RouteLedger$Disposition)

  expect_identical(unname(dispositions["unsupported"]), 12L)
  expect_identical(unname(dispositions["no_exact_route_established"]), 8L)
  expect_identical(unname(dispositions["reduction_only"]), 8L)
  expect_identical(unname(dispositions["non_equivalent"]), 4L)
  expect_true(all(!result$RouteLedger$FullP1sExactReproduction))
  expect_true(all(!result$RouteLedger$NumericComparisonAuthorized))
  expect_identical(result$FullP1sExactRoutes, 0L)
  expect_identical(result$ExternalFitsRun, 0L)
  expect_false(result$P1sReproducedExternally)
})

test_that("P1t keeps projections separate from full P1s reproduction", {
  env <- gpcm_goer_p1t_environment()
  result <- env$mfrmr_run_gpcm_owner_external_reproducibility_preflight_p1t(
    gpcm_goer_p1t_manifest(env)
  )
  projections <- result$ProjectionRegistry

  expect_identical(nrow(projections), 5L)
  expect_identical(anyDuplicated(projections$ProjectionId), 0L)
  expect_identical(
    projections$StructuralStatus[projections$ProjectionId == "CQ-ITEMONLY-MML"],
    "exact_coordinate_map_established"
  )
  expect_true(all(!projections$FullP1sReproduction))
  expect_true(all(!projections$ExternalExecutionAuthorized))
  expect_true(all(!projections$ClaimAuthorized))
})

test_that("P1t fails closed on owner scale manifest and authority drift", {
  env <- gpcm_goer_p1t_environment()
  make <- function() gpcm_goer_p1t_manifest(env)

  owner <- make()
  owner$StepOwner[[1L]] <- "Rater"
  expect_error(env$mfrmr_goer_p1t_validate_manifest(owner),
               "owner or estimator-scale identity")

  scale <- make()
  scale$GpcmMmlIdentification[scale$Estimator == "MML"][1L] <-
    "fixed_standard_normal"
  expect_error(env$mfrmr_goer_p1t_validate_manifest(scale),
               "owner or estimator-scale identity")

  authority <- make()
  authority$ExternalComparisonAuthorized[[1L]] <- TRUE
  expect_error(env$mfrmr_goer_p1t_validate_manifest(authority),
               "cannot widen P1s external")

  identity <- make()
  identity$RuntimeIdentity[[1L]] <- paste(rep("f", 64L), collapse = "")
  expect_error(env$mfrmr_goer_p1t_validate_manifest(identity),
               "admitted P1s manifest content identity")
})

test_that("P1t record binds the executable preflight", {
  env <- gpcm_goer_p1t_environment()
  paths <- gpcm_goer_p1t_paths()
  source_hash <- digest::digest(
    paths[["p1t"]], algo = "sha256", file = TRUE, serialize = FALSE
  )
  text <- paste(readLines(paths[["record"]], warn = FALSE), collapse = "\n")

  expect_identical(
    source_hash,
    "6c4502051016bb12c3935b411b3ce92b8271e194918a585df8f3057ab7160882"
  )
  expect_match(text, source_hash, fixed = TRUE)
  expect_match(text, "FullP1sExactRoutes = 0", fixed = TRUE)
  expect_match(text, "ExternalFitsRun = 0", fixed = TRUE)
  expect_match(text, "ExternalExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "BroadSimulationAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
  expect_identical(
    env$mfrmr_goer_p1t_admitted_manifest_sha256,
    "c7e51e7e166286dc690593921e661827f049252ec5859ea8928b129ab1e34f4f"
  )
})
