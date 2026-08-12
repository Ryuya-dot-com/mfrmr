gpcm_gocs_p1s_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    contract = file.path(
      validation, "gpcm-owner-current-default-contract-p1r-0.2.3.R"
    ),
    runner = file.path(
      validation, "gpcm-owner-current-default-smoke-p1s-0.2.3.R"
    ),
    record = file.path(
      validation, "gpcm-owner-current-default-smoke-p1s-record-0.2.3.md"
    )
  )
}

gpcm_gocs_p1s_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- gpcm_gocs_p1s_paths()
    testthat::skip_if_not(all(file.exists(paths[c("contract", "runner")])))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    sys.source(paths[["runner"]], envir = value)
    value
  }
})

test_that("P1s dry run binds the current runtime to exactly eight routes", {
  testthat::skip_if_not(as.character(packageVersion("mfrmr")) == "0.2.3")
  env <- gpcm_gocs_p1s_environment()
  paths <- gpcm_gocs_p1s_paths()
  expect_identical(
    digest::digest(
      paths[["contract"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    env$mfrmr_gocs_p1s_dependency_sha256
  )
  expect_identical(
    digest::digest(
      paths[["runner"]], algo = "sha256", file = TRUE, serialize = FALSE
    ),
    "fed9b5ac53f6ad9c0d873006fe3340dc29c00e5484dcc0e36487f0c9b2335a7a"
  )
  result <- env$mfrmr_run_gpcm_owner_current_default_smoke_p1s(execute = FALSE)

  expect_s3_class(result, "mfrmr_gpcm_owner_current_default_smoke_p1s")
  expect_identical(nrow(result$manifest), 8L)
  expect_identical(result$execution_identity$PlannedDatasets, 2L)
  expect_identical(result$execution_identity$PlannedRoutes, 8L)
  expect_identical(
    unique(result$manifest$RuntimeIdentity),
    result$execution_identity$RuntimeIdentity
  )
  expect_false(result$SmokeExecuted)
  expect_false(result$CurrentDefaultOwnerEvidenceComplete)
  expect_false(result$AdditionalReplicationAuthorized)
  expect_false(result$BroadSimulationAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("P1s generated data are exactly paired within source owner", {
  testthat::skip_if_not(as.character(packageVersion("mfrmr")) == "0.2.3")
  env <- gpcm_gocs_p1s_environment()
  context <- env$mfrmr_gocs_p1s_context()
  built <- env$mfrmr_gocs_p1s_build_datasets(context$manifest)

  expect_identical(length(built$datasets), 2L)
  expect_identical(nrow(built$ledger), 8L)
  hashes <- split(built$ledger$DataSHA256, built$ledger$DataScenarioId)
  expect_true(all(vapply(hashes, function(x) length(unique(x)) == 1L,
                         logical(1L))))
  expect_identical(length(unique(built$ledger$DataSHA256)), 2L)
  expect_true(all(built$ledger$Rows > 0L))
  expect_true(all(built$ledger$CategoryCounts != ""))
})

test_that("P1s checkpoint rejects manifest and result mutation", {
  testthat::skip_if_not(as.character(packageVersion("mfrmr")) == "0.2.3")
  env <- gpcm_gocs_p1s_environment()
  context <- env$mfrmr_gocs_p1s_context()
  row <- context$manifest[1L, , drop = FALSE]
  result <- env$mfrmr_gocs_p1s_empty_result(row, paste(rep("d", 64L),
                                                       collapse = ""))
  checkpoint <- env$mfrmr_gocs_p1s_checkpoint(
    row, result, context$execution_identity$ExecutionSHA256
  )
  expect_invisible(env$mfrmr_gocs_p1s_validate_checkpoint(
    checkpoint, row, context$execution_identity$ExecutionSHA256
  ))

  changed <- checkpoint
  changed$result$SlopeOwner <- "Rater"
  expect_error(
    env$mfrmr_gocs_p1s_validate_checkpoint(
      changed, row, context$execution_identity$ExecutionSHA256
    ),
    "checkpoint identity validation failed"
  )
  changed <- checkpoint
  changed$execution_sha256 <- paste(rep("e", 64L), collapse = "")
  expect_error(
    env$mfrmr_gocs_p1s_validate_checkpoint(
      changed, row, context$execution_identity$ExecutionSHA256
    ),
    "checkpoint identity validation failed"
  )
})

test_that("P1s synthetic aggregates retain all required surface identity", {
  testthat::skip_if_not(as.character(packageVersion("mfrmr")) == "0.2.3")
  env <- gpcm_gocs_p1s_environment()
  context <- env$mfrmr_gocs_p1s_context()
  manifest <- context$manifest
  results <- do.call(rbind, lapply(seq_len(nrow(manifest)), function(i) {
    out <- env$mfrmr_gocs_p1s_empty_result(
      manifest[i, , drop = FALSE], paste(rep("d", 64L), collapse = "")
    )
    out$Executed <- TRUE
    out$FitSucceeded <- TRUE
    out$ConfigIdentityMatch <- TRUE
    out$PublicManifestIdentityMatch <- TRUE
    out$ReplayIdentityMatch <- TRUE
    out$PublicSummaryIdentityMatch <- TRUE
    out
  }))
  checkpoints <- lapply(seq_len(nrow(manifest)), function(i) {
    env$mfrmr_gocs_p1s_checkpoint(
      manifest[i, , drop = FALSE], results[i, , drop = FALSE],
      context$execution_identity$ExecutionSHA256
    )
  })
  data_ledger <- cbind(
    manifest[, env$mfrmr_gocd_p1r_identity_fields(), drop = FALSE],
    data.frame(
      RouteId = manifest$RouteId,
      DataScenarioId = manifest$DataScenarioId,
      DataSHA256 = paste(rep("d", 64L), collapse = ""),
      stringsAsFactors = FALSE
    )
  )
  replays <- rep("synthetic replay", 8L)
  aggregates <- env$mfrmr_gocs_p1s_aggregate(
    manifest, results, data_ledger, context$execution_identity,
    checkpoints, replays
  )
  audit <- env$mfrmr_gocs_p1s_surface_audit(
    manifest, aggregates, checkpoints
  )

  required <- audit$RequiredForSmoke
  expect_identical(sum(required), 12L)
  expect_true(all(audit$State[required] == "complete"))
  expect_true(all(audit$FullIdentityRetained[required]))
  external <- audit$Surface == "external_normalizer_if_instantiated"
  expect_identical(
    audit$State[external],
    "conditional_not_instantiated_no_external_claim"
  )
  expect_true(is.na(audit$FullIdentityRetained[external]))
})

test_that("P1s atomic save refuses replacement", {
  env <- gpcm_gocs_p1s_environment()
  expect_identical(
    env$mfrmr_gocs_p1s_expected_identification("JML"),
    "not_applicable_jml"
  )
  expect_identical(
    env$mfrmr_gocs_p1s_expected_identification("MML"),
    "free_population"
  )
  expect_true(is.na(env$mfrmr_gocs_p1s_numeric_scalar(NULL)))
  expect_true(is.na(env$mfrmr_gocs_p1s_numeric_scalar(numeric(0))))
  expect_identical(env$mfrmr_gocs_p1s_numeric_scalar(c(2, 3)), 2)
  path <- tempfile("p1s-atomic-", fileext = ".rds")
  on.exit(unlink(path, force = TRUE), add = TRUE)
  expect_invisible(env$mfrmr_gocs_p1s_atomic_save(list(value = 1L), path))
  expect_identical(readRDS(path), list(value = 1L))
  expect_error(
    env$mfrmr_gocs_p1s_atomic_save(list(value = 2L), path),
    "refuses to replace"
  )
})

test_that("P1s stored eight-route execution remains separately opt in", {
  testthat::skip_if(
    !identical(Sys.getenv("MFRMR_RUN_P1S_SMOKE"), "true"),
    "set MFRMR_RUN_P1S_SMOKE=true and MFRMR_P1S_RESULT"
  )
  path <- Sys.getenv("MFRMR_P1S_RESULT")
  testthat::skip_if_not(file.exists(path))
  result <- readRDS(path)
  expect_s3_class(result, "mfrmr_gpcm_owner_current_default_smoke_p1s")
  expect_identical(result$ExecutedRoutes, 8L)
  expect_true(result$RequiredSmokeSurfacesComplete)
  expect_true(result$AllRouteIdentityChecksPass)
  expect_false(result$RecoveryClaimAuthorized)
  expect_false(result$OwnerSuperiorityClaimAuthorized)
  expect_false(result$AdditionalReplicationAuthorized)
  expect_false(result$BroadSimulationAuthorized)
  expect_false(result$ConfirmationAuthorized)
})
