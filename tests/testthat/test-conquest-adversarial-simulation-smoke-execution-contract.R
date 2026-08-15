load_conquest_adversarial_simulation_smoke_execution <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  paths <- file.path(validation, c(
    "conquest-successor-semantic-registry-0.2.3.R",
    "conquest-p2-additive-adversarial-fixtures-0.2.3.R",
    "conquest-adversarial-simulation-program-0.2.3.R",
    "conquest-adversarial-simulation-template-contract-0.2.3.R",
    "conquest-adversarial-simulation-dgp-oracle-contract-0.2.3.R",
    "conquest-adversarial-simulation-smoke-authorization-0.2.3.R",
    "conquest-adversarial-simulation-smoke-execution-0.2.3.R"
  ))
  skip_if_not(all(file.exists(paths)), "ConQuest ASP smoke files are excluded.")
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  list(root = root, validation = validation, paths = paths, env = env)
}

test_that("execution contract is bound to the sealed authorization", {
  env <- load_conquest_adversarial_simulation_smoke_execution()$env
  authorization <- env$mfrmr_cq_asg_review(
    run_full_continuous_oracle = TRUE
  )

  expect_identical(
    env$mfrmr_cq_ase_output_basename,
    "conquest-adversarial-simulation-smoke-20260815-v1"
  )
  expect_true(authorization$G3_authorization_complete)
  expect_true(authorization$smoke_dataset_generation_authorized)
  expect_identical(authorization$authorized_smoke_datasets, 18L)
  expect_identical(authorization$maximum_datasets_per_arm, 1L)
  expect_false(authorization$any_fit_authorized)
  expect_false(authorization$ConQuest_execution_authorized)
})

test_that("RNG contract is local and replay is not scientific acceptance", {
  env <- load_conquest_adversarial_simulation_smoke_execution()$env
  contract <- env$mfrmr_cq_ase_rng_contract()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) {
    get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  } else {
    NULL
  }
  old_kind <- RNGkind()
  first <- env$mfrmr_cq_ase_uniform_stream(12345L, 4L, 8L)
  second <- env$mfrmr_cq_ase_uniform_stream(12345L, 4L, 8L)

  expect_identical(first, second)
  expect_true(all(unlist(first) > 0 & unlist(first) < 1))
  expect_identical(RNGkind(), old_kind)
  expect_identical(
    exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE), had_seed
  )
  if (had_seed) {
    expect_identical(
      get(".Random.seed", envir = .GlobalEnv, inherits = FALSE), old_seed
    )
  }
  expect_true(contract$CallerRNGStateRestored)
  expect_false(contract$ReplayIsScientificAcceptanceCriterion)
  expect_false(contract$ByteIdentityIsScientificAcceptanceCriterion)
})

test_that("execution cannot start without explicit authorization", {
  env <- load_conquest_adversarial_simulation_smoke_execution()$env
  target <- file.path(
    tempdir(), env$mfrmr_cq_ase_output_basename
  )

  expect_error(
    env$mfrmr_cq_ase_execute(target, authorize = FALSE),
    "explicit `authorize=TRUE`", fixed = TRUE
  )
  expect_false(file.exists(target))
  expect_false(dir.exists(target))
})

test_that("structural adapter uses the frozen full-location rank fields", {
  env <- load_conquest_adversarial_simulation_smoke_execution()$env
  allocation <- env$mfrmr_cq_asg_seed_registry()
  disposition <- lapply(seq_len(nrow(allocation)), function(index) {
    current <- allocation[index, , drop = FALSE]
    template <- env$mfrmr_cq_ast_template(current$ArmId)
    env$mfrmr_cq_ase_structural_disposition(
      template, template$Data, current
    )
  })
  disposition <- do.call(rbind, disposition)

  expect_identical(nrow(disposition), 18L)
  expect_true(all(disposition$PredictorDimension %in% c(9L, 13L)))
  expect_true(all(disposition$PredictorRank %in% c(8L, 9L, 12L, 13L)))
  expect_true(all(disposition$DispositionMatchesExpected))
})

test_that("semantic replay tolerates lossless CSV numeric type inference", {
  env <- load_conquest_adversarial_simulation_smoke_execution()$env
  replay <- env$mfrmr_cq_ase_generate_all()
  observed <- replay
  observed$response_data$X <- as.integer(observed$response_data$X)

  expect_true(env$mfrmr_cq_ase_semantic_replay_match(observed, replay))
})

