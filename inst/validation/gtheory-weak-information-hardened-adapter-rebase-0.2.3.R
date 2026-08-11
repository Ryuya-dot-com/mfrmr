# Draft.83d2b2b1g18 nonreserved hardened production-adapter rebase.
#
# Repository-internal only. Historical b1g14 functions and identities remain
# unchanged. This descendant path uses the b1g17 RNG-hardened generator and
# cannot access calibration or confirmation replicates.

mfrmr_gtwam_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwag_expected_candidate_rows",
    "mfrmr_gtwag_execute", "mfrmr_gtwag_manifest_hash_valid",
    "mfrmr_gtwah_candidate_evaluator", "mfrmr_gtwah_reference_evaluator",
    "mfrmr_gtwah_lme4_fit", "mfrmr_gtwah_glmm_fit",
    "mfrmr_gtwah_curvature_state", "mfrmr_gtwah_glmm_reference",
    "mfrmr_gtwah_lme4_reference", "mfrmr_gtwah_authorized_for_unit",
    "mfrmr_gtwal_generate", "mfrmr_gtwal_generation_hash_valid",
    "mfrmr_gtwal_contract_hash_valid", "mfrmr_gtwal_audit_hash_valid",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwaa_select_profile", "mfrmr_gtwaf_probe_lme4",
    "mfrmr_gtwaf_probe_glmmtmb", "mfrmr_gtw_registry"
  )
  audit_environment <- environment(mfrmr_gtwam_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g17 chain before the b1g18 adapter rebase: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwam_function_hash <- function(fun) {
  mfrmr_gta_hash(list(
    Formals = paste(deparse(formals(fun), width.cutoff = 500L), collapse = "\n"),
    Body = paste(deparse(body(fun), width.cutoff = 500L), collapse = "\n")
  ))
}

mfrmr_gtwam_policy <- function() {
  identity <- list(
    Contract = "hardened_adapter_rebase_policy_b1g18_v1",
    ParentAdapterContractHash =
      "baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1",
    HardenedGeneratorContractHash =
      "90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2",
    HardenedGeneratorAuditHash =
      "918e7da5e0ba484bbdef4251965c25ff31c5d4a39be237c3d218ed47fceae397",
    DryRunScenarioId = "GT-WI-baseline_complete-reference_1200",
    DryRunReplicate = 902L,
    RequiredMethodIds = c(
      "glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml"
    ),
    ReservedCalibrationReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    HistoricalAdapterMustRemainUnmodified = TRUE,
    CandidateReferenceGeneratorIdentityMustMatch = TRUE,
    HistoricalAndHardenedAnalysisDataMustMatch = TRUE,
    CompleteFailureDenominatorRequired = TRUE,
    NonreservedOnly = TRUE,
    ReservedManifestRebaseDeferred = TRUE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwam_policy")
}

mfrmr_gtwam_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwam_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity)) &&
    identical(policy$Contract, "hardened_adapter_rebase_policy_b1g18_v1") &&
    identical(policy$DryRunReplicate, 902L) &&
    identical(policy$ReservedCalibrationReplicates, 201:300) &&
    identical(policy$ConfirmationReplicates, 501:700) &&
    isTRUE(policy$HistoricalAdapterMustRemainUnmodified) &&
    isTRUE(policy$CandidateReferenceGeneratorIdentityMustMatch) &&
    isTRUE(policy$HistoricalAndHardenedAnalysisDataMustMatch) &&
    isTRUE(policy$CompleteFailureDenominatorRequired) &&
    isTRUE(policy$NonreservedOnly) &&
    isTRUE(policy$ReservedManifestRebaseDeferred) &&
    !isTRUE(policy$CalibrationResponsesUsed) &&
    !isTRUE(policy$ConfirmationResponsesUsed)
}

