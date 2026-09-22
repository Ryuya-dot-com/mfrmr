# Record-consuming GPCM score v4 confirmation runner. Dry-run is the default.
# Execution requires a separate exact same-process authorization row, an absent
# absolute target, and embeds both issued- and consumed-row hashes.

mfrmr_gsv4q_contract_version <-
  "mfrmr_gpcm_score_v4_confirmation_runner_v1"
mfrmr_gsv4q_authorization_contract <-
  "mfrmr_gpcm_score_v4_confirmation_authorization_v1"
mfrmr_gsv4q_sources_loaded <- FALSE

mfrmr_gsv4q_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v4-confirmation-runner-0\\.2\\.3\\.R$", files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4q_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4q_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4q_source_dir) && dir.exists(mfrmr_gsv4q_source_dir)) {
    return(mfrmr_gsv4q_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"), file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-confirmation-design-0.2.3.R"
  ))]
  mfrmr_gsv4q_assert(length(found) > 0L,
                     "Cannot locate v4 confirmation runner sources.")
  normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4q_require_sources <- function() {
  target <- environment(mfrmr_gsv4q_require_sources)
  if (!isTRUE(get0("mfrmr_gsv4q_sources_loaded", envir = target,
                   inherits = FALSE, ifnotfound = FALSE))) {
    for (file in c(
      "gpcm-score-v4-confirmation-design-0.2.3.R",
      "gpcm-score-v3-replay-runner-0.2.3.R",
      "gpcm-score-v4-rule-contract-0.2.3.R"
    )) {
      sys.source(file.path(mfrmr_gsv4q_validation_dir(), file), envir = target)
    }
    assign("mfrmr_gsv4q_sources_loaded", TRUE, envir = target)
  }
  mfrmr_gsv3r_require_sources()
  invisible(TRUE)
}

mfrmr_gsv4q_is_absolute_path <- function(path) {
  length(path) == 1L && !is.na(path) && nzchar(path) &&
    grepl("^(/|[A-Za-z]:[/\\\\]|\\\\\\\\)", path)
}

