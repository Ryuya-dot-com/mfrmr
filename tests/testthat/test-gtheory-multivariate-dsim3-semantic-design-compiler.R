gtheory_dsim3c_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
      "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
      "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
      "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
      "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R"
    )
  )
}

load_gtheory_dsim3c <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3c_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 compiler excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3c_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3c_manifest()
    manifest
  }
})

test_that("semantic compiler freezes one package-level rule system", {
  env <- load_gtheory_dsim3c()
  contract <- env$mfrmr_gtds3c_contract()
  expect_invisible(env$mfrmr_gtds3c_validate_contract(contract))
  expect_s3_class(contract, "mfrmr_gtds3c_contract")
  expect_identical(
    contract$ContractHash,
    "67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666"
  )
  expect_identical(contract$ExpectedProfileCount, 21L)
  expect_identical(length(contract$CompiledAxisIds), 9L)
  expect_identical(
    contract$DeferredGeneratorAxisIds,
    c(
      "variance_regime", "cross_stratum_covariance",
      "response_distribution"
    )
  )
  expect_identical(nrow(contract$SemanticRuleRegistry), 22L)
  expect_identical(contract$ScenarioSpecificBranchCount, 0L)
  expect_true(contract$AllProfilesMustCompile)
  expect_true(all(!contract$SemanticRuleRegistry$StochasticOperationRequired))
  expect_true(all(
    !contract$SemanticRuleRegistry$ScenarioSpecificPatchAllowed
  ))
  expect_false(contract$CompilerMayUseRng)
  expect_false(contract$CompilerMayGenerateResponses)
  expect_false(contract$CompilerMayCallBackend)
  expect_false(contract$StochasticMissingnessQualified)
  expect_false(contract$CovarianceGeneratorQualified)
  expect_false(contract$ResponseDistributionGeneratorQualified)
  expect_false(contract$ExploratoryExecutionAllowed)
})

test_that("all 21 profiles compile through the same typed layer", {
  env <- load_gtheory_dsim3c()
  manifest <- gtheory_dsim3c_manifest(env)
  registry <- manifest$ProfileCompilationRegistry
  expect_invisible(env$mfrmr_gtds3c_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "dd69c9eb4f7b75641efb9f4b9bbfcee7818b8a645a7c70cdbc8f9b2551d74a3b"
  )
  expect_identical(nrow(registry), 21L)
  expect_identical(registry$ScenarioId, sprintf("D3-S%03d", 1:21))
  expect_true(all(registry$ConditionSharingQualified))
  expect_true(all(registry$ObservationEventQualified))
  expect_true(all(registry$CrossingQualified))
  expect_true(all(registry$BalanceQualified))
  expect_true(all(registry$MissingnessMaskQualified))
  expect_true(all(registry$TypedDesignCompilerQualified))
  expect_true(all(!registry$StochasticMissingnessGenerationQualified))
  expect_true(all(!registry$CovarianceGeneratorQualified))
  expect_true(all(!registry$ResponseDistributionGeneratorQualified))
  expect_true(all(!registry$GeneratorSemanticsQualified))
  expect_identical(sum(registry$PlannedRowCount), 147948L)
  expect_identical(sum(registry$ScheduledObservationRowCount), 130694L)
  expect_identical(sum(registry$OmittedRowCount), 17254L)
  expect_true(manifest$Summary$SharedCompilerQualified)
  expect_identical(manifest$Summary$QualifiedTypedDesignProfileCount, 21L)
  expect_identical(
    manifest$Summary$GeneratorSemanticsQualifiedProfileCount, 0L
  )
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
})

