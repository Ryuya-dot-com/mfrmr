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
