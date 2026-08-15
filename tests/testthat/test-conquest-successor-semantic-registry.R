load_conquest_successor_semantic_registry <- function() {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  validation <- file.path(root, "inst", "validation")
  source_path <- file.path(
    validation, "conquest-successor-semantic-registry-0.2.3.R"
  )
  skip_if_not(
    file.exists(source_path),
    "Repository-only ConQuest successor registry is excluded."
  )
  env <- new.env(parent = globalenv())
  sys.source(source_path, envir = env)
  list(root = root, validation = validation, source_path = source_path,
       env = env)
}

test_that("successor rows have one stratum, denominator, and decision", {
  ctx <- load_conquest_successor_semantic_registry()
  review <- ctx$env$mfrmr_cq_ssr_validate()
  registry <- review$registry

  expect_identical(nrow(registry), 23L)
  expect_identical(anyDuplicated(registry$RegistryRowId), 0L)
  expect_identical(
    as.integer(table(registry$ExpectedDisposition)),
    c(3L, 14L, 6L)
  )
  expect_true(all(registry$SemanticSignatureFrozen))
  expect_true(all(nzchar(registry$ComparisonStratum)))
  expect_true(all(nzchar(registry$FailureDenominator)))
  expect_true(all(nzchar(registry$DecisionConsequence)))
  expect_true(all(nzchar(registry$ClaimCeiling)))
  expect_true(all(nzchar(registry$ExpectedOutputSchema)))
  expect_true(all(nzchar(registry$AllowedObservedOutcomes)))
  prospective <- registry$ExpectedDisposition ==
    "prospective_numeric_comparison"
  expect_true(all(grepl(
    "unknown", registry$AllowedObservedOutcomes[prospective], fixed = TRUE
  )))
  expect_true(all(grepl(
    "iteration_history", registry$ExpectedOutputSchema[prospective],
    fixed = TRUE
  )))
  expect_false(any(registry$ExternalExecutionAuthorized))
  expect_false(any(registry$ComparisonPassed))
  expect_false(any(registry$ScientificEquivalenceInferred))
  expect_identical(
    review$status,
    "semantic_registry_ready_fixture_matrices_and_numeric_rules_pending"
  )
  expect_true(review$semantic_signature_ready)
  expect_true(review$negative_controls_ready)
  expect_false(review$fixture_identity_ready)
  expect_false(review$matrix_reconstruction_ready)
  expect_false(review$metric_specific_rules_ready)
  expect_false(review$P1_ready)
  expect_false(review$external_execution_authorized)
  expect_identical(nrow(review$denominator), 5L)
  expect_identical(sum(review$denominator$Freq), 23L)
})

test_that("each row exposes a reviewable human-readable signature", {
  ctx <- load_conquest_successor_semantic_registry()
  registry <- ctx$env$mfrmr_cq_ssr_registry()
  signatures <- lapply(
    registry$RegistryRowId,
    ctx$env$mfrmr_cq_ssr_human_signature,
    registry = registry
  )

  expect_true(all(vapply(signatures, nrow, integer(1L)) == 40L))
  expect_true(all(vapply(signatures, function(signature) {
    identical(signature$Field[1L], "RegistryRowId") &&
      all(nzchar(signature$Field)) && all(nzchar(signature$Value))
  }, logical(1L))))
  item_signature <- ctx$env$mfrmr_cq_ssr_human_signature(
    "P3-GPCM-NONUNIT-COVARIATE", registry
  )
  expect_identical(
    item_signature$Value[item_signature$Field == "ExpectedFreeDimension"],
    "17"
  )
  expect_identical(
    item_signature$Value[item_signature$Field == "SlopeOwner"], "Item"
  )
})

test_that("free dimensions are independently reproducible by stratum", {
  ctx <- load_conquest_successor_semantic_registry()
  registry <- ctx$env$mfrmr_cq_ssr_registry()
  dimension <- function(id) registry$ExpectedFreeDimension[
    registry$RegistryRowId == id
  ]

  expect_identical(dimension("P2-RSM-CONNECTED-MULTIBRIDGE"), 10L)
  expect_identical(dimension("P2-PCM-CONNECTED-MULTIBRIDGE"), 14L)
  expect_identical(dimension("P3-PCM-UNIT-SLOPE-INTERCEPT"), 13L)
  expect_identical(dimension("P3-GPCM-NONUNIT-INTERCEPT"), 16L)
  expect_identical(dimension("P3-GPCM-NONUNIT-COVARIATE"), 17L)
  expect_true(all(registry$ExpectedFreeDimension[
    registry$ComparisonStratum == "additive_rsm_pcm_mml" &
      registry$Family == "RSM"
  ] == 10L))
  expect_true(all(registry$ExpectedFreeDimension[
    registry$ComparisonStratum == "additive_rsm_pcm_mml" &
      registry$Family == "PCM"
  ] == 14L))
})

