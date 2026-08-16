load_conquest_adversarial_simulation_diagnostic_numeric_eligibility <-
  function() {
    root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
    validation <- file.path(root, "inst", "validation")
    paths <- file.path(validation, c(
      "conquest-semantic-runtime-preflight-0.2.3.R",
      "conquest-successor-semantic-registry-0.2.3.R",
      "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
      "conquest-adversarial-simulation-program-0.2.3.R",
      "conquest-adversarial-simulation-template-contract-0.2.3.R",
      "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
      "conquest-adversarial-simulation-smoke-authorization-0.2.3.R",
      "conquest-adversarial-simulation-smoke-execution-0.2.3.R",
      "conquest-adversarial-simulation-calibration-freeze-0.2.3.R",
      "conquest-adversarial-simulation-engine-mechanics-authorization-0.2.3.R",
      "conquest-adversarial-simulation-engine-mechanics-harness-0.2.3.R",
      "conquest-adversarial-simulation-post-mechanics-calibration-review-0.2.3.R",
      paste0(
        "conquest-adversarial-simulation-diagnostic-numeric-",
        "eligibility-addendum-0.2.3.R"
      )
    ))
    skip_if_not(all(file.exists(paths)), "ConQuest ASP G4N files are excluded.")
    pkgload::load_all(root, quiet = TRUE)
    env <- new.env(parent = globalenv())
    for (path in paths) sys.source(path, envir = env)
    output <- file.path(
      root, "validation-results", env$mfrmr_cq_amea_output_basename
    )
    skip_if_not(dir.exists(output), "The retained run-once G4X output is absent.")
    list(root = root, validation = validation, paths = paths, env = env,
         output = output)
  }

g4n_attempt_fixture <- function(engine = "mfrmr",
                                representation = "observed_rows_only") {
  mfrmr <- identical(engine, "mfrmr")
  data.frame(
    Family = "RSM",
    Engine = engine,
    QuadratureId = "q61",
    RepresentationId = representation,
    StructuralDispositionFromRetainedG3 = "eligible_numeric_comparison",
    AttemptCap = 1L,
    Started = TRUE,
    Completed = TRUE,
    AttemptCount = 1L,
    ParseableResult = TRUE,
    ExpectedFreeDimension = 10L,
    ObservedFreeDimension = 10L,
    ModelIdentityMatch = TRUE,
    AutomaticRetryPermitted = FALSE,
    NumericAgreementInspected = FALSE,
    TerminalCode = if (mfrmr) {
      "optimizer_nonconvergence_or_readiness_hold"
    } else {
      "complete_numeric_eligible"
    },
    SecondaryCode = if (mfrmr) {
      "mfrmr_optimizer_nonconvergence_or_readiness_hold"
    } else {
      NA_character_
    },
    RegisteredFailureCount = if (mfrmr) 1L else 0L,
    ExitStatus = if (mfrmr) NA_integer_ else 0L,
    TerminalMarkerObserved = if (mfrmr) NA else TRUE,
    ArtifactSetComplete = TRUE,
    SemanticBridgeSatisfied = TRUE,
    stringsAsFactors = FALSE
  )
}

g4n_readiness_fixture <- function(representation = "observed_rows_only") {
  explicit <- identical(representation, "explicit_missing")
  data.frame(
    Model = "RSM",
    ICQuadraturePoints = 61L,
    MMLEngineRequested = "direct",
    MMLEngineUsed = "direct",
    Converged = TRUE,
    ConvergenceCode = 0L,
    ConvergenceStatus = "converged",
    ConvergenceSeverity = "pass",
    ReviewableWarning = FALSE,
    FitReadiness = "review",
    InferenceReady = FALSE,
    InputState = if (explicit) "review" else "pass",
    EstimabilityState = "not_evaluated",
    CategoryState = "adequate",
    BoundaryState = "finite",
    NumericalState = "ready",
    ReadinessReasonCodes = if (explicit) {
      "input_review_required;design_rank_not_evaluated"
    } else {
      "design_rank_not_evaluated"
    },
    stringsAsFactors = FALSE
  )
}

