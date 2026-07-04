# DIF/DFF simulation matrix review for the 0.2.2 program.
#
# This script is intentionally not part of the CRAN-time test suite. It builds
# seeded RSM, PCM, and bounded-GPCM simulation cases for categorical two-group
# DFF, categorical three-group DFF, null DFF, and continuous-covariate DFF
# moderation. The checks emphasize route boundaries, target direction, output
# schema, and reporting/plot payload consistency. Larger operating-characteristic
# claims require increasing `reps` outside CRAN timing constraints.
#
# Run from the package root:
#   Rscript inst/validation/dif-dff-simulation-matrix-0.2.2.R [reps] [out_dir]
#
# By default, generated files are written under validation-results/ so short
# smoke runs do not look like curated release evidence.

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

.mfrmr_dif_sim_get_function <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  if (requireNamespace("mfrmr", quietly = TRUE)) {
    return(utils::getFromNamespace(name, "mfrmr"))
  }
  stop("`", name, "()` is not available. Load or install mfrmr first.",
       call. = FALSE)
}

.mfrmr_dif_sim_forbidden_hits <- function(text) {
  forbidden <- c(
    "bias was detected",
    "measurement bias was detected",
    "fairness was established",
    "invariance was established",
    "proved measurement bias",
    "proved fairness",
    "operational subgroup decision"
  )
  forbidden[vapply(forbidden, function(pattern) {
    grepl(tolower(pattern), tolower(text), fixed = TRUE)
  }, logical(1))]
}

.mfrmr_dif_sim_check_row <- function(model, scenario, rep, check, passed,
                                     detail = "") {
  data.frame(
    Model = as.character(model),
    Scenario = as.character(scenario),
    Rep = as.integer(rep),
    Check = as.character(check),
    Passed = isTRUE(passed),
    Detail = as.character(detail),
    stringsAsFactors = FALSE
  )
}

.mfrmr_dif_sim_model_controls <- function(model) {
  model <- toupper(as.character(model[1]))
  if (!model %in% c("RSM", "PCM", "GPCM")) {
    stop("Unsupported model in simulation matrix: ", model, call. = FALSE)
  }
  list(
    model = model,
    step_facet = if (identical(model, "RSM")) NULL else "Criterion",
    slope_facet = if (identical(model, "GPCM")) "Criterion" else NULL,
    slopes = if (identical(model, "GPCM")) {
      data.frame(
        SlopeFacet = paste0("C0", 1:3),
        Estimate = c(0.80, 1.00, 1.25),
        stringsAsFactors = FALSE
      )
    } else {
      NULL
    },
    fit_method = if (identical(model, "GPCM")) "MML" else "JML"
  )
}

.mfrmr_dif_sim_seed <- function(model, scenario, rep, seed_base) {
  model_index <- match(model, c("RSM", "PCM", "GPCM"))
  scenario_base <- switch(
    scenario,
    categorical_signal = 100L,
    categorical_null = 200L,
    continuous_signal = 300L,
    categorical_three_level = 400L,
    900L
  )
  seed_base + scenario_base + model_index + (as.integer(rep) - 1L) * 1000L
}

