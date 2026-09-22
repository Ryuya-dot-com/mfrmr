# Dry-run-by-default runner for the single v4 calibration-only boundary
# completion. Execution requires a separate exact authorization row, and the
# consumed row is embedded in the saved result.

mfrmr_gsv4x_contract_version <-
  "mfrmr_gpcm_score_v4_boundary_completion_runner_v1"
mfrmr_gsv4x_sources_loaded <- FALSE

mfrmr_gsv4x_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v4-boundary-completion-runner-0\\.2\\.3\\.R$",
                     files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(hit[length(hit)], winslash = "/", mustWork = FALSE))
})

mfrmr_gsv4x_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4x_validation_dir <- function() {
  if (!is.na(mfrmr_gsv4x_source_dir) && dir.exists(mfrmr_gsv4x_source_dir)) {
    return(mfrmr_gsv4x_source_dir)
  }
  candidates <- c(file.path("inst", "validation"),
                  file.path("..", "inst", "validation"),
                  file.path("..", "..", "inst", "validation"), ".")
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-boundary-completion-design-0.2.3.R"
  ))]
  mfrmr_gsv4x_assert(length(candidates) > 0L,
                     "Cannot locate v4 completion runner sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4x_require_sources <- function() {
  target <- environment(mfrmr_gsv4x_require_sources)
  if (!isTRUE(get0("mfrmr_gsv4x_sources_loaded", envir = target,
                   inherits = FALSE, ifnotfound = FALSE))) {
    for (file in c("gpcm-score-v4-boundary-completion-design-0.2.3.R",
                   "gpcm-score-v3-confirmation-runner-0.2.3.R",
                   "gpcm-score-v4-rule-contract-0.2.3.R")) {
      sys.source(file.path(mfrmr_gsv4x_validation_dir(), file), envir = target)
    }
    assign("mfrmr_gsv4x_sources_loaded", TRUE, envir = target)
  }
  mfrmr_gsv3x_require_sources()
  invisible(TRUE)
}

