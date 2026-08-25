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

test_that("amended G4 v5 contract is prospective and binds its unopened record", {
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
  roadmap <- paste(
    readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE),
    collapse = "\n"
  )
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
    hardening, "`AmendedG4ContractFrozen=TRUE`", fixed = TRUE
  )
  expect_match(
    roadmap,
    "  - [x] Freeze an amended current-source confirmation contract",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "  - [ ] Run the amended denominator from an isolated current source-tarball",
    fixed = TRUE
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
  roadmap <- paste(
    readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE),
    collapse = "\n"
  )
  expect_match(
    record, "`CandidateBindingPreflightImplemented=TRUE`", fixed = TRUE
  )
  expect_match(record, "`LiveCandidateBindingComplete=FALSE`", fixed = TRUE)
  expect_match(record, "`CurrentExecutionOpened=FALSE`", fixed = TRUE)
  expect_match(record, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "  - [x] Implement a fail-closed candidate-binding preflight",
    fixed = TRUE
  )
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("mfrmr_score_calibration\\s*\\(", source, perl = TRUE))
  expect_false(grepl("R CMD check|R CMD build", source, fixed = TRUE))
})

test_that("G4 candidate inventory classifies every live path fail closed", {
  ctx <- load_fixed_calibration_g4_candidate_inventory()
  review <- ctx$env$mfrmr_fc_g4i_review(ctx$root)
  inventory <- review$Inventory
  expect_identical(
    review$Status, "all_live_changes_classified_commit_lanes_unexecuted"
  )
  expect_true(review$AllChangesClassified)
  expect_true(review$ResearchExcludedFromPackagePayload)
  expect_true(review$PublicInternalLanguageClean)
  expect_true(review$CommitPlanReady)
  expect_identical(review$WorkingTreeClean, nrow(inventory) == 0L)
  expect_false(review$CandidateBindingComplete)
  expect_false(review$CurrentExecutionOpened)
  expect_false(review$G4ExitComplete)
  expect_identical(
    sum(inventory$Classification == "unclassified_fail_closed"), 0L
  )
  expect_identical(anyDuplicated(inventory$Path), 0L)
  allowed <- c(
    "release_production_code_and_metadata",
    "release_public_and_user_facing_surface",
    "release_build_test_and_repository_evidence",
    "deferred_multivariate_gtheory_research",
    "deferred_rater_anchor_design_research"
  )
  expect_true(all(inventory$Classification %in% allowed))
  representative <- vapply(c(
    "R/api-prediction.R", "NEWS.md",
    "inst/validation/fixed-calibration-example-0.2.4.md"
  ), ctx$env$mfrmr_fc_g4i_classify_path, character(1L))
  expect_identical(unname(representative), allowed[1:3])
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
  expect_identical(nrow(ignore), 5L)
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

test_that("macOS release gates the four remaining workflow cells", {
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
  expect_match(workflow, "  g4-hosted-matrix:", fixed = TRUE)
  expect_match(workflow, "needs: [macos-release, remaining-platforms]",
               fixed = TRUE)
  expect_match(workflow, "Aggregate five bound G4 receipts", fixed = TRUE)

  expect_match(cell, "  workflow_call:", fixed = TRUE)
  expect_match(cell, "Exact bound-tarball R CMD check and G4 evidence",
               fixed = TRUE)
  expect_match(
    cell, "fixed-calibration-g4-hosted-runner-0.2.4.R", fixed = TRUE
  )
  expect_match(cell, "MFRMR_CHECK_ERROR_ON: warning", fixed = TRUE)
  expect_match(cell, "Repository validation review", fixed = TRUE)
  expect_match(
    cell, "mfrmr_fc_g4h_repository_review", fixed = TRUE
  )
  expect_match(
    cell, "G6 and public API remain", fixed = TRUE
  )
  expect_false(grepl("pkgload::load_all", cell, fixed = TRUE))
  expect_match(cell, "Upload bound G4 cell receipt", fixed = TRUE)
  expect_match(cell, "hosted-cell-receipt.rds", fixed = TRUE)
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

test_that("historical G4 close is retained while current-source G4 is reopened", {
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
  roadmap <- paste(
    readLines(file.path(ctx$root, "ROADMAP.md"), warn = FALSE),
    collapse = "\n"
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
  expect_match(hardening_record, "`CORE05Complete=FALSE`", fixed = TRUE)
  expect_match(hardening_record, "`CORE06Complete=FALSE`", fixed = TRUE)
  expect_match(hardening_record, "`G4ExitComplete=FALSE`", fixed = TRUE)
  expect_match(roadmap, "- [ ] **CORE-05 — Independent evidence:**",
               fixed = TRUE)
  expect_match(roadmap, "- [ ] **CORE-06 — Reproducible operation:**",
               fixed = TRUE)
  expect_match(roadmap, "- [ ] **G4 — Independent and operational evidence**",
               fixed = TRUE)
  expect_match(
    roadmap,
    "  - [x] Run the prospectively required hosted macOS release workflow cell",
    fixed = TRUE
  )
  expect_match(roadmap, "  - [ ] **G4 exit:**", fixed = TRUE)
  expect_match(roadmap, "- [x] **G5 — Optional-lane qualification**",
               fixed = TRUE)
})
