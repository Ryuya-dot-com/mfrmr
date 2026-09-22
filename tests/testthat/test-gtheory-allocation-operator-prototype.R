gtheory_allocation_operator_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-design-incidence-audit-0.2.3.R",
      "gtheory-allocation-operator-prototype-0.2.3.R"
    )
  )
}

load_gtheory_allocation_operator <- function() {
  paths <- gtheory_allocation_operator_paths()
  skip_if_not(all(file.exists(paths)),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  for (path in paths) sys.source(path, envir = env)
  env
}

gto_pxi_spec <- function(env) {
  env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Item),
    object = "Person", facets = "Item", residual_scale_by = "Item"
  )
}

test_that("Draft.83b balanced operators reduce exactly to Draft.81", {
  env <- load_gtheory_allocation_operator()
  for (kind in c("pxi", "pxrxi")) {
    fixture <- env$mfrmr_gta_fixture(kind)
    allocation <- env$mfrmr_gto_crossed_balanced_allocation(
      fixture$spec, fixture$design_grid, units = 2L
    )
    operator <- env$mfrmr_gto_operator(fixture$spec, allocation)
    applied <- env$mfrmr_gto_apply(
      fixture$spec, operator, fixture$components
    )
    oracle <- env$mfrmr_gta_d_study(
      fixture$spec, fixture$components, fixture$design_grid
    )

    expect_true(operator$ComponentScalingReady)
    expect_true(operator$JointAllocationReady)
    expect_false(operator$CoefficientEligible)
    expect_false(operator$DecisionReady)
    expect_true(applied$ScenarioResults$AlgebraReady)
    expect_equal(applied$ScenarioResults$ScalarG, oracle$Scenarios$G,
                 tolerance = 1e-14)
    expect_equal(applied$ScenarioResults$ScalarPhi, oracle$Scenarios$Phi,
                 tolerance = 1e-14)
    expect_false(applied$ScenarioResults$DecisionReady)
    expect_false(applied$InferenceReady)

    first_unit <- operator$ComponentOperators[
      operator$ComponentOperators$Unit == "Unit_1", , drop = FALSE
    ]
    expected_divisors <- oracle$Contributions$Divisor[
      match(first_unit$ComponentId, oracle$Contributions$ComponentId)
    ]
    expect_equal(first_unit$ScalingFactor, 1 / expected_divisors,
                 tolerance = 1e-14)
    expect_match(operator$OperatorHash, "^[0-9a-f]{64}$")
    expect_match(applied$ResultHash, "^[0-9a-f]{64}$")
  }
})

test_that("Draft.83b uses conditional level identities for nested allocation", {
  env <- load_gtheory_allocation_operator()
  spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Site/Rater),
    object = "Person", facets = c("Site", "Rater"),
    nesting = data.frame(Parent = "Site", Child = "Rater"),
    residual_scale_by = c("Site", "Rater")
  )
  allocation <- expand.grid(
    Scenario = "nested",
    Unit = c("U1", "U2"),
    Site = c("S1", "S2"),
    Rater = c("R1", "R2", "R3"),
    stringsAsFactors = FALSE
  )
  allocation$Weight <- 1 / 6

  operator <- env$mfrmr_gto_operator(spec, allocation)
  applied <- env$mfrmr_gto_apply(
    spec, operator,
    c(Person = 1, Site = .1, `Site:Rater` = .2, Residual = .7)
  )

  expect_identical(operator$ResolvedPriorIssues,
                   "nested_scaling_not_supported")
  expect_true(all(is.na(operator$UnitDesignAudit$SupportCoverage)))
  expect_true(all(
    operator$UnitDesignAudit$StructuralCellBasis ==
      "explicit_planned_nested_support"
  ))
  expect_equal(operator$UnitDesignAudit$PlannedSupportCells, c(6L, 6L))
  expect_equal(operator$UnitDesignAudit$CartesianEffectiveCells,
               c(12, 12))
  unit_one <- operator$ComponentOperators[
    operator$ComponentOperators$Unit == "U1", , drop = FALSE
  ]
  expect_equal(
    unit_one$ScalingFactor[
      match(c("Person", "Site", "Site:Rater", "Residual"),
            unit_one$ComponentId)
    ],
    c(1, 1 / 2, 1 / 6, 1 / 6), tolerance = 1e-14
  )
  expect_equal(
    operator$FactorAudit$PlannedLevels[
      operator$FactorAudit$Unit == "U1" &
        operator$FactorAudit$Factor == "Rater"
    ],
    6L
  )
  expect_equal(applied$UnitResults$RelativeErrorVariance,
               rep(.7 / 6, 2), tolerance = 1e-14)
  expect_equal(applied$UnitResults$AbsoluteErrorVariance,
               rep(.7 / 6 + .1 / 2 + .2 / 6, 2), tolerance = 1e-14)
  expect_true(applied$ScenarioResults$AlgebraReady)
  expect_false(applied$DecisionReady)
})

