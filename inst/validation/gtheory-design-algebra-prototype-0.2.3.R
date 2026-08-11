# Draft.81 typed G-theory design parser and balanced D-study algebra oracle.
#
# This repository-internal prototype performs no model fitting and is not a
# public API. It supports only the explicitly gated crossed balanced-count
# algebra described in the companion contract.

mfrmr_gta_formula_tools <- function() {
  if (requireNamespace("reformulas", quietly = TRUE)) {
    return(list(
      findbars = getExportedValue("reformulas", "findbars"),
      nobars = getExportedValue("reformulas", "nobars"),
      backend = paste0(
        "reformulas@", as.character(utils::packageVersion("reformulas"))
      )
    ))
  }
  if (requireNamespace("lme4", quietly = TRUE)) {
    return(list(
      findbars = getFromNamespace("findbars", "lme4"),
      nobars = getFromNamespace("nobars", "lme4"),
      backend = paste0("lme4@", as.character(utils::packageVersion("lme4")))
    ))
  }
  stop(
    "The Draft.81 parser requires `reformulas` or `lme4`.",
    call. = FALSE
  )
}

mfrmr_gta_deparse1 <- function(x) {
  paste(deparse(x, width.cutoff = 500L), collapse = " ")
}

mfrmr_gta_original_bars <- function(x) {
  found <- list()
  walk <- function(node) {
    if (!is.call(node)) return(invisible(NULL))
    operator <- as.character(node[[1L]])
    if (operator %in% c("|", "||")) {
      found[[length(found) + 1L]] <<- node
      return(invisible(NULL))
    }
    for (index in seq.int(2L, length(node))) walk(node[[index]])
    invisible(NULL)
  }
  walk(x)
  found
}

mfrmr_gta_is_intercept <- function(x) {
  is.numeric(x) && length(x) == 1L && is.finite(x) && x == 1
}

mfrmr_gta_is_colon_group <- function(x) {
  if (is.name(x)) return(TRUE)
  if (!is.call(x) || !identical(as.character(x[[1L]]), ":") ||
      length(x) != 3L) return(FALSE)
  mfrmr_gta_is_colon_group(x[[2L]]) && mfrmr_gta_is_colon_group(x[[3L]])
}

mfrmr_gta_has_operator <- function(x, operator) {
  if (!is.call(x)) return(FALSE)
  if (identical(as.character(x[[1L]]), operator)) return(TRUE)
  any(vapply(
    as.list(x)[-1L], mfrmr_gta_has_operator, logical(1L),
    operator = operator
  ))
}

mfrmr_gta_nesting_chain <- function(x) {
  if (is.name(x)) return(as.character(x))
  if (!is.call(x) || !identical(as.character(x[[1L]]), "/") ||
      length(x) != 3L) {
    stop(
      "Draft.81 nesting grammar accepts only simple chains such as `Site/Rater`.",
      call. = FALSE
    )
  }
  c(mfrmr_gta_nesting_chain(x[[2L]]), mfrmr_gta_nesting_chain(x[[3L]]))
}

mfrmr_gta_formula_nesting <- function(original_bars) {
  chains <- lapply(original_bars, function(bar) {
    grouping <- bar[[3L]]
    if (!mfrmr_gta_has_operator(grouping, "/")) return(character())
    mfrmr_gta_nesting_chain(grouping)
  })
  chains <- chains[lengths(chains) > 0L]
  if (length(chains) == 0L) {
    return(data.frame(
      Parent = character(), Child = character(),
      stringsAsFactors = FALSE
    ))
  }
  edges <- lapply(chains, function(chain) {
    if (length(chain) < 2L) return(NULL)
    data.frame(
      Parent = chain[-length(chain)], Child = chain[-1L],
      stringsAsFactors = FALSE
    )
  })
  unique(do.call(rbind, edges))
}

