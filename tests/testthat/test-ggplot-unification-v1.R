# test-ggplot-unification-v1.R
# Comprehensive V1 contract tests:
# 1. All 63 plot.* S3 methods registered and returning native ggplot objects
# 2. DFF 2D scatterplot (refit & residual) coordinates, identity/threshold guides,
#    non-zeroing of fixed/unavailable rows, and marginal histogram accounting
# 3. FacetMarginalHist (marginal = c("auto", "histogram", "none")) across 2D
#    scatterplots (n < 8 vs n >= 8, single-panel vs multi-panel, + labs())
# 4. Python-application scientific theme, default caption/title suppression,
#    #CBD5E1 missing-cell palette, formerly unavailable views, and long ID labels
# 5. 0.2.x saved plot-data / plot-bundle RDS round-trip backward compatibility

test_that("appendix-role ggplots retain series colours and read older single-row legends", {
  data <- data.frame(Person = c("p1", "p2"), Rater = c("r1", "r1"), Score = 0:1)
  bundle <- build_summary_table_bundle(describe_mfrm_data(data,
    person = "Person", facets = "Rater", score = "Score"))
  p <- plot(bundle, type = "appendix_roles", draw = FALSE,
    palette = c(appendix_role_recommended = "#112233", appendix_role_compact = "#445566"))
  expect_no_warning(ggplot2::ggplot_build(p))
  expect_identical(p$scales$get_scales("fill")$palette(2),
    c(Recommended = "#112233", Compact = "#445566"))
  legacy <- attr(p, "mfrmr_plot_data")
  legacy$data$legend <- legacy$data$legend[1L, , drop = FALSE]
  legacy <- unserialize(serialize(legacy, NULL))
  restored <- as_ggplot(legacy)
  expect_no_warning(ggplot2::ggplot_build(restored))
  expect_identical(restored$scales$get_scales("fill")$palette(2),
    c(Recommended = "#112233", Compact = "#8d99ae"))
  expect_identical(plot_data(restored)$recommended_tables, plot_data(p)$recommended_tables)
  expect_identical(plot_data(restored)$compact_tables, plot_data(p)$compact_tables)
})

test_that("appendix preset labels remain data when rendering a ggplot", {
  data <- data.frame(Person = c("p1", "p2"), Rater = c("r1", "r1"), Score = 0:1)
  bundle <- build_summary_table_bundle(describe_mfrm_data(data,
    person = "Person", facets = "Rater", score = "Score"))
  p <- plot(bundle, type = "appendix_presets", draw = FALSE)
  expect_s3_class(p, "ggplot")
  expect_no_warning(built <- ggplot2::ggplot_build(p))
  expect_identical(plot_data(p)$preset,
    c("all", "recommended", "compact", "methods", "results", "diagnostics", "reporting"))
  expect_equal(built$data[[2L]]$y, plot_data(p)$tables)
})

v1_fixture <- local({
  saved <- NULL
  function() {
    if (is.null(saved)) {
      fit <- readRDS(test_path("fixtures", "ordinary-score-integration.rds"))$fits[[1L]]
      diag <- suppressWarnings(diagnose_mfrm(fit, residual_pca = "both", diagnostic_mode = "both"))
      saved <<- list(fit = fit, diagnostics = diag)
    }
    saved
  }
})

.has_marginal_grobs <- function(p) {
  gt <- ggplot2::ggplotGrob(p)
  all(c("marginal-hist-x", "marginal-hist-y") %in% gt$layout$name)
}

