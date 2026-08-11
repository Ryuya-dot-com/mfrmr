# mfrmr 0.2.3 bounded GPCM low-basin quadrature P1b audit
#
# P1b refits the P1a-qualified low-variance local basin independently at
# q=31/61/91 and reevaluates every returned vector at held-out q=121. The P0b
# default/high-variance basin is rerun only as a diagnostic lane and is never
# admitted retrospectively to the comparison denominator. Finite-node
# agreement is not a continuous-normal integration certificate.

mfrmr_gqi_p1b_specification <- "0.2.3-draft.1"
mfrmr_gqi_p1b_contract <- "mfrmr_gpcm_low_basin_quadrature_p1b_v1"
mfrmr_gqi_p1b_dependency_contract <-
  "mfrmr_gpcm_population_variance_profile_p1a_v1"
mfrmr_gqi_p1b_dependency_sha256 <-
  "dc085c99f068ee5854ae67899c265b5f6a9e0fc7634ef31c064bdb0dc945064b"
mfrmr_gqi_p1b_quad_points <- c(31L, 61L, 91L)
mfrmr_gqi_p1b_common_quad_points <- 121L
mfrmr_gqi_p1b_lanes <- c("qualified_low", "diagnostic_default")
mfrmr_gqi_p1b_start_ids <- c(
  qualified_low = "variance_low",
  diagnostic_default = "default"
)
mfrmr_gqi_p1b_derivative_step <- 1e-5

mfrmr_gqi_p1b_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gqi_p1b_abs_difference <- function(left, right) {
  left <- suppressWarnings(as.numeric(left)[1L])
  right <- suppressWarnings(as.numeric(right)[1L])
  if (is.finite(left) && is.finite(right)) abs(left - right) else NA_real_
}

mfrmr_gqi_p1b_require_sources <- function() {
  target <- environment(mfrmr_gqi_p1b_require_sources)
  required <- c(
    "mfrmr_gvp_p1a_contract",
    "mfrmr_run_gpcm_endpoint_solution_stability_p0b",
    "mfrmr_num_fit_context", "mfrmr_num_central_gradient",
    "mfrmr_gss_get", "mfrmr_gss_hash_vector",
    "mfrmr_gss_dimension_audit", "mfrmr_gss_semantic_vector",
    "mfrmr_gss_compare_signatures"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = target,
    inherits = TRUE
  )
  mfrmr_gqi_p1b_assert(
    all(available) && identical(
      get("mfrmr_gvp_p1a_contract", envir = target, inherits = TRUE),
      mfrmr_gqi_p1b_dependency_contract
    ),
    paste0(
      "Source the numerical P0, endpoint P0b, population-variance P1a, ",
      "and their dependencies before P1b."
    )
  )
  invisible(TRUE)
}

