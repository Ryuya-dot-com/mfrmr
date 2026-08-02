# mfrmr 0.2.3 common-GHQ information-criterion pilot matrix
#
# Run from the repository root after loading the development package:
#
#   pkgload::load_all(".")
#   source("inst/validation/ic-integration-pilot-0.2.3.R")
#   source("inst/validation/ic-integration-pilot-matrix-0.2.3.R")
#   matrix <- mfrmr_run_ic_integration_pilot_matrix()
#   print(matrix)
#
# The matrix uses deterministic development scenarios. It remains pilot-only:
# no observed result is a frozen release threshold or confirmation decision.

mfrmr_ic_matrix_registry <- function() {
  data.frame(
    ScenarioId = c(
      "IC-CORE-RSM-PCM",
      "IC-GPCM-SLOPE",
      "IC-SPARSE-LINKED",
      "IC-RATER-CRITERION-INTERACTION",
      "IC-LATENT-REGRESSION-SIGNAL",
      "IC-WIDE-LATENT-NEAR-TIE"
    ),
    Seed = c(NA_integer_, 20260727L, 20260728L, NA_integer_, 2718L, 20260730L),
    Design = c(
      "Packaged 48-Person RSM versus Criterion-PCM core",
      "True bounded-GPCM slope variation; PCM versus bounded GPCM",
      "Sparse but linked 48-Person assignment; RSM versus Criterion-PCM",
      "Packaged core additive RSM versus Rater-by-Criterion interaction",
      "Binary latent regression with a predictive Person covariate",
      "Binary latent variance near 9 with an irrelevant covariate"
    ),
    StressRole = c(
      "standard_and_close_aic",
      "bounded_gpcm",
      "sparse_linked",
      "interaction_confounding",
      "latent_regression",
      "wide_latent_and_coarse_grid_switch"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_ic_matrix_export <- function(name) {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop("Load the development mfrmr package before running the matrix.",
         call. = FALSE)
  }
  getExportedValue("mfrmr", name)
}

mfrmr_ic_matrix_binary_population <- function(seed,
                                              n_person,
                                              n_item,
                                              mode = c("signal", "wide_null")) {
  mode <- match.arg(mode)
  set.seed(seed)
  persons <- sprintf("P%03d", seq_len(n_person))
  items <- paste0("I", seq_len(n_item))
  x <- stats::rnorm(n_person)
  if (identical(mode, "signal")) {
    theta <- 0.25 + 0.9 * x + stats::rnorm(n_person, sd = 0.6)
    item_beta <- seq(-1.2, 1.2, length.out = n_item)
  } else {
    theta <- stats::rnorm(n_person, sd = 3)
    item_beta <- seq(-4, 4, length.out = n_item)
  }
  data <- expand.grid(
    Person = persons,
    Item = items,
    stringsAsFactors = FALSE
  )
  eta <- theta[match(data$Person, persons)] -
    item_beta[match(data$Item, items)]
  data$Score <- stats::rbinom(nrow(data), 1, stats::plogis(eta))
  list(
    data = data,
    person_data = data.frame(Person = persons, X = x,
                             stringsAsFactors = FALSE)
  )
}

mfrmr_ic_matrix_build_scenario <- function(scenario_id, seed) {
  load_data <- mfrmr_ic_matrix_export("load_mfrmr_data")
  simulate <- mfrmr_ic_matrix_export("simulate_mfrm_data")
  build_spec <- mfrmr_ic_matrix_export("build_mfrm_sim_spec")

  if (identical(scenario_id, "IC-CORE-RSM-PCM")) {
    return(list(
      data = load_data("example_core"),
      common = list(
        person = "Person", facets = c("Rater", "Criterion"),
        score = "Score", method = "MML"
      ),
      candidates = list(
        RSM = list(model = "RSM"),
        PCM = list(model = "PCM", step_facet = "Criterion")
      )
    ))
  }

  if (identical(scenario_id, "IC-GPCM-SLOPE")) {
    data <- simulate(
      n_person = 60, n_rater = 4, n_criterion = 4,
      raters_per_person = 2, assignment = "rotating",
      model = "GPCM", step_facet = "Criterion",
      slope_facet = "Criterion", slopes = c(0.70, 0.90, 1.15, 1.45),
      seed = seed
    )
    return(list(
      data = data,
      common = list(
        person = "Person", facets = c("Rater", "Criterion"),
        score = "Score", rating_min = 1, rating_max = 4, method = "MML"
      ),
      candidates = list(
        PCM = list(model = "PCM", step_facet = "Criterion"),
        GPCM = list(
          model = "GPCM", step_facet = "Criterion",
          slope_facet = "Criterion"
        )
      )
    ))
  }

  if (identical(scenario_id, "IC-SPARSE-LINKED")) {
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
    return(list(
      data = simulate(sim_spec = spec, seed = seed),
      common = list(
        person = "Person", facets = c("Rater", "Criterion"),
        score = "Score", rating_min = 1, rating_max = 4, method = "MML"
      ),
      candidates = list(
        RSM = list(model = "RSM"),
        PCM = list(model = "PCM", step_facet = "Criterion")
      )
    ))
  }

  if (identical(scenario_id, "IC-RATER-CRITERION-INTERACTION")) {
    return(list(
      data = load_data("example_core"),
      common = list(
        person = "Person", facets = c("Rater", "Criterion"),
        score = "Score", method = "MML", model = "RSM"
      ),
      candidates = list(
        Additive = list(),
        Interaction = list(facet_interactions = "Rater:Criterion")
      )
    ))
  }

  if (identical(scenario_id, "IC-LATENT-REGRESSION-SIGNAL")) {
    fixture <- mfrmr_ic_matrix_binary_population(
      seed = seed, n_person = 90L, n_item = 6L, mode = "signal"
    )
    return(list(
      data = fixture$data,
      common = list(
        person = "Person", facets = "Item", score = "Score",
        rating_min = 0, rating_max = 1, method = "MML", model = "RSM",
        person_data = fixture$person_data
      ),
      candidates = list(
        Intercept = list(population_formula = ~ 1),
        X = list(population_formula = ~ X)
      )
    ))
  }

  if (identical(scenario_id, "IC-WIDE-LATENT-NEAR-TIE")) {
    fixture <- mfrmr_ic_matrix_binary_population(
      seed = seed, n_person = 120L, n_item = 8L, mode = "wide_null"
    )
    return(list(
      data = fixture$data,
      common = list(
        person = "Person", facets = "Item", score = "Score",
        rating_min = 0, rating_max = 1, method = "MML", model = "RSM",
        person_data = fixture$person_data
      ),
      candidates = list(
        Null = list(population_formula = ~ 1),
        Noise = list(population_formula = ~ X)
      )
    ))
  }

  stop("Unknown IC integration matrix scenario: ", scenario_id,
       call. = FALSE)
}

mfrmr_ic_matrix_capture_fit <- function(arguments) {
  fit_function <- mfrmr_ic_matrix_export("fit_mfrm")
  warnings <- character(0)
  messages <- character(0)
  value <- tryCatch(
    withCallingHandlers(
      do.call(fit_function, arguments),
      warning = function(warning) {
        warnings <<- c(warnings, conditionMessage(warning))
        invokeRestart("muffleWarning")
      },
      message = function(message) {
        messages <<- c(messages, conditionMessage(message))
        invokeRestart("muffleMessage")
      }
    ),
    error = function(error) error
  )
  list(
    value = value,
    error = if (inherits(value, "error")) conditionMessage(value) else "",
    warnings = unique(warnings),
    messages = unique(messages)
  )
}

mfrmr_ic_matrix_fit_scenario <- function(built,
                                         source_quad,
                                         maxit,
                                         reltol) {
  fits <- list()
  warning_rows <- list()
  message_rows <- list()
  for (label in names(built$candidates)) {
    arguments <- utils::modifyList(
      c(list(data = built$data), built$common),
      c(
        built$candidates[[label]],
        list(
          quad_points = source_quad,
          maxit = maxit,
          reltol = reltol
        )
      )
    )
    captured <- mfrmr_ic_matrix_capture_fit(arguments)
    if (inherits(captured$value, "error")) {
      stop("Fit `", label, "` failed: ", captured$error, call. = FALSE)
    }
    fits[[label]] <- captured$value
    if (length(captured$warnings) > 0L) {
      warning_rows[[label]] <- data.frame(
        Candidate = label,
        Warning = captured$warnings,
        stringsAsFactors = FALSE
      )
    }
    if (length(captured$messages) > 0L) {
      message_rows[[label]] <- data.frame(
        Candidate = label,
        Message = captured$messages,
        stringsAsFactors = FALSE
      )
    }
  }
  empty_or_bind <- function(rows, names) {
    if (length(rows) > 0L) return(do.call(rbind, rows))
    as.data.frame(setNames(replicate(
      length(names), character(0), simplify = FALSE
    ), names), stringsAsFactors = FALSE)
  }
  list(
    fits = fits,
    warnings = empty_or_bind(warning_rows, c("Candidate", "Warning")),
    messages = empty_or_bind(message_rows, c("Candidate", "Message"))
  )
}

mfrmr_ic_matrix_summarize_pilot <- function(pilot,
                                             scenario,
                                             warning_count,
                                             candidate_raw_tolerance,
                                             candidate_gap_tolerance,
                                             candidate_ratio_tolerance) {
  core <- pilot$summary[pilot$summary$Scope == "core_ladder", , drop = FALSE]
  ratios <- core$MaxGapDriftRatio[is.finite(core$MaxGapDriftRatio)]
  max_ratio <- if (length(ratios) > 0L) max(ratios) else NA_real_
  observed_within_candidates <-
    all(core$OrderingStable) &&
    max(core$MaxAbsCriterionDrift) <= candidate_raw_tolerance &&
    max(core$MaxAbsPairwiseGapDrift) <= candidate_gap_tolerance &&
    (length(ratios) == 0L || max_ratio <= candidate_ratio_tolerance)
  reference <- pilot$criterion_values[
    pilot$criterion_values$EvaluationQuadraturePoints ==
      pilot$reference_quadrature_points &
      pilot$criterion_values$Criterion %in% c("AIC", "BIC", "SABIC"),
    , drop = FALSE
  ]
  preferences <- vapply(c("AIC", "BIC", "SABIC"), function(criterion) {
    unique(reference$Preferred[reference$Criterion == criterion])[1]
  }, character(1))
  data.frame(
    ScenarioId = scenario$ScenarioId,
    StressRole = scenario$StressRole,
    Candidates = paste(pilot$fit_metadata$Label, collapse = ";"),
    ResponseRows = unique(pilot$evaluations$ResponseRows)[1],
    Persons = unique(pilot$fit_metadata$Persons)[1],
    Npar = paste(pilot$fit_metadata$Npar, collapse = ";"),
    SourceQuadraturePoints = paste(
      unique(pilot$fit_metadata$SourceQuadraturePoints), collapse = ";"
    ),
    MaxCoreRawDrift = max(core$MaxAbsCriterionDrift),
    MaxCorePairwiseGapDrift = max(core$MaxAbsPairwiseGapDrift),
    MaxCoreGapDriftRatio = max_ratio,
    CoreOrderingStable = pilot$core_ordering_stable,
    FullLadderOrderingStable = pilot$full_ordering_stable,
    AICPreferred = preferences[["AIC"]],
    BICPreferred = preferences[["BIC"]],
    SABICPreferred = preferences[["SABIC"]],
    CapturedWarnings = warning_count,
    CandidateRuleObservation = if (observed_within_candidates) {
      "within_candidate_rules"
    } else {
      "candidate_rule_challenge"
    },
    EvidenceStatus = "review",
    stringsAsFactors = FALSE
  )
}

mfrmr_run_ic_integration_pilot_matrix <- function(
    scenarios = mfrmr_ic_matrix_registry()$ScenarioId,
    quad_points = c(7L, 15L, 31L, 61L, 91L, 121L),
    reference_quad = 121L,
    core_quad_points = c(31L, 61L, 91L, 121L),
    source_quad = 31L,
    maxit = 1000L,
    reltol = 1e-10,
    candidate_raw_tolerance = 0.10,
    candidate_gap_tolerance = 0.10,
    candidate_ratio_tolerance = 0.10,
    fail_fast = FALSE,
    progress = interactive(),
    pkg_dir = ".") {
  if (!exists("mfrmr_run_ic_integration_pilot", mode = "function")) {
    stop(
      "Source `ic-integration-pilot-0.2.3.R` before running the matrix.",
      call. = FALSE
    )
  }
  registry <- mfrmr_ic_matrix_registry()
  unknown <- setdiff(scenarios, registry$ScenarioId)
  if (length(unknown) > 0L) {
    stop("Unknown matrix scenario(s): ", paste(unknown, collapse = ", "),
         call. = FALSE)
  }
  registry <- registry[match(scenarios, registry$ScenarioId), , drop = FALSE]
  pilots <- list()
  aggregate <- list()
  warnings <- list()
  failures <- list()

  for (index in seq_len(nrow(registry))) {
    scenario <- registry[index, , drop = FALSE]
    scenario_id <- scenario$ScenarioId
    if (isTRUE(progress)) {
      cat("Running", scenario_id, "(", index, "of", nrow(registry), ")\n")
    }
    result <- tryCatch({
      built <- mfrmr_ic_matrix_build_scenario(scenario_id, scenario$Seed)
      fitted <- mfrmr_ic_matrix_fit_scenario(
        built = built,
        source_quad = source_quad,
        maxit = maxit,
        reltol = reltol
      )
      fits <- fitted$fits
      pilot <- mfrmr_run_ic_integration_pilot(
        fits = fits,
        labels = names(fits),
        quad_points = quad_points,
        reference_quad = reference_quad,
        core_quad_points = core_quad_points,
        scenario_id = scenario_id,
        specification = mfrmr_ic_integration_specification,
        pkg_dir = pkg_dir
      )
      warning_table <- fitted$warnings
      warning_table$ScenarioId <- rep(scenario_id, nrow(warning_table))
      warning_table <- warning_table[, c("ScenarioId", "Candidate", "Warning"),
                                     drop = FALSE]
      list(pilot = pilot, warnings = warning_table)
    }, error = function(error) error)

    if (inherits(result, "error")) {
      failure <- data.frame(
        ScenarioId = scenario_id,
        Error = conditionMessage(result),
        EvidenceStatus = "concern",
        stringsAsFactors = FALSE
      )
      failures[[scenario_id]] <- failure
      if (isTRUE(fail_fast)) stop(result)
      next
    }

    pilots[[scenario_id]] <- result$pilot
    warnings[[scenario_id]] <- result$warnings
    aggregate[[scenario_id]] <- mfrmr_ic_matrix_summarize_pilot(
      pilot = result$pilot,
      scenario = scenario,
      warning_count = nrow(result$warnings),
      candidate_raw_tolerance = candidate_raw_tolerance,
      candidate_gap_tolerance = candidate_gap_tolerance,
      candidate_ratio_tolerance = candidate_ratio_tolerance
    )
  }

  bind_or_empty <- function(rows, columns) {
    if (length(rows) > 0L) return(do.call(rbind, rows))
    out <- as.data.frame(setNames(replicate(
      length(columns), character(0), simplify = FALSE
    ), columns), stringsAsFactors = FALSE)
    out
  }
  aggregate_table <- bind_or_empty(aggregate, c("ScenarioId"))
  warning_table <- bind_or_empty(
    warnings,
    c("ScenarioId", "Candidate", "Warning")
  )
  failure_table <- bind_or_empty(
    failures,
    c("ScenarioId", "Error", "EvidenceStatus")
  )
  out <- list(
    specification = mfrmr_ic_integration_specification,
    evidence_role = "pilot",
    confirmation_authorized = FALSE,
    registry = registry,
    quadrature_points = quad_points,
    core_quadrature_points = core_quad_points,
    reference_quadrature_points = reference_quad,
    source_quadrature_points = source_quad,
    candidate_rules = c(
      raw_drift = candidate_raw_tolerance,
      pairwise_gap_drift = candidate_gap_tolerance,
      relative_gap_drift = candidate_ratio_tolerance
    ),
    pilots = pilots,
    aggregate = aggregate_table,
    warnings = warning_table,
    failures = failure_table,
    status = if (nrow(failure_table) > 0L) "concern" else "review"
  )
  class(out) <- c("mfrmr_ic_integration_pilot_matrix", class(out))
  out
}

print.mfrmr_ic_integration_pilot_matrix <- function(x, digits = 6L, ...) {
  cat("mfrmr 0.2.3 common-GHQ IC integration pilot matrix\n")
  cat("  Specification:", x$specification, "\n")
  cat("  Scenarios retained:", nrow(x$aggregate), "of", nrow(x$registry), "\n")
  cat("  Failed scenarios:", nrow(x$failures), "\n")
  cat("  Status:", x$status, "\n")
  if (nrow(x$aggregate) > 0L) {
    display <- x$aggregate[, c(
      "ScenarioId", "MaxCoreRawDrift", "MaxCorePairwiseGapDrift",
      "MaxCoreGapDriftRatio", "CoreOrderingStable",
      "FullLadderOrderingStable", "CandidateRuleObservation"
    ), drop = FALSE]
    numeric_columns <- vapply(display, is.numeric, logical(1))
    display[numeric_columns] <- lapply(display[numeric_columns], round, digits)
    print(display, row.names = FALSE)
  }
  if (nrow(x$failures) > 0L) print(x$failures, row.names = FALSE)
  cat("  Pilot only: candidate rules remain unfrozen.\n")
  invisible(x)
}
