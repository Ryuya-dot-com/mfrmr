# 0.2.4 post-maintenance G4 admission boundary.
#
# This repository-only helper verifies the 0.2.3.1 maintenance bridge and
# freezes the additional compiled-source boundary required before a successor
# G4 confirmation contract can be opened. It performs no fit or scoring.

mfrmr_fc_g4m_git <- function(repo_root, arguments) {
  output <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", shQuote(repo_root), arguments),
      stdout = TRUE, stderr = TRUE
    )),
    error = function(condition) structure(
      conditionMessage(condition), status = 127L
    )
  )
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(Status = as.integer(status), Output = enc2utf8(as.character(output)))
}

mfrmr_fc_g4m_required_production_boundary <- function() {
  data.frame(
    Path = c(
      "R/core-fixed-calibration.R", "R/api-prediction.R",
      "R/api-reference-benchmark.R", "R/api-export-bundles.R",
      "R/core-optimizer.R", "DESCRIPTION", "src/mml_backend.cpp",
      "src/cpp11.cpp"
    ),
    Role = c(
      "calibration_schema_and_artifact_scoring",
      "fitted_object_scoring",
      "reference_benchmark_readiness",
      "replay_completeness",
      "checkpoint_identity_and_resume",
      "development_release_identity",
      "compiled_likelihood_backend",
      "compiled_registration_translation_unit"
    ),
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4m_required_support_boundary <- function() {
  data.frame(
    Path = c(
      "tests/testthat/test-compiled-header-contract.R",
      "inst/validation/public-release-baseline-0.2.4.csv",
      "inst/validation/fixed-calibration-g0-maintenance-addendum-0.2.4.md",
      "inst/validation/fixed-calibration-boundary-hardening-0.2.4.md",
      "inst/validation/release-check-runner-0.2.4.R",
      "inst/validation/fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R",
      "inst/validation/fixed-calibration-g4-post-maintenance-v6-worker-0.2.4.R",
      "tests/testthat/test-fixed-calibration-g4-v6-evidence.R",
      ".github/workflows/fixed-calibration-g4-v6.yaml",
      ".github/workflows/fixed-calibration-g4-v6-cell.yaml",
      ".github/workflows/R-CMD-check.yaml",
      ".github/workflows/R-CMD-check-cell.yaml"
    ),
    Role = c(
      "compiled_header_regression",
      "public_predecessor_identity",
      "maintenance_patch_bridge",
      "post_maintenance_gate_disposition",
      "package_check_without_g4_receipt",
      "post_maintenance_v6_contract",
      "post_maintenance_v6_worker",
      "post_maintenance_v6_repository_test",
      "manual_v6_matrix_orchestration",
      "manual_v6_platform_execution",
      "five_platform_check_orchestration",
      "platform_check_without_legacy_g4_issuance"
    ),
    Required = TRUE,
    stringsAsFactors = FALSE
  )
}

mfrmr_fc_g4m_baseline <- function(path) {
  if (!file.exists(path)) return(data.frame())
  tryCatch(
    utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE),
    error = function(...) data.frame()
  )
}

mfrmr_fc_g4m_baseline_value <- function(baseline, field) {
  if (!all(c("Field", "Value") %in% names(baseline))) return(NA_character_)
  hit <- which(as.character(baseline$Field) == field)
  if (length(hit) != 1L) return(NA_character_)
  as.character(baseline$Value[hit])
}

mfrmr_fc_g4m_review <- function(repo_root = ".") {
  repo_root <- normalizePath(repo_root, winslash = "/", mustWork = TRUE)
  production <- mfrmr_fc_g4m_required_production_boundary()
  support <- mfrmr_fc_g4m_required_support_boundary()
  required_paths <- c(production$Path, support$Path)
  required_present <- file.exists(file.path(repo_root, required_paths))

  description <- tryCatch(
    read.dcf(file.path(repo_root, "DESCRIPTION")),
    error = function(...) matrix(character(), nrow = 0L, ncol = 0L)
  )
  description_value <- function(field) {
    if (nrow(description) == 1L && field %in% colnames(description)) {
      as.character(description[1L, field])
    } else {
      NA_character_
    }
  }
  baseline <- mfrmr_fc_g4m_baseline(file.path(
    repo_root, "inst", "validation", "public-release-baseline-0.2.4.csv"
  ))
  expected <- c(
    PublicVersion = "0.2.3.1",
    CranSourceSHA256 =
      "d3d2b00638fcbd8407dfabd5206eb670b2a3470e0e30e0079ca64a2e7a77b67a",
    ReleaseCommit = "be5611ed9a9390ac6d33997f28e16be041aec56f",
    LTOPatchId = "8744a9894ab0a02186cab16ef3e337b067abbbeb",
    DocumentationPatchId = "b99133ae6ab40c1496e9b7550b2b98097cd194d8"
  )
  observed <- vapply(
    names(expected),
    function(field) mfrmr_fc_g4m_baseline_value(baseline, field),
    character(1L)
  )
  baseline_ok <- identical(unname(observed), unname(expected))

  integrated_commits <- c(
    "dc4a3375411ce3b2ccb8a28d3985436e66ba0b9d",
    "7fa91a110b1f6abac30a567b76d9275b7de9afd5"
  )
  integrated <- vapply(integrated_commits, function(commit) {
    identical(mfrmr_fc_g4m_git(
      repo_root, c("merge-base", "--is-ancestor", commit, "HEAD")
    )$Status, 0L)
  }, logical(1L))

  compiled <- list.files(
    file.path(repo_root, "src"),
    pattern = "[.](c|cc|cpp|cxx|h|hh|hpp)$",
    recursive = TRUE, full.names = TRUE
  )
  makevars <- list.files(
    file.path(repo_root, "src"), pattern = "^Makevars", full.names = TRUE
  )
  scanned <- c(compiled, makevars)
  header_override <- vapply(scanned, function(path) {
    any(grepl("HAVE_ENUM_BASE_TYPE", readLines(path, warn = FALSE),
              fixed = TRUE))
  }, logical(1L))

  public_paths <- c(
    "R/api-hierarchical-audit.R", "R/api-tables.R",
    "R/help_facets_coverage.R", "README.md",
    "man/analyze_hierarchical_structure.Rd",
    "man/facet_small_sample_review.Rd", "man/facets_feature_coverage.Rd",
    "man/fair_average_table.Rd"
  )
  invalid_targets <- c(
    "https://www.winsteps.com/facets.htm",
    "https://www.winsteps.com/facetman64/outputtableindex.htm",
    "https://www.winsteps.com/facetman64/models.htm",
    "https://www.winsteps.com/facetman64/t7menu.htm"
  )
  public_text <- unlist(lapply(file.path(repo_root, public_paths), function(path) {
    if (file.exists(path)) readLines(path, warn = FALSE) else character()
  }), use.names = FALSE)
  invalid_hits <- invalid_targets[vapply(
    invalid_targets,
    function(target) any(grepl(target, public_text, fixed = TRUE)),
    logical(1L)
  )]

  workflow_paths <- file.path(repo_root, c(
    ".github/workflows/R-CMD-check.yaml",
    ".github/workflows/R-CMD-check-cell.yaml"
  ))
  workflow_text <- unlist(lapply(workflow_paths, function(path) {
    if (file.exists(path)) readLines(path, warn = FALSE) else character()
  }), use.names = FALSE)
  check_runner_path <- file.path(
    repo_root, "inst", "validation", "release-check-runner-0.2.4.R"
  )
  check_runner_text <- if (file.exists(check_runner_path)) {
    readLines(check_runner_path, warn = FALSE)
  } else {
    character()
  }
  legacy_v5_tokens <- c(
    "fixed-calibration-g4-hosted-runner-0.2.4.R",
    "Upload bound G4 cell receipt", "g4-hosted-matrix",
    "hosted-cell-receipt.rds"
  )
  legacy_v5_automatic_issuance_disabled <-
    length(workflow_text) > 0L &&
    !any(vapply(legacy_v5_tokens, function(token) {
      any(grepl(token, workflow_text, fixed = TRUE))
    }, logical(1L))) &&
    any(grepl(
      "release-check-runner-0.2.4.R", workflow_text, fixed = TRUE
    )) &&
    any(grepl(
      "G4EvidenceIssued = FALSE", check_runner_text, fixed = TRUE
    ))

  v5_change <- mfrmr_fc_g4m_git(repo_root, c(
    "diff", "--quiet", "bcf86197619e3eae4c7cdd5288b797549df47c99",
    "--", "src/mml_backend.cpp", "tests/testthat.R",
    "tests/testthat/test-compiled-header-contract.R"
  ))
  metadata_ok <- identical(description_value("Version"), "0.2.4.9000") &&
    identical(tolower(description_value("Config/mfrmr/release-status")),
              "development") &&
    identical(description_value("Config/mfrmr/public-version"), "0.2.3.1")
  v6_path <- file.path(
    repo_root, "inst", "validation",
    "fixed-calibration-g4-post-maintenance-v6-contract-0.2.4.R"
  )
  v6_review <- if (file.exists(v6_path)) {
    tryCatch({
      environment <- new.env(parent = globalenv())
      sys.source(v6_path, envir = environment)
      environment$mfrmr_fc_g4v6_review()
    }, error = identity)
  } else {
    simpleError("The post-maintenance v6 contract is absent.")
  }
  v6_contract_frozen <- !inherits(v6_review, "error") &&
    identical(
      v6_review$status,
      "G4_v6_rules_frozen_candidate_unbound_confirmation_unopened"
    ) && isTRUE(v6_review$rules_frozen) &&
    isTRUE(v6_review$v6_identities_disjoint_and_frozen) &&
    isTRUE(v6_review$denominator_frozen) &&
    isTRUE(v6_review$compiled_boundary_frozen) &&
    !isTRUE(v6_review$v6_execution_opened) &&
    !isTRUE(v6_review$G4_exit_complete)
  bridge_complete <- all(required_present) && baseline_ok && all(integrated) &&
    length(scanned) > 0L && !any(header_override) &&
    length(invalid_hits) == 0L && metadata_ok && v5_change$Status == 1L &&
    legacy_v5_automatic_issuance_disabled && v6_contract_frozen

  list(
    Contract = "mfrmr_fixed_calibration_g4_maintenance_admission_v1",
    Status = if (bridge_complete) {
      "maintenance_bridge_complete_v6_contract_frozen_execution_required"
    } else {
      "maintenance_bridge_blocked"
    },
    ProductionBoundary = production,
    SupportBoundary = support,
    RequiredPathsPresent = all(required_present),
    MissingRequiredPaths = required_paths[!required_present],
    PublicBaselineMatched = baseline_ok,
    IntegratedCommits = integrated_commits,
    IntegratedCommitsAreAncestors = integrated,
    CompiledSourcesScanned = as.integer(length(scanned)),
    CompiledHeaderOverrideAbsent = length(scanned) > 0L &&
      !any(header_override),
    InvalidDocumentationTargets = invalid_hits,
    DevelopmentMetadataAligned = metadata_ok,
    V5ExactSourceChanged = identical(v5_change$Status, 1L),
    V5EvidenceRetainedAsHistorical = TRUE,
    LegacyV5AutomaticIssuanceDisabled =
      legacy_v5_automatic_issuance_disabled,
    V6SourceBoundaryFrozen = TRUE,
    V6ConfirmationContractFrozen = v6_contract_frozen,
    PostMaintenanceG4Complete = FALSE,
    G6Authorized = FALSE,
    MaintenanceBridgeComplete = bridge_complete
  )
}
