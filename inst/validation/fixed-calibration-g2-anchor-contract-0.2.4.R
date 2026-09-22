# 0.2.4 fixed-calibration G2 typed-anchor and identification contract.
#
# This repository-only object freezes namespace, selector, conflict, and rank
# semantics. It neither adds a public argument nor authorizes optional lanes.

mfrmr_fc_g2_contract_id <-
  "0.2.4-fixed-calibration-g2-typed-anchor-identification-v1"

mfrmr_fc_g2_namespaces <- function() {
  data.frame(
    Namespace = c(
      "facet_direct", "facet_group", "shared_step", "owned_step",
      "relative_slope", "population"
    ),
    AnchorType = c(
      "direct", "group", "shared_step", "owned_step", NA, NA
    ),
    ParameterClass = c(
      "facet", "facet", "shared_step", "owned_step",
      "relative_slope", "population"
    ),
    Selector = c(
      "OwnerFacet+Level",
      "OwnerFacet+GroupId with explicit Level membership",
      "Step",
      "OwnerFacet+Level+Step",
      "OwnerFacet+Level",
      "PopulationCoordinate"
    ),
    CoordinateSystem = c(
      rep("expanded_logit", 4), "identified_log_slope", "population_native"
    ),
    Core024Status = c(
      rep("implemented_internal", 4), "reserved_optional_not_accepted",
      "reserved_optional_not_accepted"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g2_selector_rules <- function() {
  data.frame(
    AnchorType = c("direct", "group", "shared_step", "owned_step"),
    Family = c("RSM|PCM", "RSM|PCM", "RSM", "PCM"),
    OwnerFacet = c("required", "required", "typed_NA", "exact_step_owner"),
    Level = c("required_owner_level", "required_group_member", "typed_NA",
              "required_owner_level"),
    Step = c("typed_NA", "typed_NA", "canonical_transition_index",
             "canonical_transition_index"),
    GroupId = c("typed_NA", "required", "typed_NA", "typed_NA"),
    Value = "one_finite_full_precision_number",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g2_conflict_rules <- function() {
  data.frame(
    Case = c(
      "identical_selector_identical_value",
      "identical_selector_different_value",
      "group_member_multiple_groups",
      "group_target_multiple_values",
      "direct_member_of_group",
      "wrong_namespace_or_owner",
      "wrong_coordinate_system"
    ),
    Disposition = c(
      "deduplicate_and_record_note",
      "error_ANCHOR_CONFLICT",
      "error_ANCHOR_CONFLICT",
      "error_ANCHOR_CONFLICT",
      "jointly_check_constraint_feasibility",
      "error_before_optimization",
      "error_ANCHOR_COORDINATE_SYSTEM_INVALID"
    ),
    OrderInvariant = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g2_step_rank_rule <- function() {
  data.frame(
    Scope = c("RSM shared ladder", "each PCM owner-level ladder"),
    ExpandedDimension = "K-1 transitions",
    FixedCount = "a",
    RemainingCount = "u=(K-1)-a",
    FreeDimension = "max(u-1,0)",
    DerivedCoordinate = "last unanchored transition in canonical score-map order",
    Constraint = "sum(expanded transitions)=0",
    FullFixRule = "all fixed values must sum to zero",
    RankGate = "expansion Jacobian column rank equals FreeDimension",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g2_reduction_matrix <- function() {
  data.frame(
    Fixture = c(
      "empty_typed_spec", "fully_fixed_coordinates", "partial_shared_step",
      "partial_owned_step", "declaration_reversal", "duplicate_mutation",
      "missing_or_unused_category", "wrong_owner", "reversed_score_map"
    ),
    RequiredResult = c(
      "exact existing unanchored parameterization",
      "same expanded coordinates and response probabilities",
      "free dimension max(u-1,0) and full-rank Jacobian",
      "per-owner free dimension max(u-1,0) and full-rank Jacobian",
      "identical canonical declarations and constraints",
      "identical deduplicates with note; conflicting value refuses",
      "declared transitions retained; fixed transitions are not estimated",
      "refuse before parameter sizing or optimization",
      "transition indices follow internal score-map order without relabeling"
    ),
    RequirementId = "CORE-03",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g2_review <- function() {
  list(
    status = "G2_complete_internal_public_gate_closed",
    namespace_contract_complete = TRUE,
    strict_conflict_route_complete = TRUE,
    shared_step_anchor_complete = TRUE,
    owned_step_anchor_complete = TRUE,
    reduction_matrix_complete = TRUE,
    rank_gate_complete = TRUE,
    CORE_03_complete = TRUE,
    public_api_authorized = FALSE,
    optional_slope_anchor_authorized = FALSE,
    optional_population_anchor_authorized = FALSE
  )
}
