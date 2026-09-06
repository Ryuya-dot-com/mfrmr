# Internal D-SIM-3 unopened-855 launch-readiness reconciliation.
#
# This audit binds the frozen execution plan to the five qualified shared
# substrate layers and asks whether an executable, identity-bound launch bridge
# exists. It performs no RNG initialization, response generation, backend
# call, fit, metric, or process launch.

mfrmr_gtds3l_require_primitives <- function() {
  required <- c(
    "mfrmr_gtds_v4_hash", "mfrmr_gtds3e_plan",
    "mfrmr_gtds3e_assert_plan", "mfrmr_gtds3g_contract",
    "mfrmr_gtds3r_contract", "mfrmr_gtds3u_contract"
  )
  target <- environment(mfrmr_gtds3l_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the complete D-SIM-3 shared-substrate chain first: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtds3l_hash <- function(value) {
  mfrmr_gtds_v4_hash(value)
}

mfrmr_gtds3l_file_hash <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("D-SIM-3 launch reconciliation requires `digest`.", call. = FALSE)
  }
  if (!file.exists(path) || dir.exists(path)) return(NA_character_)
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gtds3l_identity <- function() {
  list(
    ContractId = "MFRMR-GTHEORY-MV-DSIM3-LAUNCH-READINESS-V1",
    ContractVersion = "1.0.0",
    ContractDate = "2026-08-31",
    ParentExecutionPlanHash =
      "b91ab4229203efc15a3ca9421256d81ae7331143e42f845b5c6a879575552de7",
    ParentResourceContractHash =
      "535ab118a335a66bf0fd264ecc609249dc4e5042ffa1ac64aee1fdc846c94919",
    ParentResourceManifestHash =
      "2a752382b94d0eb0b488c1e7b96029f0f6cc786738997e2dc7c27f28c4051f9d",
    ParentRouteReceiptManifestHash =
      "6a59dc1a7874f731554baff7a134b8b52ad18614e26ee80470d08ffbd8372e9f",
    ParentResourceSourceSHA256 =
      "6eb29c2a34f12393c19748f6df674eb018aabcf94c276261aa4c79ef05079348",
    ParentResourceRecordSHA256 =
      "19facd7b37058bb072b81002ed2672a0b5a81bf76732e86f420d5269b194cdff",
    ParentResourceWorkerSHA256 =
      "44c2a2eb527b53d220cdb8f2e52c34e89651a005ed475331ddac15a868b0a4d0",
    ParentRouteSourceSHA256 =
      "b57e72455b93ffcd24f6db7091dc1cba2589109406ba18ec208e778a5fe91722",
    ParentGeneratorSourceSHA256 =
      "6a2e5cfbdb837079ec07650b4494af068fa7cbbcafb3fceae985e5d7fa4e2bc0"
  )
}

mfrmr_gtds3l_contract <- function() {
  mfrmr_gtds3l_require_primitives()
  identity <- mfrmr_gtds3l_identity()
  payload <- c(identity, list(
    ExpectedReadinessGateCount = 10L,
    ExpectedPassingReadinessGateCount = 4L,
    ExpectedBlockingReadinessGateCount = 6L,
    ExpectedDependencyCount = 5L,
    ExpectedCandidateRouteFamilyCount = 2L,
    ExpectedPlannedDatasetAttemptCount = 42L,
    ExpectedCandidateRouteUnitCount = 50L,
    ExpectedCandidateRouteEstimandCount = 100L,
    ExpectedOpenTerminalUnitCount = 92L,
    MinimumRVersion = "4.1.0",
    RequiredPackages = c("R", "Matrix", "lme4", "processx", "digest"),
    ExpectedCandidateRouteFamilies = c(
      "multivariate_lme4_restricted", "separate_univariate"
    ),
    BackendCriterionFrozenRouteFamilies =
      "multivariate_lme4_restricted",
    SeparateUnivariateBackendInferenceAllowed = FALSE,
    ExactEnvironmentIdentityRequired = TRUE,
    PlannedGenerationRequestRequired = TRUE,
    CandidateBackendRequestRequired = TRUE,
    CandidateMetricRequestRequired = TRUE,
    FitMetricWorkerRequired = TRUE,
    TerminalResourceOrchestratorRequired = TRUE,
    PartialLaunchAllowed = FALSE,
    ScenarioSpecificExecutionPatchAllowed = FALSE,
    MechanicsQualificationConfersLaunchAuthority = FALSE,
    ReconciliationMayUseRng = FALSE,
    ReconciliationMayGenerateResponse = FALSE,
    ReconciliationMayCallBackend = FALSE,
    ReconciliationMayFit = FALSE,
    ReconciliationMayComputeMetric = FALSE,
    ReconciliationMayLaunchProcess = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationClaimAllowed = FALSE,
    PublicSupportPromotionAllowed = FALSE
  ))
  structure(c(payload, list(
    ContractHash = mfrmr_gtds3l_hash(payload)
  )), class = c("mfrmr_gtds3l_contract", "list"))
}

mfrmr_gtds3l_parent_evidence_registry <- function(
    repository_root, contract = mfrmr_gtds3l_contract()) {
  files <- data.frame(
    EvidenceOrdinal = 1:5,
    EvidenceId = c(
      "resource_controller_source", "resource_controller_record",
      "resource_probe_worker", "route_receipt_source",
      "response_generator_source"
    ),
    RelativePath = file.path("inst", "validation", c(
      "gtheory-multivariate-dsim3-resource-controller-0.2.4.R",
      "gtheory-multivariate-dsim3-resource-controller-record-0.2.4.md",
      "gtheory-multivariate-dsim3-resource-probe-worker-0.2.4.R",
      "gtheory-multivariate-dsim3-route-receipt-adapter-0.2.4.R",
      "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R"
    )),
    ExpectedSHA256 = c(
      contract$ParentResourceSourceSHA256,
      contract$ParentResourceRecordSHA256,
      contract$ParentResourceWorkerSHA256,
      contract$ParentRouteSourceSHA256,
      contract$ParentGeneratorSourceSHA256
    ),
    stringsAsFactors = FALSE
  )
  paths <- file.path(repository_root, files$RelativePath)
  files$FilePresent <- file.exists(paths) & !dir.exists(paths)
  files$ObservedSHA256 <- vapply(paths, mfrmr_gtds3l_file_hash, character(1L))
  files$EvidenceBound <- files$FilePresent &
    !is.na(files$ObservedSHA256) &
    files$ObservedSHA256 == files$ExpectedSHA256
  files
}

mfrmr_gtds3l_description_dependencies <- function(repository_root) {
  path <- file.path(repository_root, "DESCRIPTION")
  if (!file.exists(path)) {
    stop("The package DESCRIPTION is required.", call. = FALSE)
  }
  description <- read.dcf(path)[1L, , drop = TRUE]
  parse_field <- function(field) {
    if (!field %in% names(description)) return(character())
    values <- trimws(unlist(strsplit(
      gsub("[\r\n]", " ", description[[field]]), ",", fixed = TRUE
    )))
    trimws(sub("\\s*\\(.*$", "", values))
  }
  list(
    Depends = parse_field("Depends"), Imports = parse_field("Imports"),
    Suggests = parse_field("Suggests")
  )
}

mfrmr_gtds3l_environment_registry <- function(repository_root, contract) {
  declarations <- mfrmr_gtds3l_description_dependencies(repository_root)
  packages <- contract$RequiredPackages
  role <- vapply(packages, function(package) {
    matches <- names(Filter(function(values) package %in% values, declarations))
    if (length(matches) == 0L) "undeclared_internal_validation_dependency"
    else matches[[1L]]
  }, character(1L))
  available <- vapply(packages, function(package) {
    if (identical(package, "R")) {
      getRversion() >= package_version(contract$MinimumRVersion)
    } else requireNamespace(package, quietly = TRUE)
  }, logical(1L))
  data.frame(
    DependencyOrdinal = seq_along(packages),
    Dependency = packages,
    DeclarationRole = unname(role),
    CurrentDependencyAvailable = unname(available),
    ExactVersionIdentityFrozen = FALSE,
    SourceArtifactIdentityFrozen = FALSE,
    LaunchEnvironmentReady = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3l_candidate_route_registry <- function(
    execution_plan, environment_registry, contract) {
  candidates <- execution_plan$RouteUnitRegistry[
    execution_plan$RouteUnitRegistry$PlannedDisposition ==
      "qualification_candidate", , drop = FALSE
  ]
  counts <- table(factor(
    candidates$RouteId, levels = contract$ExpectedCandidateRouteFamilies
  ))
  lme4_available <- environment_registry$CurrentDependencyAvailable[
    environment_registry$Dependency == "lme4"
  ]
  data.frame(
    RouteFamilyOrdinal = 1:2,
    RouteId = contract$ExpectedCandidateRouteFamilies,
    CandidateRouteUnitCount = as.integer(counts),
    RequestedBackend = c("lme4", "unresolved"),
    RequestedCriterion = c("REML", "unresolved"),
    BackendCriterionFrozen = c(TRUE, FALSE),
    CurrentBackendAvailable = c(lme4_available, FALSE),
    SharedDatasetPayloadQualified = TRUE,
    ExactBackendRequestCompiled = FALSE,
    FitMetricWorkerBound = FALSE,
    MetricAdapterBound = FALSE,
    RouteFamilyLaunchReady = FALSE,
    BlockingReason = c(
      paste(
        "exact_candidate_request_and_fit_metric_worker_not_bound_to",
        "resource_and_terminal_controller", sep = "_"
      ),
      paste(
        "backend_and_criterion_unresolved_and_exact_candidate_request",
        "fit_metric_worker_not_bound", sep = "_"
      )
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3l_request_coverage_registry <- function(execution_plan) {
  routes <- execution_plan$RouteUnitRegistry
  coordinates <- execution_plan$RouteEstimandCoordinateRegistry
  candidate_routes <- routes$PlannedDisposition == "qualification_candidate"
  candidate_coordinates <- coordinates$RouteUnitId %in%
    routes$RouteUnitId[candidate_routes]
  expected <- c(
    nrow(execution_plan$DatasetAttemptRegistry), sum(candidate_routes),
    sum(candidate_coordinates),
    nrow(execution_plan$DatasetAttemptRegistry) + sum(candidate_routes)
  )
  data.frame(
    RequestCoverageOrdinal = 1:4,
    RequestClass = c(
      "planned_dataset_generation", "candidate_route_fit",
      "candidate_route_estimand_metric", "open_unit_terminal_orchestration"
    ),
    ExpectedRegisteredUnitCount = as.integer(expected),
    IdentityBoundRequestCount = 0L,
    RequestCoverageReady = FALSE,
    CountsInFrozenDenominator = TRUE,
    ReplacementAllowed = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3l_artifact_gap_registry <- function(repository_root) {
  output <- data.frame(
    ArtifactGapOrdinal = 1:5,
    ArtifactId = c(
      "exact_launch_environment", "planned_generation_request_compiler",
      "candidate_backend_request_compiler", "fit_metric_worker",
      "terminal_resource_orchestrator"
    ),
    ExpectedRelativePath = file.path("inst", "validation", c(
      "gtheory-multivariate-dsim3-launch-environment-0.2.4.R",
      "gtheory-multivariate-dsim3-launch-bundle-compiler-0.2.4.R",
      "gtheory-multivariate-dsim3-launch-bundle-compiler-0.2.4.R",
      "gtheory-multivariate-dsim3-fit-metric-worker-0.2.4.R",
      "gtheory-multivariate-dsim3-launch-orchestrator-0.2.4.R"
    )),
    stringsAsFactors = FALSE
  )
  output$ArtifactPresent <- file.exists(file.path(
    repository_root, output$ExpectedRelativePath
  ))
  output$ExactContractBound <- FALSE
  output$GapOpen <- !output$ArtifactPresent | !output$ExactContractBound
  output$ExecutionAttempted <- FALSE
  output
}

mfrmr_gtds3l_gate_registry <- function(
    execution_plan, parent_evidence, environment, routes, requests,
    artifacts) {
  dependency_ready <- all(environment$CurrentDependencyAvailable)
  plan_ready <- isTRUE(execution_plan$Summary$ContractFrozen) &&
    isTRUE(execution_plan$Summary$ExecutionPlanFrozen) &&
    !isTRUE(execution_plan$Summary$ExecutionCurrentlyAllowed)
  denominator_ready <- identical(
    requests$ExpectedRegisteredUnitCount, c(42L, 50L, 100L, 92L)
  ) && all(requests$CountsInFrozenDenominator) &&
    all(!requests$ReplacementAllowed)
  passed <- c(
    plan_ready, all(parent_evidence$EvidenceBound), dependency_ready,
    denominator_ready, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
  )
  data.frame(
    GateOrdinal = 1:10,
    GateId = c(
      "frozen_plan_identity", "shared_substrate_evidence_identity",
      "current_runtime_dependencies", "frozen_denominator_identity",
      "exact_environment_identity", "planned_generation_requests",
      "candidate_backend_requests", "candidate_metric_requests",
      "fit_metric_worker", "terminal_resource_orchestration"
    ),
    GatePassed = passed,
    Blocking = !passed,
    BlockingReason = c(
      rep("", 4L),
      "exact_R_package_source_and_library_identity_not_frozen",
      "zero_of_42_planned_generation_requests_compiled",
      paste0(
        "zero_of_50_backend_requests_compiled_and_separate_univariate_",
        "backend_criterion_unresolved"
      ),
      "zero_of_100_candidate_route_estimand_metric_requests_compiled",
      "no_D_SIM_3_fit_metric_worker_exists",
      paste0(
        "resource_stop_and_terminal_receipt_are_not_joined_by_an_",
        "executable_orchestrator"
      )
    ),
    ReconciliationOnly = TRUE,
    ExecutionAttempted = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtds3l_validate_contract <- function(
    contract = mfrmr_gtds3l_contract(), execution_plan = NULL,
    repository_root = ".") {
  mfrmr_gtds3l_require_primitives()
  if (is.null(execution_plan)) execution_plan <- mfrmr_gtds3e_plan()
  mfrmr_gtds3e_assert_plan(execution_plan)
  canonical <- mfrmr_gtds3l_contract()
  resource <- mfrmr_gtds3u_contract()
  route <- mfrmr_gtds3r_contract()
  generator <- mfrmr_gtds3g_contract()
  valid <- inherits(contract, "mfrmr_gtds3l_contract") &&
    identical(contract, canonical) && identical(
      contract$ParentExecutionPlanHash, execution_plan$PlanHash
    ) && identical(
      contract$ParentResourceContractHash, resource$ContractHash
    ) && identical(resource$ParentRouteReceiptManifestHash,
                   contract$ParentRouteReceiptManifestHash) &&
    identical(route$ParentGeneratorContractHash, generator$ContractHash) &&
    identical(contract$ExpectedReadinessGateCount, 10L) &&
    identical(contract$ExpectedPassingReadinessGateCount, 4L) &&
    identical(contract$ExpectedBlockingReadinessGateCount, 6L) &&
    !isTRUE(contract$SeparateUnivariateBackendInferenceAllowed) &&
    isTRUE(contract$ExactEnvironmentIdentityRequired) &&
    isTRUE(contract$PlannedGenerationRequestRequired) &&
    isTRUE(contract$CandidateBackendRequestRequired) &&
    isTRUE(contract$CandidateMetricRequestRequired) &&
    isTRUE(contract$FitMetricWorkerRequired) &&
    isTRUE(contract$TerminalResourceOrchestratorRequired) &&
    !isTRUE(contract$PartialLaunchAllowed) &&
    !isTRUE(contract$ScenarioSpecificExecutionPatchAllowed) &&
    !isTRUE(contract$MechanicsQualificationConfersLaunchAuthority) &&
    !isTRUE(contract$ReconciliationMayUseRng) &&
    !isTRUE(contract$ReconciliationMayGenerateResponse) &&
    !isTRUE(contract$ReconciliationMayCallBackend) &&
    !isTRUE(contract$ReconciliationMayFit) &&
    !isTRUE(contract$ReconciliationMayComputeMetric) &&
    !isTRUE(contract$ReconciliationMayLaunchProcess) &&
    !isTRUE(contract$ExploratoryExecutionAllowed) &&
    !isTRUE(contract$SimulationValidationClaimAllowed) &&
    !isTRUE(contract$PublicSupportPromotionAllowed)
  if (!valid) {
    stop("The D-SIM-3 launch-readiness contract is invalid.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtds3l_implementation_identity <- function() {
  functions <- c(
    "mfrmr_gtds3l_require_primitives", "mfrmr_gtds3l_hash",
    "mfrmr_gtds3l_file_hash", "mfrmr_gtds3l_identity",
    "mfrmr_gtds3l_contract", "mfrmr_gtds3l_parent_evidence_registry",
    "mfrmr_gtds3l_description_dependencies",
    "mfrmr_gtds3l_environment_registry",
    "mfrmr_gtds3l_candidate_route_registry",
    "mfrmr_gtds3l_request_coverage_registry",
    "mfrmr_gtds3l_artifact_gap_registry", "mfrmr_gtds3l_gate_registry",
    "mfrmr_gtds3l_validate_contract",
    "mfrmr_gtds3l_implementation_identity",
    "mfrmr_gtds3l_manifest_fields", "mfrmr_gtds3l_manifest",
    "mfrmr_gtds3l_assert_manifest"
  )
  target <- environment(mfrmr_gtds3l_implementation_identity)
  data.frame(
    FunctionOrdinal = seq_along(functions), FunctionName = functions,
    FunctionHash = vapply(functions, function(name) {
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtds3l_hash(list(Formals = formals(fun), Body = body(fun)))
    }, character(1L)), stringsAsFactors = FALSE
  )
}

mfrmr_gtds3l_manifest_fields <- function() {
  c(
    "Contract", "ParentExecutionPlanHash", "ParentResourceManifestHash",
    "ParentEvidenceRegistry", "EnvironmentRegistry",
    "CandidateRouteReadinessRegistry", "RequestCoverageRegistry",
    "LaunchArtifactGapRegistry", "ReadinessGateRegistry",
    "ImplementationIdentity", "Summary"
  )
}

mfrmr_gtds3l_manifest <- function(
    repository_root = ".", contract = mfrmr_gtds3l_contract(),
    execution_plan = mfrmr_gtds3e_plan()) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  mfrmr_gtds3l_validate_contract(contract, execution_plan, repository_root)
  evidence <- mfrmr_gtds3l_parent_evidence_registry(
    repository_root, contract
  )
  environment <- mfrmr_gtds3l_environment_registry(
    repository_root, contract
  )
  routes <- mfrmr_gtds3l_candidate_route_registry(
    execution_plan, environment, contract
  )
  requests <- mfrmr_gtds3l_request_coverage_registry(execution_plan)
  artifacts <- mfrmr_gtds3l_artifact_gap_registry(repository_root)
  gates <- mfrmr_gtds3l_gate_registry(
    execution_plan, evidence, environment, routes, requests, artifacts
  )
  implementation <- mfrmr_gtds3l_implementation_identity()
  summary <- list(
    ContractId = contract$ContractId,
    ContractHash = contract$ContractHash,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    ParentResourceManifestHash = contract$ParentResourceManifestHash,
    ReadinessGateCount = nrow(gates),
    PassingReadinessGateCount = sum(gates$GatePassed),
    BlockingReadinessGateCount = sum(gates$Blocking),
    CurrentDependencyCount = nrow(environment),
    AvailableCurrentDependencyCount =
      sum(environment$CurrentDependencyAvailable),
    ParentEvidenceIdentityBound = all(evidence$EvidenceBound),
    SharedExecutionSubstrateQualified = all(evidence$EvidenceBound),
    ExactEnvironmentIdentityFrozen = FALSE,
    PlannedDatasetAttemptCount =
      requests$ExpectedRegisteredUnitCount[[1L]],
    IdentityBoundGenerationRequestCount = 0L,
    CandidateRouteUnitCount =
      requests$ExpectedRegisteredUnitCount[[2L]],
    BackendCriterionFrozenCandidateRouteUnitCount = sum(
      routes$CandidateRouteUnitCount[routes$BackendCriterionFrozen]
    ),
    IdentityBoundBackendRequestCount = 0L,
    CandidateRouteEstimandCount =
      requests$ExpectedRegisteredUnitCount[[3L]],
    IdentityBoundMetricRequestCount = 0L,
    OpenTerminalUnitCount =
      requests$ExpectedRegisteredUnitCount[[4L]],
    IdentityBoundTerminalOrchestrationCount = 0L,
    TechnicalLaunchReady = all(gates$GatePassed),
    CurrentDisposition = "no_go_missing_execution_bridge",
    Planned855RngStreamOpened = FALSE,
    ExploratoryResponseGenerated = FALSE,
    BackendCallMade = FALSE, FitReturned = FALSE, MetricComputed = FALSE,
    ExploratoryExecutionAllowed = FALSE,
    SimulationValidationReady = FALSE,
    PublicSupportReady = FALSE,
    FeatureMaturity = "specified",
    NextAction = paste(
      "freeze separate-univariate backend and criterion semantics, then",
      "implement one identity-bound launch-bundle compiler, fit/metric",
      "worker, and terminal/resource orchestrator; qualify both candidate",
      "route families on nonreserved shadow fixtures before rerunning this",
      "reconciliation or opening any 855 stream"
    )
  )
  payload <- list(
    Contract = contract,
    ParentExecutionPlanHash = execution_plan$PlanHash,
    ParentResourceManifestHash = contract$ParentResourceManifestHash,
    ParentEvidenceRegistry = evidence,
    EnvironmentRegistry = environment,
    CandidateRouteReadinessRegistry = routes,
    RequestCoverageRegistry = requests,
    LaunchArtifactGapRegistry = artifacts,
    ReadinessGateRegistry = gates,
    ImplementationIdentity = implementation,
    Summary = summary
  )
  manifest <- structure(c(payload, list(
    ManifestHash = mfrmr_gtds3l_hash(payload)
  )), class = c("mfrmr_gtds3l_manifest", "list"))
  mfrmr_gtds3l_assert_manifest(manifest, repository_root)
  manifest
}

mfrmr_gtds3l_assert_manifest <- function(manifest, repository_root = ".") {
  fields <- mfrmr_gtds3l_manifest_fields()
  if (!inherits(manifest, "mfrmr_gtds3l_manifest") ||
      !identical(names(manifest), c(fields, "ManifestHash"))) {
    stop("A typed D-SIM-3 launch-readiness manifest is required.",
         call. = FALSE)
  }
  contract <- manifest$Contract
  evidence <- manifest$ParentEvidenceRegistry
  environment <- manifest$EnvironmentRegistry
  routes <- manifest$CandidateRouteReadinessRegistry
  requests <- manifest$RequestCoverageRegistry
  artifacts <- manifest$LaunchArtifactGapRegistry
  gates <- manifest$ReadinessGateRegistry
  valid <- identical(
    manifest$ManifestHash, mfrmr_gtds3l_hash(manifest[fields])
  ) && identical(contract, mfrmr_gtds3l_contract()) && identical(
    evidence,
    mfrmr_gtds3l_parent_evidence_registry(repository_root, contract)
  ) && identical(
    environment,
    mfrmr_gtds3l_environment_registry(repository_root, contract)
  ) && all(evidence$EvidenceBound) && identical(
    environment$Dependency, contract$RequiredPackages
  ) && identical(nrow(environment), 5L) &&
    all(environment$CurrentDependencyAvailable) &&
    all(!environment$ExactVersionIdentityFrozen) &&
    all(!environment$SourceArtifactIdentityFrozen) &&
    all(!environment$LaunchEnvironmentReady) &&
    identical(nrow(routes), 2L) && identical(
      routes$RouteId, contract$ExpectedCandidateRouteFamilies
    ) && identical(routes$CandidateRouteUnitCount, c(8L, 42L)) &&
    identical(routes$BackendCriterionFrozen, c(TRUE, FALSE)) &&
    all(routes$SharedDatasetPayloadQualified) &&
    all(!routes$ExactBackendRequestCompiled) &&
    all(!routes$FitMetricWorkerBound) &&
    all(!routes$MetricAdapterBound) &&
    all(!routes$RouteFamilyLaunchReady) &&
    identical(nrow(requests), 4L) && identical(
      requests$ExpectedRegisteredUnitCount, c(42L, 50L, 100L, 92L)
    ) && identical(requests$IdentityBoundRequestCount, rep(0L, 4L)) &&
    all(!requests$RequestCoverageReady) &&
    all(requests$CountsInFrozenDenominator) &&
    all(!requests$ReplacementAllowed) &&
    identical(nrow(artifacts), 5L) && all(artifacts$GapOpen) &&
    all(!artifacts$ExactContractBound) &&
    all(!artifacts$ExecutionAttempted) &&
    identical(nrow(gates), 10L) && identical(
      gates$GatePassed, c(rep(TRUE, 4L), rep(FALSE, 6L))
    ) && identical(gates$Blocking, !gates$GatePassed) &&
    all(gates$ReconciliationOnly) && all(!gates$ExecutionAttempted) &&
    identical(
      manifest$ImplementationIdentity,
      mfrmr_gtds3l_implementation_identity()
    ) && identical(manifest$Summary$ReadinessGateCount, 10L) &&
    identical(manifest$Summary$PassingReadinessGateCount, 4L) &&
    identical(manifest$Summary$BlockingReadinessGateCount, 6L) &&
    identical(manifest$Summary$CurrentDependencyCount, 5L) &&
    identical(manifest$Summary$AvailableCurrentDependencyCount, 5L) &&
    isTRUE(manifest$Summary$ParentEvidenceIdentityBound) &&
    isTRUE(manifest$Summary$SharedExecutionSubstrateQualified) &&
    !isTRUE(manifest$Summary$ExactEnvironmentIdentityFrozen) &&
    identical(manifest$Summary$PlannedDatasetAttemptCount, 42L) &&
    identical(manifest$Summary$IdentityBoundGenerationRequestCount, 0L) &&
    identical(manifest$Summary$CandidateRouteUnitCount, 50L) &&
    identical(
      manifest$Summary$BackendCriterionFrozenCandidateRouteUnitCount, 8L
    ) && identical(
      manifest$Summary$IdentityBoundBackendRequestCount, 0L
    ) && identical(manifest$Summary$CandidateRouteEstimandCount, 100L) &&
    identical(manifest$Summary$IdentityBoundMetricRequestCount, 0L) &&
    identical(manifest$Summary$OpenTerminalUnitCount, 92L) &&
    identical(
      manifest$Summary$IdentityBoundTerminalOrchestrationCount, 0L
    ) && !isTRUE(manifest$Summary$TechnicalLaunchReady) && identical(
      manifest$Summary$CurrentDisposition,
      "no_go_missing_execution_bridge"
    ) && !isTRUE(manifest$Summary$Planned855RngStreamOpened) &&
    !isTRUE(manifest$Summary$ExploratoryResponseGenerated) &&
    !isTRUE(manifest$Summary$BackendCallMade) &&
    !isTRUE(manifest$Summary$FitReturned) &&
    !isTRUE(manifest$Summary$MetricComputed) &&
    !isTRUE(manifest$Summary$ExploratoryExecutionAllowed) &&
    !isTRUE(manifest$Summary$SimulationValidationReady) &&
    !isTRUE(manifest$Summary$PublicSupportReady) &&
    identical(manifest$Summary$FeatureMaturity, "specified")
  if (!valid) {
    stop("The D-SIM-3 launch-readiness manifest was altered.", call. = FALSE)
  }
  invisible(TRUE)
}
