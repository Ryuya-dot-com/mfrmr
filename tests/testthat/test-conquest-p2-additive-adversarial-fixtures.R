load_conquest_p2_additive_fixtures <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R"
  ))
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only ConQuest P2 fixture files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("P2 fixtures are disjoint, deterministic, and execution-free", {
  ctx <- load_conquest_p2_additive_fixtures()
  fixtures <- ctx$env$mfrmr_cq_p2_fixture_registry()

  expect_identical(length(fixtures), 13L)
  expect_setequal(names(fixtures), c(
    "P2-RSM-CONNECTED-MULTIBRIDGE",
    "P2-PCM-CONNECTED-MULTIBRIDGE",
    "P2-RSM-WEAK-SINGLE-BRIDGE",
    "P2-PCM-WEAK-SINGLE-BRIDGE",
    "P2-RSM-UNEQUAL-WORKLOAD",
    "P2-PCM-UNEQUAL-WORKLOAD",
    "P2-RSM-PLANNED-MISSING-ROWS",
    "P2-RSM-EXPLICIT-MISSING-VALUES",
    "P2-PCM-RARE-BOUNDARY-CATEGORIES",
    "P2-RSM-NONEXTREME-PERSON",
    "P2-RSM-EXTREME-PERSON",
    "P2-NEG-UNUSED-INTERMEDIATE-CATEGORY",
    "P2-NEG-DISCONNECTED-DESIGN"
  ))
  expect_true(all(vapply(
    fixtures,
    function(fixture) identical(sort(unique(fixture$Data$Person)),
                                sprintf("P%03d", 1:48)),
    logical(1L)
  )))
  expect_true(all(vapply(
    fixtures, `[[`, logical(1L), "ExternalExecutionAuthorized"
  ) == FALSE))
  expect_false(any(grepl("candidate-003", vapply(
    fixtures, `[[`, character(1L), "SemanticFixtureId"
  ), fixed = TRUE)))
  repeated <- ctx$env$mfrmr_cq_p2_fixture_registry()
  expect_identical(
    lapply(fixtures, `[[`, "Data"), lapply(repeated, `[[`, "Data")
  )
})

test_that("connected, weak-link, workload, and disconnected controls differ", {
  ctx <- load_conquest_p2_additive_fixtures()
  fixtures <- ctx$env$mfrmr_cq_p2_fixture_registry()
  graph <- lapply(fixtures, ctx$env$mfrmr_cq_p2_graph_audit)

  multi <- graph[["P2-RSM-CONNECTED-MULTIBRIDGE"]]
  expect_true(multi$Connected)
  expect_identical(multi$Components, 1L)
  expect_identical(multi$PositiveEdgeCount, 4L)
  expect_identical(multi$BridgeEdgeCount, 0L)
  expect_true(multi$MinPositiveCommonPersons >= 12L)

  weak <- graph[["P2-RSM-WEAK-SINGLE-BRIDGE"]]
  expect_true(weak$Connected)
  expect_identical(weak$BridgeEdgeCount, 1L)
  expect_identical(weak$MinPositiveCommonPersons, 2L)

  workload <- graph[["P2-RSM-UNEQUAL-WORKLOAD"]]
  expect_true(workload$Connected)
  expect_true(workload$RaterLoadMax > workload$RaterLoadMin)

  disconnected <- graph[["P2-NEG-DISCONNECTED-DESIGN"]]
  expect_false(disconnected$Connected)
  expect_identical(disconnected$Components, 2L)

  expect_error(
    ctx$env$mfrmr_cq_p2_assignment(
      "future_registry_row_not_yet_typed",
      ctx$env$mfrmr_cq_p2_complete_grid()
    ),
    "Unregistered P2 assignment design",
    fixed = TRUE
  )
})

test_that("planned absence and explicit missing values retain identical data", {
  ctx <- load_conquest_p2_additive_fixtures()
  fixtures <- ctx$env$mfrmr_cq_p2_fixture_registry()
  planned <- ctx$env$mfrmr_cq_p2_observed_data(
    fixtures[["P2-RSM-PLANNED-MISSING-ROWS"]]
  )
  explicit_fixture <- fixtures[["P2-RSM-EXPLICIT-MISSING-VALUES"]]
  explicit <- ctx$env$mfrmr_cq_p2_observed_data(explicit_fixture)

  expect_identical(nrow(planned), 288L)
  expect_identical(nrow(explicit_fixture$Data), 576L)
  expect_identical(sum(is.na(explicit_fixture$Data$Response)), 288L)
  expect_identical(planned, explicit)
})

