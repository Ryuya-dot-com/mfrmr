facets_mfs_environment <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) return(cache)
    cache <<- new.env(parent = globalenv())
    validation_dir <- testthat::test_path("..", "..", "inst", "validation")
    files <- c(
      "facets-multifacet-precision-contract-0.2.3.R",
      "facets-multifacet-pilot-adapter-0.2.3.R",
      "facets-rsm-pcm-stress-envelope-0.2.3.R"
    )
    paths <- file.path(validation_dir, files)
    expect_true(all(file.exists(paths)))
    for (path in paths) sys.source(path, envir = cache)
    cache
  }
})

test_that("stress registry separates capacity, sparsity, and facet count", {
  env <- facets_mfs_environment()
  registry <- env$mfrmr_facets_mfs_registry()

  expect_true(env$mfrmr_facets_mfs_validate_registry(registry))
  expect_equal(nrow(registry), 6L)
  expect_equal(sort(unique(registry$TotalFacets)), c(5L, 10L, 30L))
  expect_true(all(registry$TargetRows ==
                    registry$Persons * registry$RowsPerPerson))
  expect_equal(sum(registry$StressAxis == "capacity"), 1L)
  expect_equal(sum(registry$StressAxis == "sparse_topology"), 2L)
  expect_equal(sum(registry$StressAxis == "negative_control"), 1L)
  expect_equal(sum(registry$StressAxis == "facet_count"), 2L)
})

test_that("many-facet generator is reproducible without changing caller RNG", {
  env <- facets_mfs_environment()
  set.seed(771L)
  before <- .Random.seed
  design <- env$mfrmr_facets_mfs_design(
    "MFS-MANY-F30", model = "PCM", seed = 451003L
  )

  expect_identical(.Random.seed, before)
  expect_equal(design$total_facets, 30L)
  expect_equal(length(design$facet_names), 29L)
  expect_equal(nrow(design$data), 12800L)
  expect_equal(sort(unique(design$data$Score)), 0:3)
  expect_equal(nrow(design$truth$Steps), 18L)
  key <- do.call(
    paste,
    c(design$data[c("Person", design$facet_names)], sep = "\r")
  )
  expect_false(anyDuplicated(key) > 0L)
  expect_identical(
    design$data,
    env$mfrmr_facets_mfs_design(
      "MFS-MANY-F30", model = "PCM", seed = 451003L
    )$data
  )
})

test_that("stress preflight opens no files and rejects protected seeds", {
  env <- facets_mfs_environment()
  work_dir <- tempfile("facets-mfs-preflight-")
  result <- env$mfrmr_run_facets_mfs_pilot(
    facets_exe = "deliberately-missing-facets.exe",
    work_dir = work_dir,
    base_seed = 451001L,
    scenario_ids = c("MFS-LARGE-F5", "MFS-MANY-F30"),
    models = c("RSM", "PCM")
  )

  expect_s3_class(result, "mfrmr_facets_mfs_result")
  expect_false(dir.exists(work_dir))
  expect_equal(nrow(result$manifest), 4L)
  expect_true(all(result$manifest$ExecutionStatus == "not_run"))
  expect_true(all(!result$manifest$FileHashUsed))
  expect_false(result$decision$ExternalExecutionRequested)
  expect_false(result$decision$BiasIsMonteCarloEstimate)
  expect_false(result$decision$ConfirmationOutcomeOpened)
  expect_false(result$decision$FACETSReplacementClaimAuthorized)
  expect_error(
    env$mfrmr_run_facets_mfs_pilot(
      facets_exe = "deliberately-missing-facets.exe",
      work_dir = tempfile("facets-mfs-preflight-"),
      base_seed = 460001L,
      scenario_ids = "MFS-LARGE-F5",
      models = "RSM"
    ),
    "confirmation seeds are not permitted"
  )
})

test_that("injected many-facet design reuses the semantic FACETS runner", {
  env <- facets_mfs_environment()
  work_dir <- tempfile("facets-mfs-injected-")
  builder <- function(total_facets, model, seed) {
    env$mfrmr_facets_mfs_design("MFS-MANY-F10", model, seed)
  }
  result <- env$mfrmr_run_facets_mfp_external_pilot(
    facets_exe = "deliberately-missing-facets.exe",
    work_dir = work_dir,
    execute = FALSE,
    total_facets = 10L,
    models = "RSM",
    design_builder = builder
  )

  expect_equal(nrow(result$manifest), 1L)
  expect_equal(result$manifest$TotalFacets, 10L)
  expect_equal(result$manifest$Rows, 6400L)
  expect_equal(result$manifest$ExpectedCoordinates, 228L)
  expect_equal(result$manifest$ExpectedStepCoordinates, 3L)
  control <- readLines(file.path(
    work_dir, "rsm-f10", "facets_control.txt"
  ), warn = FALSE)
  expect_true("Facets = 10" %in% control)
  expect_true("Models = ?,?,?,?,?,?,?,?,?,?,R3" %in% control)
  expect_error(
    env$mfrmr_run_facets_mfp_external_pilot(
      facets_exe = "deliberately-missing-facets.exe",
      work_dir = tempfile("facets-mfs-injected-"),
      execute = FALSE, total_facets = 10L, models = "RSM"
    ),
    "3, 4, and 5"
  )
})

