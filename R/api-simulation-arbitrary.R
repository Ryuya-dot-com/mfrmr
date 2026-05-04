#' Build an arbitrary-facet MFRM simulation specification
#'
#' @param n_person Number of persons. A vector creates design-grid choices.
#' @param facets Named counts for all non-person facets, or a named list whose
#'   elements are count choices.
#' @param facet_sd Optional named standard deviations for simulated facet
#'   effects. A single unnamed value is reused for every facet.
#' @param facets_per_person Optional named assignment counts. Facets not listed
#'   are fully crossed within each person; listed facets use deterministic
#'   rotating subsets of the requested size.
#' @param score_levels Number of ordered score categories.
#' @param theta_sd Standard deviation of simulated person measures.
#' @param noise_sd Optional observation-level noise added to the linear
#'   predictor.
#' @param step_span Spread of generated common RSM thresholds.
#' @param thresholds Optional common RSM thresholds. Must have
#'   `score_levels - 1` values.
#' @param group_levels Optional group labels assigned at the person level.
#' @param dif_effects Optional DIF effect table. See
#'   [simulate_mfrm_arbitrary_data()].
#' @param interaction_effects Optional facet-interaction effect table. See
#'   [simulate_mfrm_arbitrary_data()].
#' @param model Measurement model for the arbitrary-facet generator. Version
#'   0.2.0 supports `model = "RSM"` for this arbitrary-facet branch.
#'
#' @details
#' This specification is the arbitrary-facet counterpart to
#' [build_mfrm_sim_spec()]. It is intentionally additive: the older
#' role-based `Person x Rater x Criterion` generator remains available for
#' PCM/GPCM simulation contracts, while this branch focuses on flexible
#' RSM-based design and bias-screening sensitivity checks with any number of
#' non-person facets.
#'
#' If `facets_per_person` contains `Rater = 2` and `Task = 3`, each person is
#' assigned a deterministic rotating subset of two raters and three tasks. Any
#' omitted facet, such as `Criteria`, is fully crossed with those selected
#' levels. This makes the generated skeleton reproducible and easy to inspect
#' before fitting.
#'
#' A typical design-first workflow is to build a specification, inspect it with
#' [summarize_mfrm_sim_design()] or [plot_mfrm_sim_design()], simulate data, and
#' then fit or evaluate the design. If a researcher already has a fitted RSM
#' model, use [extract_mfrm_arbitrary_sim_spec()] instead so the simulation
#' starts from the observed response skeleton and fitted estimates.
#'
#' @return An object of class `mfrm_arbitrary_sim_spec`.
#' @seealso [simulate_mfrm_arbitrary_data()], [summarize_mfrm_sim_design()],
#'   [summarize_mfrm_sim_grid()], [plot_mfrm_sim_grid()],
#'   [evaluate_mfrm_bias_detection()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 20,
#'   facets = c(Rater = 4, Criteria = 3, Task = 5, Occasion = 2),
#'   facet_sd = c(Rater = .35, Criteria = .25, Task = .30, Occasion = .10),
#'   facets_per_person = c(Rater = 2, Task = 3),
#'   score_levels = 5
#' )
#' spec$design_grid
#' design <- summarize_mfrm_sim_design(spec)
#' design$overview
#' design$assignment
#' @export
build_mfrm_arbitrary_sim_spec <- function(n_person = 50,
                                          facets,
                                          facet_sd = NULL,
                                          facets_per_person = NULL,
                                          score_levels = 5,
                                          theta_sd = 1,
                                          noise_sd = 0,
                                          step_span = 1.4,
                                          thresholds = NULL,
                                          group_levels = NULL,
                                          dif_effects = NULL,
                                          interaction_effects = NULL,
                                          model = c("RSM", "PCM", "GPCM")) {
  if (missing(facets) || is.null(facets)) {
    stop("`facets` must be a named vector or named list of non-person facet counts.", call. = FALSE)
  }
  model <- match.arg(toupper(as.character(model[1])), c("RSM", "PCM", "GPCM"))
  if (!identical(model, "RSM")) {
    stop(
      "`build_mfrm_arbitrary_sim_spec()` supports `model = \"RSM\"` in version 0.2.0. ",
      "Use `build_mfrm_sim_spec()` / `simulate_mfrm_data()` for role-based PCM/GPCM simulation.",
      call. = FALSE
    )
  }

  n_person_choices <- mfrm_arbitrary_int_choices(n_person, "n_person", min_value = 2L)
  facet_choices <- mfrm_arbitrary_named_int_choices(facets, "facets", min_value = 2L)
  facet_names <- names(facet_choices)
  mfrm_arbitrary_validate_facet_names(facet_names)

  assignment_choices <- mfrm_arbitrary_assignment_choices(
    facets_per_person,
    facet_names = facet_names
  )
  facet_sd <- mfrm_arbitrary_facet_sd(facet_sd, facet_names)

  score_levels <- as.integer(score_levels[1])
  if (!is.finite(score_levels) || score_levels < 2L) {
    stop("`score_levels` must be an integer >= 2.", call. = FALSE)
  }
  theta_sd <- as.numeric(theta_sd[1])
  noise_sd <- as.numeric(noise_sd[1])
  step_span <- as.numeric(step_span[1])
  if (!is.finite(theta_sd) || theta_sd < 0) stop("`theta_sd` must be non-negative.", call. = FALSE)
  if (!is.finite(noise_sd) || noise_sd < 0) stop("`noise_sd` must be non-negative.", call. = FALSE)
  if (!is.finite(step_span) || step_span <= 0) stop("`step_span` must be positive.", call. = FALSE)

  thresholds <- mfrm_arbitrary_thresholds(
    thresholds = thresholds,
    score_levels = score_levels,
    step_span = step_span
  )

  group_levels <- mfrm_arbitrary_group_levels(group_levels)
  allowed_cols <- c("Group", "Person", facet_names)
  dif_effects <- simulation_normalize_effects(
    effects = dif_effects,
    arg_name = "dif_effects",
    allowed_cols = allowed_cols
  )
  interaction_effects <- simulation_normalize_effects(
    effects = interaction_effects,
    arg_name = "interaction_effects",
    allowed_cols = allowed_cols
  )

  spec <- list(
    n_person = n_person_choices,
    facets = facet_choices,
    facet_names = facet_names,
    facet_sd = facet_sd,
    facets_per_person = assignment_choices,
    score_levels = score_levels,
    theta_sd = theta_sd,
    noise_sd = noise_sd,
    step_span = step_span,
    thresholds = thresholds,
    group_levels = group_levels,
    dif_effects = dif_effects,
    interaction_effects = interaction_effects,
    model = model,
    assignment = "rotating_per_person_subsets",
    measurement_formula = "eta = theta_person - sum(facet_level_effects) + injected_effects",
    response_model = "RSM_common_thresholds"
  )
  spec$design_grid <- mfrm_arbitrary_design_grid(spec)
  class(spec) <- c("mfrm_arbitrary_sim_spec", "list")
  spec
}

#' Extract an arbitrary-facet simulation specification from a fitted model
#'
#' @param fit An `mfrm_fit` object returned by [fit_mfrm()].
#' @param data Optional original long-format data. When supplied with
#'   `group`, person-level group labels are carried into the simulation
#'   skeleton. The fitted model's retained analysis skeleton is otherwise used.
#' @param assignment Simulation assignment mode. `"skeleton"` reuses the
#'   fitted response skeleton exactly. `"balanced"` keeps the fitted facet
#'   levels and estimated parameters but rebuilds a deterministic rotating
#'   design using `facets_per_person`.
#' @param parameter_source Parameter source for simulated truth. `"estimates"`
#'   uses the fitted person, facet, and RSM threshold estimates directly.
#'   `"resampled"` samples fitted person/facet estimates with replacement from
#'   their empirical support.
#' @param facets_per_person Optional named assignment counts used when
#'   `assignment = "balanced"`. If omitted, the median number of observed levels
#'   per person is derived from the fitted skeleton for each facet.
#' @param group Optional group column in `data` to carry into the skeleton.
#' @param include_weights Whether the fitted analysis weights should be carried
#'   into skeleton simulations.
#' @param noise_sd Optional observation-level noise added during simulation.
#' @param dif_effects Optional DIF effect table passed through to the resulting
#'   specification.
#' @param interaction_effects Optional interaction effect table passed through
#'   to the resulting specification.
#'
#' @details
#' This helper connects the model a researcher has already estimated to the
#' arbitrary-facet simulation branch. It is deliberately limited to fitted
#' `RSM` models in version 0.2.0 because [simulate_mfrm_arbitrary_data()] uses a
#' common-threshold RSM response generator. Role-based PCM/GPCM simulation
#' remains available through [extract_mfrm_sim_spec()] and [simulate_mfrm_data()].
#'
#' With `assignment = "skeleton"`, the generated data reuse the same retained
#' person-by-facet observation rows used by the fitted model. With
#' `parameter_source = "estimates"`, the fitted person measures, facet
#' measures, and step estimates are used as the data-generating truth, so the
#' simulation answers a direct question: how would repeated responses behave
#' under this fitted model and this observed design? If the fitted analysis
#' used observation weights, the extracted specification records the retained
#' `Weight` column so [evaluate_mfrm_bias_detection()] can refit simulated data
#' with the same weighting unless `fit_args$weight` overrides it.
#'
#' Use `assignment = "balanced"` when the question is not a direct parametric
#' replay of the observed design, but a planning question such as "what if the
#' same fitted severity distribution were used under a more balanced rater-task
#' assignment?" In that case, `facets_per_person` controls the rebuilt design.
#'
#' @return An object of class `mfrm_arbitrary_sim_spec`.
#' @seealso [simulate_mfrm_arbitrary_data()], [build_mfrm_arbitrary_sim_spec()],
#'   [extract_mfrm_sim_spec()]
#' @examples
#' spec0 <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 12,
#'   facets = c(Rater = 3, Criteria = 2, Task = 2),
#'   facets_per_person = c(Rater = 2),
#'   score_levels = 4
#' )
#' dat <- simulate_mfrm_arbitrary_data(spec0, seed = 1)
#' fit <- fit_mfrm(
#'   dat,
#'   person = "Person",
#'   facets = spec0$facet_names,
#'   score = "Score",
#'   rating_min = 1,
#'   rating_max = 4,
#'   model = "RSM",
#'   method = "JML",
#'   maxit = 20
#' )
#' fitted_spec <- extract_mfrm_arbitrary_sim_spec(fit)
#' summarize_mfrm_sim_design(fitted_spec)$overview
#' fitted_sim <- simulate_mfrm_arbitrary_data(fitted_spec, seed = 2)
#' head(fitted_sim)
#'
#' balanced_spec <- extract_mfrm_arbitrary_sim_spec(
#'   fit,
#'   assignment = "balanced",
#'   parameter_source = "resampled",
#'   facets_per_person = c(Rater = 2)
#' )
#' summarize_mfrm_sim_design(balanced_spec)$assignment
#' @export
extract_mfrm_arbitrary_sim_spec <- function(fit,
                                            data = NULL,
                                            assignment = c("skeleton", "balanced"),
                                            parameter_source = c("estimates", "resampled"),
                                            facets_per_person = NULL,
                                            group = NULL,
                                            include_weights = TRUE,
                                            noise_sd = 0,
                                            dif_effects = NULL,
                                            interaction_effects = NULL) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object returned by fit_mfrm().", call. = FALSE)
  }
  model <- toupper(as.character(fit$config$model %||% fit$summary$Model[1] %||% NA_character_))
  if (!identical(model, "RSM")) {
    stop(
      "`extract_mfrm_arbitrary_sim_spec()` currently supports fitted `RSM` models only. ",
      "Use `extract_mfrm_sim_spec()` / `simulate_mfrm_data()` for role-based PCM/GPCM simulation.",
      call. = FALSE
    )
  }
  assignment <- match.arg(assignment)
  parameter_source <- match.arg(parameter_source)
  if (!is.logical(include_weights) || length(include_weights) != 1L || is.na(include_weights)) {
    stop("`include_weights` must be TRUE or FALSE.", call. = FALSE)
  }

  facet_names <- as.character(fit$config$facet_names %||% fit$prep$facet_names %||% character(0))
  if (length(facet_names) == 0L) {
    stop("Could not identify facet names from `fit`.", call. = FALSE)
  }
  mfrm_arbitrary_validate_facet_names(facet_names)
  skeleton <- mfrm_arbitrary_fit_skeleton(
    fit = fit,
    data = data,
    group = group,
    include_weights = include_weights
  )
  facet_levels <- stats::setNames(
    lapply(facet_names, function(facet) sort(unique(as.character(skeleton[[facet]])))),
    facet_names
  )
  person_levels <- sort(unique(as.character(skeleton$Person)))
  facet_counts <- vapply(facet_levels, length, integer(1))
  facet_counts_list <- as.list(facet_counts)
  names(facet_counts_list) <- facet_names
  empirical_assign <- mfrm_arbitrary_empirical_facets_per_person(skeleton, facet_names)
  if (identical(assignment, "skeleton")) {
    assignment_counts <- NULL
  } else {
    assignment_counts <- if (is.null(facets_per_person)) empirical_assign else facets_per_person
  }

  params <- mfrm_arbitrary_fit_parameters(fit, facet_names = facet_names)
  score_levels <- as.integer(fit$prep$rating_max - fit$prep$rating_min + 1L)
  spec <- build_mfrm_arbitrary_sim_spec(
    n_person = length(person_levels),
    facets = facet_counts_list,
    facet_sd = mfrm_arbitrary_empirical_facet_sd(params$facets, facet_names),
    facets_per_person = assignment_counts,
    score_levels = score_levels,
    theta_sd = mfrm_arbitrary_sd(params$person),
    noise_sd = noise_sd,
    thresholds = params$thresholds,
    group_levels = if ("Group" %in% names(skeleton)) sort(unique(as.character(skeleton$Group))) else NULL,
    dif_effects = dif_effects,
    interaction_effects = interaction_effects,
    model = "RSM"
  )
  spec$assignment <- assignment
  spec$parameter_source <- parameter_source
  spec$source <- "fit_mfrm"
  spec$source_fit <- list(
    model = model,
    method = as.character(fit$config$method_input %||% fit$config$method %||% NA_character_),
    converged = isTRUE(as.logical(fit$summary$Converged[1])),
    logLik = suppressWarnings(as.numeric(fit$summary$LogLik[1] %||% NA_real_))
  )
  spec$rating_min <- as.integer(fit$prep$rating_min)
  spec$rating_max <- as.integer(fit$prep$rating_max)
  spec$score_values <- seq(spec$rating_min, spec$rating_max)
  spec$weight_col <- if (isTRUE(include_weights) && "Weight" %in% names(skeleton)) "Weight" else NULL
  spec$person_levels <- person_levels
  spec$facet_levels <- facet_levels
  spec$empirical_skeleton <- skeleton
  spec$empirical_parameters <- params
  spec$empirical_assignment <- empirical_assign
  spec$measurement_formula <- "eta = fitted_person_measure - sum(fitted_facet_measures) + injected_effects"
  spec$response_model <- "RSM_common_thresholds_from_fit"
  spec$extraction <- list(
    assignment = assignment,
    parameter_source = parameter_source,
    group = if (is.null(group)) NULL else as.character(group[1]),
    include_weights = isTRUE(include_weights)
  )
  class(spec) <- c("mfrm_arbitrary_sim_spec", "list")
  spec
}

