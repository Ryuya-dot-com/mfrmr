# Draft.83d2b1 atomic G-theory ADEMP fit adapter prototype.
#
# Repository-internal only. This file executes method-specific point fits for
# structurally eligible Draft.83d2b0 units and records typed pre-fit/backend/
# regularity failures. It computes no recovery metric or interval.

mfrmr_gtd4_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_component_id", "mfrmr_gtc_matrix_rank",
    "mfrmr_gtc_lme4_diagnostics", "mfrmr_gtm_diagnostics",
    "mfrmr_gtm_components", "mfrmr_gtm_control_identity",
    "mfrmr_gtm_backend_function_hashes", "mfrmr_gte_mom",
    "mfrmr_gtd_registry", "mfrmr_gtd2_generate",
    "mfrmr_gtd_denominator_summary", "mfrmr_gtd3_prefit_registry"
  )
  prototype_environment <- environment(mfrmr_gtd4_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source Draft.81/82/83a/c1/c2/d1/d2a/d2b0 before Draft.83d2b1: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gtd4_function_hash <- function(fun) {
  mfrmr_gta_hash(list(Formals = formals(fun), Body = body(fun)))
}

mfrmr_gtd4_function_hashes <- function() {
  functions <- c(
    "mfrmr_gtd4_curvature", "mfrmr_gtd4_lme4_components",
    "mfrmr_gtd4_fit_mom", "mfrmr_gtd4_fit_lme4",
    "mfrmr_gtd4_fit_glmmtmb", "mfrmr_gtd4_failure_detail",
    "mfrmr_gtd4_execute_one", "mfrmr_gtd4_execute_registry"
  )
  environment <- environment(mfrmr_gtd4_function_hashes)
  stats::setNames(vapply(functions, function(name) {
    mfrmr_gtd4_function_hash(get(name, envir = environment, inherits = TRUE))
  }, character(1L)), functions)
}

mfrmr_gtd4_curvature <- function(matrix, parameter_count,
                                  tolerance = 1e-8,
                                  matrix_is_covariance = FALSE) {
  parameter_count <- as.integer(parameter_count)
  if (length(parameter_count) != 1L || is.na(parameter_count) ||
      parameter_count < 1L) {
    return(data.frame(
      CurvatureState = "unavailable", CurvatureParameterCount = 0L,
      CurvatureRank = 0L, CurvatureRankFull = FALSE,
      MinimumCurvatureEigenvalue = NA_real_, stringsAsFactors = FALSE
    ))
  }
  if (!is.matrix(matrix) || !identical(nrow(matrix), parameter_count) ||
      !identical(ncol(matrix), parameter_count) || !all(is.finite(matrix))) {
    return(data.frame(
      CurvatureState = "unavailable",
      CurvatureParameterCount = parameter_count, CurvatureRank = 0L,
      CurvatureRankFull = FALSE, MinimumCurvatureEigenvalue = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  symmetric <- (matrix + t(matrix)) / 2
  if (isTRUE(matrix_is_covariance)) {
    values <- eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values
    if (any(values <= 0)) {
      return(data.frame(
        CurvatureState = "nonpositive_covariance",
        CurvatureParameterCount = parameter_count, CurvatureRank = 0L,
        CurvatureRankFull = FALSE, MinimumCurvatureEigenvalue = NA_real_,
        stringsAsFactors = FALSE
      ))
    }
    symmetric <- solve(symmetric)
    symmetric <- (symmetric + t(symmetric)) / 2
  }
  rank <- mfrmr_gtc_matrix_rank(symmetric, tolerance)
  eigenvalues <- eigen(symmetric, symmetric = TRUE, only.values = TRUE)$values
  minimum <- min(eigenvalues)
  full <- identical(rank$Rank, parameter_count) && is.finite(minimum) &&
    minimum > rank$Threshold
  data.frame(
    CurvatureState = if (full) "positive_full_rank" else
      "nonpositive_or_rank_deficient",
    CurvatureParameterCount = parameter_count,
    CurvatureRank = rank$Rank, CurvatureRankFull = full,
    MinimumCurvatureEigenvalue = minimum, stringsAsFactors = FALSE
  )
}

mfrmr_gtd4_lme4_components <- function(fit, spec) {
  vc <- as.data.frame(lme4::VarCorr(fit))
  vc <- vc[is.na(vc$var2), c("grp", "vcov"), drop = FALSE]
  declared <- c(spec$ObjectFacet, spec$RandomFacets, spec$FixedFacets)
  component_id <- vapply(as.character(vc$grp), function(group) {
    if (identical(group, "Residual")) return("Residual")
    mfrmr_gta_component_id(
      strsplit(group, ":", fixed = TRUE)[[1L]], declared
    )
  }, character(1L))
  estimate <- stats::setNames(as.numeric(vc$vcov), component_id)
  required <- spec$EffectMap$ComponentId
  if (anyDuplicated(names(estimate)) || !setequal(names(estimate), required)) {
    stop("lme4 components do not match the typed effect map.", call. = FALSE)
  }
  estimate[required]
}

mfrmr_gtd4_fit_mom <- function(generation, prefit) {
  started <- proc.time()[["elapsed"]]
  fit <- mfrmr_gte_mom(generation$Spec, generation$AnalysisData)
  estimates <- stats::setNames(
    as.numeric(fit$Components$Estimate), fit$Components$ComponentId
  )
  finite <- length(estimates) == prefit$StructuralDimension &&
    all(is.finite(estimates))
  identified <- all(fit$Components$EstimabilityStatus == "identified")
  passed <- finite && identified
  payload <- list(
    Contract = "gtheory_ademp_mom_adapter_draft83d2b1_v1",
    ScenarioId = generation$ScenarioId,
    GeneratorHash = generation$GeneratorHash,
    PreFitHash = prefit$ResultHash,
    MethodId = "balanced_mom", Backend = "balanced_mom",
    EstimatorIdentity = fit$EstimatorIdentity,
    Components = fit$Components,
    ComputationalCompletion = TRUE,
    PointGatePassed = passed,
    LikelihoodInformationState = "not_applicable_nonlikelihood_mom",
    IntervalState = "none"
  )
  list(
    FitReturned = TRUE, OptimizerConverged = TRUE,
    ComponentVectorFinite = finite, EstimationGatePassed = passed,
    RegularInterior = NA, Curvature = data.frame(
      CurvatureState = "not_applicable_nonlikelihood_mom",
      CurvatureParameterCount = 0L, CurvatureRank = 0L,
      CurvatureRankFull = TRUE, MinimumCurvatureEigenvalue = NA_real_,
      stringsAsFactors = FALSE
    ),
    BoundaryComponentCount = sum(fit$Components$BoundaryState == "negative_raw"),
    FailureStage = if (passed) "none" else "component_extraction",
    FailureCode = if (passed) "none" else "mom_component_contract_failed",
    ConditionClass = if (passed) "none" else "mfrmr_gtd4_mom_failure",
    Message = if (passed) "" else "MoM component output was incomplete.",
    RuntimeSeconds = proc.time()[["elapsed"]] - started,
    PointResultHash = mfrmr_gta_hash(payload), Detail = payload
  )
}

mfrmr_gtd4_fit_lme4 <- function(generation, prefit, reml,
                                 rank_tolerance = 1e-8,
                                 boundary_tolerance = 1e-8,
                                 singular_tolerance = 1e-4) {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    stop("Draft.83d2b1 lme4 adapter requires `lme4`.", call. = FALSE)
  }
  started <- proc.time()[["elapsed"]]
  formula <- stats::as.formula(generation$Spec$FormulaCanonical)
  control <- lme4::lmerControl()
  warnings <- character()
  messages <- character()
  fit <- withCallingHandlers(
    lme4::lmer(
      formula, data = prefit$StructuralRankAudit$PreparedData$Data,
      REML = isTRUE(reml), control = control
    ),
    warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    },
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  )
  estimates <- mfrmr_gtd4_lme4_components(fit, generation$Spec)
  zero <- estimates <= boundary_tolerance
  diagnostics <- mfrmr_gtc_lme4_diagnostics(
    fit, warnings, messages, zero, singular_tolerance
  )
  theta <- lme4::getME(fit, "theta")
  curvature <- mfrmr_gtd4_curvature(
    fit@optinfo$derivs$Hessian, length(theta), rank_tolerance
  )
  finite <- all(is.finite(estimates))
  optimizer <- diagnostics$OptimizerCode[[1L]] == 0L &&
    diagnostics$FitStatus[[1L]] != "optimizer_warning"
  regular <- finite && !any(zero) && !isTRUE(diagnostics$Singular[[1L]])
  passed <- optimizer && finite && regular && curvature$CurvatureRankFull[[1L]]
  failure <- if (!optimizer) c("optimizer", "lme4_optimizer_not_converged")
    else if (!finite) c("component_extraction", "nonfinite_component_vector")
    else if (!regular) c("regularity", "lme4_boundary_or_singular")
    else if (!curvature$CurvatureRankFull[[1L]])
      c("local_curvature", "lme4_profiled_theta_curvature_failed")
    else c("none", "none")
  likelihood <- stats::logLik(fit)
  estimator <- list(
    Family = if (isTRUE(reml)) "lme4_reml" else "lme4_ml",
    Backend = "lme4", BackendVersion = as.character(packageVersion("lme4")),
    Method = if (isTRUE(reml)) "REML" else "ML",
    FormulaCanonical = paste(deparse(formula, width.cutoff = 500L), collapse = " "),
    RowContract = "draft83d2b0_retained_rows_exact",
    RandomEffects = "independent_scalar_random_intercepts",
    ControlHash = mfrmr_gta_hash(control), Interval = "none"
  )
  payload <- list(
    Contract = "gtheory_ademp_lme4_adapter_draft83d2b1_v1",
    ScenarioId = generation$ScenarioId, GeneratorHash = generation$GeneratorHash,
    PreFitHash = prefit$ResultHash,
    MethodId = estimator$Family, Backend = "lme4",
    EstimatorIdentity = estimator, Components = estimates,
    Diagnostics = diagnostics, LocalCurvature = curvature,
    Likelihood = list(Value = as.numeric(likelihood),
                      DegreesFreedom = as.integer(attr(likelihood, "df")),
                      Observations = as.integer(stats::nobs(fit))),
    LikelihoodInformationState =
      "backend_profiled_theta_curvature_not_full_expected_information",
    RegularInterior = regular, PointGatePassed = passed, IntervalState = "none"
  )
  list(
    FitReturned = TRUE, OptimizerConverged = optimizer,
    ComponentVectorFinite = finite, EstimationGatePassed = passed,
    RegularInterior = regular, Curvature = curvature,
    BoundaryComponentCount = sum(zero), FailureStage = failure[[1L]],
    FailureCode = failure[[2L]],
    ConditionClass = if (passed) "none" else "mfrmr_gtd4_lme4_gate_failure",
    Message = if (passed) "" else paste(
      c(diagnostics$Warnings, diagnostics$Messages,
        diagnostics$ConvergenceMessages), collapse = " | "
    ),
    RuntimeSeconds = proc.time()[["elapsed"]] - started,
    PointResultHash = mfrmr_gta_hash(payload), Detail = payload
  )
}

mfrmr_gtd4_fit_glmmtmb <- function(generation, prefit, reml,
                                    rank_tolerance = 1e-8,
                                    boundary_tolerance = 1e-8) {
  if (!requireNamespace("glmmTMB", quietly = TRUE) ||
      !requireNamespace("TMB", quietly = TRUE)) {
    stop("Draft.83d2b1 glmmTMB adapter requires `glmmTMB` and `TMB`.",
         call. = FALSE)
  }
  started <- proc.time()[["elapsed"]]
  formula <- stats::as.formula(generation$Spec$FormulaCanonical)
  family <- stats::gaussian(link = "identity")
  control <- glmmTMB::glmmTMBControl()
  warnings <- character()
  messages <- character()
  fit <- withCallingHandlers(
    glmmTMB::glmmTMB(
      formula = formula, data = prefit$StructuralRankAudit$PreparedData$Data,
      family = family, ziformula = ~ 0, dispformula = ~ 1,
      REML = isTRUE(reml), control = control
    ),
    warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    },
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  )
  estimates <- mfrmr_gtm_components(fit, generation$Spec)
  zero <- estimates <= boundary_tolerance
  diagnostics <- mfrmr_gtm_diagnostics(fit, warnings, messages, zero)
  covariance <- fit$sdr$cov.fixed
  parameter_count <- if (is.matrix(covariance)) nrow(covariance) else 0L
  curvature <- mfrmr_gtd4_curvature(
    covariance, parameter_count, rank_tolerance, matrix_is_covariance = TRUE
  )
  finite <- all(is.finite(estimates))
  optimizer <- diagnostics$OptimizerCode[[1L]] == 0L &&
    isTRUE(diagnostics$PositiveDefiniteHessian[[1L]])
  regular <- finite && !any(zero)
  passed <- optimizer && finite && regular && curvature$CurvatureRankFull[[1L]]
  failure <- if (!optimizer) c("optimizer", "glmmtmb_optimizer_or_hessian_failed")
    else if (!finite) c("component_extraction", "nonfinite_component_vector")
    else if (!regular) c("regularity", "glmmtmb_boundary_tolerance_reached")
    else if (!curvature$CurvatureRankFull[[1L]])
      c("local_curvature", "glmmtmb_joint_curvature_failed")
    else c("none", "none")
  likelihood <- stats::logLik(fit)
  estimator <- list(
    Family = if (isTRUE(reml)) "glmmTMB_reml" else "glmmTMB_ml",
    Backend = "glmmTMB",
    BackendVersion = as.character(packageVersion("glmmTMB")),
    TMBVersion = as.character(packageVersion("TMB")),
    Method = if (isTRUE(reml)) "REML" else "ML",
    FormulaCanonical = paste(deparse(formula, width.cutoff = 500L), collapse = " "),
    FamilyName = family$family, Link = family$link,
    ZeroInflationFormula = "~0", DispersionFormula = "~1",
    RowContract = "draft83d2b0_retained_rows_exact",
    RandomEffects = "independent_scalar_random_intercepts",
    Control = mfrmr_gtm_control_identity(control),
    BackendFunctionHashes = mfrmr_gtm_backend_function_hashes(),
    Interval = "none"
  )
  payload <- list(
    Contract = "gtheory_ademp_glmmtmb_adapter_draft83d2b1_v1",
    ScenarioId = generation$ScenarioId, GeneratorHash = generation$GeneratorHash,
    PreFitHash = prefit$ResultHash,
    MethodId = estimator$Family, Backend = "glmmTMB",
    EstimatorIdentity = estimator, Components = estimates,
    Diagnostics = diagnostics, LocalCurvature = curvature,
    Likelihood = list(Value = as.numeric(likelihood),
                      DegreesFreedom = as.integer(attr(likelihood, "df")),
                      Observations = as.integer(stats::nobs(fit))),
    LikelihoodInformationState =
      "backend_joint_curvature_not_full_expected_information",
    RegularInterior = regular, PointGatePassed = passed, IntervalState = "none"
  )
  list(
    FitReturned = TRUE, OptimizerConverged = optimizer,
    ComponentVectorFinite = finite, EstimationGatePassed = passed,
    RegularInterior = regular, Curvature = curvature,
    BoundaryComponentCount = sum(zero), FailureStage = failure[[1L]],
    FailureCode = failure[[2L]],
    ConditionClass = if (passed) "none" else "mfrmr_gtd4_glmmtmb_gate_failure",
    Message = if (passed) "" else paste(
      c(diagnostics$Warnings, diagnostics$Messages,
        diagnostics$OptimizerMessage), collapse = " | "
    ),
    RuntimeSeconds = proc.time()[["elapsed"]] - started,
    PointResultHash = mfrmr_gta_hash(payload), Detail = payload
  )
}

mfrmr_gtd4_failure_detail <- function(stage, code, condition_class, message) {
  list(
    FitReturned = FALSE, OptimizerConverged = FALSE,
    ComponentVectorFinite = FALSE, EstimationGatePassed = FALSE,
    RegularInterior = FALSE, Curvature = data.frame(
      CurvatureState = "not_evaluated", CurvatureParameterCount = 0L,
      CurvatureRank = 0L, CurvatureRankFull = FALSE,
      MinimumCurvatureEigenvalue = NA_real_, stringsAsFactors = FALSE
    ),
    BoundaryComponentCount = 0L, FailureStage = stage, FailureCode = code,
    ConditionClass = condition_class, Message = message,
    RuntimeSeconds = 0, PointResultHash = NA_character_, Detail = NULL
  )
}

mfrmr_gtd4_execute_one <- function(manifest_row, generation, prefit,
                                    rank_tolerance = 1e-8,
                                    boundary_tolerance = 1e-8,
                                    singular_tolerance = 1e-4) {
  if (!is.data.frame(manifest_row) || nrow(manifest_row) != 1L ||
      !inherits(generation, "mfrmr_gtd2_generation") ||
      !inherits(prefit, "mfrmr_gtd3_prefit")) {
    stop("Draft.83d2b1 requires one manifest row and its generation/prefit.",
         call. = FALSE)
  }
  if (!identical(manifest_row$ScenarioId[[1L]], generation$ScenarioId) ||
      !identical(generation$ScenarioId, prefit$ScenarioId) ||
      !identical(manifest_row$GeneratorHash[[1L]], generation$GeneratorHash) ||
      !identical(manifest_row$PreFitState[[1L]], prefit$PreFitState)) {
    stop("Manifest, generation, and pre-fit identities differ.", call. = FALSE)
  }
  eligible <- isTRUE(prefit$PreFitEligible)
  attempted <- eligible
  if (!eligible) {
    detail <- mfrmr_gtd4_failure_detail(
      "pre_fit", prefit$PreFitState, "mfrmr_gtd4_prefit_block",
      "Backend call prohibited by Draft.83d2b0."
    )
    attempted <- FALSE
  } else {
    method <- manifest_row$MethodId[[1L]]
    detail <- tryCatch(
      if (identical(method, "balanced_mom")) {
        mfrmr_gtd4_fit_mom(generation, prefit)
      } else if (method %in% c("lme4_ml", "lme4_reml")) {
        mfrmr_gtd4_fit_lme4(
          generation, prefit, reml = identical(method, "lme4_reml"),
          rank_tolerance = rank_tolerance,
          boundary_tolerance = boundary_tolerance,
          singular_tolerance = singular_tolerance
        )
      } else if (method %in% c("glmmTMB_ml", "glmmTMB_reml")) {
        mfrmr_gtd4_fit_glmmtmb(
          generation, prefit, reml = identical(method, "glmmTMB_reml"),
          rank_tolerance = rank_tolerance,
          boundary_tolerance = boundary_tolerance
        )
      } else {
        stop("Unregistered Draft.83d2b1 method: ", method, ".", call. = FALSE)
      },
      error = function(error) mfrmr_gtd4_failure_detail(
        "backend_fit", "backend_call_failed", class(error)[[1L]],
        conditionMessage(error)
      )
    )
  }
  point_hash <- detail$PointResultHash
  message_digest <- if (nzchar(detail$Message)) {
    mfrmr_gta_hash(detail$Message)
  } else "none"
  row <- data.frame(
    manifest_row[c(
      "ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId",
      "Backend", "RegistryHash"
    )],
    Generated = TRUE, PreFitEligible = eligible,
    FitAttempted = attempted, FitReturned = detail$FitReturned,
    OptimizerConverged = detail$OptimizerConverged,
    ComponentVectorFinite = detail$ComponentVectorFinite,
    EstimationGatePassed = detail$EstimationGatePassed,
    FailureStage = detail$FailureStage, FailureCode = detail$FailureCode,
    FitAttemptAuthorized = eligible, AtomicResultRecorded = TRUE,
    GeneratorHash = generation$GeneratorHash, PreFitHash = prefit$ResultHash,
    StructuralRankHash = prefit$ScalableStructuralRankHash,
    RegularInterior = detail$RegularInterior,
    CurvatureState = detail$Curvature$CurvatureState[[1L]],
    CurvatureRankFull = detail$Curvature$CurvatureRankFull[[1L]],
    BoundaryComponentCount = as.integer(detail$BoundaryComponentCount),
    ConditionClass = detail$ConditionClass, MessageDigest = message_digest,
    PointResultHash = if (is.na(point_hash)) "none" else point_hash,
    RuntimeSeconds = as.numeric(detail$RuntimeSeconds),
    stringsAsFactors = FALSE
  )
  hash_payload <- row
  hash_payload$RuntimeSeconds <- NULL
  row$AtomicResultHash <- mfrmr_gta_hash(hash_payload)
  list(Row = row, Detail = detail$Detail)
}

mfrmr_gtd4_execute_registry <- function(
    prefit_registry = mfrmr_gtd3_prefit_registry(),
    rank_tolerance = 1e-8, boundary_tolerance = 1e-8,
    singular_tolerance = 1e-4, progress = interactive()) {
  mfrmr_gtd4_require_primitives()
  if (!inherits(prefit_registry, "mfrmr_gtd3_prefit_registry")) {
    stop("`prefit_registry` must be a Draft.83d2b0 registry result.",
         call. = FALSE)
  }
  registry <- mfrmr_gtd_registry()
  if (!identical(registry$RegistryHash, prefit_registry$RegistryHash)) {
    stop("Draft.83d1 and Draft.83d2b0 registry identities differ.",
         call. = FALSE)
  }
  plan <- prefit_registry$ManifestPlan
  generations <- lapply(names(prefit_registry$PreFitResults), function(id) {
    mfrmr_gtd2_generate(registry, id, replicate = 1L)
  })
  names(generations) <- names(prefit_registry$PreFitResults)
  outputs <- vector("list", nrow(plan))
  for (index in seq_len(nrow(plan))) {
    scenario_id <- plan$ScenarioId[[index]]
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] %s / %s", index, nrow(plan), scenario_id,
                      plan$MethodId[[index]]))
    }
    outputs[[index]] <- mfrmr_gtd4_execute_one(
      plan[index, , drop = FALSE],
      generations[[scenario_id]],
      prefit_registry$PreFitResults[[scenario_id]],
      rank_tolerance = rank_tolerance,
      boundary_tolerance = boundary_tolerance,
      singular_tolerance = singular_tolerance
    )
  }
  rows <- do.call(rbind, lapply(outputs, `[[`, "Row"))
  row.names(rows) <- NULL
  dataset_schema <- c(
    "ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId", "Backend",
    "Generated", "PreFitEligible", "FitAttempted", "FitReturned",
    "OptimizerConverged", "ComponentVectorFinite", "EstimationGatePassed",
    "FailureStage", "FailureCode", "RegistryHash"
  )
  denominator <- mfrmr_gtd_denominator_summary(
    registry,
    plan[, c("ScenarioId", "Replicate", "DatasetId", "Seed", "MethodId",
             "Backend", "RegistryHash")],
    rows[, dataset_schema]
  )
  failures <- rows[rows$FailureStage != "none", c(
    "ScenarioId", "Replicate", "DatasetId", "MethodId", "Backend",
    "FailureStage", "FailureCode", "ConditionClass", "MessageDigest",
    "RegistryHash", "AtomicResultHash"
  ), drop = FALSE]
  expected_not_ready <- denominator$ScenarioId %in%
    registry$Scenarios$ScenarioId[
      registry$Scenarios$ExpectedDesignState ==
        "must_fail_ready_gate"
    ]
  identity <- list(
    Contract = "gtheory_ademp_atomic_execution_draft83d2b1_v1",
    RegistryHash = prefit_registry$RegistryHash,
    PreFitPlanHash = prefit_registry$PreFitPlanHash,
    RankTolerance = rank_tolerance,
    BoundaryTolerance = boundary_tolerance,
    SingularTolerance = singular_tolerance,
    FunctionHashes = mfrmr_gtd4_function_hashes(),
    AtomicRows = rows[, setdiff(names(rows), "RuntimeSeconds"), drop = FALSE],
    FailureLedger = failures,
    DenominatorSummary = denominator
  )
  structure(c(identity, list(
    ExecutionHash = mfrmr_gta_hash(identity), Details = lapply(outputs, `[[`, "Detail"),
    RuntimeSeconds = sum(rows$RuntimeSeconds), PlannedFitUnits = nrow(rows),
    FitAttemptCount = sum(rows$FitAttempted), FitReturnCount = sum(rows$FitReturned),
    PointGatePassCount = sum(rows$EstimationGatePassed),
    TypedFailureCount = nrow(failures),
    AtomicCompletionPassed = nrow(rows) == nrow(plan) &&
      all(denominator$ExactAccountingPassed),
    ZeroFalseReadyPassed = all(
      denominator$FalseReadyCount[expected_not_ready] == 0L
    ),
    RecoveryEvidenceReady = FALSE, InferenceReady = FALSE,
    CoefficientEligible = FALSE, DecisionReady = FALSE
  )), class = "mfrmr_gtd4_execution")
}
