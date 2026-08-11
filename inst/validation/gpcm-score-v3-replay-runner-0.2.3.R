# Repository-only identity-bound replay runner for the GPCM score-rule v3.
#
# The default is dry-run. Explicit execution replays the same eight
# deterministic v2 calibration cells, but evaluates the v3 rule with complete
# independent analytic-score and entrywise Jacobian evidence. It is neither a
# recovery simulation nor disjoint confirmation and cannot change v2.

mfrmr_gsv3r_contract_version <- "mfrmr_gpcm_score_v3_replay_v1"
mfrmr_gsv3r_sources_loaded <- FALSE
mfrmr_gsv3r_expected_v2_sha256 <-
  "c3bc7cd84ecf930a1b52fdfbd1c9f965aceb9072c7ee675dc4e0e42363f0f5dc"
mfrmr_gsv3r_expected_attribution_sha256 <-
  "3a98f86bafa44c49d5826e1826162c71314d486545b38481fbe734b746721c7f"

mfrmr_gsv3r_source_dir <- local({
  files <- unlist(lapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) character(0) else as.character(value)
  }), use.names = FALSE)
  hit <- files[grepl("gpcm-score-v3-replay-runner-0\\.2\\.3\\.R$", files)]
  if (length(hit) == 0L) return(NA_character_)
  dirname(normalizePath(
    hit[length(hit)], winslash = "/", mustWork = FALSE
  ))
})

mfrmr_gsv3r_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv3r_validation_dir <- function() {
  if (!is.na(mfrmr_gsv3r_source_dir) && dir.exists(mfrmr_gsv3r_source_dir)) {
    return(mfrmr_gsv3r_source_dir)
  }
  candidates <- c(
    file.path("inst", "validation"),
    file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"),
    file.path("..", "..", "..", "inst", "validation"),
    "."
  )
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v3-rule-contract-0.2.3.R"
  ))]
  if (length(candidates) == 0L) {
    stop("Cannot locate the GPCM score v3 replay sources.", call. = FALSE)
  }
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv3r_require_sources <- function() {
  target <- environment(mfrmr_gsv3r_require_sources)
  source_files <- c(
    "gpcm-score-v3-rule-contract-0.2.3.R",
    "gpcm-score-calibration-runner-0.2.3.R",
    "gpcm-extreme-score-attribution-0.2.3.R"
  )
  required <- c(
    "mfrmr_gsv3_contract", "mfrmr_gsv3_allowance",
    "mfrmr_gsv3_classify_log_slopes", "mfrmr_gsv3_decision",
    "mfrmr_gscr_manifest", "mfrmr_gscr_fit", "mfrmr_gscr_point",
    "mfrmr_gscr_five_point_bundle", "mfrmr_gscr_parameter_class",
    "mfrmr_gscr_package_payload_identity", "mfrmr_gscr_hash_file",
    "mfrmr_gscr_hash_object", "mfrmr_gsea_independent_score",
    "mfrmr_num_fit_context", "mfrmr_num_logprob_bundle",
    "mfrmr_num_gpcm_jacobian_from_free", "mfrmr_num_get",
    "mfrmr_gno_independent_oracle", "mfrmr_gno_probability_difference",
    "mfrmr_gno_limits"
  )
  if (!isTRUE(get0("mfrmr_gsv3r_sources_loaded", envir = target,
                   inherits = FALSE, ifnotfound = FALSE))) {
    for (file in source_files) {
      sys.source(file.path(mfrmr_gsv3r_validation_dir(), file), envir = target)
    }
    assign("mfrmr_gsv3r_sources_loaded", TRUE, envir = target)
  }
  if (exists("mfrmr_gsea_require_sources", envir = target,
             inherits = FALSE)) {
    get("mfrmr_gsea_require_sources", envir = target,
        inherits = FALSE)()
  }
  available <- vapply(required, exists, logical(1), envir = target,
                      inherits = FALSE)
  mfrmr_gsv3r_assert(
    all(available),
    paste0("The GPCM score v3 replay source chain is incomplete: ",
           paste(required[!available], collapse = ", "), ".")
  )
  invisible(TRUE)
}

