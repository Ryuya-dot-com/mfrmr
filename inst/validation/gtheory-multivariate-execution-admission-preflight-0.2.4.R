# Draft.85c3 multivariate G-theory execution-admission preflight.
#
# Repository-internal only. This file proves that planned responses and
# backend calls remain unreachable until independent evidence closes every
# execution prerequisite. It does not create a receipt, authorize a lane,
# generate a planned response, or call an estimator.

mfrmr_gtvf_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtvd_plan", "mfrmr_gtvd_assert_plan",
    "mfrmr_gtvd_freeze_receipt_template",
    "mfrmr_gtvd_assert_freeze_receipt_template",
    "mfrmr_gtve_manifest", "mfrmr_gtve_assert_manifest"
  )
  target <- environment(mfrmr_gtvf_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = target, inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81 and the Draft.85a0-c2 chain before Draft.85c3: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtvf_exact_object <- function(object, expected_names, expected_class) {
  identical(names(object), expected_names) &&
    identical(class(object), expected_class) &&
    setequal(names(attributes(object)), c("names", "class"))
}

mfrmr_gtvf_scalar_character <- function(value, argument, missing_ok = FALSE) {
  valid <- is.character(value) && length(value) == 1L &&
    if (isTRUE(missing_ok)) is.na(value) || nzchar(value) else
      !is.na(value) && nzchar(value)
  if (!valid) stop(argument, " must be one ",
                   if (isTRUE(missing_ok)) "nonempty or missing " else "nonempty ",
                   "character value.", call. = FALSE)
  value
}

mfrmr_gtvf_environment_values <- function() {
  package_available <- function(package) {
    suppressWarnings(requireNamespace(package, quietly = TRUE))
  }
  package_version <- function(package, available) {
    if (!isTRUE(available)) return(NA_character_)
    as.character(utils::packageVersion(package))
  }
  lme4_available <- package_available("lme4")
  glmmtmb_available <- package_available("glmmTMB")
  tmb_available <- package_available("TMB")
  build_tmb <- if (glmmtmb_available) {
    namespace <- suppressWarnings(asNamespace("glmmTMB"))
    if (exists(".TMB.build.version", envir = namespace, inherits = FALSE)) {
      as.character(get(".TMB.build.version", envir = namespace,
                       inherits = FALSE))
    } else {
      NA_character_
    }
  } else {
    NA_character_
  }
  list(
    RVersion = R.version.string,
    Platform = R.version$platform,
    Lme4Available = lme4_available,
    Lme4Version = package_version("lme4", lme4_available),
    GlmmTMBAvailable = glmmtmb_available,
    GlmmTMBVersion = package_version("glmmTMB", glmmtmb_available),
    TMBAvailable = tmb_available,
    TMBVersion = package_version("TMB", tmb_available),
    GlmmTMBBuildTMBVersion = build_tmb
  )
}

mfrmr_gtvf_environment_snapshot <- function(
    values = mfrmr_gtvf_environment_values()) {
  required <- c(
    "RVersion", "Platform", "Lme4Available", "Lme4Version",
    "GlmmTMBAvailable", "GlmmTMBVersion", "TMBAvailable", "TMBVersion",
    "GlmmTMBBuildTMBVersion"
  )
  if (!is.list(values) || !identical(names(values), required)) {
    stop("The Draft.85c3 environment values have an invalid schema.",
         call. = FALSE)
  }
  mfrmr_gtvf_scalar_character(values$RVersion, "RVersion")
  mfrmr_gtvf_scalar_character(values$Platform, "Platform")
  logical_fields <- c("Lme4Available", "GlmmTMBAvailable", "TMBAvailable")
  if (!all(vapply(values[logical_fields], function(value) {
    is.logical(value) && length(value) == 1L && !is.na(value)
  }, logical(1L)))) {
    stop("Package availability must contain exact TRUE/FALSE values.",
         call. = FALSE)
  }
  version_pairs <- list(
    c("Lme4Available", "Lme4Version"),
    c("GlmmTMBAvailable", "GlmmTMBVersion"),
    c("TMBAvailable", "TMBVersion")
  )
  for (pair in version_pairs) {
    available <- values[[pair[[1L]]]]
    version <- values[[pair[[2L]]]]
    mfrmr_gtvf_scalar_character(version, pair[[2L]], missing_ok = TRUE)
    if (isTRUE(available) != !is.na(version)) {
      stop("Package availability and version identity disagree for ",
           pair[[2L]], ".", call. = FALSE)
    }
  }
  mfrmr_gtvf_scalar_character(
    values$GlmmTMBBuildTMBVersion, "GlmmTMBBuildTMBVersion",
    missing_ok = TRUE
  )
  packages_available <- all(unlist(values[logical_fields], use.names = FALSE))
  dependency_match <- packages_available &&
    !is.na(values$GlmmTMBBuildTMBVersion) &&
    identical(values$GlmmTMBBuildTMBVersion, values$TMBVersion)
  payload <- c(list(
    Contract = "gtheory_multivariate_environment_snapshot_draft85c3_v1"
  ), values, list(
    GlmmTMBRuntimeTMBVersion = values$TMBVersion,
    RequiredBackendRoutes = c(
      "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
    ),
    ConQuestRouteIncluded = FALSE
  ))
  structure(c(payload, list(
    SnapshotHash = mfrmr_gta_hash(payload),
    RequiredPackagesAvailable = packages_available,
    DependencyABIMatch = dependency_match,
    DiagnosticOverrideAllowed = FALSE,
    EnvironmentReadyForBackendQualification =
      packages_available && dependency_match,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    RecoveryExecuted = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvf_environment", "list"))
}

mfrmr_gtvf_assert_environment_snapshot <- function(snapshot) {
  payload_fields <- c(
    "Contract", "RVersion", "Platform", "Lme4Available", "Lme4Version",
    "GlmmTMBAvailable", "GlmmTMBVersion", "TMBAvailable", "TMBVersion",
    "GlmmTMBBuildTMBVersion", "GlmmTMBRuntimeTMBVersion",
    "RequiredBackendRoutes", "ConQuestRouteIncluded"
  )
  suffix_fields <- c(
    "SnapshotHash", "RequiredPackagesAvailable", "DependencyABIMatch",
    "DiagnosticOverrideAllowed", "EnvironmentReadyForBackendQualification",
    "BackendQualificationReady", "PilotExecutionAuthorized",
    "ConfirmationExecutionAuthorized", "RecoveryExecuted",
    "PublicSupportReady"
  )
  if (!mfrmr_gtvf_exact_object(
    snapshot, c(payload_fields, suffix_fields),
    c("mfrmr_gtvf_environment", "list")
  )) {
    stop("A typed Draft.85c3 environment snapshot is required.",
         call. = FALSE)
  }
  values <- unclass(snapshot[c(
    "RVersion", "Platform", "Lme4Available", "Lme4Version",
    "GlmmTMBAvailable", "GlmmTMBVersion", "TMBAvailable", "TMBVersion",
    "GlmmTMBBuildTMBVersion"
  )])
  expected <- mfrmr_gtvf_environment_snapshot(values)
  if (!identical(snapshot, expected)) {
    stop("The Draft.85c3 environment identity or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvf_accuracy_rule_template <- function(plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  criteria <- plan$RecoveryThresholdRegistry
  payload <- list(
    Contract = "gtheory_multivariate_accuracy_rule_template_draft85c3_v1",
    PlanHash = plan$PlanHash,
    CriterionTable = criteria,
    CriterionTableHash = mfrmr_gta_hash(criteria),
    IndependentBasisId = NA_character_,
    IndependentBasisCitation = NA_character_,
    IndependentBasisSHA256 = NA_character_,
    UTCFreezeTimestamp = NA_character_,
    SignerOrAuthorityId = NA_character_,
    ExternalRecordId = NA_character_,
    PilotOutcomeConsulted = FALSE,
    ConfirmationOutcomeConsulted = FALSE
  )
  structure(c(payload, list(
    TemplateHash = mfrmr_gta_hash(payload),
    NumericThresholdsComplete = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    RecoveryThresholdFrozen = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    RecoveryEvidenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvf_accuracy_template", "list"))
}

mfrmr_gtvf_assert_accuracy_rule_template <- function(
    template, plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  expected <- mfrmr_gtvf_accuracy_rule_template(plan)
  if (!identical(template, expected)) {
    stop("The Draft.85c3 accuracy-rule template or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvf_isolation_template <- function(plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  payload <- list(
    Contract = "gtheory_multivariate_isolation_template_draft85c3_v1",
    PlanHash = plan$PlanHash,
    CandidateExecutorSHA256 = NA_character_,
    CandidateInputSchemaSHA256 = NA_character_,
    CandidateReceiptSchemaSHA256 = NA_character_,
    ReferenceVaultSHA256 = NA_character_,
    IsolationAuditId = NA_character_,
    CandidateCanReadScenarioIdentity = NA,
    CandidateCanReadDataSeed = NA,
    CandidateCanReadReferenceIdentity = NA,
    CandidateCanReadTruth = NA,
    CandidateCanReadAccuracyThreshold = NA,
    TruthReleaseRequiresCompleteReceipts = TRUE
  )
  structure(c(payload, list(
    TemplateHash = mfrmr_gta_hash(payload),
    CandidateSchemaReady = FALSE,
    ReceiptSchemaReady = FALSE,
    ReferenceVaultReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    CandidateCompletionSealed = FALSE,
    TruthReleaseAuthorized = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvf_isolation_template", "list"))
}

mfrmr_gtvf_assert_isolation_template <- function(
    template, plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  if (!identical(template, mfrmr_gtvf_isolation_template(plan))) {
    stop("The Draft.85c3 isolation template or readiness was altered.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvf_authority_templates <- function(plan = mfrmr_gtvd_plan()) {
  mfrmr_gtvd_assert_plan(plan)
  stages <- plan$StageCatalog
  data.frame(
    StageOrdinal = stages$StageOrdinal,
    StageId = stages$StageId,
    LaneOpaqueId = stages$LaneOpaqueId,
    AuthorityId = NA_character_,
    AuthorityTokenSHA256 = NA_character_,
    SignerOrAuthorityId = NA_character_,
    UTCAuthorizedAt = NA_character_,
    UTCExpiresAt = NA_character_,
    AuthorizedAction = c(
      "pilot_candidate_execution_only",
      "confirmation_candidate_execution_only",
      "negative_control_structural_execution_only"
    ),
    AuthorityReady = FALSE,
    ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvf_prerequisite_audit <- function(
    plan, generator_manifest, environment_snapshot, freeze_template,
    accuracy_template, isolation_template, authority_templates,
    upstream_validated = FALSE) {
  if (!is.logical(upstream_validated) || length(upstream_validated) != 1L ||
      is.na(upstream_validated)) {
    stop("`upstream_validated` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!isTRUE(upstream_validated)) {
    mfrmr_gtvd_assert_plan(plan)
    mfrmr_gtve_assert_manifest(
      generator_manifest, plan, generator_manifest$FixtureRegistry
    )
    mfrmr_gtvf_assert_environment_snapshot(environment_snapshot)
    mfrmr_gtvd_assert_freeze_receipt_template(plan, freeze_template)
    mfrmr_gtvf_assert_accuracy_rule_template(accuracy_template, plan)
    mfrmr_gtvf_assert_isolation_template(isolation_template, plan)
    if (!identical(authority_templates,
                   mfrmr_gtvf_authority_templates(plan))) {
      stop("The Draft.85c3 lane-authority templates were altered.",
           call. = FALSE)
    }
  }
  ids <- plan$ExecutionPrerequisiteRegistry$PrerequisiteId
  satisfied <- c(
    external_freeze_receipt = freeze_template$FreezeReceiptReady,
    clean_source_identity = FALSE,
    all_four_matched_backends_qualified = FALSE,
    truth_blind_process_boundary =
      isolation_template$TruthBlindProcessBoundaryReady,
    lane_specific_authority = all(authority_templates$AuthorityReady),
    candidate_completion_before_truth_release =
      isolation_template$CandidateCompletionSealed,
    accuracy_threshold_before_confirmation =
      accuracy_template$IndependentAccuracyRuleReady,
    no_diagnostic_override =
      !environment_snapshot$DiagnosticOverrideAllowed
  )
  if (!identical(names(satisfied), ids)) {
    stop("The Draft.85c1/c3 prerequisite registry drifted.", call. = FALSE)
  }
  reason <- c(
    "external_receipt_template_only",
    "source_commit_and_clean_tree_receipt_not_supplied",
    if (environment_snapshot$EnvironmentReadyForBackendQualification) {
      "environment_only_no_four_route_fit_receipts"
    } else {
      "backend_environment_or_dependency_abi_not_ready"
    },
    "candidate_executor_and_reference_vault_not_isolated",
    "lane_authority_templates_only",
    "no_candidate_completion_receipts_exist",
    "independent_numeric_accuracy_rule_not_supplied",
    "diagnostic_override_is_prohibited"
  )
  data.frame(
    PrerequisiteOrdinal = plan$ExecutionPrerequisiteRegistry$PrerequisiteOrdinal,
    PrerequisiteId = ids,
    Requirement = plan$ExecutionPrerequisiteRegistry$Requirement,
    CurrentSatisfied = unname(as.logical(satisfied)),
    PartialExecutionAllowed = FALSE,
    EvidenceState = reason,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtvf_function_identity <- function() {
  function_names <- c(
    "mfrmr_gtvf_require_primitives", "mfrmr_gtvf_exact_object",
    "mfrmr_gtvf_scalar_character", "mfrmr_gtvf_environment_values",
    "mfrmr_gtvf_environment_snapshot",
    "mfrmr_gtvf_assert_environment_snapshot",
    "mfrmr_gtvf_accuracy_rule_template",
    "mfrmr_gtvf_assert_accuracy_rule_template",
    "mfrmr_gtvf_isolation_template", "mfrmr_gtvf_assert_isolation_template",
    "mfrmr_gtvf_authority_templates", "mfrmr_gtvf_prerequisite_audit",
    "mfrmr_gtvf_function_identity", "mfrmr_gtvf_manifest",
    "mfrmr_gtvf_assert_manifest", "mfrmr_gtvf_dispatch_guard"
  )
  target <- environment(mfrmr_gtvf_function_identity)
  hashes <- vapply(function_names, function(name) {
    if (!exists(name, envir = target, inherits = TRUE)) {
      stop("A Draft.85c3 implementation function is missing: ", name, ".",
           call. = FALSE)
    }
    fun <- get(name, envir = target, inherits = TRUE)
    mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
  }, character(1L))
  data.frame(Function = function_names, SHA256 = unname(hashes),
             stringsAsFactors = FALSE)
}

mfrmr_gtvf_manifest <- function(
    plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    environment_snapshot = mfrmr_gtvf_environment_snapshot()) {
  mfrmr_gtvd_assert_plan(plan)
  mfrmr_gtve_assert_manifest(
    generator_manifest, plan, generator_manifest$FixtureRegistry
  )
  mfrmr_gtvf_assert_environment_snapshot(environment_snapshot)
  freeze_template <- mfrmr_gtvd_freeze_receipt_template(plan)
  accuracy_template <- mfrmr_gtvf_accuracy_rule_template(plan)
  isolation_template <- mfrmr_gtvf_isolation_template(plan)
  authorities <- mfrmr_gtvf_authority_templates(plan)
  prerequisites <- mfrmr_gtvf_prerequisite_audit(
    plan, generator_manifest, environment_snapshot, freeze_template,
    accuracy_template, isolation_template, authorities,
    upstream_validated = TRUE
  )
  implementation <- mfrmr_gtvf_function_identity()
  policy <- list(
    Contract = "gtheory_multivariate_execution_admission_draft85c3_v1",
    PlanHash = plan$PlanHash,
    PlanCoreHash = plan$PlanCoreHash,
    GeneratorManifestHash = generator_manifest$ManifestHash,
    GeneratorImplementationIdentityHash =
      generator_manifest$ImplementationIdentityHash,
    FreezeReceiptTemplate = freeze_template,
    AccuracyRuleTemplate = accuracy_template,
    IsolationTemplate = isolation_template,
    AuthorityTemplates = authorities,
    PrerequisiteAudit = prerequisites,
    AllowedBackendRoutes = c(
      "lme4_ml", "lme4_reml", "glmmTMB_ml", "glmmTMB_reml"
    ),
    ConQuestRouteIncluded = FALSE,
    PlannedSeedMaterialIncluded = FALSE
  )
  payload <- c(policy, list(
    PolicyHash = mfrmr_gta_hash(policy),
    EnvironmentSnapshot = environment_snapshot,
    EnvironmentSnapshotHash = environment_snapshot$SnapshotHash,
    ImplementationIdentity = implementation,
    ImplementationIdentityHash = mfrmr_gta_hash(implementation)
  ))
  structure(c(payload, list(
    ManifestHash = mfrmr_gta_hash(payload),
    PlanIdentityReady = TRUE,
    GeneratorPreflightReady = TRUE,
    EnvironmentABIMatch = environment_snapshot$DependencyABIMatch,
    EnvironmentReadyForBackendQualification =
      environment_snapshot$EnvironmentReadyForBackendQualification,
    ExternalFreezeReady = FALSE,
    CleanSourceIdentityReady = FALSE,
    IndependentAccuracyRuleReady = FALSE,
    TruthBlindProcessBoundaryReady = FALSE,
    BackendQualificationReady = FALSE,
    PilotExecutionAuthorized = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    NegativeControlExecutionAuthorized = FALSE,
    ExecutionGateClosed = TRUE,
    BackendExecutionOccurred = FALSE,
    PlannedResponseGenerated = FALSE,
    RecoveryExecuted = FALSE,
    RecoveryEvidenceReady = FALSE,
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    PublicSupportReady = FALSE
  )), class = c("mfrmr_gtvf_manifest", "list"))
}

mfrmr_gtvf_assert_manifest <- function(
    manifest, plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    current_environment = mfrmr_gtvf_environment_snapshot()) {
  canonical <- mfrmr_gtvf_manifest(plan, generator_manifest, current_environment)
  if (!identical(manifest, canonical)) {
    stop("The Draft.85c3 admission manifest, environment, or readiness was altered.",
         call. = FALSE)
  }
  # The policy root excludes only the machine-dependent environment and
  # implementation hashes. It is pinned so rehashing a relaxed prerequisite
  # or authority state cannot manufacture a canonical gate.
  if (!identical(
    manifest$PolicyHash,
    "4d5f9a3481bdef0c935970bd65df9f65f86a76cfa70f197b6c1a4fcc39db0443"
  )) {
    stop("The Draft.85c3 sealed execution policy root does not match.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_gtvf_dispatch_guard <- function(
    manifest, stage_id, backend_route, callback, ..., authorize = FALSE,
    plan = mfrmr_gtvd_plan(),
    generator_manifest = mfrmr_gtve_manifest(plan),
    current_environment = mfrmr_gtvf_environment_snapshot()) {
  mfrmr_gtvf_assert_manifest(
    manifest, plan, generator_manifest, current_environment
  )
  stage_id <- mfrmr_gtvf_scalar_character(stage_id, "stage_id")
  backend_route <- mfrmr_gtvf_scalar_character(
    backend_route, "backend_route"
  )
  if (!stage_id %in% plan$StageCatalog$StageId) {
    stop("The requested stage is not in the sealed Draft.85c1 plan.",
         call. = FALSE)
  }
  if (!backend_route %in% manifest$AllowedBackendRoutes) {
    stop("The requested backend route is outside the Draft.85c3 estimand.",
         call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }
  if (!is.logical(authorize) || length(authorize) != 1L || is.na(authorize)) {
    stop("`authorize` must be TRUE or FALSE.", call. = FALSE)
  }
  stage_flag <- switch(
    stage_id,
    pilot = manifest$PilotExecutionAuthorized,
    confirmation = manifest$ConfirmationExecutionAuthorized,
    negative_control = manifest$NegativeControlExecutionAuthorized
  )
  if (!isTRUE(authorize) || !isTRUE(stage_flag) ||
      isTRUE(manifest$ExecutionGateClosed)) {
    stop(
      "Draft.85c3 execution is blocked before response generation or backend ",
      "dispatch; external freeze, clean source, isolated candidate execution, ",
      "matched-backend qualification, and lane authority are incomplete.",
      call. = FALSE
    )
  }
  callback(...)
}
