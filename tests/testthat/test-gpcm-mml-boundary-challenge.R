mml_boundary_challenge_runner_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-challenge-0.2.3.R"
  )
}

mml_boundary_challenge_validator_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-challenge-completion-validator-0.2.3.R"
  )
}

test_that("MML boundary challenge freezes owner direction and q grid", {
  runner <- mml_boundary_challenge_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  contract <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-challenge-contract-0.2.3.md"
  )
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-challenge-record-0.2.3.md"
  )
  expect_true(file.exists(contract))
  expect_true(file.exists(record))
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  assign(
    "mfrmr_gpcm_repilot_hash_object",
    function(x) paste0("rows-", nrow(x)), envir = env
  )
  manifest <- env$mfrmr_gpcm_mml_boundary_challenge_manifest()
  expect_identical(
    env$mfrmr_gpcm_mml_boundary_challenge_quad_points, c(31L, 61L, 91L)
  )
  expect_identical(env$mfrmr_gpcm_mml_boundary_challenge_maxit, 50L)
  expect_identical(nrow(manifest), 10L)
  expect_setequal(unique(manifest$SlopeOwner), c("Criterion", "Rater"))
  expect_identical(sum(manifest$ExpectedCertifiedPairs), 6L)
  expect_identical(sum(manifest$ExpectedRetainedRows == 47L), 2L)
  expect_false(any(manifest$ConfirmationAuthorized))
  expect_false(any(manifest$ReadinessPropagation))

  contract_text <- paste(readLines(contract, warn = FALSE), collapse = "\n")
  expect_match(contract_text, "frozen before running", fixed = TRUE)
  expect_match(contract_text, "q=31/61/91", fixed = TRUE)
  expect_match(contract_text, "1e-8", fixed = TRUE)
  expect_match(contract_text, "failed deterministic expectation", fixed = TRUE)
})

test_that("MML boundary challenge distinguishes zero and positive discordance", {
  runner <- mml_boundary_challenge_runner_path()
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)
  for (owner in c("Criterion", "Rater")) {
    zero <- env$mfrmr_gpcm_mml_boundary_challenge_build_data(
      owner, "zero_weight_discordant"
    )
    epsilon <- env$mfrmr_gpcm_mml_boundary_challenge_build_data(
      owner, "epsilon_weight_discordant"
    )
    expect_identical(zero$Score, epsilon$Score)
    expect_identical(which(zero$Weight == 0), which(epsilon$Weight == 1e-8))
    expect_identical(sum(zero$Weight == 0), 1L)
    expect_identical(sum(epsilon$Weight == 1e-8), 1L)
    expect_true(all(zero$Weight[zero$Weight != 0] == 1))
    expect_true(all(epsilon$Weight[epsilon$Weight != 1e-8] == 1))
  }
})

test_that("MML boundary challenge record preserves the concern result", {
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-challenge-record-0.2.3.md"
  )
  skip_if_not(file.exists(record),
              "repository-internal validation artifacts are excluded")
  text <- paste(readLines(record, warn = FALSE), collapse = "\n")
  expect_match(text, "all dense-grid positive expectations fail", fixed = TRUE)
  expect_match(text, "12", fixed = TRUE)
  expect_match(text, "0", fixed = TRUE)
  expect_match(text, "does not show that the marginal likelihood has a finite maximum",
               fixed = TRUE)
  expect_match(text, "blocks the planned readiness-propagation step",
               fixed = TRUE)
})

test_that("MML boundary challenge validator pins the failed execution", {
  validator <- mml_boundary_challenge_validator_path()
  skip_if_not(file.exists(validator),
              "repository-internal validation artifacts are excluded")
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-mml-boundary-challenge-record-0.2.3.md"
  )
  env <- new.env(parent = globalenv())
  sys.source(validator, envir = env)
  expect_true(is.function(
    env$mfrmr_validate_gpcm_mml_boundary_challenge_completion
  ))
  expect_identical(
    eval(formals(
      env$mfrmr_validate_gpcm_mml_boundary_challenge_completion
    )$expected_execution_sha256),
    "1b442b29510fa763ebe1277a4c314b3c27dcff9dea3715cda8db7d55811ab11f"
  )
  record_text <- paste(readLines(record, warn = FALSE), collapse = "\n")
  expect_match(
    record_text,
    "b66532e12873b60337eebdb7e967610cd742d874bccb572b8730eba26d1b7f3b",
    fixed = TRUE
  )
})
