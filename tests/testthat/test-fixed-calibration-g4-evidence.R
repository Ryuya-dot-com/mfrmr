load_fixed_calibration_g4_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "fixed-calibration-g4-evidence-contract-0.2.4.R"
  )
  skip_if_not(file.exists(script), "Fixed-calibration G4 contract is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

load_fixed_calibration_g4_current_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "fixed-calibration-g4-current-source-contract-0.2.4.R"
  )
  skip_if_not(
    file.exists(script), "Amended fixed-calibration G4 contract is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

load_fixed_calibration_g4_candidate_binding <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation,
    "fixed-calibration-g4-candidate-binding-preflight-0.2.4.R"
  )
  skip_if_not(
    file.exists(script), "Fixed-calibration candidate binding is excluded."
  )
  skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  env$`%||%` <- function(x, y) if (is.null(x)) y else x
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

load_fixed_calibration_g4_candidate_inventory <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "fixed-calibration-g4-candidate-source-inventory-0.2.4.R"
  )
  skip_if_not(
    file.exists(script), "Fixed-calibration candidate inventory is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

load_fixed_calibration_release_candidate_transition <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "fixed-calibration-release-candidate-transition-0.2.4.R"
  )
  skip_if_not(
    file.exists(script), "Release-candidate transition contract is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

load_fixed_calibration_release_candidate_recovery_transition <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  implementation <- file.path(
    validation, "fixed-calibration-release-candidate-transition-0.2.4.R"
  )
  contract <- file.path(
    validation,
    "fixed-calibration-release-candidate-transition-recovery-0.2.4.R"
  )
  skip_if_not(
    file.exists(implementation) && file.exists(contract),
    "Recovery release-candidate transition contract is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(implementation, envir = env)
  sys.source(contract, envir = env)
  list(
    root = root, validation = validation, script = contract, env = env
  )
}

load_fixed_calibration_release_candidate_public_language_transition <-
    function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  implementation <- file.path(
    validation, "fixed-calibration-release-candidate-transition-0.2.4.R"
  )
  contract <- file.path(
    validation,
    "fixed-calibration-release-candidate-transition-public-language-0.2.4.R"
  )
  skip_if_not(
    file.exists(implementation) && file.exists(contract),
    "Public-language release-candidate transition contract is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(implementation, envir = env)
  sys.source(contract, envir = env)
  list(
    root = root, validation = validation, script = contract, env = env
  )
}

load_fixed_calibration_g4_maintenance_admission <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  script <- file.path(
    validation, "fixed-calibration-g4-maintenance-admission-0.2.4.R"
  )
  skip_if_not(
    file.exists(script), "Fixed-calibration maintenance admission is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(script, envir = env)
  list(root = root, validation = validation, script = script, env = env)
}

g4b_rehash_git_identity <- function(env, identity) {
  payload_names <- c(
    "Contract", "RepositoryRoot", "HeadCommit", "HeadTree", "Branch",
    "StatusRegistry", "StatusRegistryHash", "StatusEntryCount",
    "StagedEntryCount", "UnstagedEntryCount", "UntrackedEntryCount"
  )
  identity$IdentityHash <- env$mfrmr_fc_g4b_hash(identity[payload_names])
  identity$GitAvailable <- grepl("^[0-9a-f]{40}$", identity$HeadCommit) &&
    grepl("^[0-9a-f]{40}$", identity$HeadTree)
  identity$Clean <- identity$GitAvailable &&
    nrow(identity$StatusRegistry) == 0L
  identity
}

test_that("G4 identity hashes use a frozen portable text encoding", {
  binding <- load_fixed_calibration_g4_candidate_binding()
  value <- list(
    alpha = c("Å", "", NA_character_),
    beta = data.frame(
      i = c(1L, NA_integer_), ok = c(TRUE, FALSE),
      stringsAsFactors = FALSE
    ),
    gamma = c(0, -0, 0.1, Inf, -Inf, NaN, NA_real_)
  )
  expect_identical(
    binding$env$mfrmr_fc_g4b_hash(value),
    "de752d512a8e7f9d3aa5af7412882a208295340bed50a0eff1db6b316957ef42"
  )
  expect_match(
    paste(binding$env$mfrmr_fc_g4b_canonical_tokens(value), collapse = "\n"),
    "atomic_value:1:utf8:c385", fixed = TRUE
  )
  expect_error(
    binding$env$mfrmr_fc_g4b_hash(as.POSIXct("2026-08-25", tz = "UTC")),
    "unsupported value", fixed = TRUE
  )
  lf <- tempfile("g4-lf-")
  crlf <- tempfile("g4-crlf-")
  on.exit(unlink(c(lf, crlf)), add = TRUE)
  writeBin(charToRaw("alpha\nbeta\n"), lf)
  writeBin(charToRaw("alpha\r\nbeta\r\n"), crlf)
  lf_observation <- binding$env$mfrmr_fc_g4b_text_file_observation(lf)
  crlf_observation <- binding$env$mfrmr_fc_g4b_text_file_observation(crlf)
  expect_identical(lf_observation, crlf_observation)
})

g4_deterministic_data <- function(n_person, prefix, offset) {
  persons <- sprintf(paste0(prefix, "%03d"), seq_len(n_person))
  raters <- paste0("Judge_", c("A", "B", "C", "D"))
  criteria <- paste0("Domain_", c("alpha", "beta", "gamma"))
  out <- expand.grid(
    Person = persons, Rater = raters, Criterion = criteria,
    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  person_index <- match(out$Person, persons)
  rater_index <- match(out$Rater, raters)
  criterion_index <- match(out$Criterion, criteria)
  theta <- stats::qnorm((person_index - 0.35) / (n_person + 0.3))
  rater <- c(-0.45, -0.10, 0.20, 0.35)
  criterion <- c(-0.35, 0.05, 0.30)
  steps <- c(-0.55, 0.05, 0.50)
  eta <- theta - rater[rater_index] - criterion[criterion_index]
  cumulative <- c(0, cumsum(steps))
  row_id <- seq_len(nrow(out)) + as.integer(offset)
  uniform <- ((
    row_id * 73L + person_index * 19L + rater_index * 11L +
      criterion_index * 7L
  ) %% 997L + 0.5) / 997
  out$Score <- vapply(seq_len(nrow(out)), function(i) {
    logits <- 0:3 * eta[i] - cumulative
    probability <- exp(logits - max(logits))
    probability <- probability / sum(probability)
    which(cumsum(probability) >= uniform[i])[1] - 1L
  }, integer(1))
  out
}

g4_confirmation_fixture <- local({
  cache <- new.env(parent = emptyenv())
  function(family = c("RSM", "PCM")) {
    family <- match.arg(family)
    if (exists(family, envir = cache, inherits = FALSE)) {
      return(get(family, envir = cache, inherits = FALSE))
    }
    contract <- load_fixed_calibration_g4_contract()
    design <- contract$env$mfrmr_fc_g4_confirmation_design()
    design <- design[design$Family == family, , drop = FALSE]
    source <- g4_deterministic_data(48L, "G4SRC", 0L)
    confirmation <- g4_deterministic_data(7L, "G4CNF", 401L)
    confirmation$Weight <- rep(c(0.5, 1, 1.5, 2),
                               length.out = nrow(confirmation))
    fit <- suppressWarnings(fit_mfrm(
      source,
      person = "Person", facets = c("Rater", "Criterion"), score = "Score",
      method = "MML", model = family,
      step_facet = if (identical(family, "PCM")) "Criterion" else NULL,
      quad_points = 9, maxit = 100, mml_engine = "direct"
    ))
    stopifnot(mfrmr:::mfrm_inference_ready(fit))
    draft <- mfrmr:::mfrmr_extract_calibration_draft(
      fit,
      calibration_id = design$CalibrationId,
      source_fit_id = design$SourceFixtureId,
      created_at_utc = "2026-08-22T04:00:00Z",
      scoring_quad_points = design$QuadratureOrder
    )
    validated <- mfrmr:::mfrmr_validate_calibration_draft(
      draft, validated_at_utc = "2026-08-22T04:01:00Z"
    )
    frozen <- mfrmr:::mfrmr_freeze_calibration(
      validated, frozen_at_utc = "2026-08-22T04:02:00Z"
    )
    value <- list(
      family = family, source = source, confirmation = confirmation,
      fit = fit, frozen = frozen, design = design
    )
    assign(family, value, envir = cache)
    value
  }
})

g4_capture_calibration_error <- function(expr) {
  tryCatch(force(expr), mfrm_calibration_error = function(error) error)
}

g4_sorted_numeric_score <- function(score) {
  out <- score$estimates[order(score$estimates$Person),
                         c("Person", "Estimate", "SD", "Lower", "Upper"),
                         drop = FALSE]
  rownames(out) <- NULL
  out
}

g4_independent_oracle <- function(artifact, rows, interval_level = 0.84,
                                  node_scale = 1) {
  stopifnot(nrow(artifact$model$interactions) == 0L)
  coordinates <- artifact$parameters$coordinates
  score_map <- artifact$response$score_map
  nodes <- artifact$scoring_basis$nodes * node_scale
  weights <- artifact$scoring_basis$weights
  categories <- 0:(artifact$response$n_categories - 1L)
  alpha <- (1 - interval_level) / 2
  persons <- unique(as.character(rows$Person))
  probability_error <- 0

  result <- lapply(persons, function(person) {
    person_rows <- rows[as.character(rows$Person) == person, , drop = FALSE]
    log_likelihood <- numeric(length(nodes))
    for (row_index in seq_len(nrow(person_rows))) {
      row <- person_rows[row_index, , drop = FALSE]
      base_eta <- 0
      for (facet in artifact$model$facet_names) {
        coordinate <- coordinates[
          coordinates$ParameterClass == "facet" &
            coordinates$OwnerFacet == facet &
            coordinates$Level == as.character(row[[facet]]),
          , drop = FALSE
        ]
        stopifnot(nrow(coordinate) == 1L)
        base_eta <- base_eta +
          artifact$model$facet_signs[[facet]] * coordinate$Value
      }
      if (identical(artifact$model$family, "RSM")) {
        step_rows <- coordinates[
          coordinates$ParameterClass == "shared_step", , drop = FALSE
        ]
      } else {
        owner <- artifact$model$step_owner
        step_rows <- coordinates[
          coordinates$ParameterClass == "owned_step" &
            coordinates$OwnerFacet == owner &
            coordinates$Level == as.character(row[[owner]]), , drop = FALSE
        ]
      }
      step_rows <- step_rows[order(as.integer(step_rows$Step)), , drop = FALSE]
      cumulative <- c(0, cumsum(step_rows$Value))
      observed_internal <- score_map$InternalScore[
        match(row$Score, score_map$OriginalScore)
      ]
      observed_index <- observed_internal - artifact$response$rating_min + 1L
      for (node_index in seq_along(nodes)) {
        logits <- categories * (nodes[node_index] + base_eta) - cumulative
        shifted <- logits - max(logits)
        probabilities <- exp(shifted) / sum(exp(shifted))
        probability_error <- max(
          probability_error, abs(sum(probabilities) - 1),
          max(abs(exp(log(probabilities)) - probabilities))
        )
        log_likelihood[node_index] <- log_likelihood[node_index] +
          as.numeric(row$Weight) * log(probabilities[observed_index])
      }
    }
    shifted <- log_likelihood - max(log_likelihood)
    posterior <- weights * exp(shifted)
    posterior <- posterior / sum(posterior)
    estimate <- sum(nodes * posterior)
    quantile <- function(probability) {
      nodes[which(cumsum(posterior) >= probability)[1]]
    }
    data.frame(
      Person = person,
      Estimate = estimate,
      SD = sqrt(sum(posterior * (nodes - estimate)^2)),
      Lower = quantile(alpha),
      Upper = quantile(1 - alpha),
      stringsAsFactors = FALSE
    )
  })
  estimates <- do.call(rbind, result)
  estimates <- estimates[order(estimates$Person), , drop = FALSE]
  rownames(estimates) <- NULL
  list(estimates = estimates, probability_error = probability_error)
}

g4_mock_config <- function(family = c("RSM", "PCM")) {
  family <- match.arg(family)
  levels <- list(
    Rater = c("R1", "R2", "R3"),
    Criterion = c("C1", "C2", "C3")
  )
  config <- list(
    model = family, method = "MML", n_cat = 5L,
    facet_names = names(levels), facet_levels = levels,
    step_facet = if (identical(family, "PCM")) "Criterion" else NULL,
    interaction_specs = list(), facet_interactions = character(0),
    population_spec = list(active = FALSE),
    facet_signs = c(Rater = -1, Criterion = -1),
    score_map = data.frame(
      OriginalScore = 0:4, InternalScore = 0:4,
      stringsAsFactors = FALSE
    )
  )
  config$facet_specs <- lapply(levels, mfrmr:::build_facet_constraint)
  config$step_specs <- mfrmr:::mfrmr_default_step_specs(config)
  config
}

g4_anchor <- function(family, level = NA_character_, step, value, order) {
  data.frame(
    AnchorId = paste0("g4::", order),
    AnchorType = if (identical(family, "RSM")) "shared_step" else "owned_step",
    ParameterClass = if (identical(family, "RSM")) "shared_step" else "owned_step",
    OwnerFacet = if (identical(family, "RSM")) NA_character_ else "Criterion",
    Level = level, Step = as.character(step), GroupId = NA_character_,
    Value = as.numeric(value), CoordinateSystem = "expanded_logit",
    DeclarationOrder = as.integer(order), stringsAsFactors = FALSE
  )
}

g4_profile_score <- function(artifact, rows) {
  profile <- tempfile(fileext = ".out")
  on.exit(unlink(profile), add = TRUE)
  gc()
  utils::Rprofmem(profile, threshold = 1000)
  timing <- system.time(result <- mfrmr:::mfrmr_score_calibration(artifact, rows))
  utils::Rprofmem(NULL)
  allocations <- readLines(profile, warn = FALSE)
  allocations <- allocations[grepl("^[0-9]+", allocations)]
  allocated <- if (length(allocations) == 0L) 0 else {
    sum(as.numeric(sub(" .*", "", allocations)))
  }
  list(
    elapsed = unname(timing[["elapsed"]]),
    allocated = allocated,
    result_bytes = length(serialize(result, NULL, version = 3)),
    result = result
  )
}

test_that("G4 rules freeze disjoint identities and complete denominators", {
  ctx <- load_fixed_calibration_g4_contract()
  review <- ctx$env$mfrmr_fc_g4_review()
  design <- ctx$env$mfrmr_fc_g4_confirmation_design()
  denominator <- ctx$env$mfrmr_fc_g4_adversarial_denominator()
  platforms <- ctx$env$mfrmr_fc_g4_platform_matrix()

  expect_identical(review$status, "G4_rules_frozen_confirmation_unopened")
  expect_true(review$rules_frozen)
  expect_true(review$disjoint_identities_frozen)
  expect_true(review$denominator_frozen)
  expect_true(review$resource_budgets_frozen)
  expect_false(review$CORE_05_complete)
  expect_false(review$CORE_06_complete)
  expect_false(review$G4_exit_complete)
  expect_false(review$public_api_authorized)
  expect_identical(design$Family, c("RSM", "PCM"))
  expect_false(any(design$PreviouslyUsed))
  expect_identical(nrow(denominator), 19L)
  expect_true(all(denominator$Required))
  expect_false(any(denominator$ConfirmationResultOpened))
  expect_identical(platforms$CellId, c(
    "macos-release", "windows-release", "ubuntu-devel",
    "ubuntu-release", "ubuntu-oldrel-1"
  ))
  expect_true(all(platforms$EvidenceStatus ==
                    "pending_unrun_for_current_g4_payload"))
})

test_that("amended G4 freezes current scoring and boundary identities unopened", {
  ctx <- load_fixed_calibration_g4_current_contract()
  review <- ctx$env$mfrmr_fc_g4_current_review()
  identity <- ctx$env$mfrmr_fc_g4_current_scoring_identity()
  design <- ctx$env$mfrmr_fc_g4_current_confirmation_design()
  rules <- ctx$env$mfrmr_fc_g4_current_numerical_rules()
  denominator <- ctx$env$mfrmr_fc_g4_current_denominator()
  binding <- ctx$env$mfrmr_fc_g4_current_candidate_binding()
  platforms <- ctx$env$mfrmr_fc_g4_current_platform_matrix()

  expect_identical(
    review$status,
    "G4_current_rules_frozen_candidate_unbound_confirmation_unopened"
  )
  expect_true(review$rules_frozen)
  expect_true(review$current_identities_disjoint_and_frozen)
  expect_true(review$historical_control_non_authorizing)
  expect_true(review$denominator_frozen)
  expect_false(review$candidate_binding_complete)
  expect_false(review$current_execution_opened)
  expect_false(review$CORE_05_complete)
  expect_false(review$CORE_06_complete)
  expect_false(review$G4_exit_complete)
  expect_false(review$G6_authorized)
  expect_false(review$public_api_authorized)

  expect_identical(
    identity$Value[identity$Field == "ScoringAlgorithm"],
    "quadrature_eap_v1"
  )
  expect_identical(
    identity$Value[identity$Field == "DefaultScoringQuadratureOrder"], "31"
  )
  expect_identical(
    identity$Value[identity$Field == "MinimumScoringQuadratureOrder"], "2"
  )
  expect_identical(
    rules$Comparison[rules$RuleId == "PRIOR_SENSITIVITY_REVIEW"],
    "review_if_greater_or_equal"
  )
  current <- design[design$DisjointCurrentConfirmationAuthority, ]
  control <- design[
    design$EvidenceRole == "historical_explicit9_regression_control", ,
    drop = FALSE
  ]
  expect_identical(current$FitQuadratureOrder, c(13L, 13L, 1L, 1L))
  expect_identical(current$ScoringQuadratureOrder, rep(31L, 4L))
  expect_identical(current$SourcePersons, c(58L, 58L, 50L, 50L))
  expect_identical(current$ConfirmationPersons, c(11L, 11L, 9L, 9L))
  expect_identical(current$GeneratorIdentity, c(
    rep("closed-form-logits-mod1039-v1-no-r-rng", 2L),
    rep("closed-form-logits-mod1049-v1-no-r-rng", 2L)
  ))
  expect_true(all(grepl("mod1039|mod1049", current$SourceFixtureId)))
  expect_true(all(grepl("mod1039|mod1049", current$ConfirmationFixtureId)))
  expect_false(any(current$PreviouslyUsedFixture))
  expect_false(any(current$CurrentExecutionOpened))
  expect_true(all(control$PreviouslyUsedFixture))
  expect_identical(control$ScoringQuadratureOrder, c(9L, 9L))
  expect_false(any(control$DisjointCurrentConfirmationAuthority))
  expect_false(any(control$ControlMayAuthorizeCurrentG4))

  expect_identical(nrow(denominator), 49L)
  expect_identical(anyDuplicated(denominator$CellId), 0L)
  expect_true(all(denominator$Required))
  expect_false(any(denominator$CurrentExecutionOpened))
  expect_true(all(c(
    "JML_SOURCE1_DEFAULT31_NONDEGENERATE",
    "INTERACTION_REPLAY_FULL_ROUNDTRIP",
    "REPLAY_SCORING_SETTING_PRESERVATION",
    "CHECKPOINT_WEIGHT_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_CROSS_STAGE_REFUSAL",
    "CHECKPOINT_CHECKED_ATOMIC_REPLACEMENT"
  ) %in% denominator$CellId))
  expect_identical(nrow(binding), 12L)
  expect_true(all(binding$RequiredBeforeExecution))
  expect_true(all(is.na(binding$BoundValue)))
  expect_identical(
    platforms$ExecutionOrder,
    c("prerequisite_first", rep("after_macos_release_pass", 4L))
  )
  expect_true(all(
    platforms$EvidenceStatus ==
      "pending_unrun_for_bound_current_candidate"
  ))
})

test_that("amended G4 v5 contract remains immutable historical evidence", {
  ctx <- load_fixed_calibration_g4_current_contract()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("mfrmr_score_calibration\\s*\\(", source, perl = TRUE))
  expect_false(grepl("saveRDS\\s*\\(|readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))

  record_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-current-source-v5-contract-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  hardening <- paste(readLines(file.path(
    ctx$validation, "fixed-calibration-boundary-hardening-0.2.4.md"
  ), warn = FALSE), collapse = "\n")
  expect_match(
    record, ctx$env$mfrmr_fc_g4_current_specification, fixed = TRUE
  )
  expect_match(record, "`V5ContractFrozen=TRUE`", fixed = TRUE)
  expect_match(
    record, "`V5CurrentExecutionOpened=FALSE`", fixed = TRUE
  )
  expect_match(record, "`V5CandidateBound=FALSE`", fixed = TRUE)
  expect_match(record, "`V5DenominatorCells=49`", fixed = TRUE)
  expect_match(record, "`V4IdentityReuseAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(
    hardening, "`HistoricalG4Retained=TRUE`", fixed = TRUE
  )
  expect_match(
    hardening, "`HistoricalG4CurrentSourceEvidence=FALSE`", fixed = TRUE
  )
  expect_match(
    hardening, "`PostMaintenanceG4ContractFrozen=TRUE`", fixed = TRUE
  )
})

test_that("amended G4 worker statically covers every frozen cell exactly", {
  ctx <- load_fixed_calibration_g4_current_contract()
  worker_path <- file.path(
    ctx$validation, "fixed-calibration-g4-confirmation-worker-0.2.4.R"
  )
  expect_true(file.exists(worker_path))
  worker <- new.env(parent = globalenv())
  before_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  sys.source(worker_path, envir = worker)
  denominator <- ctx$env$mfrmr_fc_g4_current_denominator()
  handlers <- worker$mfrmr_fc_g4w_current_handlers(
    ctx$env, ctx$root, worker_path
  )
  expect_identical(worker$mfrmr_fc_g4w_cell_ids(), denominator$CellId)
  expect_identical(names(handlers), denominator$CellId)
  expect_identical(length(handlers), 49L)
  expect_identical(
    exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE), before_seed
  )
  source <- paste(readLines(worker_path, warn = FALSE), collapse = "\n")
  expect_match(source, "CurrentExecutionOpened = TRUE", fixed = TRUE)
  expect_match(source, "retained_failure", fixed = TRUE)
  expect_match(source, "nrow(cells) == 49L", fixed = TRUE)
})

test_that("consumed current-source failures are retained before v5 execution", {
  ctx <- load_fixed_calibration_g4_current_contract()
  v2_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-current-execution-53f5f21-record-0.2.4.md"
  )
  v3_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-current-execution-7afff78-record-0.2.4.md"
  )
  expect_true(file.exists(v2_path))
  expect_true(file.exists(v3_path))
  v2 <- paste(readLines(v2_path, warn = FALSE), collapse = "\n")
  v3 <- paste(readLines(v3_path, warn = FALSE), collapse = "\n")
  for (record in list(v2, v3)) {
    expect_match(record, "`DenominatorRowsRetained=49`", fixed = TRUE)
    expect_match(record, "`ResourceScalesPassed=3`", fixed = TRUE)
    expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
    expect_match(
      record, "`RetrySameCurrentIdentityAuthorized=FALSE`", fixed = TRUE
    )
  }
  expect_match(v2, "`PassedCells=44`", fixed = TRUE)
  expect_match(v2, "`FailedCells=5`", fixed = TRUE)
  expect_match(v3, "`PassedCells=48`", fixed = TRUE)
  expect_match(v3, "`FailedCells=1`", fixed = TRUE)
  design <- ctx$env$mfrmr_fc_g4_current_confirmation_design()
  current <- design[design$DisjointCurrentConfirmationAuthority, , drop = FALSE]
  expect_false(any(grepl(
    "mod1009|mod1013|mod1019|mod1021|mod1031|mod1033",
    current$GeneratorIdentity
  )))
  expect_true(all(grepl("mod1039|mod1049", current$GeneratorIdentity)))
})