test_that("G4N admits only the narrow converged rank-hold diagnostic lane", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  attempt <- g4n_attempt_fixture()
  readiness <- g4n_readiness_fixture()
  result <- ctx$env$mfrmr_cq_adne_classify_attempt(attempt, readiness)

  expect_true(result$DiagnosticNumericEligible)
  expect_identical(
    result$DiagnosticEligibilityMode, "diagnostic_rank_hold_only"
  )
  expect_false(result$InferenceReadyBeforeContract)
  expect_false(result$InferenceReadyAfterContract)
  expect_true(result$InferenceReadyPreserved)
  expect_true(result$TerminalCodePreserved)
  expect_identical(
    result$TerminalCodeBeforeContract,
    "optimizer_nonconvergence_or_readiness_hold"
  )
  expect_identical(
    result$TerminalCodeAfterContract, result$TerminalCodeBeforeContract
  )
  expect_true(result$DiagnosticUseOnly)
  expect_false(result$NumericValueInspected)
})

test_that("the terminal taxonomy contains exactly one narrow exception", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  taxonomy <- ctx$env$mfrmr_cq_adne_terminal_exclusion_registry()
  allowed <- ctx$env$mfrmr_cq_adne_allowed_rank_hold_registry()

  expect_identical(nrow(taxonomy), 18L)
  expect_identical(
    sum(taxonomy$DiagnosticEligibilityRule ==
          "always_diagnostic_ineligible"),
    16L
  )
  expect_identical(
    taxonomy$TerminalCode[grepl(
      "narrow_exception", taxonomy$DiagnosticEligibilityRule, fixed = TRUE
    )],
    "optimizer_nonconvergence_or_readiness_hold"
  )
  expect_identical(
    taxonomy$TerminalCode[grepl(
      "eligible_only_if", taxonomy$DiagnosticEligibilityRule, fixed = TRUE
    )],
    "complete_numeric_eligible"
  )
  expect_false(any(taxonomy$MayBeRelabelled))
  expect_false(any(taxonomy$MayBeDropped))
  expect_identical(nrow(allowed), 2L)
  expect_true(all(allowed$InferenceReadyMustRemainFalse))
  expect_true(all(allowed$DiagnosticUseOnly))
})

test_that("G4N rank-hold exception fails closed under adversarial mutations", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  classify <- ctx$env$mfrmr_cq_adne_classify_attempt
  base_attempt <- g4n_attempt_fixture()
  base_readiness <- g4n_readiness_fixture()
  cases <- list(
    nonconverged = list("readiness", "Converged", FALSE),
    convergence_status = list(
      "readiness", "ConvergenceStatus", "iteration_limit"
    ),
    convergence_code = list("readiness", "ConvergenceCode", 1L),
    convergence_severity = list(
      "readiness", "ConvergenceSeverity", "review"
    ),
    reviewable_warning = list("readiness", "ReviewableWarning", TRUE),
    wrong_model = list("readiness", "Model", "PCM"),
    wrong_quadrature = list("readiness", "ICQuadraturePoints", 121L),
    wrong_requested_engine = list(
      "readiness", "MMLEngineRequested", "EM"
    ),
    wrong_used_engine = list("readiness", "MMLEngineUsed", "EM"),
    parse_failure = list("attempt", "ParseableResult", FALSE),
    dimension_mismatch = list("attempt", "ObservedFreeDimension", 11L),
    family_dimension_mismatch = list("attempt", "Family", "PCM"),
    unregistered_quadrature = list("attempt", "QuadratureId", "q60"),
    model_mismatch = list("attempt", "ModelIdentityMatch", FALSE),
    unknown_reason = list(
      "readiness", "ReadinessReasonCodes",
      "design_rank_not_evaluated;unknown_reason"
    ),
    structurally_unidentified = list(
      "readiness", "EstimabilityState", "structurally_unidentified"
    ),
    category_weak = list(
      "readiness", "CategoryState", "weak_information"
    ),
    boundary_exclusion = list(
      "readiness", "BoundaryState", "has_exclusions"
    ),
    numerical_failure = list("readiness", "NumericalState", "failed"),
    optimizer_terminal = list("attempt", "TerminalCode", "optimizer_error"),
    artifact_missing = list("attempt", "ArtifactSetComplete", FALSE),
    semantic_bridge_failure = list(
      "attempt", "SemanticBridgeSatisfied", FALSE
    ),
    duplicate_attempt = list("attempt", "AttemptCount", 2L),
    retry_permitted = list(
      "attempt", "AutomaticRetryPermitted", TRUE
    ),
    result_already_opened = list(
      "attempt", "NumericAgreementInspected", TRUE
    )
  )
  for (name in names(cases)) {
    attempt <- base_attempt
    readiness <- base_readiness
    target <- cases[[name]][[1L]]
    field <- cases[[name]][[2L]]
    value <- cases[[name]][[3L]]
    if (target == "attempt") attempt[[field]] <- value
    if (target == "readiness") readiness[[field]] <- value
    observed <- classify(attempt, readiness)
    expect_false(observed$DiagnosticNumericEligible, info = name)
    expect_identical(observed$DiagnosticEligibilityMode, "ineligible")
    expect_false(observed$InferenceReadyAfterContract)
    expect_true(observed$TerminalCodePreserved)
  }
})

