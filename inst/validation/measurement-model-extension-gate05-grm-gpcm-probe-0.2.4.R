# Gate 0.5 GRM--GPCM decision probe for mfrmr 0.2.4
#
# Repository-internal only. This script does not add a response family, public
# API, portable artifact, or support claim. It asks whether cumulative versus
# adjacent-category geometry is predictively detectable for a new Person before
# package-native GRM work is considered. The first probe is deliberately
# unidimensional and item-only so facet structure is not changed at the same
# time as the response family.

mfrmr_gate05_contract <- function() {
  list(
    ContractId = "MFRMR-GATE05-GRM-GPCM-NEW-PERSON-V1",
    StageId = "B2",
    Status = "parked_mechanical_probe_only",
    PredictionTarget = "new_person_complete_item_vector",
    Conditioning = "training_item_parameters_and_standard_normal_population",
    PrimaryMetric = "new_person_marginal_log_score_per_response",
    Comparator = "paired_matched_minus_mismatched_family",
    DGPFamilies = c("GRM", "GPCM"),
    FitFamilies = c("GRM", "GPCM"),
    MajorIdentityAxesChanged = "response_family_only",
    ExcludedAxes = c(
      "observed_facets", "latent_dimension", "random_blocks",
      "portable_calibration", "response_time", "mixtures"
    ),
    TerminalStates = c(
      "valid", "dgm_invalid", "fit_error", "nonconverged",
      "invalid_probability", "metric_undefined"
    ),
    DenominatorIdentity = "all_dataset_fit_attempts_v1",
    SeedPolicy = "utf8_rolling_mod_2147483646_v1",
    QuadratureOrders = c(81L, 161L),
    QuadratureRange = c(-6, 6),
    DirectionRule = "matched_minus_mismatched_95pct_mc_interval_excludes_zero",
    PortfolioRule = paste(
      "No simulation result admits GRM. A stable matched-family advantage may",
      "reopen user-data discovery only; a weak asymmetric or unstable result",
      "keeps B2 parked."
    ),
    ExternalEngine = "mirt",
    PublicApiChange = FALSE
  )
}

mfrmr_gate05_registry <- function(smoke = FALSE) {
  smoke <- isTRUE(smoke)
  scenarios <- data.frame(
    ScenarioId = c("G05-REGULAR", "G05-COMPRESSED"),
    ThresholdRegime = c("regular", "compressed"),
    stringsAsFactors = FALSE
  )
  grid <- merge(
    scenarios,
    data.frame(DGPFamily = c("GRM", "GPCM"), stringsAsFactors = FALSE),
    by = NULL,
    sort = FALSE
  )
  grid <- grid[order(grid$ScenarioId, grid$DGPFamily, method = "radix"), ]
  rownames(grid) <- NULL
  grid$NTrain <- if (smoke) 160L else 400L
  grid$NTest <- if (smoke) 80L else 200L
  grid$NItem <- if (smoke) 6L else 8L
  grid$NCategory <- 4L
  grid$Replications <- if (smoke) 1L else 30L
  grid$MinimumTrainCategoryCount <- if (smoke) 1L else 5L
  grid$MaximumCycles <- if (smoke) 300L else 500L
  grid$CellPrefix <- paste(grid$ScenarioId, grid$DGPFamily, sep = "-")
  grid$StudyRole <- if (smoke) "mechanical_smoke" else "exploratory_pilot"
  grid
}

mfrmr_gate05_seed <- function(...) {
  key <- paste(..., sep = "|")
  values <- utf8ToInt(enc2utf8(key))
  accumulator <- 104729
  for (value in values) {
    accumulator <- (accumulator * 131 + value) %% 2147483646
  }
  as.integer(accumulator + 1)
}

mfrmr_gate05_with_seed <- function(seed, expression) {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  old_kind <- RNGkind()
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(as.integer(seed))
  force(expression)
}