test_that("v4 hosted integration failure is retained below G4 completion", {
  ctx <- load_fixed_calibration_g4_current_contract()
  path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32822833138-record-0.2.4.md"
  )
  expect_true(file.exists(path))
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(record, "`CompletedHostedCellReceipts=4`", fixed = TRUE)
  expect_match(
    record, "`CompletedHostedCellsPassed49Of49=4`", fixed = TRUE
  )
  expect_match(
    record, "`UbuntuReleasePackageSuitePassed=FALSE`", fixed = TRUE
  )
  expect_match(record, "`V4ConfirmationIdentityConsumed=TRUE`", fixed = TRUE)
  expect_match(record, "`V4ReceiptsReusableForV5=FALSE`", fixed = TRUE)
  expect_match(record, "`HostedPlatformMatrixComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
})

test_that("local v5 success remains below hosted matrix completion", {
  ctx <- load_fixed_calibration_g4_current_contract()
  path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-current-execution-bcf8619-record-0.2.4.md"
  )
  expect_true(file.exists(path))
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(record, "`V5DisjointIdentitiesUsed=TRUE`", fixed = TRUE)
  expect_match(record, "`DenominatorRowsRetained=49`", fixed = TRUE)
  expect_match(record, "`PassedCells=49`", fixed = TRUE)
  expect_match(record, "`FailedCells=0`", fixed = TRUE)
  expect_match(record, "`ResourceScalesPassed=3`", fixed = TRUE)
  expect_match(record, "`G4LocalCandidateComplete=TRUE`", fixed = TRUE)
  expect_match(record, "`HostedPlatformMatrixComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`G6Authorized=FALSE`", fixed = TRUE)
  expect_match(record, "`PublicAPIAuthorized=FALSE`", fixed = TRUE)
})

