# Reuse retained fits. These checks must never optimize or simulate new data.
native_location_fixture <- local({
  saved <- list()
  function(name = c("separate", "paired", "single", "shared", "regression", "pcm", "fixed")) {
    name <- match.arg(name)
    if (!is.null(saved[[name]])) return(saved[[name]])
    if (name == "separate") {
      fit <- readRDS(test_path("fixtures", "mfrm-conditional-scoring-gpcm.rds"))$fit
    } else if (name == "fixed") {
      fit <- readRDS(test_path("fixtures", "native-location-fixed-gpcm.rds"))
    } else if (name == "pcm") {
      path <- test_path("..", "..", "validation-results", "gpcm-separated-owners-20260926", "fit", "pcm.rds")
      skip_if_not(file.exists(path), "Repository-only retained intercept-population PCM fit")
      fit <- readRDS(path)$value
    } else if (name == "shared") {
      path <- test_path("..", "..", "validation-results", "gpcm-probability-refit-20260925", "refit-788.rds")
      skip_if_not(file.exists(path), "Repository-only retained shared-owner fit")
      fit <- readRDS(path)$fit
    } else {
      path <- test_path("..", "..", "inst", "validation", "population-full-information-evidence-0.2.4.rds")
      skip_if_not(file.exists(path), "Repository-only independent population information archive")
      key <- switch(name, paired = "paired-61", single = "single-31", regression = "PCM-61")
      fit <- readRDS(path)$results[[key]]$result$fit
    }
    saved[[name]] <<- fit
    fit
  }
})

# Share interval qualification across tests; the finer-grid failure test also
# evaluates the same retained separate-owner Hessian once. Replay tests below
# replace fitting/covariance entry points with errors.
native_location_result <- local({
  saved <- list()
  function(name = "separate") {
    if (is.null(saved[[name]])) saved[[name]] <<- suppressWarnings(
      mfrm_facet_intervals(native_location_fixture(name), "Rater"))
    saved[[name]]
  }
})

test_that("native locations retain full nuisance covariance at fixed fitted points", {
  local_mocked_bindings(fit_mfrm = function(...) stop("No refitting"),
    simulate_mfrm_data = function(...) stop("No simulation"),
    mfrm_mml_person_scores_numeric = function(...) stop("No empirical Person-score rank gate"),
    .package = "mfrmr")
  for (name in c("separate", "paired", "shared", "pcm", "fixed")) {
    fit <- native_location_fixture(name); before <- fit
    ci <- native_location_result(name)
    expect_true(all(ci$checks$Passed))
    expect_true(all(ci$table$CIEligible))
    expect_identical(ci$settings$procedure, "mml_native_location_model_v1")
    expect_identical(ci$settings$scale, "native_ability")
    expect_identical(ci$settings$comparison_quad_points, 2 * ci$settings$quad_points - 1)
    expect_identical(ci$fit, before)
    expect_identical(fit, before)
    expect_identical(ci$fit$readiness, fit$readiness)
    expect_equal(ci$table$Lower, ci$table$Estimate - qnorm(.975) * ci$table$SE)
    sizes <- build_param_sizes(fit$config)
    slice <- build_param_slices(sizes)$Rater
    n <- length(fit$prep$levels$Rater)
    J <- matrix(0, n, length(fit$opt$par))
    J[, slice] <- rbind(diag(n - 1L), rep(-1, n - 1L))
    expect_equal(unname(ci$target_jacobian), J)
    expect_equal(ci$covariance, J %*% ci$parameter_covariance %*% t(J), ignore_attr = TRUE)
    expect_match(paste(ci$cautions, collapse = " "), "not standardized")
    expect_null(ci$person_scores)
    expect_null(ci$score_rank)
  }
  # Independently differentiated continuous-information reference, not a
  # second call to the package Hessian used to construct the interval.
  archive <- readRDS(test_path("..", "..", "inst", "validation",
    "population-full-information-evidence-0.2.4.rds"))$results[["paired-61"]]$result
  ci <- native_location_result("paired")
  J <- ci$target_jacobian
  expect_equal(ci$covariance, J %*% archive$reference$covariance %*% t(J),
    ignore_attr = TRUE, tolerance = 1e-5)
  expect_gt(abs(ci$parameter_covariance[1, 1] - 1 / archive$reference$hessian[1, 1]), 1e-5)
})

