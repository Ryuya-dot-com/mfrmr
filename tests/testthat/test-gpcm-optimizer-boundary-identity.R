# Repository-only historical identity checks. The source records and their
# cryptographic identities are intentionally excluded from the package tarball.

test_that("optimizer sensitivity source remains pinned to Draft.66", {
  runner <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-owner-jml-optimizer-sensitivity-0.2.3.R"
  )
  skip_if_not(file.exists(runner),
              "repository-internal validation artifacts are excluded")
  expect_true(file.exists(runner))
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)

  expect_identical(
    env$mfrmr_gpcm_jml_source_execution_sha256,
    "f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037"
  )
  expect_identical(
    env$mfrmr_gpcm_jml_source_runner_sha256,
    "b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16"
  )
  expect_identical(
    env$mfrmr_gpcm_jml_source_runtime_sha256,
    "ebd9e8eb219ece646adfd37301eba997392637749513191ca7c52d33ce77356d"
  )
})

test_that("boundary recheck pins both historical and patched identities", {
  runner <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-owner-jml-boundary-rejection-recheck-0.2.3.R"
  )
  record <- testthat::test_path(
    "..", "..", "inst", "validation",
    "gpcm-owner-jml-optimizer-attribution-record-0.2.3.md"
  )
  skip_if_not(file.exists(runner) && file.exists(record),
              "repository-internal validation artifacts are excluded")
  expect_true(file.exists(runner))
  expect_true(file.exists(record))
  env <- new.env(parent = globalenv())
  sys.source(runner, envir = env)

  expect_identical(
    env$mfrmr_gpcm_jml_recheck_runtime_sha256,
    "31c87d7a888ca760afa02476f1c226bae148403475e34b75eefaaa9679522920"
  )
  expect_identical(
    env$mfrmr_gpcm_jml_recheck_source_execution_sha256,
    "15aafe52e32a729bfb245895604d7ec8fc0ec7157c2db5020a607d675587882b"
  )
  expect_identical(
    env$mfrmr_gpcm_jml_recheck_source_inventory_sha256,
    "210baba78b46741ab9d1cf84dc4a31059c86b7afbb3ee961d271ce224c0751e1"
  )
})
