facets_mfp_environment <- local({
  cache <- NULL
  function() {
    if (!is.null(cache)) return(cache)
    path <- testthat::test_path(
      "..", "..", "inst", "validation",
      "facets-multifacet-precision-contract-0.2.3.R"
    )
    expect_true(file.exists(path))
    cache <<- new.env(parent = globalenv())
    sys.source(path, envir = cache)
    cache
  }
})

test_that("multifacet registry separates dimensions, levels, rows, and topology", {
  env <- facets_mfp_environment()
  registry <- env$mfrmr_facets_mfp_registry()

  expect_true(env$mfrmr_facets_mfp_validate_registry(registry))
  expect_equal(nrow(registry), 16L)
  expect_equal(sort(unique(registry$TotalFacets)), 3:5)
  expect_equal(sort(unique(registry$Model)), c("PCM", "RSM"))
  expect_true(all(registry$NonPersonFacets == registry$TotalFacets - 1L))
  expect_true(all(registry$ScientificByteEqualityRequired == FALSE))
  expect_true(all(registry$RequestedMeasureDecimals == 8L))
  expect_true(all(registry$RequestedResidualDecimals == 8L))
  expect_true(all(registry$HighPrecisionOutputRequired))
  expect_true(all(registry$ActualPrecisionProbeRequired))
  expect_true(all(registry$MetricSpecificPrecisionRequired))
  expect_true(all(registry$ReportedNumericTokensRequired))
  expect_true(any(registry$Topology == "distributed_connected"))
  expect_true(any(registry$Topology == "two_blocks_few_link_persons"))
  expect_true(any(registry$Topology == "two_disconnected_components"))

  contract <- env$mfrmr_facets_mfp_contract()
  expect_s3_class(contract, "mfrmr_facets_mfp_contract")
  expect_true(contract$authorization$FACETSPrecisionQualificationCompleted)
  expect_true(
    contract$authorization$FACETSFixedInformationDimensionQualificationCompleted
  )
  expect_true(contract$authorization$FACETSStepCoordinateQualificationCompleted)
  expect_true(
    contract$authorization$FACETSCandidateLinkedMultiseedPilotCompleted
  )
  expect_true(contract$authorization$FACETSConfirmationDesignFrozen)
  expect_true(contract$authorization$FACETSNumericalAcceptanceRuleFrozen)
  expect_true(contract$authorization$NumericToleranceFrozen)
  expect_true(contract$authorization$ReplicationFrozen)
  expect_false(contract$authorization$FACETSConfirmationExecutionAuthorized)
  expect_false(contract$authorization$FACETSRegistryExecutionCompleted)
  expect_false(contract$authorization$FACETSExecutionAuthorized)
  expect_false(contract$authorization$EquivalenceClaimAuthorized)

  precision <- env$mfrmr_facets_mfp_precision_requirements()
  expect_equal(
    precision$Metric,
    c("Measure", "SE", "InfitMnSq", "OutfitMnSq", "InfitZSTD",
      "OutfitZSTD", "DF")
  )
  expect_equal(
    precision$RequestedDecimalsWhereConfigurable,
    c(8L, 8L, rep(NA_integer_, 5L))
  )
  expect_equal(precision$ConfigurationRoute[1:2], rep("Udecim=8", 2L))
  expect_true(all(grepl(
    "probe_actual_output$", precision$ConfigurationRoute[3:7]
  )))
  expect_true(all(precision$ActualReportedDecimalsRequired))
  expect_equal(
    precision$BoundaryFallback[precision$Metric %in% c("InfitZSTD", "OutfitZSTD")],
    rep("display_equality_indeterminate", 2L)
  )
})

test_that("displayed FACETS threshold equality remains in the denominator", {
  env <- facets_mfp_environment()
  path <- tempfile(fileext = ".csv")
  writeLines(c(
    "Facet,Level,Infit ZStd,Outfit ZStd",
    "Rater,R1,2.0,1.9",
    "Rater,R2,-2.00,2.1",
    "Rater,R3,1.8,-1.7",
    "Rater,R4,>2.0,1.6"
  ), path)
  imported <- mfrmr::read_facets_fit_table(path)
  review <- env$mfrmr_facets_mfp_precision_review(imported)
  normalized <- mfrmr:::normalize_facets_fit_frame(imported)
  quality <- mfrmr:::summarize_external_facets_fit_quality(normalized)

  expect_equal(review$Rows, 4L)
  expect_equal(review$ReportedTokenRows, 4L)
  expect_equal(review$ZSTDBoundaryRows, 1L)
  expect_equal(review$InvalidTokenRows, 1L)
  expect_equal(review$ThresholdClassifiableRows, 2L)
  expect_false(review$ThresholdAgreementEligible)
  expect_false(review$HiddenValueEqualityClaimAuthorized)
  expect_equal(quality$ReportedTokenRows, 4L)
  expect_equal(quality$ZSTDBoundaryRows, 1L)

  direct_character <- mfrmr:::normalize_facets_fit_frame(data.frame(
    Facet = "Rater", Level = "R5", InfitZSTD = "2.00", OutfitZSTD = "1.80",
    stringsAsFactors = FALSE
  ))
  expect_identical(
    direct_character$FACETS_SourcePrecisionStatus,
    "reported_tokens_retained"
  )
  expect_identical(direct_character$FACETS_InfitZSTDRaw, "2.00")
  expect_identical(
    direct_character$FACETS_ZSTDDisplayFlagState,
    "display_boundary_indeterminate"
  )
})

