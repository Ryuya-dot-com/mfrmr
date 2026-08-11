gtheory_stationarity_acceptance_policy_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R",
      "gtheory-ademp-fit-prototype-0.2.3.R",
      "gtheory-weak-information-calibration-prototype-0.2.3.R",
      "gtheory-weak-information-pilot-prototype-0.2.3.R",
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
      "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-runner-0.2.3.R",
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
      "gtheory-weak-information-typed-replay-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-",
        "instrumentation-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-calibration-",
        "design-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-reference-",
        "calibration-0.2.3.R"
      ),
      paste0(
        "gtheory-weak-information-stationarity-calibration-",
        "authorization-audit-0.2.3.R"
      ),
      "gtheory-weak-information-glmmtmb-ml-reference-coverage-0.2.3.R",
      paste0(
        "gtheory-weak-information-lme4-objective-reference-",
        "preflight-0.2.3.R"
      ),
      "gtheory-weak-information-lme4-reference-coverage-0.2.3.R",
      paste0(
        "gtheory-weak-information-stationarity-acceptance-policy-",
        "0.2.3.R"
      )
    )
  )
}

load_gtheory_stationarity_acceptance_policy <- function() {
  paths <- gtheory_stationarity_acceptance_policy_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c(
    "digest", "lme4", "Matrix", "glmmTMB", "TMB", "minqa", "nloptr",
    "numDeriv"
  )) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gtheory_stationarity_acceptance_policy_objects <- function(env) {
  plan <- env$mfrmr_gtwp_plan()
  design <- env$mfrmr_gtwsz_contract(plan)
  design_manifest <- env$mfrmr_gtwsz_manifest(design, plan)
  reference <- env$mfrmr_gtwta_contract(design)
  reference_manifest <- env$mfrmr_gtwta_manifest(reference)
  authorization_audit <- env$mfrmr_gtwaa_contract(
    design, design_manifest, reference, reference_manifest
  )
  ml_coverage <- env$mfrmr_gtwab_contract(authorization_audit, reference)
  objective_preflight <- env$mfrmr_gtwac_contract(ml_coverage)
  lme4_coverage <- env$mfrmr_gtwad_contract(objective_preflight)
  acceptance <- env$mfrmr_gtwae_contract(lme4_coverage)
  list(
    Plan = plan, Design = design, AuthorizationAudit = authorization_audit,
    Lme4Coverage = lme4_coverage, Acceptance = acceptance
  )
}

gtheory_stationarity_acceptance_fixture <- function(env) {
  policy <- env$mfrmr_gtwae_policy()
  required <- policy$RequiredReferenceClasses
  base <- data.frame(
    ObservationId = sprintf("O%03d", seq_len(nrow(required))),
    ScenarioId = sprintf("S%03d", seq_len(nrow(required))),
    required,
    stringsAsFactors = FALSE
  )
  base$ReferenceState <- c(
    finite_accept = "finite_local_minimum",
    finite_reject = "finite_nonstationary",
    boundary = "boundary_limit"
  )[base$ReferenceClass]
  grid <- policy$CandidateGrid
  ledger <- merge(base, grid["CandidateId"], by = NULL, sort = FALSE)
  first <- grid$CandidateId[[1L]]
  second <- grid$CandidateId[[2L]]
  ledger$CandidateState <- "indeterminate"
  correct <- ledger$CandidateId == first
  ledger$CandidateState[correct & ledger$ReferenceClass == "finite_accept"] <-
    "numerically_eligible"
  ledger$CandidateState[correct & ledger$ReferenceClass == "finite_reject"] <-
    "numerically_ineligible"
  ledger$CandidateState[correct & ledger$ReferenceClass == "boundary"] <-
    "boundary_handoff"
  unsafe <- ledger$CandidateId == second
  ledger$CandidateState[unsafe & ledger$ReferenceClass == "finite_accept"] <-
    "numerically_eligible"
  ledger$CandidateState[unsafe & ledger$ReferenceClass == "finite_reject"] <-
    "numerically_eligible"
  ledger$CandidateState[unsafe & ledger$ReferenceClass == "boundary"] <-
    "boundary_handoff"
  ledger
}

