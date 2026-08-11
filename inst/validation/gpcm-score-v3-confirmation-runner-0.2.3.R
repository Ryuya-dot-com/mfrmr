# Record-consuming GPCM score v3 confirmation runner. Dry-run is the default.
# Execution requires a separate exact authorization record and an absent output
# target. Sourcing this file or calling dry-run never fits a model.

mfrmr_gsv3x_contract_version <- "mfrmr_gpcm_score_v3_confirmation_runner_v1"
mfrmr_gsv3x_sources_loaded <- FALSE

mfrmr_gsv3x_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v3-confirmation-runner-0\\.2\\.3\\.R$", files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv3x_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv3x_validation_dir <- function() {
  if (!is.na(mfrmr_gsv3x_source_dir) && dir.exists(mfrmr_gsv3x_source_dir)) {
    return(mfrmr_gsv3x_source_dir)
  }
  candidates <- c(file.path("inst", "validation"),
                  file.path("..", "inst", "validation"),
                  file.path("..", "..", "inst", "validation"),
                  file.path("..", "..", "..", "inst", "validation"), ".")
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v3-confirmation-design-0.2.3.R"
  ))]
  mfrmr_gsv3x_assert(length(candidates) > 0L,
                     "Cannot locate confirmation runner sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv3x_require_sources <- function() {
  target <- environment(mfrmr_gsv3x_require_sources)
  if (!isTRUE(get0("mfrmr_gsv3x_sources_loaded", envir = target,
                   inherits = FALSE, ifnotfound = FALSE))) {
    for (file in c("gpcm-score-v3-confirmation-design-0.2.3.R",
                   "gpcm-score-v3-replay-runner-0.2.3.R")) {
      sys.source(file.path(mfrmr_gsv3x_validation_dir(), file), envir = target)
    }
    assign("mfrmr_gsv3x_sources_loaded", TRUE, envir = target)
  }
  mfrmr_gsv3r_require_sources()
  invisible(TRUE)
}

