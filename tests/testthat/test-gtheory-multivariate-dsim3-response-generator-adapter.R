gtheory_dsim3g_paths <- function() {
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
      )
    )
  )
}

load_gtheory_dsim3g <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3g_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 generator excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3g_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3g_manifest()
    manifest
  }
})

gtheory_dsim3g_generation <- function(environment, scenario_id) {
  environment$mfrmr_gtds3g_generate_profile(
    scenario_id, validate = FALSE
  )
}

test_that("generator contract isolates qualification from reserved 855", {
  env <- load_gtheory_dsim3g()
  binding_manifest <- env$mfrmr_gtds3b_manifest()
  contract <- env$mfrmr_gtds3g_contract()
  expect_invisible(env$mfrmr_gtds3g_validate_contract(
    contract, binding_manifest
  ))
  expect_s3_class(contract, "mfrmr_gtds3g_contract")
  expect_identical(
    contract$ContractHash,
    "92a6b8b1b0728bc33477e4ec6737c0a3c448f8934708120cbc8aeff51025b2d4"
  )
  expect_identical(
    contract$ParentBindingManifestHash,
    "8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625"
  )
  expect_identical(contract$ExpectedProfileCount, 21L)
  expect_identical(contract$ExpectedUnitCovarianceAuditCount, 84L)
  expect_identical(contract$ShadowSeedBandId, "NONRESERVED-FIXTURE-854")
  expect_identical(contract$MinimumShadowSeed, 854100001L)
  expect_identical(contract$MaximumShadowSeed, 854100021L)
  expect_lt(contract$MaximumShadowSeed,
            contract$ReservedExploratoryLowerInclusive)
  expect_identical(
    contract$SubstreamOrder,
    c("Object", "Rater", "Object:Rater", "Residual", "Missingness")
  )
  expect_true(contract$ResidualIsResponseInnovation)
  expect_false(contract$DuplicateResidualRepresentationAllowed)
  expect_false(contract$StochasticMcarSupportRepairAllowed)
  expect_true(contract$CallerRngStateMustBeRestored)
  expect_true(contract$OneDrawVectorPerComponentIdentity)
  expect_identical(contract$ScenarioSpecificPatchCount, 0L)
  expect_false(contract$Planned855RngStreamAllowed)
  expect_false(contract$BackendCallAllowed)
  expect_false(contract$FitAllowed)
  expect_false(contract$ExploratoryExecutionAllowed)
  expect_false(contract$SimulationValidationClaimAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
})

test_that("all profiles generate one qualified nonpromoting shadow fixture", {
  env <- load_gtheory_dsim3g()
  manifest <- gtheory_dsim3g_manifest(env)
  profiles <- manifest$ProfileGenerationRegistry
  units <- manifest$UnitCovarianceAuditRegistry
  expect_invisible(env$mfrmr_gtds3g_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a"
  )
  expect_identical(nrow(profiles), 21L)
  expect_identical(profiles$ScenarioId, sprintf("D3-S%03d", 1:21))
  expect_identical(profiles$ShadowSeed, 854100000L + 1:21)
  expect_true(all(profiles$ShadowSeed < 855000000L))
  expect_identical(nrow(units), 84L)
  expect_true(all(units$PositiveSemidefinite))
  expect_true(all(
    units$UnitFactorReconstructionMaximumError <=
      manifest$Contract$MatrixTolerance
  ))
  expect_true(all(
    units$EffectiveCovarianceImplicationMaximumError <=
      manifest$Contract$MatrixTolerance
  ))
  expect_true(all(profiles$FullGeneratorAdapterQualified))
  expect_true(all(profiles$GeneratorSemanticsQualified))
  expect_true(all(profiles$ShadowRngStreamOpened))
  expect_true(all(!profiles$Planned855RngStreamOpened))
  expect_true(all(profiles$ShadowResponseGenerated))
  expect_true(all(!profiles$ExploratoryResponseGenerated))
  expect_true(all(!profiles$BackendCallMade))
  expect_true(all(!profiles$FitExecuted))
  expect_identical(
    manifest$Summary$GeneratorSemanticsQualifiedProfileCount, 21L
  )
  expect_identical(manifest$Summary$RandomizedFixedCountMcarProfileCount, 9L)
  expect_identical(manifest$Summary$PlannedStructuralRowCount, 147948L)
  expect_identical(manifest$Summary$ShadowGeneratedResponseCount, 130694L)
  expect_identical(manifest$Summary$ShadowOmittedResponseCount, 17254L)
  expect_identical(manifest$Summary$ExploratoryGeneratedDatasetCount, 0L)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})

test_that("unit covariance and identity overlap reproduce effective blocks", {
  env <- load_gtheory_dsim3g()
  generation <- gtheory_dsim3g_generation(env, "D3-S007")
  for (component_id in names(generation$UnitCovarianceBindings)) {
    unit <- generation$UnitCovarianceBindings[[component_id]]
    expect_equal(
      unit$UnitCovarianceMatrix * unit$IdentityOverlapMatrix,
      unit$ImpliedEffectiveCovarianceMatrix,
      tolerance = 1e-14
    )
    expect_lte(
      unit$EffectiveCovarianceImplicationMaximumError,
      env$mfrmr_gtds3g_contract()$MatrixTolerance
    )
    expect_true(unit$UnitCovarianceAudit$PositiveSemidefinite)
  }
  rater <- generation$UnitCovarianceBindings$Rater
  object_rater <- generation$UnitCovarianceBindings$`Object:Rater`
  expect_gt(abs(rater$UnitCovarianceMatrix[1L, 2L]),
            abs(rater$ImpliedEffectiveCovarianceMatrix[1L, 2L]))
  expect_gt(abs(object_rater$UnitCovarianceMatrix[1L, 2L]),
            abs(object_rater$ImpliedEffectiveCovarianceMatrix[1L, 2L]))
})

test_that("component effects are drawn once per exact compiled identity", {
  env <- load_gtheory_dsim3g()
  generation <- gtheory_dsim3g_generation(env, "D3-S001")
  data <- generation$GeneratedData
  for (component_id in names(generation$ComponentDraws)) {
    draw <- generation$ComponentDraws[[component_id]]
    key <- paste(
      draw$EffectRegistry$IdentityId, draw$EffectRegistry$Stratum,
      sep = "\036"
    )
    expect_identical(anyDuplicated(key), 0L)
    expect_true(draw$OneDrawVectorPerIdentity)
    expect_true(all(is.finite(draw$EffectRegistry$Effect)))
  }
  object_key <- paste(data$ObjectId, data$Stratum, sep = "\036")
  object_effect_count <- tapply(data$ObjectEffect, object_key, function(x) {
    length(unique(x))
  })
  expect_true(all(object_effect_count == 1L))
  expect_identical(
    generation$ComponentDraws$`Object:Rater`$IdentityColumn,
    "ObjectConditionId"
  )
  expect_true("ResidualEffect" %in% names(data))
  expect_false("InnovationEffect" %in% names(data))
})

test_that("kernel families generate their declared response support", {
  env <- load_gtheory_dsim3g()
  gaussian <- gtheory_dsim3g_generation(env, "D3-S001")
  heavy <- gtheory_dsim3g_generation(env, "D3-S003")
  ordinal <- gtheory_dsim3g_generation(env, "D3-S004")
  expect_true(all(is.finite(
    gaussian$GeneratedData$Score[gaussian$GeneratedData$ResponseGenerated]
  )))
  expect_identical(
    heavy$ComponentDraws$Residual$DrawDistribution,
    "standardized_multivariate_student_t_df5_innovation"
  )
  ordinal_score <- ordinal$GeneratedData$Score[
    ordinal$GeneratedData$ResponseGenerated
  ]
  expect_true(all(ordinal_score %in% 0:4))
  expect_true(all(ordinal_score == as.integer(ordinal_score)))
  expect_identical(
    ordinal$Summary$ResponseDistribution, "ordinal_aggregate"
  )
  expect_false(env$mfrmr_gtds3b_kernel(
    ordinal$Summary$ResponseDistribution
  )$IrtResponseModel)
})

test_that("randomized fixed-count MCAR is outcome-independent and exact", {
  env <- load_gtheory_dsim3g()
  generation <- gtheory_dsim3g_generation(env, "D3-S003")
  missingness <- generation$MissingnessBinding
  expect_true(missingness$RandomizedFixedCountMcar)
  expect_false(missingness$SupportRepairApplied)
  expect_false(missingness$OutcomeValuesInspected)
  expect_identical(
    missingness$OmittedCount,
    as.integer(floor(nrow(generation$GeneratedData) * 0.10 + 1e-12))
  )
  expect_identical(
    sum(generation$GeneratedData$ResponseGenerated),
    missingness$ScheduledCount
  )
  expect_true(all(is.na(generation$GeneratedData$Score[
    !generation$GeneratedData$ResponseGenerated
  ])))
})

test_that("shadow generation exactly restores caller RNG and replays", {
  env <- load_gtheory_dsim3g()
  set.seed(240834L)
  caller_kind <- RNGkind()
  caller_state <- .Random.seed
  first <- gtheory_dsim3g_generation(env, "D3-S008")
  expect_identical(RNGkind(), caller_kind)
  expect_identical(.Random.seed, caller_state)
  replay <- gtheory_dsim3g_generation(env, "D3-S008")
  expect_identical(replay$GenerationHash, first$GenerationHash)
  expect_identical(replay$GeneratedData, first$GeneratedData)
  expect_identical(.Random.seed, caller_state)
  expect_invisible(env$mfrmr_gtds3g_assert_generation(
    replay, validate = FALSE, replay = TRUE
  ))
})

test_that("reserved seeds and response mutations fail closed", {
  env <- load_gtheory_dsim3g()
  contract <- env$mfrmr_gtds3g_contract()
  expect_error(
    env$mfrmr_gtds3g_with_seed(
      855001001L, contract, function() TRUE
    ), "nonreserved shadow seed"
  )

  generation <- gtheory_dsim3g_generation(env, "D3-S001")
  changed <- generation
  observed <- which(changed$GeneratedData$ResponseGenerated)[[1L]]
  changed$GeneratedData$Score[[observed]] <-
    changed$GeneratedData$Score[[observed]] + 1
  changed$Summary$GeneratedDataHash <- env$mfrmr_gtds3g_hash(
    changed$GeneratedData
  )
  changed$GenerationHash <- env$mfrmr_gtds3g_hash(
    changed[env$mfrmr_gtds3g_generation_fields()]
  )
  expect_error(
    env$mfrmr_gtds3g_assert_generation(
      changed, validate = FALSE, replay = TRUE
    ), "altered"
  )

  promoted <- gtheory_dsim3g_manifest(env)
  promoted$Summary$ExploratoryExecutionAllowed <- TRUE
  promoted$ManifestHash <- env$mfrmr_gtds3g_hash(
    promoted[env$mfrmr_gtds3g_manifest_fields()]
  )
  expect_error(env$mfrmr_gtds3g_assert_manifest(promoted), "altered")
})

test_that("response generator remains outside public package surfaces", {
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
      "mfrmr_gtds3g_|",
      "MFRMR-GTHEORY-MV-DSIM3-RESPONSE-GENERATOR-ADAPTER"
    ), public_text
  )))
})