test_that("fixed-normal native locations recognize the public fit metadata", {
  fit <- native_location_fixture("fixed")
  expect_false(fit$population$active)
  expect_identical(fit$config$posterior_basis, "legacy_mml")
  expect_identical(fit$config$gpcm_mml_identification, "fixed_standard_normal")
  expect_true(all(native_location_result("fixed")$table$CIEligible))
  local_mocked_bindings(compute_mml_parameter_covariance = function(...) stop("No information for inconsistent coding"),
    .package = "mfrmr")
  for (change in list(
    function(f) { f$config$posterior_basis <- "fixed_standard_normal"; f },
    function(f) { f$config$gpcm_mml_identification <- "free_population"; f },
    function(f) { f$population$active <- TRUE; f })) {
    expect_error(mfrm_facet_intervals(change(fit), "Rater"), "Population coding")
  }
})

test_that("fixed and redundant native contrasts remain pointwise targets", {
  base <- native_location_result("separate")
  V <- base$parameter_covariance
  local_mocked_bindings(mfrm_native_location_inference = function(...) list(
    covariance = V, information = list(status = "ok"), checks = base$checks,
    check = list(eligible = TRUE, review = "Saved positive-control qualification")), .package = "mfrmr")
  C <- rbind(Difference = c(1, -1, 0), Reverse = c(-1, 1, 0), Sum = c(1, 1, 1))
  colnames(C) <- base$table$Target
  ci <- suppressWarnings(mfrm_facet_intervals(base$fit, "Rater", C[, 3:1], level = .9))
  expect_equal(ci$table$Estimate, as.numeric(C %*% base$table$Estimate))
  expect_equal(ci$covariance, C %*% base$covariance %*% t(C), ignore_attr = TRUE)
  expect_equal(ci$table$Lower[1], -ci$table$Upper[2])
  expect_identical(ci$table$Status, c("available", "available", "fixed"))
  expect_identical(ci$table$CIEligible, c(TRUE, TRUE, FALSE))
  expect_equal(ci$table$SE[3], 0)
  expect_true(is.na(ci$table$Lower[3]))
  expect_true(all(ci$covariance[3, ] == 0))
})

test_that("scope and altered metadata fail before information evaluation", {
  fit <- native_location_fixture()
  local_mocked_bindings(compute_mml_parameter_covariance = function(...) stop("Unexpected information evaluation"),
    .package = "mfrmr")
  expect_error(mfrm_facet_intervals(fit, "Rater", method = "sandwich"), "sandwich intervals are unavailable")
  expect_error(mfrm_facet_intervals(native_location_fixture("regression"), "Rater"), "intercept-only")
  changes <- list(
    locations = function(f) { f$facets$others$Estimate[1] <- 999; f },
    steps = function(f) { f$steps$Estimate[1] <- 999; f },
    slopes = function(f) { f$slopes$Estimate[1] <- 999; f },
    population = function(f) { f$population$sigma2 <- 999; f },
    coding = function(f) { f$config$population_spec$person_lookup[1] <- NA_integer_; f },
    integration = function(f) { f$config$estimation_control$mml_integration <- "unknown"; f },
    constraints = function(f) { f$config$facet_specs$Rater$centered <- FALSE; f },
    weights = function(f) { f$prep$data$Weight[1] <- 2; f })
  patterns <- c("Saved locations", "Saved steps", "Saved slopes", "Saved population", "Population coding", "integration metadata", "sum-to-zero", "unit weights")
  for (i in seq_along(changes)) expect_error(
    mfrm_facet_intervals(changes[[i]](fit), "Rater"), patterns[i])
})

test_that("known nonidentification keeps points without differentiating", {
  fit <- native_location_fixture("single")
  local_mocked_bindings(compute_mml_parameter_covariance = function(...) stop("A known failure must stop first"),
    .package = "mfrmr")
  ci <- suppressWarnings(mfrm_facet_intervals(fit, "Rater"))
  expect_true(all(is.finite(ci$table$Estimate)))
  expect_true(all(!ci$table$CIEligible))
  expect_true(all(is.na(ci$table$SE) & is.na(ci$table$Lower) & is.na(ci$table$ModelLower)))
  expect_identical(ci$table$Status, rep("numerical_review_failed", nrow(ci$table)))
  expect_match(ci$table$InferenceReview[1], "identification failure")
  expect_null(ci$parameter_covariance)
})

