# 0.2.4 fixed-calibration G0 baseline and threat inventory.
#
# This repository-only contract inventories the fitted-object state consumed by
# the 0.2.3 unit-scoring path. It authorizes no calibration constructor,
# persistence format, operational scorer, optional-lane promotion, or release.

mfrmr_fc_g0_specification <-
  "0.2.4-fixed-calibration-g0-baseline-threat-inventory-v1"
mfrmr_fc_g0_contract <- "mfrmr_fixed_calibration_g0_contract_v1"

mfrmr_fc_g0_claim_ledger <- function() {
  data.frame(
    RequirementId = c(
      sprintf("GOV-%02d", 1:7),
      sprintf("CORE-%02d", 1:8),
      sprintf("OPT-%02d", 1:4),
      "H-024-01", "H-024-02", "H-025-01", "H-030-01", "H-100-01"
    ),
    Lane = c(
      rep("governance", 7), rep("core", 8),
      "estimated_population_mml", "bounded_gpcm_mml",
      "jml_reference_prior", "bounded_gpcm_jml",
      "0.2.4", "0.2.4", "0.2.5", "0.3.0", "1.0.0"
    ),
    Claim = c(
      "0.2.3 is the maintainer-declared published baseline for 0.2.4 sequencing.",
      "One reviewed single-scale calibration can be frozen and applied without silent semantic change.",
      "Source fitting, draft extraction, freezing, anchored refitting, and scoring remain distinct operations.",
      "The bounded RSM/PCM MML core and four optional promotion lanes are adjudicated separately.",
      "Claims require independent, falsifiable, negative, metamorphic, and disjoint evidence where applicable.",
      "Scope shrinks or is re-chartered before an acceptance rule is weakened.",
      "Every 0.2.4 requirement has a falsifier, evidence location, consequence, status, and fallback.",
      "A minimal artifact is sufficient without a source fit or training data.",
      "Calibration lifecycle and persistence are lossless and fail closed.",
      "Direct, group, shared-step, and owned-step anchors are typed and identified.",
      "Operational scoring is pure, reason-coded, and conditional on the declared basis.",
      "Independent mathematics and adversarial confirmation support the core.",
      "The core is reproducible across sessions, orderings, platforms, and supported R versions.",
      "Every public surface states the same support envelope.",
      "The final release decision follows the complete ledger and no-go audit.",
      "Estimated-population and latent-regression MML meet their added coding and transport contract.",
      "Bounded GPCM MML preserves population scale, slope ownership, and step ownership.",
      "JML scoring uses an explicit post-hoc prior and excludes source Person coordinates.",
      "Bounded GPCM JML passes both boundary and post-hoc-prior gates.",
      "0.2.4 ships direct one-scale semantics.",
      "0.2.4 records explicit calibration and schema identities.",
      "0.2.5 adds ScaleId by explicit migration rather than field overloading.",
      "0.3.0 consolidation uses observed adoption, migration, performance, and bug evidence.",
      "1.0 promotes only independently reviewed, multi-release support."
    ),
    Falsifier = c(
      "The maintainer withdraws the publication statement or the bound public payload is not version 0.2.3.",
      "A supported score changes because model coordinates, scale, or prior changed silently.",
      "One public operation silently performs or substitutes another.",
      "An optional lane inherits a core pass or blocks a smaller core without its own evidence.",
      "A claim closes using only shared production helpers, ordinary pass counts, or opened-rule tuning.",
      "A failed result weakens a gate without an explicit public re-charter.",
      "A requirement lacks any one required ledger field or has an ambiguous duplicate identity.",
      "Artifact-only fresh-process reconstruction needs source-fit or response-row state.",
      "Save/load, refusal, or lifecycle transition changes semantics or accepts an unknown state.",
      "Anchor order, namespace collision, or unidentified constraints change the fitted coordinate meaning.",
      "Scoring refits, substitutes a prior, silently drops invalid cases, or lacks dispositions.",
      "The oracle shares the evaluated helper or a disjoint adversarial fixture fails.",
      "A supported invariant exceeds its frozen numerical or resource budget.",
      "Code, documentation, metadata, runtime messages, or package contents disagree.",
      "Any earlier core gate or no-go row remains open at release decision time.",
      "Population coding, coefficients, variance, or transport caveat cannot be reconstructed.",
      "GPCM score probabilities change under saved slope/step/population coordinates.",
      "JML scoring uses an implicit prior or includes fitted Person coordinates in the calibration.",
      "Either the GPCM boundary gate or JML scoring-prior gate is open.",
      "Dormant multi-scale routing is required to interpret a 0.2.4 artifact.",
      "A later reader must guess calibration or schema identity.",
      "0.2.5 overloads a 0.2.4 field instead of migrating explicitly.",
      "0.3.0 freezes a schema without observed prior-release evidence.",
      "A historically callable but unreviewed route enters the 1.0 stable core."
    ),
    EvidencePath = c(
      "ROADMAP.md#current-position; publication payload identity pending in G0",
      "ROADMAP.md#release-question-and-current-gap",
      "ROADMAP.md#release-question-and-current-gap",
      "ROADMAP.md#minimum-public-scope-and-promotion-lanes",
      "ROADMAP.md#evidence-plan-and-independence-rules",
      "ROADMAP.md#no-go-conditions-and-scope-fallback",
      "inst/validation/fixed-calibration-g0-contract-0.2.4.R",
      "inst/validation/fixed-calibration-g1-lifecycle-record-0.2.4.md",
      "inst/validation/fixed-calibration-g1-lifecycle-record-0.2.4.md",
      "inst/validation/fixed-calibration-g2-anchor-record-0.2.4.md",
      "inst/validation/fixed-calibration-g3-scoring-record-0.2.4.md",
      "inst/validation/fixed-calibration-g4-evidence-record-0.2.4.md",
      "pending:G4 current-payload cross-platform reproducible-operation matrix",
      "pending:G6 public-surface agreement",
      "pending:G6 final release decision",
      "pending:G5 OPT-01 evidence", "pending:G5 OPT-02 evidence",
      "pending:G5 OPT-03 evidence", "pending:G5 OPT-04 evidence",
      "pending:G1/G6 one-scale schema evidence",
      "pending:G1/G6 identity and migration-refusal evidence",
      "pending:0.2.5 migration contract", "pending:0.3.0 evidence review",
      "pending:1.0 independent multi-release review"
    ),
    DecisionConsequence = c(
      "Selects the release baseline; does not by itself bind a distributed payload.",
      "Defines whether 0.2.4 may use the operational-calibration claim.",
      "Prevents fitted scoring, linking refits, and operational application from being conflated.",
      "Keeps optional failures from widening or weakening the core.",
      "Controls what can close a release checkbox.",
      "Controls fallback after negative evidence.",
      "Makes roadmap status auditable rather than narrative-only.",
      rep("Blocks CORE-08 until closed.", 8),
      rep("Controls only its optional public support row.", 4),
      "Constrains the 0.2.4 schema to its actual supported dimension.",
      "Makes future migration detectable and explicit.",
      "Constrains the 0.2.5 migration design.",
      "Constrains 0.3.0 stabilization timing.",
      "Constrains the 1.0 stable-core claim."
    ),
    Status = c(
      rep("complete_governance_decision", 6),
      "complete_ledger_created",
      "complete_g1", "complete_g1", "complete_g2", "complete_g3",
      "complete_g4_local", "open_g4_platform", rep("open", 2),
      rep("open_unpromoted", 4),
      rep("open", 2), rep("future_nonblocking", 3)
    ),
    Fallback = c(
      "Keep G0 open and describe 0.2.3 only as maintainer-declared until the public payload is bound.",
      "Do not use operational-calibration wording.",
      "Retain existing fitted-object and anchored-refit APIs as separately named analysis routes.",
      "Release only the independently closed core and label optional rows accurately.",
      "Leave the claim open and design independent evidence.",
      "Defer, block, or publicly re-charter before new confirmation.",
      "Keep GOV-07 and G0 open.",
      rep("Keep the corresponding core gate open; delay or re-charter before release.", 8),
      rep("Leave the optional lane unavailable, caveated, experimental, or blocked.", 4),
      "Remove premature multi-scale structure from 0.2.4.",
      "Keep compatibility unclaimed until identity is explicit.",
      "Defer multi-scale support rather than infer old meaning.",
      "Delay consolidation rather than freeze speculation.",
      "Keep the route outside the 1.0 stable core."
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g0_field_inventory <- function() {
  row <- function(id, source, role, owner, behavior, threat, disposition,
                  requirement, evidence) {
    data.frame(
      FieldId = id,
      CurrentSource = source,
      CurrentRole = role,
      ArtifactOwner = owner,
      CurrentBehavior = behavior,
      Threat = threat,
      G0Disposition = disposition,
      RequirementId = requirement,
      Evidence = evidence,
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, list(
    row("FIT_CLASS", "class(fit)", "dispatch guard", "not persisted",
        "Requires mfrm_fit.", "A class name is mistaken for semantic validity.",
        "replace_with_schema_validation", "CORE-01", "R/api-prediction.R:1179"),
    row("METHOD", "config$method_input|method|summary$Method", "method identity", "header$estimator",
        "Falls through three fields and maps JMLE to JML.", "Conflicting fields choose a plausible wrong method.",
        "require_one_canonical_value", "CORE-01", "R/api-prediction.R:989-1001"),
    row("MODEL", "config$model", "RSM/PCM/GPCM probability branch", "model$model",
        "Used directly by parameter expansion and posterior scoring.", "Wrong family can still return finite scores.",
        "must_store_and_validate", "CORE-01", "R/api-prediction.R:824-878"),
    row("FACET_NAMES", "config$facet_names", "facet order and namespace", "model$facets",
        "Required; no calibrated facets stops.", "Reordering changes parameter lookup.",
        "must_store_and_validate", "CORE-01", "R/api-prediction.R:457-482"),
    row("SOURCE_COLUMNS", "config$source_columns|prep$source_columns", "input-column defaults", "input_schema$source_columns",
        "Falls back to Person/Score and calibrated facet names.", "Convenience defaults are mistaken for model identity.",
        "store_as_nonsemantic_convenience", "CORE-04", "R/api-prediction.R:537-551"),
    row("SCORE_MAP", "prep$score_map", "original-to-internal category map", "response$score_map",
        "Falls back to an integer sequence from rating bounds.", "Compressed or reversed coding is silently reconstructed incorrectly.",
        "require_exact_map_no_fallback", "CORE-01", "R/api-prediction.R:627-640"),
    row("RATING_BOUNDS", "prep$rating_min|rating_max", "internal score origin and category count", "response$rating_bounds",
        "Used for score_k and fallback score map.", "A shifted origin changes every observed category index.",
        "must_store_and_cross_validate", "CORE-01", "R/api-prediction.R:627-670"),
    row("FACET_LEVELS", "prep$levels", "known non-Person level dictionaries", "model$facet_levels",
        "Unknown levels stop; factors use stored order.", "Same labels in a different order select wrong coordinates.",
        "must_store_and_validate", "CORE-01", "R/api-prediction.R:642-660"),
    row("KEEP_ORIGINAL", "prep$keep_original", "preparation metadata", "provenance$score_preparation",
        "Copied into temporary prep but not used in posterior mathematics.", "Nonessential fit state bloats the artifact.",
        "provenance_only", "CORE-01", "R/api-prediction.R:675"),
    row("STEP_FACET", "config$step_facet", "PCM/GPCM step owner", "model$step_owner",
        "Controls row step indices and parameter dimensions.", "Wrong owner returns plausible probabilities on wrong thresholds.",
        "must_store_and_validate", "CORE-03", "R/api-prediction.R:1212-1217"),
    row("SLOPE_FACET", "config$slope_facet", "GPCM slope owner", "model$slope_owner",
        "Controls row slope indices.", "Wrong owner changes discrimination assignment.",
        "optional_lane_required", "OPT-02", "R/api-prediction.R:1212-1217"),
    row("INTERACTION_SPECS", "config$interaction_specs", "interaction coordinates and cell indices", "model$interactions",
        "Carries facet names, level dimensions, and free-coordinate map.", "Omitted or reordered cells shift the linear predictor.",
        "must_store_if_active", "CORE-01", "R/core-data-prep.R:729-777"),
    row("N_CAT", "config$n_cat", "step dimension", "response$n_categories",
        "Controls RSM/PCM/GPCM expansion.", "Category dimension mismatch can mis-split raw parameters.",
        "must_store_and_cross_validate", "CORE-01", "R/mfrm_core.R:1215-1247"),
    row("THETA_SPEC", "config$theta_spec", "raw JML parameter-vector split", "excluded source-Person coordinates",
        "Needed only because current scoring re-expands fit$opt$par.", "Training Person coordinates leak into a calibration artifact.",
        "exclude_after_expansion", "OPT-03", "R/mfrm_core.R:1217-1220"),
    row("FACET_SPECS", "config$facet_specs", "constraint expansion", "constraints$facet_specs",
        "Expands raw free facet parameters under anchors/groups/centering.", "Constraint semantics disappear if only expanded values survive.",
        "store_semantics_and_expanded_values", "CORE-03", "R/mfrm_core.R:1290-1303"),
    row("CONFIG_FACET_LEVELS", "config$facet_levels", "step-owner level dimensions", "model$facet_levels",
        "Used separately from prep$levels during parameter expansion.", "Two level registries can drift.",
        "canonicalize_one_registry", "CORE-01", "R/mfrm_core.R:1305-1316"),
    row("GPCM_SPEC", "config$gpcm_spec", "sum-zero log-slope expansion", "model$gpcm_identification",
        "Expands relative positive slopes.", "Finite slopes can be attached to the wrong identification contract.",
        "optional_lane_required", "OPT-02", "R/mfrm_core.R:1320-1330"),
    row("FACET_SIGNS", "config$facet_signs", "linear-predictor orientation", "model$facet_signs",
        "Missing facet signs default to -1.", "A missing sign yields plausible mirrored or shifted scores.",
        "require_every_sign_no_fallback", "CORE-01", "R/mfrm_core.R:1362-1375"),
    row("RAW_PARAMETERS", "opt$par", "all fitted free coordinates", "parameters$expanded_named",
        "Re-split using current config and helper implementations.", "Parser or schema drift changes coordinates after save/load.",
        "replace_with_expanded_named_parameters", "CORE-01", "R/api-prediction.R:1218-1219"),
    row("QUAD_POINTS", "config$estimation_control$quad_points", "posterior grid size", "scoring_basis$quadrature",
        "Missing value defaults to 15 and nodes/weights are regenerated.", "A missing or changed algorithm silently changes scores.",
        "store_points_nodes_weights_no_fallback", "CORE-02", "R/api-prediction.R:1220-1221"),
    row("POSTERIOR_BASIS", "config$posterior_basis|population$posterior_basis", "prior/population branch", "scoring_basis$type",
        "Missing value defaults to legacy_mml.", "Implicit prior substitution remains numerically plausible.",
        "require_explicit_basis", "CORE-04", "R/api-prediction.R:727-733"),
    row("POPULATION_ACTIVE", "population$active|posterior_basis", "population-model activation", "scoring_basis$population$active",
        "Either flag can activate the branch.", "Conflicting activation fields select the wrong prior.",
        "require_one_canonical_value", "OPT-01", "R/api-prediction.R:722-734"),
    row("POPULATION_FORMULA", "population$formula|config$population_formula", "target design-matrix formula", "scoring_basis$population$formula",
        "Rebuilds scoring-time model matrix.", "Formula environment or coding drift changes person means.",
        "optional_lane_required", "OPT-01", "R/api-prediction.R:766-773"),
    row("POPULATION_CODING", "population$xlevels|contrasts|design_columns", "model-matrix identity", "scoring_basis$population$coding",
        "Reuses levels/contrasts and reorders equal column sets.", "Same column names can hide different contrast semantics.",
        "optional_lane_required", "OPT-01", "R/api-prediction.R:723-789"),
    row("POPULATION_PARAMETERS", "population$coefficients|sigma2", "conditional normal mean and variance", "scoring_basis$population$parameters",
        "Copied into scoring scaffold; sigma2 must be positive when used.", "Missing or stale values change the prior and posterior.",
        "optional_lane_required", "OPT-01", "R/api-prediction.R:792-795"),
    row("TRAINING_DESIGN_MATRIX", "config$population_spec$design_matrix", "raw parameter-vector dimension", "prohibited",
        "Current build_param_sizes reads the training-person design matrix to split fit$opt$par.", "Artifact sufficiency accidentally retains training-person state.",
        "prohibit_replace_with_expanded_parameters", "CORE-01", "R/mfrm_core.R:1249-1256"),
    row("READINESS", "fit$readiness|summary readiness fields", "source eligibility", "source_readiness",
        "The current unit scorer does not inspect readiness.", "A blocked or legacy fit can produce finite posterior scores.",
        "require_current_fit_and_parameter_gate", "CORE-04", "R/mfrm_core.R:75-141; R/api-prediction.R:1179-1229"),
    row("ANCHOR_DECLARATIONS", "config$facet_specs and anchor review", "source identification/provenance", "constraints$anchors",
        "Direct/group constraints are embedded in expansion specs; thresholds are unsupported.", "Expanded values alone cannot prove scale provenance.",
        "store_typed_declarations", "CORE-03", "R/core-anchor-audit.R:201-484")
  ))
}

mfrmr_fc_g0_behavior_inventory <- function() {
  data.frame(
    BehaviorId = c(
      "INVALID_ROW_DROP", "UNKNOWN_SCORE", "UNKNOWN_LEVEL", "DUPLICATE_EVENT",
      "READINESS_GATE", "QUADRATURE_FALLBACK", "POSTERIOR_FALLBACK",
      "JML_PRIOR", "ENDPOINT_STATUS", "QUADRATURE_EDGE_STATUS",
      "POPULATION_MISSING", "SCORE_MAP_COMPRESSION", "RNG_PRESERVATION",
      "ANCHOR_DUPLICATE", "ANCHOR_OVERLAP", "GROUP_VALUE_FALLBACK",
      "ANCHOR_EXPORT_ROUNDING", "ANCHORED_REFIT"
    ),
    CurrentBehavior = c(
      "Missing/non-numeric/non-positive rows are dropped with one warning; zero retained rows stop.",
      "Observed score outside score_map stops.",
      "Unknown non-Person facet level stops.",
      "No explicit exact-event duplicate check exists in unit scoring.",
      "Only class and MML/JML method are checked; source fit readiness is not consulted.",
      "Missing quad_points silently selects 15 and regenerates nodes/weights.",
      "Missing posterior basis silently selects legacy_mml.",
      "JML scoring uses a standard-normal reference prior selected by method branch and explained in notes.",
      "All-endpoint response patterns receive no dedicated returned status.",
      "Posterior mass near the outer quadrature nodes receives no dedicated returned status.",
      "Latent-regression missing covariates error by default or omit complete Persons under an explicit policy.",
      "Exact stored original-to-internal mappings are honored for compressed scores.",
      "Seeded draws preserve and restore the caller RNG state.",
      "Duplicate direct/group rows are reviewed, then the last row is retained.",
      "Direct anchors take precedence over overlapping group anchors.",
      "Missing/conflicting group values use zero or the most recent finite value.",
      "make_anchor_table rounds to six digits by default and omits steps/slopes/population coordinates.",
      "anchor_to_baseline exports facet anchors and performs a new fit; it is not pure scoring."
    ),
    TargetDisposition = c(
      "replace_with_explicit_policy_and_reason_codes", "retain_fail_closed",
      "retain_fail_closed", "add_strict_duplicate_contract",
      "add_current_fit_and_parameter_eligibility_gate", "remove_fallback",
      "remove_fallback", "store_explicit_prior_identity", "add_person_status",
      "add_person_status", "retain_only_in_OPT_01_with_full_disposition",
      "retain_and_cross_validate", "retain_and_test", "error_on_conflict_in_typed_route",
      "reject_ambiguous_overlap_in_typed_route", "error_in_typed_route",
      "keep_human_facing_never_canonical", "keep_separate_from_operational_scoring"
    ),
    RequirementId = c(
      "CORE-04", "CORE-04", "CORE-04", "CORE-04", "CORE-04", "CORE-02",
      "CORE-04", "OPT-03", "CORE-04", "CORE-04", "OPT-01", "CORE-01",
      "CORE-06", "CORE-03", "CORE-03", "CORE-03", "CORE-02", "GOV-03"
    ),
    BaselineEvidence = c(
      "R/api-prediction.R:574-622", "R/api-prediction.R:627-640",
      "R/api-prediction.R:642-656", "R/api-prediction.R:521-683",
      "R/api-prediction.R:1179-1229", "R/api-prediction.R:1220-1221",
      "R/api-prediction.R:727-733", "R/api-prediction.R:1243-1260",
      "R/api-prediction.R:888-940", "R/api-prediction.R:888-940",
      "R/api-prediction.R:736-817", "tests/testthat/test-prediction.R:524-552",
      "tests/testthat/test-prediction.R:177-184", "R/core-anchor-audit.R:127-132",
      "R/core-anchor-audit.R:121-122", "R/core-anchor-audit.R:124-133",
      "R/api-estimation.R:3977-4060", "R/api-advanced.R:3499-3657"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g0_support_matrix <- function() {
  data.frame(
    LaneId = c(
      "core_rsm_mml_fixed_normal", "core_pcm_mml_fixed_normal",
      "opt01_rsm_pcm_estimated_population", "opt02_gpcm_mml",
      "opt03_rsm_pcm_jml", "opt04_gpcm_jml"
    ),
    RequirementId = c("CORE-08", "CORE-08", "OPT-01", "OPT-02", "OPT-03", "OPT-04"),
    Model = c("RSM", "PCM", "RSM/PCM", "bounded GPCM", "RSM/PCM", "bounded GPCM"),
    Estimator = c("MML", "MML", "MML", "MML", "JML", "JML"),
    ScoringBasis = c(
      "fixed_standard_normal", "fixed_standard_normal",
      "estimated_conditional_normal", "estimated_or_legacy_identification",
      "explicit_post_hoc_prior_required", "explicit_post_hoc_prior_required"
    ),
    CurrentCallablePredecessor = TRUE,
    FrozenCalibrationPublicStatus = "not_available",
    ProvisionalDisposition = c(
      "core_candidate_unvalidated", "core_candidate_unvalidated",
      rep("optional_unpromoted", 4)
    ),
    EvidenceBudget = c(
      "G1-G4 and G6", "G1-G4 and G6", "G5 OPT-01", "G5 OPT-02",
      "G5 OPT-03", "G5 OPT-04 after OPT-02 and OPT-03 parent evidence"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g0_publication_baseline <- function() {
  data.frame(
    ObservationId = c(
      "maintainer_statement", "cran_package_page", "cran_source_tarball",
      "local_description", "local_head", "cran_local_common_files",
      "local_v0.2.3_tag", "github_latest_release", "r_universe_build"
    ),
    ObservedOn = "2026-08-22",
    ObservedValue = c(
      "0.2.3 published", "Version 0.2.3; Published 2026-08-21",
      paste0(
        "mfrmr_0.2.3.tar.gz; sha256 ",
        "3395df8ea7f9263b0b191bb9e95ff297c139355cdd25fa3da65f7c3e73fe640f; ",
        "md5 384f3e60d17d28c14814207b924b6f34"
      ),
      "Version 0.2.3; release-status candidate; public-version 0.2.2",
      "1dde9cb25f83683bd97e4ca0707901a41b1870ad",
      "no byte differences among common payload files after CRAN-generated files and DESCRIPTION normalization are separated",
      "absent", "v0.2.2", "0.2.1.9000 at 359003afa3"
    ),
    Evidence = c(
      "maintainer instruction in the 0.2.4 planning conversation",
      "https://cran.r-project.org/web/packages/mfrmr/index.html",
      "https://cran.r-project.org/src/contrib/mfrmr_0.2.3.tar.gz",
      "DESCRIPTION", "git log -1", "repository-to-tarball byte comparison",
      "git tag --list",
      "https://github.com/Ryuya-dot-com/mfrmr/releases",
      "https://ryuya-dot-com.r-universe.dev/mfrmr"
    ),
    Interpretation = c(
      "Authoritative for roadmap sequencing and confirmed by the live CRAN page.",
      "Binds the public version and publication date.",
      "Binds the exact public source payload independently of mutable indexes.",
      "Local metadata matches Version but retains stale candidate/public-version fields.",
      "Local source baseline commit.",
      "Binds local source behavior to the CRAN payload while separating packaging normalization.",
      "A missing GitHub tag does not invalidate the bound CRAN source artifact.",
      "GitHub Releases is a lagging secondary channel for this baseline.",
      "R-universe is a lagging secondary channel for this baseline."
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g0_review <- function() {
  claims <- mfrmr_fc_g0_claim_ledger()
  fields <- mfrmr_fc_g0_field_inventory()
  behaviors <- mfrmr_fc_g0_behavior_inventory()
  support <- mfrmr_fc_g0_support_matrix()
  publication <- mfrmr_fc_g0_publication_baseline()
  required_claim_ids <- c(
    sprintf("GOV-%02d", 1:7), sprintf("CORE-%02d", 1:8),
    sprintf("OPT-%02d", 1:4),
    "H-024-01", "H-024-02", "H-025-01", "H-030-01", "H-100-01"
  )
  valid <-
    identical(claims$RequirementId, required_claim_ids) &&
    !anyDuplicated(fields$FieldId) && !anyDuplicated(behaviors$BehaviorId) &&
    !anyDuplicated(support$LaneId) &&
    all(fields$RequirementId %in% claims$RequirementId) &&
    all(behaviors$RequirementId %in% claims$RequirementId) &&
    all(support$RequirementId %in% claims$RequirementId) &&
    all(nzchar(claims$Falsifier)) && all(nzchar(claims$EvidencePath)) &&
    all(nzchar(claims$DecisionConsequence)) && all(nzchar(claims$Fallback)) &&
    all(support$FrozenCalibrationPublicStatus == "not_available") &&
    any(publication$ObservationId == "cran_package_page" &
          grepl("Version 0.2.3", publication$ObservedValue, fixed = TRUE)) &&
    any(publication$ObservationId == "cran_source_tarball" &
          grepl("3395df8ea7f9263b0b191bb9e95ff297", publication$ObservedValue,
                fixed = TRUE)) &&
    any(publication$ObservationId == "cran_local_common_files" &
          grepl("no byte differences", publication$ObservedValue, fixed = TRUE))
  list(
    specification = mfrmr_fc_g0_specification,
    contract_version = mfrmr_fc_g0_contract,
    status = if (valid) {
      "G0_complete_cran_0.2.3_source_bound"
    } else {
      "G0_contract_invalid"
    },
    claim_ledger = claims,
    field_inventory = fields,
    behavior_inventory = behaviors,
    support_matrix = support,
    publication_baseline = publication,
    claim_ledger_complete = isTRUE(valid),
    field_inventory_complete = isTRUE(valid),
    support_matrix_provisional = isTRUE(valid),
    published_artifact_identity_bound = isTRUE(valid),
    local_candidate_content_bound = isTRUE(valid),
    G0_exit_complete = isTRUE(valid),
    fit_executed = FALSE,
    data_generated = FALSE,
    public_api_change_authorized = FALSE,
    public_promotion_authorized = FALSE,
    G1_implementation_authorized = isTRUE(valid)
  )
}
