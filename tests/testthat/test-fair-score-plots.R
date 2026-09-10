test_that("fair-score derivatives match the actual reference transformation", {
  for (model in c("RSM", "PCM")) {
    fit <- make_toy_fit(model = model, maxit = 20)
    dx <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "legacy")
    # Nonzero person mean distinguishes FairM from FairZ on non-person rows.
    fit$facets$person$Estimate <- fit$facets$person$Estimate + 0.7
    for (metric in c("FairM", "FairZ")) {
      p <- plot_fair_average(fit, diagnostics = dx, metric = metric, show_ci = TRUE, draw = FALSE)
      d <- p$data$data
      derivative <- mfrmr:::.fair_average_delta_variance(fit, d, metric)
      for (i in seq_len(nrow(d))) {
        plus <- minus <- dx
        at <- which(dx$measures$Facet == d$Facet[i] & dx$measures$Level == d$Level[i])
        if (!length(at)) next
        plus$measures$Estimate[at] <- plus$measures$Estimate[at] + 1e-5
        minus$measures$Estimate[at] <- minus$measures$Estimate[at] - 1e-5
        a <- fair_average_table(fit, diagnostics = plus)$raw_by_facet[[d$Facet[i]]]
        b <- fair_average_table(fit, diagnostics = minus)$raw_by_facet[[d$Facet[i]]]
        numerical <- abs((a[[metric]][match(d$Level[i], a$Level)] - b[[metric]][match(d$Level[i], b$Level)]) / 2e-5)
        expect_equal(derivative[i], unname(numerical), tolerance = 1e-7)
      }
      scaled <- plot_fair_average(fit, diagnostics = dx, metric = metric, show_ci = TRUE,
        umean = 50, uscale = -10, draw = FALSE)$data$data
      at <- match(paste(d$Facet, d$Level), paste(scaled$Facet, scaled$Level))
      expect_equal(d$CI_SE, scaled$CI_SE[at], tolerance = 1e-8)
      expect_equal(d$CI_Lower, scaled$CI_Lower[at], tolerance = 1e-8)
    }
  }
})

test_that("fair-score relationship plots preserve data, notes and grayscale encodings", {
  fit <- make_toy_fit(maxit = 10)
  bundle <- fair_average_table(fit)
  bundle$raw_by_facet$Person$ObservedAverage[1] <- NA_real_
  p <- plot_fair_average(bundle, plot_type = "measure", facet = "Person", draw = FALSE,
    metric = "FairZ", preset = "monochrome", show_title = FALSE, show_notes = FALSE)
  expect_equal(nrow(p$data$data), nrow(bundle$raw_by_facet$Person))
  expect_equal(p$data$plot_data$X, p$data$data$Measure)
  expect_equal(p$data$plot_data$Y, p$data$data$FairZ)
  expect_equal(nrow(p$data$reference_lines), 0L)
  expect_true(any(grepl("does not mean z-score", p$data$notes$Text)))
  all <- plot_fair_average(fit, plot_type = "scatter", draw = FALSE, preset = "monochrome")
  rgb <- grDevices::col2rgb(all$data$encoding$Color)
  expect_equal(unname(rgb[1, ]), unname(rgb[2, ]))
  expect_equal(unname(rgb[2, ]), unname(rgb[3, ]))
  expect_equal(length(unique(all$data$encoding$Shape)), nrow(all$data$encoding))
  ranked <- plot_fair_average(fit, top_n = 2, draw = FALSE)
  expect_equal(nrow(ranked$data$plot_data), 2L)
  expect_true(all(diff(abs(ranked$data$plot_data$Gap)) <= 0))
  expect_equal(nrow(ranked$data$data), nrow(all$data$data))
  unavailable <- plot_fair_average(fit, xtreme = 0.25, show_ci = TRUE, draw = FALSE)
  expect_true(all(is.na(unavailable$data$data$CI_Lower)))
  expect_true(all(unavailable$data$data$CI_Status == "unavailable"))
  expect_error(plot_fair_average(fit, top_n = NA, draw = FALSE), "top_n")
  skip_if_not_installed("ggplot2")
  g <- as_ggplot(p)
  expect_null(g$labels$title)
  expect_null(g$labels$subtitle)
  expect_identical(attr(g, "mfrmr_notes"), p$data$notes)
  expect_no_warning(ggplot2::ggplot_build(g))
  built <- ggplot2::ggplot_build(g)$data[[1]]
  expect_equal(built$x, unname(p$data$plot_data$X))
  expect_equal(built$y, unname(p$data$plot_data$Y))
  expect_equal(nrow(built), nrow(p$data$plot_data))
})

test_that("stored GPCM fair-score intervals honor the requested confidence level", {
  # A precomputed bundle tests interval conversion without another costly fit.
  fit <- make_toy_fit(maxit = 10)
  b <- fair_average_table(fit)
  b$settings$model <- "GPCM"
  for (facet in names(b$raw_by_facet)) {
    d <- b$raw_by_facet[[facet]]
    for (metric in c("FairM", "FairZ")) {
      d[[paste0(metric, "SE")]] <- 0.1
      d[[paste0(metric, "_SE_Status")]] <- "ok"
      d[[paste0(metric, "_CI_Level")]] <- 0.95
      d[[paste0(metric, "_CI_Lower")]] <- d[[metric]] - qnorm(.975) * .1
      d[[paste0(metric, "_CI_Upper")]] <- d[[metric]] + qnorm(.975) * .1
    }
    b$raw_by_facet[[facet]] <- d
  }
  p <- plot_fair_average(b, show_ci = TRUE, ci_level = .9, draw = FALSE)
  expect_equal(p$data$data$CI_Lower, pmax(b$settings$rating_min, p$data$data$FairM - qnorm(.95)*.1))
  expect_true(all(p$data$data$CI_Level == .9))
  b$settings$rating_min <- b$settings$rating_max <- NULL
  p <- plot_fair_average(b, show_ci = TRUE, ci_level = .9, draw = FALSE)
  expect_true(all(is.na(p$data$data$CI_Lower)))
})
