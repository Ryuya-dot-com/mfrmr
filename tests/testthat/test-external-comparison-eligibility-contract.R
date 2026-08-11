load_external_comparison_eligibility_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_path <- file.path(
    root, "inst", "validation",
    "external-comparison-eligibility-contract-0.2.3.R"
  )
  fixture_path <- file.path(
    root, "inst", "validation",
    "external-comparison-eligibility-fixtures-0.2.3.csv"
  )
  skip_if_not(file.exists(source_path),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(source_path, envir = env)
  fixtures <- utils::read.csv(
    fixture_path, stringsAsFactors = FALSE, check.names = FALSE,
    na.strings = c("", "NA")
  )
  list(root = root, env = env, fixtures = fixtures)
}

test_that("comparison eligibility fixtures give exact row dispositions", {
  contract <- load_external_comparison_eligibility_contract()
  result <- contract$env$mfrmr_external_comparison_eligibility(
    contract$fixtures
  )
  expected <- contract$fixtures[
    order(contract$fixtures$ComparisonRowId, method = "radix"),
    , drop = FALSE
  ]
  expected_reason <- expected$ExpectedReasonCodes
  expected_reason[is.na(expected_reason)] <- ""

  expect_identical(result$Rows$ComparisonRowId, expected$ComparisonRowId)
  expect_identical(result$Rows$Disposition, expected$ExpectedDisposition)
  expect_identical(result$Rows$Eligible, expected$ExpectedEligible)
  expect_identical(result$Rows$ReasonCodes, expected_reason)
  expect_identical(result$Rows$IncludeInAggregate, expected$ExpectedEligible)
  expect_true(result$Decision$StructuralContractValid)
  expect_identical(result$Decision$EvidenceStatus, "review")
  expect_identical(
    result$Decision$Decision,
    "structural_contract_ready_external_bindings_pending"
  )
  expect_identical(result$Decision$IneligibleIncludedRows, 0L)
})

test_that("every required comparison axis has a deterministic rejection", {
  contract <- load_external_comparison_eligibility_contract()
  result <- contract$env$mfrmr_external_comparison_eligibility(
    contract$fixtures
  )
  required_reasons <- c(
    "unexpected_row_not_in_registry", "missing_expected_row",
    "external_fit_failed", "family_mismatch", "estimator_mismatch",
    "correction_mode_mismatch", "observations_mismatch",
    "weights_mismatch", "active_facets_mismatch",
    "sign_orientation_mismatch", "category_map_mismatch",
    "step_dimension_mismatch", "anchors_mismatch",
    "constraints_mismatch", "coordinates_mismatch",
    "identification_unknown", "conditioning_mismatch",
    "boundary_convention_mismatch", "metric_value_missing_or_nonfinite"
  )

  expect_setequal(unique(result$Reasons$ReasonCode), required_reasons)
  expect_true(all(result$Reasons$Disposition != "eligible"))
  expect_setequal(unique(result$ReasonCounts$ReasonCode), required_reasons)
  expect_true(all(result$ReasonCounts$Rows >= 1L))
})

test_that("denominators expose every disposition and exclude finite rejects", {
  contract <- load_external_comparison_eligibility_contract()
  fixtures <- contract$fixtures
  fixtures$IncludeInAggregate <- TRUE
  result <- contract$env$mfrmr_external_comparison_eligibility(fixtures)

  core <- result$Denominators[
    result$Denominators$ScenarioId == "EXT-CQ-RSM-CORE" &
      result$Denominators$Metric == "bias" &
      result$Denominators$ParameterClass == "severity",
    , drop = FALSE
  ]
  expect_equal(nrow(core), 1L)
  expect_identical(core$ExpectedRows, 4L)
  expect_identical(core$EligibleRows, 1L)
  expect_identical(core$RejectedRows, 1L)
  expect_identical(core$MissingRows, 1L)
  expect_identical(core$FailedRows, 1L)
  expect_identical(core$UnexpectedRows, 1L)
  expect_identical(core$IncludedRows, 1L)
  expect_identical(core$IneligibleIncludedRows, 0L)
  expect_equal(core$AggregateValue, 0.10, tolerance = 0)
  core_reasons <- result$ReasonCounts[
    result$ReasonCounts$ScenarioId == "EXT-CQ-RSM-CORE",
    , drop = FALSE
  ]
  expect_setequal(core_reasons$ReasonCode, c(
    "family_mismatch", "missing_expected_row", "external_fit_failed",
    "unexpected_row_not_in_registry"
  ))
  expect_true(all(core_reasons$Rows == 1L))

  facets <- result$Denominators[
    result$Denominators$ScenarioId == "EXT-FACETS-PCM-CORE",
    , drop = FALSE
  ]
  expect_equal(nrow(facets), 1L)
  expect_identical(facets$ExpectedRows, 11L)
  expect_identical(facets$EligibleRows, 1L)
  expect_identical(facets$RejectedRows, 10L)
  expect_identical(facets$IncludedRows, 1L)
  expect_equal(facets$AggregateValue, 0.05, tolerance = 0)
})

