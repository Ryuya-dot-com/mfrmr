# mfrmr 0.2.3 repository-only MML canonical-score pilot
#
# This runner fits fixed binary, RSM, PCM, and identified positive-slope GPCM
# fixtures, checks
# the analytical score in the identified free coordinate system against an
# independently implemented central-difference reference, audits the GPCM
# log-slope transformation Jacobian, and checks exact binary/unit-slope
# reductions. It calibrates a future gate only: it freezes no tolerance and
# never authorizes confirmation or model selection.
#
# From the repository root:
#
#   pkgload::load_all(".")
#   source("inst/validation/numerical-stationarity-pilot-0.2.3.R")
#   numerical <- mfrmr_run_numerical_stationarity_pilot()
#   numerical$score_summary
#   numerical$reduction_results
#   numerical$summary

mfrmr_num_specification <- "0.2.3-draft.12"
mfrmr_num_contract <- "mfrmr_mml_canonical_score_audit_v1"
mfrmr_num_primary_step <- 3e-5
mfrmr_num_step_ladder <- c(1e-4, 3e-5, 1e-5)

mfrmr_num_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

mfrmr_num_namespace <- function() {
  if (!requireNamespace("mfrmr", quietly = TRUE)) {
    stop(
      "Load the mfrmr working-tree source before running the numerical stationarity pilot.",
      call. = FALSE
    )
  }
  namespace <- asNamespace("mfrmr")
  required <- c(
    "with_preserved_rng_seed", "mfrm_loglik_mml", "mfrm_grad_mml",
    "build_param_sizes", "build_param_slices", "build_indices",
    "gauss_hermite_normal", "expand_params", "compute_base_eta",
    "mfrm_mml_logprob_bundle", "category_prob_pcm"
  )
  available <- vapply(
    required,
    exists,
    logical(1),
    envir = namespace,
    inherits = FALSE
  )
  if (!all(available)) {
    stop(
      "The loaded mfrmr namespace is not the required 0.2.3 working-tree source; use pkgload::load_all('.').",
      call. = FALSE
    )
  }
  namespace
}

mfrmr_num_get <- function(name) {
  get(name, envir = mfrmr_num_namespace(), inherits = FALSE)
}

mfrmr_num_plan <- function() {
  data.frame(
    RunId = c(
      "binary_rsm", "binary_pcm", "rsm_core", "pcm_core", "gpcm_core"
    ),
    ScenarioId = c(
      "NUM-BIN-REDUCE", "NUM-BIN-REDUCE", "NUM-RSM-CORE",
      "NUM-PCM-CORE", "NUM-GPCM-BOUND"
    ),
    Model = c("RSM", "PCM", "RSM", "PCM", "GPCM"),
    FixtureId = c(
      "binary_fixed", "binary_fixed", "polytomous_fixed",
      "polytomous_fixed", "polytomous_fixed"
    ),
    StepFacet = c(NA, "Item", NA, "Item", "Item"),
    SlopeFacet = c(NA, NA, NA, NA, "Item"),
    QuadPoints = 31L,
    Maxit = 2000L,
    Reltol = 1e-12,
    ProbeScale = 0.08,
    EvidenceRole = c(
      "exact_reduction_partner", "exact_reduction_partner",
      "canonical_score_pilot", "canonical_score_pilot",
      "canonical_score_and_transform_pilot"
    ),
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_num_fixture <- function(fixture_id) {
  fixture_id <- as.character(fixture_id)[1]
  mfrmr_num_assert(
    fixture_id %in% c("binary_fixed", "polytomous_fixed"),
    "`fixture_id` must be 'binary_fixed' or 'polytomous_fixed'."
  )
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The repository-only numerical pilot requires the suggested `digest` package.",
         call. = FALSE)
  }

  preserve_seed <- mfrmr_num_get("with_preserved_rng_seed")
  seed <- if (identical(fixture_id, "binary_fixed")) 20260741L else 20260742L
  preserve_seed(seed, {
    persons <- sprintf("P%03d", seq_len(60L))
    items <- sprintf("I%02d", seq_len(4L))
    data <- expand.grid(
      Person = persons,
      Item = items,
      stringsAsFactors = FALSE
    )
    person_index <- match(data$Person, persons)
    item_index <- match(data$Item, items)
    theta <- seq(-1.7, 1.7, length.out = length(persons)) +
      0.12 * sin(seq_along(persons) * 0.7)
    item_effect <- c(-0.65, -0.20, 0.20, 0.65)
    eta <- theta[person_index] - item_effect[item_index]

    if (identical(fixture_id, "binary_fixed")) {
      p1 <- stats::plogis(eta)
      probability <- cbind(1 - p1, p1)
      rating_max <- 1L
    } else {
      step_matrix <- rbind(
        c(-1.25, -0.10, 1.35),
        c(-0.95,  0.05, 0.90),
        c(-1.10,  0.20, 0.90),
        c(-0.75, -0.15, 0.90)
      )
      probability <- mfrmr_num_get("category_prob_pcm")(
        eta = eta,
        step_cum_mat = t(apply(
          step_matrix,
          1,
          function(value) c(0, cumsum(value))
        )),
        criterion_idx = item_index
      )
      rating_max <- 3L
    }

    data$Score <- vapply(seq_len(nrow(data)), function(index) {
      sample.int(
        ncol(probability),
        size = 1L,
        prob = probability[index, ]
      ) - 1L
    }, integer(1L))
    category_counts <- as.data.frame(
      table(
        Item = factor(data$Item, levels = items),
        Score = factor(data$Score, levels = 0:rating_max)
      ),
      stringsAsFactors = FALSE
    )
    category_counts$Item <- as.character(category_counts$Item)
    category_counts$Score <- as.integer(as.character(category_counts$Score))
    mfrmr_num_assert(
      all(category_counts$Freq > 0L),
      paste0(
        "The fixed ", fixture_id,
        " fixture must retain every declared category for every item."
      )
    )

    canonical_csv <- paste(
      capture.output(utils::write.csv(data, row.names = FALSE, quote = TRUE)),
      collapse = "\n"
    )
    list(
      fixture_id = fixture_id,
      seed = seed,
      data = data,
      persons = persons,
      items = items,
      rating_min = 0L,
      rating_max = rating_max,
      category_counts = category_counts,
      sha256 = digest::digest(
        canonical_csv,
        algo = "sha256",
        serialize = FALSE
      )
    )
  })
}

