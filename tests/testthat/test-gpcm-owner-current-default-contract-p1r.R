gpcm_gocd_p1r_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    p1q = file.path(
      validation, "gpcm-owner-identity-propagation-p1q-0.2.3.R"
    ),
    runner = file.path(
      validation, "gpcm-owner-current-default-contract-p1r-0.2.3.R"
    ),
    record = file.path(
      validation,
      "gpcm-owner-current-default-contract-p1r-record-0.2.3.md"
    )
  )
}

gpcm_gocd_p1r_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_gocd_p1r_paths()
    testthat::skip_if_not(all(file.exists(paths[c("p1q", "runner")])))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["runner"]], envir = value)
    value
  }
})

gpcm_gocd_p1r_hash <- function(letter) paste(rep(letter, 64L), collapse = "")

test_that("P1r freezes its P1q dependency and eight-route design", {
  env <- gpcm_gocd_p1r_environment()
  paths <- gpcm_gocd_p1r_paths()
  expect_identical(
    digest::digest(
      paths[["p1q"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gocd_p1r_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["runner"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "e029a4cd8b0a42bd593fa4a1d56b539389de20af1c8f766592d7954e1222b75e"
  )
  manifest <- env$mfrmr_gocd_p1r_manifest(
    gpcm_gocd_p1r_hash("a"), gpcm_gocd_p1r_hash("b"),
    gpcm_gocd_p1r_hash("c")
  )

  expect_identical(nrow(manifest), 8L)
  expect_identical(length(unique(manifest$DataScenarioId)), 2L)
  expect_identical(as.integer(table(manifest$DataScenarioId)), c(4L, 4L))
  expect_identical(sort(unique(manifest$SlopeOwner)), c("Criterion", "Rater"))
  expect_identical(sort(unique(manifest$Estimator)), c("JML", "MML"))
  expect_true(all(manifest$SlopeOwner == manifest$StepOwner))
  expect_identical(anyDuplicated(manifest$RouteId), 0L)
  expect_identical(length(unique(manifest$ManifestSHA256)), 1L)
})

test_that("P1r explicitly separates JML and current-default MML scales", {
  env <- gpcm_gocd_p1r_environment()
  manifest <- env$mfrmr_gocd_p1r_manifest(
    gpcm_gocd_p1r_hash("a"), gpcm_gocd_p1r_hash("b"),
    gpcm_gocd_p1r_hash("c")
  )
  mml <- manifest$Estimator == "MML"
  jml <- manifest$Estimator == "JML"

  expect_true(all(manifest$GpcmMmlIdentification[mml] == "free_population"))
  expect_true(all(manifest$AbilityScaleContract[mml] ==
                    "estimated_normal_population_intercept_only_free_scale"))
  expect_true(all(manifest$GpcmMmlIdentification[jml] == "not_applicable_jml"))
  expect_true(all(manifest$AbilityScaleContract[jml] ==
                    "fixed_person_coordinates"))
  expect_true(all(manifest$FitArgumentGpcmMmlIdentification ==
                    "free_population"))
  expect_true(all(manifest$DeclaredCategorySupport == "1:4"))
  expect_true(all(manifest$KeepOriginal))
})

test_that("P1r fails closed on pairing scale support and authority drift", {
  env <- gpcm_gocd_p1r_environment()
  make <- function() env$mfrmr_gocd_p1r_manifest(
    gpcm_gocd_p1r_hash("a"), gpcm_gocd_p1r_hash("b"),
    gpcm_gocd_p1r_hash("c")
  )
  pairing <- make()
  pairing$DataSeed[[1L]] <- pairing$DataSeed[[1L]] + 1L
  expect_error(
    env$mfrmr_gocd_p1r_validate_manifest(pairing), "source-dataset identity"
  )
  scale <- make()
  scale$GpcmMmlIdentification[scale$Estimator == "MML"][1L] <-
    "fixed_standard_normal"
  expect_error(
    env$mfrmr_gocd_p1r_validate_manifest(scale), "ability-scale identity"
  )
  support <- make()
  support$RatingMin[[1L]] <- 0L
  expect_error(
    env$mfrmr_gocd_p1r_validate_manifest(support), "support, pairing"
  )
  authority <- make()
  authority$ConfirmationAuthorized[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gocd_p1r_validate_manifest(authority),
    "cannot authorize inference, expansion, or confirmation"
  )
  content <- make()
  content$RouteId[[1L]] <- paste0(content$RouteId[[1L]], "-MUTATED")
  expect_error(
    env$mfrmr_gocd_p1r_validate_manifest(content),
    "manifest content hash mismatch"
  )
})

test_that("P1r requires identity on every prospective surface", {
  env <- gpcm_gocd_p1r_environment()
  surfaces <- env$mfrmr_gocd_p1r_surface_contract()
  fields <- env$mfrmr_gocd_p1r_identity_fields()

  expect_identical(nrow(surfaces), 13L)
  expect_true(all(vapply(
    strsplit(surfaces$RequiredIdentityFields, ";", fixed = TRUE),
    function(x) identical(x, fields), logical(1L)
  )))
  external <- surfaces$Surface == "external_normalizer_if_instantiated"
  expect_identical(sum(external), 1L)
  expect_identical(
    surfaces$Admission[external],
    "conditional_required_before_external_claim"
  )
  expect_true(all(surfaces$MissingFieldPolicy ==
                    "fail_closed_no_evidence_admission"))
  aggregate <- grepl("summary|execution_", surfaces$Surface)
  expect_true(all(surfaces$Binding[aggregate] ==
                    "eight_route_identity_registry_expansion"))
})

test_that("P1r admits only a bounded unexecuted smoke", {
  env <- gpcm_gocd_p1r_environment()
  result <- env$mfrmr_run_gpcm_owner_current_default_contract_p1r(
    gpcm_gocd_p1r_hash("a"), gpcm_gocd_p1r_hash("b"),
    gpcm_gocd_p1r_hash("c")
  )

  expect_s3_class(result, "mfrmr_gpcm_owner_current_default_contract_p1r")
  expect_true(result$ContractComplete)
  expect_true(result$BoundedSmokeAdmissibleAfterRuntimeBinding)
  expect_false(result$SmokeExecuted)
  expect_false(result$CurrentDefaultOwnerEvidenceComplete)
  expect_false(result$RecoveryClaimAuthorized)
  expect_false(result$OwnerSuperiorityClaimAuthorized)
  expect_false(result$ExternalComparisonAuthorized)
  expect_false(result$AdditionalReplicationAuthorized)
  expect_false(result$BroadSimulationAuthorized)
  expect_false(result$SelectionAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1r record preserves the prospective boundary", {
  text <- paste(
    readLines(gpcm_gocd_p1r_paths()[["record"]], warn = FALSE),
    collapse = "\n"
  )
  expect_match(text, "PlannedRoutes = 8", fixed = TRUE)
  expect_match(text, "ContractComplete = TRUE", fixed = TRUE)
  expect_match(text, "SmokeExecuted = FALSE", fixed = TRUE)
  expect_match(
    text, "CurrentDefaultOwnerEvidenceComplete = FALSE", fixed = TRUE
  )
  expect_match(text, "AdditionalReplicationAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "BroadSimulationAuthorized = FALSE", fixed = TRUE)
  expect_match(text, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
