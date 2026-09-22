# Repository-only GPCM covering-grid stress runner for mfrmr 0.2.3.
#
# This file turns the prespecified GPCM stress envelope into an executable,
# fail-closed manifest.  It is calibration instrumentation, not confirmation,
# a public API, or a source of release thresholds.  Numeric external comparison
# remains ineligible until the model, estimator, identification, retained data,
# and output transformation have an exact matched contract.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

mfrmr_gpcm_stress_fun <- function(name) {
  if (exists(name, mode = "function", inherits = TRUE)) {
    return(get(name, mode = "function", inherits = TRUE))
  }
  getExportedValue("mfrmr", name)
}

mfrmr_gpcm_stress_capture <- function(expr) {
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

mfrmr_gpcm_stress_axes <- function() {
  list(
    Estimator = c("JML", "MML", "PCM_JML", "PCM_MML"),
    SlopeLevels = c("one", "two", "four", "twelve"),
    SlopeSpread = c("unit", "mild", "strong", "near_zero_high"),
    Categories = c("K2", "K3", "K5", "K7"),
    CategoryPrevalence = c(
      "balanced", "rare_interior", "dominant_middle", "floor", "ceiling",
      "internal_zero", "boundary_zero"
    ),
    RaterPanel = c("R2", "R3", "R6", "R12"),
    Assignment = c(
      "complete", "sparse_connected", "weak_bridge", "zero_shared",
      "routed", "disconnected"
    ),
    Missingness = c("none", "mcar", "person", "rater", "outcome"),
    CellStructure = c(
      "unique", "repeated", "occasion", "unequal_weights", "zero_weights"
    ),
    Interaction = c(
      "none", "person_rater", "slope_correlated", "slope_orthogonal"
    ),
    Diagnostic = c("null", "local_dependence", "bias", "rater_drift"),
    SampleSize = c("small", "standard", "target_sparse")
  )
}

mfrmr_gpcm_stress_pair_key <- function(axis_a, level_a, axis_b, level_b) {
  paste(axis_a, level_a, axis_b, level_b, sep = "::")
}

mfrmr_gpcm_stress_pairwise_array <- function(
    axes = mfrmr_gpcm_stress_axes()) {
  if (!is.list(axes) || length(axes) < 2L || is.null(names(axes)) ||
      any(!nzchar(names(axes))) || anyDuplicated(names(axes))) {
    stop("`axes` must be a named list containing at least two axes.",
         call. = FALSE)
  }
  valid <- vapply(axes, function(x) {
    is.character(x) && length(x) >= 2L && !anyNA(x) &&
      all(nzchar(x)) && !anyDuplicated(x)
  }, logical(1))
  if (!all(valid)) {
    stop("Every stress axis must contain at least two unique labels.",
         call. = FALSE)
  }

  rows <- expand.grid(
    axes[seq_len(2L)], KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
  )
  axis_names <- names(axes)
  for (k in 3:length(axes)) {
    new_axis <- axis_names[k]
    required <- do.call(rbind, lapply(seq_len(k - 1L), function(i) {
      expand.grid(
        AxisIndex = i,
        PriorLevel = axes[[i]],
        NewLevel = axes[[k]],
        KEEP.OUT.ATTRS = FALSE,
        stringsAsFactors = FALSE
      )
    }))
    required$Key <- mfrmr_gpcm_stress_pair_key(
      required$AxisIndex, required$PriorLevel, k, required$NewLevel
    )
    uncovered <- required$Key
    assigned <- character(nrow(rows))

    for (row in seq_len(nrow(rows))) {
      gain <- vapply(axes[[k]], function(candidate) {
        keys <- vapply(seq_len(k - 1L), function(i) {
          mfrmr_gpcm_stress_pair_key(i, rows[[axis_names[i]]][row],
                                     k, candidate)
        }, character(1))
        sum(keys %in% uncovered)
      }, integer(1))
      chosen <- axes[[k]][which.max(gain)]
      assigned[row] <- chosen
      covered <- vapply(seq_len(k - 1L), function(i) {
        mfrmr_gpcm_stress_pair_key(i, rows[[axis_names[i]]][row], k, chosen)
      }, character(1))
      uncovered <- setdiff(uncovered, covered)
    }
    rows[[new_axis]] <- assigned

    while (length(uncovered) > 0L) {
      target <- required[match(uncovered[1L], required$Key), , drop = FALSE]
      new_row <- stats::setNames(
        as.list(vapply(axes[seq_len(k)], `[`, character(1), 1L)),
        axis_names[seq_len(k)]
      )
      source_axis <- as.integer(target$AxisIndex)
      new_level <- as.character(target$NewLevel)
      new_row[[axis_names[source_axis]]] <- as.character(target$PriorLevel)
      new_row[[new_axis]] <- new_level

      for (i in setdiff(seq_len(k - 1L), source_axis)) {
        gain <- vapply(axes[[i]], function(candidate) {
          key <- mfrmr_gpcm_stress_pair_key(i, candidate, k, new_level)
          as.integer(key %in% uncovered)
        }, integer(1))
        new_row[[axis_names[i]]] <- axes[[i]][which.max(gain)]
      }
      new_df <- as.data.frame(new_row, stringsAsFactors = FALSE,
                              check.names = FALSE)
      rows <- rbind(rows, new_df)
      covered <- vapply(seq_len(k - 1L), function(i) {
        mfrmr_gpcm_stress_pair_key(
          i, new_df[[axis_names[i]]][1L], k, new_level
        )
      }, character(1))
      uncovered <- setdiff(uncovered, covered)
    }
  }
  row.names(rows) <- NULL
  rows
}

mfrmr_gpcm_stress_mandatory_corners <- function() {
  data.frame(
    CornerId = c(
      "binary_unit_jml", "unit_mml_reference", "two_rater_joint_warning",
      "zero_shared_jml", "internal_zero_mml", "outcome_ceiling_mml",
      "local_dependence_jml", "target_sparse_mml", "one_level_gap",
      "repeated_person_missing", "routed_mml", "disconnected_boundary_zero"
    ),
    Estimator = c(
      "JML", "PCM_MML", "JML", "JML", "MML", "MML",
      "JML", "MML", "JML", "JML", "MML", "JML"
    ),
    SlopeLevels = c(
      "two", "two", "two", "two", "four", "four",
      "four", "twelve", "one", "two", "four", "twelve"
    ),
    SlopeSpread = c(
      "unit", "unit", "near_zero_high", "strong", "mild", "strong",
      "mild", "strong", "unit", "strong", "mild", "near_zero_high"
    ),
    Categories = c(
      "K2", "K5", "K5", "K3", "K5", "K7",
      "K5", "K7", "K3", "K5", "K3", "K7"
    ),
    CategoryPrevalence = c(
      "balanced", "balanced", "rare_interior", "balanced",
      "internal_zero", "ceiling", "balanced", "rare_interior",
      "balanced", "floor", "balanced", "boundary_zero"
    ),
    RaterPanel = c(
      "R2", "R3", "R2", "R2", "R3", "R6",
      "R3", "R12", "R2", "R2", "R6", "R6"
    ),
    Assignment = c(
      "complete", "complete", "weak_bridge", "zero_shared",
      "sparse_connected", "complete", "sparse_connected",
      "sparse_connected", "complete", "weak_bridge", "routed",
      "disconnected"
    ),
    Missingness = c(
      "none", "none", "mcar", "none", "none", "outcome",
      "none", "rater", "none", "person", "person", "none"
    ),
    CellStructure = c(
      "unique", "unique", "unique", "unique", "unique",
      "unequal_weights", "occasion", "zero_weights", "unique",
      "repeated", "unique", "unique"
    ),
    Interaction = c(
      "none", "none", "slope_correlated", "none", "none",
      "slope_correlated", "person_rater", "slope_orthogonal", "none",
      "person_rater", "slope_correlated", "none"
    ),
    Diagnostic = c(
      "null", "null", "bias", "null", "null", "rater_drift",
      "local_dependence", "bias", "null", "rater_drift", "null", "null"
    ),
    SampleSize = c(
      "small", "small", "small", "small", "small", "standard",
      "standard", "target_sparse", "small", "small", "standard", "standard"
    ),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_stress_axis_signature <- function(data,
                                              axes = mfrmr_gpcm_stress_axes()) {
  apply(data[names(axes)], 1L, paste, collapse = "\r")
}

mfrmr_gpcm_stress_manifest <- function(
    profile = c("smoke", "pilot", "confirmation"),
    axes = mfrmr_gpcm_stress_axes()) {
  profile <- match.arg(profile)
  pairwise <- mfrmr_gpcm_stress_pairwise_array(axes)
  pairwise$CornerId <- NA_character_
  pairwise$DesignSource <- "pairwise_covering_array"
  mandatory <- mfrmr_gpcm_stress_mandatory_corners()
  mandatory$DesignSource <- "mandatory_corner"
  axis_names <- names(axes)
  missing_axes <- setdiff(axis_names, names(mandatory))
  if (length(missing_axes) > 0L) {
    stop("Mandatory corners are missing axis columns: ",
         paste(missing_axes, collapse = ", "), call. = FALSE)
  }
  for (axis in axis_names) {
    bad <- setdiff(unique(as.character(mandatory[[axis]])), axes[[axis]])
    if (length(bad) > 0L) {
      stop("Mandatory corner has unknown `", axis, "` level(s): ",
           paste(bad, collapse = ", "), call. = FALSE)
    }
  }

  pairwise <- pairwise[, c("CornerId", axis_names, "DesignSource"), drop = FALSE]
  mandatory <- mandatory[, names(pairwise), drop = FALSE]
  mandatory_signature <- mfrmr_gpcm_stress_axis_signature(mandatory, axes)
  pairwise_signature <- mfrmr_gpcm_stress_axis_signature(pairwise, axes)
  pairwise <- pairwise[!pairwise_signature %in% mandatory_signature, , drop = FALSE]
  manifest <- rbind(mandatory, pairwise)

  if (identical(profile, "smoke")) {
    keep <- c(
      "binary_unit_jml", "unit_mml_reference", "two_rater_joint_warning",
      "zero_shared_jml", "internal_zero_mml", "local_dependence_jml",
      "one_level_gap"
    )
    manifest <- manifest[match(keep, manifest$CornerId), , drop = FALSE]
  }
  row.names(manifest) <- NULL
  manifest$Profile <- profile
  manifest$ScenarioId <- sprintf(
    "GPCM-%s-%03d", toupper(substr(profile, 1L, 1L)), seq_len(nrow(manifest))
  )
  seed_base <- switch(profile,
                      smoke = 130000L,
                      pilot = 230000L,
                      confirmation = 930000L)
  manifest$Seed <- seed_base + seq_len(nrow(manifest))
  manifest$Reps <- switch(profile,
                          smoke = 1L,
                          pilot = 5L,
                          confirmation = 50L)
  manifest$Phase <- profile
  manifest$ConfirmationEvidence <- identical(profile, "confirmation")

  slope_count <- c(one = 1L, two = 2L, four = 4L, twelve = 12L)
  category_count <- c(K2 = 2L, K3 = 3L, K5 = 5L, K7 = 7L)
  rater_count <- c(R2 = 2L, R3 = 3L, R6 = 6L, R12 = 12L)
  person_count <- c(small = 24L, standard = 80L, target_sparse = 400L)
  manifest$NSlopeLevels <- unname(slope_count[manifest$SlopeLevels])
  manifest$NCategories <- unname(category_count[manifest$Categories])
  manifest$NRaters <- unname(rater_count[manifest$RaterPanel])
  manifest$NPersons <- unname(person_count[manifest$SampleSize])
  manifest$FitModel <- ifelse(startsWith(manifest$Estimator, "PCM_"),
                              "PCM", "GPCM")
  manifest$FitMethod <- ifelse(grepl("MML$", manifest$Estimator),
                               "MML", "JML")
  manifest$Executable <- manifest$SlopeLevels != "one"
  manifest$ExecutionReason <- ifelse(
    manifest$Executable,
    "supported_current_single_scale_generator",
    "single_slope_level_generator_not_supported"
  )
  manifest$ExpectedFitState <- ifelse(
    !manifest$Executable,
    "manifest_only_known_gap",
    ifelse(
      manifest$Assignment %in% c("zero_shared", "disconnected") |
        manifest$CategoryPrevalence %in% c("internal_zero", "boundary_zero"),
      "must_not_be_false_ready",
      "review_recovery"
    )
  )
  manifest$TruthRecoveryEligible <-
    manifest$Missingness %in% c("none", "mcar") &
    manifest$CategoryPrevalence == "balanced" &
    manifest$CellStructure == "unique" &
    manifest$Interaction == "none" &
    manifest$Diagnostic == "null" &
    manifest$Assignment %in% c("complete", "sparse_connected", "weak_bridge") &
    (manifest$FitModel == "GPCM" | manifest$SlopeSpread == "unit")
  manifest$FACETSRole <- ifelse(
    manifest$FitModel == "PCM" & manifest$SlopeSpread == "unit",
    "matched_lower_model_candidate_pending_normalizer",
    ifelse(
      manifest$SlopeSpread == "unit",
      "lower_model_fixed_equal_slope_reference_only",
      "diagnostic_only_different_slope_estimand"
    )
  )
  manifest$TAMRole <- ifelse(
    manifest$FitModel == "PCM",
    "lower_model_reference_pending_identification_contract",
    ifelse(
      manifest$FitMethod == "MML",
      "pending_exact_free_slope_design_reexpression",
      "pending_jml_adjustment_and_identification_contract"
    )
  )
  manifest$immerRole <- ifelse(
    manifest$FitModel == "PCM" & manifest$SlopeSpread == "unit",
    "matched_pcm_candidate_pending_normalizer",
    ifelse(
      manifest$SlopeSpread == "unit",
      "pcm_reduction_reference_only",
      "alternative_model_only"
    )
  )
  manifest$NumericExternalEligible <- FALSE
  manifest$ExternalIneligibilityReason <-
    "external_estimand_and_normalizer_not_yet_matched"
  manifest$ThresholdStatus <- "pilot_required_not_frozen"
  manifest$ReleaseUse <- "calibration_only"

  canonical <- manifest[, c(
    "ScenarioId", axis_names, "FitModel", "FitMethod", "Seed", "Reps", "Phase",
    "ExecutionReason", "ExpectedFitState", "TruthRecoveryEligible",
    "FACETSRole", "TAMRole", "immerRole", "NumericExternalEligible"
  ), drop = FALSE]
  manifest_hash <- if (requireNamespace("digest", quietly = TRUE)) {
    digest::digest(canonical, algo = "sha256", serialize = TRUE)
  } else {
    NA_character_
  }
  manifest$ManifestHash <- manifest_hash
  manifest
}

mfrmr_gpcm_stress_coverage <- function(
    manifest,
    axes = mfrmr_gpcm_stress_axes()) {
  manifest <- as.data.frame(manifest, stringsAsFactors = FALSE)
  missing_axes <- setdiff(names(axes), names(manifest))
  if (length(missing_axes) > 0L) {
    stop("Manifest is missing stress axis columns: ",
         paste(missing_axes, collapse = ", "), call. = FALSE)
  }
  rows <- list()
  cursor <- 0L
  for (i in seq_len(length(axes) - 1L)) {
    for (j in (i + 1L):length(axes)) {
      required <- expand.grid(
        LevelA = axes[[i]], LevelB = axes[[j]],
        KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
      )
      counts <- vapply(seq_len(nrow(required)), function(k) {
        sum(
          as.character(manifest[[names(axes)[i]]]) == required$LevelA[k] &
            as.character(manifest[[names(axes)[j]]]) == required$LevelB[k]
        )
      }, integer(1))
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        AxisA = names(axes)[i],
        LevelA = required$LevelA,
        AxisB = names(axes)[j],
        LevelB = required$LevelB,
        NRows = counts,
        Covered = counts > 0L,
        stringsAsFactors = FALSE
      )
    }
  }
  detail <- do.call(rbind, rows)
  row.names(detail) <- NULL
  structure(
    list(
      detail = detail,
      summary = data.frame(
        ManifestRows = nrow(manifest),
        RequiredPairs = nrow(detail),
        CoveredPairs = sum(detail$Covered),
        UncoveredPairs = sum(!detail$Covered),
        PairwiseComplete = all(detail$Covered),
        stringsAsFactors = FALSE
      )
    ),
    class = "mfrmr_gpcm_stress_coverage"
  )
}

mfrmr_gpcm_stress_thresholds <- function(levels, n_categories) {
  n_steps <- as.integer(n_categories) - 1L
  base <- if (n_steps == 1L) 0 else seq(-1.35, 1.35, length.out = n_steps)
  offsets <- if (length(levels) == 1L) 0 else {
    seq(-0.25, 0.25, length.out = length(levels))
  }
  do.call(rbind, lapply(seq_along(levels), function(i) {
    data.frame(
      StepFacet = levels[i],
      StepIndex = seq_len(n_steps),
      Estimate = base + offsets[i],
      stringsAsFactors = FALSE
    )
  }))
}

mfrmr_gpcm_stress_slopes <- function(levels, spread) {
  n <- length(levels)
  log_slope <- switch(
    as.character(spread),
    unit = rep(0, n),
    mild = seq(-0.25, 0.25, length.out = n),
    strong = seq(-0.85, 0.85, length.out = n),
    near_zero_high = if (n == 2L) c(-1.7, 1.7) else {
      seq(-1.7, 1.7, length.out = n)
    },
    stop("Unknown slope spread: ", spread, call. = FALSE)
  )
  log_slope <- log_slope - mean(log_slope)
  stats::setNames(exp(log_slope), levels)
}

mfrmr_gpcm_stress_bind_effects <- function(...) {
  tables <- list(...)
  tables <- tables[vapply(tables, function(x) {
    is.data.frame(x) && nrow(x) > 0L
  }, logical(1))]
  if (length(tables) == 0L) return(NULL)
  all_names <- unique(unlist(lapply(tables, names), use.names = FALSE))
  tables <- lapply(tables, function(x) {
    missing <- setdiff(all_names, names(x))
    for (name in missing) x[[name]] <- NA_character_
    x[, all_names, drop = FALSE]
  })
  out <- do.call(rbind, tables)
  row.names(out) <- NULL
  out$Effect <- as.numeric(out$Effect)
  out
}

mfrmr_gpcm_stress_effects <- function(row, slope_values) {
  n_person <- as.integer(row$NPersons)
  persons <- sprintf("P%03d", seq_len(n_person))
  raters <- sprintf("R%02d", seq_len(as.integer(row$NRaters)))
  criteria <- names(slope_values)
  interaction <- NULL
  if (identical(row$Interaction, "person_rater")) {
    interaction <- expand.grid(
      Person = persons[seq_len(min(6L, length(persons)))],
      Rater = raters[seq_len(min(2L, length(raters)))],
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    interaction$Effect <- 0.65 * ifelse(
      (match(interaction$Person, persons) + match(interaction$Rater, raters)) %% 2L,
      1, -1
    )
  } else if (row$Interaction %in% c(
    "slope_correlated", "slope_orthogonal"
  )) {
    centered <- log(as.numeric(slope_values))
    centered <- centered - mean(centered)
    if (identical(row$Interaction, "slope_orthogonal") && length(centered) > 1L) {
      centered <- centered[c(2:length(centered), 1L)]
    }
    scale <- max(abs(centered))
    if (!is.finite(scale) || scale == 0) scale <- 1
    interaction <- expand.grid(
      Rater = raters[seq_len(min(2L, length(raters)))],
      Criterion = criteria,
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    interaction$Effect <- 0.55 *
      ifelse(match(interaction$Rater, raters) %% 2L, 1, -1) *
      centered[match(interaction$Criterion, criteria)] / scale
  }

  diagnostic <- NULL
  if (identical(row$Diagnostic, "local_dependence")) {
    target <- criteria[seq_len(min(2L, length(criteria)))]
    signal <- 0.7 * sin(seq_along(persons) * pi / 5)
    diagnostic <- expand.grid(
      Person = persons,
      Criterion = target,
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    diagnostic$Effect <- signal[match(diagnostic$Person, persons)]
  } else if (identical(row$Diagnostic, "bias")) {
    diagnostic <- data.frame(
      Rater = raters[1L], Criterion = criteria[1L], Effect = 0.8,
      stringsAsFactors = FALSE
    )
  } else if (identical(row$Diagnostic, "rater_drift")) {
    late <- persons[seq.int(floor(length(persons) / 2L) + 1L, length(persons))]
    diagnostic <- data.frame(
      Person = late, Rater = raters[1L], Effect = 0.65,
      stringsAsFactors = FALSE
    )
  }
  mfrmr_gpcm_stress_bind_effects(interaction, diagnostic)
}

mfrmr_gpcm_stress_build <- function(row) {
  row <- as.list(row)
  if (!isTRUE(as.logical(row$Executable))) {
    stop("Scenario is manifest-only: ", row$ExecutionReason, call. = FALSE)
  }
  n_person <- as.integer(row$NPersons)
  n_rater <- as.integer(row$NRaters)
  n_criterion <- as.integer(row$NSlopeLevels)
  n_categories <- as.integer(row$NCategories)
  criteria <- sprintf("C%02d", seq_len(n_criterion))
  slopes <- mfrmr_gpcm_stress_slopes(criteria, row$SlopeSpread)
  assignment <- if (row$Assignment %in% c(
    "sparse_connected", "weak_bridge"
  )) {
    "sparse_linked"
  } else if (identical(row$Assignment, "zero_shared")) {
    "rotating"
  } else {
    "crossed"
  }
  raters_per_person <- if (identical(assignment, "crossed")) {
    n_rater
  } else {
    1L
  }
  sparse_controls <- if (identical(assignment, "sparse_linked")) {
    list(
      link_persons = if (identical(row$Assignment, "weak_bridge")) {
        1L
      } else {
        max(2L, ceiling(0.10 * n_person))
      },
      link_raters_per_person = n_rater,
      assignment_mode = "balanced",
      min_common_persons_per_rater_pair = 1L
    )
  } else {
    NULL
  }
  effects <- mfrmr_gpcm_stress_effects(row, slopes)
  build_spec <- mfrmr_gpcm_stress_fun("build_mfrm_sim_spec")
  simulate <- mfrmr_gpcm_stress_fun("simulate_mfrm_data")
  spec <- build_spec(
    n_person = n_person,
    n_rater = n_rater,
    n_criterion = n_criterion,
    raters_per_person = raters_per_person,
    score_levels = n_categories,
    theta_sd = 1,
    rater_sd = 0.55,
    criterion_sd = 0.35,
    thresholds = mfrmr_gpcm_stress_thresholds(criteria, n_categories),
    slopes = slopes,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    assignment = assignment,
    sparse_controls = sparse_controls,
    interaction_effects = effects
  )
  data <- simulate(sim_spec = spec, seed = as.integer(row$Seed))
  list(data = data, spec = spec, truth = attr(data, "mfrm_truth"))
}

mfrmr_gpcm_stress_keep <- function(data, keep) {
  keep <- as.logical(keep)
  keep[is.na(keep)] <- FALSE
  if (!any(keep)) keep[1L] <- TRUE
  data[keep, , drop = FALSE]
}

mfrmr_gpcm_stress_transform <- function(generated, row) {
  data <- generated$data
  truth <- generated$truth
  spec <- generated$spec
  set.seed(as.integer(row$Seed) + 10000L)
  n <- nrow(data)
  n_categories <- as.integer(row$NCategories)

  if (identical(row$Assignment, "routed")) {
    theta <- truth$person[as.character(data$Person)]
    rater_rank <- match(data$Rater, sort(unique(data$Rater)))
    lower <- theta <= stats::median(truth$person)
    lower_rater <- rater_rank <= ceiling(as.integer(row$NRaters) / 2)
    bridge <- data$Person == names(sort(abs(truth$person)))[1L]
    data <- mfrmr_gpcm_stress_keep(data, lower == lower_rater | bridge)
  } else if (identical(row$Assignment, "disconnected")) {
    person_rank <- match(data$Person, sort(unique(data$Person)))
    rater_rank <- match(data$Rater, sort(unique(data$Rater)))
    criterion_rank <- match(data$Criterion, sort(unique(data$Criterion)))
    left <- person_rank <= floor(as.integer(row$NPersons) / 2L)
    left_rater <- rater_rank <= floor(as.integer(row$NRaters) / 2L)
    left_criterion <- criterion_rank <= floor(as.integer(row$NSlopeLevels) / 2L)
    data <- mfrmr_gpcm_stress_keep(
      data, (left & left_rater & left_criterion) |
        (!left & !left_rater & !left_criterion)
    )
  }

  n <- nrow(data)
  if (identical(row$Missingness, "mcar")) {
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) > 0.30)
  } else if (identical(row$Missingness, "person")) {
    theta <- truth$person[as.character(data$Person)]
    scaled <- stats::pnorm(theta / max(stats::sd(truth$person), 0.1))
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < 0.25 + 0.70 * scaled)
  } else if (identical(row$Missingness, "rater")) {
    rank <- match(data$Rater, sort(unique(data$Rater)))
    keep_prob <- pmax(0.10, 1 - 0.75 * (rank - 1L) /
                        max(1L, length(unique(rank)) - 1L))
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < keep_prob)
  } else if (identical(row$Missingness, "outcome")) {
    keep_prob <- ifelse(data$Score %in% c(1L, n_categories), 0.25, 0.85)
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < keep_prob)
  }

  n <- nrow(data)
  middle <- max(2L, ceiling(n_categories / 2L))
  if (identical(row$CategoryPrevalence, "rare_interior")) {
    keep_prob <- ifelse(data$Score == middle, 0.05, 1)
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < keep_prob)
  } else if (identical(row$CategoryPrevalence, "dominant_middle")) {
    keep_prob <- ifelse(data$Score == middle, 1, 0.20)
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < keep_prob)
  } else if (identical(row$CategoryPrevalence, "floor")) {
    keep_prob <- exp(-0.60 * (data$Score - 1L))
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < keep_prob)
  } else if (identical(row$CategoryPrevalence, "ceiling")) {
    keep_prob <- exp(-0.60 * (n_categories - data$Score))
    data <- mfrmr_gpcm_stress_keep(data, stats::runif(n) < keep_prob)
  } else if (identical(row$CategoryPrevalence, "internal_zero")) {
    data <- mfrmr_gpcm_stress_keep(data, data$Score != middle)
  } else if (identical(row$CategoryPrevalence, "boundary_zero")) {
    data <- mfrmr_gpcm_stress_keep(data, data$Score != n_categories)
  }

  if (identical(row$CellStructure, "repeated")) {
    take <- seq_len(max(1L, ceiling(0.10 * nrow(data))))
    data <- rbind(data, data[take, , drop = FALSE])
  } else if (identical(row$CellStructure, "occasion")) {
    data$Occasion <- "O1"
    take <- seq_len(max(1L, ceiling(0.10 * nrow(data))))
    extra <- data[take, , drop = FALSE]
    extra$Occasion <- "O2"
    data <- rbind(data, extra)
  } else if (identical(row$CellStructure, "unequal_weights")) {
    rank <- match(data$Rater, sort(unique(data$Rater)))
    data$Weight <- 0.25 + 1.75 * rank / max(rank)
  } else if (identical(row$CellStructure, "zero_weights")) {
    data$Weight <- 1
    take <- seq_len(max(1L, ceiling(0.10 * nrow(data))))
    data$Weight[take] <- 0
  }
  row.names(data) <- NULL
  attr(data, "mfrm_truth") <- truth
  attr(data, "mfrm_simulation_spec") <- spec
  list(data = data, truth = truth, spec = spec)
}