mfrmr_num_coordinate_table <- function(sizes) {
  mfrmr_num_assert(
    is.list(sizes) && length(sizes) > 0L && !is.null(names(sizes)) &&
      all(!is.na(names(sizes))) && all(nzchar(names(sizes))) &&
      !anyDuplicated(names(sizes)),
    "`sizes` must be one named parameter-size list."
  )
  rows <- lapply(names(sizes), function(parameter_class) {
    raw_count <- suppressWarnings(as.numeric(sizes[[parameter_class]]))
    mfrmr_num_assert(
      length(raw_count) == 1L && is.finite(raw_count) && raw_count >= 0 &&
        raw_count == floor(raw_count),
      "Every parameter-size entry must be one finite nonnegative integer."
    )
    count <- as.integer(raw_count)
    if (count == 0L) return(NULL)
    data.frame(
      ParameterClass = parameter_class,
      ClassCoordinate = seq_len(count),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  if (is.null(out)) {
    return(data.frame(
      CoordinateIndex = integer(0),
      ParameterClass = character(0),
      ClassCoordinate = integer(0),
      CoordinateLabel = character(0),
      CoordinateSystem = character(0),
      stringsAsFactors = FALSE
    ))
  }
  rownames(out) <- NULL
  out$CoordinateIndex <- seq_len(nrow(out))
  out$CoordinateLabel <- paste0(
    out$ParameterClass, "[", out$ClassCoordinate, "]"
  )
  out$CoordinateSystem <- "identified_free_optimizer_coordinates_v1"
  out[, c(
    "CoordinateIndex", "ParameterClass", "ClassCoordinate",
    "CoordinateLabel", "CoordinateSystem"
  )]
}

mfrmr_num_central_gradient <- function(fn, par, rel_step) {
  mfrmr_num_assert(is.function(fn), "`fn` must be a function.")
  par <- as.numeric(par)
  rel_step <- suppressWarnings(as.numeric(rel_step))
  mfrmr_num_assert(
    length(par) > 0L && all(is.finite(par)),
    "`par` must be a non-empty finite numeric vector."
  )
  mfrmr_num_assert(
    length(rel_step) == 1L && is.finite(rel_step) && rel_step > 0,
    "`rel_step` must be one finite positive value."
  )
  step <- rel_step * pmax(1, abs(par))
  value <- vapply(seq_along(par), function(index) {
    high <- low <- par
    high[index] <- high[index] + step[index]
    low[index] <- low[index] - step[index]
    high_value <- suppressWarnings(as.numeric(fn(high))[1])
    low_value <- suppressWarnings(as.numeric(fn(low))[1])
    if (!is.finite(high_value) || !is.finite(low_value)) return(NA_real_)
    (high_value - low_value) / (2 * step[index])
  }, numeric(1L))
  value
}

mfrmr_num_fit_context <- function(fit) {
  config <- fit$config
  sizes <- mfrmr_num_get("build_param_sizes")(config)
  idx <- mfrmr_num_get("build_indices")(
    fit$prep,
    step_facet = config$step_facet,
    slope_facet = config$slope_facet,
    interaction_specs = config$interaction_specs
  )
  nodes <- suppressWarnings(as.integer(
    config$estimation_control$quad_points[1]
  ))
  mfrmr_num_assert(
    length(nodes) == 1L && is.finite(nodes) && nodes > 0L,
    "The fit does not retain one valid quadrature-node count."
  )
  quad <- mfrmr_num_get("gauss_hermite_normal")(nodes)
  fn <- function(par) {
    mfrmr_num_get("mfrm_loglik_mml")(par, idx, config, sizes, quad)
  }
  gr <- function(par) {
    mfrmr_num_get("mfrm_grad_mml")(par, idx, config, sizes, quad)
  }
  list(
    config = config,
    sizes = sizes,
    slices = mfrmr_num_get("build_param_slices")(sizes),
    coordinates = mfrmr_num_coordinate_table(sizes),
    idx = idx,
    quad = quad,
    fn = fn,
    gr = gr
  )
}

mfrmr_num_probe_point <- function(fit, probe_scale = 0.08) {
  par <- as.numeric(fit$opt$par)
  context <- mfrmr_num_fit_context(fit)
  probe_scale <- suppressWarnings(as.numeric(probe_scale)[1])
  mfrmr_num_assert(
    is.finite(probe_scale) && probe_scale > 0,
    "`probe_scale` must be one finite positive value."
  )
  direction <- sin(seq_along(par) * sqrt(2)) +
    0.5 * cos(seq_along(par) * sqrt(3))
  direction <- direction / max(abs(direction))
  probe <- par + probe_scale * direction * pmax(1, abs(par))
  point <- "deterministic_probe"

  if (identical(fit$config$model, "GPCM")) {
    slope_slice <- context$slices$log_slopes
    n_levels <- length(fit$config$gpcm_spec$levels)
    mfrmr_num_assert(
      length(slope_slice) == max(n_levels - 1L, 0L) && n_levels >= 2L,
      "The GPCM fit does not retain the declared free log-slope block."
    )
    target <- exp(seq(log(0.45), log(2.20), length.out = n_levels))
    target_log <- log(target) - mean(log(target))
    probe[slope_slice] <- target_log[seq_len(n_levels - 1L)]
    point <- "high_dispersion_probe"
  }
  list(label = point, par = probe)
}

mfrmr_num_audit_fit <- function(fit, plan_row,
                                rel_steps = mfrmr_num_step_ladder) {
  context <- mfrmr_num_fit_context(fit)
  retained <- as.numeric(fit$opt$par)
  mfrmr_num_assert(
    length(retained) == nrow(context$coordinates) && all(is.finite(retained)),
    "The retained parameter vector does not match the canonical free-coordinate table."
  )
  probe <- mfrmr_num_probe_point(fit, plan_row$ProbeScale)
  points <- list(
    retained_solution = retained,
    probe = probe$par
  )
  names(points)[2] <- probe$label

  fit_summary <- as.data.frame(fit$summary, stringsAsFactors = FALSE)[1, , drop = FALSE]
  rows <- list()
  row_index <- 1L
  for (point_name in names(points)) {
    point_par <- points[[point_name]]
    analytic <- suppressWarnings(as.numeric(context$gr(point_par)))
    objective <- suppressWarnings(as.numeric(context$fn(point_par))[1])
    for (rel_step in rel_steps) {
      numeric_score <- tryCatch(
        mfrmr_num_central_gradient(context$fn, point_par, rel_step),
        error = function(error) rep(NA_real_, length(point_par))
      )
      difference <- analytic - numeric_score
      score_scale <- pmax(1, abs(analytic), abs(numeric_score))
      row <- context$coordinates
      row$Specification <- mfrmr_num_specification
      row$ContractVersion <- mfrmr_num_contract
      row$RunId <- as.character(plan_row$RunId)
      row$ScenarioId <- as.character(plan_row$ScenarioId)
      row$Model <- as.character(plan_row$Model)
      row$FixtureId <- as.character(plan_row$FixtureId)
      row$Point <- point_name
      row$RelativeStep <- as.numeric(rel_step)
      row$Objective <- objective
      row$AnalyticScore <- analytic
      row$NumericScore <- numeric_score
      row$AbsDifference <- abs(difference)
      row$ScaledDifference <- abs(difference) / score_scale
      row$MfrmrInferenceReady <- isTRUE(fit_summary$InferenceReady)
      row$SelectionAuthorized <- FALSE
      row$ConfirmationAuthorized <- FALSE
      rows[[row_index]] <- row
      row_index <- row_index + 1L
    }
  }
  do.call(rbind, rows)
}

mfrmr_num_score_summarize <- function(score_results,
                                      primary_step = mfrmr_num_primary_step) {
  required <- c(
    "RunId", "ScenarioId", "Model", "Point", "RelativeStep",
    "CoordinateIndex", "AnalyticScore", "NumericScore", "AbsDifference",
    "ScaledDifference", "MfrmrInferenceReady"
  )
  mfrmr_num_assert(
    is.data.frame(score_results) && all(required %in% names(score_results)),
    "`score_results` does not satisfy the canonical-score summary contract."
  )
  primary_step <- suppressWarnings(as.numeric(primary_step))
  mfrmr_num_assert(
    length(primary_step) == 1L && is.finite(primary_step) && primary_step > 0 &&
      any(abs(score_results$RelativeStep - primary_step) < .Machine$double.eps),
    "The prespecified primary finite-difference step is absent."
  )
  mfrmr_num_assert(
    nrow(score_results) > 0L &&
      all(is.finite(score_results$RelativeStep)) &&
      all(score_results$RelativeStep > 0) &&
      all(is.finite(score_results$CoordinateIndex)) &&
      all(score_results$CoordinateIndex > 0),
    "Canonical-score rows require positive finite steps and coordinate indices."
  )
  mfrmr_num_assert(
    all(vapply(
      c("RunId", "ScenarioId", "Model", "Point"),
      function(field) {
        value <- as.character(score_results[[field]])
        all(!is.na(value)) && all(nzchar(value))
      },
      logical(1L)
    )),
    "Canonical-score rows require complete run, scenario, model, and point labels."
  )
  key <- interaction(
    score_results$RunId,
    score_results$Point,
    drop = TRUE,
    lex.order = TRUE
  )
  rows <- lapply(split(score_results, key), function(group) {
    steps <- sort(unique(as.numeric(group$RelativeStep)))
    coordinates <- sort(unique(as.integer(group$CoordinateIndex)))
    primary <- group[
      abs(group$RelativeStep - primary_step) < .Machine$double.eps,
      ,
      drop = FALSE
    ]
    coordinate_groups <- split(group, as.integer(group$CoordinateIndex))
    step_ranges <- vapply(coordinate_groups, function(rows) {
      value <- suppressWarnings(as.numeric(rows$NumericScore))
      row_steps <- sort(unique(as.numeric(rows$RelativeStep)))
      if (
        nrow(rows) != length(steps) ||
          !identical(row_steps, steps) ||
          length(value) < 2L ||
          any(!is.finite(value))
      ) {
        return(NA_real_)
      }
      value <- suppressWarnings(as.numeric(value))
      diff(range(value))
    }, numeric(1L))
    metadata_complete <- all(vapply(
      c("RunId", "ScenarioId", "Model", "Point"),
      function(field) {
        value <- unique(as.character(group[[field]]))
        length(value) == 1L && !is.na(value) && nzchar(value)
      },
      logical(1L)
    ))
    structure_complete <- length(steps) >= 3L &&
      length(coordinates) > 0L &&
      nrow(group) == length(steps) * length(coordinates) &&
      !anyDuplicated(data.frame(
        RelativeStep = group$RelativeStep,
        CoordinateIndex = group$CoordinateIndex
      )) &&
      nrow(primary) == length(coordinates) &&
      identical(sort(as.integer(primary$CoordinateIndex)), coordinates)
    complete <- metadata_complete && structure_complete &&
      all(is.finite(primary$AnalyticScore)) &&
      all(is.finite(primary$NumericScore)) &&
      all(is.finite(primary$AbsDifference)) &&
      all(is.finite(primary$ScaledDifference)) &&
      all(is.finite(step_ranges))
    data.frame(
      Specification = mfrmr_num_specification,
      ContractVersion = mfrmr_num_contract,
      RunId = as.character(group$RunId[1]),
      ScenarioId = as.character(group$ScenarioId[1]),
      Model = as.character(group$Model[1]),
      Point = as.character(group$Point[1]),
      PrimaryRelativeStep = primary_step,
      CoordinateCount = length(coordinates),
      MaxAbsAnalyticScore = if (
        nrow(primary) > 0L && all(is.finite(primary$AnalyticScore))
      ) {
        max(abs(primary$AnalyticScore), na.rm = TRUE)
      } else {
        NA_real_
      },
      MaxAbsDifference = if (complete) max(primary$AbsDifference) else NA_real_,
      MaxScaledDifference = if (complete) {
        max(primary$ScaledDifference)
      } else {
        NA_real_
      },
      MaxNumericStepRange = if (complete) max(step_ranges) else NA_real_,
      MfrmrInferenceReady = nrow(primary) > 0L &&
        all(primary$MfrmrInferenceReady %in% TRUE),
      ReferenceStatus = if (complete) "review_complete" else "rejected",
      SelectionAuthorized = FALSE,
      ConfirmationAuthorized = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

mfrmr_num_gpcm_jacobian_from_free <- function(
    free_log_slopes,
    levels = paste0("Slope_", seq_len(length(free_log_slopes) + 1L)),
    point = "probe",
    rel_step = 1e-6) {
  free_log_slopes <- as.numeric(free_log_slopes)
  levels <- as.character(levels)
  n_free <- length(free_log_slopes)
  n_levels <- n_free + 1L
  rel_step <- suppressWarnings(as.numeric(rel_step))
  mfrmr_num_assert(
    n_free > 0L && length(levels) == n_levels &&
      all(!is.na(levels)) && all(nzchar(levels)) && !anyDuplicated(levels) &&
      all(is.finite(free_log_slopes)) && length(rel_step) == 1L &&
      is.finite(rel_step) && rel_step > 0,
    "GPCM Jacobian review requires finite n-1 free log slopes and n labels."
  )
  transform <- function(value) {
    log_slopes <- c(value, -sum(value))
    list(log_slopes = log_slopes, slopes = exp(log_slopes))
  }
  transformed <- transform(free_log_slopes)
  log_jacobian <- rbind(diag(n_free), rep(-1, n_free))
  slope_jacobian <- diag(transformed$slopes, nrow = n_levels) %*%
    log_jacobian
  numeric_log <- matrix(NA_real_, nrow = n_levels, ncol = n_free)
  numeric_slope <- matrix(NA_real_, nrow = n_levels, ncol = n_free)
  step <- rel_step * pmax(1, abs(free_log_slopes))
  for (column in seq_len(n_free)) {
    high <- low <- free_log_slopes
    high[column] <- high[column] + step[column]
    low[column] <- low[column] - step[column]
    high_value <- transform(high)
    low_value <- transform(low)
    numeric_log[, column] <-
      (high_value$log_slopes - low_value$log_slopes) / (2 * step[column])
    numeric_slope[, column] <-
      (high_value$slopes - low_value$slopes) / (2 * step[column])
  }
  table <- expand.grid(
    ExpandedLevel = levels,
    FreeCoordinate = paste0("log_slope_free[", seq_len(n_free), "]"),
    stringsAsFactors = FALSE
  )
  row_index <- match(table$ExpandedLevel, levels)
  column_index <- match(
    table$FreeCoordinate,
    paste0("log_slope_free[", seq_len(n_free), "]")
  )
  table$Point <- point
  table$CoordinateSystem <-
    "free_log_slopes_to_sum_zero_logs_to_positive_slopes_v1"
  table$AnalyticLogJacobian <- log_jacobian[cbind(row_index, column_index)]
  table$NumericLogJacobian <- numeric_log[cbind(row_index, column_index)]
  table$AnalyticSlopeJacobian <- slope_jacobian[cbind(row_index, column_index)]
  table$NumericSlopeJacobian <- numeric_slope[cbind(row_index, column_index)]
  table$ExpandedLogSlope <- transformed$log_slopes[row_index]
  table$ExpandedSlope <- transformed$slopes[row_index]
  summary <- data.frame(
    Point = point,
    FreeCoordinates = n_free,
    ExpandedLevels = n_levels,
    MinSlope = min(transformed$slopes),
    MaxSlope = max(transformed$slopes),
    GeometricMeanResidual = abs(mean(log(transformed$slopes))),
    MaxAbsLogJacobianDifference = max(abs(log_jacobian - numeric_log)),
    MaxAbsSlopeJacobianDifference = max(abs(slope_jacobian - numeric_slope)),
    Status = if (
      all(is.finite(numeric_log)) && all(is.finite(numeric_slope))
    ) "review_complete" else "rejected",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
  list(table = table, summary = summary)
}

mfrmr_num_gpcm_jacobian_audit <- function(fit, score_results) {
  context <- mfrmr_num_fit_context(fit)
  slope_slice <- context$slices$log_slopes
  levels <- as.character(fit$config$gpcm_spec$levels)
  points <- unique(as.character(
    score_results$Point[score_results$RunId == "gpcm_core"]
  ))
  reviews <- lapply(points, function(point) {
    point_par <- if (identical(point, "retained_solution")) {
      as.numeric(fit$opt$par)
    } else {
      mfrmr_num_probe_point(fit)$par
    }
    mfrmr_num_gpcm_jacobian_from_free(
      point_par[slope_slice],
      levels = levels,
      point = point
    )
  })
  list(
    table = do.call(rbind, lapply(reviews, `[[`, "table")),
    summary = do.call(rbind, lapply(reviews, `[[`, "summary"))
  )
}

mfrmr_num_logprob_bundle <- function(context, par) {
  params <- mfrmr_num_get("expand_params")(par, context$sizes, context$config)
  base_eta <- mfrmr_num_get("compute_base_eta")(
    context$idx, params, context$config
  )
  mfrmr_num_get("mfrm_mml_logprob_bundle")(
    idx = context$idx,
    config = context$config,
    quad = context$quad,
    params = params,
    base_eta = base_eta
  )
}

mfrmr_num_reduction_row <- function(reduction_id, left_context, left_par,
                                    right_context, right_par,
                                    common_right_coordinates) {
  left_objective <- suppressWarnings(as.numeric(left_context$fn(left_par))[1])
  right_objective <- suppressWarnings(as.numeric(right_context$fn(right_par))[1])
  left_score <- suppressWarnings(as.numeric(left_context$gr(left_par)))
  right_score <- suppressWarnings(as.numeric(right_context$gr(right_par)))
  left_bundle <- mfrmr_num_logprob_bundle(left_context, left_par)
  right_bundle <- mfrmr_num_logprob_bundle(right_context, right_par)
  common_right_coordinates <- as.integer(common_right_coordinates)
  valid <- all(is.finite(c(left_objective, right_objective))) &&
    length(common_right_coordinates) > 0L &&
    all(is.finite(common_right_coordinates)) &&
    all(common_right_coordinates > 0L) &&
    all(common_right_coordinates <= length(right_score)) &&
    !anyDuplicated(common_right_coordinates) &&
    length(left_score) == length(common_right_coordinates) &&
    all(is.finite(left_score)) &&
    all(is.finite(right_score[common_right_coordinates])) &&
    identical(dim(left_bundle$log_prob_mat), dim(right_bundle$log_prob_mat)) &&
    all(is.finite(left_bundle$log_prob_mat)) &&
    all(is.finite(right_bundle$log_prob_mat))
  log_probability_difference <- if (valid) {
    max(abs(left_bundle$log_prob_mat - right_bundle$log_prob_mat))
  } else {
    NA_real_
  }
  probability_difference <- if (valid) {
    max(abs(exp(left_bundle$log_prob_mat) - exp(right_bundle$log_prob_mat)))
  } else {
    NA_real_
  }
  objective_difference <- if (valid) {
    abs(left_objective - right_objective)
  } else {
    NA_real_
  }
  score_difference <- if (valid) {
    max(abs(left_score - right_score[common_right_coordinates]))
  } else {
    NA_real_
  }
  exact <- isTRUE(valid && log_probability_difference <= 1e-12 &&
    probability_difference <= 1e-12 && objective_difference <= 1e-10 &&
    score_difference <= 1e-10)
  data.frame(
    Specification = mfrmr_num_specification,
    ContractVersion = mfrmr_num_contract,
    ReductionId = reduction_id,
    LogProbabilityMaxAbsDifference = log_probability_difference,
    ProbabilityMaxAbsDifference = probability_difference,
    ObjectiveAbsDifference = objective_difference,
    CommonScoreMaxAbsDifference = score_difference,
    LeftFreeDimension = length(left_par),
    RightFreeDimension = length(right_par),
    ComparedScoreCoordinates = length(common_right_coordinates),
    ExactReductionObserved = exact,
    Status = if (exact) "review_exact" else "rejected",
    SelectionAuthorized = FALSE,
    ConfirmationAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_num_reduction_audit <- function(fits) {
  required <- c("binary_rsm", "binary_pcm", "pcm_core", "gpcm_core")
  mfrmr_num_assert(
    is.list(fits) && all(required %in% names(fits)),
    "The exact-reduction audit requires binary RSM/PCM and polytomous PCM/GPCM fits."
  )
  binary_rsm <- mfrmr_num_fit_context(fits$binary_rsm)
  binary_pcm <- mfrmr_num_fit_context(fits$binary_pcm)
  mfrmr_num_assert(
    identical(binary_rsm$sizes, binary_pcm$sizes),
    "Binary RSM/PCM free-coordinate dimensions do not match."
  )
  binary_par <- as.numeric(fits$binary_rsm$opt$par)
  binary <- mfrmr_num_reduction_row(
    "binary_rsm_equals_pcm",
    binary_rsm,
    binary_par,
    binary_pcm,
    binary_par,
    seq_along(binary_par)
  )

  pcm <- mfrmr_num_fit_context(fits$pcm_core)
  gpcm <- mfrmr_num_fit_context(fits$gpcm_core)
  pcm_par <- as.numeric(fits$pcm_core$opt$par)
  common_names <- names(pcm$sizes)
  mfrmr_num_assert(
    identical(gpcm$sizes[common_names], pcm$sizes) &&
      identical(names(gpcm$sizes)[seq_along(common_names)], common_names),
    "PCM/GPCM common free-coordinate blocks do not match."
  )
  gpcm_par <- c(
    pcm_par,
    rep(0, as.integer(gpcm$sizes$log_slopes))
  )
  unit_slope <- mfrmr_num_reduction_row(
    "unit_slope_gpcm_equals_pcm",
    pcm,
    pcm_par,
    gpcm,
    gpcm_par,
    seq_along(pcm_par)
  )
  rbind(binary, unit_slope)
}

mfrmr_num_global_summary <- function(score_summary, jacobian_summary,
                                     reduction_results, fixture_manifest) {
  required_score <- c(
    "ReferenceStatus", "MaxAbsDifference", "MaxScaledDifference",
    "MaxNumericStepRange", "RunId", "Point", "SelectionAuthorized",
    "ConfirmationAuthorized"
  )
  mfrmr_num_assert(
    is.data.frame(score_summary) && all(required_score %in% names(score_summary)),
    "`score_summary` is incomplete."
  )
  required_jacobian <- c(
    "Point", "Status", "MaxAbsLogJacobianDifference",
    "MaxAbsSlopeJacobianDifference", "SelectionAuthorized",
    "ConfirmationAuthorized"
  )
  required_reduction <- c(
    "ReductionId", "Status", "ExactReductionObserved",
    "SelectionAuthorized", "ConfirmationAuthorized"
  )
  required_fixture <- c("FixtureId", "SHA256")
  mfrmr_num_assert(
    is.data.frame(jacobian_summary) &&
      all(required_jacobian %in% names(jacobian_summary)),
    "`jacobian_summary` is incomplete."
  )
  mfrmr_num_assert(
    is.data.frame(reduction_results) &&
      all(required_reduction %in% names(reduction_results)),
    "`reduction_results` is incomplete."
  )
  mfrmr_num_assert(
    is.data.frame(fixture_manifest) &&
      all(required_fixture %in% names(fixture_manifest)),
    "`fixture_manifest` is incomplete."
  )
  expected_score_keys <- c(
    "binary_rsm|retained_solution", "binary_rsm|deterministic_probe",
    "binary_pcm|retained_solution", "binary_pcm|deterministic_probe",
    "rsm_core|retained_solution", "rsm_core|deterministic_probe",
    "pcm_core|retained_solution", "pcm_core|deterministic_probe",
    "gpcm_core|retained_solution", "gpcm_core|high_dispersion_probe"
  )
  score_keys <- paste(score_summary$RunId, score_summary$Point, sep = "|")
  complete <- nrow(score_summary) == length(expected_score_keys) &&
    all(!is.na(score_keys)) &&
    identical(sort(score_keys), sort(expected_score_keys)) &&
    !anyDuplicated(score_keys) &&
    all(score_summary$ReferenceStatus == "review_complete") &&
    all(is.finite(score_summary$MaxAbsDifference)) &&
    all(is.finite(score_summary$MaxScaledDifference)) &&
    all(is.finite(score_summary$MaxNumericStepRange)) &&
    all(score_summary$SelectionAuthorized %in% FALSE) &&
    all(score_summary$ConfirmationAuthorized %in% FALSE)
  expected_jacobian_points <- c(
    "retained_solution", "high_dispersion_probe"
  )
  jacobian_complete <- nrow(jacobian_summary) ==
    length(expected_jacobian_points) &&
    all(!is.na(jacobian_summary$Point)) && identical(
    sort(as.character(jacobian_summary$Point)),
    sort(expected_jacobian_points)
  ) && !anyDuplicated(jacobian_summary$Point) &&
    all(jacobian_summary$Status == "review_complete") &&
    all(is.finite(jacobian_summary$MaxAbsLogJacobianDifference)) &&
    all(is.finite(jacobian_summary$MaxAbsSlopeJacobianDifference)) &&
    all(jacobian_summary$SelectionAuthorized %in% FALSE) &&
    all(jacobian_summary$ConfirmationAuthorized %in% FALSE)
  expected_reductions <- c(
    "binary_rsm_equals_pcm", "unit_slope_gpcm_equals_pcm"
  )
  reduction_complete <- nrow(reduction_results) == length(expected_reductions) &&
    all(!is.na(reduction_results$ReductionId)) && identical(
    sort(as.character(reduction_results$ReductionId)),
    sort(expected_reductions)
  ) && !anyDuplicated(reduction_results$ReductionId) &&
    all(reduction_results$Status == "review_exact") &&
    all(reduction_results$ExactReductionObserved %in% TRUE) &&
    all(reduction_results$SelectionAuthorized %in% FALSE) &&
    all(reduction_results$ConfirmationAuthorized %in% FALSE)
  expected_fixtures <- c("binary_fixed", "polytomous_fixed")
  fixtures_complete <- nrow(fixture_manifest) == length(expected_fixtures) &&
    all(!is.na(fixture_manifest$FixtureId)) && identical(
    sort(as.character(fixture_manifest$FixtureId)),
    sort(expected_fixtures)
  ) && !anyDuplicated(fixture_manifest$FixtureId) &&
    all(!is.na(fixture_manifest$SHA256)) &&
    all(grepl("^[0-9a-f]{64}$", fixture_manifest$SHA256))
  data.frame(
    Specification = mfrmr_num_specification,
    ContractVersion = mfrmr_num_contract,
    Status = "review",
    FixedRunCount = length(unique(score_summary$RunId)),
    FixedFixtureCount = nrow(fixture_manifest),
    FixedFixturesComplete = fixtures_complete,
    AllScoreReferencesComplete = complete,
    GpcmTransformationJacobianComplete = jacobian_complete,
    ExactReductionsObserved = reduction_complete,
    MaxAbsScoreDifference = if (complete) {
      max(score_summary$MaxAbsDifference)
    } else {
      NA_real_
    },
    MaxScaledScoreDifference = if (complete) {
      max(score_summary$MaxScaledDifference)
    } else {
      NA_real_
    },
    MaxNumericStepRange = if (complete) {
      max(score_summary$MaxNumericStepRange)
    } else {
      NA_real_
    },
    MaxLogJacobianDifference = if (jacobian_complete) {
      max(jacobian_summary$MaxAbsLogJacobianDifference)
    } else {
      NA_real_
    },
    MaxSlopeJacobianDifference = if (jacobian_complete) {
      max(jacobian_summary$MaxAbsSlopeJacobianDifference)
    } else {
      NA_real_
    },
    ScoreToleranceStatus = "pilot_required",
    EngineParityStatus = "not_run",
    ConfirmationAuthorized = FALSE,
    SelectionAuthorized = FALSE,
    stringsAsFactors = FALSE
  )
}

mfrmr_run_numerical_stationarity_pilot <- function(
    rel_steps = mfrmr_num_step_ladder,
    primary_step = mfrmr_num_primary_step) {
  mfrmr_num_namespace()
  rel_steps <- suppressWarnings(as.numeric(rel_steps))
  primary_step <- suppressWarnings(as.numeric(primary_step))
  mfrmr_num_assert(
    length(rel_steps) >= 3L && length(unique(rel_steps)) == length(rel_steps) &&
      all(is.finite(rel_steps)) && all(rel_steps > 0) &&
      length(primary_step) == 1L && is.finite(primary_step) &&
      primary_step > 0 && primary_step %in% rel_steps,
    "The numerical pilot requires at least three positive steps including the prespecified primary step."
  )
  plan <- mfrmr_num_plan()
  fixtures <- list(
    binary_fixed = mfrmr_num_fixture("binary_fixed"),
    polytomous_fixed = mfrmr_num_fixture("polytomous_fixed")
  )
  fixture_manifest <- do.call(rbind, lapply(fixtures, function(fixture) {
    data.frame(
      FixtureId = fixture$fixture_id,
      Seed = fixture$seed,
      Persons = length(fixture$persons),
      Items = length(fixture$items),
      RatingMin = fixture$rating_min,
      RatingMax = fixture$rating_max,
      Rows = nrow(fixture$data),
      SHA256 = fixture$sha256,
      stringsAsFactors = FALSE
    )
  }))
  fit_fun <- getExportedValue("mfrmr", "fit_mfrm")
  fits <- vector("list", nrow(plan))
  names(fits) <- plan$RunId
  score_rows <- vector("list", nrow(plan))

  for (index in seq_len(nrow(plan))) {
    row <- plan[index, , drop = FALSE]
    fixture <- fixtures[[as.character(row$FixtureId)]]
    fit_args <- list(
      data = fixture$data,
      person = "Person",
      facets = "Item",
      score = "Score",
      rating_min = fixture$rating_min,
      rating_max = fixture$rating_max,
      method = "MML",
      model = as.character(row$Model),
      quad_points = as.integer(row$QuadPoints),
      maxit = as.integer(row$Maxit),
      reltol = as.numeric(row$Reltol),
      optimizer = "L-BFGS-B",
      mml_engine = "direct"
    )
    if (!is.na(row$StepFacet) && nzchar(row$StepFacet)) {
      fit_args$step_facet <- as.character(row$StepFacet)
    }
    if (!is.na(row$SlopeFacet) && nzchar(row$SlopeFacet)) {
      fit_args$slope_facet <- as.character(row$SlopeFacet)
    }
    fit <- suppressMessages(suppressWarnings(do.call(fit_fun, fit_args)))
    mfrmr_num_assert(
      length(fit$opt$par) > 0L && all(is.finite(fit$opt$par)),
      paste0("The fixed ", row$RunId, " fit did not retain a finite parameter vector.")
    )
    fits[[as.character(row$RunId)]] <- fit
    score_rows[[index]] <- mfrmr_num_audit_fit(
      fit,
      row,
      rel_steps = rel_steps
    )
    score_rows[[index]]$FixtureSHA256 <- fixture$sha256
  }

  score_results <- do.call(rbind, score_rows)
  score_summary <- mfrmr_num_score_summarize(
    score_results,
    primary_step = primary_step
  )
  gpcm_jacobian <- mfrmr_num_gpcm_jacobian_audit(
    fits$gpcm_core,
    score_results
  )
  reduction_results <- mfrmr_num_reduction_audit(fits)
  summary <- mfrmr_num_global_summary(
    score_summary,
    gpcm_jacobian$summary,
    reduction_results,
    fixture_manifest
  )
  out <- list(
    specification = mfrmr_num_specification,
    contract_version = mfrmr_num_contract,
    status = "review",
    plan = plan,
    fixture_manifest = fixture_manifest,
    score_results = score_results,
    score_summary = score_summary,
    gpcm_jacobian = gpcm_jacobian,
    reduction_results = reduction_results,
    summary = summary,
    notes = c(
      "The reference differentiates the same retained marginal objective independently with a three-step central-difference ladder.",
      "The bounded-GPCM route is not box-constrained: its audited coordinate map is free log slopes to sum-zero expanded log slopes to positive slopes.",
      "Retained-solution and deterministic nonzero-score probes are both required so a near-zero optimum cannot hide a derivative error.",
      "No score tolerance is frozen; engine parity, confirmation, and selection remain unauthorized."
    ),
    confirmation_authorized = FALSE,
    selection_authorized = FALSE
  )
  class(out) <- c("mfrmr_numerical_stationarity_pilot", class(out))
  out
}
