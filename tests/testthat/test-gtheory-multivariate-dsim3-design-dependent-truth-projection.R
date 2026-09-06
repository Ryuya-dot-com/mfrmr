gtheory_dsim3t_paths <- function() {
  validation <- testthat::test_path("..", "..", "inst", "validation")
  file.path(validation, c(
    "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
    "gtheory-multivariate-dsim2-plumbing-smoke-0.2.4.R",
    "gtheory-multivariate-dsim3-coverage-manifest-0.2.4.R",
    "gtheory-multivariate-dsim3-exploratory-execution-contract-0.2.4.R",
    "gtheory-multivariate-dsim3-preexecution-qualification-0.2.4.R",
    "gtheory-multivariate-dsim3-semantic-design-compiler-0.2.4.R",
    "gtheory-multivariate-dsim3-covariance-distribution-binding-0.2.4.R",
    "gtheory-multivariate-dsim3-response-generator-adapter-0.2.4.R",
    paste0(
      "gtheory-multivariate-dsim3-separate-univariate-semantics-audit-",
      "0.2.4.R"
    ),
    paste0(
      "gtheory-multivariate-dsim3-design-dependent-truth-projection-",
      "0.2.4.R"
    )
  ))
}

load_gtheory_dsim3t <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3t_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 truth projection excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3t_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) {
      manifest <<- environment$mfrmr_gtds3t_manifest()
    }
    manifest
  }
})

test_that("truth projection binds parent semantics and generator identities", {
  env <- load_gtheory_dsim3t()
  contract <- env$mfrmr_gtds3t_contract()
  manifest <- gtheory_dsim3t_manifest(env)
  expect_invisible(env$mfrmr_gtds3t_validate_contract(contract))
  expect_invisible(env$mfrmr_gtds3t_assert_manifest(manifest))
  expect_identical(
    contract$ContractHash,
    "fb66bd15526afa1f18f613dcbc4b0d470350bcf803a642fcde537602d017f327"
  )
  expect_identical(
    manifest$ManifestHash,
    "97d98f649cbc49d646a7f9ac37e8292d8eb1a8ceff4f369b609108d0812189e5"
  )
  expect_identical(
    manifest$ParentSemanticsManifestHash,
    "815d29f76640f2886b572ffda418582a02135d51cd50dadbab5ff6e4308bbb2f"
  )
  expect_identical(
    manifest$ParentGeneratorManifestHash,
    "c334578b20b886d158f5fd1aa82c3c1bd9e24f64e7e9d1d4d1c25e7f868da46a"
  )
})

test_that("generator components remain distinct from estimand components", {
  env <- load_gtheory_dsim3t()
  contract <- env$mfrmr_gtds3t_contract()
  mapping <- contract$MappingRegistry
  nested <- mapping$DesignClass == "nested"
  expect_identical(nrow(mapping), 8L)
  expect_identical(
    mapping$SourceGeneratorComponent[nested],
    c("Object", "Rater", "Object:Rater", "Residual")
  )
  expect_identical(
    mapping$TargetEstimandComponent[nested],
    c("Object", "NestedCondition", "NestedCondition", "Residual")
  )
  expect_identical(
    unique(mapping$TargetUniverseRole[
      mapping$TargetEstimandComponent == "NestedCondition"
    ]),
    "relative_error"
  )
  expect_true(all(mapping$SourceDrawRetained))
  expect_false(any(mapping$GeneratorPayloadMutationRequired))
  expect_true(contract$GeneratorComponentRegistryPreserved)
  expect_true(contract$GeneratorSubstreamIdentityPreserved)
  expect_false(contract$GeneratorPayloadHashMayBeRelabeled)
  expect_identical(
    contract$CollapsedSourceComponents, c("Rater", "Object:Rater")
  )
  expect_true(contract$CollapsedSourceComponentsMustBeGaussian)
  expect_true(contract$CollapsedSourceStreamsMustBeDistinct)
})

