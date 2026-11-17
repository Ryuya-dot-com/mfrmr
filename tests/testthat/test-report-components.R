test_that("one report entry retains component meaning and saved methods", {
  fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))$fit
  quality <- mfrm_report(fit, type = "data_quality")
  expect_s3_class(quality, "mfrm_data_quality")
  scores <- fit$prep$data$Score
  counts <- tabulate(match(scores, quality$category_counts$Score),
    nbins = nrow(quality$category_counts))
  expect_equal(quality$category_counts$Count, counts)
  expect_equal(sum(quality$category_counts$Count), sum(!is.na(scores)))

  specification <- mfrm_report(fit, type = "specifications", title = "Reviewed calibration")
  expect_s3_class(specification, "mfrm_specifications")
  expect_true(any(grepl("Reviewed calibration", unlist(specification$header), fixed = TRUE)))
  expect_s3_class(mfrm_report(fit, type = "category_structure"), "mfrm_category_structure")
  curves <- mfrm_report(fit, type = "category_curves", theta_points = 61, digits = 6)
  expect_s3_class(curves, "mfrm_category_curves")
  expect_equal(curves$settings$theta_points, 61)
  probabilities <- curves$probabilities
  sums <- tapply(probabilities$Probability,
    interaction(probabilities$CurveGroup, probabilities$Theta, drop = TRUE), sum)
  expect_equal(as.numeric(sums), rep(1, length(sums)), tolerance = 5e-6)
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(curves, path)
  saved <- readRDS(path)
  expect_identical(saved, curves)
  expect_identical(summary(saved), summary(curves))
  expect_identical(plot_data(plot(saved, draw = FALSE)), plot_data(plot(curves, draw = FALSE)))
})

test_that("report components reject unrelated formats and controls", {
  fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))$fit
  old <- c("specifications_report", "data_quality_report",
    "category_structure_report", "category_curves_report")
  expect_false(any(old %in% getNamespaceExports("mfrmr")))
  expect_false(any(vapply(old, exists, TRUE, envir = asNamespace("mfrmr"), inherits = FALSE)))
  expect_error(mfrm_report(fit, type = "unknown"), "arg")
  expect_error(mfrm_report(fit, type = "data_quality", output = "html"), "do not apply")
  expect_error(mfrm_report(fit, type = "specifications", style = "apa"), "do not apply")
  expect_error(mfrm_report(fit, type = "category_curves", diagnostics = list()), "unused argument")
  expect_error(mfrm_report(fit, type = "data_quality", not_an_option = TRUE), "unused argument")
  expect_error(mfrm_report(fit, theta_points = 61), "require a component")
  expect_error(mfrm_report(fit), "mfrm_results")
  before <- getOption("mfrmr.suppress_legacy_name_warning")
  expect_error(mfrm_report(NULL, type = "specifications"), "mfrm_fit")
  expect_identical(getOption("mfrmr.suppress_legacy_name_warning"), before)
})

test_that("iteration and bias reports retain their selected inputs and GPCM scope", {
  fit <- readRDS(system.file("examples", "measurement-fits.rds", package = "mfrmr"))$gpcm
  observed <- list()
  testthat::local_mocked_bindings(
    table3_iteration_report = function(fit, max_iter = 20, reltol = NULL,
      include_prox = TRUE, include_fixed = FALSE) {
      observed$iterations <<- list(fit = fit, max_iter = max_iter, reltol = reltol,
        include_prox = include_prox, include_fixed = include_fixed)
      list(table = data.frame(Iteration = 1L))
    },
    table13_bias_plot_export = function(x, top_n = 50) {
      observed$bias <<- list(x = x, top_n = top_n)
      list(table = data.frame(BiasLogit = .5))
    }, .package = "mfrmr")
  out <- mfrm_report(fit, type = "iterations", max_iter = 3L, include_prox = FALSE)
  expect_s3_class(out, "mfrm_iteration_report")
  expect_identical(observed$iterations, list(fit = fit, max_iter = 3L, reltol = NULL,
    include_prox = FALSE, include_fixed = FALSE))
  expect_identical(out$gpcm_boundary$Area, "Replayed optimization diagnostics under GPCM")
  expect_equal(nrow(out$gpcm_boundary), 1L)
  expect_true(nzchar(out$gpcm_boundary$Boundary))
  bias <- list(saved = TRUE)
  expect_s3_class(mfrm_report(bias, type = "bias_interaction", top_n = 7L), "mfrm_bias_interaction")
  expect_identical(observed$bias, list(x = bias, top_n = 7L))
  expect_error(mfrm_report(bias, type = "bias_interaction", unknown = TRUE), "unused argument")
  old <- c("estimation_iteration_report", "bias_interaction_report")
  expect_false(any(old %in% getNamespaceExports("mfrmr")))
  expect_false(any(vapply(old, exists, TRUE, envir = asNamespace("mfrmr"), inherits = FALSE)))
})

