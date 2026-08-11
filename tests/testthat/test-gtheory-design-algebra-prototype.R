gtheory_design_algebra_prototype_path <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    "gtheory-design-algebra-prototype-0.2.3.R"
  )
}

load_gtheory_design_algebra_prototype <- function() {
  path <- gtheory_design_algebra_prototype_path()
  skip_if_not(file.exists(path),
              "repository-internal validation artifacts are excluded")
  skip_if_not_installed("digest")
  if (!requireNamespace("reformulas", quietly = TRUE) &&
      !requireNamespace("lme4", quietly = TRUE)) {
    skip("Draft.81 formula parser requires reformulas or lme4")
  }
  env <- new.env(parent = globalenv())
  sys.source(path, envir = env)
  env
}

test_that("Draft.81 canonicalizes formula terms into typed effects", {
  env <- load_gtheory_design_algebra_prototype()
  spec <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Item:Rater) + (1 | Item:Person) +
      (1 | Item) + (1 | Rater:Person) + (1 | Person) + (1 | Rater),
    object = "Person", facets = c("Rater", "Item"),
    residual_scale_by = c("Item", "Rater")
  )

  expect_true(spec$DStudyEligible)
  expect_length(spec$Issues, 0L)
  expect_identical(
    spec$EffectMap$ComponentId,
    c(
      "Person", "Rater", "Item", "Person:Rater", "Person:Item",
      "Rater:Item", "Residual"
    )
  )
  expect_identical(
    spec$EffectMap$UniverseRole,
    c(
      "universe_score", "absolute_only", "absolute_only", "both_errors",
      "both_errors", "absolute_only", "both_errors"
    )
  )
  expect_identical(
    spec$EffectMap$ScaleBy,
    c("", "Rater", "Item", "Rater", "Item", "Rater:Item", "Rater:Item")
  )
  expect_identical(
    spec$FormulaCanonical,
    paste0(
      "Score ~ 1 + (1 | Person) + (1 | Rater) + (1 | Item) + ",
      "(1 | Person:Rater) + (1 | Person:Item) + (1 | Rater:Item)"
    )
  )
  expect_match(spec$DesignHash, "^[0-9a-f]{64}$")

  equivalent <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 || Person) + (1 | Rater) + (1 | Item) +
      (1 | Person:Rater) + (1 | Person:Item) + (1 | Rater:Item),
    object = "Person", facets = c("Rater", "Item"),
    residual_scale_by = c("Rater", "Item")
  )
  expect_identical(equivalent$DesignHash, spec$DesignHash)
})

test_that("Draft.81 reproduces the hand-calculated p x i oracle", {
  env <- load_gtheory_design_algebra_prototype()
  fixture <- env$mfrmr_gta_fixture("pxi")
  result <- env$mfrmr_gta_d_study(
    fixture$spec, fixture$components, fixture$design_grid
  )

  observed <- result$Scenarios[1L, names(fixture$expected), drop = FALSE]
  expect_equal(observed, fixture$expected, tolerance = 1e-14)
  expect_true(result$Scenarios$AlgebraReady)
  expect_false(result$Scenarios$DecisionReady)
  expect_identical(
    result$Scenarios$DecisionStatus,
    "prototype_no_estimation_or_uncertainty"
  )
  expect_identical(result$Scenarios$AlgebraStatus, "algebra_ok")
  expect_equal(
    result$Contributions$Divisor,
    c(Person = 1, Item = 4, Residual = 4),
    ignore_attr = TRUE
  )
  expect_match(result$ResultHash, "^[0-9a-f]{64}$")

  replay_grid <- fixture$design_grid
  row.names(replay_grid) <- "nonsemantic_row_name"
  replay <- env$mfrmr_gta_d_study(
    fixture$spec, rev(fixture$components), replay_grid
  )
  expect_identical(replay$ResultHash, result$ResultHash)
})

test_that("Draft.81 reproduces component-wise p x r x i algebra", {
  env <- load_gtheory_design_algebra_prototype()
  fixture <- env$mfrmr_gta_fixture("pxrxi")
  result <- env$mfrmr_gta_d_study(
    fixture$spec, fixture$components, fixture$design_grid
  )

  observed <- result$Scenarios[1L, names(fixture$expected), drop = FALSE]
  expect_equal(observed, fixture$expected, tolerance = 1e-14)
  contributions <- result$Contributions
  expect_equal(
    contributions$RelativeContribution[
      match(c("Person:Rater", "Person:Item", "Residual"),
            contributions$ComponentId)
    ],
    c(0.12, 0.10, 0.08),
    tolerance = 1e-14
  )
  expect_equal(
    contributions$AbsoluteContribution[
      match(c("Rater", "Item", "Rater:Item"),
            contributions$ComponentId)
    ],
    c(0.06, 0.06, 0.08 / 6),
    tolerance = 1e-14
  )

  grid <- expand.grid(n_Rater = c(1L, 2L, 4L), n_Item = 3L)
  scaled <- env$mfrmr_gta_d_study(fixture$spec, fixture$components, grid)
  expect_true(all(diff(scaled$Scenarios$G) > 0))
  expect_true(all(diff(scaled$Scenarios$Phi) > 0))
  expect_true(all(scaled$Scenarios$Phi <= scaled$Scenarios$G))
})

