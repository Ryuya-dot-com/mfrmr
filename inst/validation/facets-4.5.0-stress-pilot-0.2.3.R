# Repository-only FACETS 4.5.0 JML stress pilot for mfrmr 0.2.3.
#
# This driver generates synthetic RSM/PCM scenarios, fits the same retained
# observations with mfrmr JML, invokes the workspace FACETS batch runner, and
# normalizes truth recovery and matched element differences. It is pilot
# instrumentation, not confirmation and not a package/runtime dependency.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_facets_450_fun <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  getExportedValue("mfrmr", name)
}

mfrmr_facets_450_sha256 <- function(path) {
  if (!file.exists(path)) return(NA_character_)
  if (!requireNamespace("digest", quietly = TRUE)) return(NA_character_)
  digest::digest(file = path, algo = "sha256")
}

mfrmr_facets_450_registry <- function(profile = c("expanded", "smoke", "extension")) {
  profile <- match.arg(profile)
  out <- data.frame(
    Scenario = c(
      "balanced_complete",
      "rotating_25pct",
      "planned_sparse_linked",
      "mcar_20",
      "mcar_80",
      "mcar_90",
      "rater_dependent_missing",
      "score_dependent_missing",
      "person_block_dropout",
      "workload_zipf",
      "weak_single_bridge",
      "disconnected_components",
      "rater_item_structural_hole",
      "nested_with_one_shared_item",
      "rare_upper_category",
      "unused_middle_category",
      "extreme_persons",
      "missing_entire_rater",
      "exact_duplicate_cells",
      "conflicting_duplicate_cells",
      "rater_drift_contamination",
      "small_n_sparse",
      "two_rater_complete",
      "two_rater_one_per_person",
      "two_rater_weak_overlap",
      "category_middle_dominant",
      "category_single_dominant",
      "category_skewed_person",
      "interaction_checkerboard_weak",
      "interaction_checkerboard_strong",
      "residual_local_dependence"
    ),
    StressClass = c(
      "reference", "planned_missing", "planned_missing",
      "unplanned_missing", "unplanned_missing", "unplanned_missing",
      "unplanned_missing", "nonignorable_missing", "block_missing",
      "workload_imbalance", "topology", "negative_control",
      "structural_missing", "nesting_confounding", "category_support",
      "category_support", "extreme_score", "version_sensitive_reporting",
      "duplicate_observation", "duplicate_observation", "temporal_instability",
      "small_sparse", "minimum_rater_count", "minimum_rater_count",
      "minimum_rater_count", "category_imbalance", "category_imbalance",
      "category_imbalance",
      "known_interaction", "known_interaction", "residual_structure"
    ),
    MissingMechanism = c(
      "none", "planned_rotation", "planned_linking",
      "MCAR", "MCAR", "MCAR", "rater_dependent_MAR",
      "score_dependent_MNAR", "monotone_block", "rater_workload_MAR",
      "planned_bridge", "planned_disconnection", "rater_by_item_block",
      "nested_with_shared_item", "outcome_dependent", "outcome_dependent",
      "none", "entire_labelled_element", "none", "none", "none", "planned_sparse",
      "none", "planned_rotation_no_common_person", "planned_sparse_linking",
      "none", "none", "none", "none", "none", "none"
    ),
    Topology = c(
      "complete", "rotating_connected", "sparse_linked",
      "sampled", "sampled", "sampled", "workload_skewed", "sampled",
      "person_item_block", "hub_like", "two_blocks_one_bridge",
      "two_disconnected_blocks", "connected_structural_hole",
      "two_rater_blocks_one_shared_item", "complete_after_outcome_filter",
      "complete_after_outcome_filter", "complete", "declared_unobserved_level",
      "complete_with_duplicates", "complete_with_conflicts", "complete", "sparse_linked",
      "two_raters_complete", "two_raters_disjoint_person_sets",
      "two_raters_few_common_persons", "complete", "complete", "complete",
      "complete", "complete", "complete"
    ),
    ExpectedState = c(
      rep("review_recovery", 11),
      "must_not_be_false_ready",
      rep("review_recovery", 5),
      "version_sensitive_reporting",
      "review_duplicate_policy", "review_duplicate_policy",
      "review_contamination_sensitivity", "review_recovery",
      "review_minimum_rater_information", "must_not_be_false_ready",
      "review_weak_link_information", "review_category_information",
      "review_category_identification", "review_category_information",
      "review_interaction_sensitivity",
      "review_interaction_sensitivity", "review_residual_sensitivity"
    ),
    stringsAsFactors = FALSE
  )
  if (identical(profile, "smoke")) {
    keep <- c(
      "balanced_complete", "planned_sparse_linked", "mcar_80",
      "score_dependent_missing", "workload_zipf", "weak_single_bridge",
      "disconnected_components", "unused_middle_category",
      "extreme_persons", "missing_entire_rater"
    )
    out <- out[out$Scenario %in% keep, , drop = FALSE]
  } else if (identical(profile, "extension")) {
    keep <- c(
      "two_rater_complete", "two_rater_one_per_person",
      "two_rater_weak_overlap", "category_middle_dominant",
      "category_single_dominant", "category_skewed_person",
      "interaction_checkerboard_weak",
      "interaction_checkerboard_strong", "residual_local_dependence"
    )
    out <- out[out$Scenario %in% keep, , drop = FALSE]
  }
  rownames(out) <- NULL
  out
}

