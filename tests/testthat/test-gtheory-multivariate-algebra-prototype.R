gtheory_multivariate_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R"
    )
  )
}

load_gtheory_multivariate <- function() {
  paths <- gtheory_multivariate_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

test_that("future Draft.85a0 constructs exact allocation Gram operators", {
  env <- load_gtheory_multivariate()
  common <- env$mfrmr_gtv_fixture_allocation("common", "Rater")
  partial <- env$mfrmr_gtv_fixture_allocation("partial", "Rater")
  independent <- env$mfrmr_gtv_fixture_allocation("independent", "Rater")

  expect_s3_class(common, "mfrmr_gtv_operator")
  expect_equal(common$Matrix, matrix(
    0.5, 2L, 2L, dimnames = list(c("A", "B"), c("A", "B"))
  ))
  expect_equal(diag(partial$Matrix), c(A = 0.5, B = 0.5))
  expect_equal(partial$Matrix["A", "B"], 0.25)
  expect_equal(independent$Matrix["A", "B"], 0)
  expect_equal(common$SharedConditionCount["A", "B"], 2L)
  expect_equal(partial$SharedConditionCount["A", "B"], 1L)
  expect_equal(independent$SharedConditionCount["A", "B"], 0L)

  unequal <- data.frame(
    Stratum = c("A", "A", "B", "B", "B"),
    ConditionId = c("R1", "R2", "R2", "R3", "R4"),
    Weight = c(0.5, 0.5, 1 / 3, 1 / 3, 1 / 3)
  )
  operator <- env$mfrmr_gtv_overlap_operator(
    unequal, c("A", "B"), "UnequalRater"
  )
  expect_equal(diag(operator$Matrix), c(A = 1 / 2, B = 1 / 3))
  expect_equal(operator$Matrix["A", "B"], 1 / 6)
  expect_false(isTRUE(all.equal(
    operator$Matrix["A", "B"], 1 / sqrt(2 * 3)
  )))
})

test_that("future Draft.85a0 forms typed universe and error matrices", {
  env <- load_gtheory_multivariate()
  spec <- env$mfrmr_gtv_fixture("common")
  strata <- c("A", "B")
  named_matrix <- function(values) {
    matrix(values, 2L, 2L, byrow = TRUE,
           dimnames = list(strata, strata))
  }

  expect_s3_class(spec, "mfrmr_gtv_spec")
  expect_equal(spec$SigmaP, named_matrix(c(1, 0.4, 0.4, 0.8)))
  expect_equal(
    spec$SigmaRelativeError,
    named_matrix(c(0.5, 0.15, 0.15, 0.5))
  )
  expect_equal(
    spec$SigmaAbsoluteError,
    named_matrix(c(0.6, 0.2, 0.2, 0.65))
  )
  expect_equal(
    spec$SigmaRelativeError,
    spec$ComponentContributions[["Person:Rater"]] +
      spec$ComponentContributions$Residual
  )
  expect_equal(
    spec$SigmaAbsoluteError - spec$SigmaRelativeError,
    spec$ComponentContributions$Rater
  )
  expect_true(all(spec$MatrixAudit$PositiveSemidefinite))
})

test_that("future Draft.85a0 reproduces hand composite G and Phi", {
  env <- load_gtheory_multivariate()
  spec <- env$mfrmr_gtv_fixture("common")
  result <- env$mfrmr_gtv_composite(spec, c(A = 0.6, B = 0.4))

  expect_s3_class(result, "mfrmr_gtv_composite")
  expect_equal(result$UniverseVariance, 0.68, tolerance = 1e-14)
  expect_equal(result$RelativeErrorVariance, 0.332, tolerance = 1e-14)
  expect_equal(result$AbsoluteErrorVariance, 0.416, tolerance = 1e-14)
  expect_equal(result$G, 0.68 / 1.012, tolerance = 1e-14)
  expect_equal(result$Phi, 0.68 / 1.096, tolerance = 1e-14)
  expect_equal(
    sum(result$ComponentContributions$QuadraticContribution[
      result$ComponentContributions$UniverseRole == "relative_error"
    ]),
    result$RelativeErrorVariance,
    tolerance = 1e-14
  )

  univariate_g <- c(A = 1 / 1.5, B = 0.8 / 1.3)
  expect_false(isTRUE(all.equal(
    result$G, sum(c(A = 0.6, B = 0.4) * univariate_g)
  )))
})

test_that("future Draft.85a0 distinguishes shared and independent facets", {
  env <- load_gtheory_multivariate()
  sharing <- c("common", "partial", "independent")
  results <- lapply(sharing, function(value) {
    env$mfrmr_gtv_composite(
      env$mfrmr_gtv_fixture(value), c(A = 0.6, B = 0.4)
    )
  })
  g <- vapply(results, function(x) x$G, numeric(1L))
  phi <- vapply(results, function(x) x$Phi, numeric(1L))

  expect_equal(g, c(
    0.68 / 1.012, 0.68 / 0.976, 0.68 / 0.94
  ), tolerance = 1e-14)
  expect_equal(phi, c(
    0.68 / 1.096, 0.68 / 1.048, 0.68 / 1.00
  ), tolerance = 1e-14)
  expect_true(all(diff(g) > 0))
  expect_true(all(diff(phi) > 0))
  expect_identical(length(unique(vapply(
    results, function(x) x$SpecificationHash, character(1L)
  ))), 3L)
})

test_that("future Draft.85a0 reduces exactly to one-stratum G theory", {
  env <- load_gtheory_multivariate()
  strata <- "S"
  scalar <- function(value) matrix(
    value, 1L, 1L, dimnames = list(strata, strata)
  )
  map <- data.frame(
    ComponentId = c("Person", "Item", "Residual"),
    UniverseRole = c("object", "absolute_only", "relative_error")
  )
  covariance <- list(
    Person = scalar(1.2), Item = scalar(0.3), Residual = scalar(0.6)
  )
  item_allocation <- data.frame(
    Stratum = "S", ConditionId = c("I1", "I2"), Weight = 0.5
  )
  residual_allocation <- data.frame(
    Stratum = "S", ConditionId = paste0("O", 1:4), Weight = 0.25
  )
  operators <- list(
    Person = env$mfrmr_gtv_unscaled_operator(strata, "Person"),
    Item = env$mfrmr_gtv_overlap_operator(
      item_allocation, strata, "Item"
    ),
    Residual = env$mfrmr_gtv_overlap_operator(
      residual_allocation, strata, "Residual"
    )
  )
  spec <- env$mfrmr_gtv_spec(strata, map, covariance, operators)
  result <- env$mfrmr_gtv_composite(spec, c(S = 1))

  expect_equal(spec$SigmaP[1, 1], 1.2)
  expect_equal(spec$SigmaRelativeError[1, 1], 0.6 / 4)
  expect_equal(spec$SigmaAbsoluteError[1, 1], 0.6 / 4 + 0.3 / 2)
  expect_equal(result$G, 1.2 / 1.35)
  expect_equal(result$Phi, 1.2 / 1.5)
})

test_that("future Draft.85a0 preserves three-stratum order and rank state", {
  env <- load_gtheory_multivariate()
  strata <- c("Language", "Reasoning", "Communication")
  object <- matrix(
    c(1, 0.3, 0.2, 0.3, 0.8, 0.25, 0.2, 0.25, 0.9),
    3L, 3L, byrow = TRUE, dimnames = list(strata, strata)
  )
  residual <- diag(c(0.4, 0.5, 0.6))
  dimnames(residual) <- list(strata, strata)
  map <- data.frame(
    ComponentId = c("Person", "Residual"),
    UniverseRole = c("object", "relative_error")
  )
  allocation <- do.call(rbind, lapply(strata, function(stratum) {
    data.frame(
      Stratum = stratum,
      ConditionId = paste0(stratum, c("/O1", "/O2")), Weight = 0.5
    )
  }))
  spec <- env$mfrmr_gtv_spec(
    strata, map, list(Person = object, Residual = residual),
    list(
      Person = env$mfrmr_gtv_unscaled_operator(strata, "Person"),
      Residual = env$mfrmr_gtv_overlap_operator(
        allocation, strata, "Residual"
      )
    )
  )
  result <- env$mfrmr_gtv_composite(
    spec, c(Language = 0.3, Reasoning = 0.4, Communication = 0.3)
  )

  expect_identical(spec$Strata, strata)
  expect_identical(rownames(spec$SigmaP), strata)
  expect_equal(dim(spec$SigmaP), c(3L, 3L))
  expect_true(all(spec$MatrixAudit$EffectiveRank >= 1L))
  expect_true(is.finite(result$G))
  expect_true(is.finite(result$Phi))
})

test_that("future Draft.85a0 fails closed for invalid matrix semantics", {
  env <- load_gtheory_multivariate()
  fixture <- env$mfrmr_gtv_fixture("common")
  covariance <- fixture$ComponentCovariances
  operators <- fixture$AllocationOperators

  indefinite <- covariance
  indefinite$Person[,] <- matrix(
    c(1, 1.2, 1.2, 1), 2L, 2L,
    dimnames = list(c("A", "B"), c("A", "B"))
  )
  expect_error(
    env$mfrmr_gtv_spec(
      fixture$Strata, fixture$ComponentMap, indefinite, operators
    ),
    "not positive semidefinite"
  )

  wrong_order <- covariance
  wrong_order$Person <- wrong_order$Person[c("B", "A"), c("B", "A")]
  expect_error(
    env$mfrmr_gtv_spec(
      fixture$Strata, fixture$ComponentMap, wrong_order, operators
    ),
    "exact stratum order"
  )

  asymmetric <- covariance
  asymmetric$Person["A", "B"] <- 0.1
  expect_error(
    env$mfrmr_gtv_spec(
      fixture$Strata, fixture$ComponentMap, asymmetric, operators
    ),
    "asymmetric"
  )

  wrong_object <- operators
  wrong_object$Person <- diag(2)
  dimnames(wrong_object$Person) <- list(c("A", "B"), c("A", "B"))
  expect_error(
    env$mfrmr_gtv_spec(
      fixture$Strata, fixture$ComponentMap, covariance, wrong_object
    ),
    "unscaled all-ones"
  )

  bad_allocation <- data.frame(
    Stratum = c("A", "A", "B"), ConditionId = c("R1", "R2", "R1"),
    Weight = c(0.2, 0.2, 1)
  )
  expect_error(
    env$mfrmr_gtv_overlap_operator(
      bad_allocation, c("A", "B"), "Rater"
    ),
    "summing exactly to one"
  )
})

test_that("future Draft.85a0 enforces explicit weight policy", {
  env <- load_gtheory_multivariate()
  spec <- env$mfrmr_gtv_fixture("partial")
  base <- env$mfrmr_gtv_composite(
    spec, c(A = 0.6, B = 0.4), weight_policy = "nonzero_linear_contrast"
  )
  scaled <- env$mfrmr_gtv_composite(
    spec, c(A = 6, B = 4), weight_policy = "nonzero_linear_contrast"
  )

  expect_equal(base$G, scaled$G, tolerance = 1e-14)
  expect_equal(base$Phi, scaled$Phi, tolerance = 1e-14)
  expect_error(
    env$mfrmr_gtv_composite(spec, c(A = 0.8, B = 0.4)),
    "sum to one"
  )
  expect_error(
    env$mfrmr_gtv_composite(spec, c(A = 1.2, B = -0.2)),
    "nonnegative"
  )
  expect_error(
    env$mfrmr_gtv_composite(
      spec, c(A = 0, B = 0), weight_policy = "nonzero_linear_contrast"
    ),
    "cannot all be zero"
  )
  expect_error(
    env$mfrmr_gtv_composite(spec, c(B = 0.4, C = 0.6)),
    "every stratum"
  )
})

test_that("future Draft.85a0 replays algebra but claims no estimation", {
  env <- load_gtheory_multivariate()
  first <- env$mfrmr_gtv_fixture("common")
  second <- env$mfrmr_gtv_fixture("common")
  result <- env$mfrmr_gtv_composite(first, c(A = 0.6, B = 0.4))

  expect_identical(first$SpecificationHash, second$SpecificationHash)
  expect_identical(first$ComponentContributions, second$ComponentContributions)
  expect_true(first$AlgebraReady)
  expect_true(result$AlgebraReady)
  expect_false(first$EstimationReady)
  expect_false(first$InferenceReady)
  expect_false(first$CoefficientEligible)
  expect_false(first$DecisionReady)
  expect_false(result$EstimationReady)
  expect_false(result$InferenceReady)
  expect_false(result$CoefficientEligible)
  expect_false(result$DecisionReady)
  expect_true(any(first$MatrixAudit$RankDeficient))
})
