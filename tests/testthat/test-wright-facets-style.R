make_wright_ready_fit <- function(...) {
  fit <- make_toy_fit(...)
  fit$readiness$fit$InputState <- "pass"
  fit$readiness$fit$EstimabilityState <- "identified"
  fit$readiness$fit$CategoryState <- "adequate"
  fit$readiness$fit$BoundaryState <- "finite"
  fit$readiness$fit$NumericalState <- "ready"
  fit$readiness$fit$FitReadiness <- "ready"
  fit$readiness$fit$InferenceReady <- TRUE
  fit$readiness$fit$ReasonCodes <- ""
  fit$readiness$components$State <- c(
    input = "pass",
    estimability = "identified",
    category = "adequate",
    boundary = "finite",
    numerical = "ready"
  )[fit$readiness$components$Component]
  fit$readiness$components$Complete <- TRUE
  fit$readiness$components$ReasonCodes <- ""
  fit$summary$Converged <- TRUE
  fit$summary$InputState <- "pass"
  fit$summary$EstimabilityState <- "identified"
  fit$summary$CategoryState <- "adequate"
  fit$summary$BoundaryState <- "finite"
  fit$summary$NumericalState <- "ready"
  fit$summary$FitReadiness <- "ready"
  fit$summary$InferenceReady <- TRUE
  fit$summary$ReadinessReasonCodes <- ""
  fit$summary$ConvergenceSeverity <- "pass"
  fit$summary$ConvergenceStatus <- "converged"
  fit
}

test_that("named Wright selection adds omitted levels without changing estimates", {
  fit <- make_wright_ready_fit()
  original <- serialize(fit, NULL)
  full <- plot(fit, top_n = Inf, draw = FALSE)
  compact <- plot(fit, top_n = 1, draw = FALSE)
  full_pd <- plot_data(full)
  compact_pd <- plot_data(compact)
  candidates <- subset(full_pd$locations, PlotType == "Facet level")
  omitted <- candidates[!paste(candidates$Group, candidates$Label) %in%
    paste(compact_pd$locations$Group, compact_pd$locations$Label), ][1, ]
  selection <- setNames(list(as.character(omitted$Label)), as.character(omitted$Group))
  marked <- plot(fit, top_n = 1, highlight = selection, draw = FALSE)
  marked_pd <- plot_data(marked)
  key <- function(z) paste(z$Group, z$Label)
  expect_setequal(key(marked_pd$locations), c(key(compact_pd$locations), key(omitted)))
  selected <- subset(marked_pd$locations, Highlighted)
  expect_equal(nrow(selected), 1L)
  expect_identical(selected$DisplayLabel, paste0("> ", selected$Label))
  numeric_cols <- c("Estimate", "SE", "CI_Lower", "CI_Upper")
  expect_equal(as.data.frame(marked_pd$locations[numeric_cols]),
    as.data.frame(full_pd$locations[match(key(marked_pd$locations),
      key(full_pd$locations)), numeric_cols]))
  expect_identical(marked_pd$y_range, compact_pd$y_range)
  expect_identical(marked_pd$y_range, full_pd$y_range)
  expect_equal(marked_pd$retention$Shown[1], compact_pd$retention$Shown[1] + 1)
  expect_equal(marked_pd$retention$Omitted[1], compact_pd$retention$Omitted[1] - 1)
  expect_match(paste(marked_pd$notes$Text, collapse = " "), "not a statistical flag")
  expect_identical(serialize(fit, NULL), original)

  unified <- plot(fit, view = "unified", top_n = 1, highlight = selection, draw = FALSE)
  expect_equal(plot_data(unified, "locations"), marked_pd$locations)
  bundle <- plot(fit, type = "bundle", top_n = 1, highlight = selection, draw = FALSE)
  expect_equal(plot_data(plot_data(bundle)$wright_map, "locations"), marked_pd$locations)

  # Compaction must not hide an opposite endpoint of the fitted ruler.
  fit$facets$others$Estimate[1:2] <- c(100, -99)
  scale <- build_wright_map_data(fit, top_n = 1, include_steps = FALSE)
  expect_equal(scale$y_range, c(-99, 100))
})

