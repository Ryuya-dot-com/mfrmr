load_conquest_adversarial_simulation_tranche_a_live_execution <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  path <- file.path(
    root, "inst", "validation",
    "conquest-adversarial-simulation-tranche-a-live-execution-0.2.3.R"
  )
  skip_if_not(file.exists(path), "ConQuest ASP G4M file excluded.")
  pkgload::load_all(root, quiet = TRUE)
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env$mfrmr_cq_ag4m_source_contracts(root, env)
  list(
    root = root, path = path, env = env,
    smoke_output = file.path(
      root, "validation-results", env$mfrmr_cq_ase_output_basename
    ),
    g4x_output = file.path(
      root, "validation-results", env$mfrmr_cq_amea_output_basename
    ),
    calibration_output = file.path(
      root, "validation-results", env$mfrmr_cq_ataa_output_basename
    )
  )
}

test_that("G4M dry review has no execution side effect", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  skip_if(dir.exists(ctx$calibration_output), "G4M retained output exists.")
  before <- file.exists(ctx$calibration_output)
  review <- ctx$env$mfrmr_cq_ag4m_dry_run_review(
    ctx$g4x_output, ctx$calibration_output, ctx$smoke_output,
    run_date = as.Date("2026-08-16"), worktree_clean_attested = TRUE
  )

  expect_true(review$execution_ready)
  expect_true(review$g4l_review$all_thirty_two_fatal_gates_passed)
  expect_identical(nrow(review$g4l_review$gates), 32L)
  expect_false(review$positive_authorization_issued)
  expect_false(review$authorization_consumed)
  expect_false(review$sentinel_attempted)
  expect_false(review$responses_generated)
  expect_identical(review$fit_attempts, 0L)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$numeric_agreement_inspected)
  expect_identical(file.exists(ctx$calibration_output), before)
})

test_that("G4M positive path remains explicit opt-in", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  expect_error(
    ctx$env$mfrmr_cq_ag4m_execute(
      ctx$g4x_output, ctx$calibration_output, ctx$smoke_output
    ),
    "held without explicit run-once authorization"
  )
})

test_that("G4M scalar reductions retain detail and forbid promotion", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  registry <- ctx$env$mfrmr_cq_ag4m_scalar_reduction_registry()

  expect_identical(nrow(registry), 9L)
  expect_identical(anyDuplicated(registry$SummaryId), 0L)
  expect_true(all(nzchar(registry$RetainedCompanionDetail)))
  expect_false(any(registry$ThresholdApplied))
  expect_false(any(registry$ConfirmationUsePermitted))
  expect_false(any(registry$PublicClaimPermitted))
  expect_identical(
    registry$Measure[registry$SummaryId == "ASP-PARAMETER-BIAS"],
    "mean_signed_full_coordinate_error"
  )
  expect_identical(
    registry$Measure[registry$SummaryId == "ASP-PARAMETER-RMSE"],
    "full_coordinate_root_mean_square_error"
  )
})

test_that("G4M expands ConQuest free coordinates onto frozen full scales", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  regression <- data.frame(Estimate = c(0.5, -0.25))
  covariance <- data.frame(Covariance = 1.2)
  history <- data.frame(LogLikelihood = c(100, 90))
  facet <- data.frame(
    Label = c(
      "rater R1", "rater R2", "rater R3",
      "criterion C1", "criterion C2"
    ),
    Estimate = c(0.1, 0.2, -0.1, 0.3, -0.2),
    stringsAsFactors = FALSE
  )
  rsm <- rbind(
    facet,
    data.frame(
      Label = c("category 1", "category 2"),
      Estimate = c(0.4, -0.3), stringsAsFactors = FALSE
    )
  )
  pcm_step <- do.call(rbind, lapply(paste0("C", 1:3), function(criterion) {
    data.frame(
      Label = paste("criterion", criterion, "category", 1:2),
      Estimate = c(0.2, -0.1), stringsAsFactors = FALSE
    )
  }))
  pcm <- rbind(facet, pcm_step)

  rsm_value <- ctx$env$mfrmr_cq_ag4m_conquest_coordinates_from_tables(
    rsm, regression, covariance, history, "RSM"
  )
  pcm_value <- ctx$env$mfrmr_cq_ag4m_conquest_coordinates_from_tables(
    pcm, regression, covariance, history, "PCM"
  )

  expect_identical(
    names(rsm_value$coordinates),
    ctx$env$mfrmr_cq_ag4m_full_coordinate_names("RSM")
  )
  expect_identical(
    names(pcm_value$coordinates),
    ctx$env$mfrmr_cq_ag4m_full_coordinate_names("PCM")
  )
  expect_equal(sum(rsm_value$coordinates[paste0("Rater::R", 1:4)]), 0)
  expect_equal(sum(rsm_value$coordinates[paste0("Criterion::C", 1:3)]), 0)
  expect_equal(
    sum(rsm_value$coordinates[paste0("Step::Shared::S", 1:3)]), 0
  )
  for (criterion in paste0("C", 1:3)) {
    expect_equal(sum(pcm_value$coordinates[paste0(
      "Step::", criterion, "::S", 1:3
    )]), 0)
  }
  expect_identical(rsm_value$deviance, 90)
  expect_identical(pcm_value$deviance, 90)
})

