# Run from the development root with mfrmr loaded. Reuse the ten source RDS
# files from run_adaptive_optimization_probe() and its inputs.csv.
run_adaptive_fitting_audit <- function(input_dir, output_dir) {
  source("inst/validation/adaptive-optimization-probe-0.2.4.R", local = environment())
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  inputs <- read.csv(file.path(input_dir, "inputs.csv"), stringsAsFactors = FALSE)
  results <- coordinates <- conditions <- list()
  capture <- function(expr, case, order, action) withCallingHandlers(expr, warning = function(w) {
    conditions[[length(conditions) + 1L]] <<- data.frame(case = case, order = order,
      action = action, detail = conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  for (case in unique(inputs$case)) {
    message(case)
    previous <- readRDS(file.path(input_dir, paste0(case, ".rds")))
    data <- inputs[inputs$case == case, setdiff(names(inputs), "case"), drop = FALSE]
    args <- previous$fit$config$replay_inputs
    args <- args[intersect(names(args), names(formals(mfrmr::fit_mfrm)))]
    args$data <- data
    args$mml_integration <- "adaptive"
    if (case == "rsm_regression") {
      args$population_formula <- stats::as.formula("~ X", env = baseenv())
      args$person_data <- data.frame(Person = sprintf("P%02d", 1:8), X = rep(c(-1, 1), 4))
    }
    for (order in c(31L, 61L)) {
      args$quad_points <- order
      fit <- capture(do.call(mfrmr::fit_mfrm, args), case, order, "fit")
      audit <- fit$config$estimability_audit
      if (length(audit$nonlinear_blocks)) {
        stopifnot(audit$mml_observed_pattern_score$status == "not_evaluated_adaptive_quadrature",
          audit$mml_all_pattern_information$status == "not_evaluated_adaptive_quadrature",
          audit$nonlinear_local_estimability$state == "not_evaluated")
      }
      ctx <- aqopt_context(fit, aq_continuous_reference)
      original <- serialize(fit, NULL)
      reference <- ctx$reference(fit$opt$par)
      gradient <- aqopt_gradient(ctx$continuous, fit$opt$par, 5e-5)
      evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(ctx$idx, ctx$config, ctx$sizes, order)
      value <- evaluate(fit$opt$par)
      persons <- fit$facets$person
      position <- match(ctx$labels, persons$Person)
      stopifnot(nrow(persons) == nrow(reference), !anyNA(position))
      scored <- capture(mfrmr::predict_mfrm_units(fit, data, weight = "Weight",
        person_data = args$person_data, scoring_quad_points = order,
        readiness_policy = "review", n_draws = 5L, seed = 472L), case, order, "score")
      scored_position <- match(persons$Person, scored$estimates$Person)
      covariance <- mfrmr:::compute_mml_parameter_covariance(fit)
      numerical_hessian <- stats::optimHess(fit$opt$par, ctx$adaptive(order),
        control = list(ndeps = rep(1e-4, length(fit$opt$par))))
      information <- mfrmr:::compute_mml_expected_category_diagnostics(fit)
      restored <- unserialize(serialize(fit, NULL))
      results[[length(results) + 1L]] <- data.frame(case = case, order = order,
        model = fit$config$model, convergence = fit$opt$convergence,
        nll = -fit$summary$LogLik, analytic_gradient = max(abs(value$gradient)),
        reported_gradient_error = abs(fit$summary$TerminalGradientSupNorm - max(abs(value$gradient))),
        objective_error = fit$summary$LogLik + value$value,
        continuous_nll_error = fit$summary$LogLik - sum(reference[, "log_marginal"]),
        continuous_gradient_error = max(abs(value$gradient - gradient)),
        continuous_eap_error = max(abs(persons$Estimate[position] - reference[, "eap"])),
        continuous_sd_error = max(abs(persons$SD[position] - reference[, "sd"])),
        scoring_eap_error = max(abs(persons$Estimate - scored$estimates$Estimate[scored_position])),
        scoring_sd_error = max(abs(persons$SD - scored$estimates$SD[scored_position])),
        covariance_hessian_error = max(abs(covariance$hessian - numerical_hessian)),
        diagnostic_nll_error = sum(information$posterior_bundle$person_bundle$log_marginal) - fit$summary$LogLik,
        integration = fit$summary$MMLIntegration,
        scoring_algorithm = scored$settings$scoring_algorithm,
        restored_integration = restored$config$estimation_control$mml_integration,
        source_unchanged = identical(original, serialize(fit, NULL)),
        old_adaptive61_parameter_change = max(abs(fit$opt$par - previous$candidates$adaptive61_fixed31$par)))
      coordinates[[length(coordinates) + 1L]] <- data.frame(case = case, order = order,
        coordinate = seq_along(fit$opt$par), value = fit$opt$par)
      saveRDS(fit, file.path(output_dir, paste0(case, "-q", order, ".rds")))
      for (name in c("results", "coordinates", "conditions")) {
        table <- get(name)
        if (length(table)) write.csv(do.call(rbind, table), file.path(output_dir, paste0(name, ".csv")), row.names = FALSE)
      }
    }
  }
  results <- do.call(rbind, results)
  stopifnot(nrow(results) == 20L, all(results$convergence == 0L),
    all(results$analytic_gradient < 1e-4), all(results$reported_gradient_error < 1e-8),
    all(abs(results$objective_error) < 1e-8), all(abs(results$continuous_nll_error) < 1e-7),
    all(results$continuous_gradient_error < 1e-5), all(results$continuous_eap_error < 1e-7),
    all(results$continuous_sd_error < 1e-7), all(results$scoring_eap_error < 1e-10),
    all(results$scoring_sd_error < 1e-10), all(results$covariance_hessian_error < 1e-2),
    all(abs(results$diagnostic_nll_error) < 1e-8), all(results$integration == "adaptive"),
    all(results$restored_integration == "adaptive"), all(results$source_unchanged),
    all(results$scoring_algorithm == "adaptive_quadrature_eap_v1"))
  invisible(results)
}


# Use an installed build: the reader process must load the same package library.
run_adaptive_fitting_fresh_process <- function(output_dir) {
  library(mfrmr)
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  package_library <- dirname(normalizePath(find.package('mfrmr'),winslash='/'))
  rows <- load_mfrmr_data('example_operational')
  results <- list()
  for (model in c('RSM','PCM')) {
   fit <- fit_mfrm(rows,'Person',c('Rater','Criterion'),'Score',model=model,
    step_facet=if(model=='PCM') 'Criterion' else NULL,mml_integration='adaptive',
    quad_points=31L,reltol=1e-10,maxit=200L)
   review <- mml_quadrature_sensitivity(fit,rows,quad_points=c(31L,41L))
   fit <- review$fits$q41
   artifact <- freeze_mfrm_calibration(validate_mfrm_calibration(
    extract_mfrm_calibration(fit,quadrature_review=review)))
   batch <- rows[rows$Person %in% unique(rows$Person)[1:2],]
   batch$Score[batch$Person==unique(batch$Person)[1L]] <- min(rows$Score)
   batch$Score[batch$Person==unique(batch$Person)[2L]] <- max(rows$Score)
   artifact_path <- file.path(output_dir,paste0(model,'-calibration.rds'))
   fit_path <- file.path(output_dir,paste0(model,'-fit.rds'))
   batch_path <- file.path(output_dir,paste0(model,'-rows.rds'))
   result_path <- file.path(output_dir,paste0(model,'-result.rds'))
   script_path <- file.path(output_dir,paste0(model,'-reader.R'))
   save_mfrm_calibration(artifact,artifact_path)
   saveRDS(fit,fit_path); saveRDS(batch,batch_path)
   writeLines(c('args <- commandArgs(TRUE)', '.libPaths(c(args[1],.libPaths()))',
    'library(mfrmr)', 'artifact <- load_mfrm_calibration(args[2])',
    'fit <- readRDS(args[3])', 'rows <- readRDS(args[4])',
    'score <- score_mfrm_calibration(artifact,rows)',
    'prediction <- predict_mfrm_units(fit,rows,n_draws=10L,seed=714L)',
    'saveRDS(list(score=score,prediction=prediction),args[5])'),script_path)
   rscript <- file.path(R.home('bin'),if(.Platform$OS.type=='windows') 'Rscript.exe' else 'Rscript')
   status <- system2(rscript,c('--vanilla',shQuote(script_path),shQuote(package_library),
    shQuote(artifact_path),shQuote(fit_path),shQuote(batch_path),shQuote(result_path)))
   stopifnot(status==0L)
   actual <- readRDS(result_path)
   expected <- score_mfrm_calibration(artifact,batch)
   index <- match(actual$score$estimates$Person,actual$prediction$estimates$Person)
   error <- max(abs(as.matrix(actual$score$estimates[c('Estimate','SD','Lower','Upper')])-
    as.matrix(actual$prediction$estimates[index,c('Estimate','SD','Lower','Upper')])) )
   results[[model]] <- data.frame(model=model,reader_status=status,score_error=error,
    artifact_score_identical=identical(actual$score$estimates,expected$estimates),
    artifact_algorithm=actual$score$settings$scoring_algorithm,
    prediction_algorithm=actual$prediction$settings$scoring_algorithm,
    posterior_draws=nrow(actual$prediction$draws))
   stopifnot(error<1e-10,identical(actual$score$estimates,expected$estimates),
    actual$score$settings$scoring_algorithm=='adaptive_quadrature_eap_v1',
    actual$prediction$settings$scoring_algorithm=='adaptive_quadrature_eap_v1',
    nrow(actual$prediction$draws)==20L)
  }
  write.csv(do.call(rbind,results),file.path(output_dir,'fresh.csv'),row.names=FALSE)
  invisible(do.call(rbind, results))
}