mfrmr_gsv3x_identity <- function() {
  mfrmr_gsv3x_require_sources()
  validation_dir <- mfrmr_gsv3x_validation_dir()
  root <- normalizePath(file.path(validation_dir, "..", ".."),
                        winslash = "/", mustWork = TRUE)
  runtime <- mfrmr_gsv3r_runtime_identity(root)
  payload <- mfrmr_gscr_package_payload_identity()
  files <- c(
    Freeze = "gpcm-score-v3-freeze-contract-0.2.3.R",
    Design = "gpcm-score-v3-confirmation-design-0.2.3.R",
    Rule = "gpcm-score-v3-rule-contract-0.2.3.R",
    ReplayRunner = "gpcm-score-v3-replay-runner-0.2.3.R",
    ConfirmationRunner = "gpcm-score-v3-confirmation-runner-0.2.3.R"
  )
  source_paths <- stats::setNames(
    file.path(validation_dir, unname(files)), names(files)
  )
  hashes <- vapply(source_paths, mfrmr_gscr_hash_file, character(1L))
  out <- data.frame(
    ContractVersion = mfrmr_gsv3x_contract_version,
    PackagePayloadSHA256 = payload$sha256,
    FreezeSHA256 = unname(hashes["Freeze"]),
    DesignSHA256 = unname(hashes["Design"]),
    RuleSHA256 = unname(hashes["Rule"]),
    ReplayRunnerSHA256 = unname(hashes["ReplayRunner"]),
    ConfirmationRunnerSHA256 = unname(hashes["ConfirmationRunner"]),
    FrozenReplayIdentity = mfrmr_gsv3c_frozen_replay_identity,
    DevelopmentSourceLoaded = runtime$DevelopmentSourceLoaded,
    FreshProcessRequired = TRUE,
    ConfirmationExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out$IdentitySHA256 <- mfrmr_gscr_hash_object(out)
  out
}

mfrmr_gsv3x_manifest <- function() {
  identity <- mfrmr_gsv3x_identity()
  out <- mfrmr_gsv3c_scenarios()
  out$RunnerIdentitySHA256 <- identity$IdentitySHA256
  out$ConfirmationRunnerSHA256 <- identity$ConfirmationRunnerSHA256
  out$DesignSHA256 <- identity$DesignSHA256
  out$PackagePayloadSHA256 <- identity$PackagePayloadSHA256
  out$ResultOpened <- FALSE
  out$ConfirmationExecutionAuthorized <- FALSE
  canonical <- out
  canonical$ManifestSHA256 <- NULL
  out$ManifestSHA256 <- mfrmr_gscr_hash_object(canonical)
  out
}

mfrmr_gsv3x_fit <- function(scenario) {
  fixture <- mfrmr_gsv3c_fixture(as.character(scenario$DesignId))
  mfrmr_gsv3x_assert(
    identical(fixture$sha256, as.character(scenario$FixtureSHA256)),
    "Confirmation fixture identity changed."
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
  list(fit = capture$value, error = capture$error, warnings = capture$warnings,
       elapsed = proc.time()[["elapsed"]] - started, fixture = fixture)
}

mfrmr_gsv3x_failed_evidence <- function(scenario) {
  grid <- expand.grid(Point = mfrmr_gsv3c_points,
                      ParameterClass = mfrmr_gsv3c_classes,
                      stringsAsFactors = FALSE)
  data.frame(
    ContractVersion = mfrmr_gsv3_contract_version,
    ScenarioId = as.character(scenario$ScenarioId), Point = grid$Point,
    ParameterClass = grid$ParameterClass, CoordinateCount = 0L,
    SlopeRegion = "not_evaluable", StructuralOraclePass = FALSE,
    AnalyticScorePass = FALSE, MaxAnalyticScoreCombinedRatio = NA_real_,
    FiniteDifferenceStatus = "not_evaluable",
    FiniteDifferenceCombinedRatio = NA_real_,
    LogJacobianCombinedRatio = NA_real_, SlopeJacobianCombinedRatio = NA_real_,
    ExtremeSlopeReviewHandoff = FALSE, SourceInferenceReady = FALSE,
    EvaluationComplete = FALSE, CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_gsv3x_run_scenario <- function(scenario, progress = TRUE) {
  if (isTRUE(progress)) message("GPCM score v3 confirmation: ", scenario$ScenarioId)
  fitted <- mfrmr_gsv3x_fit(scenario)
  fit <- fitted$fit
  succeeded <- !is.null(fit) && length(fit$opt$par) > 0L &&
    all(is.finite(fit$opt$par))
  fit_row <- data.frame(
    ScenarioId = as.character(scenario$ScenarioId),
    FixtureSHA256 = fitted$fixture$sha256, Rows = nrow(fitted$fixture$data),
    FitSucceeded = succeeded, Error = fitted$error,
    Warnings = paste(fitted$warnings, collapse = " | "),
    ElapsedSeconds = fitted$elapsed,
    OptimizerConvergence = if (succeeded) as.integer(fit$opt$convergence) else NA_integer_,
    FitReadiness = if (succeeded) as.character(fit$summary$FitReadiness[1]) else "not_available",
    InferenceReady = succeeded && isTRUE(fit$summary$InferenceReady[1]),
    ConfirmationAuthorized = FALSE, stringsAsFactors = FALSE
  )
  if (!succeeded) return(list(fit = fit_row, coordinates = data.frame(),
                              evidence = mfrmr_gsv3x_failed_evidence(scenario),
                              point_summary = data.frame(), jacobian = data.frame()))
  audits <- lapply(mfrmr_gsv3c_points, function(point) {
    mfrmr_gsv3r_point_audit(fit, scenario, point)
  })
  list(fit = fit_row,
       coordinates = do.call(rbind, lapply(audits, `[[`, "coordinates")),
       evidence = do.call(rbind, lapply(audits, `[[`, "evidence")),
       point_summary = do.call(rbind, lapply(audits, `[[`, "point_summary")),
       jacobian = do.call(rbind, lapply(audits, `[[`, "jacobian")))
}

mfrmr_gsv3x_decision <- function(evidence, coordinates, point_summary, jacobian) {
  expected <- mfrmr_gsv3c_expected_evidence()
  key <- function(x) paste(x$ScenarioId, x$Point, x$ParameterClass, sep = "::")
  scenarios <- mfrmr_gsv3c_scenarios()
  complete <- is.data.frame(evidence) && is.data.frame(coordinates) &&
    is.data.frame(point_summary) && is.data.frame(jacobian) &&
    nrow(evidence) == 96L &&
    !anyDuplicated(key(evidence)) && identical(sort(key(evidence)), sort(key(expected))) &&
    nrow(coordinates) == 560L && nrow(point_summary) == 24L &&
    nrow(jacobian) == 376L
  if (complete) {
    actual_coordinates <- as.data.frame(table(
      coordinates$ScenarioId, coordinates$Point,
      coordinates$ParameterClassFrozen
    ), stringsAsFactors = FALSE)
    names(actual_coordinates) <- c(
      "ScenarioId", "Point", "ParameterClass", "ActualCount"
    )
    coordinate_counts <- merge(
      evidence[c("ScenarioId", "Point", "ParameterClass", "CoordinateCount")],
      actual_coordinates,
      by = c("ScenarioId", "Point", "ParameterClass"), all = TRUE
    )
    actual_jacobian <- as.data.frame(table(
      jacobian$ScenarioId, jacobian$Point
    ), stringsAsFactors = FALSE)
    names(actual_jacobian) <- c("ScenarioId", "Point", "ActualJacobianRows")
    expected_jacobian <- merge(
      expand.grid(ScenarioId = scenarios$ScenarioId, Point = mfrmr_gsv3c_points,
                  stringsAsFactors = FALSE),
      scenarios[c("ScenarioId", "JacobianRowsPerPoint")], by = "ScenarioId"
    )
    jacobian_counts <- merge(expected_jacobian, actual_jacobian,
                             by = c("ScenarioId", "Point"), all = TRUE)
    complete <- nrow(coordinate_counts) == 96L && !anyNA(coordinate_counts) &&
      all(coordinate_counts$CoordinateCount == coordinate_counts$ActualCount) &&
      nrow(jacobian_counts) == 24L && !anyNA(jacobian_counts) &&
      all(jacobian_counts$JacobianRowsPerPoint ==
            jacobian_counts$ActualJacobianRows)
  }
  finite <- if (complete) evidence$SlopeRegion == "finite_slope_region" else logical()
  extreme <- if (complete) evidence$SlopeRegion == "extreme_slope_review_handoff" else logical()
  passed <- isTRUE(complete && all(finite | extreme) &&
    all(evidence$SlopeRegion[evidence$Point != "retained_solution"] ==
          "finite_slope_region") &&
    all(evidence$EvaluationComplete %in% TRUE) &&
    all(evidence$StructuralOraclePass %in% TRUE) &&
    all(evidence$AnalyticScorePass %in% TRUE) &&
    all(is.finite(evidence$LogJacobianCombinedRatio)) &&
    all(evidence$LogJacobianCombinedRatio <= 1) &&
    all(is.finite(evidence$SlopeJacobianCombinedRatio)) &&
    all(evidence$SlopeJacobianCombinedRatio <= 1) &&
    all(evidence$FiniteDifferenceStatus[finite] == "pass") &&
    all(is.finite(evidence$FiniteDifferenceCombinedRatio[finite])) &&
    all(evidence$FiniteDifferenceCombinedRatio[finite] <= 1) &&
    all(evidence$FiniteDifferenceStatus[extreme] == "not_applicable_extreme_slope") &&
    all(is.na(evidence$FiniteDifferenceCombinedRatio[extreme])) &&
    all(evidence$ExtremeSlopeReviewHandoff[extreme]) &&
    all(!evidence$SourceInferenceReady[extreme]) &&
    all(evidence$CalibrationAuthorized %in% FALSE) &&
    all(evidence$ConfirmationAuthorized %in% FALSE))
  data.frame(
    ContractVersion = mfrmr_gsv3x_contract_version,
    Status = if (passed) "candidate_score_confirmation_pass" else "rejected",
    CompleteDenominator = complete, FrozenRulePass = passed,
    GeneralNUMSCORETOLFrozen = FALSE, BoundaryProven = FALSE,
    InferenceAuthorized = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_gsv3x_validate_authorization <- function(authorization, identity,
                                                manifest, output_path) {
  required <- c("Status", "RunnerIdentitySHA256", "ManifestSHA256",
                "OutputPath", "ExecutionAuthorized")
  mfrmr_gsv3x_assert(is.data.frame(authorization) && nrow(authorization) == 1L &&
                       all(required %in% names(authorization)),
                     "A separate exact confirmation authorization record is required.")
  normalized <- normalizePath(output_path, winslash = "/", mustWork = FALSE)
  mfrmr_gsv3x_assert(
    identical(authorization$Status, "go_issued_not_executed") &&
      identical(authorization$RunnerIdentitySHA256, identity$IdentitySHA256) &&
      identical(authorization$ManifestSHA256, manifest$ManifestSHA256[1]) &&
      identical(authorization$OutputPath, normalized) &&
      isTRUE(authorization$ExecutionAuthorized) && !file.exists(normalized),
    "Confirmation authorization is absent, stale, mismatched, or already consumed."
  )
  invisible(TRUE)
}

mfrmr_run_gpcm_score_v3_confirmation <- function(
    dry_run = TRUE, authorize = FALSE, authorization = NULL,
    output_path = NULL, progress = TRUE) {
  mfrmr_gsv3x_require_sources()
  identity <- mfrmr_gsv3x_identity()
  manifest <- mfrmr_gsv3x_manifest()
  design <- mfrmr_gsv3c_design_decision()
  if (isTRUE(dry_run)) return(list(
    contract_version = mfrmr_gsv3x_contract_version, identity = identity,
    manifest = manifest, design = design, executed = FALSE,
    result_opened = FALSE, confirmation_execution_authorized = FALSE
  ))
  mfrmr_gsv3x_assert(isTRUE(authorize),
                     "Confirmation requires explicit `authorize = TRUE`.")
  mfrmr_gsv3x_assert(length(output_path) == 1L && nzchar(output_path),
                     "Confirmation requires one explicit output path.")
  mfrmr_gsv3x_validate_authorization(authorization, identity, manifest, output_path)
  results <- lapply(seq_len(nrow(manifest)), function(i) {
    mfrmr_gsv3x_run_scenario(manifest[i, , drop = FALSE], progress)
  })
  coordinates <- do.call(rbind, lapply(results, `[[`, "coordinates"))
  evidence <- do.call(rbind, lapply(results, `[[`, "evidence"))
  point_summary <- do.call(rbind, lapply(results, `[[`, "point_summary"))
  jacobian <- do.call(rbind, lapply(results, `[[`, "jacobian"))
  out <- list(contract_version = mfrmr_gsv3x_contract_version,
              identity = identity, manifest = manifest,
              fits = do.call(rbind, lapply(results, `[[`, "fit")),
              coordinates = coordinates, evidence = evidence,
              point_summary = point_summary, jacobian = jacobian,
              decision = mfrmr_gsv3x_decision(evidence, coordinates,
                                               point_summary, jacobian),
              executed = TRUE, general_num_score_tol_frozen = FALSE,
              boundary_proven = FALSE, inference_authorized = FALSE)
  saveRDS(out, output_path)
  out
}
