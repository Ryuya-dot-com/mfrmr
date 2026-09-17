design_evaluation_denominator_fixture <- function() {
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
  structure(list(results = dplyr::bind_rows(available, complete),
    rep_overview = runs), class = "mfrm_design_evaluation")
}

test_that("design recommendations retain failed runs in convergence denominators", {
  x <- design_evaluation_denominator_fixture()
  runs <- x$rep_overview

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
  x$results <- mfrmr:::design_eval_result_prototype()
  x$rep_overview <- runs[runs$design_id == "D3", ]
  failed <- summary(x)
  expect_equal(failed$overview$Replications, 10)
  expect_equal(failed$overview$ConvergedRuns, 0)
  expect_equal(nrow(failed$design_summary), 0)
  expect_error(recommend_mfrm_design(x), "No design summary rows")
})

test_that("workload limits include failed runs and preserve ranking within limits", {
  x <- design_evaluation_denominator_fixture()
  # D1 has a costly failed run; its mean workload would conceal the overrun.
  x$rep_overview$Observations <- c(rep(180, 9), 480, rep(240, 10), rep(300, 10))
  x$rep_overview$MaxRatingsPerRater <- c(rep(90, 9), 200, rep(80, 10), rep(100, 10))
  s <- summary(x)
  d1 <- s$design_summary[s$design_summary$design_id == "D1", ]
  expect_equal(d1$MaxRatings, c(480, 480))
  expect_equal(d1$MaxRatingsPerRater, c(200, 200))
  expect_identical(recommend_mfrm_design(x, min_convergence_rate = .1)$recommended$design_id, "D1")

  total <- recommend_mfrm_design(x, min_convergence_rate = .1, max_ratings = 300)
  expect_identical(total$recommended$design_id, "D2")
  expect_false(total$design_table$RatingsPass[total$design_table$design_id == "D1"])
  expect_true(all(total$facet_table$Pass))
  per_rater <- recommend_mfrm_design(s, min_convergence_rate = .1, max_ratings_per_rater = 100)
  expect_identical(per_rater$recommended$design_id, "D2")
  expect_false(per_rater$design_table$RaterWorkloadPass[per_rater$design_table$design_id == "D1"])
  boundary <- recommend_mfrm_design(x, min_convergence_rate = .1,
    max_ratings = 480, max_ratings_per_rater = 200)
  expect_identical(boundary$recommended$design_id, "D1")
  expect_equal(boundary$thresholds$max_ratings, 480)
  expect_equal(boundary$thresholds$max_ratings_per_rater, 200)
  expect_equal(nrow(recommend_mfrm_design(x, max_ratings = 0)$recommended), 0)
  expect_equal(nrow(recommend_mfrm_design(x, max_ratings_per_rater = 79)$recommended), 0)

  # Unknown counts cannot be omitted when checking a hard workload limit.
  x$rep_overview$Observations[10] <- NA
  x$rep_overview$MaxRatingsPerRater[10] <- NA
  d1 <- summary(x)$design_summary
  expect_true(all(is.na(d1$MaxRatings[d1$design_id == "D1"])))
  expect_true(all(is.na(d1$MaxRatingsPerRater[d1$design_id == "D1"])))
  expect_identical(recommend_mfrm_design(x, min_convergence_rate = .1,
    max_ratings = 1000, max_ratings_per_rater = 1000)$recommended$design_id, "D2")
})

test_that("legacy workload records are unknown without changing uncapped recommendations", {
  x <- design_evaluation_denominator_fixture()
  x$rep_overview$Observations <- 240
  expect_identical(recommend_mfrm_design(x, max_ratings = 240)$recommended$design_id, "D2")
  expect_equal(nrow(recommend_mfrm_design(x, max_ratings_per_rater = 1000)$recommended), 0)
  s <- summary(x)
  s$design_summary$MaxRatings <- NULL
  s$design_summary$MaxRatingsPerRater <- NULL
  expect_identical(recommend_mfrm_design(s)$recommended$design_id, "D2")
  expect_equal(nrow(recommend_mfrm_design(s, max_ratings = 1000)$recommended), 0)
  expect_equal(nrow(recommend_mfrm_design(s, max_ratings_per_rater = 1000)$recommended), 0)
})

test_that("workload limits require finite non-negative whole numbers", {
  x <- design_evaluation_denominator_fixture()
  for (name in c("max_ratings", "max_ratings_per_rater")) {
    for (value in list(-1, .5, NA_real_, Inf, numeric(0), c(1, 2), "100", TRUE)) {
      args <- c(list(x = x), stats::setNames(list(value), name))
      expect_error(do.call(recommend_mfrm_design, args), paste0("`", name, "` must be"))
    }
  }
})

test_that("actual unweighted assignment counts survive fit and diagnostic failures", {
  calls <- 0L
  testthat::local_mocked_bindings(
    fit_mfrm = function(...) {
      calls <<- calls + 1L
      if (calls == 1L) stop("forced fit failure")
      list()
    },
    diagnose_mfrm = function(...) stop("forced diagnostic failure"),
    .package = "mfrmr"
  )
  skeleton <- rbind(
    expand.grid(TemplatePerson = paste0("P", 1:4), Judge = "J1", Task = c("T1", "T2")),
    expand.grid(TemplatePerson = paste0("P", 1:2), Judge = "J2", Task = c("T1", "T2")),
    data.frame(TemplatePerson = "P3", Judge = "J3", Task = "T1")
  )
  skeleton$TemplatePersonReuse <- TRUE
  skeleton$Weight <- 7
  spec <- build_mfrm_sim_spec(n_person = 4, n_rater = 3,
    n_criterion = 2, raters_per_person = 2, facet_names = c("Judge", "Task"),
    assignment = "skeleton", design_skeleton = skeleton)
  x <- evaluate_mfrm_design(sim_spec = spec, n_person = 4, n_rater = 3,
    n_criterion = 2, raters_per_person = 2, reps = 2, seed = 123, progress = FALSE)
  expect_equal(x$rep_overview$Observations, c(13, 13))
  expect_equal(x$rep_overview$MaxRatingsPerRater, c(8, 8))
  expect_identical(x$rep_overview$ErrorComponent, c("fit", "diagnostics"))
  expect_false(any(x$rep_overview$RunOK))
  expect_equal(nrow(x$results), 0)
})
