# Repository-only mfrmr preflight for ConQuest P2 candidate 003.
#
# This run-once harness fits exactly RSM/PCM at q=31/61 against the frozen
# candidate-003 data. It cannot launch ConQuest or authorize external execution.
# A retained `design_rank_not_evaluated` readiness hold is not relabelled as
# inference-ready, but is separated from fatal numerical and boundary failures.

mfrmr_cq_p2c3p_specification <-
  "0.2.3-conquest-p2-candidate-003-mfrmr-preflight-v1"
mfrmr_cq_p2c3p_contract <-
  "mfrmr_conquest_p2_candidate_003_mfrmr_preflight_v1"
mfrmr_cq_p2c3p_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003"
mfrmr_cq_p2c3p_output_basename <-
  "conquest-p2-candidate-003-mfrmr-preflight-20260815-v1"
mfrmr_cq_p2c3p_minimum_population_variance <- 0.05

mfrmr_cq_p2c3p_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c3p_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c3p_require_contracts)
  required <- c("mfrmr_cq_p2c3_review", "mfrmr_cq_p2m_metric_rule_registry")
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_p2c3_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c3_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_003_coverage_conditioned_fixture_v1"
      ),
    exists("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_metric_boundary_contract_v1"
      )
  )
  mfrmr_cq_p2c3p_assert(
    all(available) && all(identity),
    paste(
      "Source the exact candidate-003 fixture and P2 metric contracts before",
      "the mfrmr-only preflight."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_p2c3p_q_tolerances <- function() {
  mfrmr_cq_p2c3p_require_contracts()
  rules <- mfrmr_cq_p2m_metric_rule_registry()
  coordinate <- rules[
    rules$RuleId == "P2-MFRMR-Q-MOVEMENT-COORDINATE", , drop = FALSE
  ]
  deviance <- rules[
    rules$RuleId == "P2-MFRMR-Q-MOVEMENT-DEVIANCE", , drop = FALSE
  ]
  mfrmr_cq_p2c3p_assert(
    nrow(coordinate) == 1L && nrow(deviance) == 1L &&
      isTRUE(coordinate$Frozen) && isTRUE(deviance$Frozen) &&
      isTRUE(coordinate$NumericPassAuthorized) &&
      isTRUE(deviance$NumericPassAuthorized),
    "The frozen mfrmr q-movement rules are absent or ineligible."
  )
  c(
    coordinate = as.numeric(coordinate$AbsoluteTolerance),
    deviance = as.numeric(deviance$AbsoluteTolerance)
  )
}

mfrmr_cq_p2c3p_plan <- function() {
  tolerance <- mfrmr_cq_p2c3p_q_tolerances()
  family <- rep(c("RSM", "PCM"), each = 2L)
  nodes <- rep(c(31L, 61L), times = 2L)
  out <- data.frame(
    ExecutionOrder = seq_along(nodes),
    RunId = paste0(tolower(family), "_q", sprintf("%03d", nodes)),
    Family = family,
    Nodes = nodes,
    ExpectedNpar = rep(c(10L, 14L), each = 2L),
    ExpectedExpandedCoordinateCount = rep(c(13L, 19L), each = 2L),
    MinimumPopulationVariance = mfrmr_cq_p2c3p_minimum_population_variance,
    QCoordinateAbsoluteTolerance = unname(tolerance["coordinate"]),
    QDevianceAbsoluteTolerance = unname(tolerance["deviance"]),
    FitAttemptCap = 1L,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c3p_assert(
    nrow(out) == 4L &&
      identical(out$Family, c("RSM", "RSM", "PCM", "PCM")) &&
      identical(out$Nodes, c(31L, 61L, 31L, 61L)) &&
      identical(out$ExpectedNpar, c(10L, 10L, 14L, 14L)) &&
      identical(
        out$ExpectedExpandedCoordinateCount, c(13L, 13L, 19L, 19L)
      ) &&
      all(out$MinimumPopulationVariance == 0.05) &&
      all(out$QCoordinateAbsoluteTolerance == 2e-6) &&
      all(out$QDevianceAbsoluteTolerance == 2e-6) &&
      all(out$FitAttemptCap == 1L) &&
      !any(out$ExternalExecutionAuthorized),
    "The candidate-003 mfrmr preflight plan drifted."
  )
  out
}

mfrmr_cq_p2c3p_fixture <- function() {
  review <- mfrmr_cq_p2c3_review()
  mfrmr_cq_p2c3p_assert(
    isTRUE(review$mfrmr_fit_preflight_authorized) &&
      !isTRUE(review$external_execution_authorized) &&
      !isTRUE(review$truth_recovery_authorized),
    "Candidate 003 is not eligible for the mfrmr-only preflight."
  )
  data <- review$fixture$Data
  data$Score <- data$Response
  data$Response <- NULL
  person <- unique(data[, c("Person", "X"), drop = FALSE])
  list(
    long = data,
    person = person,
    candidate_review = review,
    truth_recovery_authorized = FALSE,
    external_execution_authorized = FALSE
  )
}

mfrmr_cq_p2c3p_fit_arguments <- function(family, nodes, fixture = NULL) {
  if (is.null(fixture)) fixture <- mfrmr_cq_p2c3p_fixture()
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  mfrmr_cq_p2c3p_assert(
    family %in% c("RSM", "PCM") && nodes %in% c(31L, 61L),
    "The preflight permits only RSM/PCM at q=31/q=61."
  )
  out <- list(
    data = fixture$long,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 0,
    rating_max = 3,
    method = "MML",
    model = family,
    population_formula = ~ X,
    person_data = fixture$person,
    quad_points = nodes,
    maxit = 2000L,
    reltol = 1e-12,
    mml_engine = "direct"
  )
  if (family == "PCM") out$step_facet <- "Criterion"
  out
}

mfrmr_cq_p2c3p_namespace <- function(source_root = ".") {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("Load the mfrmr working tree before executing the preflight.",
         call. = FALSE)
  }
  source_root <- normalizePath(
    as.character(source_root)[1L], winslash = "/", mustWork = TRUE
  )
  namespace <- asNamespace("mfrmr")
  namespace_path <- normalizePath(
    getNamespaceInfo(namespace, "path"), winslash = "/", mustWork = TRUE
  )
  mfrmr_cq_p2c3p_assert(
    identical(namespace_path, source_root) &&
      identical(as.character(utils::packageVersion("mfrmr")), "0.2.3") &&
      exists("fit_mfrm", envir = namespace, inherits = FALSE),
    paste(
      "The loaded mfrmr namespace is not the requested 0.2.3 source root;",
      "use pkgload::load_all(source_root)."
    )
  )
  namespace
}

mfrmr_cq_p2c3p_value <- function(row, name, default) {
  if (name %in% names(row) && length(row[[name]]) > 0L) row[[name]][1L] else default
}

mfrmr_cq_p2c3p_fit_gate <- function(summary, sigma2, expected_npar) {
  summary <- as.data.frame(summary, stringsAsFactors = FALSE)
  mfrmr_cq_p2c3p_assert(nrow(summary) == 1L, "One fit summary row is required.")
  npar <- suppressWarnings(as.integer(
    mfrmr_cq_p2c3p_value(summary, "Npar", NA_integer_)
  ))
  inference_ready <- isTRUE(
    mfrmr_cq_p2c3p_value(summary, "InferenceReady", FALSE)
  )
  fit_readiness <- as.character(
    mfrmr_cq_p2c3p_value(summary, "FitReadiness", "missing")
  )
  estimability <- as.character(
    mfrmr_cq_p2c3p_value(summary, "EstimabilityState", "missing")
  )
  reason <- as.character(
    mfrmr_cq_p2c3p_value(summary, "ReadinessReasonCodes", "missing")
  )
  only_design_rank_hold <- !inference_ready && fit_readiness == "review" &&
    estimability == "not_evaluated" && reason == "design_rank_not_evaluated"
  numerical_pass <-
    as.character(mfrmr_cq_p2c3p_value(
      summary, "ConvergenceStatus", "missing"
    )) == "converged" &&
    as.character(mfrmr_cq_p2c3p_value(
      summary, "ConvergenceSeverity", "missing"
    )) == "pass" &&
    as.character(mfrmr_cq_p2c3p_value(
      summary, "NumericalState", "missing"
    )) == "ready" &&
    is.finite(as.numeric(mfrmr_cq_p2c3p_value(
      summary, "TerminalGradientSupNorm", NA_real_
    )))
  boundary_pass <-
    as.character(mfrmr_cq_p2c3p_value(
      summary, "BoundaryState", "missing"
    )) == "finite" &&
    is.finite(sigma2) &&
    sigma2 >= mfrmr_cq_p2c3p_minimum_population_variance
  dimension_pass <- identical(npar, as.integer(expected_npar)[1L])
  readiness_state_retained <- inference_ready || only_design_rank_hold
  data.frame(
    DimensionPass = dimension_pass,
    NumericalPass = numerical_pass,
    BoundaryAndVariancePass = boundary_pass,
    InferenceReady = inference_ready,
    OnlyDesignRankNotEvaluatedHold = only_design_rank_hold,
    ReadinessStateRetained = readiness_state_retained,
    StructuralNumericalPass = dimension_pass && numerical_pass &&
      boundary_pass && readiness_state_retained,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c3p_coordinates <- function(fit, arm) {
  population <- c(
    as.numeric(fit$population$coefficients[c("(Intercept)", "X")]),
    as.numeric(fit$population$sigma2)
  )
  names(population) <- c(
    "Population::Intercept", "Population::X", "Population::Variance"
  )
  facet <- as.data.frame(fit$facets$others, stringsAsFactors = FALSE)
  facet_value <- as.numeric(facet$Estimate)
  names(facet_value) <- paste(facet$Facet, facet$Level, sep = "::")
  step <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
  if (arm$Family == "RSM") {
    step_value <- as.numeric(step$Estimate)
    names(step_value) <- paste("Step", step$Step, sep = "::")
  } else {
    step_value <- as.numeric(step$Estimate)
    names(step_value) <- paste("Step", step$StepFacet, step$Step, sep = "::")
  }
  value <- c(population, facet_value, step_value)
  mfrmr_cq_p2c3p_assert(
    all(is.finite(value)) && !anyDuplicated(names(value)),
    paste0("Fitted coordinates are incomplete for `", arm$RunId, "`.")
  )
  data.frame(
    RunId = arm$RunId,
    Family = arm$Family,
    Nodes = arm$Nodes,
    Coordinate = names(value),
    Estimate = unname(value),
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c3p_failure_summary <- function(arm, error) {
  data.frame(
    RunId = arm$RunId, Family = arm$Family, Nodes = arm$Nodes,
    ExpectedNpar = arm$ExpectedNpar, ObservedNpar = NA_integer_,
    LogLik = NA_real_, Deviance = NA_real_, PopulationVariance = NA_real_,
    ConvergenceStatus = "fit_failed", ConvergenceSeverity = "fail",
    FitReadiness = "blocked", InferenceReady = FALSE,
    EstimabilityState = "not_evaluated", BoundaryState = "not_evaluated",
    NumericalState = "failed", ReadinessReasonCodes = "fit_failed",
    WarningCount = NA_integer_, Error = as.character(error)[1L],
    DimensionPass = FALSE, NumericalPass = FALSE,
    BoundaryAndVariancePass = FALSE,
    OnlyDesignRankNotEvaluatedHold = FALSE,
    ReadinessStateRetained = FALSE, StructuralNumericalPass = FALSE,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c3p_q_review <- function(fit_summary, coordinates, plan) {
  rows <- lapply(c("RSM", "PCM"), function(family) {
    summary <- fit_summary[fit_summary$Family == family, , drop = FALSE]
    coordinate <- coordinates[coordinates$Family == family, , drop = FALSE]
    q31 <- coordinate[coordinate$Nodes == 31L, c("Coordinate", "Estimate")]
    q61 <- coordinate[coordinate$Nodes == 61L, c("Coordinate", "Estimate")]
    same_coordinates <- nrow(q31) > 0L && nrow(q31) == nrow(q61) &&
      !anyDuplicated(q31$Coordinate) && !anyDuplicated(q61$Coordinate) &&
      setequal(q31$Coordinate, q61$Coordinate)
    maximum <- NA_real_
    if (same_coordinates) {
      q61 <- q61[match(q31$Coordinate, q61$Coordinate), , drop = FALSE]
      maximum <- max(abs(q61$Estimate - q31$Estimate))
    }
    deviance <- if (nrow(summary) == 2L && all(is.finite(summary$Deviance))) {
      abs(summary$Deviance[summary$Nodes == 61L] -
            summary$Deviance[summary$Nodes == 31L])
    } else {
      NA_real_
    }
    coordinate_tolerance <- unique(
      plan$QCoordinateAbsoluteTolerance[plan$Family == family]
    )
    deviance_tolerance <- unique(
      plan$QDevianceAbsoluteTolerance[plan$Family == family]
    )
    expected_coordinate_count <- unique(
      plan$ExpectedExpandedCoordinateCount[plan$Family == family]
    )
    complete_coordinate_denominator <- same_coordinates &&
      nrow(q31) == expected_coordinate_count
    passed <- nrow(summary) == 2L &&
      all(summary$StructuralNumericalPass) && complete_coordinate_denominator &&
      is.finite(maximum) && maximum <= coordinate_tolerance &&
      length(deviance) == 1L && is.finite(deviance) &&
      deviance <= deviance_tolerance
    data.frame(
      Family = family,
      ExpectedCoordinateCount = expected_coordinate_count,
      CoordinateCount = if (same_coordinates) nrow(q31) else 0L,
      SameCoordinateSet = same_coordinates,
      CompleteCoordinateDenominator = complete_coordinate_denominator,
      MaximumAbsoluteQ31Q61CoordinateMovement = maximum,
      CoordinateTolerance = coordinate_tolerance,
      AbsoluteQ31Q61DevianceMovement = deviance,
      DevianceTolerance = deviance_tolerance,
      Passed = passed,
      FailureOutcome = if (passed) "none" else "integration_unresolved",
      ExternalExecutionAuthorized = FALSE,
      EvidencePromotionAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_cq_p2c3p_review <- function() {
  mfrmr_cq_p2c3p_require_contracts()
  fixture <- mfrmr_cq_p2c3p_fixture()
  plan <- mfrmr_cq_p2c3p_plan()
  list(
    specification = mfrmr_cq_p2c3p_specification,
    contract_version = mfrmr_cq_p2c3p_contract,
    candidate_id = mfrmr_cq_p2c3p_candidate_id,
    status = "mfrmr_preflight_contract_frozen_execution_unopened",
    plan = plan,
    fixture_rows = nrow(fixture$long),
    fixture_persons = nrow(fixture$person),
    fit_cap = sum(plan$FitAttemptCap),
    frozen_output_basename = mfrmr_cq_p2c3p_output_basename,
    design_rank_not_evaluated_is_inference_ready = FALSE,
    truth_recovery_authorized = FALSE,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}

mfrmr_cq_p2c3p_execute <- function(
    output_dir, source_root = ".", authorize = FALSE) {
  mfrmr_cq_p2c3p_assert(
    identical(authorize, TRUE),
    "Execution is held; set `authorize = TRUE` only for this four-fit preflight."
  )
  review <- mfrmr_cq_p2c3p_review()
  output_dir <- normalizePath(
    as.character(output_dir)[1L], winslash = "/", mustWork = FALSE
  )
  mfrmr_cq_p2c3p_assert(
    identical(basename(output_dir), mfrmr_cq_p2c3p_output_basename),
    "The preflight output directory basename is not the frozen candidate path."
  )
  mfrmr_cq_p2c3p_assert(
    !file.exists(output_dir) && !dir.exists(output_dir),
    "The frozen preflight output directory must not already exist."
  )
  namespace <- mfrmr_cq_p2c3p_namespace(source_root)
  mfrmr_cq_p2c3p_assert(
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE),
    "The preflight output directory could not be created."
  )
  output_dir <- normalizePath(output_dir, winslash = "/", mustWork = TRUE)
  fixture <- mfrmr_cq_p2c3p_fixture()
  plan <- review$plan
  utils::write.csv(plan, file.path(output_dir, "preflight_plan.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(fixture$long, file.path(output_dir, "fixture_long.csv"),
                   row.names = FALSE, na = "")
  summaries <- vector("list", nrow(plan))
  coordinates <- vector("list", nrow(plan))
  for (index in seq_len(nrow(plan))) {
    arm <- plan[index, , drop = FALSE]
    warnings <- character(0)
    fit <- tryCatch(
      withCallingHandlers(
        do.call(
          get("fit_mfrm", envir = namespace, inherits = FALSE),
          mfrmr_cq_p2c3p_fit_arguments(arm$Family, arm$Nodes, fixture)
        ),
        warning = function(warning) {
          warnings <<- c(warnings, conditionMessage(warning))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(error) error
    )
    if (inherits(fit, "error")) {
      summaries[[index]] <- mfrmr_cq_p2c3p_failure_summary(
        arm, conditionMessage(fit)
      )
      coordinates[[index]] <- NULL
      writeLines(
        conditionMessage(fit),
        file.path(output_dir, paste0(arm$RunId, "_error.txt")),
        useBytes = TRUE
      )
      next
    }
    saveRDS(fit, file.path(output_dir, paste0(arm$RunId, "_fit.rds")))
    fit_summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)
    sigma2 <- as.numeric(fit$population$sigma2)
    gate <- mfrmr_cq_p2c3p_fit_gate(
      fit_summary, sigma2, arm$ExpectedNpar
    )
    summaries[[index]] <- data.frame(
      RunId = arm$RunId, Family = arm$Family, Nodes = arm$Nodes,
      ExpectedNpar = arm$ExpectedNpar,
      ObservedNpar = as.integer(fit_summary$Npar[1L]),
      LogLik = as.numeric(fit_summary$LogLik[1L]),
      Deviance = as.numeric(fit_summary$Deviance[1L]),
      PopulationVariance = sigma2,
      ConvergenceStatus = as.character(fit_summary$ConvergenceStatus[1L]),
      ConvergenceSeverity = as.character(fit_summary$ConvergenceSeverity[1L]),
      FitReadiness = as.character(fit_summary$FitReadiness[1L]),
      EstimabilityState = as.character(fit_summary$EstimabilityState[1L]),
      BoundaryState = as.character(fit_summary$BoundaryState[1L]),
      NumericalState = as.character(fit_summary$NumericalState[1L]),
      ReadinessReasonCodes = as.character(
        fit_summary$ReadinessReasonCodes[1L]
      ),
      WarningCount = length(unique(warnings)), Error = NA_character_,
      gate,
      stringsAsFactors = FALSE
    )
    coordinates[[index]] <- mfrmr_cq_p2c3p_coordinates(fit, arm)
    writeLines(
      if (length(warnings)) unique(warnings) else "none",
      file.path(output_dir, paste0(arm$RunId, "_warnings.txt")),
      useBytes = TRUE
    )
  }
  fit_summary <- do.call(rbind, summaries)
  coordinate <- do.call(rbind, coordinates)
  if (is.null(coordinate)) {
    coordinate <- data.frame(
      RunId = character(), Family = character(), Nodes = integer(),
      Coordinate = character(), Estimate = numeric(),
      ExternalExecutionAuthorized = logical(),
      ScientificEquivalenceInferred = logical(), stringsAsFactors = FALSE
    )
  }
  q_review <- mfrmr_cq_p2c3p_q_review(fit_summary, coordinate, plan)
  passed <- nrow(fit_summary) == 4L &&
    all(fit_summary$StructuralNumericalPass) && all(q_review$Passed)
  run_summary <- data.frame(
    Specification = mfrmr_cq_p2c3p_specification,
    ContractVersion = mfrmr_cq_p2c3p_contract,
    CandidateId = mfrmr_cq_p2c3p_candidate_id,
    Status = if (passed) {
      "mfrmr_preflight_passed_new_external_authorization_review_required"
    } else {
      "mfrmr_preflight_failed_external_execution_blocked"
    },
    SourceRoot = normalizePath(
      source_root, winslash = "/", mustWork = TRUE
    ),
    PackageVersion = as.character(utils::packageVersion("mfrmr")),
    AttemptedFits = nrow(plan),
    StructuralNumericalPassFits = sum(fit_summary$StructuralNumericalPass),
    InferenceReadyFits = sum(fit_summary$InferenceReady),
    DesignRankHoldFits = sum(fit_summary$OnlyDesignRankNotEvaluatedHold),
    QPairsPassed = sum(q_review$Passed),
    EligibleForNewExternalAuthorizationReview = passed,
    ExternalExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    TruthRecoveryAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
  utils::write.csv(fit_summary, file.path(output_dir, "fit_summary.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(coordinate, file.path(output_dir, "coordinates.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(q_review, file.path(output_dir, "q31_q61_review.csv"),
                   row.names = FALSE, na = "")
  utils::write.csv(run_summary, file.path(output_dir, "run_summary.csv"),
                   row.names = FALSE, na = "")
  list(
    status = run_summary$Status,
    output_dir = output_dir,
    fit_summary = fit_summary,
    coordinates = coordinate,
    q_review = q_review,
    run_summary = run_summary,
    eligible_for_new_external_authorization_review = passed,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    truth_recovery_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
