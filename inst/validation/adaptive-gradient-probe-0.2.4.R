# From the development root after loading mfrmr, run
# run_adaptive_gradient_probe(previous_optimization_rds_directory, output_dir).
# The previous probe generates the ten input RDS files; no fitted object is changed.
run_adaptive_gradient_probe <- function(input_dir, output_dir) {
  source("inst/validation/adaptive-optimization-probe-0.2.4.R", local = environment())
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  paths <- list.files(input_dir, pattern = "\\.rds$", full.names = TRUE)
  stopifnot(length(paths) == 10L)
  derivatives <- runs <- checks <- list()
  save_tables <- function() {
    for (name in c("derivatives", "runs", "checks")) {
      rows <- get(name)
      if (length(rows)) write.csv(do.call(rbind, rows),
        file.path(output_dir, paste0(name, ".csv")), row.names = FALSE)
    }
  }
  for (path in paths) {
    case <- sub("\\.rds$", "", basename(path))
    message(case)
    input <- readRDS(path)
    before <- serialize(input$fit, NULL)
    ctx <- aqopt_context(input$fit, aq_continuous_reference)
    baseline <- input$candidates$adaptive61_fixed31$par
    points <- list(initial = ctx$initial, fixed31 = input$fit$opt$par,
      adaptive61 = baseline, perturbed = baseline + 0.3 * sin(seq_along(baseline)))
    for (order in c(1L, 3L, 15L, 31L, 61L)) {
      evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(ctx$idx, ctx$config, ctx$sizes, order)
      objective <- ctx$adaptive(order)
      for (point in names(points)) {
        par <- points[[point]]
        result <- evaluate(par)
        g1 <- aqopt_gradient(objective, par, 1e-4)
        g2 <- aqopt_gradient(objective, par, 5e-5)
        numerical <- (4 * g2 - g1) / 3
        derivatives[[length(derivatives) + 1L]] <- data.frame(
          case = case, order = order, point = point, coordinate = seq_along(par),
          analytic = result$gradient, numerical = numerical,
          error = result$gradient - numerical, finite_difference_step_change = g2 - g1,
          value_error = result$value - objective(par))
      }
    }
    plans <- data.frame(order = c(15L, 31L, 61L, 31L),
                         start = c("fixed31", "fixed31", "fixed31", "initial"))
    retained <- list()
    for (j in seq_len(nrow(plans))) {
      order <- plans$order[j]
      start <- plans$start[j]
      initial <- points[[start]]
      evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(ctx$idx, ctx$config, ctx$sizes, order)
      for (method in if (order == 31L) c("analytic", "finite_difference") else "analytic") {
        calls <- 0L
        key <- cached <- NULL
        if (method == "analytic") {
          shared <- function(par) {
            if (!identical(par, key)) {
              cached <<- evaluate(par)
              key <<- par + 0 # Own the key: optim may reuse its callback buffer.
              calls <<- calls + 1L
            }
            cached
          }
          fn <- function(par) shared(par)$value
          gr <- function(par) shared(par)$gradient
        } else {
          objective <- ctx$adaptive(order)
          fn <- function(par) { calls <<- calls + 1L; objective(par) }
          gr <- NULL
        }
        elapsed <- system.time(fit <- stats::optim(initial, fn, gr, method = "BFGS",
          control = list(ndeps = rep(1e-4, length(initial)), maxit = 200L, reltol = 1e-12)))[["elapsed"]]
        initial_calls <- calls
        initial_gradient <- max(abs(evaluate(fit$par)$gradient))
        initial_value <- fit$value
        polish_elapsed <- 0
        if (initial_gradient > 1e-4) {
          polish_elapsed <- system.time(fit <- stats::optim(fit$par, fn, gr, method = "BFGS",
            control = list(ndeps = rep(1e-4, length(initial)), maxit = 200L, reltol = 1e-14)))[["elapsed"]]
        }
        result <- evaluate(fit$par)
        runs[[length(runs) + 1L]] <- data.frame(case = case, order = order, start = start,
          method = method, nll = result$value, convergence = fit$convergence,
          initial_gradient = initial_gradient, gradient = max(abs(result$gradient)),
          free_change_from_previous61 = max(abs(fit$par - baseline)),
          initial_calls = initial_calls, calls = calls, elapsed = elapsed,
          polish_elapsed = polish_elapsed, polish_improvement = initial_value - fit$value)
        retained[[paste(order, start, method, sep = "_")]] <- fit
      }
    }
    evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(ctx$idx, ctx$config, ctx$sizes, 61L)
    par <- retained[["61_fixed31_analytic"]]$par
    hessian <- stats::optimHess(par, function(x) evaluate(x)$value,
      function(x) evaluate(x)$gradient, control = list(ndeps = rep(1e-4, length(par))))
    numerical_hessian <- stats::optimHess(par, ctx$adaptive(61L),
      control = list(ndeps = rep(1e-4, length(par))))
    continuous_gradient <- aqopt_gradient(ctx$continuous, par, 5e-5)
    reference <- ctx$reference(par)
    ref_review <- ctx$review(par, 61L)
    checks[[length(checks) + 1L]] <- data.frame(case = case,
      continuous_value_error = evaluate(par)$value + sum(reference[, "log_marginal"]),
      continuous_gradient_error = max(abs(evaluate(par)$gradient - continuous_gradient)),
      eap_error = max(abs(ref_review$AdaptiveEAP - reference[, "eap"])),
      sd_error = max(abs(ref_review$AdaptivePosteriorSD - reference[, "sd"])),
      hessian_error = max(abs(hessian - numerical_hessian)),
      minimum_hessian_eigenvalue = min(eigen(hessian, symmetric = TRUE, only.values = TRUE)$values),
      source_unchanged = identical(serialize(input$fit, NULL), before))
    saveRDS(retained, file.path(output_dir, paste0(case, ".rds")))
    save_tables()
  }
  derivatives <- do.call(rbind, derivatives)
  runs <- do.call(rbind, runs)
  checks <- do.call(rbind, checks)
  stopifnot(all(abs(derivatives$value_error) < 1e-8), all(abs(derivatives$error) < 1e-6),
    nrow(runs) == 60L, all(runs$convergence == 0L), all(runs$gradient < 1e-4),
    all(abs(checks$continuous_value_error) < 1e-7), all(checks$continuous_gradient_error < 1e-5),
    all(checks$eap_error < 1e-7), all(checks$sd_error < 1e-7),
    all(checks$hessian_error < 1e-3), all(checks$minimum_hessian_eigenvalue > 0),
    all(checks$source_unchanged))
  invisible(list(derivatives = derivatives, runs = runs, checks = checks))
}