test_that("compiled profiles retain every declared design-axis level", {
  env <- load_gtheory_dsim3c()
  coverage <- env$mfrmr_gtds3_manifest()
  contract <- env$mfrmr_gtds3c_contract()
  scenarios <- coverage$ScenarioRegistry
  axes <- coverage$Contract$DatasetAxisIds
  for (axis in contract$CompiledAxisIds) {
    expected <- unique(
      env$mfrmr_gtds3_dataset_axis_registry()$LevelId[
        env$mfrmr_gtds3_dataset_axis_registry()$AxisId == axis
      ]
    )
    expect_setequal(unique(scenarios[[axis]]), expected)
  }
  expect_setequal(
    names(scenarios)[names(scenarios) %in% axes], axes
  )
})

test_that("anchor and closure counts use frozen object and rater meanings", {
  env <- load_gtheory_dsim3c()
  contract <- env$mfrmr_gtds3c_contract()
  coverage <- env$mfrmr_gtds3_manifest()
  anchor <- env$mfrmr_gtds3c_compile_profile(
    "D3-S001", contract, coverage, validate = FALSE
  )
  closure <- env$mfrmr_gtds3c_compile_profile(
    "D3-S002", contract, coverage, validate = FALSE
  )
  expect_invisible(env$mfrmr_gtds3c_assert_compilation(
    anchor, contract, coverage
  ))
  expect_identical(anchor$Summary$StratumCount, 2L)
  expect_identical(anchor$Summary$ObjectCount, 200L)
  expect_identical(anchor$Summary$RatingsPerObjectStratum, 4L)
  expect_identical(anchor$Summary$RepeatCount, 2L)
  expect_identical(anchor$Summary$PlannedRowCount, 3200L)
  expect_identical(anchor$Summary$ConditionIdentityCount, 4L)
  expect_identical(anchor$Summary$EventIdentityCount, 3200L)
  expect_identical(anchor$Summary$OmittedRowCount, 0L)
  expect_identical(closure$Summary$StratumCount, 1L)
  expect_identical(closure$Summary$PlannedRowCount, 1600L)
  expect_identical(closure$Summary$OmittedRowCount, 0L)
})

test_that("partial sharing mixed events and incomplete crossing remain typed", {
  env <- load_gtheory_dsim3c()
  contract <- env$mfrmr_gtds3c_contract()
  coverage <- env$mfrmr_gtds3_manifest()
  compilation <- env$mfrmr_gtds3c_compile_profile(
    "D3-S004", contract, coverage, validate = FALSE
  )
  assignments <- compilation$AssignmentRegistry
  expect_identical(
    as.integer(table(compilation$ObjectStratumRegistry$Stratum)),
    c(50L, 25L)
  )
  expect_identical(compilation$Summary$PlannedRowCount, 600L)
  expect_identical(compilation$Summary$OmittedRowCount, 180L)
  expect_identical(compilation$Summary$ScheduledObservationRowCount, 420L)
  expect_true(all(compilation$ConditionPairAudit$SharedBindings > 0L))
  expect_true(all(compilation$ConditionPairAudit$DistinctBindings > 0L))
  expect_true(all(compilation$EventPairAudit$SharedBindings > 0L))
  expect_true(all(compilation$EventPairAudit$DistinctBindings > 0L))
  expect_identical(length(unique(assignments$RaterBaseOrdinal)), 16L)
  expect_identical(
    unique(assignments$ConditionPoolSize), 16L
  )
  expect_true(all(tapply(
    assignments$ResponseScheduled,
    paste(assignments$Stratum, assignments$ObjectId), sum
  ) > 0L))
})