mfrmr_gsv4x_identity <- function() {
  mfrmr_gsv4x_require_sources()
  validation_dir <- mfrmr_gsv4x_validation_dir()
  root <- normalizePath(file.path(validation_dir, "..", ".."),
                        winslash = "/", mustWork = TRUE)
  runtime <- mfrmr_gsv3r_runtime_identity(root)
  payload <- mfrmr_gscr_package_payload_identity()
  files <- c(
    V4Rule = "gpcm-score-v4-rule-contract-0.2.3.R",
    Retrospective = "gpcm-score-v4-retrospective-calibration-0.2.3.R",
    Design = "gpcm-score-v4-boundary-completion-design-0.2.3.R",
    V3ReplayRunner = "gpcm-score-v3-replay-runner-0.2.3.R",
    CompletionRunner = "gpcm-score-v4-boundary-completion-runner-0.2.3.R"
  )
  paths <- stats::setNames(file.path(validation_dir, unname(files)), names(files))
  hashes <- vapply(paths, mfrmr_gscr_hash_file, character(1L))
  out <- data.frame(
    ContractVersion = mfrmr_gsv4x_contract_version,
    PackagePayloadSHA256 = payload$sha256,
    V4RuleSHA256 = unname(hashes["V4Rule"]),
    RetrospectiveSHA256 = unname(hashes["Retrospective"]),
    DesignSHA256 = unname(hashes["Design"]),
    V3ReplayRunnerSHA256 = unname(hashes["V3ReplayRunner"]),
    CompletionRunnerSHA256 = unname(hashes["CompletionRunner"]),
    DevelopmentSourceLoaded = runtime$DevelopmentSourceLoaded,
    FreshProcessRequired = TRUE, ExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out$IdentitySHA256 <- mfrmr_gscr_hash_object(out)
  out
}

mfrmr_gsv4x_manifest <- function() {
  identity <- mfrmr_gsv4x_identity()
  out <- mfrmr_gsv4b_manifest()
  out$RunnerIdentitySHA256 <- identity$IdentitySHA256
  out$CompletionRunnerSHA256 <- identity$CompletionRunnerSHA256
  out$DesignSHA256 <- identity$DesignSHA256
  out$PackagePayloadSHA256 <- identity$PackagePayloadSHA256
  out$AuthorizationEmbedded <- FALSE
  canonical <- out
  canonical$ManifestSHA256 <- NULL
  out$ManifestSHA256 <- mfrmr_gscr_hash_object(canonical)
  out
}

mfrmr_gsv4x_fit <- function(manifest) {
  fixture <- mfrmr_gsv4b_fixture()
  mfrmr_gsv4x_assert(identical(fixture$sha256, manifest$FixtureSHA256),
                     "V4 completion fixture identity changed.")
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  started <- proc.time()[["elapsed"]]
  capture <- mfrmr_gscr_capture(fit_fun(
    fixture$data, person = "Person", facets = c("Rater", "Criterion"),
    score = "Score", rating_min = 1L, rating_max = 4L,
    keep_original = TRUE, method = "MML", model = "GPCM",
    step_facet = "Criterion", slope_facet = "Criterion",
    quad_points = as.integer(manifest$QuadPoints),
    maxit = as.integer(manifest$Maxit), reltol = as.numeric(manifest$Reltol),
    optimizer = "L-BFGS-B", mml_engine = "direct"
  ))
  list(fit = capture$value, error = capture$error, warnings = capture$warnings,
       elapsed = proc.time()[["elapsed"]] - started, fixture = fixture)
}

mfrmr_gsv4x_point_audit <- function(fit, manifest) {
  scenario <- manifest
  point <- "finite_slope_stress_forward"
  base <- mfrmr_gsv3r_point_audit(fit, scenario, point)
  context <- mfrmr_num_fit_context(fit)
  par <- mfrmr_gscr_point(fit, point)
  structural <- mfrmr_gsv3r_structural_audit(context, par)
  classification <- mfrmr_gsv4_classify_log_slopes(
    structural$oracle$log_slopes, point
  )
  mfrmr_gsv4x_assert(
    identical(classification$Region, "finite_slope_region") &&
      isTRUE(classification$AllowanceApplied),
    "The sealed v4 construction is not in its finite region."
  )
  package_score <- suppressWarnings(as.numeric(context$gr(par)))
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
  ratio <- abs(package_score - reference) / allowance

  coordinates <- base$coordinates
  coordinates$SlopeRegion <- classification$Region
  coordinates$FiniteDifferenceReference <- reference
  coordinates$FiniteDifferenceReferenceSpread <- spread
  coordinates$FiniteDifferenceRoundoffBound <- roundoff
  coordinates$FiniteDifferenceCombinedAllowance <- allowance
  coordinates$FiniteDifferenceCombinedRatio <- ratio
  coordinates$V4ConstructionRawExcess <- classification$RawExcess
  coordinates$V4ConstructionAllowance <- classification$Allowance
  for (index in seq_along(mfrmr_gsc_relative_steps)) {
    label <- gsub("[.]", "p", format(
      mfrmr_gsc_relative_steps[index], scientific = TRUE
    ))
    coordinates[[paste0("FivePointScore_", label)]] <- derivative[[index]]$score
  }
  evidence <- do.call(rbind, lapply(mfrmr_gsv4b_classes, function(class) {
    keep <- coordinates$ParameterClassFrozen == class
    data.frame(
      ContractVersion = mfrmr_gsv4_contract_version,
      ScenarioId = manifest$ScenarioId, Point = point, ParameterClass = class,
      CoordinateCount = sum(keep), SlopeRegion = classification$Region,
      StructuralOraclePass = all(coordinates$StructuralOraclePass[keep]),
      AnalyticScorePass = all(coordinates$AnalyticScoreCombinedRatio[keep] <= 1),
      MaxAnalyticScoreCombinedRatio =
        max(coordinates$AnalyticScoreCombinedRatio[keep]),
      FiniteDifferenceStatus = if (
        all(is.finite(ratio[keep])) && all(ratio[keep] <= 1)) "pass" else "fail",
      FiniteDifferenceCombinedRatio = max(ratio[keep]),
      LogJacobianCombinedRatio = max(base$jacobian$LogCombinedRatio),
      SlopeJacobianCombinedRatio = max(base$jacobian$SlopeCombinedRatio),
      V4ConstructionRawExcess = classification$RawExcess,
      V4ConstructionAllowance = classification$Allowance,
      EvaluationComplete = all(is.finite(unlist(coordinates[keep, c(
        "PackageAnalyticScore", "IndependentAnalyticScore",
        "AnalyticScoreCombinedRatio", "FiniteDifferenceReference",
        "FiniteDifferenceCombinedRatio"
      )], use.names = FALSE))),
      CalibrationOnly = TRUE, ConfirmationEligible = FALSE,
      ConfirmationAuthorized = FALSE, stringsAsFactors = FALSE
    )
  }))
  point_summary <- base$point_summary
  point_summary$SlopeRegion <- classification$Region
  point_summary$FiniteDifferenceStatus <- if (
    all(is.finite(ratio)) && all(ratio <= 1)) "pass" else "fail"
  point_summary$MaxFiniteDifferenceCombinedRatio <- max(ratio)
  point_summary$V4ConstructionRawExcess <- classification$RawExcess
  point_summary$V4ConstructionAllowance <- classification$Allowance
  jacobian <- base$jacobian
  jacobian$SlopeRegion <- classification$Region
  list(coordinates = coordinates, evidence = evidence,
       point_summary = point_summary, jacobian = jacobian)
}

mfrmr_gsv4x_decision <- function(audit, authorization_embedded) {
  counts <- table(audit$coordinates$ParameterClassFrozen)
  expected_counts <- c(owner_additive = 5L, other_additive = 2L,
                       steps = 12L, log_slopes = 5L)
  complete <- nrow(audit$evidence) == 4L &&
    nrow(audit$coordinates) == 24L && nrow(audit$point_summary) == 1L &&
    nrow(audit$jacobian) == 30L &&
    identical(as.integer(counts[names(expected_counts)]),
              as.integer(expected_counts)) &&
    all(audit$evidence$CoordinateCount == as.integer(expected_counts))
  passed <- isTRUE(complete && authorization_embedded &&
    all(audit$evidence$EvaluationComplete) &&
    all(audit$evidence$StructuralOraclePass) &&
    all(audit$evidence$AnalyticScorePass) &&
    all(audit$evidence$FiniteDifferenceStatus == "pass") &&
    all(audit$evidence$FiniteDifferenceCombinedRatio <= 1) &&
    all(audit$evidence$LogJacobianCombinedRatio <= 1) &&
    all(audit$evidence$SlopeJacobianCombinedRatio <= 1) &&
    all(audit$evidence$CalibrationOnly) &&
    all(!audit$evidence$ConfirmationEligible) &&
    all(!audit$evidence$ConfirmationAuthorized))
  data.frame(
    ContractVersion = mfrmr_gsv4x_contract_version,
    Status = if (passed) "boundary_completion_calibration_pass" else "rejected",
    CompleteDenominator = complete, NumericalRulePass = passed,
    ConsumedAuthorizationEmbedded = authorization_embedded,
    CalibrationOnly = TRUE, ConfirmationEligible = FALSE,
    V4FreezeReady = passed, V4ConfirmationAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE, InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4x_validate_authorization <- function(authorization, identity,
                                                manifest, output_path) {
  required <- c(
    "Status", "ContractVersion", "RunnerIdentitySHA256", "ManifestSHA256",
    "AuthorizationSourceSHA256", "AuthorizationSHA256", "OutputPath",
    "ProcessId", "IssuedAtUTC", "ExecutionAuthorized", "IssuedNotExecuted",
    "ConsumedAtUTC", "ConsumedRowSHA256"
  )
  mfrmr_gsv4x_assert(
    is.data.frame(authorization) && nrow(authorization) == 1L &&
      all(required %in% names(authorization)),
    "An exact v4 completion authorization row is required."
  )
  target <- normalizePath(output_path, winslash = "/", mustWork = FALSE)
  authorization_source <- file.path(
    mfrmr_gsv4x_validation_dir(),
    "gpcm-score-v4-boundary-completion-authorization-0.2.3.R"
  )
  mfrmr_gsv4x_assert(
    identical(authorization$Status, "go_issued_not_executed") &&
      identical(authorization$ContractVersion,
                "mfrmr_gpcm_score_v4_boundary_completion_authorization_v1") &&
      file.exists(authorization_source) &&
      identical(authorization$AuthorizationSourceSHA256,
                mfrmr_gscr_hash_file(authorization_source)) &&
      identical(authorization$RunnerIdentitySHA256, identity$IdentitySHA256) &&
      identical(authorization$ManifestSHA256, manifest$ManifestSHA256[1]) &&
      identical(authorization$OutputPath, target) &&
      identical(as.integer(authorization$ProcessId), as.integer(Sys.getpid())) &&
      isTRUE(authorization$ExecutionAuthorized) &&
      isTRUE(authorization$IssuedNotExecuted) &&
      is.na(authorization$ConsumedAtUTC) &&
      is.na(authorization$ConsumedRowSHA256) && !file.exists(target),
    "V4 completion authorization is absent, stale, mismatched, consumed, or occupied."
  )
  canonical <- authorization
  canonical$AuthorizationSHA256 <- NULL
  mfrmr_gsv4x_assert(
    identical(authorization$AuthorizationSHA256,
              mfrmr_gscr_hash_object(canonical)),
    "V4 completion authorization hash is invalid."
  )
  invisible(TRUE)
}

mfrmr_gsv4x_consume_authorization <- function(authorization) {
  consumed <- authorization
  consumed$Status <- "consumed_result_embedded"
  consumed$IssuedNotExecuted <- FALSE
  consumed$ConsumedAtUTC <- format(Sys.time(), tz = "UTC", usetz = TRUE)
  canonical <- consumed
  canonical$ConsumedRowSHA256 <- NULL
  consumed$ConsumedRowSHA256 <- mfrmr_gscr_hash_object(canonical)
  consumed
}

mfrmr_run_gpcm_score_v4_boundary_completion <- function(
    dry_run = TRUE, authorize = FALSE, authorization = NULL,
    output_path = NULL, progress = TRUE) {
  mfrmr_gsv4x_require_sources()
  identity <- mfrmr_gsv4x_identity()
  manifest <- mfrmr_gsv4x_manifest()
  design <- mfrmr_gsv4b_design_decision()
  if (isTRUE(dry_run)) return(list(
    contract_version = mfrmr_gsv4x_contract_version, identity = identity,
    manifest = manifest, design = design, executed = FALSE,
    fit_opened = FALSE, authorization_embedded = FALSE
  ))
  mfrmr_gsv4x_assert(isTRUE(authorize),
                     "V4 completion requires explicit `authorize = TRUE`.")
  mfrmr_gsv4x_assert(length(output_path) == 1L && nzchar(output_path),
                     "V4 completion requires one explicit output path.")
  mfrmr_gsv4x_validate_authorization(
    authorization, identity, manifest, output_path
  )
  if (isTRUE(progress)) message("GPCM score v4 boundary completion: ",
                                manifest$ScenarioId)
  fitted <- mfrmr_gsv4x_fit(manifest)
  mfrmr_gsv4x_assert(
    !is.null(fitted$fit) && length(fitted$fit$opt$par) > 0L &&
      all(is.finite(fitted$fit$opt$par)),
    paste0("V4 completion fit failed: ", fitted$error)
  )
  audit <- mfrmr_gsv4x_point_audit(fitted$fit, manifest)
  consumed <- mfrmr_gsv4x_consume_authorization(authorization)
  fit_row <- data.frame(
    ScenarioId = manifest$ScenarioId, FixtureSHA256 = fitted$fixture$sha256,
    FitSucceeded = TRUE, OptimizerConvergence = as.integer(fitted$fit$opt$convergence),
    FitReadiness = as.character(fitted$fit$summary$FitReadiness[1]),
    InferenceReady = isTRUE(fitted$fit$summary$InferenceReady[1]),
    Error = fitted$error, Warnings = paste(fitted$warnings, collapse = " | "),
    ElapsedSeconds = fitted$elapsed, stringsAsFactors = FALSE
  )
  out <- list(
    contract_version = mfrmr_gsv4x_contract_version,
    identity = identity, manifest = manifest, authorization = consumed,
    fit = fit_row, coordinates = audit$coordinates,
    evidence = audit$evidence, point_summary = audit$point_summary,
    jacobian = audit$jacobian,
    decision = mfrmr_gsv4x_decision(audit, authorization_embedded = TRUE),
    executed = TRUE, calibration_only = TRUE,
    confirmation_authorized = FALSE
  )
  saveRDS(out, output_path)
  out
}
