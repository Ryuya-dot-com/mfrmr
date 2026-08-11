load_conquest_gpcm_overlap_contract <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  source_path <- file.path(
    root, "inst", "validation", "conquest-gpcm-overlap-contract-0.2.3.R"
  )
  registry_path <- file.path(
    root, "inst", "validation", "conquest-gpcm-overlap-registry-0.2.3.csv"
  )
  skip_if_not(all(file.exists(c(source_path, registry_path))),
              "repository-internal validation artifacts are excluded")
  env <- new.env(parent = globalenv())
  sys.source(source_path, envir = env)
  registry <- utils::read.csv(
    registry_path, stringsAsFactors = FALSE, check.names = FALSE
  )
  list(root = root, env = env, registry = registry)
}

test_that("item latent-regression coordinates preserve GPCM probabilities", {
  contract <- load_conquest_gpcm_overlap_contract()
  slopes <- c(I1 = 0.5, I2 = 1, I3 = 2)
  locations <- c(I1 = -0.7, I2 = 0.1, I3 = 0.6)
  steps <- rbind(
    I1 = c(-1.2, 0.1, 1.1),
    I2 = c(-0.8, -0.2, 1.0),
    I3 = c(-1.4, 0.5, 0.9)
  )
  mapped <- contract$env$mfrmr_cq_gpcm_transform(
    beta0 = 0.25,
    beta = c(X = 0.6),
    sigma2 = 0.49,
    slopes = slopes,
    item_locations = locations,
    steps = steps
  )
  audit <- contract$env$mfrmr_cq_gpcm_probability_audit(
    mapped, theta = c(-2.5, -0.75, 0, 0.9, 2.7)
  )

  expect_equal(audit$MaxAbsProbabilityDifference, 0, tolerance = 1e-14)
  expect_equal(audit$TauGeometricMean, 0.7, tolerance = 1e-14)
  expect_equal(mapped$ConQuest$Regression, c(X = 0.6 / 0.7),
               tolerance = 1e-14)
  expect_equal(mapped$ConQuest$Tau, 0.7 * slopes, tolerance = 1e-14)
  expect_equal(
    mapped$ConQuest$ItemLocations,
    slopes * (locations - 0.25),
    tolerance = 1e-14
  )
  expect_equal(mapped$ConQuest$Steps, steps * slopes, tolerance = 1e-14)
})

test_that("the overlap registry admits no unsupported external claim", {
  contract <- load_conquest_gpcm_overlap_contract()
  registry <- contract$registry
  required <- c(
    "OverlapRow", "ConQuestFamily", "ConQuestEstimator", "MfrmrEstimator",
    "Design", "ConQuestScoreOwner", "MfrmrSlopeOwner", "MfrmrStepOwner",
    "LatentScaleMap", "ProbabilityMapStatus", "ExecutionState",
    "ComparisonEligibility", "ReasonCode", "ClaimUse"
  )
  expect_true(all(required %in% names(registry)))
  expect_identical(anyDuplicated(registry$OverlapRow), 0L)
  expect_identical(
    registry$OverlapRow[registry$ComparisonEligibility == "review"],
    "CQ-GPCM-ITEM-LR-MML"
  )
  expect_false(any(registry$ComparisonEligibility == "eligible"))
  expect_true(all(
    registry$ComparisonEligibility[registry$ConQuestEstimator == "JML"] ==
      "rejected"
  ))
  expect_true(any(grepl(
    "slope_scaled_facet_mismatch", registry$ReasonCode, fixed = TRUE
  )))
})

test_that("generated ConQuest control is MML-only and side-effect free", {
  contract <- load_conquest_gpcm_overlap_contract()
  control <- contract$env$mfrmr_cq_gpcm_control(
    prefix = "cq_gpcm", first_response = "I001",
    last_response = "I005", nodes = 31L
  )
  expect_true(any(control == "set lconstraints=cases, sconstraint=cases;"))
  expect_true(any(control == "model item + item*step!scoresfree;"))
  expect_true(any(grepl("method=quadrature, nodes=31", control, fixed = TRUE)))
  expect_true(any(grepl("export tau", control, fixed = TRUE)))
  expect_true(any(grepl("export itemscores", control, fixed = TRUE)))
  expect_true(any(grepl("export cmatrix", control, fixed = TRUE)))
  expect_error(
    contract$env$mfrmr_cq_gpcm_control(
      "cq_gpcm", "I001", "I005", estimator = "JML"
    ),
    "cannot estimate item scores under JML"
  )

  source_text <- paste(
    readLines(
      file.path(
        contract$root, "inst", "validation",
        "conquest-gpcm-overlap-contract-0.2.3.R"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source_text, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source_text, fixed = TRUE))
})

test_that("coordinate guards reject unidentified or malformed inputs", {
  contract <- load_conquest_gpcm_overlap_contract()
  valid_steps <- rbind(A = c(-1, 0, 1), B = c(-0.5, 0, 0.5))
  expect_error(
    contract$env$mfrmr_cq_gpcm_transform(
      0, 0.5, 1, c(A = 1, B = 2), c(A = 0, B = 0), valid_steps
    ),
    "geometric-mean-one"
  )
  expect_error(
    contract$env$mfrmr_cq_gpcm_transform(
      0, 0.5, 1, c(A = 0.5, B = 2), c(A = 0, B = 0),
      rbind(A = c(-1, 0, 1), B = c(-0.5, 0, 0.6))
    ),
    "sum-zero"
  )
  expect_error(
    contract$env$mfrmr_cq_gpcm_transform(
      0, 0.5, 0, c(A = 0.5, B = 2), c(A = 0, B = 0), valid_steps
    ),
    "positive finite"
  )
})

test_that("the overlap record binds its executable structural sources", {
  skip_if_not_installed("digest")
  contract <- load_conquest_gpcm_overlap_contract()
  paths <- c(
    file.path(
      contract$root, "inst", "validation",
      "conquest-gpcm-overlap-contract-0.2.3.R"
    ),
    file.path(
      contract$root, "inst", "validation",
      "conquest-gpcm-overlap-registry-0.2.3.csv"
    ),
    file.path(
      contract$root, "tests", "testthat",
      "test-conquest-gpcm-overlap-contract.R"
    )
  )
  record <- paste(
    readLines(
      file.path(
        contract$root, "inst", "validation",
        "conquest-gpcm-overlap-record-0.2.3.md"
      ),
      warn = FALSE, encoding = "UTF-8"
    ),
    collapse = "\n"
  )
  hashes <- vapply(
    paths,
    function(path) tolower(digest::digest(file = path, algo = "sha256")),
    character(1)
  )
  expect_true(all(vapply(
    hashes, grepl, logical(1), x = record, fixed = TRUE
  )))
})
