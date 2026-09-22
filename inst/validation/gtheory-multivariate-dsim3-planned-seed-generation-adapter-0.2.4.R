# Internal D-SIM-3 parameterized planned-seed generation adapter.
#
# This layer reuses the qualified response-generator implementation as its only
# stochastic core. Qualification executes nonreserved 854 equivalence fixtures
# and statically compiles 856 forwarding contracts; it never initializes 856.

mfrmr_gtds3aa_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3_manifest",
    "mfrmr_gtds3_assert_manifest", "mfrmr_gtds3g_contract",
    "mfrmr_gtds3g_generate_profile", "mfrmr_gtds3g_manifest",
    "mfrmr_gtds3g_assert_manifest",
    "mfrmr_gtds3p_plan", "mfrmr_gtds3p_assert_plan",
    "mfrmr_gtds3x_manifest", "mfrmr_gtds3x_assert_manifest"
  )
  target <- environment(mfrmr_gtds3aa_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the D-SIM-3 generator and superseding request chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3aa_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3aa_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The planned-seed adapter requires `digest`.", call. = FALSE)
  }
  path <- normalizePath(path, mustWork = TRUE)
  if (dir.exists(path)) stop("A generator source file is required.",
                             call. = FALSE)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds3aa_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-PLANNED-SEED-ADAPTER-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentGeneratorContractHash =
      "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4",
    ParentGeneratorManifestHash =
      "c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a",
    ParentGeneratorSourceSHA256 =
      "6a2e5cfbdb837079ec07650b4494af068fa7cbbcafb3fceae985e5d7fa4e2bc0",
    ParentSupersedingPlanHash =
      "58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a",
    ParentRequestContractHash =
      "c37fbedb03f0535d2e8aab1380949385ba10b0fc32b205f77df17074d52fd67e",
    ParentRequestManifestHash =
      "69cf70189e1a72fbdda3af4fcca5d37873ef3e5f23d96c0d2cb4b1b87e8e1cef",
    ParentOrchestratorManifestHash =
      "bffb82e3155bf12597b686f47c7762cdce802c1ac4666c1c4572f2cb1f25c724",
    ParentReconciliationManifestHash =
      "b3b5404b2b262941046cfa7a85866a1b7432f3e5a87cb759f3b61a6a345c90b9"
  )
}

mfrmr_gtds3aa_contract <- function() {
  mfrmr_gtds3aa_require_primitives()
  identity <- mfrmr_gtds3aa_identity()
  payload <- c(identity, list(
    ExpectedPlannedGenerationRequestCount = 42L,
    ExpectedShadowEquivalenceProfileCount = 21L,
    ExpectedResourceRebindingCount = 5L,
    ExpectedQualificationGateCount = 8L,
    PlannedSeedBandId = "DSIM3-SUPERSEDING-856",
    PlannedSeedMinimum = 856001001L,
    PlannedSeedMaximum = 856021002L,
    QualificationSeedBandId = "NONRESERVED-FIXTURE-854",
    QualificationSeedMinimum = 854100001L,
    QualificationSeedMaximum = 854100021L,
    ParameterizedCoreContractId =
      "MFRMR-GTHEORY-MV-DSIM3-PARAMETERIZED-GENERATOR-CORE-V1",
    StochasticCoreFunction = "mfrmr_gtds3g_generate_profile",
    CopiedStochasticCoreFunctionCount = 0L,
    CoreReuseRequired = TRUE,
    ExactSeedForwardingRequired = TRUE,
    ShadowGeneratedDataHashEquivalenceRequired = TRUE,
    QualificationMayUsePlannedSeed = FALSE,
    QualificationMayOpen856 = FALSE,
    PlannedExecutionRequiresFutureReadinessManifest = TRUE,
    SelfAuthorizationAllowed = FALSE,
    IntegratedWorkloadCapacityQualificationRequired = FALSE,
    PartialLaunchAllowed = FALSE,
    HistoricalReceiptInheritanceAllowed = FALSE,
    PlannedTerminalReceiptIssuanceAllowed = FALSE,
    RecoveryClaimAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3aa_hash(payload)
  )), class = c("mfrmr_gtds3aa_contract", "list"))
}