mfrmr_gtwam_prepare_unit <- function(
    contract, unit, registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwam_contract") ||
      !is.data.frame(unit) || nrow(unit) != 1L ||
      !all(c(
        "AtomicUnitId", "DatasetId", "ScenarioId", "Replicate",
        "MethodId", "Backend", "Likelihood"
      ) %in% names(unit)) || !inherits(registry, "mfrmr_gtw_registry")) {
    stop("The exact b1g18 contract and one atomic unit are required.",
         call. = FALSE)
  }
  policy <- contract$HardenedAdapterPolicy
  replicate <- as.integer(unit$Replicate[[1L]])
  if (replicate %in% c(
    policy$ReservedCalibrationReplicates, policy$ConfirmationReplicates
  )) {
    stop("The b1g18 nonreserved adapter cannot open a reserved replicate.",
         call. = FALSE)
  }
  method <- unit$MethodId[[1L]]
  expected_backend <- if (grepl("^glmmTMB_", method)) "glmmTMB" else "lme4"
  expected_likelihood <- if (grepl("_reml$", method)) "REML" else "ML"
  expected_dataset <- sprintf(
    "%s/R%04d", unit$ScenarioId[[1L]], replicate
  )
  if (!identical(unit$Backend[[1L]], expected_backend) ||
      !identical(unit$Likelihood[[1L]], expected_likelihood) ||
      !identical(unit$DatasetId[[1L]], expected_dataset) ||
      !method %in% policy$RequiredMethodIds ||
      !unit$ScenarioId[[1L]] %in% registry$Cells$ScenarioId) {
    stop("The atomic unit method or dataset identity is inconsistent.",
         call. = FALSE)
  }
  generation <- mfrmr_gtwal_generate(
    registry, unit$ScenarioId[[1L]], replicate,
    contract$HardenedGeneratorPolicy
  )
  if (!mfrmr_gtwal_generation_hash_valid(generation) ||
      !identical(
        generation$GeneratorIdentity$AnalysisDataHash,
        generation$HistoricalGeneratorIdentity$AnalysisDataHash
      )) {
    stop("Hardened generation failed exact historical-data reduction.",
         call. = FALSE)
  }
  prefit <- mfrmr_gtd3_prefit_one(generation)
  if (!isTRUE(prefit$PreFitEligible)) {
    stop("The hardened adapter received a pre-fit-ineligible unit.",
         call. = FALSE)
  }
  list(
    Generation = generation, PreFit = prefit,
    Data = prefit$StructuralRankAudit$PreparedData$Data,
    GeneratorHash = generation$GeneratorHash,
    HistoricalGeneratorHash = generation$HistoricalGeneratorHash,
    AnalysisDataHash = generation$GeneratorIdentity$AnalysisDataHash,
    HistoricalAnalysisDataHash =
      generation$HistoricalGeneratorIdentity$AnalysisDataHash,
    PreFitHash = prefit$ResultHash
  )
}

