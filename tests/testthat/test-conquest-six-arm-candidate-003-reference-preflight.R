load_conquest_candidate_003_reference_preflight <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-prospective-tolerance-contract-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-six-arm-candidate-binding-0.2.3.R",
    "conquest-six-arm-candidate-reference-preflight-0.2.3.R",
    "conquest-six-arm-candidate-003-binding-0.2.3.R",
    "conquest-six-arm-candidate-003-reference-preflight-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only candidate-003 reference preflight is excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

test_that("candidate-003 reference and provenance identities are frozen", {
  env <- load_conquest_candidate_003_reference_preflight()$env
  registry <- env$mfrmr_cq_c3rp_reference_registry()
  sources <- env$mfrmr_cq_c3rp_source_registry()
  provenance <- env$mfrmr_cq_c3rp_provenance_registry()
  bundles <- env$mfrmr_cq_c3rp_bundle_hashes()

  expect_identical(nrow(registry), 16L)
  expect_identical(length(unique(registry$ArmId)), 6L)
  expect_identical(nrow(sources), 3L)
  expect_true(all(
    sources$SourceCommit == "4f86fa187e010d3c9faff647c88abc38ddcf5b0f"
  ))
  expect_identical(
    provenance$Artifact,
    c(
      "additive_source_manifest", "additive_reference_manifest",
      "additive_q_sensitivity"
    )
  )
  expect_true(all(grepl("^[[:xdigit:]]{64}$", c(
    registry$SHA256, sources$SHA256, provenance$SHA256
  ))))
  expect_identical(
    bundles$Bundle,
    c("reference_artifact", "reference_source", "reference_provenance")
  )
  expect_identical(bundles$SHA256, bundles$ExpectedSHA256)
  expect_identical(
    bundles$SHA256,
    c(
      "0d23be47efce2965c8f4fa76c93d6aa569bc5aa313bce6550286ac2d9f7942a8",
      "cd37c3b75517c7af6afb4834fd6ec26d3e6b254a0a966c9b425d15d74ad986c2",
      "556c87bcfa8b70e46e4f89389edbe99a31e9dcd8cc7577e2e8e22bcbbb10d7c1"
    )
  )
})

test_that("candidate-003 references are audited without reopening execution", {
  ctx <- load_conquest_candidate_003_reference_preflight()
  candidate_root <- file.path(
    ctx$root, ctx$env$mfrmr_cq_c3_candidate_root
  )

  if (dir.exists(candidate_root)) {
    review <- ctx$env$mfrmr_cq_c3rp_review(candidate_root, ctx$root)
    expect_identical(nrow(review$arm_summary), 6L)
    expect_true(all(review$arm_summary$NumericalReferenceReady))
    expect_identical(
      review$arm_summary$OracleChecked,
      c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE)
    )
    expect_identical(
      review$arm_summary$AllPatternLocalRankRetained,
      c(FALSE, FALSE, TRUE, TRUE, TRUE, TRUE)
    )
    expect_true(all(review$integration$CoordinatePass))
    expect_true(all(review$integration$DeviancePass))
    expect_lt(max(review$integration$CoordinateMaxAbsDifference), 2e-6)
    expect_lt(max(review$integration$DevianceAbsDifference), 2e-6)
    expect_true(review$provenance$all_provenance_files_match)
    expect_true(review$provenance$additive_manifest_consistent)
    expect_true(all(review$source_registry$IdentityOK))
    expect_identical(
      review$provenance$all_manifested_sources_match,
      all(review$provenance$source_manifest$IdentityOK %in% TRUE)
    )
    expect_identical(
      review$provenance$provenance_ready,
      isTRUE(review$provenance$all_provenance_files_match) &&
        isTRUE(review$provenance$all_manifested_sources_match) &&
        isTRUE(review$provenance$additive_manifest_consistent)
    )
    readiness_gates <- c(
      artifact_identity = all(review$artifact_registry$IdentityOK %in% TRUE),
      source_identity = all(review$source_registry$IdentityOK %in% TRUE),
      bundle_identity = all(
        review$bundle_hashes$SHA256 == review$bundle_hashes$ExpectedSHA256
      ),
      binding_unopened = isTRUE(
        review$candidate_binding$candidate_core_structurally_authorized
      ),
      frozen_source = isTRUE(review$source_status$IdentityOK),
      provenance = isTRUE(review$provenance$provenance_ready),
      arm_reference = all(review$arm_summary$NumericalReferenceReady),
      integration = all(review$integration$CoordinatePass) &&
        all(review$integration$DeviancePass)
    )
    if (all(readiness_gates)) {
      expect_identical(
        review$status,
        "candidate_003_numerical_reference_ready_execution_handoff_pending"
      )
      expect_true(review$numerical_reference_ready)
    } else {
      # An executed candidate or a changed working tree closes the historical
      # preflight without invalidating the separately frozen reference files.
      expect_identical(review$status, "candidate_003_numerical_reference_invalid")
      expect_false(review$numerical_reference_ready)
    }
    expect_false(review$inference_ready)
    expect_false(review$numerical_reference_promotes_inference)
    expect_false(review$candidate_execution_authorized)
    expect_identical(
      review$execution_hold_reason,
      "candidate_003_execution_handoff_not_frozen"
    )
    expect_false(review$comparison_authorized)
    expect_false(review$scientific_equivalence_inferred)
    expect_false(review$confirmation_authorized)
    expect_false(review$sparse_extension_authorized)
    expect_false(review$large_simulation_authorized)
  } else {
    expect_false(dir.exists(candidate_root))
  }
})