test_that("all 63 plot.* S3 methods exist and representative routes render without mutating ggproto", {
  ns_lines <- readLines(system.file("NAMESPACE", package = "mfrmr"))
  if (!length(ns_lines) && file.exists(test_path("..", "..", "NAMESPACE"))) {
    ns_lines <- readLines(test_path("..", "..", "NAMESPACE"))
  }
  s3_plot <- grep("^S3method\\(plot,", ns_lines, value = TRUE)
  expect_equal(length(s3_plot), 63L)
  classes <- sub("^S3method\\(plot,([^)]+)\\)$", "\\1", s3_plot)
  ns <- asNamespace("mfrmr")
  for (cls in classes) {
    fn_name <- paste0("plot.", cls)
    expect_true(exists(fn_name, envir = ns, inherits = FALSE), info = fn_name)
    expect_true(is.function(get(fn_name, envir = ns, inherits = FALSE)), info = fn_name)
  }

  fx <- v1_fixture()
  fit <- fx$fit
  diag <- fx$diagnostics

  # Verify draw = FALSE never opens or alters graphics devices
  dev_before <- grDevices::dev.cur()
  p_no_draw <- suppressWarnings(plot(fit, type = "wright", draw = FALSE))
  expect_identical(grDevices::dev.cur(), dev_before)
  expect_s3_class(p_no_draw, "ggplot")
  expect_s3_class(attr(p_no_draw, "mfrmr_plot_data"), "mfrm_plot_data")

  # Verify draw = TRUE renders to PNG cleanly and returns identical ggplot object
  png_file <- tempfile(fileext = ".png")
  grDevices::png(png_file, width = 960, height = 640, res = 96)
  p_drawn <- tryCatch(
    suppressWarnings(plot(fit, type = "wright", draw = TRUE)),
    finally = grDevices::dev.off()
  )
  on.exit(unlink(png_file), add = TRUE)
  expect_true(file.exists(png_file))
  expect_gt(file.info(png_file)$size, 0)
  expect_identical(p_drawn, p_no_draw)

  # Formerly unavailable as_ggplot() views now build valid grobs directly from plot()
  cc <- mfrm_report(x = fit, theta_points = 41, type = "category_curves")
  p_cc <- plot(cc, draw = FALSE)
  expect_s3_class(p_cc, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_cc))

  p_qq <- suppressWarnings(plot(fit, type = "residual_qq", diagnostics = diag, draw = FALSE))
  expect_s3_class(p_qq, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_qq))

  p_facets_wright <- suppressWarnings(plot(fit, type = "wright", renderer = "facets", draw = FALSE))
  expect_s3_class(p_facets_wright, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_facets_wright))

  p_bundle <- suppressWarnings(plot(fit, type = "bundle", draw = FALSE))
  expect_s3_class(p_bundle, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_bundle))

  g_out <- mfrm_g_study(
    fit$prep$data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "minque0"
  )
  d_out <- mfrm_d_study(g_out, data.frame(Rater = c(1, 2, 4), Criterion = c(2, 2, 2)))
  p_d <- plot(d_out, draw = FALSE)
  expect_s3_class(p_d, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_d))

  rn <- mfrm_residual_network(fit, diag, facet = "Criterion")
  p_rn <- plot(rn, draw = FALSE)
  expect_s3_class(p_rn, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_rn))

  bias_coll <- suppressWarnings(estimate_all_bias(
    fit,
    diagnostics = diag,
    pairs = list(c("Rater", "Criterion"))
  ))
  p_bc <- plot(bias_coll, draw = FALSE)
  expect_s3_class(p_bc, "ggplot")
  expect_silent(ggplot2::ggplotGrob(p_bc))

  sim_spec <- extract_mfrm_sim_spec(fit)
  expect_s3_class(sim_spec, "mfrm_sim_spec")
})

