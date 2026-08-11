v4_confirmation_auth_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v4-confirmation-authorization-0.2.3.R"
)
v4_confirmation_auth_env <- new.env(parent = globalenv())
sys.source(v4_confirmation_auth_path, envir = v4_confirmation_auth_env)

test_that("v4 confirmation authorization defaults to no-fit NO-GO", {
  decision <- v4_confirmation_auth_env$mfrmr_gsv4qa_decide()
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$IssuedNotExecuted)
  expect_false(decision$ExplicitRequest)
  expect_false(decision$FreshProcessAttested)
  expect_false(decision$InputPathAbsolute)
  expect_false(decision$FitOpened)
  expect_false(decision$ResultOpened)
})

test_that("v4 confirmation authorization blocks an evolved package payload", {
  target <- tempfile(fileext = ".rds")
  decision <- v4_confirmation_auth_env$mfrmr_gsv4qa_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$IssuedNotExecuted)
  expect_false(decision$ExactPayload)
  expect_false(decision$ExactIdentity)
  expect_false(decision$ExactManifest)
  expect_true(all(decision[c(
    "ExactRunner", "ExactDesign", "ExactFreeze", "ExactRule",
    "ExactReplayRunner",
    "ExactValidator", "CompleteDesign", "DisjointConfirmation",
    "DevelopmentSource",
    "FreshProcessAttested", "ExplicitRequest", "InputPathAbsolute",
    "OutputParentExists", "OutputTargetAbsent"
  )]))
  expect_match(decision$AuthorizationSourceSHA256, "^[0-9a-f]{64}$")
  expect_match(decision$ValidatorSHA256, "^[0-9a-f]{64}$")
  expect_match(decision$AuthorizationSHA256, "^[0-9a-f]{64}$")
  expect_true(is.na(decision$ConsumedAtUTC))
  expect_true(is.na(decision$ConsumedRowSHA256))
  expect_false(decision$FitOpened)
  expect_false(decision$ResultOpened)
  expect_false(file.exists(target))
})

test_that("v4 confirmation authorization refuses relative and occupied targets", {
  relative <- v4_confirmation_auth_env$mfrmr_gsv4qa_decide(
    output_path = "relative-confirmation.rds", request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(relative$Status, "no_go_not_issued")
  expect_false(relative$InputPathAbsolute)
  expect_false(relative$ExecutionAuthorized)

  target <- tempfile(fileext = ".rds")
  writeLines("occupied", target)
  occupied <- v4_confirmation_auth_env$mfrmr_gsv4qa_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(occupied$Status, "no_go_not_issued")
  expect_false(occupied$OutputTargetAbsent)
  expect_false(occupied$ExecutionAuthorized)
})

test_that("runner rejects an absolute row after payload drift", {
  target <- tempfile(fileext = ".rds")
  authorization <- v4_confirmation_auth_env$mfrmr_gsv4qa_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  runner <- v4_confirmation_auth_env$mfrmr_gsv4qa_load_runner()
  dry <- runner$mfrmr_run_gpcm_score_v4_confirmation(progress = FALSE)
  expect_error(
    runner$mfrmr_gsv4q_validate_authorization(
      authorization, dry$identity, dry$manifest, target
    ),
    "absent, stale, mismatched, consumed, or occupied", fixed = TRUE
  )
  expect_false(file.exists(target))
})
