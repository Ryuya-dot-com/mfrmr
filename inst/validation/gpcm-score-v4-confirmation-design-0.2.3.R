# No-fit, response-prespecified design for structurally disjoint GPCM score-rule
# v4 confirmation. It creates deterministic fixtures only and authorizes no fit
# or confirmation execution.

mfrmr_gsv4c_contract_version <-
  "mfrmr_gpcm_score_v4_confirmation_design_v1"
mfrmr_gsv4c_frozen_payload <-
  "ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a"
mfrmr_gsv4c_freeze_contract_sha256 <-
  "3baab8bfabf5b05600a2a12057cfcb6b79c7c3c665824675afb6cafa9c56744b"
mfrmr_gsv4c_prior_design_sha256 <-
  "c22bf47998fbad9b46e6d8b205af8a52ef6a03b17a190fb24207f2b0fc7d4ec6"
mfrmr_gsv4c_completion_design_sha256 <-
  "bf6ae572a3c0c2253c6fbd35fc5138eaaae92728d7d9588f1d50cebfafcae838"
mfrmr_gsv4c_prior_fixture_hashes <- c(
  "71f144dbee608f04f49d68c6155dd27d92d6be83d9e1b3f3fad1c5bfc5087309",
  "02630b52b65f74948e3158b2ef03da7ed7ebac8757689d586c65c61f67ac195a",
  "e82b1c8ab9d8e1914a5534c2f5c40daed9765c2ed4929db8f3276dbff865a44c",
  "57ad036bb60bd0f2cff0d2666584f3cb6d51ccb7255f4993068803a3c15a2c89"
)
mfrmr_gsv4c_expected_fixture_hashes <- c(
  braid5 = "7d751e4436ea6be7ae9bad5d1d990b527fb81f5ee5b3335dc9475225a779dbd0",
  weave6 = "53e53bdc816338008a07459d434c69a1b7acabfa41ef5dd215d2fefd8dcb2a7b",
  fan7 = "50bb1b0c48f7ee9154315d5794d9c44a60f842f6df986e57191cc7c78ddc899f"
)
mfrmr_gsv4c_points <- c(
  "retained_solution", "coupled_free_probe",
  "finite_slope_stress_forward", "finite_slope_stress_reverse"
)
mfrmr_gsv4c_classes <- c(
  "owner_additive", "other_additive", "steps", "log_slopes"
)

