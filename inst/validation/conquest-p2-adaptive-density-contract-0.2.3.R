# Repository-only bounded adaptive-density contract for a future ConQuest P2
# candidate.
#
# The ladder and stop rule are finite and prospective. The first dense pair
# that passes for every arm in a slice is selected; failure through q=241 stops
# the slice. Candidate 003 remains closed. This file fits and launches nothing.

mfrmr_cq_p2ad_specification <-
  "0.2.3-conquest-p2-bounded-adaptive-density-contract-v1"
mfrmr_cq_p2ad_contract <-
  "mfrmr_conquest_p2_bounded_adaptive_density_contract_v1"
mfrmr_cq_p2ad_maximum_nodes <- 241L

mfrmr_cq_p2ad_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2ad_require_contract <- function() {
  target <- environment(mfrmr_cq_p2ad_require_contract)
  required <- c(
    "mfrmr_cq_p2_fixture_registry", "mfrmr_cq_p2_observed_data",
    "mfrmr_cq_p2_probability", "mfrmr_cq_p2_continuous_loglikelihood",
    "mfrmr_cq_p2si_budget"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_p2si_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2si_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_successor_integration_contract_v1"
  )
  mfrmr_cq_p2ad_assert(
    all(available) && identity,
    "Source the exact failed fixed-q121 successor contract first."
  )
  invisible(TRUE)
}