test_that("truth recovery retains engine, parameter block, bias, and RMSE", {
  env <- facets_mfs_environment()
  design <- env$mfrmr_facets_mfs_design(
    "MFS-MANY-F10", model = "RSM", seed = 451002L
  )
  truth <- env$mfrmr_facets_mfs_truth_table(design, "element")
  coordinates <- data.frame(
    truth[, c("Facet", "Level")],
    MfrmrEstimate = truth$TrueValue + 0.1,
    FACETSEstimate = truth$TrueValue - 0.2,
    stringsAsFactors = FALSE
  )
  coordinates$Difference <- 0.3
  coordinates$AbsoluteDifference <- 0.3
  recovery <- env$mfrmr_facets_mfs_recovery_rows(
    coordinates, design, "element"
  )
  summary <- env$mfrmr_facets_mfs_summarize_recovery(recovery)

  expect_equal(sort(unique(recovery$Engine)), c("FACETS", "mfrmr"))
  expect_equal(
    recovery$Error[recovery$Engine == "mfrmr"],
    rep(0.1, sum(recovery$Engine == "mfrmr"))
  )
  expect_equal(
    recovery$Error[recovery$Engine == "FACETS"],
    rep(-0.2, sum(recovery$Engine == "FACETS"))
  )
  expect_true(all(c("Bias", "MAE", "RMSE") %in% names(summary)))
  expect_equal(
    summary$RMSE[summary$Engine == "mfrmr"],
    rep(0.1, sum(summary$Engine == "mfrmr"))
  )
  expect_equal(
    summary$RMSE[summary$Engine == "FACETS"],
    rep(0.2, sum(summary$Engine == "FACETS"))
  )
})

test_that("independent mfrmr recovery is not gated by FACETS availability", {
  env <- facets_mfs_environment()
  design <- env$mfrmr_facets_mfs_design(
    "MFS-MANY-F10", model = "RSM", seed = 451002L
  )
  person_truth <- design$truth$Person
  other_rows <- do.call(rbind, lapply(design$facet_names, function(facet) {
    values <- design$truth[[facet]]
    data.frame(
      Facet = facet, Level = names(values), Estimate = as.numeric(values),
      stringsAsFactors = FALSE
    )
  }))
  fit <- list(
    summary = data.frame(
      ConvergenceCode = 0L, Converged = TRUE,
      TerminalGradientSupNorm = 5e-5, GradientReviewTolerance = 1e-4
    ),
    facets = list(
      person = data.frame(
        Person = names(person_truth), Estimate = as.numeric(person_truth),
        ParameterStatus = "estimable", stringsAsFactors = FALSE
      ),
      others = other_rows
    ),
    steps = design$truth$Steps
  )
  result <- env$mfrmr_facets_mfs_fit_mfrmr(
    design, existing_fit = fit
  )

  expect_true(result$fit_returned)
  expect_true(result$numerical_gate_passed)
  expect_false(result$independently_attempted)
  expect_equal(nrow(result$recovery), 228L + 3L)
  expect_true(all(result$recovery$RecoveryEligible))
  expect_equal(result$recovery$Error, rep(0, nrow(result$recovery)))
  expect_identical(
    env$mfrmr_facets_mfs_collapse_messages(c("", NA, "first", "first")),
    "first"
  )
})

