conquest_additive_validation_dir <- function() {
  candidates <- c(
    file.path("inst", "validation"),
    testthat::test_path("..", "..", "inst", "validation")
  )
  candidates <- candidates[dir.exists(candidates)]
  if (length(candidates) == 0L) return(NA_character_)
  candidates[1]
}

load_conquest_additive_design <- function() {
  testthat::skip_if_not_installed("digest")
  validation_dir <- conquest_additive_validation_dir()
  testthat::skip_if(
    is.na(validation_dir),
    "Repository-only ConQuest additive files are unavailable."
  )
  env <- new.env(parent = globalenv())
  script <- file.path(
    validation_dir, "conquest-additive-mfrm-design-0.2.3.R"
  )
  sys.source(script, envir = env)
  list(env = env, script = script)
}

test_that("the additive fixture is complete, connected, and supported", {
  env <- load_conquest_additive_design()$env
  set.seed(9876)
  before <- .Random.seed
  fixture <- env$mfrmr_cq_additive_fixture()
  expect_identical(.Random.seed, before)

  expect_identical(fixture$seed, 20260846L)
  expect_identical(sort(unique(fixture$wide$X)), c(-1, 1))
  expect_equal(nrow(fixture$long), 384L)
  expect_equal(nrow(fixture$wide), 96L)
  expect_equal(length(fixture$raters), 2L)
  expect_equal(length(fixture$criteria), 2L)
  expect_identical(fixture$categories, 0:3)
  expect_identical(
    names(fixture$wide),
    c("Person", "X", fixture$response_names)
  )
  expect_equal(nrow(fixture$coverage), 16L)
  expect_gt(min(fixture$coverage$Freq), 0L)
  expect_gte(min(fixture$person_unique_categories), 2L)
  expect_equal(sum(fixture$generating$rater_severity), 0)
  expect_equal(sum(fixture$generating$criterion_difficulty), 0)
  expect_equal(
    unname(rowSums(fixture$generating$criterion_steps)),
    rep(0, 2L)
  )

  profile <- env$mfrmr_cq_additive_profile(fixture)
  expect_equal(profile$ObservedCellRate, 1)
  expect_true(profile$Connected)
  expect_equal(profile$RaterLoadMin, profile$RaterLoadMax)
  expect_equal(profile$CriterionLoadMin, profile$CriterionLoadMax)
  expect_equal(profile$AllMinimumPersons, 0L)
  expect_equal(profile$AllMaximumPersons, 0L)
})

test_that("RSM and PCM maps have independent free-dimension counts", {
  env <- load_conquest_additive_design()$env
  rsm <- env$mfrmr_cq_additive_parameter_map("RSM")
  pcm <- env$mfrmr_cq_additive_parameter_map("PCM")
  expect_identical(sort(stats::na.omit(rsm$FreeOrder)), 1:7)
  expect_identical(sort(stats::na.omit(pcm$FreeOrder)), 1:9)
  expect_equal(sum(rsm$ConstraintRole == "derived_sum_zero"), 3L)
  expect_equal(sum(pcm$ConstraintRole == "derived_sum_zero"), 4L)
  expect_true(all(!rsm$ComparisonEligible))
  expect_true(all(!pcm$ComparisonEligible))
  expect_true(all(
    rsm$NativeDesignMatrixRequired[rsm$ExportSource == "parameter_export"]
  ))
  expect_error(
    env$mfrmr_cq_additive_parameter_map("GPCM"),
    "RSM or PCM",
    fixed = TRUE
  )
})

test_that("the additive probability oracle has the declared orientation", {
  env <- load_conquest_additive_design()$env
  base <- env$mfrmr_cq_additive_probability(
    theta = c(-0.5, 0.5),
    rater_severity = c(0, 0),
    criterion_difficulty = c(0, 0),
    steps = c(-1, 0, 1)
  )
  harsh <- env$mfrmr_cq_additive_probability(
    theta = c(-0.5, 0.5),
    rater_severity = c(0.5, 0.5),
    criterion_difficulty = c(0, 0),
    steps = c(-1, 0, 1)
  )
  expected <- function(probability) as.vector(probability %*% 0:3)
  expect_equal(rowSums(base), rep(1, 2L))
  expect_equal(rowSums(harsh), rep(1, 2L))
  expect_true(all(expected(harsh) < expected(base)))
  expect_true(expected(base)[2] > expected(base)[1])
})

