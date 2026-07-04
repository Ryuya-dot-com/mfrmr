test_that("as_ggplot converts core plot-data shapes", {
  skip_if_not_installed("ggplot2")

  fit <- make_toy_fit(maxit = 20)

  wright <- as_ggplot(fit, type = "wright")
  expect_s3_class(wright, "ggplot")
  wright_build <- ggplot2::ggplot_build(wright)
  expect_gte(length(wright_build$data), 6L)

  pathway <- as_ggplot(fit, type = "pathway")
  expect_s3_class(pathway, "ggplot")
  pathway_build <- ggplot2::ggplot_build(pathway)
  expect_gte(length(pathway_build$data), 5L)

  ccc <- as_ggplot(plot(fit, type = "ccc", draw = FALSE))
  expect_s3_class(ccc, "ggplot")
  expect_no_error(ggplot2::ggplot_build(ccc))

  direct_ccc <- as_ggplot(fit, type = "ccc", theta_points = 81,
                          slope_aes = "alpha")
  expect_s3_class(direct_ccc, "ggplot")
  expect_no_error(ggplot2::ggplot_build(direct_ccc))

  threshold <- as_ggplot(plot_threshold_ladder(fit, draw = FALSE))
  expect_s3_class(threshold, "ggplot")
  expect_no_error(ggplot2::ggplot_build(threshold))
})

test_that("as_ggplot converts EAP power-sensitivity diagnostics", {
  skip_if_not_installed("ggplot2")

  fit <- make_toy_fit(method = "JML", maxit = 20)
  toy <- load_mfrmr_data("example_core")
  raters <- unique(toy$Rater)[1:2]
  criteria <- unique(toy$Criterion)[1:2]
  new_units <- data.frame(
    Person = c("NEW01", "NEW01", "NEW02", "NEW02"),
    Rater = c(raters[1], raters[2], raters[1], raters[2]),
    Criterion = c(criteria[1], criteria[2], criteria[1], criteria[2]),
    Score = c(2, 3, 2, 4)
  )
  sens <- analyze_eap_power_sensitivity(
    fit,
    new_units,
    prior_power = c(0.8, 1, 1.2),
    likelihood_power = c(0.9, 1, 1.1)
  )

  heatmap <- as_ggplot(plot(sens, type = "person_heatmap", draw = FALSE))
  curve <- as_ggplot(plot(sens, type = "person_curve", draw = FALSE))
  facet_bar <- as_ggplot(plot(sens, type = "facet_stability", draw = FALSE))
  facet_heatmap <- as_ggplot(plot(sens, type = "facet_heatmap", facet = "Rater", draw = FALSE))
  expect_s3_class(heatmap, "ggplot")
  expect_s3_class(curve, "ggplot")
  expect_s3_class(facet_bar, "ggplot")
  expect_s3_class(facet_heatmap, "ggplot")
  expect_no_error(ggplot2::ggplot_build(heatmap))
  expect_no_error(ggplot2::ggplot_build(curve))
  expect_no_error(ggplot2::ggplot_build(facet_bar))
  expect_no_error(ggplot2::ggplot_build(facet_heatmap))
})

test_that("as_ggplot exposes CCC styling controls and overlays", {
  skip_if_not_installed("ggplot2")

  fit <- make_toy_fit(maxit = 20)

  ccc_payload <- plot(fit, type = "ccc", draw = FALSE, theta_points = 81)
  prob <- ccc_payload$data$probabilities
  expect_true(all(c("Theta", "Probability", "Category", "CurveGroup") %in%
                    names(prob)))

  category_values <- unique(as.character(prob$Category))
  prob$Slope <- ifelse(
    as.character(prob$Category) == category_values[1],
    0.70,
    1.35
  )
  ccc_payload$data$probabilities <- prob

  linewidth_plot <- as_ggplot(
    ccc_payload,
    slope_aes = "linewidth",
    show_dominance = TRUE,
    facet_by = "curve_group"
  )
  expect_s3_class(linewidth_plot, "ggplot")
  built <- ggplot2::ggplot_build(linewidth_plot)
  line_layers <- Filter(function(layer) "linewidth" %in% names(layer),
                        built$data)
  expect_gt(length(line_layers), 0L)
  expect_true(any(vapply(line_layers, function(layer) {
    length(unique(round(layer$linewidth, 4))) > 1L
  }, logical(1))))

  colour_plot <- as_ggplot(ccc_payload, slope_aes = "colour")
  expect_s3_class(colour_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(colour_plot))

  overlay_payload <- plot(fit, type = "ccc_overlay", draw = FALSE,
                          theta_points = 81)
  overlay_plot <- as_ggplot(overlay_payload, show_overlay = TRUE)
  expect_s3_class(overlay_plot, "ggplot")
  overlay_build <- ggplot2::ggplot_build(overlay_plot)
  expect_gte(length(overlay_build$data), 2L)
})

