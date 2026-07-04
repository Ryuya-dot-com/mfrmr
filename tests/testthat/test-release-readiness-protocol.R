release_readiness_protocol_path <- function() {
  source_path <- testthat::test_path("..", "..", "inst", "validation", "release-readiness.R")
  if (file.exists(source_path)) {
    source_path
  } else {
    system.file("validation", "release-readiness.R", package = "mfrmr")
  }
}

release_readiness_source_root <- function() {
  test_root <- normalizePath(testthat::test_path(), winslash = "/", mustWork = TRUE)
  candidates <- unique(suppressWarnings(normalizePath(c(
    file.path(test_root, "..", ".."),
    file.path(test_root, "..", "..", "00_pkg_src", "mfrmr"),
    file.path(test_root, "..", "..", "..", "00_pkg_src", "mfrmr"),
    getwd(),
    file.path(getwd(), ".."),
    file.path(getwd(), "..", "00_pkg_src", "mfrmr"),
    file.path(getwd(), "..", "..", "00_pkg_src", "mfrmr")
  ), winslash = "/", mustWork = FALSE)))

  hits <- candidates[
    file.exists(file.path(candidates, "DESCRIPTION")) &
      file.exists(file.path(candidates, "R", "help_gpcm_scope.R")) &
      file.exists(file.path(candidates, "inst", "validation", "release-readiness.R"))
  ]
  if (length(hits) > 0L) {
    return(hits[1])
  }
  system.file(package = "mfrmr")
}

test_that("release-readiness protocol exposes review steps and parses check logs", {
  protocol <- release_readiness_protocol_path()
  expect_true(nzchar(protocol))

  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  steps <- env$mfrmr_release_readiness_prompt_steps()
  expect_s3_class(steps, "data.frame")
  expect_equal(nrow(steps), 8L)
  expect_true(all(c("Step", "Label", "Prompt", "Evidence", "Gate") %in% names(steps)))
  expect_true(all(c("blocker", "caveat") %in% steps$Gate))

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking package namespace information ... OK",
    "* checking tests ... OK",
    "Status: 1 NOTE"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(log_file, target_version = "0.2.1")
  expect_identical(parsed$PackageVersion, "0.2.1")
  expect_true(parsed$VersionMatchesTarget)
  expect_true(parsed$CheckPassed)
  expect_true(parsed$NeedsExplanation)
  expect_equal(parsed$Errors, 0L)
  expect_equal(parsed$Warnings, 0L)
  expect_equal(parsed$Notes, 1L)
})

test_that("release-readiness protocol rejects stale check logs by version", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.0’",
    "* checking tests ... OK",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(log_file, target_version = "0.2.1")
  expect_true(parsed$CheckPassed)
  expect_false(parsed$VersionMatchesTarget)

  version_status <- data.frame(
    TargetVersion = "0.2.1",
    DescriptionVersion = "0.2.1",
    NewsHeading = "# mfrmr 0.2.1",
    DevelopmentLabelPresent = FALSE,
    VersionOK = TRUE
  )
  term_status <- data.frame(
    FilesScanned = 1L,
    DisallowedRemovedTerms = 0L,
    TerminologyOK = TRUE,
    Examples = ""
  )
  checklist_status <- data.frame(
    Checklist = tempfile(),
    Rows = 1L,
    BlockerRows = 1L,
    CaveatRows = 0L,
    RoadmapRows = 0L,
    ChecklistAvailable = TRUE
  )
  ci_status <- data.frame(
    WorkflowAvailable = TRUE,
    PackageCheckStepPresent = TRUE,
    WarningsAreFailures = TRUE,
    CheckArtifactsUploaded = TRUE,
    ReadinessGatePresent = TRUE,
    CIWorkflowOK = TRUE
  )
  paths <- list(
    evidence_map = log_file,
    gpcm_roadmap = log_file,
    external_recovery_evidence = log_file,
    external_recovery_helper = log_file
  )
  gate <- env$mfrmr_release_readiness_gate_summary(
    version_status = version_status,
    check_status = parsed,
    term_status = term_status,
    checklist_status = checklist_status,
    ci_workflow_status = ci_status,
    paths = paths
  )
  expect_identical(gate$Status[gate$Gate == "package_check"], "review")
})