test_that("numeric-only FACETS input cannot claim reported precision", {
  env <- facets_mfp_environment()
  imported <- mfrmr::read_facets_fit_table(data.frame(
    Facet = "Rater",
    Level = "R1",
    InfitZSTD = 2,
    OutfitZSTD = 1.9
  ))
  review <- env$mfrmr_facets_mfp_precision_review(imported)

  expect_equal(review$ReportedTokenRows, 0L)
  expect_equal(review$NumericOnlyRows, 1L)
  expect_false(review$ThresholdAgreementEligible)
})

test_that("reported-decimal comparisons use resolution without inventing rounding", {
  env <- facets_mfp_environment()
  review <- env$mfrmr_facets_mfp_display_resolution(
    c("0.10", "0.1000", "bad"),
    c(0.104, 0.104, 0.1)
  )

  expect_equal(review$ReportedDecimals, c(2L, 4L, NA_integer_))
  expect_equal(review$DisplayedUnit[1:2], c(0.01, 0.0001))
  expect_equal(
    review$DisplayResolutionStatus,
    c("within_one_displayed_unit", "outside_one_displayed_unit", "not_comparable")
  )
  expect_true(all(review$RoundingRuleAssumed == FALSE))
  expect_true(all(review$HiddenValueEqualityClaimAuthorized == FALSE))
  expect_error(
    env$mfrmr_facets_mfp_display_resolution(c("0.1", "0.2"), 0.1),
    "equal lengths"
  )
})

test_that("multifacet smoke generator preserves RNG and declared dimensions", {
  env <- facets_mfp_environment()
  set.seed(991L)
  before <- .Random.seed
  designs <- lapply(3:5, function(total) {
    env$mfrmr_facets_mfp_smoke_design(total, model = "PCM", seed = 451000L + total)
  })
  expect_identical(.Random.seed, before)

  for (i in seq_along(designs)) {
    design <- designs[[i]]
    expect_equal(length(design$facet_names), i + 1L)
    expect_equal(nrow(design$data), 40L * 16L)
    cell_key <- do.call(
      paste,
      c(design$data[c("Person", design$facet_names)], sep = "\r")
    )
    expect_false(anyDuplicated(cell_key) > 0L)
    expect_equal(sort(unique(design$data$Score)), 0:3)
    expect_true(all(c("Person", design$facet_names, "Score") %in% names(design$data)))
  }

  coupled <- lapply(3:5, function(total) {
    env$mfrmr_facets_mfp_smoke_design(total, model = "RSM", seed = 451999L)
  })
  for (design in coupled[-1L]) {
    expect_identical(design$truth$Person, coupled[[1L]]$truth$Person)
    expect_identical(design$truth$Rater, coupled[[1L]]$truth$Rater)
    expect_identical(design$truth$Criterion, coupled[[1L]]$truth$Criterion)
  }
})