test_that("eligibility is row-order invariant and strata are never pooled", {
  contract <- load_external_comparison_eligibility_contract()
  forward <- contract$env$mfrmr_external_comparison_eligibility(
    contract$fixtures
  )
  reverse <- contract$env$mfrmr_external_comparison_eligibility(
    contract$fixtures[rev(seq_len(nrow(contract$fixtures))), , drop = FALSE]
  )

  expect_identical(forward$Rows, reverse$Rows)
  expect_identical(forward$Denominators, reverse$Denominators)
  expect_identical(forward$Reasons, reverse$Reasons)
  expect_identical(forward$ReasonCounts, reverse$ReasonCounts)
  stratum_key <- do.call(paste, c(
    forward$Denominators[c(
      "ScenarioId", "Program", "ExpectedFamily", "ExpectedEstimator",
      "ExpectedCorrectionMode", "Metric", "ParameterClass"
    )], sep = "|"
  ))
  expect_false(anyDuplicated(stratum_key) > 0L)
  expect_setequal(unique(forward$Denominators$Program),
                  c("ConQuest", "FACETS", "TAM", "immer"))
})

test_that("malformed registries fail closed", {
  contract <- load_external_comparison_eligibility_contract()
  fixtures <- contract$fixtures

  expect_error(
    contract$env$mfrmr_external_comparison_eligibility(
      fixtures[, setdiff(names(fixtures), "WeightsStatus"), drop = FALSE]
    ),
    "missing required comparison columns"
  )
  duplicate <- fixtures
  duplicate$ComparisonRowId[2L] <- duplicate$ComparisonRowId[1L]
  expect_error(
    contract$env$mfrmr_external_comparison_eligibility(duplicate),
    "must be unique"
  )
  bad_status <- fixtures
  bad_status$IdentificationStatus[1L] <- "assumed_match"
  expect_error(
    contract$env$mfrmr_external_comparison_eligibility(bad_status),
    "must be match"
  )
  bad_program <- fixtures
  bad_program$Program[1L] <- "generic_external"
  expect_error(
    contract$env$mfrmr_external_comparison_eligibility(bad_program),
    "unsupported external engine"
  )
})

test_that("eligibility record binds the executable contract and fixtures", {
  skip_if_not_installed("digest")
  contract <- load_external_comparison_eligibility_contract()
  paths <- c(
    file.path(
      contract$root, "inst", "validation",
      "external-comparison-eligibility-contract-0.2.3.R"
    ),
    file.path(
      contract$root, "inst", "validation",
      "external-comparison-eligibility-fixtures-0.2.3.csv"
    ),
    file.path(
      contract$root, "tests", "testthat",
      "test-external-comparison-eligibility-contract.R"
    )
  )
  record_path <- file.path(
    contract$root, "inst", "validation",
    "external-comparison-eligibility-contract-record-0.2.3.md"
  )
  record <- paste(
    readLines(record_path, warn = FALSE, encoding = "UTF-8"),
    collapse = "\n"
  )
  hashes <- vapply(
    paths,
    function(path) tolower(digest::digest(file = path, algo = "sha256")),
    character(1)
  )

  expect_true(all(vapply(
    hashes, grepl, logical(1), x = record, fixed = TRUE
  )))
})
