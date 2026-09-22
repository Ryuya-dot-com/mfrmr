# Repository-only semantic runner for the fixed FACETS RSM/PCM confirmation.
# It builds no responses and launches no fit. It validates future case and
# coordinate evidence, recomputes eligibility, and applies the frozen rule.

mfrmr_facets_mfr_contract_version <-
  "mfrmr_facets_multifacet_confirmation_runner_v1"

mfrmr_facets_mfr_require_support <- function() {
  required <- c(
    "mfrmr_facets_mfc_design", "mfrmr_facets_mfc_validate",
    "mfrmr_facets_mfa_contract", "mfrmr_facets_mfa_adjudicate_coordinates"
  )
  support_env <- parent.env(environment())
  available <- vapply(required, function(name) {
    exists(name, envir = support_env, mode = "function", inherits = TRUE)
  }, logical(1))
  missing <- required[!available]
  if (length(missing)) {
    stop("Confirmation runner support is missing: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfr_facet_levels <- function(total_facets) {
  levels <- list(
    Person = sprintf("P%03d", seq_len(40L)),
    Rater = sprintf("R%02d", seq_len(4L)),
    Task = sprintf("T%02d", seq_len(3L)),
    Occasion = sprintf("O%02d", seq_len(2L)),
    Criterion = sprintf("C%02d", seq_len(4L))
  )
  facets <- switch(
    as.character(total_facets),
    `3` = c("Person", "Rater", "Criterion"),
    `4` = c("Person", "Rater", "Task", "Criterion"),
    `5` = c("Person", "Rater", "Task", "Occasion", "Criterion"),
    stop("TotalFacets must be 3, 4, or 5.", call. = FALSE)
  )
  levels[facets]
}

mfrmr_facets_mfr_expected_elements <- function(registry) {
  rows <- lapply(seq_len(nrow(registry)), function(i) {
    case <- registry[i, , drop = FALSE]
    levels <- mfrmr_facets_mfr_facet_levels(case$TotalFacets)
    coordinates <- do.call(rbind, lapply(names(levels), function(facet) {
      data.frame(Facet = facet, Level = levels[[facet]],
                 stringsAsFactors = FALSE)
    }))
    data.frame(
      ScenarioId = case$ScenarioId,
      BaseSeed = case$BaseSeed,
      DesignSeed = case$DesignSeed,
      Model = case$Model,
      TotalFacets = case$TotalFacets,
      coordinates,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_facets_mfr_expected_steps <- function(registry) {
  rows <- lapply(seq_len(nrow(registry)), function(i) {
    case <- registry[i, , drop = FALSE]
    owners <- if (identical(case$Model, "RSM")) {
      "Common"
    } else {
      sprintf("C%02d", seq_len(4L))
    }
    coordinates <- expand.grid(
      StepFacet = owners,
      Step = paste0("Step_", seq_len(3L)),
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
    data.frame(
      ScenarioId = case$ScenarioId,
      BaseSeed = case$BaseSeed,
      DesignSeed = case$DesignSeed,
      Model = case$Model,
      TotalFacets = case$TotalFacets,
      coordinates,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_facets_mfr_empty_manifest <- function(registry) {
  data.frame(
    ScenarioId = registry$ScenarioId,
    BaseSeed = registry$BaseSeed,
    DesignSeed = registry$DesignSeed,
    Model = registry$Model,
    TotalFacets = registry$TotalFacets,
    ExecutionStatus = "not_run",
    ResultOpened = FALSE,
    FACETSReturnCode = NA_integer_,
    FACETSReportedConvergenceScoreResidual = NA_real_,
    FACETSReportedConvergenceLogitChange = NA_real_,
    FACETSConvergenceSpecificationPassed = FALSE,
    FACETSConvergenceAchieved = FALSE,
    FACETSFinalIteration = NA_integer_,
    FACETSFinalElementScoreResidual = NA_real_,
    FACETSFinalElementLogitChange = NA_real_,
    MfrmrFitReturned = FALSE,
    MfrmrConvergenceCode = NA_integer_,
    MfrmrEstimationConverged = FALSE,
    MfrmrTerminalGradientSupNorm = NA_real_,
    MfrmrGradientReviewTolerance = NA_real_,
    ElementCoordinateContractPassed = FALSE,
    StepCoordinateContractPassed = FALSE,
    ComparisonEligible = FALSE,
    Warnings = "",
    Error = NA_character_,
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfr_numerical_gates <- function(manifest, registry) {
  score_specification_allowance <- 8 * .Machine$double.eps * pmax(
    1, abs(manifest$FACETSReportedConvergenceScoreResidual),
    abs(registry$FACETSConvergenceScoreResidual)
  )
  logit_specification_allowance <- 8 * .Machine$double.eps * pmax(
    1, abs(manifest$FACETSReportedConvergenceLogitChange),
    abs(registry$FACETSConvergenceLogitChange)
  )
  facets_specification <-
    is.finite(manifest$FACETSReportedConvergenceScoreResidual) &
    abs(manifest$FACETSReportedConvergenceScoreResidual -
          registry$FACETSConvergenceScoreResidual) <=
      score_specification_allowance &
    is.finite(manifest$FACETSReportedConvergenceLogitChange) &
    abs(manifest$FACETSReportedConvergenceLogitChange -
          registry$FACETSConvergenceLogitChange) <=
      logit_specification_allowance
  facets_achieved <-
    !is.na(manifest$FACETSFinalIteration) & manifest$FACETSFinalIteration > 0L &
    is.finite(manifest$FACETSFinalElementScoreResidual) &
    abs(manifest$FACETSFinalElementScoreResidual) <=
      registry$FACETSConvergenceScoreResidual &
    is.finite(manifest$FACETSFinalElementLogitChange) &
    abs(manifest$FACETSFinalElementLogitChange) <=
      registry$FACETSConvergenceLogitChange
  mfrmr_converged <-
    !is.na(manifest$MfrmrConvergenceCode) &
    manifest$MfrmrConvergenceCode == 0L
  mfrmr_gradient <-
    is.finite(manifest$MfrmrTerminalGradientSupNorm) &
    is.finite(manifest$MfrmrGradientReviewTolerance) &
    manifest$MfrmrTerminalGradientSupNorm >= 0 &
    manifest$MfrmrGradientReviewTolerance > 0 &
    manifest$MfrmrTerminalGradientSupNorm <=
      manifest$MfrmrGradientReviewTolerance
  list(
    facets_specification = facets_specification,
    facets_achieved = facets_achieved,
    mfrmr_converged = mfrmr_converged,
    mfrmr_gradient = mfrmr_gradient
  )
}

mfrmr_facets_mfr_eligibility <- function(manifest, registry) {
  gates <- mfrmr_facets_mfr_numerical_gates(manifest, registry)
  facets_numerical <-
    !is.na(manifest$FACETSReturnCode) & manifest$FACETSReturnCode == 0L &
    gates$facets_specification & gates$facets_achieved
  mfrmr_numerical <- manifest$MfrmrFitReturned & gates$mfrmr_converged &
    gates$mfrmr_gradient
  manifest$ExecutionStatus == "completed" & facets_numerical &
    mfrmr_numerical & manifest$ElementCoordinateContractPassed &
    manifest$StepCoordinateContractPassed & is.na(manifest$Error)
}

mfrmr_facets_mfr_validate_manifest <- function(manifest, registry) {
  if (!is.data.frame(manifest)) {
    stop("Confirmation manifest must be a data frame.", call. = FALSE)
  }
  required <- c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets",
    "ExecutionStatus", "ResultOpened", "FACETSReturnCode",
    "FACETSReportedConvergenceScoreResidual",
    "FACETSReportedConvergenceLogitChange",
    "FACETSConvergenceSpecificationPassed", "FACETSConvergenceAchieved",
    "FACETSFinalIteration", "FACETSFinalElementScoreResidual",
    "FACETSFinalElementLogitChange", "MfrmrFitReturned",
    "MfrmrConvergenceCode", "MfrmrEstimationConverged",
    "MfrmrTerminalGradientSupNorm", "MfrmrGradientReviewTolerance",
    "ElementCoordinateContractPassed", "StepCoordinateContractPassed",
    "ComparisonEligible", "Warnings", "Error"
  )
  missing <- setdiff(required, names(manifest))
  if (length(missing)) {
    stop("Confirmation manifest is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  identity_fields <- c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets"
  )
  if (nrow(manifest) != nrow(registry) ||
      anyDuplicated(manifest$ScenarioId) ||
      !identical(manifest[identity_fields], registry[identity_fields])) {
    stop("Confirmation manifest does not match the frozen registry.",
         call. = FALSE)
  }
  allowed_status <- c(
    "not_run", "completed", "generation_failure", "facets_failure",
    "parse_failure", "convergence_failure", "mfrmr_failure",
    "coordinate_failure"
  )
  logical_fields <- c(
    "ResultOpened", "FACETSConvergenceSpecificationPassed",
    "FACETSConvergenceAchieved", "MfrmrFitReturned",
    "MfrmrEstimationConverged", "ElementCoordinateContractPassed",
    "StepCoordinateContractPassed", "ComparisonEligible"
  )
  numeric_fields <- c(
    "FACETSReturnCode", "FACETSFinalIteration",
    "FACETSReportedConvergenceScoreResidual",
    "FACETSReportedConvergenceLogitChange",
    "FACETSFinalElementScoreResidual", "FACETSFinalElementLogitChange",
    "MfrmrConvergenceCode", "MfrmrTerminalGradientSupNorm",
    "MfrmrGradientReviewTolerance"
  )
  logical_values <- unlist(manifest[logical_fields], use.names = FALSE)
  valid_status <- is.character(manifest$ExecutionStatus) &&
    !anyNA(manifest$ExecutionStatus) &&
    all(manifest$ExecutionStatus %in% allowed_status)
  valid_logical <- is.logical(logical_values) && !anyNA(logical_values)
  valid_numeric <- all(vapply(
    manifest[numeric_fields], is.numeric, logical(1)
  ))
  valid_text <- is.character(manifest$Warnings) &&
    !anyNA(manifest$Warnings) && is.character(manifest$Error)
  if (!all(c(valid_status, valid_logical, valid_numeric, valid_text))) {
    stop("Confirmation manifest contains invalid status fields.",
         call. = FALSE)
  }
  integer_fields <- c(
    "FACETSReturnCode", "FACETSFinalIteration", "MfrmrConvergenceCode"
  )
  integer_values <- unlist(manifest[integer_fields], use.names = FALSE)
  invalid_integer <- !is.na(integer_values) &
    (!is.finite(integer_values) | integer_values != floor(integer_values))
  if (any(invalid_integer)) {
    stop("Confirmation manifest contains invalid status fields.",
         call. = FALSE)
  }
  not_run <- manifest$ExecutionStatus == "not_run"
  failed <- !not_run & manifest$ExecutionStatus != "completed"
  if (!identical(manifest$ResultOpened, !not_run) ||
      any(!is.na(manifest$Error[not_run])) ||
      any(!is.na(manifest$Error[manifest$ExecutionStatus == "completed"])) ||
      any(is.na(manifest$Error[failed])) ||
      any(!nzchar(manifest$Error[failed]))) {
    stop("Confirmation manifest result/error accounting is inconsistent.",
         call. = FALSE)
  }
  gates <- mfrmr_facets_mfr_numerical_gates(manifest, registry)
  if (!identical(
        manifest$FACETSConvergenceSpecificationPassed,
        gates$facets_specification
      ) ||
      !identical(manifest$FACETSConvergenceAchieved,
                 gates$facets_achieved) ||
      !identical(manifest$MfrmrEstimationConverged,
                 gates$mfrmr_converged)) {
    stop("Supplied convergence flags do not match the recomputed gates.",
         call. = FALSE)
  }
  derived <- mfrmr_facets_mfr_eligibility(manifest, registry)
  if (!identical(manifest$ComparisonEligible, derived)) {
    stop("ComparisonEligible does not match the recomputed numerical gates.",
         call. = FALSE)
  }
  if (!identical(manifest$ExecutionStatus == "completed", derived)) {
    stop("Completed status does not match the recomputed numerical gates.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfr_coordinate_key <- function(x, kind = c("element", "step")) {
  kind <- match.arg(kind)
  coordinate_fields <- if (identical(kind, "element")) {
    c("Facet", "Level")
  } else {
    c("StepFacet", "Step")
  }
  fields <- c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets",
    coordinate_fields
  )
  do.call(paste, c(x[fields], sep = "::"))
}

mfrmr_facets_mfr_validate_coordinates <- function(
    coordinates, expected, eligible_ids, kind = c("element", "step")) {
  kind <- match.arg(kind)
  if (!is.data.frame(coordinates)) {
    stop("Confirmation ", kind, " coordinates must be a data frame.",
         call. = FALSE)
  }
  coordinate_fields <- if (identical(kind, "element")) {
    c("Facet", "Level")
  } else {
    c("StepFacet", "Step")
  }
  required <- c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets",
    coordinate_fields, "MfrmrEstimate", "FACETSEstimate", "Difference",
    "AbsoluteDifference"
  )
  missing <- setdiff(required, names(coordinates))
  if (length(missing)) {
    stop("Confirmation ", kind, " coordinates are missing: ",
         paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  expected <- expected[expected$ScenarioId %in% eligible_ids, , drop = FALSE]
  expected_key <- mfrmr_facets_mfr_coordinate_key(expected, kind)
  observed_key <- mfrmr_facets_mfr_coordinate_key(coordinates, kind)
  if (anyDuplicated(observed_key) ||
      !identical(sort(observed_key), sort(expected_key))) {
    stop("Confirmation ", kind,
         " coordinate identities do not match eligible cases.", call. = FALSE)
  }
  numeric_fields <- c(
    "MfrmrEstimate", "FACETSEstimate", "Difference", "AbsoluteDifference"
  )
  if (any(!vapply(coordinates[numeric_fields], is.numeric, logical(1)))) {
    stop("Confirmation ", kind, " coordinate values must be numeric.",
         call. = FALSE)
  }
  numeric_values <- coordinates[numeric_fields]
  if (any(vapply(numeric_values, function(x) any(!is.finite(x)), logical(1)))) {
    stop("Confirmation ", kind, " coordinates must be finite.", call. = FALSE)
  }
  calculated_difference <- numeric_values$MfrmrEstimate -
    numeric_values$FACETSEstimate
  calculated_absolute <- abs(calculated_difference)
  difference_allowance <- 8 * .Machine$double.eps * pmax(
    1, abs(numeric_values$MfrmrEstimate), abs(numeric_values$FACETSEstimate),
    abs(calculated_difference), abs(numeric_values$Difference)
  )
  absolute_allowance <- 8 * .Machine$double.eps * pmax(
    1, abs(numeric_values$MfrmrEstimate), abs(numeric_values$FACETSEstimate),
    calculated_absolute, abs(numeric_values$AbsoluteDifference)
  )
  if (any(abs(numeric_values$Difference - calculated_difference) >
          difference_allowance) ||
      any(abs(numeric_values$AbsoluteDifference - calculated_absolute) >
          absolute_allowance)) {
    stop("Confirmation ", kind,
         " coordinate arithmetic is inconsistent.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfr_continuous_summary <- function(x) {
  n <- length(x)
  if (!n) {
    return(c(Mean = NA_real_, MCSE = NA_real_, Lower = NA_real_,
             Upper = NA_real_))
  }
  mean_x <- mean(x)
  if (n < 2L) {
    return(c(Mean = mean_x, MCSE = NA_real_, Lower = NA_real_,
             Upper = NA_real_))
  }
  mcse <- stats::sd(x) / sqrt(n)
  half_width <- stats::qt(0.975, df = n - 1L) * mcse
  c(Mean = mean_x, MCSE = mcse, Lower = mean_x - half_width,
    Upper = mean_x + half_width)
}

mfrmr_facets_mfr_wilson <- function(successes, n) {
  if (n <= 0L) return(c(Proportion = NA_real_, Lower = NA_real_,
                         Upper = NA_real_, MCSE = NA_real_))
  z <- stats::qnorm(0.975)
  p <- successes / n
  denominator <- 1 + z^2 / n
  center <- (p + z^2 / (2 * n)) / denominator
  half_width <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) /
    denominator
  c(Proportion = p, Lower = center - half_width, Upper = center + half_width,
    MCSE = sqrt(p * (1 - p) / n))
}

mfrmr_facets_mfr_review <- function(manifest, element_coordinates,
                                     step_coordinates) {
  mfrmr_facets_mfr_require_support()
  design <- mfrmr_facets_mfc_design()
  mfrmr_facets_mfc_validate(design$registry, design$mcse)
  mfrmr_facets_mfa_contract(design)
  registry <- design$registry
  mcse_targets <- stats::setNames(
    design$mcse$MCSETarget, design$mcse$Endpoint
  )
  mfrmr_facets_mfr_validate_manifest(manifest, registry)
  eligible_ids <- manifest$ScenarioId[manifest$ComparisonEligible]
  expected_elements <- mfrmr_facets_mfr_expected_elements(registry)
  expected_steps <- mfrmr_facets_mfr_expected_steps(registry)
  mfrmr_facets_mfr_validate_coordinates(
    element_coordinates, expected_elements, eligible_ids, "element"
  )
  mfrmr_facets_mfr_validate_coordinates(
    step_coordinates, expected_steps, eligible_ids, "step"
  )

  element_rule_input <- data.frame(
    Model = element_coordinates$Model,
    TotalFacets = element_coordinates$TotalFacets,
    ParameterClass = "Element",
    AbsoluteDifference = element_coordinates$AbsoluteDifference,
    ComparisonScale = pmax(
      abs(element_coordinates$MfrmrEstimate),
      abs(element_coordinates$FACETSEstimate)
    ),
    stringsAsFactors = FALSE
  )
  step_rule_input <- data.frame(
    Model = step_coordinates$Model,
    TotalFacets = step_coordinates$TotalFacets,
    ParameterClass = "Step",
    AbsoluteDifference = step_coordinates$AbsoluteDifference,
    ComparisonScale = pmax(
      abs(step_coordinates$MfrmrEstimate),
      abs(step_coordinates$FACETSEstimate)
    ),
    stringsAsFactors = FALSE
  )
  element_adjudication <- mfrmr_facets_mfa_adjudicate_coordinates(
    element_rule_input
  )
  step_adjudication <- mfrmr_facets_mfa_adjudicate_coordinates(step_rule_input)
  element_coordinates$NumericalAgreementStatus <-
    element_adjudication$NumericalAgreementStatus
  element_coordinates$AbsoluteDifferenceTolerance <-
    element_adjudication$AbsoluteDifferenceTolerance
  element_coordinates$FloatingPointComparisonAllowance <-
    element_adjudication$FloatingPointComparisonAllowance
  step_coordinates$NumericalAgreementStatus <-
    step_adjudication$NumericalAgreementStatus
  step_coordinates$AbsoluteDifferenceTolerance <-
    step_adjudication$AbsoluteDifferenceTolerance
  step_coordinates$FloatingPointComparisonAllowance <-
    step_adjudication$FloatingPointComparisonAllowance

  case_summary <- manifest[, c(
    "ScenarioId", "BaseSeed", "DesignSeed", "Model", "TotalFacets",
    "ExecutionStatus", "FACETSConvergenceAchieved", "ComparisonEligible"
  )]
  case_maximum <- function(coordinates) {
    if (!nrow(coordinates)) return(numeric(0))
    tapply(coordinates$AbsoluteDifference, coordinates$ScenarioId, max)
  }
  element_maximum <- case_maximum(element_coordinates)
  step_maximum <- case_maximum(step_coordinates)
  case_pass <- function(coordinates) {
    if (!nrow(coordinates)) return(logical(0))
    tapply(
      coordinates$NumericalAgreementStatus == "numeric_pass",
      coordinates$ScenarioId,
      all
    )
  }
  element_pass <- case_pass(element_coordinates)
  step_pass <- case_pass(step_coordinates)
  case_summary$ElementMaximumAbsoluteDifference <-
    unname(element_maximum[case_summary$ScenarioId])
  case_summary$StepMaximumAbsoluteDifference <-
    unname(step_maximum[case_summary$ScenarioId])
  case_summary$ElementNumericalPass <- ifelse(
    case_summary$ComparisonEligible,
    unname(element_pass[case_summary$ScenarioId]), FALSE
  )
  case_summary$StepNumericalPass <- ifelse(
    case_summary$ComparisonEligible,
    unname(step_pass[case_summary$ScenarioId]), FALSE
  )

  cell_rows <- list()
  index <- 0L
  for (model in c("RSM", "PCM")) {
    for (total in 3:5) {
      index <- index + 1L
      rows <- case_summary$Model == model & case_summary$TotalFacets == total
      cell <- case_summary[rows, , drop = FALSE]
      eligible <- cell$ComparisonEligible
      element_summary <- mfrmr_facets_mfr_continuous_summary(
        cell$ElementMaximumAbsoluteDifference[eligible]
      )
      step_summary <- mfrmr_facets_mfr_continuous_summary(
        cell$StepMaximumAbsoluteDifference[eligible]
      )
      convergence <- mfrmr_facets_mfr_wilson(
        sum(cell$FACETSConvergenceAchieved), nrow(cell)
      )
      eligibility <- mfrmr_facets_mfr_wilson(sum(eligible), nrow(cell))
      cell_rows[[index]] <- data.frame(
        Model = model,
        TotalFacets = total,
        PlannedCases = nrow(cell),
        EligibleCases = sum(eligible),
        FACETSConvergenceRate = convergence["Proportion"],
        FACETSConvergenceMCSE = convergence["MCSE"],
        FACETSConvergenceWilsonLower = convergence["Lower"],
        FACETSConvergenceWilsonUpper = convergence["Upper"],
        ComparisonEligibilityRate = eligibility["Proportion"],
        ComparisonEligibilityMCSE = eligibility["MCSE"],
        ComparisonEligibilityWilsonLower = eligibility["Lower"],
        ComparisonEligibilityWilsonUpper = eligibility["Upper"],
        ElementCaseMaximumMean = element_summary["Mean"],
        ElementCaseMaximumMCSE = element_summary["MCSE"],
        ElementCaseMaximumTLower = element_summary["Lower"],
        ElementCaseMaximumTUpper = element_summary["Upper"],
        StepCaseMaximumMean = step_summary["Mean"],
        StepCaseMaximumMCSE = step_summary["MCSE"],
        StepCaseMaximumTLower = step_summary["Lower"],
        StepCaseMaximumTUpper = step_summary["Upper"],
        ElementMCSETargetMet = is.finite(element_summary["MCSE"]) &&
          element_summary["MCSE"] <= mcse_targets[
            "element_case_maximum_absolute_difference"
          ],
        StepMCSETargetMet = is.finite(step_summary["MCSE"]) &&
          step_summary["MCSE"] <= mcse_targets[
            "step_case_maximum_absolute_difference"
          ],
        ConvergenceMCSETargetMet = convergence["MCSE"] <= mcse_targets[
          "facets_convergence_rate"
        ],
        EligibilityMCSETargetMet = eligibility["MCSE"] <= mcse_targets[
          "comparison_eligibility_rate"
        ],
        AllEligibleCoordinatesPassed = all(
          cell$ElementNumericalPass[eligible] & cell$StepNumericalPass[eligible]
        ) && any(eligible),
        stringsAsFactors = FALSE
      )
    }
  }
  cell_summary <- do.call(rbind, cell_rows)
  row.names(cell_summary) <- NULL
  decision <- data.frame(
    ContractVersion = mfrmr_facets_mfr_contract_version,
    Status = if (all(manifest$ExecutionStatus == "not_run")) {
      "dry_run_no_confirmation_outcome_opened"
    } else {
      "caller_supplied_evidence_reviewed_without_external_provenance"
    },
    ExpectedCases = nrow(registry),
    EligibleCases = sum(manifest$ComparisonEligible),
    ExpectedElementCoordinates = nrow(expected_elements),
    ReviewedElementCoordinates = nrow(element_coordinates),
    ExpectedStepCoordinates = nrow(expected_steps),
    ReviewedStepCoordinates = nrow(step_coordinates),
    AllCasesExecuted = all(manifest$ExecutionStatus != "not_run"),
    AllCasesEligible = all(manifest$ComparisonEligible),
    AllCoordinatesWithinTolerance =
      nrow(element_coordinates) > 0L && nrow(step_coordinates) > 0L &&
      all(element_coordinates$NumericalAgreementStatus == "numeric_pass") &&
      all(step_coordinates$NumericalAgreementStatus == "numeric_pass"),
    AllMCSERulesMet = all(
      cell_summary$ElementMCSETargetMet & cell_summary$StepMCSETargetMet &
        cell_summary$ConvergenceMCSETargetMet &
        cell_summary$EligibilityMCSETargetMet
    ),
    CompleteFixedCoreNumericalContractPassed = FALSE,
    ExternalProvenanceValidated = FALSE,
    ConfirmationClaimAuthorized = FALSE,
    ExactEqualityClaimAuthorized = FALSE,
    FACETSReplacementClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  decision$CompleteFixedCoreNumericalContractPassed <-
    decision$AllCasesExecuted && decision$AllCasesEligible &&
    decision$ReviewedElementCoordinates == decision$ExpectedElementCoordinates &&
    decision$ReviewedStepCoordinates == decision$ExpectedStepCoordinates &&
    decision$AllCoordinatesWithinTolerance && decision$AllMCSERulesMet
  list(
    manifest = manifest,
    element_coordinates = element_coordinates,
    step_coordinates = step_coordinates,
    cases = case_summary,
    cells = cell_summary,
    decision = decision
  )
}

mfrmr_facets_mfr_preflight <- function() {
  mfrmr_facets_mfr_require_support()
  design <- mfrmr_facets_mfc_design()
  mfrmr_facets_mfc_validate(design$registry, design$mcse)
  mfrmr_facets_mfa_contract(design)
  registry <- design$registry
  expected_elements <- mfrmr_facets_mfr_expected_elements(registry)
  expected_steps <- mfrmr_facets_mfr_expected_steps(registry)
  out <- list(
    contract_version = mfrmr_facets_mfr_contract_version,
    manifest = mfrmr_facets_mfr_empty_manifest(registry),
    expected_elements = expected_elements,
    expected_steps = expected_steps,
    decision = data.frame(
      Status = "semantic_runner_ready_execution_not_authorized",
      ExpectedCases = nrow(registry),
      ExpectedElementCoordinates = nrow(expected_elements),
      ExpectedStepCoordinates = nrow(expected_steps),
      ConfirmationOutcomeOpened = FALSE,
      ResponseGenerationImplemented = FALSE,
      ExternalExecutionImplemented = FALSE,
      FileHashRequired = FALSE,
      ExecutionAuthorized = FALSE,
      ConfirmationClaimAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  )
  class(out) <- c("mfrmr_facets_mfr_preflight", "list")
  out
}

print.mfrmr_facets_mfr_preflight <- function(x, ...) {
  cat("FACETS multifacet confirmation semantic runner\n")
  cat("Status:", x$decision$Status, "\n")
  cat("Expected cases:", x$decision$ExpectedCases, "\n")
  cat("Expected coordinates: element", x$decision$ExpectedElementCoordinates,
      "; step", x$decision$ExpectedStepCoordinates, "\n")
  cat("Confirmation outcome opened: no\n")
  cat("Execution authorized: no\n")
  invisible(x)
}