test_that("external pilot writer emits genuine multifacet FACETS controls", {
  env <- facets_mfp_environment()
  design <- env$mfrmr_facets_mfp_smoke_design(
    total_facets = 5L, model = "PCM", seed = 451002L
  )
  case_dir <- tempfile("facets-mfp-external-")
  case <- env$mfrmr_facets_mfp_write_external_case(
    design, model = "PCM", case_dir = case_dir
  )
  control <- readLines(case$control_path, warn = FALSE)
  data_lines <- readLines(case$data_path, warn = FALSE)

  expect_true("Facets = 5" %in% control)
  expect_true("Models = ?,?,?,?,#,R3" %in% control)
  expect_true("Umean = 0, 1, 8" %in% control)
  expect_true("Iterations = 0" %in% control)
  expect_true("Convergence = .01, .0001" %in% control)
  expect_true(any(startsWith(control, "Graphfile = ")))
  expect_true(any(startsWith(control, "Anchorfile = ")))
  expect_equal(case$facet_names,
               c("Person", "Rater", "Task", "Occasion", "Criterion"))
  expect_equal(length(strsplit(data_lines[1], ",", fixed = TRUE)[[1]]), 6L)
  expect_gt(length(case$level_maps$Task), 1L)
  expect_gt(length(case$level_maps$Occasion), 1L)
  expect_error(
    env$mfrmr_facets_mfp_write_external_case(
      design, model = "PCM", case_dir = case_dir
    ),
    "absent or empty"
  )

  expected_external <- do.call(rbind, lapply(case$facet_names, function(facet) {
    data.frame(
      Facet = facet,
      Level = unique(as.character(design$data[[facet]])),
      Estimate = 0,
      stringsAsFactors = FALSE
    )
  }))
  coordinate_contract <- env$mfrmr_facets_mfp_external_coordinate_contract(
    design, expected_external
  )
  expect_true(coordinate_contract$passed)
  expect_equal(coordinate_contract$expected_coordinates, 53L)
  expect_equal(coordinate_contract$imported_coordinates, 53L)
  duplicated_external <- rbind(expected_external, expected_external[1, ])
  expect_false(env$mfrmr_facets_mfp_external_coordinate_contract(
    design, duplicated_external
  )$passed)
})

test_that("external multifacet pilot is dry-run by default", {
  env <- facets_mfp_environment()
  work_dir <- tempfile("facets-mfp-pilot-")
  pilot <- env$mfrmr_run_facets_mfp_external_pilot(
    facets_exe = "deliberately-missing-facets.exe",
    work_dir = work_dir,
    execute = FALSE,
    total_facets = 4L,
    models = c("RSM", "PCM")
  )

  expect_false(pilot$executed)
  expect_equal(nrow(pilot$manifest), 2L)
  expect_equal(pilot$manifest$BaseSeed, rep(451001L, 2L))
  expect_equal(pilot$manifest$DesignSeed, c(451002L, 451003L))
  expect_true(all(!pilot$manifest$ExecuteRequested))
  expect_true(all(!pilot$manifest$FACETSReportPresent))
  expect_equal(pilot$manifest$ExpectedCoordinates, rep(51L, 2L))
  expect_equal(pilot$manifest$ExpectedStepCoordinates, c(3L, 12L))
  expect_true(all(is.na(pilot$manifest$CoordinateContractPassed)))
  expect_true(all(is.na(pilot$manifest$StepCoordinateContractPassed)))
  expect_equal(
    pilot$manifest$FACETSConvergenceRequested,
    rep("0.01,0.0001,0,0", 2L)
  )
  expect_true(all(is.na(pilot$manifest$FACETSConvergenceContractPassed)))
  expect_true(all(is.na(pilot$manifest$FACETSConvergenceAchieved)))
  expect_true(all(!pilot$manifest$ComparisonEligible))
  expect_true(all(!pilot$manifest$ConfirmationAuthorized))
  expect_true(all(!pilot$manifest$EquivalenceClaimAuthorized))
  expect_equal(nrow(pilot$metrics), 0L)
  expect_equal(nrow(pilot$step_comparisons), 0L)
  expect_true(all(file.exists(file.path(
    work_dir, c("rsm-f4", "pcm-f4"), "facets_control.txt"
  ))))
  expect_error(
    env$mfrmr_run_facets_mfp_external_pilot(
      facets_exe = "deliberately-missing-facets.exe",
      work_dir = tempfile("facets-mfp-pilot-"),
      execute = TRUE,
      total_facets = 4L
    ),
    "executable was not found"
  )
})

test_that("external multiseed pilot preserves explicit seed provenance", {
  env <- facets_mfp_environment()
  work_dir <- tempfile("facets-mfp-multiseed-")
  pilot <- env$mfrmr_run_facets_mfp_external_multiseed_pilot(
    facets_exe = "deliberately-missing-facets.exe",
    work_dir = work_dir,
    base_seeds = c(452001L, 452101L),
    execute = FALSE,
    total_facets = 3L,
    models = "PCM"
  )

  expect_false(pilot$executed)
  expect_true(pilot$candidate_linked_pilot)
  expect_false(pilot$confirmation_authorized)
  expect_equal(pilot$base_seeds, c(452001L, 452101L))
  expect_equal(pilot$manifest$BaseSeed, c(452001L, 452101L))
  expect_equal(pilot$manifest$DesignSeed, c(452003L, 452103L))
  expect_equal(pilot$manifest$ExpectedStepCoordinates, rep(12L, 2L))
  expect_equal(nrow(pilot$metrics), 0L)
  expect_equal(nrow(pilot$step_comparisons), 0L)
  expect_true(all(file.exists(file.path(
    work_dir,
    paste0("seed-", c(452001L, 452101L)),
    "pcm-f3",
    "facets_control.txt"
  ))))
  expect_error(
    env$mfrmr_run_facets_mfp_external_multiseed_pilot(
      facets_exe = "deliberately-missing-facets.exe",
      work_dir = tempfile("facets-mfp-multiseed-"),
      base_seeds = c(1L, 1L)
    ),
    "unique finite integers"
  )
})