test_that("all sealed arms populate the six tables without metric evaluation", {
  env <- load_conquest_adversarial_simulation_smoke_execution()$env
  tables <- env$mfrmr_cq_ase_generate_all()
  manifest <- tables$dataset_manifest
  structural <- tables$structural_disposition

  expect_true(env$mfrmr_cq_ase_validate_tables(tables))
  expect_identical(nrow(manifest), 18L)
  expect_identical(anyDuplicated(manifest$ArmId), 0L)
  expect_identical(anyDuplicated(manifest$DatasetId), 0L)
  expect_identical(sort(manifest$Seed), 987001:987018)
  expect_true(all(manifest$GenerationStatus == "generated_and_retained"))
  expect_true(all(manifest$RetainedInUnconditionalDenominator))
  expect_false(any(manifest$PrototypeResponseVectorReused))
  expect_false(any(manifest$SmokeResultCanTuneDesign))
  expect_identical(nrow(tables$response_data), 7032L)
  expect_identical(nrow(structural), 18L)
  expect_true(all(structural$DispositionMatchesExpected))
  expect_identical(sum(structural$NumericalComparisonPermitted), 14L)
  expect_identical(nrow(tables$engine_outcome), 36L)
  expect_false(any(tables$engine_outcome$Attempted))
  expect_identical(nrow(tables$metric_outcome), 216L)
  expect_true(all(is.na(tables$metric_outcome$Estimate)))
  expect_identical(nrow(tables$continuous_oracle), 36L)
  expect_true(all(is.na(tables$continuous_oracle$Deviance)))
})

test_that("retained local smoke output passes semantic review", {
  ctx <- load_conquest_adversarial_simulation_smoke_execution()
  output <- file.path(
    ctx$root, "validation-results", ctx$env$mfrmr_cq_ase_output_basename
  )
  skip_if_not(dir.exists(output), "Local retained smoke output is unavailable.")
  review <- ctx$env$mfrmr_cq_ase_review_output(output)

  expect_identical(
    review$status,
    "ASP_G3_eighteen_smoke_datasets_generated_and_retained"
  )
  expect_true(review$files_complete)
  expect_true(review$tables_valid)
  expect_true(review$container_valid)
  expect_true(review$semantic_replay_match)
  expect_identical(review$generated_datasets, 18L)
  expect_identical(review$unique_arms, 18L)
  expect_identical(review$response_table_rows, 7032L)
  expect_true(review$structural_dispositions_match)
  expect_identical(review$eligible_structural_arms, 14L)
  expect_identical(review$rejected_structural_arms, 4L)
  expect_identical(review$prototype_response_vectors_reused, 0L)
  expect_identical(review$retained_unconditional_arms, 18L)
  expect_identical(review$fit_attempts, 0L)
  expect_false(review$ConQuest_execution_attempted)
  expect_false(review$operating_characteristics_estimated)
  expect_false(review$result_used_to_tune_design)
  expect_true(review$G3_smoke_execution_complete)
  expect_true(review$G3_complete)
  expect_identical(review$next_gate, "ASP-G4-CALIBRATION-FREEZE")
  expect_false(review$public_text_change_authorized)
  expect_false(review$scientific_equivalence_inferred)
})

test_that("execution source contains no fit, external launch, or hash gate", {
  ctx <- load_conquest_adversarial_simulation_smoke_execution()
  source <- paste(readLines(ctx$paths[7L], warn = FALSE), collapse = "\n")

  expect_true(grepl("set.seed\\s*\\(", source, perl = TRUE))
  expect_true(grepl("runif\\s*\\(", source, perl = TRUE))
  expect_false(grepl(
    "fit_mfrm\\s*\\(|system2\\s*\\(|system\\s*\\(", source, perl = TRUE
  ))
  expect_false(grepl(
    "SHA-256|SHA256|md5|digest::", source, ignore.case = TRUE
  ))
})

test_that("execution record closes G3 and roadmap advances only to G4", {
  ctx <- load_conquest_adversarial_simulation_smoke_execution()
  record <- paste(readLines(file.path(
    ctx$validation,
    "conquest-adversarial-simulation-smoke-execution-record-0.2.3.md"
  ), warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(file.path(
    ctx$validation, "internal-roadmap-0.2.3.md"
  ), warn = FALSE), collapse = "\n")

  expect_match(record, ctx$env$mfrmr_cq_ase_specification, fixed = TRUE)
  expect_match(record, "`G3Complete=TRUE`", fixed = TRUE)
  expect_match(record, "`FitAttempts=0`", fixed = TRUE)
  expect_match(record, "stale rank-field adapter", fixed = TRUE)
  expect_match(record, "CSV type inference read", fixed = TRUE)
  expect_match(
    roadmap, "[x] Generate exactly one sealed smoke dataset per",
    fixed = TRUE
  )
  expect_match(
    roadmap, "[ ] Freeze the calibration seed band, failure taxonomy",
    fixed = TRUE
  )
})