mfrmr_gsv4c_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv4c_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"), file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"), "."
  )
  found <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v4-freeze-contract-0.2.3.R"
  ))]
  mfrmr_gsv4c_assert(length(found) > 0L,
                     "Cannot locate the frozen v4 validation sources.")
  normalizePath(found[[1L]], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv4c_hash_file <- function(path) {
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4c_hash_fixture <- function(data) {
  canonical <- paste(
    c(paste(names(data), collapse = "|"),
      apply(data, 1L, paste, collapse = "|")),
    collapse = "\n"
  )
  digest::digest(canonical, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv4c_bipartite_connected <- function(data, left, right) {
  edges <- unique(data[c(left, right)])
  left_values <- unique(as.character(edges[[left]]))
  right_values <- unique(as.character(edges[[right]]))
  nodes <- c(paste0("L::", left_values), paste0("R::", right_values))
  adjacency <- stats::setNames(vector("list", length(nodes)), nodes)
  for (index in seq_len(nrow(edges))) {
    l <- paste0("L::", edges[[left]][index])
    r <- paste0("R::", edges[[right]][index])
    adjacency[[l]] <- unique(c(adjacency[[l]], r))
    adjacency[[r]] <- unique(c(adjacency[[r]], l))
  }
  visited <- nodes[1L]
  frontier <- visited
  while (length(frontier) > 0L) {
    next_nodes <- unique(unlist(adjacency[frontier], use.names = FALSE))
    next_nodes <- setdiff(next_nodes, visited)
    visited <- c(visited, next_nodes)
    frontier <- next_nodes
  }
  length(visited) == length(nodes)
}

mfrmr_gsv4c_fixture <- function(
    design_id = c("braid5", "weave6", "fan7"), enforce_hash = TRUE) {
  design_id <- match.arg(design_id)
  if (identical(design_id, "braid5")) {
    persons <- sprintf("N4A-P%03d", seq_len(41L))
    raters <- sprintf("N4A-R%02d", seq_len(4L))
    criteria <- sprintf("N4A-C%02d", seq_len(7L))
    rows <- lapply(seq_along(persons), function(index) {
      rater_index <- 1L + ((index - 1L + c(0L, 1L)) %% length(raters))
      expand.grid(
        Person = persons[index], Rater = raters[rater_index],
        Criterion = criteria, KEEP.OUT.ATTRS = FALSE,
        stringsAsFactors = FALSE
      )
    })
    data <- do.call(rbind, rows)
    n_categories <- 5L
    assignment <- "adjacent_rater_braid_all_criteria"
    pi <- match(data$Person, persons)
    ri <- match(data$Rater, raters)
    ci <- match(data$Criterion, criteria)
    data$Score <- 1L +
      (pi + 2L * ri + 3L * ci + (pi - 1L) %/% 4L) %% n_categories
  } else if (identical(design_id, "weave6")) {
    persons <- sprintf("N4B-P%03d", seq_len(49L))
    raters <- sprintf("N4B-R%02d", seq_len(6L))
    criteria <- sprintf("N4B-C%02d", seq_len(4L))
    rows <- lapply(seq_along(persons), function(index) {
      rater_index <- 1L + ((index - 1L + c(0L, 2L, 5L)) %% length(raters))
      criterion_index <- 1L +
        ((2L * index - 2L + c(0L, 1L, 3L)) %% length(criteria))
      expand.grid(
        Person = persons[index], Rater = raters[rater_index],
        Criterion = criteria[criterion_index], KEEP.OUT.ATTRS = FALSE,
        stringsAsFactors = FALSE
      )
    })
    data <- do.call(rbind, rows)
    n_categories <- 6L
    assignment <- "three_by_three_rater_criterion_weave"
    pi <- match(data$Person, persons)
    ri <- match(data$Rater, raters)
    ci <- match(data$Criterion, criteria)
    data$Score <- 1L +
      (pi + ri + 2L * ci + (pi - 1L) %/% 6L) %% n_categories
  } else {
    persons <- sprintf("N4C-P%03d", seq_len(53L))
    raters <- sprintf("N4C-R%02d", seq_len(5L))
    criteria <- sprintf("N4C-C%02d", seq_len(8L))
    rows <- lapply(seq_along(persons), function(index) {
      rater_index <- unique(c(
        1L, 1L + ((2L * index - 1L) %% length(raters)),
        if (index %% 4L == 0L) 1L + ((index + 2L) %% length(raters)) else 1L
      ))
      criterion_index <- 1L +
        ((index - 1L + c(0L, 1L, 3L, 5L, 6L)) %% length(criteria))
      expand.grid(
        Person = persons[index], Rater = raters[rater_index],
        Criterion = criteria[criterion_index], KEEP.OUT.ATTRS = FALSE,
        stringsAsFactors = FALSE
      )
    })
    data <- do.call(rbind, rows)
    n_categories <- 7L
    assignment <- "common_hub_workload_fan_rotating_five_criteria"
    pi <- match(data$Person, persons)
    ri <- match(data$Rater, raters)
    ci <- match(data$Criterion, criteria)
    data$Score <- 1L +
      (pi + 2L * ri + 3L * ci + (pi - 1L) %/% 5L) %% n_categories
  }
  data$Score <- as.integer(data$Score)
  data <- data[order(data$Person, data$Rater, data$Criterion), , drop = FALSE]
  row.names(data) <- NULL
  support <- lapply(c("Rater", "Criterion"), function(owner) {
    table(factor(data[[owner]], levels = sort(unique(data[[owner]]))),
          factor(data$Score, levels = seq_len(n_categories)))
  })
  names(support) <- c("Rater", "Criterion")
  key <- paste(data$Person, data$Rater, data$Criterion, sep = "::")
  hash <- mfrmr_gsv4c_hash_fixture(data)
  expected_hash <- unname(mfrmr_gsv4c_expected_fixture_hashes[design_id])
  rater_load <- table(data$Rater)
  mfrmr_gsv4c_assert(
    !anyDuplicated(key) &&
      all(vapply(support, function(x) all(x > 0), logical(1L))) &&
      mfrmr_gsv4c_bipartite_connected(data, "Person", "Rater") &&
      mfrmr_gsv4c_bipartite_connected(data, "Person", "Criterion"),
    "A v4 confirmation fixture lost row identity, support, or connectivity."
  )
  if (isTRUE(enforce_hash)) {
    mfrmr_gsv4c_assert(!is.na(expected_hash) && identical(hash, expected_hash),
                       "A sealed v4 confirmation fixture changed.")
  }
  list(
    design_id = design_id, data = data, n_categories = n_categories,
    n_persons = length(persons), n_raters = length(raters),
    n_criteria = length(criteria), assignment = assignment, support = support,
    missing_assignment_rate = 1 - nrow(data) /
      (length(persons) * length(raters) * length(criteria)),
    rater_load_ratio = max(rater_load) / min(rater_load), sha256 = hash,
    stochastic = FALSE, fit_opened = FALSE, result_opened = FALSE,
    confirmation_executed = FALSE
  )
}

mfrmr_gsv4c_scenarios <- function() {
  design <- rep(c("braid5", "weave6", "fan7"), each = 2L)
  owner <- rep(c("Criterion", "Rater"), 3L)
  fixtures <- lapply(unique(design), mfrmr_gsv4c_fixture)
  names(fixtures) <- unique(design)
  n_persons <- c(braid5 = 41L, weave6 = 49L, fan7 = 53L)[design]
  n_raters <- c(braid5 = 4L, weave6 = 6L, fan7 = 5L)[design]
  n_criteria <- c(braid5 = 7L, weave6 = 4L, fan7 = 8L)[design]
  n_categories <- c(braid5 = 5L, weave6 = 6L, fan7 = 7L)[design]
  owner_levels <- ifelse(owner == "Criterion", n_criteria, n_raters)
  other_levels <- ifelse(owner == "Criterion", n_raters, n_criteria)
  data.frame(
    ContractVersion = mfrmr_gsv4c_contract_version,
    ScenarioId = paste("NUM-GPCM-SCORE-V4-CONF", toupper(design),
                       ifelse(owner == "Criterion", "C", "R"), sep = "-"),
    DesignId = design, SlopeOwner = owner, StepOwner = owner,
    NPersons = unname(n_persons), NRaters = unname(n_raters),
    NCriteria = unname(n_criteria), NCategories = unname(n_categories),
    Rows = vapply(design, function(x) nrow(fixtures[[x]]$data), integer(1L)),
    Assignment = vapply(design, function(x) fixtures[[x]]$assignment,
                        character(1L)),
    MissingAssignmentRate = vapply(
      design, function(x) fixtures[[x]]$missing_assignment_rate, numeric(1L)
    ),
    RaterLoadRatio = vapply(
      design, function(x) fixtures[[x]]$rater_load_ratio, numeric(1L)
    ),
    FixtureSHA256 = unname(mfrmr_gsv4c_expected_fixture_hashes[design]),
    CoordinatesPerPoint =
      2L * (owner_levels - 1L) + (other_levels - 1L) +
      owner_levels * (n_categories - 2L),
    JacobianRowsPerPoint = owner_levels * (owner_levels - 1L),
    Estimator = "MML", Engine = "direct", QuadPoints = 31L,
    Maxit = 2000L, Reltol = 1e-12,
    PriorFixtureIdentityOverlap = FALSE,
    CalibrationDataReused = FALSE, FitOpened = FALSE, ResultOpened = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4c_expected_evidence <- function() {
  scenarios <- mfrmr_gsv4c_scenarios()
  grid <- expand.grid(
    ScenarioId = scenarios$ScenarioId, Point = mfrmr_gsv4c_points,
    ParameterClass = mfrmr_gsv4c_classes,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$ContractVersion <- mfrmr_gsv4c_contract_version
  grid$ResultOpened <- FALSE
  grid$ConfirmationExecutionAuthorized <- FALSE
  grid[c("ContractVersion", "ScenarioId", "Point", "ParameterClass",
         "ResultOpened", "ConfirmationExecutionAuthorized")]
}

mfrmr_gsv4c_prior_identity_overlap <- function() {
  validation_dir <- mfrmr_gsv4c_validation_dir()
  prior_path <- file.path(
    validation_dir, "gpcm-score-v3-confirmation-design-0.2.3.R"
  )
  completion_path <- file.path(
    validation_dir, "gpcm-score-v4-boundary-completion-design-0.2.3.R"
  )
  mfrmr_gsv4c_assert(
    identical(mfrmr_gsv4c_hash_file(prior_path),
              mfrmr_gsv4c_prior_design_sha256) &&
      identical(mfrmr_gsv4c_hash_file(completion_path),
                mfrmr_gsv4c_completion_design_sha256),
    "A protected prior design source changed."
  )
  prior_env <- new.env(parent = globalenv())
  completion_env <- new.env(parent = globalenv())
  sys.source(prior_path, envir = prior_env)
  sys.source(completion_path, envir = completion_env)
  prior <- do.call(rbind, lapply(
    c("rect4", "cyclic5", "work6"),
    function(id) prior_env$mfrmr_gsv3c_fixture(id)$data
  ))
  completion <- completion_env$mfrmr_gsv4b_fixture()$data
  protected <- rbind(prior, completion)
  current <- do.call(rbind, lapply(
    c("braid5", "weave6", "fan7"),
    function(id) mfrmr_gsv4c_fixture(id)$data
  ))
  data.frame(
    PersonOverlap = length(intersect(current$Person, protected$Person)),
    RaterOverlap = length(intersect(current$Rater, protected$Rater)),
    CriterionOverlap = length(intersect(current$Criterion,
                                        protected$Criterion)),
    FixtureHashOverlap = sum(
      mfrmr_gsv4c_expected_fixture_hashes %in% mfrmr_gsv4c_prior_fixture_hashes
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4c_design_decision <- function() {
  validation_dir <- mfrmr_gsv4c_validation_dir()
  freeze_hash <- mfrmr_gsv4c_hash_file(file.path(
    validation_dir, "gpcm-score-v4-freeze-contract-0.2.3.R"
  ))
  scenarios <- mfrmr_gsv4c_scenarios()
  fixtures <- lapply(c("braid5", "weave6", "fan7"), mfrmr_gsv4c_fixture)
  observed_hashes <- vapply(fixtures, `[[`, character(1L), "sha256")
  overlap <- mfrmr_gsv4c_prior_identity_overlap()
  complete <- nrow(scenarios) == 6L && !anyDuplicated(scenarios$ScenarioId) &&
    identical(unname(observed_hashes),
              unname(mfrmr_gsv4c_expected_fixture_hashes)) &&
    all(unlist(overlap, use.names = FALSE) == 0L) &&
    all(!scenarios$PriorFixtureIdentityOverlap) &&
    all(!scenarios$CalibrationDataReused) && all(!scenarios$FitOpened) &&
    all(!scenarios$ResultOpened) &&
    all(!scenarios$ConfirmationExecutionAuthorized) &&
    nrow(mfrmr_gsv4c_expected_evidence()) == 96L &&
    sum(scenarios$CoordinatesPerPoint) * 4L == 888L &&
    nrow(scenarios) * 4L == 24L &&
    sum(scenarios$JacobianRowsPerPoint) * 4L == 688L &&
    identical(freeze_hash, mfrmr_gsv4c_freeze_contract_sha256)
  mfrmr_gsv4c_assert(complete,
                     "The sealed v4 confirmation design is incomplete.")
  data.frame(
    ContractVersion = mfrmr_gsv4c_contract_version,
    Status = "v4_confirmation_design_sealed_execution_not_authorized",
    ScenarioCount = 6L, ExpectedEvidenceRows = 96L,
    ExpectedCoordinateRows = 888L, ExpectedPointRows = 24L,
    ExpectedJacobianRows = 688L, PriorFixtureIdentityOverlap = FALSE,
    CalibrationDataReused = FALSE, ResultOpened = FALSE,
    RuleChangedAfterFreeze = FALSE,
    FutureExecutionMustRecordAbsoluteTarget = TRUE,
    ConfirmationExecutionAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE, InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv4c_contract <- function() {
  list(
    contract_version = mfrmr_gsv4c_contract_version,
    frozen_payload_sha256 = mfrmr_gsv4c_frozen_payload,
    freeze_contract_sha256 = mfrmr_gsv4c_freeze_contract_sha256,
    scenarios = mfrmr_gsv4c_scenarios(),
    points = mfrmr_gsv4c_points,
    parameter_classes = mfrmr_gsv4c_classes,
    expected_evidence = mfrmr_gsv4c_expected_evidence(),
    prior_identity_overlap = mfrmr_gsv4c_prior_identity_overlap(),
    decision = mfrmr_gsv4c_design_decision(),
    confirmation_execution_authorized = FALSE
  )
}
