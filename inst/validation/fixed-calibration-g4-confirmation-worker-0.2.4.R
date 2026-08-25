# 0.2.4 fixed-calibration G4 confirmation worker.
#
# The historical five-argument entry point performs one fresh-process artifact
# score. The `current` entry point consumes a bound candidate receipt and
# retains one result row for each prospectively frozen current-source cell.
# Sourcing this file only defines functions and never opens confirmation.

`%||%` <- function(x, y) if (is.null(x)) y else x

mfrmr_fc_g4w_contract <-
  "mfrmr_fixed_calibration_g4_current_confirmation_worker_v1"

mfrmr_fc_g4w_cell_ids <- function() {
  c(
    "RSM_DEFAULT31_PROBABILITY_ORACLE",
    "PCM_DEFAULT31_PROBABILITY_ORACLE",
    "RSM_DEFAULT31_POSTERIOR_ORACLE",
    "PCM_DEFAULT31_POSTERIOR_ORACLE",
    "RSM_EXPLICIT9_HISTORICAL_CONTROL",
    "PCM_EXPLICIT9_HISTORICAL_CONTROL",
    "RSM_SOURCE1_DEFAULT31_POSTERIOR_ORACLE",
    "PCM_SOURCE1_DEFAULT31_POSTERIOR_ORACLE",
    "RSM_STEP_RANK_ORACLE", "PCM_STEP_RANK_ORACLE",
    "SCORING_ALGORITHM_MUTATION_REFUSAL",
    "QUADRATURE_ORDER_MUTATION_REFUSAL",
    "QUADRATURE_NODE_MUTATION_REFUSAL",
    "SIGN_MUTATION_REFUSAL", "COHERENT_SIGN_METAMORPHIC",
    "CATEGORY_MAP_MUTATION_REFUSAL", "EXTERNAL_SCORE_REVERSAL",
    "NAMESPACE_RECODING", "ROW_ORDER", "PERSON_CHUNK_ORDER",
    "C_COLLATION", "UTF8_RDS_ROUNDTRIP", "FRESH_VANILLA_PROCESS",
    "PRIOR_MUTATION_REFUSAL", "PRIOR_SENSITIVITY_ORACLE",
    "CORRUPT_COORDINATE_LOAD_REFUSAL",
    "ARTIFACT_NONFINITE_WEIGHT_REFUSAL",
    "ARTIFACT_NONPOSITIVE_WEIGHT_REFUSAL",
    "JML_SOURCE1_DEFAULT31_NONDEGENERATE",
    "EXPLICIT_SCORING_ONE_REFUSAL", "FITTED_NONREADY_DEFAULT_REFUSAL",
    "FITTED_NONREADY_REVIEW_LABEL", "FITTED_NONFINITE_WEIGHT_REFUSAL",
    "FITTED_NONPOSITIVE_WEIGHT_REFUSAL",
    "INTERACTION_REPLAY_FULL_ROUNDTRIP",
    "REPLAY_ARGUMENT_REGISTRY_COMPLETENESS",
    "REPLAY_SCORING_SETTING_PRESERVATION",
    "CHECKPOINT_SCORE_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_WEIGHT_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_FACET_LABEL_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_ANCHOR_MUTATION_SAME_LAYOUT_REFUSAL",
    "CHECKPOINT_QUADRATURE_MUTATION_REFUSAL",
    "HYBRID_CHECKPOINT_WRITE_RESUME", "CHECKPOINT_CROSS_STAGE_REFUSAL",
    "PURE_EM_SAME_MAXIT_REFUSAL", "PURE_EM_INCREASED_MAXIT_CONTINUATION",
    "CHECKPOINT_LEGACY_OR_CORRUPT_LAYOUT_REFUSAL",
    "CHECKPOINT_CONTROL_SCALAR_REFUSAL",
    "CHECKPOINT_CHECKED_ATOMIC_REPLACEMENT"
  )
}

mfrmr_fc_g4w_assert <- function(condition, detail) {
  if (!isTRUE(condition)) stop(detail, call. = FALSE)
  invisible(TRUE)
}

mfrmr_fc_g4w_error <- function(expression) {
  tryCatch(
    {
      force(expression)
      list(Error = FALSE, Class = character(), Code = "", Message = "")
    },
    error = function(condition) list(
      Error = TRUE, Class = class(condition),
      Code = as.character(condition$code %||% ""),
      Message = conditionMessage(condition)
    )
  )
}

mfrmr_fc_g4w_expect_error <- function(expression, code = NULL,
                                       pattern = NULL) {
  observed <- mfrmr_fc_g4w_error(expression)
  mfrmr_fc_g4w_assert(observed$Error, "The operation did not fail closed.")
  if (!is.null(code)) {
    mfrmr_fc_g4w_assert(
      identical(observed$Code, code),
      paste0("Unexpected refusal code: `", observed$Code, "`.")
    )
  }
  if (!is.null(pattern)) {
    mfrmr_fc_g4w_assert(
      grepl(pattern, observed$Message, fixed = TRUE),
      paste0("Unexpected refusal message: ", observed$Message)
    )
  }
  observed
}

mfrmr_fc_g4w_observation <- function(metric, observed, threshold = NA_real_,
                                      detail = "") {
  list(
    Metric = as.character(metric), Observed = as.numeric(observed),
    Threshold = as.numeric(threshold), Detail = as.character(detail)
  )
}

mfrmr_fc_g4w_deterministic_data <- function(n_person, prefix, offset,
                                             modulus) {
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
  eta <- theta - c(-0.45, -0.10, 0.20, 0.35)[rater_index] -
    c(-0.35, 0.05, 0.30)[criterion_index]
  cumulative <- c(0, cumsum(c(-0.55, 0.05, 0.50)))
  row_id <- seq_len(nrow(out)) + as.integer(offset)
  uniform <- ((
    row_id * 73L + person_index * 19L + rater_index * 11L +
      criterion_index * 7L
  ) %% as.integer(modulus) + 0.5) / as.integer(modulus)
  out$Score <- vapply(seq_len(nrow(out)), function(index) {
    logits <- 0:3 * eta[index] - cumulative
    probability <- exp(logits - max(logits))
    probability <- probability / sum(probability)
    which(cumsum(probability) >= uniform[index])[1L] - 1L
  }, integer(1L))
  out
}

mfrmr_fc_g4w_fixture <- function(family, role, design) {
  family <- match.arg(family, c("RSM", "PCM"))
  row <- design[
    design$Family == family & design$EvidenceRole == role, , drop = FALSE
  ]
  mfrmr_fc_g4w_assert(nrow(row) == 1L, "Frozen fixture identity is missing.")
  if (identical(role, "current_default31_confirmation")) {
    modulus <- 1009L
    source_prefix <- paste0("G4D31", substr(family, 1L, 1L), "S")
    confirmation_prefix <- paste0("G4D31", substr(family, 1L, 1L), "C")
    source_offset <- 127L
    confirmation_offset <- 613L
  } else if (identical(role, "one_node_source_fit_adversary")) {
    modulus <- 1013L
    source_prefix <- paste0("G4S01", substr(family, 1L, 1L), "S")
    confirmation_prefix <- paste0("G4S01", substr(family, 1L, 1L), "C")
    source_offset <- 263L
    confirmation_offset <- 709L
  } else {
    modulus <- 997L
    source_prefix <- paste0("G4H09", substr(family, 1L, 1L), "S")
    confirmation_prefix <- paste0("G4H09", substr(family, 1L, 1L), "C")
    source_offset <- 0L
    confirmation_offset <- 401L
  }
  source <- mfrmr_fc_g4w_deterministic_data(
    row$SourcePersons, source_prefix, source_offset, modulus
  )
  confirmation <- mfrmr_fc_g4w_deterministic_data(
    row$ConfirmationPersons, confirmation_prefix, confirmation_offset,
    modulus
  )
  confirmation$Weight <- rep(
    c(0.5, 1, 1.5, 2), length.out = nrow(confirmation)
  )
  fit <- suppressMessages(suppressWarnings(mfrmr::fit_mfrm(
    source, person = "Person", facets = c("Rater", "Criterion"),
    score = "Score", method = "MML", model = family,
    step_facet = if (identical(family, "PCM")) "Criterion" else NULL,
    quad_points = row$FitQuadratureOrder, maxit = 100,
    mml_engine = "direct"
  )))
  mfrmr_fc_g4w_assert(
    mfrmr:::mfrm_inference_ready(fit),
    paste0(family, " ", role, " source fit is not inference-ready.")
  )
  stamp <- if (identical(family, "RSM")) "00" else "10"
  draft <- mfrmr:::mfrmr_extract_calibration_draft(
    fit, calibration_id = row$CalibrationId,
    source_fit_id = row$SourceFixtureId,
    created_at_utc = paste0("2026-08-25T05:", stamp, ":00Z"),
    scoring_quad_points = row$ScoringQuadratureOrder
  )
  validated <- mfrmr:::mfrmr_validate_calibration_draft(
    draft, validated_at_utc = paste0("2026-08-25T05:", stamp, ":01Z")
  )
  frozen <- mfrmr:::mfrmr_freeze_calibration(
    validated, frozen_at_utc = paste0("2026-08-25T05:", stamp, ":02Z")
  )
  list(
    family = family, role = role, design = row, source = source,
    confirmation = confirmation, fit = fit, frozen = frozen
  )
}

