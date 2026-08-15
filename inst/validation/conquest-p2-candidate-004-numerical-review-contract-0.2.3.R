# Repository-only numerical-review contract for ConQuest P2 candidate 004.
#
# The external output schema had been inspected when this contract was written,
# but no candidate-004 metric result is embedded here. Acceptance budgets come
# unchanged from contracts frozen before candidate 004. The reviewer consumes
# existing artifacts only; it cannot fit, launch, rerun, widen, or promote.

mfrmr_cq_p2c4nr_specification <-
  "0.2.3-conquest-p2-candidate-004-numerical-review-contract-v1"
mfrmr_cq_p2c4nr_contract <-
  "mfrmr_conquest_p2_candidate_004_numerical_review_contract_v1"
mfrmr_cq_p2c4nr_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004"

mfrmr_cq_p2c4nr_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4nr_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c4nr_require_contracts)
  required <- c(
    "mfrmr_cq_p2c4eo_review", "mfrmr_cq_p2c4h_plan",
    "mfrmr_cq_p2c4h_command", "mfrmr_cq_p2c4po_review",
    "mfrmr_cq_p2c4_fixture", "mfrmr_cq_p2_matrix_contract",
    "mfrmr_cq_p2m_metric_rule_registry", "mfrmr_cq_p2si_budget",
    "mfrmr_cq_rop_parse_exact_decimal"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identities <- c(
    exists("mfrmr_cq_p2c4eo_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c4eo_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_004_execution_observation_v1"
      ),
    exists("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2m_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_metric_boundary_contract_v1"
      ),
    exists("mfrmr_cq_p2si_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2si_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_successor_integration_contract_v1"
      ),
    exists("mfrmr_cq_rop_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_rop_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_reported_output_precision_v1"
      )
  )
  mfrmr_cq_p2c4nr_assert(
    all(available) && all(identities),
    "Source the exact P2, candidate-004, and reported-decimal contracts first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4nr_rule <- function(rule_id, family = NULL) {
  mfrmr_cq_p2c4nr_require_contracts()
  rules <- mfrmr_cq_p2m_metric_rule_registry()
  row <- rules[rules$RuleId == rule_id, , drop = FALSE]
  if (!is.null(family)) {
    row <- row[grepl(toupper(family), row$RuleId, fixed = TRUE), , drop = FALSE]
  }
  mfrmr_cq_p2c4nr_assert(
    nrow(row) == 1L && isTRUE(row$Frozen),
    paste0("The frozen P2 rule `", rule_id, "` is unavailable.")
  )
  row
}

mfrmr_cq_p2c4nr_budget_registry <- function() {
  rule <- function(id) {
    as.numeric(mfrmr_cq_p2c4nr_rule(id)$AbsoluteTolerance)
  }
  out <- data.frame(
    BudgetId = c(
      "C4-CROSS-COORDINATE", "C4-CROSS-DEVIANCE",
      "C4-CONQUEST-Q61-Q121-COORDINATE",
      "C4-MFRMR-Q61-Q121-COORDINATE",
      "C4-CONQUEST-Q61-Q121-DEVIANCE",
      "C4-MFRMR-Q61-Q121-DEVIANCE",
      "C4-RSM-CONDITIONAL-PROBABILITY",
      "C4-PCM-CONDITIONAL-PROBABILITY",
      "C4-RATER-TIE-BAND", "C4-CRITERION-TIE-BAND"
    ),
    Units = c(
      "common_model_coordinate", "positive_deviance",
      "common_model_coordinate", "common_model_coordinate",
      "positive_deviance", "positive_deviance",
      "absolute_probability", "absolute_probability",
      "common_model_coordinate", "common_model_coordinate"
    ),
    AbsoluteTolerance = c(
      rule("P2-XENG-COORDINATE"),
      rule("P2-XENG-DEVIANCE"),
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-COORDINATE"),
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-COORDINATE"),
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE"),
      mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE"),
      rule("P2-RSM-CONDITIONAL-PROBABILITY"),
      rule("P2-PCM-CONDITIONAL-PROBABILITY"),
      as.numeric(mfrmr_cq_p2c4nr_rule("P2-RATER-ORDERING")$TieBand),
      as.numeric(mfrmr_cq_p2c4nr_rule("P2-CRITERION-ORDERING")$TieBand)
    ),
    SourceBasis = c(
      "pre_candidate_exact_reported_decimal_coordinate_rule",
      "pre_candidate_matched_constant_positive_deviance_rule",
      "successor_q61_q121_coordinate_rule",
      "successor_q61_q121_coordinate_rule",
      "successor_q61_q121_deviance_rule",
      "successor_q61_q121_deviance_rule",
      "pre_candidate_RSM_A_matrix_transport_bound",
      "pre_candidate_PCM_A_matrix_transport_bound",
      "twice_pre_candidate_coordinate_budget",
      "twice_pre_candidate_coordinate_budget"
    ),
    Candidate004OutputTuned = FALSE,
    Frozen = TRUE,
    stringsAsFactors = FALSE
  )
  mfrmr_cq_p2c4nr_assert(
    nrow(out) == 10L && !anyDuplicated(out$BudgetId) &&
      identical(out$AbsoluteTolerance[1:6],
                c(1e-5, 2e-6, 2e-6, 2e-6, 2e-6, 2e-6)) &&
      all(out$AbsoluteTolerance[7:8] > 0) &&
      identical(out$AbsoluteTolerance[9:10], c(2e-5, 2e-5)) &&
      !any(out$Candidate004OutputTuned) && all(out$Frozen),
    "The candidate-004 numerical budgets drifted from frozen P2 rules."
  )
  out
}

mfrmr_cq_p2c4nr_budget <- function(id) {
  row <- mfrmr_cq_p2c4nr_budget_registry()
  row <- row[row$BudgetId == id, , drop = FALSE]
  mfrmr_cq_p2c4nr_assert(nrow(row) == 1L, paste0("Unknown budget `", id, "`."))
  as.numeric(row$AbsoluteTolerance)
}

mfrmr_cq_p2c4nr_plan <- function() {
  mfrmr_cq_p2c4nr_require_contracts()
  plan <- mfrmr_cq_p2c4h_plan()
  out <- plan[, c(
    "ExecutionOrder", "RunId", "Family", "Nodes",
    "ExpectedFreeDimension", "ExpectedNativeOutputCount", "Prefix"
  )]
  out$CrossEngineRole <- ifelse(
    out$Nodes == 121L, "governing_dense_upper", "retained_dense_lower"
  )
  out$QMovementRole <- "q121_minus_q61_complete_pair"
  out$NumericalReviewRequired <- TRUE
  out$NewFitAuthorized <- FALSE
  out$RerunAuthorized <- FALSE
  out$EvidencePromotionAuthorized <- FALSE
  mfrmr_cq_p2c4nr_assert(
    nrow(out) == 4L &&
      identical(out$Family, c("RSM", "RSM", "PCM", "PCM")) &&
      identical(out$Nodes, c(61L, 121L, 61L, 121L)) &&
      identical(out$ExpectedFreeDimension, c(10L, 10L, 14L, 14L)) &&
      all(out$NumericalReviewRequired) && !any(out$NewFitAuthorized) &&
      !any(out$RerunAuthorized),
    "The candidate-004 numerical-review plan is incomplete or widened."
  )
  out
}

mfrmr_cq_p2c4nr_coordinate_registry <- function(family) {
  family <- toupper(as.character(family)[1L])
  mfrmr_cq_p2c4nr_assert(family %in% c("RSM", "PCM"),
                         "`family` must be RSM or PCM.")
  make <- function(coordinate, class, constraint, role, row = NA_integer_,
                   label = NA_character_, group = NA_character_,
                   a_column = NA_character_) {
    data.frame(
      Family = family, Coordinate = coordinate, ParameterClass = class,
      ConstraintRole = constraint, SourceRole = role,
      SourceRow = as.integer(row), ExpectedLabel = label,
      DerivationGroup = group, ExpectedAColumn = a_column,
      stringsAsFactors = FALSE
    )
  }
  out <- rbind(
    make("Population::Intercept", "population_intercept", "free",
         "regression_export", 1L),
    make("Population::X", "population_slope", "free",
         "regression_export", 2L),
    make("Population::Variance", "population_variance", "free",
         "covariance_export", 1L),
    make(paste0("Rater::R", 1:3), "rater_severity", "free",
         "parameter_export", 1:3, paste("rater", paste0("R", 1:3)),
         "Rater", paste0("Rater:R", 1:3)),
    make("Rater::R4", "rater_severity", "derived_sum_zero",
         "derived", group = "Rater"),
    make(paste0("Criterion::C", 1:2), "criterion_difficulty", "free",
         "parameter_export", 4:5,
         paste("criterion", paste0("C", 1:2)), "Criterion",
         paste0("Criterion:C", 1:2)),
    make("Criterion::C3", "criterion_difficulty", "derived_sum_zero",
         "derived", group = "Criterion")
  )
  if (family == "RSM") {
    out <- rbind(
      out,
      make(paste0("Step::Step_", 1:2), "shared_step", "free",
           "parameter_export", 6:7, paste("category", 1:2),
           "SharedStep", paste0("SharedStep:S", 1:2)),
      make("Step::Step_3", "shared_step", "derived_sum_zero",
           "derived", group = "SharedStep")
    )
  } else {
    parameter_row <- 6L
    for (criterion in paste0("C", 1:3)) {
      out <- rbind(
        out,
        make(
          paste0("Step::", criterion, "::Step_", 1:2),
          "criterion_specific_step", "free", "parameter_export",
          parameter_row:(parameter_row + 1L),
          paste("criterion", criterion, "category", 1:2),
          paste0("Step::", criterion),
          paste0(criterion, ":Step:S", 1:2)
        ),
        make(
          paste0("Step::", criterion, "::Step_3"),
          "criterion_specific_step", "derived_sum_zero", "derived",
          group = paste0("Step::", criterion)
        )
      )
      parameter_row <- parameter_row + 2L
    }
  }
  rownames(out) <- NULL
  expected_rows <- if (family == "RSM") 13L else 19L
  expected_free <- if (family == "RSM") 10L else 14L
  mfrmr_cq_p2c4nr_assert(
    nrow(out) == expected_rows && !anyDuplicated(out$Coordinate) &&
      sum(out$ConstraintRole == "free") == expected_free &&
      sum(out$SourceRole == "parameter_export") == expected_free - 3L,
    paste0("The ", family, " coordinate registry has the wrong dimension.")
  )
  out
}

mfrmr_cq_p2c4nr_denominator_registry <- function() {
  data.frame(
    Metric = c(
      "native_A_matrix", "raw_reported_tokens",
      "cross_engine_coordinate", "cross_engine_deviance",
      "within_engine_q_coordinate", "within_engine_q_deviance",
      "conditional_probability", "facet_ordering",
      "person_EAP_typed_state", "person_posterior_SD_typed_state",
      "mfrmr_readiness_retention", "decision_consequence_retention"
    ),
    ExpectedAtomicCount = c(
      4L, 52L, 64L, 4L, 64L, 4L, 480L, 18L,
      96L, 96L, 2L, 2L
    ),
    RequiredState = c(
      rep("eligible_and_pass_required", 8L),
      rep("typed_ineligible_pass_required", 2L),
      rep("retained_nonpromotion_state_required", 2L)
    ),
    DropFailedRowsAllowed = FALSE,
    Candidate004NumericCore = TRUE,
    FullP2DesignPortfolio = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4nr_read_character_csv <- function(path) {
  utils::read.csv(
    path, colClasses = "character", na.strings = character(),
    check.names = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4nr_extract_arm_tables <- function(
    family, nodes, parameters, regression, covariance, history) {
  family <- toupper(as.character(family)[1L])
  nodes <- as.integer(nodes)[1L]
  registry <- mfrmr_cq_p2c4nr_coordinate_registry(family)
  expected_parameter_rows <- if (family == "RSM") 7L else 11L
  mfrmr_cq_p2c4nr_assert(
    nodes %in% c(61L, 121L) &&
      nrow(parameters) == expected_parameter_rows &&
      nrow(regression) == 2L && nrow(covariance) == 1L &&
      nrow(history) >= 1L && nrow(history) <= 2000L &&
      all(c("Estimate", "Label") %in% names(parameters)) &&
      all(c("Regressor", "Estimate") %in% names(regression)) &&
      "Covariance" %in% names(covariance) &&
      all(c("Iteration", "LogLikelihood") %in% names(history)),
    paste0("The ", family, " q", nodes, " native numeric schema changed.")
  )
  iteration <- suppressWarnings(as.integer(history$Iteration))
  mfrmr_cq_p2c4nr_assert(
    identical(iteration, seq_len(nrow(history))),
    "The native iteration history is incomplete or unordered."
  )
  free <- registry[registry$ConstraintRole == "free", , drop = FALSE]
  token <- vapply(seq_len(nrow(free)), function(index) {
    role <- free$SourceRole[index]
    row <- free$SourceRow[index]
    if (role == "regression_export") regression$Estimate[row] else
    if (role == "covariance_export") covariance$Covariance[row] else
      parameters$Estimate[row]
  }, character(1L))
  parameter_free <- free$SourceRole == "parameter_export"
  mfrmr_cq_p2c4nr_assert(
    identical(
      trimws(parameters$Label[free$SourceRow[parameter_free]]),
      free$ExpectedLabel[parameter_free]
    ),
    "The native parameter labels do not match the frozen coordinate map."
  )
  parsed <- mfrmr_cq_rop_parse_exact_decimal(token)
  deviance_token <- utils::tail(history$LogLikelihood, 1L)
  deviance_parsed <- mfrmr_cq_rop_parse_exact_decimal(deviance_token)
  mfrmr_cq_p2c4nr_assert(
    all(parsed$NumericGrammarValid) &&
      isTRUE(deviance_parsed$NumericGrammarValid) &&
      all(is.finite(parsed$NumericValue)) &&
      is.finite(deviance_parsed$NumericValue) &&
      parsed$NumericValue[free$Coordinate == "Population::Variance"] > 0 &&
      deviance_parsed$NumericValue > 0,
    "A final native exact-reported-decimal token is invalid."
  )
  coordinate <- data.frame(
    Family = family, Nodes = nodes, Coordinate = free$Coordinate,
    ParameterClass = free$ParameterClass,
    ConstraintRole = free$ConstraintRole,
    NativeToken = token, Estimate = parsed$NumericValue,
    CanonicalExactDecimal = parsed$CanonicalExactDecimal,
    SourcePrecisionStatus = "exact_reported_decimal_rounding_unknown",
    HiddenSolutionIntervalAvailable = FALSE,
    stringsAsFactors = FALSE
  )
  derived <- registry[registry$ConstraintRole == "derived_sum_zero", , drop = FALSE]
  for (index in seq_len(nrow(derived))) {
    members <- !is.na(registry$DerivationGroup) &
      registry$DerivationGroup == derived$DerivationGroup[index] &
      registry$ConstraintRole == "free"
    source <- coordinate[match(
      registry$Coordinate[members], coordinate$Coordinate
    ), , drop = FALSE]
    mfrmr_cq_p2c4nr_assert(
      nrow(source) >= 2L && !anyNA(source$Estimate),
      "A derived sum-zero coordinate has incomplete source tokens."
    )
    coordinate <- rbind(coordinate, data.frame(
      Family = family, Nodes = nodes,
      Coordinate = derived$Coordinate[index],
      ParameterClass = derived$ParameterClass[index],
      ConstraintRole = "derived_sum_zero",
      NativeToken = paste0("-sum(", paste(source$NativeToken, collapse = ";"), ")"),
      Estimate = -sum(source$Estimate),
      CanonicalExactDecimal = NA_character_,
      SourcePrecisionStatus = "derived_from_exact_reported_decimals",
      HiddenSolutionIntervalAvailable = FALSE,
      stringsAsFactors = FALSE
    ))
  }
  coordinate <- coordinate[match(registry$Coordinate, coordinate$Coordinate), , drop = FALSE]
  rownames(coordinate) <- NULL
  raw <- rbind(
    coordinate[coordinate$ConstraintRole == "free", c(
      "Family", "Nodes", "Coordinate", "NativeToken", "Estimate",
      "CanonicalExactDecimal", "SourcePrecisionStatus"
    )],
    data.frame(
      Family = family, Nodes = nodes, Coordinate = "Deviance",
      NativeToken = deviance_token, Estimate = deviance_parsed$NumericValue,
      CanonicalExactDecimal = deviance_parsed$CanonicalExactDecimal,
      SourcePrecisionStatus = "exact_reported_decimal_rounding_unknown",
      stringsAsFactors = FALSE
    )
  )
  list(
    coordinate = coordinate,
    deviance = as.numeric(deviance_parsed$NumericValue),
    deviance_token = deviance_token,
    raw_tokens = raw,
    iterations = nrow(history),
    reported_output_estimand_ready = TRUE,
    rounding_rule_inferred = FALSE,
    hidden_solution_interval_available = FALSE
  )
}

mfrmr_cq_p2c4nr_a_matrix_exact <- function(amatrix, family) {
  family <- toupper(as.character(family)[1L])
  registry <- mfrmr_cq_p2c4nr_coordinate_registry(family)
  conditional <- registry[
    registry$ConstraintRole == "free" &
      registry$SourceRole == "parameter_export", , drop = FALSE
  ]
  expected <- mfrmr_cq_p2_matrix_contract(family)
  mfrmr_cq_p2c4nr_assert(
    nrow(amatrix) == 48L &&
      all(c("GIN", "Category") %in% names(amatrix)) &&
      identical(trimws(names(amatrix)[-(1:2)]), conditional$ExpectedLabel),
    paste0("The ", family, " native A-matrix schema changed.")
  )
  gin <- suppressWarnings(as.integer(amatrix$GIN))
  category <- suppressWarnings(as.integer(amatrix$Category))
  native <- apply(amatrix[, -(1:2), drop = FALSE], 2L, as.numeric)
  if (is.null(dim(native))) native <- matrix(native, ncol = 1L)
  rater <- paste0("R", ((gin - 1L) %% 4L) + 1L)
  criterion <- paste0("C", ((gin - 1L) %/% 4L) + 1L)
  key <- paste0(rater, "::", criterion, "::k", category - 1L)
  index <- match(expected$C$RowKey, key)
  ready <- !anyNA(c(gin, category, native, index)) &&
    identical(sort(unique(gin)), 1:12) &&
    all(table(gin) == 4L) &&
    identical(sort(unique(category)), 1:4) &&
    identical(
      unname(native[index, , drop = FALSE]), unname(expected$A)
    )
  isTRUE(ready)
}

mfrmr_cq_p2c4nr_arm_files <- function(output_root, run_id) {
  prefix <- paste0("cq_p2c4_", run_id)
  root <- file.path(output_root, run_id)
  list(
    command = file.path(root, paste0(prefix, ".cqc")),
    console = file.path(root, paste0(prefix, "_console.log")),
    parameters = file.path(root, paste0(prefix, "_conquest_parameters.csv")),
    amatrix = file.path(root, paste0(prefix, "_conquest_amatrix.csv")),
    regression = file.path(root, paste0(prefix, "_conquest_reg_coefficients.csv")),
    covariance = file.path(root, paste0(prefix, "_conquest_covariance.csv")),
    cases = file.path(root, paste0(prefix, "_conquest_cases_eap.csv")),
    history = file.path(root, paste0(prefix, "_conquest_history.csv")),
    internal_log = file.path(root, paste0(prefix, "_conquest_internal.log")),
    parameter_review = file.path(root, paste0(prefix, "_conquest_parameters_review.txt"))
  )
}

mfrmr_cq_p2c4nr_read_arm <- function(output_root, arm) {
  files <- mfrmr_cq_p2c4nr_arm_files(output_root, arm$RunId)
  mfrmr_cq_p2c4nr_assert(
    all(vapply(files, file.exists, logical(1L))),
    paste0("The retained arm `", arm$RunId, "` is incomplete.")
  )
  command <- readLines(files$command, warn = FALSE)
  console <- readLines(files$console, warn = FALSE)
  internal <- readLines(files$internal_log, warn = FALSE)
  mfrmr_cq_p2c4nr_assert(
    identical(command, mfrmr_cq_p2c4h_command(
      arm$Prefix, arm$Family, arm$Nodes
    )) && any(grepl("End of Program", console, fixed = TRUE)) &&
      any(grepl(
        "Deviance change is less than convergence criterion",
        console, fixed = TRUE
      )) && any(grepl("quit", utils::tail(internal, 20L), fixed = TRUE)),
    paste0("The command or convergence transcript failed for `", arm$RunId, "`.")
  )
  extracted <- mfrmr_cq_p2c4nr_extract_arm_tables(
    arm$Family, arm$Nodes,
    mfrmr_cq_p2c4nr_read_character_csv(files$parameters),
    mfrmr_cq_p2c4nr_read_character_csv(files$regression),
    mfrmr_cq_p2c4nr_read_character_csv(files$covariance),
    mfrmr_cq_p2c4nr_read_character_csv(files$history)
  )
  amatrix <- mfrmr_cq_p2c4nr_read_character_csv(files$amatrix)
  cases <- mfrmr_cq_p2c4nr_read_character_csv(files$cases)
  person_ready <- nrow(cases) == 48L &&
    length(unique(trimws(cases$PID))) == 48L &&
    all(is.finite(suppressWarnings(as.numeric(cases$EAP_1)))) &&
    all(is.finite(suppressWarnings(as.numeric(cases$PosteriorSD_1))))
  c(
    extracted,
    list(
      run_id = arm$RunId,
      native_A_matrix_exact = mfrmr_cq_p2c4nr_a_matrix_exact(
        amatrix, arm$Family
      ),
      person_export_structurally_ready = person_ready,
      person_posterior_numerically_eligible = FALSE
    )
  )
}

mfrmr_cq_p2c4nr_semantic_fixture_equal <- function(actual, canonical, score) {
  columns <- c(
    "Person", "PersonIndex", "X", "Rater", "RaterIndex",
    "Criterion", "CriterionIndex"
  )
  if (!all(c(columns, score) %in% names(actual))) return(FALSE)
  actual <- actual[, c(columns, score), drop = FALSE]
  names(actual)[ncol(actual)] <- "Response"
  expected <- canonical[, c(columns, "Response"), drop = FALSE]
  order_rows <- function(x) x[order(
    x$PersonIndex, x$RaterIndex, x$CriterionIndex
  ), , drop = FALSE]
  actual <- order_rows(actual)
  expected <- order_rows(expected)
  rownames(actual) <- rownames(expected) <- NULL
  character_columns <- c("Person", "Rater", "Criterion")
  numeric_columns <- setdiff(names(expected), character_columns)
  for (column in character_columns) {
    actual[[column]] <- as.character(actual[[column]])
    expected[[column]] <- as.character(expected[[column]])
  }
  for (column in numeric_columns) {
    actual[[column]] <- suppressWarnings(as.numeric(actual[[column]]))
    expected[[column]] <- suppressWarnings(as.numeric(expected[[column]]))
  }
  if (anyNA(actual) || anyNA(expected)) return(FALSE)
  identical(actual, expected)
}

mfrmr_cq_p2c4nr_serialized_numeric_equal <- function(actual, expected) {
  actual <- as.numeric(actual)
  expected <- as.numeric(expected)
  length(actual) == length(expected) && !anyNA(c(actual, expected)) &&
    all(abs(actual - expected) <=
          64 * .Machine$double.eps * pmax(1, abs(expected)))
}

mfrmr_cq_p2c4nr_read_reference <- function(mfrmr_root) {
  required <- c(
    "coordinates.csv", "fit_summary.csv", "fixture_long.csv",
    "preflight_plan.csv", "run_summary.csv"
  )
  mfrmr_cq_p2c4nr_assert(
    all(file.exists(file.path(mfrmr_root, required))),
    "The retained candidate-004 mfrmr preflight is incomplete."
  )
  coordinates <- utils::read.csv(
    file.path(mfrmr_root, "coordinates.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  fits <- utils::read.csv(
    file.path(mfrmr_root, "fit_summary.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  fixture <- utils::read.csv(
    file.path(mfrmr_root, "fixture_long.csv"), stringsAsFactors = FALSE,
    check.names = FALSE
  )
  canonical <- mfrmr_cq_p2c4_fixture()$Data
  plan <- mfrmr_cq_p2c4nr_plan()
  expected_fits <- mfrmr_cq_p2c4po_review()$fit_summary
  fits <- fits[fits$RunId %in% plan$RunId, , drop = FALSE]
  fits <- fits[match(plan$RunId, fits$RunId), , drop = FALSE]
  expected_fits <- expected_fits[match(plan$RunId, expected_fits$RunId), , drop = FALSE]
  coordinates <- coordinates[coordinates$RunId %in% plan$RunId, , drop = FALSE]
  expected_coordinate <- unlist(lapply(c("RSM", "PCM"), function(family) {
    mfrmr_cq_p2c4nr_coordinate_registry(family)$Coordinate
  }))
  expected_coordinate <- rep(expected_coordinate, times = 1L)
  expected_counts <- c(RSM = 2L * 13L, PCM = 2L * 19L)
  count <- table(factor(coordinates$Family, levels = c("RSM", "PCM")))
  key <- paste(coordinates$RunId, coordinates$Coordinate, sep = "\r")
  coordinate_identity <- length(key) == 64L && !anyDuplicated(key) &&
    identical(as.integer(count), unname(expected_counts)) &&
    all(vapply(seq_len(nrow(plan)), function(index) {
      observed <- coordinates$Coordinate[coordinates$RunId == plan$RunId[index]]
      identical(
        observed,
        mfrmr_cq_p2c4nr_coordinate_registry(plan$Family[index])$Coordinate
      )
    }, logical(1L)))
  fit_identity <- nrow(fits) == 4L &&
    identical(as.character(fits$RunId), plan$RunId) &&
    identical(as.integer(fits$ObservedNpar), plan$ExpectedFreeDimension) &&
    all(fits$ConvergenceStatus == "converged") &&
    all(fits$StructuralNumericalPass) && !any(fits$InferenceReady) &&
    all(fits$OnlyDesignRankNotEvaluatedHold) &&
    mfrmr_cq_p2c4nr_serialized_numeric_equal(
      fits$Deviance, expected_fits$Deviance
    ) && mfrmr_cq_p2c4nr_serialized_numeric_equal(
      fits$PopulationVariance, expected_fits$PopulationVariance
    )
  fixture_identity <- mfrmr_cq_p2c4nr_semantic_fixture_equal(
    fixture, canonical, "Score"
  )
  mfrmr_cq_p2c4nr_assert(
    coordinate_identity && fit_identity && fixture_identity &&
      all(is.finite(coordinates$Estimate)),
    "The retained mfrmr reference failed semantic identity checks."
  )
  list(
    coordinates = coordinates,
    fits = fits,
    coordinate_identity = coordinate_identity,
    fit_identity = fit_identity,
    fixture_identity = fixture_identity
  )
}

mfrmr_cq_p2c4nr_probability <- function(family, coordinate) {
  value <- stats::setNames(coordinate$Estimate, coordinate$Coordinate)
  cases <- expand.grid(
    Theta = c(-2.25, -0.50, 0, 0.75, 2.40),
    Rater = paste0("R", 1:4), Criterion = paste0("C", 1:3),
    Category = 0:3, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  group <- split(seq_len(nrow(cases)), paste(
    cases$Theta, cases$Rater, cases$Criterion, sep = "\r"
  ))
  probability <- numeric(nrow(cases))
  for (index in group) {
    row <- cases[index[1L], , drop = FALSE]
    steps <- if (family == "RSM") {
      value[paste0("Step::Step_", 1:3)]
    } else {
      value[paste0("Step::", row$Criterion, "::Step_", 1:3)]
    }
    eta <- row$Theta - value[paste0("Rater::", row$Rater)] -
      value[paste0("Criterion::", row$Criterion)]
    kernel <- 0:3 * eta - c(0, cumsum(steps))
    kernel <- kernel - max(kernel)
    p <- exp(kernel) / sum(exp(kernel))
    probability[index] <- p[cases$Category[index] + 1L]
  }
  cases$Probability <- probability
  cases
}

mfrmr_cq_p2c4nr_order_class <- function(delta, tie_band) {
  ifelse(abs(delta) <= tie_band, "tie", ifelse(delta < 0, "first_lower", "first_higher"))
}

mfrmr_cq_p2c4nr_order_rows <- function(family, engine, coordinate) {
  value <- stats::setNames(coordinate$Estimate, coordinate$Coordinate)
  make <- function(facet, levels, tie_band) {
    pairs <- utils::combn(levels, 2L, simplify = FALSE)
    do.call(rbind, lapply(pairs, function(pair) {
      first <- paste0(facet, "::", pair[1L])
      second <- paste0(facet, "::", pair[2L])
      delta <- value[first] - value[second]
      data.frame(
        Family = family, Engine = engine, Facet = facet,
        First = pair[1L], Second = pair[2L], Delta = delta,
        TieBand = tie_band,
        Classification = mfrmr_cq_p2c4nr_order_class(delta, tie_band),
        stringsAsFactors = FALSE
      )
    }))
  }
  rbind(
    make("Rater", paste0("R", 1:4),
         mfrmr_cq_p2c4nr_budget("C4-RATER-TIE-BAND")),
    make("Criterion", paste0("C", 1:3),
         mfrmr_cq_p2c4nr_budget("C4-CRITERION-TIE-BAND"))
  )
}

mfrmr_cq_p2c4nr_review <- function(output_root, mfrmr_root) {
  mfrmr_cq_p2c4nr_require_contracts()
  execution <- mfrmr_cq_p2c4eo_review()
  mfrmr_cq_p2c4nr_assert(
    isTRUE(execution$all_four_semantically_complete) &&
      isTRUE(execution$same_author_technical_review_authorized),
    "Candidate 004 is not eligible for same-author numerical review."
  )
  output_root <- normalizePath(output_root, winslash = "/", mustWork = TRUE)
  mfrmr_root <- normalizePath(mfrmr_root, winslash = "/", mustWork = TRUE)
  plan <- mfrmr_cq_p2c4nr_plan()
  canonical <- mfrmr_cq_p2c4_fixture()$Data
  external_fixture <- utils::read.csv(
    file.path(output_root, "sealed_fixture_long.csv"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  mfrmr_cq_p2c4nr_assert(
    mfrmr_cq_p2c4nr_semantic_fixture_equal(
      external_fixture, canonical, "Response"
    ),
    "The ConQuest fixture is not semantically candidate 004."
  )
  reference <- mfrmr_cq_p2c4nr_read_reference(mfrmr_root)
  arm <- lapply(seq_len(nrow(plan)), function(index) {
    mfrmr_cq_p2c4nr_read_arm(output_root, plan[index, , drop = FALSE])
  })
  names(arm) <- plan$RunId
  native_coordinate <- do.call(rbind, lapply(seq_along(arm), function(index) {
    out <- arm[[index]]$coordinate
    out$RunId <- plan$RunId[index]
    out[, c("RunId", setdiff(names(out), "RunId")), drop = FALSE]
  }))
  native_deviance <- data.frame(
    RunId = plan$RunId, Family = plan$Family, Nodes = plan$Nodes,
    ConQuestDeviance = vapply(arm, `[[`, numeric(1L), "deviance"),
    stringsAsFactors = FALSE
  )
  raw_tokens <- do.call(rbind, lapply(seq_along(arm), function(index) {
    out <- arm[[index]]$raw_tokens
    out$RunId <- plan$RunId[index]
    out[, c("RunId", setdiff(names(out), "RunId")), drop = FALSE]
  }))
  ref_coordinate <- reference$coordinates[, c(
    "RunId", "Family", "Nodes", "Coordinate", "Estimate"
  )]
  names(ref_coordinate)[names(ref_coordinate) == "Estimate"] <- "MfrmrEstimate"
  key_native <- paste(native_coordinate$RunId, native_coordinate$Coordinate, sep = "\r")
  key_reference <- paste(ref_coordinate$RunId, ref_coordinate$Coordinate, sep = "\r")
  mfrmr_cq_p2c4nr_assert(
    nrow(native_coordinate) == 64L && !anyDuplicated(key_native) &&
      !anyDuplicated(key_reference) && setequal(key_native, key_reference),
    "The 64-row cross-engine coordinate denominator is incomplete."
  )
  ref_coordinate <- ref_coordinate[match(key_native, key_reference), , drop = FALSE]
  cross_coordinate <- native_coordinate
  cross_coordinate$MfrmrEstimate <- ref_coordinate$MfrmrEstimate
  cross_coordinate$Difference <-
    cross_coordinate$Estimate - cross_coordinate$MfrmrEstimate
  cross_coordinate$AbsoluteDifference <- abs(cross_coordinate$Difference)
  cross_coordinate$Tolerance <- mfrmr_cq_p2c4nr_budget("C4-CROSS-COORDINATE")
  cross_coordinate$Pass <-
    cross_coordinate$AbsoluteDifference <= cross_coordinate$Tolerance

  fit <- reference$fits[, c("RunId", "Deviance")]
  cross_deviance <- merge(native_deviance, fit, by = "RunId", sort = FALSE)
  cross_deviance <- cross_deviance[match(plan$RunId, cross_deviance$RunId), , drop = FALSE]
  cross_deviance$MatchedConstantProven <- TRUE
  cross_deviance$Difference <- cross_deviance$ConQuestDeviance - cross_deviance$Deviance
  cross_deviance$AbsoluteDifference <- abs(cross_deviance$Difference)
  cross_deviance$Tolerance <- mfrmr_cq_p2c4nr_budget("C4-CROSS-DEVIANCE")
  cross_deviance$Pass <- cross_deviance$MatchedConstantProven &
    cross_deviance$AbsoluteDifference <= cross_deviance$Tolerance

  q_coordinate <- do.call(rbind, lapply(c("ConQuest", "mfrmr"), function(engine) {
    source <- if (engine == "ConQuest") {
      native_coordinate[, c("Family", "Nodes", "Coordinate", "Estimate")]
    } else {
      data.frame(
        Family = ref_coordinate$Family, Nodes = ref_coordinate$Nodes,
        Coordinate = ref_coordinate$Coordinate,
        Estimate = ref_coordinate$MfrmrEstimate, stringsAsFactors = FALSE
      )
    }
    do.call(rbind, lapply(c("RSM", "PCM"), function(family) {
      lower <- source[source$Family == family & source$Nodes == 61L, , drop = FALSE]
      upper <- source[source$Family == family & source$Nodes == 121L, , drop = FALSE]
      upper <- upper[match(lower$Coordinate, upper$Coordinate), , drop = FALSE]
      data.frame(
        Engine = engine, Family = family, Coordinate = lower$Coordinate,
        Difference = upper$Estimate - lower$Estimate,
        AbsoluteDifference = abs(upper$Estimate - lower$Estimate),
        Tolerance = mfrmr_cq_p2c4nr_budget(paste0(
          "C4-", toupper(engine), "-Q61-Q121-COORDINATE"
        )),
        stringsAsFactors = FALSE
      )
    }))
  }))
  q_coordinate$Pass <- q_coordinate$AbsoluteDifference <= q_coordinate$Tolerance

  q_deviance <- do.call(rbind, lapply(c("ConQuest", "mfrmr"), function(engine) {
    source <- if (engine == "ConQuest") {
      data.frame(Family = native_deviance$Family, Nodes = native_deviance$Nodes,
                 Deviance = native_deviance$ConQuestDeviance)
    } else {
      reference$fits[, c("Family", "Nodes", "Deviance")]
    }
    do.call(rbind, lapply(c("RSM", "PCM"), function(family) {
      value <- source[source$Family == family, , drop = FALSE]
      difference <- value$Deviance[value$Nodes == 121L] -
        value$Deviance[value$Nodes == 61L]
      data.frame(
        Engine = engine, Family = family, Difference = difference,
        AbsoluteDifference = abs(difference),
        Tolerance = mfrmr_cq_p2c4nr_budget(paste0(
          "C4-", toupper(engine), "-Q61-Q121-DEVIANCE"
        )),
        MatchedConstantProven = TRUE, stringsAsFactors = FALSE
      )
    }))
  }))
  q_deviance$Pass <- q_deviance$MatchedConstantProven &
    q_deviance$AbsoluteDifference <= q_deviance$Tolerance

  probability <- do.call(rbind, lapply(c("RSM", "PCM"), function(family) {
    native <- native_coordinate[
      native_coordinate$Family == family & native_coordinate$Nodes == 121L,
      c("Coordinate", "Estimate"), drop = FALSE
    ]
    reference_rows <- ref_coordinate[
      ref_coordinate$Family == family & ref_coordinate$Nodes == 121L,
      c("Coordinate", "MfrmrEstimate"), drop = FALSE
    ]
    names(reference_rows)[2L] <- "Estimate"
    cq <- mfrmr_cq_p2c4nr_probability(family, native)
    mr <- mfrmr_cq_p2c4nr_probability(family, reference_rows)
    key <- paste(cq$Theta, cq$Rater, cq$Criterion, cq$Category, sep = "\r")
    reference_key <- paste(mr$Theta, mr$Rater, mr$Criterion, mr$Category, sep = "\r")
    mr <- mr[match(key, reference_key), , drop = FALSE]
    data.frame(
      Family = family, cq[, c("Theta", "Rater", "Criterion", "Category")],
      ConQuestProbability = cq$Probability,
      MfrmrProbability = mr$Probability,
      Difference = cq$Probability - mr$Probability,
      AbsoluteDifference = abs(cq$Probability - mr$Probability),
      Tolerance = mfrmr_cq_p2c4nr_budget(paste0(
        "C4-", family, "-CONDITIONAL-PROBABILITY"
      )),
      stringsAsFactors = FALSE
    )
  }))
  probability$Pass <- probability$AbsoluteDifference <= probability$Tolerance

  ordering <- do.call(rbind, lapply(c("RSM", "PCM"), function(family) {
    native <- native_coordinate[
      native_coordinate$Family == family & native_coordinate$Nodes == 121L,
      c("Coordinate", "Estimate"), drop = FALSE
    ]
    reference_rows <- ref_coordinate[
      ref_coordinate$Family == family & ref_coordinate$Nodes == 121L,
      c("Coordinate", "MfrmrEstimate"), drop = FALSE
    ]
    names(reference_rows)[2L] <- "Estimate"
    cq <- mfrmr_cq_p2c4nr_order_rows(family, "ConQuest", native)
    mr <- mfrmr_cq_p2c4nr_order_rows(family, "mfrmr", reference_rows)
    key <- paste(cq$Facet, cq$First, cq$Second, sep = "\r")
    reference_key <- paste(mr$Facet, mr$First, mr$Second, sep = "\r")
    mr <- mr[match(key, reference_key), , drop = FALSE]
    data.frame(
      Family = family, cq[, c("Facet", "First", "Second")],
      ConQuestClassification = cq$Classification,
      MfrmrClassification = mr$Classification,
      Pass = cq$Classification == mr$Classification,
      stringsAsFactors = FALSE
    )
  }))

  person_state <- do.call(rbind, lapply(seq_along(arm), function(index) {
    if (plan$Nodes[index] != 121L) return(NULL)
    data.frame(
      Family = plan$Family[index],
      Metric = c("person_EAP", "person_posterior_SD"),
      ExpectedAtomicCount = 48L,
      ObservedExternalAtomicCount = if (arm[[index]]$person_export_structurally_ready) 48L else 0L,
      State = "typed_ineligible_pending_posterior_identity",
      NumericComparisonAuthorized = FALSE,
      Pass = arm[[index]]$person_export_structurally_ready &&
        !arm[[index]]$person_posterior_numerically_eligible,
      stringsAsFactors = FALSE
    )
  }))
  readiness <- data.frame(
    Family = c("RSM", "PCM"),
    MfrmrInferenceReady = FALSE,
    MfrmrReadinessReason = "design_rank_not_evaluated",
    ExternalAgreementCanPromote = FALSE,
    RetainedStatePass = TRUE,
    stringsAsFactors = FALSE
  )
  decision <- data.frame(
    Family = c("RSM", "PCM"),
    CandidateRunOnceConsumed = TRUE,
    RerunAuthorized = FALSE,
    WiderExecutionAuthorized = FALSE,
    EvidencePromotionAuthorized = FALSE,
    RetainedDecisionPass = TRUE,
    stringsAsFactors = FALSE
  )
  denominator <- mfrmr_cq_p2c4nr_denominator_registry()
  observed <- c(
    sum(vapply(arm, `[[`, logical(1L), "native_A_matrix_exact")),
    nrow(raw_tokens), nrow(cross_coordinate), nrow(cross_deviance),
    nrow(q_coordinate), nrow(q_deviance), nrow(probability), nrow(ordering),
    sum(person_state$ExpectedAtomicCount[person_state$Metric == "person_EAP"]),
    sum(person_state$ExpectedAtomicCount[person_state$Metric == "person_posterior_SD"]),
    nrow(readiness), nrow(decision)
  )
  passed <- c(
    sum(vapply(arm, `[[`, logical(1L), "native_A_matrix_exact")),
    sum(!is.na(raw_tokens$CanonicalExactDecimal)),
    sum(cross_coordinate$Pass), sum(cross_deviance$Pass),
    sum(q_coordinate$Pass), sum(q_deviance$Pass),
    sum(probability$Pass), sum(ordering$Pass),
    sum(person_state$ExpectedAtomicCount[
      person_state$Metric == "person_EAP" & person_state$Pass
    ]),
    sum(person_state$ExpectedAtomicCount[
      person_state$Metric == "person_posterior_SD" & person_state$Pass
    ]),
    sum(readiness$RetainedStatePass), sum(decision$RetainedDecisionPass)
  )
  denominator$ObservedAtomicCount <- observed
  denominator$PassedAtomicCount <- passed
  denominator$Complete <- observed == denominator$ExpectedAtomicCount
  denominator$Passed <- passed == denominator$ExpectedAtomicCount
  core_passed <- all(denominator$Complete) && all(denominator$Passed)
  list(
    specification = mfrmr_cq_p2c4nr_specification,
    contract_version = mfrmr_cq_p2c4nr_contract,
    candidate_id = mfrmr_cq_p2c4nr_candidate_id,
    status = if (core_passed) {
      "candidate_004_same_author_numeric_core_passed_independent_promotion_review_pending"
    } else {
      "candidate_004_numerical_disagreement_or_invalid_complete_denominator_retained"
    },
    plan = plan, budget_registry = mfrmr_cq_p2c4nr_budget_registry(),
    denominator = denominator, raw_tokens = raw_tokens,
    cross_engine_coordinate = cross_coordinate,
    cross_engine_deviance = cross_deviance,
    within_engine_q_coordinate = q_coordinate,
    within_engine_q_deviance = q_deviance,
    conditional_probability = probability,
    ordering = ordering, person_state = person_state,
    readiness = readiness, decision_consequence = decision,
    native_A_matrices_exact = all(vapply(
      arm, `[[`, logical(1L), "native_A_matrix_exact"
    )),
    raw_reported_tokens_retained = nrow(raw_tokens) == 52L,
    rounding_rule_inferred = FALSE,
    hidden_solution_interval_available = FALSE,
    matched_deviance_constant_proven = all(
      cross_deviance$MatchedConstantProven
    ) && all(q_deviance$MatchedConstantProven),
    same_author_numeric_core_passed = core_passed,
    independent_comprehensive_review_passed = FALSE,
    mfrmr_inference_ready = FALSE,
    complete_P2_design_portfolio_reviewed = FALSE,
    rerun_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
