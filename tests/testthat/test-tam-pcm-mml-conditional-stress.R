load_tam_pcm_mml_conditional_stress <- function() {
  skip_if_not_installed("TAM")
  skip_if_not_installed("digest")
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  .mfrmr_test_ensure_source_namespace(root)
  path <- file.path(
    root, "inst", "validation", "tam-pcm-mml-conditional-stress-0.2.4.R"
  )
  skip_if_not(file.exists(path), "TAM PCM conditional stress is excluded.")
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  list(root = root, env = env, core = env$mfrmr_tpcm_load_core(root))
}

test_that("TAM PCM conditional stress freezes 60 fixed-basis comparisons", {
  ctx <- load_tam_pcm_mml_conditional_stress()
  plan <- ctx$env$mfrmr_tpcm_plan(ctx$core)

  expect_identical(nrow(plan), 60L)
  expect_identical(length(unique(plan$DatasetId)), 15L)
  expect_identical(sort(unique(plan$Nodes)), c(31L, 61L, 121L, 181L))
  expect_identical(unique(plan$Model), "PCM")
  expect_identical(unique(plan$PopulationMode), "fixed_standard_normal")
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

test_that("TAM PCM preparation retains full category support", {
  ctx <- load_tam_pcm_mml_conditional_stress()
  ctx$env$mfrmr_tpcm_install_core(ctx$core)
  plan <- ctx$env$mfrmr_tpcm_plan(ctx$core)
  row <- plan[
    plan$ProfileId == "SPARSE_RATER" & plan$Replicate == 1L &
      plan$Nodes == 31L,
    , drop = FALSE
  ]
  data <- ctx$core$mfrmr_tms_generate(row)
  prepared <- ctx$core$mfrmr_tms_prepare_tam(data)

  expect_identical(nrow(data), 960L)
  expect_identical(dim(prepared$resp), c(84L, 30L))
  expect_identical(dim(prepared$A)[1:2], c(30L, 4L))
  expect_true(anyNA(prepared$resp))
  expect_identical(prepared$pweights, c(rep(1, 80L), rep(0, 4L)))
  expect_equal(prepared$deviance_scale, 80 / 84)
})

test_that("TAM PCM conditional stress executes one matched fit", {
  ctx <- load_tam_pcm_mml_conditional_stress()
  ctx$env$mfrmr_tpcm_install_core(ctx$core)
  plan <- ctx$env$mfrmr_tpcm_plan(ctx$core)
  row <- plan[
    plan$ProfileId == "WEAK_EXPOSURE" & plan$Replicate == 1L &
      plan$Nodes == 31L,
    , drop = FALSE
  ]
  data <- ctx$core$mfrmr_tms_generate(row)
  prepared <- ctx$core$mfrmr_tms_prepare_tam(data)
  result <- ctx$core$mfrmr_tms_compare_one(row, data, prepared)

  expect_identical(result$summary$Error, "")
  expect_true(is.finite(result$summary$MfrmrDeviance))
  expect_identical(nrow(result$surface), 90L)
  expect_identical(nrow(result$scores), 80L)
})

test_that("TAM PCM conditional-stress record retains the full denominator", {
  ctx <- load_tam_pcm_mml_conditional_stress()
  validation <- file.path(ctx$root, "inst", "validation")
  summary_path <- file.path(
    validation, "tam-pcm-mml-conditional-stress-summary-0.2.4.csv"
  )
  integration_path <- file.path(
    validation, "tam-pcm-mml-conditional-stress-integration-0.2.4.csv"
  )
  record_path <- file.path(
    validation, "tam-pcm-mml-conditional-stress-record-0.2.4.md"
  )
  skip_if_not(all(file.exists(c(summary_path, integration_path, record_path))))

  summary <- utils::read.csv(summary_path, stringsAsFactors = FALSE)
  integration <- utils::read.csv(integration_path, stringsAsFactors = FALSE)
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  source_hash <- digest::digest(
    file.path(validation, "tam-pcm-mml-conditional-stress-0.2.4.R"),
    algo = "sha256", file = TRUE, serialize = FALSE
  )

  expect_identical(nrow(summary), 60L)
  expect_identical(
    as.integer(tapply(summary$PairPassed, summary$Nodes, sum)),
    c(3L, 6L, 10L, 15L)
  )
  expect_true(all(is.na(summary$Error) | summary$Error == ""))
  expect_identical(nrow(integration), 45L)
  expect_identical(
    as.integer(tapply(
      integration$IntegrationPassed, integration$HighNodes, sum
    )),
    c(3L, 6L, 15L)
  )
  expect_match(record, source_hash, fixed = TRUE)
  expect_match(record, "ConditionalStressComplete.*FALSE", ignore.case = TRUE)
  expect_match(record, "ReleaseAuthorized.*FALSE", ignore.case = TRUE)
})
