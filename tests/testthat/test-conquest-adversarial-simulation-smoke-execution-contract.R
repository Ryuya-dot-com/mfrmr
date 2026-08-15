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
