rater_anchor_sparse_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  c(
    canonical = file.path(
      validation, "rater-anchor-sparse-canonical-hash-0.2.3.R"
    ),
    runner = file.path(
      validation, "rater-anchor-sparse-stress-pilot-0.2.3.R"
    ),
    record = file.path(
      validation, "rater-anchor-sparse-stress-pilot-record-0.2.3.md"
    )
  )
}

rater_anchor_sparse_environment <- local({
  value <- NULL
  function() {
    if (!is.null(value)) return(value)
    paths <- rater_anchor_sparse_paths()
    if (!file.exists(paths[["canonical"]])) {
      stop("Required repository canonical-hash helper is missing.", call. = FALSE)
    }
    testthat::skip_if_not(file.exists(paths[["runner"]]))
    testthat::skip_if_not_installed("digest")
    value <<- new.env(parent = globalenv())
    for (path in paths[c("canonical", "runner")]) {
      sys.source(path, envir = value)
    }
    value
  }
})

test_that("Rater-anchor stress manifest separates anchors from links", {
  env <- rater_anchor_sparse_environment()
  designs <- env$mfrmr_rass_design_registry()
  anchors <- env$mfrmr_rass_anchor_registry()
  smoke <- env$mfrmr_rass_manifest("smoke")
  pilot <- env$mfrmr_rass_manifest("pilot")

  expect_identical(nrow(designs), 7L)
  expect_identical(nrow(anchors), 7L)
  expect_identical(nrow(smoke), 9L)
  expect_identical(nrow(pilot), 147L)
  expect_identical(anyDuplicated(pilot$ScenarioId), 0L)
  expect_equal(sort(unique(anchors$AnchorRate)), c(0, 0.125, 0.25, 0.5, 0.75))
  expect_equal(sort(unique(designs$LinkPersons)), c(0L, 2L, 10L, 80L))
  expect_true(all(pilot$Model == "PCM"))
  expect_true(all(pilot$Estimator == "JML"))
  expect_true(all(!pilot$AppropriateAnchorRateSelected))
  expect_true(all(!pilot$ConfirmationAuthorized))

  dry <- env$mfrmr_run_rater_anchor_sparse_stress(
    "pilot", execute = FALSE
  )
  expect_identical(
    dry$IdentityFormat, "mfrmr_rater_anchor_canonical_tables_v1"
  )
  expect_identical(nrow(dry$manifest), 147L)
  expect_identical(nrow(dry$results), 0L)
  expect_false(dry$AppropriateAnchorRateSelected)
})

test_that("stress dry-run fails clearly without canonical identities", {
  path <- rater_anchor_sparse_paths()[["runner"]]
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  expect_error(
    env$mfrmr_run_rater_anchor_sparse_stress("pilot", execute = FALSE),
    "canonical-hash helper"
  )
})

test_that("sparse designs preserve truth and realize declared support", {
  env <- rater_anchor_sparse_environment()
  generated <- env$mfrmr_rass_generate_complete(615001L)
  designs <- env$mfrmr_rass_design_registry()
  built <- lapply(seq_len(nrow(designs)), function(i) {
    env$mfrmr_rass_apply_design(generated, designs[i, , drop = FALSE])
  })

  expect_equal(
    vapply(built, `[[`, numeric(1), "DesignDensity"),
    designs$ExpectedDensity,
    tolerance = 1e-12
  )
  expect_identical(
    vapply(built, `[[`, integer(1), "MinCommonPersons"),
    designs$ExpectedMinCommonPersons
  )
  expect_identical(built[[2L]]$ZeroCommonRaterPairs, 28L)
  expect_identical(built[[6L]]$ZeroCommonRaterPairs, 20L)
  expect_true(all(vapply(built, function(x) nchar(x$DataSHA256) == 64L,
                         logical(1))))
  expect_identical(nchar(generated$TruthSHA256), 64L)
})

test_that("anchor configurations distinguish count representation and error", {
  env <- rater_anchor_sparse_environment()
  generated <- env$mfrmr_rass_generate_complete(615001L)
  registry <- env$mfrmr_rass_anchor_registry()
  tables <- lapply(seq_len(nrow(registry)), function(i) {
    env$mfrmr_rass_build_anchors(generated$truth, registry[i, , drop = FALSE])
  })

  expect_identical(vapply(tables, nrow, integer(1)), registry$AnchorCount)
  exact <- registry$AnchorQuality == "exact_generating_value"
  expect_true(all(vapply(tables[exact], function(x) {
    all(abs(x$Anchor - x$GeneratingTruth) < 1e-12)
  }, logical(1))))
  shifted <- tables[[which(registry$AnchorConfig == "shifted_25_span")]]
  expect_true(all(abs(shifted$AnchorError - 0.25) < 1e-12))

  span <- tables[[which(registry$AnchorConfig == "exact_25_span")]]$Level
  central <- tables[[which(
    registry$AnchorConfig == "exact_25_central"
  )]]$Level
  expect_false(setequal(span, central))
})

