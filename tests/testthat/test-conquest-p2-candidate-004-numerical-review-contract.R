load_conquest_p2_candidate_004_numerical_review_contract <- function() {
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
    "conquest-p2-candidate-004-harness-0.2.3.R",
    "conquest-p2-candidate-004-execution-observation-0.2.3.R",
    "conquest-reported-output-precision-contract-0.2.3.R",
    "conquest-p2-candidate-004-numerical-review-contract-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(all(file.exists(paths)), "Candidate-004 review contract is excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("candidate-004 reuses frozen budgets without output tuning", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  budget <- env$mfrmr_cq_p2c4nr_budget_registry()

  expect_identical(nrow(budget), 10L)
  expect_identical(
    budget$AbsoluteTolerance[1:6],
    c(1e-5, 2e-6, 2e-6, 2e-6, 2e-6, 2e-6)
  )
  expect_true(all(budget$AbsoluteTolerance[7:8] > 0))
  expect_identical(budget$AbsoluteTolerance[9:10], c(2e-5, 2e-5))
  expect_false(any(budget$Candidate004OutputTuned))
  expect_true(all(budget$Frozen))
})

test_that("the four-arm plan retains both dense grids", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  plan <- env$mfrmr_cq_p2c4nr_plan()

  expect_identical(plan$RunId, c(
    "rsm_q061", "rsm_q121", "pcm_q061", "pcm_q121"
  ))
  expect_identical(plan$Nodes, c(61L, 121L, 61L, 121L))
  expect_identical(plan$ExpectedFreeDimension, c(10L, 10L, 14L, 14L))
  expect_identical(
    plan$CrossEngineRole,
    c("retained_dense_lower", "governing_dense_upper",
      "retained_dense_lower", "governing_dense_upper")
  )
  expect_true(all(plan$NumericalReviewRequired))
  expect_false(any(plan$NewFitAuthorized))
  expect_false(any(plan$RerunAuthorized))
})

test_that("coordinate maps expand every sum-zero constraint", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  rsm <- env$mfrmr_cq_p2c4nr_coordinate_registry("RSM")
  pcm <- env$mfrmr_cq_p2c4nr_coordinate_registry("PCM")

  expect_identical(nrow(rsm), 13L)
  expect_identical(nrow(pcm), 19L)
  expect_identical(sum(rsm$ConstraintRole == "free"), 10L)
  expect_identical(sum(pcm$ConstraintRole == "free"), 14L)
  expect_identical(sum(rsm$ConstraintRole == "derived_sum_zero"), 3L)
  expect_identical(sum(pcm$ConstraintRole == "derived_sum_zero"), 5L)
  expect_setequal(
    rsm$Coordinate[rsm$ConstraintRole == "derived_sum_zero"],
    c("Rater::R4", "Criterion::C3", "Step::Step_3")
  )
  expect_setequal(
    pcm$Coordinate[pcm$ConstraintRole == "derived_sum_zero"],
    c("Rater::R4", "Criterion::C3",
      paste0("Step::C", 1:3, "::Step_3"))
  )
})

test_that("complete numerical-core denominators cannot drop rows", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  denominator <- env$mfrmr_cq_p2c4nr_denominator_registry()

  expect_identical(nrow(denominator), 12L)
  expect_identical(
    denominator$ExpectedAtomicCount,
    c(4L, 52L, 64L, 4L, 64L, 4L, 480L, 18L, 96L, 96L, 2L, 2L)
  )
  expect_false(any(denominator$DropFailedRowsAllowed))
  expect_true(all(denominator$Candidate004NumericCore))
  expect_false(any(denominator$FullP2DesignPortfolio))
})

test_that("fixture identity is semantic across numeric storage modes", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  canonical <- env$mfrmr_cq_p2c4_fixture()$Data
  serialized <- canonical
  serialized$X <- as.integer(serialized$X)

  expect_false(identical(serialized, canonical))
  expect_true(env$mfrmr_cq_p2c4nr_semantic_fixture_equal(
    serialized, canonical, "Response"
  ))
  serialized$Response[1L] <- serialized$Response[1L] + 1L
  expect_false(env$mfrmr_cq_p2c4nr_semantic_fixture_equal(
    serialized, canonical, "Response"
  ))
})

test_that("table extraction reconstructs constraints but not hidden precision", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  parameters <- data.frame(
    Estimate = c("-0.3", "-0.2", "0.1", "-0.4", "0.15", "-1.1", "0.2"),
    Label = c(
      " rater R1", " rater R2", " rater R3", " criterion C1",
      " criterion C2", " category 1", " category 2"
    ), stringsAsFactors = FALSE
  )
  regression <- data.frame(
    Regressor = c("1", "2"), Estimate = c("0.1", "0.5"),
    stringsAsFactors = FALSE
  )
  covariance <- data.frame(Covariance = "0.7", stringsAsFactors = FALSE)
  history <- data.frame(
    Iteration = as.character(1:2), LogLikelihood = c("101.0", "100.0"),
    stringsAsFactors = FALSE
  )
  out <- env$mfrmr_cq_p2c4nr_extract_arm_tables(
    "RSM", 61L, parameters, regression, covariance, history
  )
  value <- stats::setNames(out$coordinate$Estimate, out$coordinate$Coordinate)

  expect_equal(unname(value["Rater::R4"]), 0.4)
  expect_equal(unname(value["Criterion::C3"]), 0.25)
  expect_equal(unname(value["Step::Step_3"]), 0.9)
  expect_identical(nrow(out$coordinate), 13L)
  expect_identical(nrow(out$raw_tokens), 11L)
  expect_true(out$reported_output_estimand_ready)
  expect_false(out$rounding_rule_inferred)
  expect_false(out$hidden_solution_interval_available)
})

