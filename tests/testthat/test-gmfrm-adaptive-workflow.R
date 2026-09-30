test_that("two-family adaptive fitting preserves its objective and output scope", {
  data <- expand.grid(Candidate = paste0("p", 1:12),
    A = c("same", "a2", "a3"), B = c("same", "b2"))
  data <- data[!(data$A == "a3" & data$B == "b2"), ]
  data$Rating <- rep(c(0, 2, 1, 1, 2, 0, 2, 1, 0, 1), length.out = nrow(data))
  names(data)[2:3] <- c("First owner", "Second owner")
  args <- list(data = data, person = "Candidate", facets = names(data)[3:2],
    score = "Rating", model = "GPCM", method = "MML",
    slope_facet = names(data)[2:3], step_facet = names(data)[3],
    noncenter_facet = names(data)[3], gpcm_mml_identification = "fixed_standard_normal",
    mml_engine = "direct", mml_integration = "adaptive", quad_points = 7L, maxit = 1L)
  fit <- suppressWarnings(do.call(fit_mfrm, args))
  expect_s3_class(fit, "mfrm_fit")
  expect_identical(fit$summary$MMLEngineUsed, "direct")
  expect_identical(fit$summary$MMLIntegration, "adaptive")
  expect_identical(fit$summary$ConvergenceBasis, "optimizer_gradient")
  expect_false(fit$summary$Converged)
  expect_false(fit$summary$InferenceReady)
  expect_false(fit$summary$ICEligible)
  expect_null(fit$opt$em_trace)
  expect_null(fit$config$replay_inputs$em_score_tol)
  expect_identical(fit$config$replay_inputs$reltol, 1e-9)
  setup <- do.call(mfrm_gmfrm_problem, fit$gmfrm$specification)$common
  review <- mfrmr_adaptive_quadrature_review(setup$idx, fit$config,
    expand_params(fit$opt$par, setup$sizes, fit$config),
    gauss_hermite_normal(7L), fit$prep$levels$Person, 7L)
  expect_equal(fit$summary$LogLik, sum(review$AdaptiveLogMarginal), tolerance = 1e-12)
  expect_gt(abs(sum(review$FixedLogMarginal) - fit$summary$LogLik), 1e-7)
  ci <- confint(fit)
  expect_true(all(is.na(ci)))
  expect_match(attr(ci, "diagnostics")$InferenceReview[1], "adaptive-fit component intervals")
  expect_output(print(fit), "adaptive Gauss-Hermite")
  expect_identical(summary(fit)$slope_overview$SlopeOwner, names(data)[2:3])
  grid <- data.frame(Theta = c(-1, 0, 1))
  grid[[names(data)[2]]] <- "a2"; grid[[names(data)[3]]] <- "b2"
  curves <- mfrm_curve_intervals(fit, grid)
  expect_s3_class(as_ggplot(curves), "ggplot")
  results <- mfrm_results(fit, include = c("fit", "plots"), compute = "never",
    intervals = list(curves = curves, slopes = ci))
  report <- mfrm_report(results)
  expect_match(report$markdown, "Direct adaptive MML did not pass")
  expect_false(grepl("EM stopped|EM stopping", report$markdown))
  expect_match(report$markdown, "intervals are unavailable for adaptive")
  unresolved <- results
  unresolved$fit$summary$Converged <- TRUE
  unresolved$fit$opt$optimizer_diagnostics$ConvergenceSeverity <- "review"
  expect_match(mfrm_report(unresolved)$markdown, "did not pass its numerical")
  # A component profile must also stop before using fixed-grid curvature.
  expect_error(confint(fit, method = "profile", slope = c(`First owner` = "a2")),
    "adaptive-fit component intervals are unavailable")
  expect_error(mfrm_response_diagnostics(fit), "fixed-N\\(0,1\\) MML-EM")
  expect_error(predict_mfrm_units(fit, data), class = "mfrmr_gpcm_scope_error")
  file <- tempfile(fileext = ".rds"); on.exit(unlink(file), add = TRUE)
  saveRDS(fit, file); restored <- readRDS(file)
  expect_identical(restored, fit)
  replay <- restored$config$replay_inputs
  replay$package_version <- NULL; replay$data <- data
  expect_identical(suppressWarnings(do.call(fit_mfrm, replay))$summary, fit$summary)
  comparison <- suppressWarnings(mml_quadrature_sensitivity(fit, data,
    quad_points = c(7, 9), adaptive_quad_points = c(7, 9)))
  expect_true(all(vapply(comparison$fits, function(x)
    identical(x$config$estimation_control$mml_integration, "adaptive"), TRUE)))
  expect_true(all(vapply(comparison$intervals, function(x) all(is.na(x)), TRUE)))
  expect_true(all(comparison$quadrature_review$Status == "computed"))
  args$em_score_tol <- 1e-6
  expect_error(do.call(fit_mfrm, args), "not supported by the two-family route")
  args$em_score_tol <- NULL; args$reltol <- 0
  expect_error(do.call(fit_mfrm, args), "finite positive")
})
