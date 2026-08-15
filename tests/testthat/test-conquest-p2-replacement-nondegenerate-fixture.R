load_conquest_p2_replacement_fixture <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-p2-replacement-nondegenerate-fixture-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest P2 replacement fixture files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the replacement is one deterministic no-search candidate", {
  ctx <- load_conquest_p2_replacement_fixture()
  env <- ctx$env
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  first <- env$mfrmr_cq_p2r_fixture()
  second <- env$mfrmr_cq_p2r_fixture()

  expect_identical(first$Seed, 2026081502L)
  expect_identical(first$CandidateId,
                   "mfrmr-0.2.3-conquest-p2-minimum-diagnostic-002")
  expect_identical(first$GeneratingFamily, "PCM")
  expect_identical(first$Data, second$Data)
  expect_identical(first$Person, second$Person)
  expect_identical(first$SharedAcrossCandidateFamilies, c("RSM", "PCM"))
  expect_false(first$SeedSearchPerformed)
  expect_false(first$ExternalExecutionAuthorized)
  expect_false(first$EvidencePromotionAuthorized)
  expect_false(first$ScientificEquivalenceInferred)
  if (had_seed) {
    expect_identical(get(".Random.seed", envir = .GlobalEnv), old_seed)
  } else {
    expect_false(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
  }
  expect_error(
    env$mfrmr_cq_p2r_fixture(2026081503L),
    "single frozen seed",
    fixed = TRUE
  )
})

test_that("shape and multibridge topology are preserved", {
  ctx <- load_conquest_p2_replacement_fixture()
  fixture <- ctx$env$mfrmr_cq_p2r_fixture()
  graph <- ctx$env$mfrmr_cq_p2r_graph_audit(fixture)

  expect_identical(nrow(fixture$Data), 288L)
  expect_identical(length(unique(fixture$Data$Person)), 48L)
  expect_identical(sort(unique(fixture$Data$Response)), 0:3)
  expect_true(graph$Connected)
  expect_identical(graph$Components, 1L)
  expect_identical(graph$PositiveEdgeCount, 4L)
  expect_identical(graph$BridgeEdgeCount, 0L)
  expect_identical(graph$MinimumCommonPersons, 12L)
  expect_identical(graph$EdgeTable$CommonPersons, rep(12L, 4L))
})

test_that("population and facet signal improve without passing full support", {
  ctx <- load_conquest_p2_replacement_fixture()
  signal <- ctx$env$mfrmr_cq_p2r_signal_audit()

  expect_identical(signal$UniquePersonTotalScores, 16L)
  expect_identical(signal$PersonTotalScoreRange, 16L)
  expect_gt(abs(signal$PersonScoreXCorrelation), 0.20)
  expect_gt(signal$XGroupMeanPersonScoreSeparation, 0.75)
  expect_gt(signal$MaximumAbsoluteCenteredRaterScore, 1)
  expect_gt(signal$MaximumAbsoluteCenteredCriterionScore, 1)
  expect_false(signal$ExactFacetCategoryBalance)
  expect_equal(signal$GeneratingThetaXMeanSeparation, 0.9,
               tolerance = 1e-14)
  expect_gt(signal$GeneratingThetaVariance, 0.50)
  expect_identical(signal$MinimumRaterCriterionCategoryCount, 0L)
  expect_false(signal$SeedSearchPerformed)
  expect_false(signal$ExternalExecutionAuthorized)
  expect_false(signal$ScientificEquivalenceInferred)
})

test_that("exactly one prospective pre-fit gate rejects candidate 002", {
  ctx <- load_conquest_p2_replacement_fixture()
  env <- ctx$env
  gates <- env$mfrmr_cq_p2r_gate_results()
  review <- env$mfrmr_cq_p2r_review()

  expect_identical(nrow(gates), 13L)
  expect_identical(sum(gates$Passed), 12L)
  expect_identical(
    gates$GateId[!gates$Passed],
    "ALL_RATER_CRITERION_CATEGORIES_PRESENT"
  )
  expect_true(all(gates$FrozenBeforeGenerationReview))
  expect_false(any(gates$CanAuthorizeExternalExecution))
  expect_false(any(gates$CanPromoteEvidence))
  expect_false(any(gates$ScientificEquivalenceInferred))
  expect_identical(review$status, "replacement_fixture_rejected_before_fit")
  expect_false(review$all_thirteen_prefit_gates_passed)
  expect_false(review$old_candidate_superseded_for_future_design)
  expect_false(review$mfrmr_fit_preflight_required)
  expect_false(review$replacement_candidate_execution_authorized)
  expect_true(review$fresh_runtime_and_authorization_required)
  expect_false(review$evidence_promotion_authorized)
  expect_false(review$public_claim_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("the rejected fixture contract cannot fit or launch", {
  ctx <- load_conquest_p2_replacement_fixture()
  source <- paste(readLines(ctx$paths[3L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("fit_mfrm\\s*\\(", source, perl = TRUE))
  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5", source, ignore.case = TRUE))
})

test_that("the internal record retains rejection and the next design gate", {
  ctx <- load_conquest_p2_replacement_fixture()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-replacement-nondegenerate-fixture-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2r_specification, fixed = TRUE)
  expect_match(record, ctx$env$mfrmr_cq_p2r_contract, fixed = TRUE)
  expect_match(record, "passed 12 of 13 pre-fit gates", fixed = TRUE)
  expect_match(record, "`SeedSearchPerformed=FALSE`", fixed = TRUE)
  expect_match(
    record, "`ReplacementCandidateExecutionAuthorized=FALSE`", fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze one no-search PCM-generating replacement seed",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Give candidate 003 a prospectively defined support-guaranteeing",
    fixed = TRUE
  )
})
