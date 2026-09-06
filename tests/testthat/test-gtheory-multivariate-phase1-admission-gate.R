phase1_gate_paths <- function() {
  testthat::test_path(
    "..", "..", "inst", "validation",
    c(
      "gtheory-multivariate-phase1-admission-gate-0.2.4.R",
      "gtheory-multivariate-phase1-owner-response-candidate-0.2.4.csv"
    )
  )
}

load_phase1_gate <- local({
  environment <- NULL
  function() {
    paths <- phase1_gate_paths()
    skip_if_not(all(file.exists(paths)),
                "repository-internal Phase 1 artifacts are excluded")
    skip_if_not_installed("digest")
    if (is.null(environment)) {
      environment <<- new.env(parent = globalenv())
      sys.source(paths[[1L]], envir = environment)
    }
    list(
      env = environment,
      candidate = utils::read.csv(
        paths[[2L]], stringsAsFactors = FALSE, check.names = FALSE,
        na.strings = NULL
      )
    )
  }
})

phase1_complete_enabled <- function(candidate) {
  response <- candidate
  response$Enabled <- c(TRUE, FALSE)
  response$DecisionOwnerId <- "TEST-OWNER-NOT-AUTHORIZATION"
  response$DecisionOwnerRole <- "test_practical_owner"
  response$ExternalEvidenceAnchor <- c(
    "TEST-ABS-ANCHOR", "TEST-REL-DISABLE-ANCHOR"
  )
  response$OwnerConfirmed <- TRUE
  response$NamedOperationalUse[[1L]] <-
    "test absolute composite dependability use"
  response$AffectedWorkflowIdentity[[1L]] <- "TEST-WORKFLOW-V1"
  response$TargetPopulationIdentity[[1L]] <- "TEST-POPULATION-V1"
  response$ConsequenceIdentity[[1L]] <- "TEST-CONSEQUENCE-V1"
  response$DisableRationaleIfNotEnabled[[2L]] <-
    "no test rank-ordering workflow"
  response
}

phase1_complete_stop <- function(candidate) {
  response <- candidate
  response$Enabled <- FALSE
  response$DecisionOwnerId <- "TEST-OWNER-NOT-AUTHORIZATION"
  response$DecisionOwnerRole <- "test_practical_owner"
  response$ExternalEvidenceAnchor <- c(
    "TEST-ABS-DISABLE-ANCHOR", "TEST-REL-DISABLE-ANCHOR"
  )
  response$DisableRationaleIfNotEnabled <- c(
    "no test absolute-score workflow", "no test rank-ordering workflow"
  )
  response$OwnerConfirmed <- TRUE
  response
}

test_that("Phase 1 candidate remains pending and nonauthorizing", {
  objects <- load_phase1_gate()
  env <- objects$env
  candidate <- objects$candidate
  expect_invisible(env$mfrmr_gtp1_validate_response(candidate))
  result <- env$mfrmr_gtp1_adjudicate(candidate)
  expect_s3_class(result, "mfrmr_gtp1_adjudication")
  expect_identical(
    result$Summary$GateStatus, "pending_external_owner_evidence"
  )
  expect_identical(result$Summary$PendingFamilyCount, 2L)
  expect_false(result$Summary$ResponseEvidenceComplete)
  expect_false(result$Summary$StopNoOperationalUse)
  expect_false(result$Summary$AdvanceToPhase2EvidenceCollection)
  expect_false(result$Summary$OwnerPacketFamilyRegistryConstructionAllowed)
  expect_false(result$Summary$Dsim0Satisfied)
  expect_false(result$Summary$SimulationExecutionAllowed)
  expect_false(result$Summary$PlannedSeedAccessAllowed)
  expect_true(all(!result$FamilyReadiness$RequiredEvidenceComplete))
  expect_true(all(!result$FamilyReadiness$OwnerEnablementMayBeInferred))
})

test_that("Phase 1 can advance evidence collection without execution", {
  objects <- load_phase1_gate()
  response <- phase1_complete_enabled(objects$candidate)
  result <- objects$env$mfrmr_gtp1_adjudicate(response)
  expect_identical(
    result$Summary$GateStatus,
    "completed_advance_to_phase2_evidence_collection"
  )
  expect_identical(result$Summary$EnabledFamilyCount, 1L)
  expect_identical(result$Summary$DisabledFamilyCount, 1L)
  expect_identical(result$Summary$PendingFamilyCount, 0L)
  expect_true(result$Summary$ResponseEvidenceComplete)
  expect_true(result$Summary$AdvanceToPhase2EvidenceCollection)
  expect_true(result$Summary$OwnerPacketFamilyRegistryConstructionAllowed)
  expect_false(result$Summary$Dsim0Satisfied)
  expect_false(result$Summary$SimulationExecutionAllowed)
  expect_false(result$Summary$PlannedSeedAccessAllowed)
})

test_that("Phase 1 records a completed terminal stop", {
  objects <- load_phase1_gate()
  response <- phase1_complete_stop(objects$candidate)
  result <- objects$env$mfrmr_gtp1_adjudicate(response)
  expect_identical(
    result$Summary$GateStatus, "completed_stop_no_operational_use"
  )
  expect_identical(result$Summary$EnabledFamilyCount, 0L)
  expect_identical(result$Summary$DisabledFamilyCount, 2L)
  expect_identical(result$Summary$PendingFamilyCount, 0L)
  expect_true(result$Summary$ResponseEvidenceComplete)
  expect_true(result$Summary$StopNoOperationalUse)
  expect_false(result$Summary$AdvanceToPhase2EvidenceCollection)
  expect_false(result$Summary$OwnerPacketFamilyRegistryConstructionAllowed)
  expect_false(result$Summary$Dsim0Satisfied)
  expect_false(result$Summary$SimulationExecutionAllowed)
  expect_false(result$Summary$PlannedSeedAccessAllowed)
  expect_match(result$Summary$NextAction, "terminal stop", fixed = TRUE)
})

test_that("Phase 1 rejects mutation and self-authorization", {
  objects <- load_phase1_gate()
  env <- objects$env
  changed_hash <- objects$candidate
  changed_hash$ContractHash[[1L]] <- paste0(
    "0", substring(changed_hash$ContractHash[[1L]], 2L)
  )
  expect_error(
    env$mfrmr_gtp1_validate_response(changed_hash),
    "not bound to the current v3 candidate"
  )

  self_ready <- objects$candidate
  self_ready$Ready[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtp1_validate_response(self_ready), "cannot self-authorize"
  )
  self_execution <- objects$candidate
  self_execution$SimulationExecutionAllowed[[1L]] <- TRUE
  expect_error(
    env$mfrmr_gtp1_validate_response(self_execution),
    "cannot self-authorize"
  )

  incomplete_enabled <- phase1_complete_enabled(objects$candidate)
  incomplete_enabled$ConsequenceIdentity[[1L]] <- NA_character_
  pending <- env$mfrmr_gtp1_adjudicate(incomplete_enabled)
  expect_identical(
    pending$Summary$GateStatus, "pending_external_owner_evidence"
  )
  expect_false(pending$Summary$AdvanceToPhase2EvidenceCollection)
  expect_false(pending$Summary$SimulationExecutionAllowed)
})