mfrmr_gta_normalize_nesting <- function(nesting, declared) {
  if (is.null(nesting)) {
    return(data.frame(
      Parent = character(), Child = character(),
      stringsAsFactors = FALSE
    ))
  }
  if (!is.data.frame(nesting) ||
      !all(c("Parent", "Child") %in% names(nesting))) {
    stop("`nesting` must be a data frame with Parent and Child columns.",
         call. = FALSE)
  }
  out <- data.frame(
    Parent = as.character(nesting$Parent),
    Child = as.character(nesting$Child),
    stringsAsFactors = FALSE
  )
  if (anyNA(out) || any(!nzchar(out$Parent)) || any(!nzchar(out$Child))) {
    stop("`nesting` contains a missing or empty facet name.", call. = FALSE)
  }
  if (any(!c(out$Parent, out$Child) %in% declared)) {
    stop("Every nesting parent and child must be a declared object or facet.",
         call. = FALSE)
  }
  if (any(out$Parent == out$Child)) {
    stop("A nesting graph cannot contain a self-edge.", call. = FALSE)
  }
  out <- unique(out)

  for (start in declared) {
    frontier <- start
    visited <- character()
    while (length(frontier) > 0L) {
      current <- frontier[[1L]]
      frontier <- frontier[-1L]
      children <- out$Child[out$Parent == current]
      if (start %in% children) {
        stop("The nesting graph must be acyclic.", call. = FALSE)
      }
      new_children <- setdiff(children, visited)
      visited <- union(visited, new_children)
      frontier <- union(frontier, new_children)
    }
  }
  order_index <- match(out$Parent, declared) * (length(declared) + 1L) +
    match(out$Child, declared)
  out <- out[order(order_index), , drop = FALSE]
  row.names(out) <- NULL
  out
}

mfrmr_gta_canonical_members <- function(members, declared) {
  members <- unique(as.character(members))
  position <- match(members, declared)
  if (anyNA(position)) {
    stop("A random-effect grouping term uses an undeclared variable.",
         call. = FALSE)
  }
  members[order(position)]
}

mfrmr_gta_component_id <- function(members, declared) {
  paste(mfrmr_gta_canonical_members(members, declared), collapse = ":")
}

mfrmr_gta_expected_crossed <- function(declared) {
  out <- character()
  for (size in seq_len(length(declared) - 1L)) {
    sets <- utils::combn(declared, size, simplify = FALSE)
    out <- c(out, vapply(sets, paste, collapse = ":", character(1L)))
  }
  out
}

mfrmr_gta_hash <- function(x) {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("The Draft.81 identity contract requires the suggested `digest` package.",
         call. = FALSE)
  }
  digest::digest(x, algo = "sha256", serialize = TRUE)
}

