tam_dimensionality_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_tam_dimensionality_pilot <- function() {
  validation_dir <- tam_dimensionality_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only dimensionality validation files are unavailable."
  )
  env <- new.env(parent = globalenv())
  sys.source(
    file.path(validation_dir, "external-ic-normalizer-0.2.3.R"),
    envir = env
  )
  sys.source(
    file.path(validation_dir, "tam-dimensionality-pilot-0.2.3.R"),
    envir = env
  )
  list(
    env = env,
    pkg_dir = normalizePath(
      file.path(validation_dir, "..", ".."),
      winslash = "/",
      mustWork = TRUE
    )
  )
}

test_that("the TAM dimensionality pilot freezes prespecified Q hypotheses", {
  testthat::skip_if_not_installed("digest")
  loaded <- load_tam_dimensionality_pilot()
  env <- loaded$env
  registry <- env$mfrmr_tam_dim_scenario_registry()
  expect_identical(
    registry$ScenarioId,
    c("DIM-SYN-TRUE-1D", "DIM-SYN-TRUE-2D")
  )
  expect_true(all(registry$EvidenceRole == "pilot"))
  expect_true(all(registry$PartitionRole == "pilot_only_not_confirmation"))

  generated <- env$mfrmr_tam_dim_simulate_binary(
    registry[registry$ScenarioId == "DIM-SYN-TRUE-2D", , drop = FALSE],
    persons = 80L,
    items = 8L
  )
  expect_identical(dim(generated$response), c(80L, 8L))
  expect_identical(dim(generated$Q$TAM_1D), c(8L, 1L))
  expect_identical(dim(generated$Q$TAM_2D), c(8L, 2L))
  expect_true(all(rowSums(generated$Q$TAM_2D) == 1))
  expect_false(identical(
    generated$metadata$Q1Hash,
    generated$metadata$Q2Hash
  ))
  expect_false(generated$metadata$ConfirmationAuthorized)

  invalid_q <- generated$Q$TAM_2D
  invalid_q[1, ] <- 1
  expect_error(
    env$mfrmr_tam_dim_validate_q(
      invalid_q, colnames(generated$response), 2L
    ),
    "exactly one prespecified dimension"
  )
  expect_error(
    env$mfrmr_tam_dim_integration_grid(
      product_nodes = c(20L, 21L), qmc_nodes = 128L
    ),
    "unique odd integers"
  )

  grid <- env$mfrmr_tam_dim_integration_grid(
    product_nodes = c(21L, 31L),
    qmc_nodes = c(128L, 256L)
  )
  expect_identical(
    grid$IntegrationFamily,
    c(
      "product_quadrature", "product_quadrature",
      "deterministic_qmc", "deterministic_qmc"
    )
  )
  expect_true(all(grid$QMC))
  expect_true(all(!grid$SeedOperative))
  expect_identical(
    grid$IntegrationId[grid$ReferenceWithinFamily],
    c("product-q31", "qmc-s256")
  )

  stochastic_grid <- env$mfrmr_tam_dim_stochastic_grid(
    snodes = 128L,
    seeds = c(2701L, 2702L)
  )
  expect_true(all(stochastic_grid$IntegrationFamily == "stochastic_mc"))
  expect_true(all(!stochastic_grid$QMC))
  expect_true(all(stochastic_grid$SeedOperative))
  expect_identical(stochastic_grid$Seed, c(2701L, 2702L))
  expect_true(all(grepl("seed=27", stochastic_grid$IntegrationComparisonId)))
})

