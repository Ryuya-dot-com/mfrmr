# One-time generation and semantic review for ConQuest ASP-G3 smoke data.
#
# The eighteen frozen seeds generate one dataset per scenario-family arm. The
# result is written into the six-table schema fixed by the authorization
# contract. No model is fit and ConQuest is not launched. Replay is assessed by
# semantic keys and values rather than file-byte identity.

mfrmr_cq_ase_specification <-
  "0.2.3-conquest-adversarial-simulation-smoke-execution-v1"
mfrmr_cq_ase_contract <-
  "mfrmr_conquest_adversarial_simulation_smoke_execution_v1"
mfrmr_cq_ase_output_basename <-
  "conquest-adversarial-simulation-smoke-20260815-v1"

mfrmr_cq_ase_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_ase_require_contracts <- function() {
  target <- environment(mfrmr_cq_ase_require_contracts)
  ready <- exists(
    "mfrmr_cq_asg_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_asg_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_adversarial_simulation_smoke_authorization_v1"
  ) && exists(
    "mfrmr_cq_asg_review", envir = target, mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_ado_response_from_uniform", envir = target,
    mode = "function", inherits = TRUE
  ) && exists(
    "mfrmr_cq_ast_location_predictor_rank", envir = target,
    mode = "function", inherits = TRUE
  )
  mfrmr_cq_ase_assert(
    ready, "Source the complete ASP G3 authorization dependency chain first."
  )
  invisible(TRUE)
}