test_that("Draft.83b keeps heterogeneous unit coefficients unit-specific", {
  env <- load_gtheory_allocation_operator()
  spec <- gto_pxi_spec(env)
  allocation <- data.frame(
    Scenario = "unequal",
    Unit = c("U1", "U1", "U2", "U2"),
    Item = c("I1", "I2", "I1", "I2"),
    Weight = c(.5, .5, .8, .2),
    stringsAsFactors = FALSE
  )

  operator <- env$mfrmr_gto_operator(spec, allocation)
  applied <- env$mfrmr_gto_apply(
    spec, operator, c(Person = 1, Item = .2, Residual = .8)
  )
  residual <- operator$ComponentOperators[
    operator$ComponentOperators$ComponentId == "Residual", , drop = FALSE
  ]

  expect_equal(residual$ScalingFactor[match(c("U1", "U2"), residual$Unit)],
               c(.5, .68), tolerance = 1e-14)
  expect_equal(residual$EffectiveCount[match(c("U1", "U2"), residual$Unit)],
               c(2, 1 / .68), tolerance = 1e-14)
  expect_false(operator$ScenarioAudit$HomogeneousFullOperator)
  expect_identical(operator$ScenarioAudit$ScalarAggregationStatus,
                   "heterogeneous_unit_specific_only")
  expect_false(applied$ScenarioResults$AlgebraReady)
  expect_true(is.na(applied$ScenarioResults$ScalarG))
  expect_true(is.na(applied$ScenarioResults$ScalarPhi))
  expect_identical(applied$ScenarioResults$ScalarStatus,
                   "heterogeneous_unit_specific_only")
  expect_true(all(applied$UnitResults$AlgebraReady))
  expect_false(isTRUE(all.equal(
    applied$UnitResults$G[[1L]], applied$UnitResults$G[[2L]]
  )))
  expect_true(all(!applied$UnitResults$DecisionReady))
})

test_that("Draft.83b separates allocation overlap from object interactions", {
  env <- load_gtheory_allocation_operator()
  spec <- gto_pxi_spec(env)
  shared <- data.frame(
    Scenario = "shared",
    Unit = c("U1", "U1", "U2", "U2"),
    Item = c("I1", "I2", "I1", "I2"),
    Weight = c(.5, .5, .8, .2),
    stringsAsFactors = FALSE
  )
  shared_operator <- env$mfrmr_gto_operator(spec, shared)
  item_overlap <- shared_operator$CrossUnitOverlap[
    shared_operator$CrossUnitOverlap$ComponentId == "Item", , drop = FALSE
  ]
  residual_overlap <- shared_operator$CrossUnitOverlap[
    shared_operator$CrossUnitOverlap$ComponentId == "Residual", , drop = FALSE
  ]

  expect_equal(item_overlap$AllocationOverlap, .5, tolerance = 1e-14)
  expect_equal(item_overlap$CovarianceMultiplier, .5, tolerance = 1e-14)
  expect_equal(residual_overlap$AllocationOverlap, .5, tolerance = 1e-14)
  expect_equal(residual_overlap$CovarianceMultiplier, 0)
  expect_identical(item_overlap$SharingState,
                   "partial_or_unequal_overlap")

  disjoint <- shared
  disjoint$Scenario <- "disjoint"
  disjoint$Item[disjoint$Unit == "U2"] <- c("J1", "J2")
  disjoint$Weight <- rep(.5, 4L)
  disjoint_operator <- env$mfrmr_gto_operator(spec, disjoint)
  disjoint_item <- disjoint_operator$CrossUnitOverlap[
    disjoint_operator$CrossUnitOverlap$ComponentId == "Item", , drop = FALSE
  ]
  disjoint_applied <- env$mfrmr_gto_apply(
    spec, disjoint_operator, c(Person = 1, Item = .2, Residual = .8)
  )

  expect_equal(disjoint_item$AllocationOverlap, 0)
  expect_equal(disjoint_item$CovarianceMultiplier, 0)
  expect_identical(disjoint_item$SharingState, "disjoint_support")
  expect_equal(disjoint_applied$UnitResults$G[[1L]],
               disjoint_applied$UnitResults$G[[2L]], tolerance = 1e-14)
  expect_false(disjoint_applied$ScenarioResults$AlgebraReady)
  expect_true(is.na(disjoint_applied$ScenarioResults$ScalarG))
})

