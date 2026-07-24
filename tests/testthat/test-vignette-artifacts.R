test_that("precomputed vignette artifacts match their manifest", {
  artifact_dir <- system.file(
    "extdata", "vignette-artifacts",
    package = "mfrmr",
    mustWork = TRUE
  )
  manifest <- utils::read.csv(
    file.path(artifact_dir, "manifest.csv"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  expect_true(nrow(manifest) > 0L)
  expect_true(all(c(
    "Artifact", "Rows", "Columns", "Schema", "MD5", "Source",
    "DataKey", "GeneratedWith"
  ) %in% names(manifest)))
  expect_true(all(manifest$DataKey == "example_operational"))
  expect_true(all(manifest$GeneratedWith == as.character(utils::packageVersion("mfrmr"))))

  for (i in seq_len(nrow(manifest))) {
    path <- file.path(artifact_dir, manifest$Artifact[i])
    expect_true(file.exists(path), info = manifest$Artifact[i])
    artifact <- utils::read.csv(
      path,
      stringsAsFactors = FALSE,
      check.names = FALSE,
      na.strings = character()
    )
    expect_equal(nrow(artifact), manifest$Rows[i], info = manifest$Artifact[i])
    expect_equal(ncol(artifact), manifest$Columns[i], info = manifest$Artifact[i])
    expect_identical(
      paste(names(artifact), collapse = "|"),
      manifest$Schema[i],
      info = manifest$Artifact[i]
    )
    expect_identical(
      unname(tools::md5sum(path)),
      manifest$MD5[i],
      info = manifest$Artifact[i]
    )
  }
})

test_that("precomputed workflow artifacts represent the canonical successful fit", {
  artifact_dir <- system.file(
    "extdata", "vignette-artifacts",
    package = "mfrmr",
    mustWork = TRUE
  )
  fit_overview <- utils::read.csv(
    file.path(artifact_dir, "workflow_fit_overview.csv"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  diagnostic_overview <- utils::read.csv(
    file.path(artifact_dir, "workflow_diagnostic_overview.csv"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  expect_identical(fit_overview$Model, "RSM")
  expect_identical(fit_overview$Method, "MML")
  expect_true(isTRUE(fit_overview$Converged))
  expect_true(isTRUE(fit_overview$InferenceReady))
  expect_identical(fit_overview$ConvergenceSeverity, "pass")
  expect_true(all(c(
    "OptimizerInitialMethod", "OptimizerMethod", "OptimizerPolished",
    "RequestedReltol", "EffectiveReltol", "OptimizerFactr",
    "OptimizerPgtol"
  ) %in% names(fit_overview)))
  expect_identical(fit_overview$OptimizerInitialMethod, "L-BFGS-B")
  expect_true(isTRUE(fit_overview$OptimizerPolished))
  expect_equal(fit_overview$RequestedReltol, 1e-9)
  expect_lt(fit_overview$EffectiveReltol, fit_overview$RequestedReltol)
  expect_true(is.finite(fit_overview$OptimizerFactr))
  expect_true(is.finite(fit_overview$OptimizerPgtol))
  expect_identical(diagnostic_overview$Method, "MML")
  expect_identical(diagnostic_overview$PrecisionTier, "model_based")
})
