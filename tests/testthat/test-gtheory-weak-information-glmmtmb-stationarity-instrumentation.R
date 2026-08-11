gtheory_glmmtmb_stationarity_paths <- function(full_chain = FALSE) {
  short <- testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-",
        "instrumentation-0.2.3.R"
      )
    )
  )
  if (!full_chain) return(short)
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-balanced-estimation-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-covariance-information-audit-0.2.3.R",
      "gtheory-glmmtmb-parity-prototype-0.2.3.R",
      "gtheory-ademp-registry-prototype-0.2.3.R",
      "gtheory-ademp-generator-prototype-0.2.3.R",
      "gtheory-ademp-prefit-prototype-0.2.3.R",
      "gtheory-ademp-fit-prototype-0.2.3.R",
      "gtheory-weak-information-calibration-prototype-0.2.3.R",
      "gtheory-weak-information-pilot-prototype-0.2.3.R",
      "gtheory-weak-information-diagnostic-refit-prototype-0.2.3.R",
      "gtheory-weak-information-bootstrap-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-prototype-0.2.3.R",
      "gtheory-weak-information-feasibility-runner-0.2.3.R",
      "gtheory-weak-information-numerical-sensitivity-0.2.3.R",
      "gtheory-weak-information-typed-replay-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stabilization-prototype-0.2.3.R",
      "gtheory-weak-information-glmmtmb-stabilization-runner-0.2.3.R",
      "gtheory-weak-information-glmmtmb-alignment-runner-0.2.3.R",
      "gtheory-weak-information-glmmtmb-numerical-adjudication-0.2.3.R",
      paste0(
        "gtheory-weak-information-glmmtmb-stationarity-",
        "instrumentation-0.2.3.R"
      )
    )
  )
}

