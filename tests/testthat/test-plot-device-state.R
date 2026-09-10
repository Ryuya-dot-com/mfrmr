test_that("single-panel plots advance through caller layouts and restore style", {
  fit <- make_toy_fit(maxit = 20)
  grDevices::pdf(NULL, width = 12, height = 10)
  on.exit(grDevices::dev.off(), add = TRUE)
  graphics::par(mfrow = c(2, 2), col = "purple", fg = "navy")
  style_names <- c("bg", "fg", "col", "col.axis", "col.lab", "col.main",
                   "col.sub", "cex.axis", "cex.lab", "cex.main", "lend", "ljoin", "mar")
  original <- graphics::par()[style_names]
  types <- c("pathway", "person", "step", "fit_pathway")
  positions <- matrix(c(1, 1, 1, 2, 2, 1, 2, 2), ncol = 2, byrow = TRUE)
  for (i in seq_along(types)) {
    .mfrmr_muffle_expected_warnings(
      plot(fit, type = types[i], preset = "publication"), "^Review-only display:"
    )
    expect_equal(graphics::par("mfg")[1:2], positions[i, ])
    expect_identical(graphics::par()[style_names], original)
    expect_false(graphics::par("new"))
    expect_false(identical(graphics::par("usr"), c(0, 1, 0, 1)))
  }

  graphics::layout(matrix(1:2, nrow = 1), widths = c(1, 3))
  .mfrmr_muffle_expected_warnings(plot(fit, type = "person"), "^Review-only display:")
  expect_equal(graphics::par("fig"), c(0, 0.25, 0, 1))
  .mfrmr_muffle_expected_warnings(
    plot(fit, type = "wright", renderer = "facets", show_ci = FALSE),
    "^Review-only display:"
  )
  expect_equal(graphics::par("fig"), c(0.25, 1, 0, 1))
})

test_that("Wright and CCC layouts do not shrink subsequent standalone plots", {
  grDevices::pdf(NULL, width = 7, height = 5)
  on.exit(grDevices::dev.off(), add = TRUE)
  for (model in c("RSM", "PCM")) {
    fit <- make_toy_fit(model = model, maxit = 20)
    for (type in c("wright", "pathway", "ccc", "pathway")) {
      .mfrmr_muffle_expected_warnings(plot(fit, type = type), "^Review-only display:")
      expect_equal(graphics::par("mfrow"), c(1, 1))
      expect_false(graphics::par("new"))
      if (type == "pathway") expect_equal(graphics::par("fig"), c(0, 1, 0, 1))
    }
  }
})

test_that("APA composite draws four panels on one page", {
  fit <- make_toy_fit(maxit = 20)
  grDevices::pdf(NULL, width = 12, height = 9)
  on.exit(grDevices::dev.off(), add = TRUE)
  previous_hook <- getHook("plot.new")
  on.exit(setHook("plot.new", previous_hook, action = "replace"), add = TRUE)
  positions <- list()
  setHook("plot.new", function(...) {
    positions[[length(positions) + 1L]] <<- graphics::par("mfg")
  }, action = "append")
  result <- .mfrmr_muffle_expected_warnings(
    plot_apa_figure_one(fit, diagnostics = make_toy_diagnostics(fit)),
    "^Review-only display:"
  )
  expect_equal(do.call(rbind, positions),
               cbind(matrix(c(1, 1, 1, 2, 2, 1, 2, 2), ncol = 2, byrow = TRUE), 2, 2))
  expect_equal(graphics::par("mfrow"), c(1, 1))
  expect_identical(result$data$data$wright$data$wright_style, "facets_style")
})