test_that("DFF report counts retain their distinct denominators and saved fields", {
  rows <- data.frame(Classification = c("Linked contrast (screening only)",
    "Linked contrast (screening only)", "Unclassified (insufficient linking)",
    "Fixed target; no comparison", "Unavailable", NA_character_),
    ConditionalRefitScreenEligible = c(TRUE, FALSE, FALSE, FALSE, FALSE, NA),
    Contrast = c(.3, -.2, NA, NA, NA, Inf))
  x <- structure(list(config = list(facet = "Rater", group = "School", method = "refit",
    refit_output_version = 1L), dif_table = rows), class = c("mfrm_dff", "mfrm_dif"))
  report <- mfrm_report(x = x, type = "dff")
  expect_identical(report$counts, c(Conditional_plugin_screen = 1L,
    Linked_screening_only = 2L, Unclassified = 1L, Fixed_target = 1L,
    Unavailable = 1L, Total = 6L))
  expect_identical(names(report), c("narrative", "counts", "comparison_review",
    "large_dif", "gpcm_boundary", "config"))
  expect_null(report$comparison_review)
  expect_equal(nrow(report$large_dif), 0L)
  expect_match(report$narrative, "do not provide formal tests")
  x$config <- list(facet = "Rater", group = "School", method = "residual",
    residual_output_version = 3L)
  expect_identical(mfrm_report(x = x, type = "dff")$counts, c(Available = 2L, Unavailable = 4L, Total = 6L))

  cells <- data.frame(Level = c("R1", "R1", "R2", "R2"), GroupValue = c("A", "B", "A", "B"),
    ObsExpAvg = c(.7, .1, NA, -.8), StdResidual = c(1.3, .2, NA, -1.7), N = c(3L, 10L, 0L, 9L),
    sparse = c(TRUE, FALSE, NA, FALSE), flag_bias = c(TRUE, FALSE, NA, TRUE))
  cell_input <- structure(list(config = c(x$config, list(min_obs = 5, abs_bias_warn = .5)),
    table = cells, comparison_review = list(marker = "Not a pairwise comparison")),
    class = "mfrm_dif_interaction")
  cell_report <- mfrm_report(x = cell_input, type = "dff")
  expect_identical(cell_report$counts, c(Total = 4L, Sparse = 1L, Flag_t = NA_integer_, Flag_bias = 2L))
  flagged <- cells[c(1L, 4L), ]; rownames(flagged) <- NULL
  expect_identical(as.data.frame(cell_report$large_dif), flagged)
  expect_false("comparison_review" %in% names(cell_report))
  expect_match(cell_report$narrative, "magnitude comparison, not a test", fixed = TRUE)
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(cell_report, path)
  expect_identical(summary(readRDS(path)), summary(cell_report))
  cell_input$config$residual_output_version <- NULL
  expect_error(mfrm_report(x = cell_input, type = "dff"), "earlier residual inference")
})

test_that("common report helpers preserve note roles, rounding and GPCM context", {
  notes <- data.frame(Extra = c("x", "y"), Message = c("Inspect", "Retain"),
    Count = c(0L, NA_integer_), Area = c("Fit", "Scores"), Stage = c("Input", "Coding"),
    Condition = c("Sparse", "Missing"), Severity = c("review", "warn"),
    Categories = c("0,1", "2"), Affected = c("P1", "P2"), RecommendedAction = c("Inspect", "Keep"))
  caveats <- mfrmr:::summary_note_display_table(notes)
  preparation <- mfrmr:::summary_note_display_table(notes, preparation = TRUE)
  expect_identical(names(caveats), c("Area", "Severity", "Condition", "Categories", "Message", "RecommendedAction"))
  expect_identical(names(preparation), c("Stage", "Severity", "Condition", "Count", "Affected", "RecommendedAction"))
  expect_identical(preparation$Count, c(0L, NA_integer_))
  unknown <- notes["Extra"]
  expect_identical(mfrmr:::summary_note_display_table(unknown), unknown)
  expect_identical(mfrmr:::summary_note_display_table(NULL), data.frame())
  text <- capture.output(mfrmr:::print_note_section(notes, title = "Data preparation notes", preparation = TRUE))
  expect_identical(text[2L], "Data preparation notes")
  expect_identical(mfrmr:::simulation_planning_note(list(note = c("First", "Second"))), "First")
  expect_identical(mfrmr:::simulation_planning_note(list(note = 1)), character())
  expect_identical(mfrmr:::simulation_planning_note(list(note = character())), character())
  expect_identical(mfrmr:::simulation_planning_note(list(note = NA_character_)), NA_character_)

  numeric <- data.frame(Value = c(1.234, -3.456), Count = c(0L, NA_integer_), Label = c("X", "Y"))
  attr(numeric, "source") <- "Preserve metadata"
  expected <- numeric; expected$Value <- c(1.23, -3.46); expected$Count <- c(0, NA_real_)
  expect_identical(mfrmr:::round_numeric_df(numeric, 2), expected)
  expect_identical(mfrmr:::round_numeric_df(numeric[FALSE, ], 2), numeric[FALSE, ])
  expect_identical(mfrmr:::simulation_gpcm_boundary(FALSE), data.frame())
  expect_identical(mfrmr:::simulation_gpcm_boundary(TRUE)$Area,
    "Design evaluation and population forecasting under GPCM")
  expect_identical(mfrmr:::simulation_gpcm_boundary(TRUE, screening = TRUE)$Area,
    "Diagnostic and signal-detection design screening under GPCM")
  expect_identical(mfrmr:::simulation_gpcm_notes(FALSE), character())
  expect_match(mfrmr:::simulation_gpcm_notes(TRUE)[3L], "simulate_mfrm_recovery", fixed = TRUE)
  expect_match(mfrmr:::simulation_gpcm_notes(TRUE, screening = TRUE)[3L], "Type I proxy", fixed = TRUE)
  unavailable <- mfrmr:::simulation_gpcm_boundary
  lookup <- new.env(parent = environment(unavailable)); lookup$exists <- function(...) FALSE
  environment(unavailable) <- lookup
  expect_identical(unavailable(TRUE), data.frame())
})

