load_gtheory_dsim4a <- local({
  loaded <- NULL
  function() {
    root <- testthat::test_path("..", "..")
    validation <- file.path(root, "inst", "validation")
    controller <- file.path(
      validation,
      paste0(
        "gtheory-multivariate-dsim3-bounded-exploratory-launch-",
        "controller-0.2.4.R"
      )
    )
    descriptive <- file.path(
      validation,
      paste0(
        "gtheory-multivariate-dsim3-descriptive-recovery-",
        "adjudication-0.2.4.R"
      )
    )
    admission <- file.path(
      validation,
      "gtheory-multivariate-dsim4-admission-decision-0.2.4.R"
    )
    record <- file.path(
      validation,
      "gtheory-multivariate-dsim4-admission-decision-record-0.2.4.md"
    )
    skip_if_not(
      all(file.exists(c(controller, descriptive, admission, record))),
      "repository-internal D-SIM-4 admission evidence excluded"
    )
    skip_if_not_installed("digest")
    if (is.null(loaded)) {
      probe <- new.env(parent = globalenv())
      sys.source(controller, envir = probe, keep.source = FALSE)
      environment <- new.env(parent = globalenv())
      for (basename in head(probe$mfrmr_gtds3ac_source_basenames(), -1L)) {
        sys.source(file.path(validation, basename), envir = environment,
                   keep.source = FALSE)
      }
      sys.source(descriptive, envir = environment, keep.source = FALSE)
      sys.source(admission, envir = environment, keep.source = FALSE)
      loaded <<- list(
        Environment = environment, SourceRoot = root, RecordPath = record
      )
    }
    loaded
  }
})

test_that("D-SIM-4 admission opens contract construction only", {
  env <- load_gtheory_dsim4a()$Environment
  contract <- env$mfrmr_gtds4a_contract()
  expect_invisible(env$mfrmr_gtds4a_validate_contract(contract))
  expect_identical(
    contract$ContractHash,
    "a4158f9afc9aab4e250a6b4a1c5341299ba79da094fb5b60b5bf72928ff72380"
  )
  expect_identical(
    contract$DecisionOutcome, "admit_contract_construction_only"
  )
  expect_true(contract$Dsim4ContractConstructionAdmitted)
  expect_false(contract$Dsim4FreezeComplete)
  expect_false(contract$Dsim5ExecutionAuthorized)
  expect_false(contract$PlannedResponseGenerationAllowed)
  expect_false(contract$BackendCallAllowed)
  expect_false(contract$ConfirmationFitAllowed)
  expect_false(contract$PublicSupportPromotionAllowed)
  expect_false(contract$Dsim3OutcomeRanksMaySelectConfirmationScenarios)
  expect_false(contract$Dsim3LowErrorProfilesMayReceivePreferentialWeight)
  expect_true(contract$Dsim3FailuresAndBoundarySignalsMustRemainVisible)
  expect_false(contract$WithinBackendParityCountsAsIndependentReference)
  expect_false(contract$NamedOperationalOwnerRequired)
  expect_false(contract$UserActionConsequenceRequired)
})

test_that("D-SIM-4 admission record preserves the claim boundary", {
  loaded <- load_gtheory_dsim4a()
  record <- paste(readLines(loaded$RecordPath, warn = FALSE), collapse = "\n")
  expect_match(
    record,
    "2c98b5f29bafca074f4d095ce51c5c9ad2e04253cef48292a691b307d9c45282",
    fixed = TRUE
  )
  expect_match(record, "8/8 required criteria", fixed = TRUE)
  expect_match(record, "0/14 confirmation requirements", fixed = TRUE)
  expect_match(record, "admit_contract_construction_only", fixed = TRUE)
  expect_match(record, "does not depend on an operational\\s+owner")
  expect_match(record, "D-SIM-5 execution authorized: **no**", fixed = TRUE)
  expect_match(record, "feature maturity: `specified`", fixed = TRUE)
})

test_that("local D-SIM-4 admission manifest is exact when present", {
  loaded <- load_gtheory_dsim4a()
  env <- loaded$Environment
  descriptive_path <- file.path(
    loaded$SourceRoot, "validation-results",
    "gtheory-multivariate-dsim3-descriptive-recovery-0.2.4",
    "descriptive-recovery-manifest.rds"
  )
  admission_path <- file.path(
    loaded$SourceRoot, "validation-results",
    "gtheory-multivariate-dsim4-admission-0.2.4",
    "admission-manifest.rds"
  )
  if (!all(file.exists(c(descriptive_path, admission_path)))) {
    skip("local D-SIM-4 admission binary evidence is not present")
  }
  descriptive <- readRDS(descriptive_path)
  manifest <- readRDS(admission_path)
  expect_invisible(env$mfrmr_gtds4a_assert_manifest(manifest))
  expect_identical(
    manifest$ManifestHash,
    "2c98b5f29bafca074f4d095ce51c5c9ad2e04253cef48292a691b307d9c45282"
  )
  expect_identical(
    env$mfrmr_gtds4a_manifest(descriptive)$ManifestHash,
    manifest$ManifestHash
  )
  expect_true(all(manifest$AdmissionCriterionRegistry$Satisfied))
  expect_identical(nrow(manifest$AdmissionCriterionRegistry), 8L)
  expect_identical(nrow(manifest$FreezeRequirementRegistry), 14L)
  expect_true(all(
    manifest$FreezeRequirementRegistry$MustBeFrozenBeforeDsim5
  ))
  expect_true(all(
    !manifest$FreezeRequirementRegistry$FrozenByThisAdmission
  ))
  expect_false(manifest$Summary$LocalScenarioOptimizationAuthorized)
  expect_true(manifest$Summary$ConfirmationContractConstructionAdmitted)
  expect_false(manifest$Summary$ConfirmationContractFrozen)
  expect_false(manifest$Summary$Dsim5ExecutionAuthorized)
  expect_false(manifest$Summary$SimulationValidationReady)
  expect_false(manifest$Summary$ReferenceValidationReady)
  expect_false(manifest$Summary$PublicSupportReady)
})