test_that("all required negative controls fail closed", {
  ctx <- load_conquest_successor_semantic_registry()
  registry <- ctx$env$mfrmr_cq_ssr_registry()
  negative <- registry[registry$CaseRole == "negative_control", , drop = FALSE]

  expect_setequal(
    negative$RegistryRowId,
    ctx$env$mfrmr_cq_ssr_required_negative_controls()
  )
  expect_true(all(
    negative$ExpectedDisposition == "reject_before_numeric_comparison"
  ))
  expect_true(all(grepl(
    "failure_path_only", negative$ClaimCeiling, fixed = TRUE
  )))

  category_mutation <- registry
  category_index <- category_mutation$RegistryRowId ==
    "P1-NEG-CATEGORY-MAP-MISMATCH"
  category_mutation$DeliberatelyObservedCategoryMap[category_index] <-
    category_mutation$ExpectedCategoryMap[category_index]
  expect_error(
    ctx$env$mfrmr_cq_ssr_validate(category_mutation),
    "category-map negative control"
  )

  dimension_mutation <- registry
  dimension_index <- dimension_mutation$RegistryRowId ==
    "P1-NEG-FREE-DIMENSION-MISMATCH"
  dimension_mutation$DeliberatelyObservedFreeDimension[dimension_index] <-
    dimension_mutation$ExpectedFreeDimension[dimension_index]
  expect_error(
    ctx$env$mfrmr_cq_ssr_validate(dimension_mutation),
    "free-dimension negative control"
  )

  output_mutation <- registry
  output_index <- output_mutation$RegistryRowId == "P1-NEG-MISSING-OUTPUT"
  output_mutation$DeliberatelyObservedOutputCount[output_index] <-
    output_mutation$ExpectedOutputCount[output_index]
  expect_error(
    ctx$env$mfrmr_cq_ssr_validate(output_mutation),
    "missing-output negative control"
  )
})

test_that("GPCM name similarity cannot transfer evidence across strata", {
  ctx <- load_conquest_successor_semantic_registry()
  registry <- ctx$env$mfrmr_cq_ssr_registry()
  item <- registry[registry$ComparisonStratum == "item_only_gpcm_mml", ]
  excluded <- registry[registry$CaseRole == "documented_nonoverlap", ]

  expect_identical(nrow(item), 2L)
  expect_true(all(item$SlopeOwner == "Item"))
  expect_true(all(item$StepOwner == "Item"))
  expect_true(all(item$LatentDimensionCount == 1L))
  expect_true(all(
    item$ExpectedDisposition == "prospective_numeric_comparison"
  ))
  expect_identical(nrow(excluded), 3L)
  expect_true(all(
    excluded$ExpectedDisposition ==
      "document_nonoverlap_no_numeric_comparison"
  ))
  expect_true(all(grepl(
    "none_numeric", excluded$EligibleParametersAndDecisions, fixed = TRUE
  )))
  expect_true(any(grepl(
    "JML", excluded$DecisionConsequence, fixed = TRUE
  )))
  expect_true(any(excluded$LatentDimensionCount == 2L))
})

test_that("the semantic registry is offline and contains no local engine path", {
  ctx <- load_conquest_successor_semantic_registry()
  source <- paste(readLines(ctx$source_path, warn = FALSE), collapse = "\n")

  expect_false(grepl("system2\\s*\\(|system\\s*\\(", source, perl = TRUE))
  expect_false(grepl("/Applications/ConQuest", source, fixed = TRUE))
  expect_false(grepl("SHA-256", source, fixed = TRUE))
  expect_false(grepl("ScientificEquivalenceInferred <- TRUE", source,
                     fixed = TRUE))
})

test_that("the P1 record and roadmap preserve pending gates", {
  ctx <- load_conquest_successor_semantic_registry()
  record_path <- file.path(
    ctx$validation,
    "conquest-successor-semantic-registry-record-0.2.3.md"
  )
  roadmap_path <- file.path(ctx$validation, "internal-roadmap-0.2.3.md")
  expect_true(all(file.exists(c(record_path, roadmap_path))))
  record <- paste(readLines(record_path, warn = FALSE), collapse = "\n")
  roadmap <- paste(readLines(roadmap_path, warn = FALSE), collapse = "\n")

  expected <- c(
    ctx$env$mfrmr_cq_ssr_specification,
    ctx$env$mfrmr_cq_ssr_contract,
    "Prospective numerical comparison | 14",
    "Negative control | 6",
    "Documented non-overlap/unsupported | 3",
    "P1_ready=FALSE",
    "ExternalExecutionAuthorized=FALSE",
    "ScientificEquivalenceInferred=FALSE"
  )
  expect_true(all(vapply(
    expected, grepl, logical(1L), x = record, fixed = TRUE
  )))
  expect_match(
    record,
    "fixture identities, independent A/C matrices",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Bind the disjoint fixtures and independently reconstruct",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Freeze metric-specific acceptance",
    fixed = TRUE
  )
  expect_match(
    roadmap,
    "[ ] Close P1 only after",
    fixed = TRUE
  )
})