test_that("specialist reports retain their classes through the common report entry", {
  old <- c("facet_statistics_report", "precision_review_report", "bias_iteration_report",
    "bias_pairwise_report", "dif_report", "reporting_checklist", "reference_case_review")
  expect_false(any(old %in% getNamespaceExports("mfrmr")))
  expect_false(any(vapply(old, exists, TRUE, envir = asNamespace("mfrmr"), inherits = FALSE)))
  types <- c("facet_statistics", "precision", "bias_iterations", "bias_pairwise", "dff",
    "checklist", "reference_review")
  for (type in types) {
    expect_error(mfrm_report(NULL, type = type, unknown = TRUE), "complete name")
    expect_error(mfrm_report(NULL, type = type, output = "tables"), "do not apply")
  }
  expect_error(mfrm_report(NULL, type = "precision", diagnostic = list()), "complete name")
  expect_error(mfrm_report(NULL, type = "precision", diagnostics = NULL, diagnostics = NULL),
    "complete name")
  expect_error(mfrm_report(NULL, type = "precision", NULL), "do not apply")
  expect_error(mfrm_report(NULL, type = "dff", ignored_before = TRUE), "complete name")
})

test_that("saved diagnostics connect component reports and consolidated reports without refitting", {
  saved <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
  optimization_calls <- 0L
  testthat::local_mocked_bindings(
    fit_mfrm = function(...) stop("Unexpected refit"),
    run_mfrm_optimization = function(...) {
      optimization_calls <<- optimization_calls + 1L
      stop("Unexpected optimization replay")
    },
    diagnose_mfrm = function(...) stop("Unexpected diagnostics"),
    estimate_bias = function(...) stop("Unexpected bias estimation"), .package = "mfrmr")
  fit <- saved$fit; diagnostics <- saved$diagnostics
  statistics <- mfrm_report(fit, type = "facet_statistics", diagnostics = diagnostics,
    distribution_basis = "sample", se_mode = "fit_adjusted")
  expect_s3_class(statistics, "mfrm_facet_statistics")
  expect_identical(statistics$precision_summary$Facet, c("Criterion", "Person", "Rater"))
  expect_identical(statistics$precision_summary$DistributionBasis, rep("sample", 3L))
  expect_identical(statistics$precision_summary$SEMode, rep("fit_adjusted", 3L))
  precision <- mfrm_report(fit, type = "precision", diagnostics = diagnostics)
  checklist <- mfrm_report(fit, type = "checklist", diagnostics = diagnostics)
  expect_s3_class(precision, "mfrm_precision_review")
  expect_s3_class(checklist, "mfrm_reporting_checklist")
  res <- mfrm_results(fit, diagnostics = diagnostics,
    include = c("fit", "diagnostics", "precision", "reporting", "plots"), compute = "never")
  expect_identical(res$components$precision_review, precision)
  expect_identical(res$components$reporting_checklist, checklist)
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(res, path)
  restored <- readRDS(path)
  expect_identical(summary(restored), summary(res))
  expect_identical(mfrm_report(restored, output = "markdown"), mfrm_report(res, output = "markdown"))
  expect_identical(mfrm_report(restored, output = "tables"), mfrm_report(res)$tables)
  html <- mfrm_report(restored, output = "html")
  original_html <- mfrm_report(res, output = "html")
  on.exit(unlink(c(html$path, original_html$path)), add = TRUE)
  expect_s3_class(html, "mfrm_report_html")
  expect_identical(html$html, original_html$html)
  expect_identical(optimization_calls, 0L)
})

test_that("the legacy facet-table deprecation constructs a valid replacement call", {
  saved <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
  withr::local_options(mfrmr.suppress_legacy_name_warning = FALSE)
  replacement <- NULL
  testthat::local_mocked_bindings(deprecate_soft = function(when, what, with, ...) {
    replacement <<- with
    invisible(NULL)
  }, .package = "lifecycle")
  out <- mfrmr:::table6_2_facet_statistics(saved$fit, saved$diagnostics)
  expect_identical(replacement, "mfrm_report()")
  expect_true(is.data.frame(out$table))
  expect_equal(nrow(out$table), 12L)
})
