# Draft.83d2b2b1g14 production-adapter and reserved-manifest preflight.
#
# Repository-internal only. The production candidate/reference adapters are
# exercised on one nonreserved dataset. Reserved calibration replicates
# 201--300 remain sealed and execution-unauthorized.

mfrmr_gtwah_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtwag_contract",
    "mfrmr_gtwag_sealed_units", "mfrmr_gtwag_expected_candidate_rows",
    "mfrmr_gtwag_manifest_hash_valid", "mfrmr_gtwag_execute",
    "mfrmr_gtwaa_select_profile", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwd_capture", "mfrmr_gtwy_control",
    "mfrmr_gtwsv_control", "mfrmr_gtwsv_extract_start",
    "mfrmr_gtwsy_scale_metrics", "mfrmr_gtwaf_probe_lme4",
    "mfrmr_gtwaf_probe_glmmtmb", "mfrmr_gtwta_fit_objective",
    "mfrmr_gtwta_anchored_objective", "mfrmr_gtwta_reference",
    "mfrmr_gtwta_profile_boundary", "mfrmr_gtwta_target_theta_index",
    "mfrmr_gtwad_fit_objective", "mfrmr_gtwad_reference",
    "mfrmr_gtwad_sparse_oracle", "mfrmr_gtwad_profile_boundary",
    "mfrmr_gtwad_target_index", "mfrmr_gtw_registry"
  )
  preflight_environment <- environment(mfrmr_gtwah_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = preflight_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the b1g13 chain before b1g14 adapter preflight: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwah_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwah_policy <- function() {
  identity <- list(
    Contract = "production_adapter_preflight_policy_b1g14_v1",
    TargetComponent = "Rater",
    DryRunScenarioId = "GT-WI-baseline_complete-reference_1200",
    DryRunReplicate = 902L,
    ReservedReplicates = 201:300,
    ConfirmationReplicates = 501:700,
    ShardUnit = "one_replicate_all_30_datasets_all_four_methods",
    ReservedShardCount = 100L,
    AtomicUnitsPerShard = 120L,
    CandidateFitRowsPerShard = 1080L,
    CandidateDecisionRowsPerShard = 5760L,
    ReferenceRowsPerShard = 240L,
    OutputRoot = paste0(
      "validation-results/",
      "gtheory-stationarity-calibration-draft83d2b2b1g14"
    ),
    CandidateProfileSelection = "minimum_finite_objective_exact_tie_priority",
    BoundaryProbeAppliedAfterProfileSelection = TRUE,
    CandidateAndReferenceGeneratorHashMustMatch = TRUE,
    RuntimeIdentityRequired = TRUE,
    AdapterDependencyHashesRequired = TRUE,
    ShardAssignmentFrozenBeforeAuthorization = TRUE,
    CrossFilesystemRenamePermitted = FALSE,
    EarlyStoppingPermitted = FALSE,
    CalibrationResponsesUsed = FALSE,
    ConfirmationResponsesUsed = FALSE
  )
  structure(c(identity, list(
    PolicyHash = mfrmr_gta_hash(identity), PolicyFrozen = TRUE
  )), class = "mfrmr_gtwah_policy")
}

mfrmr_gtwah_policy_hash_valid <- function(policy) {
  if (!inherits(policy, "mfrmr_gtwah_policy") ||
      !isTRUE(policy$PolicyFrozen) || is.null(policy$PolicyHash)) return(FALSE)
  identity <- unclass(policy)
  identity$PolicyHash <- NULL
  identity$PolicyFrozen <- NULL
  identical(policy$PolicyHash, mfrmr_gta_hash(identity))
}

mfrmr_gtwah_source_registry <- function() {
  data.frame(
    SourceId = c(
      "morris_white_crowther_2019", "r_sessionInfo_current",
      "r_file_rename_current", "lme4_convergence_current",
      "glmmtmb_troubleshooting_current"
    ),
    Locator = c(
      "https://doi.org/10.1002/sim.8086",
      paste0(
        "https://stat.ethz.ch/R-manual/R-devel/library/",
        "utils/html/sessionInfo.html"
      ),
      "https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html",
      "https://lme4.github.io/lme4/reference/convergence.html",
      paste0(
        "https://glmmtmb.github.io/glmmTMB/articles/",
        "troubleshooting.html"
      )
    ),
    ContractRole = c(
      "complete ADEMP method-failure denominators",
      "runtime and loaded-package provenance",
      "same-directory rename and checked failure status",
      "optimizer termination remains separate from derivative evidence",
      "nonfinite convergence and Hessian states remain visible"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwah_runtime_identity <- function() {
  packages <- c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv"
  )
  versions <- vapply(packages, function(package) {
    as.character(utils::packageVersion(package))
  }, character(1L))
  identity <- list(
    RVersion = as.character(getRversion()),
    RPlatform = R.version$platform,
    RArch = R.version$arch,
    OS = unname(Sys.info()[["sysname"]]),
    OSRelease = unname(Sys.info()[["release"]]),
    PackageVersions = versions
  )
  c(identity, list(RuntimeHash = mfrmr_gta_hash(identity)))
}

mfrmr_gtwah_contract <- function(runner_contract, boundary_contract,
                                  glmm_reference_contract,
                                  lme4_reference_contract) {
  mfrmr_gtwah_require_primitives()
  if (!inherits(runner_contract, "mfrmr_gtwag_contract") ||
      !identical(
        runner_contract$ContractHash,
        "8fb599cd4abbabb454ce416fe3470d3e0f8d23f0bc8f2662630083fb1ec388da"
      ) || !isTRUE(runner_contract$RunnerImplementationReady) ||
      isTRUE(runner_contract$CalibrationExecutionAuthorized)) {
    stop("The exact non-authorizing b1g13 runner is required.",
         call. = FALSE)
  }
  if (!inherits(boundary_contract, "mfrmr_gtwaf_contract") ||
      !identical(
        boundary_contract$ContractHash,
        "53a36d72388eb8b4e096ef817aaf94959aa1b3fd3257190cf5c0a8164383d9da"
      ) || !inherits(glmm_reference_contract, "mfrmr_gtwta_contract") ||
      !identical(
        glmm_reference_contract$ContractHash,
        "60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a"
      ) || !inherits(lme4_reference_contract, "mfrmr_gtwad_contract") ||
      !identical(
        lme4_reference_contract$ContractHash,
        "419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0"
      )) {
    stop("The exact production-probe and reference contracts are required.",
         call. = FALSE)
  }
  policy <- mfrmr_gtwah_policy()
  runtime <- mfrmr_gtwah_runtime_identity()
  adapter_hashes <- mfrmr_gtwah_adapter_hashes()
  dependency_hashes <- mfrmr_gtwah_dependency_hashes()
  identity <- list(
    Contract = "production_adapter_contract_draft83d2b2b1g14_v1",
    UpstreamB1g13ContractHash = runner_contract$ContractHash,
    UpstreamBoundaryContractHash = boundary_contract$ContractHash,
    UpstreamGlmmReferenceContractHash =
      glmm_reference_contract$ContractHash,
    UpstreamLme4ReferenceContractHash =
      lme4_reference_contract$ContractHash,
    SealedCalibrationManifestHash =
      runner_contract$SealedCalibrationManifestHash,
    RunnerPolicyHash = runner_contract$Policy$PolicyHash,
    AcceptancePolicyHash = runner_contract$AcceptancePolicyHash,
    ReferenceReceiptHash = runner_contract$ReferenceReceiptHash,
    ProfileRegistryHash = runner_contract$ProfileRegistryHash,
    CandidateGridHash = runner_contract$CandidateGridHash,
    AdapterPolicy = policy,
    Runtime = runtime,
    AdapterHashes = adapter_hashes,
    AdapterDependencyHashes = dependency_hashes,
    BoundaryPolicy = boundary_contract$Policy,
    GlmmReferencePolicy = glmm_reference_contract$TolerancePolicy,
    Lme4ReferencePolicy = lme4_reference_contract$Policy,
    Sources = mfrmr_gtwah_source_registry(),
    FunctionHashes = mfrmr_gtwah_function_hashes()
  )
  base <- unclass(runner_contract)
  for (name in unique(c(names(identity),
    "Contract", "ContractHash", "ProductionEvaluatorAdaptersFrozen",
    "ReservedRunManifestFrozen", "CalibrationAuthorizationReady",
    "CalibrationExecutionAuthorized", "CalibrationDataGenerated",
    "CalibrationResultsViewed", "StationarityThresholdFrozen",
    "StationarityCriterionReady", "ConfirmationAuthorized",
    "InferenceReady", "CoefficientEligible", "DecisionReady"
  ))) base[[name]] <- NULL
  structure(c(base, identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    ProductionEvaluatorAdaptersFrozen = TRUE,
    AdapterRuntimeIdentityFrozen = TRUE,
    AdapterDependencyGraphFrozen = TRUE,
    ReservedRunManifestFrozen = FALSE,
    ProductionAdapterPreflightReady = FALSE,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = c("mfrmr_gtwah_contract", "mfrmr_gtwag_contract"))
}

mfrmr_gtwah_authorized_for_unit <- function(contract, unit) {
  replicate <- as.integer(unit$Replicate[[1L]])
  reserved <- replicate %in% contract$AdapterPolicy$ReservedReplicates
  if (!reserved) return(TRUE)
  isTRUE(contract$CalibrationExecutionAuthorized) &&
    is.character(contract$AuthorizationRecordHash) &&
    length(contract$AuthorizationRecordHash) == 1L &&
    nchar(contract$AuthorizationRecordHash) == 64L &&
    identical(
      contract$AuthorizedReservedManifestHash,
      contract$ReservedRunManifestHash
    )
}

mfrmr_gtwah_prepare_unit <- function(contract, unit,
                                      registry = mfrmr_gtw_registry()) {
  if (!inherits(contract, "mfrmr_gtwah_contract") ||
      !is.data.frame(unit) || nrow(unit) != 1L ||
      !all(c(
        "AtomicUnitId", "DatasetId", "ScenarioId", "Replicate",
        "MethodId", "Backend", "Likelihood"
      ) %in% names(unit)) || !mfrmr_gtwah_authorized_for_unit(contract, unit)) {
    stop("The adapter is not authorized for this atomic unit.", call. = FALSE)
  }
  method <- unit$MethodId[[1L]]
  expected_backend <- if (grepl("^glmmTMB_", method)) "glmmTMB" else "lme4"
  expected_likelihood <- if (grepl("_reml$", method)) "REML" else "ML"
  expected_dataset <- sprintf(
    "%s/R%04d", unit$ScenarioId[[1L]], unit$Replicate[[1L]]
  )
  if (!identical(unit$Backend[[1L]], expected_backend) ||
      !identical(unit$Likelihood[[1L]], expected_likelihood) ||
      !identical(unit$DatasetId[[1L]], expected_dataset) ||
      !unit$ScenarioId[[1L]] %in% registry$Cells$ScenarioId) {
    stop("The atomic unit method or dataset identity is inconsistent.",
         call. = FALSE)
  }
  generation <- mfrmr_gtw_generate(
    registry, unit$ScenarioId[[1L]], unit$Replicate[[1L]]
  )
  prefit <- mfrmr_gtd3_prefit_one(generation)
  if (!isTRUE(prefit$PreFitEligible)) {
    stop("The production adapter received a pre-fit-ineligible unit.",
         call. = FALSE)
  }
  list(
    Generation = generation,
    PreFit = prefit,
    Data = prefit$StructuralRankAudit$PreparedData$Data,
    GeneratorHash = generation$GeneratorHash,
    PreFitHash = prefit$ResultHash
  )
}

mfrmr_gtwah_curvature_state <- function(metrics) {
  if (!isTRUE(metrics$HessianAvailable)) return("not_evaluable")
  if (isTRUE(metrics$HessianPositiveDefinite) &&
      isTRUE(metrics$HessianCholeskyAvailable)) {
    return("positive_definite_factorable")
  }
  if (isTRUE(metrics$HessianPositiveDefinite)) {
    return("spectral_positive_not_factorable")
  }
  "near_singular_or_semidefinite"
}

mfrmr_gtwah_failed_fit <- function(stage, message) {
  list(
    Returned = FALSE, Fit = NULL, Objective = NA_real_,
    Metrics = mfrmr_gtwsy_scale_metrics(
      numeric(), NA_real_, numeric(), matrix(numeric(), 0L, 0L)
    ),
    OptimizerCode = NA_integer_, SidecarHash = "none",
    FailureStage = stage,
    FailureDigest = mfrmr_gta_hash(as.character(message)),
    FinalSignature = NULL
  )
}

mfrmr_gtwah_lme4_fit <- function(formula, data, reml, profile_id) {
  captured <- tryCatch(
    mfrmr_gtwd_capture(lme4::lmer(
      formula, data = data, REML = reml,
      control = mfrmr_gtwy_control(profile_id)
    )),
    error = function(error) error
  )
  if (inherits(captured, "error")) {
    return(mfrmr_gtwah_failed_fit("candidate_fit", conditionMessage(captured)))
  }
  fit <- captured$Fit
  objective <- if (reml) as.numeric(lme4::REMLcrit(fit)) else
    as.numeric(stats::deviance(fit))
  parameter <- as.numeric(lme4::getME(fit, "theta"))
  gradient <- suppressWarnings(as.numeric(fit@optinfo$derivs$gradient))
  hessian <- fit@optinfo$derivs$Hessian
  if (!is.matrix(hessian)) hessian <- matrix(numeric(), 0L, 0L)
  metrics <- mfrmr_gtwsy_scale_metrics(
    parameter, objective, gradient, hessian
  )
  optimizer_code <- suppressWarnings(as.integer(
    fit@optinfo$conv$opt[[1L]]
  ))
  if (length(optimizer_code) == 0L || is.na(optimizer_code)) {
    optimizer_code <- NA_integer_
  }
  sidecar <- list(
    Backend = "lme4", REML = reml, ProfileId = profile_id,
    Parameter = parameter, Objective = objective, Gradient = gradient,
    Hessian = hessian, Warnings = captured$Warnings,
    Messages = captured$Messages, OptimizerCode = optimizer_code
  )
  returned <- is.finite(objective)
  list(
    Returned = returned, Fit = fit, Objective = objective,
    Metrics = metrics, OptimizerCode = optimizer_code,
    SidecarHash = mfrmr_gta_hash(sidecar),
    FailureStage = if (returned) "none" else "nonfinite_objective",
    FailureDigest = if (returned) "none" else
      mfrmr_gta_hash("nonfinite lme4 candidate objective"),
    FinalSignature = NULL
  )
}

mfrmr_gtwah_glmm_fit <- function(formula, data, reml, profile,
                                  parent, contract) {
  parent_id <- profile$ParentProfileId[[1L]]
  if (parent_id != "none" &&
      (is.null(parent) || !isTRUE(parent$Returned) ||
       is.null(parent$FinalSignature))) {
    return(mfrmr_gtwah_failed_fit(
      "parent_fit_or_start_unavailable", parent_id
    ))
  }
  start <- if (parent_id == "none") NULL else parent$FinalSignature$StartList
  captured <- tryCatch(
    mfrmr_gtwd_capture(glmmTMB::glmmTMB(
      formula = formula, data = data,
      family = stats::gaussian(link = "identity"),
      ziformula = ~ 0, dispformula = ~ 1, REML = reml,
      start = start,
      control = mfrmr_gtwsv_control(profile$ProfileId[[1L]],
                                    contract$Profiles)
    )),
    error = function(error) error
  )
  if (inherits(captured, "error")) {
    return(mfrmr_gtwah_failed_fit("candidate_fit", conditionMessage(captured)))
  }
  fit <- captured$Fit
  signature <- tryCatch(
    mfrmr_gtwsv_extract_start(fit), error = function(error) error
  )
  if (inherits(signature, "error")) {
    return(mfrmr_gtwah_failed_fit(
      "start_snapshot", conditionMessage(signature)
    ))
  }
  parameter <- as.numeric(fit$fit$par)
  objective <- as.numeric(fit$fit$objective)
  gradient <- tryCatch(
    as.numeric(fit$obj$gr(fit$fit$par)), error = function(error) numeric()
  )
  hessian <- tryCatch(
    suppressWarnings(numDeriv::jacobian(
      fit$obj$gr, fit$fit$par, method = "Richardson",
      method.args = list(r = 4, v = 2, eps = 1e-4, d = 1e-4,
                         zero.tol = sqrt(.Machine$double.eps / 7e-7))
    )),
    error = function(error) matrix(numeric(), 0L, 0L)
  )
  metrics <- mfrmr_gtwsy_scale_metrics(
    parameter, objective, gradient, hessian
  )
  optimizer_code <- suppressWarnings(as.integer(fit$fit$convergence[[1L]]))
  if (length(optimizer_code) == 0L || is.na(optimizer_code)) {
    optimizer_code <- NA_integer_
  }
  sidecar <- list(
    Backend = "glmmTMB", REML = reml,
    ProfileId = profile$ProfileId[[1L]], ParentProfileId = parent_id,
    ParentSignatureHash = if (parent_id == "none") "none" else
      parent$FinalSignature$SignatureHash,
    FinalSignatureHash = signature$SignatureHash,
    Parameter = parameter, Objective = objective, Gradient = gradient,
    Hessian = hessian, Warnings = captured$Warnings,
    Messages = captured$Messages, OptimizerCode = optimizer_code
  )
  returned <- is.finite(objective)
  list(
    Returned = returned, Fit = fit, Objective = objective,
    Metrics = metrics, OptimizerCode = optimizer_code,
    SidecarHash = mfrmr_gta_hash(sidecar),
    FailureStage = if (returned) "none" else "nonfinite_objective",
    FailureDigest = if (returned) "none" else
      mfrmr_gta_hash("nonfinite glmmTMB candidate objective"),
    FinalSignature = signature
  )
}

mfrmr_gtwah_candidate_evaluator <- function(contract, unit) {
  prepared <- mfrmr_gtwah_prepare_unit(contract, unit)
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
  rows$BoundaryProbeState <- ifelse(
    rows$ModelRole == "full", "not_run", "not_run"
  )
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

mfrmr_gtwah_glmm_reference <- function(contract, unit, prepared, formulas) {
  reml <- identical(unit$Likelihood[[1L]], "REML")
  outputs <- list()
  for (role in names(formulas)) {
    fit_result <- tryCatch(
      mfrmr_gtwta_fit_objective(formulas[[role]], prepared$Data, reml),
      error = function(error) error
    )
    if (inherits(fit_result, "error")) {
      outputs[[role]] <- list(
        State = "not_evaluable", SidecarHash = "none",
        FailureStage = "high_accuracy_fit",
        FailureDigest = mfrmr_gta_hash(conditionMessage(fit_result)),
        Fit = NULL, Reference = NULL, Boundary = NULL
      )
      next
    }
    objective <- mfrmr_gtwta_anchored_objective(fit_result$Fit)
    reference <- mfrmr_gtwta_reference(
      objective$Fn, objective$Gr, fit_result$Fit$fit$par,
      contract$GlmmReferencePolicy
    )
    boundary <- if (role == "full" && reference$SidecarHash != "none") {
      mfrmr_gtwta_profile_boundary(
        objective$Fn, objective$Gr, reference$Sidecar$PolishedParameter,
        mfrmr_gtwta_target_theta_index(
          fit_result$Fit, contract$AdapterPolicy$TargetComponent
        ), contract$GlmmReferencePolicy
      )
    } else NULL
    sidecar <- list(
      Backend = "glmmTMB", REML = reml, ModelRole = role,
      Reference = reference$Sidecar,
      Boundary = if (is.null(boundary)) list() else boundary$Rows,
      RandomStartAnchorHash = objective$RandomStartAnchorHash,
      GeneratorHash = prepared$GeneratorHash,
      PreFitHash = prepared$PreFitHash
    )
    outputs[[role]] <- list(
      State = reference$State, SidecarHash = mfrmr_gta_hash(sidecar),
      FailureStage = if (reference$State %in% c(
        "reference_unresolved", "not_evaluable"
      )) "high_accuracy_reference" else "none",
      FailureDigest = if (reference$State %in% c(
        "reference_unresolved", "not_evaluable"
      )) mfrmr_gta_hash(reference$State) else "none",
      Fit = fit_result$Fit, Reference = reference, Boundary = boundary
    )
  }
  full <- outputs$full
  reduced <- outputs$reduced
  if (!is.null(full$Boundary) && isTRUE(full$Boundary$Available) &&
      isTRUE(full$Boundary$MaterialImprovementTowardBoundary) &&
      !is.null(reduced$Reference) &&
      is.finite(reduced$Reference$PolishedObjective)) {
    endpoint <- tail(full$Boundary$Rows$Objective, 1L)
    tolerance <- contract$GlmmReferencePolicy$
      BoundaryObjectiveRelativeTolerance * max(
        1, abs(endpoint), abs(reduced$Reference$PolishedObjective)
      )
    full$State <- if (is.finite(endpoint) &&
      abs(endpoint - reduced$Reference$PolishedObjective) <= tolerance) {
      "boundary_limit"
    } else "reference_unresolved"
    outputs$full <- full
  }
  outputs
}

mfrmr_gtwah_lme4_reference <- function(contract, unit, prepared, formulas) {
  reml <- identical(unit$Likelihood[[1L]], "REML")
  outputs <- list()
  for (role in names(formulas)) {
    fit_result <- tryCatch(
      mfrmr_gtwad_fit_objective(formulas[[role]], prepared$Data, reml),
      error = function(error) error
    )
    if (inherits(fit_result, "error")) {
      outputs[[role]] <- list(
        State = "not_evaluable", SidecarHash = "none",
        FailureStage = "high_accuracy_fit",
        FailureDigest = mfrmr_gta_hash(conditionMessage(fit_result)),
        FitResult = NULL, Reference = NULL, Boundary = NULL
      )
      next
    }
    fit <- fit_result$Fit
    theta <- lme4::getME(fit, "theta")
    lower <- lme4::getME(fit, "lower")
    reference <- mfrmr_gtwad_reference(
      fit_result$Devfun, theta, lower, contract$Lme4ReferencePolicy,
      oracle = function(parameter) mfrmr_gtwad_sparse_oracle(
        fit, parameter, reml
      )
    )
    boundary <- if (role == "full" && reference$SidecarHash != "none") {
      mfrmr_gtwad_profile_boundary(
        fit_result$Devfun, reference$Sidecar$PolishedParameter,
        mfrmr_gtwad_target_index(
          fit, contract$AdapterPolicy$TargetComponent
        ),
        lower, contract$Lme4ReferencePolicy
      )
    } else NULL
    sidecar <- list(
      Backend = "lme4", REML = reml, ModelRole = role,
      Reference = reference$Sidecar,
      Boundary = if (is.null(boundary)) list() else boundary$Rows,
      GeneratorHash = prepared$GeneratorHash,
      PreFitHash = prepared$PreFitHash
    )
    outputs[[role]] <- list(
      State = reference$State, SidecarHash = mfrmr_gta_hash(sidecar),
      FailureStage = if (reference$State %in% c(
        "reference_unresolved", "not_evaluable"
      )) "high_accuracy_reference" else "none",
      FailureDigest = if (reference$State %in% c(
        "reference_unresolved", "not_evaluable"
      )) mfrmr_gta_hash(reference$State) else "none",
      FitResult = fit_result, Reference = reference, Boundary = boundary
    )
  }
  full <- outputs$full
  reduced <- outputs$reduced
  if (!is.null(full$Boundary) && isTRUE(full$Boundary$Available) &&
      isTRUE(full$Boundary$MaterialImprovementTowardBoundary) &&
      !is.null(reduced$Reference) &&
      is.finite(reduced$Reference$PolishedObjective)) {
    endpoint <- tail(full$Boundary$Rows$Objective, 1L)
    tolerance <- contract$Lme4ReferencePolicy$
      BoundaryObjectiveRelativeTolerance * max(
        1, abs(endpoint), abs(reduced$Reference$PolishedObjective)
      )
    full$State <- if (is.finite(endpoint) &&
      abs(endpoint - reduced$Reference$PolishedObjective) <= tolerance) {
      "boundary_limit"
    } else "reference_unresolved"
    outputs$full <- full
  }
  outputs
}

mfrmr_gtwah_reference_evaluator <- function(contract, unit) {
  prepared <- mfrmr_gtwah_prepare_unit(contract, unit)
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

mfrmr_gtwah_adapter_hashes <- function() {
  functions <- c(
    CandidateEvaluator = "mfrmr_gtwah_candidate_evaluator",
    ReferenceEvaluator = "mfrmr_gtwah_reference_evaluator"
  )
  preflight_environment <- environment(mfrmr_gtwah_adapter_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwah_function_hash(get(
      name, envir = preflight_environment, inherits = TRUE
    ))
  }, character(1L)), names(functions))
}

mfrmr_gtwah_dependency_hashes <- function() {
  functions <- c(
    "mfrmr_gtwah_prepare_unit", "mfrmr_gtwah_curvature_state",
    "mfrmr_gtwah_failed_fit", "mfrmr_gtwah_lme4_fit",
    "mfrmr_gtwah_glmm_fit", "mfrmr_gtwah_glmm_reference",
    "mfrmr_gtwah_lme4_reference", "mfrmr_gtwy_control",
    "mfrmr_gtwsv_control", "mfrmr_gtwsv_extract_start",
    "mfrmr_gtwsy_scale_metrics", "mfrmr_gtwaf_probe_lme4",
    "mfrmr_gtwaf_probe_glmmtmb", "mfrmr_gtwta_reference",
    "mfrmr_gtwad_reference"
  )
  preflight_environment <- environment(mfrmr_gtwah_dependency_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwah_function_hash(get(
      name, envir = preflight_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwah_dry_units <- function(contract) {
  scenario <- contract$AdapterPolicy$DryRunScenarioId
  replicate <- contract$AdapterPolicy$DryRunReplicate
  lanes <- unique(contract$ReferenceReceipts[
    c("MethodId", "Backend")
  ])
  dataset_id <- sprintf("%s/R%04d", scenario, replicate)
  rows <- data.frame(
    AtomicUnitId = paste(dataset_id, lanes$MethodId, sep = "::"),
    DatasetId = dataset_id, ScenarioId = scenario,
    Replicate = replicate, MethodId = lanes$MethodId,
    Backend = lanes$Backend,
    Likelihood = ifelse(grepl("_reml$", lanes$MethodId), "REML", "ML"),
    stringsAsFactors = FALSE
  )
  counts <- table(contract$Profiles$Backend)
  rows$ExpectedCandidateFitRows <- 2L * as.integer(counts[rows$Backend])
  rows$ExpectedCandidateDecisionRows <-
    contract$Policy$CandidateDecisionsPerAtomicUnit
  rows$ExpectedReferenceRows <- 2L
  rows$CalibrationUse <- FALSE
  rows$MechanicsFixture <- FALSE
  rows$ProductionAdapterDryRun <- TRUE
  rows$ExecutionAuthorized <- TRUE
  rows$AtomicUnitIdentityHash <- vapply(seq_len(nrow(rows)), function(index) {
    mfrmr_gta_hash(rows[index, setdiff(
      names(rows), "AtomicUnitIdentityHash"
    ), drop = FALSE])
  }, character(1L))
  row.names(rows) <- NULL
  rows
}

mfrmr_gtwah_dry_manifest <- function(contract) {
  units <- mfrmr_gtwah_dry_units(contract)
  identity <- list(
    Contract = "production_adapter_dry_run_manifest_b1g14_v1",
    RunnerContractHash = contract$ContractHash,
    ExecutionMode = "nonreserved_real_adapter_preflight",
    Units = units,
    CandidateEvaluatorHash =
      contract$AdapterHashes[["CandidateEvaluator"]],
    ReferenceEvaluatorHash =
      contract$AdapterHashes[["ReferenceEvaluator"]],
    Replicates = sort(unique(units$Replicate)),
    ReservedCalibrationUse = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    AtomicUnitCount = nrow(units),
    DatasetCount = length(unique(units$DatasetId)),
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount = sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ExecutionAuthorized = TRUE,
    CalibrationExecutionAuthorized = FALSE,
    DataGenerated = FALSE, ResultsViewed = FALSE
  )), class = "mfrmr_gtwag_manifest")
}

mfrmr_gtwah_reserved_manifest <- function(contract, sealed_manifest) {
  if (!inherits(contract, "mfrmr_gtwah_contract") ||
      !inherits(sealed_manifest, "mfrmr_gtwaa_manifest")) {
    stop("The b1g14 contract and sealed b1g7 manifest are required.",
         call. = FALSE)
  }
  units <- mfrmr_gtwag_sealed_units(contract, sealed_manifest)
  assignment <- data.frame(
    AtomicUnitId = units$AtomicUnitId,
    AtomicUnitIdentityHash = units$AtomicUnitIdentityHash,
    ShardId = sprintf("R%04d", units$Replicate),
    stringsAsFactors = FALSE
  )
  shard_ids <- sprintf(
    "R%04d", contract$AdapterPolicy$ReservedReplicates
  )
  shards <- do.call(rbind, lapply(shard_ids, function(shard_id) {
    index <- which(assignment$ShardId == shard_id)
    data.frame(
      ShardId = shard_id,
      Replicate = as.integer(sub("^R", "", shard_id)),
      AtomicUnitCount = length(index),
      CandidateFitRowCount = sum(units$ExpectedCandidateFitRows[index]),
      CandidateDecisionRowCount =
        sum(units$ExpectedCandidateDecisionRows[index]),
      ReferenceRowCount = sum(units$ExpectedReferenceRows[index]),
      ShardIdentityHash = mfrmr_gta_hash(assignment[index, , drop = FALSE]),
      stringsAsFactors = FALSE
    )
  }))
  identity <- list(
    Contract = "reserved_stationarity_run_manifest_b1g14_v1",
    AdapterContractHash = contract$ContractHash,
    UpstreamSealedManifestHash = sealed_manifest$ManifestHash,
    OutputRoot = contract$AdapterPolicy$OutputRoot,
    RuntimeHash = contract$Runtime$RuntimeHash,
    AdapterHashes = contract$AdapterHashes,
    AdapterDependencyHashes = contract$AdapterDependencyHashes,
    UnitAssignments = assignment,
    Shards = shards,
    ScientificHashExclusions = c(
      "timing", "computed_or_reused", "progress_frequency"
    ),
    EarlyStoppingPermitted = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationUse = FALSE
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    DatasetCount = length(unique(units$DatasetId)),
    AtomicUnitCount = nrow(units),
    CandidateFitRowCount = sum(units$ExpectedCandidateFitRows),
    CandidateDecisionRowCount = sum(units$ExpectedCandidateDecisionRows),
    ReferenceRowCount = sum(units$ExpectedReferenceRows),
    ShardCount = nrow(shards),
    ReservedRunManifestFrozen = TRUE,
    ExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE
  )), class = "mfrmr_gtwah_reserved_manifest")
}

mfrmr_gtwah_reserved_manifest_hash_valid <- function(manifest) {
  fields <- c(
    "Contract", "AdapterContractHash", "UpstreamSealedManifestHash",
    "OutputRoot", "RuntimeHash", "AdapterHashes",
    "AdapterDependencyHashes", "UnitAssignments", "Shards",
    "ScientificHashExclusions", "EarlyStoppingPermitted",
    "CalibrationExecutionAuthorized", "ConfirmationUse"
  )
  inherits(manifest, "mfrmr_gtwah_reserved_manifest") &&
    all(fields %in% names(manifest)) &&
    identical(manifest$ManifestHash, mfrmr_gta_hash(manifest[fields]))
}

mfrmr_gtwah_execution_hash_valid <- function(execution) {
  fields <- c(
    "Contract", "RunnerContractHash", "RunManifestHash",
    "CandidateFits", "CandidateDecisions", "References",
    "AcceptanceLedger", "AcceptanceCellSummary", "UnitCheckpointHashes",
    "DatasetMarkerHashes"
  )
  inherits(execution, "mfrmr_gtwag_execution") &&
    all(fields %in% names(execution)) &&
    is.character(execution$ExecutionHash) &&
    length(execution$ExecutionHash) == 1L &&
    identical(execution$ExecutionHash, mfrmr_gta_hash(execution[fields]))
}

mfrmr_gtwah_preflight <- function(contract, reserved_manifest,
                                   dry_execution) {
  if (!inherits(contract, "mfrmr_gtwah_contract") ||
      !mfrmr_gtwah_reserved_manifest_hash_valid(reserved_manifest) ||
      !inherits(dry_execution, "mfrmr_gtwag_execution") ||
      !mfrmr_gtwah_execution_hash_valid(dry_execution) ||
      !identical(
        reserved_manifest$AdapterContractHash, contract$ContractHash
      ) || !identical(
        dry_execution$RunnerContractHash, contract$ContractHash
      )) {
    stop("Exact b1g14 preflight inputs are required.", call. = FALSE)
  }
  counts <- c(
    Datasets = reserved_manifest$DatasetCount,
    AtomicUnits = reserved_manifest$AtomicUnitCount,
    CandidateFits = reserved_manifest$CandidateFitRowCount,
    CandidateDecisions = reserved_manifest$CandidateDecisionRowCount,
    References = reserved_manifest$ReferenceRowCount,
    Shards = reserved_manifest$ShardCount
  )
  expected <- c(
    Datasets = 3000L, AtomicUnits = 12000L,
    CandidateFits = 108000L, CandidateDecisions = 576000L,
    References = 24000L, Shards = 100L
  )
  candidate_generator <- tapply(
    dry_execution$CandidateFits$GeneratorHash,
    dry_execution$CandidateFits$AtomicUnitId,
    function(value) {
      value <- unique(value)
      if (length(value) == 1L) value else NA_character_
    }
  )
  reference_generator <- tapply(
    dry_execution$References$GeneratorHash,
    dry_execution$References$AtomicUnitId,
    function(value) {
      value <- unique(value)
      if (length(value) == 1L) value else NA_character_
    }
  )
  generator_units <- sort(names(candidate_generator))
  generator_match <- length(generator_units) == 4L &&
    identical(generator_units, sort(names(reference_generator))) &&
    !anyNA(candidate_generator[generator_units]) &&
    !anyNA(reference_generator[generator_units]) &&
    identical(
      unname(candidate_generator[generator_units]),
      unname(reference_generator[generator_units])
    )
  candidate_prefit <- tapply(
    dry_execution$CandidateFits$PreFitHash,
    dry_execution$CandidateFits$AtomicUnitId,
    function(value) {
      value <- unique(value)
      if (length(value) == 1L) value else NA_character_
    }
  )
  reference_prefit <- tapply(
    dry_execution$References$PreFitHash,
    dry_execution$References$AtomicUnitId,
    function(value) {
      value <- unique(value)
      if (length(value) == 1L) value else NA_character_
    }
  )
  prefit_units <- sort(names(candidate_prefit))
  prefit_match <- length(prefit_units) == 4L &&
    identical(prefit_units, sort(names(reference_prefit))) &&
    !anyNA(candidate_prefit[prefit_units]) &&
    !anyNA(reference_prefit[prefit_units]) && identical(
      unname(candidate_prefit[prefit_units]),
      unname(reference_prefit[prefit_units])
    )
  shard_exact <- nrow(reserved_manifest$Shards) ==
      contract$AdapterPolicy$ReservedShardCount &&
    all(reserved_manifest$Shards$AtomicUnitCount ==
          contract$AdapterPolicy$AtomicUnitsPerShard) &&
    all(reserved_manifest$Shards$CandidateFitRowCount ==
          contract$AdapterPolicy$CandidateFitRowsPerShard) &&
    all(reserved_manifest$Shards$CandidateDecisionRowCount ==
          contract$AdapterPolicy$CandidateDecisionRowsPerShard) &&
    all(reserved_manifest$Shards$ReferenceRowCount ==
          contract$AdapterPolicy$ReferenceRowsPerShard)
  ready <- identical(counts, expected) && generator_match && prefit_match &&
    shard_exact &&
    isTRUE(dry_execution$Complete) &&
    identical(nrow(dry_execution$CandidateFits), 36L) &&
    identical(nrow(dry_execution$CandidateDecisions), 192L) &&
    identical(nrow(dry_execution$References), 8L) &&
    all(!dry_execution$CandidateDecisions$GeneratingTruthUsed) &&
    !isTRUE(reserved_manifest$ExecutionAuthorized) &&
    !isTRUE(contract$CalibrationExecutionAuthorized)
  identity <- list(
    Contract = "production_adapter_preflight_audit_b1g14_v1",
    AdapterContractHash = contract$ContractHash,
    ReservedManifestHash = reserved_manifest$ManifestHash,
    DryExecutionHash = dry_execution$ExecutionHash,
    ExactCounts = counts,
    GeneratorHashMatch = generator_match,
    PreFitHashMatch = prefit_match,
    ShardAccountingExact = shard_exact,
    CandidateFitFailureCount = dry_execution$CandidateFitFailureCount,
    ReferenceUnresolvedCount = dry_execution$ReferenceUnresolvedCount
  )
  structure(c(identity, list(
    PreflightHash = mfrmr_gta_hash(identity),
    ProductionEvaluatorAdaptersFrozen = TRUE,
    ReservedRunManifestFrozen = TRUE,
    ProductionAdapterPreflightReady = ready,
    DryRunEvidenceReady = ready,
    CalibrationAuthorizationReady = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    CalibrationDataGenerated = FALSE,
    CalibrationResultsViewed = FALSE,
    StationarityThresholdFrozen = FALSE,
    StationarityCriterionReady = FALSE,
    ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwah_preflight")
}

mfrmr_gtwah_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwah_source_registry", "mfrmr_gtwah_runtime_identity",
    "mfrmr_gtwah_policy", "mfrmr_gtwah_policy_hash_valid",
    "mfrmr_gtwah_contract", "mfrmr_gtwah_authorized_for_unit",
    "mfrmr_gtwah_prepare_unit", "mfrmr_gtwah_curvature_state",
    "mfrmr_gtwah_failed_fit", "mfrmr_gtwah_lme4_fit",
    "mfrmr_gtwah_glmm_fit", "mfrmr_gtwah_candidate_evaluator",
    "mfrmr_gtwah_glmm_reference", "mfrmr_gtwah_lme4_reference",
    "mfrmr_gtwah_reference_evaluator", "mfrmr_gtwah_adapter_hashes",
    "mfrmr_gtwah_dependency_hashes", "mfrmr_gtwah_dry_units",
    "mfrmr_gtwah_dry_manifest", "mfrmr_gtwah_reserved_manifest",
    "mfrmr_gtwah_reserved_manifest_hash_valid",
    "mfrmr_gtwah_execution_hash_valid",
    "mfrmr_gtwah_preflight"
  )
  preflight_environment <- environment(mfrmr_gtwah_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwah_function_hash(get(
      name, envir = preflight_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}
