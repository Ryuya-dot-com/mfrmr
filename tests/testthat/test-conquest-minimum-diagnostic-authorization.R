load_conquest_minimum_diagnostic_authorization <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-minimum-diagnostic-authorization-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest diagnostic-authorization files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

minimum_diagnostic_clean_runtime <- function(env, run_date = as.Date("2026-08-15")) {
  env$mfrmr_cq_srp_assess(
    console_lines = env$mfrmr_cq_srp_fixture_transcripts()$clean_demo,
    exit_status = 0L,
    executable_path = "/explicit/ConQuest",
    executable_available = TRUE,
    executable = TRUE,
    launcher_available = TRUE,
    architecture = "Mach-O 64-bit executable x86_64",
    invocation_route = "/explicit/ConQuest",
    locale = "C",
    run_date = run_date,
    command_is_data_free_quit = TRUE
  )
}

minimum_diagnostic_attestation <- function(env, overlap = TRUE) {
  env$mfrmr_cq_mda_attestation(
    auditor_id = "declared-artifact-maintainer",
    reviewer_role = "maintainer",
    author_overlap_declared = overlap,
    fatal_gate_checklist_completed = TRUE,
    exact_slice_and_cap_accepted = TRUE,
    no_interpretive_claim_accepted = TRUE,
    audit_date = as.Date("2026-08-15")
  )
}

minimum_diagnostic_assess <- function(env, ...) {
  arguments <- list(
    runtime_preflight = minimum_diagnostic_clean_runtime(env),
    explicit_executable_path = "/explicit/ConQuest",
    attestation = minimum_diagnostic_attestation(env),
    authorization_date = as.Date("2026-08-15"),
    candidate_outputs_absent = TRUE,
    ordinary_tests_external_runtime_free = TRUE,
    worktree_clean = TRUE
  )
  arguments[names(list(...))] <- list(...)
  do.call(env$mfrmr_cq_mda_assess, arguments)
}

test_that("the smallest meaningful P2 slice is exactly one paired design", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  env <- ctx$env
  slice <- env$mfrmr_cq_mda_slice_registry()
  fixtures <- env$mfrmr_cq_p2_fixture_registry()

  expect_identical(nrow(slice), 2L)
  expect_identical(slice$RegistryRowId, c(
    "P2-RSM-CONNECTED-MULTIBRIDGE",
    "P2-PCM-CONNECTED-MULTIBRIDGE"
  ))
  expect_identical(slice$Family, c("RSM", "PCM"))
  expect_true(all(slice$IntegrationNodeLadder == "31;61"))
  expect_identical(sum(slice$ConQuestFits), 4L)
  expect_identical(sum(slice$MfrmrFits), 4L)
  expect_true(all(slice$ExpectedNativeOutputsPerFit == 8L))
  expect_true(identical(
    fixtures[[slice$RegistryRowId[1L]]]$Data,
    fixtures[[slice$RegistryRowId[2L]]]$Data
  ))
  expect_false(any(grepl(
    "candidate-003", slice$ExecutionIdentity, fixed = TRUE
  )))
  expect_false(any(slice$EvidencePromotionAuthorized))
  expect_false(any(slice$WiderExecutionAuthorized))
  expect_false(any(slice$P3ExecutionAuthorized))
  expect_false(any(slice$ScientificEquivalenceInferred))
})

test_that("review independence is deferred only for sealed diagnostic execution", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  tiers <- ctx$env$mfrmr_cq_mda_review_tier_registry()

  expect_identical(nrow(tiers), 2L)
  expect_identical(
    tiers$ReviewTier,
    c(
      "minimum_preexecution_fatal_gate_audit",
      "independent_postoutput_evidence_review"
    )
  )
  expect_true(tiers$BlocksSmallestDiagnosticExecution[1L])
  expect_false(tiers$BlocksSmallestDiagnosticExecution[2L])
  expect_match(tiers$PermittedReviewer[1L], "maintainer", fixed = TRUE)
  expect_match(tiers$PermittedReviewer[1L], "author_overlap_declared",
               fixed = TRUE)
  expect_match(tiers$PermittedReviewer[2L], "independent", fixed = TRUE)
  expect_true(all(tiers$BlocksEvidencePromotion))
  expect_true(all(tiers$BlocksWiderExecution))
  expect_true(all(tiers$BlocksPublicClaim))
  expect_false(any(tiers$CanInferScientificEquivalence))
})

test_that("all construction layers are ready without authorizing a run", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  review <- ctx$env$mfrmr_cq_mda_construction_review()

  expect_identical(
    review$status,
    "minimum_diagnostic_contract_ready_runtime_and_attestation_unbound"
  )
  expect_true(review$semantic_construction_ready)
  expect_true(review$P2_fixture_construction_ready)
  expect_true(review$P2_metric_construction_ready)
  expect_true(review$exact_slice_frozen)
  expect_true(review$review_tiers_frozen)
  expect_true(review$fatal_gate_definitions_frozen)
  expect_true(review$all_construction_layers_ready)
  expect_identical(nrow(review$fatal_gates), 15L)
  expect_true(all(review$fatal_gates$BlocksSmallestDiagnosticExecution))
  expect_false(any(review$fatal_gates$CanBeWaivedForExpiryPressure))
  expect_false(review$current_runtime_bound)
  expect_false(review$minimum_audit_attested)
  expect_false(review$smallest_P2_diagnostic_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$wider_execution_authorized)
  expect_false(review$P3_execution_authorized)
})