mfrmr_gta_spec <- function(formula, object, facets,
                           fixed_facets = character(), nesting = NULL,
                           residual_scale_by = NULL,
                           residual_role = "both_errors",
                           cell_replication = FALSE) {
  if (!inherits(formula, "formula") || length(formula) != 3L) {
    stop("`formula` must be a two-sided formula.", call. = FALSE)
  }
  object <- as.character(object)
  facets <- as.character(facets)
  fixed_facets <- as.character(fixed_facets)
  if (length(object) != 1L || is.na(object) || !nzchar(object)) {
    stop("`object` must name exactly one object of measurement.",
         call. = FALSE)
  }
  if (anyNA(facets) || any(!nzchar(facets)) || anyDuplicated(facets) ||
      object %in% facets) {
    stop("`facets` must be unique, nonempty, and exclude `object`.",
         call. = FALSE)
  }
  if (any(!fixed_facets %in% facets) || anyDuplicated(fixed_facets)) {
    stop("`fixed_facets` must be a unique subset of `facets`.",
         call. = FALSE)
  }
  if (length(cell_replication) != 1L || is.na(cell_replication)) {
    stop("`cell_replication` must be TRUE or FALSE.", call. = FALSE)
  }
  cell_replication <- isTRUE(cell_replication)
  random_facets <- facets[!facets %in% fixed_facets]
  declared <- c(object, facets)

  response <- all.vars(formula[[2L]])
  if (length(response) != 1L || !identical(response, as.character(formula[[2L]]))) {
    stop("The response must be one untransformed score column.", call. = FALSE)
  }

  formula_tools <- mfrmr_gta_formula_tools()
  original_bars <- mfrmr_gta_original_bars(formula[[3L]])
  bars <- formula_tools$findbars(formula)
  if (length(bars) == 0L) {
    stop("The formula must contain random-intercept terms.", call. = FALSE)
  }
  fixed_formula <- formula_tools$nobars(formula)
  fixed_terms <- attr(stats::terms(fixed_formula), "term.labels")
  fixed_intercept <- attr(stats::terms(fixed_formula), "intercept")
  if (length(fixed_terms) > 0L || !identical(fixed_intercept, 1L)) {
    stop("Draft.81 supports an intercept-only fixed part.", call. = FALSE)
  }

  parsed <- lapply(bars, function(bar) {
    if (!mfrmr_gta_is_intercept(bar[[2L]])) {
      stop("Draft.81 accepts random intercepts only; random slopes are unsupported.",
           call. = FALSE)
    }
    grouping <- bar[[3L]]
    if (!mfrmr_gta_is_colon_group(grouping)) {
      stop("Expanded grouping terms must be names joined only by `:`.",
           call. = FALSE)
    }
    members <- mfrmr_gta_canonical_members(all.vars(grouping), declared)
    list(
      ComponentId = paste(members, collapse = ":"),
      Members = members,
      FormulaTerm = paste0("(1 | ", paste(members, collapse = ":"), ")")
    )
  })
  component_ids <- vapply(parsed, `[[`, character(1L), "ComponentId")
  if (anyDuplicated(component_ids)) {
    stop("The expanded formula contains duplicate semantic components.",
         call. = FALSE)
  }

  formula_nesting <- mfrmr_gta_normalize_nesting(
    mfrmr_gta_formula_nesting(original_bars), declared
  )
  nesting_map <- mfrmr_gta_normalize_nesting(nesting, declared)
  if (nrow(formula_nesting) > 0L && nrow(nesting_map) > 0L) {
    formula_edges <- paste(formula_nesting$Parent, formula_nesting$Child,
                           sep = ">")
    supplied_edges <- paste(nesting_map$Parent, nesting_map$Child, sep = ">")
    if (!all(formula_edges %in% supplied_edges)) {
      stop("Explicit nesting metadata contradicts the formula nesting chain.",
           call. = FALSE)
    }
  }

  order_key <- vapply(parsed, function(term) {
    positions <- match(term$Members, declared)
    length(positions) * 1000 + sum(positions * 10^rev(seq_along(positions)))
  }, numeric(1L))
  parsed <- parsed[order(order_key, component_ids)]

  effect_rows <- lapply(parsed, function(term) {
    members <- term$Members
    contains_object <- object %in% members
    role <- if (identical(members, object)) {
      "universe_score"
    } else if (any(members %in% fixed_facets)) {
      "unresolved"
    } else if (contains_object) {
      "both_errors"
    } else {
      "absolute_only"
    }
    scale_by <- if (identical(role, "universe_score")) {
      character()
    } else {
      setdiff(members, object)
    }
    relevant_edges <- nesting_map[nesting_map$Child %in% members, , drop = FALSE]
    data.frame(
      ComponentId = term$ComponentId,
      FormulaTerm = term$FormulaTerm,
      Members = paste(members, collapse = ":"),
      ContainsObject = contains_object,
      UniverseRole = role,
      ScaleBy = paste(scale_by, collapse = ":"),
      NestingParents = paste(
        paste(relevant_edges$Parent, relevant_edges$Child, sep = ">"),
        collapse = ";"
      ),
      ObservedCellReplication = cell_replication,
      ComponentForm = "random_intercept",
      EstimabilityStatus = "identified",
      stringsAsFactors = FALSE
    )
  })
  effect_map <- do.call(rbind, effect_rows)
  residual_scale_by <- as.character(residual_scale_by)
  if (length(residual_scale_by) > 0L) {
    residual_scale_by <- mfrmr_gta_canonical_members(
      residual_scale_by, declared
    )
    if (object %in% residual_scale_by ||
        any(residual_scale_by %in% fixed_facets)) {
      stop("`residual_scale_by` may contain random facets only.",
           call. = FALSE)
    }
  }
  allowed_roles <- c(
    "universe_score", "relative_error", "absolute_only", "both_errors",
    "fixed_condition", "unresolved"
  )
  residual_role <- as.character(residual_role)
  if (length(residual_role) != 1L || !residual_role %in% allowed_roles) {
    stop("`residual_role` is not a recognized universe role.", call. = FALSE)
  }
  residual_status <- if (length(residual_scale_by) == 0L ||
                         identical(residual_role, "unresolved")) {
    "unresolved"
  } else {
    "identified"
  }
  effect_map <- rbind(
    effect_map,
    data.frame(
      ComponentId = "Residual",
      FormulaTerm = NA_character_,
      Members = "Residual",
      ContainsObject = TRUE,
      UniverseRole = if (length(residual_scale_by) == 0L) {
        "unresolved"
      } else {
        residual_role
      },
      ScaleBy = paste(residual_scale_by, collapse = ":"),
      NestingParents = "",
      ObservedCellReplication = cell_replication,
      ComponentForm = "collapsed_highest_order_residual",
      EstimabilityStatus = residual_status,
      stringsAsFactors = FALSE
    )
  )

  issues <- character()
  if (nrow(formula_nesting) > 0L && nrow(nesting_map) == 0L) {
    issues <- c(issues, "unresolved_nesting_metadata")
  }
  if (nrow(nesting_map) > 0L) issues <- c(issues, "nested_scaling_not_supported")
  if (length(fixed_facets) > 0L) {
    issues <- c(issues, "fixed_facet_scaling_not_supported")
  }
  if (!length(random_facets) %in% 1:2) {
    issues <- c(issues, "random_facet_count_not_supported")
  }
  if (any(effect_map$UniverseRole == "unresolved")) {
    issues <- c(issues, "unresolved_component_semantics")
  }

  highest_id <- paste(declared[c(TRUE, facets %in% random_facets)],
                      collapse = ":")
  highest_present <- highest_id %in% effect_map$ComponentId
  if (highest_present && !cell_replication) {
    effect_map$EstimabilityStatus[
      effect_map$ComponentId %in% c(highest_id, "Residual")
    ] <- "aliased"
    issues <- c(issues, "highest_order_residual_alias")
  } else if (highest_present && cell_replication) {
    issues <- c(issues, "replicated_saturated_scaling_not_supported")
  }

  if (nrow(formula_nesting) == 0L && nrow(nesting_map) == 0L &&
      length(fixed_facets) == 0L &&
      length(random_facets) %in% 1:2) {
    crossed_declared <- c(object, random_facets)
    expected <- mfrmr_gta_expected_crossed(crossed_declared)
    actual <- setdiff(effect_map$ComponentId, "Residual")
    missing <- setdiff(expected, actual)
    extra <- setdiff(actual, c(expected, paste(crossed_declared, collapse = ":")))
    if (length(missing) > 0L) {
      issues <- c(issues, paste0(
        "missing_crossed_components:", paste(missing, collapse = ",")
      ))
    }
    if (length(extra) > 0L) {
      issues <- c(issues, paste0(
        "unsupported_crossed_components:", paste(extra, collapse = ",")
      ))
    }
    if (length(residual_scale_by) > 0L &&
        !setequal(residual_scale_by, random_facets)) {
      issues <- c(issues, "residual_scaling_must_use_all_random_facets")
    }
    if (!identical(residual_role, "both_errors")) {
      issues <- c(issues, "residual_role_must_be_both_errors")
    }
  }
  issues <- unique(issues)

  canonical_terms <- effect_map$FormulaTerm[!is.na(effect_map$FormulaTerm)]
  formula_canonical <- paste(
    response, "~ 1 +", paste(canonical_terms, collapse = " + ")
  )
  identity_payload <- list(
    Contract = "gtheory_design_algebra_draft81_v1",
    ScoreColumn = response,
    ObjectFacet = object,
    RandomFacets = random_facets,
    FixedFacets = fixed_facets,
    FormulaCanonical = formula_canonical,
    FormulaNesting = formula_nesting,
    NestingGraph = nesting_map,
    EffectMap = effect_map,
    CellReplication = cell_replication,
    ParserBackend = formula_tools$backend,
    Issues = issues
  )
  design_hash <- mfrmr_gta_hash(identity_payload)
  structure(
    c(identity_payload, list(
      DesignHash = design_hash,
      DStudyEligible = length(issues) == 0L,
      OriginalFormula = mfrmr_gta_deparse1(formula)
    )),
    class = "mfrmr_gta_spec"
  )
}

