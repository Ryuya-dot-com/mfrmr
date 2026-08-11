# Draft.83b component-specific G-theory allocation operator prototype.
#
# Repository-internal only. Source the Draft.81 design/algebra and Draft.83a
# incidence prototypes first. This file fits no model, estimates no component,
# computes no interval, and never marks a result decision-ready.

mfrmr_gto_require_primitives <- function() {
  required <- c(
    "mfrmr_gta_hash", "mfrmr_gta_split_facets", "mfrmr_gta_components",
    "mfrmr_gta_validate_design_grid", "mfrmr_gti_effective_values",
    "mfrmr_gti_key", "mfrmr_gti_cv"
  )
  prototype_environment <- environment(mfrmr_gto_require_primitives)
  missing <- required[!vapply(
    required, exists, logical(1L), envir = prototype_environment,
    inherits = TRUE
  )]
  if (length(missing) > 0L) {
    stop(
      "Source the Draft.81 and Draft.83a prototypes before Draft.83b: ",
      paste(missing, collapse = ", "), ".", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gto_validate_spec <- function(spec) {
  mfrmr_gto_require_primitives()
  if (!inherits(spec, "mfrmr_gta_spec")) {
    stop("`spec` must be a Draft.81 typed design.", call. = FALSE)
  }
  if (length(spec$FixedFacets) > 0L) {
    stop("Draft.83b does not transport fixed facets through an allocation operator.",
         call. = FALSE)
  }
  allowed_prior_issues <- "nested_scaling_not_supported"
  blocking <- setdiff(spec$Issues, allowed_prior_issues)
  if (length(blocking) > 0L) {
    stop(
      "The typed design has unresolved issues outside Draft.83b: ",
      paste(blocking, collapse = "; "), ".", call. = FALSE
    )
  }
  unresolved <- spec$EffectMap$UniverseRole == "unresolved" |
    spec$EffectMap$EstimabilityStatus %in% c("aliased", "unsupported")
  if (any(unresolved)) {
    stop("Every allocation component needs resolved, non-aliased semantics.",
         call. = FALSE)
  }
  scaled <- spec$EffectMap$ComponentId != spec$ObjectFacet
  missing_scale <- scaled & !nzchar(spec$EffectMap$ScaleBy)
  if (any(missing_scale)) {
    stop("Every non-universe component needs an explicit ScaleBy map.",
         call. = FALSE)
  }
  scale_facets <- unique(unlist(lapply(
    spec$EffectMap$ScaleBy, mfrmr_gta_split_facets
  ), use.names = FALSE))
  if (any(!scale_facets %in% spec$RandomFacets)) {
    stop("Draft.83b scaling may reference random facets only.",
         call. = FALSE)
  }

  object_nested_children <- spec$NestingGraph$Child[
    spec$NestingGraph$Parent == spec$ObjectFacet
  ]
  if (length(object_nested_children) > 0L) {
    stop(
      "A facet nested within the object needs an explicit superpopulation ",
      "error-role contract before allocation scaling.", call. = FALSE
    )
  }
  invisible(TRUE)
}

mfrmr_gto_validate_column_name <- function(x, argument) {
  x <- as.character(x)
  if (length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop(argument, " must name one nonempty column.", call. = FALSE)
  }
  x
}

mfrmr_gto_prepare_allocation <- function(
    spec, allocation, scenario_col, unit_col, weight_col,
    normalization_tolerance) {
  mfrmr_gto_validate_spec(spec)
  if (!is.data.frame(allocation) || nrow(allocation) == 0L) {
    stop("`allocation` must be a nonempty data frame.", call. = FALSE)
  }
  scenario_col <- mfrmr_gto_validate_column_name(
    scenario_col, "`scenario_col`"
  )
  unit_col <- mfrmr_gto_validate_column_name(unit_col, "`unit_col`")
  weight_col <- mfrmr_gto_validate_column_name(weight_col, "`weight_col`")
  control_columns <- c(scenario_col, unit_col, weight_col)
  if (anyDuplicated(control_columns) ||
      any(control_columns %in% spec$RandomFacets)) {
    stop("Scenario, unit, weight, and random-facet columns must be distinct.",
         call. = FALSE)
  }
  required <- c(control_columns, spec$RandomFacets)
  absent <- setdiff(required, names(allocation))
  if (length(absent) > 0L) {
    stop(
      "The planned allocation is missing columns: ",
      paste(absent, collapse = ", "), ".", call. = FALSE
    )
  }
  if (!is.numeric(allocation[[weight_col]])) {
    stop("Planned allocation weights must be numeric.", call. = FALSE)
  }
  weight <- allocation[[weight_col]]
  if (anyNA(weight) || any(!is.finite(weight)) || any(weight <= 0)) {
    stop("Every planned allocation weight must be finite and strictly positive.",
         call. = FALSE)
  }
  out <- data.frame(
    Scenario = as.character(allocation[[scenario_col]]),
    Unit = as.character(allocation[[unit_col]]),
    lapply(allocation[spec$RandomFacets], as.character),
    Weight = as.numeric(weight),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  if (anyNA(out$Scenario) || any(!nzchar(out$Scenario)) ||
      anyNA(out$Unit) || any(!nzchar(out$Unit))) {
    stop("Scenario and prospective-object unit identities must be nonempty.",
         call. = FALSE)
  }
  for (factor_name in spec$RandomFacets) {
    if (anyNA(out[[factor_name]]) || any(!nzchar(out[[factor_name]]))) {
      stop("Every planned random-facet identity must be nonempty.",
           call. = FALSE)
    }
  }
  cell_columns <- c("Scenario", "Unit", spec$RandomFacets)
  cell_key <- mfrmr_gti_key(out, cell_columns)
  if (anyDuplicated(cell_key)) {
    stop(
      "Each Scenario x Unit x full-facet cell must appear once; replicate ",
      "scaling requires a separate residual/replicate contract.",
      call. = FALSE
    )
  }
  unit_sums <- stats::aggregate(
    out$Weight, by = out[c("Scenario", "Unit")], FUN = sum
  )
  names(unit_sums)[[3L]] <- "WeightSum"
  if (any(abs(unit_sums$WeightSum - 1) > normalization_tolerance)) {
    stop(
      "Planned weights must sum to one within every Scenario x Unit; ",
      "Draft.83b never normalizes them silently.", call. = FALSE
    )
  }
  ordering <- c(lapply(out[c("Scenario", "Unit", spec$RandomFacets)],
                       as.character), list(out$Weight), list(method = "radix"))
  out <- out[do.call(order, ordering), , drop = FALSE]
  row.names(out) <- NULL

  effective_input <- out
  effective_input[[spec$ObjectFacet]] <- out$Unit
  declared <- c(spec$ObjectFacet, spec$RandomFacets)
  effective_all <- mfrmr_gti_effective_values(
    effective_input, declared, spec$NestingGraph
  )
  effective <- effective_all[spec$RandomFacets]
  names(effective) <- spec$RandomFacets
  row.names(effective) <- NULL

  list(
    Data = out,
    Effective = effective,
    UnitSums = unit_sums,
    AllocationHash = mfrmr_gta_hash(out),
    ScenarioColumn = scenario_col,
    UnitColumn = unit_col,
    WeightColumn = weight_col
  )
}

mfrmr_gto_marginal_weights <- function(prepared, scale_by) {
  data <- prepared$Data
  if (length(scale_by) == 0L) {
    out <- unique(data[c("Scenario", "Unit")])
    out$ConditionKey <- "<UNIVERSE>"
    out$MarginalWeight <- 1
    return(out)
  }
  working <- data[c("Scenario", "Unit", "Weight")]
  working$ConditionKey <- mfrmr_gti_key(prepared$Effective, scale_by)
  out <- stats::aggregate(
    working$Weight,
    by = working[c("Scenario", "Unit", "ConditionKey")],
    FUN = sum
  )
  names(out)[[4L]] <- "MarginalWeight"
  out
}

mfrmr_gto_component_operators <- function(prepared, spec) {
  operator_rows <- list()
  marginal_rows <- list()
  cursor <- 0L
  for (component_index in seq_len(nrow(spec$EffectMap))) {
    component <- spec$EffectMap[component_index, , drop = FALSE]
    scale_by <- mfrmr_gta_split_facets(component$ScaleBy)
    marginal <- mfrmr_gto_marginal_weights(prepared, scale_by)
    marginal$ComponentId <- component$ComponentId
    marginal_rows[[component_index]] <- marginal[
      c("Scenario", "Unit", "ComponentId", "ConditionKey",
        "MarginalWeight")
    ]
    groups <- split(
      seq_len(nrow(marginal)),
      interaction(marginal$Scenario, marginal$Unit, drop = TRUE,
                  lex.order = TRUE)
    )
    for (indices in groups) {
      weights <- marginal$MarginalWeight[indices]
      cursor <- cursor + 1L
      operator_rows[[cursor]] <- data.frame(
        Scenario = marginal$Scenario[indices[[1L]]],
        Unit = marginal$Unit[indices[[1L]]],
        ComponentId = component$ComponentId,
        UniverseRole = component$UniverseRole,
        ContainsObject = component$ContainsObject,
        ScaleBy = component$ScaleBy,
        ConditionCount = length(weights),
        ScalingFactor = sum(weights^2),
        EffectiveCount = 1 / sum(weights^2),
        MarginalWeightMin = min(weights),
        MarginalWeightMax = max(weights),
        MarginalWeightCV = mfrmr_gti_cv(weights),
        stringsAsFactors = FALSE
      )
    }
  }
  operators <- do.call(rbind, operator_rows)
  marginals <- do.call(rbind, marginal_rows)
  row.names(operators) <- NULL
  row.names(marginals) <- NULL
  list(Operators = operators, Marginals = marginals)
}

mfrmr_gto_same_weight_map <- function(left, right, tolerance) {
  keys <- union(left$ConditionKey, right$ConditionKey)
  left_weight <- stats::setNames(left$MarginalWeight, left$ConditionKey)[keys]
  right_weight <- stats::setNames(right$MarginalWeight,
                                  right$ConditionKey)[keys]
  left_weight[is.na(left_weight)] <- 0
  right_weight[is.na(right_weight)] <- 0
  all(abs(left_weight - right_weight) <= tolerance)
}

mfrmr_gto_overlap <- function(component_data, operator_data,
                              normalization_tolerance, max_overlap_rows) {
  scenarios <- unique(component_data$Scenario)
  estimated_rows <- sum(vapply(scenarios, function(scenario) {
    units <- unique(component_data$Unit[component_data$Scenario == scenario])
    components <- unique(component_data$ComponentId[
      component_data$Scenario == scenario &
        component_data$ConditionKey != "<UNIVERSE>"
    ])
    choose(length(units), 2L) * length(components)
  }, numeric(1L)))
  if (estimated_rows > max_overlap_rows) {
    stop(
      "The requested cross-unit overlap table exceeds `max_overlap_rows`; ",
      "Draft.83b does not drop pairs silently.", call. = FALSE
    )
  }
  rows <- list()
  cursor <- 0L
  for (scenario in scenarios) {
    scenario_data <- component_data[
      component_data$Scenario == scenario &
        component_data$ConditionKey != "<UNIVERSE>", , drop = FALSE
    ]
    components <- unique(scenario_data$ComponentId)
    units <- unique(scenario_data$Unit)
    if (length(units) < 2L) next
    pairs <- utils::combn(units, 2L, simplify = FALSE)
    for (component_id in components) {
      component_operator <- operator_data[
        operator_data$Scenario == scenario &
          operator_data$ComponentId == component_id, , drop = FALSE
      ]
      contains_object <- unique(component_operator$ContainsObject)
      for (pair in pairs) {
        left <- scenario_data[
          scenario_data$ComponentId == component_id &
            scenario_data$Unit == pair[[1L]], , drop = FALSE
        ]
        right <- scenario_data[
          scenario_data$ComponentId == component_id &
            scenario_data$Unit == pair[[2L]], , drop = FALSE
        ]
        keys <- union(left$ConditionKey, right$ConditionKey)
        left_weight <- stats::setNames(
          left$MarginalWeight, left$ConditionKey
        )[keys]
        right_weight <- stats::setNames(
          right$MarginalWeight, right$ConditionKey
        )[keys]
        left_weight[is.na(left_weight)] <- 0
        right_weight[is.na(right_weight)] <- 0
        overlap <- sum(left_weight * right_weight)
        state <- if (overlap <= normalization_tolerance) {
          "disjoint_support"
        } else if (mfrmr_gto_same_weight_map(
          left, right, normalization_tolerance
        )) {
          "identical_weight_operator"
        } else {
          "partial_or_unequal_overlap"
        }
        cursor <- cursor + 1L
        rows[[cursor]] <- data.frame(
          Scenario = scenario,
          ComponentId = component_id,
          UnitLeft = pair[[1L]],
          UnitRight = pair[[2L]],
          AllocationOverlap = overlap,
          CovarianceMultiplier = if (contains_object) 0 else overlap,
          SharingState = state,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  if (length(rows) == 0L) {
    return(data.frame(
      Scenario = character(), ComponentId = character(),
      UnitLeft = character(), UnitRight = character(),
      AllocationOverlap = numeric(), CovarianceMultiplier = numeric(),
      SharingState = character(), stringsAsFactors = FALSE
    ))
  }
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gto_factor_audit <- function(prepared, spec) {
  rows <- list()
  cursor <- 0L
  for (factor_name in spec$RandomFacets) {
    marginal <- mfrmr_gto_marginal_weights(prepared, factor_name)
    groups <- split(
      seq_len(nrow(marginal)),
      interaction(marginal$Scenario, marginal$Unit, drop = TRUE,
                  lex.order = TRUE)
    )
    for (indices in groups) {
      weights <- marginal$MarginalWeight[indices]
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        Scenario = marginal$Scenario[indices[[1L]]],
        Unit = marginal$Unit[indices[[1L]]],
        Factor = factor_name,
        PlannedLevels = length(weights),
        MarginalWeightMin = min(weights),
        MarginalWeightMax = max(weights),
        MarginalWeightCV = mfrmr_gti_cv(weights),
        Concentration = sum(weights^2),
        EffectiveCount = 1 / sum(weights^2),
        stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gto_unit_design_audit <- function(prepared, spec,
                                        normalization_tolerance) {
  data <- prepared$Data
  full_key <- mfrmr_gti_key(prepared$Effective, spec$RandomFacets)
  working <- data[c("Scenario", "Unit", "Weight")]
  working$FullConditionKey <- full_key
  groups <- split(
    seq_len(nrow(working)),
    interaction(working$Scenario, working$Unit, drop = TRUE,
                lex.order = TRUE)
  )
  rows <- lapply(groups, function(indices) {
    subset <- working[indices, , drop = FALSE]
    weights <- subset$Weight
    effective_subset <- prepared$Effective[indices, , drop = FALSE]
    cartesian <- prod(vapply(effective_subset, function(x) {
      length(unique(x))
    }, integer(1L)))
    nested <- nrow(spec$NestingGraph) > 0L
    data.frame(
      Scenario = subset$Scenario[[1L]],
      Unit = subset$Unit[[1L]],
      PlannedSupportCells = nrow(subset),
      CartesianEffectiveCells = cartesian,
      SupportCoverage = if (nested) NA_real_ else nrow(subset) / cartesian,
      StructuralCellBasis = if (nested) {
        "explicit_planned_nested_support"
      } else {
        "explicit_planned_crossed_support"
      },
      FullWeightMin = min(weights),
      FullWeightMax = max(weights),
      FullWeightCV = mfrmr_gti_cv(weights),
      FullConcentration = sum(weights^2),
      EffectiveFullCells = 1 / sum(weights^2),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gto_scenario_audit <- function(prepared, unit_audit,
                                     normalization_tolerance) {
  data <- prepared$Data
  full_key <- mfrmr_gti_key(prepared$Effective, names(prepared$Effective))
  maps <- data.frame(
    Scenario = data$Scenario, Unit = data$Unit,
    ConditionKey = full_key, MarginalWeight = data$Weight,
    stringsAsFactors = FALSE
  )
  rows <- lapply(unique(data$Scenario), function(scenario) {
    scenario_maps <- maps[maps$Scenario == scenario, , drop = FALSE]
    units <- unique(scenario_maps$Unit)
    reference <- scenario_maps[
      scenario_maps$Unit == units[[1L]], , drop = FALSE
    ]
    homogeneous <- all(vapply(units, function(unit) {
      comparison <- scenario_maps[
        scenario_maps$Unit == unit, , drop = FALSE
      ]
      mfrmr_gto_same_weight_map(
        reference, comparison, normalization_tolerance
      )
    }, logical(1L)))
    unit_rows <- unit_audit[unit_audit$Scenario == scenario, , drop = FALSE]
    data.frame(
      Scenario = scenario,
      UnitCount = length(units),
      HomogeneousFullOperator = homogeneous,
      PlannedSupportCellsMin = min(unit_rows$PlannedSupportCells),
      PlannedSupportCellsMax = max(unit_rows$PlannedSupportCells),
      EffectiveFullCellsMin = min(unit_rows$EffectiveFullCells),
      EffectiveFullCellsMax = max(unit_rows$EffectiveFullCells),
      ScalarAggregationStatus = if (homogeneous) {
        "homogeneous_operator_scalar_available_after_components"
      } else {
        "heterogeneous_unit_specific_only"
      },
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}

mfrmr_gto_operator <- function(
    spec, allocation, scenario_col = "Scenario", unit_col = "Unit",
    weight_col = "Weight", normalization_tolerance = 1e-10,
    max_overlap_rows = 1e6) {
  if (!is.numeric(normalization_tolerance) ||
      length(normalization_tolerance) != 1L ||
      !is.finite(normalization_tolerance) || normalization_tolerance <= 0) {
    stop("`normalization_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  if (!is.numeric(max_overlap_rows) || length(max_overlap_rows) != 1L ||
      !is.finite(max_overlap_rows) || max_overlap_rows < 0) {
    stop("`max_overlap_rows` must be one finite nonnegative number.",
         call. = FALSE)
  }
  prepared <- mfrmr_gto_prepare_allocation(
    spec, allocation, scenario_col, unit_col, weight_col,
    normalization_tolerance
  )
  components <- mfrmr_gto_component_operators(prepared, spec)
  unit_audit <- mfrmr_gto_unit_design_audit(
    prepared, spec, normalization_tolerance
  )
  scenario_audit <- mfrmr_gto_scenario_audit(
    prepared, unit_audit, normalization_tolerance
  )
  factor_audit <- mfrmr_gto_factor_audit(prepared, spec)
  overlap <- mfrmr_gto_overlap(
    components$Marginals, components$Operators,
    normalization_tolerance, max_overlap_rows
  )
  identity <- list(
    Contract = "gtheory_allocation_operator_draft83b_v1",
    DesignHash = spec$DesignHash,
    AllocationHash = prepared$AllocationHash,
    NormalizationTolerance = normalization_tolerance,
    MaxOverlapRows = max_overlap_rows,
    CanonicalAllocation = prepared$Data,
    UnitDesignAudit = unit_audit,
    ScenarioAudit = scenario_audit,
    FactorAudit = factor_audit,
    ComponentOperators = components$Operators,
    CrossUnitOverlap = overlap,
    ResolvedPriorIssues = intersect(
      spec$Issues, "nested_scaling_not_supported"
    )
  )
  operator_hash <- mfrmr_gta_hash(identity)
  structure(c(identity, list(
    ComponentScalingReady = TRUE,
    JointAllocationReady = TRUE,
    CoefficientEligible = FALSE,
    DecisionReady = FALSE,
    OperatorHash = operator_hash,
    MarginalWeights = components$Marginals
  )), class = "mfrmr_gto_operator")
}

mfrmr_gto_apply <- function(spec, operator, components,
                            equality_tolerance = 1e-12) {
  mfrmr_gto_validate_spec(spec)
  if (!inherits(operator, "mfrmr_gto_operator")) {
    stop("`operator` must be a Draft.83b allocation operator.",
         call. = FALSE)
  }
  if (!identical(operator$DesignHash, spec$DesignHash)) {
    stop("The allocation operator design identity does not match `spec`.",
         call. = FALSE)
  }
  if (!is.numeric(equality_tolerance) || length(equality_tolerance) != 1L ||
      !is.finite(equality_tolerance) || equality_tolerance <= 0) {
    stop("`equality_tolerance` must be one finite positive number.",
         call. = FALSE)
  }
  component_table <- mfrmr_gta_components(
    components, spec$EffectMap$ComponentId
  )
  mapped <- operator$ComponentOperators
  mapped$Estimate <- component_table$Estimate[
    match(mapped$ComponentId, component_table$ComponentId)
  ]
  mapped$Contribution <- mapped$ScalingFactor * mapped$Estimate

  groups <- split(
    seq_len(nrow(mapped)),
    interaction(mapped$Scenario, mapped$Unit, drop = TRUE, lex.order = TRUE)
  )
  raw_negative <- any(component_table$Estimate < 0)
  unit_rows <- lapply(groups, function(indices) {
    subset <- mapped[indices, , drop = FALSE]
    universe <- sum(subset$Contribution[
      subset$UniverseRole == "universe_score"
    ])
    relative <- sum(subset$Contribution[
      subset$UniverseRole %in% c("relative_error", "both_errors")
    ])
    absolute <- relative + sum(subset$Contribution[
      subset$UniverseRole == "absolute_only"
    ])
    status <- if (raw_negative) {
      "raw_negative_component"
    } else if (!is.finite(universe) || universe <= 0) {
      "nonpositive_universe_variance"
    } else if (universe + relative <= 0 || universe + absolute <= 0) {
      "nonpositive_coefficient_denominator"
    } else {
      "algebra_ok"
    }
    data.frame(
      Scenario = subset$Scenario[[1L]],
      Unit = subset$Unit[[1L]],
      UniverseVariance = universe,
      RelativeErrorVariance = relative,
      AbsoluteErrorVariance = absolute,
      G = universe / (universe + relative),
      Phi = universe / (universe + absolute),
      AlgebraStatus = status,
      AlgebraReady = identical(status, "algebra_ok"),
      InferenceReady = FALSE,
      DecisionReady = FALSE,
      stringsAsFactors = FALSE
    )
  })
  unit_results <- do.call(rbind, unit_rows)
  row.names(unit_results) <- NULL

  scenario_rows <- lapply(unique(unit_results$Scenario), function(scenario) {
    units <- unit_results[unit_results$Scenario == scenario, , drop = FALSE]
    audit <- operator$ScenarioAudit[
      operator$ScenarioAudit$Scenario == scenario, , drop = FALSE
    ]
    homogeneous_values <- all(is.finite(units$G)) &&
      all(is.finite(units$Phi)) &&
      max(units$G) - min(units$G) <= equality_tolerance &&
      max(units$Phi) - min(units$Phi) <= equality_tolerance
    scalar_ready <- isTRUE(audit$HomogeneousFullOperator) &&
      homogeneous_values && all(units$AlgebraReady)
    status <- if (!all(units$AlgebraReady)) {
      unique(units$AlgebraStatus[!units$AlgebraReady])[[1L]]
    } else if (!isTRUE(audit$HomogeneousFullOperator)) {
      "heterogeneous_unit_specific_only"
    } else if (!homogeneous_values) {
      "operator_equality_invariant_failed"
    } else {
      "homogeneous_operator_scalar_available"
    }
    data.frame(
      Scenario = scenario,
      UnitCount = nrow(units),
      ScalarG = if (scalar_ready) units$G[[1L]] else NA_real_,
      ScalarPhi = if (scalar_ready) units$Phi[[1L]] else NA_real_,
      ScalarStatus = status,
      AlgebraReady = scalar_ready,
      InferenceReady = FALSE,
      DecisionReady = FALSE,
      stringsAsFactors = FALSE
    )
  })
  scenario_results <- do.call(rbind, scenario_rows)
  row.names(scenario_results) <- NULL
  identity <- list(
    Contract = "gtheory_allocation_application_draft83b_v1",
    DesignHash = spec$DesignHash,
    OperatorHash = operator$OperatorHash,
    Components = component_table,
    Contributions = mapped,
    UnitResults = unit_results,
    ScenarioResults = scenario_results,
    EqualityTolerance = equality_tolerance
  )
  result_hash <- mfrmr_gta_hash(identity)
  structure(c(identity, list(
    EstimationReady = FALSE,
    InferenceReady = FALSE,
    DecisionReady = FALSE,
    ResultHash = result_hash
  )), class = "mfrmr_gto_result")
}

mfrmr_gto_crossed_balanced_allocation <- function(
    spec, design_grid, units = 1L) {
  mfrmr_gto_validate_spec(spec)
  if (nrow(spec$NestingGraph) > 0L) {
    stop("The balanced constructor is crossed-only; nested support must be explicit.",
         call. = FALSE)
  }
  if (!is.numeric(units) || length(units) != 1L || !is.finite(units) ||
      units <= 0 || abs(units - round(units)) > 1e-12) {
    stop("`units` must be one positive integer.", call. = FALSE)
  }
  grid <- mfrmr_gta_validate_design_grid(design_grid, spec$RandomFacets)
  rows <- list()
  cursor <- 0L
  for (scenario_index in seq_len(nrow(grid))) {
    levels <- lapply(spec$RandomFacets, function(factor_name) {
      count <- grid[[paste0("n_", factor_name)]][[scenario_index]]
      paste0(factor_name, "_", seq_len(count))
    })
    names(levels) <- spec$RandomFacets
    support <- do.call(
      expand.grid,
      c(levels, list(KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE))
    )
    for (unit_index in seq_len(as.integer(units))) {
      cursor <- cursor + 1L
      rows[[cursor]] <- data.frame(
        Scenario = as.character(grid$Scenario[[scenario_index]]),
        Unit = paste0("Unit_", unit_index),
        support,
        Weight = rep.int(1 / nrow(support), nrow(support)),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    }
  }
  out <- do.call(rbind, rows)
  row.names(out) <- NULL
  out
}