mfrmr_facets_450_thresholds <- function(model, criterion_levels, scenario = NULL) {
  common <- if (identical(scenario, "category_middle_dominant")) {
    c(-3, 0, 3)
  } else if (identical(scenario, "category_single_dominant")) {
    c(-8, 3, 5)
  } else {
    c(-1.2, 0, 1.2)
  }
  if (identical(model, "RSM")) return(common)
  if (scenario %in% c("category_middle_dominant", "category_single_dominant")) {
    return(stats::setNames(rep(list(common), length(criterion_levels)), criterion_levels))
  }
  spreads <- seq(0.75, 1.35, length.out = length(criterion_levels))
  stats::setNames(
    lapply(spreads, function(x) c(-x, 0, x)),
    criterion_levels
  )
}

mfrmr_facets_450_base <- function(scenario, model, seed) {
  build_spec <- mfrmr_facets_450_fun("build_mfrm_sim_spec")
  simulate <- mfrmr_facets_450_fun("simulate_mfrm_data")
  small <- identical(scenario, "small_n_sparse")
  two_rater <- startsWith(scenario, "two_rater_")
  n_person <- if (small) 24L else 60L
  n_rater <- if (two_rater) 2L else 8L
  n_criterion <- if (small) 4L else 5L
  criterion_levels <- sprintf("C%02d", seq_len(n_criterion))
  assignment <- if (scenario %in% c("planned_sparse_linked", "small_n_sparse",
                                     "two_rater_weak_overlap")) {
    "sparse_linked"
  } else if (scenario %in% c("rotating_25pct", "two_rater_one_per_person")) {
    "rotating"
  } else {
    "crossed"
  }
  raters_per_person <- if (identical(assignment, "crossed")) n_rater else if (
    identical(assignment, "rotating")
  ) if (two_rater) 1L else 2L else 1L
  sparse_controls <- if (identical(assignment, "sparse_linked")) {
    list(
      link_persons = if (small) 3L else if (two_rater) 3L else 6L,
      link_raters_per_person = if (small) 3L else if (two_rater) 2L else 4L,
      assignment_mode = "balanced",
      min_common_persons_per_rater_pair = 1L
    )
  } else {
    NULL
  }
  interaction_effects <- if (scenario %in% c(
    "interaction_checkerboard_weak", "interaction_checkerboard_strong"
  )) {
    effect <- if (identical(scenario, "interaction_checkerboard_weak")) 0.4 else 1.0
    data.frame(
      Rater = c("R01", "R01", "R02", "R02"),
      Criterion = c("C01", "C02", "C01", "C02"),
      Effect = effect * c(1, -1, -1, 1),
      stringsAsFactors = FALSE
    )
  } else if (identical(scenario, "residual_local_dependence")) {
    set.seed(seed + 700L)
    persons <- sprintf("P%03d", seq_len(n_person))
    person_signal <- stats::rnorm(n_person, mean = 0, sd = 0.9)
    data.frame(
      Person = rep(persons, each = 2L),
      Criterion = rep(c("C01", "C02"), times = n_person),
      Effect = rep(person_signal, each = 2L),
      stringsAsFactors = FALSE
    )
  } else {
    NULL
  }
  empirical <- identical(scenario, "category_skewed_person")
  spec <- build_spec(
    n_person = n_person,
    n_rater = n_rater,
    n_criterion = n_criterion,
    raters_per_person = raters_per_person,
    score_levels = 4L,
    theta_sd = 1,
    rater_sd = 0.75,
    criterion_sd = 0.45,
    thresholds = mfrmr_facets_450_thresholds(model, criterion_levels, scenario),
    model = model,
    step_facet = "Criterion",
    assignment = assignment,
    sparse_controls = sparse_controls,
    interaction_effects = interaction_effects,
    latent_distribution = if (empirical) "empirical" else "normal",
    empirical_person = if (empirical) c(rep(-0.3, 9L), 2.7) else NULL,
    empirical_rater = if (empirical) seq(-1, 1, length.out = n_rater) else NULL,
    empirical_criterion = if (empirical) seq(-0.6, 0.6, length.out = n_criterion) else NULL
  )
  list(data = simulate(sim_spec = spec, seed = seed), spec = spec)
}