#' Simulate arbitrary-facet RSM data
#'
#' @param sim_spec Output from [build_mfrm_arbitrary_sim_spec()].
#' @param design_id Design row to use from `sim_spec$design_grid`. Use one value
#'   for data generation.
#' @param design Optional one-row design override with the same columns as
#'   `sim_spec$design_grid`.
#' @param seed Optional random seed.
#' @param dif_effects Optional DIF effect table. The table must include `Effect`,
#'   `Group`, and at least one of `Person` or a simulated facet column.
#' @param interaction_effects Optional interaction effect table. The table must
#'   include `Effect` and at least one of `Person` or a simulated facet column.
#'
#' @details
#' The arbitrary-facet generator samples
#' \deqn{\eta_{n...} = \theta_n - \sum_f \delta_{f,\ell} + e_{n...},}
#' then applies any row-matched `dif_effects` and `interaction_effects` as logit
#' shifts before sampling ordered categories under a common-threshold RSM:
#' \deqn{P(X = k) \propto \exp(k\eta - \sum_{h=1}^{k}\tau_h).}
#'
#' Higher simulated facet effects therefore behave as more severe or more
#' difficult levels, matching the sign convention used by [fit_mfrm()].
#' Specifications created by [extract_mfrm_arbitrary_sim_spec()] may reuse a
#' fitted response skeleton, fitted person/facet estimates, retained weights,
#' and the fitted rating range rather than generated labels and parameters.
#'
#' Category labels are generated as `1:score_levels` for design-first
#' specifications. For fit-derived specifications, the fitted `rating_min` and
#' `rating_max` are reused, so scales such as `0:3` remain on their original
#' score metric.
#'
#' @return A long-format `data.frame` with `Study`, `Person`, arbitrary facet
#'   columns, and `Score`. Attributes `mfrm_truth` and `mfrm_simulation_spec`
#'   store the generating values and reusable design metadata.
#' @seealso [build_mfrm_arbitrary_sim_spec()], [fit_mfrm()],
#'   [summarize_mfrm_sim_design()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 12,
#'   facets = c(Rater = 3, Criteria = 2, Task = 3),
#'   facets_per_person = c(Rater = 2, Task = 2),
#'   score_levels = 4
#' )
#' sim <- simulate_mfrm_arbitrary_data(spec, seed = 1)
#' head(sim)
#' attr(sim, "mfrm_truth")$design
#' @export
simulate_mfrm_arbitrary_data <- function(sim_spec,
                                         design_id = 1,
                                         design = NULL,
                                         seed = NULL,
                                         dif_effects = NULL,
                                         interaction_effects = NULL) {
  if (!inherits(sim_spec, "mfrm_arbitrary_sim_spec")) {
    stop("`sim_spec` must be output from build_mfrm_arbitrary_sim_spec().", call. = FALSE)
  }
  design_row <- mfrm_arbitrary_select_single_design(sim_spec, design_id = design_id, design = design)
  facet_counts <- mfrm_arbitrary_design_counts(sim_spec, design_row)
  assignment_counts <- mfrm_arbitrary_design_assignments(sim_spec, design_row, facet_counts)
  facet_names <- sim_spec$facet_names
  thresholds <- sim_spec$thresholds

  dif_effects <- if (is.null(dif_effects)) sim_spec$dif_effects else dif_effects
  interaction_effects <- if (is.null(interaction_effects)) {
    sim_spec$interaction_effects
  } else {
    interaction_effects
  }

  with_preserved_rng_seed(seed, {
    use_skeleton <- identical(as.character(sim_spec$assignment %||% ""), "skeleton") &&
      is.data.frame(sim_spec$empirical_skeleton)
    person_ids <- if (isTRUE(use_skeleton)) {
      unique(as.character(sim_spec$empirical_skeleton$Person))
    } else if (!is.null(sim_spec$person_levels) &&
               length(sim_spec$person_levels) == as.integer(design_row$n_person[1])) {
      as.character(sim_spec$person_levels)
    } else {
      sprintf("P%03d", seq_len(as.integer(design_row$n_person[1])))
    }
    level_map <- stats::setNames(
      lapply(facet_names, function(f) {
        fitted_levels <- sim_spec$facet_levels[[f]] %||% NULL
        if (!is.null(fitted_levels) && length(fitted_levels) == facet_counts[[f]]) {
          return(as.character(fitted_levels))
        }
        mfrm_arbitrary_level_labels(f, facet_counts[[f]])
      }),
      facet_names
    )
    dat <- if (isTRUE(use_skeleton)) {
      tibble::as_tibble(sim_spec$empirical_skeleton)
    } else {
      mfrm_arbitrary_build_skeleton(
        person_ids = person_ids,
        level_map = level_map,
        assignment_counts = assignment_counts
      )
    }
    group_assign <- NULL
    if (!is.null(sim_spec$group_levels)) {
      if ("Group" %in% names(dat)) {
        group_assign_tbl <- dat[!is.na(dat$Group) & nzchar(as.character(dat$Group)), c("Person", "Group"), drop = FALSE]
        group_assign_tbl <- unique(group_assign_tbl)
        group_assign <- stats::setNames(as.character(group_assign_tbl$Group), as.character(group_assign_tbl$Person))
      } else {
        group_assign <- rep(sim_spec$group_levels, length.out = length(person_ids))
        group_assign <- sample(group_assign, size = length(person_ids), replace = FALSE)
        names(group_assign) <- person_ids
        dat$Group <- unname(group_assign[dat$Person])
      }
    }

    theta <- mfrm_arbitrary_sim_person_values(sim_spec, person_ids)
    names(theta) <- person_ids
    facet_effects <- mfrm_arbitrary_sim_facet_values(sim_spec, facet_names, level_map)

    allowed_cols <- intersect(c("Group", "Person", facet_names), names(dat))
    dif_effects <- simulation_normalize_effects(
      effects = dif_effects,
      arg_name = "dif_effects",
      allowed_cols = allowed_cols
    )
    if (nrow(dif_effects) > 0L) {
      if (!"Group" %in% names(dif_effects)) {
        stop("`dif_effects` must include a `Group` column.", call. = FALSE)
      }
      if (!any(c("Person", facet_names) %in% names(dif_effects))) {
        stop("`dif_effects` must include at least one target facet or `Person` column.", call. = FALSE)
      }
    }
    interaction_effects <- simulation_normalize_effects(
      effects = interaction_effects,
      arg_name = "interaction_effects",
      allowed_cols = allowed_cols
    )
    if (nrow(interaction_effects) > 0L && !any(c("Person", facet_names) %in% names(interaction_effects))) {
      stop("`interaction_effects` must include at least one target facet or `Person` column.", call. = FALSE)
    }

    eta <- as.numeric(theta[dat$Person])
    for (facet in facet_names) {
      eta <- eta - as.numeric(facet_effects[[facet]][as.character(dat[[facet]])])
    }
    eta <- eta + simulation_apply_effects(dat, dif_effects)
    eta <- eta + simulation_apply_effects(dat, interaction_effects)
    if (sim_spec$noise_sd > 0) {
      eta <- eta + stats::rnorm(length(eta), mean = 0, sd = sim_spec$noise_sd)
    }

    prob_mat <- category_prob_rsm(eta, c(0, cumsum(thresholds)))
    rating_min <- as.integer(sim_spec$rating_min %||% 1L)
    dat$Score <- apply(prob_mat, 1, function(p) rating_min + sample.int(sim_spec$score_levels, size = 1L, prob = p) - 1L)
    dat$Study <- "SimulatedArbitraryDesign"
    keep_cols <- c("Study", "Person", facet_names, "Score")
    if ("Group" %in% names(dat)) keep_cols <- c(keep_cols, "Group")
    if ("Weight" %in% names(dat)) keep_cols <- c(keep_cols, "Weight")
    dat <- dat[, keep_cols, drop = FALSE]

    step_table <- data.frame(
      StepFacet = "Common",
      StepIndex = seq_along(thresholds),
      Step = paste0("Step_", seq_along(thresholds)),
      Estimate = thresholds,
      stringsAsFactors = FALSE
    )
    attr(dat, "mfrm_truth") <- list(
      person = theta,
      facets = facet_effects,
      steps = thresholds,
      step_table = step_table,
      groups = group_assign,
      design = list(
        design_id = as.integer(design_row$design_id[1] %||% NA_integer_),
        facet_counts = facet_counts,
        facets_per_person = assignment_counts,
        observations = nrow(dat),
        assignment = as.character(sim_spec$assignment %||% "rotating_per_person_subsets"),
        parameter_source = as.character(sim_spec$parameter_source %||% "generated")
      ),
      signals = list(
        dif_effects = dif_effects,
        interaction_effects = interaction_effects
      )
    )
    attr(dat, "mfrm_simulation_spec") <- sim_spec
    dat
  })
}