test_that("local v4 success and hosted pre-worker failure stay distinct", {
  ctx <- load_fixed_calibration_g4_current_contract()
  local_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-current-execution-5af00ed-record-0.2.4.md"
  )
  hosted_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32815204590-record-0.2.4.md"
  )
  hosted2_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32818900492-record-0.2.4.md"
  )
  hosted3_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32819992290-record-0.2.4.md"
  )
  expect_true(file.exists(local_path))
  expect_true(file.exists(hosted_path))
  expect_true(file.exists(hosted2_path))
  expect_true(file.exists(hosted3_path))
  local <- paste(readLines(local_path, warn = FALSE), collapse = "\n")
  hosted <- paste(readLines(hosted_path, warn = FALSE), collapse = "\n")
  hosted2 <- paste(readLines(hosted2_path, warn = FALSE), collapse = "\n")
  hosted3 <- paste(readLines(hosted3_path, warn = FALSE), collapse = "\n")
  expect_match(local, "`PassedCells=49`", fixed = TRUE)
  expect_match(local, "`FailedCells=0`", fixed = TRUE)
  expect_match(local, "`ResourceScalesPassed=3`", fixed = TRUE)
  expect_match(local, "`HostedPlatformMatrixComplete=FALSE`", fixed = TRUE)
  expect_match(local, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(hosted, "`ExactTarballCheckStatus=OK`", fixed = TRUE)
  expect_match(hosted, "`HostedCurrentWorkerInvoked=FALSE`", fixed = TRUE)
  expect_match(
    hosted, "`HostedConfirmationResultObserved=FALSE`", fixed = TRUE
  )
  expect_match(hosted, "`DependentPlatformJobsSkipped=TRUE`", fixed = TRUE)
  expect_match(hosted, "`V4NumericalIdentityChanged=FALSE`", fixed = TRUE)
  expect_match(hosted, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(hosted2, "`ExactTarballCheckStatus=OK`", fixed = TRUE)
  expect_match(hosted2, "`HostedCurrentWorkerInvoked=FALSE`", fixed = TRUE)
  expect_match(hosted2, "`HostedCellReceiptCreated=FALSE`", fixed = TRUE)
  expect_match(hosted2, "`DependentPlatformJobsSkipped=TRUE`", fixed = TRUE)
  expect_match(hosted2, "`V4NumericalIdentityChanged=FALSE`", fixed = TRUE)
  expect_match(hosted2, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(hosted3, "`ExactTarballCheckStatus=OK`", fixed = TRUE)
  expect_match(hosted3, "`HostedCurrentWorkerInvoked=FALSE`", fixed = TRUE)
  expect_match(hosted3, "`HostedCellReceiptCreated=FALSE`", fixed = TRUE)
  expect_match(hosted3, "`DependentPlatformJobsSkipped=TRUE`", fixed = TRUE)
  expect_match(hosted3, "`V4NumericalIdentityChanged=FALSE`", fixed = TRUE)
  expect_match(hosted3, "`G4ExitComplete=FALSE`", fixed = TRUE)
})

test_that("G4 candidate binding observes source identities and stays closed", {
  ctx <- load_fixed_calibration_g4_candidate_binding()
  manifest <- ctx$env$mfrmr_fc_g4b_manifest(ctx$root)
  expect_s3_class(manifest, "mfrmr_fc_g4b_manifest")
  expect_silent(ctx$env$mfrmr_fc_g4b_assert_manifest(manifest, ctx$root))
  expect_identical(manifest$ProspectiveContract,
                   "mfrmr_fixed_calibration_g4_current_source_evidence_v5")
  expect_true(manifest$ObservedGitIdentity$GitAvailable)
  expect_true(manifest$GitIdentityMatchesLive)
  expect_identical(nrow(manifest$ProductionRegistry), 6L)
  expect_identical(manifest$ProductionRegistry$Path, c(
    "R/core-fixed-calibration.R", "R/api-prediction.R",
    "R/api-reference-benchmark.R", "R/api-export-bundles.R",
    "R/core-optimizer.R", "DESCRIPTION"
  ))
  expect_true(all(nchar(manifest$ProductionRegistry$SHA256) == 64L))
  expect_identical(nrow(manifest$SupportRegistry), 7L)
  expect_identical(manifest$SupportRegistry$Role, c(
    "contract", "confirmation_worker", "confirmation_test",
    "binding_preflight", "hosted_runner", "hosted_cell_workflow",
    "hosted_matrix_workflow"
  ))
  expect_true(all(nchar(manifest$SupportRegistry$SHA256) == 64L))
  expect_true(manifest$WorkerDenominatorCoverage$Exact)
  expect_identical(
    manifest$WorkerDenominatorCoverage$ExpectedCellIds,
    manifest$WorkerDenominatorCoverage$WorkerCellIds
  )
  expect_identical(
    manifest$WorkerDenominatorCoverage$ExpectedCellIds,
    manifest$WorkerDenominatorCoverage$HandlerNames
  )
  expect_identical(nrow(manifest$Binding), 12L)
  expect_true(all(c(
    "HostedRunnerSHA256", "HostedCellWorkflowSHA256",
    "HostedMatrixWorkflowSHA256"
  ) %in% manifest$Binding$Field))
  expect_false(manifest$CandidateBindingComplete)
  expect_false(manifest$IsolatedExecutionAdmissionReady)
  expect_false(manifest$CurrentExecutionOpened)
  expect_false(manifest$ConfirmationResultObserved)
  expect_false(manifest$CORE05Complete)
  expect_false(manifest$CORE06Complete)
  expect_false(manifest$G4ExitComplete)
  expect_true("TARBALL_ABSENT" %in% manifest$Refusals$Code)
  expect_true("BINDING_FIELD_INCOMPLETE" %in% manifest$Refusals$Code)
  if (!manifest$ObservedGitIdentity$Clean) {
    expect_true("WORKTREE_DIRTY_OR_UNBOUND" %in% manifest$Refusals$Code)
  }
  expect_error(
    ctx$env$mfrmr_fc_g4b_require_bound_candidate(manifest, ctx$root),
    "candidate binding is incomplete", fixed = TRUE
  )
})

test_that("G4 candidate binding rejects caller-forged live Git identity", {
  ctx <- load_fixed_calibration_g4_candidate_binding()
  live <- ctx$env$mfrmr_fc_g4b_git_identity(ctx$root)
  forged <- live
  forged$HeadCommit <- paste(rep(if (
    identical(substr(live$HeadCommit, 1L, 1L), "0")
  ) "1" else "0", 40L), collapse = "")
  forged <- g4b_rehash_git_identity(ctx$env, forged)
  expect_silent(ctx$env$mfrmr_fc_g4b_assert_git_identity(forged))
  manifest <- ctx$env$mfrmr_fc_g4b_manifest(
    ctx$root, git_identity = forged
  )
  expect_false(manifest$GitIdentityMatchesLive)
  expect_false(manifest$CandidateBindingComplete)
  expect_true("GIT_IDENTITY_NOT_CURRENT" %in% manifest$Refusals$Code)
  expect_true("WORKTREE_DIRTY_OR_UNBOUND" %in% manifest$Refusals$Code)
})

test_that("G4 candidate binding rejects tampering and invalid tarballs", {
  ctx <- load_fixed_calibration_g4_candidate_binding()
  invalid <- tempfile(fileext = ".tar.gz")
  on.exit(unlink(invalid), add = TRUE)
  writeLines("not a source tarball", invalid)
  manifest <- ctx$env$mfrmr_fc_g4b_manifest(ctx$root, invalid)
  expect_false(manifest$CandidateBindingComplete)
  expect_true("TARBALL_INVALID" %in% manifest$Refusals$Code)
  expect_false(manifest$TarballObservation$Safe)

  changed <- ctx$env$mfrmr_fc_g4b_manifest(ctx$root)
  changed$CandidateBindingComplete <- TRUE
  expect_error(
    ctx$env$mfrmr_fc_g4b_assert_manifest(changed, ctx$root),
    "manifest or readiness was altered", fixed = TRUE
  )
})

test_that("G4 candidate binding distinguishes DCF normalization from drift", {
  ctx <- load_fixed_calibration_g4_candidate_binding()
  source <- tempfile(fileext = ".dcf")
  built <- tempfile(fileext = ".dcf")
  on.exit(unlink(c(source, built)), add = TRUE)
  writeLines(c(
    "Package: mfrmr", "Version: 0.2.4.9000",
    "Imports:", "    stats,", "    utils"
  ), source)
  writeLines(c(
    "Package: mfrmr", "Version: 0.2.4.9000",
    "Imports: stats, utils", "NeedsCompilation: yes",
    "Packaged: 2026-08-25 00:00:00 UTC; builder",
    "Author: Example Author", "Maintainer: Example <example@example.org>"
  ), built)
  equivalent <- ctx$env$mfrmr_fc_g4b_description_semantics(source, built)
  expect_true(equivalent$Match)
  expect_identical(sort(equivalent$AddedFields), sort(c(
    "NeedsCompilation", "Packaged", "Author", "Maintainer"
  )))
  expect_identical(equivalent$ChangedSourceFields, character(0))

  changed <- readLines(built, warn = FALSE)
  changed[changed == "Version: 0.2.4.9000"] <- "Version: 0.2.4.9001"
  writeLines(changed, built)
  drift <- ctx$env$mfrmr_fc_g4b_description_semantics(source, built)
  expect_false(drift$Match)
  expect_identical(drift$ChangedSourceFields, "Version")
  expect_identical(drift$ErrorCode, "DESCRIPTION_SEMANTIC_MISMATCH")
})

test_that("G4 candidate binding represents zero refusals as an empty table", {
  ctx <- load_fixed_calibration_g4_candidate_binding()
  empty <- ctx$env$mfrmr_fc_g4b_reason_table(character(0))
  expect_s3_class(empty, "data.frame")
  expect_identical(nrow(empty), 0L)
  expect_identical(
    names(empty), c("Ordinal", "Code", "Disposition")
  )
  expect_identical(empty$Ordinal, integer(0))
  expect_identical(empty$Code, character(0))
  expect_identical(empty$Disposition, character(0))
})

test_that("G4 tarball registries exclude ephemeral row-name identity", {
  files <- c("mfrmr/DESCRIPTION", "mfrmr/R/example.R")
  hashes <- setNames(c(
    paste(rep("a", 64L), collapse = ""),
    paste(rep("b", 64L), collapse = "")
  ), file.path(tempdir(), files))
  registry <- data.frame(
    Ordinal = seq_along(files), Path = files, Bytes = c(10, 20),
    SHA256 = unname(hashes), stringsAsFactors = FALSE
  )
  rownames(registry) <- NULL
  expect_identical(rownames(registry), c("1", "2"))
  expect_identical(names(registry$SHA256), NULL)
  expect_false(any(grepl(tempdir(), registry$SHA256, fixed = TRUE)))
})

test_that("G4 candidate-binding record retains the live refusal boundary", {
  ctx <- load_fixed_calibration_g4_candidate_binding()
  record_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-candidate-binding-preflight-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")
  expect_match(
    record, "`CandidateBindingPreflightImplemented=TRUE`", fixed = TRUE
  )
  expect_match(record, "`LiveCandidateBindingComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`CurrentExecutionOpened=FALSE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("mfrmr_score_calibration\\s*\\(", source, perl = TRUE))
  expect_false(grepl("R CMD check|R CMD build", source, fixed = TRUE))
})

test_that("historical G4 inventory hands candidate paths to the transition contract", {
  ctx <- load_fixed_calibration_g4_candidate_inventory()
  review <- ctx$env$mfrmr_fc_g4i_review(ctx$root)
  inventory <- review$Inventory
  transition <- load_fixed_calibration_release_candidate_transition()
  current <- transition$env$mfrmr_rc04_review(transition$root)
  handed_off <- inventory$Path[
    inventory$Classification == "unclassified_fail_closed"
  ]
  if (length(handed_off) == 0L) {
    expect_identical(
      review$Status, "all_live_changes_classified_commit_lanes_unexecuted"
    )
    expect_true(review$AllChangesClassified)
    expect_true(review$CommitPlanReady)
  } else {
    expect_identical(review$Status, "candidate_source_inventory_blocked")
    expect_false(review$AllChangesClassified)
    expect_false(review$CommitPlanReady)
  }
  expect_true(current$Metadata$Stage %in% c("development", "candidate"))
  expect_true(review$ResearchExcludedFromPackagePayload)
  expect_true(review$PublicInternalLanguageClean)
  expect_identical(review$WorkingTreeClean, nrow(inventory) == 0L)
  expect_false(review$CandidateBindingComplete)
  expect_false(review$CurrentExecutionOpened)
  expect_false(review$G4ExitComplete)
  expect_identical(anyDuplicated(inventory$Path), 0L)
  allowed <- c(
    "release_production_code_and_metadata",
    "release_public_and_user_facing_surface",
    "release_build_test_and_repository_evidence",
    "deferred_multivariate_gtheory_research",
    "deferred_rater_anchor_design_research"
  )
  expect_true(all(inventory$Classification %in% c(
    allowed, "unclassified_fail_closed"
  )))
  representative <- vapply(c(
    "R/api-prediction.R", "src/mml_backend.cpp", "NEWS.md",
    "inst/validation/fixed-calibration-example-0.2.4.md",
    "inst/validation/public-release-baseline-0.2.4.csv"
  ), ctx$env$mfrmr_fc_g4i_classify_path, character(1L))
  expect_identical(unname(representative), c(
    rep(allowed[1], 2L), allowed[2], rep(allowed[3], 2L)
  ))
})

test_that("G4 candidate inventory keeps deferred research outside payload", {
  ctx <- load_fixed_calibration_g4_candidate_inventory()
  paths <- c(
    "inst/validation/gtheory-multivariate-example-0.2.4.R",
    "tests/testthat/test-gtheory-multivariate-example.R",
    "inst/validation/rater-anchor-example-0.2.4.R",
    "tests/testthat/test-rater-anchor-example.R"
  )
  classification <- vapply(
    paths, ctx$env$mfrmr_fc_g4i_classify_path, character(1L)
  )
  expect_identical(unname(classification), c(
    rep("deferred_multivariate_gtheory_research", 2L),
    rep("deferred_rater_anchor_design_research", 2L)
  ))
  research <- classification %in% c(
    "deferred_multivariate_gtheory_research",
    "deferred_rater_anchor_design_research"
  )
  payload <- vapply(seq_along(paths), function(index) {
    ctx$env$mfrmr_fc_g4i_package_payload_expected(
      paths[index], classification[index]
    )
  }, logical(1L))
  expect_true(all(research))
  expect_false(any(payload))
  ignore <- ctx$env$mfrmr_fc_g4i_buildignore_contract(ctx$root)
  expect_true(all(ignore$PresentExactly))
  expect_identical(nrow(ignore), 6L)
})

test_that("G4 candidate inventory keeps internal mechanics out of public help", {
  ctx <- load_fixed_calibration_g4_candidate_inventory()
  hits <- ctx$env$mfrmr_fc_g4i_public_internal_language_audit(ctx$root)
  expect_identical(nrow(hits), 0L)
  record_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-candidate-source-inventory-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expect_match(record, "`AllLiveChangesClassified=TRUE`", fixed = TRUE)
  expect_match(record, "`UnknownPathCount=0`", fixed = TRUE)
  expect_match(record, "`PublicInternalLanguageClean=TRUE`", fixed = TRUE)
  expect_match(record, "`WorkingTreeClean=TRUE`", fixed = TRUE)
})

test_that("disjoint RSM and PCM probability/posterior oracles pass frozen rules", {
  ctx <- load_fixed_calibration_g4_contract()
  rules <- ctx$env$mfrmr_fc_g4_numerical_rules()
  posterior_tolerance <- rules$Threshold[
    rules$RuleId == "POSTERIOR_ABSOLUTE"
  ]
  probability_tolerance <- rules$Threshold[
    rules$RuleId == "PROBABILITY_ABSOLUTE"
  ]

  for (family in c("RSM", "PCM")) {
    fixture <- g4_confirmation_fixture(family)
    expect_length(intersect(
      fixture$source$Person, fixture$confirmation$Person
    ), 0L)
    scored <- mfrmr:::mfrmr_score_calibration(
      fixture$frozen, fixture$confirmation,
      weight = "Weight", interval_level = 0.84
    )
    oracle <- g4_independent_oracle(
      fixture$frozen, fixture$confirmation, interval_level = 0.84
    )
    actual <- g4_sorted_numeric_score(scored)
    expect_lte(oracle$probability_error, probability_tolerance)
    expect_equal(
      actual, oracle$estimates, tolerance = posterior_tolerance
    )
    expect_identical(
      scored$settings$semantic_components,
      fixture$frozen$integrity$semantic_components
    )
  }
})

test_that("independent explicit step Jacobians reproduce RSM and PCM ranks", {
  rsm <- g4_mock_config("RSM")
  rsm_anchor <- g4_anchor("RSM", step = 2L, value = 0.2, order = 1L)
  rsm_applied <- mfrmr:::mfrmr_apply_typed_anchors(rsm, rsm_anchor)$config
  rsm_actual <- as.matrix(mfrmr:::mfrmr_step_jacobian_sparse(
    rsm_applied, mfrmr:::build_param_sizes(rsm_applied)
  )$jacobian)
  rsm_oracle <- matrix(c(
    1, 0,
    0, 0,
    0, 1,
    -1, -1
  ), nrow = 4L, byrow = TRUE)
  expect_equal(unname(rsm_actual), rsm_oracle, tolerance = 0)
  expect_identical(qr(rsm_oracle)$rank, 2L)

  pcm <- g4_mock_config("PCM")
  pcm_anchors <- rbind(
    g4_anchor("PCM", "C1", 2L, 0.2, 1L),
    g4_anchor("PCM", "C2", 1L, -0.3, 2L),
    g4_anchor("PCM", "C2", 4L, 0.1, 3L)
  )
  pcm_applied <- mfrmr:::mfrmr_apply_typed_anchors(pcm, pcm_anchors)$config
  pcm_actual <- as.matrix(mfrmr:::mfrmr_step_jacobian_sparse(
    pcm_applied, mfrmr:::build_param_sizes(pcm_applied)
  )$jacobian)
  block <- function(rows) {
    out <- matrix(0, nrow = rows, ncol = rows - 1L)
    if (ncol(out) > 0L) {
      out[seq_len(ncol(out)), ] <- diag(ncol(out))
      out[rows, ] <- -1
    }
    out
  }
  c1 <- rbind(c(1, 0), c(0, 0), c(0, 1), c(-1, -1))
  c2 <- matrix(c(0, 1, -1, 0), ncol = 1L)
  c3 <- block(4L)
  pcm_oracle <- matrix(0, nrow = 12L, ncol = 6L)
  pcm_oracle[1:4, 1:2] <- c1
  pcm_oracle[5:8, 3] <- c2[, 1]
  pcm_oracle[9:12, 4:6] <- c3
  expect_equal(unname(pcm_actual), pcm_oracle, tolerance = 0)
  expect_identical(qr(pcm_oracle)$rank, 6L)
})

test_that("semantic mutations fail closed or remain visibly distinct", {
  fixture <- g4_confirmation_fixture("RSM")
  artifact <- fixture$frozen
  rows <- fixture$confirmation
  baseline <- mfrmr:::mfrmr_score_calibration(
    artifact, rows, weight = "Weight", interval_level = 0.84
  )
  baseline_numeric <- g4_sorted_numeric_score(baseline)

  sign_only <- artifact
  sign_only$model$facet_signs[1] <- -sign_only$model$facet_signs[1]
  expect_identical(
    g4_capture_calibration_error(
      mfrmr:::mfrmr_score_calibration(sign_only, rows, weight = "Weight")
    )$code,
    "IDENTITY_COMPONENT_MISMATCH"
  )

  coherent_sign <- artifact
  coherent_sign$model$facet_signs <- -coherent_sign$model$facet_signs
  facet_rows <- coherent_sign$parameters$coordinates$ParameterClass == "facet"
  coherent_sign$parameters$coordinates$Value[facet_rows] <-
    -coherent_sign$parameters$coordinates$Value[facet_rows]
  coherent_sign$integrity$semantic_components <-
    mfrmr:::mfrmr_calibration_semantic_components(coherent_sign)
  coherent_score <- mfrmr:::mfrmr_score_calibration(
    coherent_sign, rows, weight = "Weight", interval_level = 0.84
  )
  expect_equal(
    g4_sorted_numeric_score(coherent_score), baseline_numeric,
    tolerance = 5e-14
  )
  expect_false(identical(
    coherent_score$settings$semantic_components,
    baseline$settings$semantic_components
  ))

  category_only <- artifact
  category_only$response$score_map$OriginalScore <-
    rev(category_only$response$score_map$OriginalScore)
  expect_identical(
    g4_capture_calibration_error(
      mfrmr:::mfrmr_score_calibration(category_only, rows, weight = "Weight")
    )$code,
    "IDENTITY_COMPONENT_MISMATCH"
  )

  reversed <- category_only
  reversed$integrity$semantic_components <-
    mfrmr:::mfrmr_calibration_semantic_components(reversed)
  reversed_rows <- rows
  reversed_rows$Score <- reversed$response$score_map$OriginalScore[
    match(rows$Score, artifact$response$score_map$OriginalScore)
  ]
  reversed_score <- mfrmr:::mfrmr_score_calibration(
    reversed, reversed_rows, weight = "Weight", interval_level = 0.84
  )
  expect_equal(
    g4_sorted_numeric_score(reversed_score), baseline_numeric,
    tolerance = 5e-14
  )
  expect_false(identical(
    reversed_score$settings$score_map, baseline$settings$score_map
  ))

  renamed <- artifact
  replacements <- c(
    Judge_A = "判定者_甲", Judge_B = "判定者_乙",
    Judge_C = "判定者_丙", Judge_D = "判定者_丁"
  )
  level_rows <- renamed$model$facet_levels$Facet == "Rater"
  renamed$model$facet_levels$Level[level_rows] <-
    unname(replacements[renamed$model$facet_levels$Level[level_rows]])
  coordinate_rows <- renamed$parameters$coordinates$ParameterClass == "facet" &
    renamed$parameters$coordinates$OwnerFacet == "Rater"
  renamed$parameters$coordinates$Level[coordinate_rows] <-
    unname(replacements[renamed$parameters$coordinates$Level[coordinate_rows]])
  renamed$integrity$semantic_components <-
    mfrmr:::mfrmr_calibration_semantic_components(renamed)
  renamed_rows <- rows
  renamed_rows$Rater <- unname(replacements[renamed_rows$Rater])
  renamed_score <- mfrmr:::mfrmr_score_calibration(
    renamed, renamed_rows, weight = "Weight", interval_level = 0.84
  )
  expect_equal(
    g4_sorted_numeric_score(renamed_score), baseline_numeric,
    tolerance = 5e-14
  )
  expect_false(identical(
    renamed_score$settings$semantic_components,
    baseline$settings$semantic_components
  ))
})

test_that("order chunk locale encoding and fresh process preserve scores", {
  ctx <- load_fixed_calibration_g4_contract()
  fixture <- g4_confirmation_fixture("PCM")
  artifact <- fixture$frozen
  rows <- fixture$confirmation
  baseline <- mfrmr:::mfrmr_score_calibration(
    artifact, rows, weight = "Weight", interval_level = 0.84
  )
  baseline_numeric <- g4_sorted_numeric_score(baseline)

  reversed <- mfrmr:::mfrmr_score_calibration(
    artifact, rows[rev(seq_len(nrow(rows))), , drop = FALSE],
    weight = "Weight", interval_level = 0.84
  )
  expect_equal(g4_sorted_numeric_score(reversed), baseline_numeric,
               tolerance = 5e-14)

  chunks <- split(rows, rows$Person)
  chunk_estimates <- do.call(rbind, lapply(rev(chunks), function(chunk) {
    mfrmr:::mfrmr_score_calibration(
      artifact, chunk, weight = "Weight", interval_level = 0.84
    )$estimates
  }))
  chunk_estimates <- chunk_estimates[order(chunk_estimates$Person),
                                     names(baseline_numeric), drop = FALSE]
  rownames(chunk_estimates) <- NULL
  expect_equal(chunk_estimates, baseline_numeric, tolerance = 5e-14)

  old_collate <- Sys.getlocale("LC_COLLATE")
  on.exit(suppressWarnings(Sys.setlocale("LC_COLLATE", old_collate)), add = TRUE)
  expect_identical(Sys.setlocale("LC_COLLATE", "C"), "C")
  c_locale <- mfrmr:::mfrmr_score_calibration(
    artifact, rows, weight = "Weight", interval_level = 0.84
  )
  expect_equal(g4_sorted_numeric_score(c_locale), baseline_numeric,
               tolerance = 5e-14)
  suppressWarnings(Sys.setlocale("LC_COLLATE", old_collate))

  utf8_rows <- rows
  utf8_rows$Person <- enc2utf8(utf8_rows$Person)
  utf8_rows$Rater <- enc2utf8(utf8_rows$Rater)
  utf8_rows$Criterion <- enc2utf8(utf8_rows$Criterion)
  artifact_path <- tempfile(fileext = ".rds")
  input_path <- tempfile(fileext = ".rds")
  output_path <- tempfile(fileext = ".rds")
  unlink(output_path)
  on.exit(unlink(c(artifact_path, input_path, output_path)), add = TRUE)
  mfrmr:::mfrmr_save_calibration(artifact, artifact_path)
  saveRDS(utf8_rows, input_path, version = 3)
  restored <- mfrmr:::mfrmr_load_calibration(artifact_path)
  restored_rows <- readRDS(input_path)
  roundtrip <- mfrmr:::mfrmr_score_calibration(
    restored, restored_rows, weight = "Weight", interval_level = 0.84
  )
  expect_equal(g4_sorted_numeric_score(roundtrip), baseline_numeric,
               tolerance = 5e-14)

  worker <- file.path(
    ctx$validation, "fixed-calibration-g4-confirmation-worker-0.2.4.R"
  )
  rscript <- file.path(R.home("bin"), "Rscript")
  if (.Platform$OS.type == "windows") rscript <- paste0(rscript, ".exe")
  status <- suppressWarnings(system2(
    rscript,
    c("--vanilla", worker, ctx$root, artifact_path, input_path,
      output_path, "C"),
    stdout = TRUE, stderr = TRUE
  ))
  process_status <- attr(status, "status")
  if (is.null(process_status)) process_status <- 0L
  if (!identical(process_status, 0L)) {
    testthat::fail(paste(status, collapse = "\n"))
    return(invisible(NULL))
  }
  child <- readRDS(output_path)
  expect_identical(child$status, "pass")
  expected_load_mode <- if (nzchar(Sys.getenv(
    "MFRMR_G4_INSTALLED_LIBRARY", unset = ""
  ))) "installed_library" else "source_tree"
  expect_identical(child$load_mode, expected_load_mode)
  expect_false(child$fit_present)
  expect_false(child$source_data_present)
  expect_false(child$rng_state_present)
  expect_identical(child$semantic_components,
                   artifact$integrity$semantic_components)
  child_numeric <- child$estimates[order(child$estimates$Person),
                                   names(baseline_numeric), drop = FALSE]
  rownames(child_numeric) <- NULL
  expect_equal(child_numeric, baseline_numeric, tolerance = 1e-12)
})

test_that("prior mutation refuses and independent sensitivity remains separate", {
  ctx <- load_fixed_calibration_g4_contract()
  rules <- ctx$env$mfrmr_fc_g4_numerical_rules()
  review_threshold <- rules$Threshold[
    rules$RuleId == "PRIOR_SENSITIVITY_REVIEW"
  ]
  fixture <- g4_confirmation_fixture("RSM")
  artifact <- fixture$frozen
  rows <- fixture$confirmation
  altered <- artifact
  altered$scoring_basis$prior_sd <- 1.5
  altered$integrity$semantic_components <-
    mfrmr:::mfrmr_calibration_semantic_components(altered)
  expect_identical(
    g4_capture_calibration_error(
      mfrmr:::mfrmr_score_calibration(altered, rows, weight = "Weight")
    )$code,
    "SCORING_PRIOR_INVALID"
  )

  baseline <- g4_independent_oracle(artifact, rows, node_scale = 1)$estimates
  narrow <- g4_independent_oracle(artifact, rows, node_scale = 0.7)$estimates
  wide <- g4_independent_oracle(artifact, rows, node_scale = 1.5)$estimates
  sensitivity <- max(
    abs(narrow$Estimate - baseline$Estimate),
    abs(wide$Estimate - baseline$Estimate)
  )
  expect_true(is.finite(sensitivity))
  expect_gte(sensitivity, review_threshold)
  score <- mfrmr:::mfrmr_score_calibration(artifact, rows, weight = "Weight")
  expect_true(all(
    score$person_dispositions$PriorSensitivityStatus ==
      "not_evaluated_fixed_basis"
  ))
})

test_that("corrupt coordinate persistence fails closed under the disjoint ID", {
  artifact <- g4_confirmation_fixture("PCM")$frozen
  corrupt <- artifact
  corrupt$parameters$coordinates$Value[1] <-
    corrupt$parameters$coordinates$Value[1] + 0.125
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(corrupt, path, version = 3)
  error <- g4_capture_calibration_error(
    mfrmr:::mfrmr_load_calibration(path)
  )
  expect_s3_class(error, "mfrm_calibration_error")
  expect_identical(error$code, "IDENTITY_COMPONENT_MISMATCH")
})

test_that("artifact and scoring resources stay under prospectively frozen ceilings", {
  ctx <- load_fixed_calibration_g4_contract()
  budgets <- ctx$env$mfrmr_fc_g4_resource_budgets()
  fixture <- g4_confirmation_fixture("RSM")
  artifact <- fixture$frozen
  artifact_bytes <- length(serialize(artifact, NULL, version = 3))
  template <- fixture$confirmation[
    fixture$confirmation$Person == fixture$confirmation$Person[1],
    c("Person", "Rater", "Criterion", "Score", "Weight"), drop = FALSE
  ]

  for (i in seq_len(nrow(budgets))) {
    rows <- template[rep(seq_len(nrow(template)), budgets$Persons[i]), , drop = FALSE]
    rows$Person <- rep(
      sprintf("G4OP%05d", seq_len(budgets$Persons[i])),
      each = nrow(template)
    )
    rownames(rows) <- NULL
    observation <- g4_profile_score(artifact, rows)
    expect_identical(nrow(rows), budgets$Rows[i])
    expect_lte(artifact_bytes, budgets$MaxArtifactBytes[i])
    expect_lte(observation$elapsed, budgets$MaxElapsedSeconds[i])
    expect_lte(observation$allocated,
               budgets$MaxProfiledAllocationBytes[i])
    expect_lte(observation$result_bytes,
               budgets$MaxSerializedResultBytes[i])
    expect_identical(nrow(observation$result$estimates), budgets$Persons[i])
  }
})

test_that("G4 contract source is prospective and non-executing", {
  ctx <- load_fixed_calibration_g4_contract()
  source <- paste(readLines(ctx$script, warn = FALSE), collapse = "\n")
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("mfrmr_score_calibration\\s*\\(", source, perl = TRUE))
  expect_false(grepl("saveRDS\\s*\\(|readRDS\\s*\\(", source, perl = TRUE))
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
})

test_that("macOS gates standard checks while legacy v5 issuance is disabled", {
  ctx <- load_fixed_calibration_g4_contract()
  workflow_path <- file.path(
    ctx$root, ".github", "workflows", "R-CMD-check.yaml"
  )
  cell_path <- file.path(
    ctx$root, ".github", "workflows", "R-CMD-check-cell.yaml"
  )
  expect_true(file.exists(workflow_path))
  expect_true(file.exists(cell_path))

  workflow <- paste(readLines(workflow_path, warn = FALSE), collapse = "\n")
  cell <- paste(readLines(cell_path, warn = FALSE), collapse = "\n")
  worker <- paste(readLines(file.path(
    ctx$validation, "fixed-calibration-g4-confirmation-worker-0.2.4.R"
  ), warn = FALSE), collapse = "\n")
  runner_path <- file.path(
    ctx$validation, "fixed-calibration-g4-hosted-runner-0.2.4.R"
  )
  runner <- paste(readLines(runner_path, warn = FALSE), collapse = "\n")
  release_runner <- paste(readLines(file.path(
    ctx$validation, "release-check-runner-0.2.4.R"
  ), warn = FALSE), collapse = "\n")
  expect_match(workflow, "permissions:\n  contents: read", fixed = TRUE)
  expect_match(workflow, "  macos-release:", fixed = TRUE)
  expect_match(
    workflow, "    name: macos-latest (release) prerequisite", fixed = TRUE
  )
  expect_match(workflow, "      os: macos-latest", fixed = TRUE)
  expect_match(workflow, "      r: release", fixed = TRUE)
  expect_match(workflow, "    needs: macos-release", fixed = TRUE)
  expect_identical(
    lengths(regmatches(
      workflow,
      gregexpr(
        "uses: ./.github/workflows/R-CMD-check-cell.yaml",
        workflow,
        fixed = TRUE
      )
    )),
    2L
  )
  expect_false(grepl("- {os: macos-latest", workflow, fixed = TRUE))
  expect_match(workflow, "id: windows-release", fixed = TRUE)
  expect_match(workflow, "id: ubuntu-devel", fixed = TRUE)
  expect_match(workflow, "id: ubuntu-release", fixed = TRUE)
  expect_match(workflow, "id: ubuntu-oldrel-1", fixed = TRUE)
  expect_match(workflow, "post-maintenance successor contract", fixed = TRUE)
  expect_false(grepl("  g4-hosted-matrix:", workflow, fixed = TRUE))
  expect_false(grepl(
    "Aggregate five bound G4 receipts", workflow, fixed = TRUE
  ))

  expect_match(cell, "  workflow_call:", fixed = TRUE)
  expect_match(cell, "          fetch-depth: 0", fixed = TRUE)
  expect_match(cell, "Exact source-tarball R CMD check (G4 confirmation held)",
               fixed = TRUE)
  expect_match(
    cell, "release-check-runner-0.2.4.R", fixed = TRUE
  )
  expect_match(cell, "MFRMR_CHECK_ERROR_ON: warning", fixed = TRUE)
  expect_match(cell, "Repository validation review", fixed = TRUE)
  expect_match(
    cell, "mfrmr_fc_g4m_review", fixed = TRUE
  )
  expect_match(
    cell, "G6 and public", fixed = TRUE
  )
  expect_match(cell, "API remain unauthorized", fixed = TRUE)
  expect_false(grepl("pkgload::load_all", cell, fixed = TRUE))
  expect_false(grepl("Upload bound G4 cell receipt", cell, fixed = TRUE))
  expect_false(grepl("hosted-cell-receipt.rds", cell, fixed = TRUE))
  expect_false(grepl(
    "fixed-calibration-g4-hosted-runner-0.2.4.R", cell, fixed = TRUE
  ))
  expect_match(release_runner, "pkgbuild::build(", fixed = TRUE)
  expect_match(release_runner, "rcmdcheck::rcmdcheck(", fixed = TRUE)
  expect_match(release_runner, "G4EvidenceIssued = FALSE", fixed = TRUE)
  expect_match(
    release_runner, 'EvidenceRole = "package_check_only"', fixed = TRUE
  )
  expect_match(worker, "winslash = \"/\"", fixed = TRUE)
  expect_match(worker, "tolower(loaded_library_path)", fixed = TRUE)
  expect_match(
    worker, "MFRMR_G4_DEPENDENCY_LIBRARIES", fixed = TRUE
  )
  expect_match(worker, ".Platform$path.sep", fixed = TRUE)
  expect_match(runner, "pkgbuild::build(", fixed = TRUE)
  expect_match(runner, "rcmdcheck::rcmdcheck(", fixed = TRUE)
  expect_match(runner, "path = tarball", fixed = TRUE)
  expect_match(runner, "error_on = \"warning\"", fixed = TRUE)
  expect_match(runner, "Sys.setenv(R_LIBS =", fixed = TRUE)
  expect_match(runner, "collapse = .Platform$path.sep", fixed = TRUE)
  expect_match(
    runner, "MFRMR_G4_DEPENDENCY_LIBRARIES = paste(", fixed = TRUE
  )
  installed_binding <- regexpr(
    "Sys.setenv(MFRMR_G4_INSTALLED_LIBRARY = installed_library)",
    runner, fixed = TRUE
  )[[1L]]
  static_execution <- regexpr(
    "static <- mfrmr_fc_g4h_test_installed_evidence(", runner, fixed = TRUE
  )[[1L]]
  expect_gt(installed_binding, 0L)
  expect_gt(static_execution, installed_binding)
  expect_match(runner, "hosted-cell-receipt.rds", fixed = TRUE)
  expect_match(runner, "HostedPlatformMatrixComplete = TRUE", fixed = TRUE)
  expect_match(runner, "G6Authorized = FALSE", fixed = TRUE)
  expect_match(runner, "PublicAPIAuthorized = FALSE", fixed = TRUE)
  expect_false(grepl("serialize = TRUE", runner, fixed = TRUE))

  binding <- load_fixed_calibration_g4_candidate_binding()
  runner_env <- new.env(parent = globalenv())
  sys.source(runner_path, envir = runner_env)
  gate_names <- c(
    "version_contract", "source_truth", "candidate_identity",
    "gate_results", "public_scope", "claim_disposition",
    "evidence_counts", "package_check", "check_timing", "example_policy",
    "release_evidence_freshness", "ci_workflow", "terminology",
    "evidence_artifacts"
  )
  release_only <- c(
    "version_contract", "claim_disposition", "package_check", "check_timing"
  )
  readiness <- list(
    gate_summary = data.frame(
      Gate = gate_names,
      Status = ifelse(gate_names %in% release_only, "concern", "ok"),
      stringsAsFactors = FALSE
    ),
    check_status = data.frame(
      CheckPassed = TRUE, StatusPresent = TRUE,
      VersionMatchesTarget = TRUE, AsCRAN = FALSE,
      ManualChecked = FALSE, RunDonttest = FALSE
    )
  )
  review <- runner_env$mfrmr_fc_g4h_repository_review(
    list(Preflight = binding$env), readiness
  )
  expect_true(review$G4RepositoryScopeComplete)
  expect_false(review$G6Authorized)
  expect_false(review$PublicAPIAuthorized)
  expect_identical(nrow(review$RequiredGates), 8L)
  bad_gate <- readiness
  bad_gate$gate_summary$Status[
    bad_gate$gate_summary$Gate == "terminology"
  ] <- "concern"
  expect_error(
    runner_env$mfrmr_fc_g4h_repository_review(
      list(Preflight = binding$env), bad_gate
    ),
    "required for hosted G4 evidence", fixed = TRUE
  )
  bad_check <- readiness
  bad_check$check_status$CheckPassed <- FALSE
  expect_error(
    runner_env$mfrmr_fc_g4h_repository_review(
      list(Preflight = binding$env), bad_check
    ),
    "package check is not successful", fixed = TRUE
  )

  protocol <- new.env(parent = globalenv())
  source(
    file.path(ctx$validation, "release-readiness.R"),
    local = protocol
  )
  status <- protocol$mfrmr_release_readiness_ci_workflow_status(workflow_path)
  expect_true(status$CIWorkflowOK)
  expect_true(status$LegacyG4AutomaticIssuanceAbsent)
})

test_that("hosted post-receipt review failure remains below matrix completion", {
  ctx <- load_fixed_calibration_g4_current_contract()
  path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32821105381-record-0.2.4.md"
  )
  expect_true(file.exists(path))
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(record, "`HostedCurrentWorkerInvoked=TRUE`", fixed = TRUE)
  expect_match(record, "`PassedCells=49`", fixed = TRUE)
  expect_match(record, "`FailedCells=0`", fixed = TRUE)
  expect_match(record, "`ResourceScalesPassed=3`", fixed = TRUE)
  expect_match(record, "`HostedCellReceiptCreated=TRUE`", fixed = TRUE)
  expect_match(record, "`HostedPlatformMatrixComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`V4NumericalIdentityChanged=FALSE`", fixed = TRUE)
})

test_that("historical reopening is retained while v5 closes current-source G4", {
  ctx <- load_fixed_calibration_g4_contract()
  record_path <- file.path(
    ctx$validation, "fixed-calibration-g4-evidence-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  macos_record_path <- file.path(
    ctx$validation, "fixed-calibration-g4-macos-record-0.2.4.md"
  )
  expect_true(file.exists(macos_record_path))
  macos_record <- paste(
    readLines(macos_record_path, warn = FALSE), collapse = "\n"
  )
  hardening_record_path <- file.path(
    ctx$validation, "fixed-calibration-boundary-hardening-0.2.4.md"
  )
  expect_true(file.exists(hardening_record_path))
  hardening_record <- paste(
    readLines(hardening_record_path, warn = FALSE), collapse = "\n"
  )
  current_record_path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32832244619-record-0.2.4.md"
  )
  expect_true(file.exists(current_record_path))
  current_record <- paste(
    readLines(current_record_path, warn = FALSE), collapse = "\n"
  )
  expect_match(record, ctx$env$mfrmr_fc_g4_specification, fixed = TRUE)
  expect_match(record, "`CORE05Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`CORE06Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=TRUE`", fixed = TRUE)
  expect_match(
    record, "`MacOSReleaseNativePreflightComplete=TRUE`", fixed = TRUE
  )
  expect_match(
    record, "`MacOSReleaseWorkflowComplete=TRUE`", fixed = TRUE
  )
  expect_match(record, "`RemainingRequiredWorkflowCells=0`", fixed = TRUE)
  expect_match(record, "`HostedWorkflowRun=32534030853`", fixed = TRUE)
  expect_match(
    record,
    "`HostedWorkflowCommit=f492fb9f0ee977777d03f0255de008af33860db5`",
    fixed = TRUE
  )
  expect_match(
    record, "`HostedWorkflowRequiredCellsPassed=5`", fixed = TRUE
  )
  expect_match(
    record, "`HostedWindowsPathHarnessAttemptRetained=TRUE`", fixed = TRUE
  )
  expect_match(record, "`PublicAPIAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`OptionalLaneAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    record, "`NextGate=G5-optional-lane-qualification`", fixed = TRUE
  )
  expect_match(
    macos_record, "`MacOSReleaseNativePreflightComplete=TRUE`", fixed = TRUE
  )
  expect_match(
    macos_record, "`MacOSReleaseWorkflowComplete=TRUE`", fixed = TRUE
  )
  expect_match(
    macos_record, "`RemainingRequiredWorkflowCells=0`", fixed = TRUE
  )
  expect_match(
    macos_record, "`HostedMacOSAttempt1Retained=TRUE`", fixed = TRUE
  )
  expect_match(
    macos_record, "`HostedMacOSAttempt1DenominatorOpened=FALSE`", fixed = TRUE
  )
  expect_match(
    hardening_record, "`HistoricalG4CurrentSourceEvidence=FALSE`", fixed = TRUE
  )
  expect_match(hardening_record, "`CORE05Complete=TRUE`", fixed = TRUE)
  expect_match(hardening_record, "`CORE06Complete=TRUE`", fixed = TRUE)
  expect_match(hardening_record, "`G4ExitComplete=TRUE`", fixed = TRUE)
  expect_match(
    current_record,
    "`HostedWorkflowConclusion=success`", fixed = TRUE
  )
  expect_match(current_record, "`HostedPlatformCells=5`", fixed = TRUE)
  expect_match(
    current_record, "`CompleteHostedPlatformCells=5`", fixed = TRUE
  )
  expect_match(
    current_record, "`EachPlatformPassedCells=49`", fixed = TRUE
  )
  expect_match(
    current_record, "`EachPlatformResourceScalesPassed=3`", fixed = TRUE
  )
  expect_match(current_record, "`AllReceiptHashesValid=TRUE`", fixed = TRUE)
  expect_match(current_record, "`HostedMatrixHashValid=TRUE`", fixed = TRUE)
  expect_match(current_record, "`CORE05Complete=TRUE`", fixed = TRUE)
  expect_match(current_record, "`CORE06Complete=TRUE`", fixed = TRUE)
  expect_match(current_record, "`G4ExitComplete=TRUE`", fixed = TRUE)
  expect_match(current_record, "`G6Authorized=FALSE`", fixed = TRUE)
  expect_match(current_record, "`PublicAPIAuthorized=FALSE`", fixed = TRUE)
})