test_that("explicit missingness requires its exact extra review reason", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  attempt <- g4n_attempt_fixture(representation = "explicit_missing")
  readiness <- g4n_readiness_fixture(representation = "explicit_missing")

  eligible <- ctx$env$mfrmr_cq_adne_classify_attempt(attempt, readiness)
  expect_true(eligible$DiagnosticNumericEligible)
  expect_false(eligible$InferenceReadyAfterContract)

  missing_reason <- readiness
  missing_reason$ReadinessReasonCodes <- "design_rank_not_evaluated"
  expect_false(ctx$env$mfrmr_cq_adne_classify_attempt(
    attempt, missing_reason
  )$DiagnosticNumericEligible)

  wrong_representation <- attempt
  wrong_representation$RepresentationId <- "planned_absence"
  expect_false(ctx$env$mfrmr_cq_adne_classify_attempt(
    wrong_representation, readiness
  )$DiagnosticNumericEligible)
})

test_that("ordinary complete results use the standard path without relabeling", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  attempt <- g4n_attempt_fixture()
  attempt$TerminalCode <- "complete_numeric_eligible"
  attempt$SecondaryCode <- NA_character_
  attempt$RegisteredFailureCount <- 0L
  readiness <- g4n_readiness_fixture()
  readiness$FitReadiness <- "ready"
  readiness$InferenceReady <- TRUE
  readiness$EstimabilityState <- "identified"
  readiness$ReadinessReasonCodes <- NA_character_

  result <- ctx$env$mfrmr_cq_adne_classify_attempt(attempt, readiness)
  expect_true(result$DiagnosticNumericEligible)
  expect_identical(result$DiagnosticEligibilityMode, "complete_numeric")
  expect_true(result$InferenceReadyBeforeContract)
  expect_true(result$InferenceReadyAfterContract)
  expect_true(result$InferenceReadyPreserved)
  expect_identical(result$TerminalCodeAfterContract, "complete_numeric_eligible")
})

test_that("ConQuest diagnostic eligibility requires clean native completion", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  classify <- ctx$env$mfrmr_cq_adne_classify_attempt
  attempt <- g4n_attempt_fixture(engine = "ConQuest")
  eligible <- classify(attempt)

  expect_true(eligible$DiagnosticNumericEligible)
  expect_identical(eligible$DiagnosticEligibilityMode, "complete_numeric")
  expect_true(is.na(eligible$InferenceReadyAfterContract))

  for (field in c(
    "ParseableResult", "ModelIdentityMatch", "ArtifactSetComplete",
    "TerminalMarkerObserved"
  )) {
    mutated <- attempt
    mutated[[field]] <- FALSE
    expect_false(classify(mutated)$DiagnosticNumericEligible, info = field)
  }
  bad_exit <- attempt
  bad_exit$ExitStatus <- 1L
  expect_false(classify(bad_exit)$DiagnosticNumericEligible)
  bad_secondary <- attempt
  bad_secondary$SecondaryCode <- "unregistered_failure"
  expect_false(classify(bad_secondary)$DiagnosticNumericEligible)
})

test_that("the G4X state is categorically reachable without numeric reads", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  audit <- ctx$env$mfrmr_cq_adne_g4x_reachability_audit(ctx$output)
  mfrmr <- audit$Engine == "mfrmr"
  conquest <- audit$Engine == "ConQuest"

  expect_identical(nrow(audit), 30L)
  expect_identical(sum(mfrmr), 16L)
  expect_identical(sum(conquest), 14L)
  expect_true(all(audit$DiagnosticNumericEligible))
  expect_true(all(
    audit$DiagnosticEligibilityMode[mfrmr] == "diagnostic_rank_hold_only"
  ))
  expect_true(all(
    audit$DiagnosticEligibilityMode[conquest] == "complete_numeric"
  ))
  expect_true(all(!audit$InferenceReadyAfterContract[mfrmr]))
  expect_true(all(audit$TerminalCodePreserved))
  expect_false(any(audit$NumericValueInspected))
})

