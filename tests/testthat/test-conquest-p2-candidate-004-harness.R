load_conquest_p2_candidate_004_harness <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-003-mfrmr-preflight-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-0.2.3.R",
    "conquest-p2-log-centered-continuous-oracle-observation-0.2.3.R",
    "conquest-p2-candidate-004-coverage-conditioned-fixture-0.2.3.R",
    "conquest-p2-candidate-004-fixture-observation-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-0.2.3.R",
    "conquest-p2-candidate-004-mfrmr-preflight-observation-0.2.3.R",
    "conquest-p2-candidate-004-live-authorization-0.2.3.R",
    "conquest-p2-candidate-004-harness-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 harness is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("harness contains exactly four q61/q121 run-once arms", {
  ctx <- load_conquest_p2_candidate_004_harness()
  plan <- ctx$env$mfrmr_cq_p2c4h_plan()
  native <- ctx$env$mfrmr_cq_p2c4h_native_output_registry(plan)

  expect_identical(nrow(plan), 4L)
  expect_identical(plan$Family, c("RSM", "RSM", "PCM", "PCM"))
  expect_identical(plan$Nodes, c(61L, 121L, 61L, 121L))
  expect_identical(plan$ExpectedFreeDimension, c(10L, 10L, 14L, 14L))
  expect_true(all(plan$RunOnce))
  expect_false(any(plan$NewMfrmrFitAuthorized))
  expect_identical(nrow(native), 32L)
  expect_identical(
    as.integer(table(native$RunId)), rep(8L, 4L)
  )
})

test_that("wide fixture preserves the candidate-004 sparse response layout", {
  ctx <- load_conquest_p2_candidate_004_harness()
  fixture <- ctx$env$mfrmr_cq_p2c4h_wide_fixture()
  response <- fixture$wide[, -(1:2), drop = FALSE]

  expect_identical(dim(fixture$wide), c(48L, 14L))
  expect_identical(nrow(fixture$long), 288L)
  expect_identical(sum(!is.na(response)), 288L)
  expect_identical(sum(is.na(response)), 288L)
  expect_identical(as.integer(rowSums(!is.na(response))), rep(6L, 48L))
  expect_identical(sort(unique(fixture$long$Response)), 0:3)
})

test_that("commands freeze model semantics and the selected dense pair", {
  ctx <- load_conquest_p2_candidate_004_harness()
  env <- ctx$env
  rsm <- env$mfrmr_cq_p2c4h_command("rsm_prefix", "RSM", 61L)
  pcm <- env$mfrmr_cq_p2c4h_command("pcm_prefix", "PCM", 121L)

  expect_true(any(grepl("model rater + criterion + step;", rsm, fixed = TRUE)))
  expect_true(any(grepl(
    "model rater + criterion + criterion*step;", pcm, fixed = TRUE
  )))
  expect_true(any(grepl("nodes=61", rsm, fixed = TRUE)))
  expect_true(any(grepl("nodes=121", pcm, fixed = TRUE)))
  expect_identical(tail(rsm, 1L), "quit;")
  expect_identical(tail(pcm, 1L), "quit;")
  expect_error(
    env$mfrmr_cq_p2c4h_command("bad", "RSM", 31L), "q61/q121", fixed = TRUE
  )
})

test_that("preparation creates and validates only the unopened bundle", {
  ctx <- load_conquest_p2_candidate_004_harness()
  env <- ctx$env
  root <- file.path(
    withr::local_tempdir(), env$mfrmr_cq_p2c4a_output_basename
  )
  prepared <- env$mfrmr_cq_p2c4h_prepare(
    root, authorization_date = as.Date("2026-08-15"), authorize = TRUE
  )

  expect_true(prepared$execution_ready)
  expect_true(prepared$exact_plan_ready)
  expect_true(prepared$output_root_identity_ready)
  expect_true(prepared$semantic_fixture_ready)
  expect_true(prepared$command_semantics_ready)
  expect_true(prepared$exact_preexecution_file_boundary)
  expect_true(prepared$all_candidate_outputs_absent)
  expect_false(prepared$execution_attempted)
  expect_error(
    env$mfrmr_cq_p2c4h_prepare(root, authorize = TRUE),
    "inactive or widened", fixed = TRUE
  )
})

test_that("execution is explicit and cannot run in ordinary tests", {
  ctx <- load_conquest_p2_candidate_004_harness()
  env <- ctx$env
  expect_error(
    env$mfrmr_cq_p2c4h_execute("missing", authorize = FALSE),
    "Execution is held", fixed = TRUE
  )
  source <- paste(readLines(tail(ctx$paths, 1L), warn = FALSE), collapse = "\n")
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("record and roadmap keep execution unopened", {
  ctx <- load_conquest_p2_candidate_004_harness()
  record_path <- file.path(
    ctx$validation, "conquest-p2-candidate-004-harness-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4h_specification, fixed = TRUE)
  expect_match(record, "`ExecutionOpened=FALSE`", fixed = TRUE)
  expect_match(record, "status zero alone cannot pass", ignore.case = TRUE)
  expect_match(
    roadmap,
    "candidate-004 run-once harness is frozen",
    fixed = TRUE
  )
})
