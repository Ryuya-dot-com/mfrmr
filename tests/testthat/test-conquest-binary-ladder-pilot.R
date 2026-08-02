conquest_binary_ladder_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_conquest_binary_ladder_pilot <- function() {
  validation_dir <- conquest_binary_ladder_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only ConQuest ladder validation files are unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir, "conquest-binary-ladder-pilot-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

test_that("the ConQuest binary ladder is prespecified and never auto-executes", {
  loaded <- load_conquest_binary_ladder_pilot()
  env <- loaded$env
  plan <- env$mfrmr_cq_binary_ladder_plan()

  expect_identical(env$mfrmr_cq_binary_ladder_specification, "0.2.3-draft.9")
  expect_identical(
    env$mfrmr_cq_binary_ladder_contract,
    "mfrmr_conquest_binary_ladder_v1"
  )
  expect_identical(
    plan$RunId,
    c("q007", "q015", "q031a", "q061", "q091", "q121", "q031b")
  )
  expect_identical(plan$Nodes, c(7L, 15L, 31L, 61L, 91L, 121L, 31L))
  expect_identical(plan$Nodes[plan$CoreCandidate], c(31L, 61L, 91L, 121L))
  expect_true(all(!plan$ConfirmationAuthorized))
  expect_identical(
    plan$ReplicateGroup[plan$RunId %in% c("q031a", "q031b")],
    c("q31", "q31")
  )

  script_lines <- readLines(loaded$script, warn = FALSE)
  executable_calls <- grep(
    "system2\\s*\\(|/Applications/ConQuest|ConQuestCMD",
    script_lines,
    perl = TRUE,
    value = TRUE
  )
  expect_length(executable_calls, 0L)

  occupied <- file.path(tempdir(), "occupied-conquest-ladder")
  dir.create(occupied, recursive = TRUE, showWarnings = FALSE)
  marker <- file.path(occupied, "marker.txt")
  writeLines("do not overwrite", marker)
  expect_error(
    env$mfrmr_prepare_conquest_binary_ladder(occupied),
    "absent or empty",
    fixed = TRUE
  )
  expect_identical(readLines(marker, warn = FALSE), "do not overwrite")

  empty <- file.path(tempdir(), "empty-conquest-ladder-review")
  dir.create(empty, recursive = TRUE, showWarnings = FALSE)
  expect_error(
    env$mfrmr_review_conquest_binary_ladder(empty),
    "manifest is missing",
    fixed = TRUE
  )
})

test_that("the ConQuest binary ladder summary remains pilot-only", {
  env <- load_conquest_binary_ladder_pilot()$env
  plan <- env$mfrmr_cq_binary_ladder_plan()
  core_deviance <- c(
    NA_real_, NA_real_,
    424.738979, 424.738979, 424.738979, 424.738979,
    424.738979
  )
  mfrmr_deviance <- c(
    424.7391725425, 424.7389793664,
    424.738979414154, 424.738979414154,
    424.738979414155, 424.738979414155,
    424.738979414154
  )
  results <- data.frame(
    RunId = plan$RunId,
    Nodes = plan$Nodes,
    CoreCandidate = plan$CoreCandidate,
    AdapterStatus = c(
      "rejected", "rejected", rep("accepted_arithmetic", 5L)
    ),
    ConQuestDeviance = core_deviance,
    MfrmrDeviance = mfrmr_deviance,
    CrossEngineDevianceDifference = core_deviance - mfrmr_deviance,
    MaxTransformedParameterAbsDifference = c(
      NA_real_, NA_real_, rep(5.761704441e-6, 5L)
    ),
    NativeOutputFingerprint = c(
      "q7", "q15", "q31-repeat", "q61", "q91", "q121", "q31-repeat"
    ),
    ComparisonReady = FALSE,
    stringsAsFactors = FALSE
  )

  summary <- env$mfrmr_cq_binary_ladder_summarize(results)
  expect_identical(summary$Status, "review")
  expect_identical(summary$CoreDistinctNodes, 4L)
  expect_true(summary$CoreArithmeticAccepted)
  expect_equal(summary$CoreConQuestDevianceRange, 0, tolerance = 0)
  expect_lt(summary$CoreMfrmrDevianceRange, 2e-12)
  expect_lt(summary$CoreMaxAbsCrossEngineDevianceDifference, 5e-7)
  expect_equal(
    summary$CoreMaxTransformedParameterAbsDifference,
    5.761704441e-6,
    tolerance = 0
  )
  expect_true(summary$Q31ReplicationByteIdentical)
  expect_true(summary$Q31ReplicationDevianceIdentical)
  expect_true(summary$Q7Rejected)
  expect_true(summary$Q15Rejected)
  expect_false(summary$AnyComparisonReady)
  expect_identical(summary$IntegrationStabilityStatus, "review")
  expect_identical(summary$FreezeCriterionStatus, "pilot_required")
  expect_false(summary$SelectionAuthorized)
  expect_false(summary$ConfirmationAuthorized)

  mismatched_repeat <- results
  mismatched_repeat$NativeOutputFingerprint[
    mismatched_repeat$RunId == "q031b"
  ] <- "different"
  expect_false(
    env$mfrmr_cq_binary_ladder_summarize(
      mismatched_repeat
    )$Q31ReplicationByteIdentical
  )

  rejected_core <- results
  rejected_core$AdapterStatus[rejected_core$RunId == "q061"] <- "rejected"
  expect_false(
    env$mfrmr_cq_binary_ladder_summarize(
      rejected_core
    )$CoreArithmeticAccepted
  )

  expect_error(
    env$mfrmr_cq_binary_ladder_summarize(results[, "RunId", drop = FALSE]),
    "summary contract",
    fixed = TRUE
  )
})