.mfrmr_dif_sim_generate <- function(model,
                                    scenario,
                                    seed,
                                    n_person = 80L,
                                    score_levels = 4L,
                                    target_level = "C02",
                                    categorical_effect = -1.0,
                                    three_level_effect = -1.2) {
  simulate_mfrm_data <- .mfrmr_dif_sim_get_function("simulate_mfrm_data")
  controls <- .mfrmr_dif_sim_model_controls(model)
  n_case <- if (identical(scenario, "continuous_signal")) {
    min(as.integer(n_person), 60L)
  } else {
    as.integer(n_person)
  }
  args <- list(
    n_person = n_case,
    n_rater = 3L,
    n_criterion = 3L,
    raters_per_person = 3L,
    score_levels = score_levels,
    model = controls$model,
    seed = seed
  )
  if (!is.null(controls$step_facet)) {
    args$step_facet <- controls$step_facet
  }
  if (!is.null(controls$slope_facet)) {
    args$slope_facet <- controls$slope_facet
  }
  if (!is.null(controls$slopes)) {
    args$slopes <- controls$slopes
  }

  if (identical(scenario, "categorical_signal")) {
    args$group_levels <- c("Reference", "Focal")
    args$dif_effects <- data.frame(
      Group = "Focal",
      Criterion = target_level,
      Effect = categorical_effect,
      stringsAsFactors = FALSE
    )
  } else if (identical(scenario, "categorical_null")) {
    args$group_levels <- c("Reference", "Focal")
  } else if (identical(scenario, "categorical_three_level")) {
    args$group_levels <- c("Reference", "FocalA", "FocalB")
    args$dif_effects <- data.frame(
      Group = "FocalB",
      Criterion = target_level,
      Effect = three_level_effect,
      stringsAsFactors = FALSE
    )
  }

  dat <- do.call(simulate_mfrm_data, args)

  if (identical(scenario, "continuous_signal")) {
    persons <- sort(unique(as.character(dat$Person)))
    covariate <- seq(-1.5, 1.5, length.out = length(persons))
    lookup <- setNames(covariate, persons)
    dat$AgeLike <- as.numeric(lookup[as.character(dat$Person)])
    rating_max <- max(dat$Score, na.rm = TRUE)
    hit <- dat$Criterion == target_level & dat$AgeLike > 0.5
    dat$Score[hit] <- pmin(rating_max, dat$Score[hit] + 1L)
    attr(dat, "mfrmr_continuous_signal") <- data.frame(
      Covariate = "AgeLike",
      Criterion = target_level,
      Direction = "positive",
      Rule = "Score increased by 1 for high-covariate target rows, clipped at rating_max.",
      stringsAsFactors = FALSE
    )
  }

  dat
}

.mfrmr_dif_sim_fit <- function(dat, model, maxit = 30L, quad_points = 7L) {
  fit_mfrm <- .mfrmr_dif_sim_get_function("fit_mfrm")
  controls <- .mfrmr_dif_sim_model_controls(model)
  args <- list(
    data = dat,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = controls$model,
    method = controls$fit_method,
    maxit = maxit
  )
  if (!is.null(controls$step_facet)) {
    args$step_facet <- controls$step_facet
  }
  if (!is.null(controls$slope_facet)) {
    args$slope_facet <- controls$slope_facet
  }
  if (identical(controls$fit_method, "MML")) {
    args$quad_points <- quad_points
  }
  suppressWarnings(do.call(fit_mfrm, args))
}

.mfrmr_dif_sim_fit_converged <- function(fit) {
  s <- as.data.frame(fit$summary %||% data.frame(), stringsAsFactors = FALSE)
  if ("Converged" %in% names(s)) {
    return(isTRUE(s$Converged[1]))
  }
  if ("Convergence" %in% names(s)) {
    return(identical(as.character(s$Convergence[1]), "converged"))
  }
  NA
}

.mfrmr_dif_sim_target_row <- function(tbl, scenario, target_level) {
  tbl <- as.data.frame(tbl, stringsAsFactors = FALSE)
  if (identical(scenario, "categorical_three_level")) {
    rows <- tbl[
      tbl$Level == target_level &
        ((tbl$Group1 == "FocalB" & tbl$Group2 == "Reference") |
           (tbl$Group1 == "Reference" & tbl$Group2 == "FocalB")),
      ,
      drop = FALSE
    ]
    if (nrow(rows) == 0L) {
      rows <- tbl[
        tbl$Level == target_level &
          (tbl$Group1 == "FocalB" | tbl$Group2 == "FocalB"),
        ,
        drop = FALSE
      ]
    }
  } else {
    rows <- tbl[tbl$Level == target_level, , drop = FALSE]
  }
  if (nrow(rows) == 0L) {
    return(rows)
  }
  rows[which.max(abs(rows$Contrast)), , drop = FALSE]
}

