# Repository-only, no-fit numerical agreement rule for the fixed-information
# FACETS RSM/PCM JML confirmation. This rule is frozen independently of the
# candidate-linked pilot maxima and before any confirmation outcome is opened.

mfrmr_facets_mfa_contract_version <-
  "mfrmr_facets_multifacet_acceptance_rule_v1"

mfrmr_facets_mfa_design_version <-
  "mfrmr_facets_multifacet_confirmation_design_v1"

mfrmr_facets_mfa_tolerance <- 0.005

mfrmr_facets_mfa_rule <- function() {
  grid <- expand.grid(
    Model = c("RSM", "PCM"),
    TotalFacets = 3:5,
    ParameterClass = c("Element", "Step"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid <- grid[
    order(match(grid$Model, c("RSM", "PCM")), grid$TotalFacets,
          match(grid$ParameterClass, c("Element", "Step"))),
    , drop = FALSE
  ]
  row.names(grid) <- NULL
  grid$ContractVersion <- mfrmr_facets_mfa_contract_version
  grid$ConfirmationDesignVersion <- mfrmr_facets_mfa_design_version
  grid$Unit <- "logit"
  grid$FACETSDocumentedPracticalIncrement <- 0.01
  grid$AbsoluteDifferenceTolerance <- mfrmr_facets_mfa_tolerance
  grid$ToleranceInclusive <- TRUE
  grid$CoordinatewisePassRequired <- TRUE
  grid$PilotOutcomeUsedToSetTolerance <- FALSE
  grid$ConfirmationOutcomeOpened <- FALSE
  grid$FileHashRequired <- FALSE
  grid$ByteEqualityRequired <- FALSE
  grid$Binary64EqualityRequired <- FALSE
  grid$DisplayedTokenEqualityRequired <- FALSE
  grid
}

mfrmr_facets_mfa_validate <- function(rule = mfrmr_facets_mfa_rule()) {
  required <- c(
    "Model", "TotalFacets", "ParameterClass", "ContractVersion",
    "ConfirmationDesignVersion", "Unit",
    "FACETSDocumentedPracticalIncrement", "AbsoluteDifferenceTolerance",
    "ToleranceInclusive", "CoordinatewisePassRequired",
    "PilotOutcomeUsedToSetTolerance", "ConfirmationOutcomeOpened",
    "FileHashRequired", "ByteEqualityRequired", "Binary64EqualityRequired",
    "DisplayedTokenEqualityRequired"
  )
  missing <- setdiff(required, names(rule))
  if (length(missing)) {
    stop("Acceptance rule is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  expected <- expand.grid(
    Model = c("RSM", "PCM"), TotalFacets = 3:5,
    ParameterClass = c("Element", "Step"),
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  expected_key <- paste(
    expected$Model, expected$TotalFacets, expected$ParameterClass, sep = "::"
  )
  observed_key <- paste(
    rule$Model, rule$TotalFacets, rule$ParameterClass, sep = "::"
  )
  checks <- c(
    nrow(rule) == 12L,
    !anyDuplicated(observed_key),
    identical(sort(observed_key), sort(expected_key)),
    all(rule$ContractVersion == mfrmr_facets_mfa_contract_version),
    all(rule$ConfirmationDesignVersion == mfrmr_facets_mfa_design_version),
    all(rule$Unit == "logit"),
    all(rule$FACETSDocumentedPracticalIncrement == 0.01),
    all(rule$AbsoluteDifferenceTolerance == mfrmr_facets_mfa_tolerance),
    all(rule$ToleranceInclusive),
    all(rule$CoordinatewisePassRequired),
    all(!rule$PilotOutcomeUsedToSetTolerance),
    all(!rule$ConfirmationOutcomeOpened),
    all(!rule$FileHashRequired),
    all(!rule$ByteEqualityRequired),
    all(!rule$Binary64EqualityRequired),
    all(!rule$DisplayedTokenEqualityRequired)
  )
  if (!isTRUE(all(checks))) {
    stop("FACETS multifacet acceptance rule failed its semantic contract.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfa_validate_design <- function(design) {
  incompatible <- "Confirmation design is incompatible with the acceptance rule."
  if (!is.list(design) ||
      !identical(design$contract_version, mfrmr_facets_mfa_design_version)) {
    stop(incompatible, call. = FALSE)
  }
  registry <- design$registry
  opened_fields <- c("ResponseDataOpened", "FitOpened", "ResultOpened")
  if (!is.data.frame(registry) || nrow(registry) != 180L ||
      !all(opened_fields %in% names(registry))) {
    stop(incompatible, call. = FALSE)
  }
  opened <- unlist(registry[opened_fields], use.names = FALSE)
  if (!is.logical(opened) || anyNA(opened) || any(opened)) {
    stop(incompatible, call. = FALSE)
  }
  decision <- design$decision
  blocked_fields <- c(
    "ExecutionAuthorized", "ConfirmationAuthorized",
    "EquivalenceClaimAuthorized"
  )
  if (!is.data.frame(decision) || nrow(decision) != 1L ||
      !all(blocked_fields %in% names(decision))) {
    stop(incompatible, call. = FALSE)
  }
  blocked <- unlist(decision[blocked_fields], use.names = FALSE)
  if (!is.logical(blocked) || anyNA(blocked) || any(blocked)) {
    stop(incompatible, call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfa_fp_allowance <- function(difference, tolerance,
                                           comparison_scale = 1) {
  8 * .Machine$double.eps * pmax(
    1, abs(difference), abs(tolerance), abs(comparison_scale)
  )
}

mfrmr_facets_mfa_adjudicate_coordinates <- function(
    coordinates, rule = mfrmr_facets_mfa_rule()) {
  mfrmr_facets_mfa_validate(rule)
  required <- c(
    "Model", "TotalFacets", "ParameterClass", "AbsoluteDifference"
  )
  missing <- setdiff(required, names(coordinates))
  if (length(missing)) {
    stop("Coordinate evidence is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  difference <- coordinates$AbsoluteDifference
  if (!is.numeric(difference) || any(!is.finite(difference)) ||
      any(difference < 0)) {
    stop("AbsoluteDifference must contain finite non-negative numbers.",
         call. = FALSE)
  }
  comparison_scale <- if ("ComparisonScale" %in% names(coordinates)) {
    coordinates$ComparisonScale
  } else {
    rep(1, length(difference))
  }
  if (!is.numeric(comparison_scale) || any(!is.finite(comparison_scale)) ||
      any(comparison_scale < 0)) {
    stop("ComparisonScale must contain finite non-negative numbers.",
         call. = FALSE)
  }
  rule_key <- paste(
    rule$Model, rule$TotalFacets, rule$ParameterClass, sep = "::"
  )
  coordinate_key <- paste(
    coordinates$Model, coordinates$TotalFacets,
    coordinates$ParameterClass, sep = "::"
  )
  matched <- match(coordinate_key, rule_key)
  if (anyNA(matched)) {
    stop("Coordinate evidence contains a model/facet/class outside the rule.",
         call. = FALSE)
  }
  tolerance <- rule$AbsoluteDifferenceTolerance[matched]
  allowance <- mfrmr_facets_mfa_fp_allowance(
    difference, tolerance, comparison_scale
  )
  out <- coordinates
  out$AbsoluteDifferenceTolerance <- tolerance
  out$FloatingPointComparisonAllowance <- allowance
  out$NumericalAgreementStatus <- ifelse(
    difference <= tolerance + allowance, "numeric_pass", "numeric_fail"
  )
  out
}

mfrmr_facets_mfa_decision <- function() {
  rule <- mfrmr_facets_mfa_rule()
  mfrmr_facets_mfa_validate(rule)
  data.frame(
    ContractVersion = mfrmr_facets_mfa_contract_version,
    ConfirmationDesignVersion = mfrmr_facets_mfa_design_version,
    Status = "acceptance_rule_frozen_confirmation_execution_still_blocked",
    ExpectedCases = 180L,
    AbsoluteDifferenceTolerance = mfrmr_facets_mfa_tolerance,
    Unit = "logit",
    RuleChosenFromPilotMaximum = FALSE,
    ConfirmationOutcomeOpened = FALSE,
    CoordinatewisePassRequired = TRUE,
    AllExpectedCasesEligibleForCompleteConfirmation = TRUE,
    MissingOrIneligibleCaseCanPassCompleteConfirmation = FALSE,
    MCSEIsNumericalAgreementTolerance = FALSE,
    FileHashRequired = FALSE,
    ByteEqualityRequired = FALSE,
    Binary64EqualityRequired = FALSE,
    ExactEqualityClaimAuthorized = FALSE,
    StatisticalEquivalenceClaimAuthorized = FALSE,
    FACETSReplacementClaimAuthorized = FALSE,
    ExecutionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

print.mfrmr_facets_mfa_contract <- function(x, ...) {
  cat("FACETS multifacet numerical agreement rule\n")
  cat("Status:", x$decision$Status, "\n")
  cat("Coordinate tolerance: 0.005 logits (inclusive)\n")
  cat("File or binary64 identity required: no\n")
  cat("Confirmation execution authorized: no\n")
  invisible(x)
}

mfrmr_facets_mfa_contract <- function(design = NULL) {
  rule <- mfrmr_facets_mfa_rule()
  mfrmr_facets_mfa_validate(rule)
  if (!is.null(design)) {
    mfrmr_facets_mfa_validate_design(design)
  }
  out <- list(
    contract_version = mfrmr_facets_mfa_contract_version,
    rule = rule,
    decision = mfrmr_facets_mfa_decision()
  )
  class(out) <- c("mfrmr_facets_mfa_contract", "list")
  out
}