test_that("candidate-003 reference drift fails closed", {
  ctx <- load_conquest_candidate_003_reference_preflight()
  expect_error(
    ctx$env$mfrmr_cq_c3rp_review(tempfile("missing-reference-"), ctx$root),
    "No such file or directory|cannot find|mustWork"
  )

  original <- ctx$env$mfrmr_cq_c3rp_provenance_bundle_sha256
  ctx$env$mfrmr_cq_c3rp_provenance_bundle_sha256 <-
    paste(rep("0", 64L), collapse = "")
  drift <- ctx$env$mfrmr_cq_c3rp_bundle_hashes()
  expect_false(identical(drift$SHA256, drift$ExpectedSHA256))
  ctx$env$mfrmr_cq_c3rp_provenance_bundle_sha256 <- original
  expect_identical(
    ctx$env$mfrmr_cq_c3rp_bundle_hashes()$SHA256,
    ctx$env$mfrmr_cq_c3rp_bundle_hashes()$ExpectedSHA256
  )
})

test_that("candidate-003 reference record is source-bound", {
  ctx <- load_conquest_candidate_003_reference_preflight()
  record_path <- file.path(
    ctx$validation,
    "conquest-six-arm-candidate-003-reference-preflight-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  # Bind the executable contracts, not the mutable test harness that checks
  # them. This avoids a self-referential hash update on every test refinement.
  artifacts <- c(
    file.path(
      ctx$validation,
      c(
        "conquest-six-arm-candidate-003-reference-preflight-0.2.3.R",
        "conquest-six-arm-candidate-003-binding-0.2.3.R"
      )
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
    ctx$env$mfrmr_cq_c3rp_candidate_id,
    ctx$env$mfrmr_cq_c3rp_reference_bundle_sha256,
    ctx$env$mfrmr_cq_c3rp_source_bundle_sha256,
    ctx$env$mfrmr_cq_c3rp_provenance_bundle_sha256,
    "candidate_003_execution_handoff_not_frozen"
  )
  expect_true(all(vapply(
    identities, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_true(grepl("CandidateExecutionAuthorized.*FALSE", record))
  expect_true(grepl("ScientificEquivalenceInferred.*FALSE", record))
})
