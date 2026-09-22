# Repository-only replacement fixture for the failed minimum P2 diagnostic.
#
# One seed and one PCM-generating mechanism are frozen without seed search.
# RSM and PCM retain the same observed rows. The contract adds engine-
# independent population-signal and facet-sufficient-statistic gates before
# any replacement candidate can be authorized. It launches and fits nothing.

mfrmr_cq_p2r_specification <-
  "0.2.3-conquest-p2-replacement-nondegenerate-fixture-v1"
mfrmr_cq_p2r_contract <-
  "mfrmr_conquest_p2_replacement_nondegenerate_fixture_v1"
mfrmr_cq_p2r_seed <- 2026081502L
mfrmr_cq_p2r_candidate_id <-
  "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-002"

mfrmr_cq_p2r_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_cq_p2r_require_contracts <- function() {
  target <- environment(mfrmr_cq_p2r_require_contracts)
  required <- c(
    "mfrmr_cq_p2_complete_grid", "mfrmr_cq_p2_assignment",
    "mfrmr_cq_p2_truth", "mfrmr_cq_p2_probability",
    "mfrmr_cq_p2_component_count"
  )
  available <- vapply(
    required, exists, logical(1L), envir = target,
    mode = "function", inherits = TRUE
  )
  identity <- exists(
    "mfrmr_cq_p2_contract", envir = target, inherits = TRUE
  ) && identical(
    get("mfrmr_cq_p2_contract", envir = target, inherits = TRUE),
    "mfrmr_conquest_p2_additive_adversarial_fixtures_v1"
  )
  mfrmr_cq_p2r_assert(
    all(available) && identity,
    "Source the exact P2 adversarial-fixture contract before its replacement."
  )
  invisible(TRUE)
}

mfrmr_cq_p2r_with_seed <- function(seed, code) {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(as.integer(seed)[1L])
  force(code)
}