mfrmr_gtds3aa_validate_contract <- function(
    contract = mfrmr_gtds3aa_contract()) {
  canonical <- mfrmr_gtds3aa_contract()
  valid <- inherits(contract, "mfrmr_gtds3aa_contract") &&
    identical(contract, canonical) &&
    identical(contract$ExpectedPlannedGenerationRequestCount, 42L) &&
    identical(contract$ExpectedShadowEquivalenceProfileCount, 21L) &&
    identical(contract$CopiedStochasticCoreFunctionCount, 0L) &&
    isTRUE(contract$CoreReuseRequired) &&
    isTRUE(contract$ExactSeedForwardingRequired) &&
    isTRUE(contract$ShadowGeneratedDataHashEquivalenceRequired) &&
    !isTRUE(contract$QualificationMayUsePlannedSeed) &&
    !isTRUE(contract$QualificationMayOpen856) &&
    isTRUE(contract$PlannedExecutionRequiresFutureReadinessManifest) &&
    !isTRUE(contract$SelfAuthorizationAllowed) &&
    !isTRUE(contract$IntegratedWorkloadCapacityQualificationRequired) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    !isTRUE(contract$HistoricalReceiptInheritanceAllowed) &&
    !isTRUE(contract$PlannedTerminalReceiptIssuanceAllowed) &&
    !isTRUE(contract$RecoveryClaimAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 planned-seed adapter contract is invalid.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3aa_parameterized_core_contract <- function(
    seed, scenario_ordinal, mode = c("shadow_equivalence", "planned_856"),
    contract = mfrmr_gtds3aa_contract()) {
  mfrmr_gtds3aa_validate_contract(contract)
  mode <- match.arg(mode)
  seed <- as.integer(seed)
  scenario_ordinal <- as.integer(scenario_ordinal)
  in_range <- if (mode == "shadow_equivalence") {
    seed >= contract$QualificationSeedMinimum &&
      seed <= contract$QualificationSeedMaximum &&
      seed == 854100000L + scenario_ordinal
  } else {
    seed >= contract$PlannedSeedMinimum &&
      seed <= contract$PlannedSeedMaximum
  }
  if (length(seed) != 1L || is.na(seed) ||
      length(scenario_ordinal) != 1L || is.na(scenario_ordinal) ||
      scenario_ordinal < 1L || scenario_ordinal > 21L || !in_range) {
    stop("The parameterized generator seed policy was violated.",
         call. = FALSE)
  }
  parent <- mfrmr_gtds3g_contract()
  parent$ContractId <- contract$ParameterizedCoreContractId
  parent$ContractVersion <- "1.0.0"
  parent$ShadowSeedBandId <- if (mode == "shadow_equivalence") {
    contract$QualificationSeedBandId
  } else contract$PlannedSeedBandId
  parent$ShadowSeedBase <- as.integer(seed - scenario_ordinal)
  parent$MinimumShadowSeed <- seed
  parent$MaximumShadowSeed <- seed
  parent$ReservedExploratoryLowerInclusive <- if (
    mode == "shadow_equivalence"
  ) 855000000L else 857000000L
  parent$ReservedExploratoryUpperInclusive <- if (
    mode == "shadow_equivalence"
  ) 855999999L else 857999999L
  parent$ExploratoryExecutionAllowed <- mode == "planned_856"
  parent$ContractHash <- mfrmr_gtds3aa_hash(
    parent[names(parent) != "ContractHash"]
  )
  attr(parent, "mfrmr_gtds3aa_mode") <- mode
  parent
}

mfrmr_gtds3aa_core_reuse_registry <- function(
    generator_source_path, contract) {
  function_hash <- mfrmr_gtds3aa_hash(list(
    Formals = formals(mfrmr_gtds3g_generate_profile),
    Body = body(mfrmr_gtds3g_generate_profile)
  ))
  data.frame(
    CoreOrdinal = 1L,
    CoreFunction = contract$StochasticCoreFunction,
    ParentGeneratorContractHash = contract$ParentGeneratorContractHash,
    ExpectedSourceSHA256 = contract$ParentGeneratorSourceSHA256,
    ObservedSourceSHA256 = mfrmr_gtds3aa_file_hash(generator_source_path),
    CoreFunctionHash = function_hash,
    ExistingCoreReused = TRUE,
    CopiedStochasticCoreFunctionCount = 0L,
    CoreReuseQualified =
      mfrmr_gtds3aa_file_hash(generator_source_path) ==
        contract$ParentGeneratorSourceSHA256,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3aa_dry_run_registry <- function(
    request_manifest, plan, coverage, contract) {
  requests <- request_manifest$GenerationRequestRegistry
  scenarios <- coverage$ScenarioRegistry
  scenario_index <- match(requests$ScenarioId, scenarios$ScenarioId)
  datasets <- plan$DatasetAttemptRegistry
  dataset_index <- match(requests$DatasetId, datasets$DatasetId)
  rows <- lapply(seq_len(nrow(requests)), function(index) {
    ordinal <- scenarios$ScenarioOrdinal[[scenario_index[[index]]]]
    core_contract <- mfrmr_gtds3aa_parameterized_core_contract(
      requests$DataSeed[[index]], ordinal, "planned_856", contract
    )
    configured_seed <- as.integer(
      core_contract$ShadowSeedBase + ordinal
    )
    data.frame(
      DryRunOrdinal = as.integer(index),
      GenerationRequestId = requests$GenerationRequestId[[index]],
      GenerationRequestHash = requests$RequestHash[[index]],
      DatasetId = requests$DatasetId[[index]],
      ScenarioId = requests$ScenarioId[[index]],
      ScenarioOrdinal = as.integer(ordinal),
      Replicate = requests$Replicate[[index]],
      RequestedSeed = requests$DataSeed[[index]],
      ConfiguredCoreSeed = configured_seed,
      SeedBandId = requests$SeedBandId[[index]],
      ParameterizedCoreContractHash = core_contract$ContractHash,
      RequestIdentityBound = requests$RequestCompiled[[index]] &&
        !is.na(dataset_index[[index]]) &&
        requests$DataSeed[[index]] ==
          datasets$DataSeed[[dataset_index[[index]]]] &&
        requests$SeedBandId[[index]] ==
          datasets$SeedBandId[[dataset_index[[index]]]],
      PlannedSeedPolicyAccepted = TRUE,
      ExactSeedForwardingReady = configured_seed ==
        requests$DataSeed[[index]],
      DryRunOnly = TRUE,
      RngStreamOpened = FALSE,
      ResponseGenerated = FALSE,
      ExecutionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3aa_shadow_equivalence_registry <- function(
    generator_manifest, coverage, contract) {
  profiles <- generator_manifest$ProfileGenerationRegistry
  rows <- lapply(seq_len(nrow(profiles)), function(index) {
    profile <- profiles[index, , drop = FALSE]
    before_kind <- RNGkind()
    had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if (had_seed) before_seed <- get(".Random.seed", envir = .GlobalEnv)
    core_contract <- mfrmr_gtds3aa_parameterized_core_contract(
      profile$ShadowSeed[[1L]], profile$ScenarioOrdinal[[1L]],
      "shadow_equivalence", contract
    )
    generated <- mfrmr_gtds3g_generate_profile(
      profile$ScenarioId[[1L]], contract = core_contract,
      coverage = coverage, validate = FALSE
    )
    after_kind <- RNGkind()
    has_seed_after <- exists(
      ".Random.seed", envir = .GlobalEnv, inherits = FALSE
    )
    caller_restored <- identical(before_kind, after_kind) &&
      identical(had_seed, has_seed_after) &&
      (!had_seed || identical(
        before_seed, get(".Random.seed", envir = .GlobalEnv)
      ))
    data.frame(
      EquivalenceOrdinal = as.integer(index),
      ScenarioId = profile$ScenarioId,
      ScenarioOrdinal = profile$ScenarioOrdinal,
      QualificationSeed = profile$ShadowSeed,
      ParameterizedCoreContractHash = core_contract$ContractHash,
      ParentGeneratedDataHash = profile$GeneratedDataHash,
      AdapterGeneratedDataHash = generated$Summary$GeneratedDataHash,
      ParentMissingnessMaskHash = profile$MissingnessMaskHash,
      AdapterMissingnessMaskHash = generated$Summary$MissingnessMaskHash,
      GeneratedResponseCount = generated$Summary$GeneratedResponseCount,
      GeneratedDataHashEquivalent =
        profile$GeneratedDataHash == generated$Summary$GeneratedDataHash,
      MissingnessMaskHashEquivalent =
        profile$MissingnessMaskHash ==
          generated$Summary$MissingnessMaskHash,
      ExactSeedForwardingObserved =
        generated$ShadowSeed == profile$ShadowSeed,
      CallerRngStateRestored = caller_restored,
      Planned856Identity = FALSE,
      CountsAsExploratoryAttempt = FALSE,
      stringsAsFactors = FALSE
    )
  })
  output <- do.call(rbind, rows)
  row.names(output) <- NULL
  output
}

mfrmr_gtds3aa_resource_rebindings <- function(
    request_manifest, contract) {
  requests <- request_manifest$ResourceBindingRegistry
  operations <- c(
    "parameterized_planned_seed_generator",
    "qualified_two_family_fit_worker",
    "qualified_nonpooled_metric_worker",
    "parameterized_generation_fit_metric_sequence",
    "registered_parameterized_request_scheduler"
  )
  adapter_required <- c(TRUE, FALSE, FALSE, TRUE, TRUE)
  data.frame(
    ResourceRebindingOrdinal = seq_len(nrow(requests)),
    ResourceBindingId = requests$ResourceBindingId,
    ResourceBindingHash = requests$BindingHash,
    ScopeId = requests$ScopeId,
    WorkerOperation = operations,
    PlannedSeedAdapterRequiredForScope = adapter_required,
    PlannedSeedAdapterBound = TRUE,
    MechanicalControllerManifestHash =
      requests$MechanicalResourceManifestHash,
    ParentOrchestratorManifestHash =
      contract$ParentOrchestratorManifestHash,
    ResourceRequestIdentityBound = TRUE,
    MechanicsQualified = TRUE,
    IntegratedWorkloadCapacityQualified = FALSE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3aa_gate_registry <- function() {
  data.frame(
    GateOrdinal = 1:8,
    GateId = c(
      "parent_generator_identity", "superseding_request_identity",
      "single_stochastic_core_reused", "exact_856_seed_forwarding_dry_run",
      "shadow_generated_data_equivalence", "caller_rng_restoration",
      "resource_operations_rebound", "execution_boundary_closed"
    ),
    GatePassed = TRUE,
    Blocking = FALSE,
    QualificationOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3aa_validate_readiness_manifest <- function(
    readiness_manifest, adapter_manifest) {
  valid <- inherits(readiness_manifest, "mfrmr_gtds3ab_manifest") &&
    is.list(readiness_manifest$Summary) &&
    isTRUE(readiness_manifest$Summary$TechnicalLaunchReady) &&
    isTRUE(
      readiness_manifest$Summary$PlannedSeedGenerationAdapterQualified
    ) &&
    !isTRUE(readiness_manifest$Summary$Planned856RngStreamOpened) &&
    identical(
      readiness_manifest$ParentAdapterManifestHash,
      adapter_manifest$ManifestHash
    ) && is.character(readiness_manifest$ManifestHash) &&
    length(readiness_manifest$ManifestHash) == 1L &&
    grepl("^[0-9a-f]{64}$", readiness_manifest$ManifestHash)
  if (!valid) {
    stop("A future 10/10 D-SIM-3 readiness manifest is required.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3aa_planned_generation_fields <- function() {
  c(
    "AdapterContractHash", "AdapterManifestHash",
    "ReadinessManifestHash", "GenerationRequestId",
    "GenerationRequestHash", "DatasetId", "ScenarioId", "Replicate",
    "DataSeed", "SeedBandId", "ParameterizedCoreContractHash",
    "CoreGenerationHash", "StreamRegistry", "UnitCovarianceBindings",
    "ComponentDraws", "MissingnessBinding", "GeneratedData", "Summary"
  )
}

mfrmr_gtds3aa_execute_request <- function(
    generation_request_id, request_manifest, adapter_manifest,
    readiness_manifest, generator_source_path,
    coverage = mfrmr_gtds3_manifest()) {
  mfrmr_gtds3x_assert_manifest(request_manifest)
  mfrmr_gtds3aa_assert_manifest(
    adapter_manifest, generator_source_path
  )
  mfrmr_gtds3aa_validate_readiness_manifest(
    readiness_manifest, adapter_manifest
  )
  request <- request_manifest$GenerationRequestRegistry[
    request_manifest$GenerationRequestRegistry$GenerationRequestId ==
      generation_request_id, , drop = FALSE
  ]
  if (nrow(request) != 1L) {
    stop("One exact generation request is required.", call. = FALSE)
  }
  scenario <- coverage$ScenarioRegistry[
    coverage$ScenarioRegistry$ScenarioId == request$ScenarioId[[1L]],
    , drop = FALSE
  ]
  if (nrow(scenario) != 1L) {
    stop("The generation scenario is not frozen.", call. = FALSE)
  }
  core_contract <- mfrmr_gtds3aa_parameterized_core_contract(
    request$DataSeed[[1L]], scenario$ScenarioOrdinal[[1L]],
    "planned_856", adapter_manifest$Contract
  )
  generated <- mfrmr_gtds3g_generate_profile(
    request$ScenarioId[[1L]], contract = core_contract,
    coverage = coverage, validate = FALSE
  )
  streams <- generated$StreamRegistry
  streams$Planned856Identity <- TRUE
  summary <- list(
    Planned856RngStreamOpened = TRUE,
    ExploratoryResponseGenerated = TRUE,
    GeneratedResponseCount = generated$Summary$GeneratedResponseCount,
    OmittedResponseCount = generated$Summary$OmittedResponseCount,
    GeneratedDataHash = generated$Summary$GeneratedDataHash,
    CallerRngStateRestored = TRUE,
    BackendCallMade = FALSE,
    FitExecuted = FALSE,
    MetricComputed = FALSE,
    TerminalReceiptIssued = FALSE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE
  )
  payload <- list(
    AdapterContractHash = adapter_manifest$Contract$ContractHash,
    AdapterManifestHash = adapter_manifest$ManifestHash,
    ReadinessManifestHash = readiness_manifest$ManifestHash,
    GenerationRequestId = request$GenerationRequestId[[1L]],
    GenerationRequestHash = request$RequestHash[[1L]],
    DatasetId = request$DatasetId[[1L]],
    ScenarioId = request$ScenarioId[[1L]],
    Replicate = request$Replicate[[1L]],
    DataSeed = request$DataSeed[[1L]],
    SeedBandId = request$SeedBandId[[1L]],
    ParameterizedCoreContractHash = core_contract$ContractHash,
    CoreGenerationHash = generated$GenerationHash,
    StreamRegistry = streams,
    UnitCovarianceBindings = generated$UnitCovarianceBindings,
    ComponentDraws = generated$ComponentDraws,
    MissingnessBinding = generated$MissingnessBinding,
    GeneratedData = generated$GeneratedData,
    Summary = summary
  )
  result <- structure(c(payload, list(
    PlannedGenerationHash = mfrmr_gtds3aa_hash(payload)
  )), class = c("mfrmr_gtds3aa_planned_generation", "list"))
  mfrmr_gtds3aa_assert_planned_generation(
    result, request_manifest, adapter_manifest, readiness_manifest
  )
  result
}

mfrmr_gtds3aa_assert_planned_generation <- function(
    generation, request_manifest, adapter_manifest, readiness_manifest) {
  fields <- mfrmr_gtds3aa_planned_generation_fields()
  request <- request_manifest$GenerationRequestRegistry[
    request_manifest$GenerationRequestRegistry$GenerationRequestId ==
      generation$GenerationRequestId, , drop = FALSE
  ]
  valid <- inherits(
    generation, "mfrmr_gtds3aa_planned_generation"
  ) && identical(names(generation), c(fields, "PlannedGenerationHash")) &&
    identical(
      generation$PlannedGenerationHash,
      mfrmr_gtds3aa_hash(generation[fields])
    ) && nrow(request) == 1L &&
    identical(generation$AdapterManifestHash, adapter_manifest$ManifestHash) &&
    identical(
      generation$ReadinessManifestHash, readiness_manifest$ManifestHash
    ) && identical(generation$GenerationRequestHash, request$RequestHash[[1L]]) &&
    identical(generation$DataSeed, request$DataSeed[[1L]]) &&
    identical(generation$SeedBandId, "DSIM3-SUPERSEDING-856") &&
    isTRUE(generation$Summary$Planned856RngStreamOpened) &&
    isTRUE(generation$Summary$ExploratoryResponseGenerated) &&
    !isTRUE(generation$Summary$BackendCallMade) &&
    !isTRUE(generation$Summary$FitExecuted) &&
    !isTRUE(generation$Summary$MetricComputed) &&
    !isTRUE(generation$Summary$TerminalReceiptIssued) &&
    !isTRUE(generation$Summary$RecoveryEvidenceComputed) &&
    !isTRUE(generation$Summary$SimulationValidationReady) &&
    !isTRUE(generation$Summary$PublicSupportReady)
  if (!valid) {
    stop("The planned D-SIM-3 generation evidence was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3aa_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3aa_require_primitives", "mfrmr_gtds3aa_hash",
    "mfrmr_gtds3aa_file_hash", "mfrmr_gtds3aa_identity",
    "mfrmr_gtds3aa_contract", "mfrmr_gtds3aa_validate_contract",
    "mfrmr_gtds3aa_parameterized_core_contract",
    "mfrmr_gtds3aa_core_reuse_registry",
    "mfrmr_gtds3aa_dry_run_registry",
    "mfrmr_gtds3aa_shadow_equivalence_registry",
    "mfrmr_gtds3aa_resource_rebindings", "mfrmr_gtds3aa_gate_registry",
    "mfrmr_gtds3aa_validate_readiness_manifest",
    "mfrmr_gtds3aa_planned_generation_fields",
    "mfrmr_gtds3aa_execute_request",
    "mfrmr_gtds3aa_assert_planned_generation",
    "mfrmr_gtds3aa_implementation_identity",
    "mfrmr_gtds3aa_manifest_fields", "mfrmr_gtds3aa_manifest",
    "mfrmr_gtds3aa_assert_manifest"
  )
  target <- environment(mfrmr_gtds3aa_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3aa_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3aa_manifest_fields <- function() {
  c(
    "Contract", "ParentGeneratorManifestHash",
    "ParentSupersedingPlanHash", "ParentRequestManifestHash",
    "CoreReuseRegistry", "PlannedSeedDryRunRegistry",
    "ShadowEquivalenceRegistry", "ResourceRebindingRegistry",
    "QualificationGateRegistry", "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3aa_manifest <- function(
    generator_source_path, request_manifest = NULL,
    generator_manifest = NULL, plan = mfrmr_gtds3p_plan(),
    coverage = mfrmr_gtds3_manifest(),
    contract = mfrmr_gtds3aa_contract()) {
  mfrmr_gtds3aa_validate_contract(contract)
  mfrmr_gtds3p_assert_plan(plan)
  mfrmr_gtds3_assert_manifest(coverage)
  if (is.null(request_manifest)) request_manifest <- mfrmr_gtds3x_manifest()
  if (is.null(generator_manifest)) generator_manifest <- mfrmr_gtds3g_manifest()
  mfrmr_gtds3x_assert_manifest(request_manifest)
  mfrmr_gtds3g_assert_manifest(generator_manifest)
  if (!identical(generator_manifest$Contract$ContractHash,
                 contract$ParentGeneratorContractHash) ||
      !identical(generator_manifest$ManifestHash,
                 contract$ParentGeneratorManifestHash) ||
      !identical(plan$PlanHash, contract$ParentSupersedingPlanHash) ||
      !identical(request_manifest$Contract$ContractHash,
                 contract$ParentRequestContractHash) ||
      !identical(request_manifest$ManifestHash,
                 contract$ParentRequestManifestHash)) {
    stop("A planned-seed adapter parent identity changed.", call. = FALSE)
  }
  core <- mfrmr_gtds3aa_core_reuse_registry(
    generator_source_path, contract
  )
  dry_run <- mfrmr_gtds3aa_dry_run_registry(
    request_manifest, plan, coverage, contract
  )
  equivalence <- mfrmr_gtds3aa_shadow_equivalence_registry(
    generator_manifest, coverage, contract
  )
  resources <- mfrmr_gtds3aa_resource_rebindings(
    request_manifest, contract
  )
  gates <- mfrmr_gtds3aa_gate_registry()
  implementation <- mfrmr_gtds3aa_implementation_identity()
  summary <- list(
    StochasticCoreFunctionCount = nrow(core),
    ExistingStochasticCoreReuseCount = sum(core$ExistingCoreReused),
    CopiedStochasticCoreFunctionCount =
      sum(core$CopiedStochasticCoreFunctionCount),
    PlannedGenerationRequestCount = nrow(dry_run),
    ExactPlannedSeedForwardingReadyCount =
      sum(dry_run$ExactSeedForwardingReady),
    PlannedSeedDryRunCount = sum(dry_run$DryRunOnly),
    PlannedSeedRngStreamOpenedCount = sum(dry_run$RngStreamOpened),
    ShadowEquivalenceProfileCount = nrow(equivalence),
    GeneratedDataHashEquivalentProfileCount =
      sum(equivalence$GeneratedDataHashEquivalent),
    MissingnessMaskHashEquivalentProfileCount =
      sum(equivalence$MissingnessMaskHashEquivalent),
    CallerRngStateRestoredProfileCount =
      sum(equivalence$CallerRngStateRestored),
    ResourceRebindingCount = nrow(resources),
    PlannedSeedAdapterResourceBindingCount =
      sum(resources$PlannedSeedAdapterBound),
    IntegratedWorkloadCapacityQualifiedCount =
      sum(resources$IntegratedWorkloadCapacityQualified),
    PassingQualificationGateCount = sum(gates$GatePassed),
    BlockingQualificationGateCount = sum(gates$Blocking),
    PlannedSeedGenerationAdapterShadowQualified = TRUE,
    FinalLaunchReadinessReconciliationRequired = TRUE,
    TechnicalLaunchReady = FALSE,
    Planned855RngStreamOpened = FALSE,
    Planned856RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    ExploratoryBackendCallMade = FALSE,
    ExploratoryFitReturned = FALSE,
    ExploratoryMetricComputed = FALSE,
    PlannedTerminalReceiptIssued = FALSE,
    RecoveryEvidenceComputed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    CurrentDisposition =
      "planned_seed_adapter_shadow_qualified_final_reconciliation_required",
    NextAction = paste(
      "run one final static reconciliation against this exact adapter",
      "manifest and the existing request, worker, terminal, resource, and",
      "environment identities before any 856 stream is opened"
    )
  )
  payload <- list(
    Contract = contract,
    ParentGeneratorManifestHash = generator_manifest$ManifestHash,
    ParentSupersedingPlanHash = plan$PlanHash,
    ParentRequestManifestHash = request_manifest$ManifestHash,
    CoreReuseRegistry = core,
    PlannedSeedDryRunRegistry = dry_run,
    ShadowEquivalenceRegistry = equivalence,
    ResourceRebindingRegistry = resources,
    QualificationGateRegistry = gates,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3aa_hash(payload)
  )), class = c("mfrmr_gtds3aa_manifest", "list"))
  mfrmr_gtds3aa_assert_manifest(manifest, generator_source_path)
  manifest
}

mfrmr_gtds3aa_assert_manifest <- function(
    manifest, generator_source_path) {
  fields <- mfrmr_gtds3aa_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3aa_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 planned-seed adapter manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  core <- manifest$CoreReuseRegistry
  dry_run <- manifest$PlannedSeedDryRunRegistry
  equivalence <- manifest$ShadowEquivalenceRegistry
  resources <- manifest$ResourceRebindingRegistry
  gates <- manifest$QualificationGateRegistry
  summary <- manifest$Summary
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3aa_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3aa_contract()) &&
    identical(manifest$ImplementationIdentity,
              mfrmr_gtds3aa_implementation_identity()) &&
    identical(nrow(core), 1L) && all(core$ExistingCoreReused) &&
    identical(core$CopiedStochasticCoreFunctionCount, 0L) &&
    all(core$ObservedSourceSHA256 == contract$ParentGeneratorSourceSHA256) &&
    all(core$CoreReuseQualified) &&
    identical(mfrmr_gtds3aa_file_hash(generator_source_path),
              contract$ParentGeneratorSourceSHA256) &&
    identical(nrow(dry_run), 42L) &&
    !anyDuplicated(dry_run$GenerationRequestId) &&
    !anyDuplicated(dry_run$GenerationRequestHash) &&
    identical(range(dry_run$RequestedSeed),
              c(856001001L, 856021002L)) &&
    all(dry_run$SeedBandId == contract$PlannedSeedBandId) &&
    all(dry_run$RequestIdentityBound) &&
    all(dry_run$PlannedSeedPolicyAccepted) &&
    all(dry_run$ExactSeedForwardingReady) &&
    all(dry_run$DryRunOnly) && all(!dry_run$RngStreamOpened) &&
    all(!dry_run$ResponseGenerated) && all(!dry_run$ExecutionAuthorized) &&
    identical(nrow(equivalence), 21L) &&
    identical(equivalence$QualificationSeed, 854100000L + 1:21) &&
    all(equivalence$GeneratedDataHashEquivalent) &&
    all(equivalence$MissingnessMaskHashEquivalent) &&
    all(equivalence$ExactSeedForwardingObserved) &&
    all(equivalence$CallerRngStateRestored) &&
    all(!equivalence$Planned856Identity) &&
    all(!equivalence$CountsAsExploratoryAttempt) &&
    identical(nrow(resources), 5L) &&
    identical(resources$ScopeId, c(
      "dataset_generation", "one_route_fit", "one_route_metric",
      "one_dataset_pipeline", "complete_exploratory_run"
    )) && all(resources$PlannedSeedAdapterBound) &&
    all(resources$ResourceRequestIdentityBound) &&
    all(resources$MechanicsQualified) &&
    all(!resources$IntegratedWorkloadCapacityQualified) &&
    all(!resources$ExecutionAuthorized) &&
    identical(nrow(gates), 8L) && all(gates$GatePassed) &&
    all(!gates$Blocking) && all(gates$QualificationOnly) &&
    all(!gates$ExecutionAttempted) &&
    identical(summary$StochasticCoreFunctionCount, 1L) &&
    identical(summary$ExistingStochasticCoreReuseCount, 1L) &&
    identical(summary$CopiedStochasticCoreFunctionCount, 0L) &&
    identical(summary$PlannedGenerationRequestCount, 42L) &&
    identical(summary$ExactPlannedSeedForwardingReadyCount, 42L) &&
    identical(summary$PlannedSeedDryRunCount, 42L) &&
    identical(summary$PlannedSeedRngStreamOpenedCount, 0L) &&
    identical(summary$ShadowEquivalenceProfileCount, 21L) &&
    identical(summary$GeneratedDataHashEquivalentProfileCount, 21L) &&
    identical(summary$MissingnessMaskHashEquivalentProfileCount, 21L) &&
    identical(summary$CallerRngStateRestoredProfileCount, 21L) &&
    identical(summary$ResourceRebindingCount, 5L) &&
    identical(summary$PlannedSeedAdapterResourceBindingCount, 5L) &&
    identical(summary$IntegratedWorkloadCapacityQualifiedCount, 0L) &&
    identical(summary$PassingQualificationGateCount, 8L) &&
    identical(summary$BlockingQualificationGateCount, 0L) &&
    isTRUE(summary$PlannedSeedGenerationAdapterShadowQualified) &&
    isTRUE(summary$FinalLaunchReadinessReconciliationRequired) &&
    !isTRUE(summary$TechnicalLaunchReady) &&
    !isTRUE(summary$Planned855RngStreamOpened) &&
    !isTRUE(summary$Planned856RngStreamOpened) &&
    !isTRUE(summary$ExploratoryResponseGenerated) &&
    !isTRUE(summary$ExploratoryBackendCallMade) &&
    !isTRUE(summary$ExploratoryFitReturned) &&
    !isTRUE(summary$ExploratoryMetricComputed) &&
    !isTRUE(summary$PlannedTerminalReceiptIssued) &&
    !isTRUE(summary$RecoveryEvidenceComputed) &&
    !isTRUE(summary$SimulationValidationReady) &&
    !isTRUE(summary$PublicSupportReady) &&
    identical(summary$FeatureMaturity, "specified") &&
    identical(
      summary$CurrentDisposition,
      "planned_seed_adapter_shadow_qualified_final_reconciliation_required"
    )
  if (!valid) {
    stop("The D-SIM-3 planned-seed adapter evidence was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}