.mfrmr_dif_sim_case_summary <- function(result,
                                        model,
                                        scenario,
                                        rep,
                                        seed,
                                        target_level) {
  if (identical(scenario, "continuous_signal")) {
    tbl <- as.data.frame(result$moderation_table, stringsAsFactors = FALSE)
    target <- tbl[tbl$Level == target_level, , drop = FALSE]
    if (nrow(target) > 0L) {
      target <- target[which.max(abs(target$Slope)), , drop = FALSE]
    }
    target_effect <- if (nrow(target) > 0L) target$Slope[1] else NA_real_
    target_positive <- if (nrow(target) > 0L) {
      identical(target$Classification[1], "Screen positive")
    } else {
      FALSE
    }
    direction_ok <- is.finite(target_effect) && target_effect > 0
    non_target <- tbl[tbl$Level != target_level, , drop = FALSE]
    route <- "continuous_covariate_residual_moderation"
  } else {
    tbl <- as.data.frame(result$dif_table, stringsAsFactors = FALSE)
    target <- .mfrmr_dif_sim_target_row(tbl, scenario, target_level)
    target_effect <- if (nrow(target) > 0L) target$Contrast[1] else NA_real_
    target_positive <- if (nrow(target) > 0L) {
      identical(target$Classification[1], "Screen positive")
    } else {
      FALSE
    }
    direction_ok <- if (identical(scenario, "categorical_three_level")) {
      if (nrow(target) > 0L && target$Group1[1] == "FocalB") {
        is.finite(target_effect) && target_effect < 0
      } else {
        is.finite(target_effect) && target_effect > 0
      }
    } else if (identical(scenario, "categorical_null")) {
      NA
    } else {
      is.finite(target_effect) && target_effect > 0
    }
    if (identical(scenario, "categorical_three_level") && nrow(target) > 0L) {
      non_target <- tbl[
        !(tbl$Level == target_level &
            ((tbl$Group1 == target$Group1[1] & tbl$Group2 == target$Group2[1]) |
               (tbl$Group1 == target$Group2[1] & tbl$Group2 == target$Group1[1]))),
        ,
        drop = FALSE
      ]
    } else {
      non_target <- tbl[tbl$Level != target_level, , drop = FALSE]
    }
    route <- "categorical_residual_dff"
  }

  classification_systems <- unique(as.character(tbl$ClassificationSystem %||% NA_character_))
  reporting_use <- as.character(tbl$ReportingUse %||% NA_character_)
  primary <- tbl$PrimaryReportingEligible %||% rep(NA, nrow(tbl))
  screen_positive <- as.character(tbl$Classification %||% "") == "Screen positive"
  non_target_positive <- as.character(non_target$Classification %||% "") ==
    "Screen positive"
  gpcm_boundary <- as.data.frame(result$gpcm_boundary %||% data.frame(),
                                 stringsAsFactors = FALSE)
  data.frame(
    Model = model,
    Scenario = scenario,
    Rep = as.integer(rep),
    Seed = as.integer(seed),
    Route = route,
    Rows = nrow(tbl),
    TargetLevel = target_level,
    TargetEffect = as.numeric(target_effect),
    TargetScreenPositive = target_positive,
    DirectionOK = if (is.na(direction_ok)) NA else isTRUE(direction_ok),
    ScreenPositiveCount = sum(screen_positive, na.rm = TRUE),
    NonTargetScreenPositiveCount = sum(non_target_positive, na.rm = TRUE),
    ClassificationSystems = paste(stats::na.omit(classification_systems), collapse = ";"),
    ClassificationSystemOK = all(classification_systems == "screening", na.rm = TRUE),
    ReportingBoundaryOK =
      all(reporting_use == "screening_only", na.rm = TRUE) &&
        all(!isTRUE(primary), na.rm = TRUE),
    FitModel = as.character(result$config$fit_model %||% NA_character_)[1],
    ModelScope = as.character(result$config$model_scope %||% NA_character_)[1],
    GPCMCaveatPresent = if (identical(model, "GPCM")) {
      nrow(gpcm_boundary) > 0L &&
        any(gpcm_boundary$Status == "supported_with_caveat", na.rm = TRUE)
    } else {
      NA
    },
    stringsAsFactors = FALSE
  )
}

