g4v6_root <- function() {
  normalizePath(
    file.path(testthat::test_path(), "..", ".."),
    winslash = "/", mustWork = TRUE
  )
}

g4v6_source <- function(path, parent = globalenv()) {
  environment <- new.env(parent = parent)
  sys.source(path, envir = environment)
  environment
}

test_that("post-maintenance G4 v6 contract is frozen and unopened", {
  root <- g4v6_root()
  path <- file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R"
  )
  expect_true(file.exists(path))
  contract <- g4v6_source(path)
  review <- contract$mfrmr_fc_g4v6_review()
  expect_identical(
    review$status,
    "G4_v6_rules_frozen_candidate_unbound_confirmation_unopened"
  )
  expect_identical(
    review$contract_version,
    "mfrmr_fixed_calibration_g4_post_maintenance_evidence_v6"
  )
  expect_true(review$rules_frozen)
  expect_true(review$v6_identities_disjoint_and_frozen)
  expect_true(review$denominator_frozen)
  expect_true(review$compiled_boundary_frozen)
  expect_false(review$candidate_binding_complete)
  expect_false(review$v6_execution_opened)
  expect_false(review$G4_exit_complete)
  expect_false(review$G6_authorized)

  record <- paste(readLines(file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-contract-record-0.2.4.md"
  ), warn = FALSE), collapse = "\n")
  expect_match(record, review$specification, fixed = TRUE)
  expect_match(record, "`V6ContractFrozen=TRUE`", fixed = TRUE)
  expect_match(record, "`V6CandidateBound=FALSE`", fixed = TRUE)
  expect_match(record, "`V6ExecutionOpened=FALSE`", fixed = TRUE)
  expect_match(record, "`HistoricalV5ReceiptsReusableForV6=FALSE`",
               fixed = TRUE)

  source_text <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_false(grepl("fit_mfrm\\s*\\(", source_text, perl = TRUE))
  expect_false(grepl(
    "mfrmr_score_calibration\\s*\\(", source_text, perl = TRUE
  ))
  expect_false(grepl(
    "saveRDS\\s*\\(|readRDS\\s*\\(|system2\\s*\\(",
    source_text, perl = TRUE
  ))
})

test_that("v6 identities are disjoint from every consumed authority", {
  root <- g4v6_root()
  contract <- g4v6_source(file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R"
  ))
  design <- contract$mfrmr_fc_g4v6_confirmation_design()
  current <- design[design$DisjointV6ConfirmationAuthority, , drop = FALSE]
  control <- design[
    design$EvidenceRole == "historical_explicit9_regression_control", ,
    drop = FALSE
  ]
  expect_identical(nrow(current), 4L)
  expect_false(any(current$PreviouslyUsedFixture))
  expect_false(any(current$V6ExecutionOpened))
  expect_setequal(current$Modulus, c(1061L, 1063L))
  expect_true(all(grepl("mod1061|mod1063", current$GeneratorIdentity)))
  expect_false(any(grepl(
    "mod997|mod1009|mod1013|mod1019|mod1021|mod1031|mod1033|mod1039|mod1049",
    current$GeneratorIdentity
  )))
  expect_identical(current$SourcePersons, c(61L, 61L, 53L, 53L))
  expect_identical(
    current$ConfirmationPersons, c(13L, 13L, 10L, 10L)
  )
  expect_identical(current$FitQuadratureOrder, c(15L, 15L, 1L, 1L))
  expect_true(all(current$ScoringQuadratureOrder == 31L))
  expect_identical(nrow(control), 2L)
  expect_true(all(control$PreviouslyUsedFixture))
  expect_false(any(control$DisjointV6ConfirmationAuthority))
  expect_false(any(control$ControlMayAuthorizeV6G4))
})