test_that("the TAM dimensionality runner stays pilot-only and fails closed", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("TAM")
  testthat::skip_if_not_installed("digest")
  loaded <- load_tam_dimensionality_pilot()
  env <- loaded$env
  pilot <- env$mfrmr_run_tam_dimensionality_pilot(
    scenario_id = "DIM-SYN-TRUE-2D",
    product_nodes = c(21L, 31L),
    qmc_nodes = c(128L, 256L),
    persons = 80L,
    items = 8L,
    pkg_dir = loaded$pkg_dir
  )

  expect_identical(pilot$specification, "0.2.3-draft.6")
  expect_identical(
    pilot$contract_version,
    "mfrmr_tam_dimensionality_pilot_v1"
  )
  expect_identical(pilot$status, "review")
  expect_false(pilot$confirmation_authorized)
  expect_false(pilot$selection_authorized)
  expect_equal(nrow(pilot$fits), 8L)
  expect_setequal(pilot$fits$Dimensions, c(1L, 2L))
  expect_true(all(pilot$fits$ConvergenceStatus != "fail"))
  expect_true(all(pilot$fits$ObjectiveConsistent))
  expect_true(all(pilot$fits$ObservedLogLikRangePass))
  expect_true(all(pilot$fits$ObservationSetPreserved))
  expect_true(all(pilot$fits$NativeABICFormulaVerified))
  expect_true(all(
    pilot$fits$NativeABICFormula ==
      "tam_deviance_plus_log_n_minus_2_over_24_k"
  ))
  expect_true(all(!pilot$fits$ComparisonReady))
  expect_true(all(
    pilot$fits$IntegrationStabilityStatus == "not_checked"
  ))
  expect_true(all(!pilot$fits$RegularChiSquareLRTAuthorized))
  expect_true(all(!pilot$pairwise$RegularChiSquareLRTAuthorized))
  expect_true(all(
    pilot$pairwise$ParametricBootstrapStatus == "not_implemented"
  ))
  expect_true(all(!pilot$pairwise$SelectionAuthorized))
  expect_true(all(!pilot$stability$SelectionAuthorized))
  expect_true(all(
    pilot$stability$FreezeCriterionStatus == "pilot_required"
  ))
  expect_equal(nrow(pilot$stability), 2L)
  expect_true(all(is.finite(
    pilot$stability$MaxAbsDevianceGainDrift
  )))
  expect_true(all(is.finite(
    pilot$stability$MaxAbsParameterDrift1D
  )))
  expect_true(all(is.finite(
    pilot$stability$MaxAbsParameterDrift2D
  )))
  expect_false(any(grepl(
    "pvalue|p_value|chisquarep",
    names(pilot$pairwise),
    ignore.case = TRUE
  )))

  public_import_target <- pilot$records[[1]]
  expect_s3_class(public_import_target, "mfrmr_external_ic_record")
  expect_true(public_import_target$record$ArithmeticEligible)
  expect_false(public_import_target$record$ComparisonReady)

  repeat_audit <- env$mfrmr_run_tam_dimensionality_qmc_repeat_audit(
    scenario_id = "DIM-SYN-TRUE-2D",
    qmc_nodes = 128L,
    repeats = 2L,
    persons = 80L,
    items = 8L,
    pkg_dir = loaded$pkg_dir
  )
  expect_identical(repeat_audit$status, "review")
  expect_true(all(!repeat_audit$summary$SeedOperative))
  expect_true(all(repeat_audit$summary$AllFitsWithoutHardFailure))
  expect_true(all(repeat_audit$summary$DeterministicReplayObserved))
  expect_equal(
    repeat_audit$summary$MaxAbsDevianceRepeatDifference,
    c(0, 0),
    tolerance = 0
  )
  expect_equal(
    repeat_audit$summary$MaxAbsParameterRepeatDifference,
    c(0, 0),
    tolerance = 0
  )

  stochastic <- env$mfrmr_run_tam_dimensionality_stochastic_audit(
    scenario_id = "DIM-SYN-TRUE-2D",
    snodes = 128L,
    seeds = c(2701L, 2702L),
    persons = 80L,
    items = 8L,
    pkg_dir = loaded$pkg_dir
  )
  expect_identical(stochastic$status, "review")
  expect_true(all(stochastic$fits$ConvergenceStatus != "fail"))
  expect_true(all(stochastic$fits$IntegrationSeed %in% c(2701L, 2702L)))
  expect_true(all(stochastic$model_stability$AllSeedsRecorded))
  expect_true(all(
    stochastic$model_stability$StochasticVariationExpected
  ))
  expect_true(any(
    stochastic$model_stability$MaxAbsDevianceSeedDifference > 0
  ))
  expect_true(all(!stochastic$pairwise$SelectionAuthorized))
  expect_true(all(vapply(stochastic$records, function(record) {
    grepl("qmc=false:nnodes=128:seed=27", record$record$IntegrationEvaluationId)
  }, logical(1))))
})