test_that("native labels remain distinct without moving or discarding fitted data", {
  place_labels <- mfrmr:::.place_plot_labels
  layouts <- list()
  testthat::local_mocked_bindings(.place_plot_labels = function(...) {
    args <- list(...)
    placed <- place_labels(...)
    layouts[[length(layouts) + 1L]] <<- list(
      placed = placed, preferred_y = args[[2]], points = cbind(args$point_x, args$point_y),
      usr = graphics::par("usr")
    )
    placed
  }, .package = "mfrmr")
  for (size in list(c(7, 5), c(5, 4))) {
    grDevices::pdf(NULL, width = size[1], height = size[2])
    tryCatch({
      for (model in c("RSM", "PCM")) {
        fit <- make_toy_fit(model = model, maxit = 20)
        for (type in c("wright", "pathway")) {
          before <- .mfrmr_muffle_expected_warnings(
            plot(fit, type = type, draw = FALSE), "^Review-only display:"
          )
          drawn <- .mfrmr_muffle_expected_warnings(
            plot(fit, type = type), "^Review-only display:"
          )
          expect_identical(drawn, before)
          expected_n <- if (type == "wright") nrow(before$data$label_points) else nrow(before$data$steps)
          expect_equal(nrow(tail(layouts, 1)[[1]]$placed), expected_n)
        }
      }
      fit <- make_toy_fit(model = "PCM", maxit = 20)
      narrowed <- .mfrmr_muffle_expected_warnings(
        plot(fit, type = "pathway", theta_range = c(-0.1, 0.1)), "^Review-only display:"
      )
      expect_gt(nrow(narrowed$data$steps), nrow(tail(layouts, 1)[[1]]$placed))
      expect_true(all(abs(tail(layouts, 1)[[1]]$points[, 1]) <= 0.1))
      n_layouts <- length(layouts)
      .mfrmr_muffle_expected_warnings(
        plot(fit, type = "pathway", theta_range = c(5, 6)), "^Review-only display:"
      )
      expect_length(layouts, n_layouts)
    }, finally = grDevices::dev.off())
  }
  expect_length(layouts, 10L)
  for (layout in layouts) {
    box <- layout$placed
    overlap <- pmin(outer(box$Right, box$Right, pmin) - outer(box$Left, box$Left, pmax),
                    outer(box$Top, box$Top, pmin) - outer(box$Bottom, box$Bottom, pmax))
    expect_true(all(overlap[upper.tri(overlap)] < 1e-10))
    expect_true(all(box$Left >= layout$usr[1] & box$Right <= layout$usr[2]))
    expect_true(all(box$Bottom >= layout$usr[3] & box$Top <= layout$usr[4]))
    expect_lt(max(abs(box$Y - layout$preferred_y)), diff(layout$usr[3:4]) * 0.3)
    covered <- vapply(seq_len(nrow(layout$points)), function(j) {
      p <- layout$points[j, ]
      any(p[1] > box$Left & p[1] < box$Right & p[2] > box$Bottom & p[2] < box$Top)
    }, logical(1))
    expect_false(any(covered))
  }
})

test_that("long and Japanese names stay distinguishable when abbreviated", {
  for (prefix in c("Analytical judgement of evidence number ",
                   "論理構成と根拠の説明に関する評価観点番号")) {
    original <- paste0(prefix, sprintf("C%02d", 1:8))
    labels <- mfrmr:::truncate_axis_label(c(original, original[1], NA), width = 14)
    expect_equal(anyDuplicated(labels[1:8]), 0L)
    expect_true(all(nchar(labels[1:8], type = "width") <= 14))
    expect_equal(labels[1], labels[9])
    expect_true(is.na(labels[10]))
    expect_true(all(endsWith(labels[1:8], sprintf("C%02d", 1:8))))
  }
  original <- paste0("abcdefghijk", c("A", "B"), "lmnopqrstuv")
  expect_identical(mfrmr:::truncate_axis_label(original, width = 8), original)
  expect_equal(mfrmr:::truncate_axis_label(c("abcde...", "abcdefghijkl"), width = 8)[1], "abcde...")
})