mfrmr_gtwam_candidate_evaluator <- function(contract, unit) {
  prepared <- mfrmr_gtwam_prepare_unit(contract, unit)
  rows <- mfrmr_gtwag_expected_candidate_rows(contract, unit)
  generation <- prepared$Generation
  formulas <- list(
    full = stats::as.formula(generation$Spec$FormulaCanonical),
    reduced = mfrmr_gtwd_reduced_formula(
      generation$Spec, contract$AdapterPolicy$TargetComponent
    )
  )
  reml <- identical(unit$Likelihood[[1L]], "REML")
  backend <- unit$Backend[[1L]]
  profile_rows <- contract$Profiles[
    contract$Profiles$Backend == backend, , drop = FALSE
  ]
  results <- list()
  for (role in names(formulas)) {
    role_results <- list()
    for (index in seq_len(nrow(profile_rows))) {
      profile <- profile_rows[index, , drop = FALSE]
      if (backend == "lme4") {
        result <- mfrmr_gtwah_lme4_fit(
          formulas[[role]], prepared$Data, reml, profile$ProfileId[[1L]]
        )
      } else {
        parent <- if (profile$ParentProfileId[[1L]] == "none") NULL else
          role_results[[profile$ParentProfileId[[1L]]]]
        result <- mfrmr_gtwah_glmm_fit(
          formulas[[role]], prepared$Data, reml, profile, parent, contract
        )
      }
      role_results[[profile$ProfileId[[1L]]]] <- result
    }
    results[[role]] <- role_results
  }
  rows$FitReturned <- FALSE
  rows$Objective <- NA_real_
  rows$objective_parameter_relative_max <- NA_real_
  rows$lme4_minimum_gradient_max <- NA_real_
  rows$newton_decrement <- NA_real_
  rows$CurvatureState <- "not_evaluable"
  rows$BoundaryProbeState <- "not_run"
  rows$BoundaryProbeHash <- "not_applicable"
  rows$FailureStage <- "none"
  rows$FailureMessageDigest <- "none"
  rows$GeneratorHash <- prepared$GeneratorHash
  rows$PreFitHash <- prepared$PreFitHash
  rows$ScoreSidecarHash <- "none"
  rows$OptimizerCode <- NA_integer_
  for (index in seq_len(nrow(rows))) {
    result <- results[[rows$ModelRole[[index]]]][[
      rows$ProfileId[[index]]
    ]]
    rows$FitReturned[[index]] <- isTRUE(result$Returned)
    rows$Objective[[index]] <- result$Objective
    rows$objective_parameter_relative_max[[index]] <-
      result$Metrics$ObjectiveRelativeParameterScaledMaximumAbsolute
    rows$lme4_minimum_gradient_max[[index]] <-
      result$Metrics$Lme4MinimumGradientMaximumAbsolute
    rows$newton_decrement[[index]] <- result$Metrics$NewtonDecrement
    rows$CurvatureState[[index]] <- mfrmr_gtwah_curvature_state(
      result$Metrics
    )
    rows$FailureStage[[index]] <- result$FailureStage
    rows$FailureMessageDigest[[index]] <- result$FailureDigest
    rows$ScoreSidecarHash[[index]] <- result$SidecarHash
    rows$OptimizerCode[[index]] <- result$OptimizerCode
  }
  selections <- lapply(contract$Policy$ModelRoles, function(role) {
    mfrmr_gtwaa_select_profile(
      rows[rows$ModelRole == role, , drop = FALSE],
      backend, contract$Profiles
    )
  })
  names(selections) <- contract$Policy$ModelRoles
  full_id <- selections$full$SelectedProfileId[[1L]]
  reduced_id <- selections$reduced$SelectedProfileId[[1L]]
  selected_index <- which(
    rows$ModelRole == "full" & rows$ProfileId == full_id
  )
  if (length(selected_index) == 1L && full_id != "none" &&
      reduced_id != "none") {
    full <- results$full[[full_id]]
    reduced <- results$reduced[[reduced_id]]
    probe <- tryCatch({
      if (backend == "lme4") {
        full_result <- list(
          Fit = full$Fit,
          Devfun = lme4::lmer(
            formulas$full, data = prepared$Data, REML = reml,
            control = lme4::lmerControl(calc.derivs = FALSE),
            devFunOnly = TRUE
          ),
          Criterion = full$Objective
        )
        reduced_result <- list(
          Fit = reduced$Fit, Devfun = NULL, Criterion = reduced$Objective
        )
        mfrmr_gtwaf_probe_lme4(
          full_result, reduced_result,
          target = contract$AdapterPolicy$TargetComponent,
          policy = contract$BoundaryPolicy
        )
      } else {
        mfrmr_gtwaf_probe_glmmtmb(
          list(Fit = full$Fit), list(Fit = reduced$Fit),
          target = contract$AdapterPolicy$TargetComponent,
          policy = contract$BoundaryPolicy
        )
      }
    }, error = function(error) error)
    if (inherits(probe, "error")) {
      rows$BoundaryProbeState[[selected_index]] <- "not_evaluable"
      rows$BoundaryProbeHash[[selected_index]] <- mfrmr_gta_hash(list(
        Stage = "production_boundary_probe",
        Message = conditionMessage(probe)
      ))
    } else {
      rows$BoundaryProbeState[[selected_index]] <- probe$State
      rows$BoundaryProbeHash[[selected_index]] <- probe$ProbeHash
    }
  } else {
    rows$BoundaryProbeState[rows$ModelRole == "full"] <- "not_evaluable"
    rows$BoundaryProbeHash[rows$ModelRole == "full"] <- "none"
  }
  rows
}