mfrmr_gsv4q_identity <- function() {
  mfrmr_gsv4q_require_sources()
  validation_dir <- mfrmr_gsv4q_validation_dir()
  root <- normalizePath(file.path(validation_dir, "..", ".."),
                        winslash = "/", mustWork = TRUE)
  runtime <- mfrmr_gsv3r_runtime_identity(root)
  payload <- mfrmr_gscr_package_payload_identity()
  files <- c(
    NumericalBase = "numerical-stationarity-pilot-0.2.3.R",
    CalibrationDesign = "gpcm-score-calibration-design-0.2.3.R",
    Oracle = "gpcm-nonunit-score-oracle-0.2.3.R",
    V3Rule = "gpcm-score-v3-rule-contract-0.2.3.R",
    V3ReplayRunner = "gpcm-score-v3-replay-runner-0.2.3.R",
    V4Rule = "gpcm-score-v4-rule-contract-0.2.3.R",
    V4Freeze = "gpcm-score-v4-freeze-contract-0.2.3.R",
    V4Design = "gpcm-score-v4-confirmation-design-0.2.3.R",
    V4Runner = "gpcm-score-v4-confirmation-runner-0.2.3.R"
  )
  hashes <- vapply(
    file.path(validation_dir, unname(files)),
    mfrmr_gscr_hash_file, character(1L)
  )
  names(hashes) <- names(files)
  out <- data.frame(
    ContractVersion = mfrmr_gsv4q_contract_version,
    PackagePayloadSHA256 = payload$sha256,
    NumericalBaseSHA256 = unname(hashes["NumericalBase"]),
    CalibrationDesignSHA256 = unname(hashes["CalibrationDesign"]),
    OracleSHA256 = unname(hashes["Oracle"]),
    V3RuleSHA256 = unname(hashes["V3Rule"]),
    V3ReplayRunnerSHA256 = unname(hashes["V3ReplayRunner"]),
    V4RuleSHA256 = unname(hashes["V4Rule"]),
    V4FreezeSHA256 = unname(hashes["V4Freeze"]),
    V4DesignSHA256 = unname(hashes["V4Design"]),
    V4RunnerSHA256 = unname(hashes["V4Runner"]),
    DevelopmentSourceLoaded = runtime$DevelopmentSourceLoaded,
    FreshProcessRequired = TRUE,
    AbsoluteOutputTargetRequired = TRUE,
    ConfirmationExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out$IdentitySHA256 <- mfrmr_gscr_hash_object(out)
  out
}

mfrmr_gsv4q_manifest <- function() {
  identity <- mfrmr_gsv4q_identity()
  out <- mfrmr_gsv4c_scenarios()
  out$RunnerIdentitySHA256 <- identity$IdentitySHA256
  out$V4RunnerSHA256 <- identity$V4RunnerSHA256
  out$V4DesignSHA256 <- identity$V4DesignSHA256
  out$V4FreezeSHA256 <- identity$V4FreezeSHA256
  out$PackagePayloadSHA256 <- identity$PackagePayloadSHA256
  out$ResultOpened <- FALSE
  out$ConfirmationExecutionAuthorized <- FALSE
  canonical <- out
  canonical$ManifestSHA256 <- NULL
  out$ManifestSHA256 <- mfrmr_gscr_hash_object(canonical)
  out
}

mfrmr_gsv4q_fit <- function(scenario) {
  fixture <- mfrmr_gsv4c_fixture(as.character(scenario$DesignId))
  mfrmr_gsv4q_assert(
    identical(fixture$sha256, as.character(scenario$FixtureSHA256)),
    "V4 confirmation fixture identity changed."
  )
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  started <- proc.time()[["elapsed"]]
  capture <- mfrmr_gscr_capture(fit_fun(
    fixture$data, person = "Person", facets = c("Rater", "Criterion"),
    score = "Score", rating_min = 1L,
    rating_max = as.integer(scenario$NCategories), keep_original = TRUE,
    method = "MML", model = "GPCM",
    step_facet = as.character(scenario$StepOwner),
    slope_facet = as.character(scenario$SlopeOwner),
    quad_points = as.integer(scenario$QuadPoints),
    maxit = as.integer(scenario$Maxit), reltol = as.numeric(scenario$Reltol),
    optimizer = "L-BFGS-B", mml_engine = "direct"
  ))
  list(
    fit = capture$value, error = capture$error, warnings = capture$warnings,
    elapsed = proc.time()[["elapsed"]] - started, fixture = fixture
  )
}

mfrmr_gsv4q_finite_difference <- function(context, par, package_score) {
  oracle_fn <- function(value) {
    mfrmr_gno_independent_oracle(context, value)$objective
  }
  derivative <- lapply(mfrmr_gsc_relative_steps, function(step) {
    mfrmr_gscr_five_point_bundle(oracle_fn, par, step)
  })
  score_matrix <- do.call(cbind, lapply(derivative, `[[`, "score"))
  objective_matrix <- do.call(cbind, lapply(
    derivative, `[[`, "max_abs_objective"
  ))
  step_matrix <- do.call(cbind, lapply(derivative, `[[`, "absolute_step"))
  primary <- match(mfrmr_gsc_primary_step, mfrmr_gsc_relative_steps)
  reference <- score_matrix[, primary]
  spread <- apply(score_matrix, 1L, function(value) {
    if (any(!is.finite(value))) return(NA_real_)
    diff(range(value))
  })
  roundoff <- 32 * .Machine$double.eps *
    pmax(1, apply(objective_matrix, 1L, max)) /
    apply(step_matrix, 1L, min)
  scale <- pmax(1, abs(package_score), abs(reference))
  allowance <- mfrmr_gsv3_allowance(
    "finite_difference_score", scale,
    reference_spread = spread, roundoff_bound = roundoff
  )
  list(
    derivative = derivative, reference = reference, spread = spread,
    roundoff = roundoff, allowance = allowance,
    ratio = abs(package_score - reference) / allowance
  )
}

mfrmr_gsv4q_point_audit <- function(fit, scenario, point) {
  base <- mfrmr_gsv3r_point_audit(fit, scenario, point)
  context <- mfrmr_num_fit_context(fit)
  par <- mfrmr_gscr_point(fit, point)
  structural <- mfrmr_gsv3r_structural_audit(context, par)
  classification <- mfrmr_gsv4_classify_log_slopes(
    structural$oracle$log_slopes, point
  )
  finite_region <- identical(classification$Region, "finite_slope_region")
  package_score <- suppressWarnings(as.numeric(context$gr(par)))
  coordinates <- base$coordinates
  derivative <- NULL
  if (finite_region && any(!is.finite(
      coordinates$FiniteDifferenceCombinedRatio
  ))) {
    fd <- mfrmr_gsv4q_finite_difference(context, par, package_score)
    coordinates$FiniteDifferenceReference <- fd$reference
    coordinates$FiniteDifferenceReferenceSpread <- fd$spread
    coordinates$FiniteDifferenceRoundoffBound <- fd$roundoff
    coordinates$FiniteDifferenceCombinedAllowance <- fd$allowance
    coordinates$FiniteDifferenceCombinedRatio <- fd$ratio
    derivative <- fd$derivative
  }
  if (!finite_region) {
    coordinates$FiniteDifferenceReference <- NA_real_
    coordinates$FiniteDifferenceReferenceSpread <- NA_real_
    coordinates$FiniteDifferenceRoundoffBound <- NA_real_
    coordinates$FiniteDifferenceCombinedAllowance <- NA_real_
    coordinates$FiniteDifferenceCombinedRatio <- NA_real_
  }
  coordinates$SlopeRegion <- classification$Region
  coordinates$V4ConstructionRawExcess <- classification$RawExcess
  coordinates$V4ConstructionAllowance <- classification$Allowance
  coordinates$V4AllowanceApplied <- classification$AllowanceApplied
  coordinates$DesignConfirmationEligible <- TRUE
  for (index in seq_along(mfrmr_gsc_relative_steps)) {
    label <- gsub("[.]", "p", format(
      mfrmr_gsc_relative_steps[index], scientific = TRUE
    ))
    column <- paste0("FivePointScore_", label)
    if (!finite_region) coordinates[[column]] <- NA_real_
    if (!is.null(derivative)) coordinates[[column]] <- derivative[[index]]$score
  }

  jacobian <- base$jacobian
  jacobian$SlopeRegion <- classification$Region
  jacobian$V4ConstructionRawExcess <- classification$RawExcess
  jacobian$V4ConstructionAllowance <- classification$Allowance
  jacobian$DesignConfirmationEligible <- TRUE
  log_ratio <- max(jacobian$LogCombinedRatio)
  slope_ratio <- max(jacobian$SlopeCombinedRatio)
  source_inference_ready <- "InferenceReady" %in% names(fit$summary) &&
    isTRUE(fit$summary[["InferenceReady"]][1])

  evidence <- do.call(rbind, lapply(mfrmr_gsv4c_classes, function(class) {
    keep <- coordinates$ParameterClassFrozen == class
    analytic_complete <- any(keep) && all(is.finite(unlist(
      coordinates[keep, c(
        "PackageAnalyticScore", "IndependentAnalyticScore",
        "AnalyticScoreCombinedAllowance", "AnalyticScoreCombinedRatio"
      )], use.names = FALSE
    )))
    fd_complete <- if (finite_region) {
      any(keep) && all(is.finite(unlist(coordinates[keep, c(
        "FiniteDifferenceReference", "FiniteDifferenceReferenceSpread",
        "FiniteDifferenceRoundoffBound", "FiniteDifferenceCombinedAllowance",
        "FiniteDifferenceCombinedRatio"
      )], use.names = FALSE)))
    } else TRUE
    fd_ratio <- if (finite_region && fd_complete) {
      max(coordinates$FiniteDifferenceCombinedRatio[keep])
    } else NA_real_
    fd_status <- if (finite_region) {
      if (fd_complete && fd_ratio <= 1) "pass" else "fail"
    } else "not_applicable_extreme_slope"
    data.frame(
      ContractVersion = mfrmr_gsv4_contract_version,
      ScenarioId = as.character(scenario$ScenarioId), Point = point,
      ParameterClass = class, CoordinateCount = sum(keep),
      SlopeRegion = classification$Region,
      StructuralOraclePass = structural$pass,
      AnalyticScorePass = analytic_complete &&
        all(coordinates$AnalyticScoreCombinedRatio[keep] <= 1),
      MaxAnalyticScoreCombinedRatio = if (analytic_complete) {
        max(coordinates$AnalyticScoreCombinedRatio[keep])
      } else NA_real_,
      FiniteDifferenceStatus = fd_status,
      FiniteDifferenceCombinedRatio = fd_ratio,
      LogJacobianCombinedRatio = log_ratio,
      SlopeJacobianCombinedRatio = slope_ratio,
      V4ConstructionRawExcess = classification$RawExcess,
      V4ConstructionAllowance = classification$Allowance,
      V4AllowanceApplied = classification$AllowanceApplied,
      ExtremeSlopeReviewHandoff =
        identical(classification$Region, "extreme_slope_review_handoff"),
      SourceInferenceReady = source_inference_ready,
      EvaluationComplete = analytic_complete && fd_complete &&
        structural$pass && is.finite(log_ratio) && is.finite(slope_ratio),
      CalibrationDataReused = FALSE,
      DesignConfirmationEligible = TRUE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  }))
  point_summary <- base$point_summary
  point_summary$SlopeRegion <- classification$Region
  point_summary$FiniteDifferenceStatus <- if (finite_region) {
    if (all(is.finite(coordinates$FiniteDifferenceCombinedRatio)) &&
        all(coordinates$FiniteDifferenceCombinedRatio <= 1)) "pass" else "fail"
  } else "not_applicable_extreme_slope"
  point_summary$MaxFiniteDifferenceCombinedRatio <- if (finite_region) {
    max(coordinates$FiniteDifferenceCombinedRatio)
  } else NA_real_
  point_summary$V4ConstructionRawExcess <- classification$RawExcess
  point_summary$V4ConstructionAllowance <- classification$Allowance
  point_summary$V4AllowanceApplied <- classification$AllowanceApplied
  point_summary$DesignConfirmationEligible <- TRUE
  list(
    coordinates = coordinates, evidence = evidence,
    point_summary = point_summary, jacobian = jacobian
  )
}

mfrmr_gsv4q_failed_evidence <- function(scenario) {
  grid <- expand.grid(
    Point = mfrmr_gsv4c_points, ParameterClass = mfrmr_gsv4c_classes,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  data.frame(
    ContractVersion = mfrmr_gsv4_contract_version,
    ScenarioId = as.character(scenario$ScenarioId), Point = grid$Point,
    ParameterClass = grid$ParameterClass, CoordinateCount = 0L,
    SlopeRegion = "not_evaluable", StructuralOraclePass = FALSE,
    AnalyticScorePass = FALSE, MaxAnalyticScoreCombinedRatio = NA_real_,
    FiniteDifferenceStatus = "not_evaluable",
    FiniteDifferenceCombinedRatio = NA_real_,
    LogJacobianCombinedRatio = NA_real_, SlopeJacobianCombinedRatio = NA_real_,
    V4ConstructionRawExcess = NA_real_, V4ConstructionAllowance = NA_real_,
    V4AllowanceApplied = FALSE, ExtremeSlopeReviewHandoff = FALSE,
    SourceInferenceReady = FALSE, EvaluationComplete = FALSE,
    CalibrationDataReused = FALSE, DesignConfirmationEligible = TRUE,
    ConfirmationAuthorized = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_gsv4q_run_scenario <- function(scenario, progress = TRUE) {
  if (isTRUE(progress)) {
    message("GPCM score v4 confirmation: ", scenario$ScenarioId)
  }
  fitted <- mfrmr_gsv4q_fit(scenario)
  fit <- fitted$fit
  succeeded <- !is.null(fit) && length(fit$opt$par) > 0L &&
    all(is.finite(fit$opt$par))
  fit_row <- data.frame(
    ScenarioId = as.character(scenario$ScenarioId),
    FixtureSHA256 = fitted$fixture$sha256, Rows = nrow(fitted$fixture$data),
    FitSucceeded = succeeded, Error = fitted$error,
    Warnings = paste(fitted$warnings, collapse = " | "),
    ElapsedSeconds = fitted$elapsed,
    OptimizerConvergence = if (succeeded) {
      as.integer(fit$opt$convergence)
    } else NA_integer_,
    FitReadiness = if (succeeded) {
      as.character(fit$summary$FitReadiness[1])
    } else "not_available",
    InferenceReady = succeeded && isTRUE(fit$summary$InferenceReady[1]),
    ConfirmationAuthorized = FALSE, stringsAsFactors = FALSE
  )
  if (!succeeded) return(list(
    fit = fit_row, coordinates = data.frame(),
    evidence = mfrmr_gsv4q_failed_evidence(scenario),
    point_summary = data.frame(), jacobian = data.frame()
  ))
  audits <- lapply(mfrmr_gsv4c_points, function(point) {
    mfrmr_gsv4q_point_audit(fit, scenario, point)
  })
  list(
    fit = fit_row,
    coordinates = do.call(rbind, lapply(audits, `[[`, "coordinates")),
    evidence = do.call(rbind, lapply(audits, `[[`, "evidence")),
    point_summary = do.call(rbind, lapply(audits, `[[`, "point_summary")),
    jacobian = do.call(rbind, lapply(audits, `[[`, "jacobian"))
  )
}

mfrmr_gsv4q_expected_coordinate_counts <- function() {
  scenarios <- mfrmr_gsv4c_scenarios()
  rows <- lapply(seq_len(nrow(scenarios)), function(index) {
    scenario <- scenarios[index, , drop = FALSE]
    owner_levels <- if (scenario$SlopeOwner == "Criterion") {
      scenario$NCriteria
    } else scenario$NRaters
    other_levels <- if (scenario$SlopeOwner == "Criterion") {
      scenario$NRaters
    } else scenario$NCriteria
    counts <- c(
      owner_additive = owner_levels - 1L,
      other_additive = other_levels - 1L,
      steps = owner_levels * (scenario$NCategories - 2L),
      log_slopes = owner_levels - 1L
    )
    grid <- expand.grid(
      Point = mfrmr_gsv4c_points, ParameterClass = names(counts),
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    grid$ScenarioId <- scenario$ScenarioId
    grid$ExpectedCount <- as.integer(counts[grid$ParameterClass])
    grid[c("ScenarioId", "Point", "ParameterClass", "ExpectedCount")]
  })
  do.call(rbind, rows)
}

mfrmr_gsv4q_decision <- function(evidence, coordinates, point_summary, jacobian,
                                  authorization_embedded) {
  expected <- mfrmr_gsv4c_expected_evidence()
  expected_counts <- mfrmr_gsv4q_expected_coordinate_counts()
  scenarios <- mfrmr_gsv4c_scenarios()
  key <- function(x) paste(x$ScenarioId, x$Point, x$ParameterClass, sep = "::")
  complete <- is.data.frame(evidence) && is.data.frame(coordinates) &&
    is.data.frame(point_summary) && is.data.frame(jacobian) &&
    nrow(evidence) == 96L && !anyDuplicated(key(evidence)) &&
    identical(sort(key(evidence)), sort(key(expected))) &&
    nrow(coordinates) == 888L && nrow(point_summary) == 24L &&
    nrow(jacobian) == 688L
  if (complete) {
    actual_coordinates <- as.data.frame(table(
      coordinates$ScenarioId, coordinates$Point,
      coordinates$ParameterClassFrozen
    ), stringsAsFactors = FALSE)
    names(actual_coordinates) <- c(
      "ScenarioId", "Point", "ParameterClass", "ActualCount"
    )
    counts <- Reduce(function(x, y) merge(
      x, y, by = c("ScenarioId", "Point", "ParameterClass"), all = TRUE
    ), list(
      evidence[c("ScenarioId", "Point", "ParameterClass", "CoordinateCount")],
      expected_counts, actual_coordinates
    ))
    actual_jacobian <- as.data.frame(table(
      jacobian$ScenarioId, jacobian$Point
    ), stringsAsFactors = FALSE)
    names(actual_jacobian) <- c("ScenarioId", "Point", "ActualJacobianRows")
    expected_jacobian <- merge(
      expand.grid(
        ScenarioId = scenarios$ScenarioId, Point = mfrmr_gsv4c_points,
        KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
      ),
      scenarios[c("ScenarioId", "JacobianRowsPerPoint")], by = "ScenarioId"
    )
    jacobian_counts <- merge(
      expected_jacobian, actual_jacobian,
      by = c("ScenarioId", "Point"), all = TRUE
    )
    point_keys <- paste(point_summary$ScenarioId, point_summary$Point, sep = "::")
    expected_point_keys <- paste(
      expected_jacobian$ScenarioId, expected_jacobian$Point, sep = "::"
    )
    complete <- nrow(counts) == 96L && !anyNA(counts) &&
      all(counts$CoordinateCount == counts$ExpectedCount) &&
      all(counts$ActualCount == counts$ExpectedCount) &&
      nrow(jacobian_counts) == 24L && !anyNA(jacobian_counts) &&
      all(jacobian_counts$JacobianRowsPerPoint ==
            jacobian_counts$ActualJacobianRows) &&
      !anyDuplicated(point_keys) &&
      identical(sort(point_keys), sort(expected_point_keys))
  }
  finite <- if (complete) {
    evidence$SlopeRegion == "finite_slope_region"
  } else logical()
  extreme <- if (complete) {
    evidence$SlopeRegion == "extreme_slope_review_handoff"
  } else logical()
  constructed <- if (complete) evidence$Point != "retained_solution" else logical()
  passed <- isTRUE(complete && authorization_embedded && all(finite | extreme) &&
    all(finite[constructed]) && all(evidence$EvaluationComplete) &&
    all(evidence$StructuralOraclePass) && all(evidence$AnalyticScorePass) &&
    all(is.finite(evidence$MaxAnalyticScoreCombinedRatio)) &&
    all(evidence$MaxAnalyticScoreCombinedRatio <= 1) &&
    all(is.finite(evidence$LogJacobianCombinedRatio)) &&
    all(evidence$LogJacobianCombinedRatio <= 1) &&
    all(is.finite(evidence$SlopeJacobianCombinedRatio)) &&
    all(evidence$SlopeJacobianCombinedRatio <= 1) &&
    all(evidence$FiniteDifferenceStatus[finite] == "pass") &&
    all(is.finite(evidence$FiniteDifferenceCombinedRatio[finite])) &&
    all(evidence$FiniteDifferenceCombinedRatio[finite] <= 1) &&
    all(evidence$FiniteDifferenceStatus[extreme] ==
          "not_applicable_extreme_slope") &&
    all(is.na(evidence$FiniteDifferenceCombinedRatio[extreme])) &&
    all(evidence$ExtremeSlopeReviewHandoff[extreme]) &&
    all(!evidence$SourceInferenceReady[extreme]) &&
    all(!evidence$CalibrationDataReused) &&
    all(evidence$DesignConfirmationEligible) &&
    all(!evidence$ConfirmationAuthorized))
  data.frame(
    ContractVersion = mfrmr_gsv4q_contract_version,
    Status = if (passed) "v4_candidate_score_confirmation_pass" else "rejected",
    CompleteDenominator = complete,
    BoundedV4RuleConfirmed = passed,
    ConsumedAuthorizationEmbedded = authorization_embedded,
    CalibrationDataReused = FALSE,
    CompletionFixtureReused = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE,
    BoundaryProven = FALSE,
    InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4q_validate_authorization <- function(authorization, identity,
                                                manifest, output_path) {
  required <- c(
    "ContractVersion", "Status", "RunnerIdentitySHA256", "ManifestSHA256",
    "AuthorizationSourceSHA256", "AuthorizationSHA256", "OutputPath",
    "ProcessId", "IssuedAtUTC", "ExecutionAuthorized", "IssuedNotExecuted",
    "ConsumedAtUTC", "ConsumedRowSHA256"
  )
  mfrmr_gsv4q_assert(
    is.data.frame(authorization) && nrow(authorization) == 1L &&
      all(required %in% names(authorization)),
    "An exact v4 confirmation authorization row is required."
  )
  mfrmr_gsv4q_assert(
    mfrmr_gsv4q_is_absolute_path(output_path),
    "V4 confirmation requires an absolute output path."
  )
  target <- normalizePath(output_path, winslash = "/", mustWork = FALSE)
  authorization_source <- file.path(
    mfrmr_gsv4q_validation_dir(),
    "gpcm-score-v4-confirmation-authorization-0.2.3.R"
  )
  mfrmr_gsv4q_assert(
    identical(authorization$ContractVersion,
              mfrmr_gsv4q_authorization_contract) &&
      identical(authorization$Status, "go_issued_not_executed") &&
      file.exists(authorization_source) &&
      identical(authorization$AuthorizationSourceSHA256,
                mfrmr_gscr_hash_file(authorization_source)) &&
      identical(authorization$RunnerIdentitySHA256, identity$IdentitySHA256) &&
      identical(authorization$ManifestSHA256, manifest$ManifestSHA256[1]) &&
      identical(authorization$OutputPath, target) &&
      mfrmr_gsv4q_is_absolute_path(authorization$OutputPath) &&
      identical(as.integer(authorization$ProcessId), as.integer(Sys.getpid())) &&
      isTRUE(authorization$ExecutionAuthorized) &&
      isTRUE(authorization$IssuedNotExecuted) &&
      is.na(authorization$ConsumedAtUTC) &&
      is.na(authorization$ConsumedRowSHA256) && !file.exists(target),
    "V4 confirmation authorization is absent, stale, mismatched, consumed, or occupied."
  )
  canonical <- authorization
  canonical$AuthorizationSHA256 <- NULL
  mfrmr_gsv4q_assert(
    identical(authorization$AuthorizationSHA256,
              mfrmr_gscr_hash_object(canonical)),
    "V4 confirmation authorization hash is invalid."
  )
  invisible(TRUE)
}

mfrmr_gsv4q_consume_authorization <- function(authorization) {
  consumed <- authorization
  consumed$Status <- "consumed_result_embedded"
  consumed$IssuedNotExecuted <- FALSE
  consumed$ConsumedAtUTC <- format(Sys.time(), tz = "UTC", usetz = TRUE)
  canonical <- consumed
  canonical$ConsumedRowSHA256 <- NULL
  consumed$ConsumedRowSHA256 <- mfrmr_gscr_hash_object(canonical)
  consumed
}

mfrmr_run_gpcm_score_v4_confirmation <- function(
    dry_run = TRUE, authorize = FALSE, authorization = NULL,
    output_path = NULL, progress = TRUE) {
  mfrmr_gsv4q_require_sources()
  identity <- mfrmr_gsv4q_identity()
  manifest <- mfrmr_gsv4q_manifest()
  design <- mfrmr_gsv4c_design_decision()
  if (isTRUE(dry_run)) return(list(
    contract_version = mfrmr_gsv4q_contract_version,
    identity = identity, manifest = manifest, design = design,
    executed = FALSE, fit_opened = FALSE, result_opened = FALSE,
    authorization_embedded = FALSE,
    confirmation_execution_authorized = FALSE
  ))
  mfrmr_gsv4q_assert(isTRUE(authorize),
                     "V4 confirmation requires explicit `authorize = TRUE`.")
  mfrmr_gsv4q_assert(length(output_path) == 1L && nzchar(output_path),
                     "V4 confirmation requires one explicit output path.")
  mfrmr_gsv4q_validate_authorization(
    authorization, identity, manifest, output_path
  )
  results <- lapply(seq_len(nrow(manifest)), function(index) {
    mfrmr_gsv4q_run_scenario(manifest[index, , drop = FALSE], progress)
  })
  coordinates <- do.call(rbind, lapply(results, `[[`, "coordinates"))
  evidence <- do.call(rbind, lapply(results, `[[`, "evidence"))
  point_summary <- do.call(rbind, lapply(results, `[[`, "point_summary"))
  jacobian <- do.call(rbind, lapply(results, `[[`, "jacobian"))
  consumed <- mfrmr_gsv4q_consume_authorization(authorization)
  out <- list(
    contract_version = mfrmr_gsv4q_contract_version,
    identity = identity, manifest = manifest, authorization = consumed,
    fits = do.call(rbind, lapply(results, `[[`, "fit")),
    coordinates = coordinates, evidence = evidence,
    point_summary = point_summary, jacobian = jacobian,
    decision = mfrmr_gsv4q_decision(
      evidence, coordinates, point_summary, jacobian,
      authorization_embedded = TRUE
    ),
    executed = TRUE, calibration_data_reused = FALSE,
    completion_fixture_reused = FALSE,
    general_num_score_tol_frozen = FALSE,
    boundary_proven = FALSE, inference_authorized = FALSE
  )
  saveRDS(out, output_path)
  out
}
