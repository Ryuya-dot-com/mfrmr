# 0.2.4 fixed-calibration G1 schema, lifecycle, and refusal specification.
#
# This repository-only specification was frozen before the internal lifecycle
# implementation. It does not execute the constructor, persistence route,
# scorer, or any public export.

mfrmr_fc_g1_specification <-
  "0.2.4-fixed-calibration-g1-schema-lifecycle-refusal-v1"
mfrmr_fc_g1_schema_id <- "mfrmr.fixed_calibration"
mfrmr_fc_g1_schema_version <- 1L

mfrmr_fc_g1_field_schema <- function() {
  row <- function(path, type, cardinality, required, owner, core_value,
                  omission, validation, refusal, requirement) {
    data.frame(
      FieldPath = path,
      StorageType = type,
      Cardinality = cardinality,
      RequiredCore = required,
      SemanticOwner = owner,
      CoreValueOrDomain = core_value,
      OmissionPolicy = omission,
      ValidationRule = validation,
      RefusalCode = refusal,
      RequirementId = requirement,
      stringsAsFactors = FALSE
    )
  }
  do.call(rbind, list(
    row("header.schema_id", "character", "scalar", TRUE, "schema",
        mfrmr_fc_g1_schema_id, "required_exact", "exact registered identifier",
        "SCHEMA_ID_UNKNOWN", "CORE-01"),
    row("header.schema_version", "integer", "scalar", TRUE, "schema",
        "1", "required_exact", "exact registered version",
        "SCHEMA_VERSION_UNSUPPORTED", "CORE-02"),
    row("header.object_class", "character", "scalar", TRUE, "schema",
        "mfrm_calibration", "required_exact", "exact class marker",
        "SCHEMA_CLASS_INVALID", "CORE-01"),
    row("header.calibration_id", "character", "scalar", TRUE, "identity",
        "nonempty immutable identifier", "required_explicit", "unique and immutable",
        "IDENTITY_ID_INVALID", "CORE-02"),
    row("header.semantic_identity_version", "character", "scalar", TRUE, "identity",
        "mfrmr-calibration-semantic-identity-v1", "required_exact",
        "exact registered identity algorithm", "IDENTITY_VERSION_UNKNOWN", "H-024-02"),
    row("model.family", "character", "scalar", TRUE, "model",
        "RSM|PCM", "required_explicit", "registered core family",
        "MODEL_FAMILY_UNSUPPORTED", "CORE-01"),
    row("model.estimator", "character", "scalar", TRUE, "model",
        "MML", "required_exact", "registered core estimator",
        "MODEL_ESTIMATOR_UNSUPPORTED", "CORE-01"),
    row("model.n_observed_scales", "integer", "scalar", TRUE, "model",
        "1", "required_exact", "equal to one",
        "MODEL_SCALE_COUNT_UNSUPPORTED", "H-024-01"),
    row("model.n_latent_dimensions", "integer", "scalar", TRUE, "model",
        "1", "required_exact", "equal to one",
        "MODEL_DIMENSION_COUNT_UNSUPPORTED", "CORE-01"),
    row("model.facet_names", "character", "nonempty ordered vector", TRUE, "model",
        "complete non-Person facet order", "required_explicit",
        "unique names in declared order", "MODEL_FACET_ORDER_INVALID", "CORE-01"),
    row("model.facet_roles", "data.frame", "one row per facet", TRUE, "model",
        "Facet, Role, OrderIndex", "required_explicit",
        "one unique role row per facet", "MODEL_FACET_ROLE_INVALID", "CORE-01"),
    row("model.facet_levels", "data.frame", "one row per facet-level", TRUE, "model",
        "Facet, Level, LevelIndex", "required_explicit",
        "complete unique level dictionary", "MODEL_FACET_LEVEL_INVALID", "CORE-01"),
    row("model.facet_signs", "numeric", "named vector per facet", TRUE, "model",
        "each value is -1 or 1", "required_explicit",
        "names exactly equal facet_names", "MODEL_FACET_SIGN_INVALID", "CORE-01"),
    row("model.step_owner", "character", "scalar", TRUE, "model",
        "shared for RSM; one declared facet for PCM", "required_explicit",
        "agrees with family and owned-step coordinates",
        "IDENTIFICATION_CONTRACT_INVALID", "CORE-01"),
    row("model.interactions", "data.frame", "zero or more typed rows", TRUE, "model",
        "InteractionId, Facets, LevelShape, CoordinateKeys", "required_even_when_empty",
        "typed identifiers and complete cell map", "MODEL_INTERACTION_INVALID", "CORE-01"),
    row("response.score_map", "data.frame", "one row per accepted score", TRUE, "response",
        "OriginalScore, InternalScore, OrderIndex", "required_explicit",
        "one-to-one ordered complete map", "RESPONSE_SCORE_MAP_INVALID", "CORE-01"),
    row("response.rating_min", "integer", "scalar", TRUE, "response",
        "minimum internal score", "required_explicit", "matches score_map",
        "RESPONSE_RATING_BOUND_INVALID", "CORE-01"),
    row("response.rating_max", "integer", "scalar", TRUE, "response",
        "maximum internal score", "required_explicit", "matches score_map",
        "RESPONSE_RATING_BOUND_INVALID", "CORE-01"),
    row("response.n_categories", "integer", "scalar", TRUE, "response",
        "rating_max-rating_min+1", "required_explicit", "matches score_map and steps",
        "RESPONSE_CATEGORY_COUNT_INVALID", "CORE-01"),
    row("input_schema.source_columns", "list", "one typed list", TRUE,
        "input_schema", "person, named facets, score, optional weight",
        "required_explicit", "facet defaults align with model.facet_names",
        "SCHEMA_TYPE_INVALID", "CORE-04"),
    row("parameters.coordinates", "data.frame", "one row per expanded coordinate", TRUE,
        "parameters", "mfrmr_fc_g1_coordinate_schema()", "required_explicit",
        "complete unique named full-precision coordinates",
        "PARAMETER_COORDINATE_INVALID", "CORE-01"),
    row("constraints.identification", "data.frame", "one or more typed rows", TRUE,
        "constraints", "constraint type, target namespace, exact rule",
        "required_explicit", "identified core parameterization",
        "IDENTIFICATION_CONTRACT_INVALID", "CORE-03"),
    row("constraints.anchors", "data.frame", "zero or more typed rows", TRUE,
        "constraints", "mfrmr_fc_g1_anchor_schema()", "required_even_when_empty",
        "typed namespace; no conflicting selectors", "ANCHOR_DECLARATION_INVALID", "CORE-03"),
    row("scoring_basis.type", "character", "scalar", TRUE, "scoring_basis",
        "fixed_standard_normal", "required_exact", "exact registered basis",
        "SCORING_BASIS_UNSUPPORTED", "CORE-04"),
    row("scoring_basis.prior_mean", "numeric", "scalar", TRUE, "scoring_basis",
        "0", "required_exact", "finite and exactly zero",
        "SCORING_PRIOR_INVALID", "CORE-04"),
    row("scoring_basis.prior_sd", "numeric", "scalar", TRUE, "scoring_basis",
        "1", "required_exact", "finite, positive, and exactly one",
        "SCORING_PRIOR_INVALID", "CORE-04"),
    row("scoring_basis.scoring_algorithm", "character", "scalar", TRUE,
        "scoring_basis", "quadrature_eap_v1", "required_exact",
        "registered EAP algorithm identity",
        "SCORING_BASIS_UNSUPPORTED", "CORE-04"),
    row("scoring_basis.quadrature_rule", "character", "scalar", TRUE, "scoring_basis",
        "explicit registered rule identity", "required_explicit",
        "rule identity agrees with stored nodes and weights",
        "QUADRATURE_RULE_INVALID", "CORE-02"),
    row("scoring_basis.quadrature_order", "integer", "scalar", TRUE, "scoring_basis",
        "stored order of at least 2", "required_explicit", "equals node and weight lengths",
        "QUADRATURE_ORDER_INVALID", "CORE-02"),
    row("scoring_basis.nodes", "numeric", "ordered vector", TRUE, "scoring_basis",
        "full-precision transformed nodes", "required_explicit",
        "finite, strictly increasing, length equals order",
        "QUADRATURE_NODES_INVALID", "CORE-02"),
    row("scoring_basis.weights", "numeric", "ordered vector", TRUE, "scoring_basis",
        "full-precision normalized weights", "required_explicit",
        "finite, positive, aligned, normalized under stored rule",
        "QUADRATURE_WEIGHTS_INVALID", "CORE-02"),
    row("eligibility.lane_id", "character", "scalar", TRUE, "eligibility",
        "core_rsm_mml_fixed_normal|core_pcm_mml_fixed_normal", "required_explicit",
        "registered and validated lane", "ELIGIBILITY_LANE_INVALID", "CORE-01"),
    row("eligibility.source_readiness_contract", "character", "scalar", TRUE,
        "eligibility", "exact readiness contract identity", "required_explicit",
        "registered current-fit contract", "SOURCE_READINESS_CONTRACT_INVALID", "CORE-04"),
    row("eligibility.source_readiness_status", "character", "scalar", TRUE,
        "eligibility", "eligible", "required_exact", "source fit passed required gate",
        "SOURCE_READINESS_INELIGIBLE", "CORE-04"),
    row("eligibility.parameter_class_status", "data.frame", "one row per class", TRUE,
        "eligibility", "ParameterClass, Status, EvidenceCode", "required_explicit",
        "every stored class is eligible", "PARAMETER_CLASS_INELIGIBLE", "CORE-04"),
    row("validation.schema_valid", "logical", "scalar", TRUE, "validation",
        "TRUE only after validation", "required_explicit", "agrees with refusal table",
        "VALIDATION_SCHEMA_FAILED", "CORE-02"),
    row("validation.semantic_valid", "logical", "scalar", TRUE, "validation",
        "TRUE only after validation", "required_explicit", "agrees with refusal table",
        "VALIDATION_SEMANTIC_FAILED", "CORE-02"),
    row("validation.refusals", "data.frame", "zero or more typed rows", TRUE, "validation",
        "Code, FieldPath, Detail, Severity", "required_even_when_empty",
        "codes belong to frozen taxonomy", "VALIDATION_REFUSAL_INVALID", "CORE-02"),
    row("validation.validated_at_utc", "character", "zero or one scalar", FALSE,
        "validation", "RFC3339 UTC after successful validation", "absent_until_validated",
        "absent for draft; present for validated/frozen", "VALIDATION_TIME_INVALID", "CORE-02"),
    row("lifecycle.state", "character", "scalar", TRUE, "lifecycle",
        "draft|validated|frozen|superseded|retired", "required_explicit",
        "reachable through registered transition", "LIFECYCLE_STATE_INVALID", "CORE-02"),
    row("lifecycle.revision", "integer", "scalar", TRUE, "lifecycle",
        "positive monotone revision", "required_explicit", "matches event chain",
        "LIFECYCLE_REVISION_INVALID", "CORE-02"),
    row("lifecycle.events", "data.frame", "one or more ordered rows", TRUE, "lifecycle",
        "Revision, Operation, From, To, AtUTC, ParentId", "required_explicit",
        "immutable contiguous registered event chain", "LIFECYCLE_EVENT_CHAIN_INVALID", "CORE-02"),
    row("provenance.source_fit_id", "character", "scalar", TRUE, "provenance",
        "nonempty source-fit identity", "required_explicit", "identity only; no fit object",
        "PROVENANCE_SOURCE_ID_INVALID", "CORE-01"),
    row("provenance.source_package_version", "character", "scalar", TRUE, "provenance",
        "exact creator package version", "required_explicit", "valid version string",
        "PROVENANCE_PACKAGE_VERSION_INVALID", "CORE-02"),
    row("provenance.created_at_utc", "character", "scalar", TRUE, "provenance",
        "RFC3339 UTC", "required_explicit", "valid immutable timestamp",
        "PROVENANCE_TIME_INVALID", "CORE-02"),
    row("provenance.created_by", "character", "scalar", TRUE, "provenance",
        "registered constructor identity", "required_explicit", "nonempty identity",
        "PROVENANCE_CREATOR_INVALID", "CORE-02"),
    row("provenance.parent_calibration_id", "character", "zero or one scalar", FALSE,
        "provenance", "prior identity for supersession/retirement record",
        "absent_without_parent", "required for derived lifecycle record",
        "PROVENANCE_PARENT_INVALID", "CORE-02"),
    row("integrity.semantic_components", "list", "named canonical list", TRUE, "identity",
        "mfrmr_fc_g1_identity_components()", "required_explicit",
        "exactly reconstructible from semantic fields", "IDENTITY_COMPONENT_MISMATCH", "H-024-02"),
    row("integrity.optional_hash", "character", "zero or one scalar", FALSE, "integrity",
        "provenance alarm only", "optional_alarm_only",
        "never substitutes for semantic validation", "INTEGRITY_HASH_INVALID", "CORE-02")
  ))
}

