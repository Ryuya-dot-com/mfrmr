# First-use workflow stress validation for mfrmr
#
# This repository-level protocol exercises the public data -> description ->
# fit -> summary -> plot workflow under deterministic conditions that a new
# first-time user might encounter. It is intentionally excluded from routine
# CRAN checks; a small canonical subset is covered by testthat.

mfrmr_first_use_or <- function(x, fallback) {
  if (is.null(x)) fallback else x
}

mfrmr_first_use_stress_plan <- function() {
  data.frame(
    Scenario = c(
      "balanced_rsm",
      "sparse_linked_rsm",
      "disconnected_rsm",
      "shared_criterion_link",
      "pcm_varying_steps",
      "gpcm_varying_slopes",
      "skewed_extreme_scores",
      "separated_raters",
      "sentinel_score_codes",
      "weighted_rows"
    ),
    Tier = c(
      "quick", "core", "quick", "core", "core",
      "core", "core", "core", "quick", "core"
    ),
    Aim = c(
      "Reproduce the recommended first MML/RSM workflow on a linked design.",
      "Check an incomplete but deliberately linked rater assignment.",
      "Confirm that two design components remain a reporting hold even if optimization succeeds.",
      "Confirm that a shared criterion links otherwise separate rater groups on the overall graph.",
      "Exercise criterion-specific thresholds under PCM.",
      "Exercise bounded positive discriminations under GPCM.",
      "Separate difficult numerical conditions from software failure.",
      "Keep boundary-separated rater estimates on a stability reporting hold.",
      "Verify that declared score sentinels are removed without changing identifiers.",
      "Verify row-retention and weighted-likelihood provenance."
    ),
    Model = c(
      "RSM", "RSM", "RSM", "RSM", "PCM",
      "GPCM", "RSM", "RSM", "RSM", "RSM"
    ),
    Method = rep("MML", 10L),
    NumericalExpectation = c(
      "ready", "review_permitted", "review_permitted", "ready",
      "ready", "ready", "review_permitted", "review_permitted",
      "ready", "ready"
    ),
    DesignExpectation = c(
      "linked", "linked", "disconnected", "linked", "linked",
      "linked", "linked", "linked", "linked", "linked"
    ),
    DataExpectation = c(
      "pass", "pass", "pass", "pass", "pass",
      "pass", "pass", "pass", "review", "review"
    ),
    StabilityExpectation = c(
      "pass", "pass", "pass", "pass", "pass",
      "pass", "pass", "hold_boundary_separation", "pass", "pass"
    ),
    ReportingExpectation = c(
      "no_upstream_hold", "no_upstream_hold", "hold_design",
      "no_upstream_hold", "no_upstream_hold", "no_upstream_hold",
      "no_upstream_hold", "hold_stability", "review_data", "review_data"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_first_use_api <- function(name) {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("The `mfrmr` package must be available before running validation.",
         call. = FALSE)
  }
  getExportedValue("mfrmr", name)
}

mfrmr_first_use_capture <- function(expr) {
  warnings <- character(0)
  messages <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      },
      message = function(m) {
        messages <<- c(messages, conditionMessage(m))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(e) e
  )
  list(
    value = value,
    error = if (inherits(value, "error")) conditionMessage(value) else "",
    warnings = warnings,
    unique_warnings = unique(warnings),
    messages = messages,
    unique_messages = unique(messages)
  )
}

mfrmr_first_use_make_scenario <- function(scenario, seed) {
  simulate <- mfrmr_first_use_api("simulate_mfrm_data")
  build_spec <- mfrmr_first_use_api("build_mfrm_sim_spec")
  common_fit <- list(
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    method = "MML",
    model = "RSM"
  )

  if (identical(scenario, "balanced_rsm")) {
    data <- simulate(
      n_person = 48, n_rater = 6, n_criterion = 3,
      raters_per_person = 3, assignment = "rotating", seed = seed
    )
  } else if (identical(scenario, "sparse_linked_rsm")) {
    spec <- build_spec(
      n_person = 48, n_rater = 8, n_criterion = 3,
      raters_per_person = 1, assignment = "sparse_linked",
      sparse_controls = list(
        link_persons = 6,
        link_raters_per_person = 8,
        assignment_mode = "balanced",
        min_common_persons_per_rater_pair = 2
      )
    )
    data <- simulate(sim_spec = spec, seed = seed)
  } else if (identical(scenario, "disconnected_rsm")) {
    full <- simulate(
      n_person = 24, n_rater = 4, n_criterion = 4,
      raters_per_person = 4, assignment = "crossed", seed = seed
    )
    person_index <- suppressWarnings(as.integer(sub("^P", "", full$Person)))
    component_a <- person_index <= 12L &
      full$Rater %in% c("R01", "R02") &
      full$Criterion %in% c("C01", "C02")
    component_b <- person_index > 12L &
      full$Rater %in% c("R03", "R04") &
      full$Criterion %in% c("C03", "C04")
    data <- full[component_a | component_b, , drop = FALSE]
  } else if (identical(scenario, "shared_criterion_link")) {
    full <- simulate(
      n_person = 24, n_rater = 4, n_criterion = 3,
      raters_per_person = 4, assignment = "crossed", seed = seed
    )
    person_index <- suppressWarnings(as.integer(sub("^P", "", full$Person)))
    # Person-rater links form two groups, but the same Criterion levels occur
    # in both groups. The complete Person x Rater x Criterion graph is linked.
    data <- full[
      (person_index <= 12L & full$Rater %in% c("R01", "R02")) |
        (person_index > 12L & full$Rater %in% c("R03", "R04")),
      ,
      drop = FALSE
    ]
  } else if (identical(scenario, "pcm_varying_steps")) {
    data <- simulate(
      n_person = 60, n_rater = 4, n_criterion = 4,
      raters_per_person = 2, assignment = "rotating",
      model = "PCM", step_facet = "Criterion", seed = seed
    )
    common_fit$model <- "PCM"
    common_fit$step_facet <- "Criterion"
  } else if (identical(scenario, "gpcm_varying_slopes")) {
    data <- simulate(
      n_person = 60, n_rater = 4, n_criterion = 4,
      raters_per_person = 2, assignment = "rotating",
      model = "GPCM", step_facet = "Criterion",
      slope_facet = "Criterion", slopes = c(0.70, 0.90, 1.15, 1.45),
      seed = seed
    )
    common_fit$model <- "GPCM"
    common_fit$step_facet <- "Criterion"
    common_fit$slope_facet <- "Criterion"
  } else if (identical(scenario, "skewed_extreme_scores")) {
    data <- simulate(
      n_person = 40, n_rater = 4, n_criterion = 3,
      raters_per_person = 2, assignment = "rotating",
      theta_sd = 2.4, rater_sd = 0.8, criterion_sd = 0.6,
      step_span = 2.8, seed = seed
    )
  } else if (identical(scenario, "separated_raters")) {
    data <- simulate(
      n_person = 24, n_rater = 4, n_criterion = 3,
      raters_per_person = 4, assignment = "crossed", seed = seed
    )
    data$Score[data$Rater == "R01"] <- 1L
    data$Score[data$Rater == "R02"] <- 4L
  } else if (identical(scenario, "sentinel_score_codes")) {
    data <- simulate(
      n_person = 48, n_rater = 4, n_criterion = 3,
      raters_per_person = 2, assignment = "rotating", seed = seed
    )
    data$Score <- as.character(data$Score)
    data$Score[seq.int(7L, nrow(data), by = 29L)] <- "99"
    # A legitimate short identifier verifies the score-only default policy.
    data$Person[data$Person == unique(data$Person)[1L]] <- "N"
    common_fit$missing_codes <- TRUE
  } else if (identical(scenario, "weighted_rows")) {
    data <- simulate(
      n_person = 48, n_rater = 4, n_criterion = 3,
      raters_per_person = 2, assignment = "rotating", seed = seed
    )
    data$Weight <- rep(c(1, 0.5, 2, 1, 0), length.out = nrow(data))
    common_fit$weight <- "Weight"
  } else {
    stop("Unknown first-use stress scenario: ", scenario, call. = FALSE)
  }

  list(data = data, fit_args = common_fit)
}

mfrmr_first_use_status_value <- function(summary_object, item) {
  status <- as.data.frame(summary_object$status, stringsAsFactors = FALSE)
  if (nrow(status) == 0L || !all(c("Item", "Value") %in% names(status))) {
    return(NA_character_)
  }
  value <- status$Value[match(item, status$Item)]
  if (length(value) == 0L) NA_character_ else as.character(value[1L])
}

mfrmr_first_use_plot_status <- function(plot_object) {
  if (is.null(plot_object)) return(NA_character_)
  candidate <- NULL
  if (is.list(plot_object$data)) {
    candidate <- plot_object$data$interpretation_status
  }
  if (is.null(candidate)) candidate <- plot_object$interpretation_status
  if (is.null(candidate) || length(candidate) == 0L) return(NA_character_)
  as.character(candidate)[1L]
}

mfrmr_first_use_summary_domain <- function(summary_object, domain,
                                           default = "not_assessed") {
  readiness <- as.data.frame(
    mfrmr_first_use_or(summary_object$readiness, data.frame()),
    stringsAsFactors = FALSE
  )
  if (nrow(readiness) == 0L ||
      !all(c("Domain", "Status") %in% names(readiness))) {
    return(default)
  }
  value <- readiness$Status[match(domain, readiness$Domain)]
  if (length(value) == 0L || is.na(value[1L]) || !nzchar(value[1L])) {
    default
  } else {
    as.character(value[1L])
  }
}

mfrmr_run_first_use_stress <- function(tier = c("quick", "core"),
                                     seeds = NULL,
                                     scenarios = NULL,
                                     reltol = NULL,
                                     include_diagnostics = TRUE,
                                     output_dir = NULL) {
  tier <- match.arg(tier)
  plan <- mfrmr_first_use_stress_plan()
  if (is.null(scenarios)) {
    scenarios <- if (identical(tier, "quick")) {
      plan$Scenario[plan$Tier == "quick"]
    } else {
      plan$Scenario
    }
  }
  unknown <- setdiff(scenarios, plan$Scenario)
  if (length(unknown) > 0L) {
    stop("Unknown scenario(s): ", paste(unknown, collapse = ", "), call. = FALSE)
  }
  if (is.null(seeds)) {
    seeds <- if (identical(tier, "quick")) 20260724L else 20260724:20260726
  }
  seeds <- as.integer(seeds)

  describe <- mfrmr_first_use_api("describe_mfrm_data")
  fit_fun <- mfrmr_first_use_api("fit_mfrm")
  diagnose <- mfrmr_first_use_api("diagnose_mfrm")
  rows <- list()
  row_index <- 0L

  for (scenario in scenarios) {
    expectation <- plan[plan$Scenario == scenario, , drop = FALSE]
    for (seed in seeds) {
      row_index <- row_index + 1L
      setup <- mfrmr_first_use_make_scenario(scenario, seed)
      data <- setup$data
      fit_args <- c(list(data = data), setup$fit_args)
      if (!is.null(reltol)) fit_args$reltol <- as.numeric(reltol)

      describe_args <- fit_args[intersect(
        names(fit_args),
        c("data", "person", "facets", "score", "weight", "rating_min",
          "rating_max", "keep_original", "missing_codes")
      )]
      describe_args$include_agreement <- FALSE
      described <- mfrmr_first_use_capture(do.call(describe, describe_args))
      description_ok <- !inherits(described$value, "error")
      disconnected_facets <- NA_integer_
      if (description_ok) {
        connectivity <- as.data.frame(
          described$value$design_connectivity,
          stringsAsFactors = FALSE
        )
        disconnected_facets <- if (nrow(connectivity) > 0L) {
          sum(!as.logical(connectivity$Connected), na.rm = TRUE)
        } else {
          0L
        }
      }

      elapsed <- system.time(
        fitted <- mfrmr_first_use_capture(do.call(fit_fun, fit_args))
      )[["elapsed"]]
      fit_ok <- !inherits(fitted$value, "error")
      fit <- if (fit_ok) fitted$value else NULL
      overview <- if (fit_ok) as.data.frame(fit$summary, stringsAsFactors = FALSE) else data.frame()

      diagnostics <- NULL
      diagnostic_capture <- list(error = "", warnings = character(0))
      if (fit_ok && isTRUE(include_diagnostics)) {
        diagnostic_capture <- mfrmr_first_use_capture(
          diagnose(
            fit,
            residual_pca = "none",
            diagnostic_mode = "both",
            fit_df_method = "both"
          )
        )
        if (!inherits(diagnostic_capture$value, "error")) {
          diagnostics <- diagnostic_capture$value
        }
      }

      summary_capture <- if (fit_ok) {
        mfrmr_first_use_capture(summary(
          fit,
          profile = "facets",
          detail = "brief",
          diagnostics = diagnostics,
          compute = if (is.null(diagnostics)) "auto" else "never"
        ))
      } else {
        list(value = NULL, error = "fit unavailable", warnings = character(0))
      }
      summary_ok <- fit_ok && !inherits(summary_capture$value, "error")

      wright_capture <- if (fit_ok) {
        mfrmr_first_use_capture(plot(
          fit, type = "wright", renderer = "native",
          show_ci = TRUE, top_n = Inf, draw = FALSE
        ))
      } else {
        list(value = NULL, error = "fit unavailable", warnings = character(0))
      }
      wright_ok <- fit_ok && !inherits(wright_capture$value, "error")

      facets_wright_capture <- if (fit_ok) {
        mfrmr_first_use_capture(plot(
          fit, type = "wright", renderer = "facets",
          show_ci = TRUE, top_n = Inf, draw = FALSE
        ))
      } else {
        list(value = NULL, error = "fit unavailable", warnings = character(0))
      }
      facets_wright_ok <- fit_ok &&
        !inherits(facets_wright_capture$value, "error")

      fit_pathway_capture <- if (fit_ok) {
        mfrmr_first_use_capture(plot(
          fit,
          type = "fit_pathway",
          diagnostics = diagnostics,
          fit_stat = "Infit",
          include_person = TRUE,
          top_n_person = 12L,
          draw = FALSE
        ))
      } else {
        list(value = NULL, error = "fit unavailable", warnings = character(0))
      }
      fit_pathway_ok <- fit_ok &&
        !inherits(fit_pathway_capture$value, "error")

      fit_review_status <- if (fit_ok) {
        as.data.frame(fit$data_review$status, stringsAsFactors = FALSE)
      } else {
        data.frame()
      }
      fit_domain_status <- function(domain, default = "not_assessed") {
        if (nrow(fit_review_status) == 0L ||
            !all(c("Domain", "Status") %in% names(fit_review_status))) {
          return(default)
        }
        value <- fit_review_status$Status[
          match(domain, fit_review_status$Domain)
        ]
        if (length(value) == 0L || is.na(value[1L])) {
          default
        } else {
          as.character(value[1L])
        }
      }
      actual_data_status <- fit_domain_status("Data")
      actual_design_domain <- fit_domain_status("Design")
      actual_stability_status <- fit_domain_status("Stability")

      subset_count <- if (fit_ok) {
        as.integer(fit$data_review$overall_connectivity$components)
      } else {
        NA_integer_
      }
      if (!is.finite(subset_count) &&
          !is.null(diagnostics) && !is.null(diagnostics$subsets$summary)) {
        subset_count <- nrow(as.data.frame(diagnostics$subsets$summary))
      }
      actual_design <- if (is.finite(subset_count)) {
        if (subset_count > 1L) "disconnected" else "linked"
      } else if (is.finite(disconnected_facets)) {
        if (disconnected_facets > 0L) "disconnected" else "linked"
      } else {
        "unknown"
      }

      numerical_ready <- if (nrow(overview) > 0L) {
        isTRUE(overview$InferenceReady[1L])
      } else {
        FALSE
      }
      convergence_status <- if (nrow(overview) > 0L) {
        as.character(overview$ConvergenceStatus[1L])
      } else {
        "unknown"
      }
      convergence_severity <- if (nrow(overview) > 0L) {
        tolower(as.character(overview$ConvergenceSeverity[1L]))
      } else {
        "error"
      }
      numerical_expected <- identical(expectation$NumericalExpectation, "ready")
      numerical_state_consistent <-
        (identical(convergence_severity, "pass") && numerical_ready) ||
        (identical(convergence_severity, "review") && !numerical_ready)
      numerical_contract <- if (numerical_expected) {
        fit_ok && numerical_ready && identical(convergence_severity, "pass")
      } else {
        fit_ok && numerical_state_consistent &&
          convergence_severity %in% c("pass", "review")
      }
      design_contract <- identical(actual_design, expectation$DesignExpectation)
      data_contract <- identical(actual_data_status, expectation$DataExpectation)
      stability_contract <- identical(
        actual_stability_status,
        expectation$StabilityExpectation
      )
      reporting_status <- if (summary_ok) {
        mfrmr_first_use_status_value(summary_capture$value, "Reporting readiness")
      } else {
        NA_character_
      }
      reporting_expectation <- as.character(expectation$ReportingExpectation)
      reporting_contract <- if (!summary_ok || is.na(reporting_status)) {
        FALSE
      } else if (identical(reporting_expectation, "hold_design")) {
        startsWith(reporting_status, "hold_for_design")
      } else if (identical(reporting_expectation, "hold_stability")) {
        startsWith(reporting_status, "hold_for_stability")
      } else if (identical(reporting_expectation, "review_data")) {
        identical(reporting_status, "review_data_before_reporting")
      } else {
        reporting_status %in% c(
          "ready_for_diagnostics_and_reporting_follow_up",
          "review_diagnostics_before_reporting"
        )
      }
      plot_status <- if (wright_ok) {
        mfrmr_first_use_plot_status(wright_capture$value)
      } else {
        NA_character_
      }
      facets_plot_status <- if (facets_wright_ok) {
        mfrmr_first_use_plot_status(facets_wright_capture$value)
      } else {
        NA_character_
      }
      pathway_plot_status <- if (fit_pathway_ok) {
        mfrmr_first_use_plot_status(fit_pathway_capture$value)
      } else {
        NA_character_
      }
      expected_plot_review <- !numerical_ready ||
        !identical(actual_data_status, "pass") ||
        !identical(actual_design_domain, "pass_linked") ||
        !identical(actual_stability_status, "pass")
      plot_contract <- if (!wright_ok || is.na(plot_status)) {
        FALSE
      } else if (expected_plot_review) {
        identical(plot_status, "review_only")
      } else {
        identical(plot_status, "ready_for_diagnostic_interpretation")
      }

      expected_plot_status <- if (expected_plot_review) {
        "review_only"
      } else {
        "ready_for_diagnostic_interpretation"
      }
      plot_readiness_contract <- all(
        !is.na(c(plot_status, facets_plot_status, pathway_plot_status)),
        c(plot_status, facets_plot_status, pathway_plot_status) ==
          expected_plot_status
      )

      summary_domains <- if (summary_ok) {
        as.data.frame(
          mfrmr_first_use_or(summary_capture$value$readiness, data.frame()),
          stringsAsFactors = FALSE
        )
      } else {
        data.frame()
      }
      expected_summary_domains <- c(
        "Numerical", "Data", "Design", "Stability", "Diagnostics", "Reporting"
      )
      summary_domains_contract <- summary_ok &&
        all(c("Domain", "Status") %in% names(summary_domains)) &&
        setequal(as.character(summary_domains$Domain), expected_summary_domains) &&
        !anyDuplicated(as.character(summary_domains$Domain)) &&
        identical(
          mfrmr_first_use_summary_domain(summary_capture$value, "Numerical"),
          convergence_severity
        ) &&
        identical(
          mfrmr_first_use_summary_domain(summary_capture$value, "Data"),
          actual_data_status
        ) &&
        identical(
          mfrmr_first_use_summary_domain(summary_capture$value, "Design"),
          actual_design_domain
        ) &&
        identical(
          mfrmr_first_use_summary_domain(summary_capture$value, "Stability"),
          actual_stability_status
        )

      native_surface_contract <- wright_ok &&
        identical(wright_capture$value$data$uncertainty_display, "native_mfrmr_ci") &&
        is.data.frame(wright_capture$value$data$locations) &&
        nrow(wright_capture$value$data$locations) > 0L

      facets_surface <- if (facets_wright_ok) {
        facets_wright_capture$value$data$facets_style
      } else {
        NULL
      }
      facets_surface_contract <- facets_wright_ok &&
        identical(
          facets_wright_capture$value$data$uncertainty_display,
          "hybrid_mfrmr_ci"
        ) &&
        is.list(facets_surface) &&
        all(c(
          "person_frequency", "facet_ruler", "step_ruler",
          "score_transitions", "settings"
        ) %in% names(facets_surface)) &&
        nrow(facets_surface$person_frequency) > 0L &&
        nrow(facets_surface$facet_ruler) > 0L &&
        nrow(facets_surface$step_ruler) > 0L

      pathway_table <- if (fit_pathway_ok) {
        as.data.frame(
          mfrmr_first_use_or(
            fit_pathway_capture$value$data$table,
            data.frame()
          ),
          stringsAsFactors = FALSE
        )
      } else {
        data.frame()
      }
      person_pathway_rows <- if ("Facet" %in% names(pathway_table)) {
        sum(as.character(pathway_table$Facet) == "Person")
      } else {
        0L
      }
      pathway_surface_contract <- fit_pathway_ok &&
        identical(fit_pathway_capture$value$data$fit_column, "Infit") &&
        nrow(pathway_table) > 0L &&
        person_pathway_rows >= 1L && person_pathway_rows <= 12L &&
        any(as.character(pathway_table$Facet) != "Person")

      surface_checks <- c(
        Numerical = numerical_contract,
        SummaryDomains = summary_domains_contract,
        Data = data_contract,
        Design = design_contract,
        Stability = stability_contract,
        Reporting = reporting_contract,
        NativeWright = native_surface_contract,
        FacetsWright = facets_surface_contract,
        InfitPathway = pathway_surface_contract,
        PlotReadiness = plot_readiness_contract
      )

      row <- data.frame(
        Scenario = scenario,
        Seed = seed,
        Rows = nrow(data),
        Persons = length(unique(as.character(data$Person))),
        Model = expectation$Model,
        Method = expectation$Method,
        DescriptionOK = description_ok,
        FitOK = fit_ok,
        SummaryOK = summary_ok,
        WrightOK = wright_ok,
        FacetsWrightOK = facets_wright_ok,
        FitPathwayOK = fit_pathway_ok,
        Converged = if (nrow(overview) > 0L) isTRUE(overview$Converged[1L]) else FALSE,
        InferenceReady = numerical_ready,
        ConvergenceStatus = convergence_status,
        ConvergenceSeverity = convergence_severity,
        TerminalGradientSupNorm = if (nrow(overview) > 0L) {
          as.numeric(overview$TerminalGradientSupNorm[1L])
        } else {
          NA_real_
        },
        EffectiveReltol = if (nrow(overview) > 0L) {
          as.numeric(overview$EffectiveReltol[1L])
        } else {
          NA_real_
        },
        OptimizerPolished = if (nrow(overview) > 0L) {
          isTRUE(overview$OptimizerPolished[1L])
        } else {
          FALSE
        },
        OptimizerPolishStages = if (nrow(overview) > 0L) {
          as.integer(overview$OptimizerPolishStages[1L])
        } else {
          NA_integer_
        },
        FunctionEvaluations = if (nrow(overview) > 0L) {
          as.integer(overview$FunctionEvaluations[1L])
        } else {
          NA_integer_
        },
        ElapsedSeconds = as.numeric(elapsed),
        Subsets = subset_count,
        ActualDesignStatus = actual_design,
        ExpectedDesignStatus = expectation$DesignExpectation,
        ActualDataStatus = actual_data_status,
        ExpectedDataStatus = expectation$DataExpectation,
        StabilityStatus = actual_stability_status,
        ExpectedStabilityStatus = expectation$StabilityExpectation,
        OverallStatus = if (summary_ok) {
          mfrmr_first_use_status_value(summary_capture$value, "Overall status")
        } else {
          NA_character_
        },
        ReportingStatus = reporting_status,
        UpstreamReportingHold = startsWith(reporting_status, "hold_for_") ||
          identical(reporting_status, "review_data_before_reporting"),
        DiagnosticReviewRequired = identical(
          reporting_status,
          "review_diagnostics_before_reporting"
        ),
        DiagnosticFollowUpPending = identical(
          reporting_status,
          "ready_for_diagnostics_and_reporting_follow_up"
        ),
        PlotInterpretationStatus = plot_status,
        FacetsPlotInterpretationStatus = facets_plot_status,
        PathwayPlotInterpretationStatus = pathway_plot_status,
        PersonPathwayRows = person_pathway_rows,
        WarningEventCount = length(c(
          described$warnings, fitted$warnings, diagnostic_capture$warnings,
          summary_capture$warnings, wright_capture$warnings,
          facets_wright_capture$warnings, fit_pathway_capture$warnings
        )),
        UniqueWarningCount = length(unique(c(
          described$warnings, fitted$warnings, diagnostic_capture$warnings,
          summary_capture$warnings, wright_capture$warnings,
          facets_wright_capture$warnings, fit_pathway_capture$warnings
        ))),
        Error = paste(
          Filter(nzchar, c(
            described$error, fitted$error, diagnostic_capture$error,
            summary_capture$error, wright_capture$error,
            facets_wright_capture$error, fit_pathway_capture$error
          )),
          collapse = " | "
        ),
        NumericalContract = numerical_contract,
        DesignContract = design_contract,
        DataContract = data_contract,
        StabilityContract = stability_contract,
        ReportingContract = reporting_contract,
        PlotContract = plot_contract,
        SummaryDomainsContract = summary_domains_contract,
        FacetsWrightContract = facets_surface_contract,
        FitPathwayContract = pathway_surface_contract,
        PlotReadinessContract = plot_readiness_contract,
        SurfaceChecksPassed = sum(surface_checks),
        SurfaceChecksTotal = length(surface_checks),
        ContractPassed = description_ok && fit_ok && summary_ok && wright_ok &&
          facets_wright_ok && fit_pathway_ok &&
          all(surface_checks),
        stringsAsFactors = FALSE
      )
      # Backward-compatible alias. `ContractPassed` is the precise name:
      # it means the observed behavior matched the scenario expectation, not
      # that the fitted model is automatically ready for a report.
      row$WorkflowPassed <- row$ContractPassed
      rows[[row_index]] <- row
    }
  }

  results <- do.call(rbind, rows)
  out <- list(
    plan = plan[match(scenarios, plan$Scenario), , drop = FALSE],
    results = results,
    settings = list(
      tier = tier,
      seeds = seeds,
      reltol = if (is.null(reltol)) "package_default" else as.numeric(reltol),
      include_diagnostics = isTRUE(include_diagnostics),
      generated_at = format(Sys.time(), tz = "UTC", usetz = TRUE)
    )
  )
  class(out) <- "mfrmr_first_use_stress"

  if (!is.null(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    utils::write.csv(
      results,
      file.path(output_dir, "first-use-workflow-stress-results.csv"),
      row.names = FALSE,
      na = ""
    )
    saveRDS(out, file.path(output_dir, "first-use-workflow-stress.rds"))
  }
  out
}

summary.mfrmr_first_use_stress <- function(object, ...) {
  results <- as.data.frame(object$results, stringsAsFactors = FALSE)
  scenario_summary <- do.call(rbind, lapply(split(results, results$Scenario), function(x) {
    data.frame(
      Scenario = x$Scenario[1L],
      Runs = nrow(x),
      FitSuccessRate = mean(x$FitOK),
      InferenceReadyRate = mean(x$InferenceReady),
      ContractPassRate = mean(x$ContractPassed),
      UpstreamReportingHoldRate = mean(x$UpstreamReportingHold),
      DiagnosticReviewRequiredRate = mean(x$DiagnosticReviewRequired),
      DiagnosticFollowUpPendingRate = mean(x$DiagnosticFollowUpPending),
      MaxGradient = if (any(is.finite(x$TerminalGradientSupNorm))) {
        max(x$TerminalGradientSupNorm, na.rm = TRUE)
      } else {
        NA_real_
      },
      MedianElapsedSeconds = stats::median(x$ElapsedSeconds, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  }))
  out <- list(
    overall = data.frame(
      Runs = nrow(results),
      Scenarios = length(unique(results$Scenario)),
      FitsCompleted = sum(results$FitOK),
      InferenceReady = sum(results$InferenceReady),
      ContractsPassed = sum(results$ContractPassed),
      SurfaceChecksPassed = sum(results$SurfaceChecksPassed),
      SurfaceChecksTotal = sum(results$SurfaceChecksTotal),
      UpstreamReportingHolds = sum(results$UpstreamReportingHold),
      DiagnosticReviewsRequired = sum(results$DiagnosticReviewRequired),
      DiagnosticFollowUpsPending = sum(results$DiagnosticFollowUpPending),
      stringsAsFactors = FALSE
    ),
    scenario_summary = scenario_summary,
    concerns = results[!results$ContractPassed, , drop = FALSE],
    settings = object$settings
  )
  class(out) <- "summary.mfrmr_first_use_stress"
  out
}

print.mfrmr_first_use_stress <- function(x, ...) {
  print(summary(x), ...)
  invisible(x)
}

print.summary.mfrmr_first_use_stress <- function(x, ...) {
  cat("mfrmr first-use workflow stress validation\n")
  print(x$overall, row.names = FALSE)
  cat("\nScenario summary\n")
  print(x$scenario_summary, row.names = FALSE)
  if (nrow(x$concerns) > 0L) {
    cat("\nScenario contract mismatches\n")
    keep <- intersect(
      c("Scenario", "Seed", "InferenceReady", "ActualDesignStatus",
        "ActualDataStatus", "OverallStatus", "ReportingStatus", "Error"),
      names(x$concerns)
    )
    print(x$concerns[, keep, drop = FALSE], row.names = FALSE)
  }
  invisible(x)
}