test_that("post-maintenance G4 admission binds 0.2.3.1 and stays closed", {
  admission <- load_fixed_calibration_g4_maintenance_admission()
  review <- admission$env$mfrmr_fc_g4m_review(admission$root)
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  current <- transition$env$mfrmr_rc04_review(transition$root)

  expect_identical(
    review$Contract,
    "mfrmr_fixed_calibration_g4_maintenance_admission_v2_lifecycle_aware"
  )
  expect_identical(
    review$Status,
    "maintenance_bridge_complete_v6_contract_frozen_execution_required"
  )
  expect_identical(current$Metadata$Stage, "development")
  expect_identical(review$MetadataStage, "development")
  expect_true(review$DevelopmentMetadataAligned)
  expect_false(review$CandidateMetadataAligned)
  expect_true(review$ReleaseMetadataAligned)
  expect_true(review$MaintenanceBridgeComplete)
  expect_false(current$Metadata$CandidateMetadataOK)
  expect_false(current$ChangedPathsAllowed)
  expect_false(current$CandidateReady)
  expect_true(current$G6DecisionBound)
  expect_true(review$RequiredPathsPresent)
  expect_true(review$PublicBaselineMatched)
  expect_true(all(review$IntegratedCommitsAreAncestors))
  expect_true(review$CompiledHeaderOverrideAbsent)
  expect_length(review$InvalidDocumentationTargets, 0L)
  expect_true(review$V5ExactSourceChanged)
  expect_true(review$V5EvidenceRetainedAsHistorical)
  expect_true(review$LegacyV5AutomaticIssuanceDisabled)
  expect_true(review$V6SourceBoundaryFrozen)
  expect_true(review$V6ConfirmationContractFrozen)
  expect_false(review$PostMaintenanceG4Complete)
  expect_false(review$G6Authorized)
  expect_setequal(
    review$ProductionBoundary$Path,
    c(
      "R/core-fixed-calibration.R", "R/api-prediction.R",
      "R/api-reference-benchmark.R", "R/api-export-bundles.R",
      "R/core-optimizer.R", "DESCRIPTION", "src/mml_backend.cpp",
      "src/cpp11.cpp"
    )
  )
})