.mfrmr_dif_sim_boundary_checks <- function(result, model, scenario, rep,
                                           summary_row) {
  dif_report <- .mfrmr_dif_sim_get_function("dif_report")
  plot_dif_summary <- .mfrmr_dif_sim_get_function("plot_dif_summary")
  plot_dif_heatmap <- .mfrmr_dif_sim_get_function("plot_dif_heatmap")
  checks <- list(
    .mfrmr_dif_sim_check_row(
      model, scenario, rep,
      "classification_system_screening",
      isTRUE(summary_row$ClassificationSystemOK[1]),
      summary_row$ClassificationSystems[1]
    ),
    .mfrmr_dif_sim_check_row(
      model, scenario, rep,
      "reporting_boundary_screening_only",
      isTRUE(summary_row$ReportingBoundaryOK[1]),
      summary_row$ModelScope[1]
    ),
    .mfrmr_dif_sim_check_row(
      model, scenario, rep,
      "model_recorded",
      identical(summary_row$FitModel[1], model),
      paste0("fit_model=", summary_row$FitModel[1])
    )
  )
  if (identical(model, "GPCM")) {
    checks <- c(checks, list(.mfrmr_dif_sim_check_row(
      model, scenario, rep,
      "gpcm_caveat_present",
      isTRUE(summary_row$GPCMCaveatPresent[1]) &&
        grepl("bounded_gpcm", summary_row$ModelScope[1], fixed = TRUE),
      summary_row$ModelScope[1]
    )))
  }

  rpt <- tryCatch(dif_report(result, style = "apa"), error = function(e) e)
  if (inherits(rpt, "error")) {
    checks <- c(checks, list(.mfrmr_dif_sim_check_row(
      model, scenario, rep,
      "apa_report_builds",
      FALSE,
      conditionMessage(rpt)
    )))
  } else {
    note_text <- paste(
      as.character(rpt$narrative %||% ""),
      as.character(rpt$apa_note %||% ""),
      as.character(rpt$apa_caption %||% ""),
      collapse = " "
    )
    forbidden <- .mfrmr_dif_sim_forbidden_hits(note_text)
    checks <- c(checks, list(
      .mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "apa_report_builds",
        inherits(rpt, "mfrm_dif_report"),
        paste(class(rpt), collapse = "/")
      ),
      .mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "apa_report_keeps_screening_boundary",
        grepl("screening", note_text, ignore.case = TRUE) &&
          length(forbidden) == 0L,
        if (length(forbidden) == 0L) "no forbidden wording" else
          paste(forbidden, collapse = "; ")
      )
    ))
  }

  if (!identical(scenario, "continuous_signal")) {
    plot_sum <- tryCatch(plot_dif_summary(result, draw = FALSE),
                         error = function(e) e)
    if (inherits(plot_sum, "error")) {
      checks <- c(checks, list(.mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "summary_plot_payload",
        FALSE,
        conditionMessage(plot_sum)
      )))
    } else {
      pdata <- as.data.frame(plot_sum$data$data %||% data.frame(),
                             stringsAsFactors = FALSE)
      checks <- c(checks, list(.mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "summary_plot_no_ets_display",
        "ETSDisplayEligible" %in% names(pdata) &&
          !any(pdata$ETSDisplayEligible, na.rm = TRUE),
        paste(unique(as.character(pdata$ClassificationSystem %||% NA_character_)),
              collapse = ";")
      )))
    }
    heat <- tryCatch(plot_dif_heatmap(result, metric = "contrast", draw = FALSE),
                     error = function(e) e)
    if (inherits(heat, "error")) {
      checks <- c(checks, list(.mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "heatmap_payload",
        FALSE,
        conditionMessage(heat)
      )))
    } else {
      checks <- c(checks, list(.mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "heatmap_no_ets_display",
        !isTRUE(heat$data$ets_display_eligible) &&
          identical(heat$data$classification_system, "screening"),
        paste0("classification_system=", heat$data$classification_system)
      )))
    }
  }
  do.call(rbind, checks)
}