test_that("Wright selection survives both layouts and saved ggplot conversion", {
  fit <- make_wright_ready_fit()
  levels <- fit$facets$others
  selection <- lapply(split(as.character(levels$Level), levels$Facet), head, 1)
  p <- plot(fit, highlight = selection, renderer = "facets", draw = FALSE)
  p_pd <- plot_data(p)
  ruler <- p_pd$facets_style$facet_ruler
  expect_equal(sum(ruler$Highlighted), length(selection))
  expect_true(all(startsWith(ruler$DisplayLabel[ruler$Highlighted], "> ")))
  expect_true(any(grepl("> ", p_pd$facets_style$facet_cells$CellLabel, fixed = TRUE)))
  expect_true(all(p_pd$retention$Complete))
  for (renderer in c("native", "facets")) {
    p <- plot(fit, highlight = selection, renderer = renderer, draw = FALSE)
    saved <- unserialize(serialize(p, NULL))
    expect_identical(saved, p)
    if (requireNamespace("ggplot2", quietly = TRUE)) {
      g <- as_ggplot(saved)
      layers <- ggplot2::ggplot_build(g)$data
      labels <- unlist(lapply(layers, function(z) z$label), use.names = FALSE)
      expect_equal(sum(startsWith(labels, "> ")), length(selection))
      expect_identical(plot_data(g), plot_data(p))
    }
  }
})

test_that("Wright selection rejects unknown or unavailable levels and other routes", {
  fit <- make_wright_ready_fit()
  expect_error(plot(fit, highlight = "R01", draw = FALSE), "named list")
  expect_error(plot(fit, highlight = list(Rater = NA_character_), draw = FALSE), "character level IDs")
  expect_error(plot(fit, highlight = list(Unknown = "R01"), draw = FALSE), "Unknown highlight facet")
  expect_error(plot(fit, highlight = list(Rater = "Unknown"), draw = FALSE), "Unknown highlight level")
  expect_error(plot(fit, type = "ccc", highlight = list(Rater = "R01"), draw = FALSE), "only for Wright")
  unavailable <- fit$facets$others[1, ]
  selection <- setNames(list(as.character(unavailable$Level)), as.character(unavailable$Facet))
  fit$facets$others$Estimate[1] <- NA_real_
  expect_error(build_wright_map_data(fit, highlight = selection), "finite fitted locations")
})

test_that("plot readiness preserves a failed numerical state", {
  fit <- make_wright_ready_fit()
  fit$readiness$fit$NumericalState <- "failed"
  fit$readiness$fit$FitReadiness <- "blocked"
  fit$readiness$fit$InferenceReady <- FALSE
  fit$readiness$fit$ReasonCodes <- "optimizer_failed;iteration_limit"
  numerical_row <- fit$readiness$components$Component == "numerical"
  fit$readiness$components$State[numerical_row] <- "failed"
  fit$readiness$components$ReasonCodes[numerical_row] <-
    "optimizer_failed;iteration_limit"
  fit$summary$Converged <- FALSE
  fit$summary$NumericalState <- "failed"
  fit$summary$FitReadiness <- "blocked"
  fit$summary$InferenceReady <- FALSE
  fit$summary$ReadinessReasonCodes <- "optimizer_failed;iteration_limit"
  fit$summary$ConvergenceSeverity <- "fail"
  fit$summary$ConvergenceStatus <- "iteration_limit"

  expect_warning(
    out <- plot(fit, type = "wright", draw = FALSE),
    "Numerical=fail",
    fixed = TRUE
  )
  out_pd <- plot_data(out)
  numerical <- out_pd$fit_readiness[
    out_pd$fit_readiness$Domain == "Numerical",
    ,
    drop = FALSE
  ]
  expect_identical(numerical$Status, "fail")
  expect_identical(out_pd$interpretation_status, "review_only")
  expect_match(out_pd$subtitle, "REVIEW ONLY", fixed = TRUE)
})

