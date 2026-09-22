v4_confirmation_validator_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-confirmation-validator-0.2.3.R"
)
v4_confirmation_validator_env <- new.env(parent = globalenv())
sys.source(v4_confirmation_validator_path, envir = v4_confirmation_validator_env)

test_that("v4 confirmation validator closes the prespecified denominators", {
  counts <- v4_confirmation_validator_env$mfrmr_gsv4qv_expected_counts()
  jacobian <- v4_confirmation_validator_env$mfrmr_gsv4qv_expected_jacobian()
  expect_equal(nrow(counts), 96L)
  expect_identical(sum(counts$ExpectedCount), 888L)
  expect_equal(nrow(jacobian), 24L)
  expect_identical(sum(jacobian$ExpectedCount), 688L)
  expect_identical(anyDuplicated(counts[c(
    "ScenarioId", "Point", "ParameterClass"
  )]), 0L)
  expect_identical(anyDuplicated(jacobian[c("ScenarioId", "Point")]), 0L)
})

test_that("v4 confirmation validator pins sources without sourcing runner", {
  expect_invisible(
    v4_confirmation_validator_env$mfrmr_gsv4qv_validate_sources()
  )
  text <- paste(readLines(v4_confirmation_validator_path, warn = FALSE),
                collapse = "\n")
  expect_false(grepl("sys.source", text, fixed = TRUE))
  expect_false(grepl("mfrmr_run_gpcm_score_v4_confirmation(",
                     text, fixed = TRUE))
})

test_that("v4 confirmation validator refuses absent and incomplete results", {
  absent <- tempfile(fileext = ".rds")
  expect_error(
    v4_confirmation_validator_env$mfrmr_validate_gpcm_score_v4_confirmation(
      absent
    ),
    "artifact is absent", fixed = TRUE
  )
  target <- tempfile(fileext = ".rds")
  saveRDS(list(identity = data.frame()), target)
  expect_error(
    v4_confirmation_validator_env$mfrmr_validate_gpcm_score_v4_confirmation(
      target
    ),
    "schema is incomplete", fixed = TRUE
  )
})

test_that("v4 confirmation validator rejects a row after payload drift", {
  auth_env <- new.env(parent = globalenv())
  sys.source(testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-score-v4-confirmation-authorization-0.2.3.R"
  ), envir = auth_env)
  target <- tempfile(fileext = ".rds")
  authorization <- auth_env$mfrmr_gsv4qa_decide(
    target, request_execution = TRUE, fresh_process_attested = TRUE
  )
  runner <- auth_env$mfrmr_gsv4qa_load_runner()
  dry <- runner$mfrmr_run_gpcm_score_v4_confirmation(progress = FALSE)
  saveRDS(NULL, target)
  expect_error(
    v4_confirmation_validator_env$mfrmr_gsv4qv_validate_authorization(
      authorization, dry$identity, dry$manifest, target
    ),
    "authorization cannot be verified", fixed = TRUE
  )
})