#' Summarize an arbitrary-facet simulation design
#'
#' @param x Simulated data from [simulate_mfrm_arbitrary_data()] or a
#'   specification from [build_mfrm_arbitrary_sim_spec()].
#' @param design_id Design row used when `x` is a specification.
#' @param design Optional one-row design override used when `x` is a
#'   specification.
#'
#' @return A list of class `mfrm_sim_design_summary` with overview,
#'   facet-load, person-load, pair-coverage, and assignment tables.
#' @seealso [plot_mfrm_sim_design()], [summarize_mfrm_sim_grid()],
#'   [simulate_mfrm_arbitrary_data()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 10,
#'   facets = c(Rater = 3, Criteria = 2, Task = 2),
#'   facets_per_person = c(Rater = 2)
#' )
#' summarize_mfrm_sim_design(spec)
#' @export
summarize_mfrm_sim_design <- function(x, design_id = 1, design = NULL) {
  if (inherits(x, "mfrm_arbitrary_sim_spec")) {
    if (identical(as.character(x$assignment %||% ""), "skeleton") &&
        is.data.frame(x$empirical_skeleton)) {
      dat <- tibble::as_tibble(x$empirical_skeleton)
    } else {
      design_row <- mfrm_arbitrary_select_single_design(x, design_id = design_id, design = design)
      facet_counts <- mfrm_arbitrary_design_counts(x, design_row)
      assignment_counts <- mfrm_arbitrary_design_assignments(x, design_row, facet_counts)
      person_ids <- if (!is.null(x$person_levels) && length(x$person_levels) == as.integer(design_row$n_person[1])) {
        as.character(x$person_levels)
      } else {
        sprintf("P%03d", seq_len(as.integer(design_row$n_person[1])))
      }
      level_map <- stats::setNames(
        lapply(x$facet_names, function(f) {
          fitted_levels <- x$facet_levels[[f]] %||% NULL
          if (!is.null(fitted_levels) && length(fitted_levels) == facet_counts[[f]]) {
            return(as.character(fitted_levels))
          }
          mfrm_arbitrary_level_labels(f, facet_counts[[f]])
        }),
        x$facet_names
      )
      dat <- mfrm_arbitrary_build_skeleton(
        person_ids = person_ids,
        level_map = level_map,
        assignment_counts = assignment_counts
      )
    }
    dat$Study <- "SimulatedArbitraryDesign"
    spec <- x
    source <- "specification"
  } else if (is.data.frame(x)) {
    dat <- as.data.frame(x, stringsAsFactors = FALSE)
    spec <- attr(x, "mfrm_simulation_spec")
    source <- "data"
  } else {
    stop("`x` must be simulated data or an mfrm_arbitrary_sim_spec object.", call. = FALSE)
  }

  facet_names <- if (inherits(spec, "mfrm_arbitrary_sim_spec")) {
    spec$facet_names
  } else {
    setdiff(names(dat), c("Study", "Person", "Score", "Group", "Weight"))
  }
  facet_names <- facet_names[facet_names %in% names(dat)]
  if (!"Person" %in% names(dat) || length(facet_names) == 0L) {
    stop("Could not identify `Person` and non-person facet columns in `x`.", call. = FALSE)
  }

  overview <- data.frame(
    Source = source,
    Observations = nrow(dat),
    Persons = length(unique(as.character(dat$Person))),
    Facets = length(facet_names),
    ScoreLevels = if ("Score" %in% names(dat)) {
      length(unique(dat$Score))
    } else if (inherits(spec, "mfrm_arbitrary_sim_spec")) {
      as.integer(spec$score_levels %||% NA_integer_)
    } else {
      NA_integer_
    },
    stringsAsFactors = FALSE
  )
  facet_load <- mfrm_arbitrary_facet_load(dat, facet_names)
  person_load <- mfrm_arbitrary_person_load(dat, facet_names)
  pair_coverage <- mfrm_arbitrary_pair_coverage(dat, facet_names)
  assignment <- mfrm_arbitrary_assignment_summary(dat, facet_names)

  out <- list(
    overview = overview,
    facet_load = facet_load,
    person_load = person_load,
    pair_coverage = pair_coverage,
    assignment = assignment,
    facet_names = facet_names,
    source = source
  )
  class(out) <- c("mfrm_sim_design_summary", "list")
  out
}