test_that("stationarity audit separates gradient checks from readiness", {
  env <- facets_mfs_environment()
  fit <- make_toy_fit(maxit = 25L, model = "RSM")
  audit <- env$mfrmr_facets_mfs_jml_stationarity_audit(
    fit, max_numeric_probes = 4L
  )

  expect_s3_class(audit, "mfrmr_facets_mfs_stationarity_audit")
  expect_true(audit$summary$ObjectiveReconstructionAgrees)
  expect_true(audit$summary$NumericGradientAgrees)
  expect_true(audit$summary$ReplicationTransportAgrees)
  expect_false(audit$summary$ReadinessChanged)
  expect_false(audit$summary$FACETSStoppingRuleApplied)
  expect_identical(audit$summary$DecisionUse, "diagnostic_only")
  expect_equal(nrow(audit$numeric_probes), 4L)
  expect_true(all(is.finite(audit$numeric_probes$NumericGradient)))
  expect_true(all(audit$numeric_probes$ScaledDifference <= 1e-6))
  expect_equal(audit$replication_transport$ReplicationFactor, c(1L, 2L, 10L))
  expect_equal(
    audit$replication_transport$GradientSupNorm,
    audit$summary$TerminalGradientSupNorm * c(1, 2, 10),
    tolerance = 1e-12
  )
  expect_true(all(audit$replication_transport$SameMLESetByConstantScaling))
  expect_true(all(!audit$replication_transport$ReadinessChanged))

  gate_fixture <- fit
  gate_fixture$summary$GradientReviewTolerance <-
    1.5 * audit$summary$TerminalGradientSupNorm
  gate_audit <- env$mfrmr_facets_mfs_jml_stationarity_audit(gate_fixture)
  expect_identical(
    gate_audit$replication_transport$RawGradientGatePassed,
    c(TRUE, FALSE, FALSE)
  )
  expect_false(
    gate_audit$summary$RawGradientGateStableAcrossRequestedReplication
  )
  expect_true(all(c("theta", "steps") %in%
                    audit$free_gradient_blocks$Block))
  expect_equal(
    nrow(audit$expanded_element_residuals),
    nrow(fit$facets$person) + nrow(fit$facets$others)
  )
  expect_true(all(audit$expanded_element_residuals$Observations > 0L))

  wrong_method <- fit
  wrong_method$config$method <- "MML"
  expect_error(
    env$mfrmr_facets_mfs_jml_stationarity_audit(wrong_method),
    "requires an RSM or PCM JML fit"
  )
  expect_error(
    env$mfrmr_facets_mfs_jml_stationarity_audit(
      fit, numeric_relative_step = 0
    ),
    "finite positive scalars"
  )
  expect_error(
    env$mfrmr_facets_mfs_jml_stationarity_audit(
      fit, replication_factors = c(1, 1)
    ),
    "finite positive scalars"
  )
})

test_that("information displacement is correlated and replication invariant", {
  env <- facets_mfs_environment()
  fit <- make_toy_fit(maxit = 25L, model = "RSM")
  audit <- env$mfrmr_facets_mfs_information_displacement_audit(fit)

  expect_s3_class(
    audit, "mfrmr_facets_mfs_information_displacement_audit"
  )
  expect_identical(audit$summary$Status, "evaluated_positive_definite")
  expect_true(audit$summary$Evaluated)
  expect_true(audit$summary$HessianPositiveDefiniteAtTolerance)
  expect_true(audit$summary$ReplicationDisplacementStable)
  expect_false(audit$summary$ReadinessChanged)
  expect_false(audit$summary$ParameterDisplacementThresholdSelected)
  expect_identical(audit$summary$DecisionUse, "diagnostic_only")
  expect_equal(audit$hessian, t(audit$hessian), tolerance = 0)
  expect_equal(
    dim(audit$hessian),
    rep(audit$summary$FreeCoordinates, 2L)
  )
  expect_true(all(audit$eigenvalues > 0))
  expect_gt(audit$summary$FullNewtonParameterChangeSupNorm, 0)
  expect_gt(audit$summary$ActualObjectiveImprovement, 0)
  expect_lte(
    max(audit$replication_transport$MaximumDifferenceFromBase), 1e-12
  )
  expect_true(all(audit$replication_transport$SameMLESetByConstantScaling))

  wider_step <- env$mfrmr_facets_mfs_information_displacement_audit(
    fit, difference_step = 3e-3
  )
  expect_lt(
    abs(wider_step$summary$FullNewtonParameterChangeSupNorm -
          audit$summary$FullNewtonParameterChangeSupNorm) /
      audit$summary$FullNewtonParameterChangeSupNorm,
    1e-3
  )

  limited <- env$mfrmr_facets_mfs_information_displacement_audit(
    fit, max_free_dimension = 1L
  )
  expect_identical(
    limited$summary$Status, "not_evaluated_dimension_limit"
  )
  expect_false(limited$summary$Evaluated)
  expect_null(limited$hessian)
  expect_false(limited$summary$ReadinessChanged)
  expect_error(
    env$mfrmr_facets_mfs_information_displacement_audit(
      fit, replication_factors = c(1, 1)
    ),
    "controls are invalid"
  )
})

test_that("stress envelope contains no cryptographic file identity operation", {
  path <- testthat::test_path(
    "..", "..", "inst", "validation",
    "facets-rsm-pcm-stress-envelope-0.2.3.R"
  )
  source_text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_false(grepl(
    "digest::|sha256|sha-256|md5sum", source_text, ignore.case = TRUE
  ))
  env <- facets_mfs_environment()
  expect_error(
    env$mfrmr_run_mfs_mfrmr_only(
      scenario_ids = "MFS-MANY-F10", models = "RSM", maxit = 0L
    ),
    "positive finite integer"
  )
})
