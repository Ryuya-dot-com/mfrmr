# Repository-only generation contract for ConQuest P2 candidate 004.
#
# One new identity and seed are frozen before generation. The candidate reuses
# candidate 003's probability-weighted full-cell-support conditioning and the
# same thirteen candidate-002 pre-fit gates. Disjoint lineage is checked
# separately from those scientific/design gates. This file fits and launches
# nothing.

mfrmr_cq_p2c4_specification <-
  "0.2.3-conquest-p2-candidate-004-coverage-conditioned-fixture-v1"
mfrmr_cq_p2c4_contract <-
  "mfrmr_conquest_p2_candidate_004_coverage_conditioned_fixture_v1"
mfrmr_cq_p2c4_seed <- 2026081504L
mfrmr_cq_p2c4_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004"
mfrmr_cq_p2c4_maximum_cell_draws <- 10000L

mfrmr_cq_p2c4_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c4_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c4_require_contracts)
  required <- c(
    "mfrmr_cq_p2_complete_grid", "mfrmr_cq_p2_assignment",
    "mfrmr_cq_p2_truth", "mfrmr_cq_p2_probability",
    "mfrmr_cq_p2r_with_seed", "mfrmr_cq_p2r_gate_registry",
    "mfrmr_cq_p2r_signal_audit", "mfrmr_cq_p2r_gate_results",
    "mfrmr_cq_p2c3_fixture", "mfrmr_cq_p2coo_review"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identities <- c(
    exists("mfrmr_cq_p2_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
      ),
    exists("mfrmr_cq_p2r_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2r_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_replacement_nondegenerate_fixture_v1"
      ),
    exists("mfrmr_cq_p2c3_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2c3_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_candidate_003_coverage_conditioned_fixture_v1"
      ),
    exists("mfrmr_cq_p2coo_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2coo_contract", envir = target, inherits = TRUE),
        paste0(
          "mfrmr_conquest_p2_log_centered_continuous_oracle_",
          "observation_v1"
        )
      )
  )
  mfrmr_cq_p2c4_assert(
    all(available) && all(identities),
    paste(
      "Source the exact P2, candidate-002/003, and qualified",
      "log-centered-oracle contracts before candidate 004."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_p2c4_generation_contract <- function() {
  data.frame(
    CandidateId = mfrmr_cq_p2c4_candidate_id,
    Seed = mfrmr_cq_p2c4_seed,
    MaximumCellDraws = mfrmr_cq_p2c4_maximum_cell_draws,
    GeneratingFamily = "PCM",
    Persons = 48L,
    ObservedRows = 288L,
    RaterCriterionCells = 12L,
    PersonsPerCell = 24L,
    Categories = "0;1;2;3",
    SamplingDesign =
      "independent_PCM_response_blocks_conditioned_on_full_cell_support",
    GateDenominator = 13L,
    GateRegistrySource = "candidate_002_unchanged",
    DisjointLineageGateSeparate = TRUE,
    SeedSearchPermitted = FALSE,
    PostGenerationResponseRepairPermitted = FALSE,
    Candidate003OutputTuned = FALSE,
    FitPermitted = FALSE,
    ExternalExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2c4_fixture <- function(
    seed = mfrmr_cq_p2c4_seed,
    maximum_cell_draws = mfrmr_cq_p2c4_maximum_cell_draws) {
  mfrmr_cq_p2c4_require_contracts()
  seed <- as.integer(seed)[1L]
  maximum_cell_draws <- as.integer(maximum_cell_draws)[1L]
  mfrmr_cq_p2c4_assert(
    identical(seed, mfrmr_cq_p2c4_seed),
    "Candidate 004 permits only its single frozen seed."
  )
  mfrmr_cq_p2c4_assert(
    identical(maximum_cell_draws, mfrmr_cq_p2c4_maximum_cell_draws),
    "Candidate 004 permits only its frozen cell-draw ceiling."
  )
  mfrmr_cq_p2r_with_seed(seed, {
    truth <- mfrmr_cq_p2_truth()
    grid <- mfrmr_cq_p2_complete_grid()
    observed <- mfrmr_cq_p2_assignment(
      "connected_sparse_multiple_independent_bridges", grid
    )
    data <- grid[observed, , drop = FALSE]
    rownames(data) <- NULL
    x <- ifelse(seq_len(48L) <= 24L, -1, 1)
    residual_half <- stats::rnorm(24L)
    residual <- c(residual_half, rev(residual_half))
    theta <- truth$PopulationIntercept + truth$PopulationSlope * x +
      sqrt(truth$PopulationVariance) * residual
    person <- data.frame(
      Person = sprintf("P%03d", seq_len(48L)),
      X = x,
      GeneratingTheta = theta,
      stringsAsFactors = FALSE
    )
    data$X <- person$X[match(data$Person, person$Person)]
    data$Response <- NA_integer_
    probability <- t(vapply(seq_len(nrow(data)), function(index) {
      mfrmr_cq_p2_probability(
        "PCM",
        theta[match(data$Person[index], person$Person)],
        data$Rater[index], data$Criterion[index]
      )
    }, numeric(4L)))
    cell_id <- paste(data$Rater, data$Criterion, sep = "::")
    cell_levels <- as.vector(outer(
      paste0("R", 1:4), paste0("C", 1:3), paste, sep = "::"
    ))
    cells <- split(
      seq_len(nrow(data)), factor(cell_id, levels = cell_levels)
    )
    draw_rows <- vector("list", length(cells))
    for (cell_index in seq_along(cells)) {
      index <- cells[[cell_index]]
      mfrmr_cq_p2c4_assert(
        length(index) == 24L,
        "Each coverage-conditioned cell must contain exactly 24 Persons."
      )
      attempts <- 0L
      repeat {
        attempts <- attempts + 1L
        response <- vapply(index, function(row) {
          sample.int(4L, size = 1L, prob = probability[row, ]) - 1L
        }, integer(1L))
        if (all(tabulate(response + 1L, nbins = 4L) > 0L)) break
        mfrmr_cq_p2c4_assert(
          attempts < maximum_cell_draws,
          paste0(
            "Coverage conditioning exceeded its frozen ceiling for `",
            names(cells)[cell_index], "`."
          )
        )
      }
      data$Response[index] <- response
      count <- tabulate(response + 1L, nbins = 4L)
      draw_rows[[cell_index]] <- data.frame(
        Cell = names(cells)[cell_index],
        Rater = data$Rater[index[1L]],
        Criterion = data$Criterion[index[1L]],
        Persons = length(index),
        DrawAttempts = attempts,
        RejectedCompleteBlocks = attempts - 1L,
        Category0 = count[1L],
        Category1 = count[2L],
        Category2 = count[3L],
        Category3 = count[4L],
        CoverageSatisfied = all(count > 0L),
        stringsAsFactors = FALSE
      )
    }
    conditioning <- do.call(rbind, draw_rows)
    rownames(conditioning) <- NULL
    mfrmr_cq_p2c4_assert(
      nrow(data) == 288L && !anyNA(data$Response) &&
        all(data$Response %in% 0:3) && nrow(conditioning) == 12L &&
        all(conditioning$CoverageSatisfied),
      "Candidate 004 did not satisfy its coverage-conditioned support."
    )
    list(
      Specification = mfrmr_cq_p2c4_specification,
      ContractVersion = mfrmr_cq_p2c4_contract,
      CandidateId = mfrmr_cq_p2c4_candidate_id,
      Seed = seed,
      MaximumCellDraws = maximum_cell_draws,
      GeneratingFamily = "PCM",
      SamplingDesign =
        "independent_PCM_response_blocks_conditioned_on_full_cell_support",
      Data = data,
      Person = person,
      Probability = probability,
      Conditioning = conditioning,
      Truth = truth,
      SharedAcrossCandidateFamilies = c("RSM", "PCM"),
      SeedSearchPerformed = FALSE,
      ResponseRepairPerformed = FALSE,
      PostGenerationCategoryEditing = FALSE,
      ProbabilityWeighted = TRUE,
      JointSamplingConditionedOnFullCellSupport = TRUE,
      TruthRecoveryAuthorized = FALSE,
      FitAuthorized = FALSE,
      ExternalExecutionAuthorized = FALSE,
      EvidencePromotionAuthorized = FALSE,
      ScientificEquivalenceInferred = FALSE
    )
  })
}

mfrmr_cq_p2c4_review <- function(run_generation = FALSE) {
  mfrmr_cq_p2c4_require_contracts()
  generation <- mfrmr_cq_p2c4_generation_contract()
  oracle <- mfrmr_cq_p2coo_review()
  gate_registry <- mfrmr_cq_p2r_gate_registry()
  gate_identity <- nrow(gate_registry) == 13L && identical(
    gate_registry$GateId,
    c(
      "EXACT_PERSON_COUNT", "EXACT_OBSERVED_ROW_COUNT",
      "CONNECTED_MULTIBRIDGE_GRAPH",
      "ALL_RATER_CRITERION_CATEGORIES_PRESENT",
      "PERSON_SCORE_UNIQUE_SUPPORT", "PERSON_SCORE_RANGE",
      "PERSON_SCORE_X_CORRELATION", "PERSON_SCORE_X_MEAN_SEPARATION",
      "RATER_SUFFICIENT_STATISTIC_NONCANCELLATION",
      "CRITERION_SUFFICIENT_STATISTIC_NONCANCELLATION",
      "FACET_CATEGORY_MARGINS_NOT_EXACTLY_BALANCED",
      "GENERATING_THETA_X_MEAN_SEPARATION", "GENERATING_THETA_VARIANCE"
    )
  ) && all(gate_registry$FrozenBeforeGenerationReview) &&
    !any(gate_registry$CanAuthorizeExternalExecution) &&
    !any(gate_registry$CanPromoteEvidence)
  lineage_identity_ready <-
    !identical(mfrmr_cq_p2c4_candidate_id, mfrmr_cq_p2c3_candidate_id) &&
    !identical(mfrmr_cq_p2c4_seed, mfrmr_cq_p2c3_seed)
  contract_ready <- isTRUE(
    oracle$candidate_004_generation_authorized
  ) && gate_identity && lineage_identity_ready &&
    nrow(generation) == 1L && generation$GateDenominator == 13L &&
    isTRUE(generation$DisjointLineageGateSeparate) &&
    !isTRUE(generation$SeedSearchPermitted) &&
    !isTRUE(generation$PostGenerationResponseRepairPermitted) &&
    !isTRUE(generation$Candidate003OutputTuned) &&
    !isTRUE(generation$FitPermitted)
  fixture <- if (isTRUE(run_generation)) mfrmr_cq_p2c4_fixture() else NULL
  predecessor <- if (isTRUE(run_generation)) mfrmr_cq_p2c3_fixture() else NULL
  signal <- if (isTRUE(run_generation)) {
    mfrmr_cq_p2r_signal_audit(fixture)
  } else {
    data.frame()
  }
  gates <- if (isTRUE(run_generation)) {
    mfrmr_cq_p2r_gate_results(fixture)
  } else {
    data.frame()
  }
  frozen_gate_identity <- isTRUE(run_generation) && identical(
    gates[, names(mfrmr_cq_p2r_gate_registry()), drop = FALSE],
    mfrmr_cq_p2r_gate_registry()
  )
  conditioning_ready <- isTRUE(run_generation) &&
    nrow(fixture$Conditioning) == 12L &&
    all(fixture$Conditioning$Persons == 24L) &&
    all(fixture$Conditioning$CoverageSatisfied) &&
    all(fixture$Conditioning$DrawAttempts >= 1L) &&
    all(fixture$Conditioning$DrawAttempts <= fixture$MaximumCellDraws) &&
    sum(fixture$Conditioning[, paste0("Category", 0:3)]) == 288L
  lineage_data_disjoint <- isTRUE(run_generation) &&
    !identical(fixture$Data, predecessor$Data) &&
    !identical(fixture$Person, predecessor$Person)
  provenance_ready <- isTRUE(run_generation) &&
    identical(fixture$Seed, mfrmr_cq_p2c4_seed) &&
    !isTRUE(fixture$SeedSearchPerformed) &&
    !isTRUE(fixture$ResponseRepairPerformed) &&
    !isTRUE(fixture$PostGenerationCategoryEditing) &&
    isTRUE(fixture$ProbabilityWeighted) &&
    isTRUE(fixture$JointSamplingConditionedOnFullCellSupport) &&
    !isTRUE(fixture$TruthRecoveryAuthorized)
  all_thirteen_passed <- isTRUE(run_generation) &&
    nrow(gates) == 13L && all(gates$Passed)
  ready <- contract_ready && isTRUE(run_generation) &&
    frozen_gate_identity && conditioning_ready && lineage_data_disjoint &&
    provenance_ready && all_thirteen_passed &&
    !isTRUE(signal$ExternalExecutionAuthorized)
  list(
    specification = mfrmr_cq_p2c4_specification,
    contract_version = mfrmr_cq_p2c4_contract,
    candidate_id = mfrmr_cq_p2c4_candidate_id,
    status = if (!contract_ready) {
      "candidate_004_generation_contract_invalid"
    } else if (!isTRUE(run_generation)) {
      "candidate_004_generation_contract_frozen_audit_unopened"
    } else if (ready) {
      "candidate_004_prefit_fixture_ready_mfrmr_preflight_contract_required"
    } else {
      "candidate_004_rejected_before_fit"
    },
    generation_contract = generation,
    fixture = fixture,
    signal_audit = signal,
    gate_results = gates,
    contract_ready = contract_ready,
    generation_audit_run = isTRUE(run_generation),
    frozen_candidate_002_gate_identity_retained = if (
      isTRUE(run_generation)
    ) frozen_gate_identity else gate_identity,
    oracle_qualification_retained = isTRUE(
      oracle$log_centered_continuous_oracle_qualified
    ),
    disjoint_identity_and_seed_frozen = lineage_identity_ready,
    disjoint_candidate_003_data = lineage_data_disjoint,
    coverage_conditioning_ready = conditioning_ready,
    provenance_ready = provenance_ready,
    all_thirteen_prefit_gates_passed = all_thirteen_passed,
    mfrmr_fit_preflight_contract_authorized = ready,
    mfrmr_fit_authorized = FALSE,
    truth_recovery_authorized = FALSE,
    candidate_003_reclassified = FALSE,
    external_execution_authorized = FALSE,
    fresh_runtime_and_minimum_audit_required = TRUE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