test_that("native top_n compacts facets but retains every step transition", {
  fit <- make_wright_ready_fit()
  full <- plot(fit, type = "wright", top_n = 100L, draw = FALSE)
  compact <- plot(fit, type = "wright", top_n = 2L, draw = FALSE)
  complete <- plot(fit, type = "wright", top_n = Inf, draw = FALSE)
  facets <- plot(fit, type = "wright", renderer = "facets", top_n = 2L, draw = FALSE)
  full_pd <- plot_data(full)
  compact_pd <- plot_data(compact)
  complete_pd <- plot_data(complete)
  facets_pd <- plot_data(facets)

  expect_identical(compact_pd$wright_style, "native")
  expect_true(compact_pd$show_ci)
  expect_identical(compact_pd$uncertainty_display, "native_mfrmr_ci")
  expect_identical(
    full_pd$display_settings$AutoRangePolicy,
    "all_fitted_locations"
  )
  expect_equal(full_pd$locations$DisplayEstimate, full_pd$locations$Estimate)
  expect_equal(
    full_pd$y_range,
    range(c(full_pd$locations$Estimate, full_pd$person$Estimate))
  )
  full_steps <- full_pd$locations[
    full_pd$locations$PlotType == "Step threshold",
    ,
    drop = FALSE
  ]
  full_location_keys <- paste(full_pd$locations$Group, full_pd$locations$Label)
  full_label_keys <- paste(full_pd$label_points$Group, full_pd$label_points$Label)
  expect_setequal(full_label_keys, full_location_keys)
  expect_true(all(c(
    "LabelX", "LabelY", "LabelSide", "LabelText", "LabelDisplaced"
  ) %in% names(full_pd$label_points)))
  full_step_labels <- full_pd$label_points[
    full_pd$label_points$PlotType == "Step threshold",
    ,
    drop = FALSE
  ]
  expect_equal(full_steps$X, full_steps$XBase)
  expect_true(all(grepl("\\([+-][0-9]", full_step_labels$LabelText)))
  compact_steps <- compact_pd$locations[
    compact_pd$locations$PlotType == "Step threshold",
    ,
    drop = FALSE
  ]
  compact_step_labels <- compact_pd$label_points[
    compact_pd$label_points$PlotType == "Step threshold",
    ,
    drop = FALSE
  ]
  expect_equal(nrow(compact_steps), nrow(full_steps))
  expect_setequal(as.character(compact_steps$Label), as.character(full_steps$Label))
  expect_setequal(
    as.character(compact_step_labels$Label),
    as.character(full_steps$Label)
  )
  expect_true(all(grepl(" -> ", compact_step_labels$Label, fixed = TRUE)))
  expect_identical(compact_pd$label_limit, 2L)
  expect_true(all(c("Component", "Shown", "Total", "Omitted", "Complete", "RequestedTopN") %in%
                    names(compact_pd$retention)))
  compact_all <- compact_pd$retention[
    compact_pd$retention$Component == "All locations",
    ,
    drop = FALSE
  ]
  expect_equal(compact_all$Shown + compact_all$Omitted, compact_all$Total)
  expect_gt(compact_all$Omitted, 0L)
  expect_false(compact_all$Complete)
  expect_match(compact_pd$retention_note, "Use `top_n = Inf`", fixed = TRUE)
  expect_match(compact_pd$subtitle, "facet locations", fixed = TRUE)
  complete_all <- complete_pd$retention[
    complete_pd$retention$Component == "All locations",
    ,
    drop = FALSE
  ]
  expect_equal(complete_all$Shown, complete_all$Total)
  expect_equal(complete_all$Omitted, 0L)
  expect_true(complete_all$Complete)
  expect_identical(complete_pd$retention_note, "")
  expect_equal(nrow(complete_pd$locations), complete_all$Total)
  expect_identical(facets_pd$renderer, "facets")
  expect_false(facets_pd$show_ci)
  expect_identical(facets_pd$uncertainty_display, "facets_style_no_ci")
  expect_equal(nrow(facets_pd$locations), nrow(full_pd$locations))
})

test_that("Wright CI payload stores absolute endpoints", {
  fit <- make_wright_ready_fit()
  out <- suppressWarnings(plot(
    fit,
    type = "wright",
    show_ci = TRUE,
    ci_level = 0.90,
    draw = FALSE
  ))
  loc <- plot_data(out, "locations")
  loc <- loc[loc$PlotType == "Facet level" & is.finite(loc$SE), , drop = FALSE]
  expect_gt(nrow(loc), 0L)
  z <- stats::qnorm(0.95)
  expect_equal(loc$CI_Lower, loc$Estimate - z * loc$SE)
  expect_equal(loc$CI_Upper, loc$Estimate + z * loc$SE)
  expect_true(all(loc$CI_Lower <= loc$Estimate & loc$Estimate <= loc$CI_Upper))
})

