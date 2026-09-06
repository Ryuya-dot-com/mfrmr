gtheory_dsim3b_paths <- function() {
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
      )
    )
  )
}

load_gtheory_dsim3b <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim3b_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-3 binding excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

gtheory_dsim3b_manifest <- local({
  manifest <- NULL
  function(environment) {
    if (is.null(manifest)) manifest <<- environment$mfrmr_gtds3b_manifest()
    manifest
  }
})

gtheory_dsim3b_binding <- function(environment, scenario_id) {
  environment$mfrmr_gtds3b_bind_profile(
    scenario_id, validate = FALSE
  )
}

gtheory_dsim3b_off_diagonal <- function(matrix) {
  matrix[row(matrix) != col(matrix)]
}

test_that("binding freezes one package-level covariance and kernel system", {
  env <- load_gtheory_dsim3b()
  compiler <- env$mfrmr_gtds3c_manifest()
  contract <- env$mfrmr_gtds3b_contract()
  expect_invisible(env$mfrmr_gtds3b_validate_contract(contract, compiler))
  expect_s3_class(contract, "mfrmr_gtds3b_contract")
  expect_identical(
    contract$ContractHash,
    "293dd2af3e8f13282ae545efa6063306f4cf59d4d7bf1027dca57de9376ae1c4"
  )
  expect_identical(
    contract$ParentCompilerContractHash,
    "67cb6077c0b0fb083362c0b7bae498be6695e61a0f84d1636f992479ef79f666"
  )
  expect_identical(
    contract$ParentCompilerManifestHash,
    "dd69c9eb4f7b75641efb9f4b9bbfcee7818b8a645a7c70cdbc8f9b2551d74a3b"
  )
  expect_identical(contract$ExpectedProfileCount, 21L)
  expect_identical(contract$ExpectedComponentCount, 4L)
  expect_identical(contract$ExpectedCovarianceBindingCount, 84L)
  expect_identical(contract$ExpectedKernelBindingCount, 21L)
  expect_identical(length(contract$BoundAxisIds), 3L)
  expect_identical(nrow(contract$ComponentRegistry), 4L)
  expect_identical(nrow(contract$VarianceRegistry), 16L)
  expect_identical(nrow(contract$KernelRegistry), 3L)
  expected_variances <- list(
    regular_interior = c(1, 0.2, 0.35, 0.5),
    near_zero_component = c(1, 0.000001, 0.35, 0.5),
    dominant_component = c(3, 0.1, 0.2, 0.3),
    near_singular_covariance = c(1, 0.2, 0.35, 0.5)
  )
  for (regime in names(expected_variances)) {
    rows <- contract$VarianceRegistry$VarianceRegime == regime
    expect_identical(
      contract$VarianceRegistry$MarginalVariance[rows],
      expected_variances[[regime]]
    )
  }
  expect_true(contract$OverlapMatricesMustBePsd)
  expect_true(contract$CovarianceMatricesMustBePsd)
  expect_false(contract$PsdRepairAllowed)
  expect_false(contract$DuplicateResidualRepresentationAllowed)
  expect_false(contract$OrdinalAggregateIsIrtModel)
  expect_identical(contract$ScenarioSpecificPatchCount, 0L)
  expect_false(contract$BindingMayUseRng)
  expect_false(contract$BindingMayGenerateResponses)
  expect_false(contract$BindingMayCallBackend)
  expect_false(contract$FullGeneratorAdapterQualified)
  expect_false(contract$ExploratoryExecutionAllowed)
})

test_that("all 21 profiles receive PSD factors and nonexecuting kernels", {
  env <- load_gtheory_dsim3b()
  manifest <- gtheory_dsim3b_manifest(env)
  profiles <- manifest$ProfileBindingRegistry
  components <- manifest$ComponentBindingRegistry
  kernels <- manifest$KernelBindingRegistry
  expect_invisible(env$mfrmr_gtds3b_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "8fcdc0297a0f09c0525a10f8c1a1ffca4310f7b7509f4df3f793f14f68151625"
  )
  expect_identical(nrow(profiles), 21L)
  expect_identical(profiles$ScenarioId, sprintf("D3-S%03d", 1:21))
  expect_identical(nrow(components), 84L)
  expect_identical(nrow(kernels), 21L)
  expect_true(all(profiles$CovarianceDistributionBindingQualified))
  expect_true(all(components$PositiveSemidefinite))
  expect_true(all(
    components$FactorReconstructionMaximumError <=
      manifest$Contract$MatrixTolerance
  ))
  expect_true(all(kernels$KernelContractQualified))
  expect_true(all(!kernels$IrtResponseModel))
  expect_true(all(!kernels$StochasticDrawQualified))
  expect_true(manifest$Summary$CovarianceDistributionLayerQualified)
  expect_identical(
    manifest$Summary$GeneratorSemanticsQualifiedProfileCount, 0L
  )
  expect_false(manifest$Summary$FullGeneratorAdapterQualified)
  expect_false(manifest$Summary$RngStreamOpened)
  expect_false(manifest$Summary$ResponseGenerated)
  expect_false(manifest$Summary$BackendCallMade)
  expect_false(manifest$Summary$FitExecuted)
  expect_false(manifest$Summary$ExploratoryExecutionAllowed)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})