test_that("FACETS anchor steps are matched by explicit scale coordinates", {
  env <- facets_mfp_environment()
  anchor_path <- tempfile(fileext = ".anc")
  writeLines(c(
    "Rating (or partial credit) scale = RS2,R3,G,O",
    " 0=,0,A",
    " 1=,-1.1000000,A",
    " 2=,0.2000000,A",
    " 3=,0.9000000,A",
    " ; Rasch-Andrich Thresholds =0, -1.1000000, 0.2000000, 0.9000000",
    "*",
    "Rating (or partial credit) scale = RS1,R3,G,O",
    " 0=,0,A",
    " 1=,-0.8000000,A",
    " 2=,-0.1000000,A",
    " 3=,0.9000000,A",
    " ; Rasch-Andrich Thresholds =0, -0.8000000, -0.1000000, 0.9000000",
    "*"
  ), anchor_path)

  external <- env$mfrmr_facets_mfp_read_anchor_steps(
    anchor_path, c(C01 = 1L, C02 = 2L)
  )
  expect_equal(nrow(external), 6L)
  expect_equal(external$StepFacet, rep(c("C01", "C02"), each = 3L))
  expect_equal(external$Step, rep(paste0("Step_", 1:3), 2L))
  expect_equal(external$FACETSScale, rep(c("RS1", "RS2"), each = 3L))
  expect_equal(external$ReportedDecimals, rep(7L, 6L))

  fit <- list(steps = external[, c("StepFacet", "Step", "Estimate")])
  comparison <- env$mfrmr_facets_mfp_compare_steps(fit, external)
  expect_true(comparison$passed)
  expect_equal(comparison$matched_coordinates, 6L)
  expect_equal(comparison$comparison$AbsoluteDifference, rep(0, 6L))

  duplicated <- rbind(external, external[1L, ])
  expect_false(env$mfrmr_facets_mfp_compare_steps(fit, duplicated)$passed)
  expect_error(
    env$mfrmr_facets_mfp_read_anchor_steps(
      anchor_path, c(C01 = 1L, C02 = 3L)
    ),
    "scale contract failed"
  )
})

test_that("FACETS convergence is verified from the report", {
  env <- facets_mfp_environment()
  report_path <- tempfile(fileext = ".txt")
  writeLines(c(
    "Convergence = 0.01, 0.0001, 0, 0 ; requested criteria",
    "Iterations (maximum) = 0",
    "| JMLE  25       .0070    .0     -.0023     -.0001   -.0001 |"
  ), report_path)
  passed <- env$mfrmr_facets_mfp_convergence_contract(report_path)
  expect_true(passed$specification_passed)
  expect_true(passed$achieved)
  expect_true(passed$passed)
  expect_equal(passed$final_iteration, 25L)
  expect_equal(passed$final_element_score_residual, 0.007)

  writeLines(c(
    "Convergence = 0.01, 0.0001, 0, 0",
    "| JMLE  75       .0825    .0      .0022      .0000    .0000 |"
  ), report_path)
  stalled <- env$mfrmr_facets_mfp_convergence_contract(report_path)
  expect_true(stalled$specification_passed)
  expect_false(stalled$achieved)
  expect_false(stalled$passed)

  writeLines(c(
    "Convergence = 0.5, 0.01, 0, 0",
    "| JMLE  14       .4470    .1     -.1162     -.0057   -.0036 |"
  ), report_path)
  expect_false(env$mfrmr_facets_mfp_convergence_contract(report_path)$passed)
  expect_false(env$mfrmr_facets_mfp_convergence_contract(
    tempfile(fileext = ".txt")
  )$passed)
})

test_that("multifacet capture retains rather than hides errors and warnings", {
  env <- facets_mfp_environment()
  warned <- env$mfrmr_facets_mfp_capture({
    warning("visible warning")
    3L
  })
  failed <- env$mfrmr_facets_mfp_capture(stop("visible error"))

  expect_identical(warned$value, 3L)
  expect_match(warned$warnings, "visible warning")
  expect_null(failed$value)
  expect_match(failed$error, "visible error")
})