mfrmr_gate05_parameters <- function(n_item,
                                    n_category,
                                    threshold_regime) {
  n_item <- as.integer(n_item)
  n_category <- as.integer(n_category)
  threshold_regime <- match.arg(
    threshold_regime, c("regular", "compressed")
  )
  if (n_item < 2L || n_category < 2L) {
    stop("Gate 0.5 requires at least two items and two categories.",
         call. = FALSE)
  }
  offsets <- if (identical(threshold_regime, "regular")) {
    seq(-0.9, 0.9, length.out = n_category - 1L)
  } else {
    seq(-0.45, 0.45, length.out = n_category - 1L)
  }
  locations <- seq(-0.55, 0.55, length.out = n_item)
  thresholds <- outer(locations, offsets, "+")
  slopes <- exp(seq(log(0.75), log(1.35), length.out = n_item))
  list(
    slopes = slopes,
    thresholds = thresholds,
    locations = locations,
    threshold_regime = threshold_regime,
    n_item = n_item,
    n_category = n_category
  )
}

mfrmr_gate05_probabilities <- function(family, theta, parameters) {
  family <- match.arg(toupper(family), c("GRM", "GPCM"))
  theta <- as.numeric(theta)
  n_category <- parameters$n_category
  out <- vector("list", parameters$n_item)
  for (item in seq_len(parameters$n_item)) {
    slope <- parameters$slopes[item]
    thresholds <- parameters$thresholds[item, ]
    if (identical(family, "GRM")) {
      cumulative <- vapply(
        thresholds,
        function(threshold) stats::plogis(slope * (theta - threshold)),
        numeric(length(theta))
      )
      cumulative <- matrix(
        cumulative, nrow = length(theta), ncol = n_category - 1L
      )
      probability <- cbind(
        1 - cumulative[, 1L],
        if (n_category > 2L) {
          cumulative[, seq_len(n_category - 2L), drop = FALSE] -
            cumulative[, 2L:(n_category - 1L), drop = FALSE]
        },
        cumulative[, n_category - 1L]
      )
    } else {
      scores <- 0:(n_category - 1L)
      logits <- matrix(0, nrow = length(theta), ncol = n_category)
      if (n_category > 1L) {
        for (category in 2:n_category) {
          step_count <- category - 1L
          logits[, category] <- slope * (
            step_count * theta - sum(thresholds[seq_len(step_count)])
          )
        }
      }
      maximum <- apply(logits, 1L, max)
      exponentiated <- exp(logits - maximum)
      probability <- exponentiated / rowSums(exponentiated)
      colnames(probability) <- paste0("Category", scores)
    }
    if (any(!is.finite(probability)) ||
        any(probability < -1e-12) ||
        any(abs(rowSums(probability) - 1) > 1e-10)) {
      stop("Gate 0.5 DGP produced invalid category probabilities.",
           call. = FALSE)
    }
    probability[probability < 0] <- 0
    probability <- probability / rowSums(probability)
    colnames(probability) <- paste0("Category", 0:(n_category - 1L))
    out[[item]] <- probability
  }
  names(out) <- paste0("Item", seq_len(parameters$n_item))
  out
}

mfrmr_gate05_generate <- function(registry_row, replication) {
  cell_id <- paste0(registry_row$CellPrefix, "-R", sprintf("%03d", replication))
  data_seed <- mfrmr_gate05_seed(
    mfrmr_gate05_contract()$ContractId, cell_id, "data"
  )
  generated <- mfrmr_gate05_with_seed(data_seed, {
    parameters <- mfrmr_gate05_parameters(
      registry_row$NItem,
      registry_row$NCategory,
      registry_row$ThresholdRegime
    )
    n_total <- registry_row$NTrain + registry_row$NTest
    theta <- stats::rnorm(n_total)
    probabilities <- mfrmr_gate05_probabilities(
      registry_row$DGPFamily, theta, parameters
    )
    responses <- matrix(
      0L, nrow = n_total, ncol = registry_row$NItem,
      dimnames = list(NULL, paste0("Item", seq_len(registry_row$NItem)))
    )
    for (item in seq_len(registry_row$NItem)) {
      for (person in seq_len(n_total)) {
        responses[person, item] <- sample.int(
          registry_row$NCategory,
          size = 1L,
          prob = probabilities[[item]][person, ]
        ) - 1L
      }
    }
    list(
      parameters = parameters,
      theta = theta,
      responses = responses
    )
  })
  train_index <- seq_len(registry_row$NTrain)
  test_index <- registry_row$NTrain + seq_len(registry_row$NTest)
  train <- generated$responses[train_index, , drop = FALSE]
  test <- generated$responses[test_index, , drop = FALSE]
  category_counts <- lapply(seq_len(ncol(train)), function(item) {
    tabulate(train[, item] + 1L, nbins = registry_row$NCategory)
  })
  minimum_train_count <- min(unlist(category_counts, use.names = FALSE))
  list(
    CellId = cell_id,
    DataSeed = data_seed,
    Train = train,
    Test = test,
    Parameters = generated$parameters,
    MinimumTrainCategoryCount = as.integer(minimum_train_count),
    DGMValid = minimum_train_count >= registry_row$MinimumTrainCategoryCount
  )
}

