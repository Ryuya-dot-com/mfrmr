# P5 evidence/disposition ledger for the retained ConQuest 0.2.3 portfolio.
#
# This is a repository-only synthesis. It keeps the early six-arm lineage and
# the later P2 minimum-diagnostic lineage distinct, retains failed and unopened
# denominators, and authorizes no independent-review or public promotion.

mfrmr_cq_p5edl_specification <-
  "0.2.3-conquest-p5-evidence-disposition-ledger-v1"
mfrmr_cq_p5edl_contract <-
  "mfrmr_conquest_p5_evidence_disposition_ledger_v1"

mfrmr_cq_p5edl_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p5edl_runtime <- function() {
  data.frame(
    RuntimeId = "conquest-5.47.5-demo-x86_64-rosetta-20260815",
    Version = "5.47.5",
    Edition = "Demonstration Version",
    HostPlatform = "arm64 macOS",
    ExecutableArchitecture = "x86_64 Mach-O",
    InvocationRoute = "/usr/bin/arch -x86_64",
    ExpiryDate = "2026-09-01",
    RuntimeSemanticSentinelPassed = TRUE,
    RuntimePortableBeyondObservedPlatform = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p5edl_execution_ledger <- function() {
  data.frame(
    LineageId = c(
      "L0-additive-calibration", "L1-six-arm-candidate-002",
      "L1-six-arm-candidate-003", "L2-p2-minimum-candidate-001",
      "L2-p2-replacement-candidate-002",
      "L2-p2-minimum-candidate-003", "L2-p2-minimum-candidate-004"
    ),
    CandidateId = c(
      "conquest-additive-native-20260811",
      "mfrmr-0.2.3-conquest-six-arm-002",
      "mfrmr-0.2.3-conquest-six-arm-003",
      "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-001",
      "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-002",
      "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003",
      "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004"
    ),
    Design = c(
      "additive RSM/PCM q31/q61 complete crossing",
      "Binary/RSM/PCM q31/q61 command incident",
      "Binary/RSM/PCM q31/q61 bounded comparison",
      "additive RSM/PCM q31/q61 degenerate-signal fixture",
      "additive RSM/PCM replacement rejected at prefit support",
      "additive RSM/PCM q31/q61 integration-unresolved preflight",
      "additive RSM/PCM q61/q121 bounded comparison"
    ),
    CandidateArmCeiling = c(4L, 6L, 6L, 4L, 4L, 4L, 4L),
    AuthorizedConQuestArms = c(4L, 6L, 6L, 4L, 0L, 0L, 4L),
    AttemptedConQuestArms = c(4L, 1L, 6L, 1L, 0L, 0L, 4L),
    SemanticallyCompleteConQuestArms = c(4L, 0L, 6L, 0L, 0L, 0L, 4L),
    BoundedComparisonRowsExpected = c(0L, 0L, 57L, 0L, 0L, 0L, 886L),
    BoundedComparisonRowsPassingExpectedDisposition =
      c(0L, 0L, 57L, 0L, 0L, 0L, 886L),
    State = c(
      "calibration_complete_threshold_and_candidate_missing",
      "semantic_command_failure_remaining_arms_withheld",
      "bounded_reported_decimal_pass_no_promotion",
      "fixture_signal_failure_remaining_arms_withheld",
      "prefit_support_gate_rejection_no_fit",
      "internal_integration_gate_failure_no_external_run",
      "same_author_bounded_core_pass_independent_review_pending"
    ),
    IndependentReviewPassed = FALSE,
    RerunAuthorized = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p5edl_overlap_registry <- function() {
  data.frame(
    OverlapId = c(
      "O1-six-arm-binary", "O2-six-arm-additive-RSM",
      "O3-six-arm-additive-PCM", "O4-p2-candidate-004-RSM",
      "O5-p2-candidate-004-PCM"
    ),
    EvidenceLineage = c(
      rep("L1-six-arm-candidate-003", 3L),
      rep("L2-p2-minimum-candidate-004", 2L)
    ),
    Design = c(
      "item-only binary MML with one numeric covariate",
      "additive RSM MML with Rater and Criterion facets",
      "additive criterion-step PCM MML with Rater and Criterion facets",
      "48-Person connected-multibridge additive RSM with one covariate",
      "48-Person connected-multibridge additive PCM with one covariate"
    ),
    QuadraturePair = c("q31/q61", "q31/q61", "q31/q61", "q61/q121", "q61/q121"),
    ParameterClasses = c(
      "population intercept; population slope; population variance; item difficulty",
      "population intercept/slope/variance; Rater severity; Criterion difficulty; shared steps",
      "population intercept/slope/variance; Rater severity; Criterion difficulty; Criterion-specific steps",
      "population intercept/slope/variance; Rater severity; Criterion difficulty; shared steps",
      "population intercept/slope/variance; Rater severity; Criterion difficulty; Criterion-specific steps"
    ),
    DecisionClasses = c(
      rep("reported-decimal coordinates; matched-constant deviance; quadrature movement", 3L),
      rep("reported-decimal coordinates; matched-constant deviance; quadrature movement; conditional probabilities; facet ordering", 2L)
    ),
    ReviewState = c(
      rep("bounded_pass_independent_promotion_not_established", 3L),
      rep("same_author_bounded_pass_independent_review_pending", 2L)
    ),
    InferenceReady = FALSE,
    GeneralInterchangeabilityInferred = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p5edl_outcome_ledger <- function() {
  data.frame(
    OutcomeId = c(
      "D1-six-arm-command-incident", "D2-minimum-001-fixture-signal",
      "D3-replacement-002-prefit-support",
      "D4-minimum-003-integration-gate",
      "D5-candidate-004-q31-diagnostic", "D6-candidate-004-EAP",
      "D7-candidate-004-posterior-SD", "D8-candidate-004-readiness",
      "D9-candidate-004-global-identification",
      "D10-six-arm-binary-oracle-and-rank",
      "D11-P2-structural-negative-controls",
      "D12-candidate-004-reviewer-controls",
      "D13-independent-promotion-reviews", "D14-full-P2-portfolio"
    ),
    OutcomeClass = c(
      "failed", "failed", "failed", "integration_limited",
      "integration_limited", "ineligible", "ineligible", "unresolved",
      "unresolved", "unresolved", "negative_control_rejection",
      "negative_control", "unresolved", "unresolved"
    ),
    FixedDenominator = c(
      6L, 4L, 13L, 4L, 4L, 96L, 96L, 4L, 4L, 2L, 2L, 7L, 2L, 5073L
    ),
    ObservedOrClassified = c(
      6L, 4L, 13L, 4L, 4L, 96L, 96L, 4L, 4L, 2L, 2L, 7L, 0L, 0L
    ),
    ExpectedDispositionCount = c(
      6L, 4L, 13L, 4L, 4L, 96L, 96L, 4L, 4L, 2L, 2L, 7L, 0L, 0L
    ),
    Detail = c(
      "one semantic failure and five correctly withheld arms",
      "one failed ConQuest arm and three correctly withheld arms after four internal fits exposed near-zero variance",
      "twelve prefit gates passed and one full-cell-support gate rejected before fitting",
      "RSM/PCM coordinate and deviance q31-to-q61 gates all exceeded the frozen limit",
      "four q31-to-q61 coordinate/deviance checks remain diagnostic and above the limit",
      "all Person EAP rows retained as typed ineligible",
      "all posterior-SD rows retained as typed ineligible",
      "four selected fits retain review/not-inference-ready status",
      "global marginal and continuous-integral identification remain unclassified for four selected fits",
      "the six-arm Binary reference retains an absent independent oracle and absent local-rank claim",
      "unused-intermediate-category and disconnected fixtures retain expected typed rejection",
      "two semantic invariances accept and five mutation/missing-row classes reject",
      "independent promotion review is absent for both successful comparison lineages",
      "the separate eleven-fixture P2 portfolio denominator remains unopened"
    ),
    DropAllowed = FALSE,
    PublicPromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p5edl_public_disposition <- function() {
  data.frame(
    DecisionId = c(
      "P1-pure-R-handoff", "P2-candidate-004-bounded-comparison",
      "P3-six-arm-historical-comparison", "P4-hidden-solution-equality",
      "P5-person-posterior-equivalence", "P6-inference-readiness",
      "P7-GPCM-DFF-and-fit-statistics", "P8-full-P2-P3-portfolio",
      "P9-general-interchangeability", "P10-runtime-portability"
    ),
    Disposition = c(
      "supported", "deferred", "caveated", "disabled", "disabled",
      "disabled", "disabled", "deferred", "disabled", "caveated"
    ),
    PublicDecision = c(
      "retain the current optional pure-R bundle and normalization boundary",
      "no public promotion until the frozen independent review passes",
      "retain as versioned same-platform technical evidence only",
      "do not claim equality beyond exact reported decimal evidence",
      "do not compare EAP or posterior SD without a new posterior-identity contract",
      "do not use external agreement to clear mfrmr readiness holds",
      "do not extend RSM/PCM core evidence to GPCM, DFF, infit/outfit, extremes, or sparse designs",
      "defer wider execution until a retained decision requires it and its own gates pass",
      "explicitly prohibit claims that mfrmr and ConQuest are generally interchangeable",
      "name ConQuest 5.47.5 Demo on x86_64/Rosetta; do not infer other-platform behavior"
    ),
    PublicTextChangeAuthorizedByThisLedger = FALSE,
    IndependentReviewRequiredBeforePromotion = c(
      FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE
    ),
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p5edl_review <- function() {
  execution <- mfrmr_cq_p5edl_execution_ledger()
  overlap <- mfrmr_cq_p5edl_overlap_registry()
  outcomes <- mfrmr_cq_p5edl_outcome_ledger()
  public <- mfrmr_cq_p5edl_public_disposition()
  valid <-
    nrow(execution) == 7L && !anyDuplicated(execution$LineageId) &&
    nrow(overlap) == 5L && !anyDuplicated(overlap$OverlapId) &&
    nrow(outcomes) == 14L && !anyDuplicated(outcomes$OutcomeId) &&
    nrow(public) == 10L && !anyDuplicated(public$DecisionId) &&
    all(execution$AttemptedConQuestArms <= execution$AuthorizedConQuestArms) &&
    all(execution$SemanticallyCompleteConQuestArms <= execution$AttemptedConQuestArms) &&
    all(outcomes$ObservedOrClassified <= outcomes$FixedDenominator) &&
    !any(execution$IndependentReviewPassed) &&
    !any(execution$PublicPromotionAuthorized) &&
    !any(overlap$PublicPromotionAuthorized) &&
    !any(outcomes$DropAllowed) &&
    !any(public$PublicTextChangeAuthorizedByThisLedger)
  list(
    specification = mfrmr_cq_p5edl_specification,
    contract_version = mfrmr_cq_p5edl_contract,
    status = if (valid) {
      "conquest_P5_evidence_and_disposition_ledger_complete_promotion_blocked"
    } else {
      "conquest_P5_evidence_ledger_invalid"
    },
    runtime = mfrmr_cq_p5edl_runtime(),
    execution = execution,
    overlap = overlap,
    outcomes = outcomes,
    public_disposition = public,
    exact_overlap_stated = valid,
    adverse_and_unresolved_denominators_stated = valid,
    public_decisions_mapped = valid,
    independent_review_passed = FALSE,
    release_spine_update_authorized = FALSE,
    public_text_change_authorized = FALSE,
    general_software_interchangeability_inferred = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
