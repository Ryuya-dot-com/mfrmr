make_unified_readiness_fixture <- function(
    method = "JML",
    model = "RSM",
    input_condition = character(0),
    estimability_state = "identified",
    estimability_complete = TRUE,
    category_state = "adequate",
    person_boundary_state = "finite",
    person_boundary_complete = TRUE,
    structural_state = "none_certified",
    structural_complete = TRUE,
    joint_state = "none_certified",
    joint_complete = TRUE,
    slope_state = "not_applicable_model",
    slope_structural_complete = FALSE,
    numerical_severity = "pass",
    numerical_status = "converged",
    numerical_reason = "tolerance_met") {
  notes <- if (length(input_condition)) {
    data.frame(
      Stage = "design_check",
      Condition = input_condition,
      Severity = "warning",
      Count = 2L,
      Affected = "Person, Rater",
      Message = "review",
      RecommendedAction = "review",
      stringsAsFactors = FALSE
    )
  } else {
    mfrmr:::bind_mfrm_preparation_notes(list())
  }
  prep <- list(
    facet_names = "Rater",
    levels = list(Person = c("P1", "P2"), Rater = c("R1", "R2")),
    preparation_notes = notes
  )
  data_review <- list(status = data.frame(
    Domain = c("Data", "Design", "Stability", "Reporting"),
    Status = c(
      if (length(input_condition)) "review" else "pass",
      "pass_linked", "pass", "ready_for_diagnostics"
    ),
    stringsAsFactors = FALSE
  ))
  config <- list(
    method = method,
    model = model,
    slope_facet = if (identical(model, "GPCM")) "Rater" else NULL,
    gpcm_spec = if (identical(model, "GPCM")) {
      list(
        levels = c("R1", "R2"),
        n_params = 1L,
        identification = "sum_to_zero_log_slopes"
      )
    } else {
      NULL
    },
    estimability_audit = list(
      complete = estimability_complete,
      readiness = data.frame(
        EstimabilityState = estimability_state,
        ReasonCodes = if (estimability_complete) "" else
          "design_rank_not_evaluated",
        Complete = estimability_complete,
        stringsAsFactors = FALSE
      )
    ),
    category_support_audit = list(
      complete = TRUE,
      readiness = data.frame(
        CategoryState = category_state,
        ReasonCodes = "",
        Complete = TRUE,
        stringsAsFactors = FALSE
      )
    ),
    boundary_audit = list(
      complete = person_boundary_complete,
      readiness = data.frame(
        BoundaryState = person_boundary_state,
        ReasonCodes = "",
        Complete = person_boundary_complete,
        stringsAsFactors = FALSE
      ),
      structural_additive = list(
        state = structural_state, complete = structural_complete
      ),
      joint_additive = list(state = joint_state, complete = joint_complete),
      gpcm_slope_boundary = list(
        state = slope_state,
        complete = TRUE,
        structural_identification_complete = slope_structural_complete
      )
    )
  )
  opt <- list(optimizer_diagnostics = list(
    ConvergenceSeverity = numerical_severity,
    ConvergenceStatus = numerical_status,
    ConvergenceReason = numerical_reason
  ))
  list(prep = prep, data_review = data_review, config = config, opt = opt)
}

build_unified_readiness_fixture <- function(...) {
  fixture <- make_unified_readiness_fixture(...)
  do.call(mfrmr:::build_mfrm_readiness_record, fixture)
}

test_that("fit readiness precedence is deterministic and fail-closed", {
  derive <- mfrmr:::mfrmr_readiness_derive_fit
  expect_identical(
    derive("pass", "identified", "adequate", "finite", "ready"),
    "ready"
  )
  expect_identical(
    derive("pass", "identified", "adequate", "has_exclusions", "ready"),
    "ready_with_exclusions"
  )
  expect_identical(
    derive(
      "pass", "weak_information", "adequate", "has_exclusions", "ready"
    ),
    "review"
  )
  expect_identical(
    derive(
      "legacy_unknown", "identified", "unsupported_coordinate", "finite",
      "ready"
    ),
    "blocked"
  )
  expect_identical(
    derive(
      "legacy_unknown", "identified", "adequate", "finite", "ready"
    ),
    "legacy_unknown"
  )
})

test_that("the unified builder preserves component causes", {
  ready <- build_unified_readiness_fixture()
  expect_s3_class(ready, "mfrmr_readiness_record")
  expect_identical(ready$fit$FitReadiness, "ready")
  expect_true(ready$fit$InferenceReady)
  expect_identical(
    ready$components$Component,
    c("input", "estimability", "category", "boundary", "numerical")
  )

  duplicate <- build_unified_readiness_fixture(
    input_condition = "duplicate_person_facet_cells"
  )
  expect_identical(duplicate$fit$InputState, "review")
  expect_identical(duplicate$fit$FitReadiness, "review")
  expect_identical(
    duplicate$fit$ReasonCodes,
    "duplicate_cell_dependence_unmodelled"
  )
  expect_false(duplicate$fit$InferenceReady)

  candidate <- build_unified_readiness_fixture(
    structural_state = "certified_recession"
  )
  expect_identical(candidate$fit$BoundaryState, "not_evaluated")
  expect_identical(candidate$fit$FitReadiness, "review")
  expect_match(
    candidate$fit$ReasonCodes,
    "boundary_candidate_not_propagated",
    fixed = TRUE
  )

  incomplete <- build_unified_readiness_fixture(
    estimability_complete = FALSE
  )
  expect_identical(incomplete$fit$EstimabilityState, "not_evaluated")
  expect_identical(incomplete$fit$FitReadiness, "review")
  expect_match(
    incomplete$fit$ReasonCodes, "design_rank_not_evaluated", fixed = TRUE
  )
})