mfrmr_fc_g4w_sorted_score <- function(score) {
  out <- score$estimates[
    order(score$estimates$Person),
    c("Person", "Estimate", "SD", "Lower", "Upper"), drop = FALSE
  ]
  rownames(out) <- NULL
  out
}

mfrmr_fc_g4w_oracle <- function(artifact, rows, interval_level = 0.84,
                                node_scale = 1) {
  mfrmr_fc_g4w_assert(
    nrow(artifact$model$interactions) == 0L,
    "The independent oracle supports additive artifacts only."
  )
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
            coordinates$Level == as.character(row[[facet]]), , drop = FALSE
        ]
        mfrmr_fc_g4w_assert(
          nrow(coordinate) == 1L, "Oracle facet coordinate is not unique."
        )
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
      logits <- outer(nodes + base_eta, categories) - matrix(
        cumulative, nrow = length(nodes), ncol = length(categories),
        byrow = TRUE
      )
      maxima <- apply(logits, 1L, max)
      independent <- exp(logits - maxima)
      independent <- independent / rowSums(independent)
      production <- if (identical(artifact$model$family, "RSM")) {
        mfrmr:::category_prob_rsm(nodes + base_eta, cumulative)
      } else {
        mfrmr:::category_prob_pcm(
          nodes + base_eta, matrix(cumulative, nrow = 1L),
          rep(1L, length(nodes))
        )
      }
      probability_error <- max(
        probability_error, abs(production - independent)
      )
      observed_internal <- score_map$InternalScore[
        match(row$Score, score_map$OriginalScore)
      ]
      observed_index <- observed_internal - artifact$response$rating_min + 1L
      log_likelihood <- log_likelihood +
        as.numeric(row$Weight) * log(independent[, observed_index])
    }
    shifted <- log_likelihood - max(log_likelihood)
    posterior <- weights * exp(shifted)
    posterior <- posterior / sum(posterior)
    estimate <- sum(nodes * posterior)
    quantile <- function(probability) {
      nodes[which(cumsum(posterior) >= probability)[1L]]
    }
    data.frame(
      Person = person, Estimate = estimate,
      SD = sqrt(sum(posterior * (nodes - estimate)^2)),
      Lower = quantile(alpha), Upper = quantile(1 - alpha),
      stringsAsFactors = FALSE
    )
  })
  estimates <- do.call(rbind, result)
  estimates <- estimates[order(estimates$Person), , drop = FALSE]
  rownames(estimates) <- NULL
  list(estimates = estimates, probability_error = probability_error)
}

mfrmr_fc_g4w_numeric_difference <- function(left, right) {
  columns <- c("Estimate", "SD", "Lower", "Upper")
  mfrmr_fc_g4w_assert(
    identical(as.character(left$Person), as.character(right$Person)),
    "Scored Person order differs from the oracle."
  )
  max(abs(as.matrix(left[columns]) - as.matrix(right[columns])))
}

