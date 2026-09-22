# Repository-only GPCM latent-distribution stress for mfrmr 0.2.3.
#
# Source `gpcm-estimator-asymptotics-0.2.3.R` first. This runner reuses its
# explicit fit capture and Monte Carlo summaries, then adds only the matched
# normal-versus-nonnormal design and contrasts needed here.

mfrmr_glds_require_support <- function() {
  required <- c(
    "mfrmr_gas_or", "mfrmr_gas_fun", "mfrmr_gas_thresholds",
    "mfrmr_gas_subset_cell", "mfrmr_gas_design_audit", "mfrmr_gas_fit_one",
    "mfrmr_gas_bind", "mfrmr_gas_group_rows", "mfrmr_gas_mc_interval",
    "mfrmr_gas_replicate_metrics", "mfrmr_gas_component_mc",
    "mfrmr_gas_coordinate_mc", "mfrmr_gas_method_contrasts",
    "mfrmr_gas_endpoint_contrasts"
  )
  support_environment <- environment(mfrmr_glds_require_support)
  missing <- required[!vapply(required, function(name) {
    exists(name, envir = support_environment, mode = "function",
           inherits = TRUE)
  }, logical(1))]
  if (length(missing) > 0L) {
    stop(
      "Source `gpcm-estimator-asymptotics-0.2.3.R` before this runner. ",
      "Missing support: ", paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_glds_profile <- function(replicates = 12L) {
  replicates <- as.integer(replicates)
  if (length(replicates) != 1L || is.na(replicates) || replicates < 1L) {
    stop("`replicates` must be one positive integer.", call. = FALSE)
  }
  list(
    replicates = replicates,
    n_person = 120L,
    n_rater = 6L,
    n_criterion = 4L,
    categories = 4L,
    exposure_raters = c(2L, 6L),
    quad_points = 31L,
    maxit = 300L,
    seed_start = 883000L,
    support_n = 4000L,
    evidence_use = "latent_distribution_calibration_pilot_only"
  )
}

mfrmr_glds_standardize <- function(value, target_sd = 1) {
  value <- as.numeric(value)
  if (length(value) < 8L || any(!is.finite(value))) {
    stop("Distribution support requires at least eight finite values.",
         call. = FALSE)
  }
  value <- value - mean(value)
  population_sd <- sqrt(mean(value^2))
  if (!is.finite(population_sd) || population_sd <= 0) {
    stop("Distribution support must have positive finite variance.",
         call. = FALSE)
  }
  value / population_sd * as.numeric(target_sd)
}

mfrmr_glds_supports <- function(support_n = 4000L) {
  support_n <- as.integer(support_n)
  if (length(support_n) != 1L || is.na(support_n) || support_n < 100L ||
      support_n %% 2L != 0L) {
    stop("`support_n` must be one even integer of at least 100.",
         call. = FALSE)
  }
  probabilities <- (seq_len(support_n) - 0.5) / support_n
  half_n <- support_n %/% 2L
  half_probabilities <- (seq_len(half_n) - 0.5) / half_n
  mixture <- sort(c(
    stats::qnorm(half_probabilities, mean = -1.5, sd = 0.5),
    stats::qnorm(half_probabilities, mean = 1.5, sd = 0.5)
  ))
  list(
    normal = mfrmr_glds_standardize(stats::qnorm(probabilities)),
    skewed_gamma2 = mfrmr_glds_standardize(
      stats::qgamma(probabilities, shape = 2, scale = 1)
    ),
    symmetric_mixture = mfrmr_glds_standardize(mixture)
  )
}

mfrmr_glds_moments <- function(value) {
  value <- as.numeric(value)
  value <- value[is.finite(value)]
  center <- value - mean(value)
  variance <- mean(center^2)
  if (length(value) < 2L || !is.finite(variance) || variance <= 0) {
    return(c(Mean = NA_real_, Variance = NA_real_, Skewness = NA_real_,
             ExcessKurtosis = NA_real_))
  }
  c(
    Mean = mean(value),
    Variance = variance,
    Skewness = mean(center^3) / variance^(3 / 2),
    ExcessKurtosis = mean(center^4) / variance^2 - 3
  )
}

mfrmr_glds_support_audit <- function(support_n = 4000L) {
  supports <- mfrmr_glds_supports(support_n)
  rows <- lapply(names(supports), function(distribution) {
    moment <- mfrmr_glds_moments(supports[[distribution]])
    data.frame(
      Distribution = distribution,
      SupportN = length(supports[[distribution]]),
      Mean = moment[["Mean"]],
      Variance = moment[["Variance"]],
      Skewness = moment[["Skewness"]],
      ExcessKurtosis = moment[["ExcessKurtosis"]],
      MomentContractPassed =
        abs(moment[["Mean"]]) < 1e-12 &&
        abs(moment[["Variance"]] - 1) < 1e-12,
      stringsAsFactors = FALSE
    )
  })
  mfrmr_gas_bind(rows)
}

mfrmr_glds_cells <- function() {
  settings <- mfrmr_glds_profile()
  distributions <- names(mfrmr_glds_supports(settings$support_n))
  cells <- expand.grid(
    Distribution = distributions,
    RatersPerPerson = settings$exposure_raters,
    stringsAsFactors = FALSE
  )
  cells$NPersons <- settings$n_person
  cells$Raters <- settings$n_rater
  cells$Criteria <- settings$n_criterion
  cells$Categories <- settings$categories
  cells$ObservationsPerPerson <-
    cells$RatersPerPerson * cells$Criteria
  cells$ExpectedRows <- cells$NPersons * cells$ObservationsPerPerson
  cells$CellId <- paste0(
    cells$Distribution,
    sprintf("-L%02d", cells$ObservationsPerPerson)
  )
  cells[, c(
    "CellId", "Distribution", "NPersons", "RatersPerPerson", "Raters",
    "Criteria", "Categories", "ObservationsPerPerson", "ExpectedRows"
  )]
}

mfrmr_glds_manifest <- function(replicates = 12L) {
  settings <- mfrmr_glds_profile(replicates)
  cells <- mfrmr_glds_cells()
  repetitions <- data.frame(
    Replicate = seq_len(settings$replicates),
    Seed = settings$seed_start + seq_len(settings$replicates),
    stringsAsFactors = FALSE
  )
  methods <- data.frame(
    Method = c("JML", "MML"),
    PersonTreatment = c("joint_fixed_effect", "integrated_normal_population"),
    stringsAsFactors = FALSE
  )
  out <- merge(merge(repetitions, cells, all = TRUE), methods, all = TRUE)
  out <- out[order(
    out$Replicate,
    match(out$CellId, cells$CellId),
    match(out$Method, methods$Method)
  ), , drop = FALSE]
  row.names(out) <- NULL
  out$Model <- "GPCM"
  out$StepFacet <- "Criterion"
  out$SlopeFacet <- "Criterion"
  out$Maxit <- settings$maxit
  out$QuadPoints <- ifelse(out$Method == "MML",
                           settings$quad_points, NA_integer_)
  out$EvidenceUse <- settings$evidence_use
  out$DistributionRobustnessDecision <-
    "pilot_planned_no_prespecified_decision_rule"
  out$EstimatorSelectionAuthorized <- FALSE
  out$BayesianComparatorAuthorized <- FALSE
  out$ConfirmationAuthorized <- FALSE
  out$CapabilityPromotionAuthorized <- FALSE
  out
}

mfrmr_glds_exposure_membership <- function() {
  cells <- mfrmr_glds_cells()
  data.frame(
    CellId = cells$CellId,
    Sequence = paste0("exposure_within_", cells$Distribution),
    XName = "ObservationsPerPerson",
    XValue = cells$ObservationsPerPerson,
    stringsAsFactors = FALSE
  )
}

mfrmr_glds_spec <- function(distribution, supports = mfrmr_glds_supports()) {
  mfrmr_glds_require_support()
  if (!distribution %in% names(supports)) {
    stop("Unknown latent distribution: ", distribution, ".", call. = FALSE)
  }
  settings <- mfrmr_glds_profile()
  criteria <- sprintf("C%02d", seq_len(settings$n_criterion))
  log_slopes <- seq(-0.3, 0.3, length.out = settings$n_criterion)
  common_normal <- supports$normal
  mfrmr_gas_fun("build_mfrm_sim_spec")(
    n_person = settings$n_person,
    n_rater = settings$n_rater,
    n_criterion = settings$n_criterion,
    raters_per_person = settings$n_rater,
    score_levels = settings$categories,
    theta_sd = 1,
    rater_sd = 0.45,
    criterion_sd = 0.30,
    thresholds = mfrmr_gas_thresholds(criteria, settings$categories),
    slopes = exp(log_slopes - mean(log_slopes)),
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    assignment = "crossed",
    latent_distribution = "empirical",
    empirical_person = supports[[distribution]],
    empirical_rater = mfrmr_glds_standardize(common_normal, 0.45),
    empirical_criterion = mfrmr_glds_standardize(common_normal, 0.30)
  )
}

mfrmr_glds_generate_replicate <- function(manifest, replicate) {
  mfrmr_glds_require_support()
  rows <- manifest[manifest$Replicate == as.integer(replicate), , drop = FALSE]
  if (nrow(rows) == 0L || length(unique(rows$Seed)) != 1L) {
    stop("Each requested replicate must have exactly one generating seed.",
         call. = FALSE)
  }
  supports <- mfrmr_glds_supports(mfrmr_glds_profile()$support_n)
  simulate <- mfrmr_gas_fun("simulate_mfrm_data")
  bases <- lapply(names(supports), function(distribution) {
    data <- simulate(
      sim_spec = mfrmr_glds_spec(distribution, supports),
      seed = unique(rows$Seed)
    )
    truth <- attr(data, "mfrm_truth")
    truth$population <- list(
      coefficients = stats::setNames(0, "(Intercept)"),
      sigma2 = 1,
      basis = if (identical(distribution, "normal")) {
        "correctly_specified_normal_distribution"
      } else {
        "generating_moments_not_normal_model_truth"
      }
    )
    truth$latent_distribution <- distribution
    attr(data, "mfrm_truth") <- truth
    list(data = data, truth = truth)
  })
  stats::setNames(bases, names(supports))
}

mfrmr_glds_coupling_audit <- function(bases, replicate, seed) {
  reference <- bases[["normal"]]
  rows <- lapply(names(bases), function(distribution) {
    base <- bases[[distribution]]
    design_columns <- c("Person", "Rater", "Criterion")
    ability <- unname(base$truth$person)
    moments <- mfrmr_glds_moments(ability)
    design_matched <- identical(
      base$data[, design_columns, drop = FALSE],
      reference$data[, design_columns, drop = FALSE]
    )
    facet_matched <- identical(base$truth$facets, reference$truth$facets)
    step_matched <- identical(
      base$truth$step_table, reference$truth$step_table
    )
    slope_matched <- identical(
      base$truth$slope_table, reference$truth$slope_table
    )
    data.frame(
      Replicate = as.integer(replicate),
      Seed = as.integer(seed),
      Distribution = distribution,
      DesignMatched = design_matched,
      FacetTruthMatched = facet_matched,
      StepTruthMatched = step_matched,
      SlopeTruthMatched = slope_matched,
      RealizedAbilityMean = moments[["Mean"]],
      RealizedAbilityVariance = moments[["Variance"]],
      RealizedAbilitySkewness = moments[["Skewness"]],
      RealizedAbilityExcessKurtosis = moments[["ExcessKurtosis"]],
      CouplingContractPassed = all(
        design_matched, facet_matched, step_matched, slope_matched
      ),
      stringsAsFactors = FALSE
    )
  })
  mfrmr_gas_bind(rows)
}

mfrmr_glds_decorate <- function(data, row) {
  if (!is.data.frame(data) || nrow(data) == 0L) return(data)
  data$Distribution <- as.character(row$Distribution)
  population_use <- if (identical(row$Distribution, "normal")) {
    "normal_distribution_parameter_recovery"
  } else {
    "generating_moment_difference_under_normal_misspecification"
  }
  data$PopulationTargetUse <- if ("ParameterType" %in% names(data)) {
    ifelse(data$ParameterType == "population", population_use,
           "not_population_parameter")
  } else {
    "not_applicable"
  }
  data
}

mfrmr_run_gpcm_latent_distribution_stress <- function(
    dry_run = TRUE, authorize_pilot = FALSE, replicates = 12L) {
  mfrmr_glds_require_support()
  manifest <- mfrmr_glds_manifest(replicates)
  support_audit <- mfrmr_glds_support_audit()
  if (!all(support_audit$MomentContractPassed)) {
    stop("A latent support failed the centered unit-variance contract.",
         call. = FALSE)
  }
  if (isTRUE(dry_run)) {
    return(structure(
      list(
        manifest = manifest,
        support_audit = support_audit,
        exposure_membership = mfrmr_glds_exposure_membership()
      ),
      class = "mfrmr_gpcm_latent_distribution_stress_plan"
    ))
  }
  if (!isTRUE(authorize_pilot)) {
    stop("Pilot execution requires `authorize_pilot = TRUE`.", call. = FALSE)
  }

  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)

  status_rows <- list()
  recovery_rows <- list()
  slope_rows <- list()
  design_rows <- list()
  coupling_rows <- list()
  cursor <- 0L
  for (replicate in sort(unique(manifest$Replicate))) {
    replicate_rows <- manifest[manifest$Replicate == replicate, , drop = FALSE]
    bases <- mfrmr_glds_generate_replicate(manifest, replicate)
    coupling <- mfrmr_glds_coupling_audit(
      bases, replicate, unique(replicate_rows$Seed)
    )
    if (!all(coupling$CouplingContractPassed)) {
      stop("A replicate failed the cross-distribution truth-coupling contract.",
           call. = FALSE)
    }
    coupling_rows[[replicate]] <- coupling

    cell_data <- list()
    for (cell_id in unique(replicate_rows$CellId)) {
      cell <- replicate_rows[replicate_rows$CellId == cell_id, , drop = FALSE][1L, ]
      data <- mfrmr_gas_subset_cell(bases[[cell$Distribution]], cell)
      cell_data[[cell_id]] <- data
      audit <- mfrmr_gas_design_audit(data, cell)
      audit$Distribution <- as.character(cell$Distribution)
      design_rows[[length(design_rows) + 1L]] <- audit
      if (!isTRUE(audit$DesignContractPassed)) {
        stop("A generated stress cell failed its design contract.",
             call. = FALSE)
      }
    }

    for (index in seq_len(nrow(replicate_rows))) {
      cursor <- cursor + 1L
      row <- replicate_rows[index, , drop = FALSE]
      fitted <- mfrmr_gas_fit_one(row, cell_data[[row$CellId]])
      status_rows[[cursor]] <- mfrmr_glds_decorate(fitted$status, row)
      recovery_rows[[cursor]] <- mfrmr_glds_decorate(fitted$recovery, row)
      slope_rows[[cursor]] <- mfrmr_glds_decorate(fitted$slope_trace, row)
    }
  }

  structure(
    list(
      manifest = manifest,
      support_audit = support_audit,
      exposure_membership = mfrmr_glds_exposure_membership(),
      coupling = mfrmr_gas_bind(coupling_rows),
      design = mfrmr_gas_bind(design_rows),
      status = mfrmr_gas_bind(status_rows),
      recovery = mfrmr_gas_bind(recovery_rows),
      slope_optimizer_trace = mfrmr_gas_bind(slope_rows),
      decisions = data.frame(
        DistributionRobustnessDecision =
          "pilot_completed_no_prespecified_decision_rule",
        EstimatorSelectionAuthorized = FALSE,
        BayesianComparatorAuthorized = FALSE,
        ConfirmationAuthorized = FALSE,
        CapabilityPromotionAuthorized = FALSE,
        stringsAsFactors = FALSE
      )
    ),
    class = "mfrmr_gpcm_latent_distribution_stress"
  )
}

mfrmr_glds_normal_contrasts <- function(replicate_metrics, manifest) {
  if (!is.data.frame(replicate_metrics) || nrow(replicate_metrics) == 0L) {
    return(data.frame())
  }
  cell_map <- unique(manifest[, c(
    "CellId", "Distribution", "ObservationsPerPerson"
  )])
  metrics <- merge(replicate_metrics, cell_map,
                   by = c("CellId", "ObservationsPerPerson"), sort = FALSE)
  alternatives <- setdiff(unique(metrics$Distribution), "normal")
  pair_keys <- c(
    "Replicate", "ObservationsPerPerson", "Method", "Component"
  )
  rows <- list()
  for (alternative in alternatives) {
    normal <- metrics[metrics$Distribution == "normal", , drop = FALSE]
    stressed <- metrics[
      metrics$Distribution == alternative, , drop = FALSE
    ]
    if (anyDuplicated(normal[pair_keys]) ||
        anyDuplicated(stressed[pair_keys])) {
      stop("Distribution metrics must be unique within each matched fit.",
           call. = FALSE)
    }
    paired <- merge(
      normal[, c(pair_keys, "RMSE", "MAE"), drop = FALSE],
      stressed[, c(pair_keys, "RMSE", "MAE"), drop = FALSE],
      by = pair_keys, suffixes = c("Normal", "Stress"), sort = FALSE
    )
    if (nrow(paired) != nrow(normal) || nrow(paired) != nrow(stressed)) {
      stop("Distribution contrasts require exactly matched replicate metrics.",
           call. = FALSE)
    }
    paired$RMSEDifference <- paired$RMSEStress - paired$RMSENormal
    paired$MAEDifference <- paired$MAEStress - paired$MAENormal
    groups <- mfrmr_gas_group_rows(
      paired, c("ObservationsPerPerson", "Method", "Component")
    )
    summaries <- lapply(groups, function(index) {
      rmse <- mfrmr_gas_mc_interval(paired$RMSEDifference[index])
      mae <- mfrmr_gas_mc_interval(paired$MAEDifference[index])
      data.frame(
        Distribution = alternative,
        ReferenceDistribution = "normal",
        ObservationsPerPerson = paired$ObservationsPerPerson[index[1L]],
        Method = paired$Method[index[1L]],
        Component = paired$Component[index[1L]],
        Replicates = as.integer(rmse[["Replicates"]]),
        MeanRMSEDifference = rmse[["Mean"]],
        MCSERMSEDifference = rmse[["MCSE"]],
        Lower95RMSEDifference = rmse[["Lower95"]],
        Upper95RMSEDifference = rmse[["Upper95"]],
        StressHigherRMSERate = mean(paired$RMSEDifference[index] > 0),
        MeanMAEDifference = mae[["Mean"]],
        stringsAsFactors = FALSE
      )
    })
    rows <- c(rows, summaries)
  }
  mfrmr_gas_bind(rows)
}

mfrmr_summarize_gpcm_latent_distribution_stress <- function(result) {
  mfrmr_glds_require_support()
  if (!inherits(result, "mfrmr_gpcm_latent_distribution_stress")) {
    stop("`result` must come from the executed distribution-stress runner.",
         call. = FALSE)
  }
  component <- ifelse(
    result$recovery$ParameterType == "facet",
    paste0("facet_", tolower(result$recovery$Facet)),
    ifelse(
      result$recovery$ParameterType == "population",
      paste0("population_", result$recovery$Subparameter),
      as.character(result$recovery$ParameterType)
    )
  )
  recovery_replicate <- mfrmr_gas_replicate_metrics(
    result$recovery, "ErrorAligned", component
  )
  slope_replicate <- mfrmr_gas_replicate_metrics(
    result$slope_optimizer_trace, "Error",
    rep("optimizer_log_slope", nrow(result$slope_optimizer_trace))
  )
  list(
    status = result$status,
    recovery_replicate = recovery_replicate,
    recovery_component_mc = mfrmr_gas_component_mc(recovery_replicate),
    recovery_coordinate_mc = mfrmr_gas_coordinate_mc(
      result$recovery,
      keys = c(
        "CellId", "Distribution", "NPersons", "ObservationsPerPerson",
        "Method", "ParameterType", "Facet", "Level", "Subparameter"
      ),
      error_column = "ErrorAligned"
    ),
    recovery_method_contrasts = mfrmr_gas_method_contrasts(
      recovery_replicate
    ),
    recovery_normal_contrasts = mfrmr_glds_normal_contrasts(
      recovery_replicate, result$manifest
    ),
    recovery_exposure_contrasts = mfrmr_gas_endpoint_contrasts(
      recovery_replicate, result$exposure_membership
    ),
    slope_replicate = slope_replicate,
    slope_component_mc = mfrmr_gas_component_mc(slope_replicate),
    slope_coordinate_mc = mfrmr_gas_coordinate_mc(
      result$slope_optimizer_trace,
      keys = c(
        "CellId", "Distribution", "NPersons", "ObservationsPerPerson",
        "Method", "SlopeFacet"
      ),
      error_column = "Error"
    ),
    slope_method_contrasts = mfrmr_gas_method_contrasts(slope_replicate),
    slope_normal_contrasts = mfrmr_glds_normal_contrasts(
      slope_replicate, result$manifest
    ),
    slope_exposure_contrasts = mfrmr_gas_endpoint_contrasts(
      slope_replicate, result$exposure_membership
    ),
    decisions = result$decisions,
    interpretation = paste(
      "Distribution contrasts are paired numerical calibration evidence.",
      "They do not select JML, MML, or a Bayesian estimator, and optimizer",
      "log-slope traces remain inferentially ineligible."
    )
  )
}
