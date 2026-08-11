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

test_that("GPCM iteration report is an explicitly caveated replay", {
  replay <- suppressWarnings(estimation_iteration_report(
    .gpcm_fit,
    max_iter = 2L
  ))

  expect_s3_class(replay, "mfrm_iteration_report")
  expect_gt(nrow(replay$table), 0L)
  expect_true(any(is.finite(replay$table$Objective)))
  expect_equal(nrow(replay$gpcm_boundary), 1L)
  expect_identical(
    replay$gpcm_boundary$Area[1],
    "Replayed optimization diagnostics under bounded GPCM"
  )
  expect_identical(
    replay$gpcm_boundary$Status[1],
    "supported_with_caveat"
  )
  expect_match(replay$gpcm_boundary$Boundary[1], "replay")
})

test_that("GPCM diagnose_mfrm returns measures with caveat status", {
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(.gpcm_fit, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  expect_true(is.data.frame(diag$measures))
  expect_true(nrow(diag$measures) > 0L)
  source_readiness <- mfrmr_get_readiness_record(.gpcm_fit)
  expect_equal(diag$fit_readiness, source_readiness$fit)
  expect_equal(diag$fit_readiness_components, source_readiness$components)
  expect_equal(diag$fit_readiness_parameters, source_readiness$parameters)
  diag_summary <- summary(diag)
  expect_equal(
    as.data.frame(diag_summary$fit_readiness),
    as.data.frame(source_readiness$fit)
  )
  expect_true(any(grepl(
    "source fit is review and is not inference-ready",
    diag_summary$key_warnings,
    fixed = TRUE
  )))
  diag_console <- capture.output(print(diag_summary))
  expect_true(any(grepl("Source fit readiness", diag_console, fixed = TRUE)))
  expect_true(any(grepl("review-only", diag_console, fixed = TRUE)))
  # The dashboard panel remains unavailable under GPCM; direct
  # fair_average_table() is supported with its own caveat.
  if (!is.null(diag$fair_average)) {
    fa_msg <- as.character(diag$fair_average$status %||% "")
    expect_true(any(grepl("placeholder|unavailable|GPCM", fa_msg,
                           ignore.case = TRUE)) ||
                  is.null(diag$fair_average$table) ||
                  nrow(as.data.frame(diag$fair_average$table)) == 0L)
  }
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
  expect_identical(
    names(m),
    c("Area", "Helpers", "Status", "Boundary", "RecommendedRoute")
  )
  expect_true(all(m$Status %in%
                    c("supported", "supported_with_caveat", "blocked", "deferred")))
})

test_that("GPCM APA/QC reporting bundle returns with explicit caveats", {
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(.gpcm_fit, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  apa <- suppressMessages(build_apa_outputs(.gpcm_fit, diag))
  expect_s3_class(apa, "mfrm_apa_outputs")
  expect_true(nrow(apa$gpcm_boundary) > 0)
  expect_true(grepl("Bounded\\s+GPCM note", apa$report_text))

  qc <- run_qc_pipeline(.gpcm_fit, diag)
  expect_s3_class(qc, "mfrm_qc_pipeline")
  expect_true(nrow(qc$gpcm_boundary) > 0)
})

test_that("five-category all-maximum persons and raters retain distinct contracts", {
  skip_if_not_installed("lpSolve")
  extreme <- expand.grid(
    Person = sprintf("P%02d", 1:20),
    Rater = paste0("R", 1:4),
    Criterion = paste0("C", 1:4),
    stringsAsFactors = FALSE
  )
  extreme$Score <- (
    as.integer(sub("P", "", extreme$Person)) +
      2L * as.integer(sub("R", "", extreme$Rater)) +
      3L * as.integer(sub("C", "", extreme$Criterion))
  ) %% 5L + 1L
  extreme$Score[extreme$Person == "P01"] <- 5L
  extreme$Score[extreme$Rater == "R1"] <- 5L

  jml <- suppressMessages(suppressWarnings(fit_mfrm(
    extreme, "Person", c("Rater", "Criterion"), "Score",
    method = "JML", model = "GPCM",
    step_facet = "Criterion", slope_facet = "Criterion",
    maxit = 80L, reltol = 1e-9
  )))
  jml_person <- jml$facets$person[jml$facets$person$Person == "P01", , drop = FALSE]
  expect_identical(jml_person$PrimaryEstimate, Inf)
  expect_true(is.finite(jml_person$OptimizerEstimate))
  expect_identical(jml_person$OptimizerEstimateUse, "numerical_trace_only")
  expect_identical(jml_person$ParameterStatus, "unbounded_high")

  jml_summary <- summary(jml, include_person = TRUE)
  expect_identical(jml_summary$facet_support_boundaries$Level, "R1")
  expect_true(jml_summary$facet_support_boundaries$BoundaryConstant)
  rater_recession <- jml_summary$facet_recession_review[
    jml_summary$facet_recession_review$Facet == "Rater", , drop = FALSE
  ]
  expect_identical(rater_recession$Level, paste0("R", 1:4))
  expect_identical(
    rater_recession$BoundaryStatus,
    c("unbounded_low", rep("unbounded_high", 3L))
  )
  expect_true(all(rater_recession$AuditScope == "joint_person_structural"))
  expect_false(any(rater_recession$AuditComplete))
  jml_console <- capture.output(print(jml_summary))
  expect_true(any(grepl("Observed boundary-constant facet support", jml_console)))
  expect_true(any(grepl("Certified JML facet recession directions", jml_console)))
  expect_true(any(grepl("numerical traces, not finite JML maxima", jml_console)))

  mml <- suppressMessages(suppressWarnings(fit_mfrm(
    extreme, "Person", c("Rater", "Criterion"), "Score",
    method = "MML", model = "GPCM",
    step_facet = "Criterion", slope_facet = "Criterion",
    quad_points = 7L, maxit = 80L, reltol = 1e-9
  )))
  mml_person <- mml$facets$person[mml$facets$person$Person == "P01", , drop = FALSE]
  expect_true(is.finite(mml_person$PrimaryEstimate))
  expect_true(is.finite(mml_person$PosteriorSD))
  expect_identical(mml_person$PrimaryEstimateBasis, "posterior_eap")
  expect_identical(
    mml_person$ReasonCodes,
    "mml_extreme_response_prior_regularized"
  )
  mml_summary <- summary(mml, include_person = TRUE)
  expect_identical(mml_summary$facet_support_boundaries$Level, "R1")
  expect_equal(nrow(mml_summary$facet_recession_review), 0L)
})
