facets_mfx_environment <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) return(cache)
    cache <<- new.env(parent = globalenv())
    validation_dir <- testthat::test_path("..", "..", "inst", "validation")
    precision_path <- file.path(
      validation_dir, "facets-multifacet-precision-contract-0.2.3.R"
    )
    adapter_path <- file.path(
      validation_dir, "facets-multifacet-pilot-adapter-0.2.3.R"
    )
    expect_true(file.exists(precision_path))
    expect_true(file.exists(adapter_path))
    sys.source(precision_path, envir = cache)
    sys.source(adapter_path, envir = cache)
    cache
  }
})

test_that("pilot adapter preflight creates no files and opens no outcome", {
  env <- facets_mfx_environment()
  work_dir <- tempfile("facets-mfx-preflight-")
  result <- env$mfrmr_run_facets_mfx_pilot_adapter(
    facets_exe = "deliberately-missing-facets.exe",
    work_dir = work_dir,
    base_seed = 451001L,
    total_facets = 3L,
    models = c("RSM", "PCM")
  )

  expect_s3_class(result, "mfrmr_facets_mfx_result")
  expect_false(dir.exists(work_dir))
  expect_equal(nrow(result$manifest), 2L)
  expect_equal(result$manifest$DesignSeed, c(451002L, 451003L))
  expect_true(all(result$manifest$ExecutionStatus == "not_run"))
  expect_true(all(!result$manifest$ResultOpened))
  expect_true(all(!result$manifest$FileHashUsed))
  expect_equal(nrow(result$element_coordinates), 0L)
  expect_equal(nrow(result$step_coordinates), 0L)
  expect_false(result$decision$ExternalExecutionRequested)
  expect_false(result$decision$ConfirmationOutcomeOpened)
  expect_false(result$decision$ConfirmationClaimAuthorized)
  expect_false(result$decision$FACETSReplacementClaimAuthorized)
  expect_false(result$decision$FileHashRequired)
})

test_that("pilot adapter accepts only the explicit opened-seed allowlist", {
  env <- facets_mfx_environment()
  expect_equal(
    env$mfrmr_facets_mfx_allowed_pilot_seeds(),
    c(451001L, 452001L, 452101L, 452201L, 452301L, 452401L)
  )
  expect_error(
    env$mfrmr_facets_mfx_registry(460001L, 3L, "RSM"),
    "confirmation seeds are not permitted"
  )
  expect_error(
    env$mfrmr_facets_mfx_registry(451002L, 3L, "RSM"),
    "already-open pilot seed"
  )
})

test_that("pilot adapter normalizes complete semantic evidence", {
  env <- facets_mfx_environment()
  work_dir <- tempfile("facets-mfx-normalize-")
  case_dir <- file.path(work_dir, "rsm-f3")
  dir.create(case_dir, recursive = TRUE)
  writeLines("Facets 4.5.0 synthetic parser fixture", file.path(
    case_dir, "report.txt"
  ))
  facets_exe <- tempfile(fileext = ".exe")
  writeBin(as.raw(1:8), facets_exe)

  element_identity <- rbind(
    data.frame(Facet = "Person", Level = sprintf("P%03d", 1:40)),
    data.frame(Facet = "Rater", Level = sprintf("R%02d", 1:4)),
    data.frame(Facet = "Criterion", Level = sprintf("C%02d", 1:4))
  )
  element_coordinates <- data.frame(
    element_identity,
    MfrmrEstimate = seq(-0.2, 0.2, length.out = 48L),
    FACETSEstimate = seq(-0.2, 0.2, length.out = 48L),
    stringsAsFactors = FALSE
  )
  element_coordinates$Difference <- 0
  element_coordinates$AbsoluteDifference <- 0
  step_coordinates <- data.frame(
    StepFacet = "Common", Step = paste0("Step_", 1:3),
    MfrmrEstimate = c(-0.8, 0, 0.8),
    FACETSEstimate = c(-0.8, 0, 0.8),
    Difference = 0, AbsoluteDifference = 0,
    stringsAsFactors = FALSE
  )
  add_identity <- function(x) {
    x$Model <- "RSM"
    x$BaseSeed <- 451001L
    x$DesignSeed <- 451002L
    x$TotalFacets <- 3L
    x
  }
  raw <- list(
    manifest = data.frame(
      BaseSeed = 451001L, DesignSeed = 451002L, Model = "RSM",
      TotalFacets = 3L, FACETSReturnCode = 0L,
      FACETSReportPresent = TRUE,
      FACETSReportedConvergenceScoreResidual = 0.01,
      FACETSReportedConvergenceLogitChange = 0.0001,
      FACETSConvergenceSpecificationPassed = TRUE,
      FACETSConvergenceAchieved = TRUE,
      FACETSFinalIteration = 18L,
      FACETSFinalElementScoreResidual = 0.005,
      FACETSFinalElementLogitChange = 0.00005,
      MfrmrFitReturned = TRUE, MfrmrConvergenceCode = 0L,
      MfrmrEstimationConverged = TRUE,
      MfrmrTerminalGradientSupNorm = 5e-5,
      MfrmrGradientReviewTolerance = 1e-4,
      MfrmrNumericalGatePassed = TRUE,
      CoordinateContractPassed = TRUE,
      StepCoordinateContractPassed = TRUE,
      ComparisonEligible = TRUE, Warnings = "", Error = NA_character_,
      stringsAsFactors = FALSE
    ),
    element_comparisons = add_identity(element_coordinates),
    step_comparisons = add_identity(step_coordinates),
    metrics = data.frame(Facet = c("Person", "Rater", "Criterion"))
  )

  result <- env$mfrmr_facets_mfx_normalize(
    raw, facets_exe, work_dir, 451001L, 3L, "RSM"
  )
  expect_identical(result$manifest$ExecutionStatus, "completed")
  expect_true(result$manifest$FACETSVersionMatched)
  expect_true(result$manifest$ComparisonEligible)
  expect_equal(nrow(result$element_coordinates), 48L)
  expect_equal(nrow(result$step_coordinates), 3L)
  expect_true(result$decision$ExternalProvenanceValidated)
  expect_false(result$decision$ConfirmationOutcomeOpened)
  expect_false(result$decision$FACETSReplacementClaimAuthorized)

  writeLines("Facets 4.5.1 synthetic parser fixture", file.path(
    case_dir, "report.txt"
  ))
  mismatch <- env$mfrmr_facets_mfx_normalize(
    raw, facets_exe, work_dir, 451001L, 3L, "RSM"
  )
  expect_identical(mismatch$manifest$ExecutionStatus, "parse_failure")
  expect_false(mismatch$manifest$ComparisonEligible)
  expect_equal(nrow(mismatch$element_coordinates), 0L)
  expect_equal(nrow(mismatch$step_coordinates), 0L)
  expect_false(mismatch$decision$ExternalProvenanceValidated)
})

test_that("pilot adapter contains no cryptographic file-identity operation", {
  path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "facets-multifacet-pilot-adapter-0.2.3.R"
  )
  source_text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_false(grepl("digest::|sha256|sha-256|md5sum", source_text,
                     ignore.case = TRUE))
})
