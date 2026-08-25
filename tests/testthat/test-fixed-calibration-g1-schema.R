load_fixed_calibration_g1_schema <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(validation, "fixed-calibration-g1-schema-0.2.4.R")
  skip_if_not(file.exists(script), "Fixed-calibration G1 schema is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

test_that("G1 core schema is explicit and has no omission fallback", {
  ctx <- load_fixed_calibration_g1_schema()
  fields <- ctx$env$mfrmr_fc_g1_field_schema()

  expect_identical(anyDuplicated(fields$FieldPath), 0L)
  expect_true(nrow(fields) >= 40L)
  expect_true(all(nzchar(fields$SemanticOwner)))
  expect_true(all(nzchar(fields$ValidationRule)))
  expect_false(any(grepl("fallback|infer", fields$OmissionPolicy, ignore.case = TRUE)))
  expect_true(all(c(
    "model.family", "model.estimator", "model.n_observed_scales",
    "model.n_latent_dimensions", "model.facet_names", "response.score_map",
    "model.step_owner", "input_schema.source_columns", "parameters.coordinates",
    "constraints.anchors", "scoring_basis.type",
    "scoring_basis.nodes", "scoring_basis.weights", "lifecycle.state"
  ) %in% fields$FieldPath))
  expect_identical(
    fields$CoreValueOrDomain[fields$FieldPath == "model.family"], "RSM|PCM"
  )
  expect_identical(
    fields$CoreValueOrDomain[fields$FieldPath == "model.estimator"], "MML"
  )
  expect_identical(
    fields$CoreValueOrDomain[fields$FieldPath == "model.n_observed_scales"], "1"
  )
})

test_that("expanded coordinates replace raw optimizer and training state", {
  ctx <- load_fixed_calibration_g1_schema()
  coordinates <- ctx$env$mfrmr_fc_g1_coordinate_schema()
  prohibited <- ctx$env$mfrmr_fc_g1_prohibited_state()

  expect_identical(coordinates$Column, c(
    "CoordinateKey", "ParameterClass", "OwnerFacet", "Level", "Step",
    "InteractionId", "Value", "OrderIndex"
  ))
  expect_true(all(coordinates$Required))
  expect_true(all(c(
    "raw_optimizer_vector", "training_response_rows", "training_design_matrix",
    "person_identifiers", "person_coordinates", "person_estimates"
  ) %in% prohibited$StateClass))
})

test_that("typed anchors cannot use declaration order as precedence", {
  ctx <- load_fixed_calibration_g1_schema()
  anchors <- ctx$env$mfrmr_fc_g1_anchor_schema()

  expect_identical(anchors$Column, c(
    "AnchorId", "AnchorType", "ParameterClass", "OwnerFacet", "Level",
    "Step", "GroupId", "Value", "CoordinateSystem", "DeclarationOrder"
  ))
  expect_match(
    anchors$Rule[anchors$Column == "AnchorType"],
    "direct|group|shared_step|owned_step", fixed = TRUE
  )
  expect_match(
    anchors$Rule[anchors$Column == "DeclarationOrder"],
    "never conflict precedence", fixed = TRUE
  )
})

test_that("lifecycle is immutable and scoring requires frozen state", {
  ctx <- load_fixed_calibration_g1_schema()
  lifecycle <- ctx$env$mfrmr_fc_g1_lifecycle_transitions()

  expect_identical(anyDuplicated(paste(lifecycle$Operation, lifecycle$From)), 0L)
  expect_true(all(!lifecycle$MutatesInput))
  score <- lifecycle[lifecycle$Operation == "score", , drop = FALSE]
  expect_identical(nrow(score), 1L)
  expect_identical(score$From, "frozen")
  expect_identical(score$To, "frozen")
  expect_false(any(lifecycle$Operation == "freeze" & lifecycle$From != "validated"))
})

test_that("artifact-only scoring boundary is explicit and fail closed", {
  ctx <- load_fixed_calibration_g1_schema()
  scoring <- ctx$env$mfrmr_fc_g1_scoring_contract()
  refusals <- ctx$env$mfrmr_fc_g1_refusal_taxonomy()

  expect_identical(anyDuplicated(scoring$BoundaryId), 0L)
  expect_identical(nrow(scoring), 14L)
  expect_true(all(nzchar(scoring$Rule)))
  expect_true(all(scoring$RefusalCode %in% refusals$Code))
  expect_true(all(c(
    "SCORE-STATE", "SCORE-MAP", "SCORE-COORDINATES", "SCORE-MATH",
    "SCORE-IMMUTABLE", "SCORE-INDEPENDENCE"
  ) %in% scoring$BoundaryId))
  expect_match(
    scoring$Rule[scoring$BoundaryId == "SCORE-MATH"],
    "no fit reconstruction helper", fixed = TRUE
  )
})

test_that("refusal taxonomy is stable, structured, and fail closed", {
  ctx <- load_fixed_calibration_g1_schema()
  refusals <- ctx$env$mfrmr_fc_g1_refusal_taxonomy()

  expect_identical(anyDuplicated(refusals$Code), 0L)
  expect_true(nrow(refusals) >= 50L)
  expect_true(all(refusals$Severity == "error"))
  expect_true(all(c(
    "SCHEMA_VERSION_UNSUPPORTED", "SCHEMA_MIGRATION_REQUIRED",
    "LIFECYCLE_NOT_FROZEN", "IDENTITY_COMPONENT_MISMATCH",
    "MODEL_SCALE_COUNT_UNSUPPORTED", "PARAMETER_COORDINATE_DUPLICATE",
    "ANCHOR_CONFLICT", "SCORING_PRIOR_INVALID",
    "SOURCE_READINESS_INELIGIBLE", "PROHIBITED_TRAINING_STATE",
    "PROHIBITED_PERSON_STATE", "PERSISTENCE_PATH_INVALID",
    "PERSISTENCE_TARGET_EXISTS", "PERSISTENCE_WRITE_FAILED",
    "PERSISTENCE_READ_FAILED"
  ) %in% refusals$Code))
  expect_true(all(c(
    "SCORING_INPUT_EMPTY", "SCORING_COLUMN_MAPPING_INVALID",
    "SCORING_SCORE_UNKNOWN", "SCORING_FACET_LEVEL_UNKNOWN",
    "SCORING_EVENT_DUPLICATE", "SCORING_NUMERICAL_FAILURE"
  ) %in% refusals$Code))
  expect_true(all(grepl("refuse|decides nothing", refusals$Consequence)))
})

test_that("semantic identity is direct and never requires a hash", {
  ctx <- load_fixed_calibration_g1_schema()
  identity <- ctx$env$mfrmr_fc_g1_identity_components()

  expect_identical(anyDuplicated(identity$Component), 0L)
  expect_true(all(!identity$HashRequired))
  expect_true(all(grepl("exact equality", identity$EqualityRule, fixed = TRUE)))
  expect_true(all(c(
    "schema", "model_family_estimator", "facet_order_roles_levels_signs",
    "response_map", "parameter_coordinates", "typed_anchors",
    "scoring_prior", "scoring_algorithm", "quadrature"
  ) %in% identity$Component))
})

test_that("G1 review closes the internal gate without public promotion", {
  ctx <- load_fixed_calibration_g1_schema()
  review <- ctx$env$mfrmr_fc_g1_review()

  expect_identical(review$status, "G1_complete_internal_public_gate_closed")
  expect_true(review$schema_spec_complete)
  expect_true(review$lifecycle_spec_complete)
  expect_true(review$refusal_taxonomy_complete)
  expect_false(review$constructor_export_authorized)
  expect_true(review$persistence_implementation_complete)
  expect_true(review$prohibited_state_exclusion_slice_complete)
  expect_true(review$mutation_refusal_slice_complete)
  expect_true(review$artifact_only_scoring_complete)
  expect_true(review$CORE_01_complete)
  expect_true(review$CORE_02_complete)
  expect_false(review$public_api_authorized)
  expect_false(review$optional_lane_authorized)
})

test_that("G1 specification does not fit, score, persist, or launch", {
  ctx <- load_fixed_calibration_g1_schema()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("predict_mfrm_units\\s*\\(", source, perl = TRUE))
  expect_false(grepl("saveRDS\\s*\\(|readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
})

test_that("roadmap marks G1 complete without public promotion", {
  ctx <- load_fixed_calibration_g1_schema()
  roadmap <- paste(readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE), collapse = "\n")

  expect_match(roadmap, "- [x] **G1 — Schema, lifecycle", fixed = TRUE)
  expect_match(roadmap, "  - [x] Specify the object schema", fixed = TRUE)
  expect_match(roadmap, "  - [x] Implement draft extraction", fixed = TRUE)
  expect_match(roadmap, "  - [x] Exclude training rows", fixed = TRUE)
  expect_match(roadmap, "  - [x] Demonstrate artifact-only scoring", fixed = TRUE)
  expect_match(roadmap, "  - [x] Reject corrupt, partial", fixed = TRUE)
  expect_match(roadmap, "  - [x] **G1 exit:**", fixed = TRUE)
})