test_that("plot(dff, type = 'scatter') preserves coordinates, guides, non-zeroing of unavailable/fixed rows, and marginal counts", {
  # Build synthetic dataset with >= 10 Rater levels so marginal = "auto" triggers (n >= 8)
  set.seed(20261031)
  grid <- expand.grid(
    Person = sprintf("P%02d", 1:24),
    Rater = sprintf("R%02d", 1:10),
    Criterion = c("C1", "C2"),
    stringsAsFactors = FALSE
  )
  p_idx <- as.integer(factor(grid$Person))
  r_idx <- as.integer(factor(grid$Rater))
  c_idx <- as.integer(factor(grid$Criterion))
  grid$Group <- ifelse(p_idx <= 12L, "Focal", "Reference")
  lp <- (p_idx - 12.5) / 8 - (r_idx - 5.5) / 5 - (c_idx - 1.5) * 0.4 +
    ifelse(grid$Group == "Focal" & r_idx == 1L, 0.9, 0)
  prob <- stats::plogis(lp)
  grid$Score <- as.integer(1L + stats::rbinom(nrow(grid), size = 3L, prob = prob))

  fit <- suppressWarnings(fit_mfrm(
    grid,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "JML",
    maxit = 25
  ))
  diag <- suppressWarnings(diagnose_mfrm(fit, residual_pca = "none"))

  dff_refit <- suppressWarnings(analyze_dff(
    fit,
    diagnostics = diag,
    facet = "Rater",
    group = "Group",
    data = grid,
    method = "refit",
    min_obs = 2
  ))
  p_refit <- plot(
    dff_refit,
    type = "scatter",
    effect_thresholds = c(0.43, 0.64),
    draw = FALSE
  )
  expect_s3_class(p_refit, "ggplot")
  expect_s3_class(p_refit$facet, "FacetMarginalHist")
  expect_true(.has_marginal_grobs(p_refit))

  tbl_plotted <- plot_data(p_refit, "data")
  expect_identical(tbl_plotted, plot_data(p_refit, "table"))
  expect_equal(nrow(tbl_plotted), 10L)
  expect_true(all(is.finite(tbl_plotted$X) & is.finite(tbl_plotted$Y)))

  mh <- attr(p_refit, "mfrmr_marginal_histograms")
  expect_true(isTRUE(mh$enabled))
  expect_equal(mh$n_complete, nrow(tbl_plotted))
  expect_equal(sum(mh$x_bins$Count), nrow(tbl_plotted))
  expect_equal(sum(mh$y_bins$Count), nrow(tbl_plotted))

  # Inject a fixed-target row and an NA/unavailable row: neither may become 0 or enter marginal counts
  dff_Unavailable <- dff_refit
  dff_Unavailable$dif_table$Fixed1 <- FALSE
  dff_Unavailable$dif_table$Fixed2 <- FALSE
  dff_Unavailable$dif_table$Fixed1[1L] <- TRUE
  dff_Unavailable$dif_table$ComparisonStatus[1L] <- "fixed_target"
  dff_Unavailable$dif_table$Contrast[1L] <- NA_real_
  dff_Unavailable$dif_table$Estimate2[2L] <- NA_real_
  dff_Unavailable$dif_table$Contrast[2L] <- NA_real_

  p_unavail <- plot(dff_Unavailable, type = "scatter", draw = FALSE)
  expect_s3_class(p_unavail, "ggplot")
  sub_df <- plot_data(p_unavail, "data")
  pairs_df <- plot_data(p_unavail, "pairs")
  expect_equal(nrow(sub_df), 8L)
  expect_identical(pairs_df$PlotStatus[1L], "Fixed target; no comparison")
  expect_identical(pairs_df$PlotStatus[2L], "Contrast unavailable")
  expect_false(any(dff_Unavailable$dif_table$Level[1:2] %in% sub_df$Level))
  mh_unavail <- attr(p_unavail, "mfrmr_marginal_histograms")
  expect_equal(sum(mh_unavail$x_bins$Count), 8L)
  expect_equal(sum(mh_unavail$y_bins$Count), 8L)
  expect_match(paste(plot_data(p_unavail, "notes")$Text, collapse = " "), "fixed-target")

  # Residual DFF scatter route
  dff_resid <- suppressWarnings(analyze_dff(
    fit,
    diagnostics = diag,
    facet = "Rater",
    group = "Group",
    data = grid,
    method = "residual",
    min_obs = 2
  ))
  p_resid <- plot(dff_resid, type = "scatter", draw = FALSE)
  expect_s3_class(p_resid, "ggplot")
  expect_true(.has_marginal_grobs(p_resid))
  expect_error(
    plot(dff_resid, type = "scatter", metric = "contrast", draw = FALSE),
    "method = \"refit\""
  )
})

