# Repository-only, no-fit confirmation design for the fixed-information
# FACETS RSM/PCM JML comparison. The design fixes semantic identities and
# denominators without file hashes, generated responses, model fitting, or
# external execution.

mfrmr_facets_mfc_contract_version <-
  "mfrmr_facets_multifacet_confirmation_design_v1"

mfrmr_facets_mfc_confirmation_seeds <- function() {
  460001L + 100L * 0:29
}

mfrmr_facets_mfc_protected_seed_range <- function() {
  451000L:452999L
}

mfrmr_facets_mfc_registry <- function() {
  grid <- expand.grid(
    BaseSeed = mfrmr_facets_mfc_confirmation_seeds(),
    Model = c("RSM", "PCM"),
    TotalFacets = 3:5,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid <- grid[order(grid$BaseSeed, match(grid$Model, c("RSM", "PCM")),
                     grid$TotalFacets), , drop = FALSE]
  row.names(grid) <- NULL
  grid$ContractVersion <- mfrmr_facets_mfc_contract_version
  grid$ScenarioId <- paste0(
    "MFC-", grid$Model, "-F", grid$TotalFacets, "-B", grid$BaseSeed
  )
  grid$DesignSeed <- grid$BaseSeed + match(grid$Model, c("RSM", "PCM"))
  grid$Persons <- 40L
  grid$Rows <- 640L
  grid$Raters <- 4L
  grid$Criteria <- 4L
  grid$Tasks <- ifelse(grid$TotalFacets >= 4L, 3L, 0L)
  grid$Occasions <- ifelse(grid$TotalFacets >= 5L, 2L, 0L)
  grid$ExpectedElementCoordinates <- c(`3` = 48L, `4` = 51L, `5` = 53L)[
    as.character(grid$TotalFacets)
  ]
  grid$ExpectedStepCoordinates <- ifelse(grid$Model == "RSM", 3L, 12L)
  grid$FACETSVersion <- "4.5.0"
  grid$FACETSConvergenceScoreResidual <- 0.01
  grid$FACETSConvergenceLogitChange <- 0.0001
  grid$MfrmrMethod <- "JML"
  grid$NoEarlyStopping <- TRUE
  grid$FailedRunsRemainInDenominator <- TRUE
  grid$FailedReplicateReplacement <- FALSE
  grid$ResponseDataOpened <- FALSE
  grid$FitOpened <- FALSE
  grid$ResultOpened <- FALSE
  grid$ExecutionAuthorized <- FALSE
  grid$ConfirmationAuthorized <- FALSE
  grid$EquivalenceClaimAuthorized <- FALSE
  grid
}

mfrmr_facets_mfc_mcse_contract <- function() {
  data.frame(
    Endpoint = c(
      "element_case_maximum_absolute_difference",
      "step_case_maximum_absolute_difference",
      "facets_convergence_rate",
      "comparison_eligibility_rate"
    ),
    Estimand = c(
      rep("cell mean across fixed replicates", 2L),
      rep("cell proportion across all fixed replicates", 2L)
    ),
    MCSEFormula = c(
      rep("sample_sd/sqrt(n_eligible)", 2L),
      rep("sqrt(p_hat*(1-p_hat)/n_planned)", 2L)
    ),
    MCSETarget = c(0.0001, 0.0001, 0.06, 0.06),
    Interval = c(rep("t_95_for_mean", 2L), rep("wilson_95", 2L)),
    AdaptiveExtensionAllowed = FALSE,
    AcceptanceTolerance = NA_real_,
    AcceptanceRuleFrozen = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_mfc_validate <- function(
    registry = mfrmr_facets_mfc_registry(),
    mcse = mfrmr_facets_mfc_mcse_contract()) {
  required <- c(
    "BaseSeed", "Model", "TotalFacets", "ContractVersion", "ScenarioId",
    "DesignSeed", "Persons", "Rows", "Raters", "Criteria", "Tasks",
    "Occasions", "ExpectedElementCoordinates", "ExpectedStepCoordinates",
    "FACETSVersion", "FACETSConvergenceScoreResidual",
    "FACETSConvergenceLogitChange", "MfrmrMethod", "NoEarlyStopping",
    "FailedRunsRemainInDenominator", "FailedReplicateReplacement",
    "ResponseDataOpened", "FitOpened", "ResultOpened",
    "ExecutionAuthorized", "ConfirmationAuthorized",
    "EquivalenceClaimAuthorized"
  )
  missing <- setdiff(required, names(registry))
  if (length(missing)) {
    stop("Confirmation registry is missing: ", paste(missing, collapse = ", "),
         ".", call. = FALSE)
  }
  seeds <- mfrmr_facets_mfc_confirmation_seeds()
  expected_key <- do.call(paste, c(expand.grid(
    BaseSeed = seeds, Model = c("RSM", "PCM"), TotalFacets = 3:5,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  ), sep = "::"))
  observed_key <- paste(
    registry$BaseSeed, registry$Model, registry$TotalFacets, sep = "::"
  )
  expected_scenario_id <- paste0(
    "MFC-", registry$Model, "-F", registry$TotalFacets,
    "-B", registry$BaseSeed
  )
  expected_mcse_endpoints <- c(
    "element_case_maximum_absolute_difference",
    "step_case_maximum_absolute_difference",
    "facets_convergence_rate",
    "comparison_eligibility_rate"
  )
  checks <- c(
    nrow(registry) == 180L,
    !anyDuplicated(registry$ScenarioId),
    identical(registry$ScenarioId, expected_scenario_id),
    identical(sort(observed_key), sort(expected_key)),
    identical(sort(unique(registry$BaseSeed)), seeds),
    !any(registry$BaseSeed %in% mfrmr_facets_mfc_protected_seed_range()),
    !any(registry$DesignSeed %in% mfrmr_facets_mfc_protected_seed_range()),
    all(registry$DesignSeed ==
          registry$BaseSeed + match(registry$Model, c("RSM", "PCM"))),
    all(registry$ContractVersion == mfrmr_facets_mfc_contract_version),
    all(registry$Persons == 40L),
    all(registry$Rows == 640L),
    all(registry$Raters == 4L),
    all(registry$Criteria == 4L),
    all(registry$Tasks == ifelse(registry$TotalFacets >= 4L, 3L, 0L)),
    all(registry$Occasions == ifelse(registry$TotalFacets >= 5L, 2L, 0L)),
    all(registry$ExpectedElementCoordinates ==
          c(`3` = 48L, `4` = 51L, `5` = 53L)[
            as.character(registry$TotalFacets)
          ]),
    all(registry$ExpectedStepCoordinates ==
          ifelse(registry$Model == "RSM", 3L, 12L)),
    all(registry$FACETSVersion == "4.5.0"),
    all(registry$FACETSConvergenceScoreResidual == 0.01),
    all(registry$FACETSConvergenceLogitChange == 0.0001),
    all(registry$MfrmrMethod == "JML"),
    all(registry$NoEarlyStopping),
    all(registry$FailedRunsRemainInDenominator),
    all(!registry$FailedReplicateReplacement),
    all(!registry$ResponseDataOpened),
    all(!registry$FitOpened),
    all(!registry$ResultOpened),
    all(!registry$ExecutionAuthorized),
    all(!registry$ConfirmationAuthorized),
    all(!registry$EquivalenceClaimAuthorized),
    nrow(mcse) == 4L,
    identical(mcse$Endpoint, expected_mcse_endpoints),
    identical(
      mcse$MCSEFormula,
      c(rep("sample_sd/sqrt(n_eligible)", 2L),
        rep("sqrt(p_hat*(1-p_hat)/n_planned)", 2L))
    ),
    identical(mcse$MCSETarget, c(0.0001, 0.0001, 0.06, 0.06)),
    identical(mcse$Interval, c(rep("t_95_for_mean", 2L),
                               rep("wilson_95", 2L))),
    all(!mcse$AdaptiveExtensionAllowed),
    all(is.na(mcse$AcceptanceTolerance)),
    all(!mcse$AcceptanceRuleFrozen)
  )
  if (!all(checks)) {
    stop("FACETS multifacet confirmation design failed its semantic contract.",
         call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_facets_mfc_decision <- function() {
  registry <- mfrmr_facets_mfc_registry()
  mcse <- mfrmr_facets_mfc_mcse_contract()
  mfrmr_facets_mfc_validate(registry, mcse)
  data.frame(
    ContractVersion = mfrmr_facets_mfc_contract_version,
    Status = "design_frozen_execution_blocked_no_acceptance_rule",
    ReplicatesPerModelFacetCell = 30L,
    ExpectedCaseRows = nrow(registry),
    ExpectedElementCoordinateRows = sum(registry$ExpectedElementCoordinates),
    ExpectedStepCoordinateRows = sum(registry$ExpectedStepCoordinates),
    ExpectedFacetBlockRows = 30L * 2L * sum(3:5),
    ProtectedSeedOverlap = any(
      c(registry$BaseSeed, registry$DesignSeed) %in%
        mfrmr_facets_mfc_protected_seed_range()
    ),
    ScientificByteEqualityRequired = FALSE,
    FileHashRequired = FALSE,
    CandidateCommitMustBeRecordedAtExecution = TRUE,
    AcceptanceRuleFrozen = all(mcse$AcceptanceRuleFrozen),
    ExecutionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    EquivalenceClaimAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

print.mfrmr_facets_mfc_design <- function(x, ...) {
  cat("FACETS multifacet confirmation design\n")
  cat("Status:", x$decision$Status, "\n")
  cat("Planned cases:", x$decision$ExpectedCaseRows, "\n")
  cat("File hashes required: no\n")
  cat("Execution authorized: no\n")
  invisible(x)
}

mfrmr_facets_mfc_design <- function() {
  registry <- mfrmr_facets_mfc_registry()
  mcse <- mfrmr_facets_mfc_mcse_contract()
  mfrmr_facets_mfc_validate(registry, mcse)
  out <- list(
    contract_version = mfrmr_facets_mfc_contract_version,
    registry = registry,
    mcse = mcse,
    decision = mfrmr_facets_mfc_decision()
  )
  class(out) <- c("mfrmr_facets_mfc_design", "list")
  out
}
