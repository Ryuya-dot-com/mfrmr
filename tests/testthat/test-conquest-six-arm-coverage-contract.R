load_conquest_six_arm_coverage_contract <- function() {
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "external-comparison-eligibility-contract-0.2.3.R",
    "conquest-external-comparison-normalizer-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R",
    "conquest-binary-external-comparison-normalizer-0.2.3.R",
    "conquest-six-arm-coverage-contract-0.2.3.R",
    "conquest-prospective-tolerance-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)),
              "Repository-only ConQuest coverage contracts are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("six-arm registries cover every prospective coordinate once", {
  env <- load_conquest_six_arm_coverage_contract()
  normalizer <- env$mfrmr_cq_sacc_normalizer_registry()
  precision <- env$mfrmr_cq_sacc_source_precision_registry()

  expect_identical(nrow(normalizer), 54L)
  expect_identical(nrow(precision), 54L)
  expect_identical(nrow(unique(
    normalizer[, c("Model", "Nodes"), drop = FALSE]
  )), 6L)
  expect_identical(
    as.character(unique(normalizer$Model)), c("Binary", "RSM", "PCM")
  )
  expect_identical(sort(unique(normalizer$Nodes)), c(31L, 61L))
  expect_identical(sum(normalizer$Model == "Binary"), 18L)
  expect_identical(sum(normalizer$Model == "RSM"), 16L)
  expect_identical(sum(normalizer$Model == "PCM"), 20L)
  expect_true(all(normalizer$ImplementationReady))
  expect_true(all(precision$ImplementationReady))
  expect_true(all(!normalizer$CandidateOutputObserved))
  expect_true(all(!precision$CandidateTokenObserved))
  expect_false(any(normalizer$RetainedNativeCalibrationAvailable[
    normalizer$Model == "Binary"
  ]))
  expect_true(all(normalizer$RetainedNativeCalibrationAvailable[
    normalizer$Model != "Binary"
  ]))
  expect_true(all(!precision$HiddenSolutionEquivalenceEligible))
})

test_that("six-arm hashes are deterministic and mutation sensitive", {
  env <- load_conquest_six_arm_coverage_contract()
  normalizer <- env$mfrmr_cq_sacc_normalizer_registry()
  precision <- env$mfrmr_cq_sacc_source_precision_registry()
  normalizer_hash <- env$mfrmr_cq_sacc_sha256(normalizer)
  precision_hash <- env$mfrmr_cq_sacc_sha256(precision)

  expect_match(normalizer_hash, "^[[:xdigit:]]{64}$")
  expect_match(precision_hash, "^[[:xdigit:]]{64}$")
  expect_false(identical(normalizer_hash, precision_hash))
  expect_identical(
    normalizer_hash,
    env$mfrmr_cq_ptc_normalizer_coverage_registry_sha256
  )
  expect_identical(
    precision_hash,
    env$mfrmr_cq_ptc_source_precision_coverage_registry_sha256
  )
  expect_identical(
    normalizer_hash,
    env$mfrmr_cq_sacc_sha256(normalizer[nrow(normalizer):1L, , drop = FALSE])
  )
  changed <- normalizer
  changed$ImplementationReady[1L] <- FALSE
  expect_false(identical(
    normalizer_hash, env$mfrmr_cq_sacc_sha256(changed)
  ))
})

test_that("six-arm review separates adapter readiness from retained evidence", {
  env <- load_conquest_six_arm_coverage_contract()
  review <- env$mfrmr_cq_sacc_review()

  expect_s3_class(review, "mfrmr_conquest_six_arm_coverage")
  expect_identical(review$summary$Families, "Binary;RSM;PCM")
  expect_identical(review$summary$Nodes, "31;61")
  expect_identical(review$summary$Arms, 6L)
  expect_identical(review$summary$CoordinateRows, 54L)
  expect_true(review$summary$NormalizerImplementationComplete)
  expect_true(review$summary$SourcePrecisionImplementationComplete)
  expect_identical(review$summary$RetainedNativeCalibrationArms, 4L)
  expect_false(review$summary$BinaryRetainedNativeEvidenceAvailable)
  expect_false(review$summary$CandidateOutputsObserved)
  expect_false(review$summary$ComparisonReady)
  expect_false(review$summary$ConfirmationAuthorized)
  expect_identical(
    review$status, "six_arm_adapter_ready_binary_native_evidence_missing"
  )
})

test_that("six-arm record binds implementation sources", {
  env <- load_conquest_six_arm_coverage_contract()
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  record_path <- file.path(
    validation, "conquest-six-arm-coverage-contract-record-0.2.3.md"
  )
  expect_true(file.exists(record_path))
  paths <- c(
    file.path(
      validation, "conquest-binary-external-comparison-normalizer-0.2.3.R"
    ),
    file.path(
      root, "tests", "testthat",
      "test-conquest-binary-external-comparison-normalizer.R"
    ),
    file.path(validation, "conquest-six-arm-coverage-contract-0.2.3.R"),
    file.path(
      root, "tests", "testthat", "test-conquest-six-arm-coverage-contract.R"
    )
  )
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  hashes <- vapply(
    paths, digest::digest, character(1L), algo = "sha256", file = TRUE,
    serialize = FALSE
  )
  expect_true(all(vapply(hashes, grepl, logical(1L), x = record, fixed = TRUE)))
  review <- env$mfrmr_cq_sacc_review()
  expect_match(
    record, review$summary$NormalizerCoverageRegistrySHA256, fixed = TRUE
  )
  expect_match(
    record, review$summary$SourcePrecisionCoverageRegistrySHA256, fixed = TRUE
  )
})
