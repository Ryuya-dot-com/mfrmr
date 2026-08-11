conquest_additive_reference_root <- function() {
  candidates <- c(
    normalizePath(".", winslash = "/", mustWork = FALSE),
    normalizePath(
      testthat::test_path("..", ".."), winslash = "/", mustWork = FALSE
    )
  )
  candidates <- candidates[
    file.exists(file.path(candidates, "DESCRIPTION")) &
      dir.exists(file.path(candidates, "R"))
  ]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_conquest_additive_reference <- function() {
  testthat::skip_if_not_installed("digest")
  source_root <- conquest_additive_reference_root()
  testthat::skip_if(
    is.na(source_root), "The source-bound additive preflight is unavailable."
  )
  namespace_path <- tryCatch(
    normalizePath(
      getNamespaceInfo(asNamespace("mfrmr"), "path"),
      winslash = "/", mustWork = TRUE
    ),
    error = function(error) NA_character_
  )
  testthat::skip_if_not(
    identical(namespace_path, source_root),
    "This integration test requires pkgload::load_all('.') source binding."
  )
  env <- new.env(parent = globalenv())
  sys.source(file.path(
    source_root, "inst", "validation",
    "conquest-additive-mfrm-design-0.2.3.R"
  ), envir = env)
  script <- file.path(
    source_root, "inst", "validation",
    "conquest-additive-mfrm-reference-preflight-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, source_root = source_root, script = script)
}

test_that("the source preflight has an independent normalized GH rule", {
  loaded <- load_conquest_additive_reference()
  env <- loaded$env
  one <- env$mfrmr_cq_additive_gh_normal(1L)
  expect_identical(one, list(nodes = 0, weights = 1))
  for (nodes in c(31L, 61L)) {
    quadrature <- env$mfrmr_cq_additive_gh_normal(nodes)
    expect_length(quadrature$nodes, nodes)
    expect_length(quadrature$weights, nodes)
    expect_equal(sum(quadrature$weights), 1, tolerance = 1e-13)
    expect_equal(
      sum(quadrature$weights * quadrature$nodes), 0,
      tolerance = 1e-13
    )
    expect_equal(
      sum(quadrature$weights * quadrature$nodes^2), 1,
      tolerance = 1e-12
    )
  }
  expect_error(env$mfrmr_cq_additive_gh_normal(0), "positive integer")
})

test_that("the source manifest binds the complete R source tree", {
  loaded <- load_conquest_additive_reference()
  manifest <- loaded$env$mfrmr_cq_additive_source_manifest(
    loaded$source_root
  )
  expect_true(all(nchar(manifest$SHA256) == 64L))
  expect_length(unique(manifest$SourceTreeSHA256), 1L)
  expect_equal(nchar(unique(manifest$SourceTreeSHA256)), 64L)
  expect_true("DESCRIPTION" %in% manifest$RelativePath)
  expect_true("NAMESPACE" %in% manifest$RelativePath)
  expect_true(any(grepl(
    "conquest-additive-mfrm-reference-preflight-0.2.3.R",
    manifest$RelativePath, fixed = TRUE
  )))
})

test_that("PCM reference export keeps facet-specific step estimates", {
  loaded <- load_conquest_additive_reference()
  coordinate <- list(
    beta = c(Intercept = 0.1, X = 0.2),
    sigma2 = 0.3,
    rater = c(R1 = -0.4, R2 = 0.4),
    criterion = c(C1 = -0.5, C2 = 0.5),
    steps = rbind(
      C1 = c(-1.1, -0.1, 1.2),
      C2 = c(-0.8, -0.2, 1.0)
    )
  )
  table <- loaded$env$mfrmr_cq_additive_reference_parameter_table(
    coordinate, "PCM", "pcm_q031", 31L
  )
  step <- table[table$Component == "Step", , drop = FALSE]
  expect_true(all(is.finite(table$Estimate)))
  expect_identical(
    step$Estimate,
    c(-1.1, -0.1, 1.2, -0.8, -0.2, 1.0)
  )
})

test_that("four source-bound arms pass the oracle but remain external NO-GO", {
  loaded <- load_conquest_additive_reference()
  env <- loaded$env
  design_dir <- tempfile("conquest-additive-reference-")
  env$mfrmr_prepare_conquest_additive_design(design_dir)
  reference <- env$mfrmr_run_conquest_additive_reference_preflight(
    design_dir, loaded$source_root
  )
  expect_s3_class(reference, "mfrmr_conquest_additive_reference")
  expect_identical(
    reference$status, "mfrmr_reference_ready_candidate_unbound"
  )
  expect_equal(nrow(reference$summary), 4L)
  expect_identical(reference$summary$Npar, c(7L, 7L, 9L, 9L))
  expect_true(all(reference$summary$ConvergenceStatus == "converged"))
  expect_true(all(reference$summary$EvaluatedPatternDesigns == 512L))
  expect_true(all(reference$summary$LocalRank == reference$summary$Npar))
  expect_true(all(reference$summary$LocalNullity == 0L))
  expect_true(all(!reference$summary$RankToleranceSensitive))
  expect_lte(max(reference$summary$OracleLogLikAbsDifference), 1e-9)
  expect_lte(
    max(reference$summary$OracleProbabilityMaxAbsDifference), 1e-13
  )
  expect_true(all(!reference$summary$InferenceReady))
  expect_true(all(is.na(
    reference$q_sensitivity$PrespecifiedAcceptanceThreshold
  )))
  expect_true(all(
    reference$q_sensitivity$AcceptanceDecision ==
      "not_set_observation_only"
  ))

  review <- env$mfrmr_validate_conquest_additive_reference_preflight(
    design_dir
  )
  expect_true(review$MfrmrReferenceObserved)
  expect_true(review$FourArmsComplete)
  expect_true(review$NumericalAndOracleReady)
  expect_true(review$AllPatternLocalRankFull)
  expect_false(review$InferenceReady)
  expect_false(review$NativeDesignMatrixObserved)
  expect_false(review$CandidateBound)
  expect_false(review$ExternalExecutionAuthorized)
  expect_false(review$ComparisonReady)
  expect_identical(
    review$Decision, "no_go_native_matrix_and_candidate_missing"
  )
  expect_error(
    env$mfrmr_run_conquest_additive_reference_preflight(
      design_dir, loaded$source_root
    ),
    "already exists",
    fixed = TRUE
  )

  target <- file.path(
    reference$reference_dir, reference$manifest$SummaryFile[1]
  )
  writeLines(c(readLines(target, warn = FALSE), "tampered"), target)
  expect_error(
    env$mfrmr_validate_conquest_additive_reference_preflight(design_dir),
    "artifact identity failed",
    fixed = TRUE
  )
})

test_that("the source preflight contains no external process call", {
  loaded <- load_conquest_additive_reference()
  lines <- readLines(loaded$script, warn = FALSE)
  executable_calls <- grep(
    "system2\\s*\\(|system\\s*\\(", lines, perl = TRUE, value = TRUE
  )
  expect_length(executable_calls, 0L)
})
