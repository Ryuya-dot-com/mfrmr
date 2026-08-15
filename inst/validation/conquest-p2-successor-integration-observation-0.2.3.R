# Repository-only observation of the first P2 successor integration audit.
#
# This file preserves all thirteen truth-oracle outcomes. It does not rerun an
# oracle, fit a model, read candidate output, change a threshold, or authorize
# candidate generation.

mfrmr_cq_p2sio_specification <-
  "0.2.3-conquest-p2-successor-integration-observation-v1"
mfrmr_cq_p2sio_contract <-
  "mfrmr_conquest_p2_successor_integration_observation_v1"

mfrmr_cq_p2sio_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2sio_require_contract <- function() {
  target <- environment(mfrmr_cq_p2sio_require_contract)
  ready <- exists(
    "mfrmr_cq_p2si_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2si_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_successor_integration_contract_v1"
  )
  mfrmr_cq_p2sio_assert(
    ready, "Source the exact first successor integration contract."
  )
  invisible(TRUE)
}

mfrmr_cq_p2sio_audit <- function() {
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
    Persons = 48L,
    Q31Q61DevianceMovement = c(
      2.601003e-06, 3.721626e-06, 8.891737e-06, 4.325170e-06,
      1.082666e-02, 9.074817e-03, 2.601003e-06, 2.601003e-06,
      5.548592e-05, 2.601003e-06, 9.310051e-06, 2.837183e-06,
      8.550894e-06
    ),
    Q61Q121DevianceMovement = c(
      4.243930e-10, 5.138645e-10, 3.419586e-09, 1.207468e-09,
      1.507427e-05, 7.395970e-06, 4.243930e-10, 4.243930e-10,
      3.058176e-11, 4.243930e-10, 5.144329e-10, 4.773710e-10,
      6.379992e-09
    ),
    Q121ContinuousDevianceMovement = c(
      5.684342e-13, 9.094947e-13, 5.097831e-09, 1.023182e-12,
      1.898386e-06, 2.185104e-06, 5.684342e-13, 5.684342e-13,
      9.094947e-13, 5.684342e-13, 6.821210e-13, 1.818989e-12,
      2.273737e-13
    ),
    ContinuousIntegrationAbsoluteErrorEstimate = c(
      9.386995e-10, 1.025134e-09, 8.509242e-10, 9.278510e-10,
      8.291663e-10, 1.060761e-09, 9.386995e-10, 9.386995e-10,
      1.579788e-09, 9.386995e-10, 9.576572e-10, 1.031587e-09,
      4.482015e-10
    ),
    Finite = TRUE,
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2sio_review <- function() {
  mfrmr_cq_p2sio_require_contract()
  audit <- mfrmr_cq_p2sio_audit()
  q_final_pass <- audit$Q61Q121DevianceMovement <=
    mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE")
  continuous_pass <- audit$Q121ContinuousDevianceMovement <=
    mfrmr_cq_p2si_budget("P2S-Q121-CONTINUOUS-DEVIANCE")
  failure <- !q_final_pass | !continuous_pass
  retained <- nrow(audit) == 13L && all(audit$Finite) &&
    identical(
      audit$RegistryRowId[failure],
      c("P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD")
    ) && sum(!q_final_pass) == 2L && sum(!continuous_pass) == 2L
  list(
    specification = mfrmr_cq_p2sio_specification,
    contract_version = mfrmr_cq_p2sio_contract,
    status = if (retained) {
      "fixed_q121_successor_rejected_unequal_workload_integration_unresolved"
    } else {
      "successor_integration_observation_invalid"
    },
    audit = transform(
      audit,
      Q61Q121Passed = q_final_pass,
      Q121ContinuousPassed = continuous_pass,
      Passed = q_final_pass & continuous_pass
    ),
    failed_registry_rows = audit$RegistryRowId[failure],
    fixed_q121_contract_consumed = retained,
    fixed_q121_contract_passed = FALSE,
    candidate_003_reclassified = FALSE,
    candidate_004_generation_authorized = FALSE,
    fixed_threshold_change_authorized = FALSE,
    design_adaptive_density_contract_required = retained,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