test_that("release-readiness protocol uses release evidence for development versions", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  validation_dir <- tempfile("validation")
  dir.create(validation_dir)
  target_file <- file.path(validation_dir, "release-evidence-checklist-0.2.2.csv")
  fallback_file <- file.path(validation_dir, "release-evidence-checklist-0.2.0.csv")
  writeLines("target", target_file)
  writeLines("fallback", fallback_file)

  resolved <- env$mfrmr_release_readiness_versioned_file(
    validation_dir = validation_dir,
    prefix = "release-evidence-checklist-",
    target_version = "0.2.2.9000",
    ext = ".csv"
  )
  expect_identical(normalizePath(resolved, winslash = "/", mustWork = TRUE),
                   normalizePath(target_file, winslash = "/", mustWork = TRUE))
})

test_that("release-readiness version status separates release and development headings", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(root)
  writeLines("Package: mfrmr\nVersion: 0.2.2", file.path(root, "DESCRIPTION"))
  writeLines("# mfrmr 0.2.2", file.path(root, "NEWS.md"))
  writeLines(character(), file.path(root, "cran-comments.md"))
  writeLines("# map", file.path(root, "evidence.md"))

  release_status <- env$mfrmr_release_readiness_version_status(
    paths = list(
      description = file.path(root, "DESCRIPTION"),
      news = file.path(root, "NEWS.md"),
      cran_comments = file.path(root, "cran-comments.md"),
      evidence_map = file.path(root, "evidence.md"),
      target_version = "0.2.2"
    )
  )
  expect_true(release_status$VersionOK)
  expect_false(release_status$DevCycle)

  writeLines("Package: mfrmr\nVersion: 0.2.2.9000", file.path(root, "DESCRIPTION"))
  writeLines("# mfrmr (development version)", file.path(root, "NEWS.md"))
  dev_status <- env$mfrmr_release_readiness_version_status(
    paths = list(
      description = file.path(root, "DESCRIPTION"),
      news = file.path(root, "NEWS.md"),
      cran_comments = file.path(root, "cran-comments.md"),
      evidence_map = file.path(root, "evidence.md"),
      target_version = "0.2.2.9000"
    )
  )
  expect_true(dev_status$VersionOK)
  expect_true(dev_status$DevCycle)
})

test_that("release-readiness protocol finds common check-log locations", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, "check", "mfrmr.Rcheck"), recursive = TRUE)
  log_file <- file.path(root, "check", "mfrmr.Rcheck", "00check.log")
  writeLines("Status: OK", log_file)

  found <- env$mfrmr_release_readiness_find_check_log(root)
  expect_identical(normalizePath(found, winslash = "/", mustWork = TRUE),
                   normalizePath(log_file, winslash = "/", mustWork = TRUE))

  stale_root_log <- file.path(root, "mfrmr.Rcheck", "00check.log")
  dir.create(dirname(stale_root_log), recursive = TRUE)
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.0’",
    "Status: OK"
  ), stale_root_log)
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "Status: OK"
  ), log_file)
  found_current <- env$mfrmr_release_readiness_find_check_log(
    root,
    target_version = "0.2.1"
  )
  expect_identical(normalizePath(found_current, winslash = "/", mustWork = TRUE),
                   normalizePath(log_file, winslash = "/", mustWork = TRUE))
})

