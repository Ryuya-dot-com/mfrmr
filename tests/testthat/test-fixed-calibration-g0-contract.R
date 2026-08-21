load_fixed_calibration_g0_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(validation, "fixed-calibration-g0-contract-0.2.4.R")
  skip_if_not(file.exists(script), "Fixed-calibration G0 contract is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("claim ledger carries local CORE-05 closure without closing G4", {
  ctx <- load_fixed_calibration_g0_contract()
  ledger <- ctx$env$mfrmr_fc_g0_claim_ledger()

  expect_identical(nrow(ledger), 24L)
  expect_identical(anyDuplicated(ledger$RequirementId), 0L)
  expect_true(all(c(
    sprintf("GOV-%02d", 1:7), sprintf("CORE-%02d", 1:8),
    sprintf("OPT-%02d", 1:4),
    "H-024-01", "H-024-02", "H-025-01", "H-030-01", "H-100-01"
  ) %in% ledger$RequirementId))
  expect_true(all(nzchar(ledger$Falsifier)))
  expect_true(all(nzchar(ledger$EvidencePath)))
  expect_true(all(nzchar(ledger$DecisionConsequence)))
  expect_true(all(nzchar(ledger$Fallback)))
  expect_identical(
    ledger$Status[ledger$RequirementId %in% c("CORE-01", "CORE-02")],
    rep("complete_g1", 2)
  )
  expect_identical(
    ledger$Status[ledger$RequirementId == "CORE-03"], "complete_g2"
  )
  expect_identical(
    ledger$Status[ledger$RequirementId == "CORE-04"], "complete_g3"
  )
  expect_identical(
    ledger$Status[ledger$RequirementId == "CORE-05"], "complete_g4_local"
  )
  expect_identical(
    ledger$Status[ledger$RequirementId == "CORE-06"], "open_g4_platform"
  )
  expect_true(all(
    ledger$Status[ledger$RequirementId %in% c("CORE-07", "CORE-08")] == "open"
  ))
  expect_true(all(ledger$Status[grepl("^OPT-", ledger$RequirementId)] == "open_unpromoted"))
})

test_that("G0 field inventory identifies prohibited fit-state dependencies", {
  ctx <- load_fixed_calibration_g0_contract()
  fields <- ctx$env$mfrmr_fc_g0_field_inventory()

  expect_identical(nrow(fields), 28L)
  expect_identical(anyDuplicated(fields$FieldId), 0L)
  expect_true(all(nzchar(fields$ArtifactOwner)))
  expect_true(all(nzchar(fields$Threat)))
  expect_true(all(nzchar(fields$G0Disposition)))
  expect_true(all(c(
    "RAW_PARAMETERS", "TRAINING_DESIGN_MATRIX", "READINESS", "SCORE_MAP",
    "FACET_SIGNS", "QUAD_POINTS", "POSTERIOR_BASIS", "ANCHOR_DECLARATIONS"
  ) %in% fields$FieldId))
  expect_identical(
    fields$G0Disposition[fields$FieldId == "TRAINING_DESIGN_MATRIX"],
    "prohibit_replace_with_expanded_parameters"
  )
  expect_identical(
    fields$G0Disposition[fields$FieldId == "READINESS"],
    "require_current_fit_and_parameter_gate"
  )
})

test_that("G0 behavior inventory separates predecessor behavior from target", {
  ctx <- load_fixed_calibration_g0_contract()
  behaviors <- ctx$env$mfrmr_fc_g0_behavior_inventory()

  expect_identical(nrow(behaviors), 18L)
  expect_identical(anyDuplicated(behaviors$BehaviorId), 0L)
  expect_true(all(c(
    "INVALID_ROW_DROP", "DUPLICATE_EVENT", "READINESS_GATE",
    "QUADRATURE_FALLBACK", "POSTERIOR_FALLBACK", "JML_PRIOR",
    "ENDPOINT_STATUS", "ANCHOR_EXPORT_ROUNDING", "ANCHORED_REFIT"
  ) %in% behaviors$BehaviorId))
  expect_true(all(nzchar(behaviors$TargetDisposition)))
})

test_that("support matrix promotes no nonexistent frozen API", {
  ctx <- load_fixed_calibration_g0_contract()
  support <- ctx$env$mfrmr_fc_g0_support_matrix()

  expect_identical(nrow(support), 6L)
  expect_identical(anyDuplicated(support$LaneId), 0L)
  expect_true(all(support$CurrentCallablePredecessor))
  expect_true(all(support$FrozenCalibrationPublicStatus == "not_available"))
  expect_identical(sum(support$ProvisionalDisposition == "core_candidate_unvalidated"), 2L)
  expect_identical(sum(support$ProvisionalDisposition == "optional_unpromoted"), 4L)
})

test_that("CRAN source identity closes G0 without authorizing public promotion", {
  ctx <- load_fixed_calibration_g0_contract()
  review <- ctx$env$mfrmr_fc_g0_review()

  expect_identical(review$status, "G0_complete_cran_0.2.3_source_bound")
  expect_true(review$claim_ledger_complete)
  expect_true(review$field_inventory_complete)
  expect_true(review$support_matrix_provisional)
  expect_true(review$published_artifact_identity_bound)
  expect_true(review$local_candidate_content_bound)
  expect_true(review$G0_exit_complete)
  expect_true(review$G1_implementation_authorized)
  expect_false(review$public_api_change_authorized)
  expect_false(review$public_promotion_authorized)
  expect_false(review$fit_executed)
  expect_false(review$data_generated)
})

test_that("G0 source cannot fit, generate data, persist, or launch", {
  ctx <- load_fixed_calibration_g0_contract()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("simulate_|rnorm\\s*\\(|runif\\s*\\(", source, perl = TRUE))
  expect_false(grepl("saveRDS\\s*\\(|write\\.", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
})

test_that("record and roadmap expose only the completed G0 subclaims", {
  ctx <- load_fixed_calibration_g0_contract()
  record <- paste(readLines(file.path(
    ctx$validation, "fixed-calibration-g0-contract-record-0.2.4.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_fc_g0_specification, fixed = TRUE)
  expect_match(record, "`PublishedArtifactIdentityBound=TRUE`", fixed = TRUE)
  expect_match(record, "`G0ExitComplete=TRUE`", fixed = TRUE)
  expect_match(roadmap, "[x] **GOV-07 — Claim ledger:**", fixed = TRUE)
  expect_match(roadmap, "- [x] **G0 — Post-0.2.3 baseline", fixed = TRUE)
  expect_match(roadmap, "- [x] **G0 exit:**", fixed = TRUE)
})