mfrmr_facets_450_keep <- function(data, keep, seed) {
  keep <- as.logical(keep)
  keep[is.na(keep)] <- FALSE
  if (!any(keep)) keep[sample.int(nrow(data), 1L)] <- TRUE
  data[keep, , drop = FALSE]
}

mfrmr_facets_450_transform <- function(data, scenario, seed) {
  set.seed(seed)
  n <- nrow(data)
  score_min <- min(data$Score, na.rm = TRUE)
  score_max <- max(data$Score, na.rm = TRUE)
  sentinel <- NULL

  if (scenario %in% c(
    "balanced_complete", "rotating_25pct", "planned_sparse_linked",
    "small_n_sparse", "two_rater_complete", "two_rater_one_per_person",
    "two_rater_weak_overlap", "category_middle_dominant",
    "category_single_dominant", "category_skewed_person",
    "interaction_checkerboard_weak",
    "interaction_checkerboard_strong", "residual_local_dependence"
  )) {
    return(list(data = data, sentinel = sentinel))
  }
  if (identical(scenario, "mcar_20")) {
    data <- mfrmr_facets_450_keep(data, stats::runif(n) > 0.20, seed)
  } else if (identical(scenario, "mcar_80")) {
    data <- mfrmr_facets_450_keep(data, stats::runif(n) > 0.80, seed)
  } else if (identical(scenario, "mcar_90")) {
    data <- mfrmr_facets_450_keep(data, stats::runif(n) > 0.90, seed)
  } else if (identical(scenario, "rater_dependent_missing")) {
    rank <- match(data$Rater, sort(unique(data$Rater)))
    keep_prob <- c(1, .90, .75, .55, .35, .20, .10, .05)[rank]
    data <- mfrmr_facets_450_keep(data, stats::runif(n) < keep_prob, seed)
  } else if (identical(scenario, "score_dependent_missing")) {
    keep_prob <- ifelse(data$Score == score_max, .15,
                        ifelse(data$Score == score_min, .35, .85))
    data <- mfrmr_facets_450_keep(data, stats::runif(n) < keep_prob, seed)
  } else if (identical(scenario, "person_block_dropout")) {
    person_rank <- match(data$Person, sort(unique(data$Person)))
    criterion_rank <- match(data$Criterion, sort(unique(data$Criterion)))
    data <- data[!(person_rank > 42L & criterion_rank > 2L), , drop = FALSE]
  } else if (identical(scenario, "workload_zipf")) {
    rank <- match(data$Rater, sort(unique(data$Rater)))
    keep_prob <- pmax(.03, 1 / rank^1.15)
    data <- mfrmr_facets_450_keep(data, stats::runif(n) < keep_prob, seed)
  } else if (scenario %in% c("weak_single_bridge", "disconnected_components")) {
    person_rank <- match(data$Person, sort(unique(data$Person)))
    rater_rank <- match(data$Rater, sort(unique(data$Rater)))
    criterion_rank <- match(data$Criterion, sort(unique(data$Criterion)))
    keep <- (person_rank <= 30L & rater_rank <= 4L & criterion_rank <= 3L) |
      (person_rank > 30L & rater_rank > 4L & criterion_rank > 3L)
    if (identical(scenario, "weak_single_bridge")) {
      keep <- keep | (data$Person == "P030" & data$Rater == "R05" &
                        data$Criterion == "C04")
    }
    data <- data[keep, , drop = FALSE]
  } else if (identical(scenario, "rater_item_structural_hole")) {
    data <- data[!(data$Rater %in% c("R01", "R02") &
                     data$Criterion %in% c("C01", "C02")), , drop = FALSE]
  } else if (identical(scenario, "nested_with_one_shared_item")) {
    first <- data$Rater %in% sprintf("R%02d", 1:4)
    left_items <- data$Criterion %in% c("C01", "C02", "C03")
    right_items <- data$Criterion %in% c("C03", "C04", "C05")
    data <- data[(first & left_items) | (!first & right_items), , drop = FALSE]
  } else if (identical(scenario, "rare_upper_category")) {
    upper <- which(data$Score == score_max)
    keep_upper <- if (length(upper)) sample(upper, max(1L, ceiling(.05 * length(upper)))) else integer(0)
    keep <- data$Score != score_max
    keep[keep_upper] <- TRUE
    data <- data[keep, , drop = FALSE]
  } else if (identical(scenario, "unused_middle_category")) {
    data <- data[data$Score != 2L, , drop = FALSE]
  } else if (identical(scenario, "extreme_persons")) {
    data$Score[data$Person %in% c("P001", "P002")] <- score_min
    data$Score[data$Person %in% c("P059", "P060")] <- score_max
  } else if (identical(scenario, "missing_entire_rater")) {
    sentinel <- data[data$Rater == "R08", , drop = FALSE][1, , drop = FALSE]
    sentinel$Score <- NA_integer_
    data <- data[data$Rater != "R08", , drop = FALSE]
  } else if (identical(scenario, "exact_duplicate_cells")) {
    idx <- sample.int(n, ceiling(.05 * n))
    data <- rbind(data, data[idx, , drop = FALSE])
  } else if (identical(scenario, "conflicting_duplicate_cells")) {
    idx <- sample.int(n, ceiling(.05 * n))
    dup <- data[idx, , drop = FALSE]
    dup$Score <- score_min + score_max - dup$Score
    data <- rbind(data, dup)
  } else if (identical(scenario, "rater_drift_contamination")) {
    late <- match(data$Person, sort(unique(data$Person))) > 30L
    target <- late & data$Rater %in% c("R01", "R02")
    data$Score[target] <- pmin(score_max, data$Score[target] + 1L)
  }
  rownames(data) <- NULL
  list(data = data, sentinel = sentinel)
}