test_that("marginal = c('auto', 'histogram', 'none') obeys n >= 8, single-panel guards, and ggplot + labs()", {
  fx <- v1_fixture()
  fit <- fx$fit
  diag <- fx$diagnostics

  # 1. DFF with n < 8 levels (Criterion has < 8 levels): auto -> off, histogram -> on, none -> off
  dat <- fit$prep$data
  people <- unique(dat$Person)
  dat$Group <- ifelse(match(dat$Person, people) <= length(people) / 2, "G1", "G2")
  dff_small <- suppressWarnings(analyze_dff(
    fit, diag, facet = "Criterion", group = "Group", data = dat, min_obs = 2
  ))
  n_crit <- nrow(dff_small$dif_table)
  expect_lt(n_crit, 8L)
  p_auto_small <- plot(dff_small, type = "scatter", marginal = "auto", draw = FALSE)
  p_hist_small <- plot(dff_small, type = "scatter", marginal = "histogram", draw = FALSE)
  p_none_small <- plot(dff_small, type = "scatter", marginal = "none", draw = FALSE)
  expect_false(.has_marginal_grobs(p_auto_small))
  expect_true(.has_marginal_grobs(p_hist_small))
  expect_false(.has_marginal_grobs(p_none_small))

  # Adding ggplot2::labs() preserves FacetMarginalHist rendering
  p_custom <- p_hist_small + ggplot2::labs(title = "Custom DFF Scatter")
  expect_s3_class(p_custom, "ggplot")
  expect_identical(p_custom$labels$title, "Custom DFF Scatter")
  expect_true(.has_marginal_grobs(p_custom))

  # 2. Paired model comparison scatterplot (Person n >= 8 vs Rater n < 8)
  p_cmp_person <- suppressWarnings(plot(
    fit, comparison = fit, type = "wright", view = "scatter",
    facet = "Person", marginal = "auto", draw = FALSE
  ))
  p_cmp_none <- suppressWarnings(plot(
    fit, comparison = fit, type = "wright", view = "scatter",
    facet = "Person", marginal = "none", draw = FALSE
  ))
  expect_true(.has_marginal_grobs(p_cmp_person))
  expect_false(.has_marginal_grobs(p_cmp_none))

  # 3. Extended model comparison scatterplot (multi-facet guard, single-panel marginal, and unavailable guard)
  ext_bundle <- readRDS(system.file("examples", "extended-models.rds", package = "mfrmr"))
  core_ratings <- load_mfrmr_data("example_core")
  base_rsm <- fit_mfrm(
    core_ratings,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    method = "MML",
    model = "RSM",
    population_formula = ~ 1,
    person_data = data.frame(Person = unique(core_ratings$Person), stringsAsFactors = FALSE)
  )
  ext_cmp <- compare_mfrm(base_rsm, ext_bundle$random_rater$fit)
  p_ext_multi <- plot(ext_cmp, style = "paired", metric = "effects", marginal = "auto", draw = FALSE)
  expect_false(.has_marginal_grobs(p_ext_multi))
  # Single panel with finite points ("Criterion" is fixed in both fits)
  p_ext_single <- plot(
    ext_cmp, style = "paired", metric = "effects",
    facet = "Criterion",
    marginal = "histogram", draw = FALSE
  )
  expect_true(.has_marginal_grobs(p_ext_single))
  # Unavailable rows in extended comparison are never zeroed or counted in marginal bins
  ext_cmp_unavail <- ext_cmp
  ext_cmp_unavail$effects$Comparison <- NA_real_
  ext_cmp_unavail$effects$Status <- "unavailable"
  p_ext_unavail <- plot(
    ext_cmp_unavail, style = "paired", metric = "effects",
    facet = "Criterion", marginal = "histogram", draw = FALSE
  )
  expect_false(.has_marginal_grobs(p_ext_unavail))
  expect_equal(attr(p_ext_unavail, "mfrmr_marginal_histograms")$n_complete, 0L)

  # 4. Fair-average scatterplot (view = "scatter" vs default view = "difference")
  p_fair_diff <- plot(fit, type = "fair_average", view = "difference", diagnostics = diag, marginal = "auto", draw = FALSE)
  p_fair_scatter <- plot(
    fit, type = "fair_average", view = "scatter", diagnostics = diag,
    marginal = "auto", draw = FALSE
  )
  expect_false(.has_marginal_grobs(p_fair_diff))
  expect_true(.has_marginal_grobs(p_fair_scatter))

  # 5. Fit pathway scatterplot (type = "fit_pathway": Bond-and-Fox fit vs measure)
  p_pathway <- suppressWarnings(plot(
    fit, type = "fit_pathway", diagnostics = diag, include_person = TRUE,
    marginal = "auto", draw = FALSE
  ))
  expect_true(.has_marginal_grobs(p_pathway))
  expect_false(.has_marginal_grobs(suppressWarnings(
    plot(fit, type = "fit_pathway", diagnostics = diag, include_person = TRUE, marginal = "none", draw = FALSE)
  )))

  # 6. Bias interaction scatterplot
  bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
  t13 <- mfrm_report(x = bias, top_n = 50, type = "bias_interaction")
  p_bias_hist <- plot(t13, type = "bias", view = "scatter", marginal = "histogram", draw = FALSE)
  p_bias_none <- plot(t13, type = "bias", view = "scatter", marginal = "none", draw = FALSE)
  expect_true(.has_marginal_grobs(p_bias_hist))
  expect_false(.has_marginal_grobs(p_bias_none))

  # 7. External-feature PCA scores scatterplot (n = 10 >= 8)
  feat_df <- data.frame(
    ID = sprintf("R%02d", 1:10),
    Years = c(1, 3, 2, 5, 4, 7, 6, 9, 8, 10),
    Hours = c(4, 8, 6, 12, 11, 15, 14, 20, 18, 22),
    Volume = c(30, 45, 40, 70, 65, 85, 80, 110, 95, 120),
    stringsAsFactors = FALSE
  )
  pca_res <- mfrm_pca(mfrm_features(feat_df, "ID", c("Years", "Hours", "Volume")))
  p_pca_auto <- plot(pca_res, type = "scores", marginal = "auto", draw = FALSE)
  p_pca_none <- plot(pca_res, type = "scores", marginal = "none", draw = FALSE)
  expect_true(.has_marginal_grobs(p_pca_auto))
  expect_false(.has_marginal_grobs(p_pca_none))

  # 8. Recovery simulation scatterplot (reusing saved simulation-recovery.rds)
  rec <- readRDS(system.file("examples", "simulation-recovery.rds", package = "mfrmr"))$result
  p_rec_auto <- plot(rec, type = "scatter", marginal = "auto", draw = FALSE)
  p_rec_none <- plot(rec, type = "scatter", marginal = "none", draw = FALSE)
  expect_true(.has_marginal_grobs(p_rec_auto))
  expect_false(.has_marginal_grobs(p_rec_none))
})

