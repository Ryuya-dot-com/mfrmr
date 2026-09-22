# No-fit, response-prespecified design for disjoint GPCM score-rule v3
# confirmation. Calling these functions creates deterministic fixture tables
# only. It never fits a model and never authorizes confirmation execution.

mfrmr_gsv3c_contract_version <- "mfrmr_gpcm_score_v3_confirmation_design_v1"
mfrmr_gsv3c_frozen_payload <-
  "ef9fe233ceaa43b9a85ee58230b80bc425dd9be38ed21867c5deeb6beea7565a"
mfrmr_gsv3c_frozen_replay_identity <-
  "5651592f12e2ba5f4c4d394d49516de1d1720e0a1c300feb1af7be4dc753f3a7"
mfrmr_gsv3c_freeze_contract_sha256 <-
  "de3b3bcf6e78ba99806bc67fafe85e908557e912c9c4212cbe6233c5913074bd"
mfrmr_gsv3c_expected_fixture_hashes <- c(
  rect4 = "71f144dbee608f04f49d68c6155dd27d92d6be83d9e1b3f3fad1c5bfc5087309",
  cyclic5 = "02630b52b65f74948e3158b2ef03da7ed7ebac8757689d586c65c61f67ac195a",
  work6 = "e82b1c8ab9d8e1914a5534c2f5c40daed9765c2ed4929db8f3276dbff865a44c"
)
mfrmr_gsv3c_points <- c(
  "retained_solution", "coupled_free_probe",
  "finite_slope_stress_forward", "finite_slope_stress_reverse"
)
mfrmr_gsv3c_classes <- c(
  "owner_additive", "other_additive", "steps", "log_slopes"
)

mfrmr_gsv3c_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_gsv3c_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"), file.path("..", "inst", "validation"),
    file.path("..", "..", "inst", "validation"),
    file.path("..", "..", "..", "inst", "validation"), "."
  )
  candidates <- candidates[file.exists(file.path(
    candidates, "gpcm-score-v3-freeze-contract-0.2.3.R"
  ))]
  mfrmr_gsv3c_assert(length(candidates) > 0L,
                     "Cannot locate the frozen v3 validation sources.")
  normalizePath(candidates[1], winslash = "/", mustWork = TRUE)
}

