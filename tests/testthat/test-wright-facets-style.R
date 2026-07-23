test_that("native top_n remains compact while FACETS payload keeps all locations", {
  fit <- make_toy_fit()
  full <- plot(fit, type = "wright", top_n = 100L, draw = FALSE)
  compact <- plot(fit, type = "wright", top_n = 2L, draw = FALSE)
  facets <- plot(fit, type = "wright", renderer = "facets", top_n = 2L, draw = FALSE)

  expect_identical(compact$data$wright_style, "native")
  expect_lte(nrow(compact$data$locations), 2L)
  expect_lte(nrow(compact$data$label_points), 2L)
  expect_identical(compact$data$label_limit, 2L)
  expect_identical(facets$data$renderer, "facets")
  expect_equal(nrow(facets$data$locations), nrow(full$data$locations))
})

test_that("Wright CI payload stores absolute endpoints", {
  fit <- make_toy_fit()
  out <- suppressWarnings(plot(
    fit,
    type = "wright",
    show_ci = TRUE,
    ci_level = 0.90,
    draw = FALSE
  ))
  loc <- out$data$locations
  loc <- loc[loc$PlotType == "Facet level" & is.finite(loc$SE), , drop = FALSE]
  expect_gt(nrow(loc), 0L)
  z <- stats::qnorm(0.95)
  expect_equal(loc$CI_Lower, loc$Estimate - z * loc$SE)
  expect_equal(loc$CI_Upper, loc$Estimate + z * loc$SE)
  expect_true(all(loc$CI_Lower <= loc$Estimate & loc$Estimate <= loc$CI_Upper))
})

test_that("supplied diagnostics drive Wright SE metadata but not coordinates", {
  fit <- make_toy_fit()
  diagnostics <- make_toy_diagnostics(fit)
  row <- which(as.character(diagnostics$measures$Facet) != "Person")[1]
  facet <- as.character(diagnostics$measures$Facet[row])
  level <- as.character(diagnostics$measures$Level[row])
  fitted_estimate <- fit$facets$others$Estimate[
    as.character(fit$facets$others$Facet) == facet &
      as.character(fit$facets$others$Level) == level
  ]
  fitted_estimate <- unname(fitted_estimate)
  diagnostics$measures$Estimate[row] <- 1.2345
  diagnostics$measures$SE[row] <- 0.123

  out <- plot(
    fit,
    type = "wright",
    diagnostics = diagnostics,
    show_ci = TRUE,
    ci_level = 0.95,
    draw = FALSE
  )
  loc <- out$data$locations[
    as.character(out$data$locations$Group) == facet &
      as.character(out$data$locations$Label) == level,
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
  unified_loc <- unified$locations[
    as.character(unified$locations$Group) == facet &
      as.character(unified$locations$Label) == level,
    , drop = FALSE
  ]
  expect_equal(unified_loc$Estimate, fitted_estimate)
  expect_equal(unified_loc$SE, 0.123)
})

test_that("FACETS-style Wright payload is complete and explicitly visual", {
  fit <- make_toy_fit()
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

  expect_identical(out$data$wright_style, "facets_style")
  expect_identical(out$data$renderer, "facets")
  expect_match(out$data$visual_contract, "not FACETS numerical equivalence", fixed = TRUE)
  fs <- out$data$facets_style
  expect_true(all(c(
    "ruler_rows", "person_frequency", "person_placements", "facet_ruler",
    "facet_cells", "step_ruler", "score_transitions", "category_labels",
    "headers", "settings"
  ) %in% names(fs)))
  expect_equal(sum(fs$person_frequency$Count), nrow(out$data$person))
  expect_equal(nrow(fs$facet_ruler), sum(out$data$locations$PlotType == "Facet level"))
  expect_setequal(
    paste(fs$facet_ruler$Facet, fs$facet_ruler$Level, sep = "::"),
    paste(
      out$data$locations$Group[out$data$locations$PlotType == "Facet level"],
      out$data$locations$Label[out$data$locations$PlotType == "Facet level"],
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
  expect_gt(nrow(fs$score_transitions), 0L)
  expect_true(all(is.finite(fs$score_transitions$Estimate)))
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
  fit <- make_toy_fit()
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
  fs <- out$data$facets_style
  expect_true(paste0("+", positive_facet) %in% fs$headers$Header)
  expect_equal(fs$category_labels$OriginalScore, as.character(mapped_scores))
  expect_true(all(fs$step_ruler$LowerScore %in% as.character(mapped_scores)))
  expect_true(all(fs$step_ruler$UpperScore %in% as.character(mapped_scores)))
  expect_true(all(grepl("Level", fs$step_ruler$TransitionLabel, fixed = TRUE)))
})

test_that("FACETS-style range, ruler resolution, and extremes are controllable", {
  fit <- make_toy_fit()
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
  fs <- out$data$facets_style
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
    estimates$data$facets_style$person_placements$DisplayEstimate[1:2],
    c(-2, 2)
  ))
})

test_that("FACETS-style thresholds can be omitted and base renderer draws", {
  fit <- make_toy_fit()
  no_steps <- plot_wright_unified(
    fit,
    renderer = "facets",
    show_thresholds = FALSE,
    draw = FALSE
  )
  expect_equal(nrow(no_steps$facets_style$step_ruler), 0L)
  expect_equal(nrow(no_steps$facets_style$score_transitions), 0L)

  grDevices::pdf(nullfile())
  on.exit(grDevices::dev.off(), add = TRUE)
  expect_silent(plot(
    fit,
    type = "wright",
    renderer = "facets",
    show_ci = TRUE
  ))
})

test_that("FACETS-style Wright arguments are validated", {
  fit <- make_toy_fit()
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