test_that("fresh sentinel uses incomplete staging but binds absent final target", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  parent <- withr::local_tempdir()
  target <- ctx$env$mfrmr_cq_ag4m_absent_path(file.path(
    parent, ctx$env$mfrmr_cq_ataa_output_basename
  ))
  staging <- paste0(target, ".incomplete")
  expect_true(dir.create(staging))
  writeLines("quit;", file.path(staging, "runtime_sentinel.cqc"))
  original <- ctx$env$mfrmr_cq_ameh_fresh_sentinel
  on.exit(assign(
    "mfrmr_cq_ameh_fresh_sentinel", original, envir = ctx$env
  ), add = TRUE)
  assign(
    "mfrmr_cq_ameh_fresh_sentinel",
    function(root, executable_path, run_date, timeout = 30L) {
      expect_identical(root, normalizePath(staging, winslash = "/"))
      expect_identical(as.integer(timeout), 30L)
      writeLines("sentinel", file.path(root, "runtime_sentinel_console.log"))
      list(
        exact_runtime_ready = TRUE,
        summary = data.frame(
          RuntimeVersion = "5.47.5",
          RuntimeEdition = "Demonstration Version",
          ExpiryDate = as.Date("2026-09-01"),
          ModelEstimationAttempted = FALSE,
          ScientificComparisonAuthorized = FALSE,
          stringsAsFactors = FALSE
        )
      )
    },
    envir = ctx$env
  )

  token <- ctx$env$mfrmr_cq_ach_fresh_sentinel(
    staging, target, ctx$env$mfrmr_cq_acf_conquest_path,
    as.Date("2026-08-16"), timeout = 30L, authorize = TRUE
  )
  allocation <- ctx$env$mfrmr_cq_acf_seed_registry()
  allocation <- allocation[allocation$Tranche == "A", , drop = FALSE]
  expect_identical(
    token$OutputDir,
    normalizePath(target, winslash = "/", mustWork = FALSE)
  )
  expect_true(ctx$env$mfrmr_cq_ach_validate_fresh_sentinel_token(
    token, allocation$DatasetId[1L], allocation$Seed[1L], target
  ))
  expect_false(file.exists(target))
})

test_that("G4M source has assignments only at top level", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  expression <- parse(ctx$path)
  top_level_assignment <- vapply(expression, function(value) {
    is.call(value) && identical(value[[1L]], as.name("<-"))
  }, logical(1L))
  source <- paste(readLines(ctx$path, warn = FALSE), collapse = "\n")

  expect_true(all(top_level_assignment))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_false(grepl("ThresholdApplied\\s*=\\s*TRUE", source, perl = TRUE))
  expect_false(grepl(
    "(ConfirmationUsePermitted|PublicClaimPermitted)\\s*=\\s*TRUE",
    source, perl = TRUE
  ))
})

test_that("G4M preflight advances only the internal checklist", {
  ctx <- load_conquest_adversarial_simulation_tranche_a_live_execution()
  validation <- file.path(ctx$root, "inst", "validation")
  record <- paste(readLines(file.path(
    validation,
    paste0(
      "conquest-adversarial-simulation-tranche-a-live-execution-",
      "preflight-record-0.2.3.md"
    )
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ag4m_specification, fixed = TRUE)
  expect_match(record, "`PositiveAuthorizationIssued=FALSE`", fixed = TRUE)
  expect_match(record, "File-byte\\s+or digest equality")
  expect_match(
    roadmap,
    "[x] Freeze and adversarially test the G4M same-process runner",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] Open one G4M same-process execution session", fixed = TRUE
  )
})
