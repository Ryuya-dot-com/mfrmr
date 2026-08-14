person_marginal_path_prototype_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-person-marginal-path-prototype-0.2.3.R"
  )
}

continuous_binary_path_paths <- function() {
  root <- testthat::test_path("..", "..", "inst", "validation")
  list(
    source = file.path(
      root, "gpcm-mml-continuous-binary-path-0.2.3.R"
    ),
    record = file.path(
      root, "gpcm-mml-continuous-binary-path-record-0.2.3.md"
    )
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

test_that("continuous binary GPCM path has the proved half-line signs", {
  paths <- continuous_binary_path_paths()
  skip_if_not(
    file.exists(paths$source) && file.exists(paths$record),
    "repository-internal validation artifacts are excluded"
  )
  env <- new.env(parent = globalenv())
  sys.source(paths$source, envir = env)
  result <- env$mfrmr_run_gpcm_mml_continuous_binary_path()

  expect_identical(
    result$status,
    "continuous_binary_microcase_proved_and_audited"
  )
  expect_true(result$theorem$MicrocaseContinuousHalfLineProved)
  expect_false(result$theorem$ProductionHalfLineCertified)
  expect_false(result$theorem$TheoremDependsOnNumericalIntegration)
  expect_true(result$theorem$NumericAuditUsesAdaptiveIntegration)

  profile <- result$profile
  expect_lt(max(abs(profile$PairIdentityDifference)), 1e-10)
  expect_lt(max(profile$MaximumIntegrationError), 1e-9)
  positive_distance <- profile$Distance > 0
  expect_lt(
    max(abs(profile$DerivativeDifference[positive_distance])),
    1e-8
  )

  discordant <- profile[profile$Pattern == "discordant_10", ]
  concordant <- profile[profile$Pattern == "concordant_11", ]
  expect_true(all(diff(discordant$MarginalProbability) > 0))
  expect_true(all(discordant$AnalyticDerivative[-1L] > 0))
  expect_true(all(discordant$BoundaryMinusMarginal > 0))
  expect_true(all(diff(concordant$MarginalProbability) < 0))
  expect_true(all(concordant$AnalyticDerivative[-1L] < 0))
  expect_true(all(concordant$BoundaryMinusMarginal < 0))
  expect_equal(
    discordant$MarginalProbability + concordant$MarginalProbability,
    rep(0.5, nrow(discordant)),
    tolerance = 1e-11
  )

  sample_profile <- result$sample_profile
  all_discordant <- sample_profile[
    sample_profile$CaseId == "all_discordant", , drop = FALSE
  ]
  balanced <- sample_profile[
    sample_profile$CaseId == "balanced_patterns", , drop = FALSE
  ]
  concordant_majority <- sample_profile[
    sample_profile$CaseId == "concordant_majority", , drop = FALSE
  ]
  all_concordant <- sample_profile[
    sample_profile$CaseId == "all_concordant", , drop = FALSE
  ]
  expect_true(all(all_discordant$AnalyticDerivative[-1L] > 0))
  expect_true(all(balanced$AnalyticDerivative[-1L] > 0))
  expect_true(all(all_discordant$BoundaryMinusLogLikelihood > 0))
  expect_true(all(balanced$BoundaryMinusLogLikelihood > 0))
  expect_true(any(concordant_majority$AnalyticDerivative > 0))
  expect_true(any(concordant_majority$AnalyticDerivative < 0))
  expect_true(all(all_concordant$AnalyticDerivative[-1L] < 0))
  expect_true(all(all_discordant$HalfLineIncreasingByCountTheorem))
  expect_true(all(balanced$HalfLineIncreasingByCountTheorem))
  expect_false(any(concordant_majority$HalfLineIncreasingByCountTheorem))
  expect_false(any(all_concordant$HalfLineIncreasingByCountTheorem))
  expect_false(result$full_gpcm_fit_covered)
  expect_false(result$readiness_overridden)
  expect_false(result$release_authorized)

  record <- paste(readLines(paths$record), collapse = "\n")
  source_text <- paste(readLines(paths$source), collapse = "\n")
  cryptographic_term <- "\\bSHA(?:-[0-9]+)?\\b|digest::|\\bmd5\\b"
  expect_false(grepl(
    cryptographic_term, source_text, ignore.case = TRUE, perl = TRUE
  ))
  expect_false(grepl(
    cryptographic_term, record, ignore.case = TRUE, perl = TRUE
  ))
  expect_match(
    record,
    "MicrocaseContinuousHalfLineProved = TRUE",
    fixed = TRUE
  )
  expect_match(record, "ProductionHalfLineCertified = FALSE", fixed = TRUE)
})

test_that("continuous binary pair identity is pointwise and sign separated", {
  paths <- continuous_binary_path_paths()
  skip_if_not(file.exists(paths$source),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(paths$source, envir = env)
  x <- c(0.05, 0.25, 1, 2, 4)
  for (distance in c(0.25, 1, 4)) {
    for (pattern in c("discordant_10", "concordant_11")) {
      paired <- env$mfrmr_gmcb_pair_probability(x, distance, pattern)
      direct <- env$mfrmr_gmcb_direct_probability(x, distance, pattern) +
        env$mfrmr_gmcb_direct_probability(-x, distance, pattern)
      expect_equal(paired, direct, tolerance = 1e-14)
    }
    expect_true(all(env$mfrmr_gmcb_pair_derivative(
      x, distance, "discordant_10"
    ) > 0))
    expect_true(all(env$mfrmr_gmcb_pair_derivative(
      x, distance, "concordant_11"
    ) < 0))
  }
  expect_error(
    env$mfrmr_gmcb_point(-1),
    "finite nonnegative"
  )
  expect_error(
    env$mfrmr_run_gpcm_mml_continuous_binary_path(c(0, 1, 1)),
    "strictly increasing"
  )
  minimal_profile <- do.call(rbind, lapply(
    c("discordant_10", "concordant_11"),
    function(pattern) env$mfrmr_gmcb_point(0, pattern)
  ))
  expect_error(
    env$mfrmr_gmcb_sample_profile(
      minimal_profile, "empty", 0, 0
    ),
    "positive total"
  )
})
