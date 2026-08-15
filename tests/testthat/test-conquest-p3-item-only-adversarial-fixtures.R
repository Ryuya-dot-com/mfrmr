load_conquest_p3_item_only_fixtures <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-gpcm-overlap-contract-0.2.3.R",
    "conquest-p3-item-only-adversarial-fixtures-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest P3 fixture files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("P3 fixtures are disjoint, deterministic, and execution-free", {
  ctx <- load_conquest_p3_item_only_fixtures()
  fixtures <- ctx$env$mfrmr_cq_p3_fixture_registry()

  expect_identical(length(fixtures), 3L)
  expect_setequal(names(fixtures), c(
    "P3-PCM-UNIT-SLOPE-INTERCEPT",
    "P3-GPCM-NONUNIT-INTERCEPT",
    "P3-GPCM-NONUNIT-COVARIATE"
  ))
  expect_identical(
    length(unique(vapply(fixtures, `[[`, character(1L), "ArmIdentity"))),
    3L
  )
  expect_true(all(vapply(fixtures, function(fixture) {
    identical(dim(fixture$Data), c(384L, 6L)) &&
      identical(unique(fixture$Data$Person), sprintf("P3P%03d", 1:96)) &&
      all(table(fixture$Data$Response, fixture$Data$Item) == 24L) &&
      identical(as.integer(table(unique(
        fixture$Data[c("Person", "X")]
      )$X)), c(48L, 48L))
  }, logical(1L))))
  repeated <- ctx$env$mfrmr_cq_p3_fixture_registry()
  expect_identical(
    lapply(fixtures, `[[`, "Data"), lapply(repeated, `[[`, "Data")
  )
  expect_false(any(grepl(
    "candidate-003|microcase",
    c(ctx$env$mfrmr_cq_p3_fixture_set_id,
      ctx$env$mfrmr_cq_p3_execution_identity),
    ignore.case = TRUE
  )))
  expect_true(all(vapply(
    fixtures, function(fixture) {
      !fixture$CandidateOutputsPresent &&
        !fixture$ExternalExecutionAuthorized &&
        !fixture$ComparisonPassed &&
        !fixture$ScientificEquivalenceInferred
    }, logical(1L)
  )))
})

test_that("P3 truth, A/C matrices, and dimensions are independently fixed", {
  ctx <- load_conquest_p3_item_only_fixtures()
  env <- ctx$env
  fixtures <- env$mfrmr_cq_p3_fixture_registry()
  audits <- lapply(fixtures, env$mfrmr_cq_p3_fixture_audit)
  pcm <- env$mfrmr_cq_p3_matrix_contract("PCM", 0L)
  gpcm0 <- env$mfrmr_cq_p3_matrix_contract("GPCM", 0L)
  gpcm1 <- env$mfrmr_cq_p3_matrix_contract("GPCM", 1L)

  expect_true(all(vapply(audits, `[[`, logical(1L), "Ready")))
  expect_true(all(vapply(fixtures, function(fixture) {
    abs(sum(fixture$Truth$ItemLocation)) < 1e-15 &&
      max(abs(rowSums(fixture$Truth$ItemSteps))) < 1e-15
  }, logical(1L))))
  expect_true(all(fixtures[[1L]]$Truth$ItemSlope == 1))
  expect_equal(
    unname(fixtures[[2L]]$Truth$ItemSlope), c(0.5, 0.8, 1.25, 2),
    tolerance = 0
  )
  expect_equal(mean(log(fixtures[[2L]]$Truth$ItemSlope)), 0,
               tolerance = 1e-15)

  expect_identical(dim(pcm$A), c(16L, 11L))
  expect_identical(dim(pcm$C), c(16L, 1L))
  expect_identical(pcm$AFreeDimension, 11L)
  expect_identical(pcm$CFreeDimension, 0L)
  expect_identical(pcm$MappedTotalFreeDimension, 13L)
  expect_identical(pcm$IndependentlyDerivedMfrmrFreeDimension, 13L)
  expect_identical(qr(pcm$A)$rank, 11L)

  expect_identical(dim(gpcm0$A), c(16L, 12L))
  expect_identical(dim(gpcm0$C), c(16L, 4L))
  expect_identical(gpcm0$AFreeDimension, 12L)
  expect_identical(gpcm0$CFreeDimension, 4L)
  expect_identical(gpcm0$MappedTotalFreeDimension, 16L)
  expect_identical(gpcm0$IndependentlyDerivedMfrmrFreeDimension, 16L)
  expect_identical(qr(gpcm0$A)$rank, 12L)
  expect_identical(qr(gpcm0$C)$rank, 4L)
  expect_identical(gpcm1$MappedTotalFreeDimension, 17L)
  expect_identical(gpcm1$IndependentlyDerivedMfrmrFreeDimension, 17L)
})