test_that("estimator and nonlinear boundary scope are not conflated", {
  mml <- build_unified_readiness_fixture(
    method = "MML",
    structural_state = "not_applicable_mml",
    joint_state = "not_applicable_mml"
  )
  expect_identical(mml$fit$BoundaryState, "finite")
  expect_identical(mml$fit$FitReadiness, "ready")

  gpcm <- build_unified_readiness_fixture(
    model = "GPCM",
    slope_state = "none_certified",
    slope_structural_complete = FALSE
  )
  expect_identical(gpcm$fit$BoundaryState, "not_evaluated")
  expect_identical(gpcm$fit$FitReadiness, "review")
  expect_match(
    gpcm$fit$ReasonCodes, "boundary_audit_incomplete", fixed = TRUE
  )

  failed <- build_unified_readiness_fixture(
    numerical_severity = "fail",
    numerical_status = "iteration_limit",
    numerical_reason = "iteration_limit_large_gradient"
  )
  expect_identical(failed$fit$NumericalState, "failed")
  expect_identical(failed$fit$FitReadiness, "blocked")
  expect_match(failed$fit$ReasonCodes, "optimizer_failed", fixed = TRUE)
  expect_match(failed$fit$ReasonCodes, "iteration_limit", fixed = TRUE)
})

test_that("new native fits store and consume one fit-readiness record", {
  data <- simulate_mfrm_data(
    n_person = 18,
    n_rater = 3,
    n_criterion = 2,
    raters_per_person = 3,
    assignment = "crossed",
    seed = 912
  )
  fit <- suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    rating_min = 1,
    rating_max = 4,
    method = "JML",
    model = "RSM",
    maxit = 80
  ))
  record <- mfrmr:::mfrmr_get_readiness_record(fit)

  expect_identical(record, fit$readiness)
  expect_identical(
    as.character(fit$summary$FitReadiness), record$fit$FitReadiness
  )
  expect_identical(
    as.logical(fit$summary$InferenceReady), record$fit$InferenceReady
  )
  expect_identical(
    as.character(fit$summary$ReadinessReasonCodes), record$fit$ReasonCodes
  )
  expect_identical(
    as.character(fit$summary$ReadinessContractVersion),
    mfrmr:::mfrmr_readiness_contract_version()
  )
  convergence <- mfrmr:::mfrm_convergence_state(fit)
  expect_identical(convergence$fit_readiness, record$fit$FitReadiness)
  expect_identical(convergence$inference_ready, record$fit$InferenceReady)
  fit_summary <- summary(fit)
  expect_identical(
    as.character(fit_summary$readiness$Status[
      fit_summary$readiness$Domain == "Fit"
    ]),
    record$fit$FitReadiness
  )
  expect_identical(
    as.character(fit_summary$readiness$Status[
      fit_summary$readiness$Domain == "Numerical"
    ]),
    "pass"
  )
})

test_that("legacy objects are not upgraded from the old scalar", {
  for (legacy_scalar in list(TRUE, FALSE, NA)) {
    legacy <- list(summary = data.frame(InferenceReady = legacy_scalar))
    record <- mfrmr:::mfrmr_get_readiness_record(legacy)
    expect_identical(record$fit$FitReadiness, "legacy_unknown")
    expect_false(record$fit$InferenceReady)
    expect_identical(record$fit$ReasonCodes, "legacy_contract_missing")
  }
})

test_that("legacy objects fail closed at convergence, summary, and plot entry points", {
  legacy <- make_toy_fit()
  legacy$readiness <- NULL
  readiness_fields <- c(
    "ReadinessContractVersion", "FitReadiness", "InputState",
    "EstimabilityState", "CategoryState", "BoundaryState", "NumericalState",
    "ReadinessReasonCodes", "ReadinessAuditProvenance"
  )
  legacy$summary <- legacy$summary[
    setdiff(names(legacy$summary), readiness_fields)
  ]
  legacy$summary$Converged <- TRUE
  legacy$summary$InferenceReady <- TRUE
  legacy$summary$ConvergenceSeverity <- "pass"
  legacy$summary$ConvergenceStatus <- "converged"

  convergence <- mfrmr:::mfrm_convergence_state(legacy)
  expect_true(convergence$code_converged)
  expect_false(convergence$inference_ready)
  expect_identical(convergence$fit_readiness, "legacy_unknown")

  fit_summary <- summary(legacy)
  fit_row <- fit_summary$readiness[
    fit_summary$readiness$Domain == "Fit", , drop = FALSE
  ]
  expect_identical(fit_row$Status, "legacy_unknown")
  expect_identical(
    fit_summary$readiness$Status[
      fit_summary$readiness$Domain == "Reporting"
    ],
    "legacy_reaudit_or_refit_required"
  )

  expect_warning(
    plotted <- plot(legacy, type = "wright", draw = FALSE),
    "Fit=legacy_unknown",
    fixed = TRUE
  )
  expect_identical(plotted$data$interpretation_status, "review_only")
})
