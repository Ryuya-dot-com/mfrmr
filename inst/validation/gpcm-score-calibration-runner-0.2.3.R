# Repository-only execution runner for the bounded GPCM score calibration.
#
# The default is dry-run. Exact execution requires `authorize = TRUE`, always
# runs all eight frozen scenarios, and cannot authorize confirmation, general
# NUM-SCORE-TOL, boundary, recovery, or inference claims.

mfrmr_gscr_contract_version <- "mfrmr_gpcm_score_calibration_execution_v1"
mfrmr_gscr_sources_loaded <- FALSE

mfrmr_gscr_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-calibration-runner-0\\.2\\.3\\.R$", files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  ))
})

mfrmr_gscr_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gscr_validation_dir <- function() {
  if (!is.na(mfrmr_gscr_source_dir) && dir.exists(mfrmr_gscr_source_dir)) {
    return(mfrmr_gscr_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"),
    file.path("..", "..", "..", "inst", "validation"),
    "."
  )
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-calibration-design-0.2.3.R"
  ))]
  if (length(candidates) == 0L) {
    stop("Cannot locate the GPCM score-calibration sources.", call. = FALSE)
  }
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gscr_require_sources <- function() {
  target <- environment(mfrmr_gscr_require_sources)
  required <- c(
    "mfrmr_gsc_design_contract", "mfrmr_gsc_fixture",
    "mfrmr_gsc_parameter_rules", "mfrmr_gsc_decision",
    "mfrmr_gno_independent_oracle", "mfrmr_gno_probability_difference",
    "mfrmr_num_fit_context", "mfrmr_num_logprob_bundle",
    "mfrmr_num_gpcm_jacobian_from_free", "mfrmr_num_get"
  )
  source_files <- c(
    "numerical-stationarity-pilot-0.2.3.R",
    "gpcm-score-calibration-design-0.2.3.R",
    "gpcm-nonunit-score-oracle-0.2.3.R"
  )
  if (!isTRUE(get0("mfrmr_gscr_sources_loaded", envir = target,
                   inherits = FALSE, ifnotfound = FALSE))) {
    for (file in source_files) {
      sys.source(file.path(mfrmr_gscr_validation_dir(), file), envir = target)
    }
    assign("mfrmr_gscr_sources_loaded", TRUE, envir = target)
  }
  if (exists("mfrmr_gno_require_base_contract", envir = target,
             inherits = FALSE)) {
    get("mfrmr_gno_require_base_contract", envir = target,
        inherits = FALSE)()
  }
  available <- vapply(required, exists, logical(1), envir = target,
                      inherits = FALSE)
  mfrmr_gscr_assert(
    all(available),
    paste0("The GPCM score-calibration source chain is incomplete: ",
           paste(required[!available], collapse = ", "), ".")
  )
  invisible(TRUE)
}

