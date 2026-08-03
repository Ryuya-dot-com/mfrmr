# Repository-only interaction, bias-screening, and residual-PCA stress pilot
# for mfrmr 0.2.3. This is calibration instrumentation, not confirmation.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_diag_stress_fun <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  getExportedValue("mfrmr", name)
}

mfrmr_diag_stress_registry <- function(profile = c("expanded", "smoke")) {
  profile <- match.arg(profile)
  scenarios <- c(
    "balanced_complete",
    "two_rater_complete",
    "two_rater_one_per_person",
    "two_rater_weak_overlap",
    "category_middle_dominant",
    "category_single_dominant",
    "category_skewed_person",
    "interaction_checkerboard_weak",
    "interaction_checkerboard_strong",
    "residual_local_dependence"
  )
  if (identical(profile, "smoke")) {
    scenarios <- c(
      "balanced_complete", "two_rater_complete",
      "category_middle_dominant", "interaction_checkerboard_strong",
      "residual_local_dependence"
    )
  }
  scenarios
}

mfrmr_diag_stress_capture <- function(expr) {
  warnings <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) e
  )
  list(value = value, warnings = unique(warnings))
}

mfrmr_diag_stress_readiness <- function(fit) {
  if (inherits(fit, "error")) {
    return(stats::setNames(
      rep(NA_character_, 6L),
      c("Numerical", "Data", "Design", "Stability", "Diagnostics", "Reporting")
    ))
  }
  review <- summary(fit, profile = "fit", detail = "brief")
  stats::setNames(
    as.character(review$readiness$Status),
    as.character(review$readiness$Domain)
  )
}

mfrmr_diag_stress_category <- function(data, n_categories = 4L) {
  counts <- tabulate(as.integer(data$Score), nbins = n_categories)
  prop <- counts / sum(counts)
  data.frame(
    CategoryCounts = paste(counts, collapse = ";"),
    MinCategoryCount = min(counts),
    MaxCategoryFraction = max(prop),
    NormalizedCategoryEntropy = if (sum(prop > 0) > 1L) {
      -sum(prop[prop > 0] * log(prop[prop > 0])) / log(n_categories)
    } else 0,
    stringsAsFactors = FALSE
  )
}

mfrmr_diag_stress_pca_cell <- function(tbl, facet = NULL) {
  if (is.null(tbl) || nrow(tbl) == 0L) {
    return(c(Eigenvalue = NA_real_, ParallelCutoff = NA_real_,
             Excess = NA_real_, Exceeds = NA_real_))
  }
  x <- tbl[tbl$Component == 1L, , drop = FALSE]
  if (!is.null(facet) && "Facet" %in% names(x)) {
    x <- x[as.character(x$Facet) == facet, , drop = FALSE]
  }
  if (!nrow(x)) {
    return(c(Eigenvalue = NA_real_, ParallelCutoff = NA_real_,
             Excess = NA_real_, Exceeds = NA_real_))
  }
  c(
    Eigenvalue = as.numeric(x$Eigenvalue[1]),
    ParallelCutoff = as.numeric(x$ParallelCutoff[1] %||% NA_real_),
    Excess = as.numeric(x$ExcessOverParallelCutoff[1] %||% NA_real_),
    Exceeds = as.numeric(x$ExceedsParallelCutoff[1] %||% NA)
  )
}