test_that("A-matrix review is semantic but rejects a coefficient mutation", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  make_native <- function(family) {
    expected <- env$mfrmr_cq_p2_matrix_contract(family)
    registry <- env$mfrmr_cq_p2c4nr_coordinate_registry(family)
    conditional <- registry[
      registry$ConstraintRole == "free" &
        registry$SourceRole == "parameter_export", , drop = FALSE
    ]
    grid <- expand.grid(
      Category = 1:4, GIN = 1:12,
      KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE
    )
    rater <- paste0("R", ((grid$GIN - 1L) %% 4L) + 1L)
    criterion <- paste0("C", ((grid$GIN - 1L) %/% 4L) + 1L)
    key <- paste0(rater, "::", criterion, "::k", grid$Category - 1L)
    value <- expected$A[match(key, expected$C$RowKey), , drop = FALSE]
    out <- data.frame(GIN = grid$GIN, Category = grid$Category, value,
                      check.names = FALSE)
    names(out)[-(1:2)] <- paste0(" ", conditional$ExpectedLabel)
    out
  }

  for (family in c("RSM", "PCM")) {
    native <- make_native(family)
    expect_true(env$mfrmr_cq_p2c4nr_a_matrix_exact(native, family))
    reordered <- native[rev(seq_len(nrow(native))), , drop = FALSE]
    expect_true(env$mfrmr_cq_p2c4nr_a_matrix_exact(reordered, family))
    mutated <- native
    mutated[2L, 3L] <- as.numeric(mutated[2L, 3L]) + 1
    expect_false(env$mfrmr_cq_p2c4nr_a_matrix_exact(mutated, family))
  }
})

test_that("label and history mutations fail before numerical adjudication", {
  env <- load_conquest_p2_candidate_004_numerical_review_contract()$env
  parameters <- data.frame(
    Estimate = c("-0.3", "-0.2", "0.1", "-0.4", "0.15", "-1.1", "0.2"),
    Label = c(
      " rater R1", " rater R2", " rater R3", " criterion C1",
      " criterion C2", " category 1", " category 2"
    ), stringsAsFactors = FALSE
  )
  regression <- data.frame(
    Regressor = c("1", "2"), Estimate = c("0.1", "0.5"),
    stringsAsFactors = FALSE
  )
  covariance <- data.frame(Covariance = "0.7", stringsAsFactors = FALSE)
  history <- data.frame(
    Iteration = as.character(1:2), LogLikelihood = c("101.0", "100.0"),
    stringsAsFactors = FALSE
  )
  bad_label <- parameters
  bad_label$Label[1L] <- " rater R2"
  expect_error(
    env$mfrmr_cq_p2c4nr_extract_arm_tables(
      "RSM", 61L, bad_label, regression, covariance, history
    ),
    "parameter labels", fixed = TRUE
  )
  bad_history <- history
  bad_history$Iteration[2L] <- "3"
  expect_error(
    env$mfrmr_cq_p2c4nr_extract_arm_tables(
      "RSM", 61L, parameters, regression, covariance, bad_history
    ),
    "iteration history", fixed = TRUE
  )
})

test_that("review contract cannot fit, launch, hash-gate, or promote", {
  ctx <- load_conquest_p2_candidate_004_numerical_review_contract()
  source <- paste(readLines(tail(ctx$paths, 1L), warn = FALSE), collapse = "\n")

  expect_false(grepl("fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE))
  expect_true(grepl("evidence_promotion_authorized = FALSE", source, fixed = TRUE))
  expect_true(grepl("scientific_equivalence_inferred = FALSE", source, fixed = TRUE))
})

test_that("record and roadmap retain the no-result boundary", {
  ctx <- load_conquest_p2_candidate_004_numerical_review_contract()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-numerical-review-contract-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_p2c4nr_specification, fixed = TRUE)
  expect_match(record, "`MetricResultRecorded=FALSE`", fixed = TRUE)
  expect_match(record, "not the complete P2 design portfolio", fixed = TRUE)
  expect_match(
    roadmap,
    "candidate-004 numerical-review contract is now frozen",
    fixed = TRUE
  )
})

test_that("adversarial-control record retains the intended asymmetries", {
  ctx <- load_conquest_p2_candidate_004_numerical_review_contract()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-p2-candidate-004-reviewer-adversarial-controls-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, "semantic row reorder", fixed = TRUE)
  expect_match(record, "coefficient mutation", fixed = TRUE)
  expect_match(record, "numeric storage-mode change", fixed = TRUE)
  expect_match(record, "response-value mutation", fixed = TRUE)
  expect_match(record, "ExternalRerunAuthorized=FALSE", fixed = TRUE)
})