mfrmr_facets_450_truth <- function(data, truth) {
  rater <- truth$facets$Rater
  criterion <- truth$facets$Criterion
  rater_mean <- mean(rater)
  criterion_mean <- mean(criterion)
  list(
    person = truth$person - rater_mean - criterion_mean,
    rater = rater - rater_mean,
    criterion = criterion - criterion_mean
  )
}

mfrmr_facets_450_input_table <- function(data, sentinel, truth_common) {
  all_data <- if (is.null(sentinel)) data else rbind(data, sentinel)
  score <- as.integer(all_data$Score) - 1L
  score[is.na(all_data$Score)] <- NA_integer_
  data.frame(
    participant_id = as.character(all_data$Person),
    rater_id = as.character(all_data$Rater),
    task = "pilot",
    criteria = as.character(all_data$Criterion),
    score = score,
    ability = unname(truth_common$person[as.character(all_data$Person)]),
    severity = unname(truth_common$rater[as.character(all_data$Rater)]),
    criteria_difficulty = unname(truth_common$criterion[as.character(all_data$Criterion)]),
    stringsAsFactors = FALSE
  )
}

mfrmr_facets_450_metric_rows <- function(records, engine, model, scenario) {
  if (is.null(records) || nrow(records) == 0L) return(data.frame())
  split_records <- split(records, records$facet)
  do.call(rbind, lapply(names(split_records), function(facet) {
    x <- split_records[[facet]]
    diff <- x$estimate - x$true_value
    data.frame(
      Model = model,
      Scenario = scenario,
      Engine = engine,
      Facet = facet,
      Expected = nrow(x),
      Estimated = sum(is.finite(x$estimate)),
      Bias = mean(diff, na.rm = TRUE),
      MAE = mean(abs(diff), na.rm = TRUE),
      RMSE = sqrt(mean(diff^2, na.rm = TRUE)),
      Correlation = if (sum(stats::complete.cases(x[, c("true_value", "estimate")])) >= 2L) {
        stats::cor(x$true_value, x$estimate, use = "complete.obs")
      } else NA_real_,
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_facets_450_fit_mfrmr <- function(data, truth_common, model, scenario) {
  fit_fun <- mfrmr_facets_450_fun("fit_mfrm")
  analysis <- data[is.finite(data$Score), , drop = FALSE]
  args <- list(
    data = analysis,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    model = model,
    rating_min = 1L,
    rating_max = 4L,
    maxit = 150L
  )
  if (identical(model, "PCM")) args$step_facet <- "Criterion"
  warnings <- character(0)
  fit <- tryCatch(
    withCallingHandlers(
      do.call(fit_fun, args),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )
  if (inherits(fit, "error")) {
    return(list(
      status = "error",
      detail = conditionMessage(fit),
      warnings = warnings,
      readiness = stats::setNames(rep(NA_character_, 6L),
                                  c("Numerical", "Data", "Design", "Stability", "Diagnostics", "Reporting")),
      records = data.frame(),
      metrics = data.frame()
    ))
  }
  person <- fit$facets$person
  others <- fit$facets$others
  records <- rbind(
    data.frame(
      facet = "participant_id",
      element_label = as.character(person$Person),
      true_value = unname(truth_common$person[as.character(person$Person)]),
      estimate = as.numeric(person$Estimate),
      stringsAsFactors = FALSE
    ),
    data.frame(
      facet = "rater_id",
      element_label = as.character(others$Level[others$Facet == "Rater"]),
      true_value = unname(truth_common$rater[as.character(others$Level[others$Facet == "Rater"])]),
      estimate = as.numeric(others$Estimate[others$Facet == "Rater"]),
      stringsAsFactors = FALSE
    ),
    data.frame(
      facet = "criteria",
      element_label = as.character(others$Level[others$Facet == "Criterion"]),
      true_value = unname(truth_common$criterion[as.character(others$Level[others$Facet == "Criterion"])]),
      estimate = as.numeric(others$Estimate[others$Facet == "Criterion"]),
      stringsAsFactors = FALSE
    )
  )
  fit_overview <- fit$summary
  inference_ready <- if ("InferenceReady" %in% names(fit_overview)) {
    as.character(fit_overview$InferenceReady[1])
  } else NA_character_
  fit_review <- summary(fit, profile = "fit", detail = "brief")
  readiness <- stats::setNames(
    as.character(fit_review$readiness$Status),
    as.character(fit_review$readiness$Domain)
  )
  status <- if (isTRUE(fit$opt$convergence == 0L)) "ok" else "review"
  list(
    status = status,
    detail = paste0("convergence=", fit$opt$convergence,
                    "; inference_ready=", inference_ready),
    warnings = unique(warnings),
    readiness = readiness,
    records = records,
    metrics = mfrmr_facets_450_metric_rows(records, "mfrmr_JML", model, scenario)
  )
}

mfrmr_generate_facets_450_stress_inputs <- function(pkg_dir = ".",
                                                     work_dir,
                                                     models = c("RSM", "PCM"),
                                                     profile = c("expanded", "smoke", "extension"),
                                                     seed = 450023L) {
  profile <- match.arg(profile)
  work_dir <- normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  registry <- mfrmr_facets_450_registry(profile)
  manifests <- list()
  mfrmr_runs <- list()
  mfrmr_records <- list()
  mfrmr_metrics <- list()
  run_index <- 0L
  for (model in models) {
    data_root <- file.path(work_dir, tolower(model), "data")
    dir.create(data_root, recursive = TRUE, showWarnings = FALSE)
    for (i in seq_len(nrow(registry))) {
      run_index <- run_index + 1L
      scenario <- registry$Scenario[i]
      scenario_seed <- as.integer(seed + 1000L * match(model, models) + i)
      base <- mfrmr_facets_450_base(scenario, model, scenario_seed)
      truth <- attr(base$data, "mfrm_truth")
      truth_common <- mfrmr_facets_450_truth(base$data, truth)
      changed <- mfrmr_facets_450_transform(base$data, scenario, scenario_seed + 100L)
      data <- changed$data
      input <- mfrmr_facets_450_input_table(data, changed$sentinel, truth_common)
      input_path <- file.path(data_root, paste0("dataset-", scenario, ".csv"))
      utils::write.csv(input, input_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
      fit <- mfrmr_facets_450_fit_mfrmr(data, truth_common, model, scenario)
      cells <- unique(data[, c("Person", "Rater", "Criterion"), drop = FALSE])
      declared <- length(truth_common$person) * length(truth_common$rater) * length(truth_common$criterion)
      category_counts <- tabulate(as.integer(data$Score), nbins = 4L)
      category_prob <- category_counts / sum(category_counts)
      manifests[[run_index]] <- data.frame(
        Model = model,
        Scenario = scenario,
        Seed = scenario_seed,
        Rows = nrow(data),
        UniqueCells = nrow(cells),
        DeclaredCells = declared,
        MissingFraction = 1 - nrow(cells) / declared,
        ObservedPersons = length(unique(data$Person)),
        ObservedRaters = length(unique(data$Rater)),
        ObservedCriteria = length(unique(data$Criterion)),
        ObservedCategories = paste(sort(unique(data$Score)), collapse = ";"),
        CategoryCounts = paste(category_counts, collapse = ";"),
        MinCategoryCount = min(category_counts),
        MaxCategoryFraction = max(category_prob),
        NormalizedCategoryEntropy = if (sum(category_prob > 0) > 1L) {
          -sum(category_prob[category_prob > 0] * log(category_prob[category_prob > 0])) / log(4)
        } else 0,
        InputSHA256 = mfrmr_facets_450_sha256(input_path),
        StressClass = registry$StressClass[i],
        MissingMechanism = registry$MissingMechanism[i],
        Topology = registry$Topology[i],
        ExpectedState = registry$ExpectedState[i],
        stringsAsFactors = FALSE
      )
      mfrmr_runs[[run_index]] <- data.frame(
        Model = model,
        Scenario = scenario,
        Status = fit$status,
        Detail = fit$detail,
        NumericalState = unname(fit$readiness["Numerical"]),
        DataState = unname(fit$readiness["Data"]),
        DesignState = unname(fit$readiness["Design"]),
        StabilityState = unname(fit$readiness["Stability"]),
        ReportingState = unname(fit$readiness["Reporting"]),
        Warnings = paste(fit$warnings, collapse = " | "),
        stringsAsFactors = FALSE
      )
      if (nrow(fit$records)) {
        fit$records$Model <- model
        fit$records$Scenario <- scenario
        mfrmr_records[[run_index]] <- fit$records
      }
      if (nrow(fit$metrics)) mfrmr_metrics[[run_index]] <- fit$metrics
    }
  }
  manifest <- do.call(rbind, manifests)
  utils::write.csv(manifest, file.path(work_dir, "scenario_manifest.csv"), row.names = FALSE)
  utils::write.csv(do.call(rbind, mfrmr_runs), file.path(work_dir, "mfrmr_runs.csv"), row.names = FALSE)
  utils::write.csv(if (length(mfrmr_records)) do.call(rbind, mfrmr_records) else data.frame(),
                   file.path(work_dir, "mfrmr_estimates.csv"), row.names = FALSE)
  utils::write.csv(if (length(mfrmr_metrics)) do.call(rbind, mfrmr_metrics) else data.frame(),
                   file.path(work_dir, "mfrmr_parameter_metrics.csv"), row.names = FALSE)
  invisible(manifest)
}

mfrmr_facets_450_report_version <- function(report_path) {
  if (!file.exists(report_path)) return(NA_character_)
  first <- readLines(report_path, n = 1L, warn = FALSE, encoding = "UTF-8")
  hit <- regmatches(first, regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", first))
  if (length(hit) && nzchar(hit)) hit else NA_character_
}

mfrmr_review_facets_450_stress <- function(work_dir,
                                           models = c("RSM", "PCM"),
                                           facets_exe = "C:/Facets/Facets.exe") {
  manifest <- utils::read.csv(file.path(work_dir, "scenario_manifest.csv"),
                              stringsAsFactors = FALSE)
  mfrmr_runs <- utils::read.csv(file.path(work_dir, "mfrmr_runs.csv"),
                                stringsAsFactors = FALSE)
  mfrmr_records <- utils::read.csv(file.path(work_dir, "mfrmr_estimates.csv"),
                                   stringsAsFactors = FALSE)
  facets_runs <- list()
  facets_metrics <- list()
  agreement <- list()
  k <- 0L
  for (model in models) {
    out_root <- file.path(work_dir, tolower(model), "facets_output")
    timing_path <- file.path(out_root, "batch_timing_dedup.csv")
    timing <- if (file.exists(timing_path)) {
      utils::read.csv(timing_path, stringsAsFactors = FALSE)
    } else data.frame()
    model_scenarios <- manifest$Scenario[manifest$Model == model]
    for (scenario in model_scenarios) {
      k <- k + 1L
      out_dir <- file.path(out_root, paste0("dataset-", scenario))
      report <- file.path(out_dir, "report.txt")
      comp_path <- file.path(out_dir, "truth_comparison.csv")
      timing_row <- if (nrow(timing)) timing[timing$dataset == paste0("dataset-", scenario), , drop = FALSE] else data.frame()
      status <- if (nrow(timing_row)) as.character(timing_row$status[1]) else "missing"
      warning_path <- file.path(out_dir, "warnings.txt")
      warning_text <- if (file.exists(warning_path)) {
        paste(readLines(warning_path, warn = FALSE, encoding = "UTF-8"), collapse = " | ")
      } else ""
      facets_runs[[k]] <- data.frame(
        Model = model,
        Scenario = scenario,
        Status = status,
        ReturnCode = if (nrow(timing_row)) timing_row$return_code[1] else NA,
        ElapsedSeconds = if (nrow(timing_row)) timing_row$elapsed_sec[1] else NA,
        ReportVersion = mfrmr_facets_450_report_version(report),
        ReportSHA256 = mfrmr_facets_450_sha256(report),
        Warnings = warning_text,
        stringsAsFactors = FALSE
      )
      if (!file.exists(comp_path)) next
      comp <- utils::read.csv(comp_path, stringsAsFactors = FALSE)
      names(comp) <- tolower(names(comp))
      comp$true_value <- as.numeric(comp$true_value)
      comp$estimate <- as.numeric(comp$estimate)
      facets_metrics[[k]] <- mfrmr_facets_450_metric_rows(
        comp[, c("facet", "element_label", "true_value", "estimate")],
        "FACETS_4.5.0", model, scenario
      )
      mine <- mfrmr_records[mfrmr_records$Model == model &
                              mfrmr_records$Scenario == scenario, , drop = FALSE]
      if (!nrow(mine)) next
      matched <- merge(
        mine[, c("facet", "element_label", "estimate")],
        comp[, c("facet", "element_label", "estimate")],
        by = c("facet", "element_label"), suffixes = c("_mfrmr", "_facets")
      )
      if (!nrow(matched)) next
      by_facet <- split(matched, matched$facet)
      agreement[[k]] <- do.call(rbind, lapply(names(by_facet), function(facet) {
        x <- by_facet[[facet]]
        diff <- x$estimate_mfrmr - x$estimate_facets
        data.frame(
          Model = model,
          Scenario = scenario,
          Facet = facet,
          Matched = nrow(x),
          MeanDifference = mean(diff),
          MAE = mean(abs(diff)),
          RMSE = sqrt(mean(diff^2)),
          MaxAbsoluteDifference = max(abs(diff)),
          Correlation = if (nrow(x) >= 2L) stats::cor(x$estimate_mfrmr, x$estimate_facets) else NA_real_,
          stringsAsFactors = FALSE
        )
      }))
    }
  }
  facets_runs <- do.call(rbind, facets_runs)
  facets_metrics <- if (length(Filter(NROW, facets_metrics))) do.call(rbind, Filter(NROW, facets_metrics)) else data.frame()
  agreement <- if (length(Filter(NROW, agreement))) do.call(rbind, Filter(NROW, agreement)) else data.frame()
  run_summary <- merge(manifest, mfrmr_runs, by = c("Model", "Scenario"), all.x = TRUE,
                       suffixes = c("", "_mfrmr"))
  run_summary <- merge(run_summary, facets_runs, by = c("Model", "Scenario"), all.x = TRUE,
                       suffixes = c("_mfrmr", "_facets"))
  exe_version <- if (file.exists(facets_exe)) {
    info <- file.info(facets_exe)
    paste0("sha256=", mfrmr_facets_450_sha256(facets_exe), "; bytes=", info$size)
  } else "missing"
  identity <- data.frame(
    Field = c("SelectedVersion", "Executable", "ExecutableIdentity", "RunDate", "EvidenceRole"),
    Value = c("4.5.0", normalizePath(facets_exe, winslash = "/", mustWork = FALSE),
              exe_version, as.character(Sys.Date()), "pilot_only_no_confirmation"),
    stringsAsFactors = FALSE
  )
  utils::write.csv(run_summary, file.path(work_dir, "paired_run_summary.csv"), row.names = FALSE)
  utils::write.csv(facets_metrics, file.path(work_dir, "facets_parameter_metrics.csv"), row.names = FALSE)
  utils::write.csv(agreement, file.path(work_dir, "mfrmr_facets_agreement.csv"), row.names = FALSE)
  utils::write.csv(identity, file.path(work_dir, "facets_identity.csv"), row.names = FALSE)
  list(
    status = "pilot_review",
    run_summary = run_summary,
    facets_metrics = facets_metrics,
    agreement = agreement,
    identity = identity
  )
}

mfrmr_run_facets_450_stress_pilot <- function(
    pkg_dir = ".",
    work_dir,
    facets_exe = "C:/Facets/Facets.exe",
    batch_runner = "../../FACETS/run_facets_batch.py",
    python = "python",
    models = c("RSM", "PCM"),
    profile = c("expanded", "smoke", "extension"),
    seed = 450023L) {
  profile <- match.arg(profile)
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = TRUE)
  work_dir <- normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  batch_runner <- normalizePath(file.path(pkg_dir, batch_runner), winslash = "/", mustWork = TRUE)
  facets_exe <- normalizePath(facets_exe, winslash = "/", mustWork = TRUE)
  mfrmr_generate_facets_450_stress_inputs(
    pkg_dir = pkg_dir,
    work_dir = work_dir,
    models = models,
    profile = profile,
    seed = seed
  )
  for (model in models) {
    data_root <- file.path(work_dir, tolower(model), "data")
    out_root <- file.path(work_dir, tolower(model), "facets_output")
    temp_root <- file.path(work_dir, tolower(model), "facets_temp")
    log_path <- file.path(work_dir, paste0("facets_", tolower(model), "_batch.log"))
    args <- c(
      shQuote(batch_runner),
      "--model", model,
      "--region-mode", "background",
      "--facets", shQuote(facets_exe),
      "--data-root", shQuote(data_root),
      "--out-root", shQuote(out_root),
      "--glob", "dataset-*.csv",
      "--skip-unzip", "--skip-viz", "--tables", "No",
      "--temp-root", shQuote(temp_root)
    )
    code <- system2(python, args = args, stdout = log_path, stderr = log_path)
    if (!identical(as.integer(code), 0L)) {
      warning("FACETS batch runner returned ", code, " for ", model,
              "; review continues for any completed scenario outputs.", call. = FALSE)
    }
  }
  mfrmr_review_facets_450_stress(work_dir, models = models, facets_exe = facets_exe)
}

mfrmr_facets_450_cli_value <- function(args, name, default = NULL) {
  prefix <- paste0("--", name, "=")
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  substring(hit[[length(hit)]], nchar(prefix) + 1L)
}

if (sys.nframe() == 0L) {
  cli_args <- commandArgs(trailingOnly = TRUE)
  cli_work_dir <- mfrmr_facets_450_cli_value(cli_args, "work-dir")
  if (is.null(cli_work_dir) || !nzchar(cli_work_dir)) {
    stop("Direct execution requires --work-dir=<path>.", call. = FALSE)
  }
  cli_pkg_dir <- mfrmr_facets_450_cli_value(cli_args, "pkg-dir", ".")
  user_library <- Sys.getenv("R_LIBS_USER")
  if (nzchar(user_library)) .libPaths(c(user_library, .libPaths()))
  if (!requireNamespace("pkgload", quietly = TRUE)) {
    stop("Direct execution requires the repository-only pkgload package.",
         call. = FALSE)
  }
  pkgload::load_all(cli_pkg_dir, quiet = TRUE)
  cli_result <- mfrmr_run_facets_450_stress_pilot(
    pkg_dir = cli_pkg_dir,
    work_dir = cli_work_dir,
    facets_exe = mfrmr_facets_450_cli_value(cli_args, "facets", "C:/Facets/Facets.exe"),
    batch_runner = mfrmr_facets_450_cli_value(
      cli_args, "batch-runner", "../../FACETS/run_facets_batch.py"
    ),
    python = mfrmr_facets_450_cli_value(cli_args, "python", "python"),
    profile = mfrmr_facets_450_cli_value(cli_args, "profile", "expanded"),
    seed = as.integer(mfrmr_facets_450_cli_value(cli_args, "seed", "450023"))
  )
  cat(
    "FACETS 4.5.0 stress pilot:", cli_result$status, "\n",
    "Runs reviewed:", nrow(cli_result$run_summary), "\n",
    "Work directory:", normalizePath(cli_work_dir, winslash = "/", mustWork = FALSE), "\n"
  )
}