.mfrmr_dif_sim_run_case <- function(model,
                                    scenario,
                                    rep,
                                    seed_base = 0L,
                                    n_person = 80L,
                                    target_level = "C02",
                                    maxit = 30L,
                                    quad_points = 7L) {
  diagnose_mfrm <- .mfrmr_dif_sim_get_function("diagnose_mfrm")
  analyze_dff <- .mfrmr_dif_sim_get_function("analyze_dff")
  analyze_dff_moderation <- .mfrmr_dif_sim_get_function("analyze_dff_moderation")
  seed <- .mfrmr_dif_sim_seed(model, scenario, rep, seed_base)
  out <- tryCatch({
    dat <- .mfrmr_dif_sim_generate(
      model = model,
      scenario = scenario,
      seed = seed,
      n_person = n_person,
      target_level = target_level
    )
    fit <- .mfrmr_dif_sim_fit(
      dat,
      model = model,
      maxit = maxit,
      quad_points = quad_points
    )
    if (identical(scenario, "continuous_signal")) {
      result <- analyze_dff_moderation(
        fit,
        facet = "Criterion",
        covariate = "AgeLike",
        data = dat,
        min_obs = 3L
      )
    } else {
      diag <- diagnose_mfrm(fit, residual_pca = "none")
      result <- analyze_dff(
        fit,
        diag,
        facet = "Criterion",
        group = "Group",
        data = dat,
        method = "residual",
        focal = if (identical(scenario, "categorical_three_level")) NULL else "Focal",
        min_obs = 3L
      )
    }
    summary_row <- .mfrmr_dif_sim_case_summary(
      result = result,
      model = model,
      scenario = scenario,
      rep = rep,
      seed = seed,
      target_level = target_level
    )
    summary_row$FitCompleted <- TRUE
    summary_row$FitConverged <- .mfrmr_dif_sim_fit_converged(fit)
    checks <- .mfrmr_dif_sim_boundary_checks(
      result = result,
      model = model,
      scenario = scenario,
      rep = rep,
      summary_row = summary_row
    )
    checks <- rbind(
      .mfrmr_dif_sim_check_row(
        model, scenario, rep,
        "fit_completed",
        TRUE,
        paste0("seed=", seed)
      ),
      checks
    )
    if (identical(scenario, "categorical_signal")) {
      checks <- rbind(
        checks,
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "target_direction_positive",
          isTRUE(summary_row$DirectionOK[1]),
          paste0("target_effect=", signif(summary_row$TargetEffect[1], 4))
        ),
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "target_screen_positive",
          isTRUE(summary_row$TargetScreenPositive[1]),
          paste0("screen_positive_count=", summary_row$ScreenPositiveCount[1])
        )
      )
    } else if (identical(scenario, "categorical_three_level")) {
      checks <- rbind(
        checks,
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "three_group_pairs_expanded",
          isTRUE(summary_row$Rows[1] == 9L),
          paste0("rows=", summary_row$Rows[1])
        ),
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "target_three_group_direction",
          isTRUE(summary_row$DirectionOK[1]),
          paste0("target_effect=", signif(summary_row$TargetEffect[1], 4))
        ),
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "target_three_group_screen_positive",
          isTRUE(summary_row$TargetScreenPositive[1]),
          paste0("screen_positive_count=", summary_row$ScreenPositiveCount[1])
        )
      )
    } else if (identical(scenario, "categorical_null")) {
      checks <- rbind(
        checks,
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "null_positive_count_recorded",
          is.finite(summary_row$ScreenPositiveCount[1]) &&
            summary_row$ScreenPositiveCount[1] <= 1L,
          paste0("screen_positive_count=", summary_row$ScreenPositiveCount[1])
        )
      )
    } else if (identical(scenario, "continuous_signal")) {
      checks <- rbind(
        checks,
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "target_slope_positive",
          isTRUE(summary_row$DirectionOK[1]),
          paste0("target_slope=", signif(summary_row$TargetEffect[1], 4))
        ),
        .mfrmr_dif_sim_check_row(
          model, scenario, rep,
          "target_moderation_screen_positive",
          isTRUE(summary_row$TargetScreenPositive[1]),
          paste0("screen_positive_count=", summary_row$ScreenPositiveCount[1])
        )
      )
    }
    list(case = summary_row, checks = checks)
  }, error = function(e) {
    case <- data.frame(
      Model = model,
      Scenario = scenario,
      Rep = as.integer(rep),
      Seed = as.integer(seed),
      Route = NA_character_,
      Rows = NA_integer_,
      TargetLevel = target_level,
      TargetEffect = NA_real_,
      TargetScreenPositive = FALSE,
      DirectionOK = FALSE,
      ScreenPositiveCount = NA_integer_,
      NonTargetScreenPositiveCount = NA_integer_,
      ClassificationSystems = NA_character_,
      ClassificationSystemOK = FALSE,
      ReportingBoundaryOK = FALSE,
      FitModel = NA_character_,
      ModelScope = NA_character_,
      GPCMCaveatPresent = if (identical(model, "GPCM")) FALSE else NA,
      FitCompleted = FALSE,
      FitConverged = FALSE,
      stringsAsFactors = FALSE
    )
    checks <- .mfrmr_dif_sim_check_row(
      model, scenario, rep,
      "fit_completed",
      FALSE,
      conditionMessage(e)
    )
    list(case = case, checks = checks)
  })
  out
}

