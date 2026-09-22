load_conquest_reported_point_calibration <- function() {
  skip_if_not_installed("digest")
  skip_if_not_installed("numDeriv")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  files <- c(
    "conquest-additive-mfrm-design-0.2.3.R",
    "conquest-additive-mfrm-reference-preflight-0.2.3.R",
    "external-comparison-eligibility-contract-0.2.3.R",
    "conquest-external-comparison-normalizer-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R",
    "conquest-reported-point-likelihood-calibration-0.2.3.R"
  )
  paths <- file.path(validation, files)
  skip_if_not(all(file.exists(paths)),
              "Repository-only reported-point calibration is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, env = env)
}

load_retained_conquest_reported_policy <- function(contract) {
  output_dir <- file.path(
    contract$root, "validation-results", "conquest-additive-native-20260811"
  )
  skip_if_not(dir.exists(output_dir),
              "Restricted retained ConQuest outputs are unavailable.")
  sources <- c(
    "conquest-numeric-resolution-contract-0.2.3.R",
    "conquest-additive-native-rsm-q31-review-0.2.3.R",
    "conquest-additive-native-pcm-q31-review-0.2.3.R",
    "conquest-additive-native-four-arm-review-0.2.3.R"
  )
  for (file in sources) {
    sys.source(file.path(contract$validation, file), envir = contract$env)
  }
  review <- contract$env$mfrmr_review_conquest_additive_native_four_arms(
    output_dir
  )
  list(
    output_dir = output_dir,
    review = review,
    policy = contract$env$mfrmr_cq_rop_review_four_arm(output_dir, review)
  )
}

test_that("free coordinates decode the declared sum-zero parameterization", {
  contract <- load_conquest_reported_point_calibration()
  env <- contract$env
  fixture <- env$mfrmr_cq_additive_fixture()

  rsm <- c(
    population_intercept = 0.1,
    population_slope = 0.5,
    log_population_variance = log(0.3),
    R1 = -0.4, C1 = -0.3, Step1 = -0.9, Step2 = -0.1
  )
  decoded <- env$mfrmr_cq_rplc_decode(rsm, "RSM", fixture)
  expect_equal(unname(decoded$variance), 0.3, tolerance = 1e-15)
  expect_equal(sum(decoded$rater), 0, tolerance = 1e-15)
  expect_equal(sum(decoded$criterion), 0, tolerance = 1e-15)
  expect_equal(rowSums(decoded$steps), c(C1 = 0, C2 = 0),
               tolerance = 1e-15)
  expect_identical(decoded$steps["C1", ], decoded$steps["C2", ])

  pcm <- c(
    rsm[1:5],
    `C1:Step1` = -1.0, `C1:Step2` = -0.1,
    `C2:Step1` = -0.8, `C2:Step2` = -0.2
  )
  decoded_pcm <- env$mfrmr_cq_rplc_decode(pcm, "PCM", fixture)
  expect_equal(rowSums(decoded_pcm$steps), c(C1 = 0, C2 = 0),
               tolerance = 1e-15)
  expect_false(identical(decoded_pcm$steps["C1", ],
                         decoded_pcm$steps["C2", ]))
})

test_that("common deviance and derivative mechanics are deterministic", {
  contract <- load_conquest_reported_point_calibration()
  env <- contract$env
  fixture <- env$mfrmr_cq_additive_fixture()
  point <- c(
    population_intercept = 0.1,
    population_slope = 0.5,
    log_population_variance = log(0.3),
    R1 = -0.4, C1 = -0.3, Step1 = -0.9, Step2 = -0.1
  )
  q31 <- env$mfrmr_cq_rplc_deviance_function("RSM", 31L, fixture)
  q61 <- env$mfrmr_cq_rplc_deviance_function("RSM", 61L, fixture)
  expect_true(is.finite(q31(point)))
  expect_identical(q31(point), q31(point))
  expect_lt(abs(q61(point) - q31(point)), 1e-8)

  quadratic <- function(x) sum((x - c(1, -2))^2)
  derivative <- env$mfrmr_cq_rplc_derivatives(quadratic, c(0, 0))
  expect_equal(derivative$gradient, c(-2, 4), tolerance = 1e-8)
  expect_equal(derivative$hessian, diag(2, 2), tolerance = 3e-6)
  expect_true(derivative$positive_definite)
  expect_equal(derivative$newton_decrement, sqrt(10), tolerance = 2e-6)
})

test_that("retained reported points are calibrated without self-passing", {
  contract <- load_conquest_reported_point_calibration()
  retained <- load_retained_conquest_reported_policy(contract)
  result <- contract$env$mfrmr_calibrate_conquest_reported_point_likelihood(
    retained$policy, retained$output_dir, retained$review
  )

  expect_s3_class(
    result, "mfrmr_conquest_reported_point_likelihood_calibration"
  )
  expect_identical(
    result$status,
    "opened_calibration_common_likelihood_ready_tolerance_missing"
  )
  expect_identical(nrow(result$arms), 4L)
  expect_identical(nrow(result$integration), 2L)
  expect_setequal(result$arms$Model, c("RSM", "PCM"))
  expect_true(all(result$arms$ReportedHessianPositiveDefinite))
  expect_true(all(result$arms$MfrmrHessianPositiveDefinite))
  expect_lt(max(result$arms$ReportedMinusMfrmrCommonDeviance), 1e-8)
  expect_lt(max(result$arms$ReportedGradientSupNorm), 2e-4)
  expect_lt(max(result$arms$MfrmrGradientSupNorm), 2e-5)
  expect_lt(max(
    result$arms$MfrmrStoredCommonDevianceAbsDifference
  ), 1e-9)
  expect_true(all(result$integration$ExactReportedCoordinatesIdentical))
  expect_lt(max(
    result$integration$SamePointIntegrationAbsDifference
  ), 1e-9)
  expect_true(result$tolerance_may_be_informed_for_future_candidate)
  expect_true(result$source_bound_review_verified)
  expect_true(result$deterministic_input_identity_verified)
  expect_false(result$calibration_may_pass_new_tolerance)
  expect_false(result$hidden_solution_equivalence_eligible)
  expect_false(result$tolerance_frozen)
  expect_false(result$candidate_bound)
  expect_false(result$comparison_ready)
  expect_false(result$scientific_equivalence_inferred)
  expect_false(result$confirmation_authorized)
})

test_that("q31/q61 token drift and hidden promotion fail closed", {
  contract <- load_conquest_reported_point_calibration()
  retained <- load_retained_conquest_reported_policy(contract)
  policy <- retained$policy

  changed <- policy
  selected <- changed$rows$RunId == "rsm_q061" &
    changed$rows$Coordinate == "R1"
  changed$rows$NativeToken[selected] <- "-0.365139"
  parsed <- contract$env$mfrmr_cq_rop_parse_exact_decimal(
    changed$rows$NativeToken[selected]
  )
  changed$rows$NativeValue[selected] <- parsed$NumericValue
  changed$rows$CanonicalExactDecimal[selected] <-
    parsed$CanonicalExactDecimal
  changed$rows$SignedReportedDifference[selected] <-
    changed$rows$NativeValue[selected] -
    changed$rows$MfrmrReferenceValue[selected]
  changed$rows$AbsoluteReportedDifference[selected] <- abs(
    changed$rows$SignedReportedDifference[selected]
  )
  changed$rows_sha256 <- contract$env$mfrmr_cq_rop_rows_sha256(changed$rows)
  expect_true(isTRUE(contract$env$mfrmr_cq_rop_validate_policy(changed)))
  expect_error(
    contract$env$mfrmr_calibrate_conquest_reported_point_likelihood(
      changed, retained$output_dir, retained$review
    ),
    "not bound to the reviewed numerical rows"
  )
  expect_error(
    contract$env$mfrmr_cq_rplc_integration_rows(
      changed, contract$env$mfrmr_cq_additive_fixture()
    ),
    "q31/q61 exact reported coordinates differ"
  )

  promoted <- policy
  promoted$hidden_solution_equivalence_eligible <- TRUE
  expect_error(
    contract$env$mfrmr_calibrate_conquest_reported_point_likelihood(
      promoted, retained$output_dir, retained$review
    ),
    "identity or scope is invalid"
  )

  unbound_review <- retained$review
  unbound_review$cross_manifest_wide_sha256_identical <- FALSE
  expect_error(
    contract$env$mfrmr_calibrate_conquest_reported_point_likelihood(
      policy, retained$output_dir, unbound_review
    ),
    "source-bound four-arm review"
  )
})