test_that("finer-grid failures cannot leak model bounds", {
  fit <- native_location_fixture()
  ci <- native_location_result()
  information <- compute_mml_parameter_covariance(fit)
  expect_length(information$solution_information$gradient, length(fit$opt$par))
  q <- fit$config$estimation_control$quad_points
  mode <- "unavailable"
  local_mocked_bindings(compute_mml_parameter_covariance = function(res, retained_matrices = 0L) {
    expect_identical(res$opt$par, fit$opt$par)
    if (res$config$estimation_control$quad_points == q) return(information)
    expect_identical(res$config$estimation_control$quad_points, 2 * q - 1)
    expect_equal(retained_matrices, 2L)
    if (mode == "unavailable") return(list(status = "unavailable", detail = "Injected finer-grid failure"))
    if (mode == "nonfinite") {
      information$solution_information$gradient[1] <- Inf
    } else {
      information$cov <- 1.05 * information$cov
      information$hessian <- information$hessian / 1.05
    }
    information
  }, .package = "mfrmr")
  failed <- suppressWarnings(mfrm_facet_intervals(fit, "Rater"))
  expect_equal(failed$table$Estimate, ci$table$Estimate)
  expect_true(all(is.na(failed$table$Lower) & is.na(failed$table$ModelLower)))
  expect_match(failed$table$InferenceReview[1], "Injected finer-grid failure")
  expect_false(tail(failed$checks$Passed, 1))
  for (next_mode in c("nonfinite", "changed")) {
    mode <- next_mode
    failed <- suppressWarnings(mfrm_facet_intervals(fit, "Rater"))
    expect_equal(failed$table$Estimate, ci$table$Estimate)
    expect_true(all(!failed$table$CIEligible & is.na(failed$table$SE)))
    expect_false(tail(failed$checks$Passed, 1))
  }
  expect_gt(failed$numerical_checks$QuadratureCovarianceChange, .01)
})

test_that("retained information matrices count against the same workspace budget", {
  fit <- native_location_fixture()
  p <- length(fit$opt$par)
  # Ten dense matrices do not fit; reject before the Hessian is requested.
  withr::local_options(mfrmr.max_information_bytes = 9 * 8 * p^2)
  local_mocked_bindings(make_param_cache = function(...) stop("No evaluator allocation expected"),
    .package = "mfrmr")
  info <- compute_mml_parameter_covariance(fit, retained_matrices = 2L)
  expect_identical(info$status, "unavailable")
  expect_null(info$cov)
  expect_match(info$detail, "No matrix was allocated")
})

test_that("native interval reports and exports replay without covariance calculations", {
  # Resolve all retained results before forbidding numerical work during replay.
  inputs <- lapply(c("separate", "paired", "shared", "pcm", "fixed"), native_location_result)
  local_mocked_bindings(fit_mfrm = function(...) stop("No refitting"),
    compute_mml_parameter_covariance = function(...) stop("No covariance evaluation"), .package = "mfrmr")
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  for (ci in inputs) {
    gpcm <- identical(ci$fit$config$model, "GPCM")
    key <- if (gpcm) "gpcm_locations" else "facet_locations"
    table_key <- paste0(key, "_intervals")
    saveRDS(ci, path); ci <- readRDS(path)
    res <- mfrm_results(ci$fit, intervals = list(locations = ci), include = c("fit", "plots"), compute = "never")
    expect_identical(res$tables[[table_key]]$Lower, ci$table$Lower)
    p <- plot_data(plot(res, type = key, draw = FALSE))
    expect_identical(p$table, ci$table)
    expect_match(p$subtitle, "Experimental native locations")
    expect_match(p$xlab, "native ability units")
    expect_identical(mfrm_report(res)$tables[[table_key]], res$tables[[table_key]])
    for (change in list(
      function(f) { f$config$facet_specs$Rater$centered <- FALSE; f },
      function(f) { f$config$estimation_control$quad_points <- 121L; f },
      function(f) { f$population$sigma2 <- 9; f })) {
      expect_error(mfrm_results(change(ci$fit), intervals = ci, compute = "never"), "must match")
    }
    folder <- tempfile("native-location-export-")
    on.exit(unlink(folder, recursive = TRUE), add = TRUE)
    suppressWarnings(export_mfrm_results(res, output_dir = folder,
      include = c("tables", "report", "replay"), preset = "starter", acknowledge_sensitive = TRUE))
    files <- list.files(folder, recursive = TRUE, full.names = TRUE)
    replay <- readRDS(files[grepl("\\.rds$", files)][1])
    saved <- if (gpcm) replay$gpcm_inference$locations else replay$facet_intervals$locations
    expect_identical(saved$table, ci$table)
    expect_identical(saved$source, ci$source)
  }
})