test_that("supplied diagnostics drive Wright SE metadata and must match coordinates", {
  fit <- make_wright_ready_fit()
  diagnostics <- make_toy_diagnostics(fit)
  row <- which(as.character(diagnostics$measures$Facet) != "Person")[1]
  facet <- as.character(diagnostics$measures$Facet[row])
  level <- as.character(diagnostics$measures$Level[row])
  fitted_estimate <- fit$facets$others$Estimate[
    as.character(fit$facets$others$Facet) == facet &
      as.character(fit$facets$others$Level) == level
  ]
  fitted_estimate <- unname(fitted_estimate)
  diagnostics$measures$SE[row] <- 0.123

  out <- plot(
    fit,
    type = "wright",
    diagnostics = diagnostics,
    show_ci = TRUE,
    ci_level = 0.95,
    draw = FALSE
  )
  out_locs <- plot_data(out, "locations")
  loc <- out_locs[
    as.character(out_locs$Group) == facet &
      as.character(out_locs$Label) == level,
    , drop = FALSE
  ]
  expect_equal(nrow(loc), 1L)
  expect_equal(loc$Estimate, fitted_estimate)
  expect_equal(loc$SE, 0.123)
  expect_identical(loc$Measure_Source, "diagnostics$measures")
  expect_equal(loc$CI_Lower, fitted_estimate - stats::qnorm(0.975) * 0.123)

  unified <- plot_wright_unified(
    fit,
    diagnostics = diagnostics,
    show_ci = TRUE,
    draw = FALSE
  )
  unified_locs <- plot_data(unified, "locations")
  unified_loc <- unified_locs[
    as.character(unified_locs$Group) == facet &
      as.character(unified_locs$Label) == level,
    , drop = FALSE
  ]
  expect_equal(unified_loc$Estimate, fitted_estimate)
  expect_equal(unified_loc$SE, 0.123)

  diagnostics$measures$Estimate[row] <- fitted_estimate + 1
  expect_error(plot(fit, type = "wright", diagnostics = diagnostics, draw = FALSE),
               "fit/diagnostics mismatch")
  expect_error(plot_wright_unified(fit, diagnostics = diagnostics, draw = FALSE),
               "fit/diagnostics mismatch")
})