test_that("b1g11 freezes 24 candidates and four reference receipts", {
  env <- load_gtheory_stationarity_acceptance_policy()
  policy <- env$mfrmr_gtwae_policy()
  grid <- policy$CandidateGrid
  receipts <- policy$ReferenceReceipts

  expect_identical(nrow(grid), 24L)
  expect_identical(length(unique(grid$RuleFamilyId)), 3L)
  expect_identical(length(unique(grid$ZoneId)), 8L)
  expect_identical(grid$RuleFamilyId[[1L]], "newton_decrement_zone")
  expect_equal(anyDuplicated(grid$CandidateId), 0L)
  expect_identical(nrow(receipts), 4L)
  expect_setequal(
    receipts$MethodId,
    c("glmmTMB_ml", "glmmTMB_reml", "lme4_ml", "lme4_reml")
  )
  expect_true(all(receipts$ReferenceMechanicsReady))
  expect_identical(policy$ReferenceMethodCoverageObserved, 4L)
  expect_true(policy$ReferenceMethodCoverageComplete)
  expect_true(policy$AcceptancePolicyFrozen)
  expect_true(policy$MonteCarloDecisionPolicyFrozen)
  expect_false(policy$CalibrationAuthorizationReady)
  expect_false(policy$CalibrationExecutionAuthorized)
  expect_false(policy$StationarityThresholdFrozen)
  expect_false(policy$StationarityCriterionReady)
  expect_false(policy$ProductionBoundaryProbeReady)
  expect_false(policy$RunnerImplementationReady)
})

test_that("retained b1g11 receipts validate all four reference lanes", {
  paths <- c(
    glmmTMB_reml = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_REFERENCE_REPLAY_RDS",
      "/private/tmp/mfrmr-gtwta-reference-replay-v4.rds"
    ),
    glmmTMB_ml = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_ML_REFERENCE_REPLAY_RDS",
      "/private/tmp/mfrmr-gtwab-ml-reference-replay-v1.rds"
    ),
    lme4 = Sys.getenv(
      "MFRMR_GTHEORY_LME4_REFERENCE_REPLAY_RDS",
      "/private/tmp/mfrmr-gtwad-lme4-reference-replay-v4.rds"
    )
  )
  skip_if_not(all(file.exists(paths)),
              "retained nonreserved reference receipts are unavailable")
  env <- load_gtheory_stationarity_acceptance_policy()
  receipts <- env$mfrmr_gtwae_reference_receipts()
  reml <- readRDS(paths[["glmmTMB_reml"]])
  ml <- readRDS(paths[["glmmTMB_ml"]])
  lme4 <- readRDS(paths[["lme4"]])

  expect_true(env$mfrmr_gtwta_execution_hash_valid(reml))
  expect_true(env$mfrmr_gtwab_execution_hash_valid(ml))
  expect_true(env$mfrmr_gtwad_execution_hash_valid(lme4))
  expect_identical(
    reml$ExecutionHash,
    receipts$ReferenceExecutionHash[receipts$MethodId == "glmmTMB_reml"]
  )
  expect_identical(
    ml$ExecutionHash,
    receipts$ReferenceExecutionHash[receipts$MethodId == "glmmTMB_ml"]
  )
  expect_identical(
    lme4$ExecutionHash,
    unique(receipts$ReferenceExecutionHash[
      receipts$MethodId %in% c("lme4_ml", "lme4_reml")
    ])
  )
  expect_true(lme4$ReferenceMethodCoverageComplete)
  expect_false(lme4$CalibrationAuthorizationReady)
  expect_false(lme4$CalibrationExecutionAuthorized)
})

test_that("b1g11 exact-binomial policy never calls zero events zero risk", {
  env <- load_gtheory_stationarity_acceptance_policy()

  expect_lt(abs(
    env$mfrmr_gtwae_binomial_upper(0L, 25L) - 0.1129281450068
  ), 1e-12)
  expect_lt(abs(
    env$mfrmr_gtwae_binomial_upper(0L, 100L) - 0.0295130496070
  ), 1e-12)
  expect_lt(abs(
    env$mfrmr_gtwae_binomial_upper(0L, 200L) - 0.0148670392313
  ), 1e-12)
  expect_true(is.na(env$mfrmr_gtwae_binomial_upper(0L, 0L)))
  expect_identical(
    env$mfrmr_gtwae_minimum_zero_event_trials(0.05), 59L
  )
  expect_error(env$mfrmr_gtwae_binomial_upper(2L, 1L), "Invalid")
  expect_error(env$mfrmr_gtwae_binomial_upper(0L, 1L, 1), "Invalid")
  expect_error(
    env$mfrmr_gtwae_minimum_zero_event_trials(0), "open-unit"
  )
})