mfrmr_cq_ase_rng_contract <- function() {
  data.frame(
    UniformKind = "Mersenne-Twister",
    NormalKind = "Inversion",
    SampleKind = "Rejection",
    LatentUniformsFirst = TRUE,
    ResponseUniformsSecond = TRUE,
    CallerRNGStateRestored = TRUE,
    OpenIntervalRequired = TRUE,
    ReplayIsScientificAcceptanceCriterion = FALSE,
    ByteIdentityIsScientificAcceptanceCriterion = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ase_uniform_stream <- function(seed, latent_count, response_count) {
  seed <- as.integer(seed)[1L]
  latent_count <- as.integer(latent_count)[1L]
  response_count <- as.integer(response_count)[1L]
  mfrmr_cq_ase_assert(
    is.finite(seed) && latent_count > 0L && response_count > 0L,
    "The smoke RNG request is invalid."
  )
  previous_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  previous_seed <- if (had_seed) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else {
    NULL
  }
  on.exit({
    do.call(RNGkind, as.list(previous_kind))
    if (had_seed) {
      assign(".Random.seed", previous_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  RNGkind(
    kind = "Mersenne-Twister", normal.kind = "Inversion",
    sample.kind = "Rejection"
  )
  set.seed(seed)
  latent <- stats::runif(latent_count)
  response <- stats::runif(response_count)
  mfrmr_cq_ase_assert(
    all(latent > 0 & latent < 1) && all(response > 0 & response < 1),
    "The seeded stream produced a value outside the required open interval."
  )
  list(latent = latent, response = response)
}

mfrmr_cq_ase_key <- function(data) {
  paste(data$Person, data$Rater, data$Criterion, sep = "::")
}

mfrmr_cq_ase_decorate_response <- function(
    data, representation_id, allocation, profile_id, latent, response_uniform) {
  person_index <- match(data$Person, latent$Person)
  mfrmr_cq_ase_assert(
    !anyNA(person_index), "A response row has no generated latent value."
  )
  data.frame(
    DatasetId = allocation$DatasetId,
    RepresentationId = representation_id,
    Person = data$Person,
    PersonIndex = data$PersonIndex,
    X = data$X,
    Rater = data$Rater,
    RaterIndex = data$RaterIndex,
    Criterion = data$Criterion,
    CriterionIndex = data$CriterionIndex,
    Response = as.integer(data$Response),
    ResponseObserved = !is.na(data$Response),
    ProfileId = profile_id,
    RecoveryEligible = latent$RecoveryEligible[person_index],
    LatentValue = latent$LatentValue[person_index],
    LatentUniform = latent$SuppliedUniform[person_index],
    ResponseUniform = as.numeric(response_uniform),
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ase_generated_responses <- function(template, truth, latent, uniforms) {
  structure <- template$Data[, setdiff(names(template$Data), "Response"),
                             drop = FALSE]
  latent_index <- match(structure$Person, latent$Person)
  mfrmr_cq_ase_assert(
    !anyNA(latent_index) && length(uniforms) == nrow(structure),
    "The generated response coordinates are incomplete."
  )
  response <- vapply(seq_len(nrow(structure)), function(index) {
    probability <- mfrmr_cq_ado_direct_probability(
      truth,
      latent$LatentValue[latent_index[index]],
      structure$Rater[index],
      structure$Criterion[index]
    )
    mfrmr_cq_ado_response_from_uniform(probability, uniforms[index])
  }, integer(1L))
  if (template$ScenarioClassId ==
      "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY") {
    response[response == 1L] <- 2L
  }
  structure$Response <- response
  structure
}

mfrmr_cq_ase_response_table <- function(
    template, primary, allocation, profile_id, latent, response_uniform) {
  primary_id <- if (
    template$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS"
  ) "planned_absence" else "observed_rows_only"
  out <- list(mfrmr_cq_ase_decorate_response(
    primary, primary_id, allocation, profile_id, latent, response_uniform
  ))
  if (template$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS") {
    companion <- template$ExplicitMissingCompanion[
      , setdiff(names(template$ExplicitMissingCompanion), "Response"),
      drop = FALSE
    ]
    index <- match(mfrmr_cq_ase_key(companion), mfrmr_cq_ase_key(primary))
    companion$Response <- primary$Response[index]
    companion_uniform <- response_uniform[index]
    out[[2L]] <- mfrmr_cq_ase_decorate_response(
      companion, "explicit_missing", allocation, profile_id, latent,
      companion_uniform
    )
  }
  do.call(rbind, out)
}

mfrmr_cq_ase_structural_disposition <- function(
    template, primary, allocation) {
  generated <- template
  generated$Data <- primary
  rank <- mfrmr_cq_ast_location_predictor_rank(generated)
  count <- tabulate(primary$Response + 1L, nbins = 4L)
  scenario <- template$ScenarioClassId
  if (scenario == "ASP-NEG-UNUSED-INTERMEDIATE-CATEGORY") {
    observed <- if (count[2L] == 0L) {
      "reject_before_numeric_comparison"
    } else {
      "unexpected_eligible_support"
    }
    reason <- if (count[2L] == 0L) {
      "declared_intermediate_category_globally_unused"
    } else {
      "unused_category_negative_control_failed"
    }
  } else if (scenario == "ASP-NEG-DISCONNECTED-DESIGN") {
    observed <- if (rank$Rank < rank$Dimension) {
      "reject_before_numeric_comparison"
    } else {
      "unexpected_full_rank"
    }
    reason <- if (rank$Rank < rank$Dimension) {
      "full_population_location_predictor_rank_deficient"
    } else {
      "disconnected_negative_control_rank_failure_absent"
    }
  } else if (rank$Rank < rank$Dimension) {
    observed <- "unexpected_rank_rejection"
    reason <- "positive_or_sensitivity_arm_rank_deficient"
  } else if (any(count == 0L)) {
    observed <- "unexpected_support_rejection"
    reason <- "positive_or_sensitivity_arm_has_unused_declared_category"
  } else {
    observed <- "eligible_numeric_comparison"
    reason <- "full_rank_and_all_declared_categories_observed"
  }
  expected_observed <- if (
    allocation$ExpectedDisposition == "reject_before_numeric_comparison"
  ) "reject_before_numeric_comparison" else "eligible_numeric_comparison"
  data.frame(
    DatasetId = allocation$DatasetId,
    ExpectedDisposition = expected_observed,
    ObservedDisposition = observed,
    DispositionReason = reason,
    PredictorDimension = rank$Dimension,
    PredictorRank = rank$Rank,
    SupportBoundaryStatus = paste0(
      "category_counts=", paste(count, collapse = ";")
    ),
    NumericalComparisonPermitted = observed == "eligible_numeric_comparison",
    DispositionMatchesExpected = observed == expected_observed,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ase_engine_outcome <- function(allocation) {
  data.frame(
    DatasetId = allocation$DatasetId,
    Engine = c("mfrmr", "ConQuest"),
    AttemptRequired = FALSE,
    Attempted = FALSE,
    ReturnStatus = "not_attempted_generation_only",
    FailureClass = "not_applicable_fit_not_authorized",
    NativeVersion = NA_character_,
    Platform = NA_character_,
    ElapsedSeconds = NA_real_,
    EligibleForNumericComparison = FALSE,
    RetainedInUnconditionalDenominator = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ase_metric_outcome <- function(allocation) {
  metric <- mfrmr_cq_asg_metric_schema_map()
  engine <- ifelse(
    metric$MetricId == "ASP-CONQUEST-EXECUTION", "ConQuest",
    ifelse(metric$MetricId == "ASP-MFRMR-EXECUTION", "mfrmr", "joint")
  )
  data.frame(
    DatasetId = allocation$DatasetId,
    MetricId = metric$MetricId,
    Engine = engine,
    Coordinate = "not_evaluated",
    Estimate = NA_real_,
    Truth = NA_real_,
    Error = NA_real_,
    Eligibility = "not_evaluated_smoke_generation_only",
    IneligibilityReason = "fit_and_metric_evaluation_not_authorized",
    PrimaryDenominator = metric$PrimaryDenominator,
    UnconditionalCompanionCount = 1L,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ase_continuous_outcome <- function(allocation) {
  data.frame(
    DatasetId = allocation$DatasetId,
    Engine = c("mfrmr", "ConQuest"),
    QuadratureId = "not_evaluated",
    Deviance = NA_real_,
    OracleDeviance = NA_real_,
    AbsoluteError = NA_real_,
    NumericalErrorEstimate = NA_real_,
    OmittedTailAnalyticBound = NA_real_,
    Eligibility = "not_evaluated_smoke_generation_only",
    IneligibilityReason = "fit_and_continuous_comparison_not_authorized",
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_ase_generate_arm <- function(allocation) {
  mfrmr_cq_ase_require_contracts()
  mfrmr_cq_ase_assert(
    is.data.frame(allocation) && nrow(allocation) == 1L &&
      !isTRUE(allocation$Generated) && !isTRUE(allocation$ResultOpened),
    "Smoke generation requires one sealed allocation row."
  )
  template <- mfrmr_cq_ast_template(allocation$ArmId)
  mapping <- mfrmr_cq_ado_scenario_map()
  profile <- mapping$ProfileId[
    mapping$ScenarioClassId == template$ScenarioClassId
  ]
  truth <- mfrmr_cq_ado_truth(profile, template$Family)
  person_count <- length(unique(template$Data$Person))
  stream <- mfrmr_cq_ase_uniform_stream(
    allocation$Seed, person_count, nrow(template$Data)
  )
  latent <- mfrmr_cq_ado_latent_from_uniform(template, stream$latent)
  primary <- mfrmr_cq_ase_generated_responses(
    template, truth, latent, stream$response
  )
  response <- mfrmr_cq_ase_response_table(
    template, primary, allocation, profile, latent, stream$response
  )
  count <- tabulate(primary$Response + 1L, nbins = 4L)
  structural <- mfrmr_cq_ase_structural_disposition(
    template, primary, allocation
  )
  prototype_different <- !identical(
    as.integer(primary$Response), as.integer(template$Data$Response)
  )
  manifest <- data.frame(
    ProgramSpecification = mfrmr_cq_asp_specification,
    SmokeContract = mfrmr_cq_ase_contract,
    Phase = allocation$Phase,
    DatasetId = allocation$DatasetId,
    ArmId = allocation$ArmId,
    ScenarioClassId = allocation$ScenarioClassId,
    Family = allocation$Family,
    Replicate = allocation$Replicate,
    Seed = allocation$Seed,
    ProfileId = profile,
    ExpectedStructuralDisposition = structural$ExpectedDisposition,
    GenerationStatus = "generated_and_retained",
    ObservedRows = nrow(primary),
    Persons = person_count,
    Category0 = count[1L],
    Category1 = count[2L],
    Category2 = count[3L],
    Category3 = count[4L],
    RecoveryEligible = all(latent$RecoveryEligible),
    EvaluationUse = allocation$EvaluationUse,
    RetainedInUnconditionalDenominator = TRUE,
    PrototypeResponseVectorReused = !prototype_different,
    SmokeResultCanTuneDesign = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    dataset_manifest = manifest,
    response_data = response,
    structural_disposition = structural,
    engine_outcome = mfrmr_cq_ase_engine_outcome(allocation),
    metric_outcome = mfrmr_cq_ase_metric_outcome(allocation),
    continuous_oracle = mfrmr_cq_ase_continuous_outcome(allocation)
  )
}

mfrmr_cq_ase_bind_arms <- function(arms) {
  table_ids <- mfrmr_cq_asg_output_schema_registry()$TableId
  out <- lapply(table_ids, function(table_id) {
    rows <- lapply(arms, `[[`, table_id)
    value <- do.call(rbind, rows)
    rownames(value) <- NULL
    value
  })
  names(out) <- table_ids
  out
}

mfrmr_cq_ase_generate_all <- function() {
  authorization <- mfrmr_cq_asg_review(run_full_continuous_oracle = TRUE)
  mfrmr_cq_ase_assert(
    isTRUE(authorization$G3_authorization_complete) &&
      isTRUE(authorization$smoke_dataset_generation_authorized) &&
      authorization$authorized_smoke_datasets == 18L &&
      authorization$maximum_datasets_per_arm == 1L &&
      !isTRUE(authorization$any_fit_authorized) &&
      !isTRUE(authorization$ConQuest_execution_authorized),
    "The G3 contract does not authorize the bounded smoke generation."
  )
  allocation <- authorization$seed_registry
  arms <- lapply(seq_len(nrow(allocation)), function(index) {
    mfrmr_cq_ase_generate_arm(allocation[index, , drop = FALSE])
  })
  out <- mfrmr_cq_ase_bind_arms(arms)
  out$execution_metadata <- list(
    Specification = mfrmr_cq_ase_specification,
    Contract = mfrmr_cq_ase_contract,
    RNGContract = mfrmr_cq_ase_rng_contract(),
    GeneratedDatasets = nrow(out$dataset_manifest),
    AnyFitAttempted = FALSE,
    ConQuestExecutionAttempted = FALSE,
    OperatingCharacteristicsEstimated = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
  out
}

mfrmr_cq_ase_primary_key_unique <- function(data, key) {
  columns <- strsplit(key, ";", fixed = TRUE)[[1L]]
  if (!all(columns %in% names(data))) return(FALSE)
  value <- do.call(paste, c(data[columns], sep = "\r"))
  !anyDuplicated(value)
}

mfrmr_cq_ase_validate_tables <- function(tables) {
  schema <- mfrmr_cq_asg_output_schema_registry()
  table_ids <- schema$TableId
  available <- all(vapply(
    table_ids, function(value) is.data.frame(tables[[value]]), logical(1L)
  ))
  if (!available) return(FALSE)
  columns <- vapply(seq_len(nrow(schema)), function(index) {
    required <- strsplit(
      schema$RequiredColumns[index], ";", fixed = TRUE
    )[[1L]]
    all(required %in% names(tables[[schema$TableId[index]]]))
  }, logical(1L))
  keys <- vapply(seq_len(nrow(schema)), function(index) {
    mfrmr_cq_ase_primary_key_unique(
      tables[[schema$TableId[index]]], schema$PrimaryKey[index]
    )
  }, logical(1L))
  manifest <- tables$dataset_manifest
  structural <- tables$structural_disposition
  response <- tables$response_data
  # Dataset IDs are numeric smoke labels; identify paired arms by the manifest.
  paired_ids <- manifest$DatasetId[
    manifest$ScenarioClassId == "ASP-INV-PAIRED-MISSINGNESS"
  ]
  paired <- response[response$DatasetId %in% paired_ids, , drop = FALSE]
  paired_equivalent <- all(vapply(paired_ids, function(dataset_id) {
    current <- paired[paired$DatasetId == dataset_id, , drop = FALSE]
    absent <- current[
      current$RepresentationId == "planned_absence", , drop = FALSE
    ]
    explicit <- current[
      current$RepresentationId == "explicit_missing" &
        current$ResponseObserved, , drop = FALSE
    ]
    absent <- absent[order(mfrmr_cq_ase_key(absent)), , drop = FALSE]
    explicit <- explicit[order(mfrmr_cq_ase_key(explicit)), , drop = FALSE]
    identical(mfrmr_cq_ase_key(absent), mfrmr_cq_ase_key(explicit)) &&
      identical(absent$Response, explicit$Response)
  }, logical(1L)))
  available && all(columns) && all(keys) &&
    nrow(manifest) == 18L && !anyDuplicated(manifest$DatasetId) &&
    !anyDuplicated(manifest$ArmId) &&
    identical(sort(manifest$Seed), 987001:987018) &&
    all(manifest$GenerationStatus == "generated_and_retained") &&
    all(manifest$RetainedInUnconditionalDenominator) &&
    !any(manifest$PrototypeResponseVectorReused) &&
    !any(manifest$SmokeResultCanTuneDesign) &&
    nrow(structural) == 18L && all(structural$DispositionMatchesExpected) &&
    paired_equivalent &&
    nrow(tables$engine_outcome) == 36L &&
    !any(tables$engine_outcome$Attempted) &&
    all(tables$engine_outcome$RetainedInUnconditionalDenominator) &&
    nrow(tables$metric_outcome) == 216L &&
    all(is.na(tables$metric_outcome$Estimate)) &&
    nrow(tables$continuous_oracle) == 36L &&
    all(is.na(tables$continuous_oracle$Deviance))
}

mfrmr_cq_ase_write_csv <- function(value, path) {
  utils::write.csv(value, path, row.names = FALSE, na = "")
  invisible(path)
}

mfrmr_cq_ase_execute <- function(output_dir, authorize = FALSE) {
  mfrmr_cq_ase_require_contracts()
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_ase_assert(
    isTRUE(authorize), "Smoke generation requires explicit `authorize=TRUE`."
  )
  mfrmr_cq_ase_assert(
    identical(basename(output_dir), mfrmr_cq_ase_output_basename),
    "The smoke output directory basename is not the frozen target."
  )
  staging <- paste0(output_dir, ".incomplete")
  mfrmr_cq_ase_assert(
    !file.exists(output_dir) && !dir.exists(output_dir) &&
      !file.exists(staging) && !dir.exists(staging),
    "The frozen smoke output target or staging directory already exists."
  )
  tables <- mfrmr_cq_ase_generate_all()
  mfrmr_cq_ase_assert(
    mfrmr_cq_ase_validate_tables(tables),
    "The generated smoke tables failed their semantic schema contract."
  )
  mfrmr_cq_ase_assert(
    dir.create(staging, recursive = TRUE, showWarnings = FALSE),
    "The smoke staging directory could not be created."
  )
  table_ids <- mfrmr_cq_asg_output_schema_registry()$TableId
  for (table_id in table_ids) {
    mfrmr_cq_ase_write_csv(
      tables[[table_id]], file.path(staging, paste0(table_id, ".csv"))
    )
  }
  saveRDS(tables, file.path(staging, "smoke_result.rds"), version = 3)
  mfrmr_cq_ase_assert(
    file.rename(staging, output_dir),
    "The smoke staging directory could not be committed atomically."
  )
  mfrmr_cq_ase_review_output(output_dir)
}

mfrmr_cq_ase_read_tables <- function(output_dir) {
  schema <- mfrmr_cq_asg_output_schema_registry()
  out <- lapply(schema$TableId, function(table_id) {
    utils::read.csv(
      file.path(output_dir, paste0(table_id, ".csv")),
      stringsAsFactors = FALSE, check.names = FALSE
    )
  })
  names(out) <- schema$TableId
  out
}

mfrmr_cq_ase_semantic_replay_match <- function(observed, replay) {
  observed_response <- observed$response_data[order(
    observed$response_data$DatasetId,
    observed$response_data$RepresentationId,
    observed$response_data$PersonIndex,
    observed$response_data$RaterIndex,
    observed$response_data$CriterionIndex
  ), , drop = FALSE]
  replay_response <- replay$response_data[order(
    replay$response_data$DatasetId,
    replay$response_data$RepresentationId,
    replay$response_data$PersonIndex,
    replay$response_data$RaterIndex,
    replay$response_data$CriterionIndex
  ), , drop = FALSE]
  key_columns <- c(
    "DatasetId", "RepresentationId", "Person", "PersonIndex", "X", "Rater",
    "RaterIndex", "Criterion", "CriterionIndex", "Response",
    "ResponseObserved", "ProfileId", "RecoveryEligible"
  )
  numeric_columns <- c("LatentValue", "LatentUniform", "ResponseUniform")
  identical(
    observed_response[, key_columns, drop = FALSE],
    replay_response[, key_columns, drop = FALSE]
  ) && isTRUE(all.equal(
    observed_response[, numeric_columns, drop = FALSE],
    replay_response[, numeric_columns, drop = FALSE],
    tolerance = 1e-14, check.attributes = FALSE
  ))
}

mfrmr_cq_ase_review_output <- function(output_dir) {
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = TRUE
  )
  schema <- mfrmr_cq_asg_output_schema_registry()
  expected <- c(paste0(schema$TableId, ".csv"), "smoke_result.rds")
  present <- list.files(output_dir, all.files = FALSE, no.. = TRUE)
  files_complete <- setequal(present, expected)
  observed <- mfrmr_cq_ase_read_tables(output_dir)
  replay <- mfrmr_cq_ase_generate_all()
  tables_valid <- mfrmr_cq_ase_validate_tables(observed)
  replay_match <- mfrmr_cq_ase_semantic_replay_match(observed, replay)
  manifest <- observed$dataset_manifest
  structural <- observed$structural_disposition
  list(
    specification = mfrmr_cq_ase_specification,
    contract_version = mfrmr_cq_ase_contract,
    status = if (files_complete && tables_valid && replay_match) {
      "ASP_G3_eighteen_smoke_datasets_generated_and_retained"
    } else {
      "ASP_G3_smoke_execution_or_semantic_replay_failed"
    },
    output_dir = output_dir,
    files_complete = files_complete,
    tables_valid = tables_valid,
    semantic_replay_match = replay_match,
    generated_datasets = nrow(manifest),
    unique_arms = length(unique(manifest$ArmId)),
    seeds = sort(manifest$Seed),
    response_table_rows = nrow(observed$response_data),
    structural_dispositions_match = all(
      structural$DispositionMatchesExpected
    ),
    eligible_structural_arms = sum(
      structural$ObservedDisposition == "eligible_numeric_comparison"
    ),
    rejected_structural_arms = sum(
      structural$ObservedDisposition == "reject_before_numeric_comparison"
    ),
    prototype_response_vectors_reused = sum(
      manifest$PrototypeResponseVectorReused
    ),
    retained_unconditional_arms = sum(
      manifest$RetainedInUnconditionalDenominator
    ),
    fit_attempts = sum(observed$engine_outcome$Attempted),
    ConQuest_execution_attempted = FALSE,
    operating_characteristics_estimated = FALSE,
    result_used_to_tune_design = FALSE,
    G3_smoke_execution_complete = files_complete && tables_valid && replay_match,
    G3_complete = files_complete && tables_valid && replay_match,
    next_gate = "ASP-G4-CALIBRATION-FREEZE",
    public_text_change_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
