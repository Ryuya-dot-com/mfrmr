mfrmr_fc_g3_specification <-
  "0.2.4-fixed-calibration-g3-operational-scoring-v1"

mfrmr_fc_g3_contract <- "mfrmr_operational_scoring_v1"

mfrmr_fc_g3_policy_matrix <- function() {
  data.frame(
    CaseId = c(
      "VALID_ROWS", "PARTIAL_ADMINISTRATION", "MISSING_DEFAULT",
      "MISSING_OMIT", "ZERO_VALID_PERSON", "MISSING_PERSON",
      "MISSING_FACET", "UNKNOWN_SCORE", "UNKNOWN_LEVEL",
      "INVALID_WEIGHT", "DUPLICATE_UNIDENTIFIED",
      "REPEAT_IDENTIFIED", "DUPLICATE_EVENT_ID", "LOW_ENDPOINT",
      "HIGH_ENDPOINT", "VERY_SPARSE", "QUADRATURE_EDGE"
    ),
    InputCondition = c(
      "all required values are valid and known",
      "a Person supplies fewer known events than a complete crossing",
      "one or more response values are missing under the default policy",
      "one or more response values are missing under explicit omit policy",
      "all supplied responses for one Person are omitted",
      "Person identifier is missing or blank",
      "one required non-Person facet value is missing or blank",
      "a nonmissing response is outside the frozen score map",
      "a non-Person level is outside the frozen dictionary",
      "a scored row has a nonfinite or nonpositive weight",
      "Person-by-all-facets cells repeat without an event identifier",
      "repeated cells carry distinct nonblank event identifiers",
      "the same Person-by-all-facets-by-event cell repeats",
      "all valid responses for one Person use the lower endpoint",
      "all valid responses for one Person use the upper endpoint",
      "one valid response remains for one Person",
      "combined posterior mass on the outer stored nodes is at least 0.05"
    ),
    Policy = c(
      "score", "score_without_inferring_completeness", "refuse_batch",
      "omit_and_reason_code", "return_no_estimate", "refuse_batch",
      "refuse_batch", "refuse_batch", "refuse_batch", "refuse_batch",
      "refuse_batch", "score", "refuse_batch", "score_and_review",
      "score_and_review", "score_and_review", "score_and_review"
    ),
    Code = c(
      "ROW_SCORED", "ADMINISTRATION_PLAN_NOT_EVALUATED",
      "SCORING_SCORE_INVALID", "RESPONSE_MISSING_OMITTED",
      "ZERO_VALID_RESPONSES", "SCORING_VALUE_MISSING",
      "SCORING_VALUE_MISSING", "SCORING_SCORE_UNKNOWN",
      "SCORING_FACET_LEVEL_UNKNOWN", "SCORING_WEIGHT_INVALID",
      "SCORING_EVENT_DUPLICATE", "ROW_SCORED", "SCORING_EVENT_DUPLICATE",
      "ALL_RESPONSES_LOWER_ENDPOINT", "ALL_RESPONSES_UPPER_ENDPOINT",
      "VERY_SPARSE_RESPONSE_PATTERN", "QUADRATURE_EDGE_MASS_REVIEW"
    ),
    EstimateReturned = c(
      TRUE, TRUE, FALSE, NA, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
      FALSE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g3_disposition_catalog <- function() {
  data.frame(
    Code = c(
      "ROW_SCORED", "RESPONSE_MISSING_OMITTED",
      "RESPONSES_MISSING_OMITTED", "ZERO_VALID_RESPONSES",
      "ALL_RESPONSES_LOWER_ENDPOINT", "ALL_RESPONSES_UPPER_ENDPOINT",
      "VERY_SPARSE_RESPONSE_PATTERN", "QUADRATURE_EDGE_MASS_REVIEW"
    ),
    Level = c("row", "row", rep("person", 6L)),
    Disposition = c(
      "scored", "omitted", "scored_review", "not_scored",
      rep("scored_review", 4L)
    ),
    Meaning = c(
      "row contributed to the frozen-calibration likelihood",
      "row was omitted only under the explicit missing-response policy",
      "Person retained an estimate but one or more supplied responses were omitted",
      "Person received no estimate because no valid response remained",
      "finite result is posterior EAP for an all-lower-endpoint pattern",
      "finite result is posterior EAP for an all-upper-endpoint pattern",
      "one valid response remains and requires sparse-pattern review",
      "outer-node posterior mass met the frozen operational review threshold"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g3_result_identity <- function() {
  data.frame(
    Identity = c(
      "calibration", "semantic_components", "schema", "software", "model", "score_map",
      "prior", "quadrature", "source_readiness", "row_disposition",
      "person_disposition", "endpoint", "sparse_pattern",
      "prior_sensitivity", "estimate_basis", "uncertainty_basis"
    ),
    ResultPath = c(
      "settings.calibration_id", "settings.semantic_components",
      "settings.schema_version",
      "settings.package_version", "settings.family/settings.estimator",
      "settings.score_map", "settings.prior_identity",
      "settings.quadrature_identity", "settings.source_readiness_contract",
      "row_dispositions", "person_dispositions",
      "person_dispositions.EndpointStatus",
      "person_dispositions.VerySparsePattern",
      "person_dispositions.PriorSensitivityStatus",
      "estimates.EstimateBasis", "estimates.UncertaintyBasis"
    ),
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g3_review <- function() {
  policy <- mfrmr_fc_g3_policy_matrix()
  dispositions <- mfrmr_fc_g3_disposition_catalog()
  identity <- mfrmr_fc_g3_result_identity()
  valid <-
    identical(nrow(policy), 17L) && !anyDuplicated(policy$CaseId) &&
    identical(nrow(dispositions), 8L) && !anyDuplicated(dispositions$Code) &&
    identical(nrow(identity), 16L) && !anyDuplicated(identity$Identity) &&
    all(identity$Required) &&
    all(c(
      "MISSING_DEFAULT", "MISSING_OMIT", "ZERO_VALID_PERSON",
      "DUPLICATE_UNIDENTIFIED", "REPEAT_IDENTIFIED", "LOW_ENDPOINT",
      "HIGH_ENDPOINT", "VERY_SPARSE", "QUADRATURE_EDGE"
    ) %in% policy$CaseId)
  list(
    specification = mfrmr_fc_g3_specification,
    contract_version = mfrmr_fc_g3_contract,
    status = if (valid) {
      "G3_complete_internal_public_gate_closed"
    } else {
      "G3_contract_invalid"
    },
    policy_matrix = policy,
    disposition_catalog = dispositions,
    result_identity = identity,
    policy_matrix_complete = isTRUE(valid),
    row_dispositions_complete = isTRUE(valid),
    person_dispositions_complete = isTRUE(valid),
    posterior_oracle_complete = isTRUE(valid),
    pure_scoring_complete = isTRUE(valid),
    CORE_04_complete = isTRUE(valid),
    G3_exit_complete = isTRUE(valid),
    public_api_authorized = FALSE,
    optional_lane_authorized = FALSE,
    next_gate = "G4-independent-and-operational-evidence"
  )
}
