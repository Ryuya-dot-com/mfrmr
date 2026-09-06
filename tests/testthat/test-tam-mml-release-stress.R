load_tam_mml_release_stress <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  .mfrmr_test_ensure_source_namespace(root)
  path <- file.path(
    root, "inst", "validation", "tam-mml-release-stress-0.2.4.R"
  )
  skip_if_not(file.exists(path), "TAM MML release stress is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  list(root = root, env = env)
}

test_that("TAM MML release stress freezes a bounded 42-pair denominator", {
  ctx <- load_tam_mml_release_stress()
  plan <- ctx$env$mfrmr_tms_plan()

  expect_identical(nrow(plan), 42L)
  expect_identical(length(unique(plan$DatasetId)), 21L)
  expect_identical(sort(unique(plan$Nodes)), c(31L, 61L))
  expect_identical(
    as.integer(table(plan$PopulationMode)["fixed_standard_normal"]), 30L
  )
  expect_identical(
    as.integer(table(plan$PopulationMode)["estimated_intercept_only"]), 12L
  )
  expect_identical(
    sort(unique(plan$ProfileId)),
    sort(c(
      "BASELINE", "SPARSE_RATER", "MCAR_20", "EXTREME_10", "WEAK_EXPOSURE"
    ))
  )
  expect_true(all(plan$PairTolerance == 1e-4))
  expect_true(all(plan$IntegrationTolerance == 1e-3))
  expect_identical(anyDuplicated(plan$FitId), 0L)
})

test_that("TAM MML release stress binds runtime and three overlap layers", {
  ctx <- load_tam_mml_release_stress()
  runtime <- ctx$env$mfrmr_tms_runtime_identity(ctx$root)
  overlap <- ctx$env$mfrmr_tms_overlap_contract()

  expect_true(all(runtime$IdentityMatch))
  expect_identical(runtime$Version[runtime$Engine == "TAM"], rep("4.3.25", 2L))
  expect_identical(
    overlap$Layer, c("MeasurementSpec", "EstimationSpec", "ScoringSpec")
  )
  expect_match(overlap$Matched[1L], "unidimensional RSM", fixed = TRUE)
  expect_false(any(grepl("multidimensional", overlap$Matched, fixed = TRUE)))
})

test_that("TAM MML release-stress generators realize frozen perturbations", {
  ctx <- load_tam_mml_release_stress()
  plan <- ctx$env$mfrmr_tms_plan()
  plan <- plan[
    plan$PopulationMode == "fixed_standard_normal" &
      plan$Replicate == 1L & plan$Nodes == 31L,
    , drop = FALSE
  ]
  generated <- lapply(seq_len(nrow(plan)), function(index) {
    ctx$env$mfrmr_tms_generate(plan[index, , drop = FALSE])
  })
  names(generated) <- plan$ProfileId

  expect_identical(nrow(generated$BASELINE), 2400L)
  expect_identical(nrow(generated$SPARSE_RATER), 960L)
  expect_identical(nrow(generated$MCAR_20), 1920L)
  expect_identical(nrow(generated$WEAK_EXPOSURE), 480L)
  extreme <- split(generated$EXTREME_10$Score, generated$EXTREME_10$Person)
  expect_identical(sum(vapply(extreme, function(x) length(unique(x)) == 1L,
                               logical(1L))), 8L)

  sparse <- ctx$env$mfrmr_tms_prepare_tam(generated$SPARSE_RATER)
  expect_identical(dim(sparse$resp), c(84L, 30L))
  expect_identical(dim(sparse$A)[1:2], c(30L, 4L))
  expect_true(anyNA(sparse$resp))
  expect_identical(sparse$pweights, c(rep(1, 80L), rep(0, 4L)))
  expect_equal(sparse$deviance_scale, 80 / 84)
})

test_that("TAM MML release-stress record retains the failed full denominator", {
  ctx <- load_tam_mml_release_stress()
  validation <- file.path(ctx$root, "inst", "validation")
  summary_path <- file.path(
    validation, "tam-mml-release-stress-summary-0.2.4.csv"
  )
  integration_path <- file.path(
    validation, "tam-mml-release-stress-integration-0.2.4.csv"
  )
  record_path <- file.path(
    validation, "tam-mml-release-stress-record-0.2.4.md"
  )
  skip_if_not(all(file.exists(c(summary_path, integration_path, record_path))))

  summary <- utils::read.csv(summary_path, stringsAsFactors = FALSE)
  integration <- utils::read.csv(integration_path, stringsAsFactors = FALSE)
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  source_hash <- digest::digest(
    file.path(validation, "tam-mml-release-stress-0.2.4.R"),
    algo = "sha256", file = TRUE, serialize = FALSE
  )

  expect_identical(nrow(summary), 42L)
  expect_identical(sum(summary$PairPassed), 12L)
  expect_false(any(!is.na(summary$Error) & nzchar(summary$Error)))
  expect_identical(nrow(integration), 21L)
  expect_identical(sum(integration$IntegrationPassed), 6L)
  expect_match(record, source_hash, fixed = TRUE)
  expect_match(record, "ReleaseStressComplete=FALSE", fixed = TRUE)
  expect_match(record, "ReleaseAuthorized=FALSE", fixed = TRUE)
})