test_that("theme presets, default title/caption suppression, #CBD5E1 missing cells, and long displacement IDs hold", {
  fx <- v1_fixture()
  fit <- fx$fit
  diag <- fx$diagnostics

  # Default show_title = FALSE, show_notes = FALSE hides in-figure title/subtitle/caption while retaining notes
  p_default <- suppressWarnings(plot(fit, type = "wright", draw = FALSE))
  expect_null(p_default$labels$title)
  expect_null(p_default$labels$subtitle)
  expect_null(p_default$labels$caption)
  expect_gt(nrow(plot_data(p_default, "notes")), 0L)

  p_annotated <- suppressWarnings(plot(
    fit, type = "wright", show_title = TRUE, show_notes = TRUE, draw = FALSE
  ))
  expect_true(nzchar(p_annotated$labels$title %||% ""))
  expect_true(nzchar(p_annotated$labels$subtitle %||% ""))

  # White scientific canvas; semantic colours and missing-value distinction remain
  st_std <- mfrmr:::resolve_plot_preset("standard")
  st_pub <- mfrmr:::resolve_plot_preset("publication")
  st_mono <- mfrmr:::resolve_plot_preset("monochrome")
  expect_identical(st_std$panel_background, "#FFFFFF")
  expect_identical(st_std$axis, "#334155")
  expect_identical(st_std$hist_fill, "#309B92")
  expect_identical(st_std$missing, "#CBD5E1")
  expect_identical(st_pub$panel_background, "#FFFFFF")
  expect_identical(st_mono$missing, "gray82")

  # Long identifiers in displacement plots remain intact on the rendered ggplot axis
  disp <- displacement_table(fit, diagnostics = diag, anchored_only = FALSE)
  long_id <- "VeryLongExamineeIdentifier_2026_CohortA_001"
  disp$table$Level[1L] <- long_id
  p_disp <- plot(disp, top_n = 8, draw = FALSE)
  expect_s3_class(p_disp, "ggplot")
  built_disp <- ggplot2::ggplot_build(p_disp)
  panel_y_labels <- built_disp$layout$panel_params[[1L]]$y$get_labels()
  expect_true(any(grepl(long_id, panel_y_labels, fixed = TRUE)))
  expect_silent(ggplot2::ggplotGrob(p_disp))
})