#' Summarize all rows in an arbitrary-facet simulation design grid
#'
#' @param sim_spec Output from [build_mfrm_arbitrary_sim_spec()] or
#'   [extract_mfrm_arbitrary_sim_spec()].
#' @param design_id Optional design rows to summarize. Use `NULL` to summarize
#'   every row in `sim_spec$design_grid`.
#'
#' @details
#' This grid summary is the multi-design companion to
#' [summarize_mfrm_sim_design()]. It is useful when a planning grid varies
#' `n_Rater` together with other facet counts such as `n_Task`,
#' `n_Criteria`, or assignment counts such as `Rater_per_person`.
#'
#' The returned table keeps the original design-grid columns and adds workload
#' and coverage metrics. `MeanObsPerPerson` describes person-level rating load;
#' `MinPairCoverage` and `MeanPairCoverage` summarize how completely each
#' pair of non-person facets is crossed within the generated skeleton.
#'
#' @return A data frame of class `mfrm_sim_grid_summary`.
#' @seealso [plot_mfrm_sim_grid()], [plot_mfrm_sim_dashboard()],
#'   [list_mfrm_sim_metrics()], [summarize_mfrm_sim_design()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 20,
#'   facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
#'   facets_per_person = list(Rater = c(1, 2), Task = 2),
#'   score_levels = 4
#' )
#' grid <- summarize_mfrm_sim_grid(spec)
#' grid[, c("design_id", "n_Rater", "n_Criteria", "n_Task", "Observations")]
#' @export
summarize_mfrm_sim_grid <- function(sim_spec, design_id = NULL) {
  if (!inherits(sim_spec, "mfrm_arbitrary_sim_spec")) {
    stop("`sim_spec` must be output from build_mfrm_arbitrary_sim_spec().", call. = FALSE)
  }
  design_rows <- mfrm_arbitrary_select_design_rows(sim_spec, design_id = design_id)
  rows <- vector("list", nrow(design_rows))
  for (i in seq_len(nrow(design_rows))) {
    design_row <- design_rows[i, , drop = FALSE]
    design_summary <- summarize_mfrm_sim_design(sim_spec, design = design_row)
    person_load <- as.data.frame(design_summary$person_load, stringsAsFactors = FALSE)
    pair_coverage <- as.data.frame(design_summary$pair_coverage, stringsAsFactors = FALSE)
    facet_load <- as.data.frame(design_summary$facet_load, stringsAsFactors = FALSE)

    pair_rates <- suppressWarnings(as.numeric(pair_coverage$CoverageRate))
    person_obs <- suppressWarnings(as.numeric(person_load$Observations))
    person_share <- suppressWarnings(as.numeric(facet_load$PersonShare))

    rows[[i]] <- cbind(
      as.data.frame(design_row, stringsAsFactors = FALSE),
      data.frame(
        Observations = as.integer(design_summary$overview$Observations[1]),
        Persons = as.integer(design_summary$overview$Persons[1]),
        Facets = as.integer(design_summary$overview$Facets[1]),
        ScoreLevels = as.integer(design_summary$overview$ScoreLevels[1]),
        MeanObsPerPerson = mean(person_obs, na.rm = TRUE),
        MinObsPerPerson = min(person_obs, na.rm = TRUE),
        MaxObsPerPerson = max(person_obs, na.rm = TRUE),
        MeanPairCoverage = if (length(pair_rates) > 0L) mean(pair_rates, na.rm = TRUE) else NA_real_,
        MinPairCoverage = if (length(pair_rates) > 0L) min(pair_rates, na.rm = TRUE) else NA_real_,
        CompletePairCoverageRate = if (length(pair_rates) > 0L) mean(pair_rates >= 1, na.rm = TRUE) else NA_real_,
        MeanFacetPersonShare = mean(person_share, na.rm = TRUE),
        MinFacetPersonShare = min(person_share, na.rm = TRUE),
        stringsAsFactors = FALSE
      )
    )
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  class(out) <- c("mfrm_sim_grid_summary", "data.frame")
  out
}

#' Plot arbitrary-facet simulation design diagnostics
#'
#' @param x Output from [summarize_mfrm_sim_design()], simulated data, or an
#'   arbitrary simulation specification.
#' @param type Plot payload type: facet-level load, person-level load, or
#'   pairwise coverage.
#' @param facet Optional facet filter for `type = "load"`.
#' @param pair Optional two-facet character vector for `type = "pair_coverage"`.
#' @param draw Whether to draw a base R plot.
#' @param ... Reserved for future extensions.
#'
#' @return Invisibly, an `mfrm_plot_data` object.
#' @seealso [summarize_mfrm_sim_design()], [plot_mfrm_sim_grid()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 10,
#'   facets = c(Rater = 3, Criteria = 2, Task = 2),
#'   facets_per_person = c(Rater = 2)
#' )
#' plot_mfrm_sim_design(spec, draw = FALSE)
#' @export
plot_mfrm_sim_design <- function(x,
                                 type = c("load", "person_load", "pair_coverage"),
                                 facet = NULL,
                                 pair = NULL,
                                 draw = TRUE,
                                 ...) {
  type <- match.arg(type)
  summary_obj <- if (inherits(x, "mfrm_sim_design_summary")) x else summarize_mfrm_sim_design(x)
  plot_tbl <- switch(
    type,
    load = {
      tbl <- summary_obj$facet_load
      if (!is.null(facet)) tbl <- tbl[as.character(tbl$Facet) == as.character(facet[1]), , drop = FALSE]
      tbl
    },
    person_load = summary_obj$person_load,
    pair_coverage = {
      tbl <- summary_obj$pair_coverage
      if (!is.null(pair)) {
        pair <- as.character(pair)
        if (length(pair) != 2L) stop("`pair` must contain exactly two facet names.", call. = FALSE)
        tbl <- tbl[
          (as.character(tbl$FacetA) == pair[1] & as.character(tbl$FacetB) == pair[2]) |
            (as.character(tbl$FacetA) == pair[2] & as.character(tbl$FacetB) == pair[1]),
          ,
          drop = FALSE
        ]
      }
      tbl
    }
  )
  if (nrow(plot_tbl) == 0L) {
    stop("No design rows are available for plotting.", call. = FALSE)
  }

  if (isTRUE(draw)) {
    if (identical(type, "load")) {
      labels <- paste(plot_tbl$Facet, plot_tbl$Level, sep = ":")
      graphics::barplot(
        stats::setNames(plot_tbl$Observations, labels),
        las = 2,
        ylab = "Observations",
        main = "Facet-level load"
      )
    } else if (identical(type, "person_load")) {
      graphics::hist(
        plot_tbl$Observations,
        xlab = "Observations per person",
        main = "Person-level load",
        col = "#BFD7EA",
        border = "white"
      )
    } else {
      labels <- paste(plot_tbl$FacetA, plot_tbl$FacetB, sep = " x ")
      graphics::barplot(
        stats::setNames(plot_tbl$CoverageRate, labels),
        las = 2,
        ylim = c(0, 1),
        ylab = "Observed pair coverage",
        main = "Pairwise facet coverage"
      )
    }
  }

  invisible(new_mfrm_plot_data(
    "simulation_design",
    list(
      data = plot_tbl,
      summary = summary_obj,
      type = type,
      title = switch(
        type,
        load = "Facet-level load",
        person_load = "Person-level load",
        pair_coverage = "Pairwise facet coverage"
      )
    )
  ))
}

#' Plot arbitrary-facet simulation design grid tradeoffs
#'
#' @param x Output from [summarize_mfrm_sim_grid()] or an arbitrary simulation
#'   specification with a design grid.
#' @param x_var Design-grid column for the horizontal axis. Defaults to
#'   `n_Rater` when available, otherwise the first `n_*` facet-count column.
#' @param metric Grid metric to plot.
#' @param group_var Optional design-grid column used to draw separate lines or
#'   point groups, such as `n_Task`.
#' @param panel_var Optional design-grid column used to split the returned
#'   payload, and the base plot when `draw = TRUE`, into panels.
#' @param design_id Optional design rows to summarize when `x` is a
#'   specification.
#' @param draw Whether to draw a base R plot.
#' @param ... Reserved for future extensions.
#'
#' @details
#' Use this function for planning questions where one facet count changes
#' together with other facet counts. For example, set `x_var = "n_Rater"`,
#' `group_var = "n_Task"`, and `panel_var = "n_Criteria"` to inspect whether
#' adding raters increases person workload, improves pair coverage, or simply
#' creates a larger response burden under different task/criteria choices.
#'
#' @return Invisibly, an `mfrm_plot_data` object. The payload contains the full
#'   grid summary and a plotting table with `.x`, `.y`, `.group`, and `.panel`
#'   columns for custom graphics.
#' @seealso [summarize_mfrm_sim_grid()], [plot_mfrm_sim_dashboard()],
#'   [list_mfrm_sim_metrics()], [plot_mfrm_sim_design()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 20,
#'   facets = list(Rater = c(2, 4), Criteria = c(2, 3), Task = c(2, 4)),
#'   facets_per_person = list(Rater = c(1, 2), Task = 2),
#'   score_levels = 4
#' )
#' plot_mfrm_sim_grid(
#'   spec,
#'   x_var = "n_Rater",
#'   metric = "Observations",
#'   group_var = "n_Task",
#'   panel_var = "n_Criteria",
#'   draw = FALSE
#' )
#' @export
plot_mfrm_sim_grid <- function(x,
                               x_var = NULL,
                               metric = c(
                                 "Observations",
                                 "MeanObsPerPerson",
                                 "MinPairCoverage",
                                 "MeanPairCoverage",
                                 "CompletePairCoverageRate",
                                 "MinFacetPersonShare"
                               ),
                               group_var = NULL,
                               panel_var = NULL,
                               design_id = NULL,
                               draw = TRUE,
                               ...) {
  metric <- match.arg(metric)
  summary_tbl <- if (inherits(x, "mfrm_arbitrary_sim_spec")) {
    summarize_mfrm_sim_grid(x, design_id = design_id)
  } else if (inherits(x, "mfrm_sim_grid_summary") || is.data.frame(x)) {
    as.data.frame(x, stringsAsFactors = FALSE)
  } else {
    stop("`x` must be an mfrm_arbitrary_sim_spec or output from summarize_mfrm_sim_grid().", call. = FALSE)
  }
  if (nrow(summary_tbl) == 0L) stop("No design-grid rows are available for plotting.", call. = FALSE)

  if (is.null(x_var)) x_var <- mfrm_sim_grid_default_x(summary_tbl)
  x_var <- as.character(x_var[1])
  group_var <- if (is.null(group_var)) NULL else as.character(group_var[1])
  panel_var <- if (is.null(panel_var)) NULL else as.character(panel_var[1])
  mfrm_sim_grid_require_column(summary_tbl, x_var, "x_var")
  mfrm_sim_grid_require_column(summary_tbl, metric, "metric")
  if (!is.null(group_var)) mfrm_sim_grid_require_column(summary_tbl, group_var, "group_var")
  if (!is.null(panel_var)) mfrm_sim_grid_require_column(summary_tbl, panel_var, "panel_var")

  y <- suppressWarnings(as.numeric(summary_tbl[[metric]]))
  if (all(!is.finite(y))) stop("`metric` must identify a numeric grid metric.", call. = FALSE)
  x_raw <- summary_tbl[[x_var]]
  x_numeric <- suppressWarnings(as.numeric(x_raw))
  if (all(is.finite(x_numeric))) {
    x_plot <- x_numeric
    x_labels <- as.character(x_raw)
  } else {
    x_factor <- factor(as.character(x_raw), levels = unique(as.character(x_raw)))
    x_plot <- as.integer(x_factor)
    x_labels <- as.character(x_factor)
  }

  plot_tbl <- cbind(
    summary_tbl,
    data.frame(
      .x = x_plot,
      .x_label = x_labels,
      .y = y,
      .group = if (is.null(group_var)) "All designs" else as.character(summary_tbl[[group_var]]),
      .panel = if (is.null(panel_var)) "All designs" else as.character(summary_tbl[[panel_var]]),
      stringsAsFactors = FALSE
    )
  )

  if (isTRUE(draw)) {
    mfrm_sim_grid_draw(plot_tbl, x_var = x_var, metric = metric, group_var = group_var, panel_var = panel_var, ...)
  }

  invisible(new_mfrm_plot_data(
    "simulation_design_grid",
    list(
      data = plot_tbl,
      summary = summary_tbl,
      x_var = x_var,
      metric = metric,
      group_var = group_var,
      panel_var = panel_var,
      title = "Simulation design grid tradeoffs"
    )
  ))
}

#' Evaluate arbitrary-facet interaction-bias screening
#'
#' @param sim_spec Output from [build_mfrm_arbitrary_sim_spec()].
#' @param bias_targets Data frame of known interaction targets. Use either
#'   direct facet columns plus `Effect`, or columns `Target`, `FacetA`,
#'   `LevelA`, `FacetB`, `LevelB`, and `Effect`.
#' @param facet_pairs Optional list of pairwise facet vectors to evaluate.
#'   Target pairs are always included.
#' @param design_id Design rows to evaluate. Use `NULL` for all rows in the
#'   specification grid.
#' @param reps Replications per design.
#' @param seed Optional random seed.
#' @param alpha Screening alpha used for adjusted p values.
#' @param p_adjust Multiplicity adjustment passed to [stats::p.adjust()].
#' @param bias_abs_t Minimum absolute screening t value.
#' @param bias_p_cut Optional p-value cutoff. Defaults to `alpha`.
#' @param fit_method Estimation method passed to [fit_mfrm()].
#' @param maxit Maximum iterations passed to [fit_mfrm()].
#' @param quad_points Quadrature points passed to [fit_mfrm()] when applicable.
#' @param bias_max_iter Maximum iterations passed to [estimate_bias()].
#' @param residual_pca Whether [diagnose_mfrm()] should compute residual PCA.
#' @param fit_args Optional additional arguments passed to [fit_mfrm()]. Core
#'   arguments (`data`, `person`, `facets`, `score`) are controlled by this
#'   evaluator.
#'
#' @details
#' This helper is a simulation-based screening sensitivity check. It does not
#' convert [estimate_bias()] into a formal inferential test. The reported
#' `BiasScreenRate` is the fraction of replications in which the injected
#' target cell passed the selected adjusted-p and absolute-t screening rules.
#' `BiasScreenFalsePositiveRate` is computed from non-target cells in the same
#' pairwise bias table.
#'
#' `Effect` is added to the RSM linear predictor for rows matching the target
#' cell. Positive effects increase expected scores; negative effects decrease
#' expected scores after accounting for person and facet main effects.
#'
#' When `sim_spec` was created by [extract_mfrm_arbitrary_sim_spec()], the
#' evaluator carries forward the fitted rating range and retained `Weight`
#' column by default. Pass an explicit `fit_args$weight` value if a sensitivity
#' run should change that refitting convention.
#'
#' @return An object of class `mfrm_bias_detection` with design grid, per-target
#'   results, pair-level summaries, run-level fit summaries, fitted estimates,
#'   reliability tables, fit-statistic tables, and settings. These table
#'   components are ordinary data frames and can be saved with [utils::write.csv()]
#'   or retrieved with `as.data.frame(x, component = "estimates")`.
#' @seealso [estimate_bias()], [simulate_mfrm_arbitrary_data()],
#'   [summary.mfrm_bias_detection()], [plot.mfrm_bias_detection()]
#' @examples
#' spec <- build_mfrm_arbitrary_sim_spec(
#'   n_person = 16,
#'   facets = c(Rater = 3, Criteria = 2, Task = 3),
#'   facets_per_person = c(Rater = 2, Task = 2),
#'   score_levels = 4
#' )
#' targets <- data.frame(Rater = "Rater03", Task = "Task03", Effect = -0.7)
#' # Repeated simulations estimate how often this injected interaction is
#' # recovered by the bias-screening workflow.
#' eval <- evaluate_mfrm_bias_detection(
#'   spec,
#'   bias_targets = targets,
#'   reps = 1,
#'   seed = 1,
#'   maxit = 20,
#'   bias_max_iter = 1
#' )
#' summary(eval)
#' @export
evaluate_mfrm_bias_detection <- function(sim_spec,
                                         bias_targets,
                                         facet_pairs = NULL,
                                         design_id = 1,
                                         reps = 20,
                                         seed = NULL,
                                         alpha = 0.05,
                                         p_adjust = "holm",
                                         bias_abs_t = 2,
                                         bias_p_cut = alpha,
                                         fit_method = c("MML", "JML", "JMLE"),
                                         maxit = 100,
                                         quad_points = 21,
                                         bias_max_iter = 2,
                                         residual_pca = c("none", "overall", "facet", "both"),
                                         fit_args = list()) {
  if (!inherits(sim_spec, "mfrm_arbitrary_sim_spec")) {
    stop("`sim_spec` must be output from build_mfrm_arbitrary_sim_spec().", call. = FALSE)
  }
  reps <- as.integer(reps[1])
  if (!is.finite(reps) || reps < 1L) stop("`reps` must be a positive integer.", call. = FALSE)
  alpha <- as.numeric(alpha[1])
  bias_p_cut <- as.numeric(bias_p_cut[1])
  bias_abs_t <- as.numeric(bias_abs_t[1])
  if (!is.finite(alpha) || alpha < 0 || alpha > 1) stop("`alpha` must be in [0, 1].", call. = FALSE)
  if (!is.finite(bias_p_cut) || bias_p_cut < 0 || bias_p_cut > 1) {
    stop("`bias_p_cut` must be in [0, 1].", call. = FALSE)
  }
  if (!is.finite(bias_abs_t) || bias_abs_t < 0) stop("`bias_abs_t` must be non-negative.", call. = FALSE)
  fit_method <- match.arg(fit_method)
  residual_pca <- if (is.logical(residual_pca)) {
    if (isTRUE(residual_pca[1])) "overall" else "none"
  } else {
    match.arg(tolower(as.character(residual_pca[1])), c("none", "overall", "facet", "both"))
  }
  design_rows <- mfrm_arbitrary_select_design_rows(sim_spec, design_id = design_id)

  targets <- mfrm_arbitrary_prepare_bias_targets(
    bias_targets = bias_targets,
    facet_names = sim_spec$facet_names,
    facet_pairs = facet_pairs
  )
  effect_table <- mfrm_arbitrary_bias_effect_table(targets, sim_spec$facet_names)
  pair_tbl <- mfrm_arbitrary_bias_pair_table(targets, facet_pairs, facet_names = sim_spec$facet_names)

  n_runs <- nrow(design_rows) * reps
  seeds <- with_preserved_rng_seed(seed, {
    sample.int(.Machine$integer.max, size = n_runs, replace = FALSE)
  })

  result_rows <- list()
  pair_rows <- list()
  rep_rows <- list()
  estimate_rows <- list()
  reliability_rows <- list()
  fit_stat_rows <- list()
  result_idx <- 0L
  pair_idx <- 0L
  rep_idx <- 0L
  estimate_idx <- 0L
  reliability_idx <- 0L
  fit_stat_idx <- 0L
  seed_idx <- 0L

  for (design_pos in seq_len(nrow(design_rows))) {
    design_row <- design_rows[design_pos, , drop = FALSE]
    for (rep in seq_len(reps)) {
      seed_idx <- seed_idx + 1L
      t0 <- proc.time()[["elapsed"]]
      sim <- tryCatch(
        simulate_mfrm_arbitrary_data(
          sim_spec,
          design = design_row,
          seed = seeds[seed_idx],
          interaction_effects = effect_table
        ),
        error = function(e) e
      )
      fit <- if (inherits(sim, "error")) sim else {
        args <- fit_args
        args[c("data", "person", "facets", "score")] <- NULL
        if (is.null(args$rating_min) && !is.null(sim_spec$rating_min)) {
          args$rating_min <- as.integer(sim_spec$rating_min)
        }
        if (is.null(args$rating_max) && !is.null(sim_spec$rating_max)) {
          args$rating_max <- as.integer(sim_spec$rating_max)
        }
        if (is.null(args$weight) && identical(as.character(sim_spec$weight_col %||% ""), "Weight") &&
            "Weight" %in% names(sim)) {
          args$weight <- "Weight"
        }
        args <- utils::modifyList(
          list(
            data = sim,
            person = "Person",
            facets = sim_spec$facet_names,
            score = "Score",
            model = "RSM",
            method = fit_method,
            maxit = maxit,
            quad_points = quad_points
          ),
          args
        )
        tryCatch(do.call(fit_mfrm, args), error = function(e) e)
      }
      diag <- if (inherits(fit, "error")) fit else {
        tryCatch(diagnose_mfrm(fit, residual_pca = residual_pca), error = function(e) e)
      }
      converged <- !inherits(fit, "error") && isTRUE(as.logical(fit$summary$Converged[1]))
      elapsed <- proc.time()[["elapsed"]] - t0
      rep_errors <- character(0)
      if (inherits(sim, "error")) rep_errors <- c(rep_errors, conditionMessage(sim))
      if (inherits(fit, "error")) rep_errors <- c(rep_errors, conditionMessage(fit))
      if (inherits(diag, "error")) rep_errors <- c(rep_errors, conditionMessage(diag))

      if (!inherits(diag, "error")) {
        measures_tbl <- mfrm_arbitrary_annotate_sim_table(diag$measures, design_row, rep)
        if (nrow(measures_tbl) > 0L) {
          estimate_idx <- estimate_idx + 1L
          estimate_rows[[estimate_idx]] <- measures_tbl
        }
        reliability_tbl <- mfrm_arbitrary_annotate_sim_table(diag$reliability, design_row, rep)
        if (nrow(reliability_tbl) > 0L) {
          reliability_idx <- reliability_idx + 1L
          reliability_rows[[reliability_idx]] <- reliability_tbl
        }
        fit_tbl <- mfrm_arbitrary_annotate_sim_table(diag$fit, design_row, rep)
        if (nrow(fit_tbl) > 0L) {
          fit_stat_idx <- fit_stat_idx + 1L
          fit_stat_rows[[fit_stat_idx]] <- fit_tbl
        }
      }

      rep_idx <- rep_idx + 1L
      rep_rows[[rep_idx]] <- mfrm_arbitrary_with_design_row(
        design_row,
        data.frame(
          rep = rep,
          Observations = if (inherits(sim, "error")) NA_integer_ else nrow(sim),
          ElapsedSec = elapsed,
          RunOK = length(rep_errors) == 0L,
          Converged = converged,
          Error = if (length(rep_errors) == 0L) NA_character_ else paste(unique(rep_errors), collapse = " | "),
          stringsAsFactors = FALSE
        )
      )

      pair_cache <- list()
      for (pair_i in seq_len(nrow(pair_tbl))) {
        pair <- c(as.character(pair_tbl$FacetA[pair_i]), as.character(pair_tbl$FacetB[pair_i]))
        key <- paste(pair, collapse = "||")
        bias_obj <- if (inherits(diag, "error")) diag else {
          tryCatch(
            estimate_bias(fit, diag, facet_a = pair[1], facet_b = pair[2], max_iter = bias_max_iter),
            error = function(e) e
          )
        }
        bias_tbl <- if (inherits(bias_obj, "error") || is.null(bias_obj$table)) {
          data.frame()
        } else {
          tibble::as_tibble(bias_obj$table)
        }
        if (nrow(bias_tbl) > 0L && "Prob." %in% names(bias_tbl)) {
          bias_tbl$PAdjusted <- stats::p.adjust(suppressWarnings(as.numeric(bias_tbl$`Prob.`)), method = p_adjust)
          bias_tbl$ScreenPositive <- is.finite(bias_tbl$PAdjusted) & bias_tbl$PAdjusted <= bias_p_cut &
            is.finite(suppressWarnings(as.numeric(bias_tbl$t))) &
            abs(suppressWarnings(as.numeric(bias_tbl$t))) >= bias_abs_t
        } else {
          bias_tbl$PAdjusted <- numeric(0)
          bias_tbl$ScreenPositive <- logical(0)
        }
        target_mask <- mfrm_arbitrary_pair_target_mask(bias_tbl, targets, pair)
        non_target <- if (nrow(bias_tbl) > 0L) bias_tbl[!target_mask, , drop = FALSE] else bias_tbl
        fp_rate <- if (nrow(non_target) > 0L) mean(non_target$ScreenPositive %in% TRUE) else NA_real_
        pair_cache[[key]] <- list(
          pair = pair,
          object = bias_obj,
          table = bias_tbl,
          fp_rate = fp_rate
        )
        pair_idx <- pair_idx + 1L
        pair_rows[[pair_idx]] <- mfrm_arbitrary_with_design_row(
          design_row,
          data.frame(
            rep = rep,
            FacetA = pair[1],
            FacetB = pair[2],
            TableRows = nrow(bias_tbl),
            ScreenPositiveN = sum(bias_tbl$ScreenPositive %in% TRUE),
            ScreenPositiveRate = if (nrow(bias_tbl) > 0L) mean(bias_tbl$ScreenPositive %in% TRUE) else NA_real_,
            NonTargetScreenPositiveRate = fp_rate,
            Error = if (inherits(bias_obj, "error")) conditionMessage(bias_obj) else NA_character_,
            stringsAsFactors = FALSE
          )
        )
      }

      for (target_i in seq_len(nrow(targets))) {
        target <- targets[target_i, , drop = FALSE]
        pair <- c(as.character(target$FacetA[1]), as.character(target$FacetB[1]))
        key <- paste(pair, collapse = "||")
        cache <- pair_cache[[key]]
        target_row <- if (!is.null(cache)) {
          mfrm_arbitrary_find_target_bias_row(cache$table, target)
        } else {
          data.frame()
        }
        target_p <- if (nrow(target_row) > 0L) suppressWarnings(as.numeric(target_row$`Prob.`[1])) else NA_real_
        target_p_adj <- if (nrow(target_row) > 0L) suppressWarnings(as.numeric(target_row$PAdjusted[1])) else NA_real_
        target_t <- if (nrow(target_row) > 0L) suppressWarnings(as.numeric(target_row$t[1])) else NA_real_
        target_size <- if (nrow(target_row) > 0L) suppressWarnings(as.numeric(target_row$`Bias Size`[1])) else NA_real_
        metric_available <- is.finite(target_p) && is.finite(target_t)
        detected <- is.finite(target_p_adj) && target_p_adj <= bias_p_cut &&
          is.finite(target_t) && abs(target_t) >= bias_abs_t

        result_idx <- result_idx + 1L
        result_rows[[result_idx]] <- mfrm_arbitrary_with_design_row(
          design_row,
          data.frame(
            rep = rep,
            Target = as.character(target$Target[1]),
            FacetA = pair[1],
            LevelA = as.character(target$LevelA[1]),
            FacetB = pair[2],
            LevelB = as.character(target$LevelB[1]),
            FacetPair = paste(pair, collapse = " x "),
            TrueEffect = as.numeric(target$Effect[1]),
            Observations = if (inherits(sim, "error")) NA_integer_ else nrow(sim),
            ElapsedSec = elapsed,
            Converged = converged,
            BiasSize = target_size,
            BiasP = target_p,
            BiasPAdjusted = target_p_adj,
            BiasT = target_t,
            BiasScreenMetricAvailable = metric_available,
            BiasDetected = detected,
            BiasScreenFalsePositiveRate = if (!is.null(cache)) cache$fp_rate else NA_real_,
            RunOK = length(rep_errors) == 0L && !is.null(cache) && !inherits(cache$object, "error"),
            Error = if (length(rep_errors) == 0L) {
              if (!is.null(cache) && inherits(cache$object, "error")) conditionMessage(cache$object) else NA_character_
            } else {
              paste(unique(rep_errors), collapse = " | ")
            },
            stringsAsFactors = FALSE
          )
        )
      }
    }
  }

  results <- tibble::as_tibble(dplyr::bind_rows(result_rows))
  pair_results <- tibble::as_tibble(dplyr::bind_rows(pair_rows))
  rep_overview <- tibble::as_tibble(dplyr::bind_rows(rep_rows))
  estimates <- tibble::as_tibble(dplyr::bind_rows(estimate_rows))
  reliability <- tibble::as_tibble(dplyr::bind_rows(reliability_rows))
  fit_statistics <- tibble::as_tibble(dplyr::bind_rows(fit_stat_rows))
  target_summary <- mfrm_arbitrary_bias_target_summary(results)
  pair_summary <- mfrm_arbitrary_bias_pair_summary(pair_results)
  fit_summary <- mfrm_arbitrary_fit_summary(reliability)

  out <- list(
    design_grid = sim_spec$design_grid,
    results = results,
    pair_results = pair_results,
    rep_overview = rep_overview,
    estimates = estimates,
    reliability = reliability,
    fit_statistics = fit_statistics,
    target_summary = target_summary,
    pair_summary = pair_summary,
    fit_summary = fit_summary,
    targets = targets,
    settings = list(
      reps = reps,
      alpha = alpha,
      p_adjust = p_adjust,
      bias_abs_t = bias_abs_t,
      bias_p_cut = bias_p_cut,
      fit_method = fit_method,
      maxit = maxit,
      quad_points = quad_points,
      bias_max_iter = bias_max_iter,
      residual_pca = residual_pca,
      seed = seed,
      model = "RSM",
      inference_note = "estimate_bias_screening_not_formal_power"
    ),
    sim_spec = sim_spec
  )
  class(out) <- c("mfrm_bias_detection", "list")
  out
}

#' @export
summary.mfrm_bias_detection <- function(object, ...) {
  if (!inherits(object, "mfrm_bias_detection")) {
    stop("`object` must be output from evaluate_mfrm_bias_detection().", call. = FALSE)
  }
  out <- list(
    target_summary = object$target_summary,
    pair_summary = object$pair_summary,
    fit_summary = object$fit_summary,
    settings = object$settings
  )
  class(out) <- c("summary.mfrm_bias_detection", "list")
  out
}

#' @export
plot.mfrm_bias_detection <- function(x,
                                     metric = c("screen_rate", "false_positive", "estimate", "reliability", "separation"),
                                     facet = NULL,
                                     draw = TRUE,
                                     ...) {
  if (!inherits(x, "mfrm_bias_detection")) {
    stop("`x` must be output from evaluate_mfrm_bias_detection().", call. = FALSE)
  }
  metric <- match.arg(metric)
  if (metric %in% c("reliability", "separation")) {
    summary_tbl <- tibble::as_tibble(x$fit_summary)
    if (nrow(summary_tbl) == 0L) {
      stop("No fitted reliability summary is available for plotting.", call. = FALSE)
    }
    if (!is.null(facet)) {
      facet <- as.character(facet[1])
      summary_tbl <- summary_tbl[as.character(summary_tbl$Facet) == facet, , drop = FALSE]
      if (nrow(summary_tbl) == 0L) stop("No rows are available for `facet = \"", facet, "\"`.", call. = FALSE)
    }
    value_col <- if (identical(metric, "reliability")) "MeanReliability" else "MeanSeparation"
    plot_tbl <- data.frame(
      design_id = as.integer(summary_tbl$design_id),
      Facet = as.character(summary_tbl$Facet),
      Metric = metric,
      Value = suppressWarnings(as.numeric(summary_tbl[[value_col]])),
      stringsAsFactors = FALSE
    )
  } else {
    summary_tbl <- tibble::as_tibble(x$target_summary)
    value_col <- switch(
      metric,
      screen_rate = "BiasScreenRate",
      false_positive = "MeanBiasScreenFalsePositiveRate",
      estimate = "MeanTargetBias"
    )
    plot_tbl <- data.frame(
      Target = as.character(summary_tbl$Target),
      FacetPair = as.character(summary_tbl$FacetPair),
      Metric = metric,
      Value = suppressWarnings(as.numeric(summary_tbl[[value_col]])),
      stringsAsFactors = FALSE
    )
  }
  if (isTRUE(draw)) {
    labels <- if (metric %in% c("reliability", "separation")) {
      paste0("D", plot_tbl$design_id, "\n", plot_tbl$Facet)
    } else {
      paste(plot_tbl$Target, plot_tbl$FacetPair, sep = "\n")
    }
    ylim <- if (metric %in% c("screen_rate", "false_positive")) c(0, 1) else NULL
    graphics::barplot(
      stats::setNames(plot_tbl$Value, labels),
      las = 2,
      ylim = ylim,
      ylab = value_col,
      main = "Bias screening sensitivity"
    )
  }
  invisible(new_mfrm_plot_data(
    "bias_detection",
    list(
      data = plot_tbl,
      summary = summary_tbl,
      metric = metric,
      facet = facet,
      settings = x$settings,
      title = "Bias screening sensitivity"
    )
  ))
}

#' @export
print.mfrm_arbitrary_sim_spec <- function(x, ...) {
  cat("Arbitrary-facet MFRM simulation specification\n")
  cat("  Model:", x$model, "\n")
  cat("  Persons:", paste(x$n_person, collapse = ", "), "\n")
  cat("  Facets:", paste(x$facet_names, collapse = ", "), "\n")
  cat("  Design rows:", nrow(x$design_grid), "\n")
  invisible(x)
}

#' @export
print.mfrm_sim_design_summary <- function(x, ...) {
  cat("Arbitrary-facet simulation design summary\n")
  print(x$overview, row.names = FALSE)
  if (nrow(x$assignment) > 0L) {
    cat("\nAssignment by person\n")
    print(x$assignment, row.names = FALSE)
  }
  invisible(x)
}

#' @export
print.mfrm_sim_grid_summary <- function(x, n = 10, ...) {
  cat("Arbitrary-facet simulation design grid summary\n")
  cat("  Design rows:", nrow(x), "\n")
  show_cols <- intersect(
    c(
      "design_id", grep("^n_", names(x), value = TRUE),
      grep("_per_person$", names(x), value = TRUE),
      "Observations", "MeanObsPerPerson", "MinPairCoverage",
      "MeanPairCoverage", "CompletePairCoverageRate"
    ),
    names(x)
  )
  print(utils::head(as.data.frame(x[, show_cols, drop = FALSE]), n = n), row.names = FALSE)
  invisible(x)
}

#' @export
print.mfrm_bias_detection <- function(x, ...) {
  cat("Arbitrary-facet bias screening evaluation\n")
  cat("  Targets:", nrow(x$targets), "\n")
  cat("  Replications:", x$settings$reps, "\n")
  cat("  Inference:", x$settings$inference_note, "\n")
  if (nrow(x$target_summary) > 0L) {
    print(x$target_summary, row.names = FALSE)
  }
  invisible(x)
}

#' @export
print.summary.mfrm_bias_detection <- function(x, ...) {
  cat("Summary of arbitrary-facet bias screening evaluation\n")
  if (nrow(x$target_summary) > 0L) {
    print(x$target_summary, row.names = FALSE)
  }
  if (nrow(x$pair_summary) > 0L) {
    cat("\nPairwise bias-table screening\n")
    print(x$pair_summary, row.names = FALSE)
  }
  invisible(x)
}

mfrm_arbitrary_fit_skeleton <- function(fit, data = NULL, group = NULL, include_weights = TRUE) {
  prep_data <- fit$prep$data
  if (!is.data.frame(prep_data) || nrow(prep_data) == 0L) {
    stop("`fit` does not contain a retained analysis skeleton in `fit$prep$data`.", call. = FALSE)
  }
  facet_names <- as.character(fit$config$facet_names %||% fit$prep$facet_names %||% character(0))
  keep <- c("Person", facet_names)
  missing <- setdiff(keep, names(prep_data))
  if (length(missing) > 0L) {
    stop("The fitted analysis skeleton is missing required columns: ", paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  skeleton <- as.data.frame(prep_data[, keep, drop = FALSE], stringsAsFactors = FALSE)
  for (nm in keep) skeleton[[nm]] <- as.character(skeleton[[nm]])
  if (isTRUE(include_weights) && "Weight" %in% names(prep_data)) {
    skeleton$Weight <- suppressWarnings(as.numeric(prep_data$Weight))
  }

  if (!is.null(group)) {
    if (is.null(data) || !is.data.frame(data)) {
      stop("`data` must be supplied when `group` is requested.", call. = FALSE)
    }
    group <- as.character(group[1])
    if (!nzchar(group) || !group %in% names(data)) {
      stop("`group` must name a column in `data`.", call. = FALSE)
    }
    source_cols <- fit$config$source_columns %||% list()
    person_col <- as.character(source_cols$person %||% "Person")
    if (!person_col %in% names(data) && "Person" %in% names(data)) {
      person_col <- "Person"
    }
    if (!person_col %in% names(data)) {
      stop("Could not identify the fitted person column in `data`.", call. = FALSE)
    }
    group_tbl <- unique(data.frame(
      Person = as.character(data[[person_col]]),
      Group = as.character(data[[group]]),
      stringsAsFactors = FALSE
    ))
    group_tbl <- group_tbl[!is.na(group_tbl$Person) & nzchar(group_tbl$Person) &
                             !is.na(group_tbl$Group) & nzchar(group_tbl$Group), , drop = FALSE]
    per_person_n <- stats::aggregate(
      x = list(GroupN = group_tbl$Group),
      by = list(Person = group_tbl$Person),
      FUN = function(x) length(unique(x))
    )
    if (any(per_person_n$GroupN > 1L)) {
      stop("`group` must be person-level: at least one person has multiple group labels.", call. = FALSE)
    }
    group_map <- stats::setNames(group_tbl$Group, group_tbl$Person)
    skeleton$Group <- unname(group_map[skeleton$Person])
  }
  tibble::as_tibble(skeleton)
}

mfrm_arbitrary_fit_parameters <- function(fit, facet_names) {
  person_df <- as.data.frame(fit$facets$person %||% data.frame(), stringsAsFactors = FALSE)
  if (!all(c("Person", "Estimate") %in% names(person_df))) {
    stop("`fit$facets$person` must contain `Person` and `Estimate` columns.", call. = FALSE)
  }
  person <- suppressWarnings(as.numeric(person_df$Estimate))
  names(person) <- as.character(person_df$Person)
  person <- mfrm_arbitrary_clean_parameter_vector(person, "person")

  others <- as.data.frame(fit$facets$others %||% data.frame(), stringsAsFactors = FALSE)
  if (!all(c("Facet", "Level", "Estimate") %in% names(others))) {
    stop("`fit$facets$others` must contain `Facet`, `Level`, and `Estimate` columns.", call. = FALSE)
  }
  facets <- stats::setNames(vector("list", length(facet_names)), facet_names)
  for (facet in facet_names) {
    rows <- others[as.character(others$Facet) == facet, , drop = FALSE]
    values <- suppressWarnings(as.numeric(rows$Estimate))
    names(values) <- as.character(rows$Level)
    levels <- as.character(fit$prep$levels[[facet]] %||% names(values))
    aligned <- stats::setNames(rep(NA_real_, length(levels)), levels)
    aligned[names(values)] <- values
    facets[[facet]] <- mfrm_arbitrary_clean_parameter_vector(aligned, facet)
  }

  steps <- as.data.frame(fit$steps %||% data.frame(), stringsAsFactors = FALSE)
  if (!"Estimate" %in% names(steps)) {
    stop("`fit$steps` must contain an `Estimate` column for RSM extraction.", call. = FALSE)
  }
  thresholds <- suppressWarnings(as.numeric(steps$Estimate))
  expected_steps <- as.integer(fit$prep$rating_max - fit$prep$rating_min)
  if (length(thresholds) != expected_steps || any(!is.finite(thresholds))) {
    stop("Could not extract a finite common RSM threshold vector from `fit`.", call. = FALSE)
  }

  list(
    person = person,
    facets = facets,
    thresholds = thresholds,
    step_table = steps,
    rating_min = as.integer(fit$prep$rating_min),
    rating_max = as.integer(fit$prep$rating_max)
  )
}

mfrm_arbitrary_clean_parameter_vector <- function(x, label) {
  x <- suppressWarnings(as.numeric(x))
  nm <- names(x)
  finite <- is.finite(x)
  replacement <- if (any(finite)) mean(x[finite]) else 0
  x[!finite] <- replacement
  names(x) <- nm
  x
}

mfrm_arbitrary_empirical_facets_per_person <- function(skeleton, facet_names) {
  out <- integer(length(facet_names))
  names(out) <- facet_names
  for (facet in facet_names) {
    per_person <- stats::aggregate(
      x = list(Levels = as.character(skeleton[[facet]])),
      by = list(Person = as.character(skeleton$Person)),
      FUN = function(x) length(unique(x))
    )
    out[[facet]] <- max(1L, as.integer(stats::median(per_person$Levels)))
  }
  out
}

mfrm_arbitrary_empirical_facet_sd <- function(facets, facet_names) {
  out <- numeric(length(facet_names))
  names(out) <- facet_names
  for (facet in facet_names) {
    out[[facet]] <- mfrm_arbitrary_sd(facets[[facet]])
  }
  out
}

mfrm_arbitrary_sd <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x <- x[is.finite(x)]
  if (length(x) <= 1L) return(0)
  stats::sd(x)
}

mfrm_arbitrary_sim_person_values <- function(sim_spec, person_ids) {
  params <- sim_spec$empirical_parameters %||% NULL
  source <- as.character(sim_spec$parameter_source %||% "generated")
  if (is.list(params) && !is.null(params$person)) {
    return(mfrm_arbitrary_sim_parameter_values(
      support = params$person,
      target_levels = person_ids,
      source = source,
      fallback_sd = sim_spec$theta_sd
    ))
  }
  stats::rnorm(length(person_ids), mean = 0, sd = sim_spec$theta_sd)
}

mfrm_arbitrary_sim_facet_values <- function(sim_spec, facet_names, level_map) {
  params <- sim_spec$empirical_parameters %||% NULL
  source <- as.character(sim_spec$parameter_source %||% "generated")
  out <- stats::setNames(vector("list", length(facet_names)), facet_names)
  for (facet in facet_names) {
    support <- if (is.list(params) && is.list(params$facets)) params$facets[[facet]] else NULL
    out[[facet]] <- if (!is.null(support)) {
      mfrm_arbitrary_sim_parameter_values(
        support = support,
        target_levels = level_map[[facet]],
        source = source,
        fallback_sd = sim_spec$facet_sd[[facet]]
      )
    } else {
      effects <- sort(stats::rnorm(length(level_map[[facet]]), mean = 0, sd = sim_spec$facet_sd[[facet]]))
      names(effects) <- level_map[[facet]]
      effects
    }
  }
  out
}

mfrm_arbitrary_sim_parameter_values <- function(support,
                                               target_levels,
                                               source = c("generated", "estimates", "resampled"),
                                               fallback_sd = 0) {
  source <- match.arg(source, c("generated", "estimates", "resampled"))
  target_levels <- as.character(target_levels)
  support <- mfrm_arbitrary_clean_parameter_vector(support, "support")
  if (identical(source, "estimates") && all(target_levels %in% names(support))) {
    out <- unname(support[target_levels])
    names(out) <- target_levels
    return(out)
  }
  finite_support <- support[is.finite(support)]
  if (identical(source, "resampled") || length(finite_support) > 0L) {
    out <- sample(as.numeric(finite_support), size = length(target_levels), replace = TRUE)
    names(out) <- target_levels
    return(out)
  }
  out <- stats::rnorm(length(target_levels), mean = 0, sd = as.numeric(fallback_sd %||% 0))
  names(out) <- target_levels
  out
}

mfrm_arbitrary_int_choices <- function(x, arg_name, min_value = 1L) {
  vals <- suppressWarnings(as.integer(x))
  if (length(vals) == 0L || any(!is.finite(vals)) || any(vals < min_value)) {
    stop("`", arg_name, "` must contain integer values >= ", min_value, ".", call. = FALSE)
  }
  unique(vals)
}

mfrm_arbitrary_named_int_choices <- function(x, arg_name, min_value = 1L) {
  if (is.list(x)) {
    out <- lapply(names(x), function(nm) mfrm_arbitrary_int_choices(x[[nm]], paste0(arg_name, "$", nm), min_value))
    names(out) <- names(x)
  } else {
    if (is.null(names(x)) || any(!nzchar(names(x)))) {
      stop("`", arg_name, "` must be named.", call. = FALSE)
    }
    out <- lapply(seq_along(x), function(i) mfrm_arbitrary_int_choices(x[[i]], paste0(arg_name, "[", i, "]"), min_value))
    names(out) <- names(x)
  }
  if (length(out) == 0L || is.null(names(out)) || any(!nzchar(names(out)))) {
    stop("`", arg_name, "` must contain named entries.", call. = FALSE)
  }
  if (anyDuplicated(names(out))) {
    stop("`", arg_name, "` names must be unique.", call. = FALSE)
  }
  out
}

mfrm_arbitrary_assignment_choices <- function(x, facet_names) {
  if (is.null(x)) return(stats::setNames(list(), character(0)))
  out <- mfrm_arbitrary_named_int_choices(x, "facets_per_person", min_value = 1L)
  unknown <- setdiff(names(out), facet_names)
  if (length(unknown) > 0L) {
    stop("`facets_per_person` includes unknown facets: ", paste(unknown, collapse = ", "), ".", call. = FALSE)
  }
  out
}

mfrm_arbitrary_validate_facet_names <- function(facet_names) {
  reserved <- c("Study", "Person", "Score", "Group", "Weight", "Effect", "Target",
                "FacetA", "FacetB", "LevelA", "LevelB")
  if (any(facet_names %in% reserved)) {
    stop("Facet names cannot use reserved columns: ", paste(intersect(facet_names, reserved), collapse = ", "), ".", call. = FALSE)
  }
  if (anyDuplicated(facet_names)) stop("Facet names must be unique.", call. = FALSE)
  if (length(facet_names) < 1L) stop("At least one non-person facet is required.", call. = FALSE)
  invisible(facet_names)
}

mfrm_arbitrary_facet_sd <- function(facet_sd, facet_names) {
  if (is.null(facet_sd)) {
    out <- rep(0.25, length(facet_names))
    names(out) <- facet_names
    return(as.list(out))
  }
  vals <- suppressWarnings(as.numeric(facet_sd))
  if (length(vals) == 1L && (is.null(names(facet_sd)) || !nzchar(names(facet_sd)[1]))) {
    out <- rep(vals, length(facet_names))
    names(out) <- facet_names
  } else {
    if (is.null(names(facet_sd))) stop("`facet_sd` must be named or length 1.", call. = FALSE)
    missing <- setdiff(facet_names, names(facet_sd))
    if (length(missing) > 0L) stop("`facet_sd` is missing: ", paste(missing, collapse = ", "), ".", call. = FALSE)
    out <- vals[match(facet_names, names(facet_sd))]
    names(out) <- facet_names
  }
  if (any(!is.finite(out)) || any(out < 0)) stop("`facet_sd` values must be non-negative.", call. = FALSE)
  as.list(out)
}

mfrm_arbitrary_thresholds <- function(thresholds, score_levels, step_span) {
  if (is.null(thresholds)) {
    return(seq(-step_span / 2, step_span / 2, length.out = score_levels - 1L))
  }
  out <- suppressWarnings(as.numeric(thresholds))
  if (length(out) != score_levels - 1L || any(!is.finite(out))) {
    stop("`thresholds` must have `score_levels - 1` finite numeric values.", call. = FALSE)
  }
  out
}

mfrm_arbitrary_group_levels <- function(group_levels) {
  if (is.null(group_levels)) return(NULL)
  out <- unique(as.character(group_levels))
  out <- out[!is.na(out) & nzchar(out)]
  if (length(out) == 0L) stop("`group_levels` must contain at least one non-empty label.", call. = FALSE)
  out
}

mfrm_arbitrary_design_grid <- function(spec) {
  choices <- c(list(n_person = spec$n_person), spec$facets)
  if (length(spec$facets_per_person) > 0L) {
    assignment_choices <- stats::setNames(
      spec$facets_per_person,
      paste0(names(spec$facets_per_person), "_per_person")
    )
    choices <- c(choices, assignment_choices)
  }
  grid <- expand.grid(choices, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  for (facet in spec$facet_names) {
    names(grid)[names(grid) == facet] <- paste0("n_", facet)
  }
  if (length(spec$facets_per_person) > 0L) {
    keep <- rep(TRUE, nrow(grid))
    for (facet in names(spec$facets_per_person)) {
      keep <- keep & as.integer(grid[[paste0(facet, "_per_person")]]) <= as.integer(grid[[paste0("n_", facet)]])
    }
    grid <- grid[keep, , drop = FALSE]
  }
  if (nrow(grid) == 0L) {
    stop("No valid design rows remain after applying `facets_per_person` constraints.", call. = FALSE)
  }
  grid$design_id <- seq_len(nrow(grid))
  grid <- grid[, c("design_id", setdiff(names(grid), "design_id")), drop = FALSE]
  tibble::as_tibble(grid)
}

mfrm_arbitrary_select_design_rows <- function(spec, design_id = 1) {
  grid <- as.data.frame(spec$design_grid, stringsAsFactors = FALSE)
  if (is.null(design_id)) return(grid)
  design_id <- as.integer(design_id)
  out <- grid[grid$design_id %in% design_id, , drop = FALSE]
  if (nrow(out) == 0L) stop("`design_id` did not match any row in `sim_spec$design_grid`.", call. = FALSE)
  out
}

mfrm_arbitrary_select_single_design <- function(spec, design_id = 1, design = NULL) {
  if (!is.null(design)) {
    row <- as.data.frame(design, stringsAsFactors = FALSE)
    if (nrow(row) != 1L) stop("`design` must contain exactly one row.", call. = FALSE)
    required <- setdiff(names(spec$design_grid), "design_id")
    missing <- setdiff(required, names(row))
    if (length(missing) > 0L) {
      stop("`design` is missing required columns: ", paste(missing, collapse = ", "), ".", call. = FALSE)
    }
    if (!"design_id" %in% names(row)) row$design_id <- NA_integer_
    return(row[, names(spec$design_grid), drop = FALSE])
  }
  rows <- mfrm_arbitrary_select_design_rows(spec, design_id = design_id)
  if (nrow(rows) != 1L) stop("Select exactly one `design_id` for data generation.", call. = FALSE)
  rows
}

mfrm_arbitrary_design_counts <- function(spec, design_row) {
  out <- stats::setNames(integer(length(spec$facet_names)), spec$facet_names)
  for (facet in spec$facet_names) {
    out[[facet]] <- as.integer(design_row[[paste0("n_", facet)]][1])
  }
  out
}

mfrm_arbitrary_design_assignments <- function(spec, design_row, facet_counts) {
  out <- stats::setNames(list(), character(0))
  for (facet in names(spec$facets_per_person)) {
    value <- as.integer(design_row[[paste0(facet, "_per_person")]][1])
    if (value > facet_counts[[facet]]) {
      stop("Assignment count for `", facet, "` cannot exceed its level count.", call. = FALSE)
    }
    out[[facet]] <- value
  }
  out
}

mfrm_arbitrary_level_labels <- function(facet, n) {
  prefix <- gsub("[^A-Za-z0-9]+", "", as.character(facet))
  if (!nzchar(prefix)) prefix <- "Facet"
  paste0(prefix, sprintf("%02d", seq_len(as.integer(n))))
}

mfrm_arbitrary_rotating_subset <- function(levels, person_index, k) {
  if (is.null(k) || k >= length(levels)) return(levels)
  levels[((person_index - 1L) + seq_len(k) - 1L) %% length(levels) + 1L]
}

mfrm_arbitrary_build_skeleton <- function(person_ids, level_map, assignment_counts) {
  facet_names <- names(level_map)
  rows <- vector("list", length(person_ids))
  for (i in seq_along(person_ids)) {
    selected <- lapply(facet_names, function(facet) {
      k <- assignment_counts[[facet]]
      mfrm_arbitrary_rotating_subset(level_map[[facet]], person_index = i, k = k)
    })
    names(selected) <- facet_names
    rows[[i]] <- expand.grid(
      c(list(Person = person_ids[i]), selected),
      KEEP.OUT.ATTRS = FALSE,
      stringsAsFactors = FALSE
    )
  }
  tibble::as_tibble(dplyr::bind_rows(rows))
}

mfrm_arbitrary_facet_load <- function(dat, facet_names) {
  persons_n <- length(unique(as.character(dat$Person)))
  rows <- lapply(facet_names, function(facet) {
    levels <- sort(unique(as.character(dat[[facet]])))
    do.call(rbind, lapply(levels, function(level) {
      mask <- as.character(dat[[facet]]) == level
      data.frame(
        Facet = facet,
        Level = level,
        Observations = sum(mask),
        Persons = length(unique(as.character(dat$Person[mask]))),
        PersonShare = length(unique(as.character(dat$Person[mask]))) / persons_n,
        stringsAsFactors = FALSE
      )
    }))
  })
  tibble::as_tibble(dplyr::bind_rows(rows))
}

mfrm_arbitrary_person_load <- function(dat, facet_names) {
  persons <- sort(unique(as.character(dat$Person)))
  rows <- lapply(persons, function(person) {
    slice <- dat[as.character(dat$Person) == person, , drop = FALSE]
    row <- data.frame(
      Person = person,
      Observations = nrow(slice),
      stringsAsFactors = FALSE
    )
    for (facet in facet_names) {
      row[[paste0(facet, "_Levels")]] <- length(unique(as.character(slice[[facet]])))
    }
    row
  })
  tibble::as_tibble(dplyr::bind_rows(rows))
}

mfrm_arbitrary_pair_coverage <- function(dat, facet_names) {
  if (length(facet_names) < 2L) {
    return(tibble::tibble())
  }
  pairs <- utils::combn(facet_names, 2, simplify = FALSE)
  rows <- lapply(pairs, function(pair) {
    a <- pair[1]
    b <- pair[2]
    combo <- unique(data.frame(A = as.character(dat[[a]]), B = as.character(dat[[b]]), stringsAsFactors = FALSE))
    possible <- length(unique(as.character(dat[[a]]))) * length(unique(as.character(dat[[b]])))
    counts <- stats::aggregate(
      x = list(Observations = rep(1L, nrow(dat))),
      by = list(A = as.character(dat[[a]]), B = as.character(dat[[b]])),
      FUN = length
    )
    data.frame(
      FacetA = a,
      FacetB = b,
      ObservedPairs = nrow(combo),
      PossiblePairs = possible,
      CoverageRate = if (possible > 0L) nrow(combo) / possible else NA_real_,
      MinObsPerObservedPair = min(counts$Observations),
      MedianObsPerObservedPair = stats::median(counts$Observations),
      MaxObsPerObservedPair = max(counts$Observations),
      stringsAsFactors = FALSE
    )
  })
  tibble::as_tibble(dplyr::bind_rows(rows))
}

mfrm_arbitrary_with_design_row <- function(design_row, tbl) {
  tbl <- as.data.frame(tbl, stringsAsFactors = FALSE)
  if (nrow(tbl) == 0L) return(tibble::tibble())
  design_row <- as.data.frame(design_row, stringsAsFactors = FALSE)
  design_row <- design_row[rep(1L, nrow(tbl)), , drop = FALSE]
  duplicate_cols <- intersect(names(tbl), names(design_row))
  if (length(duplicate_cols) > 0L) {
    tbl <- tbl[, setdiff(names(tbl), duplicate_cols), drop = FALSE]
  }
  tibble::as_tibble(cbind(design_row, tbl))
}

mfrm_arbitrary_annotate_sim_table <- function(tbl, design_row, rep) {
  tbl <- as.data.frame(tbl %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0L) return(tibble::tibble())
  mfrm_arbitrary_with_design_row(
    design_row,
    cbind(data.frame(rep = rep, stringsAsFactors = FALSE), tbl)
  )
}

mfrm_arbitrary_fit_summary <- function(reliability) {
  reliability <- tibble::as_tibble(reliability)
  if (nrow(reliability) == 0L || !"Facet" %in% names(reliability)) {
    return(tibble::tibble())
  }
  design_cols <- intersect(
    c("design_id", "n_person", grep("^n_", names(reliability), value = TRUE),
      grep("_per_person$", names(reliability), value = TRUE)),
    names(reliability)
  )
  reliability |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(design_cols, "Facet")))) |>
    dplyr::summarize(
      Reps = dplyr::n(),
      MeanSeparation = mean(suppressWarnings(as.numeric(.data$Separation)), na.rm = TRUE),
      MeanReliability = mean(suppressWarnings(as.numeric(.data$Reliability)), na.rm = TRUE),
      MeanStrata = mean(suppressWarnings(as.numeric(.data$Strata)), na.rm = TRUE),
      MeanInfit = mean(suppressWarnings(as.numeric(.data$MeanInfit)), na.rm = TRUE),
      MeanOutfit = mean(suppressWarnings(as.numeric(.data$MeanOutfit)), na.rm = TRUE),
      .groups = "drop"
    )
}