mfrmr_diag_stress_bias <- function(bias, target_rater = "R01", target_criterion = "C01") {
  empty <- list(
    summary = data.frame(
      BiasTargetEstimate = NA_real_, BiasTargetT = NA_real_,
      BiasTargetP = NA_real_, BiasTargetScreenPositive = NA,
      BiasNonTargetScreenRate = NA_real_, BiasMaxAbsEstimate = NA_real_,
      BiasMetricAvailabilityRate = NA_real_, stringsAsFactors = FALSE
    ),
    cells = data.frame()
  )
  if (inherits(bias, "error") || is.null(bias$table) || !nrow(bias$table)) return(empty)
  tbl <- as.data.frame(bias$table, stringsAsFactors = FALSE)
  target <- tbl[
    as.character(tbl$FacetA_Level) == target_rater &
      as.character(tbl$FacetB_Level) == target_criterion,
    , drop = FALSE
  ]
  p <- if (nrow(target)) suppressWarnings(as.numeric(target$`Prob.`[1])) else NA_real_
  t_value <- if (nrow(target)) suppressWarnings(as.numeric(target$t[1])) else NA_real_
  estimate <- if (nrow(target)) suppressWarnings(as.numeric(target$`Bias Size`[1])) else NA_real_
  flags <- is.finite(tbl$`Prob.`) & tbl$`Prob.` <= 0.05 &
    is.finite(tbl$t) & abs(tbl$t) >= 2
  is_target <- as.character(tbl$FacetA_Level) == target_rater &
    as.character(tbl$FacetB_Level) == target_criterion
  empty$summary <- data.frame(
    BiasTargetEstimate = estimate,
    BiasTargetT = t_value,
    BiasTargetP = p,
    BiasTargetScreenPositive = is.finite(p) && p <= 0.05 &&
      is.finite(t_value) && abs(t_value) >= 2,
    BiasNonTargetScreenRate = if (any(!is_target)) mean(flags[!is_target]) else NA_real_,
    BiasMaxAbsEstimate = max(abs(suppressWarnings(as.numeric(tbl$`Bias Size`))), na.rm = TRUE),
    BiasMetricAvailabilityRate = mean(is.finite(tbl$`Prob.`) & is.finite(tbl$t)),
    stringsAsFactors = FALSE
  )
  empty$cells <- tbl
  empty
}

