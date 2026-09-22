load_conquest_p2_adaptive_density_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-p2-successor-integration-contract-0.2.3.R",
    "conquest-p2-adaptive-density-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "P2 adaptive density is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the adaptive ladder is finite and keeps thresholds unchanged", {
  ctx <- load_conquest_p2_adaptive_density_contract()
  review <- ctx$env$mfrmr_cq_p2ad_review()
  snapshot <- review$snapshots
  stage <- review$stages

  expect_identical(
    review$status,
    "bounded_adaptive_density_contract_frozen_truth_oracles_unopened"
  )
  expect_identical(snapshot$Nodes, c(31L, 61L, 121L, 241L))
  expect_true(all(snapshot$MustRetain))
  expect_identical(stage$LowerNodes, c(31L, 61L, 121L))
  expect_identical(stage$UpperNodes, c(61L, 121L, 241L))
  expect_false(stage$Governing[1L])
  expect_true(all(stage$Governing[2:3]))
  expect_true(all(stage$CoordinateTolerance[2:3] == 2e-6))
  expect_true(all(stage$DevianceTolerance[2:3] == 2e-6))
  expect_true(all(stage$UpperContinuousDevianceTolerance[2:3] == 1e-7))
  expect_false(any(stage$ThresholdChangeAuthorized))
  expect_identical(ctx$env$mfrmr_cq_p2ad_maximum_nodes, 241L)
  expect_false(review$candidate_004_generation_authorized)
  expect_false(review$further_node_expansion_authorized)
})

adaptive_density_metrics <- function(stage_1_pass = TRUE,
                                     stage_2_pass = TRUE) {
  arms <- c("RSM", "PCM")
  make <- function(lower, upper, pass) data.frame(
    ArmId = arms, LowerNodes = lower, UpperNodes = upper,
    CoordinateMovement = if (pass) c(1e-6, 1.5e-6) else c(3e-6, 1e-6),
    DevianceMovement = c(1e-6, 1.5e-6),
    UpperContinuousDevianceMovement = c(1e-8, 2e-8),
    Finite = TRUE, stringsAsFactors = FALSE
  )
  rbind(make(61L, 121L, stage_1_pass),
        make(121L, 241L, stage_2_pass))
}

test_that("the lowest whole-slice passing pair is selected", {
  ctx <- load_conquest_p2_adaptive_density_contract()
  select <- ctx$env$mfrmr_cq_p2ad_select_stage
  first <- select(adaptive_density_metrics(), c("RSM", "PCM"))
  second <- select(
    adaptive_density_metrics(stage_1_pass = FALSE), c("RSM", "PCM")
  )

  expect_identical(first$selected_stage, "dense_pair_1")
  expect_identical(first$selected_lower_nodes, 61L)
  expect_identical(first$selected_upper_nodes, 121L)
  expect_identical(second$selected_stage, "dense_pair_2")
  expect_identical(second$selected_lower_nodes, 121L)
  expect_identical(second$selected_upper_nodes, 241L)
  expect_false(first$further_expansion_authorized)
  expect_false(second$threshold_change_authorized)
})

test_that("missing arms and failure at the ceiling stop", {
  ctx <- load_conquest_p2_adaptive_density_contract()
  select <- ctx$env$mfrmr_cq_p2ad_select_stage
  failed <- select(
    adaptive_density_metrics(FALSE, FALSE), c("RSM", "PCM")
  )
  missing <- select(
    adaptive_density_metrics()[adaptive_density_metrics()$ArmId == "RSM", ],
    c("RSM", "PCM")
  )

  expect_identical(
    failed$status, "no_predeclared_dense_pair_passed_stop_at_q241"
  )
  expect_true(is.na(failed$selected_stage))
  expect_identical(failed$maximum_nodes, 241L)
  expect_false(failed$further_expansion_authorized)
  expect_false(any(missing$stage_review$CompleteDenominator))
  expect_true(is.na(missing$selected_stage))
})

test_that("the adaptive truth evaluator retains finite lower-grid semantics", {
  ctx <- load_conquest_p2_adaptive_density_contract()
  env <- ctx$env
  fixture <- env$mfrmr_cq_p2_fixture("P2-PCM-CONNECTED-MULTIBRIDGE")
  first <- env$mfrmr_cq_p2ad_fixed_loglikelihood(fixture, 61L)
  second <- env$mfrmr_cq_p2ad_fixed_loglikelihood(fixture, 61L)

  expect_identical(first, second)
  expect_identical(first$Persons, 48L)
  expect_true(is.finite(first$Deviance))
  expect_lte(first$QuadratureWeightSumDifference, 1e-13)
  expect_error(
    env$mfrmr_cq_p2ad_fixed_loglikelihood(fixture, 481L),
    "only q=31/61/121/241",
    fixed = TRUE
  )
})

test_that("the adaptive contract fits and launches nothing", {
  ctx <- load_conquest_p2_adaptive_density_contract()
  source <- paste(readLines(ctx$paths[6L], warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(", source, perl = TRUE))
  expect_false(grepl("readRDS\\s*\\(|read[.]csv\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
})

test_that("the record retains the consumed failed audit and candidate hold", {
  ctx <- load_conquest_p2_adaptive_density_contract()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-adaptive-density-contract-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2ad_specification, fixed = TRUE)
  expect_match(record, "Hard ceiling: q=241", fixed = TRUE)
  expect_match(record, "`TruthOracleAuditOpened=TRUE`", fixed = TRUE)
  expect_match(record, "`TruthOracleAuditPassed=FALSE`", fixed = TRUE)
  expect_match(record, "`FurtherNodeExpansionAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Freeze and test a bounded design-adaptive density ladder",
    fixed = TRUE
  )
})
