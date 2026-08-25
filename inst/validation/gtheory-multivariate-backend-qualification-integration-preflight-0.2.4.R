# Draft.85c4l multivariate G-theory backend-qualification integration.
#
# Repository-internal only. This non-executing receipt projects the trusted
# Draft.85c4k route/pair identities into successor views of the Draft.85c4e
# repair plan and Draft.85c3 prerequisite audit. It does not alter either
# historical object and cannot dispatch a planned study, recovery, or public
# promotion.

mfrmr_gtvs_require_primitives <- function() {
  required <- c(
    "mfrmr_gtvd_plan", "mfrmr_gtvf_assert_manifest",
    "mfrmr_gtvl_assert_manifest", "mfrmr_gtvm_assert_manifest",
    "mfrmr_gtvm_qualification_policy", "mfrmr_gtvr_assert_live_evidence"
  )
  target <- environment(mfrmr_gtvs_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.85c1, c3, and c4e through c4k before Draft.85c4l: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvs_hash <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Draft.85c4l requires `digest`.", call. = FALSE)
  }
  digest::digest(value, algo = "sha256", serialize = TRUE)
}

mfrmr_gtvs_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    identical(sort(names(attributes(object))), c("class", "names"))
}

mfrmr_gtvs_assert_parents <- function(
    c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvs_require_primitives()
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  validation_dir <- normalizePath(validation_dir, mustWork = TRUE)
  mfrmr_gtvf_assert_manifest(c3_manifest)
  mfrmr_gtvl_assert_manifest(
    c4e_manifest, repo_root, c4e_manifest$SuppliedEnvironmentIdentity
  )
  mfrmr_gtvm_assert_manifest(c4f_manifest, repo_root, c4e_manifest)
  mfrmr_gtvr_assert_live_evidence(
    capability_evidence, qualification_receipt, repair_receipt,
    repair_worker_environment, c4e_manifest, c4f_manifest,
    qualification_worker_environment, capability_worker_environment,
    repo_root, validation_dir
  )
  if (!identical(c4e_manifest$RepairPlan$StepId, c(
    "isolated_library_created", "package_sources_pinned",
    "selected_tmb_installed", "glmmtmb_rebuilt_against_selected_tmb",
    "fresh_process_identity_reobserved", "four_route_receipts_completed"
  )) || !identical(
    c4e_manifest$QualificationReceiptTemplate$RouteId,
    capability_evidence$TrustedRouteRegistry$RouteId
  ) || !identical(
    qualification_receipt$ReceiptHash,
    capability_evidence$C4JQualificationReceiptHash
  ) || !identical(
    repair_receipt$ReceiptHash, capability_evidence$C4IRepairReceiptHash
  )) {
    stop("The Draft.85c4l parent lineage does not join exactly.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvs_repair_completion_registry <- function(
    c4e_manifest, repair_receipt, qualification_receipt,
    capability_evidence) {
  plan <- c4e_manifest$RepairPlan
  c4i_flags <- c(
    repair_receipt$IsolatedLibraryCreated,
    repair_receipt$PackageSourcesPinned,
    repair_receipt$SelectedTMBInstalled,
    repair_receipt$GlmmTMBRebuiltAgainstSelectedTMB,
    repair_receipt$FreshProcessIdentityReobserved
  )
  if (!identical(c4i_flags, rep(TRUE, 5L)) ||
      isTRUE(repair_receipt$FourRouteReceiptsCompleted) ||
      !isTRUE(capability_evidence$BackendQualificationReady)) {
    stop("The Draft.85c4e repair sequence is not ready for c4l projection.",
         call. = FALSE)
  }
  builds <- repair_receipt$BuildReceiptRegistry
  if (!is.data.frame(builds) ||
      !identical(builds$Package, c("TMB", "glmmTMB"))) {
    stop("The Draft.85c4i build receipt registry was altered.",
         call. = FALSE)
  }
  evidence_hash <- c(
    mfrmr_gtvs_hash(list(
      RepairRoot = repair_receipt$RepairRoot,
      OverlayLibrary = repair_receipt$OverlayLibrary
    )),
    repair_receipt$SourceArtifactRegistryHash,
    mfrmr_gtvs_hash(builds[1L, , drop = FALSE]),
    mfrmr_gtvs_hash(builds[2L, , drop = FALSE]),
    repair_receipt$FreshProcessReceiptHash,
    mfrmr_gtvs_hash(list(
      QualificationReceiptHash = qualification_receipt$ReceiptHash,
      TrustedRouteRegistryHash =
        capability_evidence$TrustedRouteRegistryHash,
      TrustedPairRegistryHash = capability_evidence$TrustedPairRegistryHash
    ))
  )
  data.frame(
    StepOrdinal = plan$StepOrdinal,
    StepId = plan$StepId,
    RequiredEvidence = plan$RequiredEvidence,
    SourceDraft = c(rep("Draft.85c4i", 5L), "Draft.85c4j+c4k"),
    EvidenceHash = unname(evidence_hash),
    EvidenceReady = rep(TRUE, 6L),
    MutationScope = c(
      "temporary_repair_root_only", "read_only_source_identity",
      "temporary_overlay_install", "temporary_overlay_rebuild",
      "fresh_process_observation", "qualification_receipt_observation"
    ),
    OriginalLibraryMutated = rep(FALSE, 6L),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvs_route_registry <- function(
    c4e_manifest, repair_receipt, qualification_receipt,
    capability_evidence) {
  template <- c4e_manifest$QualificationReceiptTemplate
  trusted <- capability_evidence$TrustedRouteRegistry
  route_ids <- template$RouteId
  if (!identical(names(qualification_receipt$RouteReceipts), route_ids) ||
      !identical(trusted$RouteId, route_ids)) {
    stop("The Draft.85c4l route order or identity changed.", call. = FALSE)
  }
  policy <- mfrmr_gtvm_qualification_policy()$RouteRegistry
  rows <- lapply(seq_along(route_ids), function(index) {
    route <- qualification_receipt$RouteReceipts[[route_ids[[index]]]]
    data.frame(
      RouteOrdinal = template$RouteOrdinal[[index]],
      RouteId = route_ids[[index]],
      Backend = policy$Backend[[index]],
      Criterion = policy$Criterion[[index]],
      C4ETemplateEnvironmentIdentityHash =
        template$EnvironmentIdentityHash[[index]],
      RepairedEnvironmentReceiptHash = repair_receipt$FreshProcessReceiptHash,
      TrustedQualificationReceiptHash =
        trusted$RevalidatedRouteReceiptHash[[index]],
      FitSpecificationHash = route$SpecificationHash,
      SemanticModelHash = route$SemanticModelHash,
      FitResultHash = route$FitResultHash,
      SandboxFitObjectHash = trusted$SandboxFitObjectHash[[index]],
      CapabilityProfileSemanticHash =
        trusted$CapabilityProfileSemanticHash[[index]],
      FreshProcess = route$FreshProcessVerified,
      DependencyABIMatch = route$DependencyABIMatch,
      DiagnosticOverrideUsed = route$DiagnosticOverrideUsed,
      FullB1ObjectRevalidated = trusted$FullB1ObjectRevalidated[[index]],
      ProcessCapabilityIsolationReady =
        trusted$ProcessCapabilityIsolationReady[[index]],
      ReceiptReady = trusted$TrustedReceiptReady[[index]],
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvs_pair_registry <- function(
    qualification_receipt, capability_evidence) {
  policy <- mfrmr_gtvm_qualification_policy()$PairRegistry
  trusted <- capability_evidence$TrustedPairRegistry
  pair_ids <- policy$PairId
  if (!identical(names(qualification_receipt$PairReceipts), pair_ids) ||
      !identical(trusted$PairId, pair_ids)) {
    stop("The Draft.85c4l pair order or identity changed.", call. = FALSE)
  }
  rows <- lapply(seq_along(pair_ids), function(index) {
    pair <- qualification_receipt$PairReceipts[[pair_ids[[index]]]]
    data.frame(
      PairOrdinal = policy$PairOrdinal[[index]],
      PairId = pair_ids[[index]],
      Criterion = policy$Criterion[[index]],
      Lme4RouteId = policy$Lme4RouteId[[index]],
      GlmmTMBRouteId = policy$GlmmTMBRouteId[[index]],
      TrustedPairReceiptHash =
        trusted$RevalidatedPairReceiptHash[[index]],
      SpecificationHash = pair$SpecificationHash,
      SemanticModelHash = pair$SemanticModelHash,
      SandboxParityObjectHash = trusted$SandboxParityObjectHash[[index]],
      CapabilityProfileSemanticHash =
        trusted$CapabilityProfileSemanticHash[[index]],
      ToleranceRegistryHash = pair$ToleranceRegistryHash,
      NumericalParityPassed = pair$NumericalParityPassed,
      BothPointGatesPassed = pair$BothPointGatesPassed,
      BackendDependencyIdentityPassed =
        pair$BackendDependencyIdentityPassed,
      ExactSpecificationMatch = pair$ExactSpecificationMatch,
      ExactSemanticModelMatch = pair$ExactSemanticModelMatch,
      MaximumCovarianceAbsoluteDifference =
        pair$MaximumCovarianceAbsoluteDifference,
      MaximumCovarianceRelativeDifference =
        pair$MaximumCovarianceRelativeDifference,
      MaximumFixedAbsoluteDifference = pair$MaximumFixedAbsoluteDifference,
      LogLikAbsoluteDifference = pair$LogLikAbsoluteDifference,
      FullB1ObjectRevalidated = trusted$FullB1ObjectRevalidated[[index]],
      ProcessCapabilityIsolationReady =
        trusted$ProcessCapabilityIsolationReady[[index]],
      PairReady = trusted$TrustedPairReady[[index]],
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_gtvs_prerequisite_projection <- function(
    c3_manifest, capability_evidence) {
  audit <- c3_manifest$PrerequisiteAudit
  expected_ids <- c(
    "external_freeze_receipt", "clean_source_identity",
    "all_four_matched_backends_qualified", "truth_blind_process_boundary",
    "lane_specific_authority", "candidate_completion_before_truth_release",
    "accuracy_threshold_before_confirmation", "no_diagnostic_override"
  )
  if (!is.data.frame(audit) || !identical(audit$PrerequisiteId, expected_ids)) {
    stop("The Draft.85c3 prerequisite registry drifted.", call. = FALSE)
  }
  backend_index <- match("all_four_matched_backends_qualified", expected_ids)
  no_override_index <- match("no_diagnostic_override", expected_ids)
  prior <- audit$CurrentSatisfied
  if (isTRUE(prior[[backend_index]]) || !isTRUE(prior[[no_override_index]]) ||
      !isTRUE(capability_evidence$BackendQualificationReady) ||
      isTRUE(capability_evidence$DiagnosticOverrideAllowed)) {
    stop("The Draft.85c4l prerequisite transition is not canonical.",
         call. = FALSE)
  }
  projected <- prior
  projected[[backend_index]] <- TRUE
  evidence_state <- audit$EvidenceState
  evidence_state[[backend_index]] <-
    "c4k_trusted_four_route_and_two_pair_receipts"
  evidence_hash <- rep(NA_character_, length(expected_ids))
  evidence_hash[[backend_index]] <- capability_evidence$EvidenceHash
  evidence_hash[[no_override_index]] <- c3_manifest$EnvironmentSnapshotHash
  data.frame(
    PrerequisiteOrdinal = audit$PrerequisiteOrdinal,
    PrerequisiteId = audit$PrerequisiteId,
    Requirement = audit$Requirement,
    PriorSatisfied = prior,
    ProjectedSatisfied = projected,
    TransitionedByIntegration = !prior & projected,
    PartialExecutionAllowed = audit$PartialExecutionAllowed,
    EvidenceState = evidence_state,
    EvidenceHash = evidence_hash,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvs_payload_fields <- function() {
  c(
    "Contract", "C3ManifestHash", "C3PolicyHash",
    "C3PrerequisiteAuditHash", "C4EManifestHash", "C4ERepairPlanHash",
    "C4EQualificationReceiptTemplateHash", "C4FManifestHash",
    "C4FPolicyHash", "C4IRepairReceiptHash",
    "C4JQualificationReceiptHash", "C4KEvidenceHash",
    "C4KTrustedRouteRegistryHash", "C4KTrustedPairRegistryHash",
    "RepairCompletionRegistry", "RepairCompletionRegistryHash",
    "QualificationRouteRegistry", "QualificationRouteRegistryHash",
    "QualifiedPairRegistry", "QualifiedPairRegistryHash",
    "PrerequisiteProjection", "PrerequisiteProjectionHash",
    "ImplementationIdentity", "ImplementationIdentityHash",
    "HistoricalObjectsMutated", "PlannedSeedMaterialIncluded",
    "ReferenceTruthIncluded", "ConQuestRouteIncluded"
  )
}

mfrmr_gtvs_implementation_identity <- function() {
  function_names <- c(
    "mfrmr_gtvs_require_primitives", "mfrmr_gtvs_hash",
    "mfrmr_gtvs_exact_object", "mfrmr_gtvs_assert_parents",
    "mfrmr_gtvs_repair_completion_registry", "mfrmr_gtvs_route_registry",
    "mfrmr_gtvs_pair_registry", "mfrmr_gtvs_prerequisite_projection",
    "mfrmr_gtvs_payload_fields", "mfrmr_gtvs_implementation_identity",
    "mfrmr_gtvs_integration_receipt", "mfrmr_gtvs_assert_receipt",
    "mfrmr_gtvs_dispatch_guard"
  )
  target <- environment(mfrmr_gtvs_implementation_identity)
  data.frame(
    Function = function_names,
    SHA256 = vapply(function_names, function(name) {
      if (!exists(name, envir = target, inherits = FALSE)) {
        stop("A Draft.85c4l implementation function is missing: ", name,
             ".", call. = FALSE)
      }
      fun <- get(name, envir = target, inherits = FALSE)
      mfrmr_gtvs_hash(list(
        Formals = paste(deparse(formals(fun), width.cutoff = 500L),
                        collapse = "\n"),
        Body = paste(deparse(body(fun), width.cutoff = 500L),
                     collapse = "\n")
      ))
    }, character(1L)),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvs_integration_receipt <- function(
    c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  mfrmr_gtvs_assert_parents(
    c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root, validation_dir
  )
  repair_registry <- mfrmr_gtvs_repair_completion_registry(
    c4e_manifest, repair_receipt, qualification_receipt, capability_evidence
  )
  routes <- mfrmr_gtvs_route_registry(
    c4e_manifest, repair_receipt, qualification_receipt, capability_evidence
  )
  pairs <- mfrmr_gtvs_pair_registry(
    qualification_receipt, capability_evidence
  )
  prerequisites <- mfrmr_gtvs_prerequisite_projection(
    c3_manifest, capability_evidence
  )
  implementation <- mfrmr_gtvs_implementation_identity()
  payload <- list(
    Contract =
      "gtheory_multivariate_backend_qualification_integration_draft85c4l_v1",
    C3ManifestHash = c3_manifest$ManifestHash,
    C3PolicyHash = c3_manifest$PolicyHash,
    C3PrerequisiteAuditHash = mfrmr_gtvs_hash(
      c3_manifest$PrerequisiteAudit
    ),
    C4EManifestHash = c4e_manifest$ManifestHash,
    C4ERepairPlanHash = c4e_manifest$RepairPlanHash,
    C4EQualificationReceiptTemplateHash =
      c4e_manifest$QualificationReceiptTemplateHash,
    C4FManifestHash = c4f_manifest$ManifestHash,
    C4FPolicyHash = c4f_manifest$QualificationPolicy$PolicyHash,
    C4IRepairReceiptHash = repair_receipt$ReceiptHash,
    C4JQualificationReceiptHash = qualification_receipt$ReceiptHash,
    C4KEvidenceHash = capability_evidence$EvidenceHash,
    C4KTrustedRouteRegistryHash =
      capability_evidence$TrustedRouteRegistryHash,
    C4KTrustedPairRegistryHash = capability_evidence$TrustedPairRegistryHash,
    RepairCompletionRegistry = repair_registry,
    RepairCompletionRegistryHash = mfrmr_gtvs_hash(repair_registry),
    QualificationRouteRegistry = routes,
    QualificationRouteRegistryHash = mfrmr_gtvs_hash(routes),
    QualifiedPairRegistry = pairs,
    QualifiedPairRegistryHash = mfrmr_gtvs_hash(pairs),
    PrerequisiteProjection = prerequisites,
    PrerequisiteProjectionHash = mfrmr_gtvs_hash(prerequisites),
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gtvs_hash(implementation),
    HistoricalObjectsMutated = FALSE,
    PlannedSeedMaterialIncluded = FALSE,
    ReferenceTruthIncluded = FALSE,
    ConQuestRouteIncluded = FALSE
  )
  transitioned <- prerequisites$TransitionedByIntegration
  structure(c(payload, list(
    ReceiptHash = mfrmr_gtvs_hash(payload),
    HistoricalC3ManifestPreserved = TRUE,
    HistoricalC4EManifestPreserved = TRUE,
    RepairPlanCompleted = all(repair_registry$EvidenceReady),
    AllRouteReceiptsReady = all(routes$ReceiptReady),
    AllPairReceiptsReady = all(pairs$PairReady),
    BackendQualificationAdmissionReady =
      all(repair_registry$EvidenceReady) && all(routes$ReceiptReady) &&
      all(pairs$PairReady),
    BackendQualificationReady = capability_evidence$BackendQualificationReady,
    ExactlyOneC3PrerequisiteTransitioned = sum(transitioned) == 1L,
    C3SatisfiedPrerequisiteCount =
      as.integer(sum(prerequisites$ProjectedSatisfied)),
    AllExecutionPrerequisitesReady =
      all(prerequisites$ProjectedSatisfied),
    IntegrationReceiptReady = TRUE,
    QualificationBackendExecutionObserved = TRUE,
    StudyOperationallyAdmissible = FALSE,
    DiagnosticOverrideAllowed = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    PlannedStudyBackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvs_receipt", "list"))
}

mfrmr_gtvs_assert_receipt <- function(
    receipt, c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  canonical <- mfrmr_gtvs_integration_receipt(
    c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root, validation_dir
  )
  if (!mfrmr_gtvs_exact_object(
    receipt, names(canonical), class(canonical)
  ) || !identical(receipt, canonical)) {
    stop("The Draft.85c4l integration receipt or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvs_dispatch_guard <- function(
    receipt, action, callback, ..., authorize = FALSE,
    c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root = ".",
    validation_dir = file.path("inst", "validation")) {
  allowed_actions <- c(
    "pilot", "confirmation", "negative_control", "planned_response",
    "recovery", "public_promotion"
  )
  if (!is.character(action) || length(action) != 1L || is.na(action) ||
      !action %in% allowed_actions) {
    stop("The Draft.85c4l action is outside the integration contract.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  mfrmr_gtvs_assert_receipt(
    receipt, c3_manifest, c4e_manifest, c4f_manifest, repair_receipt,
    qualification_receipt, capability_evidence,
    repair_worker_environment, qualification_worker_environment,
    capability_worker_environment, repo_root, validation_dir
  )
  stop(
    "Draft.85c4l integrates backend qualification only; all planned study, ",
    "recovery, decision, and public dispatch remains closed.",
    call. = FALSE
  )
}