test_that("unit-slope reduction and nonunit coordinate maps agree", {
  ctx <- load_conquest_p3_item_only_fixtures()
  env <- ctx$env
  probability <- env$mfrmr_cq_p3_probability_audit()
  reduction <- env$mfrmr_cq_p3_pcm_reduction_audit()

  expect_identical(probability$Cases, 240L)
  expect_lt(probability$MaxAbsProbabilityDifference, 1e-14)
  expect_identical(reduction$Cases, 80L)
  expect_equal(reduction$MaxAbsProbabilityDifference, 0, tolerance = 0)

  for (id in c(
    "P3-GPCM-NONUNIT-INTERCEPT", "P3-GPCM-NONUNIT-COVARIATE"
  )) {
    fixture <- env$mfrmr_cq_p3_fixture(id)
    truth <- fixture$Truth
    contract <- env$mfrmr_cq_gpcm_transform(
      beta0 = truth$PopulationIntercept,
      beta = if (fixture$PopulationFormula == "~1+X") {
        c(X = truth$PopulationSlope)
      } else {
        numeric(0)
      },
      sigma2 = truth$PopulationVariance,
      slopes = truth$ItemSlope,
      item_locations = truth$ItemLocation,
      steps = truth$ItemSteps
    )
    overlap <- env$mfrmr_cq_gpcm_probability_audit(
      contract, c(-2.5, -0.75, 0, 0.9, 2.7)
    )
    mapped <- env$mfrmr_cq_p3_mapped_parameters(fixture)
    expect_lt(overlap$MaxAbsProbabilityDifference, 1e-14)
    expect_equal(unname(mapped$C), unname(contract$ConQuest$Tau),
                 tolerance = 0)
    expect_equal(
      unname(mapped$A[1:4]), unname(contract$ConQuest$ItemLocations),
      tolerance = 0
    )
    expect_equal(
      unname(mapped$A[5:12]),
      as.vector(t(contract$ConQuest$Steps[, 1:2, drop = FALSE])),
      tolerance = 0
    )
    expect_equal(
      unname(mapped$Regression), unname(contract$ConQuest$Regression),
      tolerance = 0
    )
  }
})