mfrmr_cq_p2ad_snapshot_registry <- function() {
  data.frame(
    Nodes = c(31L, 61L, 121L, 241L),
    Role = c(
      "standard_start_required_diagnostic",
      "dense_pair_1_lower_and_diagnostic_upper",
      "dense_pair_1_upper_and_dense_pair_2_lower",
      "dense_pair_2_upper_hard_ceiling"
    ),
    MustRetain = TRUE,
    Candidate003CanBeReclassified = FALSE,
    ExternalExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2ad_stage_registry <- function() {
  data.frame(
    Stage = c("diagnostic", "dense_pair_1", "dense_pair_2"),
    LowerNodes = c(31L, 61L, 121L),
    UpperNodes = c(61L, 121L, 241L),
    SelectionOrder = c(NA_integer_, 1L, 2L),
    Governing = c(FALSE, TRUE, TRUE),
    CoordinateTolerance = c(
      NA_real_, rep(mfrmr_cq_p2si_budget("P2S-FINAL-Q-COORDINATE"), 2L)
    ),
    DevianceTolerance = c(
      NA_real_, rep(mfrmr_cq_p2si_budget("P2S-FINAL-Q-DEVIANCE"), 2L)
    ),
    UpperContinuousDevianceTolerance = c(
      NA_real_,
      rep(mfrmr_cq_p2si_budget("P2S-Q121-CONTINUOUS-DEVIANCE"), 2L)
    ),
    RequiresEverySliceArm = c(FALSE, TRUE, TRUE),
    Candidate003CanBeReclassified = FALSE,
    ThresholdChangeAuthorized = FALSE,
    ExternalExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2ad_select_stage <- function(metrics, expected_arm_ids) {
  metrics <- as.data.frame(metrics, stringsAsFactors = FALSE)
  expected_arm_ids <- as.character(expected_arm_ids)
  required <- c(
    "ArmId", "LowerNodes", "UpperNodes", "CoordinateMovement",
    "DevianceMovement", "UpperContinuousDevianceMovement", "Finite"
  )
  mfrmr_cq_p2ad_assert(
    length(expected_arm_ids) > 0L && !anyDuplicated(expected_arm_ids) &&
      all(required %in% names(metrics)),
    "Adaptive-density metrics or expected arm IDs are incomplete."
  )
  stage <- mfrmr_cq_p2ad_stage_registry()
  governing <- stage[stage$Governing, , drop = FALSE]
  review_rows <- lapply(seq_len(nrow(governing)), function(index) {
    candidate <- governing[index, , drop = FALSE]
    rows <- metrics[
      metrics$LowerNodes == candidate$LowerNodes &
        metrics$UpperNodes == candidate$UpperNodes,
      , drop = FALSE
    ]
    complete <- nrow(rows) == length(expected_arm_ids) &&
      !anyDuplicated(rows$ArmId) && setequal(rows$ArmId, expected_arm_ids)
    passed <- complete && all(rows$Finite) &&
      all(is.finite(rows$CoordinateMovement)) &&
      all(is.finite(rows$DevianceMovement)) &&
      all(is.finite(rows$UpperContinuousDevianceMovement)) &&
      all(abs(rows$CoordinateMovement) <= candidate$CoordinateTolerance) &&
      all(abs(rows$DevianceMovement) <= candidate$DevianceTolerance) &&
      all(abs(rows$UpperContinuousDevianceMovement) <=
            candidate$UpperContinuousDevianceTolerance)
    data.frame(
      Stage = candidate$Stage,
      LowerNodes = candidate$LowerNodes,
      UpperNodes = candidate$UpperNodes,
      ExpectedArms = length(expected_arm_ids),
      ObservedArms = nrow(rows),
      CompleteDenominator = complete,
      Passed = passed,
      SelectionOrder = candidate$SelectionOrder,
      stringsAsFactors = FALSE
    )
  })
  review <- do.call(rbind, review_rows)
  passing <- review[review$Passed, , drop = FALSE]
  selected <- if (nrow(passing)) {
    passing[which.min(passing$SelectionOrder), , drop = FALSE]
  } else {
    review[0L, , drop = FALSE]
  }
  list(
    status = if (nrow(selected) == 1L) {
      "lowest_complete_passing_dense_pair_selected"
    } else {
      "no_predeclared_dense_pair_passed_stop_at_q241"
    },
    stage_review = review,
    selected_stage = if (nrow(selected)) selected$Stage else NA_character_,
    selected_lower_nodes = if (nrow(selected)) {
      selected$LowerNodes
    } else {
      NA_integer_
    },
    selected_upper_nodes = if (nrow(selected)) {
      selected$UpperNodes
    } else {
      NA_integer_
    },
    maximum_nodes = mfrmr_cq_p2ad_maximum_nodes,
    further_expansion_authorized = FALSE,
    threshold_change_authorized = FALSE,
    candidate_003_reclassified = FALSE,
    external_execution_authorized = FALSE
  )
}

mfrmr_cq_p2ad_gh_normal <- function(nodes) {
  nodes <- as.integer(nodes)[1L]
  mfrmr_cq_p2ad_assert(
    nodes %in% c(31L, 61L, 121L, 241L),
    "The bounded adaptive oracle permits only q=31/61/121/241."
  )
  index <- seq_len(nodes - 1L)
  jacobi <- matrix(0, nrow = nodes, ncol = nodes)
  off_diagonal <- sqrt(index / 2)
  jacobi[cbind(index, index + 1L)] <- off_diagonal
  jacobi[cbind(index + 1L, index)] <- off_diagonal
  decomposition <- eigen(jacobi, symmetric = TRUE)
  list(
    nodes = sqrt(2) * decomposition$values,
    weights = decomposition$vectors[1L, ]^2
  )
}

mfrmr_cq_p2ad_fixed_loglikelihood <- function(fixture, nodes) {
  quadrature <- mfrmr_cq_p2ad_gh_normal(nodes)
  data <- mfrmr_cq_p2_observed_data(fixture)
  truth <- fixture$Truth
  by_person <- split(data, data$Person)
  log_likelihood <- vapply(by_person, function(person_data) {
    x <- unique(person_data$X)
    mfrmr_cq_p2ad_assert(
      length(x) == 1L, "Person covariate drifted within oracle rows."
    )
    theta <- truth$PopulationIntercept + truth$PopulationSlope * x +
      sqrt(truth$PopulationVariance) * quadrature$nodes
    log_pattern <- vapply(theta, function(value) {
      sum(vapply(seq_len(nrow(person_data)), function(index) {
        log(mfrmr_cq_p2_probability(
          fixture$Model, value, person_data$Rater[index],
          person_data$Criterion[index]
        )[person_data$Response[index] + 1L])
      }, numeric(1L)))
    }, numeric(1L))
    positive <- quadrature$weights > 0
    log_joint <- log_pattern[positive] + log(quadrature$weights[positive])
    maximum <- max(log_joint)
    maximum + log(sum(exp(log_joint - maximum)))
  }, numeric(1L))
  mfrmr_cq_p2ad_assert(
    all(is.finite(log_likelihood)) &&
      abs(sum(quadrature$weights) - 1) <= 1e-13,
    "The adaptive finite-GHQ truth oracle was nonfinite or unnormalized."
  )
  list(
    RegistryRowId = fixture$RegistryRowId,
    Model = fixture$Model,
    Nodes = nodes,
    Persons = length(log_likelihood),
    LogLikelihood = sum(log_likelihood),
    Deviance = -2 * sum(log_likelihood),
    QuadratureWeightSumDifference = abs(sum(quadrature$weights) - 1),
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2ad_truth_oracle_audit <- function(relative_tolerance = 1e-10) {
  mfrmr_cq_p2ad_require_contract()
  fixtures <- mfrmr_cq_p2_fixture_registry()
  rows <- lapply(fixtures, function(fixture) {
    finite <- lapply(c(31L, 61L, 121L, 241L), function(nodes) {
      mfrmr_cq_p2ad_fixed_loglikelihood(fixture, nodes)
    })
    names(finite) <- c("q31", "q61", "q121", "q241")
    continuous <- mfrmr_cq_p2_continuous_loglikelihood(
      fixture, relative_tolerance = relative_tolerance
    )
    continuous_deviance <- -2 * continuous$LogLikelihood
    data.frame(
      RegistryRowId = fixture$RegistryRowId,
      Model = fixture$Model,
      Persons = finite$q241$Persons,
      Q31Q61DevianceMovement = abs(
        finite$q61$Deviance - finite$q31$Deviance
      ),
      Q61Q121DevianceMovement = abs(
        finite$q121$Deviance - finite$q61$Deviance
      ),
      Q121ContinuousDevianceMovement = abs(
        finite$q121$Deviance - continuous_deviance
      ),
      Q121Q241DevianceMovement = abs(
        finite$q241$Deviance - finite$q121$Deviance
      ),
      Q241ContinuousDevianceMovement = abs(
        finite$q241$Deviance - continuous_deviance
      ),
      ContinuousIntegrationAbsoluteErrorEstimate =
        continuous$IntegrationAbsoluteErrorEstimate,
      Finite = all(is.finite(c(
        vapply(finite, `[[`, numeric(1L), "Deviance"),
        continuous_deviance
      ))),
      ExternalExecutionAuthorized = FALSE,
      ScientificEquivalenceInferred = FALSE,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_cq_p2ad_truth_stage_metrics <- function(audit) {
  stage_1 <- data.frame(
    ArmId = audit$RegistryRowId,
    LowerNodes = 61L,
    UpperNodes = 121L,
    CoordinateMovement = 0,
    DevianceMovement = audit$Q61Q121DevianceMovement,
    UpperContinuousDevianceMovement =
      audit$Q121ContinuousDevianceMovement,
    Finite = audit$Finite,
    CoordinateMetricRole = "fixed_truth_coordinates_not_refit",
    stringsAsFactors = FALSE
  )
  stage_2 <- data.frame(
    ArmId = audit$RegistryRowId,
    LowerNodes = 121L,
    UpperNodes = 241L,
    CoordinateMovement = 0,
    DevianceMovement = audit$Q121Q241DevianceMovement,
    UpperContinuousDevianceMovement =
      audit$Q241ContinuousDevianceMovement,
    Finite = audit$Finite,
    CoordinateMetricRole = "fixed_truth_coordinates_not_refit",
    stringsAsFactors = FALSE
  )
  rbind(stage_1, stage_2)
}

mfrmr_cq_p2ad_review <- function(run_truth_oracles = FALSE) {
  mfrmr_cq_p2ad_require_contract()
  snapshot <- mfrmr_cq_p2ad_snapshot_registry()
  stage <- mfrmr_cq_p2ad_stage_registry()
  contract_ready <- identical(snapshot$Nodes, c(31L, 61L, 121L, 241L)) &&
    nrow(stage) == 3L && !stage$Governing[1L] &&
    all(stage$Governing[2:3]) &&
    all(stage$CoordinateTolerance[2:3] == 2e-6) &&
    all(stage$DevianceTolerance[2:3] == 2e-6) &&
    all(stage$UpperContinuousDevianceTolerance[2:3] == 1e-7) &&
    !any(stage$ThresholdChangeAuthorized) &&
    max(snapshot$Nodes) == mfrmr_cq_p2ad_maximum_nodes
  audit <- if (isTRUE(run_truth_oracles)) {
    mfrmr_cq_p2ad_truth_oracle_audit()
  } else {
    data.frame()
  }
  selection <- if (nrow(audit)) {
    metrics <- mfrmr_cq_p2ad_truth_stage_metrics(audit)
    mfrmr_cq_p2ad_select_stage(metrics, audit$RegistryRowId)
  } else {
    NULL
  }
  oracle_ready <- isTRUE(run_truth_oracles) && nrow(audit) == 13L &&
    !is.null(selection) &&
    identical(selection$status, "lowest_complete_passing_dense_pair_selected")
  list(
    specification = mfrmr_cq_p2ad_specification,
    contract_version = mfrmr_cq_p2ad_contract,
    status = if (contract_ready && oracle_ready) {
      "bounded_adaptive_density_contract_and_truth_oracles_ready"
    } else if (contract_ready && !isTRUE(run_truth_oracles)) {
      "bounded_adaptive_density_contract_frozen_truth_oracles_unopened"
    } else {
      "bounded_adaptive_density_contract_or_truth_oracle_failed"
    },
    snapshots = snapshot,
    stages = stage,
    truth_oracle_audit = audit,
    truth_oracle_selection = selection,
    contract_ready = contract_ready,
    truth_oracles_run = isTRUE(run_truth_oracles),
    truth_oracle_ready = oracle_ready,
    candidate_003_reclassified = FALSE,
    candidate_004_generation_authorized = contract_ready && oracle_ready,
    candidate_004_fit_authorized = FALSE,
    further_node_expansion_authorized = FALSE,
    threshold_change_authorized = FALSE,
    external_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