test_that("nested and structural rules use identities rather than patches", {
  env <- load_gtheory_dsim3c()
  contract <- env$mfrmr_gtds3c_contract()
  coverage <- env$mfrmr_gtds3_manifest()
  nested <- env$mfrmr_gtds3c_compile_profile(
    "D3-S003", contract, coverage, validate = FALSE
  )
  structural <- env$mfrmr_gtds3c_compile_profile(
    "D3-S005", contract, coverage, validate = FALSE
  )
  raw_objects <- split(
    nested$AssignmentRegistry$ObjectId,
    nested$AssignmentRegistry$RaterRawId
  )
  expect_true(all(vapply(
    raw_objects, function(value) length(unique(value)) == 1L, logical(1L)
  )))
  expect_identical(nested$Summary$OmittedRowCount, 540L)
  expect_identical(
    as.integer(table(structural$ObjectStratumRegistry$Stratum)),
    c(50L, 37L, 25L)
  )
  omitted <- !structural$AssignmentRegistry$ResponseScheduled
  expect_true(all(
    structural$AssignmentRegistry$RaterSlotOrdinal[omitted] == 2L
  ))
  expect_true(all(
    structural$AssignmentRegistry$ObjectOrdinal[omitted] %% 2L == 0L
  ))
  expect_identical(structural$Summary$OmittedRowCount, 110L)
})

test_that("compiler replay is exact and leaves caller RNG unchanged", {
  env <- load_gtheory_dsim3c()
  first <- gtheory_dsim3c_manifest(env)
  set.seed(240832L)
  caller_state <- .Random.seed
  replay <- env$mfrmr_gtds3c_manifest()
  expect_identical(.Random.seed, caller_state)
  expect_identical(replay$ManifestHash, first$ManifestHash)
  expect_identical(
    replay$ProfileCompilationRegistry, first$ProfileCompilationRegistry
  )
  expect_false(replay$Summary$RngStreamOpened)
  expect_false(replay$Summary$ResponseGenerated)
  expect_false(replay$Summary$BackendCallMade)
  expect_false(replay$Summary$FitExecuted)
})

test_that("compiler and manifest mutations fail closed", {
  env <- load_gtheory_dsim3c()
  contract <- env$mfrmr_gtds3c_contract()
  coverage <- env$mfrmr_gtds3_manifest()
  compilation <- env$mfrmr_gtds3c_compile_profile(
    "D3-S001", contract, coverage, validate = FALSE
  )
  changed <- compilation
  changed$AssignmentRegistry$ConditionId[[1L]] <- "mutated"
  changed$Summary$AssignmentRegistryHash <- env$mfrmr_gtds3c_hash(
    changed$AssignmentRegistry
  )
  changed$CompilationHash <- env$mfrmr_gtds3c_hash(
    changed[env$mfrmr_gtds3c_compilation_fields()]
  )
  expect_error(
    env$mfrmr_gtds3c_assert_compilation(changed, contract, coverage),
    "altered"
  )

  changed_contract <- contract
  changed_contract$ScenarioSpecificBranchCount <- 1L
  expect_error(
    env$mfrmr_gtds3c_validate_contract(changed_contract), "invalid"
  )

  manifest <- gtheory_dsim3c_manifest(env)
  promoted <- manifest
  promoted$Summary$ExploratoryExecutionAllowed <- TRUE
  promoted$ManifestHash <- env$mfrmr_gtds3c_hash(
    promoted[env$mfrmr_gtds3c_manifest_fields()]
  )
  expect_error(env$mfrmr_gtds3c_assert_manifest(promoted), "altered")
})

test_that("semantic compiler remains outside public package surfaces", {
  public_files <- c(
    list.files(testthat::test_path("..", "..", "R"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "man"), recursive = TRUE,
               full.names = TRUE),
    list.files(testthat::test_path("..", "..", "vignettes"),
               recursive = TRUE, full.names = TRUE),
    testthat::test_path("..", "..", "ROADMAP.md")
  )
  public_text <- unlist(lapply(public_files, function(file) {
    if (file.exists(file) && !dir.exists(file) &&
        grepl("\\.(R|Rd|Rmd|md)$", file)) {
      readLines(file, warn = FALSE, encoding = "UTF-8")
    } else character()
  }), use.names = FALSE)
  expect_false(any(grepl(
    paste0(
      "mfrmr_gtds3c_|",
      "MFRMR-GTHEORY-MV-DSIM3-SEMANTIC-DESIGN-COMPILER"
    ), public_text
  )))
})
