# Draft.83d2b2b1e numerical-likelihood sensitivity audit.
#
# Repository-internal only. This file re-fits already viewed feasibility data
# under frozen optimizer profiles. It does not select a statistical threshold,
# run a bootstrap, or authorize inference.

mfrmr_gtwy_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gtw_registry", "mfrmr_gtw_generate",
    "mfrmr_gtd3_prefit_one", "mfrmr_gtwd_reduced_formula",
    "mfrmr_gtwd_capture", "mfrmr_gtwd_lme4_zero",
    "mfrmr_gtwd_glmmtmb_zero", "mfrmr_gtwd_lme4_coordinate",
    "mfrmr_gtwd_glmmtmb_coordinate", "mfrmr_gtc_lme4_diagnostics",
    "mfrmr_gtm_diagnostics", "mfrmr_gtwf_contract",
    "mfrmr_gtwf_manifest", "mfrmr_gtwf_observable_row",
    "mfrmr_gtwx_atomic_write", "mfrmr_gtwx_checkpoint_root",
    "mfrmr_gtwx_safe_read"
  )
  audit_environment <- environment(mfrmr_gtwy_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = audit_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.83d2b2b1d chain before Draft.83d2b2b1e: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtwy_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtwy_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtwy_profiles", "mfrmr_gtwy_control",
    "mfrmr_gtwy_validate_feasibility_execution", "mfrmr_gtwy_contract",
    "mfrmr_gtwy_manifest", "mfrmr_gtwy_fit_pair",
    "mfrmr_gtwy_success_row", "mfrmr_gtwy_failure_row",
    "mfrmr_gtwy_route_path", "mfrmr_gtwy_dataset_path",
    "mfrmr_gtwy_checkpoint", "mfrmr_gtwy_validate_checkpoint",
    "mfrmr_gtwy_marker", "mfrmr_gtwy_validate_marker",
    "mfrmr_gtwy_route_summary", "mfrmr_gtwy_profile_summary",
    "mfrmr_gtwy_spread_grid", "mfrmr_gtwy_summaries",
    "mfrmr_gtwy_execute"
  )
  audit_environment <- environment(mfrmr_gtwy_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtwy_function_hash(get(
      name, envir = audit_environment, inherits = TRUE
    ))
  }, character(1L)), functions)
}

mfrmr_gtwy_profiles <- function() {
  rows <- data.frame(
    ProfileId = c(
      "lme4_default_nloptwrap", "lme4_strict_nloptwrap", "lme4_bobyqa",
      "glmmTMB_default_nlminb", "glmmTMB_tight_nlminb",
      "glmmTMB_optim_bfgs"
    ),
    Backend = c(rep("lme4", 3L), rep("glmmTMB", 3L)),
    Algorithm = c(
      "nloptwrap", "nloptwrap", "bobyqa", "nlminb", "nlminb",
      "optim_BFGS"
    ),
    ProfileRole = rep(c("default_replay", "strict_same_algorithm",
                        "different_algorithm"), 2L),
    IsDefault = rep(c(TRUE, FALSE, FALSE), 2L),
    ControlDescription = c(
      "lmerControl_default",
      "nloptwrap_xtol_abs_1e-8_ftol_abs_1e-8_maxeval_100000",
      "bobyqa_rhoend_1e-8_maxfun_100000",
      "glmmTMBControl_default_nlminb",
      "nlminb_iter_2000_eval_2000_rel_1e-10_x_1e-10",
      "optim_BFGS_maxit_2000_reltol_1e-10"
    ),
    stringsAsFactors = FALSE
  )
  rows$ProfileHash <- vapply(seq_len(nrow(rows)), function(index) {
    mfrmr_gta_hash(rows[index, setdiff(names(rows), "ProfileHash"),
                              drop = FALSE])
  }, character(1L))
  rows
}

mfrmr_gtwy_control <- function(profile_id) {
  profile_id <- as.character(profile_id)
  if (length(profile_id) != 1L || is.na(profile_id)) {
    stop("`profile_id` must be one registered profile.", call. = FALSE)
  }
  switch(
    profile_id,
    lme4_default_nloptwrap = lme4::lmerControl(),
    lme4_strict_nloptwrap = lme4::lmerControl(
      optimizer = "nloptwrap",
      optCtrl = list(
        xtol_abs = 1e-8, ftol_abs = 1e-8, maxeval = 100000
      )
    ),
    lme4_bobyqa = lme4::lmerControl(
      optimizer = "bobyqa",
      optCtrl = list(rhoend = 1e-8, maxfun = 100000)
    ),
    glmmTMB_default_nlminb = glmmTMB::glmmTMBControl(),
    glmmTMB_tight_nlminb = glmmTMB::glmmTMBControl(
      optCtrl = list(
        iter.max = 2000, eval.max = 2000, rel.tol = 1e-10,
        x.tol = 1e-10
      )
    ),
    glmmTMB_optim_bfgs = glmmTMB::glmmTMBControl(
      optimizer = stats::optim,
      optCtrl = list(maxit = 2000, reltol = 1e-10),
      optArgs = list(method = "BFGS")
    ),
    stop("Unknown numerical-sensitivity profile.", call. = FALSE)
  )
}

mfrmr_gtwy_validate_feasibility_execution <- function(execution) {
  inherits(execution, "mfrmr_gtwx_execution") &&
    identical(
      execution$RunnerContractHash,
      "c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7"
    ) &&
    identical(
      execution$ExecutionHash,
      "04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b"
    ) &&
    isTRUE(execution$ExactAccountingPassed) &&
    isTRUE(execution$FeasibilityEvidenceReady) &&
    is.data.frame(execution$AtomicRows) &&
    nrow(execution$AtomicRows) == 3000L &&
    !anyDuplicated(execution$AtomicRows$RouteId) &&
    !isTRUE(execution$ThresholdFrozen) &&
    !isTRUE(execution$InferenceReady) &&
    !isTRUE(execution$DecisionReady)
}