test_that("nested aliases collapse once without changing response covariance", {
  env <- load_gtheory_dsim3t()
  manifest <- gtheory_dsim3t_manifest(env)
  profiles <- manifest$ProfileTruthRegistry
  nested <- profiles$DesignClass == "nested"
  crossed <- profiles$DesignClass == "crossed"
  expect_identical(sum(nested), 6L)
  expect_identical(sum(crossed), 15L)
  expect_identical(
    profiles$TargetEstimandComponentCount[nested], rep(3L, 6L)
  )
  expect_identical(
    profiles$TargetEstimandComponentCount[crossed], rep(4L, 15L)
  )
  expect_true(all(profiles$SourceAliasPresent[nested]))
  expect_false(any(profiles$SourceAliasPresent[crossed]))
  expect_true(all(profiles$SourceAliasResolved))
  expect_true(all(profiles$LatentResponseDistributionPreserved))
  expect_lte(
    max(profiles$LatentResponseCovarianceMaximumError), 1e-10
  )
  expect_true(all(profiles$AbsoluteErrorCovariancePreserved))
  expect_lte(
    max(profiles$AbsoluteErrorCovarianceMaximumError), 1e-10
  )
})

test_that("all projected component covariances are PSD and reconstruct", {
  env <- load_gtheory_dsim3t()
  components <- gtheory_dsim3t_manifest(env)$TargetComponentBindingRegistry
  expect_identical(nrow(components), 78L)
  expect_true(all(components$PositiveSemidefinite))
  expect_lte(max(components$EffectiveSourceSumMaximumError), 1e-10)
  expect_lte(
    max(components$UnitFactorReconstructionMaximumError), 1e-10
  )
  nested <- components$TargetComponentId == "NestedCondition"
  expect_identical(sum(nested), 6L)
  expect_true(all(components$UniverseRole[nested] == "relative_error"))
  expect_true(all(
    components$SourceGeneratorComponents[nested] ==
      "Rater+Object:Rater"
  ))
  expect_true(all(components$SourcePartitionAliasRequired[nested]))
  expect_true(all(components$SourcePartitionAliasQualified[nested]))
})

test_that("Phi partition is invariant while nested G truth is revised", {
  env <- load_gtheory_dsim3t()
  manifest <- gtheory_dsim3t_manifest(env)
  profiles <- manifest$ProfileTruthRegistry
  nested <- profiles$DesignClass == "nested"
  crossed <- profiles$DesignClass == "crossed"
  expect_true(all(
    profiles$RelativeErrorCovarianceRevisionMagnitude[nested] > 1e-10
  ))
  expect_true(all(
    profiles$RelativeErrorCovarianceRevisionMagnitude[crossed] <= 1e-10
  ))
  estimands <- manifest$Contract$EstimandRegistry
  expect_identical(estimands$EstimandId, c("ABS-PHI", "REL-G"))
  expect_identical(
    estimands$NestedProjection,
    c(
      "unchanged_total_error_after_alias_collapse",
      "revised_to_include_combined_nested_condition_relative_error"
    )
  )
  expect_true(all(estimands$AllocationOperatorRequired))
  expect_false(any(estimands$CoefficientComputed))
})

test_that("truth projection closes its upstream gate but not execution", {
  env <- load_gtheory_dsim3t()
  manifest <- gtheory_dsim3t_manifest(env)
  expect_identical(
    manifest$ReadinessGateRegistry$GatePassed,
    c(rep(TRUE, 8L), FALSE, FALSE)
  )
  expect_true(all(manifest$OpenGapRegistry$GapOpen))
  expect_identical(
    manifest$Summary$CurrentDisposition,
    "truth_projection_qualified_operator_and_plan_still_required"
  )
  expect_identical(manifest$Summary$IdentifiableTruthProfileCount, 21L)
  expect_identical(manifest$Summary$RelativeErrorRevisedProfileCount, 6L)
  expect_identical(manifest$Summary$GeneratorPayloadMutationCount, 0L)
  expect_true(manifest$Summary$CollapsedSourceComponentsGaussian)
  expect_true(manifest$Summary$CollapsedSourceStreamsDistinct)
  expect_false(manifest$Summary$Planned855RngStreamOpened)
  expect_false(manifest$Summary$ResponseGeneratedByProjection)
  expect_false(manifest$Summary$GeneratorPayloadRelabeled)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitReturned)
  expect_false(manifest$Summary$CoefficientComputed)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
