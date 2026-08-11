confirmation_auth_path <- testthat::test_path(
  "..", "..", "inst", "validation",
  "gpcm-score-v3-confirmation-authorization-0.2.3.R"
)
confirmation_auth_env <- new.env(parent = globalenv())
sys.source(confirmation_auth_path, envir = confirmation_auth_env)

test_that("confirmation authorization defaults to NO-GO", {
  decision <- confirmation_auth_env$mfrmr_gsv3a_decide()
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$ExplicitRequest)
  expect_false(decision$FreshProcessAttested)
  expect_false(decision$ConfirmationResultOpened)
  expect_false(decision$GeneralNUMSCORETOLFrozen)
})

test_that("confirmation authorization fails closed after payload drift", {
  target <- tempfile(fileext = ".rds")
  decision <- confirmation_auth_env$mfrmr_gsv3a_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$ExecutionAuthorized)
  expect_false(decision$IssuedNotExecuted)
  expect_false(decision$ExactPayload)
  expect_true(all(decision[c(
    "ExactRunner", "ExactDesign", "ExactFreeze",
    "ExactManifest", "CompleteDesign", "DevelopmentSource",
    "FreshProcessAttested", "ExplicitRequest", "OutputParentExists",
    "OutputTargetAbsent"
  )]))
  expect_false(file.exists(target))
})

test_that("confirmation authorization refuses occupied output", {
  target <- tempfile(fileext = ".rds")
  writeLines("occupied", target)
  decision <- confirmation_auth_env$mfrmr_gsv3a_decide(
    output_path = target, request_execution = TRUE,
    fresh_process_attested = TRUE
  )
  expect_identical(decision$Status, "no_go_not_issued")
  expect_false(decision$OutputTargetAbsent)
  expect_false(decision$ExecutionAuthorized)
})