test_that("release-readiness protocol checks CI workflow contract", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, ".github", "workflows"), recursive = TRUE)
  workflow <- file.path(root, ".github", "workflows", "R-CMD-check.yaml")
  writeLines(c(
    "name: R-CMD-check",
    "matrix:",
    "  config:",
    "    - {os: macos-latest, r: 'release'}",
    "    - {os: windows-latest, r: 'release'}",
    "    - {os: ubuntu-latest, r: 'devel'}",
    "    - {os: ubuntu-latest, r: 'oldrel-1'}",
    "- uses: r-lib/actions/check-r-package@v2",
    "  with:",
    "    error-on: '\"warning\"'",
    "- name: Upload check results",
    "  uses: actions/upload-artifact@v4",
    "  with:",
    "    path: check",
    "- name: Release-readiness gate",
    "  run: mfrmr_release_readiness_review(pkg_dir = \".\")"
  ), workflow)

  status <- env$mfrmr_release_readiness_ci_workflow_status(workflow)
  expect_true(status$WorkflowAvailable)
  expect_true(status$MatrixIncludesMainOS)
  expect_true(status$MatrixIncludesRDevelOldrelRelease)
  expect_true(status$PackageCheckStepPresent)
  expect_true(status$WarningsAreFailures)
  expect_true(status$CheckArtifactsUploaded)
  expect_true(status$ReadinessGatePresent)
  expect_true(status$CIWorkflowOK)
})

test_that("release-readiness protocol checks GPCM scope alignment", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  paths <- env$mfrmr_release_readiness_paths(pkg_root, target_version = "0.2.1")
  checklist_status <- env$mfrmr_release_readiness_checklist_status(paths$evidence_checklist)
  status <- env$mfrmr_release_readiness_gpcm_scope_status(
    paths = paths,
    checklist_status = checklist_status
  )

  expect_s3_class(status, "data.frame")
  expect_equal(status$GPCMScopeStatus[1], "ok")
  expect_gt(status$OutstandingRows[1], 0L)
  expect_true(status$GuidanceComplete[1])
  expect_true(status$RoadmapCoversOutstanding[1])
  expect_true(status$RuntimeGuardCoverageOK[1])
  expect_true(status$RuntimeGuardStatusOK[1])
  expect_gt(status$RuntimeGuardRows[1], 0L)
  expect_true(status$RuntimeGuardAreas[1] >= status$OutstandingRows[1])
  expect_identical(status$MissingRuntimeGuardAreas[1], "")
  expect_true(status$ChecklistRoadmapRows[1] >= status$OutstandingRows[1])
})

