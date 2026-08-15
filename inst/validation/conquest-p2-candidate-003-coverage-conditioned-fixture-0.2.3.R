# Repository-only coverage-conditioned fixture for ConQuest P2 candidate 003.
#
# The generator uses one frozen seed. Within each Rater-by-Criterion cell it
# samples complete response blocks from the frozen PCM probabilities until all
# four categories occur. This is an explicit conditional sampling design, not
# seed search or post-generation response repair. It reuses candidate 002's
# thirteen gates unchanged and fits or launches nothing.

mfrmr_cq_p2c3_specification <-
  "0.2.3-conquest-p2-candidate-003-coverage-conditioned-fixture-v1"
mfrmr_cq_p2c3_contract <-
  "mfrmr_conquest_p2_candidate_003_coverage_conditioned_fixture_v1"
mfrmr_cq_p2c3_seed <- 2026081503L
mfrmr_cq_p2c3_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003"
mfrmr_cq_p2c3_maximum_cell_draws <- 10000L

mfrmr_cq_p2c3_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2c3_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2c3_require_contracts)
  required <- c(
    "mfrmr_cq_p2_complete_grid", "mfrmr_cq_p2_assignment",
    "mfrmr_cq_p2_truth", "mfrmr_cq_p2_probability",
    "mfrmr_cq_p2r_with_seed", "mfrmr_cq_p2r_gate_registry",
    "mfrmr_cq_p2r_signal_audit", "mfrmr_cq_p2r_gate_results"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- c(
    exists("mfrmr_cq_p2_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
      ),
    exists("mfrmr_cq_p2r_contract", envir = target, inherits = TRUE) &&
      identical(
        get("mfrmr_cq_p2r_contract", envir = target, inherits = TRUE),
        "mfrmr_conquest_p2_replacement_nondegenerate_fixture_v1"
      )
  )
  mfrmr_cq_p2c3_assert(
    all(available) && all(identity),
    paste(
      "Source the exact P2 fixture and rejected candidate-002 gate",
      "contracts before candidate 003."
    )
  )
  invisible(TRUE)
}

mfrmr_cq_p2c3_fixture <- function(
    seed = mfrmr_cq_p2c3_seed,
    maximum_cell_draws = mfrmr_cq_p2c3_maximum_cell_draws) {
  mfrmr_cq_p2c3_require_contracts()
  seed <- as.integer(seed)[1L]
  maximum_cell_draws <- as.integer(maximum_cell_draws)[1L]
  mfrmr_cq_p2c3_assert(
    identical(seed, mfrmr_cq_p2c3_seed),
    "Candidate 003 permits only its single frozen seed."
  )
  mfrmr_cq_p2c3_assert(
    identical(maximum_cell_draws, mfrmr_cq_p2c3_maximum_cell_draws),
    "Candidate 003 permits only its frozen cell-draw ceiling."
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
      mfrmr_cq_p2c3_assert(
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
        mfrmr_cq_p2c3_assert(
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
    mfrmr_cq_p2c3_assert(
      nrow(data) == 288L && !anyNA(data$Response) &&
        all(data$Response %in% 0:3) && nrow(conditioning) == 12L &&
        all(conditioning$CoverageSatisfied),
      "Candidate 003 did not satisfy its coverage-conditioned support."
    )
    list(
      Specification = mfrmr_cq_p2c3_specification,
      ContractVersion = mfrmr_cq_p2c3_contract,
      CandidateId = mfrmr_cq_p2c3_candidate_id,
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
      ExternalExecutionAuthorized = FALSE,
      EvidencePromotionAuthorized = FALSE,
      ScientificEquivalenceInferred = FALSE
    )
  })
}

mfrmr_cq_p2c3_review <- function() {
  mfrmr_cq_p2c3_require_contracts()
  fixture <- mfrmr_cq_p2c3_fixture()
  signal <- mfrmr_cq_p2r_signal_audit(fixture)
  gates <- mfrmr_cq_p2r_gate_results(fixture)
  frozen_gate_identity <- identical(
    gates[, names(mfrmr_cq_p2r_gate_registry()), drop = FALSE],
    mfrmr_cq_p2r_gate_registry()
  )
  conditioning_ready <- nrow(fixture$Conditioning) == 12L &&
    all(fixture$Conditioning$Persons == 24L) &&
    all(fixture$Conditioning$CoverageSatisfied) &&
    all(fixture$Conditioning$DrawAttempts >= 1L) &&
    all(fixture$Conditioning$DrawAttempts <= fixture$MaximumCellDraws) &&
    sum(fixture$Conditioning[, paste0("Category", 0:3)]) == 288L
  provenance_ready <- identical(fixture$Seed, mfrmr_cq_p2c3_seed) &&
    !isTRUE(fixture$SeedSearchPerformed) &&
    !isTRUE(fixture$ResponseRepairPerformed) &&
    !isTRUE(fixture$PostGenerationCategoryEditing) &&
    isTRUE(fixture$ProbabilityWeighted) &&
    isTRUE(fixture$JointSamplingConditionedOnFullCellSupport) &&
    !isTRUE(fixture$TruthRecoveryAuthorized)
  all_thirteen_passed <- nrow(gates) == 13L && all(gates$Passed)
  ready <- frozen_gate_identity && all_thirteen_passed &&
    conditioning_ready && provenance_ready &&
    !isTRUE(signal$ExternalExecutionAuthorized)
  list(
    specification = mfrmr_cq_p2c3_specification,
    contract_version = mfrmr_cq_p2c3_contract,
    candidate_id = mfrmr_cq_p2c3_candidate_id,
    status = if (ready) {
      "candidate_003_prefit_fixture_ready_mfrmr_preflight_only"
    } else {
      "candidate_003_rejected_before_fit"
    },
    fixture = fixture,
    signal_audit = signal,
    gate_results = gates,
    frozen_candidate_002_gate_identity_retained = frozen_gate_identity,
    coverage_conditioning_ready = conditioning_ready,
    provenance_ready = provenance_ready,
    all_thirteen_prefit_gates_passed = all_thirteen_passed,
    mfrmr_fit_preflight_authorized = ready,
    truth_recovery_authorized = FALSE,
    external_execution_authorized = FALSE,
    fresh_runtime_and_minimum_audit_required = TRUE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
