# JML GPCM lexicographic log-slope rate hierarchy
# ==============================================================================
#
# P1z reduces an unbounded finite-dimensional parameter sequence to convergent
# normalized subsequences and a primary P/Z/L/D log-slope role vector. A zero
# primary-rate coordinate can still diverge at a slower scale. This file
# supplies a pathwise structural recursion for a declared finite hierarchy of
# sum-zero expanded log-slope coefficient vectors.
#
# At stage h only coordinates which were zero at every earlier stage remain
# active. A nonzero stage resolves at least one active coordinate. The first
# nonzero sum-zero stage resolves at least two, so a complete hierarchy has at
# most J - 1 nonzero stages for J slope levels. Later coefficient vectors stay
# sum-zero globally, but their restriction to the active coordinates need not
# be sum-zero: slower compensation may occur in coordinates already resolved
# at a faster scale.
#
# This is a growth-order decomposition, not a likelihood certificate. Additive
# directions and their own slower scales can still change category limits.


mfrmr_jml_gpcm_rate_hierarchy_empty_stage_table <- function() {
  data.frame(
    Stage = integer(0),
    ScaleExponent = numeric(0),
    ActiveCount = integer(0),
    ResolvedCount = integer(0),
    RemainingZeroCount = integer(0),
    ActiveLevels = character(0),
    PositiveLevels = character(0),
    ZeroLevels = character(0),
    LeadingNegativeLevels = character(0),
    DeeperNegativeLevels = character(0),
    RoleSignature = character(0),
    ActiveScaleMagnitude = numeric(0),
    GlobalSumZeroResidual = numeric(0),
    GlobalSumZero = logical(0),
    StageState = character(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_gpcm_rate_hierarchy_empty_level_table <- function() {
  data.frame(
    LevelIndex = integer(0),
    Level = character(0),
    FirstNonzeroStage = integer(0),
    RoleAtResolution = character(0),
    NormalizedLoadingAtResolution = numeric(0),
    Resolved = logical(0),
    stringsAsFactors = FALSE
  )
}

mfrmr_jml_gpcm_rate_hierarchy <- function(
    stage_rates,
    levels = NULL,
    scale_exponents = NULL,
    zero_tolerance = 1e-10) {
  empty_stages <- mfrmr_jml_gpcm_rate_hierarchy_empty_stage_table()
  empty_levels <- mfrmr_jml_gpcm_rate_hierarchy_empty_level_table()
  tolerance <- suppressWarnings(as.numeric(zero_tolerance)[1])
  tolerance_valid <- length(tolerance) == 1L && is.finite(tolerance) &&
    tolerance >= 0
  raw <- tryCatch({
    if (is.null(dim(stage_rates))) {
      matrix(as.numeric(stage_rates), nrow = 1L)
    } else {
      matrix(
        as.numeric(stage_rates),
        nrow = nrow(stage_rates), ncol = ncol(stage_rates),
        dimnames = dimnames(stage_rates)
      )
    }
  }, error = function(e) e)

  finish <- function(state, evaluated, detail, reason_codes,
                     stage_table = empty_stages,
                     level_resolution = empty_levels,
                     n_levels = 0L,
                     declared_stages = 0L,
                     used_stages = 0L,
                     nonzero_stages = 0L,
                     remaining_levels = character(0),
                     scale_order_declared = FALSE,
                     scale_order_valid = FALSE,
                     complete = FALSE) {
    maximum <- max(as.integer(n_levels) - 1L, 0L)
    list(
      contract_version = mfrmr_jml_gpcm_rate_hierarchy_contract_version(),
      state = state,
      evaluated = isTRUE(evaluated),
      complete = isTRUE(complete),
      slope_levels = as.integer(n_levels),
      declared_stages = as.integer(declared_stages),
      used_stages = as.integer(used_stages),
      nonzero_stages = as.integer(nonzero_stages),
      unused_declared_stages = as.integer(max(
        as.integer(declared_stages) - as.integer(used_stages), 0L
      )),
      maximum_nonzero_stages = as.integer(maximum),
      finite_depth_bound_respected = isTRUE(nonzero_stages <= maximum),
      scale_order_declared = isTRUE(scale_order_declared),
      scale_order_valid = isTRUE(scale_order_valid),
      global_sum_zero_each_stage = if (nrow(stage_table) > 0L) {
        all(stage_table$GlobalSumZero)
      } else {
        FALSE
      },
      active_restriction_sum_zero_required = FALSE,
      remaining_unresolved_count = as.integer(length(remaining_levels)),
      remaining_unresolved_levels = as.character(remaining_levels),
      stage_table = stage_table,
      level_resolution = level_resolution,
      structural_growth_hierarchy_classified = isTRUE(complete),
      likelihood_boundary_classified = FALSE,
      common_likelihood_limit_certified = FALSE,
      additive_hierarchy_classified = FALSE,
      global_boundary_classified = FALSE,
      zero_tolerance = tolerance,
      criterion_frozen_for_scientific_claims = FALSE,
      reason_codes = reason_codes,
      detail = detail,
      limitations = paste(
        "The hierarchy classifies only a declared ordered family of expanded",
        "sum-zero log-slope coefficients. It does not infer scales from a",
        "finite optimizer trace, prove that arbitrary normalized directions",
        "share a likelihood limit, or classify additive-coordinate",
        "hierarchies. Completion is a finite coordinate growth-order result,",
        "not a global boundary, finite-maximum, uncertainty, or external-",
        "comparison certificate."
      )
    )
  }

  if (!tolerance_valid) {
    return(finish(
      "not_evaluated_control", FALSE,
      "The hierarchy zero tolerance must be finite and nonnegative.",
      "rate_hierarchy_control_invalid"
    ))
  }
  if (inherits(raw, "error") || length(dim(raw)) != 2L ||
      nrow(raw) < 1L || ncol(raw) < 2L || any(!is.finite(raw))) {
    return(finish(
      "not_evaluated_rate_matrix", FALSE,
      "Stage rates must be a finite numeric matrix with at least two columns.",
      "rate_hierarchy_matrix_invalid"
    ))
  }

  n_stages <- nrow(raw)
  n_levels <- ncol(raw)
  if (is.null(levels)) {
    levels <- colnames(raw) %||% paste0("L", seq_len(n_levels))
  }
  levels <- as.character(levels)
  valid_levels <- length(levels) == n_levels && !anyNA(levels) &&
    all(nzchar(levels)) && !anyDuplicated(levels)
  if (!valid_levels) {
    return(finish(
      "not_evaluated_levels", FALSE,
      "Slope level labels must be nonmissing, nonempty, unique, and dimension-matched.",
      "rate_hierarchy_levels_invalid",
      n_levels = n_levels,
      declared_stages = n_stages
    ))
  }

  scale_declared <- !is.null(scale_exponents)
  if (scale_declared) {
    exponents <- suppressWarnings(as.numeric(scale_exponents))
    scale_valid <- length(exponents) == n_stages &&
      all(is.finite(exponents)) && all(exponents > 0) &&
      (n_stages == 1L || all(diff(exponents) < 0))
  } else {
    exponents <- rep(NA_real_, n_stages)
    scale_valid <- TRUE
  }
  if (!scale_valid) {
    return(finish(
      "not_evaluated_scale_order", FALSE,
      "Declared scale exponents must be finite, positive, and strictly decreasing.",
      "rate_hierarchy_scale_order_invalid",
      n_levels = n_levels,
      declared_stages = n_stages,
      scale_order_declared = scale_declared
    ))
  }

  row_scale <- apply(abs(raw), 1L, max)
  sum_residual <- rowSums(raw)
  sum_zero <- abs(sum_residual) <= tolerance *
    pmax(1, row_scale) * n_levels
  if (!all(sum_zero)) {
    return(finish(
      "not_evaluated_identification", FALSE,
      "Every expanded log-slope coefficient vector must satisfy the sum-zero identification.",
      "rate_hierarchy_sum_zero_invalid",
      n_levels = n_levels,
      declared_stages = n_stages,
      scale_order_declared = scale_declared,
      scale_order_valid = TRUE
    ))
  }

  active <- seq_len(n_levels)
  first_stage <- rep(NA_integer_, n_levels)
  resolution_role <- rep(NA_character_, n_levels)
  resolution_loading <- rep(NA_real_, n_levels)
  stage_rows <- vector("list", n_stages)
  used <- 0L
  nonzero <- 0L
  stalled <- FALSE

  for (stage in seq_len(n_stages)) {
    if (length(active) == 0L) break
    used <- stage
    active_values <- raw[stage, active]
    active_magnitude <- max(abs(active_values))
    normalized <- if (active_magnitude > tolerance) {
      active_values / active_magnitude
    } else {
      rep(0, length(active_values))
    }
    positive <- normalized > tolerance
    negative <- normalized < -tolerance
    zero <- !(positive | negative)
    leading <- rep(FALSE, length(active))
    deeper <- rep(FALSE, length(active))
    if (any(negative)) {
      leading_value <- max(normalized[negative])
      leading <- negative & abs(normalized - leading_value) <= tolerance
      deeper <- negative & !leading
    }
    roles <- rep("Z", length(active))
    roles[positive] <- "P"
    roles[leading] <- "L"
    roles[deeper] <- "D"
    resolved <- active[!zero]
    unresolved <- active[zero]
    if (length(resolved) > 0L) {
      nonzero <- nonzero + 1L
      positions <- match(resolved, active)
      first_stage[resolved] <- stage
      resolution_role[resolved] <- roles[positions]
      resolution_loading[resolved] <- normalized[positions]
      stage_state <- if (length(unresolved) == 0L) {
        "resolved_all_remaining_levels"
      } else {
        "resolved_subset"
      }
    } else {
      stalled <- TRUE
      stage_state <- "stalled_zero_active_loading"
    }
    full_roles <- rep(".", n_levels)
    full_roles[active] <- roles
    collapse_levels <- function(index) {
      if (length(index) == 0L) "" else paste(levels[index], collapse = ";")
    }
    stage_rows[[stage]] <- data.frame(
      Stage = as.integer(stage),
      ScaleExponent = exponents[stage],
      ActiveCount = as.integer(length(active)),
      ResolvedCount = as.integer(length(resolved)),
      RemainingZeroCount = as.integer(length(unresolved)),
      ActiveLevels = collapse_levels(active),
      PositiveLevels = collapse_levels(active[positive]),
      ZeroLevels = collapse_levels(active[zero]),
      LeadingNegativeLevels = collapse_levels(active[leading]),
      DeeperNegativeLevels = collapse_levels(active[deeper]),
      RoleSignature = paste(full_roles, collapse = ""),
      ActiveScaleMagnitude = as.numeric(active_magnitude),
      GlobalSumZeroResidual = as.numeric(sum_residual[stage]),
      GlobalSumZero = isTRUE(sum_zero[stage]),
      StageState = stage_state,
      stringsAsFactors = FALSE
    )
    active <- unresolved
    if (stalled) break
  }

  stage_rows <- stage_rows[!vapply(stage_rows, is.null, logical(1))]
  stage_table <- if (length(stage_rows) > 0L) {
    do.call(rbind, stage_rows)
  } else {
    empty_stages
  }
  level_resolution <- data.frame(
    LevelIndex = seq_len(n_levels),
    Level = levels,
    FirstNonzeroStage = first_stage,
    RoleAtResolution = resolution_role,
    NormalizedLoadingAtResolution = resolution_loading,
    Resolved = !is.na(first_stage),
    stringsAsFactors = FALSE
  )
  complete <- length(active) == 0L
  state <- if (complete) {
    "complete_finite_rate_hierarchy"
  } else if (stalled) {
    "incomplete_zero_active_loading"
  } else {
    "declared_depth_exhausted"
  }
  reason <- if (complete) {
    "finite_log_slope_growth_hierarchy_resolved"
  } else if (stalled) {
    "active_zero_coordinates_not_resolved_at_declared_stage"
  } else {
    "additional_slower_scale_required"
  }
  detail <- if (complete) {
    paste(
      "The declared lexicographic coefficient family resolves every slope",
      "level after", nonzero, "nonzero stage(s)."
    )
  } else {
    paste(
      length(active), "slope level(s) remain zero at every usable declared",
      "stage and require a slower scale or a bounded-remainder decision."
    )
  }
  finish(
    state, TRUE, detail, reason,
    stage_table = stage_table,
    level_resolution = level_resolution,
    n_levels = n_levels,
    declared_stages = n_stages,
    used_stages = used,
    nonzero_stages = nonzero,
    remaining_levels = levels[active],
    scale_order_declared = scale_declared,
    scale_order_valid = TRUE,
    complete = complete
  )
}
