# 0.2.4 fixed-calibration G4 independent/operational evidence contract.
#
# This repository-only file freezes confirmation identities, complete
# denominators, numerical tolerances, portability cells, and resource budgets.
# It executes no fit, score, persistence operation, benchmark, or subprocess.

mfrmr_fc_g4_specification <-
  "0.2.4-fixed-calibration-g4-independent-operational-evidence-v1"
mfrmr_fc_g4_contract <- "mfrmr_fixed_calibration_g4_evidence_v1"

mfrmr_fc_g4_confirmation_design <- function() {
  data.frame(
    Family = c("RSM", "PCM"),
    CalibrationId = c(
      "fc-g4-confirmation-rsm-024-a",
      "fc-g4-confirmation-pcm-024-a"
    ),
    SourceFixtureId = c(
      "fc-g4-source-rsm-mod997-offset000",
      "fc-g4-source-pcm-mod997-offset000"
    ),
    ConfirmationFixtureId = c(
      "fc-g4-confirm-rsm-mod997-offset401",
      "fc-g4-confirm-pcm-mod997-offset401"
    ),
    SourcePersons = 48L,
    ConfirmationPersons = 7L,
    Raters = 4L,
    Criteria = 3L,
    Categories = 4L,
    QuadratureOrder = 9L,
    Generation = "closed-form logits plus fixed modular-997 uniforms; no R RNG",
    PreviouslyUsed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_numerical_rules <- function() {
  data.frame(
    RuleId = c(
      "PROBABILITY_ABSOLUTE", "POSTERIOR_ABSOLUTE",
      "METAMORPHIC_ABSOLUTE", "RANK_EXACT", "PLATFORM_SCORE_ABSOLUTE",
      "PRIOR_SENSITIVITY_REVIEW"
    ),
    Metric = c(
      "maximum absolute category-probability difference",
      "maximum absolute EAP/SD/interval difference",
      "maximum absolute EAP/SD/interval difference",
      "integer rank and explicit Jacobian entries",
      "maximum absolute EAP/SD/interval difference",
      "maximum absolute EAP change under N(0,0.7) or N(0,1.5)"
    ),
    Threshold = c(2e-14, 5e-14, 5e-14, 0, 1e-12, 0.20),
    Comparison = c(rep("less_than_or_equal", 5L), "review_if_greater_or_equal"),
    Denominator = c(
      "all 84 confirmation rows by 9 nodes by 4 categories in each family",
      "all 7 Persons and four returned numerical fields in each family",
      "all 7 Persons and four returned numerical fields per transformation",
      "all rows and columns in the frozen RSM and PCM step Jacobians",
      "all 7 Persons and four returned numerical fields per platform cell",
      "all 7 Persons in both independently evaluated alternative bases"
    ),
    RuleFrozenBeforeConfirmation = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_adversarial_denominator <- function() {
  data.frame(
    CellId = c(
      "RSM_PROBABILITY_ORACLE", "PCM_PROBABILITY_ORACLE",
      "RSM_POSTERIOR_ORACLE", "PCM_POSTERIOR_ORACLE",
      "RSM_STEP_RANK_ORACLE", "PCM_STEP_RANK_ORACLE",
      "SIGN_MUTATION_REFUSAL", "COHERENT_SIGN_METAMORPHIC",
      "EXTERNAL_SCORE_REVERSAL", "CATEGORY_MAP_MUTATION_REFUSAL",
      "NAMESPACE_RECODING", "ROW_ORDER", "PERSON_CHUNK_ORDER",
      "C_COLLATION", "UTF8_RDS_ROUNDTRIP", "FRESH_VANILLA_PROCESS",
      "PRIOR_MUTATION_REFUSAL", "PRIOR_SENSITIVITY_ORACLE",
      "CORRUPT_COORDINATE_LOAD_REFUSAL"
    ),
    Claim = c(
      rep("independent probability/posterior mathematics", 4L),
      rep("independent constraint/rank mathematics", 2L),
      rep("semantic mutation or metamorphic visibility", 5L),
      rep("operational reproducibility", 5L),
      rep("prior boundary", 2L),
      "persistence corruption refusal"
    ),
    Required = TRUE,
    ConfirmationResultOpened = FALSE,
    FailedCellPolicy = "retain_failed_cell_change_code_or_rule_then_issue_new_disjoint_identity",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_platform_matrix <- function() {
  data.frame(
    CellId = c(
      "macos-release", "windows-release", "ubuntu-devel",
      "ubuntu-release", "ubuntu-oldrel-1"
    ),
    OS = c("macOS", "Windows", rep("Linux", 3L)),
    R = c("release", "release", "devel", "release", "oldrel-1"),
    Workflow = ".github/workflows/R-CMD-check.yaml",
    EvidenceStatus = "pending_unrun_for_current_g4_payload",
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_resource_budgets <- function() {
  data.frame(
    Scale = c("small", "medium", "operational_plausible"),
    Persons = c(10L, 500L, 2500L),
    Rows = c(120L, 6000L, 30000L),
    MaxArtifactBytes = 1048576,
    MaxElapsedSeconds = c(2, 15, 60),
    MaxProfiledAllocationBytes = c(134217728, 536870912, 2147483648),
    MaxSerializedResultBytes = c(1048576, 16777216, 67108864),
    BudgetRole = "regression ceiling, not a speed or capacity promise",
    RuleFrozenBeforeMeasurement = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4_review <- function() {
  design <- mfrmr_fc_g4_confirmation_design()
  rules <- mfrmr_fc_g4_numerical_rules()
  denominator <- mfrmr_fc_g4_adversarial_denominator()
  platforms <- mfrmr_fc_g4_platform_matrix()
  resources <- mfrmr_fc_g4_resource_budgets()
  valid <-
    identical(design$Family, c("RSM", "PCM")) &&
    !anyDuplicated(design$CalibrationId) &&
    !any(design$PreviouslyUsed) &&
    identical(nrow(rules), 6L) && !anyDuplicated(rules$RuleId) &&
    all(rules$RuleFrozenBeforeConfirmation) &&
    identical(nrow(denominator), 19L) && !anyDuplicated(denominator$CellId) &&
    all(denominator$Required) && !any(denominator$ConfirmationResultOpened) &&
    identical(nrow(platforms), 5L) && !anyDuplicated(platforms$CellId) &&
    all(platforms$Required) &&
    identical(resources$Rows, c(120L, 6000L, 30000L)) &&
    all(resources$RuleFrozenBeforeMeasurement)
  list(
    specification = mfrmr_fc_g4_specification,
    contract_version = mfrmr_fc_g4_contract,
    status = if (valid) {
      "G4_rules_frozen_confirmation_unopened"
    } else {
      "G4_contract_invalid"
    },
    rules_frozen = isTRUE(valid),
    disjoint_identities_frozen = isTRUE(valid),
    denominator_frozen = isTRUE(valid),
    resource_budgets_frozen = isTRUE(valid),
    CORE_05_complete = FALSE,
    CORE_06_complete = FALSE,
    G4_exit_complete = FALSE,
    public_api_authorized = FALSE,
    optional_lane_authorized = FALSE
  )
}
