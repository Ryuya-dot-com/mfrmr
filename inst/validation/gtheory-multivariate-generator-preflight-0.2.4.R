# Draft.85c2 multivariate G-theory generator preflight.
#
# Repository-internal only. This fixture-only generator implements the c1
# row/factor/RNG contract without opening pilot, confirmation, or structural-
# control seeds. It fits no model and computes no recovery result.

mfrmr_gtve_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtvd_assignment_rows"
  )
  environment <- environment(mfrmr_gtve_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = environment, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81 and the Draft.85a0-c1 chain before Draft.85c2: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtve_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtve_function_hash <- function(fun) {
  if (!is.function(fun)) {
    stop("A Draft.85c2 implementation function is missing.", call. = FALSE)
  }
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtve_manifest_payload_fields <- function() {
  c(
    "Contract", "PlanHash", "PlanCoreHash", "FixtureRegistry",
    "FixtureReplayRegistry", "ComponentStateRegistry", "ManifestCoreHash",
    "FixtureRegistryHash", "FixtureReplayRegistryHash",
    "ComponentStateRegistryHash", "ImplementationIdentity",
    "ImplementationIdentityHash"
  )
}

mfrmr_gtve_fixture_registry <- function(plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  scenarios <- plan$ScenarioRegistry[
    plan$ScenarioRegistry$RecoveryExecutable, , drop = FALSE
  ]
  structural <- plan$StructuralDesignPreflight
  expected_rows <- structural$StructuralRows[match(
    scenarios$AssignmentId, structural$AssignmentId
  )]
  seed <- as.integer(854000000L + scenarios$ScenarioOrdinal)
  output <- data.frame(
    FixtureOrdinal = seq_len(nrow(scenarios)),
    FixtureId = paste0("FX-", scenarios$ScenarioId),
    ScenarioId = scenarios$ScenarioId,
    ScenarioOrdinal = scenarios$ScenarioOrdinal,
    AssignmentId = scenarios$AssignmentId,
    CoordinateLayoutId = scenarios$CoordinateLayoutId,
    ReferenceId = scenarios$ReferenceId,
    ExpectedRows = as.integer(expected_rows),
    FixtureSeed = seed,
    FixtureStage = "nonreserved_generator_preflight",
    PlanSeedCollision = seed %in% plan$GenerationManifest$DataSeed,
    RecoveryDenominatorEligible = FALSE,
    stringsAsFactors = FALSE
  )
  output
}

mfrmr_gtve_assert_fixture_registry <- function(
    registry, plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  canonical <- mfrmr_gtve_fixture_registry(plan)
  if (!is.data.frame(registry) || !identical(registry, canonical) ||
      nrow(registry) != 12L || any(registry$PlanSeedCollision) ||
      any(registry$RecoveryDenominatorEligible) ||
      anyDuplicated(registry$FixtureId) > 0L ||
      anyDuplicated(registry$FixtureSeed) > 0L) {
    stop("A canonical nonreserved Draft.85c2 fixture registry is required.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtve_factor_matrix <- function(plan, reference_id, component_id,
                                      strata) {
  rows <- plan$ReferenceFactorRegistry[
    plan$ReferenceFactorRegistry$ReferenceId == reference_id &
      plan$ReferenceFactorRegistry$ComponentId == component_id,
    , drop = FALSE
  ]
  if (nrow(rows) == 0L || component_id == "Residual") {
    stop("A registered non-residual generating factor is required.",
         call. = FALSE)
  }
  row_count <- length(strata)
  column_count <- max(rows$FactorColumnOrdinal)
  expected <- expand.grid(
    FactorRowOrdinal = seq_len(row_count),
    FactorColumnOrdinal = seq_len(column_count),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  key <- paste(rows$FactorRowOrdinal, rows$FactorColumnOrdinal, sep = "\036")
  expected_key <- paste(
    expected$FactorRowOrdinal, expected$FactorColumnOrdinal, sep = "\036"
  )
  if (anyDuplicated(key) > 0L || !setequal(key, expected_key) ||
      !identical(
        rows$FactorRowStratum[match(seq_len(row_count), rows$FactorRowOrdinal)],
        strata
      )) {
    stop("The registered factor grid is incomplete or misordered.",
         call. = FALSE)
  }
  factor <- matrix(
    NA_real_, nrow = row_count, ncol = column_count,
    dimnames = list(strata, paste0("Factor", seq_len(column_count)))
  )
  factor[cbind(rows$FactorRowOrdinal, rows$FactorColumnOrdinal)] <-
    rows$FactorValue
  if (any(!is.finite(factor))) {
    stop("The registered generating factor must be finite.", call. = FALSE)
  }
  factor
}

mfrmr_gtve_component_starts <- function(seed) {
  seed <- as.integer(seed)
  if (length(seed) != 1L || is.na(seed) || seed < 1L) {
    stop("A positive scalar fixture seed is required.", call. = FALSE)
  }
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else {
    NULL
  }
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(
      ".Random.seed", envir = .GlobalEnv, inherits = FALSE
    )) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  do.call(
    RNGkind, as.list(c("L'Ecuyer-CMRG", "Inversion", "Rejection"))
  )
  set.seed(seed)
  starts <- vector("list", 4L)
  names(starts) <- c("Object", "Rater", "Object:Rater", "Residual")
  starts[[1L]] <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  for (index in 2:4) {
    starts[[index]] <- parallel::nextRNGSubStream(starts[[index - 1L]])
  }
  starts
}

mfrmr_gtve_function_identity <- function() {
  functions <- c(
    "mfrmr_gtve_require_primitives", "mfrmr_gtve_exact_object",
    "mfrmr_gtve_function_hash", "mfrmr_gtve_manifest_payload_fields",
    "mfrmr_gtve_fixture_registry",
    "mfrmr_gtve_assert_fixture_registry", "mfrmr_gtve_factor_matrix",
    "mfrmr_gtve_component_starts", "mfrmr_gtve_function_identity",
    "mfrmr_gtve_generate_fixture", "mfrmr_gtve_assert_generation",
    "mfrmr_gtve_manifest_payload", "mfrmr_gtve_manifest",
    "mfrmr_gtve_assert_manifest"
  )
  environment <- environment(mfrmr_gtve_function_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions),
    FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      mfrmr_gtve_function_hash(get(
        name, envir = environment, inherits = FALSE
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtve_generate_fixture <- function(
    fixture_id, plan = mfrmr_gtvd_plan(),
    registry = mfrmr_gtve_fixture_registry(plan)) {
  mfrmr_gtve_require_primitives()
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_fixture_registry(registry, plan)
  if (length(fixture_id) != 1L || is.na(fixture_id) ||
      !fixture_id %in% registry$FixtureId) {
    stop("`fixture_id` must identify one registered Draft.85c2 fixture.",
         call. = FALSE)
  }
  fixture <- registry[registry$FixtureId == fixture_id, , drop = FALSE]
  scenario <- plan$ScenarioRegistry[
    plan$ScenarioRegistry$ScenarioId == fixture$ScenarioId, , drop = FALSE
  ]
  if (nrow(scenario) != 1L || !isTRUE(scenario$RecoveryExecutable)) {
    stop("Draft.85c2 cannot generate a structural control or unknown scenario.",
         call. = FALSE)
  }
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else {
    NULL
  }
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(
      ".Random.seed", envir = .GlobalEnv, inherits = FALSE
    )) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  rows <- mfrmr_gtvd_assignment_rows(fixture$AssignmentId)
  if (nrow(rows) != fixture$ExpectedRows ||
      !identical(mfrmr_gta_hash(rows), plan$StructuralDesignPreflight$StructuralRowsHash[
        match(fixture$AssignmentId, plan$StructuralDesignPreflight$AssignmentId)
      ])) {
    stop("The deterministic structural rows do not match the c1 plan.",
         call. = FALSE)
  }
  means <- plan$FixedMeanRegistry[
    plan$FixedMeanRegistry$CoordinateLayoutId == fixture$CoordinateLayoutId,
    , drop = FALSE
  ]
  strata <- means$Stratum
  if (!identical(sort(unique(rows$Stratum), method = "radix"), strata)) {
    stop("The structural strata do not match the fixed-mean registry.",
         call. = FALSE)
  }
  starts <- mfrmr_gtve_component_starts(fixture$FixtureSeed)
  group_columns <- c(
    Object = "Object", Rater = "Rater", `Object:Rater` = "ObjectRater"
  )
  row_effects <- list()
  effect_registries <- list()
  state_rows <- list()
  for (component_ordinal in seq_along(group_columns)) {
    component <- names(group_columns)[[component_ordinal]]
    group_column <- unname(group_columns[[component]])
    factor <- mfrmr_gtve_factor_matrix(
      plan, fixture$ReferenceId, component, strata
    )
    groups <- sort(unique(rows[[group_column]]), method = "radix")
    assign(".Random.seed", starts[[component]], envir = .GlobalEnv)
    start_hash <- mfrmr_gta_hash(starts[[component]])
    latent <- matrix(
      stats::rnorm(length(groups) * ncol(factor)),
      nrow = length(groups), ncol = ncol(factor), byrow = TRUE,
      dimnames = list(groups, colnames(factor))
    )
    effect <- latent %*% t(factor)
    colnames(effect) <- strata
    row_index <- match(rows[[group_column]], groups)
    stratum_index <- match(rows$Stratum, strata)
    row_effects[[component]] <- effect[cbind(row_index, stratum_index)]
    effect_registry <- data.frame(
      FixtureId = fixture_id, ComponentId = component,
      GroupId = rep(groups, each = length(strata)),
      Stratum = rep(strata, times = length(groups)),
      Effect = as.numeric(t(effect)),
      stringsAsFactors = FALSE
    )
    latent_registry <- data.frame(
      GroupId = rep(groups, each = ncol(factor)),
      FactorColumnOrdinal = rep(seq_len(ncol(factor)), times = length(groups)),
      LatentDraw = as.numeric(t(latent)), stringsAsFactors = FALSE
    )
    effect_registries[[component]] <- effect_registry
    end_state <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    state_rows[[component]] <- data.frame(
      FixtureId = fixture_id, ComponentOrdinal = component_ordinal,
      ComponentId = component, StartStateHash = start_hash,
      EndStateHash = mfrmr_gta_hash(end_state),
      DrawCount = as.integer(length(latent)),
      LatentDrawHash = mfrmr_gta_hash(latent_registry),
      GeneratedEffectHash = mfrmr_gta_hash(effect_registry),
      stringsAsFactors = FALSE
    )
  }
  residual_rows <- plan$ReferenceFactorRegistry[
    plan$ReferenceFactorRegistry$ReferenceId == fixture$ReferenceId &
      plan$ReferenceFactorRegistry$ComponentId == "Residual",
    , drop = FALSE
  ]
  if (nrow(residual_rows) != 1L ||
      !is.finite(residual_rows$FactorValue) ||
      residual_rows$FactorValue < 0) {
    stop("One finite nonnegative residual factor is required.", call. = FALSE)
  }
  assign(".Random.seed", starts$Residual, envir = .GlobalEnv)
  residual_start_hash <- mfrmr_gta_hash(starts$Residual)
  residual_latent <- stats::rnorm(nrow(rows))
  residual_effect <- residual_rows$FactorValue * residual_latent
  residual_registry <- data.frame(
    FixtureId = fixture_id, ComponentId = "Residual", RowId = rows$RowId,
    LatentDraw = residual_latent, Effect = residual_effect,
    stringsAsFactors = FALSE
  )
  residual_end <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  state_rows$Residual <- data.frame(
    FixtureId = fixture_id, ComponentOrdinal = 4L, ComponentId = "Residual",
    StartStateHash = residual_start_hash,
    EndStateHash = mfrmr_gta_hash(residual_end),
    DrawCount = as.integer(nrow(rows)),
    LatentDrawHash = mfrmr_gta_hash(residual_registry[c("RowId", "LatentDraw")]),
    GeneratedEffectHash = mfrmr_gta_hash(
      residual_registry[c("FixtureId", "ComponentId", "RowId", "Effect")]
    ),
    stringsAsFactors = FALSE
  )
  fixed_mean <- means$Mean[match(rows$Stratum, means$Stratum)]
  score <- fixed_mean + row_effects$Object + row_effects$Rater +
    row_effects$`Object:Rater` + residual_effect
  truth_audit <- data.frame(
    RowId = rows$RowId, FixedMean = fixed_mean,
    ObjectEffect = row_effects$Object,
    RaterEffect = row_effects$Rater,
    ObjectRaterEffect = row_effects$`Object:Rater`,
    ResidualEffect = residual_effect, Score = score,
    stringsAsFactors = FALSE
  )
  candidate_data <- data.frame(
    rows[c(
      "RowId", "Stratum", "Object", "Rater", "ObjectRater", "Replicate"
    )],
    Score = score, stringsAsFactors = FALSE
  )
  effect_registry <- do.call(rbind, effect_registries)
  row.names(effect_registry) <- NULL
  state_registry <- do.call(rbind, state_rows)
  row.names(state_registry) <- NULL
  function_identity <- mfrmr_gtve_function_identity()
  identity <- list(
    Contract = "gtheory_multivariate_generator_preflight_draft85c2_v1",
    PlanHash = plan$PlanHash,
    PlanCoreHash = plan$PlanCoreHash,
    FixtureRegistryHash = mfrmr_gta_hash(registry),
    FixtureId = fixture_id,
    ScenarioId = fixture$ScenarioId,
    AssignmentId = fixture$AssignmentId,
    ReferenceId = fixture$ReferenceId,
    FixtureSeed = fixture$FixtureSeed,
    RNGKind = c("L'Ecuyer-CMRG", "Inversion", "Rejection"),
    StructuralRowsHash = mfrmr_gta_hash(rows),
    FactorSetHash = plan$ReferenceCatalog$FactorSetHash[
      match(fixture$ReferenceId, plan$ReferenceCatalog$ReferenceId)
    ],
    CandidateDataHash = mfrmr_gta_hash(candidate_data),
    TruthAuditHash = mfrmr_gta_hash(truth_audit),
    GeneratedEffectRegistryHash = mfrmr_gta_hash(effect_registry),
    ComponentStateRegistryHash = mfrmr_gta_hash(state_registry)
  )
  structure(list(
    Identity = identity,
    GenerationHash = mfrmr_gta_hash(identity),
    CandidateData = candidate_data,
    TruthAudit = truth_audit,
    GeneratedEffectRegistry = effect_registry,
    ComponentStateRegistry = state_registry,
    FunctionIdentity = function_identity,
    ImplementationIdentityHash = mfrmr_gta_hash(function_identity),
    FixtureOnly = TRUE,
    GeneratorImplementationReady = TRUE,
    FixtureRNGStateHashReady = TRUE,
    CallerRNGRestorationContractReady = TRUE,
    PilotSeedsOpened = FALSE,
    ConfirmationSeedsOpened = FALSE,
    NegativeControlSeedsOpened = FALSE,
    BackendExecutionOccurred = FALSE,
    RecoveryResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  ), class = c("mfrmr_gtve_generation", "list"))
}

mfrmr_gtve_assert_generation <- function(
    generation, plan = mfrmr_gtvd_plan(),
    registry = mfrmr_gtve_fixture_registry(plan)) {
  expected_names <- c(
    "Identity", "GenerationHash", "CandidateData", "TruthAudit",
    "GeneratedEffectRegistry", "ComponentStateRegistry", "FunctionIdentity",
    "ImplementationIdentityHash",
    "FixtureOnly", "GeneratorImplementationReady", "FixtureRNGStateHashReady",
    "CallerRNGRestorationContractReady", "PilotSeedsOpened",
    "ConfirmationSeedsOpened", "NegativeControlSeedsOpened",
    "BackendExecutionOccurred", "RecoveryResponseGenerated",
    "RecoveryExecuted", "RecoveryEvidenceReady", "EstimationReady",
    "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtve_exact_object(
    generation, expected_names, c("mfrmr_gtve_generation", "list")
  )) {
    stop("A canonical Draft.85c2 fixture generation is required.",
         call. = FALSE)
  }
  replay <- mfrmr_gtve_generate_fixture(
    generation$Identity$FixtureId, plan, registry
  )
  if (!identical(generation, replay)) {
    stop("The Draft.85c2 fixture generation or identity was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtve_manifest_payload <- function(
    plan = mfrmr_gtvd_plan(), registry = mfrmr_gtve_fixture_registry(plan)) {
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_fixture_registry(registry, plan)
  generations <- lapply(registry$FixtureId, function(fixture_id) {
    mfrmr_gtve_generate_fixture(fixture_id, plan, registry)
  })
  fixture_replay <- do.call(rbind, lapply(generations, function(generation) {
    identity <- generation$Identity
    data.frame(
      FixtureOrdinal = registry$FixtureOrdinal[
        match(identity$FixtureId, registry$FixtureId)
      ],
      FixtureId = identity$FixtureId,
      ScenarioId = identity$ScenarioId,
      AssignmentId = identity$AssignmentId,
      ReferenceId = identity$ReferenceId,
      FixtureSeed = identity$FixtureSeed,
      RowCount = as.integer(nrow(generation$CandidateData)),
      CandidateDataHash = identity$CandidateDataHash,
      TruthAuditHash = identity$TruthAuditHash,
      ComponentStateRegistryHash = identity$ComponentStateRegistryHash,
      GenerationHash = generation$GenerationHash,
      stringsAsFactors = FALSE
    )
  }))
  row.names(fixture_replay) <- NULL
  states <- do.call(rbind, lapply(generations, `[[`, "ComponentStateRegistry"))
  row.names(states) <- NULL
  implementation <- mfrmr_gtve_function_identity()
  core <- list(
    Contract = "gtheory_multivariate_generator_preflight_draft85c2_v1",
    PlanHash = plan$PlanHash,
    PlanCoreHash = plan$PlanCoreHash,
    FixtureRegistry = registry,
    FixtureReplayRegistry = fixture_replay,
    ComponentStateRegistry = states
  )
  c(core, list(
    ManifestCoreHash = mfrmr_gta_hash(core),
    FixtureRegistryHash = mfrmr_gta_hash(registry),
    FixtureReplayRegistryHash = mfrmr_gta_hash(fixture_replay),
    ComponentStateRegistryHash = mfrmr_gta_hash(states),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gta_hash(implementation)
  ))
}

mfrmr_gtve_manifest <- function(
    plan = mfrmr_gtvd_plan(), registry = mfrmr_gtve_fixture_registry(plan)) {
  payload <- mfrmr_gtve_manifest_payload(plan, registry)
  structure(c(payload, list(
    ManifestHash = mfrmr_gta_hash(payload),
    FixtureCount = as.integer(nrow(payload$FixtureRegistry)),
    StateRowCount = as.integer(nrow(payload$ComponentStateRegistry)),
    GeneratorImplementationReady = TRUE,
    FixtureRNGStateHashReady = TRUE,
    CallerRNGRestorationReady = TRUE,
    PlanSeedIsolationReady = TRUE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    BackendQualificationReady = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtve_manifest", "list"))
}

mfrmr_gtve_assert_manifest <- function(
    manifest, plan = mfrmr_gtvd_plan(),
    registry = mfrmr_gtve_fixture_registry(plan)) {
  payload_names <- mfrmr_gtve_manifest_payload_fields()
  suffix_names <- c(
    "ManifestHash", "FixtureCount", "StateRowCount",
    "GeneratorImplementationReady", "FixtureRNGStateHashReady",
    "CallerRNGRestorationReady", "PlanSeedIsolationReady",
    "PilotExecutionAuthorized", "ConfirmationExecutionAuthorized",
    "BackendQualificationReady", "RecoveryExecuted", "RecoveryEvidenceReady",
    "EstimationReady", "InferenceReady", "DecisionReady", "PublicSupportReady"
  )
  if (!mfrmr_gtve_exact_object(
    manifest, c(payload_names, suffix_names),
    c("mfrmr_gtve_manifest", "list")
  )) {
    stop("A canonical Draft.85c2 generator manifest is required.",
         call. = FALSE)
  }
  exact_state <-
    identical(manifest$FixtureCount, 12L) &&
    identical(manifest$StateRowCount, 48L) &&
    isTRUE(manifest$GeneratorImplementationReady) &&
    isTRUE(manifest$FixtureRNGStateHashReady) &&
    isTRUE(manifest$CallerRNGRestorationReady) &&
    isTRUE(manifest$PlanSeedIsolationReady) &&
    !isTRUE(manifest$PilotExecutionAuthorized) &&
    !isTRUE(manifest$ConfirmationExecutionAuthorized) &&
    !isTRUE(manifest$BackendQualificationReady) &&
    !isTRUE(manifest$RecoveryExecuted) &&
    !isTRUE(manifest$RecoveryEvidenceReady) &&
    !isTRUE(manifest$EstimationReady) &&
    !isTRUE(manifest$InferenceReady) &&
    !isTRUE(manifest$DecisionReady) &&
    !isTRUE(manifest$PublicSupportReady)
  if (!exact_state) {
    stop("The Draft.85c2 generator manifest or readiness was altered.",
         call. = FALSE)
  }
  canonical_payload <- mfrmr_gtve_manifest_payload(plan, registry)
  exact_payload <- identical(unclass(manifest[payload_names]), canonical_payload)
  exact_hash <- identical(
    manifest$ManifestHash, mfrmr_gta_hash(manifest[payload_names])
  )
  literal_roots <- c(
    ManifestCoreHash =
      "eeeb6ca51359909da97fca065233fe44c11ef6b9f324803466a408f0f14b09d2",
    FixtureRegistryHash =
      "28d8203a4372e908c2a62775c0e246b905cb591f5635f83e4745a0bf452f66dd",
    FixtureReplayRegistryHash =
      "824e6fc2f052a5801947a9dbde4020d02ebe608ce8665dbf12b7635c1b7b3b0d",
    ComponentStateRegistryHash =
      "31083ab9ad40cc935e40c6dc8bf26455b1f44bf12c8aa161ba8989c9b92522c6"
  )
  exact_roots <- all(vapply(names(literal_roots), function(name) {
    identical(manifest[[name]], unname(literal_roots[[name]]))
  }, logical(1L)))
  if (!exact_payload || !exact_hash || !exact_roots || !exact_state) {
    stop("The Draft.85c2 generator manifest or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
