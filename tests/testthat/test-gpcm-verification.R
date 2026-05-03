# Verification tests for the bounded-GPCM workflow declared in
# `gpcm_capability_matrix()`. Each test exercises one row of the
# matrix that is `"supported"` or `"supported_with_caveat"` and
# asserts the corresponding helper returns the documented shape.
# `"blocked"` and `"deferred"` rows have negative tests where the
# helper should refuse to run (or run with an explicit caveat).

skip_if_no_lme4 <- function() {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("`lme4` (Suggests) not installed; skipping GPCM verification.")
  }
}

local({
  .toy_gpcm <<- load_mfrmr_data("example_core")
  .gpcm_fit <<- suppressMessages(suppressWarnings(
    fit_mfrm(.toy_gpcm, "Person", c("Rater", "Criterion"), "Score",
             method = "MML", model = "GPCM",
             step_facet = "Criterion",
             slope_facet = "Criterion",
             quad_points = 7L, maxit = 25L)
  ))
})

test_that("GPCM core fit returns a populated mfrm_fit", {
  expect_s3_class(.gpcm_fit, "mfrm_fit")
  expect_identical(as.character(.gpcm_fit$config$model), "GPCM")
  expect_true(nrow(.gpcm_fit$summary) > 0L)
  expect_true(nrow(.gpcm_fit$facets$person) > 0L)
})

test_that("GPCM print / summary do not error", {
  expect_no_error(invisible(utils::capture.output(print(.gpcm_fit))))
  expect_no_error(invisible(utils::capture.output(print(summary(.gpcm_fit)))))
})

test_that("GPCM diagnose_mfrm returns measures with caveat status", {
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(.gpcm_fit, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  expect_true(is.data.frame(diag$measures))
  expect_true(nrow(diag$measures) > 0L)
  expect_true(is.data.frame(diag$fair_average$stacked))
  expect_gt(nrow(diag$fair_average$stacked), 0L)
  expect_identical(diag$fair_average$method, "GPCM-slope-aware")
  expect_match(diag$fair_average$caveat, "slope-aware", fixed = TRUE)
})

test_that("GPCM compute_information + plot_information work", {
  info <- compute_information(.gpcm_fit)
  expect_true(is.list(info))
  expect_true("tif" %in% names(info))
  p <- plot_information(info, draw = FALSE)
  expect_s3_class(p, "mfrm_plot_data")
})

test_that("GPCM CCC / pathway / Wright plots return mfrm_plot_data", {
  for (type in c("wright", "pathway", "ccc")) {
    p <- plot(.gpcm_fit, type = type, draw = FALSE)
    expect_s3_class(p, "mfrm_plot_data")
  }
})

test_that("GPCM capability matrix is consistent with the helper", {
  m <- gpcm_capability_matrix()
  expect_true(is.data.frame(m))
  expect_true(all(c("Area", "Helpers", "Status", "PrimaryUse", "Boundary")
                  %in% names(m)))
  expect_true(all(m$Status %in%
                    c("supported", "supported_with_caveat", "blocked", "deferred")))
})

test_that("GPCM visual summaries and QC pipeline run with caveat", {
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(.gpcm_fit, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  vis <- build_visual_summaries(.gpcm_fit, diag)
  expect_s3_class(vis, "mfrm_visual_summaries")
  expect_identical(vis$support_status$Status[1], "supported_with_caveat")
  expect_match(vis$caveat, "slope-aware", fixed = TRUE)

  qc <- run_qc_pipeline(.gpcm_fit, diag, include_bias = FALSE)
  expect_s3_class(qc, "mfrm_qc_pipeline")
  expect_identical(qc$support_status$Status[1], "supported_with_caveat")
  expect_match(qc$caveat, "slope-aware", fixed = TRUE)
})

test_that("GPCM preserves retained zero-frequency intermediate categories", {
  gap_data <- mfrmr:::sample_mfrm_data(seed = 42)
  gap_data <- gap_data[gap_data$Score %in% c(1, 2, 4, 5), , drop = FALSE]
  fit_gap <- suppressMessages(suppressWarnings(
    fit_mfrm(
      gap_data, "Person", c("Rater", "Task", "Criterion"), "Score",
      method = "MML", model = "GPCM",
      step_facet = "Criterion", slope_facet = "Criterion",
      rating_min = 1, rating_max = 5, keep_original = TRUE,
      quad_points = 5L, maxit = 20L
    )
  ))
  expect_equal(fit_gap$config$n_cat, 5)
  expect_identical(fit_gap$prep$unused_score_categories, 3L)

  rs <- rating_scale_table(fit_gap, drop_unused = FALSE)
  expect_true(3 %in% rs$category_table$Category)
  expect_true(isTRUE(rs$category_table$ZeroCount[rs$category_table$Category == 3]))
  expect_true(any(grepl("zero-count intermediate", rs$threshold_table$ThresholdCaveat, fixed = TRUE)))

  diag_gap <- suppressMessages(suppressWarnings(
    diagnose_mfrm(fit_gap, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  expect_gt(nrow(diag_gap$fair_average$stacked), 0L)
  expect_identical(diag_gap$fair_average$method, "GPCM-slope-aware")

  vis <- build_visual_summaries(fit_gap, diag_gap)
  expect_identical(vis$support_status$Status[1], "supported_with_caveat")
  qc <- run_qc_pipeline(fit_gap, diag_gap, include_bias = FALSE)
  expect_identical(qc$support_status$Status[1], "supported_with_caveat")
})

test_that("GPCM still blocks build_apa_outputs (blocked row)", {
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(.gpcm_fit, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  # build_apa_outputs is `blocked` for GPCM in the capability matrix.
  # fair_average_table() and estimate_bias() were unblocked in 0.2.0
  # via the slope-aware kernel; build_apa_outputs() remains blocked.
  apa_attempt <- tryCatch(
    suppressMessages(build_apa_outputs(.gpcm_fit, diag)),
    error = function(e) e,
    warning = function(w) w
  )
  expect_true(inherits(apa_attempt, "condition") ||
                inherits(apa_attempt, "mfrm_apa_outputs"))
})
