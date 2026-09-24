test_that("packaged extended examples are coherent and replay without recomputation", {
  path <- system.file("examples", "extended-models.rds", package = "mfrmr", mustWork = TRUE)
  x <- readRDS(path)
  before <- serialize(x, NULL)
  ratings <- load_mfrmr_data("example_core")
  for (model in x) {
    expect_true(model$fit$checks$NumericalReady)
    expect_true(model$fit$checks$InformationPositive)
    data <- model$fit$input$assigned_data
    if (is.null(data)) data <- model$fit$input$data
    expect_equal(data, ratings[names(data)], ignore_attr = TRUE)
    expect_equal(model$fit$settings$quad_points, 121)
    expect_true(all(is.na(model$fit$calibration_table$Lower)))
    expect_true(all(is.na(model$fit$calibration_table$Upper)))
  }
  expect_identical(x$random_rater$intervals$source, x$random_rater$fit)
  expect_true(all(is.na(x$random_rater$fit$raters$Lower)))
  expect_true(all(is.na(x$random_rater$fit$raters$Upper)))
  expect_equal(nrow(x$random_rater$intervals$trials), 19)
  expect_equal(nrow(x$random_rater$intervals$error), 19)
  expect_equal(x$testlet$scores$table$Person, sprintf("P%03d", 1:4))
  expect_equal(x$random_rater$scores$table$Person, sprintf("P%03d", 1:2))
  expect_equal(x$testlet$scores$scoring_data, x$testlet$fit$input$assigned_data)

  blocked <- function(...) stop("Unexpected statistical recomputation")
  local_mocked_bindings(fit_mfrm_testlet = blocked, fit_mfrm_random_rater = blocked,
    predict.mfrm_testlet = blocked, score_mfrm_random_rater = blocked,
    mfrm_random_rater_intervals = blocked, mfrm_response_diagnostics = blocked,
    .package = "mfrmr")
  testlet <- mfrm_results(x$testlet$fit, scores = x$testlet$scores,
    response_diagnostics = x$testlet$diagnostics, compute = "never")
  random <- mfrm_results(x$random_rater$fit, scores = x$random_rater$scores,
    intervals = x$random_rater$intervals, compute = "never")
  expect_s3_class(testlet, "mfrm_results")
  expect_s3_class(random, "mfrm_results")
  expect_equal(unname(summary(x$random_rater$intervals)$trials["Planned"]), 19)
  expect_equal(nrow(confint(x$random_rater$intervals, level = .90)), 4)
  for (result in list(testlet, random)) {
    p <- plot(result, type = "wright", draw = FALSE)
    expect_equal(p$data, plot_data(result, type = "wright"))
  }
  expect_equal(plot(x$testlet$diagnostics, draw = FALSE)$data,
    plot_data(x$testlet$diagnostics))
  expect_identical(serialize(x, NULL), before)

  # Reading the optional regeneration script must not start an estimator.
  recipe <- new.env(parent = baseenv())
  sys.source(system.file("examples", "extended-models.R", package = "mfrmr",
    mustWork = TRUE), envir = recipe)
  expect_true(is.function(recipe$extended_model_examples))
})