mfrmr_cq_p2r_gate_registry <- function() {
  data.frame(
    GateId = c(
      "EXACT_PERSON_COUNT", "EXACT_OBSERVED_ROW_COUNT",
      "CONNECTED_MULTIBRIDGE_GRAPH", "ALL_RATER_CRITERION_CATEGORIES_PRESENT",
      "PERSON_SCORE_UNIQUE_SUPPORT", "PERSON_SCORE_RANGE",
      "PERSON_SCORE_X_CORRELATION", "PERSON_SCORE_X_MEAN_SEPARATION",
      "RATER_SUFFICIENT_STATISTIC_NONCANCELLATION",
      "CRITERION_SUFFICIENT_STATISTIC_NONCANCELLATION",
      "FACET_CATEGORY_MARGINS_NOT_EXACTLY_BALANCED",
      "GENERATING_THETA_X_MEAN_SEPARATION", "GENERATING_THETA_VARIANCE"
    ),
    Metric = c(
      "persons", "observed_rows", "connected_four_edges_zero_bridges",
      "minimum_rater_criterion_category_count", "unique_person_total_scores",
      "person_total_score_range", "absolute_person_total_score_X_correlation",
      "absolute_X_group_mean_person_total_score_separation",
      "maximum_absolute_centered_rater_weighted_score",
      "maximum_absolute_centered_criterion_weighted_score",
      "exact_facet_category_balance", "absolute_X_group_mean_theta_separation",
      "generating_theta_variance"
    ),
    Comparison = c(
      "equal", "equal", "exact", "at_least", "at_least", "at_least",
      "at_least", "at_least", "at_least", "at_least", "equal",
      "at_least", "at_least"
    ),
    Threshold = c(
      48, 288, 1, 1, 6, 5, 0.20, 0.75, 1, 1, 0, 0.80, 0.50
    ),
    FailureOutcome = c(
      rep("fixture_shape_defect", 2L), "fixture_connectivity_defect",
      "fixture_support_defect", rep("fixture_population_signal_defect", 4L),
      rep("fixture_facet_signal_defect", 3L),
      rep("fixture_generating_population_defect", 2L)
    ),
    FrozenBeforeGenerationReview = TRUE,
    CanAuthorizeExternalExecution = FALSE,
    CanPromoteEvidence = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2r_fixture <- function(seed = mfrmr_cq_p2r_seed) {
  mfrmr_cq_p2r_require_contracts()
  seed <- as.integer(seed)[1L]
  mfrmr_cq_p2r_assert(
    identical(seed, mfrmr_cq_p2r_seed),
    "The replacement fixture permits only its single frozen seed."
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
    data$Response <- vapply(seq_len(nrow(data)), function(index) {
      probability <- mfrmr_cq_p2_probability(
        "PCM",
        theta[match(data$Person[index], person$Person)],
        data$Rater[index], data$Criterion[index]
      )
      sample.int(4L, size = 1L, prob = probability) - 1L
    }, integer(1L))
    mfrmr_cq_p2r_assert(
      nrow(data) == 288L && all(data$Response %in% 0:3),
      "The replacement generator did not retain the 288-row declared support."
    )
    list(
      Specification = mfrmr_cq_p2r_specification,
      ContractVersion = mfrmr_cq_p2r_contract,
      CandidateId = mfrmr_cq_p2r_candidate_id,
      Seed = seed,
      GeneratingFamily = "PCM",
      Data = data,
      Person = person,
      Truth = truth,
      SharedAcrossCandidateFamilies = c("RSM", "PCM"),
      SeedSearchPerformed = FALSE,
      ExternalExecutionAuthorized = FALSE,
      EvidencePromotionAuthorized = FALSE,
      ScientificEquivalenceInferred = FALSE
    )
  })
}

mfrmr_cq_p2r_graph_audit <- function(fixture) {
  data <- fixture$Data
  levels <- paste0("R", 1:4)
  pairs <- utils::combn(levels, 2L, simplify = FALSE)
  edge <- do.call(rbind, lapply(pairs, function(pair) {
    common <- intersect(
      unique(data$Person[data$Rater == pair[1L]]),
      unique(data$Person[data$Rater == pair[2L]])
    )
    data.frame(
      Rater1 = pair[1L], Rater2 = pair[2L],
      CommonPersons = length(common), stringsAsFactors = FALSE
    )
  }))
  edge <- edge[edge$CommonPersons > 0L, , drop = FALSE]
  components <- mfrmr_cq_p2_component_count(levels, edge)
  bridge <- vapply(seq_len(nrow(edge)), function(index) {
    mfrmr_cq_p2_component_count(levels, edge[-index, , drop = FALSE]) >
      components
  }, logical(1L))
  list(
    Components = components,
    Connected = components == 1L,
    PositiveEdgeCount = nrow(edge),
    BridgeEdgeCount = sum(bridge),
    MinimumCommonPersons = min(edge$CommonPersons),
    EdgeTable = transform(edge, IsBridge = bridge)
  )
}

mfrmr_cq_p2r_signal_audit <- function(fixture = mfrmr_cq_p2r_fixture()) {
  data <- fixture$Data
  person_score <- stats::aggregate(Response ~ Person + X, data, sum)
  theta_by_x <- stats::aggregate(GeneratingTheta ~ X, fixture$Person, mean)
  score_by_x <- stats::aggregate(Response ~ X, person_score, mean)
  cell_category <- xtabs(~ Rater + Criterion + Response, data)
  rater_category <- apply(cell_category, c(1L, 3L), sum)
  criterion_category <- apply(cell_category, c(2L, 3L), sum)
  rater_score <- tapply(data$Response, data$Rater, sum)
  criterion_score <- tapply(data$Response, data$Criterion, sum)
  graph <- mfrmr_cq_p2r_graph_audit(fixture)
  data.frame(
    Persons = nrow(person_score),
    ObservedRows = nrow(data),
    Connected = graph$Connected,
    PositiveEdgeCount = graph$PositiveEdgeCount,
    BridgeEdgeCount = graph$BridgeEdgeCount,
    MinimumCommonPersons = graph$MinimumCommonPersons,
    MinimumRaterCriterionCategoryCount = min(cell_category),
    UniquePersonTotalScores = length(unique(person_score$Response)),
    PersonTotalScoreMinimum = min(person_score$Response),
    PersonTotalScoreMaximum = max(person_score$Response),
    PersonTotalScoreRange = diff(range(person_score$Response)),
    PersonScoreXCorrelation = stats::cor(person_score$Response, person_score$X),
    XGroupMeanPersonScoreSeparation = abs(diff(score_by_x$Response)),
    MaximumAbsoluteCenteredRaterScore = max(abs(
      rater_score - mean(rater_score)
    )),
    MaximumAbsoluteCenteredCriterionScore = max(abs(
      criterion_score - mean(criterion_score)
    )),
    ExactFacetCategoryBalance =
      length(unique(as.integer(rater_category))) == 1L &&
      length(unique(as.integer(criterion_category))) == 1L,
    GeneratingThetaXMeanSeparation = abs(diff(theta_by_x$GeneratingTheta)),
    GeneratingThetaVariance = stats::var(fixture$Person$GeneratingTheta),
    SeedSearchPerformed = fixture$SeedSearchPerformed,
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_cq_p2r_gate_results <- function(
    fixture = mfrmr_cq_p2r_fixture()) {
  registry <- mfrmr_cq_p2r_gate_registry()
  signal <- mfrmr_cq_p2r_signal_audit(fixture)
  value <- c(
    signal$Persons,
    signal$ObservedRows,
    as.numeric(
      signal$Connected && signal$PositiveEdgeCount == 4L &&
        signal$BridgeEdgeCount == 0L && signal$MinimumCommonPersons == 12L
    ),
    signal$MinimumRaterCriterionCategoryCount,
    signal$UniquePersonTotalScores,
    signal$PersonTotalScoreRange,
    abs(signal$PersonScoreXCorrelation),
    signal$XGroupMeanPersonScoreSeparation,
    signal$MaximumAbsoluteCenteredRaterScore,
    signal$MaximumAbsoluteCenteredCriterionScore,
    as.numeric(signal$ExactFacetCategoryBalance),
    signal$GeneratingThetaXMeanSeparation,
    signal$GeneratingThetaVariance
  )
  passed <- mapply(function(comparison, observed, threshold) {
    switch(
      comparison,
      equal = identical(as.numeric(observed), as.numeric(threshold)),
      exact = identical(as.numeric(observed), as.numeric(threshold)),
      at_least = is.finite(observed) && observed >= threshold,
      FALSE
    )
  }, registry$Comparison, value, registry$Threshold)
  transform(
    registry,
    Observed = as.numeric(value),
    Passed = as.logical(passed),
    ExternalExecutionAuthorized = FALSE,
    ScientificEquivalenceInferred = FALSE
  )
}

mfrmr_cq_p2r_review <- function() {
  fixture <- mfrmr_cq_p2r_fixture()
  signal <- mfrmr_cq_p2r_signal_audit(fixture)
  gates <- mfrmr_cq_p2r_gate_results(fixture)
  ready <- nrow(gates) == 13L && all(gates$Passed) &&
    identical(fixture$Seed, mfrmr_cq_p2r_seed) &&
    !isTRUE(fixture$SeedSearchPerformed) &&
    !isTRUE(signal$ExactFacetCategoryBalance) &&
    !isTRUE(signal$ExternalExecutionAuthorized)
  list(
    specification = mfrmr_cq_p2r_specification,
    contract_version = mfrmr_cq_p2r_contract,
    candidate_id = mfrmr_cq_p2r_candidate_id,
    status = if (ready) {
      "replacement_fixture_nondegenerate_construction_ready_execution_unauthorized"
    } else {
      "replacement_fixture_rejected_before_fit"
    },
    fixture = fixture,
    signal_audit = signal,
    gate_results = gates,
    all_thirteen_prefit_gates_passed = ready,
    old_candidate_superseded_for_future_design = ready,
    mfrmr_fit_preflight_required = ready,
    fresh_runtime_and_authorization_required = TRUE,
    replacement_candidate_execution_authorized = FALSE,
    evidence_promotion_authorized = FALSE,
    wider_execution_authorized = FALSE,
    P3_execution_authorized = FALSE,
    public_claim_authorized = FALSE,
    scientific_equivalence_inferred = FALSE
  )
}
