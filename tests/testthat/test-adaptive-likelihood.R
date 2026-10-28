test_that("public adaptive fits use one objective for likelihood, gradient, covariance and EAP", {
  for (model in c("RSM", "PCM", "GPCM")) {
    fixture <- adaptive_api_fixture(model)
    fit <- fixture$fit
    config <- fit$config
    sizes <- mfrmr:::build_param_sizes(config)
    idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet,
                                 config$interaction_specs)
    evaluate <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(idx, config, sizes, 31L)
    expected <- evaluate(fit$opt$par)
    expect_identical(fit$summary$MMLIntegration, "adaptive")
    displayed <- paste(capture.output(print(summary(fit))), collapse = "\n")
    displayed <- gsub("[[:space:]]+", " ", displayed)
    expect_match(displayed, "Integration: adaptive Gauss-Hermite, q=31", fixed = TRUE)
    expect_match(fit$summary$IntegrationEvaluationId, "aghq_normal_v1:q=31", fixed = TRUE)
    expect_lt(abs(fit$summary$LogLik + expected$value), 1e-8)
    expect_lt(abs(fit$summary$TerminalGradientSupNorm - max(abs(expected$gradient))), 1e-8)
    covariance <- mfrmr:::compute_mml_parameter_covariance(fit)
    hessian <- stats::optimHess(fit$opt$par, function(x) evaluate(x)$value,
                               function(x) evaluate(x)$gradient)
    expect_lt(max(abs(covariance$hessian - hessian)), 1e-7)
    review <- mfrmr:::mfrmr_adaptive_quadrature_review(
      idx, config, mfrmr:::expand_params(fit$opt$par, sizes, config),
      mfrmr:::gauss_hermite_normal(31L), fit$prep$levels$Person, 31L
    )
    person <- fit$facets$person
    expect_equal(nrow(person), nrow(review))
    index <- match(person$Person, review$Person)
    expect_false(anyNA(index))
    expect_lt(max(abs(person$Estimate - review$AdaptiveEAP[index])), 1e-9)
    expected_categories <- mfrmr:::compute_mml_expected_category_diagnostics(fit)
    expect_lt(abs(sum(expected_categories$posterior_bundle$person_bundle$log_marginal) -
                    fit$summary$LogLik), 1e-8)
    if (model == "GPCM") {
      boundary <- config$boundary_audit$gpcm_slope_boundary
      expect_identical(boundary$state, "not_evaluated_adaptive_quadrature")
      expect_false(boundary$fixed_quadrature_certificate)
      audit <- config$estimability_audit
      expect_identical(audit$mml_observed_pattern_score$status, "not_evaluated_adaptive_quadrature")
      expect_identical(audit$mml_all_pattern_information$status, "not_evaluated_adaptive_quadrature")
      expect_identical(audit$nonlinear_local_estimability$state, "not_evaluated")
      expect_identical(audit$nonlinear_local_estimability$reason_codes,
                       "adaptive_quadrature_probability_map_not_validated")
      expect_identical(audit$nonlinear_local_estimability$probability_model_scope,
                       "implemented_adaptive_quadrature_objective")
    }
  }
})