mfrm_sim_grid_default_x <- function(summary_tbl) {
  if ("n_Rater" %in% names(summary_tbl)) return("n_Rater")
  facet_count_cols <- grep("^n_", names(summary_tbl), value = TRUE)
  if (length(facet_count_cols) > 0L) return(facet_count_cols[1])
  "design_id"
}

mfrm_sim_grid_require_column <- function(summary_tbl, col, arg_name) {
  if (!col %in% names(summary_tbl)) {
    stop(
      "`", arg_name, "` must name a column in the design-grid summary. ",
      "Available columns include: ", paste(names(summary_tbl), collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(col)
}

mfrm_sim_grid_draw <- function(plot_tbl, x_var, metric, group_var = NULL, panel_var = NULL, ...) {
  draw_tbl <- stats::aggregate(
    x = list(.y = plot_tbl$.y),
    by = list(.panel = plot_tbl$.panel, .group = plot_tbl$.group, .x = plot_tbl$.x),
    FUN = mean,
    na.rm = TRUE
  )
  draw_tbl <- draw_tbl[is.finite(draw_tbl$.x) & is.finite(draw_tbl$.y), , drop = FALSE]
  if (nrow(draw_tbl) == 0L) return(invisible(NULL))

  panels <- unique(as.character(draw_tbl$.panel))
  groups <- unique(as.character(draw_tbl$.group))
  cols <- grDevices::hcl.colors(max(3L, length(groups)), "Dark 3")[seq_along(groups)]
  names(cols) <- groups
  xlim <- range(draw_tbl$.x, finite = TRUE)
  ylim <- range(draw_tbl$.y, finite = TRUE)
  if (diff(xlim) == 0) xlim <- xlim + c(-0.5, 0.5)
  if (diff(ylim) == 0) ylim <- ylim + c(-0.5, 0.5)

  opar <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(opar), add = TRUE)
  if (length(panels) > 1L) {
    graphics::par(mfrow = grDevices::n2mfrow(length(panels)))
  }
  for (panel in panels) {
    panel_tbl <- draw_tbl[as.character(draw_tbl$.panel) == panel, , drop = FALSE]
    graphics::plot(
      NA_real_,
      NA_real_,
      xlim = xlim,
      ylim = ylim,
      xlab = x_var,
      ylab = metric,
      main = if (is.null(panel_var)) "Simulation design grid" else paste(panel_var, "=", panel),
      ...
    )
    for (group in groups) {
      group_tbl <- panel_tbl[as.character(panel_tbl$.group) == group, , drop = FALSE]
      if (nrow(group_tbl) == 0L) next
      group_tbl <- group_tbl[order(group_tbl$.x), , drop = FALSE]
      graphics::lines(group_tbl$.x, group_tbl$.y, col = cols[[group]], lwd = 2)
      graphics::points(group_tbl$.x, group_tbl$.y, col = cols[[group]], pch = 19)
    }
    if (!is.null(group_var) && length(groups) > 1L) {
      graphics::legend("topleft", legend = paste(group_var, groups, sep = "="), col = cols, lty = 1, pch = 19, bty = "n")
    }
  }
  invisible(NULL)
}

mfrm_arbitrary_assignment_summary <- function(dat, facet_names) {
  rows <- lapply(facet_names, function(facet) {
    per_person <- stats::aggregate(
      x = list(Levels = as.character(dat[[facet]])),
      by = list(Person = as.character(dat$Person)),
      FUN = function(x) length(unique(x))
    )
    data.frame(
      Facet = facet,
      MinLevelsPerPerson = min(per_person$Levels),
      MedianLevelsPerPerson = stats::median(per_person$Levels),
      MeanLevelsPerPerson = mean(per_person$Levels),
      MaxLevelsPerPerson = max(per_person$Levels),
      stringsAsFactors = FALSE
    )
  })
  tibble::as_tibble(dplyr::bind_rows(rows))
}

mfrm_arbitrary_prepare_bias_targets <- function(bias_targets, facet_names, facet_pairs = NULL) {
  if (!is.data.frame(bias_targets) || nrow(bias_targets) == 0L) {
    stop("`bias_targets` must be a non-empty data.frame.", call. = FALSE)
  }
  targets <- tibble::as_tibble(bias_targets)
  if (!"Effect" %in% names(targets)) {
    stop("`bias_targets` must include an `Effect` column.", call. = FALSE)
  }
  targets$Effect <- suppressWarnings(as.numeric(targets$Effect))
  if (any(!is.finite(targets$Effect))) {
    stop("`bias_targets$Effect` must contain finite numeric values.", call. = FALSE)
  }
  rows <- vector("list", nrow(targets))
  for (i in seq_len(nrow(targets))) {
    row <- targets[i, , drop = FALSE]
    if (all(c("FacetA", "FacetB") %in% names(row))) {
      facet_a <- as.character(row$FacetA[1])
      facet_b <- as.character(row$FacetB[1])
      level_a <- mfrm_arbitrary_target_level(row, facet_a, "LevelA")
      level_b <- mfrm_arbitrary_target_level(row, facet_b, "LevelB")
    } else {
      present <- facet_names[vapply(facet_names, function(f) {
        f %in% names(row) && !is.na(row[[f]][1]) && nzchar(as.character(row[[f]][1]))
      }, logical(1))]
      if (length(present) != 2L) {
        stop(
          "Each `bias_targets` row must identify exactly two target facets, ",
          "or provide `FacetA`, `LevelA`, `FacetB`, and `LevelB`.",
          call. = FALSE
        )
      }
      facet_a <- present[1]
      facet_b <- present[2]
      level_a <- as.character(row[[facet_a]][1])
      level_b <- as.character(row[[facet_b]][1])
    }
    if (!all(c(facet_a, facet_b) %in% facet_names)) {
      stop("`bias_targets` refers to facets outside `sim_spec`.", call. = FALSE)
    }
    target_label <- if ("Target" %in% names(row) && !is.na(row$Target[1]) && nzchar(as.character(row$Target[1]))) {
      as.character(row$Target[1])
    } else {
      paste(facet_a, level_a, facet_b, level_b, sep = ":")
    }
    rows[[i]] <- data.frame(
      Target = target_label,
      FacetA = facet_a,
      LevelA = level_a,
      FacetB = facet_b,
      LevelB = level_b,
      Effect = as.numeric(row$Effect[1]),
      stringsAsFactors = FALSE
    )
  }
  out <- tibble::as_tibble(dplyr::bind_rows(rows))
  pairs <- mfrm_arbitrary_normalize_pairs(facet_pairs, facet_names)
  if (nrow(pairs) > 0L) {
    ok <- vapply(seq_len(nrow(out)), function(i) {
      any(
        (pairs$FacetA == out$FacetA[i] & pairs$FacetB == out$FacetB[i]) |
          (pairs$FacetA == out$FacetB[i] & pairs$FacetB == out$FacetA[i])
      )
    }, logical(1))
    if (!all(ok)) {
      stop("Every target pair must be included in `facet_pairs` when `facet_pairs` is supplied.", call. = FALSE)
    }
  }
  out
}

mfrm_arbitrary_target_level <- function(row, facet, level_col) {
  if (level_col %in% names(row) && !is.na(row[[level_col]][1]) && nzchar(as.character(row[[level_col]][1]))) {
    return(as.character(row[[level_col]][1]))
  }
  if (facet %in% names(row) && !is.na(row[[facet]][1]) && nzchar(as.character(row[[facet]][1]))) {
    return(as.character(row[[facet]][1]))
  }
  stop("Could not determine target level for facet `", facet, "`.", call. = FALSE)
}

mfrm_arbitrary_normalize_pairs <- function(facet_pairs, facet_names) {
  if (is.null(facet_pairs)) return(tibble::tibble(FacetA = character(0), FacetB = character(0)))
  rows <- if (is.data.frame(facet_pairs)) {
    if (!all(c("FacetA", "FacetB") %in% names(facet_pairs))) {
      stop("`facet_pairs` data frames must include `FacetA` and `FacetB`.", call. = FALSE)
    }
    facet_pairs[, c("FacetA", "FacetB"), drop = FALSE]
  } else if (is.list(facet_pairs)) {
    dplyr::bind_rows(lapply(facet_pairs, function(pair) {
      pair <- as.character(pair)
      if (length(pair) != 2L) stop("Each `facet_pairs` entry must contain exactly two facets.", call. = FALSE)
      data.frame(FacetA = pair[1], FacetB = pair[2], stringsAsFactors = FALSE)
    }))
  } else {
    stop("`facet_pairs` must be NULL, a list of two-facet vectors, or a data.frame.", call. = FALSE)
  }
  rows <- tibble::as_tibble(rows)
  if (any(!rows$FacetA %in% facet_names) || any(!rows$FacetB %in% facet_names)) {
    stop("`facet_pairs` contains facets outside `sim_spec`.", call. = FALSE)
  }
  rows <- unique(rows)
  rows
}

mfrm_arbitrary_bias_effect_table <- function(targets, facet_names) {
  out <- as.data.frame(matrix(NA_character_, nrow = nrow(targets), ncol = length(facet_names)), stringsAsFactors = FALSE)
  names(out) <- facet_names
  for (i in seq_len(nrow(targets))) {
    out[[targets$FacetA[i]]][i] <- as.character(targets$LevelA[i])
    out[[targets$FacetB[i]]][i] <- as.character(targets$LevelB[i])
  }
  out$Effect <- as.numeric(targets$Effect)
  tibble::as_tibble(out)
}

mfrm_arbitrary_bias_pair_table <- function(targets, facet_pairs, facet_names) {
  target_pairs <- tibble::tibble(FacetA = as.character(targets$FacetA), FacetB = as.character(targets$FacetB))
  supplied <- mfrm_arbitrary_normalize_pairs(facet_pairs, facet_names)
  out <- dplyr::bind_rows(target_pairs, supplied)
  out$PairKey <- paste(out$FacetA, out$FacetB, sep = "||")
  out <- out[!duplicated(out$PairKey), c("FacetA", "FacetB"), drop = FALSE]
  tibble::as_tibble(out)
}

mfrm_arbitrary_pair_target_mask <- function(tbl, targets, pair) {
  if (nrow(tbl) == 0L) return(logical(0))
  mask <- rep(FALSE, nrow(tbl))
  pair_targets <- targets[targets$FacetA == pair[1] & targets$FacetB == pair[2], , drop = FALSE]
  if (nrow(pair_targets) == 0L) return(mask)
  for (i in seq_len(nrow(pair_targets))) {
    mask <- mask |
      as.character(tbl$FacetA_Level) == as.character(pair_targets$LevelA[i]) &
      as.character(tbl$FacetB_Level) == as.character(pair_targets$LevelB[i])
  }
  mask
}

mfrm_arbitrary_find_target_bias_row <- function(tbl, target) {
  tbl <- tibble::as_tibble(tbl)
  if (nrow(tbl) == 0L) return(tbl)
  out <- tbl[
    as.character(tbl$FacetA) == as.character(target$FacetA[1]) &
      as.character(tbl$FacetB) == as.character(target$FacetB[1]) &
      as.character(tbl$FacetA_Level) == as.character(target$LevelA[1]) &
      as.character(tbl$FacetB_Level) == as.character(target$LevelB[1]),
    ,
    drop = FALSE
  ]
  tibble::as_tibble(utils::head(out, 1L))
}

mfrm_arbitrary_bias_target_summary <- function(results) {
  if (nrow(results) == 0L) return(tibble::tibble())
  results |>
    dplyr::group_by(.data$design_id, .data$Target, .data$FacetA, .data$LevelA, .data$FacetB, .data$LevelB, .data$FacetPair, .data$TrueEffect) |>
    dplyr::summarise(
      Reps = dplyr::n(),
      RunOKRate = mean(.data$RunOK %in% TRUE),
      ConvergenceRate = mean(.data$Converged %in% TRUE),
      BiasScreenMetricAvailabilityRate = mean(.data$BiasScreenMetricAvailable %in% TRUE),
      BiasScreenRate = mean(.data$BiasDetected %in% TRUE),
      McseBiasScreenRate = simulation_mcse_proportion(.data$BiasDetected %in% TRUE),
      MeanTargetBias = design_eval_safe_mean(.data$BiasSize),
      McseTargetBias = simulation_mcse_mean(.data$BiasSize),
      MeanAbsTargetBias = design_eval_safe_mean(abs(.data$BiasSize)),
      MeanTargetBiasT = design_eval_safe_mean(.data$BiasT),
      MeanBiasPAdjusted = design_eval_safe_mean(.data$BiasPAdjusted),
      MeanBiasScreenFalsePositiveRate = design_eval_safe_mean(.data$BiasScreenFalsePositiveRate),
      McseBiasScreenFalsePositiveRate = simulation_mcse_mean(.data$BiasScreenFalsePositiveRate),
      MeanElapsedSec = design_eval_safe_mean(.data$ElapsedSec),
      .groups = "drop"
    )
}

mfrm_arbitrary_bias_pair_summary <- function(pair_results) {
  if (nrow(pair_results) == 0L) return(tibble::tibble())
  pair_results |>
    dplyr::group_by(.data$design_id, .data$FacetA, .data$FacetB) |>
    dplyr::summarise(
      Reps = dplyr::n(),
      MeanTableRows = design_eval_safe_mean(.data$TableRows),
      MeanScreenPositiveRate = design_eval_safe_mean(.data$ScreenPositiveRate),
      MeanNonTargetScreenPositiveRate = design_eval_safe_mean(.data$NonTargetScreenPositiveRate),
      ErrorRate = mean(!is.na(.data$Error) & nzchar(.data$Error)),
      .groups = "drop"
    )
}
