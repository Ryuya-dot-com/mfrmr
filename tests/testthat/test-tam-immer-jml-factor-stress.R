tam_immer_factor_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "tam-immer-jml-factor-stress-0.2.3.R"
  )
}

load_tam_immer_factor_runner <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("immer")
  runner <- tam_immer_factor_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  env
}

test_that("factor and metric identities prevent pooled interpretation", {
  env <- load_tam_immer_factor_runner()
  factors <- env$mfrmr_tif_factor_registry()
  metrics <- env$mfrmr_tif_metric_registry()

  expect_setequal(
    factors$Factor,
    c(
      "Persons", "ObservedResponsesPerPerson", "Raters", "Criteria",
      "Categories", "AssignmentDensity", "RaterWorkloadImbalance",
      "MinimumResponseRate", "MaximumResponseRate",
      "LowExtremePersonRate", "HighExtremePersonRate",
      "LocalDependence", "AnchorRate", "MissingMechanism"
    )
  )
  expect_identical(
    factors$Role[factors$Factor == "ObservedResponsesPerPerson"],
    "derived"
  )
  expect_match(
    metrics$PrimaryEligibility[metrics$Metric == "SECoverage95"],
    "covariance"
  )
  expect_match(
    metrics$PrimaryEligibility[
      metrics$Metric == "ReportedFacetSeparation"
    ],
    "same separation formula"
  )
  expect_identical(
    metrics$MisspecificationUse[metrics$Metric == "SECoverage95"],
    "descriptive_only"
  )
  expect_match(
    metrics$PrimaryEligibility[
      metrics$Metric == "NumericalConvergenceRate"
    ],
    "engine-specific"
  )
})

test_that("factor manifests cover requested axes and remain guarded", {
  env <- load_tam_immer_factor_runner()
  smoke <- env$mfrmr_tif_manifest("smoke")
  pilot <- env$mfrmr_run_tam_immer_jml_factor_stress(
    "pilot", dry_run = TRUE
  )

  expect_equal(nrow(smoke), 22L)
  expect_equal(nrow(pilot), 290L)
  expect_setequal(smoke$Model, c("RSM", "PCM"))
  expect_true(all(smoke$TargetResponsesPerPerson > 0))
  expect_true(all(smoke$TargetAssignmentDensity > 0 &
                    smoke$TargetAssignmentDensity <= 1))
  expect_setequal(
    smoke$MissingMechanism,
    c("none", "MCAR", "MAR_rater", "MNAR_score")
  )
  expect_true(any(smoke$LocalDependenceRho > 0))
  expect_true(any(smoke$WorkloadRatio > 1))
  expect_true(any(smoke$ExtremeFraction > 0))
  expect_true(any(smoke$AnchorRate > 0))
  expect_true(all(!smoke$FitEligible[smoke$AnchorRate > 0]))
  expect_true(all(
    smoke$ExpectedDatasetState[smoke$AnchorRate > 0] ==
      "guarded_not_attempted"
  ))
  expect_true(all(
    smoke$ExpectedDatasetState[smoke$ProfileId == "SCALE_LOW"] ==
      "structurally_unidentified"
  ))
  expect_equal(
    sum(pilot$ExpectedDatasetState == "structurally_unidentified"), 40L
  )
  expect_equal(
    sum(pilot$ExpectedDatasetState == "guarded_not_attempted"), 20L
  )
  expect_equal(sum(pilot$ExpectedDatasetState == "attempted_modes"), 230L)
  expect_true(all(
    smoke$FitIneligibilityReason[smoke$AnchorRate > 0] ==
      "common_anchor_basis_not_yet_verified"
  ))
  expect_error(
    env$mfrmr_run_tam_immer_jml_factor_stress("pilot"),
    "authorize_pilot = TRUE"
  )
})

test_that("factor generator retains target and realized design diagnostics", {
  env <- load_tam_immer_factor_runner()
  manifest <- env$mfrmr_tif_manifest("smoke")
  get_row <- function(model, profile) {
    manifest[
      manifest$Model == model & manifest$ProfileId == profile,
      , drop = FALSE
    ]
  }

  sparse_row <- get_row("RSM", "SPARSE_LOAD")
  sparse <- env$mfrmr_tif_generate(sparse_row)
  sparse_audit <- attr(sparse, "mfrmr_factor_audit")
  expect_equal(sparse_audit$MeanResponsesPerPerson, 8)
  expect_equal(sparse_audit$AssignmentDensity, 0.25)
  expect_true(sparse_audit$WorkloadGini > 0.15)
  expect_true(sparse_audit$WorkloadMaxMinRatio > 2)

  extreme <- env$mfrmr_tif_generate(get_row("PCM", "ENDPOINT_PERSON"))
  extreme_audit <- attr(extreme, "mfrmr_factor_audit")
  expect_gt(extreme_audit$LowExtremePersonRate, 0)
  expect_gt(extreme_audit$HighExtremePersonRate, 0)

  for (profile in c("MCAR", "MAR_RATER", "MNAR_SCORE")) {
    missing <- env$mfrmr_tif_generate(get_row("RSM", profile))
    audit <- attr(missing, "mfrmr_factor_audit")
    expect_gt(audit$MissingRateRealized, 0.10)
    expect_lt(audit$MissingRateRealized, 0.30)
    expect_true(all(tapply(
      !is.na(missing$Score), missing$Person, sum
    ) > 0), info = profile)
  }

  anchored <- env$mfrmr_tif_generate(get_row("RSM", "ANCHOR_25"))
  anchors <- attr(anchored, "mfrmr_factor_anchors")
  expect_equal(nrow(anchors), 1L)
  expect_true(all(anchors$Facet == "Rater"))
})