test_that("as_ggplot preserves Wright-map distribution, rails, and optional overlays", {
  skip_if_not_installed("ggplot2")

  toy <- load_mfrmr_data("example_core")
  fit <- make_toy_fit(maxit = 20)

  wright_payload <- plot(
    fit,
    type = "wright",
    draw = FALSE,
    show_ci = TRUE,
    group = "Group",
    group_data = toy
  )
  wright_plot <- as_ggplot(wright_payload)
  expect_s3_class(wright_plot, "ggplot")
  built <- ggplot2::ggplot_build(wright_plot)
  expect_gte(length(built$data), 8L)
  expect_true(is.data.frame(wright_payload$data$locations))
  expect_true(is.data.frame(wright_payload$data$person_stats))
  expect_true(is.data.frame(wright_payload$data$group))
})

test_that("as_ggplot preserves pathway bands, thresholds, and annotations", {
  skip_if_not_installed("ggplot2")

  fit <- make_toy_fit(maxit = 20)
  diag <- make_toy_diagnostics(fit)

  pathway_payload <- plot(
    fit,
    type = "pathway",
    diagnostics = diag,
    include_fit_measures = TRUE,
    draw = FALSE
  )
  pathway_plot <- as_ggplot(pathway_payload)
  expect_s3_class(pathway_plot, "ggplot")
  built <- ggplot2::ggplot_build(pathway_plot)
  expect_gte(length(built$data), 6L)
  expect_true(is.data.frame(pathway_payload$data$dominance_regions))
  expect_true(is.data.frame(pathway_payload$data$pathway_annotations))
  expect_true(any(pathway_payload$data$pathway_long$Layer == "step_threshold"))
})

test_that("as_ggplot converts fit-pathway plot data", {
  skip_if_not_installed("ggplot2")

  fit <- make_toy_fit(maxit = 20)
  diag <- make_toy_diagnostics(fit)

  fit_pathway_payload <- plot(
    fit,
    type = "fit_pathway",
    diagnostics = diag,
    fit_stat = "Outfit",
    draw = FALSE
  )
  expect_s3_class(fit_pathway_payload, "mfrm_plot_data")
  expect_equal(fit_pathway_payload$name, "fit_pathway")
  expect_equal(fit_pathway_payload$data$view, "fit_measure")
  expect_equal(fit_pathway_payload$data$fit_stat, "Outfit")

  fit_pathway_plot <- as_ggplot(fit_pathway_payload)
  expect_s3_class(fit_pathway_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(fit_pathway_plot))
})

test_that("as_ggplot converts DIF/DFF summary and heatmap payloads", {
  skip_if_not_installed("ggplot2")

  toy <- load_mfrmr_data("example_core")
  fit <- make_toy_fit(maxit = 20)
  diag <- make_toy_diagnostics(fit)
  dff <- suppressWarnings(suppressMessages(
    analyze_dff(
      fit,
      diagnostics = diag,
      facet = "Rater",
      group = "Group",
      data = toy,
      method = "residual"
    )
  ))

  summary_plot <- as_ggplot(plot_dif_summary(
    dff,
    draw = FALSE,
    ci_level = 0.90,
    effect_thresholds = c(screen = 0.5)
  ))
  expect_s3_class(summary_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(summary_plot))

  heatmap_plot <- as_ggplot(plot_dif_heatmap(
    dff,
    metric = "obs_exp",
    draw = FALSE,
    flag_threshold = 1
  ))
  expect_s3_class(heatmap_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(heatmap_plot))
})