test_that("saved 0.2.x mfrm_plot_data, design_evaluation, signal_detection, and bundle RDS objects remain compatible", {
  fx <- v1_fixture()
  fit <- fx$fit
  diag <- fx$diagnostics

  # 1. Legacy mfrm_plot_data RDS round-trip
  legacy_wright <- attr(suppressWarnings(plot(fit, type = "wright", draw = FALSE)), "mfrmr_plot_data")
  rds_path <- tempfile(fileext = ".rds")
  on.exit(unlink(rds_path), add = TRUE)
  saveRDS(legacy_wright, rds_path)
  reloaded_wright <- readRDS(rds_path)
  expect_s3_class(reloaded_wright, "mfrm_plot_data")
  g_wright <- as_ggplot(reloaded_wright)
  expect_s3_class(g_wright, "ggplot")
  expect_identical(plot_data(reloaded_wright, "locations"), plot_data(g_wright, "locations"))
  expect_true(nrow(plot_data_components(reloaded_wright)) > 0L)
  printed_pd <- capture.output(print(reloaded_wright))
  expect_gt(length(printed_pd), 0L)

  # 2. Legacy mfrm_design_evaluation_plot_data RDS round-trip
  des_eval <- readRDS(system.file("examples", "simulation-design.rds", package = "mfrmr"))$result
  p_des <- plot(des_eval, draw = FALSE)
  legacy_des <- structure(plot_data(p_des), class = c("mfrm_design_evaluation_plot_data", "list"))
  saveRDS(legacy_des, rds_path)
  reloaded_des <- readRDS(rds_path)
  g_des <- as_ggplot(reloaded_des)
  expect_s3_class(g_des, "ggplot")
  expect_silent(ggplot2::ggplotGrob(g_des))

  # 3. Legacy mfrm_signal_detection_plot_data RDS round-trip
  sig <- readRDS(system.file("examples", "simulation-signal-detection.rds", package = "mfrmr"))$result
  p_sig <- plot(sig, draw = FALSE)
  legacy_sig <- structure(plot_data(p_sig), class = c("mfrm_signal_detection_plot_data", "list"))
  saveRDS(legacy_sig, rds_path)
  reloaded_sig <- readRDS(rds_path)
  g_sig <- as_ggplot(reloaded_sig)
  expect_s3_class(g_sig, "ggplot")
  expect_silent(ggplot2::ggplotGrob(g_sig))

  # 4. Legacy mfrm_plot_bundle RDS round-trip
  bundle_pd <- plot_data(suppressWarnings(plot(fit, type = "bundle", draw = FALSE)))
  legacy_bundle <- structure(
    bundle_pd[c("wright_map", "pathway_map", "category_characteristic_curves")],
    class = "mfrm_plot_bundle"
  )
  saveRDS(legacy_bundle, rds_path)
  reloaded_bundle <- readRDS(rds_path)
  expect_s3_class(reloaded_bundle, "mfrm_plot_bundle")
  out_txt <- capture.output(print(reloaded_bundle))
  expect_true(any(grepl("mfrm plot bundle", out_txt, fixed = TRUE)))
})

test_that("shared theme text scales and edited plots retain data and local settings", {
  fit <- v1_fixture()$fit
  global <- ggplot2::theme_get()
  p <- suppressWarnings(plot(fit, type = "ccc", draw = FALSE))
  original_theme <- p$theme
  p_theme <- ggplot2::ggplot_build(p)$plot$theme
  edited <- p + ggplot2::theme(text = ggplot2::element_text(size = 18),
                              legend.position = "bottom") +
    ggplot2::labs(y = "Category probability")
  edited_theme <- ggplot2::ggplot_build(edited)$plot$theme
  components <- c("axis.text", "axis.title", "legend.text", "strip.text")
  sizes <- function(theme) vapply(components, function(n)
    ggplot2::calc_element(n, theme)$size, numeric(1))
  ratio <- ggplot2::calc_element("text", edited_theme)$size /
    ggplot2::calc_element("text", p_theme)$size
  expect_equal(sizes(edited_theme), sizes(p_theme) * ratio)
  expect_identical(p$theme, original_theme)
  expect_identical(ggplot2::theme_get(), global)
  expect_identical(plot_data(edited), plot_data(p))
  expect_identical(as_ggplot(edited), edited)
  expect_identical(edited$labels$y, "Category probability")
  expect_identical(edited$theme$legend.position, "bottom")
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path))
  saveRDS(edited, path)
  saved <- readRDS(path)
  expect_identical(plot_data(saved), plot_data(p))
  expect_equal(ggplot2::ggplot_build(saved)$data, ggplot2::ggplot_build(edited)$data)
})