mfrmr_fc_g4w_mock_config <- function(family) {
  levels <- list(
    Rater = c("R1", "R2", "R3"),
    Criterion = c("C1", "C2", "C3")
  )
  config <- list(
    model = family, method = "MML", n_cat = 5L,
    facet_names = names(levels), facet_levels = levels,
    step_facet = if (identical(family, "PCM")) "Criterion" else NULL,
    interaction_specs = list(), facet_interactions = character(),
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

mfrmr_fc_g4w_anchor <- function(family, level = NA_character_, step,
                                 value, order) {
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

mfrmr_fc_g4w_rank_observation <- function(family) {
  config <- mfrmr_fc_g4w_mock_config(family)
  if (identical(family, "RSM")) {
    anchors <- mfrmr_fc_g4w_anchor("RSM", step = 2L, value = 0.2, order = 1L)
    oracle <- matrix(c(1, 0, 0, 0, 0, 1, -1, -1), nrow = 4L,
                     byrow = TRUE)
    expected_rank <- 2L
  } else {
    anchors <- rbind(
      mfrmr_fc_g4w_anchor("PCM", "C1", 2L, 0.2, 1L),
      mfrmr_fc_g4w_anchor("PCM", "C2", 1L, -0.3, 2L),
      mfrmr_fc_g4w_anchor("PCM", "C2", 4L, 0.1, 3L)
    )
    c1 <- rbind(c(1, 0), c(0, 0), c(0, 1), c(-1, -1))
    c2 <- matrix(c(0, 1, -1, 0), ncol = 1L)
    c3 <- rbind(diag(3L), c(-1, -1, -1))
    oracle <- matrix(0, nrow = 12L, ncol = 6L)
    oracle[1:4, 1:2] <- c1
    oracle[5:8, 3] <- c2[, 1L]
    oracle[9:12, 4:6] <- c3
    expected_rank <- 6L
  }
  applied <- mfrmr:::mfrmr_apply_typed_anchors(config, anchors)$config
  actual <- as.matrix(mfrmr:::mfrmr_step_jacobian_sparse(
    applied, mfrmr:::build_param_sizes(applied)
  )$jacobian)
  error <- max(abs(unname(actual) - oracle))
  mfrmr_fc_g4w_assert(error == 0, "Step Jacobian differs from the oracle.")
  mfrmr_fc_g4w_assert(
    identical(qr(oracle)$rank, expected_rank), "Step rank differs."
  )
  mfrmr_fc_g4w_observation(
    "maximum absolute Jacobian difference", error, 0,
    paste0("rank=", expected_rank)
  )
}

mfrmr_fc_g4w_rehash_artifact <- function(artifact) {
  artifact$integrity$semantic_components <-
    mfrmr:::mfrmr_calibration_semantic_components(artifact)
  artifact
}

mfrmr_fc_g4w_replay <- function(fit, data, prefix, unit_prediction = NULL) {
  directory <- tempfile("mfrmr-g4-replay-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE, force = TRUE), add = TRUE)
  old <- getwd()
  on.exit(setwd(old), add = TRUE)
  setwd(directory)
  mfrmr::export_mfrm_bundle(
    fit, unit_prediction = unit_prediction, output_dir = ".", prefix = prefix,
    include = c("core_tables", "manifest", "predictions", "script"),
    data = data, acknowledge_sensitive = TRUE
  )
  environment <- new.env(parent = globalenv())
  suppressMessages(suppressWarnings(sys.source(
    file.path(directory, paste0(prefix, "_replay.R")), envir = environment
  )))
  environment
}

mfrmr_fc_g4w_checkpoint_fit <- function(data, checkpoint, maxit = 3L,
                                         engine = "em", quad_points = 5L,
                                         weight = NULL, anchors = NULL) {
  suppressMessages(suppressWarnings(mfrmr::fit_mfrm(
    data, "Person", c("Rater", "Criterion"), "Score",
    weight = weight, anchors = anchors, method = "MML",
    quad_points = quad_points, maxit = maxit, mml_engine = engine,
    checkpoint = list(file = checkpoint, every_iter = 1L)
  )))
}

mfrmr_fc_g4w_profile_score <- function(artifact, rows) {
  profile <- tempfile(fileext = ".out")
  on.exit(unlink(profile), add = TRUE)
  gc()
  utils::Rprofmem(profile, threshold = 1000)
  timing <- system.time(result <- mfrmr:::mfrmr_score_calibration(
    artifact, rows, weight = "Weight", interval_level = 0.84
  ))
  utils::Rprofmem(NULL)
  allocations <- readLines(profile, warn = FALSE)
  allocations <- allocations[grepl("^[0-9]+", allocations)]
  allocated <- if (length(allocations) == 0L) 0 else {
    sum(as.numeric(sub(" .*", "", allocations)))
  }
  list(
    Elapsed = unname(timing[["elapsed"]]), Allocated = allocated,
    ResultBytes = length(serialize(result, NULL, version = 3)), Result = result
  )
}

# The handler factory is appended below. Keeping the cell IDs in this file lets
# candidate binding verify the complete denominator without executing a cell.

mfrmr_fc_g4w_current_handlers <- function(contract_environment,
                                           package_root, worker_path) {
  rules <- contract_environment$mfrmr_fc_g4_current_numerical_rules()
  design <- contract_environment$mfrmr_fc_g4_current_confirmation_design()
  tolerance <- function(rule) rules$Threshold[rules$RuleId == rule]
  cache <- new.env(parent = emptyenv())
  memo <- function(key, expression) {
    if (!exists(key, envir = cache, inherits = FALSE)) {
      assign(key, tryCatch(force(expression), error = identity), envir = cache)
    }
    value <- get(key, envir = cache, inherits = FALSE)
    if (inherits(value, "error")) stop(value)
    value
  }
  fixture <- function(family, role) memo(
    paste("fixture", family, role, sep = "::"),
    mfrmr_fc_g4w_fixture(family, role, design)
  )
  score <- function(family, role) {
    item <- fixture(family, role)
    memo(paste("score", family, role, sep = "::"),
         mfrmr:::mfrmr_score_calibration(
           item$frozen, item$confirmation, weight = "Weight",
           interval_level = 0.84
         ))
  }
  oracle <- function(family, role) {
    item <- fixture(family, role)
    memo(paste("oracle", family, role, sep = "::"),
         mfrmr_fc_g4w_oracle(
           item$frozen, item$confirmation, interval_level = 0.84
         ))
  }
  posterior_cell <- function(family, role, rule) {
    difference <- mfrmr_fc_g4w_numeric_difference(
      mfrmr_fc_g4w_sorted_score(score(family, role)),
      oracle(family, role)$estimates
    )
    threshold <- tolerance(rule)
    mfrmr_fc_g4w_assert(
      difference <= threshold, "Posterior oracle tolerance was exceeded."
    )
    mfrmr_fc_g4w_observation(
      "maximum absolute EAP/SD/interval difference", difference, threshold
    )
  }
  probability_cell <- function(family) {
    difference <- oracle(
      family, "current_default31_confirmation"
    )$probability_error
    threshold <- tolerance("PROBABILITY_ABSOLUTE")
    mfrmr_fc_g4w_assert(
      difference <= threshold, "Category-probability tolerance was exceeded."
    )
    mfrmr_fc_g4w_observation(
      "maximum absolute category-probability difference", difference,
      threshold
    )
  }
  base <- function() fixture("RSM", "current_default31_confirmation")
  base_score <- function() score("RSM", "current_default31_confirmation")
  baseline_numeric <- function() mfrmr_fc_g4w_sorted_score(base_score())
  score_difference <- function(value) {
    mfrmr_fc_g4w_numeric_difference(
      mfrmr_fc_g4w_sorted_score(value), baseline_numeric()
    )
  }
  jml <- function() memo("jml-source1", {
    item <- fixture("RSM", "one_node_source_fit_adversary")
    suppressMessages(suppressWarnings(mfrmr::fit_mfrm(
      item$source, "Person", c("Rater", "Criterion"), "Score",
      method = "JML", model = "RSM", quad_points = 1L, maxit = 75L
    )))
  })
  jml_rows <- function() fixture(
    "RSM", "one_node_source_fit_adversary"
  )$confirmation
  fitted_score <- function(readiness_policy = "error", quad = 31L,
                           fit = jml(), rows = jml_rows()) {
    mfrmr::predict_mfrm_units(
      fit, rows, weight = "Weight", scoring_quad_points = quad,
      readiness_policy = readiness_policy, interval_level = 0.84
    )
  }
  checkpoint_data <- function(weighted = FALSE) memo(
    paste0("checkpoint-data-", weighted), {
      data <- mfrmr::load_mfrmr_data("example_core")
      if (weighted) {
        data$Weight <- rep(c(0.75, 1, 1.25), length.out = nrow(data))
      }
      data
    }
  )
  checkpoint_base <- function(kind = "plain") memo(
    paste0("checkpoint-base-", kind), {
      path <- tempfile(fileext = ".rds")
      on.exit(unlink(path), add = TRUE)
      data <- checkpoint_data(identical(kind, "weighted"))
      anchors <- if (identical(kind, "anchored")) c(R01 = 0) else NULL
      fit <- mfrmr_fc_g4w_checkpoint_fit(
        data, path,
        weight = if (identical(kind, "weighted")) "Weight" else NULL,
        anchors = anchors
      )
      list(Saved = readRDS(path), Fit = fit, Data = data, Anchors = anchors)
    }
  )
  with_checkpoint <- function(saved, expression) {
    path <- tempfile(fileext = ".rds")
    on.exit(unlink(path), add = TRUE)
    saveRDS(saved, path, version = 3)
    force(expression(path))
  }

  handlers <- list()
  handlers[["RSM_DEFAULT31_PROBABILITY_ORACLE"]] <- function() {
    probability_cell("RSM")
  }
  handlers[["PCM_DEFAULT31_PROBABILITY_ORACLE"]] <- function() {
    probability_cell("PCM")
  }
  handlers[["RSM_DEFAULT31_POSTERIOR_ORACLE"]] <- function() posterior_cell(
    "RSM", "current_default31_confirmation", "POSTERIOR_DEFAULT31_ABSOLUTE"
  )
  handlers[["PCM_DEFAULT31_POSTERIOR_ORACLE"]] <- function() posterior_cell(
    "PCM", "current_default31_confirmation", "POSTERIOR_DEFAULT31_ABSOLUTE"
  )
  handlers[["RSM_EXPLICIT9_HISTORICAL_CONTROL"]] <- function() posterior_cell(
    "RSM", "historical_explicit9_regression_control",
    "POSTERIOR_EXPLICIT9_CONTROL_ABSOLUTE"
  )
  handlers[["PCM_EXPLICIT9_HISTORICAL_CONTROL"]] <- function() posterior_cell(
    "PCM", "historical_explicit9_regression_control",
    "POSTERIOR_EXPLICIT9_CONTROL_ABSOLUTE"
  )
  handlers[["RSM_SOURCE1_DEFAULT31_POSTERIOR_ORACLE"]] <- function() {
    posterior_cell(
      "RSM", "one_node_source_fit_adversary", "SOURCE1_POSTERIOR_ABSOLUTE"
    )
  }
  handlers[["PCM_SOURCE1_DEFAULT31_POSTERIOR_ORACLE"]] <- function() {
    posterior_cell(
      "PCM", "one_node_source_fit_adversary", "SOURCE1_POSTERIOR_ABSOLUTE"
    )
  }
  handlers[["RSM_STEP_RANK_ORACLE"]] <- function() {
    mfrmr_fc_g4w_rank_observation("RSM")
  }
  handlers[["PCM_STEP_RANK_ORACLE"]] <- function() {
    mfrmr_fc_g4w_rank_observation("PCM")
  }
  handlers[["SCORING_ALGORITHM_MUTATION_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$scoring_basis$scoring_algorithm <- "mutated_algorithm"
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        altered, base()$confirmation, weight = "Weight"
      ), "IDENTITY_COMPONENT_MISMATCH"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["QUADRATURE_ORDER_MUTATION_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$scoring_basis$quadrature_order <- 30L
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        altered, base()$confirmation, weight = "Weight"
      ), "IDENTITY_COMPONENT_MISMATCH"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["QUADRATURE_NODE_MUTATION_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$scoring_basis$nodes[1L] <- altered$scoring_basis$nodes[1L] + 0.01
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        altered, base()$confirmation, weight = "Weight"
      ), "IDENTITY_COMPONENT_MISMATCH"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["SIGN_MUTATION_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$model$facet_signs[1L] <- -altered$model$facet_signs[1L]
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        altered, base()$confirmation, weight = "Weight"
      ), "IDENTITY_COMPONENT_MISMATCH"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["COHERENT_SIGN_METAMORPHIC"]] <- function() {
    altered <- base()$frozen
    altered$model$facet_signs <- -altered$model$facet_signs
    facet <- altered$parameters$coordinates$ParameterClass == "facet"
    altered$parameters$coordinates$Value[facet] <-
      -altered$parameters$coordinates$Value[facet]
    altered <- mfrmr_fc_g4w_rehash_artifact(altered)
    difference <- score_difference(mfrmr:::mfrmr_score_calibration(
      altered, base()$confirmation, weight = "Weight", interval_level = 0.84
    ))
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "Coherent sign invariance failed.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["CATEGORY_MAP_MUTATION_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$response$score_map$OriginalScore <-
      rev(altered$response$score_map$OriginalScore)
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        altered, base()$confirmation, weight = "Weight"
      ), "IDENTITY_COMPONENT_MISMATCH"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["EXTERNAL_SCORE_REVERSAL"]] <- function() {
    original <- base()$frozen
    altered <- original
    altered$response$score_map$OriginalScore <-
      rev(altered$response$score_map$OriginalScore)
    altered <- mfrmr_fc_g4w_rehash_artifact(altered)
    rows <- base()$confirmation
    rows$Score <- altered$response$score_map$OriginalScore[
      match(rows$Score, original$response$score_map$OriginalScore)
    ]
    difference <- score_difference(mfrmr:::mfrmr_score_calibration(
      altered, rows, weight = "Weight", interval_level = 0.84
    ))
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "External reversal invariance failed.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["NAMESPACE_RECODING"]] <- function() {
    altered <- base()$frozen
    replacements <- c(
      Judge_A = "判定者_甲", Judge_B = "判定者_乙",
      Judge_C = "判定者_丙", Judge_D = "判定者_丁"
    )
    level <- altered$model$facet_levels$Facet == "Rater"
    altered$model$facet_levels$Level[level] <-
      unname(replacements[altered$model$facet_levels$Level[level]])
    coordinate <- altered$parameters$coordinates$ParameterClass == "facet" &
      altered$parameters$coordinates$OwnerFacet == "Rater"
    altered$parameters$coordinates$Level[coordinate] <- unname(
      replacements[altered$parameters$coordinates$Level[coordinate]]
    )
    altered <- mfrmr_fc_g4w_rehash_artifact(altered)
    rows <- base()$confirmation
    rows$Rater <- unname(replacements[rows$Rater])
    difference <- score_difference(mfrmr:::mfrmr_score_calibration(
      altered, rows, weight = "Weight", interval_level = 0.84
    ))
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "Namespace recoding changed scores.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["ROW_ORDER"]] <- function() {
    rows <- base()$confirmation
    difference <- score_difference(mfrmr:::mfrmr_score_calibration(
      base()$frozen, rows[rev(seq_len(nrow(rows))), , drop = FALSE],
      weight = "Weight", interval_level = 0.84
    ))
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "Row ordering changed scores.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["PERSON_CHUNK_ORDER"]] <- function() {
    chunks <- split(base()$confirmation, base()$confirmation$Person)
    estimates <- do.call(rbind, lapply(rev(chunks), function(rows) {
      mfrmr:::mfrmr_score_calibration(
        base()$frozen, rows, weight = "Weight", interval_level = 0.84
      )$estimates
    }))
    actual <- estimates[
      order(estimates$Person), c("Person", "Estimate", "SD", "Lower", "Upper"),
      drop = FALSE
    ]
    rownames(actual) <- NULL
    difference <- mfrmr_fc_g4w_numeric_difference(actual, baseline_numeric())
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "Chunk ordering changed scores.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["C_COLLATION"]] <- function() {
    old <- Sys.getlocale("LC_COLLATE")
    on.exit(suppressWarnings(Sys.setlocale("LC_COLLATE", old)), add = TRUE)
    mfrmr_fc_g4w_assert(
      identical(Sys.setlocale("LC_COLLATE", "C"), "C"),
      "The C collation locale is unavailable."
    )
    difference <- score_difference(mfrmr:::mfrmr_score_calibration(
      base()$frozen, base()$confirmation, weight = "Weight",
      interval_level = 0.84
    ))
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "C collation changed scores.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["UTF8_RDS_ROUNDTRIP"]] <- function() {
    artifact_path <- tempfile(fileext = ".rds")
    input_path <- tempfile(fileext = ".rds")
    on.exit(unlink(c(artifact_path, input_path)), add = TRUE)
    rows <- base()$confirmation
    rows$Person <- enc2utf8(rows$Person)
    rows$Rater <- enc2utf8(rows$Rater)
    rows$Criterion <- enc2utf8(rows$Criterion)
    mfrmr:::mfrmr_save_calibration(base()$frozen, artifact_path)
    saveRDS(rows, input_path, version = 3)
    difference <- score_difference(mfrmr:::mfrmr_score_calibration(
      mfrmr:::mfrmr_load_calibration(artifact_path), readRDS(input_path),
      weight = "Weight", interval_level = 0.84
    ))
    threshold <- tolerance("METAMORPHIC_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "UTF-8 RDS roundtrip changed scores.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["FRESH_VANILLA_PROCESS"]] <- function() {
    artifact_path <- tempfile(fileext = ".rds")
    input_path <- tempfile(fileext = ".rds")
    output_path <- tempfile(fileext = ".rds")
    unlink(output_path)
    on.exit(unlink(c(artifact_path, input_path, output_path)), add = TRUE)
    mfrmr:::mfrmr_save_calibration(base()$frozen, artifact_path)
    saveRDS(base()$confirmation, input_path, version = 3)
    rscript <- file.path(R.home("bin"), "Rscript")
    if (.Platform$OS.type == "windows") rscript <- paste0(rscript, ".exe")
    output <- system2(
      rscript,
      c("--vanilla", worker_path, package_root, artifact_path, input_path,
        output_path, "C"), stdout = TRUE, stderr = TRUE
    )
    status <- attr(output, "status") %||% 0L
    mfrmr_fc_g4w_assert(status == 0L, paste(output, collapse = "\n"))
    child <- readRDS(output_path)
    mfrmr_fc_g4w_assert(
      identical(child$load_mode, "installed_library"),
      "Fresh process did not use the isolated installed package."
    )
    child_numeric <- child$estimates[
      order(child$estimates$Person),
      c("Person", "Estimate", "SD", "Lower", "Upper"), drop = FALSE
    ]
    rownames(child_numeric) <- NULL
    difference <- mfrmr_fc_g4w_numeric_difference(
      child_numeric, baseline_numeric()
    )
    threshold <- tolerance("PLATFORM_SCORE_ABSOLUTE")
    mfrmr_fc_g4w_assert(difference <= threshold, "Fresh-process score changed.")
    mfrmr_fc_g4w_observation("maximum absolute score difference", difference, threshold)
  }
  handlers[["PRIOR_MUTATION_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$scoring_basis$prior_sd <- 1.5
    altered <- mfrmr_fc_g4w_rehash_artifact(altered)
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        altered, base()$confirmation, weight = "Weight"
      ), "SCORING_PRIOR_INVALID"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["PRIOR_SENSITIVITY_ORACLE"]] <- function() {
    baseline <- oracle("RSM", "current_default31_confirmation")$estimates
    narrow <- mfrmr_fc_g4w_oracle(
      base()$frozen, base()$confirmation, node_scale = 0.7
    )$estimates
    wide <- mfrmr_fc_g4w_oracle(
      base()$frozen, base()$confirmation, node_scale = 1.5
    )$estimates
    sensitivity <- max(
      abs(narrow$Estimate - baseline$Estimate),
      abs(wide$Estimate - baseline$Estimate)
    )
    threshold <- tolerance("PRIOR_SENSITIVITY_REVIEW")
    mfrmr_fc_g4w_assert(
      is.finite(sensitivity) && sensitivity >= threshold,
      "Prior-sensitivity review threshold was not reached."
    )
    mfrmr_fc_g4w_observation(
      "maximum absolute EAP sensitivity", sensitivity, threshold,
      "material review retained; no robustness claim"
    )
  }
  handlers[["CORRUPT_COORDINATE_LOAD_REFUSAL"]] <- function() {
    altered <- base()$frozen
    altered$parameters$coordinates$Value[1L] <-
      altered$parameters$coordinates$Value[1L] + 0.125
    path <- tempfile(fileext = ".rds")
    on.exit(unlink(path), add = TRUE)
    saveRDS(altered, path, version = 3)
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_load_calibration(path), "IDENTITY_COMPONENT_MISMATCH"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["ARTIFACT_NONFINITE_WEIGHT_REFUSAL"]] <- function() {
    rows <- base()$confirmation
    rows$Weight[1L] <- Inf
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        base()$frozen, rows, weight = "Weight"
      ), "SCORING_WEIGHT_INVALID"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["ARTIFACT_NONPOSITIVE_WEIGHT_REFUSAL"]] <- function() {
    rows <- base()$confirmation
    rows$Weight[1L] <- 0
    error <- mfrmr_fc_g4w_expect_error(
      mfrmr:::mfrmr_score_calibration(
        base()$frozen, rows, weight = "Weight"
      ), "SCORING_WEIGHT_INVALID"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Code)
  }
  handlers[["JML_SOURCE1_DEFAULT31_NONDEGENERATE"]] <- function() {
    prediction <- fitted_score()
    minimum_sd <- min(prediction$estimates$SD)
    threshold <- tolerance("NONDEGENERATE_POSTERIOR_SD")
    mfrmr_fc_g4w_assert(
      identical(prediction$settings$scoring_quad_points, 31L) &&
        is.finite(minimum_sd) && minimum_sd > threshold,
      "JML one-node source fit produced a degenerate default score."
    )
    mfrmr_fc_g4w_observation("minimum posterior SD", minimum_sd, threshold)
  }
  handlers[["EXPLICIT_SCORING_ONE_REFUSAL"]] <- function() {
    error <- mfrmr_fc_g4w_expect_error(
      fitted_score(quad = 1L), pattern = "greater than or equal to 2"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["FITTED_NONREADY_DEFAULT_REFUSAL"]] <- function() {
    altered <- jml()
    altered$readiness$fit$FitReadiness[1L] <- "blocked"
    altered$readiness$fit$InferenceReady[1L] <- FALSE
    altered$readiness$fit$NumericalState[1L] <- "failed"
    altered$readiness$fit$ReasonCodes[1L] <- "g4_nonready_source"
    altered$summary$FitReadiness[1L] <- "blocked"
    altered$summary$InferenceReady[1L] <- FALSE
    altered$summary$NumericalState[1L] <- "failed"
    altered$summary$ReadinessReasonCodes[1L] <- "g4_nonready_source"
    error <- mfrmr_fc_g4w_expect_error(
      fitted_score(fit = altered), pattern = "not ready for fitted-object scoring"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["FITTED_NONREADY_REVIEW_LABEL"]] <- function() {
    altered <- jml()
    altered$readiness$fit$FitReadiness[1L] <- "blocked"
    altered$readiness$fit$InferenceReady[1L] <- FALSE
    altered$readiness$fit$NumericalState[1L] <- "failed"
    altered$readiness$fit$ReasonCodes[1L] <- "g4_nonready_source"
    altered$summary$FitReadiness[1L] <- "blocked"
    altered$summary$InferenceReady[1L] <- FALSE
    altered$summary$NumericalState[1L] <- "failed"
    altered$summary$ReadinessReasonCodes[1L] <- "g4_nonready_source"
    prediction <- fitted_score(readiness_policy = "review", fit = altered)
    mfrmr_fc_g4w_assert(
      all(!prediction$estimates$SourceScoringReady) &&
        identical(prediction$settings$source_scoring_status, "review_only") &&
        all(prediction$estimates$EstimateUse == "review_only_nonready_source"),
      "Non-ready review scores were not visibly labelled."
    )
    mfrmr_fc_g4w_observation("review-only labels retained", 1, 1)
  }
  handlers[["FITTED_NONFINITE_WEIGHT_REFUSAL"]] <- function() {
    rows <- jml_rows()
    rows$Weight[1L] <- Inf
    error <- mfrmr_fc_g4w_expect_error(
      fitted_score(rows = rows), pattern = "finite and strictly positive"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["FITTED_NONPOSITIVE_WEIGHT_REFUSAL"]] <- function() {
    rows <- jml_rows()
    rows$Weight[1L] <- 0
    error <- mfrmr_fc_g4w_expect_error(
      fitted_score(rows = rows), pattern = "finite and strictly positive"
    )
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["INTERACTION_REPLAY_FULL_ROUNDTRIP"]] <- function() {
    data <- fixture("RSM", "current_default31_confirmation")$source
    fit <- memo("interaction-fit", suppressMessages(suppressWarnings(
      mfrmr::fit_mfrm(
        data, "Person", c("Rater", "Criterion"), "Score", method = "JML",
        maxit = 40L, facet_interactions = "Rater:Criterion",
        min_obs_per_interaction = 0, interaction_policy = "error"
      )
    )))
    replayed <- mfrmr_fc_g4w_replay(fit, data, "g4_interaction")$fit
    original_interaction <- as.data.frame(
      mfrmr::interaction_effect_table(fit)
    )
    replayed_interaction <- as.data.frame(
      mfrmr::interaction_effect_table(replayed)
    )
    differences <- c(
      abs(replayed$summary$LogLik - fit$summary$LogLik),
      max(abs(replayed_interaction$Estimate - original_interaction$Estimate)),
      max(abs(replayed$facets$others$Estimate - fit$facets$others$Estimate))
    )
    mfrmr_fc_g4w_assert(
      identical(names(replayed$config$interaction_specs),
                names(fit$config$interaction_specs)) &&
        identical(length(replayed$opt$par), length(fit$opt$par)) &&
        identical(replayed$summary$FitReadiness, fit$summary$FitReadiness) &&
        max(differences) <= 1e-6,
      "Interaction replay did not preserve the full fit."
    )
    mfrmr_fc_g4w_observation(
      "maximum interaction replay difference", max(differences), 1e-6
    )
  }
  handlers[["REPLAY_ARGUMENT_REGISTRY_COMPLETENESS"]] <- function() {
    replay_inputs <- list(
      person = "Person", facets = c("Rater", "Criterion"), score = "Score",
      model = "RSM", method = "JML", facet_interactions = "Rater:Criterion",
      min_obs_per_interaction = 3, interaction_policy = "error",
      population_policy = "error", package_version = "0.2.4.9000"
    )
    lines <- mfrmr:::build_replay_fit_mfrm_lines(
      replay_inputs = replay_inputs, fit_population = list(active = FALSE),
      fit_population_person_id = NULL,
      src = list(
        person = "Person", facets = c("Rater", "Criterion"), score = "Score"
      ), cfg = list(model = "RSM", method = "JML")
    )
    call <- parse(text = paste(lines, collapse = "\n"))[[1L]][[3L]]
    emitted <- names(as.list(call)[-1L])
    material <- setdiff(
      names(replay_inputs), c("population_policy", "package_version")
    )
    missing <- setdiff(material, emitted)
    mfrmr_fc_g4w_assert(length(missing) == 0L, paste(missing, collapse = ", "))
    mfrmr_fc_g4w_observation(
      "unhandled material replay fields", length(missing), 0
    )
  }
  handlers[["REPLAY_SCORING_SETTING_PRESERVATION"]] <- function() {
    prediction <- fitted_score(quad = 17L)
    environment <- mfrmr_fc_g4w_replay(
      jml(), fixture("RSM", "one_node_source_fit_adversary")$source,
      "g4_scoring", unit_prediction = prediction
    )
    mfrmr_fc_g4w_assert(
      identical(environment$unit_prediction$settings$scoring_quad_points, 17L),
      "Replay did not preserve scoring quadrature."
    )
    difference <- mfrmr_fc_g4w_numeric_difference(
      mfrmr_fc_g4w_sorted_score(environment$unit_prediction),
      mfrmr_fc_g4w_sorted_score(prediction)
    )
    mfrmr_fc_g4w_assert(difference <= 1e-12, "Replayed unit scores changed.")
    mfrmr_fc_g4w_observation(
      "maximum replayed scoring difference", difference, 1e-12
    )
  }
  handlers[["CHECKPOINT_SCORE_MUTATION_SAME_LAYOUT_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base()
    changed <- base_checkpoint$Data
    index <- which(changed$Score > min(changed$Score))[1L]
    changed$Score[index] <- changed$Score[index] - 1L
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(changed, path, maxit = 6L),
        pattern = "checkpoint identity does not match"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["CHECKPOINT_WEIGHT_MUTATION_SAME_LAYOUT_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base("weighted")
    changed <- base_checkpoint$Data
    changed$Weight[1L] <- changed$Weight[1L] * 1.25
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(
          changed, path, maxit = 6L, weight = "Weight"
        ), pattern = "checkpoint identity does not match"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["CHECKPOINT_FACET_LABEL_MUTATION_SAME_LAYOUT_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base()
    changed <- base_checkpoint$Data
    level <- unique(changed$Rater)[1L]
    changed$Rater[changed$Rater == level] <- paste0(level, "_changed")
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(changed, path, maxit = 6L),
        pattern = "checkpoint identity does not match"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["CHECKPOINT_ANCHOR_MUTATION_SAME_LAYOUT_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base("anchored")
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(
          base_checkpoint$Data, path, maxit = 6L, anchors = c(R01 = 0.1)
        ), pattern = "checkpoint identity does not match"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["CHECKPOINT_QUADRATURE_MUTATION_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base()
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(
          base_checkpoint$Data, path, maxit = 6L, quad_points = 7L
        ), pattern = "checkpoint identity does not match"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["HYBRID_CHECKPOINT_WRITE_RESUME"]] <- function() {
    path <- tempfile(fileext = ".rds")
    on.exit(unlink(path), add = TRUE)
    first <- mfrmr_fc_g4w_checkpoint_fit(
      checkpoint_data(), path, maxit = 5L, engine = "hybrid"
    )
    saved <- readRDS(path)
    messages <- capture.output(
      second <- mfrmr_fc_g4w_checkpoint_fit(
        checkpoint_data(), path, maxit = 5L, engine = "hybrid"
      ), type = "message"
    )
    mfrmr_fc_g4w_assert(
      inherits(first, "mfrm_fit") && inherits(second, "mfrm_fit") &&
        identical(saved$identity$engine_stage, "hybrid_em_warm_start") &&
        isTRUE(saved$completed) && any(grepl(
          "Loaded completed hybrid EM warm-start checkpoint", messages,
          fixed = TRUE
        )), "Hybrid checkpoint did not write and resume."
    )
    mfrmr_fc_g4w_observation("hybrid write/resume observed", 1, 1)
  }
  handlers[["CHECKPOINT_CROSS_STAGE_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base()
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(
          base_checkpoint$Data, path, maxit = 6L, engine = "hybrid"
        ), pattern = "checkpoint identity does not match"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["PURE_EM_SAME_MAXIT_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base()
    error <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_expect_error(
        mfrmr_fc_g4w_checkpoint_fit(base_checkpoint$Data, path, maxit = 3L),
        pattern = "already reached the requested `maxit`"
      )
    })
    mfrmr_fc_g4w_observation("refusal observed", 1, 1, error$Message)
  }
  handlers[["PURE_EM_INCREASED_MAXIT_CONTINUATION"]] <- function() {
    base_checkpoint <- checkpoint_base()
    resumed <- with_checkpoint(base_checkpoint$Saved, function(path) {
      mfrmr_fc_g4w_checkpoint_fit(base_checkpoint$Data, path, maxit = 6L)
    })
    fresh_path <- tempfile(fileext = ".rds")
    on.exit(unlink(fresh_path), add = TRUE)
    uninterrupted <- mfrmr_fc_g4w_checkpoint_fit(
      base_checkpoint$Data, fresh_path, maxit = 6L
    )
    parameter_difference <- max(abs(resumed$opt$par - uninterrupted$opt$par))
    loglik_difference <- abs(
      resumed$summary$LogLik - uninterrupted$summary$LogLik
    )
    parameter_threshold <- tolerance("CHECKPOINT_PARAMETER_ABSOLUTE")
    loglik_threshold <- tolerance("CHECKPOINT_LOGLIK_ABSOLUTE")
    mfrmr_fc_g4w_assert(
      parameter_difference <= parameter_threshold &&
        loglik_difference <= loglik_threshold,
      "Resumed pure EM differs from uninterrupted EM."
    )
    mfrmr_fc_g4w_observation(
      "maximum normalized continuation difference",
      max(parameter_difference / parameter_threshold,
          loglik_difference / loglik_threshold), 1,
      paste0("parameter=", parameter_difference, "; loglik=", loglik_difference)
    )
  }
  handlers[["CHECKPOINT_LEGACY_OR_CORRUPT_LAYOUT_REFUSAL"]] <- function() {
    base_checkpoint <- checkpoint_base()
    legacy <- tempfile(fileext = ".rds")
    corrupt <- tempfile(fileext = ".rds")
    on.exit(unlink(c(legacy, corrupt)), add = TRUE)
    saveRDS(list(.mfrm_checkpoint_kind = "mml_em"), legacy, version = 3)
    first <- mfrmr_fc_g4w_expect_error(
      mfrmr_fc_g4w_checkpoint_fit(base_checkpoint$Data, legacy, maxit = 6L),
      pattern = "unsupported or legacy MML EM schema"
    )
    changed <- base_checkpoint$Saved
    names(changed$par)[1L] <- paste0(names(changed$par)[1L], "_changed")
    saveRDS(changed, corrupt, version = 3)
    second <- mfrmr_fc_g4w_expect_error(
      mfrmr_fc_g4w_checkpoint_fit(base_checkpoint$Data, corrupt, maxit = 6L),
      pattern = "parameter vector is non-finite or incompatible"
    )
    mfrmr_fc_g4w_observation(
      "legacy and corrupt refusals observed", 2, 2,
      paste(first$Message, second$Message, sep = " | ")
    )
  }
  handlers[["CHECKPOINT_CONTROL_SCALAR_REFUSAL"]] <- function() {
    data <- checkpoint_data()
    refusals <- vapply(list(NA_integer_, Inf, 0, 1.5), function(value) {
      path <- tempfile(fileext = ".rds")
      on.exit(unlink(path), add = TRUE)
      mfrmr_fc_g4w_expect_error(
        suppressWarnings(mfrmr::fit_mfrm(
          data, "Person", c("Rater", "Criterion"), "Score", method = "MML",
          quad_points = 5L, maxit = 3L, mml_engine = "em",
          checkpoint = list(file = path, every_iter = value)
        )), pattern = "finite positive integer"
      )$Error
    }, logical(1L))
    mfrmr_fc_g4w_assert(all(refusals), "A checkpoint scalar was accepted.")
    mfrmr_fc_g4w_observation("invalid control scalars refused", sum(refusals), 4)
  }
  handlers[["CHECKPOINT_CHECKED_ATOMIC_REPLACEMENT"]] <- function() {
    directory <- tempfile("mfrmr-g4-atomic-")
    dir.create(directory)
    on.exit(unlink(directory, recursive = TRUE, force = TRUE), add = TRUE)
    path <- file.path(directory, "checkpoint.rds")
    saveRDS(list(Serial = 1L), path, version = 3)
    mfrmr:::mfrm_atomic_save_checkpoint(list(Serial = 2L), path)
    residue <- list.files(
      directory, pattern = "[.](partial|previous)-", all.files = TRUE
    )
    mfrmr_fc_g4w_assert(
      identical(readRDS(path), list(Serial = 2L)) && length(residue) == 0L,
      "Checked atomic replacement did not install exactly one payload."
    )
    mfrmr_fc_g4w_observation("installed payload serial", 2, 2)
  }
  handlers
}

mfrmr_fc_g4w_evaluate <- function(handlers, denominator) {
  ids <- mfrmr_fc_g4w_cell_ids()
  mfrmr_fc_g4w_assert(
    identical(ids, denominator$CellId),
    "Worker and frozen denominator order differ."
  )
  mfrmr_fc_g4w_assert(
    identical(names(handlers), ids),
    "Worker handler registry is incomplete or reordered."
  )
  rows <- lapply(seq_along(ids), function(index) {
    started <- proc.time()[["elapsed"]]
    value <- tryCatch(handlers[[ids[index]]](), error = identity)
    elapsed <- proc.time()[["elapsed"]] - started
    if (inherits(value, "error")) {
      data.frame(
        Ordinal = as.integer(index), CellId = ids[index],
        ClaimGroup = denominator$ClaimGroup[index], Pass = FALSE,
        Status = "retained_failure", Metric = "execution error",
        Observed = NA_real_, Threshold = NA_real_,
        Detail = conditionMessage(value), ElapsedSeconds = elapsed,
        stringsAsFactors = FALSE
      )
    } else {
      data.frame(
        Ordinal = as.integer(index), CellId = ids[index],
        ClaimGroup = denominator$ClaimGroup[index], Pass = TRUE,
        Status = "pass", Metric = value$Metric,
        Observed = value$Observed, Threshold = value$Threshold,
        Detail = value$Detail, ElapsedSeconds = elapsed,
        stringsAsFactors = FALSE
      )
    }
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_fc_g4w_resources <- function(artifact, confirmation, budgets) {
  artifact_bytes <- length(serialize(artifact, NULL, version = 3))
  template <- confirmation[
    confirmation$Person == confirmation$Person[1L],
    c("Person", "Rater", "Criterion", "Score", "Weight"), drop = FALSE
  ]
  rows <- lapply(seq_len(nrow(budgets)), function(index) {
    data <- template[
      rep(seq_len(nrow(template)), budgets$Persons[index]), , drop = FALSE
    ]
    data$Person <- rep(
      sprintf("G4OP%05d", seq_len(budgets$Persons[index])),
      each = nrow(template)
    )
    rownames(data) <- NULL
    value <- tryCatch(
      mfrmr_fc_g4w_profile_score(artifact, data), error = identity
    )
    if (inherits(value, "error")) {
      return(data.frame(
        Scale = budgets$Scale[index], Persons = budgets$Persons[index],
        Rows = nrow(data), ArtifactBytes = artifact_bytes,
        ElapsedSeconds = NA_real_, ProfiledAllocationBytes = NA_real_,
        SerializedResultBytes = NA_real_, Pass = FALSE,
        Detail = conditionMessage(value), stringsAsFactors = FALSE
      ))
    }
    pass <- nrow(data) == budgets$Rows[index] &&
      artifact_bytes <= budgets$MaxArtifactBytes[index] &&
      value$Elapsed <= budgets$MaxElapsedSeconds[index] &&
      value$Allocated <= budgets$MaxProfiledAllocationBytes[index] &&
      value$ResultBytes <= budgets$MaxSerializedResultBytes[index] &&
      nrow(value$Result$estimates) == budgets$Persons[index]
    data.frame(
      Scale = budgets$Scale[index], Persons = budgets$Persons[index],
      Rows = nrow(data), ArtifactBytes = artifact_bytes,
      ElapsedSeconds = value$Elapsed,
      ProfiledAllocationBytes = value$Allocated,
      SerializedResultBytes = value$ResultBytes, Pass = pass,
      Detail = if (pass) "within frozen regression ceilings" else
        "one or more frozen regression ceilings exceeded",
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}

mfrmr_fc_g4w_load_installed <- function() {
  installed_library <- Sys.getenv("MFRMR_G4_INSTALLED_LIBRARY", unset = "")
  if (!nzchar(installed_library)) {
    stop("MFRMR_G4_INSTALLED_LIBRARY must identify the isolated library.",
         call. = FALSE)
  }
  installed_library <- normalizePath(
    installed_library, winslash = "/", mustWork = TRUE
  )
  .libPaths(c(installed_library, .libPaths()))
  suppressPackageStartupMessages(library(mfrmr))
  loaded_package_path <- normalizePath(
    find.package("mfrmr"), winslash = "/", mustWork = TRUE
  )
  loaded_library_path <- dirname(loaded_package_path)
  matches <- if (.Platform$OS.type == "windows") {
    identical(tolower(loaded_library_path), tolower(installed_library))
  } else {
    identical(loaded_library_path, installed_library)
  }
  if (!matches) {
    stop("The worker did not load mfrmr from the isolated library.", call. = FALSE)
  }
  list(
    InstalledLibrary = installed_library,
    LoadedPackagePath = loaded_package_path
  )
}

mfrmr_fc_g4w_fresh_score_main <- function(args) {
  package_root <- normalizePath(args[1L], mustWork = TRUE)
  artifact_file <- normalizePath(args[2L], mustWork = TRUE)
  input_file <- normalizePath(args[3L], mustWork = TRUE)
  output_file <- args[4L]
  collate_locale <- args[5L]
  if (file.exists(output_file)) {
    stop("The output path must not already exist.", call. = FALSE)
  }
  installed_library <- Sys.getenv("MFRMR_G4_INSTALLED_LIBRARY", unset = "")
  if (nzchar(installed_library)) {
    loaded <- mfrmr_fc_g4w_load_installed()
    load_mode <- "installed_library"
  } else {
    suppressPackageStartupMessages(pkgload::load_all(package_root, quiet = TRUE))
    load_mode <- "source_tree"
    loaded <- list(LoadedPackagePath = normalizePath(
      find.package("mfrmr"), winslash = "/", mustWork = TRUE
    ))
  }
  if (!identical(Sys.setlocale("LC_COLLATE", collate_locale), collate_locale)) {
    stop("Requested collation locale is unavailable.", call. = FALSE)
  }
  if (exists("fit", envir = .GlobalEnv, inherits = FALSE) ||
      exists("source_data", envir = .GlobalEnv, inherits = FALSE) ||
      exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    stop("Fresh-process precondition failed.", call. = FALSE)
  }
  artifact <- mfrmr:::mfrmr_load_calibration(artifact_file)
  new_responses <- readRDS(input_file)
  artifact_before <- artifact
  input_before <- new_responses
  result <- mfrmr:::mfrmr_score_calibration(
    artifact, new_responses, weight = "Weight", interval_level = 0.84
  )
  if (!identical(artifact, artifact_before) ||
      !identical(new_responses, input_before)) {
    stop("Scoring mutated an input object.", call. = FALSE)
  }
  if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
    stop("Scoring created caller RNG state.", call. = FALSE)
  }
  saveRDS(list(
    status = "pass", load_mode = load_mode,
    loaded_package_path = loaded$LoadedPackagePath,
    package_version = as.character(utils::packageVersion("mfrmr")),
    calibration_id = artifact$header$calibration_id,
    semantic_components = result$settings$semantic_components,
    estimates = result$estimates,
    row_dispositions = result$row_dispositions,
    person_dispositions = result$person_dispositions,
    fit_present = exists("fit", envir = .GlobalEnv, inherits = FALSE),
    source_data_present = exists(
      "source_data", envir = .GlobalEnv, inherits = FALSE
    ),
    rng_state_present = exists(
      ".Random.seed", envir = .GlobalEnv, inherits = FALSE
    ), locale = Sys.getlocale()
  ), output_file, version = 3)
  invisible(TRUE)
}

mfrmr_fc_g4w_current_main <- function(args, worker_path) {
  package_root <- normalizePath(args[2L], winslash = "/", mustWork = TRUE)
  tarball <- normalizePath(args[3L], winslash = "/", mustWork = TRUE)
  receipt_path <- normalizePath(args[4L], winslash = "/", mustWork = TRUE)
  output_file <- args[5L]
  if (file.exists(output_file)) {
    stop("The current confirmation output path must not already exist.",
         call. = FALSE)
  }
  preflight_path <- file.path(
    package_root, "inst", "validation",
    "fixed-calibration-g4-candidate-binding-preflight-0.2.4.R"
  )
  contract_path <- file.path(
    package_root, "inst", "validation",
    "fixed-calibration-g4-current-source-contract-0.2.4.R"
  )
  preflight <- new.env(parent = globalenv())
  contract <- new.env(parent = globalenv())
  sys.source(preflight_path, envir = preflight)
  sys.source(contract_path, envir = contract)
  receipt <- readRDS(receipt_path)
  preflight$mfrmr_fc_g4b_require_bound_candidate(
    receipt, package_root, tarball
  )
  loaded <- mfrmr_fc_g4w_load_installed()
  mfrmr_fc_g4w_assert(
    identical(
      as.character(utils::packageVersion("mfrmr")),
      receipt$TarballObservation$PackageVersion
    ), "Installed package version differs from the bound tarball."
  )
  denominator <- contract$mfrmr_fc_g4_current_denominator()
  mfrmr_fc_g4w_assert(
    identical(denominator$CellId, mfrmr_fc_g4w_cell_ids()),
    "The worker does not implement the exact frozen denominator."
  )
  started <- format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  handlers <- mfrmr_fc_g4w_current_handlers(
    contract, package_root, worker_path
  )
  cells <- mfrmr_fc_g4w_evaluate(handlers, denominator)
  default_fixture <- tryCatch(
    mfrmr_fc_g4w_fixture(
      "RSM", "current_default31_confirmation",
      contract$mfrmr_fc_g4_current_confirmation_design()
    ), error = identity
  )
  resources <- if (inherits(default_fixture, "error")) {
    budgets <- contract$mfrmr_fc_g4_current_resource_budgets()
    data.frame(
      Scale = budgets$Scale, Persons = budgets$Persons, Rows = budgets$Rows,
      ArtifactBytes = NA_real_, ElapsedSeconds = NA_real_,
      ProfiledAllocationBytes = NA_real_, SerializedResultBytes = NA_real_,
      Pass = FALSE, Detail = conditionMessage(default_fixture),
      stringsAsFactors = FALSE
    )
  } else {
    mfrmr_fc_g4w_resources(
      default_fixture$frozen, default_fixture$confirmation,
      contract$mfrmr_fc_g4_current_resource_budgets()
    )
  }
  complete <- identical(cells$CellId, denominator$CellId) &&
    nrow(cells) == 49L && all(cells$Pass) &&
    nrow(resources) == 3L && all(resources$Pass)
  result <- list(
    Contract = mfrmr_fc_g4w_contract,
    ProspectiveContract = receipt$ProspectiveContract,
    ProspectiveSpecification = receipt$ProspectiveSpecification,
    CandidateManifestHash = receipt$ManifestHash,
    CandidateGitCommit = receipt$ObservedGitIdentity$HeadCommit,
    CandidateTarballSHA256 = receipt$TarballObservation$TarballSHA256,
    CandidateTarballFileRegistrySHA256 =
      receipt$TarballObservation$FileRegistryHash,
    Binding = receipt$Binding, CandidateBindingComplete = TRUE,
    CurrentExecutionOpened = TRUE, ConfirmationResultObserved = TRUE,
    StartedAtUTC = started,
    FinishedAtUTC = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC"),
    InstalledLibrary = loaded$InstalledLibrary,
    LoadedPackagePath = loaded$LoadedPackagePath,
    PackageVersion = as.character(utils::packageVersion("mfrmr")),
    R = R.version.string, Platform = R.version$platform,
    System = as.list(Sys.info()), Locale = Sys.getlocale(),
    Cells = cells, ResourceObservations = resources,
    DenominatorCells = as.integer(nrow(cells)),
    PassedCells = as.integer(sum(cells$Pass)),
    FailedCells = as.integer(sum(!cells$Pass)),
    ResourceScalesPassed = as.integer(sum(resources$Pass)),
    Complete = complete,
    CORE05Complete = complete, CORE06Complete = complete,
    G4LocalCandidateComplete = complete,
    HostedPlatformMatrixComplete = FALSE,
    G4ExitComplete = FALSE, G6Authorized = FALSE,
    PublicAPIAuthorized = FALSE
  )
  saveRDS(result, output_file, version = 3)
  cat(
    "G4 current confirmation: cells=", nrow(cells),
    "; passed=", sum(cells$Pass), "; failed=", sum(!cells$Pass),
    "; resources=", sum(resources$Pass), "/", nrow(resources), "\n",
    sep = ""
  )
  if (!complete) {
    stop("The retained current G4 denominator is incomplete.", call. = FALSE)
  }
  invisible(TRUE)
}

mfrmr_fc_g4w_main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  file_argument <- commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))]
  if (length(file_argument) != 1L) {
    stop("The worker file identity is unavailable.", call. = FALSE)
  }
  worker_path <- normalizePath(
    sub("^--file=", "", file_argument), winslash = "/", mustWork = TRUE
  )
  if (length(args) == 5L && identical(args[1L], "current")) {
    return(mfrmr_fc_g4w_current_main(args, worker_path))
  }
  if (length(args) == 5L) {
    return(mfrmr_fc_g4w_fresh_score_main(args))
  }
  stop(
    "Usage: Rscript --vanilla fixed-calibration-g4-confirmation-worker-0.2.4.R ",
    "PACKAGE_ROOT ARTIFACT_RDS INPUT_RDS OUTPUT_RDS COLLATE_LOCALE\n",
    "   or: Rscript --vanilla fixed-calibration-g4-confirmation-worker-0.2.4.R ",
    "current PACKAGE_ROOT TARBALL BINDING_RDS OUTPUT_RDS",
    call. = FALSE
  )
}

if (sys.nframe() == 0L) mfrmr_fc_g4w_main()