mfrmr_gsv3c_hash_file <- function(path) {
  mfrmr_gsv3c_assert(requireNamespace("digest", quietly = TRUE),
                     "Package `digest` is required for confirmation design.")
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv3c_hash_fixture <- function(data) {
  canonical <- paste(
    c(paste(names(data), collapse = "|"),
      apply(data, 1L, paste, collapse = "|")),
    collapse = "\n"
  )
  digest::digest(canonical, algo = "sha256", serialize = FALSE)
}

mfrmr_gsv3c_fixture <- function(design_id = c("rect4", "cyclic5", "work6")) {
  design_id <- match.arg(design_id)
  if (identical(design_id, "rect4")) {
    persons <- sprintf("Q%03d", seq_len(37L))
    raters <- sprintf("V%02d", seq_len(3L))
    criteria <- sprintf("D%02d", seq_len(5L))
    data <- expand.grid(Person = persons, Rater = raters,
                        Criterion = criteria, stringsAsFactors = FALSE)
    pi <- match(data$Person, persons)
    ri <- match(data$Rater, raters)
    ci <- match(data$Criterion, criteria)
    n_categories <- 4L
    data$Score <- 1L +
      (2L * pi + 3L * ri + 5L * ci + pi * ri - 1L) %% n_categories
  } else if (identical(design_id, "cyclic5")) {
    persons <- sprintf("Q%03d", 101:143)
    raters <- sprintf("V%02d", 11:15)
    criteria <- sprintf("D%02d", 11:13)
    rows <- lapply(seq_along(persons), function(index) {
      assigned <- raters[1L + c((index - 1L) %% 5L, (index + 1L) %% 5L)]
      expand.grid(Person = persons[index], Rater = assigned,
                  Criterion = criteria, stringsAsFactors = FALSE)
    })
    data <- do.call(rbind, rows)
    pi <- match(data$Person, persons)
    ri <- match(data$Rater, raters)
    ci <- match(data$Criterion, criteria)
    n_categories <- 5L
    data$Score <- 1L +
      (pi + 2L * ri + 3L * ci + (pi - 1L) %/% 5L - 1L) %% n_categories
  } else {
    persons <- sprintf("Q%03d", 201:246)
    raters <- sprintf("V%02d", 21:24)
    criteria <- sprintf("D%02d", 21:26)
    data <- expand.grid(Person = persons, Rater = raters,
                        Criterion = criteria, stringsAsFactors = FALSE)
    pi <- match(data$Person, persons)
    ri <- match(data$Rater, raters)
    ci <- match(data$Criterion, criteria)
    keep <- pi <= c(46L, 38L, 29L, 21L)[ri]
    data <- data[keep, , drop = FALSE]
    pi <- pi[keep]
    ri <- ri[keep]
    ci <- ci[keep]
    n_categories <- 6L
    data$Score <- 1L +
      (pi + 2L * ri + 3L * ci + (pi - 1L) %/% 6L - 1L) %% n_categories
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
  mfrmr_gsv3c_assert(
    !anyDuplicated(key) && all(vapply(support, function(x) all(x > 0),
                                      logical(1L))),
    "A confirmation fixture lost row identity or owner-category support."
  )
  list(
    design_id = design_id, data = data, n_categories = n_categories,
    n_persons = length(persons), n_raters = length(raters),
    n_criteria = length(criteria), support = support,
    sha256 = mfrmr_gsv3c_hash_fixture(data), stochastic = FALSE,
    fit_opened = FALSE, confirmation_executed = FALSE
  )
}

mfrmr_gsv3c_scenarios <- function() {
  design <- rep(c("rect4", "cyclic5", "work6"), each = 2L)
  owner <- rep(c("Criterion", "Rater"), 3L)
  fixture <- lapply(unique(design), mfrmr_gsv3c_fixture)
  names(fixture) <- unique(design)
  n_persons <- c(rect4 = 37L, cyclic5 = 43L, work6 = 46L)[design]
  n_raters <- c(rect4 = 3L, cyclic5 = 5L, work6 = 4L)[design]
  n_criteria <- c(rect4 = 5L, cyclic5 = 3L, work6 = 6L)[design]
  n_categories <- c(rect4 = 4L, cyclic5 = 5L, work6 = 6L)[design]
  owner_levels <- ifelse(owner == "Criterion", n_criteria, n_raters)
  other_levels <- ifelse(owner == "Criterion", n_raters, n_criteria)
  data.frame(
    ContractVersion = mfrmr_gsv3c_contract_version,
    ScenarioId = paste("NUM-GPCM-SCORE-CONF", toupper(design),
                       ifelse(owner == "Criterion", "C", "R"), sep = "-"),
    DesignId = design, SlopeOwner = owner, StepOwner = owner,
    NPersons = unname(n_persons), NRaters = unname(n_raters),
    NCriteria = unname(n_criteria), NCategories = unname(n_categories),
    Rows = vapply(design, function(x) nrow(fixture[[x]]$data), integer(1L)),
    FixtureSHA256 = unname(mfrmr_gsv3c_expected_fixture_hashes[design]),
    CoordinatesPerPoint =
      2L * (owner_levels - 1L) + (other_levels - 1L) +
      owner_levels * (n_categories - 2L),
    JacobianRowsPerPoint = owner_levels * (owner_levels - 1L),
    Estimator = "MML", Engine = "direct", QuadPoints = 31L,
    Maxit = 2000L, Reltol = 1e-12,
    CalibrationDataReused = FALSE, FitOpened = FALSE,
    ConfirmationExecutionAuthorized = FALSE, stringsAsFactors = FALSE
  )
}

mfrmr_gsv3c_expected_evidence <- function() {
  scenarios <- mfrmr_gsv3c_scenarios()
  grid <- expand.grid(
    ScenarioId = scenarios$ScenarioId, Point = mfrmr_gsv3c_points,
    ParameterClass = mfrmr_gsv3c_classes,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  grid$ContractVersion <- mfrmr_gsv3c_contract_version
  grid$ResultOpened <- FALSE
  grid$ConfirmationExecutionAuthorized <- FALSE
  grid[c("ContractVersion", "ScenarioId", "Point", "ParameterClass",
         "ResultOpened", "ConfirmationExecutionAuthorized")]
}

mfrmr_gsv3c_design_decision <- function() {
  validation_dir <- mfrmr_gsv3c_validation_dir()
  freeze_hash <- mfrmr_gsv3c_hash_file(file.path(
    validation_dir, "gpcm-score-v3-freeze-contract-0.2.3.R"
  ))
  scenarios <- mfrmr_gsv3c_scenarios()
  fixture_ids <- unique(scenarios$DesignId)
  fixtures <- lapply(fixture_ids, mfrmr_gsv3c_fixture)
  names(fixtures) <- fixture_ids
  observed_hashes <- vapply(fixtures, `[[`, character(1L), "sha256")
  design_complete <- nrow(scenarios) == 6L &&
    !anyDuplicated(scenarios$ScenarioId) &&
    identical(unname(observed_hashes),
              unname(mfrmr_gsv3c_expected_fixture_hashes[names(observed_hashes)])) &&
    all(!scenarios$CalibrationDataReused) && all(!scenarios$FitOpened) &&
    all(!scenarios$ConfirmationExecutionAuthorized) &&
    nrow(mfrmr_gsv3c_expected_evidence()) == 96L &&
    sum(scenarios$CoordinatesPerPoint) * 4L == 560L &&
    sum(scenarios$JacobianRowsPerPoint) * 4L == 376L &&
    identical(freeze_hash, mfrmr_gsv3c_freeze_contract_sha256)
  mfrmr_gsv3c_assert(design_complete,
                     "The sealed confirmation design is incomplete or changed.")
  data.frame(
    ContractVersion = mfrmr_gsv3c_contract_version,
    Status = "confirmation_design_sealed_execution_not_authorized",
    ScenarioCount = 6L, ExpectedEvidenceRows = 96L,
    ExpectedCoordinateRows = 560L, ExpectedPointRows = 24L,
    ExpectedJacobianRows = 376L, CalibrationDataReused = FALSE,
    ResultOpened = FALSE, RuleChangedAfterFreeze = FALSE,
    ConfirmationExecutionAuthorized = FALSE,
    GeneralNUMSCORETOLFrozen = FALSE, InferenceAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_gsv3c_contract <- function() {
  list(
    contract_version = mfrmr_gsv3c_contract_version,
    frozen_payload_sha256 = mfrmr_gsv3c_frozen_payload,
    frozen_replay_identity = mfrmr_gsv3c_frozen_replay_identity,
    freeze_contract_sha256 = mfrmr_gsv3c_freeze_contract_sha256,
    scenarios = mfrmr_gsv3c_scenarios(),
    points = mfrmr_gsv3c_points,
    parameter_classes = mfrmr_gsv3c_classes,
    expected_evidence = mfrmr_gsv3c_expected_evidence(),
    frozen_rule = list(
      log_slope_envelope = 3,
      analytic = c(absolute = 1e-8, relative = 1e-10),
      finite_difference = c(absolute = 1e-7, relative = 5e-7,
                            spread_multiplier = 10, roundoff_multiplier = 10),
      log_jacobian = c(absolute = 5e-10, relative = 1e-9),
      slope_jacobian = c(absolute = 1e-9, relative = 1e-9)
    ),
    decision = mfrmr_gsv3c_design_decision(),
    confirmation_execution_authorized = FALSE
  )
}