test_that("b1g11 separates safety, boundary, abstention, and failure states", {
  env <- load_gtheory_stationarity_acceptance_policy()
  candidate <- c(
    "numerically_eligible", "numerically_eligible",
    "boundary_handoff", "numerically_ineligible", "indeterminate",
    "not_evaluable"
  )
  reference <- c(
    "finite_local_minimum", "finite_nonstationary",
    "finite_local_minimum", "finite_local_minimum", "boundary_limit",
    "reference_unresolved"
  )
  rows <- env$mfrmr_gtwae_pair_classification(candidate, reference)

  expect_identical(
    rows$ReferenceClass,
    c(
      "finite_accept", "finite_reject", "finite_accept", "finite_accept",
      "boundary", "unresolved"
    )
  )
  expect_identical(which(rows$SafetyFalseReady), 2L)
  expect_identical(which(rows$FalseBoundaryHandoff), 3L)
  expect_identical(which(rows$FalseUnready), 4L)
  expect_identical(which(rows$MissedBoundary), 5L)
  expect_identical(which(rows$CandidateIndeterminate), 5L)
  expect_false(rows$CandidateNotEvaluable[[6L]])
  expect_false(rows$ReferenceResolved[[6L]])
  expect_error(
    env$mfrmr_gtwae_pair_classification("resolved", "boundary_limit"),
    "registered"
  )
})

test_that("b1g11 preserves cell denominators and forbids truth columns", {
  env <- load_gtheory_stationarity_acceptance_policy()
  ledger <- gtheory_stationarity_acceptance_fixture(env)
  cells <- env$mfrmr_gtwae_cell_summary(ledger)
  policy <- env$mfrmr_gtwae_policy()

  expect_identical(
    nrow(cells),
    nrow(policy$CandidateGrid) * nrow(policy$RequiredReferenceClasses)
  )
  expect_true(all(cells$ObservationCount == 1L))
  expect_true(all(cells$ReferenceResolved == 1L))
  expect_true(all(cells$ReferenceUnresolved == 0L))
  expect_true(all(cells$FalseReadyTrials %in% c(0L, 1L)))
  expect_true(all(is.na(cells$FalseReadyExactUpper) |
                  cells$FalseReadyExactUpper > 0))

  truth <- ledger
  truth$TruthRegion <- "forbidden"
  expect_error(env$mfrmr_gtwae_cell_summary(truth), "truth-blind")
  expect_error(env$mfrmr_gtwae_cell_summary(ledger[-1L, ]), "24")
  changed <- ledger
  changed$ReferenceState[[2L]] <- "reference_unresolved"
  expect_error(env$mfrmr_gtwae_cell_summary(changed), "changed")
})

test_that("b1g11 rejects safety errors and all-abstention candidates", {
  env <- load_gtheory_stationarity_acceptance_policy()
  policy <- env$mfrmr_gtwae_policy()
  ledger <- gtheory_stationarity_acceptance_fixture(env)
  cells <- env$mfrmr_gtwae_cell_summary(ledger, policy)
  summaries <- env$mfrmr_gtwae_candidate_summary(ledger, cells, policy)
  selection <- env$mfrmr_gtwae_rank_candidate_summaries(summaries, policy)

  expect_identical(
    selection$SelectionState, policy$CandidateSelectedState
  )
  expect_identical(
    selection$SelectedCandidateId, policy$CandidateGrid$CandidateId[[1L]]
  )
  unsafe <- selection$RankedCandidates[
    selection$RankedCandidates$CandidateId ==
      policy$CandidateGrid$CandidateId[[2L]],
  ]
  abstain <- summaries[
    summaries$CandidateId == policy$CandidateGrid$CandidateId[[3L]],
  ]
  expect_gt(unsafe$SafetyFalseReady, 0L)
  expect_false(unsafe$SafetyAdmissible)
  expect_false(abstain$CorrectDecisiveCoverageComplete)
  expect_false(selection$StationarityThresholdFrozen)
  expect_false(selection$ConfirmationAuthorized)
  expect_false(selection$PostSelectionConfidenceCoverageClaimAllowed)

  negative <- summaries
  negative$SafetyFalseReady <- 1L
  failed <- env$mfrmr_gtwae_rank_candidate_summaries(negative, policy)
  expect_identical(failed$SelectionState, policy$NoAdmissibleCandidateState)
  expect_true(is.na(failed$SelectedCandidateId))
  expect_true(is.character(failed$BestDiagnosticCandidateId))
})