test_that("specialist views retain exact saved metadata through the public converter", {
  matrix_plot <- structure(list(name = "facet_nesting", data = list(
    matrix = matrix(c(1, 0, NA, .5), 2), notes = "Retain unavailable cells")),
    class = c("mfrm_plot_data", "list"), saved_source = "original")
  empty <- matrix_plot
  empty$data$matrix <- matrix(numeric(), 0, 0)
  bars <- structure(list(name = "data_description", data = list(
    plot = "score_distribution", table = data.frame(Score = 0:2, WeightedN = c(0, 3, NA)))),
    class = c("mfrm_plot_data", "list"), saved_source = "original")
  composite <- structure(list(name = "fit_plot_bundle", data = list(
    wright_map = matrix_plot, pathway_map = bars, category_characteristic_curves = empty)),
    class = c("mfrm_plot_data", "list"), saved_source = "original")
  fallback <- structure(list(name = "custom_table", data = list(
    table = data.frame(ID = c("A", "B"), Estimate = c(0, NA_real_)))),
    class = c("mfrm_plot_data", "list"), saved_source = "original")
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  for (x in list(matrix_plot, empty, bars, composite, fallback)) {
    before <- serialize(x, NULL)
    p <- as_ggplot(x)
    expect_s3_class(p, "ggplot")
    expect_identical(attr(p, "mfrmr_plot_data", exact = TRUE), x)
    expect_identical(plot_data(p), x$data)
    expect_identical(plot_data_components(p), plot_data_components(x))
    saveRDS(list(data = x, plot = p), path)
    saved <- readRDS(path)
    expect_identical(attr(saved$plot, "mfrmr_plot_data", exact = TRUE), x)
    expect_identical(plot_data(as_ggplot(saved$data)), x$data)
    expect_identical(serialize(x, NULL), before)
  }
})


test_that("network and D-study conversion share guards without changing renderer selection", {
  events <- character()
  available <- TRUE
  mock_renderer <- function(name) {
    force(name)
    function(x) {
      events <<- c(events, paste0("renderer:", name))
      name
    }
  }
  testthat::local_mocked_bindings(
    .require_mfrmr_ggplot2 = function() {
      events <<- c(events, "require")
      if (!available) stop("ggplot unavailable", call. = FALSE)
    },
    .mfrmr_gg_tabular = function(component, payload) {
      value <- component$value
      events <<- c(events, "table")
      value
    },
    .mfrmr_gg_network_ergm = mock_renderer("network_ergm"),
    .mfrmr_gg_rater_network = mock_renderer("rater_network"),
    .mfrmr_gg_subset_connectivity = mock_renderer("subset_connectivity"),
    .mfrmr_gg_residual_network = mock_renderer("residual_network"),
    .mfrmr_gg_multivariate_d_comparison = mock_renderer("multivariate_d_comparison"),
    .mfrmr_gg_d_study = mock_renderer("d_study"), .package = "mfrmr")
  table <- data.frame(Label = c("observed", "unavailable"), Value = c(0, NA_real_))
  for (name in c("network_ergm", "rater_network", "subset_connectivity",
                 "residual_network", "multivariate_d_comparison", "d_study")) {
    x <- structure(list(name = name, data = list(table = table)), class = "mfrm_plot_data")
    available <- TRUE
    events <- character()
    expect_identical(as_ggplot(x), name)
    expect_identical(events, c("require", paste0("renderer:", name)))
    events <- character()
    expect_identical(as_ggplot(x, component = "table"), table)
    expect_identical(events, c("require", "table"))
    events <- character()
    expect_error(as_ggplot(x, component = "missing"), "component")
    expect_identical(events, "require")
    events <- character()
    expect_error(as_ggplot(x, extra = TRUE), "must be empty")
    expect_length(events, 0L)
    expect_error(as_ggplot(x, type = "other", extra = TRUE), "already selects a view")
    expect_length(events, 0L)
    available <- FALSE
    expect_error(as_ggplot(x, component = "missing"), "ggplot unavailable")
    expect_identical(events, "require")
    events <- character()
    expect_error(as_ggplot(x, extra = TRUE), "must be empty")
    expect_length(events, 0L)
  }
})