mfrmr_gpcm_stress_support <- function(data, n_categories) {
  counts <- tabulate(as.integer(data$Score), nbins = n_categories)
  prop <- if (sum(counts) > 0L) counts / sum(counts) else rep(NA_real_, n_categories)
  pair_data <- unique(data[, c("Person", "Rater"), drop = FALSE])
  raters <- sort(unique(as.character(pair_data$Rater)))
  common <- integer(0)
  if (length(raters) >= 2L) {
    pairs <- utils::combn(raters, 2L)
    common <- apply(pairs, 2L, function(pair) {
      length(intersect(
        pair_data$Person[pair_data$Rater == pair[1L]],
        pair_data$Person[pair_data$Rater == pair[2L]]
      ))
    })
  }
  exact_keys <- c("Person", "Rater", "Criterion")
  distinguished_keys <- c(exact_keys, intersect("Occasion", names(data)))
  positive_weight <- if ("Weight" %in% names(data)) {
    sum(is.finite(data$Weight) & data$Weight > 0)
  } else {
    nrow(data)
  }
  canonical <- data[do.call(order, data[intersect(
    c("Person", "Rater", "Criterion", "Occasion", "Score", "Weight"),
    names(data)
  )]), , drop = FALSE]
  digest <- if (requireNamespace("digest", quietly = TRUE)) {
    digest::digest(canonical, algo = "sha256", serialize = TRUE)
  } else {
    NA_character_
  }
  data.frame(
    Rows = nrow(data),
    PositiveWeightRows = positive_weight,
    Persons = length(unique(data$Person)),
    Raters = length(unique(data$Rater)),
    Criteria = length(unique(data$Criterion)),
    CategoryCounts = paste(counts, collapse = ";"),
    ObservedCategories = sum(counts > 0L),
    ZeroCategories = sum(counts == 0L),
    MinCategoryCount = min(counts),
    MaxCategoryFraction = if (all(is.na(prop))) NA_real_ else max(prop),
    NormalizedCategoryEntropy = if (sum(prop > 0, na.rm = TRUE) > 1L) {
      -sum(prop[prop > 0] * log(prop[prop > 0])) / log(n_categories)
    } else {
      0
    },
    MinCommonPersons = if (length(common) > 0L) min(common) else NA_integer_,
    ZeroCommonRaterPairs = if (length(common) > 0L) sum(common == 0L) else NA_integer_,
    ExactCellDuplicates = sum(duplicated(data[exact_keys])),
    DistinguishedCellDuplicates = sum(duplicated(data[distinguished_keys])),
    RetainedDataHash = digest,
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_stress_empty_result <- function(row, run_state, error = NA_character_) {
  data.frame(
    ScenarioId = as.character(row$ScenarioId),
    CornerId = as.character(row$CornerId %||% NA_character_),
    Profile = as.character(row$Profile),
    Seed = as.integer(row$Seed),
    Estimator = as.character(row$Estimator),
    FitModel = as.character(row$FitModel),
    FitMethod = as.character(row$FitMethod),
    ExpectedFitState = as.character(row$ExpectedFitState),
    Executed = FALSE,
    RunState = run_state,
    Error = error,
    Warnings = NA_character_,
    Rows = NA_integer_,
    PositiveWeightRows = NA_integer_,
    Persons = NA_integer_,
    Raters = NA_integer_,
    Criteria = NA_integer_,
    CategoryCounts = NA_character_,
    ObservedCategories = NA_integer_,
    ZeroCategories = NA_integer_,
    MinCategoryCount = NA_integer_,
    MaxCategoryFraction = NA_real_,
    NormalizedCategoryEntropy = NA_real_,
    MinCommonPersons = NA_integer_,
    ZeroCommonRaterPairs = NA_integer_,
    ExactCellDuplicates = NA_integer_,
    DistinguishedCellDuplicates = NA_integer_,
    RetainedDataHash = NA_character_,
    FitReadiness = NA_character_,
    InferenceReady = NA,
    ReadinessReasons = NA_character_,
    BoundaryState = NA_character_,
    SlopeParameters = NA_integer_,
    PrimarySlopeValues = NA_integer_,
    SlopeComparisonEligible = NA_integer_,
    OptimizerLogSlopeRMSE = NA_real_,
    FalseReady = NA,
    PCAState = "not_run",
    PCAFirstEigenvalue = NA_real_,
    NumericExternalEligible = FALSE,
    ReleaseUse = "calibration_only",
    ManifestHash = as.character(row$ManifestHash),
    stringsAsFactors = FALSE
  )
}

mfrmr_gpcm_stress_run_one <- function(row, run_diagnostics = FALSE,
                                       maxit = NULL, quad_points = 7L) {
  if (!isTRUE(as.logical(row$Executable))) {
    return(mfrmr_gpcm_stress_empty_result(
      row, "not_executed_known_gap", as.character(row$ExecutionReason)
    ))
  }
  generated_capture <- mfrmr_gpcm_stress_capture(
    mfrmr_gpcm_stress_build(row)
  )
  if (inherits(generated_capture$value, "error")) {
    return(mfrmr_gpcm_stress_empty_result(
      row, "generation_failed", conditionMessage(generated_capture$value)
    ))
  }
  transformed_capture <- mfrmr_gpcm_stress_capture(
    mfrmr_gpcm_stress_transform(generated_capture$value, row)
  )
  if (inherits(transformed_capture$value, "error")) {
    return(mfrmr_gpcm_stress_empty_result(
      row, "transformation_failed", conditionMessage(transformed_capture$value)
    ))
  }
  transformed <- transformed_capture$value
  data <- transformed$data
  support <- mfrmr_gpcm_stress_support(data, as.integer(row$NCategories))
  facets <- c("Rater", "Criterion", intersect("Occasion", names(data)))
  fit_args <- list(
    data = data,
    person = "Person",
    facets = facets,
    score = "Score",
    model = as.character(row$FitModel),
    method = as.character(row$FitMethod),
    step_facet = "Criterion",
    rating_min = 1L,
    rating_max = as.integer(row$NCategories),
    maxit = as.integer(maxit %||% ifelse(row$Profile == "smoke", 80L, 180L))
  )
  if (identical(row$FitModel, "GPCM")) {
    fit_args$slope_facet <- "Criterion"
  }
  if ("Weight" %in% names(data)) fit_args$weight <- "Weight"
  if (identical(row$FitMethod, "MML")) {
    fit_args$quad_points <- as.integer(quad_points)
  }
  fit_capture <- mfrmr_gpcm_stress_capture(
    do.call(mfrmr_gpcm_stress_fun("fit_mfrm"), fit_args)
  )
  warnings <- unique(c(
    generated_capture$warnings, transformed_capture$warnings,
    fit_capture$warnings
  ))
  if (inherits(fit_capture$value, "error")) {
    out <- mfrmr_gpcm_stress_empty_result(
      row,
      if (identical(row$ExpectedFitState, "must_not_be_false_ready")) {
        "expected_fail_closed"
      } else {
        "fit_failed"
      },
      conditionMessage(fit_capture$value)
    )
    out[names(support)] <- support
    out$Executed <- TRUE
    out$Warnings <- paste(warnings, collapse = " | ")
    out$FalseReady <- FALSE
    return(out)
  }

  fit <- fit_capture$value
  readiness <- as.data.frame(fit$readiness$fit %||% data.frame(),
                             stringsAsFactors = FALSE)
  fit_summary <- as.data.frame(fit$summary %||% data.frame(),
                               stringsAsFactors = FALSE)
  fit_readiness <- if (nrow(readiness) == 1L &&
                       "FitReadiness" %in% names(readiness)) {
    as.character(readiness[["FitReadiness"]][1L])
  } else if (nrow(fit_summary) == 1L &&
             "FitReadiness" %in% names(fit_summary)) {
    as.character(fit_summary[["FitReadiness"]][1L])
  } else if (nrow(fit_summary) == 1L &&
             "InferenceReady" %in% names(fit_summary) &&
             isTRUE(fit_summary[["InferenceReady"]][1L])) {
    "legacy_ready"
  } else {
    "legacy_review_or_blocked"
  }
  inference_ready <- if (nrow(readiness) == 1L &&
                         "InferenceReady" %in% names(readiness)) {
    isTRUE(readiness[["InferenceReady"]][1L])
  } else if (nrow(fit_summary) == 1L &&
             "InferenceReady" %in% names(fit_summary)) {
    isTRUE(fit_summary[["InferenceReady"]][1L])
  } else {
    FALSE
  }
  reasons <- if (nrow(readiness) == 1L &&
                 "ReasonCodes" %in% names(readiness)) {
    as.character(readiness[["ReasonCodes"]][1L])
  } else if (nrow(fit_summary) == 1L &&
             "ReadinessReasonCodes" %in% names(fit_summary)) {
    as.character(fit_summary[["ReadinessReasonCodes"]][1L])
  } else if (nrow(fit_summary) == 1L &&
             "BoundaryReasonCodes" %in% names(fit_summary)) {
    as.character(fit_summary[["BoundaryReasonCodes"]][1L])
  } else {
    "legacy_contract_missing"
  }
  slope <- as.data.frame(fit$slopes %||% data.frame(), stringsAsFactors = FALSE)
  truth_slope <- as.data.frame(transformed$truth$slope_table %||% data.frame(),
                               stringsAsFactors = FALSE)
  optimizer_rmse <- NA_real_
  if (nrow(slope) > 0L && nrow(truth_slope) > 0L &&
      all(c("SlopeFacet", "Estimate") %in% names(slope)) &&
      all(c("SlopeFacet", "Estimate") %in% names(truth_slope))) {
    matched <- merge(
      slope[, c("SlopeFacet", "Estimate"), drop = FALSE],
      truth_slope[, c("SlopeFacet", "Estimate"), drop = FALSE],
      by = "SlopeFacet", suffixes = c(".Fit", ".Truth")
    )
    ok <- is.finite(matched$Estimate.Fit) & matched$Estimate.Fit > 0 &
      is.finite(matched$Estimate.Truth) & matched$Estimate.Truth > 0
    if (any(ok)) {
      optimizer_rmse <- sqrt(mean(
        (log(matched$Estimate.Fit[ok]) - log(matched$Estimate.Truth[ok]))^2
      ))
    }
  }
  comparison_eligible <- if ("ComparisonEligibility" %in% names(slope)) {
    sum(slope$ComparisonEligibility == "eligible", na.rm = TRUE)
  } else {
    0L
  }
  primary_values <- if ("PrimaryEstimate" %in% names(slope)) {
    sum(is.finite(slope$PrimaryEstimate))
  } else {
    0L
  }
  false_ready <- identical(row$ExpectedFitState, "must_not_be_false_ready") &&
    (isTRUE(inference_ready) || identical(fit_readiness, "ready"))

  pca_state <- "not_run"
  pca_first <- NA_real_
  if (isTRUE(run_diagnostics)) {
    pca_capture <- mfrmr_gpcm_stress_capture(
      mfrmr_gpcm_stress_fun("analyze_residual_pca")(
        fit, mode = "overall", parallel = FALSE
      )
    )
    warnings <- unique(c(warnings, pca_capture$warnings))
    if (inherits(pca_capture$value, "error")) {
      pca_state <- "failed"
    } else {
      pca_state <- "available_exploratory"
      pca_table <- as.data.frame(
        pca_capture$value$overall_table %||% data.frame(),
        stringsAsFactors = FALSE
      )
      numeric_columns <- names(pca_table)[vapply(pca_table, is.numeric,
                                                 logical(1))]
      preferred <- intersect(c("Eigenvalue", "Variance"), numeric_columns)
      chosen <- (c(preferred, numeric_columns))[1L]
      if (length(chosen) == 1L && !is.na(chosen) && nrow(pca_table) > 0L) {
        pca_first <- as.numeric(pca_table[[chosen]][1L])
      }
    }
  }

  run_state <- if (false_ready) {
    "false_ready"
  } else if (identical(row$ExpectedFitState, "must_not_be_false_ready")) {
    "expected_review_or_block"
  } else {
    "completed_calibration"
  }
  out <- mfrmr_gpcm_stress_empty_result(row, run_state)
  out[names(support)] <- support
  out$Executed <- TRUE
  out$Warnings <- paste(warnings, collapse = " | ")
  out$FitReadiness <- fit_readiness
  out$InferenceReady <- inference_ready
  out$ReadinessReasons <- reasons
  out$BoundaryState <- if (nrow(readiness) == 1L &&
                           "BoundaryState" %in% names(readiness)) {
    as.character(readiness[["BoundaryState"]][1L])
  } else if (nrow(fit_summary) == 1L &&
             "BoundaryState" %in% names(fit_summary)) {
    as.character(fit_summary[["BoundaryState"]][1L])
  } else {
    NA_character_
  }
  out$SlopeParameters <- nrow(slope)
  out$PrimarySlopeValues <- primary_values
  out$SlopeComparisonEligible <- comparison_eligible
  out$OptimizerLogSlopeRMSE <- optimizer_rmse
  out$FalseReady <- false_ready
  out$PCAState <- pca_state
  out$PCAFirstEigenvalue <- pca_first
  out
}

mfrmr_run_gpcm_stress_covering_grid <- function(
    profile = c("smoke", "pilot", "confirmation"),
    scenario_ids = NULL,
    dry_run = FALSE,
    run_diagnostics = FALSE,
    maxit = NULL,
    quad_points = 7L,
    output_dir = NULL,
    verbose = TRUE) {
  profile <- match.arg(profile)
  manifest <- mfrmr_gpcm_stress_manifest(profile)
  if (!is.null(scenario_ids)) {
    scenario_ids <- as.character(scenario_ids)
    missing <- setdiff(scenario_ids, manifest$ScenarioId)
    if (length(missing) > 0L) {
      stop("Unknown scenario ID(s): ", paste(missing, collapse = ", "),
           call. = FALSE)
    }
    manifest <- manifest[match(scenario_ids, manifest$ScenarioId), , drop = FALSE]
  }
  coverage_manifest <- if (identical(profile, "smoke")) {
    mfrmr_gpcm_stress_manifest("pilot")
  } else {
    manifest
  }
  coverage <- mfrmr_gpcm_stress_coverage(coverage_manifest)
  started_at <- Sys.time()
  results <- if (isTRUE(dry_run)) {
    do.call(rbind, lapply(seq_len(nrow(manifest)), function(i) {
      mfrmr_gpcm_stress_empty_result(
        manifest[i, , drop = FALSE],
        if (manifest$Executable[i]) "planned_not_executed" else
          "not_executed_known_gap",
        if (manifest$Executable[i]) NA_character_ else
          manifest$ExecutionReason[i]
      )
    }))
  } else {
    do.call(rbind, lapply(seq_len(nrow(manifest)), function(i) {
      if (isTRUE(verbose)) {
        message("[", manifest$ScenarioId[i], "] ",
                manifest$Estimator[i], " ", manifest$SlopeSpread[i], " ",
                manifest$Assignment[i])
      }
      mfrmr_gpcm_stress_run_one(
        manifest[i, , drop = FALSE],
        run_diagnostics = run_diagnostics,
        maxit = maxit,
        quad_points = quad_points
      )
    }))
  }
  out <- structure(
    list(
      manifest = manifest,
      coverage = coverage,
      results = results,
      settings = list(
        profile = profile,
        dry_run = isTRUE(dry_run),
        run_diagnostics = isTRUE(run_diagnostics),
        maxit = maxit,
        quad_points = as.integer(quad_points),
        numeric_external_eligible = FALSE,
        threshold_status = "pilot_required_not_frozen"
      ),
      started_at = started_at,
      completed_at = Sys.time()
    ),
    class = "mfrmr_gpcm_stress_covering_grid"
  )
  if (!is.null(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    utils::write.csv(manifest, file.path(output_dir, "scenario-manifest.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(results, file.path(output_dir, "run-results.csv"),
                     row.names = FALSE, na = "")
    utils::write.csv(coverage$detail,
                     file.path(output_dir, "pairwise-coverage.csv"),
                     row.names = FALSE, na = "")
    saveRDS(out, file.path(output_dir, "gpcm-stress-covering-grid.rds"))
  }
  out
}

mfrmr_summarize_gpcm_stress_covering_grid <- function(x) {
  if (!inherits(x, "mfrmr_gpcm_stress_covering_grid")) {
    stop("`x` must be output from mfrmr_run_gpcm_stress_covering_grid().",
         call. = FALSE)
  }
  results <- as.data.frame(x$results, stringsAsFactors = FALSE)
  data.frame(
    Profile = x$settings$profile,
    ManifestRows = nrow(x$manifest),
    PairwiseComplete = isTRUE(x$coverage$summary$PairwiseComplete[1L]),
    UncoveredPairs = as.integer(x$coverage$summary$UncoveredPairs[1L]),
    ExecutableRows = sum(x$manifest$Executable),
    KnownGapRows = sum(!x$manifest$Executable),
    ExecutedRows = sum(results$Executed %in% TRUE, na.rm = TRUE),
    FailedRows = sum(results$RunState %in% c(
      "generation_failed", "transformation_failed", "fit_failed"
    )),
    FalseReadyRows = sum(results$FalseReady %in% TRUE, na.rm = TRUE),
    NumericExternalEligibleRows = sum(
      results$NumericExternalEligible %in% TRUE, na.rm = TRUE
    ),
    ThresholdStatus = x$settings$threshold_status,
    EvidenceUse = "calibration_only",
    stringsAsFactors = FALSE
  )
}
