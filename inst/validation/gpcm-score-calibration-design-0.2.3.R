# Repository-only bounded GPCM score-calibration design for mfrmr 0.2.3.
#
# This file freezes a small calibration architecture before executing it. It
# creates no data, fits no model, selects no result-dependent tolerance, and
# authorizes neither calibration execution nor confirmation.

mfrmr_gsc_contract_version <- "mfrmr_gpcm_score_calibration_design_v2"
mfrmr_gsc_relative_steps <- c(1e-3, 3e-4, 1e-4)
mfrmr_gsc_primary_step <- 3e-4
mfrmr_gsc_expected_classes <- c(
  "owner_additive", "other_additive", "steps", "log_slopes"
)

mfrmr_gsc_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsc_scenarios <- function() {
  design <- rep(
    c("core", "weak_bridge", "workload_imbalance", "category_imbalance"),
    each = 2L
  )
  owner <- rep(c("Criterion", "Rater"), 4L)
  short_owner <- ifelse(owner == "Criterion", "C", "R")
  short_design <- c(
    CORE = "CORE5", WEAK_BRIDGE = "WEAK5",
    WORKLOAD_IMBALANCE = "WORK5", CATEGORY_IMBALANCE = "CAT5"
  )[toupper(design)]
  data.frame(
    ContractVersion = mfrmr_gsc_contract_version,
    ScenarioId = paste(
      "NUM-GPCM-SCORE-CAL", short_owner, unname(short_design), sep = "-"
    ),
    SlopeOwner = owner,
    StepOwner = owner,
    DesignId = design,
    NPersons = 40L,
    NRaters = 4L,
    NCriteria = 4L,
    NCategories = 5L,
    FixtureId = paste0("GPCM-SCORE-FIX-", unname(short_design)),
    Estimator = "MML",
    Engine = "direct",
    QuadPoints = 31L,
    Maxit = 2000L,
    Reltol = 1e-12,
    Builder = "mfrmr_gsc_deterministic_fixture_v1",
    ExpectedDesignState = c(
      "linked_core", "linked_core",
      "linked_one_person_bridge", "linked_one_person_bridge",
      "linked_workload_imbalanced", "linked_workload_imbalanced",
      "linked_category_imbalanced", "linked_category_imbalanced"
    ),
    CalibrationRowsPerCell = 1L,
    RecoveryClaim = FALSE,
    IntegrationSufficiencyClaim = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsc_fixture <- function(design_id = c(
    "core", "weak_bridge", "workload_imbalance", "category_imbalance")) {
  design_id <- match.arg(design_id)
  persons <- sprintf("P%02d", seq_len(40L))
  raters <- sprintf("R%02d", seq_len(4L))
  criteria <- sprintf("C%02d", seq_len(4L))
  if (identical(design_id, "weak_bridge")) {
    rows <- lapply(seq_along(persons), function(index) {
      assigned <- if (index == 1L) {
        raters
      } else {
        raters[1L + ((index - 1L) %% length(raters))]
      }
      expand.grid(
        Person = persons[index], Rater = assigned, Criterion = criteria,
        KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
      )
    })
    data <- do.call(rbind, rows)
  } else {
    data <- expand.grid(
      Person = persons, Rater = raters, Criterion = criteria,
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
  }
  person_index <- match(data$Person, persons)
  rater_index <- match(data$Rater, raters)
  criterion_index <- match(data$Criterion, criteria)
  if (identical(design_id, "workload_imbalance")) {
    maximum_person <- c(40L, 30L, 20L, 10L)[rater_index]
    keep <- person_index <= maximum_person
    data <- data[keep, , drop = FALSE]
    person_index <- person_index[keep]
    rater_index <- rater_index[keep]
    criterion_index <- criterion_index[keep]
  }
  if (identical(design_id, "category_imbalance")) {
    cycle <- 1L + (
      person_index + 2L * rater_index + 3L * criterion_index - 1L
    ) %% 20L
    score <- ifelse(
      cycle == 1L, 1L,
      ifelse(cycle <= 3L, 2L,
             ifelse(cycle <= 17L, 3L,
                    ifelse(cycle <= 19L, 4L, 5L)))
    )
  } else {
    score <- 1L + (
      person_index + 2L * rater_index + 3L * criterion_index - 1L
    ) %% 5L
  }
  data$Score <- as.integer(score)
  data <- data[order(data$Person, data$Rater, data$Criterion), , drop = FALSE]
  row.names(data) <- NULL
  key <- paste(data$Person, data$Rater, data$Criterion, sep = "::")
  owner_support <- function(owner) {
    table(
      factor(data[[owner]], levels = sort(unique(data[[owner]]))),
      factor(data$Score, levels = 1:5)
    )
  }
  mfrmr_gsc_assert(
    nrow(data) > 0L && !anyDuplicated(key) &&
      all(owner_support("Rater") > 0L) &&
      all(owner_support("Criterion") > 0L),
    "The deterministic GPCM fixture lost row identity or category support."
  )
  list(
    fixture_id = paste0(
      "GPCM-SCORE-FIX-",
      c(
        core = "CORE5", weak_bridge = "WEAK5",
        workload_imbalance = "WORK5", category_imbalance = "CAT5"
      )[[design_id]]
    ),
    design_id = design_id,
    data = data,
    owner_support = list(
      Rater = owner_support("Rater"),
      Criterion = owner_support("Criterion")
    ),
    stochastic = FALSE,
    recovery_claim = FALSE
  )
}

mfrmr_gsc_points <- function() {
  data.frame(
    Point = c(
      "retained_solution", "coupled_free_probe",
      "finite_slope_stress_forward", "finite_slope_stress_reverse"
    ),
    Construction = c(
      "retained_direct_MML_vector",
      paste0(
        "all_free_coordinates_plus_0.08_deterministic_direction;",
        "expanded_slopes_geometric_0.45_to_2.20"
      ),
      "slope_only_expanded_log_sequence_minus3_to_plus3",
      "slope_only_reversed_expanded_log_sequence_plus3_to_minus3"
    ),
    PerturbsAllFreeCoordinates = c(FALSE, TRUE, FALSE, FALSE),
    MinTargetSlope = c(NA_real_, 0.45, exp(-3), exp(-3)),
    MaxTargetSlope = c(NA_real_, 2.20, exp(3), exp(3)),
    BoundaryClaim = FALSE,
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsc_parameter_rules <- function() {
  data.frame(
    ParameterClass = mfrmr_gsc_expected_classes,
    HardAbsoluteCap = c(2e-6, 2e-6, 2e-6, 1e-6),
    HardScaledCap = c(2e-7, 2e-7, 2e-7, 1e-7),
    AdaptiveBaseAbsolute = c(1e-8, 1e-8, 1e-8, 1e-8),
    AdaptiveBaseScaled = c(1e-9, 1e-9, 1e-9, 1e-9),
    ReferenceSpreadMultiplier = c(10, 10, 10, 10),
    RoundoffMultiplier = c(10, 10, 10, 10),
    MaximumAdaptiveRatio = 1,
    ExpandedLogJacobianAbsoluteCap = c(NA, NA, NA, 5e-10),
    ExpandedSlopeJacobianAbsoluteCap = c(NA, NA, NA, 1e-7),
    ExpandedSlopeJacobianScaledCap = c(NA, NA, NA, 1e-8),
    GeometricMeanResidualCap = c(NA, NA, NA, 1e-12),
    RuleStatus = "calibration_evaluation_rule_frozen_after_preflight_v2",
    GeneralNUMSCORETOLStatus = "pilot_required",
    stringsAsFactors = FALSE
  )
}

mfrmr_gsc_numeric_rule <- function() {
  list(
    ContractVersion = mfrmr_gsc_contract_version,
    ReferenceObjective =
      "independent_nonunit_GPCM_kernel_and_person_marginal_objective",
    Derivative = "coordinate_scaled_five_point_central_difference",
    RelativeSteps = mfrmr_gsc_relative_steps,
    PrimaryRelativeStep = mfrmr_gsc_primary_step,
    Scale = "max(1,abs(analytic),abs(reference))",
    ReferenceSpread = "max(five_point_scores)-min(five_point_scores)",
    RoundoffBound = paste0(
      "32*.Machine$double.eps*max(1,max_abs_objective_evaluation)",
      "/minimum_absolute_coordinate_step"
    ),
    AdaptiveAllowance = paste0(
      "base_absolute+base_scaled*scale+10*reference_spread+",
      "10*roundoff_bound"
    ),
    CoordinatePass = paste0(
      "absolute_difference<=hard_absolute_cap AND ",
      "scaled_difference<=hard_scaled_cap AND ",
      "absolute_difference/adaptive_allowance<=1"
    ),
    AllCoordinatesRequired = TRUE,
    AllParameterClassesRequired = TRUE,
    AllPointsRequired = TRUE,
    AllScenariosRequired = TRUE,
    MissingOrNonfinite = "rejected_not_zero",
    CalibrationEvaluationRuleFrozen = TRUE,
    GeneralNUMSCORETOLFrozen = FALSE,
    CalibrationExecutionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE
  )
}

mfrmr_gsc_five_point_gradient <- function(fn, par, rel_step) {
  mfrmr_gsc_assert(is.function(fn), "`fn` must be a function.")
  par <- suppressWarnings(as.numeric(par))
  rel_step <- suppressWarnings(as.numeric(rel_step))
  mfrmr_gsc_assert(
    length(par) > 0L && all(is.finite(par)),
    "`par` must be a non-empty finite numeric vector."
  )
  mfrmr_gsc_assert(
    length(rel_step) == 1L && is.finite(rel_step) && rel_step > 0,
    "`rel_step` must be one finite positive value."
  )
  step <- rel_step * pmax(1, abs(par))
  vapply(seq_along(par), function(index) {
    minus_two <- minus_one <- plus_one <- plus_two <- par
    minus_two[index] <- par[index] - 2 * step[index]
    minus_one[index] <- par[index] - step[index]
    plus_one[index] <- par[index] + step[index]
    plus_two[index] <- par[index] + 2 * step[index]
    values <- suppressWarnings(as.numeric(c(
      fn(minus_two), fn(minus_one), fn(plus_one), fn(plus_two)
    )))
    if (length(values) != 4L || any(!is.finite(values))) return(NA_real_)
    (values[1] - 8 * values[2] + 8 * values[3] - values[4]) /
      (12 * step[index])
  }, numeric(1L))
}

mfrmr_gsc_expected_evidence_grid <- function() {
  out <- expand.grid(
    ScenarioId = mfrmr_gsc_scenarios()$ScenarioId,
    Point = mfrmr_gsc_points()$Point,
    ParameterClass = mfrmr_gsc_expected_classes,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  out$ContractVersion <- mfrmr_gsc_contract_version
  out <- out[, c(
    "ContractVersion", "ScenarioId", "Point", "ParameterClass"
  )]
  row.names(out) <- NULL
  out
}

mfrmr_gsc_decision <- function(evidence) {
  expected <- mfrmr_gsc_expected_evidence_grid()
  required <- c(
    names(expected), "MaxAbsDifference", "MaxScaledDifference",
    "MaxAdaptiveRatio", "StepLadderComplete", "StructuralOraclePass",
    "JacobianStatus", "EvaluationComplete", "CalibrationAuthorized",
    "ConfirmationAuthorized"
  )
  key <- function(data) paste(
    data$ScenarioId, data$Point, data$ParameterClass, sep = "::"
  )
  structure_complete <- is.data.frame(evidence) &&
    all(required %in% names(evidence)) &&
    nrow(evidence) == nrow(expected) &&
    !anyDuplicated(key(evidence)) &&
    identical(sort(key(evidence)), sort(key(expected))) &&
    all(evidence$ContractVersion == mfrmr_gsc_contract_version)
  rules <- mfrmr_gsc_parameter_rules()
  rule_index <- if (structure_complete) {
    match(evidence$ParameterClass, rules$ParameterClass)
  } else {
    integer(0)
  }
  numeric_complete <- structure_complete && !anyNA(rule_index) &&
    all(evidence$StepLadderComplete %in% TRUE) &&
    all(evidence$StructuralOraclePass %in% TRUE) &&
    all(evidence$EvaluationComplete %in% TRUE) &&
    all(is.finite(unlist(evidence[c(
      "MaxAbsDifference", "MaxScaledDifference", "MaxAdaptiveRatio"
    )], use.names = FALSE)))
  jacobian_complete <- structure_complete && all(ifelse(
    evidence$ParameterClass == "log_slopes",
    evidence$JacobianStatus == "pass",
    evidence$JacobianStatus == "not_applicable"
  ))
  passed <- numeric_complete && jacobian_complete &&
    all(evidence$MaxAbsDifference <= rules$HardAbsoluteCap[rule_index]) &&
    all(evidence$MaxScaledDifference <= rules$HardScaledCap[rule_index]) &&
    all(evidence$MaxAdaptiveRatio <= rules$MaximumAdaptiveRatio[rule_index]) &&
    all(evidence$CalibrationAuthorized %in% FALSE) &&
    all(evidence$ConfirmationAuthorized %in% FALSE)
  data.frame(
    ContractVersion = mfrmr_gsc_contract_version,
    ExpectedEvidenceRows = nrow(expected),
    StructureComplete = structure_complete,
    NumericComplete = numeric_complete,
    JacobianComplete = jacobian_complete,
    CalibrationRulePass = passed,
    Status = if (passed) "calibration_rule_pass" else "rejected",
    GeneralNUMSCORETOLStatus = "pilot_required",
    CalibrationAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsc_design_contract <- function() {
  scenarios <- mfrmr_gsc_scenarios()
  points <- mfrmr_gsc_points()
  rules <- mfrmr_gsc_parameter_rules()
  expected <- mfrmr_gsc_expected_evidence_grid()
  valid <- nrow(scenarios) == 8L && !anyDuplicated(scenarios$ScenarioId) &&
    identical(sort(unique(scenarios$SlopeOwner)), c("Criterion", "Rater")) &&
    all(scenarios$SlopeOwner == scenarios$StepOwner) &&
    all(scenarios$NCategories == 5L) &&
    nrow(points) == 4L && !anyDuplicated(points$Point) &&
    nrow(rules) == length(mfrmr_gsc_expected_classes) &&
    !anyDuplicated(rules$ParameterClass) && nrow(expected) == 128L
  mfrmr_gsc_assert(valid, "The bounded GPCM score design is inconsistent.")
  list(
    contract_version = mfrmr_gsc_contract_version,
    scenarios = scenarios,
    points = points,
    parameter_rules = rules,
    numeric_rule = mfrmr_gsc_numeric_rule(),
    expected_evidence_grid = expected,
    design_ready = TRUE,
    calibration_evaluation_rule_frozen = TRUE,
    general_num_score_tol_frozen = FALSE,
    calibration_execution_authorized = FALSE,
    confirmation_authorized = FALSE
  )
}
