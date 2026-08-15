# Repository-only observation of ConQuest P2 candidate-004 generation.
#
# This file retains the single frozen generation outcome. It generates no data,
# fits no model, reads no output, and launches no executable.

mfrmr_cq_p2c4o_specification <-
  "0.2.3-conquest-p2-candidate-004-fixture-observation-v1"
mfrmr_cq_p2c4o_contract <-
  "mfrmr_conquest_p2_candidate_004_fixture_observation_v1"

mfrmr_cq_p2c4o_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4o_require_contract <- function() {
  target <- environment(mfrmr_cq_p2c4o_require_contract)
  ready <- exists(
    "mfrmr_cq_p2c4_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2c4_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_candidate_004_coverage_conditioned_fixture_v1"
  )
  mfrmr_cq_p2c4o_assert(
    ready, "Source the exact candidate-004 generation contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4o_gate_observation <- function() {
  registry <- mfrmr_cq_p2r_gate_registry()
  observed <- c(
    48, 288, 1, 1, 15, 15, 0.30870595652027327,
    2.45833333333333393, 19.75, 17.33333333333334281, 0,
    0.89999999999999991, 0.71635412950874788
  )
  passed <- mapply(function(comparison, value, threshold) {
    switch(
      comparison,
      equal = identical(as.numeric(value), as.numeric(threshold)),
      exact = identical(as.numeric(value), as.numeric(threshold)),
      at_least = is.finite(value) && value >= threshold,
      FALSE
    )
  }, registry$Comparison, observed, registry$Threshold)
  transform(
    registry,
    Observed = as.numeric(observed),
    Passed = as.logical(passed),
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2c4o_conditioning_observation <- function() {
  data.frame(
    Cell = c(
      "R1::C1", "R2::C1", "R3::C1", "R4::C1",
      "R1::C2", "R2::C2", "R3::C2", "R4::C2",
      "R1::C3", "R2::C3", "R3::C3", "R4::C3"
    ),
    Persons = rep(24L, 12L),
    DrawAttempts = rep(1L, 12L),
    RejectedCompleteBlocks = rep(0L, 12L),
    Category0 = c(1L, 4L, 4L, 2L, 4L, 10L, 7L, 10L, 3L, 8L, 5L, 4L),
    Category1 = c(9L, 8L, 8L, 11L, 6L, 7L, 5L, 4L, 12L, 8L, 14L, 9L),
    Category2 = c(7L, 9L, 8L, 8L, 6L, 4L, 9L, 8L, 5L, 4L, 3L, 4L),
    Category3 = c(7L, 3L, 4L, 3L, 8L, 3L, 3L, 2L, 4L, 4L, 2L, 7L),
    CoverageSatisfied = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4o_review <- function() {
  mfrmr_cq_p2c4o_require_contract()
  gates <- mfrmr_cq_p2c4o_gate_observation()
  conditioning <- mfrmr_cq_p2c4o_conditioning_observation()
  gate_identity <- identical(
    gates[, names(mfrmr_cq_p2r_gate_registry()), drop = FALSE],
    mfrmr_cq_p2r_gate_registry()
  )
  conditioning_ready <- nrow(conditioning) == 12L &&
    all(conditioning$Persons == 24L) &&
    all(conditioning$DrawAttempts >= 1L) &&
    all(conditioning$DrawAttempts <= mfrmr_cq_p2c4_maximum_cell_draws) &&
    all(conditioning$CoverageSatisfied) &&
    all(rowSums(conditioning[, paste0("Category", 0:3)]) == 24L) &&
    sum(conditioning[, paste0("Category", 0:3)]) == 288L
  all_thirteen_passed <- nrow(gates) == 13L && all(gates$Passed)
  lineage_ready <- !identical(
    mfrmr_cq_p2c4_candidate_id, mfrmr_cq_p2c3_candidate_id
  ) && !identical(mfrmr_cq_p2c4_seed, mfrmr_cq_p2c3_seed)
  retained <- gate_identity && conditioning_ready && all_thirteen_passed &&
    lineage_ready
  list(
    specification = mfrmr_cq_p2c4o_specification,
    contract_version = mfrmr_cq_p2c4o_contract,
    status = if (retained) {
      "candidate_004_prefit_fixture_ready_mfrmr_preflight_contract_required"
    } else {
      "candidate_004_rejected_before_fit"
    },
    gate_results = gates,
    conditioning = conditioning,
    frozen_candidate_002_gate_identity_retained = gate_identity,
    coverage_conditioning_ready = conditioning_ready,
    all_thirteen_prefit_gates_passed = all_thirteen_passed,
    disjoint_candidate_003_identity_seed_and_data = retained,
    seed_search_performed = FALSE,
    response_repair_performed = FALSE,
    truth_recovery_authorized = FALSE,
    mfrmr_fit_preflight_contract_authorized = retained,
    mfrmr_fit_authorized = FALSE,
    candidate_003_reclassified = FALSE,
    external_execution_authorized = FALSE,
    fresh_runtime_and_minimum_audit_required = TRUE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
