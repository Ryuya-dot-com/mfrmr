load_conquest_minimum_diagnostic_harness <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  required <- c(
    "conquest-semantic-runtime-preflight-0.2.3.R",
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-prospective-tolerance-freeze-0.2.3.R",
    "conquest-p2-metric-boundary-contract-0.2.3.R",
    "conquest-minimum-diagnostic-authorization-0.2.3.R",
    "conquest-minimum-diagnostic-live-authorization-0.2.3.R",
    "conquest-minimum-diagnostic-harness-0.2.3.R"
  )
  paths <- file.path(validation, required)
  skip_if_not(
    all(file.exists(paths)),
    "Repository-only minimum diagnostic harness files are excluded."
  )
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("the harness contains only the authorized four-arm slice", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  plan <- ctx$env$mfrmr_cq_mdh_plan()

  expect_identical(
    plan$RegistryRowId,
    rep(c(
      "P2-RSM-CONNECTED-MULTIBRIDGE",
      "P2-PCM-CONNECTED-MULTIBRIDGE"
    ), each = 2L)
  )
  expect_identical(plan$Family, c("RSM", "RSM", "PCM", "PCM"))
  expect_identical(plan$Nodes, c(31L, 61L, 31L, 61L))
  expect_identical(plan$ExpectedFreeDimension, c(10L, 10L, 14L, 14L))
  expect_true(all(plan$ExpectedNativeOutputCount == 8L))
  expect_true(all(plan$RunOnce))
  expect_false(anyDuplicated(plan$Prefix) > 0L)
  expect_false(any(plan$EvidencePromotionAuthorized))
  expect_false(any(plan$WiderExecutionAuthorized))
  expect_false(any(plan$P3ExecutionAuthorized))
  expect_false(any(plan$PublicClaimAuthorized))
  expect_false(any(plan$ScientificEquivalenceInferred))
})

test_that("the sparse wide fixture retains the sealed long-data semantics", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  fixture <- ctx$env$mfrmr_cq_mdh_wide_fixture()
  response <- as.matrix(fixture$wide[, fixture$layout$ResponseName])

  expect_identical(dim(response), c(48L, 12L))
  expect_identical(sum(!is.na(response)), 288L)
  expect_identical(sum(is.na(response)), 288L)
  expect_true(all(rowSums(!is.na(response)) == 6L))
  expect_identical(sort(unique(as.integer(response[!is.na(response)]))), 0:3)
  expect_identical(nrow(fixture$long), 288L)
  expect_identical(fixture$layout$Criterion, rep(paste0("C", 1:3), 4L))
  expect_identical(fixture$layout$Rater, rep(paste0("R", 1:4), each = 3L))
})

test_that("commands and native outputs are unique and semantically fixed", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  env <- ctx$env
  plan <- env$mfrmr_cq_mdh_plan()
  native <- env$mfrmr_cq_mdh_native_output_registry(plan)

  expect_identical(nrow(native), 32L)
  expect_false(anyDuplicated(native$RelativePath) > 0L)
  expect_identical(
    as.integer(table(factor(native$RunId, levels = plan$RunId))),
    rep(8L, 4L)
  )
  for (index in seq_len(nrow(plan))) {
    command <- env$mfrmr_cq_mdh_command(
      plan$Prefix[index], plan$Family[index], plan$Nodes[index]
    )
    expected_model <- if (plan$Family[index] == "RSM") {
      "model rater + criterion + step;"
    } else {
      "model rater + criterion + criterion*step;"
    }
    expect_true(expected_model %in% command)
    expect_true(any(grepl(
      paste0("nodes=", plan$Nodes[index], ","), command, fixed = TRUE
    )))
    expect_true(any(grepl(
      "facets=criterion(3) rater(4)", command, fixed = TRUE
    )))
    expect_identical(
      sum(grepl(paste0(plan$Prefix[index], "_conquest_"),
                command, fixed = TRUE)),
      8L
    )
  }
})