test_that("Draft.81 preserves negative raw components without readiness", {
  env <- load_gtheory_design_algebra_prototype()
  fixture <- env$mfrmr_gta_fixture("pxi")
  fixture$components[["Item"]] <- -0.2
  result <- env$mfrmr_gta_d_study(
    fixture$spec, fixture$components, fixture$design_grid
  )

  expect_identical(
    result$Scenarios$AlgebraStatus, "raw_negative_component"
  )
  expect_false(result$Scenarios$DecisionReady)
  expect_equal(
    result$Components$Estimate[result$Components$ComponentId == "Item"],
    -0.2
  )
})

test_that("Draft.81 fails before coefficients when semantics are unresolved", {
  env <- load_gtheory_design_algebra_prototype()
  unresolved <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Item),
    object = "Person", facets = "Item"
  )
  expect_false(unresolved$DStudyEligible)
  expect_true("unresolved_component_semantics" %in% unresolved$Issues)
  expect_error(
    env$mfrmr_gta_d_study(
      unresolved, c(Person = 1, Item = 0.2, Residual = 0.8),
      data.frame(n_Item = 4L)
    ),
    "not eligible for coefficient calculation"
  )

  incomplete <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Rater) + (1 | Item),
    object = "Person", facets = c("Rater", "Item"),
    residual_scale_by = c("Rater", "Item")
  )
  expect_false(incomplete$DStudyEligible)
  expect_true(any(grepl("missing_crossed_components", incomplete$Issues)))

  wrong_role <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Item),
    object = "Person", facets = "Item", residual_scale_by = "Item",
    residual_role = "absolute_only"
  )
  expect_true("residual_role_must_be_both_errors" %in% wrong_role$Issues)
})

test_that("Draft.81 exposes highest-order residual aliasing", {
  env <- load_gtheory_design_algebra_prototype()
  aliased <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Item) + (1 | Person:Item),
    object = "Person", facets = "Item",
    residual_scale_by = "Item", cell_replication = FALSE
  )

  expect_false(aliased$DStudyEligible)
  expect_true("highest_order_residual_alias" %in% aliased$Issues)
  expect_true(all(
    aliased$EffectMap$EstimabilityStatus[
      aliased$EffectMap$ComponentId %in% c("Person:Item", "Residual")
    ] == "aliased"
  ))
  expect_error(
    env$mfrmr_gta_d_study(
      aliased,
      c(Person = 1, Item = 0.2, `Person:Item` = 0.4, Residual = 0.4),
      data.frame(n_Item = 4L)
    ),
    "highest_order_residual_alias"
  )
})

test_that("Draft.81 retains nesting syntax but blocks unsupported scaling", {
  env <- load_gtheory_design_algebra_prototype()
  undeclared <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Site/Rater),
    object = "Person", facets = c("Site", "Rater"),
    residual_scale_by = c("Site", "Rater")
  )
  expect_identical(
    undeclared$FormulaNesting,
    data.frame(Parent = "Site", Child = "Rater")
  )
  expect_true("unresolved_nesting_metadata" %in% undeclared$Issues)

  declared <- env$mfrmr_gta_spec(
    Score ~ 1 + (1 | Person) + (1 | Site/Rater),
    object = "Person", facets = c("Site", "Rater"),
    nesting = data.frame(Parent = "Site", Child = "Rater"),
    residual_scale_by = c("Site", "Rater")
  )
  expect_identical(
    declared$FormulaCanonical,
    "Score ~ 1 + (1 | Person) + (1 | Site) + (1 | Site:Rater)"
  )
  expect_true("nested_scaling_not_supported" %in% declared$Issues)
  expect_error(
    env$mfrmr_gta_d_study(
      declared,
      c(Person = 1, Site = 0.2, `Site:Rater` = 0.3, Residual = 0.5),
      data.frame(n_Site = 2L, n_Rater = 3L)
    ),
    "nested_scaling_not_supported"
  )
})

test_that("Draft.81 rejects grammar and identity mismatches", {
  env <- load_gtheory_design_algebra_prototype()
  expect_error(
    env$mfrmr_gta_spec(
      Score ~ 1 + (1 + Time | Person) + (1 | Item),
      "Person", "Item", residual_scale_by = "Item"
    ),
    "random intercepts only"
  )
  expect_error(
    env$mfrmr_gta_spec(
      Score ~ Group + (1 | Person) + (1 | Item),
      "Person", "Item", residual_scale_by = "Item"
    ),
    "intercept-only fixed part"
  )
  expect_error(
    env$mfrmr_gta_spec(
      Score ~ 0 + (1 | Person) + (1 | Item),
      "Person", "Item", residual_scale_by = "Item"
    ),
    "intercept-only fixed part"
  )

  fixture <- env$mfrmr_gta_fixture("pxi")
  expect_error(
    env$mfrmr_gta_d_study(
      fixture$spec, c(Person = 1, Item = 0.2), fixture$design_grid
    ),
    "identities do not match"
  )
  expect_error(
    env$mfrmr_gta_d_study(
      fixture$spec,
      data.frame(
        ComponentId = c("Person", "Item", "Residual"),
        Estimate = factor(c("1", ".2", ".8"))
      ),
      fixture$design_grid
    ),
    "must be numeric"
  )
  expect_error(
    env$mfrmr_gta_d_study(
      fixture$spec, fixture$components, data.frame(n_Item = 1.5)
    ),
    "positive integers"
  )
})
