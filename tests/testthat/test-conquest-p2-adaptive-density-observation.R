load_conquest_p2_adaptive_density_observation <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-adaptive-density-observation-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 adaptive observation is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("finite-grid convergence passes all thirteen rows", {
  ctx <- load_conquest_p2_adaptive_density_observation()
  review <- ctx$env$mfrmr_cq_p2ado_review()
  audit <- review$audit

  expect_identical(nrow(audit), 13L)
  expect_true(all(audit$Finite))
  expect_true(all(audit$Q121Q241Passed))
  expect_lt(max(audit$Q121Q241DevianceMovement), 1e-10)
  expect_true(review$finite_grid_convergence_passed_all_rows)
  expect_identical(
    review$status, "q241_ceiling_reached_continuous_reference_unresolved"
  )
})

test_that("only unequal workload retains continuous-reference failure", {
  ctx <- load_conquest_p2_adaptive_density_observation()
  review <- ctx$env$mfrmr_cq_p2ado_review()

  expect_identical(
    review$continuous_reference_failed_registry_rows,
    c("P2-RSM-UNEQUAL-WORKLOAD", "P2-PCM-UNEQUAL-WORKLOAD")
  )
  expect_identical(sum(review$audit$Q241LegacyContinuousPassed), 11L)
  expect_true(review$q241_ceiling_consumed)
  expect_false(review$further_node_expansion_authorized)
  expect_false(review$fixed_threshold_change_authorized)
  expect_false(review$legacy_continuous_oracle_qualified)
  expect_true(review$log_centered_continuous_oracle_qualification_required)
  expect_false(review$candidate_004_generation_authorized)
  expect_false(review$external_execution_authorized)
})

test_that("the observation cannot evaluate, fit, read, or launch", {
  ctx <- load_conquest_p2_adaptive_density_observation()
  source <- paste(readLines(ctx$paths[7L], warn = FALSE), collapse = "\n")

  expect_false(grepl("fixed_loglikelihood\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap stop q expansion before oracle qualification", {
  ctx <- load_conquest_p2_adaptive_density_observation()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-adaptive-density-observation-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2ado_specification, fixed = TRUE)
  expect_match(record, "`FurtherNodeExpansionAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "which numerical", fixed = TRUE)
  expect_match(record, "reference is wrong", fixed = TRUE)
  expect_match(
    roadmap,
    "[ ] Qualify a log-centered continuous P2 oracle",
    fixed = TRUE
  )
})