test_that("the additive command is explicit and never auto-executes", {
  loaded <- load_conquest_additive_design()
  env <- loaded$env
  fixture <- env$mfrmr_cq_additive_fixture()
  rsm <- env$mfrmr_cq_additive_command(
    "cq_additive_rsm_q031", "RSM", 31L, fixture$response_names
  )
  pcm <- env$mfrmr_cq_additive_command(
    "cq_additive_pcm_q061", "PCM", 61L, fixture$response_names
  )
  expect_true(any(grepl(
    "facets=criterion(2) rater(2)", rsm, fixed = TRUE
  )))
  expect_true(any(grepl(
    "model rater + criterion + step;", rsm, fixed = TRUE
  )))
  expect_true(any(grepl(
    "model rater + criterion + criterion*step;", pcm, fixed = TRUE
  )))
  expect_true(any(grepl("nodes=31,", rsm, fixed = TRUE)))
  expect_true(any(grepl("nodes=61,", pcm, fixed = TRUE)))
  expect_true(any(grepl("export amatrix", pcm, fixed = TRUE)))

  script_lines <- readLines(loaded$script, warn = FALSE)
  executable_calls <- grep(
    "system2\\s*\\(|system\\s*\\(",
    script_lines,
    perl = TRUE,
    value = TRUE
  )
  expect_length(executable_calls, 0L)
})

test_that("the prepared additive design validates but remains NO-GO", {
  env <- load_conquest_additive_design()$env
  output_dir <- tempfile("conquest-additive-design-")
  prepared <- env$mfrmr_prepare_conquest_additive_design(output_dir)
  expect_s3_class(prepared, "mfrmr_conquest_additive_design")
  expect_identical(
    prepared$status,
    "prepared_no_fit_external_execution_prohibited"
  )
  expect_equal(nrow(prepared$manifest), 4L)
  expect_equal(length(unique(prepared$manifest$WideSHA256)), 1L)
  expect_true(all(nchar(prepared$manifest$WideSHA256) == 64L))
  expect_true(all(prepared$manifest$RawTokenAuditRequired))
  expect_true(all(prepared$manifest$NativeDesignMatrixRequired))
  expect_true(all(!prepared$manifest$ExternalExecutionAuthorized))

  review <- env$mfrmr_validate_conquest_additive_design(output_dir)
  expect_true(review$DesignReady)
  expect_true(review$MathematicalMapReady)
  expect_true(review$RawTokenContractReady)
  expect_false(review$NativeDesignMatrixObserved)
  expect_false(review$MfrmrReferenceFitObserved)
  expect_false(review$ExternalExecutionAuthorized)
  expect_false(review$ComparisonReady)
  expect_identical(review$Decision, "no_go_design_only")
  expect_match(review$Reason, "candidate_unbound", fixed = TRUE)

  occupied <- tempfile("conquest-additive-occupied-")
  dir.create(occupied)
  marker <- file.path(occupied, "marker.txt")
  writeLines("preserve", marker)
  expect_error(
    env$mfrmr_prepare_conquest_additive_design(occupied),
    "absent or empty",
    fixed = TRUE
  )
  expect_identical(readLines(marker, warn = FALSE), "preserve")
})

test_that("prepared additive input tampering fails closed", {
  env <- load_conquest_additive_design()$env
  output_dir <- tempfile("conquest-additive-tamper-")
  prepared <- env$mfrmr_prepare_conquest_additive_design(output_dir)
  target <- file.path(output_dir, prepared$manifest$WideFile[1])
  lines <- readLines(target, warn = FALSE)
  lines[2] <- sub(",0,", ",3,", lines[2], fixed = TRUE)
  writeLines(lines, target, useBytes = TRUE)
  expect_error(
    env$mfrmr_validate_conquest_additive_design(output_dir),
    "artifact identity failed",
    fixed = TRUE
  )
})
