test_that("adaptive starts retain better unfinished solutions and failed alternatives", {
  problem <- list(start = 0, common = list(idx = list(), sizes = list()))
  config <- list(estimation_control = list(mml_integration = "adaptive"))
  mode <- "both"; calls <- numeric()
  local_mocked_bindings(
    mfrm_gmfrm_em = function(problem, maxit, score_tol) {
      expect_equal(maxit, 5L); expect_equal(score_tol, 1e-6)
      if (mode == "em_error") stop("seed unavailable")
      list(par = 1, converged = FALSE, reason = "iteration_limit")
    },
    mfrmr_make_adaptive_mml_evaluator = function(...) function(par) list(value = 10 + par),
    run_mfrm_optimization = function(start, method, idx, config, sizes, quad_points,
                                     maxit, reltol, optimizer) {
      calls <<- c(calls, start)
      if (mode == "all_error" || (mode == "neutral_error" && start == 0)) stop("optimizer unavailable")
      value <- if (mode == "worse_start") 12 + start else if (mode == "tie") 5 else 5 - start
      list(par = start, value = value, convergence = if (start == 1) 1L else 0L,
        optimizer_diagnostics = list(ConvergenceSeverity = if (start == 1) "review" else "pass"),
        optimizer_polish = list(Stages = data.frame(Stage = 1L)))
    }, .package = "mfrmr")
  run <- function(policy = "neutral_em") mfrm_gmfrm_adaptive_fit(problem, config,
    31L, 5L, 1e-10, "BFGS", policy)
  fit <- run()
  expect_identical(calls, c(0, 1))
  expect_identical(fit$par, 1)
  expect_identical(fit$convergence, 1L)
  expect_false(fit$mml_initialization$em$value$converged)
  expect_identical(fit$mml_initialization$selected, "em")
  expect_identical(fit$mml_initialization$table$Selected, c(FALSE, TRUE))
  expect_equal(fit$mml_initialization$table$InitialNLL, c(10, 11))
  expect_equal(fit$mml_initialization$table$FinalNLL, c(5, 4))
  mode <- "tie"
  expect_identical(run()$mml_initialization$selected, "neutral")
  mode <- "neutral_error"
  expect_warning(fit <- run(), "Some adaptive starting values failed")
  expect_match(fit$mml_initialization$table$Error[1], "optimizer unavailable")
  expect_identical(fit$par, 1)
  mode <- "em_error"
  expect_warning(fit <- run(), "Some adaptive starting values failed")
  expect_identical(fit$par, 0)
  expect_match(fit$mml_initialization$em$error, "seed unavailable")
  mode <- "all_error"
  error <- tryCatch(run(), error = identity)
  expect_s3_class(error, "mfrmr_gmfrm_start_error")
  expect_equal(nrow(error$initialization$table), 2L)
  expect_identical(error$initialization$controls$quad_points, 31L)
  mode <- "worse_start"
  expect_warning(fit <- run(), "starting value has a lower")
  expect_identical(fit$convergence, 2L)
  expect_identical(fit$optimizer_diagnostics$ConvergenceReason, "better_starting_objective")
  mode <- "em_error"; calls <- numeric()
  fit <- run("neutral")
  expect_identical(calls, 0)
  expect_null(fit$mml_initialization$em)
})