test_that("binding retains every declared generator-axis level", {
  env <- load_gtheory_dsim3b()
  coverage <- env$mfrmr_gtds3_manifest()
  manifest <- gtheory_dsim3b_manifest(env)
  profiles <- manifest$ProfileBindingRegistry
  registry <- env$mfrmr_gtds3_dataset_axis_registry()
  for (axis in manifest$Contract$BoundAxisIds) {
    expected <- registry$LevelId[registry$AxisId == axis]
    column <- switch(
      axis,
      variance_regime = "VarianceRegime",
      cross_stratum_covariance = "CrossStratumCovariance",
      response_distribution = "ResponseDistribution"
    )
    expect_setequal(unique(profiles[[column]]), expected)
  }
  expect_setequal(profiles$ScenarioId, coverage$ScenarioRegistry$ScenarioId)
  expect_setequal(
    unique(manifest$ComponentBindingRegistry$ComponentId),
    manifest$Contract$ComponentRegistry$ComponentId
  )
})

test_that("cross-stratum covariance follows compiled identity overlap", {
  env <- load_gtheory_dsim3b()
  positive_identical <- gtheory_dsim3b_binding(env, "D3-S001")
  disjoint_negative <- gtheory_dsim3b_binding(env, "D3-S003")
  linked_disjoint <- gtheory_dsim3b_binding(env, "D3-S005")
  zero <- gtheory_dsim3b_binding(env, "D3-S004")
  closure <- gtheory_dsim3b_binding(env, "D3-S002")

  expect_identical(
    zero$OverlapBindings$`Object:Rater`$IdentityColumn,
    "ObjectConditionId"
  )
  expect_lt(
    zero$OverlapBindings$`Object:Rater`$Matrix[1L, 2L],
    zero$OverlapBindings$Rater$Matrix[1L, 2L]
  )

  for (component in c("Object", "Rater", "Object:Rater")) {
    expect_true(all(gtheory_dsim3b_off_diagonal(
      positive_identical$ComponentBindings[[component]]$CovarianceMatrix
    ) > 0))
  }
  expect_true(all(abs(gtheory_dsim3b_off_diagonal(
    positive_identical$ComponentBindings$Residual$CovarianceMatrix
  )) <= 1e-12))

  expect_true(all(gtheory_dsim3b_off_diagonal(
    disjoint_negative$ComponentBindings$Object$CovarianceMatrix
  ) < 0))
  for (component in c("Rater", "Object:Rater", "Residual")) {
    expect_true(all(abs(gtheory_dsim3b_off_diagonal(
      disjoint_negative$ComponentBindings[[component]]$CovarianceMatrix
    )) <= 1e-12))
  }

  expect_true(all(gtheory_dsim3b_off_diagonal(
    linked_disjoint$ComponentBindings$Object$CovarianceMatrix
  ) > 0))
  expect_true(all(gtheory_dsim3b_off_diagonal(
    linked_disjoint$ComponentBindings$Residual$CovarianceMatrix
  ) > 0))
  for (component in c("Rater", "Object:Rater")) {
    expect_true(all(abs(gtheory_dsim3b_off_diagonal(
      linked_disjoint$ComponentBindings[[component]]$CovarianceMatrix
    )) <= 1e-12))
  }

  for (component in names(zero$ComponentBindings)) {
    expect_true(all(abs(gtheory_dsim3b_off_diagonal(
      zero$ComponentBindings[[component]]$CovarianceMatrix
    )) <= 1e-12))
  }
  expect_identical(closure$Summary$StratumCount, 1L)
  expect_true(all(vapply(closure$ComponentBindings, function(binding) {
    identical(dim(binding$CovarianceMatrix), c(1L, 1L))
  }, logical(1L))))
})

test_that("variance regimes retain their intended boundary meanings", {
  env <- load_gtheory_dsim3b()
  manifest <- gtheory_dsim3b_manifest(env)
  contract <- manifest$Contract
  profiles <- manifest$ProfileBindingRegistry
  for (scenario_id in profiles$ScenarioId) {
    binding <- gtheory_dsim3b_binding(env, scenario_id)
    regime <- binding$Summary$VarianceRegime
    if (regime == "regular_interior") {
      expect_true(all(!binding$CovarianceAudit$Boundary))
    } else if (regime == "near_zero_component") {
      expect_lte(max(diag(
        binding$ComponentBindings$Rater$CovarianceMatrix
      )), contract$BoundaryTolerance)
    } else if (regime == "dominant_component") {
      diagonals <- vapply(binding$ComponentBindings, function(component) {
        mean(diag(component$CovarianceMatrix))
      }, numeric(1L))
      expect_identical(names(which.max(diagonals)), "Object")
      expect_gte(max(diagonals) / sort(diagonals, decreasing = TRUE)[[2L]], 9)
    } else {
      expect_true(binding$ComponentBindings$Object$CovarianceAudit$Boundary)
      expect_lte(
        binding$ComponentBindings$Object$CovarianceAudit$MinimumEigenvalue,
        1e-5
      )
    }
  }
})