test_that("category and extreme controls retain their typed support", {
  ctx <- load_conquest_p2_additive_fixtures()
  fixtures <- ctx$env$mfrmr_cq_p2_fixture_registry()
  support <- do.call(rbind, lapply(
    fixtures, ctx$env$mfrmr_cq_p2_support_audit
  ))
  row <- function(id) support[support$RegistryRowId == id, , drop = FALSE]

  rare <- row("P2-PCM-RARE-BOUNDARY-CATEGORIES")
  expect_true(all(rare[, paste0("Category", 0:3)] > 0L))
  expect_true(rare$Category0 < rare$Category1)
  expect_true(rare$Category3 < rare$Category2)
  expect_identical(rare$MinimumScorePersons, 0L)
  expect_identical(rare$MaximumScorePersons, 0L)

  unused <- row("P2-NEG-UNUSED-INTERMEDIATE-CATEGORY")
  expect_identical(unused$Category1, 0L)
  expect_true(all(unused[, c("Category0", "Category2", "Category3")] > 0L))

  ordinary <- row("P2-RSM-NONEXTREME-PERSON")
  expect_identical(ordinary$MinimumScorePersons, 0L)
  expect_identical(ordinary$MaximumScorePersons, 0L)
  extreme <- row("P2-RSM-EXTREME-PERSON")
  expect_identical(extreme$MinimumScorePersons, 1L)
  expect_identical(extreme$MaximumScorePersons, 1L)
})

test_that("independent A/C coefficients reproduce RSM and PCM probabilities", {
  ctx <- load_conquest_p2_additive_fixtures()
  audit <- ctx$env$mfrmr_cq_p2_probability_audit()
  rsm <- ctx$env$mfrmr_cq_p2_matrix_contract("RSM")
  pcm <- ctx$env$mfrmr_cq_p2_matrix_contract("PCM")

  expect_identical(nrow(rsm$A), 48L)
  expect_identical(ncol(rsm$A), 7L)
  expect_identical(rsm$TotalExpectedFreeDimension, 10L)
  expect_identical(nrow(pcm$A), 48L)
  expect_identical(ncol(pcm$A), 11L)
  expect_identical(pcm$TotalExpectedFreeDimension, 14L)
  expect_identical(audit$Cases, 120L)
  expect_equal(audit$MaxAbsProbabilityDifference, 0, tolerance = 1e-14)
})

test_that("continuous-target likelihood exists for every P2 fixture", {
  ctx <- load_conquest_p2_additive_fixtures()
  deferred <- ctx$env$mfrmr_cq_p2_review(run_continuous_oracles = FALSE)
  review <- ctx$env$mfrmr_cq_p2_review(run_continuous_oracles = TRUE)
  oracle <- review$continuous_oracles

  expect_true(deferred$fixture_contract_ready)
  expect_false(deferred$continuous_oracle_ready)
  expect_false(deferred$fixture_and_oracle_ready)
  expect_identical(
    deferred$status,
    "P2_additive_fixture_contract_ready_continuous_oracles_not_run"
  )
  expect_true(review$graph_contract_ready)
  expect_true(review$support_contract_ready)
  expect_true(review$fixture_contract_ready)
  expect_true(review$continuous_oracle_ready)
  expect_true(review$fixture_and_oracle_ready)
  expect_identical(length(oracle), 13L)
  expect_true(all(vapply(
    oracle, function(result) is.finite(result$LogLikelihood), logical(1L)
  )))
  expect_true(all(vapply(
    oracle, function(result) result$Persons == 48L, logical(1L)
  )))
  expect_true(all(vapply(
    oracle,
    function(result) is.finite(result$IntegrationAbsoluteErrorEstimate),
    logical(1L)
  )))
  expect_false(review$metric_specific_rules_frozen)
  expect_false(review$external_execution_authorized)
  expect_false(review$comparison_passed)

  planned <- oracle[["P2-RSM-PLANNED-MISSING-ROWS"]]
  explicit <- oracle[["P2-RSM-EXPLICIT-MISSING-VALUES"]]
  expect_equal(planned$LogLikelihood, explicit$LogLikelihood, tolerance = 0)
  expect_identical(planned$ObservedRows, explicit$ObservedRows)
})

test_that("the P2 fixture source cannot launch ConQuest", {
  ctx <- load_conquest_p2_additive_fixtures()
  source <- paste(readLines(ctx$paths[2L], warn = FALSE), collapse = "\n")
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
})

test_that("the P2 fixture record stays historical while later gates advance", {
  ctx <- load_conquest_p2_additive_fixtures()
  record_path <- file.path(
    ctx$validation,
    "conquest-p2-additive-adversarial-fixtures-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_p2_specification,
    ctx$env$mfrmr_cq_p2_contract,
    "P2_additive_fixtures_and_independent_oracles_ready_for_review",
    "`MetricSpecificRulesFrozen`",
    "`ExternalExecutionAuthorized`",
    "`ComparisonPassed`",
    "`ScientificEquivalenceInferred`"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    roadmap,
    "[x] Type every finite, unbounded, adjusted-display",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Freeze parameter-class coordinate metrics",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Review P2 fixtures",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Authorize and run only the smallest frozen external P2 slice",
    fixed = TRUE
  )
})