test_that("release-readiness protocol reviews the source tree shape", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- release_readiness_source_root()
  expect_true(nzchar(pkg_root))
  review <- env$mfrmr_release_readiness_review(pkg_dir = pkg_root)
  expect_s3_class(review, "mfrmr_release_readiness_review")
  expect_true(all(c(
    "prompt_steps", "gate_summary", "release_decision",
    "version_status", "check_status", "ci_workflow_status", "terminology_status",
    "checklist_status", "gpcm_scope_status", "mh_dif_comparison_status",
    "dif_apa_reporting_status", "dif_dff_simulation_status",
    "gpcm_score_side_status",
    "gpcm_score_side_external_status",
    "release_scope_status",
    "external_recovery_status"
  ) %in% names(review)))
  expect_false(review$external_recovery_status$ExternalRecoveryRequested[1])
  expect_true(isTRUE(review$version_status$VersionOK[1]))
  expect_true(file.exists(review$paths$gpcm_roadmap))
  expect_equal(review$gpcm_scope_status$GPCMScopeStatus[1], "ok")
  expect_true(file.exists(review$paths$mh_dif_alignment_note))
  expect_true(file.exists(review$paths$mh_dif_comparison_helper))
  expect_true(file.exists(review$paths$mh_dif_simulation_helper))
  expect_true(file.exists(review$paths$dif_apa_reporting_note))
  expect_true(file.exists(review$paths$dif_apa_reporting_helper))
  expect_true(file.exists(review$paths$dif_apa_reporting_evidence))
  expect_true(file.exists(review$paths$dif_dff_simulation_helper))
  expect_true(file.exists(review$paths$dif_dff_simulation_evidence))
  expect_true(file.exists(review$paths$gpcm_score_side_simulation_helper))
  expect_true(file.exists(review$paths$gpcm_score_side_simulation_evidence))
  expect_true(file.exists(review$paths$gpcm_score_side_simulation_summary))
  expect_true(file.exists(review$paths$gpcm_score_side_simulation_checks))
  expect_true(file.exists(review$paths$gpcm_score_side_external_helper))
  expect_true(file.exists(review$paths$gpcm_score_side_external_evidence))
  expect_true(file.exists(review$paths$gpcm_score_side_external_results))
  expect_true(file.exists(review$paths$gpcm_score_side_external_checks))
  expect_true(file.exists(review$paths$release_scope_helper))
  expect_true(file.exists(review$paths$release_scope_evidence))
  expect_true(file.exists(review$paths$release_scope_checks))
  expect_true(review$mh_dif_comparison_status$MHDIFComparisonStatus[1] %in%
                c("ok", "skipped"))
  expect_true(isTRUE(review$mh_dif_comparison_status$ComparisonGateOK[1]))
  expect_equal(review$dif_apa_reporting_status$DIFAPAReportingStatus[1], "ok")
  expect_true(isTRUE(review$dif_apa_reporting_status$ReportingGateOK[1]))
  expect_equal(review$dif_apa_reporting_status$FailedChecks[1], 0L)
  expect_equal(review$dif_dff_simulation_status$DIFDFFSimulationStatus[1], "ok")
  expect_true(isTRUE(review$dif_dff_simulation_status$SimulationGateOK[1]))
  expect_equal(review$dif_dff_simulation_status$FailedChecks[1], 0L)
  expect_equal(review$gpcm_score_side_status$GPCMScoreSideSimulationStatus[1], "ok")
  expect_true(isTRUE(review$gpcm_score_side_status$SimulationGateOK[1]))
  expect_equal(review$gpcm_score_side_status$FailedChecks[1], 0L)
  expect_equal(review$gpcm_score_side_status$ErroredReplications[1], 0L)
  expect_equal(review$gpcm_score_side_external_status$GPCMScoreSideExternalComparisonStatus[1], "ok")
  expect_true(isTRUE(review$gpcm_score_side_external_status$ExternalComparisonGateOK[1]))
  expect_equal(review$gpcm_score_side_external_status$FailedChecks[1], 0L)
  expect_true(isTRUE(review$gpcm_score_side_external_status$ResultsRowsMatch[1]))
  expect_true(isTRUE(review$gpcm_score_side_external_status$ExpectedGridOK[1]))
  expect_true(review$gpcm_score_side_external_status$HasMirt[1])
  expect_true(review$gpcm_score_side_external_status$HasTAM[1])
  expect_true(review$gpcm_score_side_external_status$ERmBoundaryOK[1])
  expect_equal(review$release_scope_status$ReleaseScopeReviewStatus[1], "ok")
  expect_true(isTRUE(review$release_scope_status$ScopeGateOK[1]))
  expect_equal(review$release_scope_status$FailedChecks[1], 0L)
  expect_gte(review$release_scope_status$Checks[1], 67L)
  release_scope_checks <- utils::read.csv(
    review$paths$release_scope_checks,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  release_scope_contract_checks <- c(
    "readme_scope_map_has_all_release_areas",
    "news_scope_map_has_all_release_areas",
    "cran_comments_scope_map_has_core_release_areas",
    "core_engine_boundary_blocks_deferred_model_claims",
    "public_docs_gtheory_is_independent_observed_score_route",
    "minimum_report_checklist_has_generalizability_scope",
    "generalizability_not_only_in_limitations_row",
    "psychometric_guide_routes_to_gstudy_dstudy",
    "source_and_help_expose_visual_migration_columns",
    "facets_visual_contract_has_migration_schema",
    "facets_visual_contract_covers_core_facets_surfaces",
    "facets_visual_contract_routes_editable_plot_data"
  )
  expect_true(all(release_scope_contract_checks %in% release_scope_checks$Check))
  matched_scope_checks <- release_scope_checks[
    release_scope_checks$Check %in% release_scope_contract_checks,
    ,
    drop = FALSE
  ]
  expect_true(all(as.logical(matched_scope_checks$Passed)))
  if (file.exists(file.path(pkg_root, ".github", "workflows", "R-CMD-check.yaml"))) {
    expect_true(isTRUE(review$ci_workflow_status$CIWorkflowOK[1]))
  }
  expect_true(isTRUE(review$terminology_status$TerminologyOK[1]))
  expect_true(isTRUE(review$checklist_status$ChecklistAvailable[1]))
})