test_that("preparation is opt-in, dated, new-directory-only, and fit-free", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  env <- ctx$env
  parent <- withr::local_tempdir()
  held <- file.path(parent, "held")
  stale <- file.path(parent, "stale")
  existing <- file.path(parent, "existing")
  prepared_path <- file.path(parent, "prepared")

  expect_error(
    env$mfrmr_cq_mdh_prepare(
      held, as.Date("2026-08-15"), authorize = FALSE
    ),
    "Preparation is held",
    fixed = TRUE
  )
  expect_false(dir.exists(held))
  expect_error(
    env$mfrmr_cq_mdh_prepare(
      stale, as.Date("2026-08-17"), authorize = TRUE
    ),
    "live authorization is inactive",
    fixed = TRUE
  )
  expect_false(dir.exists(stale))
  expect_true(dir.create(existing))
  expect_error(
    env$mfrmr_cq_mdh_prepare(
      existing, as.Date("2026-08-15"), authorize = TRUE
    ),
    "must not already exist",
    fixed = TRUE
  )

  prepared <- env$mfrmr_cq_mdh_prepare(
    prepared_path, as.Date("2026-08-15"), authorize = TRUE
  )
  expect_identical(
    prepared$status,
    "minimum_P2_diagnostic_bundle_prepared_execution_unopened"
  )
  expect_true(prepared$exact_plan_ready)
  expect_true(prepared$semantic_fixture_ready)
  expect_true(prepared$command_semantics_ready)
  expect_true(prepared$all_candidate_outputs_absent)
  expect_true(prepared$execution_ready)
  expect_false(prepared$execution_attempted)
  expect_identical(sum(prepared$journal$MfrmrAttemptCount), 0L)
  expect_identical(sum(prepared$journal$ConQuestAttemptCount), 0L)
  expect_false(any(file.exists(file.path(
    prepared_path, prepared$plan$MfrmrFitFile
  ))))
  expect_error(
    env$mfrmr_cq_mdh_execute(
      prepared_path, as.Date("2026-08-15"), authorize = FALSE
    ),
    "Execution is held",
    fixed = TRUE
  )
})

test_that("any opened candidate path makes the run-once bundle ineligible", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  env <- ctx$env
  parent <- withr::local_tempdir()
  output_dir <- file.path(parent, "prepared")
  prepared <- env$mfrmr_cq_mdh_prepare(
    output_dir, as.Date("2026-08-15"), authorize = TRUE
  )
  opened <- file.path(output_dir, prepared$plan$ConsoleFile[1L])
  writeLines("partial retained console", opened, useBytes = TRUE)

  review <- env$mfrmr_cq_mdh_validate_prepared(output_dir)
  expect_false(review$all_candidate_outputs_absent)
  expect_false(review$execution_ready)
  expect_identical(
    review$status,
    "minimum_P2_diagnostic_bundle_invalid_or_already_opened"
  )
})

test_that("semantic success requires all native outputs and no failure token", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  env <- ctx$env
  parent <- withr::local_tempdir()
  output_dir <- file.path(parent, "prepared")
  prepared <- env$mfrmr_cq_mdh_prepare(
    output_dir, as.Date("2026-08-15"), authorize = TRUE
  )
  arm <- prepared$plan[1L, , drop = FALSE]
  native <- prepared$native_outputs[
    prepared$native_outputs$RunId == arm$RunId, , drop = FALSE
  ]
  for (path in file.path(output_dir, native$RelativePath)) {
    writeLines("retained native output", path, useBytes = TRUE)
  }
  clean <- env$mfrmr_cq_mdh_conquest_status(
    output_dir, arm, prepared$native_outputs,
    list(
      console_lines = c("ConQuest version: 5.47.5", "End of Program"),
      exit_status = 0L, host_error = NA_character_
    )
  )
  expect_true(clean$semantic_success)
  expect_identical(clean$native_output_count, 8L)
  expect_identical(sum(clean$failure_registry$Observed), 0L)
  expect_false(clean$evidence_promotion_authorized)
  expect_false(clean$scientific_equivalence_inferred)

  failed <- env$mfrmr_cq_mdh_conquest_status(
    output_dir, arm, prepared$native_outputs,
    list(
      console_lines = c(
        "Unknown command or argument: model", "End of Program"
      ),
      exit_status = 0L, host_error = NA_character_
    )
  )
  expect_false(failed$semantic_success)
  expect_identical(sum(failed$failure_registry$Observed), 1L)
})

test_that("the harness has no deletion or top-level execution path", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  source <- paste(readLines(ctx$paths[8L], warn = FALSE), collapse = "\n")

  expect_false(grepl("unlink\\s*\\(", source, perl = TRUE))
  expect_match(source, "mfrmr_cq_mdh_system_runner <- function", fixed = TRUE)
  expect_match(source, "mfrmr_cq_mdh_execute <- function", fixed = TRUE)
  expect_match(source, "authorize = FALSE", fixed = TRUE)
  expect_false(grepl("SHA-256|SHA256|md5", source, ignore.case = TRUE))
})

test_that("internal documentation keeps execution and promotion separate", {
  ctx <- load_conquest_minimum_diagnostic_harness()
  record_path <- file.path(
    ctx$validation,
    "conquest-minimum-diagnostic-harness-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_mdh_specification, fixed = TRUE)
  expect_match(record, ctx$env$mfrmr_cq_mdh_contract, fixed = TRUE)
  expect_match(
    record,
    "fail-closed harness implemented and dry-tested; no model fit launched",
    fixed = TRUE
  )
  expect_match(
    record, "`EvidencePromotionAuthorized` | `FALSE`", fixed = TRUE
  )
  expect_match(
    record, "`PublicClaimAuthorized` | `FALSE`", fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Implement and dry-test a fail-closed harness",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Launch exactly the authorized two-row P2 diagnostic candidate",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[x] Supersede the deterministic response generator",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Run a separate mfrmr-only candidate-003 preflight",
    fixed = TRUE
  )
})