test_that("as_ggplot converts simulation plot handoff payloads", {
  skip_if_not_installed("ggplot2")

  design_payload <- list(
    plot = "design_evaluation",
    facet = "Rater",
    metric = "separation",
    metric_col = "MeanSeparation",
    display_metric = "MeanSeparation",
    x_var = "n_person",
    x_label = "Persons",
    group_var = NULL,
    group_label = NULL,
    interpretation_note = "Design-evaluation plots summarize simulated operating characteristics.",
    data = data.frame(
      n_person = c(20, 40, 20, 40),
      y = c(1.1, 1.8, 1.3, 2.1),
      group = c("2 raters", "2 raters", "4 raters", "4 raters")
    )
  )
  class(design_payload) <- "mfrm_design_evaluation_plot_data"
  design_plot <- as_ggplot(design_payload)
  expect_s3_class(design_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(design_plot))

  signal_payload <- design_payload
  signal_payload$plot <- "signal_detection"
  signal_payload$signal <- "bias"
  signal_payload$metric <- "screen_rate"
  signal_payload$metric_col <- "BiasScreenRate"
  signal_payload$display_metric <- "Bias screening hit rate"
  signal_payload$interpretation_note <- "Bias-side rates summarize screening behavior."
  class(signal_payload) <- "mfrm_signal_detection_plot_data"
  signal_plot <- as_ggplot(signal_payload)
  expect_s3_class(signal_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(signal_plot))

  recovery_summary <- mfrmr:::new_mfrm_plot_data(
    "recovery_simulation",
    list(
      type = "summary",
      metric = "RMSE",
      metric_label = "RMSE",
      plot_table = data.frame(
        PlotGroup = c("person / Person / aligned", "facet / Rater / aligned"),
        ParameterType = c("person", "facet"),
        Value = c(0.35, 0.22)
      ),
      interpretation_note = "Recovery plots summarize simulation behavior."
    )
  )
  recovery_summary_plot <- as_ggplot(recovery_summary)
  expect_s3_class(recovery_summary_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(recovery_summary_plot))

  recovery_error <- mfrmr:::new_mfrm_plot_data(
    "recovery_simulation",
    list(
      type = "errors",
      metric = "ErrorAligned",
      metric_label = "Aligned recovery error",
      plot_table = data.frame(
        PlotGroup = rep(c("person / Person / aligned", "facet / Rater / aligned"), each = 4),
        ErrorForPlot = c(-0.2, 0.1, 0.05, 0.3, -0.1, 0.04, 0.08, 0.18)
      ),
      interpretation_note = "Recovery error plots are diagnostic displays."
    )
  )
  recovery_error_plot <- as_ggplot(recovery_error)
  expect_s3_class(recovery_error_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(recovery_error_plot))

  recovery_scatter <- mfrmr:::new_mfrm_plot_data(
    "recovery_simulation",
    list(
      type = "scatter",
      metric = "EstimateAligned",
      metric_label = "Aligned estimate",
      plot_table = data.frame(
        PlotGroup = c("person", "person", "facet"),
        TruthForPlot = c(-1, 0, 1),
        EstimateForPlot = c(-0.9, 0.1, 0.85)
      ),
      interpretation_note = "Truth-estimate plots are diagnostic displays."
    )
  )
  recovery_scatter_plot <- as_ggplot(recovery_scatter)
  expect_s3_class(recovery_scatter_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(recovery_scatter_plot))

  recovery_status <- mfrmr:::new_mfrm_plot_data(
    "recovery_simulation",
    list(
      type = "replications",
      metric = "Reps",
      metric_label = "Replications",
      plot_table = data.frame(Status = c("converged", "not_converged"), Reps = c(8, 1)),
      interpretation_note = "Read replication status first."
    )
  )
  recovery_status_plot <- as_ggplot(recovery_status)
  expect_s3_class(recovery_status_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(recovery_status_plot))

  gstudy_components <- mfrmr:::new_mfrm_plot_data(
    "generalizability",
    list(
      plot = "variance_components",
      metric = "ProportionVariance",
      plot_table = data.frame(
        Source = c("Person", "Rater", "Criterion", "Residual"),
        Variance = c(0.42, 0.08, 0.05, 0.20),
        ProportionVariance = c(0.56, 0.11, 0.07, 0.26),
        Value = c(0.56, 0.11, 0.07, 0.26)
      ),
      interpretation_note = "G-study plots summarize G-theory variance decomposition."
    )
  )
  gstudy_components_plot <- as_ggplot(gstudy_components)
  expect_s3_class(gstudy_components_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(gstudy_components_plot))

  gstudy_coefficients <- mfrmr:::new_mfrm_plot_data(
    "generalizability",
    list(
      plot = "coefficients",
      metric = c("G", "Phi"),
      plot_table = data.frame(
        Metric = c("G", "Phi"),
        MetricFamily = "G-theory",
        MetricRole = c("relative_decision", "absolute_decision"),
        Value = c(0.82, 0.74),
        Status = c("high_stakes_candidate", "routine_candidate")
      ),
      reference_lines = mfrmr:::new_reference_lines(
        axis = rep("y", 2L),
        value = c(0.70, 0.80),
        label = c("routine", "high_stakes"),
        linetype = c("dotted", "dashed"),
        role = rep("decision_band", 2L)
      ),
      interpretation_note = "Read G as relative and Phi as absolute dependability."
    )
  )
  gstudy_coefficients_plot <- as_ggplot(gstudy_coefficients)
  expect_s3_class(gstudy_coefficients_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(gstudy_coefficients_plot))

  dstudy_line <- mfrmr:::new_mfrm_plot_data(
    "d_study",
    list(
      plot = "coefficients",
      x_var = "n_Rater",
      metric = c("G", "Phi"),
      series = data.frame(
        n_Rater = c(2, 4, 2, 4),
        n_Criterion = 3,
        ResidualScaling = "highest_order",
        Metric = c("G", "G", "Phi", "Phi"),
        MetricFamily = "G-theory",
        MetricRole = c("relative_decision", "relative_decision",
                       "absolute_decision", "absolute_decision"),
        X = c(2, 4, 2, 4),
        Value = c(0.73, 0.81, 0.68, 0.76),
        Series = c("G", "G", "Phi", "Phi"),
        Panel = "All designs",
        PanelRow = "All designs",
        PanelCol = "panel"
      ),
      reference_lines = mfrmr:::new_reference_lines(
        axis = rep("y", 2L),
        value = c(0.70, 0.80),
        label = c("routine", "high_stakes"),
        linetype = c("dotted", "dashed"),
        role = rep("decision_band", 2L)
      ),
      interpretation_note = "D-study plots summarize projected G/Phi."
    )
  )
  dstudy_line_plot <- as_ggplot(dstudy_line)
  expect_s3_class(dstudy_line_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(dstudy_line_plot))

  dstudy_surface <- mfrmr:::new_mfrm_plot_data(
    "d_study",
    list(
      plot = "heatmap",
      x_var = "n_Rater",
      y_var = "n_Criterion",
      metric = "Phi",
      surface = data.frame(
        n_Rater = rep(2:4, each = 3),
        n_Criterion = rep(2:4, times = 3),
        ResidualScaling = "highest_order",
        Metric = "Phi",
        MetricFamily = "G-theory",
        MetricRole = "absolute_decision",
        X = rep(2:4, each = 3),
        Y = rep(2:4, times = 3),
        Value = c(0.66, 0.70, 0.73, 0.71, 0.75, 0.78, 0.74, 0.78, 0.81),
        Panel = "highest_order"
      ),
      interpretation_note = "Use the heatmap as a two-facet design grid."
    )
  )
  dstudy_surface_plot <- as_ggplot(dstudy_surface)
  expect_s3_class(dstudy_surface_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(dstudy_surface_plot))

  dstudy_surface3d <- dstudy_surface
  dstudy_surface3d$data$plot <- "surface3d"
  dstudy_surface3d_plot <- as_ggplot(dstudy_surface3d)
  expect_s3_class(dstudy_surface3d_plot, "ggplot")
  expect_no_error(ggplot2::ggplot_build(dstudy_surface3d_plot))
})

test_that("as_ggplot supports explicit component selection and clear failures", {
  skip_if_not_installed("ggplot2")

  fit <- make_toy_fit(maxit = 20)
  wright <- plot(fit, type = "wright", draw = FALSE)

  locations <- as_ggplot(wright, component = "locations")
  expect_s3_class(locations, "ggplot")
  expect_no_error(ggplot2::ggplot_build(locations))

  expect_error(
    as_ggplot(wright, component = "does_not_exist"),
    "`component` must be one of"
  )

  empty <- mfrmr:::new_mfrm_plot_data("empty", list(summary = "not tabular"))
  expect_error(
    as_ggplot(empty),
    "No tabular plot component"
  )
})
