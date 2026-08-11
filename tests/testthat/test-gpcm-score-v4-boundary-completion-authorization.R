v4_completion_auth_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-boundary-completion-authorization-0.2.3.R"
)
v4_completion_auth_env <- new.env(parent = globalenv())
sys.source(v4_completion_auth_path, envir = v4_completion_auth_env)

test_that("v4 completion authorization defaults to no-fit NO-GO", {
  decision <- v4_completion_auth_env$mfrmr_gsv4a_decide()
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$IssuedNotExecuted)
  expect_false(decision$ExplicitRequest)
  expect_false(decision$FreshProcessAttested)
  expect_false(decision$FitOpened)
  expect_false(decision$ConfirmationAuthorized)
})

test_that("v4 completion authorization blocks an evolved package payload", {
  target <- tempfile(fileext = ".rds")
  decision <- v4_completion_auth_env$mfrmr_gsv4a_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$IssuedNotExecuted)
  expect_false(decision$ExactPayload)
  expect_true(all(decision[c(
    "ExactRunner", "ExactDesign", "ExactRule", "ExactRetrospective",
    "ExactReplayRunner", "ExactManifest",
    "CompleteDesign", "CalibrationOnly", "DevelopmentSource",
    "FreshProcessAttested", "ExplicitRequest", "OutputParentExists",
    "OutputTargetAbsent"
  )]))
  expect_match(decision$AuthorizationSourceSHA256, "^[0-9a-f]{64}$")
  expect_match(decision$AuthorizationSHA256, "^[0-9a-f]{64}$")
  expect_true(is.na(decision$ConsumedAtUTC))
  expect_true(is.na(decision$ConsumedRowSHA256))
  expect_false(decision$FitOpened)
  expect_false(file.exists(target))
})

test_that("v4 completion authorization refuses an occupied target", {
  target <- tempfile(fileext = ".rds")
  writeLines("occupied", target)
  decision <- v4_completion_auth_env$mfrmr_gsv4a_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$OutputTargetAbsent)
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$FitOpened)
})

test_that("runner rejects a target-bound row after payload drift", {
  target <- tempfile(fileext = ".rds")
  authorization <- v4_completion_auth_env$mfrmr_gsv4a_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  runner <- v4_completion_auth_env$mfrmr_gsv4a_load_runner()
  dry <- runner$mfrmr_run_gpcm_score_v4_boundary_completion(progress = FALSE)
  expect_error(
    runner$mfrmr_gsv4x_validate_authorization(
      authorization, dry$identity, dry$manifest, target
    ),
    "absent, stale, mismatched, consumed, or occupied",
    fixed = TRUE
  )
  expect_false(file.exists(target))
})
