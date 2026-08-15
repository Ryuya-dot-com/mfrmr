load_conquest_p2_candidate_004_dependency_sentinel <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation,
    "conquest-p2-candidate-004-dependency-sentinel-0.2.3.R"
  )
  skip_if_not(file.exists(script), "Candidate-004 dependency sentinel is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("sentinel covers every named scientific dependency", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  registry <- env$mfrmr_cq_p2c4ds_registry()

  expect_identical(nrow(registry), 11L)
  expect_identical(anyDuplicated(registry$ChangeClass), 0L)
  expect_true(all(c(
    "likelihood_semantics", "constraint_semantics",
    "category_handling_semantics", "integration_or_optimizer_semantics",
    "external_output_parser_semantics", "coordinate_transform_semantics",
    "conquest_runtime_identity", "frozen_acceptance_contract",
    "raw_evidence_semantics"
  ) %in% registry$ChangeClass))
  expect_false(any(registry$Candidate004RerunAuthorized))
  expect_false(any(registry$PublicClaimAuthorized))
})

test_that("no declared semantic change leaves only the gate untriggered", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  review <- env$mfrmr_cq_p2c4ds_review()

  expect_identical(review$disposition, "no_declared_semantic_change")
  expect_true(review$historical_candidate_record_retained)
  expect_true(review$historical_primary_evidence_usable)
  expect_true(review$current_source_claim_attached)
  expect_false(review$successor_candidate_required_for_current_claim)
})

test_that("model semantics detach current claims without erasing history", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  for (change in c(
    "likelihood_semantics", "constraint_semantics",
    "category_handling_semantics", "integration_or_optimizer_semantics"
  )) {
    review <- env$mfrmr_cq_p2c4ds_review(change)
    expect_identical(
      review$disposition, "current_source_claim_detached_successor_required"
    )
    expect_true(review$historical_candidate_record_retained)
    expect_true(review$historical_primary_evidence_usable)
    expect_true(review$historical_scope_label_required)
    expect_false(review$current_source_claim_attached)
    expect_true(review$successor_candidate_required_for_current_claim)
    expect_false(review$candidate_004_rerun_authorized)
  }
})

test_that("parser and transform changes restart only the calculation", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  review <- env$mfrmr_cq_p2c4ds_review(c(
    "external_output_parser_semantics", "coordinate_transform_semantics"
  ))

  expect_identical(
    review$disposition, "independent_review_restart_from_raw_required"
  )
  expect_true(review$independent_review_restart_from_raw_required)
  expect_false(review$independent_review_blocked)
  expect_true(review$current_source_claim_attached)
  expect_false(review$successor_candidate_required_for_current_claim)
  expect_false(review$candidate_004_rerun_authorized)
})

test_that("runtime changes require a new sentinel and successor", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  review <- env$mfrmr_cq_p2c4ds_review("conquest_runtime_identity")

  expect_identical(
    review$disposition, "new_runtime_sentinel_and_successor_required"
  )
  expect_true(review$historical_candidate_record_retained)
  expect_true(review$new_runtime_sentinel_required)
  expect_true(review$successor_candidate_required_for_current_claim)
  expect_false(review$current_source_claim_attached)
})

test_that("evidence and contract incidents take fail-closed precedence", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  raw <- env$mfrmr_cq_p2c4ds_review(c(
    "raw_evidence_semantics", "likelihood_semantics"
  ))
  contract <- env$mfrmr_cq_p2c4ds_review(c(
    "frozen_acceptance_contract", "external_output_parser_semantics"
  ))

  expect_identical(raw$disposition, "raw_evidence_incident_review_blocked")
  expect_true(raw$raw_evidence_quarantine_required)
  expect_true(raw$independent_review_blocked)
  expect_false(raw$historical_primary_evidence_usable)
  expect_false(raw$candidate_004_rerun_authorized)

  expect_identical(
    contract$disposition, "frozen_contract_mutation_review_blocked"
  )
  expect_true(contract$frozen_contract_integrity_review_required)
  expect_true(contract$independent_review_blocked)
  expect_false(contract$candidate_004_rerun_authorized)
})

test_that("unknown impact blocks while documentation alone does not reset", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  unknown <- env$mfrmr_cq_p2c4ds_review("unknown_or_mixed")
  documentation <- env$mfrmr_cq_p2c4ds_review("documentation_or_test_only")

  expect_identical(
    unknown$disposition, "manual_dependency_classification_required"
  )
  expect_true(unknown$manual_dependency_review_required)
  expect_true(unknown$independent_review_blocked)

  expect_identical(
    documentation$disposition,
    "documentation_or_test_only_no_scientific_reset"
  )
  expect_false(documentation$independent_review_blocked)
  expect_true(documentation$current_source_claim_attached)
})

test_that("declaration is semantic and initially empty", {
  env <- load_conquest_p2_candidate_004_dependency_sentinel()$env
  declaration <- env$mfrmr_cq_p2c4ds_declaration_template()
  plan <- env$mfrmr_cq_p2c4ds_plan()

  expect_identical(declaration$ChangeClass, plan$registry$ChangeClass)
  expect_false(any(declaration$Changed))
  expect_true(all(declaration$Rationale == ""))
  expect_true(plan$semantic_change_declaration_required)
  expect_false(plan$byte_identity_is_scientific_gate)
  expect_false(plan$path_change_alone_is_scientific_decision)
})

test_that("the sentinel cannot inspect files, fit, or launch", {
  ctx <- load_conquest_p2_candidate_004_dependency_sentinel()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("read[.]csv\\s*\\(|readLines\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap expose the semantic sentinel", {
  ctx <- load_conquest_p2_candidate_004_dependency_sentinel()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-dependency-sentinel-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4ds_specification, fixed = TRUE)
  expect_match(record, "No byte-level equality is a scientific gate", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Define the smallest dependency-based sentinel",
    fixed = TRUE
  )
})