mfrmr_gtwam_reference_evaluator <- function(contract, unit) {
  prepared <- mfrmr_gtwam_prepare_unit(contract, unit)
  generation <- prepared$Generation
  formulas <- list(
    full = stats::as.formula(generation$Spec$FormulaCanonical),
    reduced = mfrmr_gtwd_reduced_formula(
      generation$Spec, contract$AdapterPolicy$TargetComponent
    )
  )
  outputs <- if (unit$Backend[[1L]] == "glmmTMB") {
    mfrmr_gtwah_glmm_reference(contract, unit, prepared, formulas)
  } else {
    mfrmr_gtwah_lme4_reference(contract, unit, prepared, formulas)
  }
  roles <- contract$Policy$ModelRoles
  data.frame(
    AtomicUnitId = unit$AtomicUnitId[[1L]],
    ObservationId = paste(unit$AtomicUnitId[[1L]], roles, sep = "::"),
    ScenarioId = unit$ScenarioId[[1L]], MethodId = unit$MethodId[[1L]],
    ModelRole = roles,
    ReferenceState = vapply(outputs[roles], `[[`, character(1L), "State"),
    ReferenceSidecarHash = vapply(
      outputs[roles], `[[`, character(1L), "SidecarHash"
    ),
    FailureStage = vapply(
      outputs[roles], `[[`, character(1L), "FailureStage"
    ),
    FailureMessageDigest = vapply(
      outputs[roles], `[[`, character(1L), "FailureDigest"
    ),
    GeneratorHash = prepared$GeneratorHash,
    PreFitHash = prepared$PreFitHash,
    Backend = unit$Backend[[1L]], Likelihood = unit$Likelihood[[1L]],
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwam_adapter_hashes <- function() {
  c(
    CandidateEvaluator =
      mfrmr_gtwag_function_hash(mfrmr_gtwam_candidate_evaluator),
    ReferenceEvaluator =
      mfrmr_gtwag_function_hash(mfrmr_gtwam_reference_evaluator)
  )
}

mfrmr_gtwam_dependency_hashes <- function() {
  functions <- list(
    prepare_unit = mfrmr_gtwam_prepare_unit,
    hardened_generate = mfrmr_gtwal_generate,
    generation_validator = mfrmr_gtwal_generation_hash_valid,
    lme4_fit = mfrmr_gtwah_lme4_fit,
    glmmtmb_fit = mfrmr_gtwah_glmm_fit,
    glmmtmb_reference = mfrmr_gtwah_glmm_reference,
    lme4_reference = mfrmr_gtwah_lme4_reference
  )
  vapply(functions, mfrmr_gtwam_function_hash, character(1L))
}

mfrmr_gtwam_contract <- function(
    parent_adapter_contract, hardened_generator_contract,
    hardened_generator_audit) {
  mfrmr_gtwam_require_primitives()
  policy <- mfrmr_gtwam_policy()
  if (!inherits(parent_adapter_contract, "mfrmr_gtwah_contract") ||
      !identical(parent_adapter_contract$ContractHash,
                 policy$ParentAdapterContractHash) ||
      !mfrmr_gtwal_contract_hash_valid(hardened_generator_contract) ||
      !identical(hardened_generator_contract$ContractHash,
                 policy$HardenedGeneratorContractHash) ||
      !mfrmr_gtwal_audit_hash_valid(hardened_generator_audit) ||
      !identical(hardened_generator_audit$AuditHash,
                 policy$HardenedGeneratorAuditHash) ||
      isTRUE(parent_adapter_contract$CalibrationExecutionAuthorized)) {
    stop("Exact non-authorizing b1g14 and b1g17 parents are required.",
         call. = FALSE)
  }
  adapter_hashes <- mfrmr_gtwam_adapter_hashes()
  dependency_hashes <- mfrmr_gtwam_dependency_hashes()
  identity <- list(
    Contract = "hardened_production_adapter_contract_b1g18_v1",
    ParentAdapterContractHash = parent_adapter_contract$ContractHash,
    HardenedGeneratorContractHash = hardened_generator_contract$ContractHash,
    HardenedGeneratorAuditHash = hardened_generator_audit$AuditHash,
    HardenedGeneratorPolicy = hardened_generator_contract$Policy,
    HardenedAdapterPolicy = policy,
    ParentAdapterHashes = parent_adapter_contract$AdapterHashes,
    AdapterHashes = adapter_hashes,
    AdapterDependencyHashes = dependency_hashes
  )
  base <- unclass(parent_adapter_contract)
  for (name in unique(c(
    names(identity), "Contract", "ContractHash", "AdapterHashes",
    "AdapterDependencyHashes", "ProductionEvaluatorAdaptersFrozen",
    "ProductionAdapterPreflightReady", "CalibrationAuthorizationReady",
    "CalibrationExecutionAuthorized", "CalibrationDataGenerated",
    "CalibrationResultsViewed", "ConfirmationAuthorized", "InferenceReady",
    "CoefficientEligible", "DecisionReady"
  ))) base[[name]] <- NULL
  structure(c(base, identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    HistoricalAdapterPreserved = TRUE,
    NonreservedHardenedAdaptersFrozen = TRUE,
    NonreservedAdapterRebaseReady = FALSE,
    ReservedAdapterEntryPointReady = FALSE,
    ReservedRunManifestFrozen = FALSE,
    AuthorizationRNG01Closed = FALSE,
    ProductionEvaluatorAdaptersFrozen = TRUE,
    ProductionAdapterPreflightReady = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = c(
    "mfrmr_gtwam_contract", "mfrmr_gtwah_contract",
    "mfrmr_gtwag_contract"
  ))
}

mfrmr_gtwam_contract_hash_valid <- function(contract) {
  fields <- c(
    "Contract", "ParentAdapterContractHash", "HardenedGeneratorContractHash",
    "HardenedGeneratorAuditHash", "HardenedGeneratorPolicy",
    "HardenedAdapterPolicy", "ParentAdapterHashes", "AdapterHashes",
    "AdapterDependencyHashes"
  )
  inherits(contract, "mfrmr_gtwam_contract") &&
    all(fields %in% names(contract)) &&
    identical(contract$ContractHash, mfrmr_gta_hash(contract[fields])) &&
    mfrmr_gtwam_policy_hash_valid(contract$HardenedAdapterPolicy) &&
    mfrmr_gtwal_policy_hash_valid(contract$HardenedGeneratorPolicy) &&
    identical(contract$AdapterHashes, mfrmr_gtwam_adapter_hashes()) &&
    identical(contract$AdapterDependencyHashes,
              mfrmr_gtwam_dependency_hashes()) &&
    isTRUE(contract$HistoricalAdapterPreserved) &&
    isTRUE(contract$NonreservedHardenedAdaptersFrozen) &&
    !isTRUE(contract$NonreservedAdapterRebaseReady) &&
    !isTRUE(contract$ReservedAdapterEntryPointReady) &&
    !isTRUE(contract$AuthorizationRNG01Closed) &&
    !isTRUE(contract$CalibrationExecutionAuthorized) &&
    !isTRUE(contract$ConfirmationAuthorized) &&
    !isTRUE(contract$InferenceReady) && !isTRUE(contract$DecisionReady)
}

mfrmr_gtwam_dry_manifest <- function(contract) {
  if (!mfrmr_gtwam_contract_hash_valid(contract)) {
    stop("The exact b1g18 contract is required.", call. = FALSE)
  }
  policy <- contract$HardenedAdapterPolicy
  lanes <- unique(contract$ReferenceReceipts[c("MethodId", "Backend")])
  lanes <- lanes[match(policy$RequiredMethodIds, lanes$MethodId), , drop = FALSE]
  dataset_id <- sprintf(
    "%s/R%04d", policy$DryRunScenarioId, policy$DryRunReplicate
  )
  units <- data.frame(
    AtomicUnitId = paste(dataset_id, lanes$MethodId, sep = "::"),
    DatasetId = dataset_id, ScenarioId = policy$DryRunScenarioId,
    Replicate = policy$DryRunReplicate, MethodId = lanes$MethodId,
    Backend = lanes$Backend,
    Likelihood = ifelse(grepl("_reml$", lanes$MethodId), "REML", "ML"),
    stringsAsFactors = FALSE
  )
  counts <- table(contract$Profiles$Backend)
  units$ExpectedCandidateFitRows <- 2L * as.integer(counts[units$Backend])
  units$ExpectedCandidateDecisionRows <-
    contract$Policy$CandidateDecisionsPerAtomicUnit
  units$ExpectedReferenceRows <- 2L
  units$CalibrationUse <- FALSE
  units$MechanicsFixture <- FALSE
  units$ProductionAdapterDryRun <- TRUE
  units$ExecutionAuthorized <- TRUE
  units$AtomicUnitIdentityHash <- vapply(
    seq_len(nrow(units)), function(index) {
      mfrmr_gta_hash(units[index, setdiff(
        names(units), "AtomicUnitIdentityHash"
      ), drop = FALSE])
    }, character(1L)
  )
  identity <- list(
    Contract = "hardened_adapter_dry_manifest_b1g18_v1",
    RunnerContractHash = contract$ContractHash,
    ExecutionMode = "nonreserved_hardened_adapter_rebase",
    Units = units,
    CandidateEvaluatorHash = contract$AdapterHashes[["CandidateEvaluator"]],
    ReferenceEvaluatorHash = contract$AdapterHashes[["ReferenceEvaluator"]],
    Replicates = policy$DryRunReplicate,
    ReservedCalibrationUse = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    AtomicUnitCount = nrow(units), DatasetCount = 1L,
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount = sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ExecutionAuthorized = TRUE,
    CalibrationExecutionAuthorized = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwag_manifest")
}

mfrmr_gtwam_semantic_rows_equal <- function(old, new, excluded) {
  common <- setdiff(intersect(names(old), names(new)), excluded)
  identical(old[common], new[common])
}

mfrmr_gtwam_audit <- function(contract, manifest, parent_execution,
                               hardened_execution) {
  if (!mfrmr_gtwam_contract_hash_valid(contract) ||
      !mfrmr_gtwag_manifest_hash_valid(manifest) ||
      !inherits(parent_execution, "mfrmr_gtwag_execution") ||
      !inherits(hardened_execution, "mfrmr_gtwag_execution") ||
      !identical(hardened_execution$RunManifestHash, manifest$ManifestHash)) {
    stop("Exact b1g18 contract, manifest, and paired executions are required.",
         call. = FALSE)
  }
  candidate_parity <- mfrmr_gtwam_semantic_rows_equal(
    parent_execution$CandidateFits, hardened_execution$CandidateFits,
    c("GeneratorHash", "PreFitHash")
  )
  decision_parity <- identical(
    parent_execution$CandidateDecisions,
    hardened_execution$CandidateDecisions
  )
  reference_parity <- mfrmr_gtwam_semantic_rows_equal(
    parent_execution$References, hardened_execution$References,
    c("ReferenceSidecarHash", "GeneratorHash", "PreFitHash")
  )
  hardened_generator_match <- identical(
    tapply(
      hardened_execution$CandidateFits$GeneratorHash,
      hardened_execution$CandidateFits$AtomicUnitId, unique
    ),
    tapply(
      hardened_execution$References$GeneratorHash,
      hardened_execution$References$AtomicUnitId, unique
    )
  )
  hardened_prefit_match <- identical(
    tapply(
      hardened_execution$CandidateFits$PreFitHash,
      hardened_execution$CandidateFits$AtomicUnitId, unique
    ),
    tapply(
      hardened_execution$References$PreFitHash,
      hardened_execution$References$AtomicUnitId, unique
    )
  )
  identity <- list(
    Contract = "hardened_adapter_rebase_audit_b1g18_v1",
    HardenedAdapterContractHash = contract$ContractHash,
    HardenedDryManifestHash = manifest$ManifestHash,
    ParentExecutionHash = parent_execution$ExecutionHash,
    HardenedExecutionHash = hardened_execution$ExecutionHash,
    ParentCounts = c(
      CandidateFits = nrow(parent_execution$CandidateFits),
      CandidateDecisions = nrow(parent_execution$CandidateDecisions),
      References = nrow(parent_execution$References),
      FitFailures = parent_execution$CandidateFitFailureCount,
      ReferenceUnresolved = parent_execution$ReferenceUnresolvedCount
    ),
    HardenedCounts = c(
      CandidateFits = nrow(hardened_execution$CandidateFits),
      CandidateDecisions = nrow(hardened_execution$CandidateDecisions),
      References = nrow(hardened_execution$References),
      FitFailures = hardened_execution$CandidateFitFailureCount,
      ReferenceUnresolved = hardened_execution$ReferenceUnresolvedCount
    ),
    CandidateSemanticParity = candidate_parity,
    CandidateDecisionParity = decision_parity,
    ReferenceSemanticParity = reference_parity,
    HardenedCandidateReferenceGeneratorMatch = hardened_generator_match,
    HardenedCandidateReferencePreFitMatch = hardened_prefit_match,
    HistoricalAdapterPreserved = TRUE,
    ReservedManifestRebaseDeferred = TRUE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  ready <- isTRUE(parent_execution$Complete) &&
    isTRUE(hardened_execution$Complete) &&
    isTRUE(parent_execution$ExactAccountingPassed) &&
    isTRUE(hardened_execution$ExactAccountingPassed) &&
    identical(identity$ParentCounts, identity$HardenedCounts) &&
    candidate_parity && decision_parity && reference_parity &&
    hardened_generator_match && hardened_prefit_match
  structure(c(identity, list(
    AuditHash = mfrmr_gta_hash(identity),
    HardenedAdapterRebaseAuditReady = ready,
    NonreservedAdapterRebaseReady = ready,
    RNGAdapterComponentProspectivelyResolved = ready,
    ReservedAdapterEntryPointReady = FALSE,
    AuthorizationRNG01Closed = FALSE,
    AuthorizationActivationEligible = FALSE,
    LargeSimulationMayStart = FALSE,
    Replicate201MayBeOpened = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtwam_audit")
}

mfrmr_gtwam_audit_hash_valid <- function(audit) {
  fields <- c(
    "Contract", "HardenedAdapterContractHash", "HardenedDryManifestHash",
    "ParentExecutionHash", "HardenedExecutionHash", "ParentCounts",
    "HardenedCounts", "CandidateSemanticParity", "CandidateDecisionParity",
    "ReferenceSemanticParity", "HardenedCandidateReferenceGeneratorMatch",
    "HardenedCandidateReferencePreFitMatch", "HistoricalAdapterPreserved",
    "ReservedManifestRebaseDeferred", "CalibrationResponsesUsed",
    "ConfirmationResponsesUsed"
  )
  ready <- inherits(audit, "mfrmr_gtwam_audit") &&
    identical(audit$ParentCounts, audit$HardenedCounts) &&
    all(c(
      audit$CandidateSemanticParity, audit$CandidateDecisionParity,
      audit$ReferenceSemanticParity,
      audit$HardenedCandidateReferenceGeneratorMatch,
      audit$HardenedCandidateReferencePreFitMatch
    ))
  inherits(audit, "mfrmr_gtwam_audit") &&
    all(fields %in% names(audit)) &&
    identical(audit$AuditHash, mfrmr_gta_hash(audit[fields])) &&
    identical(audit$HardenedAdapterRebaseAuditReady, ready) &&
    identical(audit$NonreservedAdapterRebaseReady, ready) &&
    identical(audit$RNGAdapterComponentProspectivelyResolved, ready) &&
    isTRUE(audit$HistoricalAdapterPreserved) &&
    isTRUE(audit$ReservedManifestRebaseDeferred) &&
    !isTRUE(audit$ReservedAdapterEntryPointReady) &&
    !isTRUE(audit$AuthorizationRNG01Closed) &&
    !isTRUE(audit$AuthorizationActivationEligible) &&
    !isTRUE(audit$LargeSimulationMayStart) &&
    !isTRUE(audit$Replicate201MayBeOpened) &&
    !isTRUE(audit$CalibrationExecutionAuthorized) &&
    !isTRUE(audit$CalibrationDataGenerated) &&
    !isTRUE(audit$CalibrationResultsViewed) &&
    !isTRUE(audit$ConfirmationAuthorized) &&
    !isTRUE(audit$InferenceReady) && !isTRUE(audit$DecisionReady) &&
    !isTRUE(audit$CalibrationResponsesUsed) &&
    !isTRUE(audit$ConfirmationResponsesUsed)
}
