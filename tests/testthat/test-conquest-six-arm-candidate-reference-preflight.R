load_conquest_candidate_reference_preflight <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R",
    "conquest-six-arm-candidate-reference-preflight-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only candidate reference preflight is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("the six-arm numerical-reference identity is frozen", {
  env <- load_conquest_candidate_reference_preflight()$env
  registry <- env$mfrmr_cq_crp_reference_registry()
  sources <- env$mfrmr_cq_crp_source_registry()
  bundles <- env$mfrmr_cq_crp_bundle_hashes()

  expect_identical(nrow(registry), 16L)
  expect_identical(
    unname(as.integer(table(registry$Family))), c(8L, 4L, 4L)
  )
  expect_identical(length(unique(registry$ArmId)), 6L)
  expect_false(anyDuplicated(paste(registry$ArmId, registry$ArtifactKind)) > 0L)
  expect_true(all(grepl("^[[:xdigit:]]{64}$", registry$SHA256)))
  expect_identical(nrow(sources), 3L)
  expect_true(all(grepl("^[[:xdigit:]]{64}$", sources$SHA256)))
  expect_true(all(
    sources$SourceCommit == "8ee7958f7af08141df156b333fe1fc732e2b2bc6"
  ))
  expect_identical(
    bundles$Bundle, c("reference_artifact", "reference_source")
  )
  expect_identical(bundles$SHA256, bundles$ExpectedSHA256)
  expect_identical(
    bundles$SHA256,
    c(
      "0d23be47efce2965c8f4fa76c93d6aa569bc5aa313bce6550286ac2d9f7942a8",
      "c0dfb7cf32a27e652bfed6ae644a7fe2aa606970f04a8d4a43d0ba1a71b11e2c"
    )
  )
})

test_that("candidate numerical references pass locally but remain noninferential", {
  ctx <- load_conquest_candidate_reference_preflight()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_cb_candidate_root
  )

  if (dir.exists(candidate_root)) {
    review <- ctx$env$mfrmr_cq_crp_review(candidate_root, ctx$root)
    expect_identical(
      review$status,
      "six_arm_numerical_reference_ready_execution_handoff_pending"
    )
    expect_true(review$numerical_reference_ready)
    expect_identical(nrow(review$arm_summary), 6L)
    expect_true(all(review$arm_summary$NumericalReferenceReady))
    expect_identical(review$arm_summary$OracleChecked,
                     c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE))
    expect_identical(
      review$arm_summary$AllPatternLocalRankRetained,
      c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE)
    )
    expect_true(all(review$integration$CoordinatePass))
    expect_true(all(review$integration$DeviancePass))
    expect_lt(max(review$integration$CoordinateMaxAbsDifference), 2e-6)
    expect_lt(max(review$integration$DevianceAbsDifference), 2e-6)
    expect_false(review$inference_ready)
    expect_false(review$numerical_reference_promotes_inference)
    expect_false(review$candidate_execution_authorized)
    expect_identical(
      review$execution_hold_reason,
      "candidate_execution_handoff_not_frozen"
    )
    expect_false(review$scientific_equivalence_inferred)
    expect_false(review$confirmation_authorized)
    expect_false(review$sparse_extension_authorized)
    expect_false(review$large_simulation_authorized)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("missing reference bundle and hash drift fail closed", {
  ctx <- load_conquest_candidate_reference_preflight()
  expect_error(
    ctx$env$mfrmr_cq_crp_review(tempfile("missing-reference-"), ctx$root),
    "No such file or directory|cannot find|mustWork"
  )

  original <- ctx$env$mfrmr_cq_crp_reference_bundle_sha256
  ctx$env$mfrmr_cq_crp_reference_bundle_sha256 <- paste(rep("0", 64L),
                                                        collapse = "")
  drift <- ctx$env$mfrmr_cq_crp_bundle_hashes()
  expect_false(identical(drift$SHA256, drift$ExpectedSHA256))
  ctx$env$mfrmr_cq_crp_reference_bundle_sha256 <- original
  expect_identical(
    ctx$env$mfrmr_cq_crp_bundle_hashes()$SHA256,
    ctx$env$mfrmr_cq_crp_bundle_hashes()$ExpectedSHA256
  )
})

test_that("the candidate-reference record is source-bound", {
  ctx <- load_conquest_candidate_reference_preflight()
  record_path <- file.path(
    ctx$validation,
    "conquest-six-arm-candidate-reference-preflight-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  artifacts <- c(
    file.path(
      ctx$validation,
      c(
        "conquest-six-arm-candidate-reference-preflight-0.2.3.R",
        "conquest-six-arm-candidate-binding-0.2.3.R"
      )
    ),
    file.path(
      ctx$root, "tests", "testthat",
      "test-conquest-six-arm-candidate-reference-preflight.R"
    )
  )
  hashes <- vapply(
    artifacts, digest::digest, character(1L),
    algo = "sha256", file = TRUE, serialize = FALSE
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1L), x = record, fixed = TRUE
  )))
  identities <- c(
    ctx$env$mfrmr_cq_crp_candidate_id,
    ctx$env$mfrmr_cq_crp_reference_bundle_sha256,
    ctx$env$mfrmr_cq_crp_source_bundle_sha256,
    "candidate_execution_handoff_not_frozen"
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*FALSE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
