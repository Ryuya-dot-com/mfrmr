test_that("claim disposition is one hash-bound fail-closed scope surface", {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  protocol <- file.path(root, "inst", "validation", "release-readiness.R")
  skip_if_not(file.exists(protocol),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(protocol, envir = env)
  paths <- env$mfrmr_release_readiness_paths(
    root, target_version = "0.2.3"
  )

  status <- env$mfrmr_release_readiness_claim_disposition_status(
    paths, target_version = "0.2.3"
  )

  expect_identical(status$ClaimDispositionStatus, "ok")
  expect_true(status$ProfileIntegrityOK)
  expect_true(status$HashBindingOK)
  expect_true(status$ProfileContractOK)
  expect_true(status$RowMappingOK)
  expect_true(status$ItemIdentityOK)
  expect_true(status$ClassCountsOK)
  expect_true(status$ClassContractsOK)
  expect_true(status$ConditionalFallbackSetOK)
  expect_identical(status$ChecklistRows, 106L)
  expect_identical(status$ProfileRows, 106L)
  expect_identical(status$ReleaseSpineRows, 53L)
  expect_identical(status$ReleaseSpineClosedRows, 4L)
  expect_identical(status$ReleaseSpineOpenRows, 49L)
  expect_identical(status$ReleaseSpineConcernRows, 0L)
  expect_identical(status$ConditionalRows, 32L)
  expect_identical(status$ConditionalClosedRows, 1L)
  expect_identical(status$ConditionalFallbackRows, 31L)
  expect_identical(status$DeferredRows, 21L)
  expect_identical(status$DeferredConcernRows, 9L)
  expect_identical(
    status$ReleaseScopeDecision,
    "release_no_go_49_spine_rows_open"
  )
})

test_that("claim disposition rejects reorder and fallback mutation", {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  protocol <- file.path(root, "inst", "validation", "release-readiness.R")
  skip_if_not(file.exists(protocol),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(protocol, envir = env)
  checklist <- utils::read.csv(
    file.path(root, "inst", "validation",
              "release-evidence-checklist-0.2.3.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  profile <- utils::read.csv(
    file.path(root, "inst", "validation",
              "claim-disposition-profile-0.2.3.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )

  reordered <- profile[c(2L, 1L, 3:nrow(profile)), , drop = FALSE]
  reorder_status <-
    env$mfrmr_release_readiness_claim_disposition_contract(
      checklist, reordered
    )
  expect_false(reorder_status$ProfileContractOK)
  expect_false(reorder_status$RowMappingOK)
  expect_false(reorder_status$ItemIdentityOK)
  expect_identical(
    reorder_status$ReleaseScopeDecision,
    "invalid_profile_no_decision"
  )

  bad_fallback <- profile
  row <- which(bad_fallback$PortfolioClass == "claim_conditional")[1L]
  bad_fallback$FallbackCode[row] <- "none_release_blocked"
  fallback_status <-
    env$mfrmr_release_readiness_claim_disposition_contract(
      checklist, bad_fallback
    )
  expect_false(fallback_status$ProfileContractOK)
  expect_false(fallback_status$ConditionalFallbackSetOK)
})

test_that("claim disposition rejects a profile whose bound hash changed", {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  protocol <- file.path(root, "inst", "validation", "release-readiness.R")
  skip_if_not(file.exists(protocol),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(protocol, envir = env)
  paths <- env$mfrmr_release_readiness_paths(
    root, target_version = "0.2.3"
  )
  changed <- utils::read.csv(
    paths$claim_disposition_profile,
    stringsAsFactors = FALSE, check.names = FALSE
  )
  changed$ClaimGroup[1L] <- "mutated_candidate_identity"
  changed_dir <- tempfile("mfrmr-claim-profile-")
  dir.create(changed_dir)
  changed_path <- file.path(
    changed_dir, basename(paths$claim_disposition_profile)
  )
  utils::write.csv(changed, changed_path, row.names = FALSE)
  paths$claim_disposition_profile <- changed_path

  status <- env$mfrmr_release_readiness_claim_disposition_status(
    paths, target_version = "0.2.3"
  )

  expect_identical(status$ClaimDispositionStatus, "concern")
  expect_false(status$ProfileIntegrityOK)
  expect_false(status$HashBindingOK)
})
