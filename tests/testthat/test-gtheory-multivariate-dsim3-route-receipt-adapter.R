gtheory_dsim3r_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
      "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
      "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
      "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
      "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
      paste0(
        "gtheory-multivariate-dsim3-covariance-distribution-binding-",
        "0.2.4.R"
      ),
      paste0(
        "gtheory-multivariate-dsim3-response-generator-adapter-",
        "0.2.4.R"
      ),
      paste0(
        "gtheory-multivariate-dsim3-route-receipt-adapter-",
        "0.2.4.R"
      )
    )
  )
}

load_gtheory_dsim3r <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3r_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 route adapter excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3r_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3r_manifest()
    manifest
  }
})

test_that("route/receipt contract keeps admission distinct from terminal", {
  env <- load_gtheory_dsim3r()
  manifest <- gtheory_dsim3r_manifest(env)
  contract <- manifest$Contract
  expect_invisible(env$mfrmr_gtds3r_assert_manifest(manifest))
  expect_identical(
    contract$ContractHash,
    "0b74d833dc9bff44e3eded32261258b8dbd5ca6a2a30805c871d2cc22c9d0129"
  )
  expect_identical(
    manifest$ManifestHash,
    "6a59dc1a7874f731554baff7a134b8b52ad18614e26ee80470d08ffbd8372e9f"
  )
  expect_false(contract$AdmissionIsTerminalState)
  expect_false(contract$CandidateTerminalReceiptRequiredBeforeBackendAttempt)
  expect_identical(
    contract$CandidateAdmissionState,
    "adapter_qualified_backend_call_withheld"
  )
  expect_false(contract$Planned855RngStreamAllowed)
  expect_false(contract$BackendCallAllowed)
  expect_false(contract$FitAllowed)
  expect_false(contract$MetricAllowed)
})

test_that("all candidate templates receive one shared-dataset route payload", {
  env <- load_gtheory_dsim3r()
  manifest <- gtheory_dsim3r_manifest(env)
  routes <- manifest$CandidateRouteAdmissionRegistry
  expect_identical(nrow(routes), 50L)
  route_counts <- table(routes$RouteId)
  expect_identical(
    as.integer(route_counts),
    c(8L, 42L)
  )
  expect_identical(
    names(route_counts),
    c("multivariate_lme4_restricted", "separate_univariate")
  )
  expect_identical(length(unique(routes$ShadowFixtureId)), 21L)
  expect_true(all(routes$ExactScenarioRouteAdapterReady))
  expect_true(all(routes$SharedDatasetIdentityPreserved))
  expect_true(all(routes$RouteAdmissionQualified))
  expect_true(all(!routes$CountsInExploratoryRouteDenominator))
  expect_true(all(!routes$TerminalReceiptRequiredNow))
  expect_true(all(!routes$TerminalReceiptIssued))
  expect_true(all(!routes$BackendCallCurrentlyAllowed))
  expect_true(all(!routes$BackendCallMade))
  expect_true(all(!routes$FitReturned))
  by_scenario <- split(routes, routes$ScenarioId)
  expect_true(all(vapply(by_scenario, function(rows) {
    length(unique(rows$ShadowFixtureId)) == 1L &&
      length(unique(rows$SharedDatasetHash)) == 1L
  }, logical(1L))))
  expect_identical(sum(routes$ObservedRowCount), 291908L)
  expect_identical(sum(routes$PayloadPartitionCount), 102L)
})

test_that("joint and separate adapters preserve the exact observed rows", {
  env <- load_gtheory_dsim3r()
  contract <- env$mfrmr_gtds3r_contract()
  plan <- env$mfrmr_gtds3e_plan()
  generation <- env$mfrmr_gtds3g_generate_profile(
    "D3-S001", validate = FALSE
  )
  candidates <- plan$RouteUnitRegistry[
    plan$RouteUnitRegistry$ScenarioId == "D3-S001" &
      plan$RouteUnitRegistry$Replicate == 1L &
      plan$RouteUnitRegistry$PlannedDisposition ==
        "qualification_candidate", , drop = FALSE
  ]
  lme4_unit <- candidates[
    candidates$RouteId == "multivariate_lme4_restricted", , drop = FALSE
  ]
  univariate_unit <- candidates[
    candidates$RouteId == "separate_univariate", , drop = FALSE
  ]
  joint <- env$mfrmr_gtds3r_route_payload(
    generation, lme4_unit, contract
  )
  separate <- env$mfrmr_gtds3r_route_payload(
    generation, univariate_unit, contract
  )
  expect_invisible(env$mfrmr_gtds3r_assert_route_payload(
    joint, generation, lme4_unit, contract
  ))
  expect_invisible(env$mfrmr_gtds3r_assert_route_payload(
    separate, generation, univariate_unit, contract
  ))
  expect_identical(names(joint$PayloadPartitions), "joint")
  expect_identical(names(separate$PayloadPartitions), c("S1", "S2"))
  expect_identical(joint$ObservedRowCount, 3200L)
  expect_identical(sum(separate$PartitionRowCounts), 3200L)
  expect_identical(joint$SharedDatasetHash, separate$SharedDatasetHash)
  expect_identical(
    sort(unlist(lapply(separate$PayloadPartitions, `[[`, "RowId"))),
    sort(joint$PayloadPartitions$joint$RowId)
  )
})