mfrmr_gta_split_facets <- function(x) {
  if (is.na(x) || !nzchar(x)) return(character())
  strsplit(x, ":", fixed = TRUE)[[1L]]
}

mfrmr_gta_components <- function(components, required_ids) {
  if (is.numeric(components) && !is.null(names(components))) {
    out <- data.frame(
      ComponentId = names(components), Estimate = as.numeric(components),
      stringsAsFactors = FALSE
    )
  } else if (is.data.frame(components) &&
             all(c("ComponentId", "Estimate") %in% names(components))) {
    if (!is.numeric(components$Estimate)) {
      stop("The `Estimate` column must be numeric, not coercible labels.",
           call. = FALSE)
    }
    out <- data.frame(
      ComponentId = as.character(components$ComponentId),
      Estimate = components$Estimate,
      stringsAsFactors = FALSE
    )
  } else {
    stop(
      "`components` must be a named numeric vector or a ComponentId/Estimate data frame.",
      call. = FALSE
    )
  }
  if (anyNA(out$ComponentId) || any(!nzchar(out$ComponentId)) ||
      anyDuplicated(out$ComponentId)) {
    stop("Component identifiers must be nonmissing and unique.",
         call. = FALSE)
  }
  if (anyNA(out$Estimate) || any(!is.finite(out$Estimate))) {
    stop("Every variance-component estimate must be finite.", call. = FALSE)
  }
  missing <- setdiff(required_ids, out$ComponentId)
  extra <- setdiff(out$ComponentId, required_ids)
  if (length(missing) > 0L || length(extra) > 0L) {
    stop(paste0(
      "Component identities do not match the effect map; missing=[",
      paste(missing, collapse = ","), "], extra=[",
      paste(extra, collapse = ","), "]."
    ), call. = FALSE)
  }
  out <- out[match(required_ids, out$ComponentId), , drop = FALSE]
  row.names(out) <- NULL
  out
}

