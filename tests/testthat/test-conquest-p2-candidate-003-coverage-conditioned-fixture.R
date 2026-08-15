load_conquest_p2_candidate_003_fixture <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R",
    "conquest-p2-candidate-003-coverage-conditioned-fixture-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest P2 candidate-003 fixture files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("candidate 003 is deterministic and does not contaminate RNG state", {
  ctx <- load_conquest_p2_candidate_003_fixture()
  env <- ctx$env
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  first <- env$mfrmr_cq_p2c3_fixture()
  second <- env$mfrmr_cq_p2c3_fixture()

  expect_identical(first$Seed, 2026081503L)
  expect_identical(first$MaximumCellDraws, 10000L)
  expect_identical(
    first$CandidateId,
    "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003"
  )
  expect_identical(first$Data, second$Data)
  expect_identical(first$Person, second$Person)
  expect_identical(first$Probability, second$Probability)
  expect_identical(first$Conditioning, second$Conditioning)
  expect_false(first$SeedSearchPerformed)
  expect_false(first$ResponseRepairPerformed)
  expect_false(first$PostGenerationCategoryEditing)
  expect_true(first$ProbabilityWeighted)
  expect_true(first$JointSamplingConditionedOnFullCellSupport)
  expect_false(first$TruthRecoveryAuthorized)
  if (had_seed) {
    expect_identical(get(".Random.seed", envir = .GlobalEnv), old_seed)
  } else {
    expect_false(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
  }
  expect_error(
    env$mfrmr_cq_p2c3_fixture(seed = 2026081504L),
    "single frozen seed",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_cq_p2c3_fixture(maximum_cell_draws = 9999L),
    "frozen cell-draw ceiling",
    fixed = TRUE
  )
})

test_that("coverage is conditional block sampling rather than response repair", {
  ctx <- load_conquest_p2_candidate_003_fixture()
  fixture <- ctx$env$mfrmr_cq_p2c3_fixture()
  conditioning <- fixture$Conditioning
  data <- fixture$Data

  expect_identical(dim(fixture$Probability), c(288L, 4L))
  expect_equal(rowSums(fixture$Probability), rep(1, 288), tolerance = 1e-14)
  expect_true(all(is.finite(fixture$Probability)))
  expect_true(all(fixture$Probability > 0))
  expect_identical(nrow(conditioning), 12L)
  expect_identical(conditioning$Persons, rep(24L, 12L))
  expect_true(all(conditioning$CoverageSatisfied))
  expect_true(all(conditioning$DrawAttempts >= 1L))
  expect_true(all(conditioning$DrawAttempts <= fixture$MaximumCellDraws))
  expect_identical(sum(conditioning$RejectedCompleteBlocks), 0L)
  expect_identical(
    rowSums(conditioning[, paste0("Category", 0:3)]),
    rep(24, 12L)
  )
  expect_identical(nrow(data), 288L)
  expect_identical(sort(unique(data$Response)), 0:3)
})

test_that("candidate 003 passes the unchanged thirteen candidate-002 gates", {
  ctx <- load_conquest_p2_candidate_003_fixture()
  env <- ctx$env
  review <- env$mfrmr_cq_p2c3_review()
  gates <- review$gate_results

  expect_identical(
    gates[, names(env$mfrmr_cq_p2r_gate_registry()), drop = FALSE],
    env$mfrmr_cq_p2r_gate_registry()
  )
  expect_identical(nrow(gates), 13L)
  expect_true(all(gates$Passed))
  expect_identical(
    review$status,
    "candidate_003_prefit_fixture_ready_mfrmr_preflight_only"
  )
  expect_true(review$frozen_candidate_002_gate_identity_retained)
  expect_true(review$coverage_conditioning_ready)
  expect_true(review$provenance_ready)
  expect_true(review$all_thirteen_prefit_gates_passed)
  expect_true(review$mfrmr_fit_preflight_authorized)
  expect_false(review$truth_recovery_authorized)
  expect_false(review$external_execution_authorized)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$wider_execution_authorized)
  expect_false(review$P3_execution_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("candidate 003 cannot fit, launch, delete, or substitute hashes", {
  ctx <- load_conquest_p2_candidate_003_fixture()
  source <- paste(readLines(ctx$paths[4L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5", source, ignore.case = TRUE))
})

test_that("the internal record fixes the narrow claim and next gate", {
  ctx <- load_conquest_p2_candidate_003_fixture()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-candidate-003-coverage-conditioned-fixture-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c3_specification, fixed = TRUE)
  expect_match(record, ctx$env$mfrmr_cq_p2c3_contract, fixed = TRUE)
  expect_match(record, "passed all 13 unchanged pre-fit gates", fixed = TRUE)
  expect_match(record, "changes the joint sampling law", fixed = TRUE)
  expect_match(record, "`TruthRecoveryAuthorized=FALSE`", fixed = TRUE)
  expect_match(record, "`ExternalExecutionAuthorized=FALSE`", fixed = TRUE)
  expect_match(
    roadmap,
    "[x] Give candidate 003 a prospectively defined support-guaranteeing",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Run a separate mfrmr-only candidate-003 preflight",
    fixed = TRUE
  )
})
