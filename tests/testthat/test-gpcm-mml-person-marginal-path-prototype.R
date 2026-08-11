person_marginal_path_prototype_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-person-marginal-path-prototype-0.2.3.R"
  )
}

fit_person_marginal_path_fixture <- function(q = 31L) {
  data <- expand.grid(
    Person = sprintf("P%02d", seq_len(12L)),
    Rater = c("R1", "R2"),
    Criterion = c("C1", "C2"),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  data$Score <- ifelse(data$Criterion == "C1", 1L, 0L)
  anchors <- data.frame(
    Facet = "Rater", Level = c("R1", "R2"), Anchor = c(-10, -10),
    stringsAsFactors = FALSE
  )
  suppressMessages(suppressWarnings(fit_mfrm(
    data,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    keep_original = TRUE,
    method = "MML",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    anchors = anchors,
    rating_min = 0,
    rating_max = 1,
    quad_points = q,
    maxit = 50L,
    optimizer = "auto",
    mml_engine = "direct"
  )))
}

test_that("Person-marginal path oracle reconstructs value and derivatives", {
  prototype <- person_marginal_path_prototype_path()
  skip_if_not(file.exists(prototype),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(prototype, envir = env)
  fit <- fit_person_marginal_path_fixture(31L)
  problem <- env$mfrmr_gpcm_mml_person_path_problem(
    fit, 31L, c(C1 = 1, C2 = -1)
  )
  profile <- env$mfrmr_gpcm_mml_person_path_profile(
    problem, c(0, 0.5, 1, 2, 4), difference_step = 1e-3
  )

  expect_lt(max(abs(profile$LikelihoodDifference)), 1e-10)
  expect_lt(max(abs(profile$FirstDerivativeDifference)), 1e-8)
  expect_lt(max(abs(profile$SecondDerivativeDifference)), 1e-10)
  expect_true(all(profile$FirstDerivative > 0))
  expect_true(all(profile$NegativePersonNodeDerivatives > 0L))
  expect_true(all(profile$NegativePersonMarginalDerivatives == 0L))
  expect_false(any(profile$HalfLineCertified))
  expect_true(all(profile$ReadinessEffect == "none_prototype_only"))

  reverse <- env$mfrmr_gpcm_mml_person_path_problem(
    fit, 31L, c(C1 = -1, C2 = 1)
  )
  reverse_profile <- env$mfrmr_gpcm_mml_person_path_profile(
    reverse, c(0, 0.5), difference_step = 1e-3
  )
  expect_lt(max(abs(reverse_profile$LikelihoodDifference)), 1e-10)
  expect_lt(max(abs(reverse_profile$FirstDerivativeDifference)), 1e-8)
  expect_lt(max(abs(reverse_profile$SecondDerivativeDifference)), 1e-8)
})

test_that("Person-marginal path prototype reconstructs boundary and tail", {
  prototype <- person_marginal_path_prototype_path()
  skip_if_not(file.exists(prototype),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(prototype, envir = env)
  fit <- fit_person_marginal_path_fixture(31L)
  problem <- env$mfrmr_gpcm_mml_person_path_problem(
    fit, 31L, c(C1 = 1, C2 = -1)
  )
  boundary <- env$mfrmr_gpcm_mml_person_path_boundary(problem)
  distant <- env$mfrmr_gpcm_mml_person_path_point(problem, 10)

  expect_identical(
    boundary$State, "boundary_and_leading_tail_computed"
  )
  expect_gt(boundary$MinimumCompatibleNodesPerPerson, 0L)
  expect_gt(boundary$BoundaryImprovement, 0)
  expect_gt(boundary$TailCoefficient, 0)
  expect_equal(
    distant$FirstDerivative / exp(-10),
    boundary$TailCoefficient,
    tolerance = 1e-8
  )
  expect_equal(
    distant$LogLikelihood,
    boundary$BoundaryLogLikelihood,
    tolerance = 1e-10
  )
  expect_false(boundary$HalfLineCertified)
  expect_false(boundary$TailCertified)
  expect_identical(boundary$ReadinessEffect, "none_prototype_only")
})

test_that("Person-marginal path prototype rejects malformed directions", {
  prototype <- person_marginal_path_prototype_path()
  skip_if_not(file.exists(prototype),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(prototype, envir = env)
  fit <- fit_person_marginal_path_fixture(5L)
  expect_error(
    env$mfrmr_gpcm_mml_person_path_problem(
      fit, 5L, c(C1 = 1, C2 = 0)
    ),
    "sum-zero"
  )
  expect_error(
    env$mfrmr_gpcm_mml_person_path_problem(
      fit, 5L, c(A = 1, B = -1)
    ),
    "name every fitted slope level"
  )
})
