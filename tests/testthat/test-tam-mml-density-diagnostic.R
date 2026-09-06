load_tam_mml_density_diagnostic <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  .mfrmr_test_ensure_source_namespace(root)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "tam-mml-release-stress-0.2.4.R",
    "tam-mml-density-diagnostic-0.2.4.R"
  ))
  skip_if_not(all(file.exists(paths)), "TAM MML density diagnostic is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, env = env)
}

test_that("TAM MML density diagnostic reuses all 21 failed-run identities", {
  ctx <- load_tam_mml_density_diagnostic()
  frozen <- ctx$env$mfrmr_tms_plan()
  plan <- ctx$env$mfrmr_tmdd_plan()

  expect_identical(nrow(plan), 42L)
  expect_identical(length(unique(plan$DatasetId)), 21L)
  expect_identical(sort(unique(plan$Nodes)), c(121L, 181L))
  expect_identical(sort(unique(plan$DatasetId)), sort(unique(frozen$DatasetId)))
  expect_true(all(plan$EvidenceRole == "post_result_density_diagnostic_only"))
  expect_identical(anyDuplicated(plan$FitId), 0L)
})

test_that("TAM MML density record preserves the post-result denominator", {
  ctx <- load_tam_mml_density_diagnostic()
  validation <- file.path(ctx$root, "inst", "validation")
  summary_path <- file.path(
    validation, "tam-mml-density-diagnostic-summary-0.2.4.csv"
  )
  integration_path <- file.path(
    validation, "tam-mml-density-diagnostic-integration-0.2.4.csv"
  )
  record_path <- file.path(
    validation, "tam-mml-density-diagnostic-record-0.2.4.md"
  )
  skip_if_not(all(file.exists(c(summary_path, integration_path, record_path))))

  summary <- utils::read.csv(summary_path, stringsAsFactors = FALSE)
  integration <- utils::read.csv(integration_path, stringsAsFactors = FALSE)
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  source_hash <- digest::digest(
    file.path(validation, "tam-mml-density-diagnostic-0.2.4.R"),
    algo = "sha256", file = TRUE, serialize = FALSE
  )

  expect_identical(nrow(summary), 42L)
  expect_identical(sum(summary$PairPassed[summary$Nodes == 121L]), 15L)
  expect_identical(sum(summary$PairPassed[summary$Nodes == 181L]), 17L)
  expect_identical(nrow(integration), 21L)
  expect_true(all(integration$IntegrationPassed))
  expect_match(record, source_hash, fixed = TRUE)
  expect_match(record, "Release authorized.*FALSE", ignore.case = TRUE)
})