mfrmr_gta_validate_design_grid <- function(design_grid, facets) {
  if (!is.data.frame(design_grid) || nrow(design_grid) < 1L) {
    stop("`design_grid` must be a nonempty data frame.", call. = FALSE)
  }
  count_columns <- paste0("n_", facets)
  if (!all(count_columns %in% names(design_grid))) {
    stop(paste0(
      "The balanced design grid requires columns: ",
      paste(count_columns, collapse = ", "), "."
    ), call. = FALSE)
  }
  for (column in count_columns) {
    value <- design_grid[[column]]
    if (!is.numeric(value) || anyNA(value) || any(!is.finite(value)) ||
        any(value <= 0) || any(abs(value - round(value)) > 1e-12)) {
      stop("Balanced planned facet counts must be positive integers.",
           call. = FALSE)
    }
  }
  out <- design_grid
  if (!"Scenario" %in% names(out)) {
    out$Scenario <- paste0("scenario_", seq_len(nrow(out)))
  }
  if (anyNA(out$Scenario) || any(!nzchar(as.character(out$Scenario))) ||
      anyDuplicated(as.character(out$Scenario))) {
    stop("Scenario identifiers must be nonmissing and unique.",
         call. = FALSE)
  }
  row.names(out) <- NULL
  out
}