test_that("FACETS-style Wright payload is complete and explicitly visual", {
  fit <- make_wright_ready_fit()
  diagnostics <- make_toy_diagnostics(fit)
  score_values <- as.character(fit$prep$score_map$OriginalScore)
  rubric <- stats::setNames(paste("Rubric", score_values), score_values)
  out <- plot(
    fit,
    type = "wright",
    diagnostics = diagnostics,
    show_ci = TRUE,
    renderer = "facets",
    category_labels = rubric,
    rows_per_logit = 4L,
    persons_per_star = 2,
    draw = FALSE
  )

  out_pd <- plot_data(out)
  expect_identical(out_pd$wright_style, "facets_style")
  expect_identical(out_pd$renderer, "facets")
  expect_true(out_pd$show_ci)
  expect_identical(out_pd$uncertainty_display, "hybrid_mfrmr_ci")
  expect_match(out_pd$subtitle, "Hybrid", fixed = TRUE)
  expect_true(any(grepl("CI", out_pd$legend$label, fixed = TRUE)))
  expect_true(any(out_pd$legend$role == "uncertainty"))
  expect_match(out_pd$visual_contract, "not FACETS numerical equivalence", fixed = TRUE)
  fs <- out_pd$facets_style
  expect_true(all(c(
    "ruler_rows", "person_frequency", "person_placements", "facet_ruler",
    "facet_cells", "step_ruler", "score_transitions", "category_labels",
    "headers", "settings"
  ) %in% names(fs)))
  expect_equal(sum(fs$person_frequency$Count), nrow(out_pd$person))
  expect_equal(nrow(fs$facet_ruler), sum(out_pd$locations$PlotType == "Facet level"))
  expect_setequal(
    paste(fs$facet_ruler$Facet, fs$facet_ruler$Level, sep = "::"),
    paste(
      out_pd$locations$Group[out_pd$locations$PlotType == "Facet level"],
      out_pd$locations$Label[out_pd$locations$PlotType == "Facet level"],
      sep = "::"
    )
  )
  expect_true(all(fs$headers$Header[fs$headers$ColumnType == "facet"] %in%
    paste0(ifelse(fs$facet_ruler$Sign[match(
      fs$headers$Group[fs$headers$ColumnType == "facet"],
      fs$facet_ruler$Facet
    )] >= 0, "+", "-"), fs$headers$Group[fs$headers$ColumnType == "facet"])))
  expect_gt(nrow(fs$step_ruler), 0L)
  expect_true(all(grepl(" -> ", fs$step_ruler$TransitionLabel, fixed = TRUE)))
  expect_true(all(grepl("Rubric", fs$step_ruler$TransitionLabel, fixed = TRUE)))
  expect_equal(fs$step_ruler$DrawValue, fs$step_ruler$Estimate)
  expect_true(all(grepl("[", fs$step_ruler$DrawLabel, fixed = TRUE)))
  expect_gt(nrow(fs$score_transitions), 0L)
  expect_true(all(is.finite(fs$score_transitions$Estimate)))
  expect_equal(
    fs$score_transitions$DrawValue,
    fs$score_transitions$Estimate
  )
  expect_true(all(fs$score_transitions$CrossingStatus == "in_range"))
  curve_spec <- mfrmr:::build_step_curve_spec(fit)
  for (i in seq_len(nrow(fs$score_transitions))) {
    transition <- fs$score_transitions[i, , drop = FALSE]
    curve <- mfrmr:::build_curve_tables(curve_spec, transition$Estimate)$expected
    expected <- curve$ExpectedScore[curve$CurveGroup == transition$CurveGroup]
    expect_equal(expected, transition$MeanHalfScore, tolerance = 1e-5)
  }
  expect_identical(fs$settings$RowsPerLogit, 4L)
  expect_equal(fs$settings$PersonsPerStar, 2)
  expect_equal(fs$settings$StarsPerPerson, 0.5)
  expect_match(fs$settings$VisualCorrespondence, "not a claim", fixed = TRUE)
})

test_that("FACETS-style headers and transitions respect fit metadata", {
  fit <- make_wright_ready_fit()
  positive_facet <- as.character(fit$config$facet_names[1])
  fit$config$facet_signs[[positive_facet]] <- 1
  mapped_scores <- seq_len(nrow(fit$prep$score_map)) * 10
  fit$prep$score_map$OriginalScore <- mapped_scores
  rubric <- stats::setNames(paste("Level", mapped_scores), as.character(mapped_scores))

  out <- plot(
    fit,
    type = "wright",
    renderer = "facets",
    category_labels = rubric,
    draw = FALSE
  )
  fs <- plot_data(out, "facets_style")
  expect_true(paste0("+", positive_facet) %in% fs$headers$Header)
  expect_equal(fs$category_labels$OriginalScore, as.character(mapped_scores))
  expect_true(all(fs$step_ruler$LowerScore %in% as.character(mapped_scores)))
  expect_true(all(fs$step_ruler$UpperScore %in% as.character(mapped_scores)))
  expect_true(all(grepl("Level", fs$step_ruler$TransitionLabel, fixed = TRUE)))
})