test_that("Draft.83b allocation identities are invariant to row order", {
  env <- load_gtheory_allocation_operator()
  fixture <- env$mfrmr_gta_fixture("pxrxi")
  allocation <- env$mfrmr_gto_crossed_balanced_allocation(
    fixture$spec, fixture$design_grid, units = 2L
  )
  original <- env$mfrmr_gto_operator(fixture$spec, allocation)
  replay <- env$mfrmr_gto_operator(
    fixture$spec, allocation[rev(seq_len(nrow(allocation))), ]
  )
  original_result <- env$mfrmr_gto_apply(
    fixture$spec, original, fixture$components
  )
  replay_result <- env$mfrmr_gto_apply(
    fixture$spec, replay, rev(fixture$components)
  )

  expect_identical(replay$AllocationHash, original$AllocationHash)
  expect_identical(replay$OperatorHash, original$OperatorHash)
  expect_identical(replay_result$ResultHash, original_result$ResultHash)
})

test_that("Draft.83b preserves raw negative component non-readiness", {
  env <- load_gtheory_allocation_operator()
  fixture <- env$mfrmr_gta_fixture("pxi")
  allocation <- env$mfrmr_gto_crossed_balanced_allocation(
    fixture$spec, fixture$design_grid
  )
  operator <- env$mfrmr_gto_operator(fixture$spec, allocation)
  components <- fixture$components
  components[["Item"]] <- -.2
  applied <- env$mfrmr_gto_apply(fixture$spec, operator, components)

  expect_identical(applied$UnitResults$AlgebraStatus,
                   "raw_negative_component")
  expect_false(applied$UnitResults$AlgebraReady)
  expect_identical(applied$ScenarioResults$ScalarStatus,
                   "raw_negative_component")
  expect_false(applied$ScenarioResults$AlgebraReady)
  expect_false(applied$DecisionReady)
})

test_that("Draft.83b fails closed for ambiguous or malformed allocation", {
  env <- load_gtheory_allocation_operator()
  spec <- gto_pxi_spec(env)
  valid <- data.frame(
    Scenario = "s", Unit = c("U1", "U1", "U2", "U2"),
    Item = c("I1", "I2", "I1", "I2"),
    Weight = rep(.5, 4L), stringsAsFactors = FALSE
  )

  unnormalized <- valid
  unnormalized$Weight[unnormalized$Unit == "U1"] <- c(.4, .5)
  expect_error(env$mfrmr_gto_operator(spec, unnormalized),
               "never normalizes them silently")

  duplicate <- rbind(valid, valid[1L, ])
  expect_error(env$mfrmr_gto_operator(spec, duplicate),
               "must appear once")

  nonpositive <- valid
  nonpositive$Weight[[1L]] <- 0
  expect_error(env$mfrmr_gto_operator(spec, nonpositive),
               "strictly positive")

  expect_error(env$mfrmr_gto_operator(spec, valid, max_overlap_rows = 0),
               "does not drop pairs silently")

  other_spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Rater),
    object = "Person", facets = "Rater", residual_scale_by = "Rater"
  )
  operator <- env$mfrmr_gto_operator(spec, valid)
  expect_error(
    env$mfrmr_gto_apply(
      other_spec, operator, c(Person = 1, Rater = .2, Residual = .8)
    ),
    "does not match"
  )

  object_nested <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Rater),
    object = "Person", facets = "Rater",
    nesting = data.frame(Parent = "Person", Child = "Rater"),
    residual_scale_by = "Rater"
  )
  expect_error(
    env$mfrmr_gto_operator(object_nested, valid),
    "explicit superpopulation error-role contract"
  )
})