mfrmr_gta_d_study <- function(spec, components, design_grid) {
  if (!inherits(spec, "mfrmr_gta_spec")) {
    stop("`spec` must be a Draft.81 typed G-theory specification.",
         call. = FALSE)
  }
  if (!isTRUE(spec$DStudyEligible)) {
    stop(paste0(
      "The typed design is not eligible for coefficient calculation: ",
      paste(spec$Issues, collapse = "; "), "."
    ), call. = FALSE)
  }
  unresolved <- spec$EffectMap$UniverseRole == "unresolved" |
    spec$EffectMap$EstimabilityStatus == "aliased"
  if (any(unresolved)) {
    stop("Every component must have resolved, non-aliased semantics.",
         call. = FALSE)
  }
  component_table <- mfrmr_gta_components(
    components, spec$EffectMap$ComponentId
  )
  grid <- mfrmr_gta_validate_design_grid(design_grid, spec$RandomFacets)
  mapped <- merge(
    spec$EffectMap, component_table,
    by = "ComponentId", sort = FALSE, all.x = TRUE
  )
  mapped <- mapped[match(spec$EffectMap$ComponentId, mapped$ComponentId),
                   , drop = FALSE]

  contribution_rows <- vector("list", nrow(grid))
  scenario_rows <- vector("list", nrow(grid))
  for (row in seq_len(nrow(grid))) {
    divisor <- vapply(mapped$ScaleBy, function(scale_by) {
      facets <- mfrmr_gta_split_facets(scale_by)
      if (length(facets) == 0L) return(1)
      prod(vapply(
        facets, function(facet) grid[[paste0("n_", facet)]][row],
        numeric(1L)
      ))
    }, numeric(1L))
    scaled <- mapped$Estimate / divisor
    enters_relative <- mapped$UniverseRole %in%
      c("relative_error", "both_errors")
    enters_absolute <- mapped$UniverseRole %in%
      c("relative_error", "absolute_only", "both_errors")
    relative_contribution <- ifelse(enters_relative, scaled, 0)
    absolute_contribution <- ifelse(enters_absolute, scaled, 0)
    universe <- sum(mapped$Estimate[
      mapped$UniverseRole == "universe_score"
    ])
    relative_error <- sum(relative_contribution)
    absolute_error <- sum(absolute_contribution)
    relative_denominator <- universe + relative_error
    absolute_denominator <- universe + absolute_error
    coefficient_g <- if (relative_denominator > 0) {
      universe / relative_denominator
    } else {
      NA_real_
    }
    coefficient_phi <- if (absolute_denominator > 0) {
      universe / absolute_denominator
    } else {
      NA_real_
    }
    negative <- any(mapped$Estimate < 0)
    valid_denominators <- is.finite(coefficient_g) &&
      is.finite(coefficient_phi) && universe >= 0
    status <- if (negative) {
      "raw_negative_component"
    } else if (!valid_denominators) {
      "invalid_denominator"
    } else {
      "algebra_ok"
    }
    scenario_rows[[row]] <- data.frame(
      Scenario = as.character(grid$Scenario[row]),
      UniverseVariance = universe,
      RelativeErrorVariance = relative_error,
      AbsoluteErrorVariance = absolute_error,
      G = coefficient_g,
      Phi = coefficient_phi,
      AlgebraStatus = status,
      AlgebraReady = identical(status, "algebra_ok"),
      DecisionReady = FALSE,
      DecisionStatus = "prototype_no_estimation_or_uncertainty",
      stringsAsFactors = FALSE
    )
    count_values <- grid[row, paste0("n_", spec$RandomFacets), drop = FALSE]
    scenario_rows[[row]] <- cbind(
      grid[row, c("Scenario", setdiff(names(count_values), "Scenario")),
           drop = FALSE],
      scenario_rows[[row]][, -1L, drop = FALSE]
    )
    contribution_rows[[row]] <- data.frame(
      Scenario = as.character(grid$Scenario[row]),
      ComponentId = mapped$ComponentId,
      Estimate = mapped$Estimate,
      UniverseRole = mapped$UniverseRole,
      ScaleBy = mapped$ScaleBy,
      Divisor = divisor,
      ScaledVariance = scaled,
      RelativeContribution = relative_contribution,
      AbsoluteContribution = absolute_contribution,
      stringsAsFactors = FALSE
    )
  }
  scenarios <- do.call(rbind, scenario_rows)
  row.names(scenarios) <- NULL
  contributions <- do.call(rbind, contribution_rows)
  row.names(contributions) <- NULL
  payload <- list(
    Contract = "gtheory_balanced_dstudy_draft81_v1",
    DesignHash = spec$DesignHash,
    Components = component_table,
    DesignGrid = grid,
    Scenarios = scenarios,
    Contributions = contributions
  )
  structure(
    c(payload, list(ResultHash = mfrmr_gta_hash(payload))),
    class = "mfrmr_gta_d_study"
  )
}

mfrmr_gta_fixture <- function(design = c("pxi", "pxrxi")) {
  design <- match.arg(design)
  if (identical(design, "pxi")) {
    spec <- mfrmr_gta_spec(
      Score ~ 1 + (1 | Person) + (1 | Item),
      object = "Person", facets = "Item",
      residual_scale_by = "Item"
    )
    return(list(
      spec = spec,
      components = c(Person = 1, Item = 0.2, Residual = 0.8),
      design_grid = data.frame(Scenario = "n_item_4", n_Item = 4L),
      expected = data.frame(
        UniverseVariance = 1,
        RelativeErrorVariance = 0.2,
        AbsoluteErrorVariance = 0.25,
        G = 1 / 1.2,
        Phi = 1 / 1.25
      )
    ))
  }
  spec <- mfrmr_gta_spec(
    Score ~ 1 +
      (1 | Person) + (1 | Rater) + (1 | Item) +
      (1 | Person:Rater) + (1 | Person:Item) + (1 | Rater:Item),
    object = "Person", facets = c("Rater", "Item"),
    residual_scale_by = c("Rater", "Item")
  )
  list(
    spec = spec,
    components = c(
      Person = 1, Rater = 0.12, Item = 0.18,
      `Person:Rater` = 0.24, `Person:Item` = 0.30,
      `Rater:Item` = 0.08, Residual = 0.48
    ),
    design_grid = data.frame(
      Scenario = "n_rater_2_n_item_3", n_Rater = 2L, n_Item = 3L
    ),
    expected = data.frame(
      UniverseVariance = 1,
      RelativeErrorVariance = 0.30,
      AbsoluteErrorVariance = 13 / 30,
      G = 10 / 13,
      Phi = 30 / 43
    )
  )
}
