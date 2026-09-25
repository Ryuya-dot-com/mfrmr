test_that("GPCM IC solution checks do not grant interval or LRT readiness", {
  fit <- list(
    config = list(model = "GPCM", method = "MML", estimation_control = list(quad_points = 61)),
    opt = list(par = c(0, 0), value = 100,
               optimizer_diagnostics = list(ConvergenceSeverity = "pass", GradientReviewTolerance = 1e-4))
  )
  contract <- data.frame(StoredICConsistent = TRUE, ICSelectable = TRUE)
  readiness <- data.frame(InputState = "pass", CategoryState = "adequate", NumericalState = "ready")
  information <- list(
    status = "evaluated_diagnostic_only", free_dimension = 2L,
    evaluation_summary = data.frame(ReevaluatedObjective = 100, GradientMaxAbs = 1e-6),
    eigenvalue_summary = data.frame(Smallest = 1, AbsoluteScale = 10)
  )
  calls <- 0L
  testthat::local_mocked_bindings(
    mfrmr_get_readiness_record = function(...) list(fit = readiness),
    mfrm_inference_ready = function(...) FALSE,
    mfrm_fit_decision_summary = function(...) data.frame(Why = "Slope inference unavailable"),
    build_param_sizes = function(...) list(x = 2L),
    build_indices = function(...) list(),
    compute_mml_parameter_covariance = function(...) { calls <<- calls + 1L; list(solution_information=information) },
    .package = "mfrmr"
  )
  check <- function() mfrmr:::mfrm_ic_fit_check(fit, contract)
  before <- fit
  expect_true(check()$eligible)
  expect_identical(check()$basis, "mml_local_solution_information")
  expect_identical(fit, before)
  expect_false(mfrmr:::mfrm_inference_ready(fit))

  information$evaluation_summary$ReevaluatedObjective <- 101
  expect_false(check()$eligible)
  expect_match(check()$review, "does not match reevaluation")
  information$evaluation_summary$ReevaluatedObjective <- 100
  information$evaluation_summary$GradientMaxAbs <- .01
  expect_false(check()$eligible)
  information$evaluation_summary$GradientMaxAbs <- 1e-6
  for (minimum in c(0, -1, 1e-10, NA_real_)) {
    information$eigenvalue_summary$Smallest <- minimum
    expect_false(check()$eligible)
  }
  information$eigenvalue_summary$Smallest <- 1
  information$inverse_review <- data.frame(Verified=TRUE,RelativeChange=1e-5,
    InverseResidual=1e-8,CurvatureScaledGradient=1e-6,Detail="Ill-conditioned information: verified with caution.")
  information$eigenvalue_summary$Smallest <- 1e-9
  expect_true(check()$eligible)
  expect_match(check()$caution,"Ill-conditioned")
  for(field in c("RelativeChange","InverseResidual","CurvatureScaledGradient")) {
    saved <- information$inverse_review[[field]]
    information$inverse_review[[field]] <- 1
    expect_false(check()$eligible)
    information$inverse_review[[field]] <- saved
  }
  information$inverse_review$Verified <- FALSE
  expect_false(check()$eligible)
  information$inverse_review$Verified <- TRUE
  information$inverse_review$RelativeChange <- -1
  expect_false(check()$eligible)
  information$inverse_review$RelativeChange <- NULL
  expect_false(check()$eligible)
  information$inverse_review <- NULL
  information$eigenvalue_summary$Smallest <- 1
  information$status <- "not_evaluated_dimension_limit"
  information$detail <- "Dense information execution limit exceeded."
  expect_false(check()$eligible)
  expect_match(check()$review, "execution limit")
  information$status <- "evaluated_diagnostic_only"

  previous_calls <- calls
  contract$ICSelectable <- FALSE
  expect_false(check()$eligible)
  expect_identical(calls, previous_calls)
  contract$ICSelectable <- TRUE
  contract$StoredICConsistent <- FALSE
  expect_false(check()$eligible)
  expect_identical(calls, previous_calls)
  contract$StoredICConsistent <- TRUE
  readiness$CategoryState <- "weak_information"
  expect_false(check()$eligible)
  expect_identical(calls, previous_calls)
  readiness$CategoryState <- "adequate"
  readiness$NumericalState <- "failed"
  expect_false(check()$eligible)
  expect_identical(calls, previous_calls)
  readiness$NumericalState <- "ready"
  fit$config$model <- "PCM"
  fit$config$population_spec <- list(active = TRUE)
  expect_true(check()$eligible)
  expect_false(mfrmr:::mfrm_inference_ready(fit))
  previous_calls <- calls
  fit$config$method <- "JML"
  expect_false(check()$eligible)
  expect_identical(calls, previous_calls)
})