mfrmr_gtwy_contract <- function(feasibility_execution) {
  mfrmr_gtwy_require_primitives()
  if (!mfrmr_gtwy_validate_feasibility_execution(feasibility_execution)) {
    stop("The exact Draft.83d2b2b1d execution is required.", call. = FALSE)
  }
  feasibility_contract <- mfrmr_gtwf_contract()
  feasibility_manifest <- mfrmr_gtwf_manifest(feasibility_contract)
  profiles <- mfrmr_gtwy_profiles()
  sources <- data.frame(
    SourceId = c(
      "lme4_convergence_current", "lme4_allFit_current",
      "lme4_lmerControl_current", "glmmTMB_troubleshooting_current",
      "glmmTMB_control_current", "R_nlminb_current"
    ),
    Locator = c(
      "https://lme4.github.io/lme4/reference/convergence.html",
      "https://lme4.github.io/lme4/reference/allFit.html",
      "https://lme4.github.io/lme4/reference/lmerControl.html",
      "https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html",
      "https://glmmtmb.github.io/glmmTMB/reference/glmmTMBControl.html",
      "https://stat.ethz.ch/R-manual/R-devel/library/stats/html/nlminb.html"
    ),
    stringsAsFactors = FALSE
  )
  identity <- list(
    Contract =
      "gtheory_weak_information_numerical_sensitivity_draft83d2b2b1e_v1",
    ContractArtifact =
      "gtheory-weak-information-numerical-sensitivity-contract-0.2.3.md",
    FeasibilityRunnerContractHash = feasibility_execution$RunnerContractHash,
    FeasibilityExecutionHash = feasibility_execution$ExecutionHash,
    FeasibilityManifestHash = feasibility_manifest$ManifestHash,
    Profiles = profiles,
    ProfileCountPerOriginalRoute = 3L,
    OriginalRouteCount = 3000L,
    SensitivityPairCount = 9000L,
    SensitivityBackendFitCount = 18000L,
    IndependentDatasetCount = 750L,
    SensitivityRowsPerDataset = 12L,
    TargetComponent = "Rater",
    BoundaryTolerance = 1e-8,
    SingularTolerance = 1e-4,
    NegativeLikelihoodTolerance = 1e-6,
    DefaultReplayTolerance = 1e-10,
    DevianceSpreadReportingGrid = c(1e-8, 1e-6, 1e-4, 1e-2),
    EnvelopeMeaning =
      "two_times_separate_profile_maxima_full_minus_reduced_diagnostic_only",
    PracticalEquivalenceThresholdSelected = FALSE,
    DataRescalingPermitted = FALSE,
    ModelSimplificationPermitted = FALSE,
    StartValueTransferPermitted = FALSE,
    EarlyStoppingPermitted = FALSE,
    CalibrationDataGenerationPermitted = FALSE,
    ThresholdSelectionPermitted = FALSE,
    BootstrapPermitted = FALSE,
    ScientificHashExclusions = c(
      "timing", "checkpoint_root", "execution_order", "progress_frequency",
      "computed_or_reused"
    ),
    RIdentity = list(
      Version = R.version.string, Platform = R.version$platform,
      Architecture = R.version$arch
    ),
    PackageVersions = c(
      digest = as.character(utils::packageVersion("digest")),
      lme4 = as.character(utils::packageVersion("lme4")),
      glmmTMB = as.character(utils::packageVersion("glmmTMB")),
      TMB = as.character(utils::packageVersion("TMB")),
      minqa = as.character(utils::packageVersion("minqa")),
      nloptr = as.character(utils::packageVersion("nloptr"))
    ),
    UpstreamFunctionHashes = c(
      Generator = mfrmr_gtwy_function_hash(mfrmr_gtw_generate),
      PreFit = mfrmr_gtwy_function_hash(mfrmr_gtd3_prefit_one),
      ReducedFormula = mfrmr_gtwy_function_hash(mfrmr_gtwd_reduced_formula),
      Capture = mfrmr_gtwy_function_hash(mfrmr_gtwd_capture),
      Observable = mfrmr_gtwy_function_hash(mfrmr_gtwf_observable_row)
    ),
    AuditFunctionHashes = mfrmr_gtwy_function_hashes(),
    Sources = sources
  )
  structure(c(identity, list(
    ContractHash = mfrmr_gta_hash(identity),
    NumericalSensitivityExecutionAuthorized = TRUE,
    NumericalSensitivityEvidenceReady = FALSE,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwy_contract")
}

mfrmr_gtwy_manifest <- function(contract,
                                 feasibility_manifest = NULL) {
  if (!inherits(contract, "mfrmr_gtwy_contract") ||
      !isTRUE(contract$NumericalSensitivityExecutionAuthorized)) {
    stop("A valid numerical-sensitivity contract is required.",
         call. = FALSE)
  }
  if (is.null(feasibility_manifest)) {
    feasibility_contract <- mfrmr_gtwf_contract()
    feasibility_manifest <- mfrmr_gtwf_manifest(feasibility_contract)
  }
  if (!inherits(feasibility_manifest, "mfrmr_gtwf_manifest") ||
      !identical(feasibility_manifest$ManifestHash,
                 contract$FeasibilityManifestHash)) {
    stop("The feasibility manifest identity differs.", call. = FALSE)
  }
  base <- feasibility_manifest$Rows
  profiles <- contract$Profiles
  pieces <- lapply(seq_len(nrow(base)), function(index) {
    route <- base[index, , drop = FALSE]
    matching <- profiles[profiles$Backend == route$Backend[[1L]], ,
                         drop = FALSE]
    route <- route[rep(1L, nrow(matching)), , drop = FALSE]
    row.names(route) <- NULL
    cbind(
      route,
      matching[, setdiff(names(matching), "Backend"), drop = FALSE],
      stringsAsFactors = FALSE
    )
  })
  rows <- do.call(rbind, pieces)
  row.names(rows) <- NULL
  rows$SensitivityRouteId <- paste(rows$RouteId, rows$ProfileId, sep = "::")
  rows$NumericalSensitivityContractHash <- contract$ContractHash
  rows$CalibrationUse <- FALSE
  rows$ThresholdSelectionPermitted <- FALSE
  exact <- nrow(rows) == contract$SensitivityPairCount &&
    length(unique(rows$DatasetId)) == contract$IndependentDatasetCount &&
    all(table(rows$RouteId) == contract$ProfileCountPerOriginalRoute) &&
    all(table(rows$DatasetId) == contract$SensitivityRowsPerDataset) &&
    all(table(rows$ScenarioId, rows$MethodId, rows$ProfileId)[
      table(rows$ScenarioId, rows$MethodId, rows$ProfileId) > 0
    ] == 25L) &&
    !anyDuplicated(rows$SensitivityRouteId)
  if (!exact) stop("Numerical-sensitivity manifest accounting failed.",
                   call. = FALSE)
  identity <- list(
    Contract =
      "gtheory_weak_information_numerical_sensitivity_manifest_draft83d2b2b1e_v1",
    NumericalSensitivityContractHash = contract$ContractHash,
    FeasibilityManifestHash = feasibility_manifest$ManifestHash,
    Rows = rows, ExactAccounting = exact
  )
  structure(c(identity, list(
    ManifestHash = mfrmr_gta_hash(identity),
    PlannedPairs = nrow(rows),
    PlannedBackendFits = 2L * nrow(rows),
    IndependentDatasetCount = length(unique(rows$DatasetId)),
    ResultsViewedBeforeContract = TRUE,
    CalibrationDataGenerated = FALSE,
    ThresholdSelectionPermitted = FALSE
  )), class = "mfrmr_gtwy_manifest")
}

mfrmr_gtwy_fit_pair <- function(generation, prefit, method_id, profile_id,
                                 contract) {
  if (!inherits(generation, "mfrmr_gtd2_generation") ||
      !inherits(prefit, "mfrmr_gtd3_prefit") || !prefit$PreFitEligible ||
      !inherits(contract, "mfrmr_gtwy_contract")) {
    stop("Sensitivity refits require one eligible generated/prefit unit.",
         call. = FALSE)
  }
  profile <- contract$Profiles[
    contract$Profiles$ProfileId == profile_id, , drop = FALSE
  ]
  if (nrow(profile) != 1L) stop("Unknown sensitivity profile.", call. = FALSE)
  backend <- if (grepl("^lme4_", method_id)) "lme4" else "glmmTMB"
  if (!identical(backend, profile$Backend[[1L]])) {
    stop("Method and profile backend differ.", call. = FALSE)
  }
  reml <- grepl("_reml$", method_id)
  likelihood_identity <- if (reml) "REML" else "ML"
  full_formula <- stats::as.formula(generation$Spec$FormulaCanonical)
  reduced_formula <- mfrmr_gtwd_reduced_formula(
    generation$Spec, contract$TargetComponent
  )
  data <- prefit$StructuralRankAudit$PreparedData$Data
  control <- mfrmr_gtwy_control(profile_id)
  if (backend == "lme4") {
    full <- mfrmr_gtwd_capture(lme4::lmer(
      full_formula, data = data, REML = reml, control = control
    ))
    reduced <- mfrmr_gtwd_capture(lme4::lmer(
      reduced_formula, data = data, REML = reml, control = control
    ))
    full_zero <- mfrmr_gtwd_lme4_zero(
      full$Fit, contract$BoundaryTolerance
    )
    reduced_zero <- mfrmr_gtwd_lme4_zero(
      reduced$Fit, contract$BoundaryTolerance
    )
    full_diagnostics <- mfrmr_gtc_lme4_diagnostics(
      full$Fit, full$Warnings, full$Messages, full_zero,
      contract$SingularTolerance
    )
    reduced_diagnostics <- mfrmr_gtc_lme4_diagnostics(
      reduced$Fit, reduced$Warnings, reduced$Messages, reduced_zero,
      contract$SingularTolerance
    )
    coordinate <- mfrmr_gtwd_lme4_coordinate(
      full$Fit, generation$Spec, contract$TargetComponent,
      contract$BoundaryTolerance
    )
    full_optimizer_ok <- full_diagnostics$OptimizerCode == 0L &&
      full_diagnostics$FitStatus != "optimizer_warning"
    reduced_optimizer_ok <- reduced_diagnostics$OptimizerCode == 0L &&
      reduced_diagnostics$FitStatus != "optimizer_warning"
    full_singular <- full_diagnostics$Singular
    reduced_singular <- reduced_diagnostics$Singular
    full_pd <- is.finite(full_diagnostics$MinimumHessianEigenvalue) &&
      full_diagnostics$MinimumHessianEigenvalue > 0
    reduced_pd <- is.finite(reduced_diagnostics$MinimumHessianEigenvalue) &&
      reduced_diagnostics$MinimumHessianEigenvalue > 0
  } else {
    family <- stats::gaussian(link = "identity")
    full <- mfrmr_gtwd_capture(glmmTMB::glmmTMB(
      formula = full_formula, data = data, family = family,
      ziformula = ~ 0, dispformula = ~ 1, REML = reml, control = control
    ))
    reduced <- mfrmr_gtwd_capture(glmmTMB::glmmTMB(
      formula = reduced_formula, data = data, family = family,
      ziformula = ~ 0, dispformula = ~ 1, REML = reml, control = control
    ))
    full_zero <- mfrmr_gtwd_glmmtmb_zero(
      full$Fit, contract$BoundaryTolerance
    )
    reduced_zero <- mfrmr_gtwd_glmmtmb_zero(
      reduced$Fit, contract$BoundaryTolerance
    )
    full_diagnostics <- mfrmr_gtm_diagnostics(
      full$Fit, full$Warnings, full$Messages, full_zero
    )
    reduced_diagnostics <- mfrmr_gtm_diagnostics(
      reduced$Fit, reduced$Warnings, reduced$Messages, reduced_zero
    )
    coordinate <- mfrmr_gtwd_glmmtmb_coordinate(
      full$Fit, generation$Spec, contract$TargetComponent,
      contract$BoundaryTolerance
    )
    full_optimizer_ok <- full_diagnostics$OptimizerCode == 0L &&
      isTRUE(full_diagnostics$PositiveDefiniteHessian)
    reduced_optimizer_ok <- reduced_diagnostics$OptimizerCode == 0L &&
      isTRUE(reduced_diagnostics$PositiveDefiniteHessian)
    full_singular <- NA
    reduced_singular <- NA
    full_pd <- full_diagnostics$PositiveDefiniteHessian
    reduced_pd <- reduced_diagnostics$PositiveDefiniteHessian
  }
  full_likelihood <- stats::logLik(full$Fit)
  reduced_likelihood <- stats::logLik(reduced$Fit)
  full_value <- as.numeric(full_likelihood)
  reduced_value <- as.numeric(reduced_likelihood)
  drop <- 2 * (full_value - reduced_value)
  same_rows <- identical(as.integer(stats::nobs(full$Fit)),
                         as.integer(stats::nobs(reduced$Fit))) &&
    identical(as.integer(stats::nobs(full$Fit)), nrow(data))
  df_difference <- as.integer(attr(full_likelihood, "df")) -
    as.integer(attr(reduced_likelihood, "df"))
  likelihood_available <- all(is.finite(c(full_value, reduced_value, drop))) &&
    same_rows && identical(df_difference, 1L) &&
    isTRUE(full_optimizer_ok) && isTRUE(reduced_optimizer_ok)
  negative_ok <- is.finite(drop) &&
    drop >= -contract$NegativeLikelihoodTolerance
  material_negative <- is.finite(drop) &&
    drop < -contract$NegativeLikelihoodTolerance
  comparison_state <- if (!likelihood_available) {
    "not_evaluable_fit_or_identity_failure"
  } else if (!negative_ok) {
    "invalid_materially_negative_nested_drop"
  } else if (drop < 0) {
    "available_small_negative_numerical_drop_retained"
  } else {
    "available_raw_boundary_diagnostic"
  }
  payload <- list(
    Contract =
      "gtheory_weak_information_numerical_sensitivity_pair_draft83d2b2b1e_v1",
    NumericalSensitivityContractHash = contract$ContractHash,
    ScenarioId = generation$ScenarioId, Replicate = generation$Replicate,
    GeneratorHash = generation$GeneratorHash, PreFitHash = prefit$ResultHash,
    MethodId = method_id, Backend = backend,
    LikelihoodIdentity = likelihood_identity,
    ProfileId = profile_id, ProfileHash = profile$ProfileHash[[1L]],
    TargetComponent = contract$TargetComponent,
    FullFormulaCanonical = paste(
      deparse(full_formula, width.cutoff = 500L), collapse = " "
    ),
    ReducedFormulaCanonical = paste(
      deparse(reduced_formula, width.cutoff = 500L), collapse = " "
    ),
    RetainedDataHash =
      prefit$StructuralRankAudit$PreparedData$RetainedDataHash,
    FullLogLikelihood = full_value, ReducedLogLikelihood = reduced_value,
    RawLikelihoodDrop = drop, LikelihoodDfDifference = df_difference,
    SameRows = same_rows,
    LikelihoodDiagnosticAvailable = likelihood_available,
    NegativeDropWithinTolerance = negative_ok,
    MaterialNegativeDrop = material_negative,
    ComparisonState = comparison_state,
    FullOptimizerPassed = isTRUE(full_optimizer_ok),
    ReducedOptimizerPassed = isTRUE(reduced_optimizer_ok),
    FullHessianPositiveDefinite = isTRUE(full_pd),
    ReducedHessianPositiveDefinite = isTRUE(reduced_pd),
    FullSingular = full_singular, ReducedSingular = reduced_singular,
    FullBoundaryComponentCount = sum(full_zero),
    ReducedBoundaryComponentCount = sum(reduced_zero),
    CoordinateDiagnostic = coordinate,
    ReferenceDistribution = "none_numerical_sensitivity_only",
    PValue = NA_real_, Interval = "none"
  )
  structure(c(payload, list(
    ResultHash = mfrmr_gta_hash(payload), FullFit = full$Fit,
    ReducedFit = reduced$Fit, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = c("mfrmr_gtwy_pair", "mfrmr_gtwd_pair"))
}

mfrmr_gtwy_success_row <- function(route, pair, generation, contract) {
  observable <- mfrmr_gtwf_observable_row(
    route, pair, generation,
    boundary_tolerance = contract$BoundaryTolerance
  )
  data.frame(
    route, PairReturned = TRUE, PairResultHash = pair$ResultHash,
    ObservableHash = observable$ObservableHash,
    FullLogLikelihood = pair$FullLogLikelihood,
    ReducedLogLikelihood = pair$ReducedLogLikelihood,
    RawLikelihoodDrop = pair$RawLikelihoodDrop,
    LikelihoodDiagnosticAvailable = pair$LikelihoodDiagnosticAvailable,
    NegativeDropWithinTolerance = pair$NegativeDropWithinTolerance,
    MaterialNegativeDrop = pair$MaterialNegativeDrop,
    ComparisonState = pair$ComparisonState,
    TargetEstimate = observable$TargetEstimate,
    ResidualEstimate = observable$ResidualEstimate,
    TargetFractionTotal = observable$TargetFractionTotal,
    TargetToResidualRatio = observable$TargetToResidualRatio,
    FeasibilityScoreAvailable = observable$FeasibilityScoreAvailable,
    TargetBoundaryToleranceReached =
      observable$TargetBoundaryToleranceReached,
    NuisanceBoundaryPresent = observable$NuisanceBoundaryPresent,
    FullOptimizerPassed = pair$FullOptimizerPassed,
    ReducedOptimizerPassed = pair$ReducedOptimizerPassed,
    FullHessianPositiveDefinite = pair$FullHessianPositiveDefinite,
    ReducedHessianPositiveDefinite = pair$ReducedHessianPositiveDefinite,
    FullSingular = pair$FullSingular, ReducedSingular = pair$ReducedSingular,
    FullBoundaryComponentCount = pair$FullBoundaryComponentCount,
    ReducedBoundaryComponentCount = pair$ReducedBoundaryComponentCount,
    SameRows = pair$SameRows,
    LikelihoodDfDifference = pair$LikelihoodDfDifference,
    FailureStage = "none", FailureMessageDigest = "none",
    PValue = NA_real_, Interval = "none", ThresholdApplied = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwy_failure_row <- function(route, stage, message) {
  data.frame(
    route, PairReturned = FALSE, PairResultHash = "none",
    ObservableHash = "none", FullLogLikelihood = NA_real_,
    ReducedLogLikelihood = NA_real_, RawLikelihoodDrop = NA_real_,
    LikelihoodDiagnosticAvailable = FALSE,
    NegativeDropWithinTolerance = FALSE,
    MaterialNegativeDrop = FALSE,
    ComparisonState = "not_evaluable_route_error",
    TargetEstimate = NA_real_, ResidualEstimate = NA_real_,
    TargetFractionTotal = NA_real_, TargetToResidualRatio = NA_real_,
    FeasibilityScoreAvailable = FALSE,
    TargetBoundaryToleranceReached = NA,
    NuisanceBoundaryPresent = NA,
    FullOptimizerPassed = FALSE, ReducedOptimizerPassed = FALSE,
    FullHessianPositiveDefinite = FALSE,
    ReducedHessianPositiveDefinite = FALSE,
    FullSingular = NA, ReducedSingular = NA,
    FullBoundaryComponentCount = NA_integer_,
    ReducedBoundaryComponentCount = NA_integer_,
    SameRows = FALSE, LikelihoodDfDifference = NA_integer_,
    FailureStage = as.character(stage),
    FailureMessageDigest = mfrmr_gta_hash(as.character(message)),
    PValue = NA_real_, Interval = "none", ThresholdApplied = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gtwy_route_path <- function(checkpoint_root, sensitivity_route_id) {
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  file.path(
    checkpoint_root, "routes",
    paste0(mfrmr_gta_hash(as.character(sensitivity_route_id)), ".rds")
  )
}

mfrmr_gtwy_dataset_path <- function(checkpoint_root, dataset_id) {
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  file.path(
    checkpoint_root, "datasets",
    paste0(mfrmr_gta_hash(as.character(dataset_id)), ".rds")
  )
}

mfrmr_gtwy_checkpoint <- function(contract, manifest_hash, route,
                                   generation, prefit, atomic_row,
                                   timing = NULL) {
  identity <- list(
    Contract =
      "gtheory_weak_information_numerical_checkpoint_draft83d2b2b1e_v1",
    NumericalSensitivityContractHash = contract$ContractHash,
    NumericalSensitivityManifestHash = manifest_hash,
    FeasibilityExecutionHash = contract$FeasibilityExecutionHash,
    SensitivityRouteIdentity = route,
    GeneratorHash = if (is.null(generation)) "none" else
      generation$GeneratorHash,
    AnalysisDataHash = if (is.null(generation)) "none" else
      generation$GeneratorIdentity$AnalysisDataHash,
    PreFitHash = if (is.null(prefit)) "none" else prefit$ResultHash,
    RetainedDataHash = if (is.null(prefit)) "none" else
      prefit$StructuralRankAudit$PreparedData$RetainedDataHash,
    AtomicResult = atomic_row
  )
  structure(list(
    Identity = identity, ResultHash = mfrmr_gta_hash(identity),
    Timing = timing
  ), class = "mfrmr_gtwy_checkpoint")
}

mfrmr_gtwy_validate_checkpoint <- function(checkpoint, contract,
                                             manifest_hash, route) {
  valid <- inherits(checkpoint, "mfrmr_gtwy_checkpoint") &&
    is.list(checkpoint$Identity) &&
    identical(checkpoint$ResultHash, mfrmr_gta_hash(checkpoint$Identity)) &&
    identical(checkpoint$Identity$NumericalSensitivityContractHash,
              contract$ContractHash) &&
    identical(checkpoint$Identity$NumericalSensitivityManifestHash,
              manifest_hash) &&
    identical(checkpoint$Identity$FeasibilityExecutionHash,
              contract$FeasibilityExecutionHash) &&
    identical(checkpoint$Identity$SensitivityRouteIdentity, route) &&
    is.data.frame(checkpoint$Identity$AtomicResult) &&
    nrow(checkpoint$Identity$AtomicResult) == 1L &&
    identical(
      checkpoint$Identity$AtomicResult$SensitivityRouteId[[1L]],
      route$SensitivityRouteId[[1L]]
    )
  list(
    Valid = isTRUE(valid),
    ResultHash = if (isTRUE(valid)) checkpoint$ResultHash else "none",
    AtomicResult = if (isTRUE(valid)) checkpoint$Identity$AtomicResult else NULL
  )
}

mfrmr_gtwy_marker <- function(contract, manifest_hash, dataset_id,
                               checkpoints) {
  hashes <- vapply(checkpoints, `[[`, character(1L), "ResultHash")
  names(hashes) <- vapply(checkpoints, function(checkpoint) {
    checkpoint$Identity$SensitivityRouteIdentity$SensitivityRouteId[[1L]]
  }, character(1L))
  hashes <- hashes[order(names(hashes), method = "radix")]
  identity <- list(
    Contract =
      "gtheory_weak_information_numerical_marker_draft83d2b2b1e_v1",
    NumericalSensitivityContractHash = contract$ContractHash,
    NumericalSensitivityManifestHash = manifest_hash,
    DatasetId = as.character(dataset_id), ResultHashes = hashes,
    ResultCount = length(hashes),
    CompletionState = "all_method_profile_pairs_valid"
  )
  structure(list(
    Identity = identity, MarkerHash = mfrmr_gta_hash(identity)
  ), class = "mfrmr_gtwy_marker")
}

mfrmr_gtwy_validate_marker <- function(marker, contract, manifest_hash,
                                         dataset_id, checkpoints) {
  if (!inherits(marker, "mfrmr_gtwy_marker") ||
      !identical(marker$MarkerHash, mfrmr_gta_hash(marker$Identity))) {
    return(FALSE)
  }
  expected <- mfrmr_gtwy_marker(
    contract, manifest_hash, dataset_id, checkpoints
  )
  identical(marker$Identity, expected$Identity) &&
    identical(marker$MarkerHash, expected$MarkerHash) &&
    identical(marker$Identity$ResultCount,
              contract$SensitivityRowsPerDataset)
}

mfrmr_gtwy_route_summary <- function(rows, baseline_rows, contract) {
  route_ids <- unique(rows$RouteId)
  out <- lapply(route_ids, function(route_id) {
    group <- rows[rows$RouteId == route_id, , drop = FALSE]
    baseline <- baseline_rows[baseline_rows$RouteId == route_id, , drop = FALSE]
    default <- group[group$IsDefault, , drop = FALSE]
    if (nrow(group) != 3L || nrow(default) != 1L || nrow(baseline) != 1L) {
      stop("Route summary identity is incomplete.", call. = FALSE)
    }
    finite_full <- is.finite(group$FullLogLikelihood)
    finite_reduced <- is.finite(group$ReducedLogLikelihood)
    full_max <- if (any(finite_full)) max(group$FullLogLikelihood[finite_full])
      else NA_real_
    full_min <- if (any(finite_full)) min(group$FullLogLikelihood[finite_full])
      else NA_real_
    reduced_max <- if (any(finite_reduced))
      max(group$ReducedLogLikelihood[finite_reduced]) else NA_real_
    reduced_min <- if (any(finite_reduced))
      min(group$ReducedLogLikelihood[finite_reduced]) else NA_real_
    material <- group$PairReturned %in% TRUE &
      group$MaterialNegativeDrop %in% TRUE
    within <- group$PairReturned %in% TRUE &
      is.finite(group$RawLikelihoodDrop) &
      group$NegativeDropWithinTolerance %in% TRUE
    sign_state <- if (all(material)) {
      "all_profiles_materially_negative"
    } else if (any(material) && any(within)) {
      "optimizer_sensitive_material_vs_within_tolerance"
    } else if (all(within)) {
      "all_profiles_within_tolerance"
    } else {
      "incomplete_profile_sign_state"
    }
    target <- group$TargetEstimate[is.finite(group$TargetEstimate)]
    full_best <- if (is.finite(full_max)) paste(
      group$ProfileId[finite_full &
        abs(group$FullLogLikelihood - full_max) <= 1e-12],
      collapse = ";"
    ) else "none"
    reduced_best <- if (is.finite(reduced_max)) paste(
      group$ProfileId[finite_reduced &
        abs(group$ReducedLogLikelihood - reduced_max) <= 1e-12],
      collapse = ";"
    ) else "none"
    replay_difference <- abs(
      default$RawLikelihoodDrop[[1L]] - baseline$RawLikelihoodDrop[[1L]]
    )
    data.frame(
      RouteId = route_id, ScenarioId = group$ScenarioId[[1L]],
      DesignId = group$DesignId[[1L]], VarianceId = group$VarianceId[[1L]],
      TargetVariance = group$TargetVariance[[1L]],
      TruthRegion = group$TruthRegion[[1L]],
      EvaluationRole = group$EvaluationRole[[1L]],
      Replicate = group$Replicate[[1L]], MethodId = group$MethodId[[1L]],
      Backend = group$Backend[[1L]], Likelihood = group$Likelihood[[1L]],
      ProfilePairReturnedN = sum(group$PairReturned %in% TRUE),
      ProfileLikelihoodAvailableN = sum(
        group$LikelihoodDiagnosticAvailable %in% TRUE
      ),
      ProfileComparisonAvailableN = sum(
        group$LikelihoodDiagnosticAvailable %in% TRUE &
          group$NegativeDropWithinTolerance %in% TRUE
      ),
      MaterialNegativeProfileN = sum(material), SignState = sign_state,
      BaselineRawLikelihoodDrop = baseline$RawLikelihoodDrop[[1L]],
      DefaultReplayRawLikelihoodDrop = default$RawLikelihoodDrop[[1L]],
      DefaultReplayAbsoluteDifference = replay_difference,
      DefaultReplayWithinTolerance = is.finite(replay_difference) &&
        replay_difference <= contract$DefaultReplayTolerance,
      FullLogLikelihoodMaximum = full_max,
      FullLogLikelihoodMinimum = full_min,
      FullDevianceSpread = if (is.finite(full_max) && is.finite(full_min))
        2 * (full_max - full_min) else NA_real_,
      FullMaximumProfile = full_best,
      ReducedLogLikelihoodMaximum = reduced_max,
      ReducedLogLikelihoodMinimum = reduced_min,
      ReducedDevianceSpread =
        if (is.finite(reduced_max) && is.finite(reduced_min))
          2 * (reduced_max - reduced_min) else NA_real_,
      ReducedMaximumProfile = reduced_best,
      EnvelopeRawLikelihoodDrop =
        if (is.finite(full_max) && is.finite(reduced_max))
          2 * (full_max - reduced_max) else NA_real_,
      EnvelopeNegativeWithinTolerance =
        is.finite(full_max) && is.finite(reduced_max) &&
          2 * (full_max - reduced_max) >=
            -contract$NegativeLikelihoodTolerance,
      TargetEstimateMinimum = if (length(target)) min(target) else NA_real_,
      TargetEstimateMaximum = if (length(target)) max(target) else NA_real_,
      TargetEstimateSpread = if (length(target)) max(target) - min(target)
        else NA_real_,
      TargetBoundaryProfileN = sum(
        group$TargetBoundaryToleranceReached %in% TRUE
      ),
      NuisanceBoundaryProfileN = sum(
        group$NuisanceBoundaryPresent %in% TRUE
      ),
      ThresholdSelected = FALSE, PValue = NA_real_, Interval = "none",
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  row.names(out) <- NULL
  out
}

mfrmr_gtwy_profile_summary <- function(rows) {
  key <- interaction(rows$ScenarioId, rows$MethodId, rows$ProfileId,
                     drop = TRUE, lex.order = TRUE)
  groups <- split(rows, key)
  out <- lapply(groups, function(group) {
    data.frame(
      ScenarioId = group$ScenarioId[[1L]],
      DesignId = group$DesignId[[1L]],
      VarianceId = group$VarianceId[[1L]],
      TargetVariance = group$TargetVariance[[1L]],
      MethodId = group$MethodId[[1L]], Backend = group$Backend[[1L]],
      Likelihood = group$Likelihood[[1L]],
      ProfileId = group$ProfileId[[1L]],
      ProfileRole = group$ProfileRole[[1L]], PlannedN = nrow(group),
      PairReturnedN = sum(group$PairReturned %in% TRUE),
      LikelihoodAvailableN = sum(
        group$LikelihoodDiagnosticAvailable %in% TRUE
      ),
      ComparisonAvailableN = sum(
        group$LikelihoodDiagnosticAvailable %in% TRUE &
          group$NegativeDropWithinTolerance %in% TRUE
      ),
      MaterialNegativeN = sum(
        group$PairReturned %in% TRUE &
          group$MaterialNegativeDrop %in% TRUE
      ),
      TargetBoundaryN = sum(group$TargetBoundaryToleranceReached %in% TRUE),
      NuisanceBoundaryN = sum(group$NuisanceBoundaryPresent %in% TRUE),
      TypedFailureN = sum(!(group$PairReturned %in% TRUE)),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  row.names(out) <- NULL
  out[order(out$ScenarioId, out$MethodId, out$ProfileId,
            method = "radix"), , drop = FALSE]
}

mfrmr_gtwy_spread_grid <- function(route_summary, contract) {
  keys <- expand.grid(
    DesignId = sort(unique(route_summary$DesignId), method = "radix"),
    MethodId = sort(unique(route_summary$MethodId), method = "radix"),
    Tolerance = contract$DevianceSpreadReportingGrid,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  out <- lapply(seq_len(nrow(keys)), function(index) {
    key <- keys[index, , drop = FALSE]
    selected <- route_summary$DesignId == key$DesignId[[1L]] &
      route_summary$MethodId == key$MethodId[[1L]]
    group <- route_summary[selected, , drop = FALSE]
    tolerance <- key$Tolerance[[1L]]
    data.frame(
      DesignId = key$DesignId[[1L]], MethodId = key$MethodId[[1L]],
      DevianceSpreadTolerance = tolerance, PlannedN = nrow(group),
      FullSpreadFiniteN = sum(is.finite(group$FullDevianceSpread)),
      FullWithinN = sum(
        is.finite(group$FullDevianceSpread) &
          group$FullDevianceSpread <= tolerance
      ),
      ReducedSpreadFiniteN = sum(is.finite(group$ReducedDevianceSpread)),
      ReducedWithinN = sum(
        is.finite(group$ReducedDevianceSpread) &
          group$ReducedDevianceSpread <= tolerance
      ),
      PracticalEquivalenceThresholdSelected = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

mfrmr_gtwy_summaries <- function(rows, baseline_rows, contract) {
  if (!is.data.frame(rows) || nrow(rows) != contract$SensitivityPairCount ||
      anyDuplicated(rows$SensitivityRouteId) ||
      !is.data.frame(baseline_rows) || nrow(baseline_rows) != 3000L) {
    stop("Sensitivity summaries require complete atomic ledgers.",
         call. = FALSE)
  }
  route <- mfrmr_gtwy_route_summary(rows, baseline_rows, contract)
  list(
    ProfileAvailability = mfrmr_gtwy_profile_summary(rows),
    RouteComparison = route,
    SpreadGrid = mfrmr_gtwy_spread_grid(route, contract),
    DefaultReplayPassed = all(route$DefaultReplayWithinTolerance),
    PracticalEquivalenceThresholdSelected = FALSE,
    CalibrationDataGenerated = FALSE, BootstrapRun = FALSE,
    PValuesAssigned = FALSE, IntervalsAssigned = FALSE
  )
}

mfrmr_gtwy_execute <- function(contract, manifest, feasibility_execution,
                                checkpoint_root,
                                progress_every = 25L) {
  if (!inherits(contract, "mfrmr_gtwy_contract") ||
      !inherits(manifest, "mfrmr_gtwy_manifest") ||
      !mfrmr_gtwy_validate_feasibility_execution(feasibility_execution) ||
      !identical(contract$FeasibilityExecutionHash,
                 feasibility_execution$ExecutionHash) ||
      !identical(manifest$NumericalSensitivityContractHash,
                 contract$ContractHash) ||
      !isTRUE(contract$NumericalSensitivityExecutionAuthorized) ||
      isTRUE(contract$CalibrationDataGenerationPermitted) ||
      isTRUE(contract$ThresholdSelectionPermitted) ||
      isTRUE(contract$BootstrapPermitted) ||
      isTRUE(contract$EarlyStoppingPermitted)) {
    stop("The numerical-sensitivity execution is not authorized.",
         call. = FALSE)
  }
  checkpoint_root <- mfrmr_gtwx_checkpoint_root(checkpoint_root)
  progress_every <- as.integer(progress_every)
  if (length(progress_every) != 1L || is.na(progress_every) ||
      progress_every < 0L) {
    stop("`progress_every` must be one nonnegative integer.", call. = FALSE)
  }
  rows <- manifest$Rows
  dataset_ids <- unique(rows$DatasetId)
  atomic_rows <- vector("list", nrow(rows))
  result_hashes <- character(nrow(rows))
  marker_hashes <- character(length(dataset_ids))
  timing <- vector("list", nrow(rows))
  reused <- logical(nrow(rows))
  cursor <- 0L
  registry <- mfrmr_gtw_registry()
  for (dataset_index in seq_along(dataset_ids)) {
    dataset_id <- dataset_ids[[dataset_index]]
    routes <- rows[rows$DatasetId == dataset_id, , drop = FALSE]
    paths <- vapply(routes$SensitivityRouteId, function(route_id) {
      mfrmr_gtwy_route_path(checkpoint_root, route_id)
    }, character(1L))
    checkpoints <- lapply(paths, mfrmr_gtwx_safe_read)
    validations <- lapply(seq_len(nrow(routes)), function(index) {
      mfrmr_gtwy_validate_checkpoint(
        checkpoints[[index]], contract, manifest$ManifestHash,
        routes[index, , drop = FALSE]
      )
    })
    valid <- vapply(validations, `[[`, logical(1L), "Valid")
    initially_valid <- valid
    marker_path <- mfrmr_gtwy_dataset_path(checkpoint_root, dataset_id)
    marker <- mfrmr_gtwx_safe_read(marker_path)
    marker_valid <- all(valid) && mfrmr_gtwy_validate_marker(
      marker, contract, manifest$ManifestHash, dataset_id, checkpoints
    )
    generation <- NULL
    prefit <- NULL
    generation_error <- NULL
    if (!all(valid)) {
      generated <- tryCatch({
        generation <- mfrmr_gtw_generate(
          registry, routes$ScenarioId[[1L]], routes$Replicate[[1L]]
        )
        prefit <- mfrmr_gtd3_prefit_one(generation)
        TRUE
      }, error = function(error) error)
      if (inherits(generated, "error")) generation_error <- generated
      for (route_index in which(!valid)) {
        route <- routes[route_index, , drop = FALSE]
        pair <- NULL
        pair_error <- generation_error
        clock <- system.time({
          if (is.null(generation_error)) {
            attempted <- tryCatch(
              mfrmr_gtwy_fit_pair(
                generation, prefit, route$MethodId[[1L]],
                route$ProfileId[[1L]], contract
              ),
              error = function(error) error
            )
            if (inherits(attempted, "error")) pair_error <- attempted else
              pair <- attempted
          }
        }, gcFirst = TRUE)
        if (is.null(pair)) {
          stage <- if (is.null(generation_error)) "profile_pair" else
            "generation_or_prefit"
          atomic <- mfrmr_gtwy_failure_row(
            route, stage, conditionMessage(pair_error)
          )
        } else {
          atomic <- mfrmr_gtwy_success_row(
            route, pair, generation, contract
          )
        }
        route_timing <- data.frame(
          SensitivityRouteId = route$SensitivityRouteId[[1L]],
          UserSeconds = unname(clock[["user.self"]]),
          SystemSeconds = unname(clock[["sys.self"]]),
          ElapsedSeconds = unname(clock[["elapsed"]]),
          stringsAsFactors = FALSE
        )
        checkpoint <- mfrmr_gtwy_checkpoint(
          contract, manifest$ManifestHash, route, generation, prefit,
          atomic, route_timing
        )
        mfrmr_gtwx_atomic_write(checkpoint, paths[[route_index]])
        checkpoints[[route_index]] <- checkpoint
        validations[[route_index]] <- mfrmr_gtwy_validate_checkpoint(
          checkpoint, contract, manifest$ManifestHash, route
        )
        valid[[route_index]] <- validations[[route_index]]$Valid
      }
    }
    if (!all(valid)) stop("A sensitivity dataset is incomplete.",
                          call. = FALSE)
    if (!marker_valid) {
      marker <- mfrmr_gtwy_marker(
        contract, manifest$ManifestHash, dataset_id, checkpoints
      )
      mfrmr_gtwx_atomic_write(marker, marker_path)
      marker_valid <- mfrmr_gtwy_validate_marker(
        marker, contract, manifest$ManifestHash, dataset_id, checkpoints
      )
    }
    if (!marker_valid) stop("Sensitivity dataset marker failed.",
                            call. = FALSE)
    for (route_index in seq_len(nrow(routes))) {
      cursor <- cursor + 1L
      atomic_rows[[cursor]] <- validations[[route_index]]$AtomicResult
      result_hashes[[cursor]] <- validations[[route_index]]$ResultHash
      reused[[cursor]] <- initially_valid[[route_index]]
      saved_timing <- checkpoints[[route_index]]$Timing
      timing[[cursor]] <- if (is.data.frame(saved_timing)) saved_timing else
        data.frame(
          SensitivityRouteId = routes$SensitivityRouteId[[route_index]],
          UserSeconds = NA_real_, SystemSeconds = NA_real_,
          ElapsedSeconds = NA_real_, stringsAsFactors = FALSE
        )
    }
    marker_hashes[[dataset_index]] <- marker$MarkerHash
    if (progress_every > 0L &&
        (dataset_index %% progress_every == 0L ||
         dataset_index == length(dataset_ids))) {
      message(sprintf(
        "[numerical sensitivity dataset %d/%d] %s", dataset_index,
        length(dataset_ids), dataset_id
      ))
    }
  }
  atomic <- do.call(rbind, atomic_rows)
  timing <- do.call(rbind, timing)
  row.names(atomic) <- NULL
  row.names(timing) <- NULL
  order_index <- match(rows$SensitivityRouteId, atomic$SensitivityRouteId)
  if (anyNA(order_index)) stop("Sensitivity ledger is missing routes.",
                               call. = FALSE)
  atomic <- atomic[order_index, , drop = FALSE]
  timing <- timing[match(rows$SensitivityRouteId,
                         timing$SensitivityRouteId), , drop = FALSE]
  result_hashes <- result_hashes[order_index]
  reused <- reused[order_index]
  names(result_hashes) <- atomic$SensitivityRouteId
  names(marker_hashes) <- dataset_ids
  exact <- nrow(atomic) == contract$SensitivityPairCount &&
    !anyDuplicated(atomic$SensitivityRouteId) &&
    identical(as.character(atomic$SensitivityRouteId),
              as.character(rows$SensitivityRouteId)) &&
    length(marker_hashes) == contract$IndependentDatasetCount &&
    all(table(atomic$DatasetId) == contract$SensitivityRowsPerDataset) &&
    all(table(atomic$RouteId) == contract$ProfileCountPerOriginalRoute)
  if (!exact) stop("Final sensitivity accounting failed.", call. = FALSE)
  summaries <- mfrmr_gtwy_summaries(
    atomic, feasibility_execution$AtomicRows, contract
  )
  scientific_identity <- list(
    Contract =
      "gtheory_weak_information_numerical_execution_draft83d2b2b1e_v1",
    NumericalSensitivityContractHash = contract$ContractHash,
    NumericalSensitivityManifestHash = manifest$ManifestHash,
    FeasibilityExecutionHash = feasibility_execution$ExecutionHash,
    AtomicRows = atomic, ResultHashes = result_hashes,
    MarkerHashes = marker_hashes, Summaries = summaries
  )
  ready <- exact && isTRUE(summaries$DefaultReplayPassed)
  structure(c(scientific_identity, list(
    ExecutionHash = mfrmr_gta_hash(scientific_identity),
    RouteTiming = timing, CheckpointReuse = reused,
    CheckpointReuseCount = sum(reused),
    ComputedRouteCount = sum(!reused),
    ExactAccountingPassed = exact,
    PlannedPairs = contract$SensitivityPairCount,
    PlannedBackendFits = contract$SensitivityBackendFitCount,
    PairReturnCount = sum(atomic$PairReturned %in% TRUE),
    TypedFailureCount = sum(!(atomic$PairReturned %in% TRUE)),
    LikelihoodAvailableCount = sum(
      atomic$LikelihoodDiagnosticAvailable %in% TRUE
    ),
    ComparisonAvailableCount = sum(
      atomic$LikelihoodDiagnosticAvailable %in% TRUE &
        atomic$NegativeDropWithinTolerance %in% TRUE
    ),
    MaterialNegativeCount = sum(
      atomic$PairReturned %in% TRUE &
        atomic$MaterialNegativeDrop %in% TRUE
    ),
    DefaultReplayPassed = summaries$DefaultReplayPassed,
    NumericalSensitivityEvidenceReady = ready,
    CalibrationEvidenceReady = FALSE,
    BootstrapOperatingCharacteristicsReady = FALSE,
    ThresholdFrozen = FALSE, ConfirmationAuthorized = FALSE,
    InferenceReady = FALSE, CoefficientEligible = FALSE,
    DecisionReady = FALSE
  )), class = "mfrmr_gtwy_execution")
}