test_that("maintenance admission distinguishes development and candidate metadata", {
  admission <- load_fixed_calibration_g4_maintenance_admission()
  make_description <- function(version, status, public_version, date = NULL) {
    fields <- c(
      Version = version,
      `Config/mfrmr/release-status` = status,
      `Config/mfrmr/public-version` = public_version
    )
    if (!is.null(date)) fields <- c(fields, Date = date)
    matrix(fields, nrow = 1L, dimnames = list(NULL, names(fields)))
  }

  development <- admission$env$mfrmr_fc_g4m_release_metadata_status(
    make_description("0.2.4.9000", "development", "0.2.3.1")
  )
  expect_identical(development$Stage, "development")
  expect_true(development$DevelopmentMetadataAligned)
  expect_false(development$CandidateMetadataAligned)
  expect_true(development$ReleaseMetadataAligned)

  candidate <- admission$env$mfrmr_fc_g4m_release_metadata_status(
    make_description("0.2.4", "candidate", "0.2.3.1", "2026-08-26")
  )
  expect_identical(candidate$Stage, "candidate")
  expect_false(candidate$DevelopmentMetadataAligned)
  expect_true(candidate$CandidateMetadataAligned)
  expect_true(candidate$ReleaseMetadataAligned)

  for (invalid in list(
    make_description("0.2.4", "candidate", "0.2.3.1"),
    make_description("0.2.4", "candidate", "0.2.3", "2026-08-26"),
    make_description("0.2.4.9000", "candidate", "0.2.3.1", "2026-08-26"),
    make_description("0.2.4", "released", "0.2.4", "2026-08-26")
  )) {
    status <- admission$env$mfrmr_fc_g4m_release_metadata_status(invalid)
    expect_identical(status$Stage, "invalid")
    expect_false(status$ReleaseMetadataAligned)
  }
})

test_that("post-maintenance v6 execution closes G4 only for its bound core", {
  ctx <- load_fixed_calibration_g4_contract()
  path <- file.path(
    ctx$validation,
    "fixed-calibration-g4-hosted-run-32877939836-record-0.2.4.md"
  )
  expect_true(file.exists(path))
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")

  expect_match(
    record,
    "`0aac54600062cdf5ad4a1aba699b48f1818888bc`",
    fixed = TRUE
  )
  expect_match(record, "`HostedWorkflowConclusion=success`", fixed = TRUE)
  expect_match(record, "`HostedPlatformCells=5`", fixed = TRUE)
  expect_match(record, "`CompleteHostedPlatformCells=5`", fixed = TRUE)
  expect_match(record, "`EachPlatformDenominatorCells=49`", fixed = TRUE)
  expect_match(record, "`EachPlatformPassedCells=49`", fixed = TRUE)
  expect_match(record, "`EachPlatformFailedCells=0`", fixed = TRUE)
  expect_match(
    record, "`EachPlatformResourceScalesPassed=3`", fixed = TRUE
  )
  expect_match(record, "`AllReceiptHashesValid=TRUE`", fixed = TRUE)
  expect_match(record, "`HostedMatrixHashValid=TRUE`", fixed = TRUE)
  expect_match(record, "`CORE05Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`CORE06Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=TRUE`", fixed = TRUE)
  expect_match(record, "`G6Authorized=FALSE`", fixed = TRUE)
  expect_match(record, "`PublicAPIAuthorized=FALSE`", fixed = TRUE)
})

test_that("G6 public-surface slice closes CORE-07 before final decision", {
  ctx <- load_fixed_calibration_g4_contract()
  path <- file.path(
    ctx$validation,
    "fixed-calibration-g6-public-surface-record-0.2.4.md"
  )
  expect_true(file.exists(path))
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")
  roadmap <- paste(
    readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(record, "`PublicWrapperParityComplete=TRUE`", fixed = TRUE)
  expect_match(record, "`PublicCapabilityRows=6`", fixed = TRUE)
  expect_match(record, "`PortableAvailableRows=2`", fixed = TRUE)
  expect_match(record, "`PortableUnavailableRows=4`", fixed = TRUE)
  expect_match(
    record, "`FreshSessionPublicAPIScoringComplete=TRUE`", fixed = TRUE
  )
  expect_match(record, "`PublicVignetteRendered=TRUE`", fixed = TRUE)
  expect_match(record, "`PublicOutputGuideIntegrated=TRUE`", fixed = TRUE)
  expect_match(record, "`PublicExtractionMessagesClean=TRUE`", fixed = TRUE)
  expect_match(record, "`PackageMetadataAligned=TRUE`", fixed = TRUE)
  expect_match(record, "`WebsiteBuiltAndReviewed=TRUE`", fixed = TRUE)
  expect_match(record, "`LocalSourceCheckStatus=OK`", fixed = TRUE)
  expect_match(record, "`DistributedTestPasses=435`", fixed = TRUE)
  expect_match(record, "`DistributedTestFailures=0`", fixed = TRUE)
  expect_match(record, "`NoGoAuditComplete=TRUE`", fixed = TRUE)
  expect_match(
    record, "`StepAnchorPublicConstructionResolved=TRUE`", fixed = TRUE
  )
  expect_match(
    record, "`StepAnchorPublicConstructionAvailable=FALSE`", fixed = TRUE
  )
  expect_match(record, "`CORE07Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`CORE08Complete=FALSE`", fixed = TRUE)
  expect_match(record, "`G6ExitComplete=FALSE`", fixed = TRUE)
  expect_match(
    record, "`PublicAPIAuthorizedForRelease=FALSE`", fixed = TRUE
  )
  expect_match(roadmap, "## What 0.2.4 is intended to support", fixed = TRUE)
  expect_match(roadmap, "explicit rejection of incompatible data", fixed = TRUE)
  expect_match(roadmap, "Portable GPCM calibration is not part of 0.2.4",
               fixed = TRUE)

  pkgdown <- file.path(ctx$root, "_pkgdown.yml")
  expect_true(file.exists(pkgdown))
  pkgdown_text <- paste(readLines(pkgdown, warn = FALSE), collapse = "\n")
  expect_match(pkgdown_text, "mfrm_calibration_workflow", fixed = TRUE)

  surface_paths <- c(
    "README.md", "NEWS.md", "vignettes/mfrmr-portable-calibration.Rmd",
    "man/mfrm_calibration_workflow.Rd",
    "man/mfrm_calibration_capabilities.Rd", "man/mfrmr_output_guide.Rd",
    "man/mfrmr-package.Rd", "_pkgdown.yml"
  )
  expect_true(all(file.exists(file.path(ctx$root, surface_paths))))
  surface_text <- lapply(surface_paths, function(path) {
    paste(readLines(file.path(ctx$root, path), warn = FALSE), collapse = "\n")
  })
  names(surface_text) <- surface_paths
  core_surfaces <- surface_text[c(
    "README.md", "vignettes/mfrmr-portable-calibration.Rmd",
    "man/mfrm_calibration_workflow.Rd", "man/mfrmr-package.Rd"
  )]
  for (surface in core_surfaces) {
    expect_match(surface, "RSM", fixed = TRUE)
    expect_match(surface, "PCM", fixed = TRUE)
    expect_match(surface, "MML", fixed = TRUE)
    expect_match(surface, "fixed\\s+standard-normal", perl = TRUE)
    expect_match(surface, "GPCM", fixed = TRUE)
    expect_match(surface, "JML", fixed = TRUE)
  }
  expect_match(
    surface_text$README.md,
    "mfrm_calibration_capabilities()",
    fixed = TRUE
  )
  expect_match(
    surface_text[["vignettes/mfrmr-portable-calibration.Rmd"]],
    "score_mfrm_calibration(calibration, new_rows)",
    fixed = TRUE
  )
  expect_match(
    surface_text[["man/mfrmr_output_guide.Rd"]],
    "mfrmr_output_guide(\"calibration\")",
    fixed = TRUE
  )
  public_text <- paste(
    unlist(surface_text, use.names = FALSE), collapse = "\n"
  )
  expect_false(grepl(
    "mfrmr:::|CORE-[0-9]|G[0-6] exit|PublicAPIAuthorized",
    public_text,
    perl = TRUE
  ))
})

test_that("G6 final decision binds the successful matrix and bounded scope", {
  ctx <- load_fixed_calibration_g4_contract()
  path <- file.path(
    ctx$validation,
    "fixed-calibration-g6-release-decision-record-0.2.4.md"
  )
  expect_true(file.exists(path))
  record <- paste(readLines(path, warn = FALSE), collapse = "\n")
  roadmap <- paste(
    readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE),
    collapse = "\n"
  )

  expect_match(
    record,
    "`ValidatedPayloadCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f`",
    fixed = TRUE
  )
  expect_match(record, "`HostedRunId=32906087561`", fixed = TRUE)
  expect_match(record, "`HostedWorkflowConclusion=success`", fixed = TRUE)
  expect_match(record, "`HostedPlatformCells=5`", fixed = TRUE)
  expect_match(record, "`HostedPassedCells=5`", fixed = TRUE)
  expect_match(record, "`HostedFailedCells=0`", fixed = TRUE)
  expect_match(record, "`CheckArtifactCount=5`", fixed = TRUE)
  expect_match(record, "`UnexpectedG4ArtifactCount=0`", fixed = TRUE)
  expect_match(record, "`PriorFailedHostedRuns=2`", fixed = TRUE)
  expect_match(
    record,
    "`PriorFailedHostedRunIds=32894811905,32900730800`",
    fixed = TRUE
  )
  expect_match(
    record,
    paste0(
      "`LocalSourceTarballSHA256=",
      "c93983d677739d8658b7c64c37b4da3062ed4ca8a5dc9884d37cf3d5bd788963`"
    ),
    fixed = TRUE
  )
  expect_match(
    record, "`RepositoryDecisionExpectationsPassed=530`", fixed = TRUE
  )
  expect_match(record, "`DecisionFilesRbuildExcluded=TRUE`", fixed = TRUE)
  expect_match(
    record,
    "`PostDecisionPayloadDiff=DESCRIPTION_PACKAGED_TIMESTAMP_ONLY`",
    fixed = TRUE
  )
  expect_match(record, "`PublicPredecessorVersion=0.2.3.1`", fixed = TRUE)
  expect_match(
    record,
    paste0(
      "`PublicPredecessorSHA256=",
      "d3d2b00638fcbd8407dfabd5206eb670b2a3470e0e30e0079ca64a2e7a77b67a`"
    ),
    fixed = TRUE
  )
  expect_match(record, "`ReverseDepends=0`", fixed = TRUE)
  expect_match(record, "`ReverseImports=0`", fixed = TRUE)
  expect_match(record, "`ReverseLinkingTo=0`", fixed = TRUE)
  expect_match(record, "`ReverseSuggests=0`", fixed = TRUE)
  expect_match(record, "`ReverseEnhances=0`", fixed = TRUE)
  expect_match(
    record, "`ReverseDependencyReviewComplete=TRUE`", fixed = TRUE
  )
  expect_match(record, "`NoGoAuditComplete=TRUE`", fixed = TRUE)
  expect_match(record, "`CORE07Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`CORE08Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`G6ExitComplete=TRUE`", fixed = TRUE)
  expect_match(
    record, "`PublicAPIAuthorizedForRelease=TRUE`", fixed = TRUE
  )
  expect_match(record, "`CRANSubmissionPerformed=FALSE`", fixed = TRUE)

  expect_match(
    roadmap,
    "mfrmr 0.2.4.9000 is under development and has not been released",
    fixed = TRUE
  )
  expect_match(roadmap, "## Not part of the 0.2.4 promise", fixed = TRUE)
  expect_false(grepl(
    "CORE-[0-9]|G[0-6] exit|candidate metadata|preflight|submission",
    roadmap,
    perl = TRUE,
    ignore.case = TRUE
  ))
})