mfrmr_diag_stress_interaction_truth <- function(data, effect_table) {
  raters <- sort(unique(as.character(data$Rater)))
  criteria <- sort(unique(as.character(data$Criterion)))
  truth <- expand.grid(
    FacetA_Level = raters,
    FacetB_Level = criteria,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  truth$TrueEffect <- 0
  if (!is.null(effect_table) && nrow(effect_table) &&
      all(c("Rater", "Criterion", "Effect") %in% names(effect_table))) {
    key <- paste(effect_table$Rater, effect_table$Criterion, sep = "\r")
    idx <- match(paste(truth$FacetA_Level, truth$FacetB_Level, sep = "\r"), key)
    hit <- !is.na(idx)
    truth$TrueEffect[hit] <- as.numeric(effect_table$Effect[idx[hit]])
  }
  truth
}

mfrmr_diag_stress_interaction <- function(fit, truth) {
  empty <- list(
    summary = data.frame(
      InteractionCells = NA_integer_, InteractionRMSE = NA_real_,
      InteractionMAE = NA_real_, InteractionMaxAbsError = NA_real_,
      InteractionCorrelation = NA_real_, InteractionTargetEstimate = NA_real_,
      InteractionTargetTruth = NA_real_, InteractionTargetError = NA_real_,
      stringsAsFactors = FALSE
    ),
    cells = data.frame()
  )
  if (inherits(fit, "error")) return(empty)
  extract <- mfrmr_diag_stress_fun("interaction_effect_table")
  tbl <- as.data.frame(extract(fit), stringsAsFactors = FALSE)
  if (!nrow(tbl)) return(empty)
  cells <- merge(
    tbl, truth,
    by = c("FacetA_Level", "FacetB_Level"),
    all.x = TRUE, sort = FALSE
  )
  cells$TrueEffect[is.na(cells$TrueEffect)] <- 0
  cells$Error <- as.numeric(cells$Estimate) - cells$TrueEffect
  target <- cells[
    cells$FacetA_Level == "R01" & cells$FacetB_Level == "C01",
    , drop = FALSE
  ]
  empty$summary <- data.frame(
    InteractionCells = nrow(cells),
    InteractionRMSE = sqrt(mean(cells$Error^2)),
    InteractionMAE = mean(abs(cells$Error)),
    InteractionMaxAbsError = max(abs(cells$Error)),
    InteractionCorrelation = if (stats::sd(cells$TrueEffect) > 0) {
      stats::cor(cells$Estimate, cells$TrueEffect)
    } else NA_real_,
    InteractionTargetEstimate = if (nrow(target)) target$Estimate[1] else NA_real_,
    InteractionTargetTruth = if (nrow(target)) target$TrueEffect[1] else NA_real_,
    InteractionTargetError = if (nrow(target)) target$Error[1] else NA_real_,
    stringsAsFactors = FALSE
  )
  empty$cells <- cells
  empty
}

mfrmr_diag_stress_facets_residual <- function(path, mfrmr_obs = NULL) {
  empty <- data.frame(
    FacetsResidualRows = 0L, FacetsOverallPC1Raw = NA_real_,
    MatchedResiduals = 0L, StandardizedResidualCorrelation = NA_real_,
    stringsAsFactors = FALSE
  )
  if (is.null(path) || !file.exists(path)) return(empty)
  facets <- tryCatch(utils::read.csv(path, stringsAsFactors = FALSE), error = function(e) e)
  if (inherits(facets, "error") || !nrow(facets)) return(empty)
  required <- c("participant_id", "rater_id", "criteria", "StRes")
  if (!all(required %in% names(facets))) return(empty)
  facets$StRes <- suppressWarnings(as.numeric(facets$StRes))
  facets <- facets[is.finite(facets$StRes), , drop = FALSE]
  if (!nrow(facets)) return(empty)

  facets$Person <- as.character(facets$participant_id)
  facets$Item <- paste(as.character(facets$rater_id),
                       as.character(facets$criteria), sep = "_")
  agg <- stats::aggregate(StRes ~ Person + Item, data = facets, FUN = mean)
  wide <- reshape(agg, idvar = "Person", timevar = "Item", direction = "wide")
  matrix <- as.matrix(wide[, setdiff(names(wide), "Person"), drop = FALSE])
  cor_matrix <- if (nrow(matrix) >= 2L && ncol(matrix) >= 2L) {
    suppressWarnings(stats::cor(matrix, use = "pairwise.complete.obs"))
  } else NULL
  pc1 <- NA_real_
  if (!is.null(cor_matrix)) {
    cor_matrix[!is.finite(cor_matrix)] <- 0
    diag(cor_matrix) <- 1
    pc1 <- tryCatch(
      max(eigen(cor_matrix, symmetric = TRUE, only.values = TRUE)$values),
      error = function(e) NA_real_
    )
  }

  matched_n <- 0L
  residual_cor <- NA_real_
  if (!is.null(mfrmr_obs) && nrow(mfrmr_obs) &&
      all(c("Person", "Rater", "Criterion", "StdResidual") %in% names(mfrmr_obs))) {
    mine <- as.data.frame(mfrmr_obs[, c("Person", "Rater", "Criterion", "StdResidual")])
    names(mine)[4] <- "mfrmr_StRes"
    theirs <- data.frame(
      Person = as.character(facets$participant_id),
      Rater = as.character(facets$rater_id),
      Criterion = as.character(facets$criteria),
      facets_StRes = facets$StRes,
      stringsAsFactors = FALSE
    )
    matched <- merge(mine, theirs, by = c("Person", "Rater", "Criterion"))
    matched <- matched[stats::complete.cases(matched[, c("mfrmr_StRes", "facets_StRes")]), ]
    matched_n <- nrow(matched)
    if (matched_n >= 2L) {
      residual_cor <- stats::cor(matched$mfrmr_StRes, matched$facets_StRes)
    }
  }
  data.frame(
    FacetsResidualRows = nrow(facets),
    FacetsOverallPC1Raw = pc1,
    MatchedResiduals = matched_n,
    StandardizedResidualCorrelation = residual_cor,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_interaction_bias_pca_stress_pilot <- function(
    pkg_dir = ".",
    work_dir,
    facets_work_dir = NULL,
    models = c("RSM", "PCM"),
    profile = c("expanded", "smoke"),
    seed = 450123L,
    parallel_reps = 50L) {
  profile <- match.arg(profile)
  pkg_dir <- normalizePath(pkg_dir, winslash = "/", mustWork = TRUE)
  work_dir <- normalizePath(work_dir, winslash = "/", mustWork = FALSE)
  dir.create(work_dir, recursive = TRUE, showWarnings = FALSE)
  facets_work_dir <- if (is.null(facets_work_dir)) NULL else {
    normalizePath(facets_work_dir, winslash = "/", mustWork = FALSE)
  }
  facets_manifest_path <- if (is.null(facets_work_dir)) NULL else {
    file.path(facets_work_dir, "scenario_manifest.csv")
  }
  facets_manifest <- if (!is.null(facets_manifest_path) &&
                          file.exists(facets_manifest_path)) {
    utils::read.csv(facets_manifest_path, stringsAsFactors = FALSE)
  } else {
    data.frame()
  }

  facets_driver <- file.path(
    pkg_dir, "inst", "validation", "facets-4.5.0-stress-pilot-0.2.3.R"
  )
  source(facets_driver, local = environment())
  fit_fun <- mfrmr_diag_stress_fun("fit_mfrm")
  diagnose_fun <- mfrmr_diag_stress_fun("diagnose_mfrm")
  pca_fun <- mfrmr_diag_stress_fun("analyze_residual_pca")
  bias_fun <- mfrmr_diag_stress_fun("estimate_bias")

  scenarios <- mfrmr_diag_stress_registry(profile)
  runs <- list()
  interaction_cells <- list()
  bias_cells <- list()
  index <- 0L

  for (model in models) {
    for (scenario in scenarios) {
      index <- index + 1L
      manifest_row <- facets_manifest[
        as.character(facets_manifest$Model) == model &
          as.character(facets_manifest$Scenario) == scenario,
        , drop = FALSE
      ]
      scenario_seed <- if (nrow(manifest_row) == 1L &&
                           is.finite(as.numeric(manifest_row$Seed[1]))) {
        as.integer(manifest_row$Seed[1])
      } else {
        as.integer(seed + 1000L * match(model, models) +
                     match(scenario, scenarios))
      }
      seed_source <- if (nrow(manifest_row) == 1L) {
        "facets_manifest"
      } else {
        "diagnostic_registry"
      }
      generated <- mfrmr_facets_450_base(scenario, model, scenario_seed)
      changed <- mfrmr_facets_450_transform(
        generated$data, scenario, scenario_seed + 100L
      )
      data <- changed$data[is.finite(changed$data$Score), , drop = FALSE]
      truth_signals <- attr(generated$data, "mfrm_truth")$signals$interaction_effects
      interaction_truth <- mfrmr_diag_stress_interaction_truth(data, truth_signals)
      category <- mfrmr_diag_stress_category(data)

      fit_args <- list(
        data = data, person = "Person", facets = c("Rater", "Criterion"),
        score = "Score", method = "JML", model = model,
        rating_min = 1L, rating_max = 4L, maxit = 150L
      )
      if (identical(model, "PCM")) fit_args$step_facet <- "Criterion"
      additive_capture <- mfrmr_diag_stress_capture(do.call(fit_fun, fit_args))
      additive <- additive_capture$value
      readiness <- mfrmr_diag_stress_readiness(additive)

      diagnostics_capture <- if (inherits(additive, "error")) {
        list(value = additive, warnings = character(0))
      } else {
        mfrmr_diag_stress_capture(diagnose_fun(additive, residual_pca = "none"))
      }
      diagnostics <- diagnostics_capture$value
      pca_capture <- if (inherits(diagnostics, "error")) {
        list(value = diagnostics, warnings = character(0))
      } else {
        mfrmr_diag_stress_capture(pca_fun(
          diagnostics, mode = "both", parallel = TRUE,
          parallel_reps = parallel_reps,
          seed = scenario_seed + 200L
        ))
      }
      pca <- pca_capture$value
      overall_pca <- if (inherits(pca, "error")) {
        mfrmr_diag_stress_pca_cell(NULL)
      } else {
        mfrmr_diag_stress_pca_cell(pca$overall_table)
      }
      rater_pca <- if (inherits(pca, "error")) {
        mfrmr_diag_stress_pca_cell(NULL)
      } else {
        mfrmr_diag_stress_pca_cell(pca$by_facet_table, "Rater")
      }
      criterion_pca <- if (inherits(pca, "error")) {
        mfrmr_diag_stress_pca_cell(NULL)
      } else {
        mfrmr_diag_stress_pca_cell(pca$by_facet_table, "Criterion")
      }

      bias_capture <- if (inherits(diagnostics, "error")) {
        list(value = diagnostics, warnings = character(0))
      } else {
        mfrmr_diag_stress_capture(bias_fun(
          additive, diagnostics, facet_a = "Rater", facet_b = "Criterion",
          max_iter = 10L
        ))
      }
      bias_result <- mfrmr_diag_stress_bias(bias_capture$value)
      if (nrow(bias_result$cells)) {
        bias_result$cells$Model <- model
        bias_result$cells$Scenario <- scenario
        bias_cells[[index]] <- bias_result$cells
      }

      interaction_args <- fit_args
      interaction_args$facet_interactions <- "Rater:Criterion"
      interaction_capture <- mfrmr_diag_stress_capture(
        do.call(fit_fun, interaction_args)
      )
      interaction <- interaction_capture$value
      interaction_readiness <- mfrmr_diag_stress_readiness(interaction)
      interaction_result <- mfrmr_diag_stress_interaction(
        interaction, interaction_truth
      )
      if (nrow(interaction_result$cells)) {
        interaction_result$cells$Model <- model
        interaction_result$cells$Scenario <- scenario
        interaction_cells[[index]] <- interaction_result$cells
      }

      facets_residual_path <- if (is.null(facets_work_dir)) NULL else file.path(
        facets_work_dir, tolower(model), "facets_output",
        paste0("dataset-", scenario), "residuals.txt"
      )
      facets_residual <- mfrmr_diag_stress_facets_residual(
        facets_residual_path,
        if (inherits(diagnostics, "error")) NULL else diagnostics$obs
      )

      error_messages <- c(
        if (inherits(additive, "error")) conditionMessage(additive),
        if (inherits(diagnostics, "error")) conditionMessage(diagnostics),
        if (inherits(pca, "error")) conditionMessage(pca),
        if (inherits(bias_capture$value, "error")) conditionMessage(bias_capture$value),
        if (inherits(interaction, "error")) conditionMessage(interaction)
      )
      warnings <- unique(c(
        additive_capture$warnings, diagnostics_capture$warnings,
        pca_capture$warnings, bias_capture$warnings,
        interaction_capture$warnings
      ))
      true_target <- interaction_truth$TrueEffect[
        interaction_truth$FacetA_Level == "R01" &
          interaction_truth$FacetB_Level == "C01"
      ][1] %||% 0

      runs[[index]] <- cbind(
        data.frame(
          Model = model,
          Scenario = scenario,
          Seed = scenario_seed,
          SeedSource = seed_source,
          Rows = nrow(data),
          Raters = length(unique(data$Rater)),
          Criteria = length(unique(data$Criterion)),
          Persons = length(unique(data$Person)),
          TrueTargetInteraction = as.numeric(true_target),
          AdditiveRunOK = !inherits(additive, "error"),
          AdditiveNumericalState = unname(readiness["Numerical"]),
          AdditiveDataState = unname(readiness["Data"]),
          AdditiveDesignState = unname(readiness["Design"]),
          AdditiveReportingState = unname(readiness["Reporting"]),
          InteractionRunOK = !inherits(interaction, "error"),
          InteractionNumericalState = unname(interaction_readiness["Numerical"]),
          InteractionDataState = unname(interaction_readiness["Data"]),
          InteractionDesignState = unname(interaction_readiness["Design"]),
          InteractionReportingState = unname(interaction_readiness["Reporting"]),
          OverallPC1 = overall_pca["Eigenvalue"],
          OverallPC1ParallelCutoff = overall_pca["ParallelCutoff"],
          OverallPC1Excess = overall_pca["Excess"],
          OverallPC1ExceedsParallel = as.logical(overall_pca["Exceeds"]),
          RaterPC1 = rater_pca["Eigenvalue"],
          RaterPC1ParallelCutoff = rater_pca["ParallelCutoff"],
          RaterPC1Excess = rater_pca["Excess"],
          CriterionPC1 = criterion_pca["Eigenvalue"],
          CriterionPC1ParallelCutoff = criterion_pca["ParallelCutoff"],
          CriterionPC1Excess = criterion_pca["Excess"],
          AdditiveWarnings = paste(additive_capture$warnings, collapse = " | "),
          DiagnosticWarnings = paste(
            unique(c(diagnostics_capture$warnings, pca_capture$warnings,
                     bias_capture$warnings)), collapse = " | "
          ),
          InteractionWarnings = paste(interaction_capture$warnings, collapse = " | "),
          Errors = paste(unique(error_messages), collapse = " | "),
          Warnings = paste(warnings, collapse = " | "),
          stringsAsFactors = FALSE
        ),
        category,
        bias_result$summary,
        interaction_result$summary,
        facets_residual
      )
    }
  }

  run_table <- do.call(rbind, runs)
  interaction_table <- if (length(Filter(NROW, interaction_cells))) {
    do.call(rbind, Filter(NROW, interaction_cells))
  } else data.frame()
  bias_table <- if (length(Filter(NROW, bias_cells))) {
    do.call(rbind, Filter(NROW, bias_cells))
  } else data.frame()
  utils::write.csv(run_table, file.path(work_dir, "diagnostic_stress_runs.csv"),
                   row.names = FALSE)
  utils::write.csv(interaction_table, file.path(work_dir, "interaction_cells.csv"),
                   row.names = FALSE)
  utils::write.csv(bias_table, file.path(work_dir, "bias_screen_cells.csv"),
                   row.names = FALSE)
  invisible(list(
    status = "pilot_review",
    runs = run_table,
    interaction_cells = interaction_table,
    bias_cells = bias_table
  ))
}

mfrmr_diag_stress_cli_value <- function(args, name, default = NULL) {
  prefix <- paste0("--", name, "=")
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  substring(hit[[length(hit)]], nchar(prefix) + 1L)
}

if (sys.nframe() == 0L) {
  cli_args <- commandArgs(trailingOnly = TRUE)
  cli_work_dir <- mfrmr_diag_stress_cli_value(cli_args, "work-dir")
  if (is.null(cli_work_dir) || !nzchar(cli_work_dir)) {
    stop("Direct execution requires --work-dir=<path>.", call. = FALSE)
  }
  cli_pkg_dir <- mfrmr_diag_stress_cli_value(cli_args, "pkg-dir", ".")
  user_library <- Sys.getenv("R_LIBS_USER")
  if (nzchar(user_library)) .libPaths(c(user_library, .libPaths()))
  if (!requireNamespace("pkgload", quietly = TRUE)) {
    stop("Direct execution requires the repository-only pkgload package.",
         call. = FALSE)
  }
  pkgload::load_all(cli_pkg_dir, quiet = TRUE)
  cli_facets_work_dir <- mfrmr_diag_stress_cli_value(
    cli_args, "facets-work-dir", NULL
  )
  cli_result <- mfrmr_run_interaction_bias_pca_stress_pilot(
    pkg_dir = cli_pkg_dir,
    work_dir = cli_work_dir,
    facets_work_dir = cli_facets_work_dir,
    profile = mfrmr_diag_stress_cli_value(cli_args, "profile", "expanded"),
    seed = as.integer(mfrmr_diag_stress_cli_value(cli_args, "seed", "450123")),
    parallel_reps = as.integer(mfrmr_diag_stress_cli_value(
      cli_args, "parallel-reps", "50"
    ))
  )
  cat(
    "Interaction/bias/PCA stress pilot:", cli_result$status, "\n",
    "Runs reviewed:", nrow(cli_result$runs), "\n",
    "Work directory:", normalizePath(cli_work_dir, winslash = "/", mustWork = FALSE), "\n"
  )
}
