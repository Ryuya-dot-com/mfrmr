load_fixed_calibration_g3_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "fixed-calibration-g3-scoring-contract-0.2.4.R"
  )
  skip_if_not(file.exists(script), "Fixed-calibration G3 contract is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("G3 policy matrix separates refusal omission and review", {
  ctx <- load_fixed_calibration_g3_contract()
  policy <- ctx$env$mfrmr_fc_g3_policy_matrix()
  dispositions <- ctx$env$mfrmr_fc_g3_disposition_catalog()

  expect_identical(nrow(policy), 17L)
  expect_identical(anyDuplicated(policy$CaseId), 0L)
  expect_identical(
    policy$Policy[policy$CaseId == "MISSING_DEFAULT"], "refuse_batch"
  )
  expect_identical(
    policy$Policy[policy$CaseId == "MISSING_OMIT"],
    "omit_and_reason_code"
  )
  expect_identical(
    policy$Policy[policy$CaseId == "ZERO_VALID_PERSON"],
    "return_no_estimate"
  )
  expect_identical(
    policy$Policy[policy$CaseId == "REPEAT_IDENTIFIED"], "score"
  )
  expect_true(all(
    policy$Policy[policy$CaseId %in% c(
      "LOW_ENDPOINT", "HIGH_ENDPOINT", "VERY_SPARSE", "QUADRATURE_EDGE"
    )] == "score_and_review"
  ))
  expect_identical(nrow(dispositions), 8L)
  expect_identical(anyDuplicated(dispositions$Code), 0L)
})

test_that("G3 result identity binds every conditional score", {
  ctx <- load_fixed_calibration_g3_contract()
  identity <- ctx$env$mfrmr_fc_g3_result_identity()

  expect_identical(nrow(identity), 16L)
  expect_true(all(identity$Required))
  expect_true(all(c(
    "calibration", "semantic_components", "schema", "software", "score_map", "prior",
    "quadrature", "source_readiness", "row_disposition",
    "person_disposition", "endpoint", "sparse_pattern",
    "prior_sensitivity", "estimate_basis", "uncertainty_basis"
  ) %in% identity$Identity))
})

test_that("G3 review closes CORE-04 but keeps public and optional lanes closed", {
  ctx <- load_fixed_calibration_g3_contract()
  review <- ctx$env$mfrmr_fc_g3_review()

  expect_identical(review$status, "G3_complete_internal_public_gate_closed")
  expect_true(review$policy_matrix_complete)
  expect_true(review$row_dispositions_complete)
  expect_true(review$person_dispositions_complete)
  expect_true(review$posterior_oracle_complete)
  expect_true(review$pure_scoring_complete)
  expect_true(review$CORE_04_complete)
  expect_true(review$G3_exit_complete)
  expect_false(review$public_api_authorized)
  expect_false(review$optional_lane_authorized)
  expect_identical(
    review$next_gate, "G4-independent-and-operational-evidence"
  )
})

test_that("G3 contract source cannot fit score persist or launch", {
  ctx <- load_fixed_calibration_g3_contract()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("mfrmr_score_calibration\\s*\\(", source, perl = TRUE))
  expect_false(grepl("saveRDS\\s*\\(|readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
})

test_that("record and roadmap expose completed G3 without public promotion", {
  ctx <- load_fixed_calibration_g3_contract()
  record_path <- file.path(
    ctx$validation, "fixed-calibration-g3-scoring-record-0.2.4.md"
  )
  skip_if_not(file.exists(record_path), "Fixed-calibration G3 record is absent.")
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(
    readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(record, ctx$env$mfrmr_fc_g3_specification, fixed = TRUE)
  expect_match(record, "`CORE04Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`PublicAPIAuthorized=FALSE`", fixed = TRUE)
  expect_match(roadmap, "- [x] **CORE-04 — Pure scoring:**", fixed = TRUE)
  expect_match(roadmap, "- [x] **G3 — Operational scoring closure**", fixed = TRUE)
  expect_match(roadmap, "  - [x] **G3 exit:**", fixed = TRUE)
})
