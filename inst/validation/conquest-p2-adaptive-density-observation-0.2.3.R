# Repository-only observation of the bounded adaptive-density truth audit.
#
# q121 -> q241 converged under the frozen finite-grid budget, while the same
# unequal-workload rows retained their q241 -> legacy-continuous discrepancy.
# This file reruns nothing and authorizes neither more nodes nor a candidate.

mfrmr_cq_p2ado_specification <-
  "0.2.3-conquest-p2-bounded-adaptive-density-observation-v1"
mfrmr_cq_p2ado_contract <-
  "mfrmr_conquest_p2_bounded_adaptive_density_observation_v1"

mfrmr_cq_p2ado_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2ado_require_contract <- function() {
  target <- environment(mfrmr_cq_p2ado_require_contract)
  ready <- exists(
    "mfrmr_cq_p2ad_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2ad_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_bounded_adaptive_density_contract_v1"
  )
  mfrmr_cq_p2ado_assert(
    ready, "Source the exact bounded adaptive-density contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2ado_audit <- function() {
  data.frame(
    RegistryRowId = c(
      "P2-RSM-CONNECTED-MULTIBRIDGE",
      "P2-PCM-CONNECTED-MULTIBRIDGE",
      "P2-RSM-WEAK-SINGLE-BRIDGE",
      "P2-PCM-WEAK-SINGLE-BRIDGE",
      "P2-RSM-UNEQUAL-WORKLOAD",
      "P2-PCM-UNEQUAL-WORKLOAD",
      "P2-RSM-PLANNED-MISSING-ROWS",
      "P2-RSM-EXPLICIT-MISSING-VALUES",
      "P2-PCM-RARE-BOUNDARY-CATEGORIES",
      "P2-RSM-NONEXTREME-PERSON",
      "P2-RSM-EXTREME-PERSON",
      "P2-NEG-UNUSED-INTERMEDIATE-CATEGORY",
      "P2-NEG-DISCONNECTED-DESIGN"
    ),
    Model = c(
      "RSM", "PCM", "RSM", "PCM", "RSM", "PCM", "RSM", "RSM",
      "PCM", "RSM", "RSM", "PCM", "RSM"
    ),
    Q121Q241DevianceMovement = c(
      1.023182e-12, 2.273737e-13, 1.023182e-12, 1.136868e-12,
      9.845280e-11, 2.751221e-11, 1.023182e-12, 1.023182e-12,
      9.094947e-13, 1.023182e-12, 7.958079e-13, 6.821210e-13,
      9.094947e-13
    ),
    Q241LegacyContinuousDevianceMovement = c(
      1.591616e-12, 1.136868e-12, 5.098855e-09, 2.160050e-12,
      1.898484e-06, 2.185132e-06, 1.591616e-12, 1.591616e-12,
      1.818989e-12, 1.591616e-12, 1.477929e-12, 2.501110e-12,
      6.821210e-13
    ),
    Finite = TRUE,
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2ado_review <- function() {
  mfrmr_cq_p2ado_require_contract()
  audit <- mfrmr_cq_p2ado_audit()
  finite_pass <- audit$Q121Q241DevianceMovement <=
    mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE")
  continuous_pass <- audit$Q241LegacyContinuousDevianceMovement <=
    mfrmr_cq_p2si_budget("P2S-Q121-CONTINUOUS-DEVIANCE")
  continuous_failure <- !continuous_pass
  retained <- nrow(audit) == 13L && all(audit$Finite) &&
    all(finite_pass) && sum(continuous_failure) == 2L &&
    identical(
      audit$RegistryRowId[continuous_failure],
      c("P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD")
    )
  list(
    specification = mfrmr_cq_p2ado_specification,
    contract_version = mfrmr_cq_p2ado_contract,
    status = if (retained) {
      "q241_ceiling_reached_continuous_reference_unresolved"
    } else {
      "bounded_adaptive_density_observation_invalid"
    },
    audit = transform(
      audit,
      Q121Q241Passed = finite_pass,
      Q241LegacyContinuousPassed = continuous_pass,
      Passed = finite_pass & continuous_pass
    ),
    finite_grid_convergence_passed_all_rows = retained,
    continuous_reference_failed_registry_rows =
      audit$RegistryRowId[continuous_failure],
    q241_ceiling_consumed = retained,
    further_node_expansion_authorized = FALSE,
    fixed_threshold_change_authorized = FALSE,
    legacy_continuous_oracle_qualified = FALSE,
    log_centered_continuous_oracle_qualification_required = retained,
    candidate_003_reclassified = FALSE,
    candidate_004_generation_authorized = FALSE,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