mfrmr_gate05_capture_fit <- function(data, family, seed, maximum_cycles) {
  warnings <- character()
  messages <- character()
  started <- proc.time()[["elapsed"]]
  value <- tryCatch(
    withCallingHandlers(
      mfrmr_gate05_with_seed(seed, {
        mirt::mirt(
          data = data,
          model = 1L,
          itemtype = if (identical(family, "GRM")) "graded" else "gpcm",
          verbose = FALSE,
          SE = FALSE,
          technical = list(NCYCLES = as.integer(maximum_cycles))
        )
      }),
      warning = function(condition) {
        warnings <<- c(warnings, conditionMessage(condition))
        invokeRestart("muffleWarning")
      },
      message = function(condition) {
        messages <<- c(messages, conditionMessage(condition))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(condition) condition
  )
  elapsed <- proc.time()[["elapsed"]] - started
  if (inherits(value, "error")) {
    return(list(
      value = NULL,
      terminal = "fit_error",
      error = conditionMessage(value),
      warnings = unique(warnings),
      messages = unique(messages),
      elapsed = elapsed
    ))
  }
  converged <- tryCatch(
    isTRUE(mirt::extract.mirt(value, "converged")),
    error = function(condition) FALSE
  )
  list(
    value = value,
    terminal = if (converged) "valid" else "nonconverged",
    error = "",
    warnings = unique(warnings),
    messages = unique(messages),
    elapsed = elapsed
  )
}

mfrmr_gate05_quadrature <- function(order, limits = c(-6, 6)) {
  order <- as.integer(order)
  if (order < 21L || order %% 2L == 0L) {
    stop("Gate 0.5 quadrature order must be odd and at least 21.",
         call. = FALSE)
  }
  nodes <- seq(limits[1L], limits[2L], length.out = order)
  weights <- stats::dnorm(nodes)
  weights <- weights / sum(weights)
  list(nodes = nodes, weights = weights)
}

mfrmr_gate05_fit_probabilities <- function(fit, theta, n_category) {
  theta <- matrix(as.numeric(theta), ncol = 1L)
  n_item <- mirt::extract.mirt(fit, "nitems")
  out <- lapply(seq_len(n_item), function(item) {
    probability <- mirt::probtrace(mirt::extract.item(fit, item), theta)
    probability <- as.matrix(probability)
    if (ncol(probability) != n_category ||
        any(!is.finite(probability)) ||
        any(probability < -1e-12) ||
        any(abs(rowSums(probability) - 1) > 1e-8)) {
      stop("Fitted model returned invalid or category-misaligned probabilities.",
           call. = FALSE)
    }
    probability[probability < 0] <- 0
    probability / rowSums(probability)
  })
  names(out) <- paste0("Item", seq_len(n_item))
  out
}

mfrmr_gate05_logsumexp <- function(values) {
  maximum <- max(values)
  maximum + log(sum(exp(values - maximum)))
}

mfrmr_gate05_new_person_log_score <- function(data,
                                              probability_list,
                                              weights) {
  data <- as.matrix(data)
  if (ncol(data) != length(probability_list)) {
    stop("Probability list does not match the held-out item count.",
         call. = FALSE)
  }
  log_weights <- log(weights)
  floor_probability <- .Machine$double.xmin
  score <- numeric(nrow(data))
  for (person in seq_len(nrow(data))) {
    node_log_likelihood <- numeric(length(weights))
    for (item in seq_len(ncol(data))) {
      category <- data[person, item] + 1L
      probability <- probability_list[[item]][, category]
      node_log_likelihood <- node_log_likelihood +
        log(pmax(probability, floor_probability))
    }
    score[person] <- mfrmr_gate05_logsumexp(
      log_weights + node_log_likelihood
    ) / ncol(data)
  }
  score
}

mfrmr_gate05_attempt_row <- function(registry_row,
                                     generated,
                                     replication,
                                     family,
                                     fit_seed,
                                     terminal,
                                     elapsed = 0,
                                     warnings = character(),
                                     messages = character(),
                                     error = "") {
  data.frame(
    ContractId = mfrmr_gate05_contract()$ContractId,
    ScenarioId = registry_row$ScenarioId,
    CellId = generated$CellId,
    DGPFamily = registry_row$DGPFamily,
    Replication = as.integer(replication),
    FitFamily = family,
    AttemptId = paste(generated$CellId, family, sep = "-"),
    DataSeed = generated$DataSeed,
    FitSeed = fit_seed,
    TerminalStatus = terminal,
    MinimumTrainCategoryCount = generated$MinimumTrainCategoryCount,
    WarningCount = length(warnings),
    Warnings = paste(warnings, collapse = " | "),
    Messages = paste(messages, collapse = " | "),
    Error = error,
    ElapsedSeconds = as.numeric(elapsed),
    stringsAsFactors = FALSE
  )
}

mfrmr_gate05_run_cell <- function(registry_row, replication) {
  contract <- mfrmr_gate05_contract()
  generated <- mfrmr_gate05_generate(registry_row, replication)
  fit_families <- contract$FitFamilies
  fit_seeds <- setNames(vapply(fit_families, function(family) {
    mfrmr_gate05_seed(contract$ContractId, generated$CellId, family, "fit")
  }, integer(1)), fit_families)

  if (!isTRUE(generated$DGMValid)) {
    attempts <- do.call(rbind, lapply(fit_families, function(family) {
      mfrmr_gate05_attempt_row(
        registry_row, generated, replication, family, fit_seeds[[family]],
        terminal = "dgm_invalid",
        error = "At least one training item-category count is below the frozen minimum."
      )
    }))
    return(list(attempts = attempts, scores = data.frame(), pairs = data.frame()))
  }

  fits <- setNames(vector("list", length(fit_families)), fit_families)
  attempt_rows <- list()
  for (family in fit_families) {
    captured <- mfrmr_gate05_capture_fit(
      generated$Train,
      family,
      fit_seeds[[family]],
      registry_row$MaximumCycles
    )
    fits[[family]] <- captured$value
    attempt_rows[[family]] <- mfrmr_gate05_attempt_row(
      registry_row, generated, replication, family, fit_seeds[[family]],
      terminal = captured$terminal,
      elapsed = captured$elapsed,
      warnings = captured$warnings,
      messages = captured$messages,
      error = captured$error
    )
  }

  orders <- contract$QuadratureOrders
  quadratures <- lapply(orders, mfrmr_gate05_quadrature,
                        limits = contract$QuadratureRange)
  names(quadratures) <- as.character(orders)
  score_vectors <- list()
  score_rows <- list()
  for (family in fit_families) {
    if (!identical(attempt_rows[[family]]$TerminalStatus, "valid")) next
    scored <- tryCatch({
      by_order <- lapply(quadratures, function(quadrature) {
        probabilities <- mfrmr_gate05_fit_probabilities(
          fits[[family]], quadrature$nodes, registry_row$NCategory
        )
        mfrmr_gate05_new_person_log_score(
          generated$Test, probabilities, quadrature$weights
        )
      })
      primary <- by_order[[as.character(orders[1L])]]
      sensitivity <- by_order[[as.character(orders[2L])]]
      list(
        primary = primary,
        sensitivity = sensitivity,
        quadrature_shift = mean(sensitivity) - mean(primary)
      )
    }, error = function(condition) condition)
    if (inherits(scored, "error") ||
        any(!is.finite(scored$primary)) ||
        !is.finite(scored$quadrature_shift)) {
      attempt_rows[[family]]$TerminalStatus <- if (inherits(scored, "error")) {
        "invalid_probability"
      } else {
        "metric_undefined"
      }
      attempt_rows[[family]]$Error <- if (inherits(scored, "error")) {
        conditionMessage(scored)
      } else {
        "Held-out log score or quadrature sensitivity was non-finite."
      }
      next
    }
    score_vectors[[family]] <- scored$primary
    score_rows[[family]] <- data.frame(
      ScenarioId = registry_row$ScenarioId,
      CellId = generated$CellId,
      DGPFamily = registry_row$DGPFamily,
      Replication = as.integer(replication),
      FitFamily = family,
      MeanLogScorePerResponse = mean(scored$primary),
      PersonMCSE = stats::sd(scored$primary) / sqrt(length(scored$primary)),
      QuadratureMeanShift = scored$quadrature_shift,
      NTest = nrow(generated$Test),
      stringsAsFactors = FALSE
    )
  }

  attempts <- do.call(rbind, attempt_rows)
  scores <- if (length(score_rows)) do.call(rbind, score_rows) else data.frame()
  pairs <- data.frame()
  if (all(fit_families %in% names(score_vectors))) {
    matched <- registry_row$DGPFamily
    mismatched <- setdiff(fit_families, matched)
    difference <- score_vectors[[matched]] - score_vectors[[mismatched]]
    delta <- mean(difference)
    mcse <- stats::sd(difference) / sqrt(length(difference))
    direction <- if (!is.finite(mcse)) {
      "indeterminate"
    } else if (delta - 1.96 * mcse > 0) {
      "matched_better"
    } else if (delta + 1.96 * mcse < 0) {
      "mismatched_better"
    } else {
      "indeterminate"
    }
    pairs <- data.frame(
      ScenarioId = registry_row$ScenarioId,
      CellId = generated$CellId,
      DGPFamily = registry_row$DGPFamily,
      Replication = as.integer(replication),
      MatchedFitFamily = matched,
      MismatchedFitFamily = mismatched,
      MatchedMinusMismatched = delta,
      PersonPairedMCSE = mcse,
      Direction = direction,
      PortfolioEffect = "none_mechanical_probe_only",
      stringsAsFactors = FALSE
    )
  }
  list(attempts = attempts, scores = scores, pairs = pairs)
}

mfrmr_gate05_terminal_counts <- function(attempts) {
  contract <- mfrmr_gate05_contract()
  observed <- table(factor(
    attempts$TerminalStatus,
    levels = contract$TerminalStates
  ))
  data.frame(
    TerminalStatus = names(observed),
    Attempts = as.integer(observed),
    stringsAsFactors = FALSE
  )
}

mfrmr_gate05_pair_summary <- function(pairs) {
  if (!nrow(pairs)) return(data.frame())
  groups <- split(
    pairs,
    interaction(pairs$ScenarioId, pairs$DGPFamily, drop = TRUE)
  )
  rows <- lapply(groups, function(group) {
    delta <- group$MatchedMinusMismatched
    mcse <- if (length(delta) > 1L) {
      stats::sd(delta) / sqrt(length(delta))
    } else {
      NA_real_
    }
    data.frame(
      ScenarioId = group$ScenarioId[1L],
      DGPFamily = group$DGPFamily[1L],
      ValidPairs = length(delta),
      MeanMatchedMinusMismatched = mean(delta),
      ReplicationMCSE = mcse,
      Direction = if (!is.finite(mcse)) {
        "indeterminate"
      } else if (mean(delta) - 1.96 * mcse > 0) {
        "matched_better"
      } else if (mean(delta) + 1.96 * mcse < 0) {
        "mismatched_better"
      } else {
        "indeterminate"
      },
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  out[order(out$ScenarioId, out$DGPFamily, method = "radix"), , drop = FALSE]
}

mfrmr_run_gate05_grm_gpcm_probe <- function(smoke = TRUE,
                                             registry = NULL) {
  if (!requireNamespace("mirt", quietly = TRUE)) {
    stop("Gate 0.5 requires the suggested package `mirt`.", call. = FALSE)
  }
  contract <- mfrmr_gate05_contract()
  if (is.null(registry)) {
    registry <- mfrmr_gate05_registry(smoke = smoke)
  }
  required <- c(
    "ScenarioId", "ThresholdRegime", "DGPFamily", "NTrain", "NTest",
    "NItem", "NCategory", "Replications", "MinimumTrainCategoryCount",
    "MaximumCycles", "CellPrefix", "StudyRole"
  )
  missing <- setdiff(required, names(registry))
  if (length(missing)) {
    stop("Gate 0.5 registry is missing: ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  if (anyDuplicated(registry$CellPrefix)) {
    stop("Gate 0.5 CellPrefix values must be unique.", call. = FALSE)
  }
  if (!all(registry$DGPFamily %in% contract$DGPFamilies)) {
    stop("Gate 0.5 registry contains an unsupported DGP family.",
         call. = FALSE)
  }

  results <- list()
  index <- 0L
  for (row in seq_len(nrow(registry))) {
    registry_row <- registry[row, , drop = FALSE]
    for (replication in seq_len(registry_row$Replications)) {
      index <- index + 1L
      results[[index]] <- mfrmr_gate05_run_cell(registry_row, replication)
    }
  }
  attempts <- do.call(rbind, lapply(results, `[[`, "attempts"))
  score_parts <- lapply(results, `[[`, "scores")
  score_parts <- score_parts[vapply(score_parts, nrow, integer(1)) > 0L]
  scores <- if (length(score_parts)) do.call(rbind, score_parts) else data.frame()
  pair_parts <- lapply(results, `[[`, "pairs")
  pair_parts <- pair_parts[vapply(pair_parts, nrow, integer(1)) > 0L]
  pairs <- if (length(pair_parts)) do.call(rbind, pair_parts) else data.frame()
  expected_attempts <- sum(registry$Replications) * length(contract$FitFamilies)
  if (nrow(attempts) != expected_attempts ||
      !all(attempts$TerminalStatus %in% contract$TerminalStates)) {
    stop("Gate 0.5 attempt denominator is incomplete.", call. = FALSE)
  }
  terminal_counts <- mfrmr_gate05_terminal_counts(attempts)
  pair_summary <- mfrmr_gate05_pair_summary(pairs)
  valid_attempt_rate <- mean(attempts$TerminalStatus == "valid")
  study_disposition <- if (isTRUE(smoke)) {
    if (valid_attempt_rate == 1 && nrow(pairs) == sum(registry$Replications)) {
      "mechanics_passed_no_portfolio_admission"
    } else {
      "mechanics_failed_keep_parked"
    }
  } else if (valid_attempt_rate < 0.90 || !nrow(pair_summary)) {
    "park_unstable_or_incomplete"
  } else if (all(pair_summary$Direction == "matched_better")) {
    "geometry_detectable_reopen_problem_discovery_only"
  } else {
    "park_weak_asymmetric_or_indeterminate"
  }

  structure(list(
    contract = contract,
    registry = registry,
    attempts = attempts,
    terminal_counts = terminal_counts,
    scores = scores,
    pairs = pairs,
    pair_summary = pair_summary,
    decision = data.frame(
      StudyRole = unique(registry$StudyRole),
      ExpectedAttempts = expected_attempts,
      ObservedAttempts = nrow(attempts),
      ValidAttemptRate = valid_attempt_rate,
      ValidPairs = nrow(pairs),
      Disposition = study_disposition,
      PublicApiChange = FALSE,
      stringsAsFactors = FALSE
    ),
    engine = data.frame(
      Package = "mirt",
      Version = as.character(utils::packageVersion("mirt")),
      stringsAsFactors = FALSE
    )
  ), class = "mfrmr_gate05_grm_gpcm_probe")
}