test_that("numerous PCM thresholds do not erase the default facet display", {
  dat <- simulate_mfrm_data(n_person = 30, n_rater = 2, n_criterion = 4,
                            score_levels = 9, seed = 9461)
  fit <- suppressWarnings(fit_mfrm(dat, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score", model = "PCM",
    method = "JML", maxit = 15))
  full <- .mfrmr_muffle_expected_warnings(plot(fit, draw = FALSE), "^Review-only display:")
  compact <- .mfrmr_muffle_expected_warnings(plot(fit, top_n = 2, draw = FALSE), "^Review-only display:")
  expect_equal(sum(full$data$locations$PlotType == "Facet level"), 6)
  expect_equal(sum(compact$data$locations$PlotType == "Facet level"), 2)
  expect_equal(sum(full$data$locations$PlotType == "Step threshold"), 32)
  expect_equal(sum(compact$data$locations$PlotType == "Step threshold"), 32)
  original_legend <- graphics::legend
  legends <- list()
  testthat::local_mocked_bindings(legend = function(...) {
    args <- list(...)
    result <- original_legend(...)
    box <- result$rect
    legends[[length(legends) + 1L]] <<- list(labels = args$legend,
      x = graphics::grconvertX(c(box$left, box$left + box$w), from = "user", to = "ndc"),
      y = graphics::grconvertY(c(box$top - box$h, box$top), from = "user", to = "ndc"))
    result
  }, .package = "graphics")
  grDevices::pdf(NULL, width = 5, height = 4)
  on.exit(grDevices::dev.off(), add = TRUE)
  .mfrmr_muffle_expected_warnings(plot(fit, type = "ccc"), "^Review-only display:")
  expect_length(legends, 1L)
  expect_equal(legends[[1]]$labels, paste("Category", 1:9))
  expect_true(all(legends[[1]]$x >= 0 & legends[[1]]$x <= 1))
  expect_true(all(legends[[1]]$y >= 0 & legends[[1]]$y <= 1))
  expect_equal(length(unique(mfrmr:::.plot_series_colors(as.character(1:10)))), 10)
  rsm <- suppressWarnings(mfrmr::fit_mfrm(dat, person = "Person",
    facets = c("Rater", "Criterion"), score = "Score", model = "RSM",
    method = "JML", maxit = 15))
  grDevices::dev.off()
  grDevices::pdf(NULL, width = 10, height = 5)
  graphics::par(mfrow = c(1, 2))
  .mfrmr_muffle_expected_warnings(plot(rsm, type = "ccc"), "^Review-only display:")
  expect_equal(graphics::par("mfg")[1:2], c(1, 1))
  expect_true(all(legends[[2]]$x >= 0 & legends[[2]]$x <= 0.5))
  graphics::plot(1:2)
  expect_equal(graphics::par("mfg")[1:2], c(1, 2))
  legends <- list()
  small_pcm <- make_toy_fit(model = "PCM", maxit = 15)
  .mfrmr_muffle_expected_warnings(plot(small_pcm, type = "ccc"), "^Review-only display:")
  expect_length(legends, 1L)
  expect_lte(length(legends[[1]]$labels), 5L)
})

test_that("an overcrowded canvas reports its limit without deleting labels", {
  grDevices::pdf(NULL, width = 4, height = 3)
  on.exit(grDevices::dev.off(), add = TRUE)
  graphics::plot(0:1, 0:1, type = "n")
  expect_warning(placed <- mfrmr:::.place_plot_labels(
    rep(0.5, 40), rep(0.5, 40), sprintf("Label %02d", 1:40), cex = 0.7,
    point_x = 0.5, point_y = 0.5), "^Plot labels need more space")
  expect_equal(nrow(placed), 40)
  expect_true(all(is.finite(as.matrix(placed))))
})

test_that("pathway and CCC disclose the same reference profile in data and drawing", {
  fit <- make_toy_fit(maxit = 20)
  bundle <- .mfrmr_muffle_expected_warnings(
    plot(fit, type = "bundle", draw = FALSE), "^Review-only display:")
  expected_basis <- bundle$category_characteristic_curves$data$curve_basis
  expect_identical(bundle$pathway_map$data$curve_basis, expected_basis)
  labels <- character()
  original_mtext <- graphics::mtext
  testthat::local_mocked_bindings(mtext = function(text, ...) {
    labels <<- c(labels, as.character(text))
    original_mtext(text, ...)
  }, .package = "graphics")
  grDevices::pdf(NULL, width = 7, height = 5)
  on.exit(grDevices::dev.off(), add = TRUE)
  for (type in c("pathway", "ccc")) {
    labels <- character()
    p <- .mfrmr_muffle_expected_warnings(plot(fit, type = type), "^Review-only display:")
    expect_identical(p$data$curve_basis, expected_basis)
    expect_match(paste(labels, collapse = " "),
      "additive facet main effects and fitted interactions are fixed at zero", fixed = TRUE)
    expect_true(all(p$data$curve_basis$PredictorOffset == 0))
  }
})