test_that("a disclosed maintainer audit can authorize only the sealed diagnostic", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  result <- minimum_diagnostic_assess(ctx$env)

  expect_identical(
    result$status,
    "smallest_P2_diagnostic_execution_authorized_no_evidence_promotion"
  )
  expect_true(all(result$gates$Passed))
  expect_identical(nrow(result$failed_gates), 0L)
  expect_true(result$minimum_audit_attested)
  expect_true(result$maintainer_self_audit_permitted_when_overlap_declared)
  expect_true(result$smallest_P2_diagnostic_execution_authorized)
  expect_false(result$P0_closed)
  expect_false(result$P1_closed)
  expect_false(result$independent_comprehensive_review_passed)
  expect_false(result$evidence_promotion_authorized)
  expect_false(result$wider_execution_authorized)
  expect_false(result$P3_execution_authorized)
  expect_false(result$public_claim_authorized)
  expect_false(result$scientific_equivalence_inferred)
})

test_that("runtime, scope, provenance, and attestation mutations block execution", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  env <- ctx$env
  expect_false(minimum_diagnostic_assess(
    env, requested_registry_rows = c(
      env$mfrmr_cq_mda_slice_registry()$RegistryRowId,
      "P2-RSM-WEAK-SINGLE-BRIDGE"
    )
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, requested_node_ladder = "31;61;121"
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, requested_conquest_fits = 5L
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, candidate_outputs_absent = FALSE
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, ordinary_tests_external_runtime_free = FALSE
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, worktree_clean = FALSE
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, explicit_executable_path = "/different/ConQuest"
  )$smallest_P2_diagnostic_execution_authorized)

  old_runtime <- minimum_diagnostic_clean_runtime(
    env, as.Date("2026-08-13")
  )
  expect_false(minimum_diagnostic_assess(
    env, runtime_preflight = old_runtime
  )$smallest_P2_diagnostic_execution_authorized)
  expect_false(minimum_diagnostic_assess(
    env, authorization_date = as.Date("2026-09-02")
  )$smallest_P2_diagnostic_execution_authorized)

  undeclared <- minimum_diagnostic_attestation(env)
  undeclared$AuthorOverlapDeclared <- NA
  result <- minimum_diagnostic_assess(env, attestation = undeclared)
  expect_false(result$smallest_P2_diagnostic_execution_authorized)
  expect_true("AUTHOR_OVERLAP_EXPLICITLY_DECLARED" %in%
    result$failed_gates$GateId)

  claim <- minimum_diagnostic_attestation(env)
  claim$NoInterpretiveClaimAccepted <- FALSE
  result <- minimum_diagnostic_assess(env, attestation = claim)
  expect_false(result$smallest_P2_diagnostic_execution_authorized)
  expect_true("NO_INTERPRETIVE_CLAIM_ACCEPTED" %in%
    result$failed_gates$GateId)
})

test_that("semantic dependency mutations fail before authorization", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  env <- ctx$env

  original <- env$mfrmr_cq_p2m_contract
  env$mfrmr_cq_p2m_contract <- "wrong_P2_metric_contract"
  expect_error(
    env$mfrmr_cq_mda_construction_review(),
    "exact runtime, successor-registry, P2 fixture, tolerance",
    fixed = TRUE
  )
  env$mfrmr_cq_p2m_contract <- original
  expect_true(env$mfrmr_cq_mda_construction_review()$all_construction_layers_ready)
})

test_that("the authorization contract cannot execute ConQuest itself", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  source <- paste(readLines(ctx$paths[6L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
})

test_that("the internal record replaces the monolithic pre-run review gate", {
  ctx <- load_conquest_minimum_diagnostic_authorization()
  record_path <- file.path(
    ctx$validation,
    "conquest-minimum-diagnostic-authorization-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_mda_specification,
    ctx$env$mfrmr_cq_mda_contract,
    "minimum_diagnostic_contract_ready_runtime_and_attestation_unbound",
    "P2-RSM-CONNECTED-MULTIBRIDGE",
    "P2-PCM-CONNECTED-MULTIBRIDGE",
    "ConQuest fits | 4",
    "mfrmr fits | 4",
    "`SmallestP2DiagnosticExecutionAuthorized` | `FALSE`",
    "`IndependentComprehensiveReviewPassed` | `FALSE`",
    "`EvidencePromotionAuthorized` | `FALSE`",
    "`P3ExecutionAuthorized` | `FALSE`"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    roadmap,
    "[x] Split the monolithic independent-review gate",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze the smallest meaningful external P2 diagnostic slice",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Bind a current data-free runtime sentinel and completed minimum audit",
    fixed = TRUE
  )
})