test_that("b1g11 analytic selection audit is fail closed", {
  env <- load_gtheory_stationarity_acceptance_policy()
  audit <- env$mfrmr_gtwae_selection_audit()

  expect_true(audit$SelectionAlgebraReady)
  expect_identical(
    audit$MinimumTrialsForZeroEventUpperAtMostFivePercent, 59L
  )
  expect_lt(abs(
    unname(audit$ZeroEventUpper[["N100"]]) - 0.0295130496070
  ), 1e-12)
  expect_true(is.character(audit$AuditHash))
  expect_identical(nchar(audit$AuditHash), 64L)
  expect_false(audit$PositiveSelection$ConfirmationAuthorized)
  expect_false(audit$PositiveSelection$StationarityThresholdFrozen)
  expect_true(is.na(audit$NegativeSelection$SelectedCandidateId))
})

test_that("b1g11 contract freezes policy but not calibration or criterion", {
  env <- load_gtheory_stationarity_acceptance_policy()
  objects <- gtheory_stationarity_acceptance_policy_objects(env)
  contract <- objects$Acceptance

  expect_true(contract$AcceptancePolicyFrozen)
  expect_true(contract$MonteCarloDecisionPolicyFrozen)
  expect_true(contract$ReferenceMethodCoverageComplete)
  expect_false(contract$ProductionBoundaryProbeReady)
  expect_false(contract$RunnerImplementationReady)
  expect_false(contract$CalibrationAuthorizationReady)
  expect_false(contract$CalibrationExecutionAuthorized)
  expect_false(contract$CalibrationDataGenerated)
  expect_false(contract$CalibrationResultsViewed)
  expect_false(contract$StationarityThresholdFrozen)
  expect_false(contract$StationarityCriterionReady)
  expect_false(contract$ConfirmationAuthorized)
  expect_false(contract$InferenceReady)
  expect_false(contract$CoefficientEligible)
  expect_false(contract$DecisionReady)
  expect_identical(nchar(contract$ContractHash), 64L)
  expect_identical(
    contract$UpstreamB1g10ContractHash,
    "419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0"
  )

  changed <- objects$Lme4Coverage
  changed$ContractHash <- paste(rep("0", 64L), collapse = "")
  expect_error(env$mfrmr_gtwae_contract(changed), "exact")
})

test_that("b1g11 sources are primary or official and claims remain narrow", {
  env <- load_gtheory_stationarity_acceptance_policy()
  policy <- env$mfrmr_gtwae_policy()
  sources <- policy$Sources

  expect_identical(nrow(sources), 4L)
  expect_true(any(grepl("10.1002/sim.8086", sources$Locator, fixed = TRUE)))
  expect_true(any(grepl("binom.test.html", sources$Locator, fixed = TRUE)))
  expect_true(any(grepl("convergence.html", sources$Locator, fixed = TRUE)))
  expect_true(any(grepl("isSingular.html", sources$Locator, fixed = TRUE)))
  expect_false(policy$ZeroEventPopulationRateClaimAllowed)
  expect_false(policy$PostSelectionConfidenceCoverageClaimAllowed)
  expect_false(policy$CandidateSelectionMayUseConfirmation)
  expect_false(policy$CandidateSelectionMayUseViewedSmoke)
  expect_false(policy$CandidateApplicationMayUseGeneratingTruth)
  expect_false(policy$RatePoolingAcrossPrimaryCellsAllowed)
  expect_false(policy$CandidateSelectionAutomaticallyAuthorizesConfirmation)
})