test_that("named Wright category labels must cover original score keys after recoding", {
  fit <- make_wright_ready_fit()
  n_cat <- nrow(fit$prep$score_map)
  internal_scores <- 0:(n_cat - 1L)
  original_scores <- seq_len(n_cat)
  fit$prep$rating_min <- 0L
  fit$prep$rating_max <- n_cat - 1L
  fit$config$n_cat <- n_cat
  fit$prep$score_map <- data.frame(
    OriginalScore = original_scores,
    InternalScore = internal_scores
  )

  valid <- stats::setNames(paste("Level", original_scores), original_scores)
  out <- plot(
    fit,
    type = "wright",
    renderer = "facets",
    category_labels = valid,
    draw = FALSE
  )
  out_fs <- plot_data(out, "facets_style")
  expect_equal(
    out_fs$category_labels$OriginalScore,
    as.character(original_scores)
  )
  expect_equal(
    out_fs$category_labels$RubricLabel,
    unname(valid)
  )

  internal_keyed <- stats::setNames(paste("Internal", internal_scores), internal_scores)
  expect_error(
    plot(
      fit,
      type = "wright",
      renderer = "facets",
      category_labels = internal_keyed,
      draw = FALSE
    ),
    "appear to use internal score keys"
  )
  expect_error(
    plot(
      fit,
      type = "wright",
      renderer = "facets",
      category_labels = valid[-n_cat],
      draw = FALSE
    ),
    paste0("original score key\\(s\\): ", n_cat)
  )
  expect_error(
    plot(
      fit,
      type = "wright",
      renderer = "facets",
      category_labels = data.frame(
        Score = original_scores[-n_cat],
        Label = unname(valid[-n_cat])
      ),
      draw = FALSE
    ),
    paste0("original score key\\(s\\): ", n_cat)
  )
})

test_that("FACETS-style range, ruler resolution, and extremes are controllable", {
  fit <- make_wright_ready_fit()
  fit$facets$person$Extreme[1:2] <- c("low", "high")
  out <- plot(
    fit,
    type = "wright",
    renderer = "facets",
    wright_range = c(-2, 2),
    rows_per_logit = 2L,
    extreme_placement = "ends",
    draw = FALSE
  )
  fs <- plot_data(out, "facets_style")
  expect_equal(range(fs$ruler_rows$Logit), c(-2, 2))
  expect_equal(unique(diff(fs$ruler_rows$Logit)), 0.5)
  expect_equal(fs$person_placements$RulerValue[1:2], c(-2, 2))

  estimates <- plot(
    fit,
    type = "wright",
    renderer = "facets",
    wright_range = c(-2, 2),
    extreme_placement = "estimate",
    draw = FALSE
  )
  expect_false(identical(
    plot_data(estimates, "facets_style")$person_placements$DisplayEstimate[1:2],
    c(-2, 2)
  ))
})

test_that("FACETS-style thresholds can be omitted and base renderer draws", {
  fit <- make_wright_ready_fit()
  no_steps <- plot_wright_unified(
    fit,
    renderer = "facets",
    show_thresholds = FALSE,
    draw = FALSE
  )
  no_steps_fs <- plot_data(no_steps, "facets_style")
  expect_equal(nrow(no_steps_fs$step_ruler), 0L)
  expect_equal(nrow(no_steps_fs$score_transitions), 0L)

  grDevices::pdf(nullfile())
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_silent(plot(
    fit,
    type = "wright",
    renderer = "native",
    top_n = 2L
  ))
  expect_silent(plot(
    fit,
    type = "wright",
    renderer = "facets",
    show_ci = FALSE
  ))
})

test_that("plot_wright_unified uses the same renderer-specific uncertainty contract", {
  fit <- make_wright_ready_fit()

  native <- plot_wright_unified(fit, top_n = Inf, draw = FALSE)
  native_pd <- plot_data(native)
  expect_true(native_pd$show_ci)
  expect_identical(native_pd$uncertainty_display, "native_mfrmr_ci")
  expect_true(all(native_pd$retention$Omitted == 0L))

  facets <- plot_wright_unified(fit, renderer = "facets", draw = FALSE)
  facets_pd <- plot_data(facets)
  expect_false(facets_pd$show_ci)
  expect_identical(facets_pd$uncertainty_display, "facets_style_no_ci")

  hybrid <- plot_wright_unified(
    fit,
    renderer = "facets",
    show_ci = TRUE,
    draw = FALSE
  )
  hybrid_pd <- plot_data(hybrid)
  expect_true(hybrid_pd$show_ci)
  expect_identical(hybrid_pd$uncertainty_display, "hybrid_mfrmr_ci")
  expect_match(hybrid_pd$title, "hybrid", ignore.case = TRUE)
})