test_that("metric gates encode paired denominators and unconditional companions", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  registry <- ctx$env$mfrmr_cq_adne_metric_use_registry()
  gate <- ctx$env$mfrmr_cq_adne_metric_gate

  expect_identical(nrow(registry), 14L)
  expect_identical(
    sum(registry$UseClass == "conditional_exploratory_diagnostic_numeric"),
    7L
  )
  expect_true(all(registry$FailureRowsRetained))
  expect_false(any(registry$InferenceReadyMayFilterDiagnosticLane))
  expect_false(any(registry$InferenceReadyMayBeChanged))
  expect_false(any(registry$ExistingTerminalCodeMayBeChanged))
  expect_false(any(registry$ConfirmationUsePermitted))
  expect_false(any(registry$PublicClaimPermitted))

  expect_true(gate("ASP-PARAMETER-BIAS", engine_eligible = TRUE))
  expect_false(gate("ASP-PARAMETER-BIAS", engine_eligible = FALSE))
  expect_true(gate(
    "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
    engine_eligible = TRUE, peer_engine_eligible = TRUE,
    semantic_bridge_passed = TRUE
  ))
  expect_false(gate(
    "ASP-CROSS-ENGINE-COORDINATE-DIFFERENCE",
    engine_eligible = TRUE, peer_engine_eligible = FALSE,
    semantic_bridge_passed = TRUE
  ))
  expect_false(gate(
    "ASP-QUADRATURE-SENSITIVITY",
    q61_eligible = TRUE, q121_eligible = FALSE
  ))
  expect_true(gate(
    "ASP-REPRESENTATION-INVARIANCE",
    representation_primary_eligible = TRUE,
    representation_companion_eligible = TRUE,
    semantic_bridge_passed = TRUE
  ))
  expect_false(gate(
    "ASP-REPRESENTATION-INVARIANCE",
    representation_primary_eligible = TRUE,
    representation_companion_eligible = TRUE,
    semantic_bridge_passed = FALSE
  ))
  expect_true(gate("ASP-FALSE-READY-OR-FALSE-PASS"))
  expect_true(gate("ASP-ELAPSED-RUNTIME"))
})

test_that("G4N freezes the contract but does not authorize calibration", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  review <- ctx$env$mfrmr_cq_adne_review(ctx$output)

  expect_identical(
    review$status,
    paste0(
      "ASP_G4N_diagnostic_numeric_eligibility_frozen_",
      "calibration_authorization_required"
    )
  )
  expect_identical(review$g4x_mfrmr_diagnostic_numeric_reachable, 16L)
  expect_identical(review$g4x_conquest_diagnostic_numeric_reachable, 14L)
  expect_false(review$g4x_terminal_codes_relabelled)
  expect_false(review$g4x_inference_ready_states_changed)
  expect_false(review$calibration_numeric_values_inspected)
  expect_false(review$calibration_response_generation_authorized)
  expect_false(review$calibration_execution_authorized)
  expect_false(review$rerun_engine_mechanics_authorized)
  expect_false(review$confirmation_use_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
  expect_true(review$separate_calibration_authorization_required)
  expect_identical(
    review$next_action, "ASP-G4A-TRANCHE-A-AUTHORIZATION-REVIEW"
  )
  checklist <- review$addendum_checklist
  expect_true(all(checklist$Complete))
  expect_false(any(checklist$MayChangeInferenceReady))
  expect_false(any(checklist$MayChangeTerminalCode))
  expect_false(any(checklist$MayAuthorizeCalibrationGenerationAlone))
  expect_false(any(checklist$MayAuthorizeExecutionAlone))
})

test_that("G4N cannot read numeric outputs or launch an engine", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  source <- paste(readLines(ctx$paths[13L], warn = FALSE), collapse = "\n")

  expect_false(grepl("readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2?\\s*\\(", source, perl = TRUE))
  expect_false(grepl("read[.]csv.*(population|facets|steps)", source))
  expect_false(grepl("read[.]csv.*(parameters|amatrix|covariance)", source))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("G4N record and internal roadmap require a separate G4A gate", {
  ctx <- load_conquest_adversarial_simulation_diagnostic_numeric_eligibility()
  record <- paste(readLines(file.path(
    ctx$validation,
    paste0(
      "conquest-adversarial-simulation-diagnostic-numeric-eligibility-",
      "addendum-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_adne_specification, fixed = TRUE)
  expect_match(record, "`CalibrationExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`G4XMfrmrDiagnosticNumericReachable=16`", fixed = TRUE)
  expect_match(
    roadmap, "[x] Freeze the G4N diagnostic-numeric-eligibility addendum",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] Complete the G4A tranche-A authorization review",
    fixed = TRUE
  )
})