test_that("incomplete assignment compares modes and withholds invalid metrics", {
  env <- load_tam_immer_factor_runner()
  manifest <- env$mfrmr_tif_manifest("smoke")
  row <- manifest[
    manifest$Model == "RSM" & manifest$ProfileId == "SPARSE_LOAD",
    , drop = FALSE
  ]
  data <- env$mfrmr_tif_generate(row)
  output <- env$mfrmr_ti_fit_one(row, data = data)
  metrics <- env$mfrmr_tif_recovery_metrics(output, row)

  expect_equal(nrow(output$modes), 9L)
  expect_true(all(output$modes$FitReturned))
  expect_true(all(output$modes$FiniteSurface))
  expect_equal(nrow(output$recovery), 864L)

  tam_factor <- output$modes$BiasFactor[
    output$modes$ModeId == "TAM_BC"
  ]
  immer_factor <- output$modes$BiasFactor[
    output$modes$ModeId == "IMMER_BC"
  ]
  expect_equal(tam_factor, 31 / 32)
  expect_equal(immer_factor, 7 / 8)
  expect_false(isTRUE(all.equal(tam_factor, immer_factor)))

  expect_equal(
    output$fits$TAM_RAW$errorP,
    output$fits$TAM_BC$errorP,
    tolerance = 1e-12
  )
  expect_equal(
    output$fits$IMMER_JML$xsi_se,
    output$fits$IMMER_BC$xsi_se,
    tolerance = 1e-12
  )

  coverage <- metrics[metrics$Metric == "SECoverage95", , drop = FALSE]
  separation <- metrics[
    metrics$Metric == "ReportedFacetSeparation", , drop = FALSE
  ]
  expect_true(all(!coverage$Eligible & is.na(coverage$Value)))
  expect_true(all(
    coverage$IneligibilityReason == "common_surface_covariance_unavailable"
  ))
  expect_true(all(!separation$Eligible & is.na(separation$Value)))
  expect_true(all(metrics$EvidenceReady == FALSE))
  convergence <- metrics[
    metrics$Metric == "NumericalConvergenceRate", , drop = FALSE
  ]
  expect_equal(nrow(convergence), 9L)
  expect_true(all(nzchar(convergence$Definition)))

  rank <- metrics[
    metrics$Metric == "SpearmanRankRecovery" & metrics$Facet == "Rater",
    , drop = FALSE
  ]
  expect_equal(nrow(rank), 9L)
  expect_true(all(rank$Eligible))
  expect_true(all(rank$Value >= -1 & rank$Value <= 1))
})

test_that("factor checkpoints bind execution, manifest row, and payload", {
  env <- load_tam_immer_factor_runner()
  manifest <- env$mfrmr_tif_manifest("smoke")
  identity <- env$mfrmr_tif_execution_identity("smoke", manifest)
  row <- manifest[1L, , drop = FALSE]
  result <- env$mfrmr_tif_run_cell(row)
  checkpoint <- env$mfrmr_tif_checkpoint(row, result, identity)

  expect_no_error(
    env$mfrmr_tif_validate_checkpoint(checkpoint, row, identity)
  )
  expect_identical(
    identity$ExecutionSHA256,
    env$mfrmr_tif_execution_identity("smoke", manifest)$ExecutionSHA256
  )

  changed_row <- row
  changed_row$Seed <- changed_row$Seed + 1L
  expect_error(
    env$mfrmr_tif_validate_checkpoint(checkpoint, changed_row, identity),
    "manifest row hash mismatch"
  )
  tampered <- checkpoint
  tampered$Result$Dataset$Generated <- FALSE
  expect_error(
    env$mfrmr_tif_validate_checkpoint(tampered, row, identity),
    "result payload hash mismatch"
  )
})

test_that("factor runner writes one atomic checkpoint before interruption", {
  env <- load_tam_immer_factor_runner()
  checkpoint_dir <- file.path(
    tempdir(), paste0("mfrmr-factor-checkpoint-", Sys.getpid(), "-",
                      sample.int(1e6, 1L))
  )
  dir.create(checkpoint_dir, recursive = TRUE)

  expect_error(
    env$mfrmr_run_tam_immer_jml_factor_stress(
      "smoke", checkpoint_dir = checkpoint_dir,
      interrupt_after_new = 1L, progress = FALSE
    ),
    "Intentional factor-stress interruption after 1"
  )
  files <- list.files(checkpoint_dir, pattern = "[.]rds$", full.names = TRUE)
  expect_length(files, 1L)
  expect_false(file.exists(file.path(checkpoint_dir, "completion-marker.rds")))
  expect_error(
    env$mfrmr_run_tam_immer_jml_factor_stress(
      "smoke", checkpoint_dir = checkpoint_dir, progress = FALSE
    ),
    "require `resume = TRUE`"
  )
})