test_that("terminal semantics and present-tense cardinality are complete", {
  env <- load_gtheory_dsim3r()
  manifest <- gtheory_dsim3r_manifest(env)
  probes <- manifest$TerminalSemanticQualificationRegistry
  receipts <- manifest$TerminalReceiptRegistry
  accounting <- manifest$TerminalAccountingRegistry
  expect_identical(nrow(probes), 13L)
  expect_true(all(probes$TerminalStateQualified))
  expect_identical(sum(probes$ValidStateSchemaProbeConstructed), 12L)
  expect_identical(sum(probes$InvalidSentinelRejected), 1L)
  expect_true(all(!probes$SchemaProbeReceiptIssued))
  expect_identical(nrow(receipts), 181L)
  expect_identical(
    unname(table(receipts$TerminalState)),
    c(
      generation_complete = 21L,
      missing_contract_block_as_frozen = 112L,
      not_applicable_as_frozen = 8L,
      prefit_rejected_as_planned = 40L
    )
  )
  expect_identical(nrow(accounting), 273L)
  expect_identical(sum(accounting$RequiredTerminalCountNow == 1L), 181L)
  expect_identical(sum(accounting$RequiredTerminalCountNow == 0L), 92L)
  expect_true(all(accounting$ExactlyOneOrCorrectlyOpen))
  expect_identical(manifest$Summary$CandidateTerminalReceiptCount, 0L)
  expect_identical(manifest$Summary$PlannedDatasetTerminalReceiptCount, 0L)
  expect_true(manifest$Summary$RouteAdapterQualified)
  expect_true(manifest$Summary$TerminalReceiptAdapterQualified)
})

test_that("invalid states, duplicate receipts, and forged terminals fail closed", {
  env <- load_gtheory_dsim3r()
  manifest <- gtheory_dsim3r_manifest(env)
  expect_error(
    env$mfrmr_gtds3r_terminal_receipt(
      "integrity", "bad", "unrecorded_invalid", "test",
      env$mfrmr_gtds3r_hash("bad"), FALSE,
      execution_contract = env$mfrmr_gtds3e_contract(),
      contract = manifest$Contract
    ),
    "cannot produce"
  )
  duplicate <- rbind(
    manifest$TerminalReceiptRegistry,
    manifest$TerminalReceiptRegistry[1L, , drop = FALSE]
  )
  expect_error(
    env$mfrmr_gtds3r_validate_accounting(
      manifest$TerminalAccountingRegistry[c(
        "UnitNamespace", "UnitType", "UnitId", "UnitKey", "ScenarioId",
        "PlannedDisposition", "RequiredTerminalCountNow",
        "ExpectedTerminalStateNow", "CountsInRegisteredDenominator"
      )],
      duplicate
    ),
    "exactly one receipt"
  )
  candidate <- manifest$CandidateRouteAdmissionRegistry[1L, ]
  forged <- manifest$TerminalReceiptRegistry[1L, , drop = FALSE]
  forged$UnitNamespace <- "planned_route"
  forged$UnitType <- "route"
  forged$UnitId <- candidate$PlannedRouteUnitId
  forged$UnitKey <- paste("planned_route", forged$UnitId, sep = "::")
  expect_error(
    env$mfrmr_gtds3r_validate_accounting(
      manifest$TerminalAccountingRegistry[c(
        "UnitNamespace", "UnitType", "UnitId", "UnitKey", "ScenarioId",
        "PlannedDisposition", "RequiredTerminalCountNow",
        "ExpectedTerminalStateNow", "CountsInRegisteredDenominator"
      )],
      rbind(manifest$TerminalReceiptRegistry, forged)
    ),
    "correctly open"
  )
})

test_that("qualification never opens 855 or invokes an estimator", {
  env <- load_gtheory_dsim3r()
  manifest <- gtheory_dsim3r_manifest(env)
  expect_true(all(manifest$ShadowDatasetRegistry$ShadowSeed < 855000000L))
  expect_true(all(!manifest$ShadowDatasetRegistry$Planned855Identity))
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ExploratoryResponseGenerated)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$MetricComputed)
  expect_false(manifest$Summary$ResourceControllerQualified)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
  function_text <- vapply(
    manifest$ImplementationIdentity$FunctionName,
    function(name) paste(deparse(body(env[[name]])), collapse = "\n"),
    character(1L)
  )
  expect_false(any(grepl(
    "lme4::lmer\\s*\\(|glmmTMB::glmmTMB\\s*\\(|system2\\s*\\(",
    function_text, perl = TRUE
  )))
})

test_that("route/receipt manifest mutations are rejected", {
  env <- load_gtheory_dsim3r()
  manifest <- gtheory_dsim3r_manifest(env)
  altered <- manifest
  altered$CandidateRouteAdmissionRegistry$TerminalReceiptIssued[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtds3r_assert_manifest(altered),
    "manifest was altered"
  )
  altered <- manifest
  altered$TerminalReceiptRegistry$TerminalState[[1L]] <- "fit_failure"
  expect_error(
    env$mfrmr_gtds3r_assert_manifest(altered),
    "manifest was altered"
  )
  altered <- manifest
  altered$ParentExecutionPlanHash <- env$mfrmr_gtds3r_hash(
    "forged-parent"
  )
  fields <- env$mfrmr_gtds3r_manifest_fields()
  altered$ManifestHash <- env$mfrmr_gtds3r_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3r_assert_manifest(altered),
    "manifest was altered"
  )
  altered <- manifest
  altered$TerminalAccountingRegistry$RequiredTerminalCountNow[[1L]] <- 0L
  altered$ManifestHash <- env$mfrmr_gtds3r_hash(altered[fields])
  expect_error(
    env$mfrmr_gtds3r_assert_manifest(altered),
    "exactly one receipt"
  )
})