test_that("boundary separation uses one robust range and explicit CI display metadata", {
  fit <- make_wright_ready_fit()
  boundary_rows <- which(
    as.character(fit$facets$others$Facet) == "Rater"
  )[1:2]
  boundary_levels <- as.character(fit$facets$others$Level[boundary_rows])
  fit$facets$others$Estimate[boundary_rows] <- c(-25, 25)
  fit$data_review$boundary_levels <- data.frame(
    Facet = "Rater",
    Level = boundary_levels,
    stringsAsFactors = FALSE
  )

  native <- suppressWarnings(plot(
    fit,
    type = "wright",
    top_n = Inf,
    show_ci = TRUE,
    draw = FALSE
  ))
  native_pd <- plot_data(native)
  settings <- native_pd$display_settings
  expect_identical(settings$AutoRangePolicy, "boundary_levels_at_ends")
  expect_equal(native_pd$y_range, c(settings$LowerLogit, settings$UpperLogit))
  expect_lt(diff(native_pd$y_range), 10)

  boundary_native <- native_pd$locations[
    native_pd$locations$BoundarySeparated,
    ,
    drop = FALSE
  ]
  expect_equal(boundary_native$OriginalEstimate, boundary_native$Estimate)
  expect_equal(boundary_native$CI_Lower, boundary_native$OriginalCI_Lower)
  expect_equal(boundary_native$CI_Upper, boundary_native$OriginalCI_Upper)
  expect_true(all(boundary_native$DisplayEstimate >= native_pd$y_range[1]))
  expect_true(all(boundary_native$DisplayEstimate <= native_pd$y_range[2]))
  expect_setequal(boundary_native$BoundaryEnd, c("lower", "upper"))
  expect_true(all(boundary_native$CIDisplayStatus == "boundary_endpoint_marker"))
  expect_true(all(grepl("(", boundary_native$DisplayLabel, fixed = TRUE)))

  drawn_key <- mfrmr:::.wright_native_legend_spec(
    native_pd,
    show_ci = TRUE,
    ci_level = 0.95
  )
  expect_identical(as.character(native_pd$legend$label), drawn_key$label)
  expect_true(all(c(
    "Person density", "Facet level", "Step threshold", "IQR / range",
    "95% mfrmr CI", "Boundary level / CI beyond ruler"
  ) %in% native_pd$legend$label))

  facets <- suppressWarnings(plot(
    fit,
    type = "wright",
    renderer = "facets",
    show_ci = TRUE,
    draw = FALSE
  ))
  fs <- plot_data(facets, "facets_style")
  expect_equal(
    c(fs$settings$LowerLogit, fs$settings$UpperLogit),
    native_pd$y_range
  )
  expect_identical(fs$settings$AutoRangePolicy, "boundary_levels_at_ends")
  boundary_facets <- fs$facet_ruler[fs$facet_ruler$BoundarySeparated, , drop = FALSE]
  expect_equal(boundary_facets$OriginalEstimate, boundary_facets$Estimate)
  expect_equal(boundary_facets$OriginalCI_Lower, boundary_facets$CI_Lower)
  expect_true(all(boundary_facets$CISuppressed))

  grDevices::pdf(nullfile(), width = 12, height = 8)
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_silent(print(native))
  expect_silent(print(facets))
})

test_that("FACETS-style Wright arguments are validated", {
  fit <- make_wright_ready_fit()
  expect_error(
    plot(fit, type = "wright", top_n = 0, draw = FALSE),
    "top_n"
  )
  expect_error(
    plot(fit, type = "wright", wright_style = "facets", draw = FALSE),
    "not recognized"
  )
  expect_error(
    plot(fit, type = "wright", wright_style = "facets_style", rows_per_logit = 0, draw = FALSE),
    "rows_per_logit"
  )
  expect_error(
    plot(fit, type = "wright", wright_style = "facets_style", wright_range = c(2, -2), draw = FALSE),
    "wright_range"
  )
  expect_error(
    plot(fit, type = "wright", wright_style = "facets_style", persons_per_star = 0, draw = FALSE),
    "persons_per_star"
  )
  expect_warning(
    plot(
      fit,
      type = "wright",
      renderer = "facets",
      group = rep(c("A", "B"), length.out = nrow(fit$facets$person)),
      draw = FALSE
    ),
    "available only"
  )
  expect_error(
    plot(fit, type = "wright", renderer = "facets_style", draw = FALSE),
    "renderer"
  )
})