test_that("internal strategic roadmap preserves the long-horizon decision axis", {
  ctx <- load_fixed_calibration_g4_contract()
  path <- file.path(
    ctx$validation,
    "mfrmr-internal-strategic-roadmap.html"
  )
  expect_true(file.exists(path))
  roadmap <- paste(readLines(path, warn = FALSE), collapse = "\n")

  for (section in c(
    "charter", "truth", "critical", "horizons", "research",
    "adversarial", "risks", "governance", "metrics", "queue"
  )) {
    expect_match(roadmap, paste0("id=\"", section, "\""), fixed = TRUE)
  }

  expect_match(
    roadmap,
    "同じ測定尺度を、意味を変えず、失敗を隠さず、独立に再現・保存・適用できること。",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "0.2.4 development: score UX / help / visual QA locally complete",
    fixed = TRUE
  )
  expect_match(roadmap, "CRAN submission: not performed", fixed = TRUE)
  expect_match(
    roadmap, "Public scope: RSM · PCM · MML · fixed N(0,1)", fixed = TRUE
  )
  expect_match(roadmap, "portable GPCM calibration", fixed = TRUE)
  expect_match(roadmap, "multivariate G-theory public support", fixed = TRUE)
  expect_match(roadmap, "public unsupported", fixed = TRUE)
  expect_match(roadmap, "今は行わない", fixed = TRUE)
  expect_match(roadmap, "停止条件", fixed = TRUE)
  expect_match(roadmap, "同時進行は release-critical 1本", fixed = TRUE)

  count_token <- function(token) {
    length(regmatches(roadmap, gregexpr(token, roadmap, fixed = TRUE))[[1L]])
  }
  expect_identical(count_token("data-state=\"done\""), 32L)
  expect_identical(count_token("data-state=\"open\""), 43L)
  expect_identical(count_token("data-state=\"hold\""), 6L)
  expect_identical(count_token("data-state=\"recurring\""), 13L)

  ignore <- readLines(file.path(ctx$root, ".Rbuildignore"), warn = FALSE)
  expect_true("^inst/validation$" %in% ignore)
  expect_true(
    "^tests/testthat/test-fixed-calibration-g4-evidence[.]R$" %in% ignore
  )
  inventory <- load_fixed_calibration_g4_candidate_inventory()
  expect_identical(
    inventory$env$mfrmr_fc_g4i_classify_path(
      "inst/validation/mfrmr-internal-strategic-roadmap.html"
    ),
    "release_build_test_and_repository_evidence"
  )

  public_paths <- c(
    "README.md", "NEWS.md", "_pkgdown.yml",
    "vignettes/mfrmr-portable-calibration.Rmd",
    "man/mfrm_calibration_workflow.Rd",
    "man/mfrm_calibration_capabilities.Rd",
    "man/mfrmr_output_guide.Rd", "man/mfrmr-package.Rd"
  )
  public_text <- paste(vapply(public_paths, function(public_path) {
    paste(
      readLines(file.path(ctx$root, public_path), warn = FALSE),
      collapse = "\n"
    )
  }, character(1)), collapse = "\n")
  expect_false(grepl(
    "mfrmr-internal-strategic-roadmap", public_text, fixed = TRUE
  ))
})

test_that("0.2.4 candidate transition admits metadata but refuses payload drift", {
  transition <- load_fixed_calibration_release_candidate_transition()
  contract <- transition$env$mfrmr_rc04_contract()
  review <- transition$env$mfrmr_rc04_review(transition$root)

  expect_identical(
    contract$ContractId, "mfrmr_release_candidate_transition_0_2_4_v1"
  )
  expect_identical(contract$TargetVersion, "0.2.4")
  expect_identical(contract$DevelopmentVersion, "0.2.4.9000")
  expect_identical(contract$PublicPredecessor, "0.2.3.1")
  expect_identical(
    contract$G6ValidatedCommit,
    "cf20dd0167db3f39224cea7d1c70998b1142f81f"
  )
  expect_identical(contract$G6HostedRunId, "32906087561")
  expect_identical(
    contract$ProductionChangePolicy,
    "invalidate_candidate_return_to_development_and_rerun_evidence"
  )
  expect_false(contract$SubmissionAuthorized)

  expect_true(review$G6BaselineAncestor)
  expect_true(review$G6DecisionBound)
  expect_true(review$Metadata$Stage %in% c("development", "candidate"))
  forbidden <- review$Inventory[
    review$Inventory$Classification == "package_payload_change_forbidden",
    , drop = FALSE
  ]
  if (nrow(forbidden) > 0L) {
    expect_false(review$Metadata$DevelopmentMetadataOK)
    expect_false(review$Metadata$MetadataTransitionOK)
    expect_false(review$ChangedPathsAllowed)
    expect_false(review$ProductionPayloadUnchanged)
    expect_false(review$DevelopmentTransitionReady)
    expect_false(review$CandidateReady)
    expect_true("tests/testthat/test-vignette-artifacts.R" %in% forbidden$Path)
  } else if (identical(review$Metadata$Stage, "development")) {
    expect_true(review$Metadata$MetadataTransitionOK)
    expect_true(review$ChangedPathsAllowed)
    expect_true(review$ProductionPayloadUnchanged)
    expect_true(review$Metadata$DevelopmentMetadataOK)
    expect_true(review$DevelopmentTransitionReady)
    expect_false(review$CandidateReady)
  } else {
    expect_true(review$Metadata$MetadataTransitionOK)
    expect_true(review$ChangedPathsAllowed)
    expect_true(review$ProductionPayloadUnchanged)
    expect_true(review$Metadata$CandidateMetadataOK)
    expect_false(review$DevelopmentTransitionReady)
  }
  expect_false(review$SubmissionAuthorized)

  classify <- transition$env$mfrmr_rc04_classify_path
  expect_identical(
    classify("DESCRIPTION"), "candidate_package_metadata"
  )
  expect_identical(classify("NEWS.md"), "candidate_package_metadata")
  expect_identical(
    classify("CITATION.cff"),
    "candidate_repository_metadata_or_internal_roadmap"
  )
  expect_identical(
    classify("inst/validation/candidate-record.md"),
    "candidate_internal_evidence"
  )
  expect_identical(
    classify("R/api-calibration.R"), "package_payload_change_forbidden"
  )
  expect_identical(
    classify("man/mfrm_calibration_workflow.Rd"),
    "package_payload_change_forbidden"
  )
  expect_identical(
    classify("vignettes/mfrmr-portable-calibration.Rmd"),
    "package_payload_change_forbidden"
  )
})

test_that("0.2.4 candidate metadata transition is exact and adversarial", {
  transition <- load_fixed_calibration_release_candidate_transition()
  env <- transition$env
  base <- env$mfrmr_rc04_contract()$G6ValidatedCommit
  baseline_description <- env$mfrmr_rc04_git_lines(
    transition$root, base, "DESCRIPTION"
  )
  baseline_cff <- env$mfrmr_rc04_git_lines(
    transition$root, base, "CITATION.cff"
  )
  baseline_news <- env$mfrmr_rc04_git_lines(
    transition$root, base, "NEWS.md"
  )

  candidate_description <- sub(
    "^Version: 0[.]2[.]4[.]9000$", "Version: 0.2.4",
    baseline_description
  )
  version_row <- which(candidate_description == "Version: 0.2.4")
  candidate_description <- append(
    candidate_description, "Date: 2026-08-26", after = version_row
  )
  candidate_description <- sub(
    "^Config/mfrmr/release-status: development$",
    "Config/mfrmr/release-status: candidate",
    candidate_description
  )
  candidate_cff <- sub(
    '^version: "0[.]2[.]4[.]9000"$', 'version: "0.2.4"', baseline_cff
  )
  cff_version_row <- which(candidate_cff == 'version: "0.2.4"')
  candidate_cff <- append(
    candidate_cff, 'date-released: "2026-08-26"',
    after = cff_version_row
  )
  candidate_news <- baseline_news
  candidate_news[grep("^# ", candidate_news)[1L]] <- "# mfrmr 0.2.4"
  candidate_cran <- c(
    "This is an update from mfrmr 0.2.3.1 to 0.2.4.",
    "Portable calibration supports RSM and PCM MML under a fixed-standard-normal basis.",
    "GPCM and JML portable-calibration routes are unavailable.",
    "Checks completed with 0 errors, 0 warnings, and 0 notes."
  )
  review_candidate <- function(
      description = candidate_description,
      cff = candidate_cff,
      news = candidate_news,
      cran = candidate_cran) {
    env$mfrmr_rc04_metadata_review(
      description_lines = description,
      cff_lines = cff,
      news_lines = news,
      cran_comments_lines = cran,
      baseline_description_lines = baseline_description,
      baseline_cff_lines = baseline_cff,
      baseline_news_lines = baseline_news
    )
  }

  candidate <- review_candidate()
  expect_identical(candidate$Stage, "candidate")
  expect_setequal(
    candidate$ChangedDescriptionFields,
    c("Version", "Date", "Config/mfrmr/release-status")
  )
  expect_true(candidate$DescriptionAllowedFieldsOnly)
  expect_true(candidate$CffAllowedFieldsOnly)
  expect_true(candidate$NewsBodyUnchanged)
  expect_true(candidate$CranCommentsReady)
  expect_true(all(candidate$CranCommentsReview$Matched))
  expect_true(candidate$CandidateMetadataOK)
  expect_true(candidate$MetadataTransitionOK)

  wrong_title <- sub(
    "^Title: ", "Title: Candidate ", candidate_description
  )
  title_review <- review_candidate(description = wrong_title)
  expect_false(title_review$DescriptionAllowedFieldsOnly)
  expect_false(title_review$CandidateMetadataOK)

  wrong_public <- sub(
    "^Config/mfrmr/public-version: 0[.]2[.]3[.]1$",
    "Config/mfrmr/public-version: 0.2.4",
    candidate_description
  )
  public_review <- review_candidate(description = wrong_public)
  expect_false(public_review$DescriptionAllowedFieldsOnly)
  expect_false(public_review$CandidateMetadataOK)

  news_review <- review_candidate(news = c(candidate_news, "Silent feature"))
  expect_false(news_review$NewsBodyUnchanged)
  expect_false(news_review$CandidateMetadataOK)

  cff_review <- review_candidate(cff = sub(
    '^title: ', 'title: "Changed ', candidate_cff
  ))
  expect_false(cff_review$CffAllowedFieldsOnly)
  expect_false(cff_review$CandidateMetadataOK)

  cran_review <- review_candidate(cran = candidate_cran[1:2])
  expect_false(cran_review$CranCommentsReady)
  expect_false(cran_review$CandidateMetadataOK)

  mismatched_date <- review_candidate(cff = sub(
    "2026-08-26", "2026-08-27", candidate_cff, fixed = TRUE
  ))
  expect_false(mismatched_date$CandidateMetadataOK)
})