load_gtheory_glmmtmb_stationarity <- function(full_chain = FALSE) {
  paths <- gtheory_glmmtmb_stationarity_paths(full_chain)
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  for (package in c("digest", "lme4", "glmmTMB", "TMB", "numDeriv")) {
    skip_if_not_installed(package)
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("b1g4 keeps lme4 and Newton curvature scalings distinct", {
  env <- load_gtheory_glmmtmb_stationarity()
  parameter <- c(a = 2, b = -0.5)
  gradient <- c(a = 4, b = 3)
  hessian <- matrix(c(4, 1, 1, 9), nrow = 2L)
  measured <- env$mfrmr_gtwsy_scale_metrics(
    parameter, objective = 20, gradient, hessian
  )
  factor <- chol(hessian)

  expect_true(measured$RawAvailable)
  expect_true(measured$HessianPositiveDefinite)
  expect_true(measured$HessianCholeskyAvailable)
  expect_equal(measured$Lme4ScaledGradient,
               as.numeric(solve(factor, gradient)), tolerance = 1e-14)
  expect_equal(measured$NewtonWhitenedGradient,
               as.numeric(solve(t(factor), gradient)), tolerance = 1e-14)
  expect_equal(
    measured$NewtonDecrement^2,
    drop(t(gradient) %*% solve(hessian, gradient)), tolerance = 1e-13
  )
  expect_false(isTRUE(all.equal(
    measured$Lme4ScaledGradient, measured$NewtonWhitenedGradient
  )))
  expect_equal(
    measured$ObjectiveRelativeParameterScaledGradient,
    unname(gradient * pmax(1, abs(parameter)) / 20), tolerance = 1e-14
  )
})

test_that("non-PD curvature never manufactures a scaled zero", {
  env <- load_gtheory_glmmtmb_stationarity()
  measured <- env$mfrmr_gtwsy_scale_metrics(
    c(0, 0), 10, c(1e-6, -2e-6), diag(c(1, -1))
  )

  expect_true(measured$RawAvailable)
  expect_true(measured$HessianAvailable)
  expect_false(measured$HessianPositiveDefinite)
  expect_false(measured$HessianCholeskyAvailable)
  expect_false(measured$Lme4ScaledAvailable)
  expect_false(measured$NewtonWhitenedAvailable)
  expect_false(measured$NewtonStepAvailable)
  expect_true(is.na(measured$Lme4ScaledMaximumAbsolute))
  expect_true(is.na(measured$NewtonDecrement))
})

test_that("raw sidecars are content-addressed and mutation-sensitive", {
  env <- load_gtheory_glmmtmb_stationarity()
  sidecar <- list(
    Contract = "x", ParameterNames = c("a", "b"), Parameter = c(1, 2),
    Objective = 3, OuterGradient = c(0.1, 0.2),
    SdreportGradient = c(0.1, 0.2), RichardsonJacobian = diag(2),
    RichardsonSymmetricHessian = diag(2), RichardsonEigenvalues = c(1, 1),
    ObjectiveRelativeParameterScaledGradient = c(0.1, 0.2),
    Lme4ScaledGradient = c(0.1, 0.2),
    Lme4MinimumGradient = c(0.1, 0.2),
    NewtonWhitenedGradient = c(0.1, 0.2), NewtonStep = c(0.1, 0.2)
  )
  hash <- env$mfrmr_gta_hash(sidecar)
  expect_true(env$mfrmr_gtwsy_sidecar_valid(sidecar, hash))
  sidecar$Parameter[[1L]] <- 4
  expect_false(env$mfrmr_gtwsy_sidecar_valid(sidecar, hash))
})

test_that("the b1g4 source freezes threshold-free semantics", {
  env <- load_gtheory_glmmtmb_stationarity()
  empty <- env$mfrmr_gtwsy_empty_instrumentation()

  expect_false(empty$RawDerivativeSidecarAvailable)
  expect_identical(empty$StationarityState, "not_evaluable")
  expect_false(empty$StationarityThresholdApplied)
  body_text <- paste(deparse(body(env$mfrmr_gtwsy_contract)), collapse = " ")
  expect_match(body_text, "ObservedValuesMayDefineThreshold = FALSE",
               fixed = TRUE)
  expect_match(body_text, "StationarityCriterionReady = FALSE", fixed = TRUE)
  expect_match(body_text, "FullExecutionAuthorized = FALSE", fixed = TRUE)
})

test_that("the exact b1g4 retained run is reproducible", {
  skip_if_not(identical(
    tolower(Sys.getenv("MFRMR_RUN_GTHEORY_GLMMTMB_STATIONARITY", "false")),
    "true"
  ), "set MFRMR_RUN_GTHEORY_GLMMTMB_STATIONARITY=true")
  env <- load_gtheory_glmmtmb_stationarity(full_chain = TRUE)
  paths <- c(
    design = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_DESIGN_RDS",
      "/private/tmp/mfrmr-gtwst-design-v2.rds"
    ),
    upstream = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_STABILIZATION_SMOKE_RDS",
      "/private/tmp/mfrmr-gtwsv-smoke-v2.rds"
    ),
    alignment = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_ALIGNMENT_SMOKE_RDS",
      "/private/tmp/mfrmr-gtwsw-smoke-v1.rds"
    ),
    adjudication = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_NUMERICAL_ADJUDICATION_RDS",
      "/private/tmp/mfrmr-gtwsx-adjudication-v1.rds"
    ),
    execution = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_STATIONARITY_EXECUTION_RDS",
      "/private/tmp/mfrmr-gtwsy-stationarity-v1.rds"
    ),
    result = Sys.getenv(
      "MFRMR_GTHEORY_GLMMTMB_STATIONARITY_RESULT_RDS",
      "/private/tmp/mfrmr-gtwsy-adjudication-v1.rds"
    )
  )
  skip_if_not(all(file.exists(paths)), "exact b1g4 artifacts are unavailable")
  design <- readRDS(paths[["design"]])
  upstream <- readRDS(paths[["upstream"]])
  alignment <- readRDS(paths[["alignment"]])
  previous <- readRDS(paths[["adjudication"]])
  execution <- readRDS(paths[["execution"]])
  result <- readRDS(paths[["result"]])
  contract <- env$mfrmr_gtwsy_contract(
    design$Contract, design$Manifest, upstream, alignment, previous
  )
  reproduced <- env$mfrmr_gtwsy_adjudicate(contract, execution)

  expect_identical(execution$RunnerContractHash,
                   contract$RunnerContractHash)
  expect_true(env$mfrmr_gtwsy_execution_hash_valid(execution))
  expect_identical(reproduced$ResultHash, result$ResultHash)
  expect_equal(nrow(execution$AtomicRows), 120L)
  expect_equal(nrow(result$FitRows), 240L)
  expect_equal(nrow(result$RouteSpreadRows), 40L)
  expect_true(execution$RawDerivativeSidecarsReady)
  expect_true(execution$ScaleAwareObservablesReady)
  expect_false(execution$StationarityCriterionReady)
  expect_false(result$StationarityCriterionReady)
  expect_false(result$FullExecutionAuthorized)
  expect_false(result$InferenceReady)
})