.mfrmr_dif_sim_aggregate <- function(case_table) {
  if (nrow(case_table) == 0L) {
    return(data.frame())
  }
  split_rows <- split(case_table, paste(case_table$Model, case_table$Scenario,
                                        sep = "::"))
  out <- lapply(split_rows, function(x) {
    data.frame(
      Model = x$Model[1],
      Scenario = x$Scenario[1],
      Replications = nrow(x),
      FitCompletedRate = mean(x$FitCompleted, na.rm = TRUE),
      TargetScreenPositiveRate = mean(x$TargetScreenPositive, na.rm = TRUE),
      DirectionOKRate = if (all(is.na(x$DirectionOK))) {
        NA_real_
      } else {
        mean(x$DirectionOK, na.rm = TRUE)
      },
      MeanTargetEffect = mean(x$TargetEffect, na.rm = TRUE),
      MeanScreenPositiveCount = mean(x$ScreenPositiveCount, na.rm = TRUE),
      MeanNonTargetScreenPositiveCount =
        mean(x$NonTargetScreenPositiveCount, na.rm = TRUE),
      BoundaryOKRate =
        mean(x$ClassificationSystemOK & x$ReportingBoundaryOK, na.rm = TRUE),
      ModelScope = paste(unique(as.character(x$ModelScope)), collapse = ";"),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, out)
}

mfrmr_dif_dff_simulation_matrix_expected_cases <- function() {
  expand.grid(
    Model = c("RSM", "PCM", "GPCM"),
    Scenario = c(
      "categorical_signal",
      "categorical_null",
      "categorical_three_level",
      "continuous_signal"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_review_dif_dff_simulation_matrix <- function(
    reps = 1L,
    models = c("RSM", "PCM", "GPCM"),
    scenarios = c(
      "categorical_signal",
      "categorical_null",
      "categorical_three_level",
      "continuous_signal"
    ),
    seed_base = 0L,
    n_person = 80L,
    maxit = 30L,
    quad_points = 7L) {
  reps <- as.integer(reps[1])
  if (!is.finite(reps) || reps < 1L) {
    stop("`reps` must be a positive integer.", call. = FALSE)
  }
  models <- toupper(as.character(models))
  scenarios <- as.character(scenarios)
  expected <- mfrmr_dif_dff_simulation_matrix_expected_cases()
  expected_key <- paste(expected$Model, expected$Scenario, sep = "::")
  requested <- expand.grid(Model = models, Scenario = scenarios,
                           stringsAsFactors = FALSE)
  requested_key <- paste(requested$Model, requested$Scenario, sep = "::")
  bad <- setdiff(requested_key, expected_key)
  if (length(bad) > 0L) {
    stop("Unsupported simulation matrix case(s): ",
         paste(bad, collapse = ", "), call. = FALSE)
  }

  runs <- list()
  idx <- 1L
  for (model in models) {
    for (scenario in scenarios) {
      for (rep in seq_len(reps)) {
        runs[[idx]] <- .mfrmr_dif_sim_run_case(
          model = model,
          scenario = scenario,
          rep = rep,
          seed_base = seed_base,
          n_person = n_person,
          maxit = maxit,
          quad_points = quad_points
        )
        idx <- idx + 1L
      }
    }
  }
  case_table <- do.call(rbind, lapply(runs, `[[`, "case"))
  checks <- do.call(rbind, lapply(runs, `[[`, "checks"))
  summary_table <- .mfrmr_dif_sim_aggregate(case_table)
  failed <- if (nrow(checks) > 0L) sum(!checks$Passed, na.rm = TRUE) else NA_integer_
  status <- if (identical(failed, 0L)) "ok" else "review"
  out <- list(
    status = status,
    reps = reps,
    models = models,
    scenarios = scenarios,
    case_table = case_table,
    summary_table = summary_table,
    checks = checks,
    failed_checks = failed,
    interpretation = paste(
      "Seeded smoke matrix for DFF/DIF helper behavior across RSM, PCM,",
      "and bounded GPCM. Results support route-boundary and target-direction",
      "checks only; they are not calibrated power, Type-I-error, fairness,",
      "invariance, or operational subgroup-decision evidence."
    )
  )
  class(out) <- "mfrmr_dif_dff_simulation_matrix_review"
  out
}

mfrmr_write_dif_dff_simulation_matrix_evidence <- function(review,
                                                           out_dir) {
  if (!inherits(review, "mfrmr_dif_dff_simulation_matrix_review")) {
    stop("`review` must be output from mfrmr_review_dif_dff_simulation_matrix().",
         call. = FALSE)
  }
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  result_path <- file.path(out_dir, "dif-dff-simulation-matrix-0.2.2-results.csv")
  summary_path <- file.path(out_dir, "dif-dff-simulation-matrix-0.2.2-summary.csv")
  checks_path <- file.path(out_dir, "dif-dff-simulation-matrix-0.2.2-checks.csv")
  md_path <- file.path(out_dir, "dif-dff-simulation-matrix-0.2.2.md")
  utils::write.csv(review$case_table, result_path, row.names = FALSE)
  utils::write.csv(review$summary_table, summary_path, row.names = FALSE)
  utils::write.csv(review$checks, checks_path, row.names = FALSE)

  lines <- c(
    "# DIF/DFF simulation matrix evidence (0.2.2)",
    "",
    "This is a seeded smoke validation summary for the 0.2.2 DIF/DFF program.",
    "It is not a calibrated operating-characteristic study. Increase `reps`",
    "and retain the CSV outputs before using the results as power or false-",
    "positive-rate evidence.",
    "",
    sprintf("- `DIFDFFSimulationStatus = \"%s\"`;", review$status),
    sprintf("- `Replications = %d` per requested model/scenario;", review$reps),
    sprintf("- `Models = %s`;", paste(review$models, collapse = ", ")),
    sprintf("- `Scenarios = %s`;", paste(review$scenarios, collapse = ", ")),
    sprintf("- `Cases = %d`;", nrow(review$case_table)),
    sprintf("- `Checks = %d`;", nrow(review$checks)),
    sprintf("- `FailedChecks = %d`.", review$failed_checks),
    "",
    "## Interpretation boundary",
    "",
    review$interpretation,
    "",
    "## Summary",
    "",
    paste(
      utils::capture.output(print(review$summary_table, row.names = FALSE)),
      collapse = "\n"
    ),
    "",
    "## Generated output files",
    "",
    "The helper writes the following CSVs when regenerating this evidence.",
    "They are generated outputs, not bundled sibling release-evidence files,",
    "unless an explicit future release review decides to preserve them.",
    "",
    sprintf("- `%s`", basename(result_path)),
    sprintf("- `%s`", basename(summary_path)),
    sprintf("- `%s`", basename(checks_path))
  )
  writeLines(lines, md_path)
  invisible(list(
    results = result_path,
    summary = summary_path,
    checks = checks_path,
    markdown = md_path
  ))
}

print.mfrmr_dif_dff_simulation_matrix_review <- function(x, ...) {
  cat("mfrmr DIF/DFF simulation matrix review\n")
  cat("Status:", x$status, "\n")
  cat("Cases:", nrow(x$case_table), " Checks:", nrow(x$checks),
      " Failed:", x$failed_checks, "\n\n")
  print(x$summary_table, row.names = FALSE)
  invisible(x)
}

if (identical(sys.nframe(), 0L)) {
  if (!exists("fit_mfrm", mode = "function", inherits = TRUE) &&
      requireNamespace("pkgload", quietly = TRUE) &&
      file.exists("DESCRIPTION")) {
    suppressMessages(pkgload::load_all(".", quiet = TRUE))
  }
  args <- commandArgs(trailingOnly = TRUE)
  reps <- if (length(args) >= 1L && nzchar(args[1])) as.integer(args[1]) else 1L
  out_dir <- if (length(args) >= 2L && nzchar(args[2])) {
    args[2]
  } else {
    file.path("validation-results", "dif-dff-simulation-matrix-0.2.2")
  }
  review <- mfrmr_review_dif_dff_simulation_matrix(reps = reps)
  print(review)
  paths <- mfrmr_write_dif_dff_simulation_matrix_evidence(review, out_dir)
  cat("\nWrote:\n")
  print(unlist(paths), quote = FALSE)
  if (!identical(review$status, "ok")) {
    quit(status = 1L)
  }
}
