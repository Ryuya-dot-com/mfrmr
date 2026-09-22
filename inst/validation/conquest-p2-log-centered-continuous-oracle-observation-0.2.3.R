# Repository-only observation of the P2 log-centered continuous-oracle audit.
#
# The frozen audit passed all thirteen truth fixtures. This file only retains
# those observations: it evaluates no likelihood, fits no model, reads no
# output, launches no executable, and cannot reclassify consumed candidates.

mfrmr_cq_p2coo_specification <-
  "0.2.3-conquest-p2-log-centered-continuous-oracle-observation-v1"
mfrmr_cq_p2coo_contract <-
  "mfrmr_conquest_p2_log_centered_continuous_oracle_observation_v1"

mfrmr_cq_p2coo_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2coo_require_contract <- function() {
  target <- environment(mfrmr_cq_p2coo_require_contract)
  ready <- exists(
    "mfrmr_cq_p2co_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2co_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_log_centered_continuous_oracle_v1"
  )
  mfrmr_cq_p2coo_assert(
    ready, "Source the exact log-centered continuous-oracle contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2coo_audit <- function() {
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
    Persons = rep(48L, 13L),
    Q121LogCenteredDevianceMovement = c(
      5.6843418860808015e-13, 5.6843418860808015e-13,
      1.0231815394945443e-12, 1.0231815394945443e-12,
      1.0072653822135180e-10, 2.9103830456733704e-11,
      5.6843418860808015e-13, 5.6843418860808015e-13,
      6.8212102632969618e-13, 5.6843418860808015e-13,
      6.8212102632969618e-13, 1.0231815394945443e-12,
      2.2737367544323206e-13
    ),
    Q241LogCenteredDevianceMovement = c(
      1.5916157281026244e-12, 7.9580786405131221e-13,
      2.0463630789890885e-12, 2.1600499167107046e-12,
      2.2737367544323206e-12, 1.5916157281026244e-12,
      1.5916157281026244e-12, 1.5916157281026244e-12,
      1.5916157281026244e-12, 1.5916157281026244e-12,
      1.4779288903810084e-12, 1.7053025658242404e-12,
      1.1368683772161603e-12
    ),
    LegacyLogCenteredDevianceMovement = c(
      0, 3.4106051316484809e-13, 5.0968083087354898e-09, 0,
      1.8984862890647491e-06, 2.1851335532119265e-06, 0, 0,
      2.2737367544323206e-13, 0, 0, 7.9580786405131221e-13,
      4.5474735088646412e-13
    ),
    DeclaredDevianceErrorBound = c(
      1.3752554033096695e-11, 1.3625709160196239e-11,
      1.1498927372701919e-11, 1.1520314442086660e-11,
      1.5494414563262416e-11, 1.2833556003313939e-11,
      1.3752554033096695e-11, 1.3752554033096695e-11,
      2.2212286109554548e-11, 1.3752554033096695e-11,
      1.3766373237632940e-11, 1.7442896944793299e-11,
      1.4149728706973101e-11
    ),
    ModesInterior = TRUE,
    LocalMaximumChecksPassed = TRUE,
    IntegrationsConverged = TRUE,
    Finite = TRUE,
    Candidate003Reclassified = FALSE,
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2coo_review <- function() {
  mfrmr_cq_p2coo_require_contract()
  audit <- mfrmr_cq_p2coo_audit()
  expected <- names(mfrmr_cq_p2_fixture_registry())
  qualification <- mfrmr_cq_p2co_qualify(audit, expected)
  legacy_pass <- audit$LegacyLogCenteredDevianceMovement <=
    mfrmr_cq_p2co_budget("Q121_LOG_CENTERED_CONTINUOUS_DEVIANCE")
  legacy_failure <- !legacy_pass
  retained <- isTRUE(qualification$passed) &&
    sum(legacy_failure) == 2L && identical(
      audit$RegistryRowId[legacy_failure],
      c("P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD")
    )
  list(
    specification = mfrmr_cq_p2coo_specification,
    contract_version = mfrmr_cq_p2coo_contract,
    status = if (retained) {
      "log_centered_continuous_oracle_qualified_for_future_p2_candidates"
    } else {
      "log_centered_continuous_oracle_observation_invalid"
    },
    audit = transform(
      audit,
      Q121LogCenteredPassed = Q121LogCenteredDevianceMovement <=
        mfrmr_cq_p2co_budget(
          "Q121_LOG_CENTERED_CONTINUOUS_DEVIANCE"
        ),
      Q241LogCenteredPassed = Q241LogCenteredDevianceMovement <=
        mfrmr_cq_p2co_budget(
          "Q241_LOG_CENTERED_CONTINUOUS_DEVIANCE"
        ),
      DeclaredErrorBoundPassed = DeclaredDevianceErrorBound <=
        mfrmr_cq_p2co_budget(
          "LOG_CENTERED_DECLARED_DEVIANCE_ERROR_BOUND"
        ),
      LegacyLogCenteredPassed = legacy_pass
    ),
    qualification = qualification,
    log_centered_continuous_oracle_qualified = retained,
    legacy_continuous_oracle_replaced_for_future_candidates = retained,
    legacy_reference_limitation_supported = retained,
    legacy_failure_mechanism_proven = FALSE,
    interval_certified_error_bound = FALSE,
    independent_software_validation_completed = FALSE,
    candidate_003_reclassified = FALSE,
    consumed_predecessor_reclassified = FALSE,
    candidate_004_generation_authorized = retained,
    candidate_004_fit_authorized = FALSE,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