test_that('bootstrap singleton exception checks fresh support without relaxing numerical guards', {
  fit <- list(config=list(model='GPCM',method='MML'),
    opt=list(par=c(0,0),value=100,
      optimizer_diagnostics=list(ConvergenceSeverity='pass',GradientReviewTolerance=1e-4)))
  contract <- data.frame(StoredICConsistent=TRUE,ICSelectable=TRUE)
  readiness <- data.frame(InputState='pass',CategoryState='weak_information',NumericalState='ready')
  information <- list(status='evaluated_diagnostic_only',free_dimension=2L,
    evaluation_summary=data.frame(ReevaluatedObjective=100,GradientMaxAbs=1e-6),
    eigenvalue_summary=data.frame(Smallest=1,AbsoluteScale=10))
  audit <- list(readiness=data.frame(Complete=TRUE,CategoryState='weak_information',
      ReasonCodes='weak_category_information',UnsupportedStepCoordinates=0L,UnsupportedCategoryContrasts=0L),
    category_table=data.frame(WithinScopeCount=c(10L,1L,12L)))
  audits <- 0L
  local_mocked_bindings(
    mfrmr_get_readiness_record=function(...) list(fit=readiness),
    mfrm_inference_ready=function(...) FALSE,
    mfrm_fit_decision_summary=function(...) data.frame(Why='Category support requires review'),
    build_param_sizes=function(...) list(),
    audit_mfrm_category_support=function(...) {audits <<- audits+1L; audit},
    compute_mml_parameter_covariance=function(...) stop('Unexpected information calculation'),
    .package='mfrmr')
  check <- function(allow=TRUE) mfrm_ic_fit_check(fit,contract,information,allow_singleton=allow)
  before <- fit
  expect_false(check(FALSE)$eligible)
  expect_identical(audits,0L)
  expect_true(check()$eligible)
  expect_match(check()$caution,'Singleton')
  expect_identical(fit,before)
  expect_identical(readiness$CategoryState,'weak_information')
  for(counts in list(c(10,0,12),c(10,NA,12),c(10,2,12),numeric())) {
    audit$category_table <- data.frame(WithinScopeCount=counts)
    expect_false(check()$eligible)
  }
  audit$category_table <- data.frame(WithinScopeCount=c(10L,1L,12L))
  audit$readiness$UnsupportedCategoryContrasts <- 1L
  expect_false(check()$eligible)
  audit$readiness$UnsupportedCategoryContrasts <- 0L
  audit$readiness$UnsupportedStepCoordinates <- 1L
  expect_false(check()$eligible)
  audit$readiness$UnsupportedStepCoordinates <- 0L
  audit$readiness$Complete <- FALSE
  expect_false(check()$eligible)
  audit$readiness$Complete <- TRUE
  readiness$InputState <- 'review'
  expect_false(check()$eligible)
  readiness$InputState <- 'pass'
  readiness$NumericalState <- 'failed'
  expect_false(check()$eligible)
  readiness$NumericalState <- 'ready'
  information$evaluation_summary$GradientMaxAbs <- .01
  expect_false(check()$eligible)
  information$evaluation_summary$GradientMaxAbs <- 1e-6
  information$evaluation_summary$ReevaluatedObjective <- 101
  expect_false(check()$eligible)
  information$evaluation_summary$ReevaluatedObjective <- 100
  information$eigenvalue_summary$Smallest <- 1e-12
  expect_false(check()$eligible)
  information$eigenvalue_summary$Smallest <- 1
  contract$ICSelectable <- FALSE
  expect_false(check()$eligible)
})