mfrmr_gscr_hash_file <- function(path) {
  mfrmr_gscr_assert(
    requireNamespace("digest", quietly = TRUE),
    "Package `digest` is required for calibration identities."
  )
  mfrmr_gscr_assert(file.exists(path), paste0("Missing identity file: ", path))
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gscr_hash_object <- function(object) {
  mfrmr_gscr_assert(
    requireNamespace("digest", quietly = TRUE),
    "Package `digest` is required for calibration identities."
  )
  digest::digest(object, algo = "sha256", serialize = TRUE)
}

mfrmr_gscr_package_payload_identity <- function() {
  validation_dir <- mfrmr_gscr_validation_dir()
  root <- normalizePath(file.path(validation_dir, "..", ".."),
                        winslash = "/", mustWork = TRUE)
  paths <- c(
    file.path(root, c("DESCRIPTION", "NAMESPACE")),
    list.files(file.path(root, "R"), pattern = "[.]R$", full.names = TRUE),
    list.files(file.path(root, "src"), full.names = TRUE, recursive = TRUE)
  )
  paths <- sort(unique(paths[file.exists(paths) & !dir.exists(paths)]))
  ledger <- data.frame(
    Path = substring(paths, nchar(root) + 2L),
    SHA256 = vapply(paths, mfrmr_gscr_hash_file, character(1L)),
    stringsAsFactors = FALSE
  )
  list(
    root = root,
    ledger = ledger,
    sha256 = mfrmr_gscr_hash_object(ledger)
  )
}

mfrmr_gscr_identity <- function() {
  mfrmr_gscr_require_sources()
  validation_dir <- mfrmr_gscr_validation_dir()
  payload <- mfrmr_gscr_package_payload_identity()
  files <- c(
    NumericalBase = "numerical-stationarity-pilot-0.2.3.R",
    Design = "gpcm-score-calibration-design-0.2.3.R",
    DesignContract = "gpcm-score-calibration-design-contract-0.2.3.md",
    Oracle = "gpcm-nonunit-score-oracle-0.2.3.R",
    Runner = "gpcm-score-calibration-runner-0.2.3.R"
  )
  file_paths <- stats::setNames(
    file.path(validation_dir, unname(files)), names(files)
  )
  file_hashes <- vapply(
    file_paths, mfrmr_gscr_hash_file, character(1L)
  )
  out <- data.frame(
    ExecutionContractVersion = mfrmr_gscr_contract_version,
    DesignContractVersion = mfrmr_gsc_contract_version,
    RVersion = as.character(getRversion()),
    Platform = R.version$platform,
    PackageVersion = as.character(utils::packageVersion("mfrmr")),
    PackagePayloadSHA256 = payload$sha256,
    NumericalBaseSHA256 = unname(file_hashes["NumericalBase"]),
    DesignSHA256 = unname(file_hashes["Design"]),
    DesignContractSHA256 = unname(file_hashes["DesignContract"]),
    OracleSHA256 = unname(file_hashes["Oracle"]),
    RunnerSHA256 = unname(file_hashes["Runner"]),
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out$IdentitySHA256 <- mfrmr_gscr_hash_object(out)
  attr(out, "payload_ledger") <- payload$ledger
  out
}

mfrmr_gscr_manifest <- function() {
  mfrmr_gscr_require_sources()
  design <- mfrmr_gsc_design_contract()
  identity <- mfrmr_gscr_identity()
  out <- design$scenarios
  out$ExecutionContractVersion <- mfrmr_gscr_contract_version
  out$PackagePayloadSHA256 <- identity$PackagePayloadSHA256
  out$DesignSHA256 <- identity$DesignSHA256
  out$OracleSHA256 <- identity$OracleSHA256
  out$RunnerSHA256 <- identity$RunnerSHA256
  out$IdentitySHA256 <- identity$IdentitySHA256
  out$CalibrationExecutionAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  canonical <- out
  canonical$ManifestSHA256 <- NULL
  out$ManifestSHA256 <- mfrmr_gscr_hash_object(canonical)
  out
}

mfrmr_gscr_capture <- function(expression) {
  warnings <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expression,
      warning = function(condition) {
        warnings <<- c(warnings, conditionMessage(condition))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(condition) condition
  )
  list(
    value = if (inherits(value, "condition")) NULL else value,
    error = if (inherits(value, "condition")) conditionMessage(value) else NA_character_,
    warnings = unique(warnings)
  )
}

mfrmr_gscr_fit <- function(scenario) {
  fixture <- mfrmr_gsc_fixture(as.character(scenario$DesignId))
  mfrmr_gscr_assert(
    identical(fixture$fixture_id, as.character(scenario$FixtureId)),
    "The deterministic fixture identity does not match the manifest."
  )
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  started <- proc.time()[["elapsed"]]
  capture <- mfrmr_gscr_capture(fit_fun(
    fixture$data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1L,
    rating_max = 5L,
    keep_original = TRUE,
    method = "MML",
    model = "GPCM",
    step_facet = as.character(scenario$StepOwner),
    slope_facet = as.character(scenario$SlopeOwner),
    quad_points = as.integer(scenario$QuadPoints),
    maxit = as.integer(scenario$Maxit),
    reltol = as.numeric(scenario$Reltol),
    optimizer = "L-BFGS-B",
    mml_engine = "direct"
  ))
  elapsed <- proc.time()[["elapsed"]] - started
  list(
    fit = capture$value,
    error = capture$error,
    warnings = capture$warnings,
    elapsed = elapsed,
    fixture = fixture,
    fixture_sha256 = mfrmr_gscr_hash_object(fixture$data)
  )
}

mfrmr_gscr_point <- function(fit, point) {
  point <- match.arg(point, mfrmr_gsc_points()$Point)
  context <- mfrmr_num_fit_context(fit)
  par <- as.numeric(fit$opt$par)
  slope_slice <- as.integer(context$slices$log_slopes)
  n_levels <- length(fit$config$gpcm_spec$levels)
  if (identical(point, "retained_solution")) return(par)
  if (identical(point, "coupled_free_probe")) {
    direction <- sin(seq_along(par) * sqrt(2)) +
      0.5 * cos(seq_along(par) * sqrt(3))
    direction <- direction / max(abs(direction))
    par <- par + 0.08 * direction * pmax(1, abs(par))
    target <- exp(seq(log(0.45), log(2.20), length.out = n_levels))
    target_log <- log(target) - mean(log(target))
  } else {
    target_log <- seq(-3, 3, length.out = n_levels)
    if (identical(point, "finite_slope_stress_reverse")) {
      target_log <- rev(target_log)
    }
  }
  par[slope_slice] <- target_log[seq_len(n_levels - 1L)]
  par
}

mfrmr_gscr_five_point_bundle <- function(fn, par, rel_step) {
  mfrmr_gscr_assert(is.function(fn), "`fn` must be a function.")
  par <- suppressWarnings(as.numeric(par))
  rel_step <- suppressWarnings(as.numeric(rel_step))
  mfrmr_gscr_assert(
    length(par) > 0L && all(is.finite(par)),
    "`par` must be a non-empty finite numeric vector."
  )
  mfrmr_gscr_assert(
    length(rel_step) == 1L && is.finite(rel_step) && rel_step > 0,
    "`rel_step` must be one finite positive value."
  )
  step <- rel_step * pmax(1, abs(par))
  values <- lapply(seq_along(par), function(index) {
    minus_two <- minus_one <- plus_one <- plus_two <- par
    minus_two[index] <- par[index] - 2 * step[index]
    minus_one[index] <- par[index] - step[index]
    plus_one[index] <- par[index] + step[index]
    plus_two[index] <- par[index] + 2 * step[index]
    objective <- suppressWarnings(as.numeric(c(
      fn(minus_two), fn(minus_one), fn(plus_one), fn(plus_two)
    )))
    if (length(objective) != 4L || any(!is.finite(objective))) {
      return(c(Score = NA_real_, MaxAbsObjective = NA_real_))
    }
    score <- (objective[1] - 8 * objective[2] +
                8 * objective[3] - objective[4]) / (12 * step[index])
    c(Score = score, MaxAbsObjective = max(abs(objective)))
  })
  matrix <- do.call(rbind, values)
  list(
    score = as.numeric(matrix[, "Score"]),
    max_abs_objective = as.numeric(matrix[, "MaxAbsObjective"]),
    absolute_step = step,
    relative_step = rel_step
  )
}

mfrmr_gscr_parameter_class <- function(coordinates, owner) {
  mfrmr_gscr_require_sources()
  raw <- as.character(coordinates$ParameterClass)
  other <- setdiff(c("Rater", "Criterion"), owner)
  out <- ifelse(
    raw == owner, "owner_additive",
    ifelse(raw == other, "other_additive",
           ifelse(raw == "steps", "steps",
                  ifelse(raw == "log_slopes", "log_slopes", NA_character_)))
  )
  mfrmr_gscr_assert(
    length(out) == nrow(coordinates) && !anyNA(out) &&
      identical(sort(unique(out)), sort(mfrmr_gsc_expected_classes)),
    "The fitted coordinate classes do not match the frozen four-class design."
  )
  out
}

mfrmr_gscr_point_audit <- function(fit, scenario, point) {
  context <- mfrmr_num_fit_context(fit)
  par <- mfrmr_gscr_point(fit, point)
  analytic <- suppressWarnings(as.numeric(context$gr(par)))
  route <- mfrmr_num_logprob_bundle(context, par, include_probs = TRUE)
  route_objective <- suppressWarnings(as.numeric(context$fn(par))[1])
  oracle <- mfrmr_gno_independent_oracle(context, par)
  oracle_fn <- function(value) {
    mfrmr_gno_independent_oracle(context, value)$objective
  }
  derivative <- lapply(mfrmr_gsc_relative_steps, function(step) {
    mfrmr_gscr_five_point_bundle(oracle_fn, par, step)
  })
  score_matrix <- do.call(cbind, lapply(derivative, `[[`, "score"))
  max_objective_matrix <- do.call(cbind, lapply(
    derivative, `[[`, "max_abs_objective"
  ))
  step_matrix <- do.call(cbind, lapply(derivative, `[[`, "absolute_step"))
  primary_index <- match(mfrmr_gsc_primary_step, mfrmr_gsc_relative_steps)
  mfrmr_gscr_assert(!is.na(primary_index), "The primary step left the ladder.")
  reference <- score_matrix[, primary_index]
  score_scale <- pmax(1, abs(analytic), abs(reference))
  absolute_difference <- abs(analytic - reference)
  scaled_difference <- absolute_difference / score_scale
  reference_spread <- apply(score_matrix, 1L, function(value) {
    if (any(!is.finite(value))) return(NA_real_)
    diff(range(value))
  })
  roundoff_bound <- 32 * .Machine$double.eps *
    pmax(1, apply(max_objective_matrix, 1L, max)) /
    apply(step_matrix, 1L, min)
  coordinates <- context$coordinates
  coordinates$ParameterClassFrozen <- mfrmr_gscr_parameter_class(
    coordinates, as.character(scenario$SlopeOwner)
  )
  rules <- mfrmr_gsc_parameter_rules()
  rule_index <- match(coordinates$ParameterClassFrozen, rules$ParameterClass)
  adaptive_allowance <-
    rules$AdaptiveBaseAbsolute[rule_index] +
    rules$AdaptiveBaseScaled[rule_index] * score_scale +
    rules$ReferenceSpreadMultiplier[rule_index] * reference_spread +
    rules$RoundoffMultiplier[rule_index] * roundoff_bound
  adaptive_ratio <- absolute_difference / adaptive_allowance

  package_params <- mfrmr_num_get("expand_params")(
    par, context$sizes, context$config
  )
  finite_structural <- all(is.finite(c(
    route$log_prob_mat, route_objective, oracle$log_prob_mat,
    oracle$objective, package_params$log_slopes, package_params$slopes,
    oracle$log_slopes, oracle$slopes
  )))
  log_probability_difference <- if (finite_structural) {
    max(abs(route$log_prob_mat - oracle$log_prob_mat))
  } else NA_real_
  probability_difference <- if (finite_structural) {
    mfrmr_gno_probability_difference(
      route$prob_list, oracle$probability_list
    )
  } else NA_real_
  objective_difference <- if (finite_structural) {
    abs(route_objective - oracle$objective)
  } else NA_real_
  log_slope_difference <- if (finite_structural) {
    max(abs(package_params$log_slopes - oracle$log_slopes))
  } else NA_real_
  slope_difference <- if (finite_structural) {
    max(abs(package_params$slopes - oracle$slopes))
  } else NA_real_
  structural_pass <- finite_structural &&
    log_probability_difference <= mfrmr_gno_limits["log_probability"] &&
    probability_difference <= mfrmr_gno_limits["probability"] &&
    objective_difference <= mfrmr_gno_limits["objective"] &&
    log_slope_difference <= mfrmr_gno_limits["transform"] &&
    slope_difference <= mfrmr_gno_limits["transform"] &&
    oracle$geometric_mean_residual <= mfrmr_gno_limits["geometric_mean"]

  slope_slice <- as.integer(context$slices$log_slopes)
  jacobian <- mfrmr_num_gpcm_jacobian_from_free(
    par[slope_slice],
    levels = as.character(fit$config$gpcm_spec$levels),
    point = point,
    rel_step = 1e-6
  )
  jacobian_table <- jacobian$table
  log_jacobian_difference <- max(abs(
    jacobian_table$AnalyticLogJacobian - jacobian_table$NumericLogJacobian
  ))
  slope_jacobian_absolute <- abs(
    jacobian_table$AnalyticSlopeJacobian -
      jacobian_table$NumericSlopeJacobian
  )
  slope_jacobian_scale <- pmax(
    1, abs(jacobian_table$AnalyticSlopeJacobian),
    abs(jacobian_table$NumericSlopeJacobian)
  )
  slope_rule <- rules[rules$ParameterClass == "log_slopes", , drop = FALSE]
  jacobian_pass <-
    log_jacobian_difference <= slope_rule$ExpandedLogJacobianAbsoluteCap &&
    max(slope_jacobian_absolute) <=
      slope_rule$ExpandedSlopeJacobianAbsoluteCap &&
    max(slope_jacobian_absolute / slope_jacobian_scale) <=
      slope_rule$ExpandedSlopeJacobianScaledCap &&
    jacobian$summary$GeometricMeanResidual <=
      slope_rule$GeometricMeanResidualCap

  coordinates$ScenarioId <- as.character(scenario$ScenarioId)
  coordinates$Point <- point
  coordinates$AnalyticScore <- analytic
  coordinates$ReferenceScore <- reference
  coordinates$ReferenceSpread <- reference_spread
  coordinates$RoundoffBound <- roundoff_bound
  coordinates$AdaptiveAllowance <- adaptive_allowance
  coordinates$AbsDifference <- absolute_difference
  coordinates$ScaledDifference <- scaled_difference
  coordinates$AdaptiveRatio <- adaptive_ratio
  coordinates$HardAbsoluteCap <- rules$HardAbsoluteCap[rule_index]
  coordinates$HardScaledCap <- rules$HardScaledCap[rule_index]
  coordinates$CoordinatePass <-
    is.finite(absolute_difference) & is.finite(scaled_difference) &
    is.finite(adaptive_ratio) &
    absolute_difference <= coordinates$HardAbsoluteCap &
    scaled_difference <= coordinates$HardScaledCap & adaptive_ratio <= 1
  for (index in seq_along(mfrmr_gsc_relative_steps)) {
    label <- gsub("[.]", "p", format(
      mfrmr_gsc_relative_steps[index], scientific = TRUE
    ))
    coordinates[[paste0("FivePointScore_", label)]] <- score_matrix[, index]
  }
  coordinates$StructuralOraclePass <- structural_pass
  coordinates$JacobianPass <- jacobian_pass
  coordinates$CalibrationAuthorized <- FALSE
  coordinates$ConfirmationAuthorized <- FALSE

  class_rows <- lapply(mfrmr_gsc_expected_classes, function(class) {
    keep <- coordinates$ParameterClassFrozen == class
    finite <- any(keep) && all(is.finite(unlist(coordinates[keep, c(
      "AnalyticScore", "ReferenceScore", "ReferenceSpread",
      "RoundoffBound", "AdaptiveAllowance", "AbsDifference",
      "ScaledDifference", "AdaptiveRatio"
    )], use.names = FALSE)))
    data.frame(
      ContractVersion = mfrmr_gsc_contract_version,
      ScenarioId = as.character(scenario$ScenarioId),
      Point = point,
      ParameterClass = class,
      CoordinateCount = sum(keep),
      MaxAbsDifference = if (finite) {
        max(coordinates$AbsDifference[keep])
      } else NA_real_,
      MaxScaledDifference = if (finite) {
        max(coordinates$ScaledDifference[keep])
      } else NA_real_,
      MaxAdaptiveRatio = if (finite) {
        max(coordinates$AdaptiveRatio[keep])
      } else NA_real_,
      StepLadderComplete = finite,
      StructuralOraclePass = structural_pass,
      JacobianStatus = if (class == "log_slopes") {
        if (jacobian_pass) "pass" else "fail"
      } else "not_applicable",
      EvaluationComplete = finite,
      CalibrationAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  evidence <- do.call(rbind, class_rows)
  point_summary <- data.frame(
    ScenarioId = as.character(scenario$ScenarioId),
    Point = point,
    FreeCoordinates = length(par),
    MinSlope = min(oracle$slopes),
    MaxSlope = max(oracle$slopes),
    LogProbabilityMaxAbsDifference = log_probability_difference,
    ProbabilityMaxAbsDifference = probability_difference,
    ObjectiveAbsDifference = objective_difference,
    ExpandedLogSlopeMaxAbsDifference = log_slope_difference,
    ExpandedSlopeMaxAbsDifference = slope_difference,
    GeometricMeanResidual = oracle$geometric_mean_residual,
    MaxAbsScoreDifference = max(absolute_difference),
    MaxScaledScoreDifference = max(scaled_difference),
    MaxAdaptiveRatio = max(adaptive_ratio),
    LogJacobianMaxAbsDifference = log_jacobian_difference,
    SlopeJacobianMaxAbsDifference = max(slope_jacobian_absolute),
    SlopeJacobianMaxScaledDifference =
      max(slope_jacobian_absolute / slope_jacobian_scale),
    StructuralOraclePass = structural_pass,
    JacobianPass = jacobian_pass,
    AllCoordinatesPass = all(coordinates$CoordinatePass),
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    coordinates = coordinates,
    evidence = evidence,
    point_summary = point_summary,
    jacobian = jacobian
  )
}

mfrmr_gscr_failed_evidence <- function(scenario) {
  grid <- expand.grid(
    Point = mfrmr_gsc_points()$Point,
    ParameterClass = mfrmr_gsc_expected_classes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data.frame(
    ContractVersion = mfrmr_gsc_contract_version,
    ScenarioId = as.character(scenario$ScenarioId),
    Point = grid$Point,
    ParameterClass = grid$ParameterClass,
    CoordinateCount = 0L,
    MaxAbsDifference = NA_real_,
    MaxScaledDifference = NA_real_,
    MaxAdaptiveRatio = NA_real_,
    StepLadderComplete = FALSE,
    StructuralOraclePass = FALSE,
    JacobianStatus = ifelse(
      grid$ParameterClass == "log_slopes", "fail", "not_applicable"
    ),
    EvaluationComplete = FALSE,
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gscr_run_scenario <- function(scenario, progress = TRUE) {
  if (isTRUE(progress)) {
    message("GPCM score calibration: ", scenario$ScenarioId)
  }
  fitted <- mfrmr_gscr_fit(scenario)
  fit <- fitted$fit
  fit_succeeded <- !is.null(fit) && length(fit$opt$par) > 0L &&
    all(is.finite(fit$opt$par))
  fit_summary <- data.frame(
    ScenarioId = as.character(scenario$ScenarioId),
    FixtureId = fitted$fixture$fixture_id,
    FixtureSHA256 = fitted$fixture_sha256,
    Rows = nrow(fitted$fixture$data),
    FitSucceeded = fit_succeeded,
    Error = fitted$error,
    Warnings = paste(fitted$warnings, collapse = " | "),
    ElapsedSeconds = fitted$elapsed,
    OptimizerConvergence = if (fit_succeeded) {
      value <- fit$opt$convergence
      suppressWarnings(as.integer(if (is.null(value)) NA_integer_ else value))
    } else NA_integer_,
    FitReadiness = if (fit_succeeded) {
      value <- fit$summary$FitReadiness
      as.character(if (is.null(value) || length(value) == 0L) {
        "unknown"
      } else value[1])
    } else "not_available",
    InferenceReady = if (fit_succeeded) {
      isTRUE(fit$summary$InferenceReady[1])
    } else FALSE,
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  if (!fit_succeeded) {
    return(list(
      fit_summary = fit_summary,
      coordinates = data.frame(),
      evidence = mfrmr_gscr_failed_evidence(scenario),
      point_summary = data.frame()
    ))
  }
  audits <- lapply(mfrmr_gsc_points()$Point, function(point) {
    mfrmr_gscr_point_audit(fit, scenario, point)
  })
  list(
    fit_summary = fit_summary,
    coordinates = do.call(rbind, lapply(audits, `[[`, "coordinates")),
    evidence = do.call(rbind, lapply(audits, `[[`, "evidence")),
    point_summary = do.call(rbind, lapply(audits, `[[`, "point_summary"))
  )
}

mfrmr_run_gpcm_score_calibration <- function(
    dry_run = TRUE, authorize = FALSE, progress = TRUE) {
  mfrmr_gscr_require_sources()
  manifest <- mfrmr_gscr_manifest()
  identity <- mfrmr_gscr_identity()
  if (isTRUE(dry_run)) {
    return(list(
      contract_version = mfrmr_gscr_contract_version,
      manifest = manifest,
      identity = identity,
      executed = FALSE,
      calibration_execution_authorized = FALSE,
      general_num_score_tol_frozen = FALSE,
      confirmation_authorized = FALSE
    ))
  }
  mfrmr_gscr_assert(
    isTRUE(authorize),
    "Bounded calibration execution requires explicit `authorize = TRUE`."
  )
  started <- proc.time()[["elapsed"]]
  results <- lapply(seq_len(nrow(manifest)), function(index) {
    mfrmr_gscr_run_scenario(manifest[index, , drop = FALSE], progress)
  })
  fits <- do.call(rbind, lapply(results, `[[`, "fit_summary"))
  coordinates <- do.call(rbind, lapply(results, `[[`, "coordinates"))
  evidence <- do.call(rbind, lapply(results, `[[`, "evidence"))
  point_summary <- do.call(rbind, lapply(results, `[[`, "point_summary"))
  decision <- mfrmr_gsc_decision(evidence)
  elapsed <- proc.time()[["elapsed"]] - started
  list(
    contract_version = mfrmr_gscr_contract_version,
    manifest = manifest,
    identity = identity,
    fits = fits,
    coordinates = coordinates,
    evidence = evidence,
    point_summary = point_summary,
    decision = decision,
    executed = TRUE,
    elapsed_seconds = elapsed,
    calibration_execution_authorized_for_this_run = TRUE,
    calibration_authorized_by_result = FALSE,
    general_num_score_tol_frozen = FALSE,
    confirmation_authorized = FALSE
  )
}