test_that("v6 boundary binds compiled maintenance inputs", {
  root <- g4v6_root()
  contract <- g4v6_source(file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R"
  ))
  boundary <- contract$mfrmr_fc_g4v6_production_boundary()
  expect_identical(nrow(boundary), 8L)
  expect_setequal(boundary$Path, c(
    "R/core-fixed-calibration.R", "R/api-prediction.R",
    "R/api-reference-benchmark.R", "R/api-export-bundles.R",
    "R/core-optimizer.R", "DESCRIPTION", "src/mml_backend.cpp",
    "src/cpp11.cpp"
  ))
  expect_true(all(boundary$RequiredInCandidateRegistry))

  old <- Sys.getenv("MFRMR_G4_CONTRACT_GENERATION", unset = NA_character_)
  on.exit({
    if (is.na(old)) Sys.unsetenv("MFRMR_G4_CONTRACT_GENERATION") else
      Sys.setenv(MFRMR_G4_CONTRACT_GENERATION = old)
  }, add = TRUE)
  Sys.setenv(MFRMR_G4_CONTRACT_GENERATION = "v6")
  preflight <- g4v6_source(file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-candidate-binding-preflight-0.2.4.R"
  ))
  registries <- preflight$mfrmr_fc_g4b_repository_registries(root)
  expect_identical(registries$Production$Path, boundary$Path)
  expect_true(all(nchar(registries$Production$SHA256) == 64L))
  expect_true(registries$WorkerDenominatorCoverage$Exact)
  expect_true("compiled_header_regression" %in% registries$Support$Role)
  header <- registries$Support[
    registries$Support$Role == "compiled_header_regression", , drop = FALSE
  ]
  expect_identical(
    header$Path, "tests/testthat/test-compiled-header-contract.R"
  )
  expect_identical(nchar(header$SHA256), 64L)
})

test_that("v6 worker covers the exact 49-cell denominator", {
  root <- g4v6_root()
  contract <- g4v6_source(file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R"
  ))
  worker <- g4v6_source(file.path(
    root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-worker-0.2.4.R"
  ))
  ids <- worker$mfrmr_fc_g4v6w_cell_ids(root)
  handlers <- worker$mfrmr_fc_g4v6w_handlers(contract, root)
  expect_identical(ids, contract$mfrmr_fc_g4v6_denominator()$CellId)
  expect_identical(names(handlers), ids)
  expect_identical(length(handlers), 49L)
})

test_that("v6 workflow is explicitly activated and separated from routine checks", {
  root <- g4v6_root()
  workflow_path <- file.path(
    root, ".github", "workflows", "fixed-calibration-g4-v6.yaml"
  )
  cell_path <- file.path(
    root, ".github", "workflows", "fixed-calibration-g4-v6-cell.yaml"
  )
  routine_path <- file.path(
    root, ".github", "workflows", "R-CMD-check-cell.yaml"
  )
  workflow <- paste(readLines(workflow_path, warn = FALSE), collapse = "\n")
  cell <- paste(readLines(cell_path, warn = FALSE), collapse = "\n")
  routine <- paste(readLines(routine_path, warn = FALSE), collapse = "\n")
  release_runner <- paste(readLines(file.path(
    root, "inst", "validation", "release-check-runner-0.2.4.R"
  ), warn = FALSE), collapse = "\n")
  expect_match(workflow, "  workflow_dispatch:", fixed = TRUE)
  expect_match(workflow, "  push:\n    tags:", fixed = TRUE)
  expect_match(workflow, "'g4-v6-candidate-*'", fixed = TRUE)
  expect_false(grepl("    branches:", workflow, fixed = TRUE))
  expect_false(grepl("  pull_request:", workflow, fixed = TRUE))
  expect_match(
    workflow, "uses: ./.github/workflows/fixed-calibration-g4-v6-cell.yaml",
    fixed = TRUE
  )
  expect_match(workflow, "g4-v6-hosted-matrix:", fixed = TRUE)
  expect_match(cell, "MFRMR_G4_CONTRACT_GENERATION: v6", fixed = TRUE)
  expect_match(cell, "Upload bound G4 v6 cell receipt", fixed = TRUE)
  expect_match(cell, "g4-v6-evidence-${{ inputs.cell-id }}", fixed = TRUE)
  expect_false(grepl("post-maintenance-v6-worker", routine, fixed = TRUE))
  expect_false(grepl("g4-v6-evidence", routine, fixed = TRUE))
  expect_match(routine, "release-check-runner-0.2.4.R", fixed = TRUE)
  expect_match(release_runner, "G4EvidenceIssued = FALSE", fixed = TRUE)
})
