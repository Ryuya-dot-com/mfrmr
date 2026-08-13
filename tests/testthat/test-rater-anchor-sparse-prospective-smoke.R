rater_anchor_sparse_smoke_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    canonical = file.path(
      validation, "rater-anchor-sparse-canonical-hash-0.2.3.R"
    ),
    prospective = file.path(
      validation, "rater-anchor-sparse-prospective-contract-0.2.3.R"
    ),
    helpers = file.path(
      validation, "rater-anchor-sparse-stress-pilot-0.2.3.R"
    ),
    runner = file.path(
      validation, "rater-anchor-sparse-prospective-smoke-0.2.3.R"
    ),
    record = file.path(
      validation, "rater-anchor-sparse-prospective-smoke-record-0.2.3.md"
    )
  )
}

rater_anchor_sparse_smoke_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- rater_anchor_sparse_smoke_paths()
    if (!file.exists(paths[["canonical"]])) {
      stop("Required repository canonical-hash helper is missing.", call. = FALSE)
    }
    testthat::skip_if_not(all(file.exists(paths[c(
      "prospective", "helpers", "runner"
    )])))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[c("canonical", "prospective", "helpers", "runner")]) {
      sys.source(path, envir = value)
    }
    value
  }
})

rater_anchor_sparse_smoke_result <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    env <- rater_anchor_sparse_smoke_environment()
    value <<- env$mfrmr_run_rater_anchor_sparse_prospective_smoke(
      execute = TRUE, progress = FALSE
    )
    value
  }
})

test_that("prospective smoke defaults to dry-run and refuses feasibility", {
  env <- rater_anchor_sparse_smoke_environment()
  dry <- env$mfrmr_run_rater_anchor_sparse_prospective_smoke()
  expect_identical(
    dry$IdentityFormat, "mfrmr_rater_anchor_canonical_tables_v1"
  )

  expect_identical(nrow(dry$manifest), 12L)
  expect_identical(nrow(dry$results), 0L)
  expect_false(dry$SmokeExecuted)
  expect_true(is.na(dry$SmokeExecutionContractPassed))
  expect_true(is.na(dry$SmokeScientificReadinessObserved))
  expect_false(dry$FeasibilityHandoffAuthorized)
  expect_false(dry$FeasibilityExecutionAuthorized)
  expect_false(dry$AppropriateAnchorRateSelected)
  expect_false(dry$BroadSimulationAuthorized)
  expect_false(dry$ConfirmationAuthorized)
  expect_identical(nchar(dry$RegistrySHA256), 64L)
  expect_identical(nchar(dry$ManifestSHA256), 64L)

  expect_error(
    env$mfrmr_run_rater_anchor_sparse_prospective_smoke(
      profile = "feasibility"
    ),
    "refuses feasibility"
  )
})

test_that("range-spanning Rater sets are prospectively nested", {
  env <- rater_anchor_sparse_smoke_environment()
  registry <- env$mfrmr_rasp_registry()
  manifest <- env$mfrmr_rasp_execution_manifest(registry, "feasibility")
  truth <- list(facets = list(Rater = stats::setNames(
    seq(-1.5, 1.5, length.out = 16L), sprintf("R%02d", seq_len(16L))
  )))
  take <- function(config) {
    row <- manifest[
      manifest$Replicate == 1L & manifest$DesignId == "complete" &
        manifest$AnchorConfig == config,
      , drop = FALSE
    ]
    env$mfrmr_rasps_build_anchors(truth, row[1L, ])
  }
  low <- take("exact_12_5_span")
  candidate <- take("exact_25_span")
  high <- take("exact_50_span")

  expect_identical(nrow(low$anchors), 2L)
  expect_identical(nrow(candidate$anchors), 4L)
  expect_identical(nrow(high$anchors), 8L)
  expect_true(all(low$anchors$Level %in% candidate$anchors$Level))
  expect_true(all(candidate$anchors$Level %in% high$anchors$Level))
  expect_identical(low$CalibrationSHA256, candidate$CalibrationSHA256)
  expect_identical(candidate$CalibrationSHA256, high$CalibrationSHA256)
  expect_false(identical(low$SelectionSHA256, candidate$SelectionSHA256))
})

test_that("external anchor error is deterministic and design invariant", {
  env <- rater_anchor_sparse_smoke_environment()
  registry <- env$mfrmr_rasp_registry()
  manifest <- env$mfrmr_rasp_execution_manifest(registry, "smoke")
  truth <- list(facets = list(Rater = stats::setNames(
    seq(-1.5, 1.5, length.out = 16L), sprintf("R%02d", seq_len(16L))
  )))
  rows <- manifest[manifest$AnchorConfig == "normal_sd25_25_span",
                   , drop = FALSE]
  built <- lapply(seq_len(nrow(rows)), function(i) {
    env$mfrmr_rasps_build_anchors(truth, rows[i, ])
  })

  expect_true(all(vapply(
    built, function(x) identical(x$AnchorSHA256, built[[1L]]$AnchorSHA256),
    logical(1)
  )))
  expect_true(all(vapply(
    built,
    function(x) identical(x$SelectionSHA256, built[[1L]]$SelectionSHA256),
    logical(1)
  )))
  expect_true(any(abs(built[[1L]]$anchors$AnchorError) > 0))
  expect_gt(built[[1L]]$AnchorErrorRMSE, 0)
  expect_true(is.finite(built[[1L]]$SelectionEstimateRMSE))
  expect_true(is.finite(built[[1L]]$SelectionRankSpearman))

  repeated <- env$mfrmr_rasps_build_anchors(truth, rows[1L, ])
  expect_identical(repeated$anchors, built[[1L]]$anchors)
  expect_identical(repeated$AnchorSHA256, built[[1L]]$AnchorSHA256)
})