mfrmr_gsv3r_default_artifacts <- function() {
  root <- normalizePath(
    file.path(mfrmr_gsv3r_validation_dir(), "..", ".."),
    winslash = "/", mustWork = TRUE
  )
  directory <- file.path(
    root, "validation-results",
    "gpcm-score-calibration-v2-source-bound-final"
  )
  c(
    V2 = file.path(directory, "gpcm-score-calibration-v2.rds"),
    Attribution = file.path(directory, "extreme-score-attribution.rds")
  )
}

mfrmr_gsv3r_runtime_identity <- function(expected_root = NULL) {
  if (is.null(expected_root)) {
    expected_root <- normalizePath(
      file.path(mfrmr_gsv3r_validation_dir(), "..", ".."),
      winslash = "/", mustWork = TRUE
    )
  }
  expected_root <- normalizePath(
    expected_root, winslash = "/", mustWork = TRUE
  )
  namespace <- asNamespace("mfrmr")
  namespace_path <- normalizePath(
    getNamespaceInfo(namespace, "path"), winslash = "/", mustWork = TRUE
  )
  namespace_spec <- getNamespaceInfo(namespace, "spec")
  description <- read.dcf(file.path(expected_root, "DESCRIPTION"))
  source_version <- unname(description[1, "Version"])
  namespace_version <- unname(namespace_spec["version"])
  development_source <- identical(namespace_path, expected_root) &&
    identical(namespace_version, source_version)
  mfrmr_gsv3r_assert(
    development_source,
    paste0(
      "The loaded mfrmr namespace is not the exact development source. ",
      "Run `devtools::load_all(quiet = TRUE)` from the repository first."
    )
  )
  data.frame(
    ExpectedSourceRoot = expected_root,
    LoadedNamespacePath = namespace_path,
    SourceVersion = source_version,
    NamespaceVersion = namespace_version,
    DevelopmentSourceLoaded = development_source,
    FreshSessionRequired = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3r_validate_artifacts <- function(artifacts = NULL) {
  mfrmr_gsv3r_require_sources()
  mfrmr_gsv3r_runtime_identity()
  if (is.null(artifacts)) artifacts <- mfrmr_gsv3r_default_artifacts()
  artifact_names <- names(artifacts)
  artifacts <- as.character(artifacts)
  names(artifacts) <- artifact_names
  mfrmr_gsv3r_assert(
    length(artifacts) == 2L && all(c("V2", "Attribution") %in% names(artifacts)),
    "Artifacts must name exactly `V2` and `Attribution`."
  )
  artifacts <- artifacts[c("V2", "Attribution")]
  mfrmr_gsv3r_assert(
    all(file.exists(artifacts)),
    "The immutable v2 or attribution artifact is unavailable."
  )
  hashes <- vapply(artifacts, mfrmr_gscr_hash_file, character(1L))
  mfrmr_gsv3r_assert(
    identical(unname(hashes["V2"]), mfrmr_gsv3r_expected_v2_sha256) &&
      identical(unname(hashes["Attribution"]),
                mfrmr_gsv3r_expected_attribution_sha256),
    "The immutable v2 or attribution artifact identity changed."
  )
  v2 <- readRDS(artifacts["V2"])
  attribution <- readRDS(artifacts["Attribution"])
  mfrmr_gsv3r_assert(
    identical(v2$decision$Status, "rejected") &&
      identical(v2$decision$GeneralNUMSCORETOLStatus, "pilot_required") &&
      isTRUE(v2$executed) && !isTRUE(v2$calibration_authorized_by_result) &&
      !isTRUE(v2$general_num_score_tol_frozen) &&
      !isTRUE(v2$confirmation_authorized),
    "The source v2 object no longer preserves the rejected calibration."
  )
  mfrmr_gsv3r_assert(
    identical(attribution$decision$Status, "attribution_agreement") &&
      identical(attribution$decision$V2CalibrationStatus,
                "rejected_unchanged") &&
      isTRUE(attribution$executed) &&
      !isTRUE(attribution$calibration_result_changed) &&
      !isTRUE(attribution$confirmation_authorized),
    "The source attribution object no longer preserves v2 unchanged."
  )
  current_payload <- mfrmr_gscr_package_payload_identity()$sha256
  mfrmr_gsv3r_assert(
    identical(as.character(v2$identity$PackagePayloadSHA256), current_payload),
    "The current package payload differs from the immutable v2 payload."
  )
  list(
    paths = artifacts,
    hashes = hashes,
    v2 = v2,
    attribution = attribution
  )
}

mfrmr_gsv3r_reuse_audit <- function(validated) {
  mfrmr_gsv3r_require_sources()
  expected <- mfrmr_gsv3_expected_grid()
  key <- function(data) paste(
    data$ScenarioId, data$Point, data$ParameterClass, sep = "::"
  )
  v2_keys <- intersect(key(expected), key(validated$v2$evidence))
  attribution_keys <- intersect(
    key(expected), key(validated$attribution$evidence)
  )
  exact_jacobian_columns <- c(
    "LogJacobianCombinedRatio", "SlopeJacobianCombinedRatio"
  )
  exact_jacobian_points <- if (
      all(exact_jacobian_columns %in% names(validated$v2$point_summary))) {
    sum(stats::complete.cases(
      validated$v2$point_summary[, exact_jacobian_columns, drop = FALSE]
    ))
  } else 0L
  out <- data.frame(
    ExpectedEvidenceRows = nrow(expected),
    ReusableV2EvidenceRows = length(v2_keys),
    ReusableIndependentAnalyticRows = length(attribution_keys),
    MissingIndependentAnalyticRows = nrow(expected) - length(attribution_keys),
    ExpectedJacobianPointRows =
      length(mfrmr_gsv3_expected_scenarios) * length(mfrmr_gsv3_expected_points),
    ReusableExactCombinedJacobianPointRows = exact_jacobian_points,
    ReplayRequired = length(v2_keys) != nrow(expected) ||
      length(attribution_keys) != nrow(expected) ||
      exact_jacobian_points != 32L,
    RetrospectiveDecisionPerformed = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_gsv3r_assert(
    identical(out$ReusableV2EvidenceRows, 128L) &&
      identical(out$ReusableIndependentAnalyticRows, 48L) &&
      identical(out$MissingIndependentAnalyticRows, 80L) &&
      identical(out$ReusableExactCombinedJacobianPointRows, 0L) &&
      isTRUE(out$ReplayRequired),
    "The documented v3 artifact-reuse gap changed."
  )
  out
}

mfrmr_gsv3r_identity <- function(validated) {
  mfrmr_gsv3r_require_sources()
  validation_dir <- mfrmr_gsv3r_validation_dir()
  payload <- mfrmr_gscr_package_payload_identity()
  runtime <- mfrmr_gsv3r_runtime_identity()
  files <- c(
    NumericalBase = "numerical-stationarity-pilot-0.2.3.R",
    V3Rule = "gpcm-score-v3-rule-contract-0.2.3.R",
    V3RuleRecord = "gpcm-score-v3-rule-contract-0.2.3.md",
    V2Design = "gpcm-score-calibration-design-0.2.3.R",
    V2Oracle = "gpcm-nonunit-score-oracle-0.2.3.R",
    V2Runner = "gpcm-score-calibration-runner-0.2.3.R",
    AnalyticAttribution = "gpcm-extreme-score-attribution-0.2.3.R",
    V3Runner = "gpcm-score-v3-replay-runner-0.2.3.R"
  )
  file_hashes <- vapply(
    file.path(validation_dir, unname(files)),
    mfrmr_gscr_hash_file, character(1L)
  )
  names(file_hashes) <- names(files)
  out <- data.frame(
    ReplayContractVersion = mfrmr_gsv3r_contract_version,
    RuleContractVersion = mfrmr_gsv3_contract_version,
    RVersion = as.character(getRversion()),
    Platform = R.version$platform,
    PackageVersion = as.character(utils::packageVersion("mfrmr")),
    LoadedNamespacePath = runtime$LoadedNamespacePath,
    DevelopmentSourceLoaded = runtime$DevelopmentSourceLoaded,
    FreshSessionRequired = runtime$FreshSessionRequired,
    PackagePayloadSHA256 = payload$sha256,
    NumericalBaseSHA256 = unname(file_hashes["NumericalBase"]),
    V2ResultSHA256 = unname(validated$hashes["V2"]),
    AttributionResultSHA256 = unname(validated$hashes["Attribution"]),
    V3RuleSHA256 = unname(file_hashes["V3Rule"]),
    V3RuleRecordSHA256 = unname(file_hashes["V3RuleRecord"]),
    V2DesignSHA256 = unname(file_hashes["V2Design"]),
    V2OracleSHA256 = unname(file_hashes["V2Oracle"]),
    V2RunnerSHA256 = unname(file_hashes["V2Runner"]),
    AnalyticAttributionSHA256 = unname(file_hashes["AnalyticAttribution"]),
    V3RunnerSHA256 = unname(file_hashes["V3Runner"]),
    V2CalibrationStatus = "rejected_unchanged",
    ReplayExecutionAuthorized = FALSE,
    BoundaryProven = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  out$IdentitySHA256 <- mfrmr_gscr_hash_object(out)
  attr(out, "payload_ledger") <- payload$ledger
  out
}

mfrmr_gsv3r_manifest <- function(validated) {
  identity <- mfrmr_gsv3r_identity(validated)
  out <- mfrmr_gscr_manifest()
  out$ReplayContractVersion <- mfrmr_gsv3r_contract_version
  out$RuleContractVersion <- mfrmr_gsv3_contract_version
  out$V2ResultSHA256 <- identity$V2ResultSHA256
  out$AttributionResultSHA256 <- identity$AttributionResultSHA256
  out$V3RuleSHA256 <- identity$V3RuleSHA256
  out$V3RunnerSHA256 <- identity$V3RunnerSHA256
  out$ReplayIdentitySHA256 <- identity$IdentitySHA256
  out$V2CalibrationStatus <- "rejected_unchanged"
  out$ReplayExecutionAuthorized <- FALSE
  out$BoundaryProven <- FALSE
  out$ConfirmationAuthorized <- FALSE
  canonical <- out
  canonical$ReplayManifestSHA256 <- NULL
  out$ReplayManifestSHA256 <- mfrmr_gscr_hash_object(canonical)
  out
}

mfrmr_gsv3r_structural_audit <- function(context, par) {
  route <- mfrmr_num_logprob_bundle(context, par, include_probs = TRUE)
  route_objective <- suppressWarnings(as.numeric(context$fn(par))[1])
  oracle <- mfrmr_gno_independent_oracle(context, par)
  package_params <- mfrmr_num_get("expand_params")(
    par, context$sizes, context$config
  )
  finite <- all(is.finite(c(
    route$log_prob_mat, route_objective, oracle$log_prob_mat,
    oracle$objective, package_params$log_slopes, package_params$slopes,
    oracle$log_slopes, oracle$slopes
  )))
  log_probability_difference <- if (finite) {
    max(abs(route$log_prob_mat - oracle$log_prob_mat))
  } else NA_real_
  probability_difference <- if (finite) {
    mfrmr_gno_probability_difference(
      route$prob_list, oracle$probability_list
    )
  } else NA_real_
  objective_difference <- if (finite) {
    abs(route_objective - oracle$objective)
  } else NA_real_
  log_slope_difference <- if (finite) {
    max(abs(package_params$log_slopes - oracle$log_slopes))
  } else NA_real_
  slope_difference <- if (finite) {
    max(abs(package_params$slopes - oracle$slopes))
  } else NA_real_
  pass <- finite &&
    log_probability_difference <= mfrmr_gno_limits["log_probability"] &&
    probability_difference <= mfrmr_gno_limits["probability"] &&
    objective_difference <= mfrmr_gno_limits["objective"] &&
    log_slope_difference <= mfrmr_gno_limits["transform"] &&
    slope_difference <= mfrmr_gno_limits["transform"] &&
    oracle$geometric_mean_residual <= mfrmr_gno_limits["geometric_mean"]
  list(
    pass = pass,
    oracle = oracle,
    log_probability_difference = log_probability_difference,
    probability_difference = probability_difference,
    objective_difference = objective_difference,
    log_slope_difference = log_slope_difference,
    slope_difference = slope_difference
  )
}

mfrmr_gsv3r_point_audit <- function(fit, scenario, point) {
  mfrmr_gsv3r_require_sources()
  context <- mfrmr_num_fit_context(fit)
  par <- mfrmr_gscr_point(fit, point)
  structural <- mfrmr_gsv3r_structural_audit(context, par)
  package_score <- suppressWarnings(as.numeric(context$gr(par)))
  independent <- mfrmr_gsea_independent_score(context, par)
  score_scale <- pmax(1, abs(package_score), abs(independent$score))
  score_difference <- abs(package_score - independent$score)
  score_allowance <- mfrmr_gsv3_allowance(
    "independent_analytic_score", score_scale
  )
  score_ratio <- score_difference / score_allowance

  slope_region <- mfrmr_gsv3_classify_log_slopes(
    structural$oracle$log_slopes
  )
  finite_region <- identical(slope_region, "finite_slope_region")
  reference <- reference_spread <- roundoff_bound <-
    finite_difference_allowance <- finite_difference_ratio <-
    rep(NA_real_, length(par))
  finite_difference_status <- if (
      identical(slope_region, "extreme_slope_review_handoff")) {
    "not_applicable_extreme_slope"
  } else "not_evaluable"
  derivative <- NULL
  if (finite_region) {
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
    reference_spread <- apply(score_matrix, 1L, function(value) {
      if (any(!is.finite(value))) return(NA_real_)
      diff(range(value))
    })
    roundoff_bound <- 32 * .Machine$double.eps *
      pmax(1, apply(objective_matrix, 1L, max)) /
      apply(step_matrix, 1L, min)
    fd_scale <- pmax(1, abs(package_score), abs(reference))
    finite_difference_allowance <- mfrmr_gsv3_allowance(
      "finite_difference_score", fd_scale,
      reference_spread = reference_spread,
      roundoff_bound = roundoff_bound
    )
    finite_difference_ratio <-
      abs(package_score - reference) / finite_difference_allowance
    finite_difference_status <- if (
        all(is.finite(finite_difference_ratio)) &&
          all(finite_difference_ratio <= 1)) "pass" else "fail"
  }

  slope_slice <- as.integer(context$slices$log_slopes)
  jacobian <- mfrmr_num_gpcm_jacobian_from_free(
    par[slope_slice],
    levels = as.character(fit$config$gpcm_spec$levels),
    point = point,
    rel_step = 1e-6
  )
  jacobian_table <- jacobian$table
  log_scale <- pmax(
    1, abs(jacobian_table$AnalyticLogJacobian),
    abs(jacobian_table$NumericLogJacobian)
  )
  slope_scale <- pmax(
    1, abs(jacobian_table$AnalyticSlopeJacobian),
    abs(jacobian_table$NumericSlopeJacobian)
  )
  jacobian_table$LogAbsDifference <- abs(
    jacobian_table$AnalyticLogJacobian - jacobian_table$NumericLogJacobian
  )
  jacobian_table$LogCombinedAllowance <- mfrmr_gsv3_allowance(
    "expanded_log_jacobian", log_scale
  )
  jacobian_table$LogCombinedRatio <-
    jacobian_table$LogAbsDifference / jacobian_table$LogCombinedAllowance
  jacobian_table$SlopeAbsDifference <- abs(
    jacobian_table$AnalyticSlopeJacobian -
      jacobian_table$NumericSlopeJacobian
  )
  jacobian_table$SlopeCombinedAllowance <- mfrmr_gsv3_allowance(
    "expanded_slope_jacobian", slope_scale
  )
  jacobian_table$SlopeCombinedRatio <-
    jacobian_table$SlopeAbsDifference /
    jacobian_table$SlopeCombinedAllowance
  jacobian_table$ScenarioId <- as.character(scenario$ScenarioId)
  jacobian_table$Point <- point
  jacobian_table$SlopeRegion <- slope_region
  jacobian_table$CalibrationAuthorized <- FALSE
  jacobian_table$ConfirmationAuthorized <- FALSE
  log_jacobian_ratio <- max(jacobian_table$LogCombinedRatio)
  slope_jacobian_ratio <- max(jacobian_table$SlopeCombinedRatio)

  coordinates <- context$coordinates
  coordinates$ParameterClassFrozen <- mfrmr_gscr_parameter_class(
    coordinates, as.character(scenario$SlopeOwner)
  )
  coordinates$ScenarioId <- as.character(scenario$ScenarioId)
  coordinates$Point <- point
  coordinates$SlopeRegion <- slope_region
  coordinates$PackageAnalyticScore <- package_score
  coordinates$IndependentAnalyticScore <- independent$score
  coordinates$AnalyticScoreScale <- score_scale
  coordinates$AnalyticScoreAbsDifference <- score_difference
  coordinates$AnalyticScoreCombinedAllowance <- score_allowance
  coordinates$AnalyticScoreCombinedRatio <- score_ratio
  coordinates$FiniteDifferenceReference <- reference
  coordinates$FiniteDifferenceReferenceSpread <- reference_spread
  coordinates$FiniteDifferenceRoundoffBound <- roundoff_bound
  coordinates$FiniteDifferenceCombinedAllowance <-
    finite_difference_allowance
  coordinates$FiniteDifferenceCombinedRatio <- finite_difference_ratio
  coordinates$StructuralOraclePass <- structural$pass
  coordinates$CalibrationAuthorized <- FALSE
  coordinates$ConfirmationAuthorized <- FALSE
  for (index in seq_along(mfrmr_gsc_relative_steps)) {
    label <- gsub("[.]", "p", format(
      mfrmr_gsc_relative_steps[index], scientific = TRUE
    ))
    column <- paste0("FivePointScore_", label)
    coordinates[[column]] <- NA_real_
    if (!is.null(derivative)) {
      coordinates[[paste0("FivePointScore_", label)]] <-
        derivative[[index]]$score
    }
  }

  source_inference_ready <- "InferenceReady" %in% names(fit$summary) &&
    isTRUE(fit$summary[["InferenceReady"]][1])
  evidence <- do.call(rbind, lapply(
    mfrmr_gsv3_expected_classes, function(class) {
      keep <- coordinates$ParameterClassFrozen == class
      analytic_complete <- any(keep) && all(is.finite(unlist(
        coordinates[keep, c(
          "PackageAnalyticScore", "IndependentAnalyticScore",
          "AnalyticScoreCombinedAllowance", "AnalyticScoreCombinedRatio"
        )], use.names = FALSE
      )))
      finite_difference_complete <- if (finite_region) {
        any(keep) && all(is.finite(unlist(
          coordinates[keep, c(
            "FiniteDifferenceReference",
            "FiniteDifferenceReferenceSpread",
            "FiniteDifferenceRoundoffBound",
            "FiniteDifferenceCombinedAllowance",
            "FiniteDifferenceCombinedRatio"
          )], use.names = FALSE
        )))
      } else TRUE
      class_fd_ratio <- if (finite_region && finite_difference_complete) {
        max(coordinates$FiniteDifferenceCombinedRatio[keep])
      } else NA_real_
      class_fd_status <- if (finite_region) {
        if (finite_difference_complete && class_fd_ratio <= 1) "pass" else "fail"
      } else "not_applicable_extreme_slope"
      data.frame(
        ContractVersion = mfrmr_gsv3_contract_version,
        ScenarioId = as.character(scenario$ScenarioId),
        Point = point,
        ParameterClass = class,
        CoordinateCount = sum(keep),
        SlopeRegion = slope_region,
        StructuralOraclePass = structural$pass,
        AnalyticScorePass = analytic_complete &&
          all(coordinates$AnalyticScoreCombinedRatio[keep] <= 1),
        MaxAnalyticScoreCombinedRatio = if (analytic_complete) {
          max(coordinates$AnalyticScoreCombinedRatio[keep])
        } else NA_real_,
        FiniteDifferenceStatus = class_fd_status,
        FiniteDifferenceCombinedRatio = class_fd_ratio,
        LogJacobianCombinedRatio = log_jacobian_ratio,
        SlopeJacobianCombinedRatio = slope_jacobian_ratio,
        ExtremeSlopeReviewHandoff =
          identical(slope_region, "extreme_slope_review_handoff"),
        SourceInferenceReady = source_inference_ready,
        EvaluationComplete = analytic_complete &&
          finite_difference_complete && structural$pass &&
          is.finite(log_jacobian_ratio) && is.finite(slope_jacobian_ratio),
        CalibrationAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    }
  ))
  point_summary <- data.frame(
    ScenarioId = as.character(scenario$ScenarioId),
    Point = point,
    SlopeRegion = slope_region,
    MinSlope = min(structural$oracle$slopes),
    MaxSlope = max(structural$oracle$slopes),
    MaxAbsExpandedLogSlope = max(abs(structural$oracle$log_slopes)),
    StructuralOraclePass = structural$pass,
    MaxAnalyticScoreCombinedRatio = max(score_ratio),
    FiniteDifferenceStatus = finite_difference_status,
    MaxFiniteDifferenceCombinedRatio = if (finite_region) {
      max(finite_difference_ratio)
    } else NA_real_,
    MaxLogJacobianCombinedRatio = log_jacobian_ratio,
    MaxSlopeJacobianCombinedRatio = slope_jacobian_ratio,
    EntrywiseJacobianRows = nrow(jacobian_table),
    SourceInferenceReady = source_inference_ready,
    BoundaryProven = FALSE,
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(
    coordinates = coordinates,
    evidence = evidence,
    point_summary = point_summary,
    jacobian = jacobian_table
  )
}

mfrmr_gsv3r_failed_evidence <- function(scenario) {
  grid <- expand.grid(
    Point = mfrmr_gsv3_expected_points,
    ParameterClass = mfrmr_gsv3_expected_classes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data.frame(
    ContractVersion = mfrmr_gsv3_contract_version,
    ScenarioId = as.character(scenario$ScenarioId),
    Point = grid$Point,
    ParameterClass = grid$ParameterClass,
    CoordinateCount = 0L,
    SlopeRegion = "not_evaluable",
    StructuralOraclePass = FALSE,
    AnalyticScorePass = FALSE,
    MaxAnalyticScoreCombinedRatio = NA_real_,
    FiniteDifferenceStatus = "not_evaluable",
    FiniteDifferenceCombinedRatio = NA_real_,
    LogJacobianCombinedRatio = NA_real_,
    SlopeJacobianCombinedRatio = NA_real_,
    ExtremeSlopeReviewHandoff = FALSE,
    SourceInferenceReady = FALSE,
    EvaluationComplete = FALSE,
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3r_run_scenario <- function(scenario, progress = TRUE) {
  if (isTRUE(progress)) message("GPCM score v3 replay: ", scenario$ScenarioId)
  fitted <- mfrmr_gscr_fit(scenario)
  fit <- fitted$fit
  fit_succeeded <- !is.null(fit) && length(fit$opt$par) > 0L &&
    all(is.finite(fit$opt$par))
  fit_readiness <- if (fit_succeeded) {
    value <- if ("FitReadiness" %in% names(fit$summary)) {
      fit$summary[["FitReadiness"]]
    } else NULL
    as.character(if (is.null(value) || length(value) == 0L) {
      "unknown"
    } else value[1])
  } else "not_available"
  inference_ready <- if (fit_succeeded) {
    "InferenceReady" %in% names(fit$summary) &&
      isTRUE(fit$summary[["InferenceReady"]][1])
  } else FALSE
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
      suppressWarnings(as.integer(fit$opt$convergence))
    } else NA_integer_,
    FitReadiness = fit_readiness,
    InferenceReady = inference_ready,
    V2CalibrationStatus = "rejected_unchanged",
    BoundaryProven = FALSE,
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  if (!fit_succeeded) {
    return(list(
      fit = fit_summary,
      coordinates = data.frame(),
      evidence = mfrmr_gsv3r_failed_evidence(scenario),
      point_summary = data.frame(),
      jacobian = data.frame()
    ))
  }
  audits <- lapply(mfrmr_gsv3_expected_points, function(point) {
    mfrmr_gsv3r_point_audit(fit, scenario, point)
  })
  list(
    fit = fit_summary,
    coordinates = do.call(rbind, lapply(audits, `[[`, "coordinates")),
    evidence = do.call(rbind, lapply(audits, `[[`, "evidence")),
    point_summary = do.call(rbind, lapply(audits, `[[`, "point_summary")),
    jacobian = do.call(rbind, lapply(audits, `[[`, "jacobian"))
  )
}

mfrmr_run_gpcm_score_v3_replay <- function(
    dry_run = TRUE, authorize = FALSE, progress = TRUE, artifacts = NULL) {
  mfrmr_gsv3r_require_sources()
  validated <- mfrmr_gsv3r_validate_artifacts(artifacts)
  reuse_audit <- mfrmr_gsv3r_reuse_audit(validated)
  identity <- mfrmr_gsv3r_identity(validated)
  manifest <- mfrmr_gsv3r_manifest(validated)
  if (isTRUE(dry_run)) {
    return(list(
      contract_version = mfrmr_gsv3r_contract_version,
      manifest = manifest,
      identity = identity,
      reuse_audit = reuse_audit,
      executed = FALSE,
      v2_calibration_status = "rejected_unchanged",
      replay_execution_authorized = FALSE,
      general_num_score_tol_frozen = FALSE,
      boundary_proven = FALSE,
      confirmation_authorized = FALSE
    ))
  }
  mfrmr_gsv3r_assert(
    isTRUE(authorize),
    "Bounded v3 replay requires explicit `authorize = TRUE`."
  )
  started <- proc.time()[["elapsed"]]
  results <- lapply(seq_len(nrow(manifest)), function(index) {
    mfrmr_gsv3r_run_scenario(manifest[index, , drop = FALSE], progress)
  })
  fits <- do.call(rbind, lapply(results, `[[`, "fit"))
  coordinates <- do.call(rbind, lapply(results, `[[`, "coordinates"))
  evidence <- do.call(rbind, lapply(results, `[[`, "evidence"))
  point_summary <- do.call(rbind, lapply(results, `[[`, "point_summary"))
  jacobian <- do.call(rbind, lapply(results, `[[`, "jacobian"))
  decision <- mfrmr_gsv3_decision(evidence)
  list(
    contract_version = mfrmr_gsv3r_contract_version,
    manifest = manifest,
    identity = identity,
    reuse_audit = reuse_audit,
    fits = fits,
    coordinates = coordinates,
    evidence = evidence,
    point_summary = point_summary,
    jacobian = jacobian,
    decision = decision,
    executed = TRUE,
    elapsed_seconds = proc.time()[["elapsed"]] - started,
    v2_calibration_status = "rejected_unchanged",
    replay_execution_authorized_for_this_run = TRUE,
    calibration_authorized_by_result = FALSE,
    general_num_score_tol_frozen = FALSE,
    boundary_proven = FALSE,
    confirmation_authorized = FALSE
  )
}
