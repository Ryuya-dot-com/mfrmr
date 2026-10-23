test_that("simulation consumer examples retain their settings and failed-run evidence", {
  saved <- readRDS(system.file("examples", "simulation-results.rds",
    package = "mfrmr", mustWork = TRUE))
  classes <- c(recovery = "mfrm_recovery_simulation", design = "mfrm_design_evaluation",
    diagnostic_screening = "mfrm_diagnostic_screening",
    signal_detection = "mfrm_signal_detection", population = "mfrm_population_prediction")
  for (name in names(classes)) {
    expect_s3_class(saved[[name]], classes[[name]])
    expect_equal(saved[[name]]$settings$reps, 1)
    expect_equal(saved[[name]]$settings$seed, 123)
    expect_equal(saved[[name]]$settings$maxit, 30)
  }
  expect_equal(saved$design$rep_overview$n_person, c(8, 12))
  expect_true(any(!saved$design$rep_overview$Converged))
  expect_false(saved$recovery$rep_overview$Converged)
  expect_true(saved$signal_detection$rep_overview$RunOK)
  expect_match(paste(saved$generation_warnings, collapse = " "), "iteration limit")
  expect_match(paste(saved$generation_warnings, collapse = " "), "Category support")
})

test_that("saved simulation consumers and recipe loading never regenerate responses or fits", {
  path <- system.file("examples", "simulation-results.rds", package = "mfrmr", mustWork = TRUE)
  saved <- readRDS(path)
  before <- serialize(saved, NULL)
  blocked <- function(...) stop("Unexpected simulation or refitting")
  local_mocked_bindings(simulate_mfrm_data = blocked, fit_mfrm = blocked,
    simulate_mfrm_recovery = blocked, evaluate_mfrm_design = blocked,
    evaluate_mfrm_diagnostic_screening = blocked, evaluate_mfrm_signal_detection = blocked,
    predict_mfrm_population = blocked, .package = "mfrmr")
  recipe <- new.env(parent = baseenv())
  sys.source(system.file("examples", "simulation-results.R", package = "mfrmr",
    mustWork = TRUE), envir = recipe)
  expect_true(is.function(recipe$simulation_result_examples))
  for (x in saved[setdiff(names(saved), "generation_warnings")]) {
    expect_true(is.list(summary(x)))
  }
  plots <- list(
    recovery = plot(saved$recovery, type = "summary", metric = "rmse", draw = FALSE),
    design = plot(saved$design, facet = "Rater", metric = "separation", x_var = "n_person", draw = FALSE),
    diagnostic = plot(saved$diagnostic_screening, type = "overview", draw = FALSE),
    report = plot(saved$diagnostic_screening, type = "report", metric = "rate", draw = FALSE),
    signal = plot(saved$signal_detection, signal = "dif", metric = "power", x_var = "n_person", draw = FALSE)
  )
  for (x in plots[c("recovery", "diagnostic", "report")]) expect_s3_class(x, "mfrm_plot_data")
  for (x in plots[c("design", "signal")]) {
    expect_type(x, "list")
    expect_true(is.data.frame(x$data))
  }
  rec <- recommend_mfrm_design(saved$design, max_ratings = 48, max_ratings_per_rater = 24)
  expect_true(is.data.frame(rec$recommended))
  expect_identical(serialize(saved, NULL), before)
  expect_identical(readRDS(path), saved)
})