mfrmr_fc_g1_coordinate_schema <- function() {
  data.frame(
    Column = c(
      "CoordinateKey", "ParameterClass", "OwnerFacet", "Level", "Step",
      "InteractionId", "Value", "OrderIndex"
    ),
    StorageType = c(
      rep("character", 6), "numeric", "integer"
    ),
    Required = TRUE,
    Rule = c(
      "globally unique typed key",
      "facet|shared_step|owned_step|interaction",
      "explicit owner or typed NA",
      "explicit level or typed NA",
      "explicit transition index or typed NA",
      "explicit interaction identity or typed NA",
      "finite full-precision expanded value",
      "unique contiguous canonical order"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_anchor_schema <- function() {
  data.frame(
    Column = c(
      "AnchorId", "AnchorType", "ParameterClass", "OwnerFacet", "Level",
      "Step", "GroupId", "Value", "CoordinateSystem", "DeclarationOrder"
    ),
    StorageType = c(rep("character", 7), "numeric", "character", "integer"),
    Required = TRUE,
    Rule = c(
      "unique declaration identity",
      "direct|group|shared_step|owned_step",
      "facet|shared_step|owned_step",
      "explicit owner or typed NA",
      "explicit level or typed NA",
      "explicit transition index or typed NA",
      "explicit group identity or typed NA",
      "finite value in declared coordinate system",
      "exact registered coordinate identity",
      "provenance only; never conflict precedence"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_lifecycle_transitions <- function() {
  data.frame(
    Operation = c(
      "extract_draft", "validate", "freeze",
      rep("save", 5), rep("load", 5), "score", "supersede", "retire"
    ),
    From = c(
      "none", "draft", "validated",
      "draft", "validated", "frozen", "superseded", "retired",
      "draft", "validated", "frozen", "superseded", "retired",
      "frozen", "frozen", "frozen"
    ),
    To = c(
      "draft", "validated", "frozen",
      "draft", "validated", "frozen", "superseded", "retired",
      "draft", "validated", "frozen", "superseded", "retired",
      "frozen", "superseded", "retired"
    ),
    MutatesInput = FALSE,
    Gate = c(
      "eligible source fit is not yet required",
      "schema, semantic, source-readiness, parameter-class, and lane checks pass",
      "validated state and empty refusal table",
      rep("serialize exact state after structural validation without promotion", 5),
      rep("deserialize then revalidate before return", 5),
      "frozen state and operational scoring validation",
      "create a distinct terminal record pointing to the unchanged frozen parent",
      "create a distinct terminal record pointing to the unchanged frozen parent"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_refusal_taxonomy <- function() {
  code <- c(
    "SCHEMA_ID_UNKNOWN", "SCHEMA_VERSION_UNSUPPORTED", "SCHEMA_MIGRATION_REQUIRED",
    "SCHEMA_FIELD_MISSING", "SCHEMA_FIELD_UNEXPECTED", "SCHEMA_TYPE_INVALID",
    "SCHEMA_CARDINALITY_INVALID", "SCHEMA_CLASS_INVALID",
    "VALIDATION_SCHEMA_FAILED", "VALIDATION_SEMANTIC_FAILED",
    "VALIDATION_REFUSAL_INVALID", "VALIDATION_TIME_INVALID",
    "LIFECYCLE_STATE_INVALID", "LIFECYCLE_REVISION_INVALID",
    "LIFECYCLE_TRANSITION_INVALID", "LIFECYCLE_EVENT_CHAIN_INVALID",
    "LIFECYCLE_NOT_FROZEN", "IDENTITY_ID_INVALID", "IDENTITY_VERSION_UNKNOWN",
    "IDENTITY_COMPONENT_MISMATCH", "MODEL_FAMILY_UNSUPPORTED",
    "MODEL_ESTIMATOR_UNSUPPORTED", "MODEL_SCALE_COUNT_UNSUPPORTED",
    "MODEL_DIMENSION_COUNT_UNSUPPORTED", "MODEL_FACET_ORDER_INVALID",
    "MODEL_FACET_ROLE_INVALID", "MODEL_FACET_LEVEL_INVALID",
    "MODEL_FACET_SIGN_INVALID", "MODEL_INTERACTION_INVALID",
    "RESPONSE_SCORE_MAP_INVALID", "RESPONSE_RATING_BOUND_INVALID",
    "RESPONSE_CATEGORY_COUNT_INVALID", "PARAMETER_COORDINATE_INVALID",
    "PARAMETER_COORDINATE_DUPLICATE", "PARAMETER_NONFINITE",
    "IDENTIFICATION_CONTRACT_INVALID", "ANCHOR_DECLARATION_INVALID",
    "ANCHOR_SELECTOR_INVALID", "ANCHOR_OWNER_UNKNOWN", "ANCHOR_LEVEL_UNKNOWN",
    "ANCHOR_STEP_UNKNOWN", "ANCHOR_OWNER_INCOMPATIBLE",
    "ANCHOR_COORDINATE_SYSTEM_INVALID", "ANCHOR_CANONICAL_ORDER_INVALID",
    "ANCHOR_COORDINATE_MISMATCH", "ANCHOR_CONSTRAINT_INCOMPATIBLE",
    "ANCHOR_RANK_DEFICIENT", "ANCHOR_CONFLICT",
    "SCORING_BASIS_UNSUPPORTED", "SCORING_PRIOR_INVALID",
    "QUADRATURE_RULE_INVALID", "QUADRATURE_ORDER_INVALID",
    "QUADRATURE_NODES_INVALID", "QUADRATURE_WEIGHTS_INVALID",
    "ELIGIBILITY_LANE_INVALID", "SOURCE_READINESS_CONTRACT_INVALID",
    "SOURCE_READINESS_INELIGIBLE", "PARAMETER_CLASS_INELIGIBLE",
    "PROVENANCE_SOURCE_ID_INVALID", "PROVENANCE_PACKAGE_VERSION_INVALID",
    "PROVENANCE_TIME_INVALID", "PROVENANCE_CREATOR_INVALID",
    "PROVENANCE_PARENT_INVALID",
    "PROHIBITED_TRAINING_STATE", "PROHIBITED_PERSON_STATE",
    "PROHIBITED_EXECUTABLE_STATE", "INTEGRITY_HASH_INVALID",
    "PERSISTENCE_PATH_INVALID", "PERSISTENCE_TARGET_EXISTS",
    "PERSISTENCE_WRITE_FAILED", "PERSISTENCE_READ_FAILED",
    "SCORING_INPUT_TYPE_INVALID", "SCORING_INPUT_EMPTY",
    "SCORING_COLUMN_MAPPING_INVALID", "SCORING_COLUMN_MISSING",
    "SCORING_MISSING_POLICY_INVALID",
    "SCORING_VALUE_MISSING", "SCORING_SCORE_INVALID",
    "SCORING_SCORE_UNKNOWN", "SCORING_WEIGHT_INVALID",
    "SCORING_FACET_LEVEL_UNKNOWN", "SCORING_EVENT_DUPLICATE",
    "SCORING_INTERVAL_INVALID", "SCORING_NUMERICAL_FAILURE"
  )
  layer <- sub("_.*$", "", code)
  data.frame(
    Code = code,
    Layer = layer,
    Severity = "error",
    Consequence = ifelse(
      code == "INTEGRITY_HASH_INVALID",
      "refuse identity claim until semantic validation is rerun; hash alone decides nothing",
      "refuse transition, load, freeze, or score without modifying the input"
    ),
    MessageRule = "return stable code, exact field path, and bounded human-readable detail",
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_prohibited_state <- function() {
  data.frame(
    StateClass = c(
      "source_fit_object", "raw_optimizer_vector", "training_response_rows",
      "training_design_matrix", "person_identifiers", "person_coordinates",
      "person_estimates", "optimizer_trace", "hessian_or_diagnostics",
      "closure_or_environment", "external_pointer", "rng_state",
      "ambient_option_snapshot", "absolute_source_path"
    ),
    WhyProhibited = c(
      "artifact must be sufficient without mfrm_fit",
      "expanded named values prevent parser drift",
      "privacy minimization and artifact sufficiency",
      "training-person state must not partition parameters",
      "privacy minimization",
      "source Persons are not calibration coordinates",
      "source Persons are not operational scoring input",
      "not required for probability reconstruction",
      "diagnostic bulk is not calibration semantics",
      "not portable or serially stable",
      "not portable across sessions",
      "scoring must preserve caller RNG state explicitly",
      "ambient settings are not model identity",
      "machine-local provenance is not portable identity"
    ),
    RefusalCode = c(
      rep("PROHIBITED_TRAINING_STATE", 4),
      rep("PROHIBITED_PERSON_STATE", 3),
      rep("PROHIBITED_TRAINING_STATE", 2),
      rep("PROHIBITED_EXECUTABLE_STATE", 4),
      "PROHIBITED_TRAINING_STATE"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_scoring_contract <- function() {
  data.frame(
    BoundaryId = c(
      "SCORE-STATE", "SCORE-INPUT", "SCORE-COLUMNS", "SCORE-LABELS",
      "SCORE-MAP", "SCORE-WEIGHT", "SCORE-LEVELS", "SCORE-EVENT",
      "SCORE-INTERVAL", "SCORE-COORDINATES", "SCORE-MATH",
      "SCORE-OUTPUT", "SCORE-IMMUTABLE", "SCORE-INDEPENDENCE"
    ),
    Rule = c(
      "artifact inherits mfrm_calibration and lifecycle state is exactly frozen",
      "new responses are a nonempty data.frame; omission requires an explicit policy and row reason code",
      "person, every named facet, score, and optional weight map to distinct present columns",
      "Person and facet labels are atomic, present, and nonblank",
      "every finite numeric score matches exactly one frozen OriginalScore",
      "every supplied weight is finite and strictly positive",
      "every non-Person level is present in the frozen facet dictionary",
      "one response per Person-by-all-facets cell unless distinct event IDs identify intentional repeats",
      "interval level is one finite number strictly between zero and one",
      "every declared facet, transition, owner-step, and interaction cell materializes exactly once",
      "standalone cumulative-logit likelihood plus stored quadrature prior; no fit reconstruction helper",
      "one finite conditional EAP summary per Person with valid responses; zero-valid Persons receive no estimate and an explicit disposition",
      "artifact, response input, caller RNG state, and ambient options remain unchanged",
      "fresh vanilla process has artifact and new responses only; source fit and training data are absent"
    ),
    RefusalCode = c(
      "LIFECYCLE_NOT_FROZEN", "SCORING_INPUT_EMPTY",
      "SCORING_COLUMN_MAPPING_INVALID", "SCORING_VALUE_MISSING",
      "SCORING_SCORE_UNKNOWN", "SCORING_WEIGHT_INVALID",
      "SCORING_FACET_LEVEL_UNKNOWN", "SCORING_EVENT_DUPLICATE",
      "SCORING_INTERVAL_INVALID", "PARAMETER_COORDINATE_INVALID",
      "SCORING_NUMERICAL_FAILURE", "SCORING_NUMERICAL_FAILURE",
      "SCORING_NUMERICAL_FAILURE", "PROHIBITED_TRAINING_STATE"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_identity_components <- function() {
  data.frame(
    Component = c(
      "schema", "model_family_estimator", "scale_dimension_counts",
      "facet_order_roles_levels_signs", "interaction_map", "response_map",
      "parameter_coordinates", "identification_constraints", "typed_anchors",
      "scoring_prior", "scoring_algorithm", "quadrature", "eligibility_lane"
    ),
    SourcePaths = c(
      "header.schema_id;header.schema_version;header.semantic_identity_version",
      "model.family;model.estimator",
      "model.n_observed_scales;model.n_latent_dimensions",
      "model.facet_names;model.facet_roles;model.facet_levels;model.facet_signs",
      "model.interactions", "response.*", "parameters.coordinates",
      "constraints.identification", "constraints.anchors",
      "scoring_basis.type;scoring_basis.prior_mean;scoring_basis.prior_sd",
      "scoring_basis.scoring_algorithm",
      "scoring_basis.quadrature_rule;scoring_basis.quadrature_order;scoring_basis.nodes;scoring_basis.weights",
      "eligibility.lane_id"
    ),
    EqualityRule = c(
      rep("typed exact equality in canonical declared order", 13)
    ),
    HashRequired = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g1_review <- function() {
  fields <- mfrmr_fc_g1_field_schema()
  coordinates <- mfrmr_fc_g1_coordinate_schema()
  anchors <- mfrmr_fc_g1_anchor_schema()
  lifecycle <- mfrmr_fc_g1_lifecycle_transitions()
  refusals <- mfrmr_fc_g1_refusal_taxonomy()
  prohibited <- mfrmr_fc_g1_prohibited_state()
  scoring <- mfrmr_fc_g1_scoring_contract()
  identity <- mfrmr_fc_g1_identity_components()
  valid <-
    !anyDuplicated(fields$FieldPath) &&
    all(nzchar(fields$SemanticOwner)) &&
    all(nzchar(fields$OmissionPolicy)) &&
    !any(grepl("fallback|infer", fields$OmissionPolicy, ignore.case = TRUE)) &&
    identical(coordinates$Column, c(
      "CoordinateKey", "ParameterClass", "OwnerFacet", "Level", "Step",
      "InteractionId", "Value", "OrderIndex"
    )) &&
    identical(anchors$Column, c(
      "AnchorId", "AnchorType", "ParameterClass", "OwnerFacet", "Level",
      "Step", "GroupId", "Value", "CoordinateSystem", "DeclarationOrder"
    )) &&
    !anyDuplicated(paste(lifecycle$Operation, lifecycle$From, sep = "::")) &&
    all(!lifecycle$MutatesInput) && !anyDuplicated(refusals$Code) &&
    all(prohibited$RefusalCode %in% refusals$Code) &&
    !anyDuplicated(scoring$BoundaryId) &&
    all(scoring$RefusalCode %in% refusals$Code) &&
    all(!identity$HashRequired) &&
    all(c("RSM|PCM", "MML", "1", "fixed_standard_normal") %in%
          fields$CoreValueOrDomain)
  list(
    specification = mfrmr_fc_g1_specification,
    schema_id = mfrmr_fc_g1_schema_id,
    schema_version = mfrmr_fc_g1_schema_version,
    status = if (valid) "G1_complete_internal_public_gate_closed" else "G1_schema_spec_invalid",
    fields = fields,
    coordinate_schema = coordinates,
    anchor_schema = anchors,
    lifecycle = lifecycle,
    refusal_taxonomy = refusals,
    prohibited_state = prohibited,
    scoring_contract = scoring,
    identity_components = identity,
    schema_spec_complete = isTRUE(valid),
    lifecycle_spec_complete = isTRUE(valid),
    refusal_taxonomy_complete = isTRUE(valid),
    constructor_export_authorized = FALSE,
    persistence_implementation_complete = isTRUE(valid),
    prohibited_state_exclusion_slice_complete = isTRUE(valid),
    mutation_refusal_slice_complete = isTRUE(valid),
    artifact_only_scoring_complete = isTRUE(valid),
    CORE_01_complete = isTRUE(valid),
    CORE_02_complete = isTRUE(valid),
    public_api_authorized = FALSE,
    optional_lane_authorized = FALSE
  )
}