test_that("0.2.4 transition record binds the clean contract review", {
  transition <- load_fixed_calibration_release_candidate_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-release-candidate-transition-record-0.2.4.md"
  )
  roadmap_path <- file.path(
    transition$validation, "mfrmr-internal-strategic-roadmap.html"
  )
  expect_true(file.exists(record_path))
  expect_true(file.exists(roadmap_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v1",
    "TransitionContractCommitSHA40=02c216100b1637036c486c0038625924cdd8a59f",
    "G6ValidatedCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f",
    "G6HostedRunId=32906087561",
    "ReviewBranch=development/0.2.4",
    "G6BaselineAncestor=TRUE",
    "WorkingTreeCleanAtReview=TRUE",
    "ChangedPathCount=6",
    "CandidatePackageMetadataPathCount=0",
    "CandidateRepositoryRoadmapPathCount=1",
    "CandidateInternalEvidencePathCount=5",
    "ForbiddenPayloadPathCount=0",
    "ChangedPathsAllowed=TRUE",
    "ProductionPayloadUnchanged=TRUE",
    "MetadataStage=development",
    "DevelopmentMetadataOK=TRUE",
    "DevelopmentTransitionReady=TRUE",
    "CandidateMetadataApplied=FALSE",
    "CandidateReady=FALSE",
    "CandidateTagCreated=FALSE",
    "CandidateChecksRun=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "ReleaseDiffAllowlistFrozen=TRUE",
    "NextAction=apply-0.2.4-candidate-metadata-under-frozen-allowlist"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
  expect_match(
    roadmap,
    '<div class="task" data-state="done" data-horizon="now" data-priority="p0">',
    fixed = TRUE
  )
  expect_match(
    roadmap, "release差分allowlistを事前固定", fixed = TRUE
  )
  expect_match(
    roadmap,
    "fixed-calibration-release-candidate-transition-record-0.2.4.md",
    fixed = TRUE
  )
})

test_that("0.2.4 candidate metadata record binds readiness without submission", {
  transition <- load_fixed_calibration_release_candidate_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-release-candidate-metadata-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "CandidateMetadataCommitSHA40=e1fda8274579d8de6e7931148c3c59fad7d2d469",
    "CandidateVersion=0.2.4",
    "CandidateDate=2026-08-26",
    "CandidateReleaseStatus=candidate",
    "CandidatePublicVersion=0.2.3.1",
    "CandidateNewsHeading=# mfrmr 0.2.4",
    "CandidateMetadataOK=TRUE",
    "CranCommentsReady=TRUE",
    "CandidateReady=TRUE",
    "CandidateTagCreated=FALSE",
    "CandidateChecksRun=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=audit-final-public-claim-diff"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
  expect_match(
    record,
    "The metadata transition does not inherit a final-candidate check result",
    fixed = TRUE
  )
})

test_that("0.2.4 candidate invalidation record preserves the failed denominator", {
  transition <- load_fixed_calibration_release_candidate_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-release-candidate-invalidation-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "InvalidatedCandidateCommitSHA40=93d92604ed96bf7ea098b6ff52042106f44acd6b",
    "RecoveryDevelopmentCommitSHA40=499c2d510f57c7d89c9263866c6265f9b124ed1e",
    "FailedTestFile=tests/testthat/test-vignette-artifacts.R",
    "FailedExpectations=1",
    "CandidateAuditPassed=FALSE",
    "CandidateMetadataDryRunInvalidated=TRUE",
    "ReleaseTransitionContractReusable=FALSE",
    "ReturnedToDevelopment=TRUE",
    "ProductionChangeRequired=TRUE",
    "CandidateTagCreated=FALSE",
    "FinalCandidateChecksRun=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=run-new-development-payload-regression"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
  expect_match(
    record,
    "Changing the manifest to 0.2.4 would have falsified its generation provenance",
    fixed = TRUE
  )
})

test_that("0.2.4 candidate recovery local check is exact and non-authorizing", {
  transition <- load_fixed_calibration_release_candidate_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-candidate-recovery-local-check-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "CheckedCommitSHA40=76b4d65722cf82cc082717750ea14340571918a1",
    "CheckedTreeSHA40=5f34a0c205e9d4338b549b031c13c90b52cbfdc7",
    "PackageVersion=0.2.4.9000",
    "SourceTarballSHA256=ff7ea0878cef0d6ee4a6ada10db95ea43d7265452070a05be57b61005e6c9dfe",
    "CheckLogSHA256=079faf2555105ff56d98037b00b1796d5fd08b227fe746c5be2c7fd0b74325d9",
    "Errors=0",
    "Warnings=0",
    "Notes=0",
    "DistributedTestsPassed=435",
    "DistributedTestsSkipped=3",
    "G4EvidenceIssued=FALSE",
    "G6Revalidated=FALSE",
    "CandidateMetadataApplied=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=run-recovery-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 recovery hosted matrix is complete and non-authorizing", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-candidate-recovery-hosted-run-",
      "32915301113-record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "RecoveryHostedRunId=32915301113",
    "RecoveryHostedHeadSHA40=e39571974f70da0db90444732b5719c187a004d2",
    "HostedWorkflowConclusion=success",
    "HostedPlatformCells=5",
    "HostedPassedCells=5",
    "HostedFailedCells=0",
    "CheckArtifactCount=5",
    "ExpiredArtifactCount=0",
    "OldCandidateInvalidated=TRUE",
    "OldTransitionContractReusable=FALSE",
    "G6Revalidated=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=bind-recovery-g6-and-freeze-new-transition"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 recovery G6 decision binds the delta and fresh denominator", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-g6-candidate-recovery-decision-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "RecoveryG6DecisionId=mfrmr_fixed_calibration_g6_recovery_0_2_4_v1",
    "PriorG6ValidatedCommitSHA40=cf20dd0167db3f39224cea7d1c70998b1142f81f",
    "RecoveryValidatedPayloadCommitSHA40=e39571974f70da0db90444732b5719c187a004d2",
    "ValidatedPayloadCommitSHA40=e39571974f70da0db90444732b5719c187a004d2",
    "HostedRunId=32915301113",
    "HostedWorkflowConclusion=success",
    "HostedPlatformCells=5",
    "HostedPassedCells=5",
    "HostedFailedCells=0",
    "CheckArtifactCount=5",
    "LocalSourceCheckStatus=OK",
    "PathsChangedFromPriorG6=11",
    "DistributedPackageChangedPaths=1",
    "DistributedPackageChangedPath=tests/testthat/test-vignette-artifacts.R",
    "ProductionCodeChanged=FALSE",
    "CalibrationSchemaChanged=FALSE",
    "ScoringKernelChanged=FALSE",
    "StatisticalModelChanged=FALSE",
    "PublicClaimChanged=FALSE",
    "G4Reissued=FALSE",
    "G4StatisticalEvidenceStillApplicable=TRUE",
    "OldCandidateInvalidated=TRUE",
    "OldTransitionContractReusable=FALSE",
    "G6Revalidated=TRUE",
    "G6ExitComplete=TRUE",
    "PublicAPIAuthorizedForRelease=TRUE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=freeze-recovery-transition-boundary"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 recovery transition fails closed after public schema change", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  contract <- transition$env$mfrmr_rc04_contract()
  review <- transition$env$mfrmr_rc04_review(transition$root)

  expect_identical(
    contract$ContractId,
    "mfrmr_release_candidate_transition_0_2_4_v2_recovery"
  )
  expect_identical(
    contract$G6ValidatedCommit,
    "e39571974f70da0db90444732b5719c187a004d2"
  )
  expect_identical(contract$G6HostedRunId, "32915301113")
  expect_identical(
    contract$G6DecisionRecord,
    "fixed-calibration-g6-candidate-recovery-decision-record-0.2.4.md"
  )
  expect_false(contract$PriorCandidateReusable)
  expect_false(contract$PriorTransitionContractReusable)
  expect_false(contract$SubmissionAuthorized)

  expect_true(review$G6BaselineAncestor)
  expect_true(review$G6DecisionBound)
  expect_false(review$ChangedPathsAllowed)
  expect_false(review$ProductionPayloadUnchanged)
  expect_identical(review$Metadata$Stage, "development")
  expect_false(review$Metadata$DevelopmentMetadataOK)
  expect_false(review$Metadata$CandidateMetadataOK)
  expect_false(review$DevelopmentTransitionReady)
  expect_false(review$CandidateReady)
  expect_false(review$SubmissionAuthorized)
  expect_true(any(
    review$Inventory$Classification == "package_payload_change_forbidden"
  ))
  forbidden <- review$Inventory$Path[
    review$Inventory$Classification == "package_payload_change_forbidden"
  ]
  expect_true(all(c(
    "R/core-fixed-calibration.R",
    "tests/testthat/test-fixed-calibration-lifecycle.R"
  ) %in% forbidden))
})

test_that("0.2.4 recovery transition record freezes the clean v2 review", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-release-candidate-transition-recovery-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v2_recovery",
    "TransitionContractCommitSHA40=e49903255fb728bf4cc631ad66077700840c043b",
    "ReviewCommitSHA40=e49903255fb728bf4cc631ad66077700840c043b",
    "G6ValidatedCommitSHA40=e39571974f70da0db90444732b5719c187a004d2",
    "G6HostedRunId=32915301113",
    "ReviewBranch=development/0.2.4",
    "G6BaselineAncestor=TRUE",
    "WorkingTreeCleanAtReview=TRUE",
    "ChangedPathCount=7",
    "CandidatePackageMetadataPathCount=0",
    "CandidateRepositoryRoadmapPathCount=1",
    "CandidateInternalEvidencePathCount=6",
    "ForbiddenPayloadPathCount=0",
    "ChangedPathsAllowed=TRUE",
    "ProductionPayloadUnchanged=TRUE",
    "MetadataStage=development",
    "DevelopmentMetadataOK=TRUE",
    "G6DecisionBound=TRUE",
    "DevelopmentTransitionReady=TRUE",
    "PriorCandidateReusable=FALSE",
    "PriorTransitionContractReusable=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateReady=FALSE",
    "CandidateTagCreated=FALSE",
    "CandidateChecksRun=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "ReleaseDiffAllowlistFrozen=TRUE",
    "NextAction=apply-0.2.4-candidate-metadata-under-recovery-v2-allowlist"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 recovery v2 invalidation precedes candidate metadata", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-release-candidate-transition-recovery-",
      "invalidation-record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "InvalidatedTransitionContractId=mfrmr_release_candidate_transition_0_2_4_v2_recovery",
    "CandidateMetadataApplied=FALSE",
    "CandidateCommitCreated=FALSE",
    "CandidateTagCreated=FALSE",
    "CandidateChecksRun=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "ProductionPayloadChanged=TRUE",
    "PublicArtifactSchemaChanged=TRUE",
    "NumericalScoringAlgorithmChanged=FALSE",
    "StatisticalModelChanged=FALSE",
    "OldCandidateReusable=FALSE",
    "TransitionV1Reusable=FALSE",
    "TransitionV2Reusable=FALSE",
    "ReturnedToDevelopment=TRUE",
    "NextAction=run-public-language-and-schema-regression"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language schema amendment remains non-authorizing", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-public-language-schema-amendment-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "AmendmentId=mfrmr_public_language_schema_amendment_0_2_4_v1",
    "PreviousEligibilityField=eligibility.lane_id",
    "CurrentEligibilityField=eligibility.support_profile_id",
    "RsmSupportProfileId=rsm_mml_fixed_standard_normal_v1",
    "PcmSupportProfileId=pcm_mml_fixed_standard_normal_v1",
    "CurrentCreatorIdentity=mfrmr::extract_mfrm_calibration",
    "PublicPrintLabel=Support profile",
    "SemanticComponentName=support_profile",
    "InvalidProfileCode=SUPPORT_PROFILE_INVALID",
    "PublicDocumentationInternalProcessTermHits=0",
    "TargetedRegressionFiles=7",
    "TargetedRegressionPassed=TRUE",
    "TargetedRegressionFailures=0",
    "NumericalScoringAlgorithmChanged=FALSE",
    "StatisticalModelChanged=FALSE",
    "SupportedEnvelopeChanged=FALSE",
    "LocalSourceCheckPassed=FALSE",
    "HostedFivePlatformPassed=FALSE",
    "G6Revalidated=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=run-clean-source-package-check"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language schema local check is exact", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-public-language-schema-local-check-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "CheckedCommitSHA40=96068c9a16d48e7011a321f40ef125d8ab621418",
    "CheckedTreeSHA40=7569b4b84dc0182b22fc7d9c5582c17cb606f920",
    "PackageVersion=0.2.4.9000",
    "SourceTarballSHA256=ad901c65751ffc9974f1ea2ab2739058d8e9f5c672833e3792a85932784c5956",
    "CheckLogSHA256=2fda34c792dcc83301699b1bfc44a530933648d09d8fdc07883e0aeff619147e",
    "Errors=0",
    "Warnings=0",
    "Notes=0",
    "DistributedTestsPassed=435",
    "DistributedTestsSkipped=3",
    "SourceCheckStatus=OK",
    "G4EvidenceIssued=FALSE",
    "G6Revalidated=FALSE",
    "HostedRunId=32920882662",
    "HostedRunComplete=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=complete-public-language-schema-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language schema amendment preserves numeric results", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-public-language-schema-numerical-parity-",
      "record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "ParityContract=mfrmr_public_language_schema_numerical_parity_v1",
    "OldCheckedCommitSHA40=76b4d65722cf82cc082717750ea14340571918a1",
    "NewCheckedCommitSHA40=96068c9a16d48e7011a321f40ef125d8ab621418",
    "SeparateInstalledLibraries=TRUE",
    "ComparedModels=RSM,PCM",
    "Estimator=MML",
    "ScoringQuadratureOrder=31",
    "RngUsed=FALSE",
    "RsmResultSHA256=d0dbbb2b8b2a531f595afe4eca3825b8e214e4bd12a03cfd2462792f315ebb7d",
    "PcmResultSHA256=bd3c80b90a037ec3e678148f93e5f55d635787f5174f72dba0917ef20a9d462f",
    "RsmOldNewObjectIdentical=TRUE",
    "PcmOldNewObjectIdentical=TRUE",
    "MaxFitParameterDifference=0",
    "MaxCalibrationCoordinateDifference=0",
    "MaxPersonEstimateDifference=0",
    "NumericalScoringAlgorithmChanged=FALSE",
    "StatisticalModelChanged=FALSE",
    "G4Reissued=FALSE",
    "G6Revalidated=FALSE",
    "CandidateMetadataApplied=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=complete-public-language-schema-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 final public-language pass has an exact local receipt", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-public-language-final-pass-local-check-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "ReviewContract=mfrmr_public_language_final_pass_v1",
    "EvidenceRole=package_check_and_delta_classification_only",
    "PriorCheckedCommitSHA40=96068c9a16d48e7011a321f40ef125d8ab621418",
    "CheckedCommitSHA40=772ada581c37ebab4c42e932abac32d373bef938",
    "CheckedTreeSHA40=2acf9d32d2857dd71aa22f9a7aa3f5002f9d3065",
    "DistributedChangedPaths=9",
    "ExecutableRExpressionsIdentical=TRUE",
    "StatisticalCodeChanged=FALSE",
    "ScoringKernelChanged=FALSE",
    "CalibrationSchemaChanged=FALSE",
    "SourceTarballSHA256=b975104f73ca7de378a9aee523836213a1cc683369317facdf0efa4a57e43b37",
    "CheckLogSHA256=736a597848b08d5803038cf48abdf7f4e99a93070883b6184276f40045488719",
    "Errors=0",
    "Warnings=0",
    "Notes=0",
    "DistributedTestsPassed=435",
    "DistributedTestsSkipped=3",
    "PriorNumericalParityStillApplicable=TRUE",
    "G4Reissued=FALSE",
    "G6Revalidated=FALSE",
    "HostedRunId=32922730035",
    "HostedRunComplete=FALSE",
    "PriorHostedRunReusableForFinalPayload=FALSE",
    "CandidateMetadataApplied=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=complete-final-public-language-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public runtime messages have an exact local receipt", {
  transition <- load_fixed_calibration_release_candidate_recovery_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-public-language-runtime-message-",
      "local-check-record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "ReviewContract=mfrmr_public_language_runtime_message_review_v1",
    "EvidenceRole=package_check_content_audit_and_numerical_parity",
    "PriorCheckedCommitSHA40=772ada581c37ebab4c42e932abac32d373bef938",
    "CheckedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    "CheckedTreeSHA40=1697a7df6b2bd9d9b2540ac7036975f5d9921d83",
    "DistributedChangedPaths=14",
    "ControlFlowChanged=FALSE",
    "NumericExpressionChanged=FALSE",
    "StatisticalModelChanged=FALSE",
    "ScoringKernelChanged=FALSE",
    "CalibrationSchemaChanged=FALSE",
    "SourceTarballSHA256=4876a1c247109567399e74101f3bfd5b69b7e911e310f0a6ea31589e79a37241",
    "CheckLogSHA256=2f40ab9aab06d7982883f77bf85ed53f34f4db5444c800fb9afa6f3b2698b810",
    "Errors=0",
    "Warnings=0",
    "Notes=0",
    "DistributedTestsPassed=435",
    "DistributedTestsSkipped=3",
    "RsmOldNewObjectIdentical=TRUE",
    "PcmOldNewObjectIdentical=TRUE",
    "RsmResultSHA256=d0dbbb2b8b2a531f595afe4eca3825b8e214e4bd12a03cfd2462792f315ebb7d",
    "PcmResultSHA256=bd3c80b90a037ec3e678148f93e5f55d635787f5174f72dba0917ef20a9d462f",
    "MaxFitParameterDifference=0",
    "MaxCalibrationCoordinateDifference=0",
    "MaxPersonEstimateDifference=0",
    "InternalValidationPathsInTarball=0",
    "PublicDocumentationBlockedPhraseHits=0",
    "PublicRuntimeBoundaryCodeHits=0",
    "G4Reissued=FALSE",
    "G6Revalidated=FALSE",
    "HostedRunId=32923607662",
    "HostedRunComplete=FALSE",
    "PriorHostedRunReusableForFinalPayload=FALSE",
    "CandidateMetadataApplied=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=complete-public-language-runtime-message-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language payload has a complete hosted receipt", {
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-public-language-runtime-message-hosted-run-",
      "32923607662-record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "PublicLanguageHostedRunId=32923607662",
    "PublicLanguageHostedHeadSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    "HostedWorkflowConclusion=success",
    "HostedPlatformCells=5",
    "HostedPassedCells=5",
    "HostedFailedCells=0",
    "CheckArtifactCount=5",
    "ExpiredArtifactCount=0",
    "LocalCheckedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    "InterveningSourcePackagePaths=0",
    "SourceTarballSHA256=4876a1c247109567399e74101f3bfd5b69b7e911e310f0a6ea31589e79a37241",
    "CheckLogSHA256=2f40ab9aab06d7982883f77bf85ed53f34f4db5444c800fb9afa6f3b2698b810",
    "LocalSourceCheckStatus=OK",
    "G4Reissued=FALSE",
    "G6Revalidated=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=bind-public-language-g6-and-freeze-transition-v3"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language G6 decision binds scope and denominator", {
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  record_path <- file.path(
    transition$validation,
    "fixed-calibration-g6-public-language-final-decision-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "FinalPublicLanguageG6DecisionId=mfrmr_fixed_calibration_g6_public_language_0_2_4_v1",
    "PriorG6ValidatedCommitSHA40=e39571974f70da0db90444732b5719c187a004d2",
    "ValidatedPayloadCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    "HostedRunId=32923607662",
    "HostedWorkflowConclusion=success",
    "HostedPlatformCells=5",
    "HostedPassedCells=5",
    "HostedFailedCells=0",
    "CheckArtifactCount=5",
    "LocalSourceCheckStatus=OK",
    "PathsChangedFromPriorG6=62",
    "DistributedPackageChangedPaths=49",
    "DistributedRChangedPaths=27",
    "DistributedManChangedPaths=11",
    "DistributedVignetteChangedPaths=7",
    "DistributedTestChangedPaths=3",
    "CalibrationSchemaChanged=TRUE",
    "ScoringKernelChanged=FALSE",
    "LikelihoodChanged=FALSE",
    "OptimizerNumericalLogicChanged=FALSE",
    "PublicWordingChanged=TRUE",
    "PublicScopeChanged=FALSE",
    "RuntimeBoundaryMessageChanged=TRUE",
    "DirectRsmPcmNumericalParity=TRUE",
    "PublicDocumentationBlockedPhraseHits=0",
    "PublicRuntimeBoundaryCodeHits=0",
    "G4Reissued=FALSE",
    "G4StatisticalEvidenceStillApplicable=TRUE",
    "PriorCandidateReusable=FALSE",
    "PriorTransitionV1Reusable=FALSE",
    "PriorTransitionV2Reusable=FALSE",
    "G6Revalidated=TRUE",
    "G6ExitComplete=TRUE",
    "PublicAPIAuthorizedForRelease=TRUE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=freeze-public-language-transition-boundary-v3"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language transition v3 rejects later payload drift", {
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  contract <- transition$env$mfrmr_rc04_contract()
  review <- transition$env$mfrmr_rc04_review(transition$root)

  expect_identical(
    contract$ContractId,
    "mfrmr_release_candidate_transition_0_2_4_v3_public_language"
  )
  expect_identical(
    contract$G6ValidatedCommit,
    "0dd03dd9830371dd13159db68f00d14ada0cb0ba"
  )
  expect_identical(contract$G6HostedRunId, "32923607662")
  expect_identical(
    contract$G6DecisionRecord,
    "fixed-calibration-g6-public-language-final-decision-record-0.2.4.md"
  )
  expect_false(contract$PriorCandidateReusable)
  expect_false(contract$PriorTransitionContractReusable)
  expect_false(contract$SubmissionAuthorized)

  expect_true(review$G6BaselineAncestor)
  expect_false(review$ChangedPathsAllowed)
  expect_false(review$ProductionPayloadUnchanged)
  expect_identical(review$Metadata$Stage, "development")
  expect_false(review$Metadata$CandidateMetadataOK)
  expect_true(review$G6DecisionBound)
  expect_false(review$DevelopmentTransitionReady)
  expect_false(review$CandidateReady)
  expect_false(review$SubmissionAuthorized)
})

test_that("0.2.4 public-language transition record freezes clean v3", {
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-release-candidate-transition-public-language-",
      "record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v3_public_language",
    "TransitionContractCommitSHA40=fd21f8e81a92a3481e688c049697420097fa6f1d",
    "ReviewCommitSHA40=fd21f8e81a92a3481e688c049697420097fa6f1d",
    "G6ValidatedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    "G6HostedRunId=32923607662",
    "ReviewBranch=development/0.2.4",
    "G6BaselineAncestor=TRUE",
    "WorkingTreeCleanAtReview=TRUE",
    "ChangedPathCount=7",
    "CandidatePackageMetadataPathCount=0",
    "CandidateRepositoryRoadmapPathCount=1",
    "CandidateInternalEvidencePathCount=6",
    "ForbiddenPayloadPathCount=0",
    "ChangedPathsAllowed=TRUE",
    "ProductionPayloadUnchanged=TRUE",
    "MetadataStage=development",
    "DevelopmentMetadataOK=TRUE",
    "G6DecisionBound=TRUE",
    "DevelopmentTransitionReady=TRUE",
    "PriorCandidateReusable=FALSE",
    "PriorTransitionContractReusable=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateReady=FALSE",
    "CandidateTagCreated=FALSE",
    "CandidateChecksRun=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "ReleaseDiffAllowlistFrozen=TRUE",
    "NextAction=hold-candidate-metadata-pending-explicit-decision"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 public-language candidate metadata has a local receipt", {
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-release-candidate-metadata-public-language-",
      "record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")

  expected <- c(
    "TransitionContractId=mfrmr_release_candidate_transition_0_2_4_v3_public_language",
    "CandidateMetadataCommitSHA40=8b408083c0277dabe7c71450bd8b53dcbde0853e",
    "G6ValidatedCommitSHA40=0dd03dd9830371dd13159db68f00d14ada0cb0ba",
    "G6HostedRunId=32923607662",
    "WorkingTreeCleanAtReview=TRUE",
    "ChangedPathCount=12",
    "CandidatePackageMetadataPathCount=2",
    "CandidateRepositoryMetadataOrRoadmapPathCount=3",
    "CandidateInternalEvidencePathCount=7",
    "ForbiddenPayloadPathCount=0",
    "ChangedPathsAllowed=TRUE",
    "ProductionPayloadUnchanged=TRUE",
    "MetadataStage=candidate",
    "CandidateVersion=0.2.4",
    "CandidateDate=2026-08-26",
    "CandidateReleaseStatus=candidate",
    "CandidatePublicVersion=0.2.3.1",
    "CandidateCffVersion=0.2.4",
    "CandidateCffDate=2026-08-26",
    "CandidateNewsHeading=# mfrmr 0.2.4",
    "CandidateMetadataOK=TRUE",
    "CranCommentsReady=TRUE",
    "CandidateReady=TRUE",
    "CandidateSourcePackageChangedPaths=2",
    "CandidateSourcePackageChangedPath1=DESCRIPTION",
    "CandidateSourcePackageChangedPath2=NEWS.md",
    "CandidateSourceTarballSHA256=6570b98e0335de3862a5c2f12355b59c2e681dc5f3ed31d03238bc6c730836a5",
    "CandidateCheckLogSHA256=8574d99765e1b29a74dc4a435f099c33e032835e39c86576176eb6963deedd33",
    "CandidateLocalSourceCheckStatus=OK",
    "CandidateLocalErrors=0",
    "CandidateLocalWarnings=0",
    "CandidateLocalNotes=0",
    "CandidateDistributedTestsPassed=435",
    "CandidateDistributedTestsSkipped=3",
    "PublicDocumentationBlockedPhraseHits=0",
    "PublicRuntimeBoundaryCodeHits=0",
    "CandidateHostedRunId=32936425346",
    "CandidateHostedRunComplete=TRUE",
    "CandidateHostedRunSuccess=FALSE",
    "CandidateHostedPackageCheckPassed=TRUE",
    "CandidateHostedRepositoryValidationPassed=FALSE",
    "CandidateHostedMatrixCellsPassed=0",
    "CandidateHostedMatrixCellsSkipped=4",
    "CandidateHostedRetryRequired=TRUE",
    "SourceTruthRepairCommitSHA40=7a0e042ba4a0d07f0b6756d3409d1b06ad89e801",
    "SourceTruthRepairSourceTarballSHA256=fa3b13f1d179e34838bce8f8b457b7552965a7cedad3528aa3b6f206a981cf47",
    "SourceTruthRepairCheckLogSHA256=52a65160fb4b49fce01d7651e9bda8a7c053518b9bc889418e6659dcf1856d24",
    "SourceTruthRepairLocalSourceCheckStatus=OK",
    "SourceTruthRepairLocalErrors=0",
    "SourceTruthRepairLocalWarnings=0",
    "SourceTruthRepairLocalNotes=0",
    "SourceTruthRepairDistributedTestsPassed=435",
    "SourceTruthRepairDistributedTestsSkipped=3",
    "SourceTruthRepairPriorCandidatePayloadDiff=DESCRIPTION_PACKAGED_TIMESTAMP_ONLY",
    "CandidateHostedRetryRunId=32938041192",
    "CandidateHostedRetryRunComplete=TRUE",
    "CandidateHostedRetryRunSuccess=FALSE",
    "CandidateHostedRetryPackageCheckPassed=TRUE",
    "CandidateHostedRetrySourceTruthPassed=TRUE",
    "CandidateHostedRetryMaintenanceBridgePassed=FALSE",
    "CandidateHostedRetryMatrixCellsPassed=0",
    "CandidateHostedRetryMatrixCellsSkipped=4",
    "CandidateHostedSecondRetryRequired=TRUE",
    "MaintenanceBridgeRepairCommitSHA40=a4790789a5fb7f1869ae7e5eeb225e2290a6b820",
    "MaintenanceBridgeContractId=mfrmr_fixed_calibration_g4_maintenance_admission_v2_lifecycle_aware",
    "MaintenanceBridgeMetadataStage=candidate",
    "MaintenanceBridgeReleaseMetadataAligned=TRUE",
    "MaintenanceBridgeComplete=TRUE",
    "MaintenanceBridgeProductionPayloadUnchanged=TRUE",
    "CandidateHostedSecondRetryRunId=32938822686",
    "CandidateHostedSecondRetryHeadSHA40=356d0fd4149ae275f8cfbf23c59928f37d829555",
    "CandidateHostedSecondRetryRunComplete=TRUE",
    "CandidateHostedSecondRetryRunSuccess=TRUE",
    "CandidateHostedSecondRetryPlatformCells=5",
    "CandidateHostedSecondRetryPlatformCellsPassed=5",
    "CandidateHostedSecondRetryPlatformCellsFailed=0",
    "CandidateHostedSecondRetryPlatformCellsSkipped=0",
    "CandidateHostedSecondRetryEachPackageCheckPassed=TRUE",
    "CandidateHostedSecondRetryEachRepositoryReviewPassed=TRUE",
    "CandidateHostedFurtherRetryRequired=FALSE",
    "CandidateValidationHostedComplete=TRUE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=hold-for-explicit-human-sign-off-no-submission"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("0.2.4 candidate hosted validation binds the successful five-platform run", {
  transition <-
    load_fixed_calibration_release_candidate_public_language_transition()
  record_path <- file.path(
    transition$validation,
    paste0(
      "fixed-calibration-release-candidate-hosted-run-32938822686-",
      "public-language-record-0.2.4.md"
    )
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expected <- c(
    "CandidateHostedRunId=32938822686",
    "CandidateHostedHeadSHA40=356d0fd4149ae275f8cfbf23c59928f37d829555",
    "WorkflowConclusion=success",
    "PlatformCells=5",
    "CompletePlatformCells=5",
    "SuccessfulPlatformCells=5",
    "FailedPlatformCells=0",
    "SkippedPlatformCells=0",
    "EachExactSourcePackageCheckPassed=TRUE",
    "EachRepositoryValidationReviewPassed=TRUE",
    "SourceTruthOK=TRUE",
    "MaintenanceBridgeComplete=TRUE",
    "CandidateReadyAtHostedHead=TRUE",
    "ProductionPayloadUnchanged=TRUE",
    "FirstFailedRunId=32936425346",
    "SecondFailedRunId=32938041192",
    "FailedRunsRetainedInDenominator=TRUE",
    "CandidateTagCreated=FALSE",
    "SubmissionAuthorized=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "PublicationPerformed=FALSE",
    "FurtherHostedRetryRequired=FALSE",
    "NextAction=hold-for-explicit-human-sign-off-no-submission"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})

test_that("score UX review invalidates the previous candidate before human sign-off", {
  ctx <- load_fixed_calibration_g4_contract()
  record_path <- file.path(
    ctx$validation,
    "fixed-calibration-release-candidate-ux-invalidation-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expected <- c(
    "PreviousCandidateAutomatedChecksPassed=TRUE",
    "PreviousCandidateHumanSignOffComplete=FALSE",
    "FreshPkgdownBuildComplete=TRUE",
    "DesktopRenderInspected=TRUE",
    "NarrowRenderInspected=TRUE",
    "ProductionPayloadChangeRequired=TRUE",
    "PreviousCandidateReusable=FALSE",
    "ReturnedToDevelopment=TRUE",
    "CandidateTagCreated=FALSE",
    "CRANSubmissionPerformed=FALSE"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }

  description <- read.dcf(file.path(ctx$root, "DESCRIPTION"))
  expect_identical(unname(description[1L, "Version"]), "0.2.4.9000")
  expect_identical(
    unname(description[1L, "Config/mfrmr/release-status"]), "development"
  )
  expect_false("Date" %in% colnames(description))

  expected_surface <- c(
    "R/api-calibration-methods.R",
    "man/mfrm_calibration_score_methods.Rd",
    "vignettes/mfrmr-portable-calibration.Rmd",
    "vignettes/mfrmr-visual-diagnostics.Rmd"
  )
  expect_true(all(file.exists(file.path(ctx$root, expected_surface))))
  article <- paste(readLines(
    file.path(ctx$root, "vignettes/mfrmr-portable-calibration.Rmd"),
    warn = FALSE
  ), collapse = "\n")
  expect_match(article, "summary(scores)", fixed = TRUE)
  expect_match(article, 'type = "interval"', fixed = TRUE)
  expect_match(
    article, "excludes calibration-parameter uncertainty", fixed = TRUE
  )
})

test_that("score UX local validation closes repair but not release gates", {
  ctx <- load_fixed_calibration_g4_contract()
  record_path <- file.path(
    ctx$validation,
    "fixed-calibration-score-ux-local-validation-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expected <- c(
    "DevelopmentVersion=0.2.4.9000",
    "ReleaseStatus=development",
    "PortableScorePrintAvailable=TRUE",
    "PortableScoreSummaryAvailable=TRUE",
    "PortableScoreIntervalPlotAvailable=TRUE",
    "PortableScorePrecisionPlotAvailable=TRUE",
    "PortableScoreEdgeMassPlotAvailable=TRUE",
    "DrawFreePlotDataAvailable=TRUE",
    "NotScoredDispositionRetained=TRUE",
    "CalibrationParameterUncertaintyExcludedAndDisclosed=TRUE",
    "FreshPkgdownBuildComplete=TRUE",
    "DesktopArticleRenderInspected=TRUE",
    "NarrowArticleRenderInspected=TRUE",
    "DesktopHelpRenderInspected=TRUE",
    "NarrowHelpRenderInspected=TRUE",
    "NarrowWholePageOverflowDetected=FALSE",
    "ExactSourcePackageCheckStatus=OK",
    "ExactSourcePackageErrors=0",
    "ExactSourcePackageWarnings=0",
    "ExactSourcePackageNotes=0",
    "PackagedTestsPassed=15866",
    "PackagedTestsFailed=0",
    "PackagedTestsSkipped=43",
    "RepositoryWideResearchSuitePassed=FALSE",
    "PreviousCandidateReusable=FALSE",
    "FreshHostedMatrixComplete=FALSE",
    "HumanSignOffComplete=FALSE",
    "CandidateMetadataApplied=FALSE",
    "CandidateTagCreated=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=commit-development-payload-and-run-fresh-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }

  roadmap <- paste(readLines(
    file.path(ctx$validation, "mfrmr-internal-strategic-roadmap.html"),
    warn = FALSE
  ), collapse = "\n")
  expect_match(roadmap, "portable scoreの要約・3図・help・記事を統合", fixed = TRUE)
  expect_match(roadmap, "fresh development payloadを5環境で再検証", fixed = TRUE)
  expect_match(roadmap, "candidate metadataとexact headを再形成", fixed = TRUE)
})

test_that("first score UX hosted retry retains its source-truth failure", {
  ctx <- load_fixed_calibration_g4_contract()
  record_path <- file.path(
    ctx$validation,
    "fixed-calibration-score-ux-hosted-run-32961641396-record-0.2.4.md"
  )
  expect_true(file.exists(record_path))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  expected <- c(
    "WorkflowRunId=32961641396",
    "SourceCommit=e51a632478e3142bb28cfb1ee41417022d3dd618",
    "WorkflowConclusion=failure",
    "ExactSourcePackageCheckStatus=OK",
    "RepositoryValidationReviewPassed=FALSE",
    "SourceTruthOK=FALSE",
    "RoadmapLifecycleMatches=FALSE",
    "DependentPlatformJobsSkipped=TRUE",
    "HostedPlatformMatrixComplete=FALSE",
    "FailureRetainedInDenominator=TRUE",
    "CorrectiveChange=roadmap-development-lifecycle-alignment",
    "ReleaseReadinessParserWeakened=FALSE",
    "CorrectedSourceTruthLocalCheck=TRUE",
    "PreviousCandidateReusable=FALSE",
    "CandidateMetadataApplied=FALSE",
    "HumanSignOffComplete=FALSE",
    "CandidateTagCreated=FALSE",
    "CRANSubmissionPerformed=FALSE",
    "NextAction=commit-source-truth-correction-and-run-new-five-platform-matrix"
  )
  for (field in expected) {
    expect_match(record, paste0("`", field, "`"), fixed = TRUE)
  }
})