mfrmr_gqi_p1b_plan <- function() {
  plan <- expand.grid(
    ScenarioId = c(
      "EXT5-P-HI", "EXT5-P-LO", "EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO"
    ),
    Lane = mfrmr_gqi_p1b_lanes,
    QuadPoints = mfrmr_gqi_p1b_quad_points,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  plan$ScenarioOrder <- match(plan$ScenarioId, unique(plan$ScenarioId))
  plan$LaneOrder <- match(plan$Lane, mfrmr_gqi_p1b_lanes)
  plan$QuadOrder <- match(plan$QuadPoints, mfrmr_gqi_p1b_quad_points)
  plan <- plan[order(
    plan$ScenarioOrder,
    plan$LaneOrder,
    plan$QuadOrder
  ), , drop = FALSE]
  rownames(plan) <- NULL
  plan$StartId <- unname(mfrmr_gqi_p1b_start_ids[plan$Lane])
  plan$SourceLaneEligible <- plan$Lane == "qualified_low"
  plan$CommonEvaluationQuadrature <- mfrmr_gqi_p1b_common_quad_points
  plan$Model <- "GPCM"
  plan$Method <- "MML"
  plan$Identification <- "free_population"
  plan$SelectionAuthorized <- FALSE
  plan$ConfirmationAuthorized <- FALSE
  plan
}

mfrmr_gqi_p1b_context <- function(fit, quad_points) {
  quad_points <- suppressWarnings(as.integer(quad_points)[1L])
  mfrmr_gqi_p1b_assert(
    is.finite(quad_points) && quad_points > 0L,
    "P1b quadrature points must be one positive integer."
  )
  base <- mfrmr_num_fit_context(fit)
  config <- base$config
  config$estimation_control$quad_points <- quad_points
  quad <- mfrmr_gss_get("gauss_hermite_normal")(quad_points)
  idx <- base$idx
  sizes <- base$sizes
  fn <- function(par) {
    mfrmr_gss_get("mfrm_loglik_mml")(
      par,
      idx,
      config,
      sizes,
      quad
    )
  }
  gr <- function(par) {
    mfrmr_gss_get("mfrm_grad_mml")(
      par,
      idx,
      config,
      sizes,
      quad
    )
  }
  list(
    config = config,
    sizes = sizes,
    slices = base$slices,
    coordinates = base$coordinates,
    idx = idx,
    quad = quad,
    fn = fn,
    gr = gr,
    quad_points = quad_points
  )
}

mfrmr_gqi_p1b_posterior <- function(fit, context, par) {
  params <- mfrmr_gss_get("expand_params")(
    as.numeric(par),
    context$sizes,
    context$config
  )
  value <- mfrmr_gss_get("compute_person_eap")(
    context$idx,
    context$config,
    params,
    context$quad
  )
  ids <- as.character(fit$facets$person$Person)
  mfrmr_gqi_p1b_assert(
    nrow(value) == length(ids) &&
      all(is.finite(value$Estimate)) &&
      all(is.finite(value$SD)) && all(value$SD >= 0),
    "P1b posterior evaluation did not return one finite row per Person."
  )
  data.frame(
    Person = ids,
    EAP = as.numeric(value$Estimate),
    PosteriorSD = as.numeric(value$SD),
    stringsAsFactors = FALSE
  )
}

mfrmr_gqi_p1b_run_candidate <- function(
    scenario_id,
    lane,
    start_id,
    source_par,
    fit,
    native_context,
    common_context,
    maxit,
    reltol) {
  warnings <- character(0)
  error_text <- ""
  elapsed <- NA_real_
  opt <- NULL
  started <- proc.time()[["elapsed"]]
  opt <- tryCatch(
    withCallingHandlers(
      mfrmr_gss_get("run_mfrm_direct_optimization")(
        start = as.numeric(source_par),
        method = "MML",
        idx = native_context$idx,
        config = native_context$config,
        sizes = native_context$sizes,
        quad_points = native_context$quad_points,
        maxit = as.integer(maxit),
        reltol = as.numeric(reltol),
        quad = native_context$quad,
        optimizer = "L-BFGS-B",
        suppress_convergence_warning = TRUE
      ),
      warning = function(condition) {
        warnings <<- c(warnings, conditionMessage(condition))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(condition) {
      error_text <<- conditionMessage(condition)
      NULL
    }
  )
  elapsed <- proc.time()[["elapsed"]] - started
  list(
    scenario_id = scenario_id,
    lane = lane,
    start_id = start_id,
    source_par = as.numeric(source_par),
    opt = opt,
    warnings = unique(warnings),
    error = error_text,
    elapsed = elapsed,
    fit = fit,
    native_context = native_context,
    common_context = common_context
  )
}

mfrmr_gqi_p1b_candidate <- function(run) {
  opt <- run$opt
  native <- run$native_context
  common <- run$common_context
  par <- if (!is.null(opt)) as.numeric(opt$par) else numeric(0)
  returned <- length(par) == nrow(native$coordinates) && all(is.finite(par))
  native_objective <- common_objective <- NA_real_
  native_gradient <- common_gradient <- rep(
    NA_real_,
    nrow(native$coordinates)
  )
  native_numeric <- common_numeric <- rep(
    NA_real_,
    nrow(native$coordinates)
  )
  native_posterior <- common_posterior <- data.frame()
  semantic <- data.frame()
  dimension <- list(
    identity = FALSE,
    values = c(
      returned_vector = NA_integer_, parameter_sizes = NA_integer_,
      canonical_coordinate_table = NA_integer_,
      mml_optimizer_map = NA_integer_,
      observed_pattern_score_audit = NA_integer_
    )
  )
  posterior_error <- ""
  if (returned) {
    native_objective <- tryCatch(
      suppressWarnings(as.numeric(native$fn(par))[1L]),
      error = function(condition) NA_real_
    )
    common_objective <- tryCatch(
      suppressWarnings(as.numeric(common$fn(par))[1L]),
      error = function(condition) NA_real_
    )
    native_gradient <- tryCatch(
      suppressWarnings(as.numeric(native$gr(par))),
      error = function(condition) rep(NA_real_, length(par))
    )
    common_gradient <- tryCatch(
      suppressWarnings(as.numeric(common$gr(par))),
      error = function(condition) rep(NA_real_, length(par))
    )
    native_numeric <- tryCatch(
      suppressWarnings(mfrmr_num_central_gradient(
        native$fn,
        par,
        mfrmr_gqi_p1b_derivative_step
      )),
      error = function(condition) rep(NA_real_, length(par))
    )
    common_numeric <- tryCatch(
      suppressWarnings(mfrmr_num_central_gradient(
        common$fn,
        par,
        mfrmr_gqi_p1b_derivative_step
      )),
      error = function(condition) rep(NA_real_, length(par))
    )
    dimension <- mfrmr_gss_dimension_audit(run$fit, native, par)
    semantic <- tryCatch(
      mfrmr_gss_semantic_vector(native, par),
      error = function(condition) data.frame()
    )
    posterior <- tryCatch(
      list(
        native = mfrmr_gqi_p1b_posterior(run$fit, native, par),
        common = mfrmr_gqi_p1b_posterior(run$fit, common, par)
      ),
      error = function(condition) {
        posterior_error <<- conditionMessage(condition)
        NULL
      }
    )
    if (!is.null(posterior)) {
      native_posterior <- posterior$native
      common_posterior <- posterior$common
    }
  }
  native_complete <- returned && is.finite(native_objective) &&
    all(is.finite(native_gradient)) && all(is.finite(native_numeric))
  common_complete <- returned && is.finite(common_objective) &&
    all(is.finite(common_gradient)) && all(is.finite(common_numeric))
  posterior_complete <- nrow(native_posterior) > 0L &&
    identical(native_posterior$Person, common_posterior$Person)
  diagnostics <- if (!is.null(opt)) opt$optimizer_diagnostics else list()
  severity <- as.character(
    if (length(diagnostics$ConvergenceSeverity)) {
      diagnostics$ConvergenceSeverity
    } else "fail"
  )[1L]
  source_lane_eligible <- identical(run$lane, "qualified_low")
  comparison_eligible <- source_lane_eligible &&
    identical(severity, "pass") && native_complete && common_complete &&
    posterior_complete && isTRUE(dimension$identity)
  sigma2 <- if (nrow(semantic) > 0L) {
    value <- semantic$Value[semantic$ParameterClass == "population_sigma2"]
    if (length(value) == 1L) as.numeric(value) else NA_real_
  } else NA_real_
  p01_native <- if (posterior_complete) {
    native_posterior[native_posterior$Person == "P01", , drop = FALSE]
  } else data.frame()
  p01_common <- if (posterior_complete) {
    common_posterior[common_posterior$Person == "P01", , drop = FALSE]
  } else data.frame()
  row <- data.frame(
    ScenarioId = as.character(run$scenario_id),
    Lane = as.character(run$lane),
    StartId = as.character(run$start_id),
    SourceLaneEligible = source_lane_eligible,
    SourceVectorSHA256 = mfrmr_gss_hash_vector(run$source_par),
    QuadPoints = as.integer(native$quad_points),
    CommonEvaluationQuadrature = as.integer(common$quad_points),
    FitReturned = returned,
    ReturnedVectorSHA256 = if (returned) {
      mfrmr_gss_hash_vector(par)
    } else NA_character_,
    NativeObjective = native_objective,
    OptimizerNativeObjectiveAbsDifference = if (
      returned && is.finite(opt$value) && is.finite(native_objective)
    ) abs(as.numeric(opt$value) - native_objective) else NA_real_,
    CommonDenseObjective = common_objective,
    NativeGradientMaxAbs = if (native_complete) {
      max(abs(native_gradient))
    } else NA_real_,
    CommonDenseGradientMaxAbs = if (common_complete) {
      max(abs(common_gradient))
    } else NA_real_,
    NativeAnalyticNumericGradientMaxAbsDifference = if (native_complete) {
      max(abs(native_gradient - native_numeric))
    } else NA_real_,
    CommonDenseAnalyticNumericGradientMaxAbsDifference = if (
      common_complete
    ) max(abs(common_gradient - common_numeric)) else NA_real_,
    IndependentDerivativeStep = mfrmr_gqi_p1b_derivative_step,
    FreeDimensionReturned = if (returned) length(par) else NA_integer_,
    FreeDimensionSizes = as.integer(dimension$values[["parameter_sizes"]]),
    FreeDimensionCoordinates = as.integer(
      dimension$values[["canonical_coordinate_table"]]
    ),
    FreeDimensionOptimizerMap = as.integer(
      dimension$values[["mml_optimizer_map"]]
    ),
    FreeDimensionScoreAudit = as.integer(
      dimension$values[["observed_pattern_score_audit"]]
    ),
    DimensionIdentity = isTRUE(dimension$identity),
    NativeEvaluationComplete = native_complete,
    CommonDenseEvaluationComplete = common_complete,
    PosteriorEvaluationComplete = posterior_complete,
    PopulationSigma2 = sigma2,
    NativeP01EAP = if (nrow(p01_native) == 1L) p01_native$EAP else NA_real_,
    NativeP01PosteriorSD = if (
      nrow(p01_native) == 1L
    ) p01_native$PosteriorSD else NA_real_,
    CommonP01EAP = if (nrow(p01_common) == 1L) p01_common$EAP else NA_real_,
    CommonP01PosteriorSD = if (
      nrow(p01_common) == 1L
    ) p01_common$PosteriorSD else NA_real_,
    ConvergenceCode = suppressWarnings(as.integer(
      if (length(diagnostics$ConvergenceCode)) {
        diagnostics$ConvergenceCode
      } else if (!is.null(opt)) opt$convergence else NA_integer_
    )[1L]),
    ConvergenceStatus = as.character(
      if (length(diagnostics$ConvergenceStatus)) {
        diagnostics$ConvergenceStatus
      } else "not_returned"
    )[1L],
    ConvergenceReason = as.character(
      if (length(diagnostics$ConvergenceReason)) {
        diagnostics$ConvergenceReason
      } else "not_returned"
    )[1L],
    ConvergenceSeverity = severity,
    ExistingNativeOptimizerPass = identical(severity, "pass"),
    P1BComparisonEligible = comparison_eligible,
    P1BStabilityEligible = FALSE,
    P1BEligibilityReason = if (comparison_eligible) {
      "qualified_low_native_pass_common_q121_complete_tolerance_not_frozen"
    } else if (!source_lane_eligible) {
      "diagnostic_default_lane_prespecified_ineligible"
    } else {
      "qualified_low_lane_numerical_or_posterior_evaluation_incomplete"
    },
    BoundaryStatus = "not_evaluated_p1b_integration_only",
    IntegrationStatus = "finite_q_ladder_no_continuous_integral_certificate",
    ToleranceStatus = "not_frozen",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    ElapsedSeconds = as.numeric(run$elapsed),
    WarningCount = length(run$warnings),
    WarningText = paste(run$warnings, collapse = " | "),
    ErrorText = paste(
      c(run$error, posterior_error)[nzchar(c(run$error, posterior_error))],
      collapse = " | "
    ),
    stringsAsFactors = FALSE
  )
  list(
    row = row,
    opt = opt,
    semantic = semantic,
    native_posterior = native_posterior,
    common_posterior = common_posterior,
    native_gradient = native_gradient,
    common_gradient = common_gradient
  )
}

mfrmr_gqi_p1b_pairwise <- function(candidates) {
  rows <- list()
  semantic_rows <- list()
  row_index <- semantic_index <- 1L
  scenarios <- unique(vapply(candidates, function(value) {
    as.character(value$row$ScenarioId)
  }, character(1L)))
  for (scenario_id in scenarios) {
    keys <- names(candidates)[vapply(candidates, function(value) {
      identical(as.character(value$row$ScenarioId), scenario_id) &&
        identical(as.character(value$row$Lane), "qualified_low")
    }, logical(1L))]
    keys <- keys[order(vapply(candidates[keys], function(value) {
      as.integer(value$row$QuadPoints)
    }, integer(1L)))]
    pairs <- utils::combn(keys, 2L, simplify = FALSE)
    for (pair in pairs) {
      left <- candidates[[pair[1L]]]
      right <- candidates[[pair[2L]]]
      left_semantic <- left$semantic
      right_semantic <- right$semantic
      semantic_keys <- c(
        "ParameterClass", "SemanticKey", "CoordinateSystem", "Value"
      )
      semantic <- if (
        all(semantic_keys %in% names(left_semantic)) &&
          all(semantic_keys %in% names(right_semantic))
      ) {
        merge(
          left_semantic[, semantic_keys, drop = FALSE],
          right_semantic[, semantic_keys, drop = FALSE],
          by = c("ParameterClass", "SemanticKey", "CoordinateSystem"),
          suffixes = c("Left", "Right"),
          all = FALSE,
          sort = FALSE
        )
      } else {
        data.frame(
          ParameterClass = character(0), SemanticKey = character(0),
          CoordinateSystem = character(0), ValueLeft = numeric(0),
          ValueRight = numeric(0), stringsAsFactors = FALSE
        )
      }
      semantic$Difference <- semantic$ValueLeft - semantic$ValueRight
      semantic$AbsDifference <- abs(semantic$Difference)
      semantic$ScenarioId <- rep(scenario_id, nrow(semantic))
      semantic$LeftQuadPoints <- rep(
        as.integer(left$row$QuadPoints), nrow(semantic)
      )
      semantic$RightQuadPoints <- rep(
        as.integer(right$row$QuadPoints), nrow(semantic)
      )
      semantic$SelectionAuthorized <- rep(FALSE, nrow(semantic))
      semantic$ConfirmationAuthorized <- rep(FALSE, nrow(semantic))
      semantic_rows[[semantic_index]] <- semantic
      semantic_index <- semantic_index + 1L

      posterior_keys <- c("Person", "EAP", "PosteriorSD")
      posterior <- if (
        all(posterior_keys %in% names(left$common_posterior)) &&
          all(posterior_keys %in% names(right$common_posterior))
      ) {
        merge(
          left$common_posterior[, posterior_keys, drop = FALSE],
          right$common_posterior[, posterior_keys, drop = FALSE],
          by = "Person",
          suffixes = c("Left", "Right"),
          all = FALSE,
          sort = FALSE
        )
      } else {
        data.frame(
          Person = character(0), EAPLeft = numeric(0),
          PosteriorSDLeft = numeric(0), EAPRight = numeric(0),
          PosteriorSDRight = numeric(0), stringsAsFactors = FALSE
        )
      }
      eap_delta <- posterior$EAPLeft - posterior$EAPRight
      sd_delta <- posterior$PosteriorSDLeft - posterior$PosteriorSDRight
      class_max <- function(parameter_class) {
        selected <- if (identical(parameter_class, "additive")) {
          startsWith(semantic$ParameterClass, "facet:")
        } else {
          semantic$ParameterClass == parameter_class
        }
        value <- semantic$AbsDifference[selected]
        if (length(value) > 0L && all(is.finite(value))) max(value) else NA_real_
      }
      rows[[row_index]] <- data.frame(
        ScenarioId = scenario_id,
        LeftQuadPoints = as.integer(left$row$QuadPoints),
        RightQuadPoints = as.integer(right$row$QuadPoints),
        BothComparisonEligible = isTRUE(left$row$P1BComparisonEligible) &&
          isTRUE(right$row$P1BComparisonEligible),
        CommonDenseObjectiveAbsDifference = mfrmr_gqi_p1b_abs_difference(
          left$row$CommonDenseObjective,
          right$row$CommonDenseObjective
        ),
        AdditiveMaxAbsDifference = class_max("additive"),
        StepMaxAbsDifference = class_max("step"),
        LogSlopeMaxAbsDifference = class_max("log_slope"),
        SlopeMaxAbsDifference = class_max("slope"),
        PopulationBetaMaxAbsDifference = class_max("population_beta"),
        PopulationLogSigma2MaxAbsDifference = class_max(
          "population_log_sigma2"
        ),
        PopulationSigma2MaxAbsDifference = class_max("population_sigma2"),
        CommonPosteriorPersons = nrow(posterior),
        CommonEAPRMSE = if (length(eap_delta)) {
          sqrt(mean(eap_delta^2))
        } else NA_real_,
        CommonEAPMaxAbsDifference = if (length(eap_delta)) {
          max(abs(eap_delta))
        } else NA_real_,
        CommonPosteriorSDRMSE = if (length(sd_delta)) {
          sqrt(mean(sd_delta^2))
        } else NA_real_,
        CommonPosteriorSDMaxAbsDifference = if (length(sd_delta)) {
          max(abs(sd_delta))
        } else NA_real_,
        ToleranceStatus = "not_frozen_calibration_only",
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
      row_index <- row_index + 1L
    }
  }
  list(
    summary = do.call(rbind, rows),
    semantic = do.call(rbind, semantic_rows)
  )
}

mfrmr_gqi_p1b_reflection <- function(candidates) {
  scenario_pairs <- list(
    exact = c("EXT5-P-HI", "EXT5-P-LO"),
    near = c("EXT5-P-NEAR-HI", "EXT5-P-NEAR-LO")
  )
  rows <- list()
  index <- 1L
  for (pair_name in names(scenario_pairs)) {
    scenarios <- scenario_pairs[[pair_name]]
    for (lane in mfrmr_gqi_p1b_lanes) {
      for (q in mfrmr_gqi_p1b_quad_points) {
        key <- function(scenario) paste(scenario, lane, q, sep = "::")
        high <- candidates[[key(scenarios[1L])]]
        low <- candidates[[key(scenarios[2L])]]
        posterior_keys <- c("Person", "EAP", "PosteriorSD")
        posterior <- if (
          all(posterior_keys %in% names(high$common_posterior)) &&
            all(posterior_keys %in% names(low$common_posterior))
        ) {
          merge(
            high$common_posterior[, posterior_keys, drop = FALSE],
            low$common_posterior[, posterior_keys, drop = FALSE],
            by = "Person",
            suffixes = c("High", "Low"),
            all = FALSE,
            sort = FALSE
          )
        } else {
          data.frame(
            Person = character(0), EAPHigh = numeric(0),
            PosteriorSDHigh = numeric(0), EAPLow = numeric(0),
            PosteriorSDLow = numeric(0), stringsAsFactors = FALSE
          )
        }
        eap_sum <- posterior$EAPHigh + posterior$EAPLow
        sd_delta <- posterior$PosteriorSDHigh - posterior$PosteriorSDLow
        rows[[index]] <- data.frame(
          Pair = pair_name,
          HighScenarioId = scenarios[1L],
          LowScenarioId = scenarios[2L],
          Lane = lane,
          QuadPoints = q,
          BothComparisonEligible = isTRUE(high$row$P1BComparisonEligible) &&
            isTRUE(low$row$P1BComparisonEligible),
          CommonDenseObjectiveAbsDifference = mfrmr_gqi_p1b_abs_difference(
            high$row$CommonDenseObjective,
            low$row$CommonDenseObjective
          ),
          PopulationSigma2AbsDifference = mfrmr_gqi_p1b_abs_difference(
            high$row$PopulationSigma2,
            low$row$PopulationSigma2
          ),
          CommonPersons = nrow(posterior),
          EAPSignReflectionRMSE = if (length(eap_sum)) {
            sqrt(mean(eap_sum^2))
          } else NA_real_,
          EAPSignReflectionMaxAbs = if (length(eap_sum)) {
            max(abs(eap_sum))
          } else NA_real_,
          PosteriorSDReflectionRMSE = if (length(sd_delta)) {
            sqrt(mean(sd_delta^2))
          } else NA_real_,
          PosteriorSDReflectionMaxAbs = if (length(sd_delta)) {
            max(abs(sd_delta))
          } else NA_real_,
          ReflectionToleranceStatus = "not_frozen_calibration_only",
          SelectionAuthorized = FALSE,
          ConfirmationAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
        index <- index + 1L
      }
    }
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_gqi_p1b_signature <- function(candidate_row) {
  mfrmr_gqi_p1b_assert(
    is.data.frame(candidate_row) && nrow(candidate_row) == 1L,
    "P1b signature requires one candidate row."
  )
  low_lane <- isTRUE(candidate_row$SourceLaneEligible)
  native_pass <- isTRUE(candidate_row$ExistingNativeOptimizerPass)
  common_complete <- isTRUE(candidate_row$CommonDenseEvaluationComplete)
  posterior_complete <- isTRUE(candidate_row$PosteriorEvaluationComplete)
  signature <- data.frame(
    Metric = c(
      "source_lane", "native_stationarity", "common_dense_evaluation",
      "population_boundary", "continuous_integration", "candidate_eap",
      "solution_selection", "hessian", "dff", "fit", "rank",
      "overall"
    ),
    State = c(
      if (low_lane) "qualified_local_candidate" else "diagnostic_only",
      if (native_pass) "pass" else "review",
      if (common_complete) "finite" else "fail",
      "not_evaluated", "not_evaluated",
      if (posterior_complete) "descriptive_only" else "not_evaluated",
      "not_evaluated", "not_evaluated", "not_evaluated",
      "not_evaluated", "not_evaluated",
      if (low_lane && native_pass && common_complete && posterior_complete) {
        "review"
      } else "blocked"
    ),
    Eligibility = c(
      if (low_lane) "p1b_comparison_candidate" else "not_selection_eligible",
      "existing_optimizer_rule_only", "finite_q121_evaluation_only",
      rep("not_selection_eligible", 9L)
    ),
    Reason = c(
      if (low_lane) {
        "p1a_qualified_low_variance_local_basin"
      } else "p1a_nonstationary_default_high_variance_basin",
      if (native_pass) {
        "native_q_optimizer_gradient_rule_pass"
      } else "native_q_optimizer_gradient_rule_not_passed",
      if (common_complete) {
        "held_out_q121_objective_and_gradient_finite"
      } else "held_out_q121_evaluation_failed",
      "population_boundary_not_adjudicated",
      "finite_q_ladder_is_not_continuous_integral_certificate",
      if (posterior_complete) {
        "common_q121_eap_and_posterior_sd_materialized_descriptively"
      } else "common_q121_posterior_not_available",
      "no_q_tolerance_or_solution_selection_rule_frozen",
      "source_solution_not_inference_ready",
      "scheduled_after_source_solution_adjudication",
      "scheduled_after_source_solution_adjudication",
      "scheduled_after_source_solution_adjudication",
      "p1b_integration_calibration_only"
    ),
    stringsAsFactors = FALSE
  )
  mfrmr_gqi_p1b_assert(
    !anyDuplicated(signature$Metric) &&
      all(nzchar(signature$State)) &&
      all(nzchar(signature$Eligibility)) &&
      all(nzchar(signature$Reason)),
    "P1b signatures require unique non-empty canonical fields."
  )
  signature
}

mfrmr_run_gpcm_low_basin_quadrature_p1b <- function(
    maxit = 800L,
    reltol = 1e-12,
    progress = FALSE) {
  mfrmr_gqi_p1b_require_sources()
  maxit <- suppressWarnings(as.integer(maxit)[1L])
  reltol <- suppressWarnings(as.numeric(reltol)[1L])
  mfrmr_gqi_p1b_assert(
    is.finite(maxit) && maxit > 0L && is.finite(reltol) && reltol > 0,
    "P1b requires finite positive optimization controls."
  )
  plan <- mfrmr_gqi_p1b_plan()
  p0b <- mfrmr_run_gpcm_endpoint_solution_stability_p0b(
    progress = progress
  )
  candidates <- list()
  rows <- list()
  row_index <- 1L
  for (scenario_id in names(p0b$scenario_results)) {
    source <- p0b$scenario_results[[scenario_id]]
    mfrmr_gqi_p1b_assert(
      !is.null(source$fit) && !is.null(source$context),
      paste0("P1b source scenario failed: ", scenario_id, ".")
    )
    contexts <- lapply(
      c(mfrmr_gqi_p1b_quad_points, mfrmr_gqi_p1b_common_quad_points),
      function(q) mfrmr_gqi_p1b_context(source$fit, q)
    )
    names(contexts) <- as.character(c(
      mfrmr_gqi_p1b_quad_points,
      mfrmr_gqi_p1b_common_quad_points
    ))
    for (lane in mfrmr_gqi_p1b_lanes) {
      start_id <- unname(mfrmr_gqi_p1b_start_ids[[lane]])
      source_object <- source$candidate_objects[[start_id]]
      mfrmr_gqi_p1b_assert(
        !is.null(source_object) && all(is.finite(source_object$par)),
        paste0("P1b source vector is missing: ", scenario_id, "/", lane)
      )
      for (q in mfrmr_gqi_p1b_quad_points) {
        if (isTRUE(progress)) {
          message("Quadrature P1b: ", scenario_id, " / ", lane, " / q=", q)
        }
        run <- mfrmr_gqi_p1b_run_candidate(
          scenario_id = scenario_id,
          lane = lane,
          start_id = start_id,
          source_par = source_object$par,
          fit = source$fit,
          native_context = contexts[[as.character(q)]],
          common_context = contexts[[as.character(
            mfrmr_gqi_p1b_common_quad_points
          )]],
          maxit = maxit,
          reltol = reltol
        )
        candidate <- mfrmr_gqi_p1b_candidate(run)
        key <- paste(scenario_id, lane, q, sep = "::")
        candidates[[key]] <- candidate
        rows[[row_index]] <- candidate$row
        row_index <- row_index + 1L
      }
    }
  }
  candidate_rows <- do.call(rbind, rows)
  rownames(candidate_rows) <- NULL
  candidate_rows$CommonDenseObjectiveRegret <- NA_real_
  for (scenario_id in unique(candidate_rows$ScenarioId)) {
    for (lane in unique(candidate_rows$Lane)) {
      selected <- candidate_rows$ScenarioId == scenario_id &
        candidate_rows$Lane == lane &
        is.finite(candidate_rows$CommonDenseObjective)
      if (any(selected)) {
        best <- min(candidate_rows$CommonDenseObjective[selected])
        candidate_rows$CommonDenseObjectiveRegret[selected] <-
          candidate_rows$CommonDenseObjective[selected] - best
      }
    }
  }
  pairwise <- mfrmr_gqi_p1b_pairwise(candidates)
  reflection <- mfrmr_gqi_p1b_reflection(candidates)
  signatures <- lapply(seq_len(nrow(candidate_rows)), function(index) {
    mfrmr_gqi_p1b_signature(candidate_rows[index, , drop = FALSE])
  })
  names(signatures) <- paste(
    candidate_rows$ScenarioId,
    candidate_rows$Lane,
    candidate_rows$QuadPoints,
    sep = "::"
  )
  low_signature_pairs <- do.call(rbind, lapply(
    unique(candidate_rows$ScenarioId),
    function(scenario_id) {
      ids <- paste(
        scenario_id,
        "qualified_low",
        mfrmr_gqi_p1b_quad_points,
        sep = "::"
      )
      pairs <- utils::combn(ids, 2L, simplify = FALSE)
      do.call(rbind, lapply(pairs, function(pair) {
        comparison <- mfrmr_gss_compare_signatures(
          signatures[[pair[1L]]],
          signatures[[pair[2L]]]
        )
        data.frame(
          ScenarioId = scenario_id,
          LeftQuadPoints = as.integer(sub("^.*::", "", pair[1L])),
          RightQuadPoints = as.integer(sub("^.*::", "", pair[2L])),
          comparison,
          SelectionAuthorized = FALSE,
          ConfirmationAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
      }))
    }
  ))
  summary <- do.call(rbind, lapply(
    split(
      seq_len(nrow(candidate_rows)),
      interaction(
        candidate_rows$ScenarioId,
        candidate_rows$Lane,
        drop = TRUE,
        lex.order = TRUE
      )
    ),
    function(index) {
      value <- candidate_rows[index, , drop = FALSE]
      value <- value[order(value$QuadPoints), , drop = FALSE]
      data.frame(
        ScenarioId = value$ScenarioId[1L],
        Lane = value$Lane[1L],
        SourceLaneEligible = value$SourceLaneEligible[1L],
        DeclaredQuadratureArms = nrow(value),
        ReturnedQuadratureArms = sum(value$FitReturned),
        ExistingNativePassArms = sum(value$ExistingNativeOptimizerPass),
        ComparisonEligibleArms = sum(value$P1BComparisonEligible),
        NativeObjectiveRange = if (all(is.finite(value$NativeObjective))) {
          diff(range(value$NativeObjective))
        } else NA_real_,
        CommonDenseObjectiveRange = if (
          all(is.finite(value$CommonDenseObjective))
        ) diff(range(value$CommonDenseObjective)) else NA_real_,
        MaximumNativeGradient = if (
          any(is.finite(value$NativeGradientMaxAbs))
        ) max(value$NativeGradientMaxAbs, na.rm = TRUE) else NA_real_,
        MaximumCommonDenseGradient = if (
          any(is.finite(value$CommonDenseGradientMaxAbs))
        ) max(value$CommonDenseGradientMaxAbs, na.rm = TRUE) else NA_real_,
        MaximumNativeAnalyticNumericDifference = if (
          any(is.finite(value$NativeAnalyticNumericGradientMaxAbsDifference))
        ) max(
          value$NativeAnalyticNumericGradientMaxAbsDifference,
          na.rm = TRUE
        ) else NA_real_,
        MaximumCommonAnalyticNumericDifference = if (
          any(is.finite(
            value$CommonDenseAnalyticNumericGradientMaxAbsDifference
          ))
        ) max(
          value$CommonDenseAnalyticNumericGradientMaxAbsDifference,
          na.rm = TRUE
        ) else NA_real_,
        Q31PopulationSigma2 = value$PopulationSigma2[value$QuadPoints == 31L],
        Q61PopulationSigma2 = value$PopulationSigma2[value$QuadPoints == 61L],
        Q91PopulationSigma2 = value$PopulationSigma2[value$QuadPoints == 91L],
        Q31CommonP01EAP = value$CommonP01EAP[value$QuadPoints == 31L],
        Q61CommonP01EAP = value$CommonP01EAP[value$QuadPoints == 61L],
        Q91CommonP01EAP = value$CommonP01EAP[value$QuadPoints == 91L],
        QuadratureToleranceStatus = "not_frozen_calibration_only",
        ContinuousIntegralCertificate = FALSE,
        SelectionAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    }
  ))
  rownames(summary) <- NULL
  structure(
    list(
      contract = mfrmr_gqi_p1b_contract,
      specification = mfrmr_gqi_p1b_specification,
      dependency_contract = mfrmr_gqi_p1b_dependency_contract,
      dependency_sha256 = mfrmr_gqi_p1b_dependency_sha256,
      plan = plan,
      candidates = candidate_rows,
      candidate_objects = candidates,
      pairwise = pairwise$summary,
      semantic_differences = pairwise$semantic,
      reflection = reflection,
      decision_signatures = signatures,
      signature_comparisons = low_signature_pairs,
      scenario_lane_summary = summary,
      p0b = p0b,
      QuadratureToleranceStatus = "not_frozen_calibration_only",
      ContinuousIntegralCertificate = FALSE,
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE
    ),
    class = "mfrmr_gpcm_low_basin_quadrature_p1b"
  )
}