test_that("anchor-review warnings survive an error result", {
  env <- rater_anchor_sparse_environment()
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
    warning("review warning retained", call. = FALSE)
    stop("review failed", call. = FALSE)
  }
  row <- list(
    ScenarioId = "warning-fixture", Seed = 1L, DesignId = "complete",
    LinkPersons = 0L, LinkSelection = "none",
    AnchorConfig = "none", AnchorRate = 0, AnchorCount = 0L,
    AnchorQuality = "none"
  )

  expect_no_warning(out <- env$mfrmr_rass_run_one(
    row,
    generated = list(truth = list(), TruthSHA256 = "truth"),
    designed = list(data = data.frame(), DataSHA256 = "data")
  ))

  expect_identical(out$RunState, "anchor_review_failed")
  expect_identical(out$Warnings, "review warning retained")
  expect_identical(out$Error, "review failed")
})

test_that("result validation preserves pairing and rejects recommendations", {
  env <- rater_anchor_sparse_environment()
  manifest <- env$mfrmr_rass_manifest("smoke")
  results <- do.call(rbind, lapply(seq_len(nrow(manifest)), function(i) {
    row <- env$mfrmr_rass_empty_result(
      as.list(manifest[i, , drop = FALSE]), "fixture"
    )
    row$Rows <- if (row$DesignId == "complete") 2560L else 376L
    row$TruthSHA256 <- paste(rep(as.character(manifest$Seed[[i]] %% 10), 64L),
                            collapse = "")
    data_digit <- if (row$DesignId == "complete") "a" else "b"
    row$DataSHA256 <- paste(rep(data_digit, 64L), collapse = "")
    row$AnchorSHA256 <- paste(rep(as.character(i %% 10), 64L), collapse = "")
    row$DesignDensity <- manifest$ExpectedDensity[[i]]
    row$MinCommonPersons <- manifest$ExpectedMinCommonPersons[[i]]
    row
  }))
  expect_no_error(env$mfrmr_rass_validate_results(results, manifest))

  promoted <- results
  promoted$AppropriateAnchorRateSelected[[1L]] <- TRUE
  expect_error(
    env$mfrmr_rass_validate_results(promoted, manifest),
    "cannot select an anchor rate"
  )
  unpaired <- results
  unpaired$DataSHA256[[2L]] <- paste(rep("f", 64L), collapse = "")
  expect_error(
    env$mfrmr_rass_validate_results(unpaired, manifest),
    "common truth or response data"
  )
})

test_that("Rater-anchor sparse smoke fits exact and shifted controls", {
  skip_on_cran()
  env <- rater_anchor_sparse_environment()
  result <- env$mfrmr_run_rater_anchor_sparse_stress(
    "smoke", progress = FALSE
  )

  expect_identical(nrow(result$results), 9L)
  expect_true(all(result$results$FitReturned))
  expect_true(all(result$results$RaterN == 8L))
  expect_true(all(result$results$DataSHA256[
    result$results$DesignId == "complete"
  ] == result$results$DataSHA256[
    result$results$DesignId == "complete"
  ][[1L]]))
  expect_identical(nchar(result$EvidenceSHA256), 64L)
  expect_identical(nchar(result$SummarySHA256), 64L)
  expect_false(result$AppropriateAnchorRateSelected)
  expect_false(result$ConfirmationAuthorized)
})

test_that("Rater-anchor stress record binds runner and tests", {
  paths <- rater_anchor_sparse_paths()
  skip_if_not(all(file.exists(paths)))
  env <- rater_anchor_sparse_environment()
  runner_hash <- env$mfrmr_rash_hash_text_file(paths[["runner"]])
  canonical_hash <- env$mfrmr_rash_hash_text_file(paths[["canonical"]])
  test_hash <- env$mfrmr_rash_hash_text_file(
    testthat::test_path("test-rater-anchor-sparse-stress-pilot.R")
  )
  record <- paste(
    readLines(paths[["record"]], warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  expect_match(record, runner_hash, fixed = TRUE)
  expect_match(record, canonical_hash, fixed = TRUE)
  expect_match(record, test_hash, fixed = TRUE)
  expect_match(
    record,
    "f22161a9d6098b3b454612022af12953b8deb0639588c74a6d3ad4795a75fa1e",
    fixed = TRUE
  )
  expect_match(
    record,
    "949b87276944e8df83c7cd955432c7e51b3bc93137987383e5c9996e0043265c",
    fixed = TRUE
  )
  expect_match(record, "147 declared PCM/JML fits", fixed = TRUE)
  expect_match(record, "AppropriateAnchorRateSelected = FALSE", fixed = TRUE)
  expect_match(record, "ConfirmationAuthorized = FALSE", fixed = TRUE)
})
