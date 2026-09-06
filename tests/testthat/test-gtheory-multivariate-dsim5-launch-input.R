load_gtheory_dsim5i <- local({
  value <- NULL
  function() {
    if (is.null(value)) {
      root <- testthat::test_path("..", "..")
      source <- file.path(
        root, "inst", "validation",
        "gtheory-multivariate-dsim5-launch-input-0.2.4.R"
      )
      parent <- file.path(
        root, "validation-results",
        "gtheory-multivariate-dsim4-worker-qualification-0.2.4",
        "worker-qualification-manifest.rds"
      )
      skip_if_not(all(file.exists(c(source, parent))),
                  "repository-internal D-SIM-5 launch input excluded")
      skip_if_not_installed("digest")
      environment <- new.env(parent = globalenv())
      sys.source(source, envir = environment)
      value <<- list(
        Environment = environment,
        Input = environment$mfrmr_gtds5i_launch_input(readRDS(parent))
      )
    }
    value
  }
})

test_that("D-SIM-5 launch input partitions the frozen denominator exactly", {
  loaded <- load_gtheory_dsim5i()
  input <- loaded$Input
  summary <- input$Summary

  expect_invisible(loaded$Environment$mfrmr_gtds5i_assert_launch_input(input))
  expect_identical(
    input$Contract$ContractHash,
    "74716dd0fbba6ac2ceb93c225818a5b7c0e0dd33ab9a0c7440619b4e34a70cf2"
  )
  expect_identical(
    input$LaunchInputHash,
    "e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071"
  )
  expect_identical(
    unname(unlist(summary[c(
      "ShardCount", "ScenarioCount", "OuterRequestCount",
      "IntervalOuterRequestCount", "InnerAttemptCount",
      "ExpectedBackendFitCallCount"
    )])),
    c(50L, 6L, 15000L, 5000L, 995000L, 2022500L)
  )
  expect_true(all(input$ShardRegistry$OuterRequestCount == 300L))
  expect_true(all(
    input$ShardRegistry$ExpectedBackendFitCallCount == 40450L
  ))
})

test_that("D-SIM-5 launch input keeps attempts atomic and execution closed", {
  loaded <- load_gtheory_dsim5i()
  input <- loaded$Input
  assignments <- input$AssignmentRegistry

  expect_false(anyDuplicated(assignments$AttemptId) > 0L)
  expect_identical(sum(!is.na(assignments$InnerBlockHash)), 5000L)
  expect_true(input$Summary$OuterAttemptAtomic)
  expect_true(input$Summary$BootstrapBlockAtomic)
  expect_true(input$Summary$AllScenariosPresentPerShard)
  expect_false(any(assignments$RngStreamOpened))
  expect_false(any(assignments$ExecutionAuthorized))
  expect_false(input$Summary$Dsim5ExecutionAuthorized)

  changed <- input
  changed$AssignmentRegistry$ExecutionAuthorized[[1L]] <- TRUE
  expect_error(
    loaded$Environment$mfrmr_gtds5i_assert_launch_input(changed),
    "launch input was altered"
  )
})