test_that("response kernels are explicit stress distributions, not IRT", {
  env <- load_gtheory_dsim3b()
  gaussian <- env$mfrmr_gtds3b_kernel("gaussian")
  heavy <- env$mfrmr_gtds3b_kernel("heavy_tailed")
  ordinal <- env$mfrmr_gtds3b_kernel("ordinal_aggregate")
  expect_identical(gaussian$ProbeOutput, gaussian$ProbeInput)
  expect_identical(gaussian$ExpectedVariance, 1)
  expect_identical(heavy$DegreesFreedom, 5)
  expect_identical(heavy$ExpectedVariance, 1)
  expect_true(all(diff(heavy$ProbeOutput) > 0))
  expect_equal(heavy$ProbeOutput, -rev(heavy$ProbeOutput), tolerance = 1e-12)
  expect_identical(ordinal$Cutpoints, c(-1.25, -0.35, 0.35, 1.25))
  expect_identical(ordinal$ScoreValues, 0:4)
  expect_identical(ordinal$OutputSupport, "integer_0_to_4")
  expect_true(all(diff(ordinal$ProbeOutput) >= 0))
  expect_false(ordinal$IrtResponseModel)
  expect_false(ordinal$StochasticDrawQualified)
  expect_false(ordinal$ResponseGenerated)
  expect_false(ordinal$RngStreamOpened)
  expect_error(env$mfrmr_gtds3b_kernel("gpcm"), "not compiled")
})

test_that("binding replay is exact and leaves caller RNG unchanged", {
  env <- load_gtheory_dsim3b()
  first <- gtheory_dsim3b_manifest(env)
  set.seed(240833L)
  caller_state <- .Random.seed
  replay <- env$mfrmr_gtds3b_manifest()
  expect_identical(.Random.seed, caller_state)
  expect_identical(replay$ManifestHash, first$ManifestHash)
  expect_identical(replay$ProfileBindingRegistry,
                   first$ProfileBindingRegistry)
  expect_identical(replay$ComponentBindingRegistry,
                   first$ComponentBindingRegistry)
  expect_identical(replay$KernelBindingRegistry,
                   first$KernelBindingRegistry)
})

test_that("indefinite matrices and binding mutations fail closed", {
  env <- load_gtheory_dsim3b()
  indefinite <- matrix(c(1, 1.2, 1.2, 1), nrow = 2L,
                       dimnames = list(c("A", "B"), c("A", "B")))
  expect_error(
    env$mfrmr_gtds3b_matrix_audit(indefinite, "mutation"),
    "indefinite"
  )

  contract <- env$mfrmr_gtds3b_contract()
  coverage <- env$mfrmr_gtds3_manifest()
  compiler_contract <- env$mfrmr_gtds3c_contract()
  binding <- gtheory_dsim3b_binding(env, "D3-S001")
  changed <- binding
  changed$ComponentBindings$Object$CovarianceMatrix[1L, 2L] <- 0.41
  changed$ComponentBindings$Object$CovarianceMatrix[2L, 1L] <- 0.41
  changed$Summary$CovarianceRegistryHash <- env$mfrmr_gtds3b_hash(
    changed$ComponentBindings
  )
  changed$BindingHash <- env$mfrmr_gtds3b_hash(
    changed[env$mfrmr_gtds3b_binding_fields()]
  )
  expect_error(
    env$mfrmr_gtds3b_assert_binding(
      changed, contract, compiler_contract, coverage,
      validate = FALSE, replay = TRUE
    ), "altered"
  )

  repaired <- contract
  repaired$PsdRepairAllowed <- TRUE
  expect_error(env$mfrmr_gtds3b_validate_contract(
    repaired, env$mfrmr_gtds3c_manifest()
  ), "invalid")

  manifest <- gtheory_dsim3b_manifest(env)
  promoted <- manifest
  promoted$Summary$ExploratoryExecutionAllowed <- TRUE
  promoted$ManifestHash <- env$mfrmr_gtds3b_hash(
    promoted[env$mfrmr_gtds3b_manifest_fields()]
  )
  expect_error(env$mfrmr_gtds3b_assert_manifest(promoted), "altered")
})

test_that("binding remains outside public package surfaces", {
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
      "mfrmr_gtds3b_|",
      "MFRMR-GTHEORY-MV-DSIM3-COVARIANCE-DISTRIBUTION-BINDING"
    ), public_text
  )))
})