test_that("failure classification prefers typed estimability errors", {
  env <- rater_anchor_sparse_smoke_environment()
  typed <- structure(
    list(message = "message wording is irrelevant"),
    class = c("mfrmr_estimability_error", "error", "condition")
  )
  legacy <- simpleError(paste(
    "The estimator-specific constrained design is structurally unidentified",
    "(legacy fixture)."
  ))
  unrelated <- simpleError("A remote service is not connected.")

  expect_true(env$mfrmr_rasps_failure_code(typed)$structural)
  expect_true(env$mfrmr_rasps_failure_code(legacy)$structural)
  expect_false(env$mfrmr_rasps_failure_code(unrelated)$structural)
  expect_identical(
    env$mfrmr_rasps_failure_code(unrelated)$stage,
    "fit"
  )
})

test_that("support-audit warnings survive an error result", {
  env <- rater_anchor_sparse_smoke_environment()
  had_local_review <- exists(
    "review_mfrm_anchors", envir = env, inherits = FALSE
  )
  if (had_local_review) original_review <- env$review_mfrm_anchors
  on.exit({
    if (had_local_review) {
      env$review_mfrm_anchors <- original_review
    } else {
      rm("review_mfrm_anchors", envir = env)
    }
  }, add = TRUE)
  env$review_mfrm_anchors <- function(...) {
    warning("support warning retained", call. = FALSE)
    stop("support audit failed", call. = FALSE)
  }
  registry <- env$mfrmr_rasp_registry()
  manifest <- env$mfrmr_rasp_execution_manifest(registry, "smoke")
  row <- manifest[manifest$AnchorCount == 0L, , drop = FALSE][1L, ]
  designed <- list(
    data = data.frame(), DataSHA256 = "data", LinkPersonSHA256 = "link",
    DesignDensity = 1, MinCommonPersons = 1L,
    MedianCommonPersons = 1, ZeroCommonRaterPairs = 0L
  )

  expect_no_warning(out <- env$mfrmr_rasps_run_one(
    row, generated = list(truth = list(), TruthSHA256 = "truth"), designed
  ))

  expect_identical(out$FailureStage, "support_audit")
  expect_identical(out$Warnings, "support warning retained")
  expect_identical(out$FailureCode, "support audit failed")
})

test_that("smoke execution preserves identities and resource accounting", {
  skip_on_cran()
  result <- rater_anchor_sparse_smoke_result()
  manifest <- result$manifest
  results <- result$results

  expect_identical(nrow(results), 12L)
  expect_identical(results$RunId, manifest$RunId)
  expect_true(all(results$Executed))
  expect_true(all(results$SupportAuditPassed))
  expect_true(all(is.finite(results$ConvergenceCode[results$FitReturned])))
  expect_true(all(is.finite(
    results$TerminalGradientSupNorm[results$FitReturned]
  )))
  expect_true(all(is.finite(results$ExtremeTotalN[results$FitReturned])))
  exact <- results$AnchorConfig == "exact_25_span"
  noisy <- results$AnchorConfig == "normal_sd25_25_span"
  shifted <- results$AnchorConfig == "shifted_plus25_25_span"
  expect_true(all(results$AnchorErrorRMSE[exact] == 0))
  expect_true(all(results$AnchorErrorRMSE[noisy] > 0))
  expect_true(all(results$AnchorErrorRMSE[shifted] == 0.25))
  expect_true(all(results$Rows == manifest$ExpectedResponseRows))
  expect_true(all(
    results$RealizedRatingAssignments == manifest$ExpectedRatingAssignments
  ))
  expect_true(all(abs(
    results$DesignDensity - manifest$ExpectedDensity
  ) < 1e-12))
  expect_true(all(table(results$DataSHA256) == 4L))
  expect_true(all(table(results$AnchorSHA256) == 3L))
  expect_identical(nchar(result$EvidenceSHA256), 64L)
  expect_identical(nchar(result$SummarySHA256), 64L)
  expect_identical(
    result$EvidenceSHA256,
    "172856a67442812f421511c014da2497f809eb04fe227327c7f11d57cf50cfb1"
  )
  expect_identical(
    result$SummarySHA256,
    "24fe3bdf216aa759e0ab673bd7c579d738765bb295ce9e32a31bf02abe9dc4a4"
  )
  expect_true(result$SmokeExecuted)
  expect_true(result$SmokeExecutionContractPassed)
  expect_false(result$SmokeScientificReadinessObserved)
  expect_false(result$FeasibilityHandoffAuthorized)
  expect_false(result$FeasibilityExecutionAuthorized)
  expect_false(result$AppropriateAnchorRateSelected)
  expect_false(result$BroadSimulationAuthorized)
  expect_false(result$ConfirmationAuthorized)
})

test_that("smoke record binds contracts, runner, tests, and evidence", {
  paths <- rater_anchor_sparse_smoke_paths()
  skip_if_not(file.exists(paths[["record"]]))
  env <- rater_anchor_sparse_smoke_environment()
  hashes <- vapply(
    paths[c("canonical", "prospective", "helpers", "runner")],
    env$mfrmr_rash_hash_text_file, character(1)
  )
  test_hash <- env$mfrmr_rash_hash_text_file(
    testthat::test_path("test-rater-anchor-sparse-prospective-smoke.R")
  )
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_true(all(vapply(hashes, grepl, logical(1), x = record, fixed = TRUE)))
  expect_match(record, test_hash, fixed = TRUE)
  expect_match(record, "12 declared PCM/JML smoke fits", fixed = TRUE)
  expect_match(record, "FeasibilityExecutionAuthorized = FALSE", fixed = TRUE)
  expect_match(record, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
  expect_match(record, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
