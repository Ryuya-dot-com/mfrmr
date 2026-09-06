gtheory_dsim1_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-design-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-algebra-prototype-0.2.3.R",
      "gtheory-multivariate-incidence-preflight-0.2.4.R",
      "gtheory-multivariate-package-capability-contract-v4-0.2.4.R",
      "gtheory-multivariate-dsim1-deterministic-qualification-0.2.4.R"
    )
  )
}

load_gtheory_dsim1 <- local({
  environment <- NULL
  function() {
    paths <- gtheory_dsim1_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal D-SIM-1 artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      for (path in paths) sys.source(path, envir = environment)
    }
    environment
  }
})

test_that("D-SIM-1 binds five canonical designs without operational inputs", {
  env <- load_gtheory_dsim1()
  designs <- env$mfrmr_gtds1_design_registry()
  expect_invisible(env$mfrmr_gtds1_validate_design_registry(designs))
  expect_identical(nrow(designs), 5L)
  expect_identical(
    designs$DesignId,
    c(
      "U1-CLOSURE", "S2-DISJOINT-DISTINCT", "S2-SHARED-LINKED",
      "S3-PARTIAL-MIXED", "S2-DISCONNECTED-NEGATIVE"
    )
  )
  expect_true(any(designs$DesignRole == "structural_negative_control"))
  expect_true(all(!designs$PackageSupportReady))
  expect_false(any(grepl(
    "owner|workflow|consequence",
    paste(names(designs), collapse = " "), ignore.case = TRUE
  )))
})

test_that("D-SIM-1 independently closes the public one-stratum formulas", {
  env <- load_gtheory_dsim1()
  oracle <- env$mfrmr_gtds1_univariate_closure_oracle()
  expect_true(all(oracle$Checks$Pass))
  expect_equal(oracle$Result$G, 1.2 / 1.35, tolerance = 1e-14)
  expect_equal(oracle$Result$Phi, 1.2 / 1.5, tolerance = 1e-14)
  expect_lte(oracle$Result$Phi, oracle$Result$G)

  if (exists("mfrm_d_study", mode = "function", inherits = TRUE)) {
    public_gt <- structure(
      list(
        variance_components = data.frame(
          Source = c("Person", "Item", "Replicate", "Residual"),
          Variance = c(1.2, 0.3, 0, 0.6), stringsAsFactors = FALSE
        ),
        design = list(
          object_facet = "Person", random_facets = c("Item", "Replicate"),
          observed_levels = c(Person = 10L, Item = 2L, Replicate = 2L),
          identification_status = "identified", boundary_fit = FALSE
        )
      ),
      class = c("mfrm_generalizability", "list")
    )
    public <- mfrm_d_study(
      public_gt, data.frame(Item = 2L, Replicate = 2L),
      residual_scaling = "highest_order"
    )
    expect_equal(public$G, round(oracle$Result$G, 4), tolerance = 1e-14)
    expect_equal(public$Phi, round(oracle$Result$Phi, 4), tolerance = 1e-14)
  }
})

test_that("D-SIM-1 preserves labels and fails closed outside PSD", {
  env <- load_gtheory_dsim1()
  invariance <- env$mfrmr_gtds1_label_invariance_oracle()
  psd <- env$mfrmr_gtds1_psd_oracle()
  expect_true(all(invariance$Pass))
  expect_true(all(invariance$AbsoluteError <= 1e-10))
  expect_true(all(psd$Pass))
})

test_that("D-SIM-1 distinguishes incidence and observation-event identity", {
  env <- load_gtheory_dsim1()
  incidence <- env$mfrmr_gtds1_incidence_oracle()
  events <- env$mfrmr_gtds1_observation_event_oracle()
  expect_true(all(incidence$Pass))
  expect_true(all(events$Pass))
  negative <- incidence$DesignId == "S2-DISCONNECTED-NEGATIVE"
  expect_false(incidence$ActualIncidenceReady[negative])
  expect_match(
    incidence$SharingStates[incidence$DesignId == "S2-DISJOINT-DISTINCT"],
    "structurally_disjoint_by_scope", fixed = TRUE
  )
  expect_identical(
    events$ActualRelationship,
    c(
      "distinct_event_per_stratum_score",
      "one_event_yields_multiple_stratum_scores",
      "mixed_explicit_event_map"
    )
  )
})

test_that("D-SIM-1 route qualification is design-dependent and nonauthorizing", {
  env <- load_gtheory_dsim1()
  routes <- env$mfrmr_gtds1_route_oracle()
  expect_identical(nrow(routes), 20L)
  expect_true(all(routes$Pass))
  status <- function(design, route) {
    routes$QualificationStatus[
      routes$DesignId == design & routes$RouteId == route
    ]
  }
  expect_identical(
    status("S2-DISJOINT-DISTINCT", "mv_reml_lme4"),
    "conditional_sensitivity"
  )
  expect_identical(
    status("S2-SHARED-LINKED", "mv_reml_lme4"),
    "ineligible_correlated_level1_residual"
  )
  expect_identical(
    status("S3-PARTIAL-MIXED", "custom_covariance_contract"),
    "required"
  )
  expect_true(all(
    routes$QualificationStatus[
      routes$DesignId == "S2-DISCONNECTED-NEGATIVE"
    ] == "structural_negative_control_rejected"
  ))
  expect_true(all(!routes$ExecutionAllowed))
  expect_true(all(!routes$PublicSupportReady))
})

test_that("D-SIM-1 completes only deterministic qualification", {
  env <- load_gtheory_dsim1()
  result <- env$mfrmr_gtds1_run()
  expect_s3_class(result, "mfrmr_gtds1_qualification")
  expect_identical(
    result$Summary$GateStatus,
    "dsim1_deterministic_oracles_complete_dsim2_allowed"
  )
  expect_identical(result$Summary$CanonicalDesignCount, 5L)
  expect_identical(result$Summary$CriterionCount, 7L)
  expect_identical(result$Summary$PassedCriterionCount, 7L)
  expect_identical(result$Summary$UniqueEvidenceRowCount, 39L)
  expect_identical(result$Summary$CriterionEvidenceAssignmentCount, 43L)
  expect_true(result$Summary$Dsim1Satisfied)
  expect_true(result$Summary$Dsim2Allowed)
  expect_true(result$Summary$DeterministicFixtureConstructed)
  expect_false(result$Summary$StochasticResponseGenerated)
  expect_false(result$Summary$FitExecuted)
  expect_false(result$Summary$PlannedSeedAccessAllowed)
  expect_false(result$Summary$ExploratorySimulationAllowed)
  expect_false(result$Summary$ConfirmationSimulationAllowed)
  expect_false(result$Summary$PublicSupportReady)
  expect_identical(
    result$Summary$QualificationHash,
    "6fd89f49fe6238a56bb5621fa07cfb2f7ddb4aba4d3323b69246a99620b937db"
  )
})

test_that("D-SIM-1 rejects mutation and malformed event identity", {
  env <- load_gtheory_dsim1()
  changed <- env$mfrmr_gtds_v4_contract()
  changed$ContractHash <- paste0("0", substring(changed$ContractHash, 2L))
  expect_error(env$mfrmr_gtds1_run(changed), "contract is invalid")

  designs <- env$mfrmr_gtds1_design_registry()
  designs$PackageSupportReady[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtds1_validate_design_registry(designs), "registry is invalid"
  )

  events <- env$mfrmr_gtds1_observation_event_map("S2-SHARED-LINKED")
  duplicate <- rbind(events, events[1L, , drop = FALSE])
  expect_error(
    env$mfrmr_gtds1_classify_observation_events(duplicate), "malformed"
  )
})