test_that("finite ladders converge to independent continuous targets", {
  ctx <- load_conquest_p3_item_only_fixtures()
  env <- ctx$env
  deferred <- env$mfrmr_cq_p3_review(run_continuous_oracles = FALSE)
  review <- env$mfrmr_cq_p3_review(run_continuous_oracles = TRUE)

  expect_true(deferred$fixture_semantics_ready)
  expect_true(deferred$fixture_and_matrix_ready)
  expect_true(deferred$finite_integration_ladder_ready)
  expect_false(deferred$continuous_oracle_ready)
  expect_identical(
    deferred$status,
    "P3_item_only_fixture_and_finite_ladder_ready_continuous_oracles_not_run"
  )
  expect_identical(
    review$status,
    "P3_item_only_fixtures_A_C_and_likelihood_oracles_ready_for_metric_freeze"
  )
  expect_true(review$continuous_oracle_ready)
  for (result in review$likelihood_audits) {
    expect_identical(result$Finite$Nodes, c(31L, 61L, 121L))
    expect_true(all(is.finite(result$Finite$DirectLogLikelihood)))
    expect_lt(result$MaxAbsFiniteMapDifference, 1e-12)
    expect_identical(result$Continuous$Persons, 96L)
    expect_lt(abs(result$Continuous$DirectMinusMapped), 1e-10)
    q121 <- result$Finite$DirectLogLikelihood[
      result$Finite$Nodes == 121L
    ]
    expect_lt(abs(q121 - result$Continuous$DirectLogLikelihood), 1e-8)
    expect_lt(abs(result$Q121MinusQ61), abs(result$Q61MinusQ31))
  }
  for (nodes in c(31L, 61L, 121L)) {
    quadrature <- env$mfrmr_cq_p3_gh_normal(nodes)
    expect_equal(sum(quadrature$weights), 1, tolerance = 5e-14)
    expect_equal(sum(quadrature$weights * quadrature$nodes), 0,
                 tolerance = 1e-14)
    expect_equal(sum(quadrature$weights * quadrature$nodes^2), 1,
                 tolerance = 1e-13)
  }
  expect_false(review$metric_specific_rules_frozen)
  expect_false(review$independent_review_passed)
  expect_false(review$external_execution_authorized)
  expect_false(review$comparison_passed)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("semantic mutations and out-of-stratum requests fail closed", {
  ctx <- load_conquest_p3_item_only_fixtures()
  env <- ctx$env
  fixture <- env$mfrmr_cq_p3_fixture("P3-GPCM-NONUNIT-COVARIATE")

  slope_mutation <- fixture
  slope_mutation$Truth$ItemSlope[1L] <- 0.6
  expect_false(
    env$mfrmr_cq_p3_fixture_audit(slope_mutation)$TruthAndConstraintsReady
  )
  data_mutation <- fixture
  data_mutation$Data$Response[1L] <-
    (data_mutation$Data$Response[1L] + 1L) %% 4L
  expect_false(env$mfrmr_cq_p3_fixture_audit(data_mutation)$DataAndSupportReady)
  output_mutation <- fixture
  output_mutation$CandidateOutputsPresent <- TRUE
  expect_false(env$mfrmr_cq_p3_fixture_audit(output_mutation)$ExecutionClosed)

  expect_error(
    env$mfrmr_cq_p3_fixture("P3-MULTIFACET-GPCM-NONOVERLAP"),
    "prospective P3 item-only row",
    fixed = TRUE
  )
  expect_error(
    env$mfrmr_cq_p3_matrix_contract("manyfacet", 0L),
    "requires PCM/GPCM",
    fixed = TRUE
  )
  incomplete <- fixture
  incomplete$Truth <- NULL
  expect_error(
    env$mfrmr_cq_p3_fixture_audit(incomplete),
    "missing a required semantic field",
    fixed = TRUE
  )

  original_contract <- env$mfrmr_cq_gpcm_contract_version
  env$mfrmr_cq_gpcm_contract_version <- "wrong_overlap_contract"
  expect_error(
    env$mfrmr_cq_p3_fixture_registry(),
    "exact successor registry and item-only GPCM overlap contract",
    fixed = TRUE
  )
  env$mfrmr_cq_gpcm_contract_version <- original_contract
  expect_identical(length(env$mfrmr_cq_p3_fixture_registry()), 3L)
})

test_that("the P3 construction layer cannot launch ConQuest", {
  ctx <- load_conquest_p3_item_only_fixtures()
  source <- paste(readLines(ctx$paths[3L], warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
})

test_that("the P3 record closes construction and preserves later gates", {
  ctx <- load_conquest_p3_item_only_fixtures()
  record_path <- file.path(
    ctx$validation,
    "conquest-p3-item-only-adversarial-fixtures-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_p3_specification,
    ctx$env$mfrmr_cq_p3_contract,
    "P3_item_only_fixtures_A_C_and_likelihood_oracles_ready_for_metric_freeze",
    "240",
    "31;61;121",
    "`MetricSpecificRulesFrozen` | `FALSE`",
    "`IndependentReviewPassed` | `FALSE`",
    "`ExternalExecutionAuthorized` | `FALSE`",
    "`ComparisonPassed` | `FALSE`",
    "`ScientificEquivalenceInferred` | `FALSE`"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    roadmap,
    "[x] Bind the disjoint P3 item-only fixtures and independently reconstruct",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Prove the continuous-target and finite-integration contracts",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Freeze relative-slope, population-scale, transition-threshold",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Authorize the external candidate only after P0/P1 pass",
    fixed = TRUE
  )
})
