tam_immer_jml_mode_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "tam-immer-jml-mode-comparison-0.2.3.R"
  )
}

load_tam_immer_jml_mode_runner <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("immer")
  runner <- tam_immer_jml_mode_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env
}

test_that("TAM and immer mode identities remain factorially distinct", {
  env <- load_tam_immer_jml_mode_runner()
  registry <- env$mfrmr_ti_mode_registry()

  expect_equal(nrow(registry), 9L)
  expect_setequal(
    registry$ModeId,
    c(
      "MFRMR_RAW", "MFRMR_PROFILE",
      "TAM_RAW", "TAM_ADJ", "TAM_BC", "TAM_BC_ADJ",
      "IMMER_JML", "IMMER_EPS", "IMMER_BC"
    )
  )
  expect_match(
    registry$ExtremePolicy[registry$ModeId == "IMMER_JML"],
    "extreme_person_scores"
  )
  expect_match(
    registry$ExtremePolicy[registry$ModeId == "IMMER_EPS"],
    "person_and_item_scores"
  )
  expect_match(
    registry$BiasPolicy[registry$ModeId == "TAM_BC"],
    "\\(I-1\\)/I"
  )
  expect_match(
    registry$BiasPolicy[registry$ModeId == "IMMER_BC"],
    "\\(Ibar-1\\)/Ibar"
  )
})

test_that("external mode manifests and authorization are frozen", {
  env <- load_tam_immer_jml_mode_runner()
  smoke <- env$mfrmr_ti_manifest("smoke")
  pilot <- env$mfrmr_run_tam_immer_jml_mode_comparison(
    "pilot", dry_run = TRUE
  )

  expect_equal(nrow(smoke), 4L)
  expect_equal(nrow(pilot), 60L)
  expect_setequal(smoke$Model, c("RSM", "PCM"))
  expect_setequal(smoke$ExtremeFraction, c(0, 0.125))
  expect_true(all(smoke$ResponsesPerPerson == 9L))
  expect_true(all(smoke$MfrmrMaxit == 400L))
  expect_true(all(smoke$TamMaxit == 400L))
  expect_true(all(smoke$ImmerMaxit == 1000L))
  expect_true(all(pilot$MfrmrMaxit == 500L))
  expect_true(all(pilot$TamMaxit == 600L))
  expect_true(all(pilot$ImmerMaxit == 1000L))
  expect_setequal(
    unique(smoke$FormulaIdentity),
    c("~ item + rater + step", "~ item + rater + item:step")
  )
  expect_error(
    env$mfrmr_run_tam_immer_jml_mode_comparison("pilot"),
    "authorize_pilot = TRUE"
  )
})

test_that("forced-extreme datasets preserve their paired base observations", {
  env <- load_tam_immer_jml_mode_runner()
  manifest <- env$mfrmr_ti_manifest("smoke")
  for (model in c("RSM", "PCM")) {
    base_row <- manifest[
      manifest$Model == model & manifest$ExtremeFraction == 0,
      , drop = FALSE
    ]
    extreme_row <- manifest[
      manifest$Model == model & manifest$ExtremeFraction > 0,
      , drop = FALSE
    ]
    base <- env$mfrmr_ti_generate(base_row)
    extreme <- env$mfrmr_ti_generate(extreme_row)
    forced <- attr(extreme, "mfrmr_forced_extremes")
    retained <- !as.character(base$Person) %in% c(forced$high, forced$low)

    expect_equal(base[retained, ], extreme[retained, ], ignore_attr = TRUE)
    expect_length(forced$high, 4L)
    expect_length(forced$low, 4L)
  }
})

test_that("matched TAM immer and mfrmr smoke closes its semantic invariants", {
  env <- load_tam_immer_jml_mode_runner()
  result <- env$mfrmr_run_tam_immer_jml_mode_comparison(
    "smoke", progress = FALSE
  )

  expect_true(result$ContractPassed)
  expect_false(result$EvidenceReady)
  expect_identical(result$ReadinessEffect, "none_calibration_only")
  expect_equal(nrow(result$Modes), 36L)
  expect_equal(nrow(result$Recovery), 864L)
  expect_true(all(result$Invariants$Passed[result$Invariants$Required]))

  extreme_tam_raw <- result$Modes$ActualExtremeN > 0L &
    result$Modes$ModeId %in% c("TAM_RAW", "TAM_BC")
  expect_true(all(!result$Modes$FitReturned[extreme_tam_raw]))
  expect_true(all(nzchar(result$Modes$Error[extreme_tam_raw])))
  expect_true(all(result$Modes$FitReturned[!extreme_tam_raw]))
  expect_true(all(result$Modes$FiniteSurface[!extreme_tam_raw]))
  expect_equal(sum(result$Modes$OriginalRawEligible), 6L)
  expect_true(all(!result$Modes$OriginalMaximumClaimed))

  parity <- result$Invariants[
    result$Invariants$Invariant ==
      "mfrmr_vs_tam_raw_location_aligned_no_extremes" &
      result$Invariants$Required,
    , drop = FALSE
  ]
  expect_equal(nrow(parity), 2L)
  expect_true(all(parity$Estimate < 4e-6))

  scale_checks <- result$Invariants[
    grepl("bias_factor", result$Invariants$Invariant) &
      result$Invariants$Required,
    , drop = FALSE
  ]
  expect_true(all(scale_checks$Estimate < 1e-12))

  get_mode <- function(dataset, mode) {
    result$Recovery[
      result$Recovery$DatasetId == dataset &
        result$Recovery$ModeId == mode,
      c("Item", "Category", "Estimate"), drop = FALSE
    ]
  }
  datasets <- unique(result$Recovery$DatasetId)
  epsilon_difference <- vapply(datasets, function(dataset) {
    jml <- get_mode(dataset, "IMMER_JML")
    eps <- get_mode(dataset, "IMMER_EPS")
    joined <- merge(jml, eps, by = c("Item", "Category"),
                    suffixes = c(".JML", ".EPS"))
    max(abs(joined$Estimate.JML - joined$Estimate.EPS))
  }, numeric(1))
  expect_true(all(epsilon_difference > 0.1))
})
