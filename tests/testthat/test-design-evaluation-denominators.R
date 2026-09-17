test_that("design recommendations retain failed runs in convergence denominators", {
  # Public evaluation shape with known outcomes; no simulated responses or fits.
  prototype <- mfrmr:::design_eval_result_prototype()
  available <- prototype[rep(NA_integer_, 2), ]
  for (name in names(available)) {
    available[[name]] <- if (is.character(prototype[[name]])) rep("", 2) else if (
      is.logical(prototype[[name]])) rep(FALSE, 2) else rep(0, 2)
  }
  available$design_id <- "D1"
  available$rep <- 1L
  available$Facet <- c("Rater", "Criterion")
  available$n_person <- 30L
  available$n_rater <- 3L
  available$n_criterion <- 3L
  available$raters_per_person <- 2L
  available$Converged <- TRUE
  available$RecoveryComparable <- TRUE
  available$Separation <- 3
  available$Reliability <- .9
  available$SeverityRMSE <- .1
  available$MinCategoryCount <- 20
  complete <- dplyr::bind_rows(lapply(1:10, function(rep) {
    row <- available
    row$design_id <- "D2"
    row$n_person <- 40L
    row$rep <- rep
    row
  }))
  runs <- data.frame(
    design_id = rep(c("D1", "D2", "D3"), each = 10),
    rep = rep(1:10, 3),
    RunOK = c(TRUE, rep(FALSE, 9), rep(TRUE, 10), rep(FALSE, 10)),
    Converged = c(TRUE, rep(FALSE, 9), rep(TRUE, 10), rep(FALSE, 10)),
    ElapsedSec = 0
  )
  x <- structure(list(results = dplyr::bind_rows(available, complete),
    rep_overview = runs), class = "mfrm_design_evaluation")

  s <- summary(x, digits = 10)
  partial <- s$design_summary[s$design_summary$design_id == "D1", ]
  full <- s$design_summary[s$design_summary$design_id == "D2", ]
  expect_equal(partial$Reps, c(10, 10))
  expect_equal(partial$AvailableReps, c(1, 1))
  expect_equal(partial$ConvergenceRate, c(.1, .1))
  expect_equal(partial$McseConvergenceRate, rep(sqrt(.1 * .9 / 10), 2), tolerance = 1e-9)
  expect_equal(full$Reps, c(10, 10))
  expect_equal(full$AvailableReps, c(10, 10))
  expect_equal(full$ConvergenceRate, c(1, 1))
  expect_equal(s$design_summary$MeanSeverityRMSE, rep(.1, 4))
  expect_equal(s$overview$Replications, 30)
  expect_equal(s$overview$ConvergedRuns, 11)
  p <- plot(x, facet = "Rater", metric = "convergencerate", draw = FALSE)
  expect_equal(p$data$y, c(.1, 1))
  expect_identical(recommend_mfrm_design(x)$recommended$design_id, "D2")
  expect_identical(recommend_mfrm_design(s)$recommended$design_id, "D2")

  x$rep_overview$Converged[2] <- NA
  expect_equal(summary(x)$design_summary$ConvergenceRate, c(.1, 1, .1, 1))
  x$results <- prototype
  x$rep_overview <- runs[runs$design_id == "D3", ]
  failed <- summary(x)
  expect_equal(failed$overview$Replications, 10)
  expect_equal(failed$overview$ConvergedRuns, 0)
  expect_equal(nrow(failed$design_summary), 0)
  expect_error(recommend_mfrm_design(x), "No design summary rows")
})
