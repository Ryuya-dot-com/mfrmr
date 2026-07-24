release_readiness_protocol_path <- function() {
  source_path <- testthat::test_path("..", "..", "inst", "validation", "release-readiness.R")
  if (file.exists(source_path)) {
    source_path
  } else {
    system.file("validation", "release-readiness.R", package = "mfrmr")
  }
}

release_readiness_gate_fixture <- function(env, check_status,
                                           freshness_status = NULL) {
  evidence_file <- tempfile()
  writeLines("evidence", evidence_file)
  target <- as.character(check_status$TargetVersion[1])
  if (is.null(freshness_status)) {
    freshness_status <- data.frame(
      FreshnessOK = TRUE,
      LatestInput = "DESCRIPTION",
      CheckLogFresh = TRUE,
      TarballAvailable = TRUE,
      TarballFresh = TRUE,
      CheckAfterTarball = TRUE,
      StaleInputs = "",
      stringsAsFactors = FALSE
    )
  }
  env$mfrmr_release_readiness_gate_summary(
    version_status = data.frame(
      TargetVersion = target,
      DescriptionVersion = target,
      NewsHeading = paste("# mfrmr", target),
      DevelopmentLabelPresent = FALSE,
      VersionOK = TRUE
    ),
    check_status = check_status,
    term_status = data.frame(
      FilesScanned = 1L,
      DisallowedRemovedTerms = 0L,
      TerminologyOK = TRUE,
      Examples = ""
    ),
    checklist_status = data.frame(
      Checklist = evidence_file,
      Rows = 1L,
      BlockerRows = 1L,
      CaveatRows = 0L,
      RoadmapRows = 0L,
      ChecklistAvailable = TRUE
    ),
    ci_workflow_status = data.frame(
      WorkflowAvailable = TRUE,
      PackageCheckStepPresent = TRUE,
      WarningsAreFailures = TRUE,
      CheckArtifactsUploaded = TRUE,
      ReadinessGatePresent = TRUE,
      CIWorkflowOK = TRUE
    ),
    paths = list(
      evidence_map = evidence_file,
      gpcm_roadmap = evidence_file,
      external_recovery_evidence = evidence_file,
      external_recovery_helper = evidence_file
    ),
    freshness_status = freshness_status
  )
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
  expect_true(parsed$StatusPresent)
  expect_true(parsed$CheckPassed)
  expect_true(parsed$NeedsExplanation)
  expect_equal(parsed$Errors, 0L)
  expect_equal(parsed$Warnings, 0L)
  expect_equal(parsed$Notes, 1L)
})

test_that("release-readiness protocol rejects a check log without Status", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking tests ... OK",
    "* checking examples ... OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )

  expect_true(parsed$VersionMatchesTarget)
  expect_false(parsed$StatusPresent)
  expect_true(is.na(parsed$StatusLine))
  expect_false(parsed$CheckPassed)
  expect_true(parsed$NeedsExplanation)
  expect_true(all(is.na(parsed[c("Errors", "Warnings", "Notes")])))

  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(gate$Status[gate$Gate == "package_check"], "concern")
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

  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(gate$Status[gate$Gate == "package_check"], "concern")
})

test_that("release-readiness protocol rejects stale tarball and check evidence", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, "R"), recursive = TRUE)
  dir.create(file.path(root, "man"), recursive = TRUE)
  dir.create(file.path(root, "vignettes"), recursive = TRUE)
  dir.create(file.path(root, "inst", "validation"), recursive = TRUE)
  writeLines("Package: mfrmr", file.path(root, "DESCRIPTION"))
  writeLines("# mfrmr", file.path(root, "README.md"))
  writeLines("# mfrmr 0.2.1", file.path(root, "NEWS.md"))
  writeLines("^inst/validation$", file.path(root, ".Rbuildignore"))
  writeLines("fit <- function() NULL", file.path(root, "R", "fit.R"))
  writeLines("\\name{fit}", file.path(root, "man", "fit.Rd"))
  writeLines("---", file.path(root, "vignettes", "workflow.Rmd"))
  writeLines(
    "repository-only helper",
    file.path(root, "inst", "validation", "gate.R")
  )

  tarball <- file.path(root, "mfrmr_0.2.1.tar.gz")
  check_log <- file.path(root, "mfrmr.Rcheck", "00check.log")
  dir.create(dirname(check_log), recursive = TRUE)
  writeLines("source archive placeholder", tarball)
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "Status: OK"
  ), check_log)

  input_files <- c(
    file.path(root, "DESCRIPTION"),
    file.path(root, "README.md"),
    file.path(root, "NEWS.md"),
    file.path(root, ".Rbuildignore"),
    file.path(root, "R", "fit.R"),
    file.path(root, "man", "fit.Rd"),
    file.path(root, "vignettes", "workflow.Rmd"),
    file.path(root, "inst", "validation", "gate.R")
  )
  base_time <- Sys.time() - 120
  invisible(lapply(input_files, Sys.setFileTime, time = base_time))
  Sys.setFileTime(tarball, base_time + 30)
  Sys.setFileTime(check_log, base_time + 60)

  paths <- list(
    pkg_dir = normalizePath(root, winslash = "/", mustWork = TRUE),
    check_log = check_log,
    tarball = tarball
  )
  fresh <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_true(fresh$FreshnessOK)
  expect_true(fresh$TarballFresh)
  expect_true(fresh$CheckLogFresh)
  expect_true(fresh$CheckAfterTarball)

  Sys.setFileTime(
    file.path(root, "inst", "validation", "gate.R"),
    base_time + 90
  )
  ignored_change <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_true(ignored_change$FreshnessOK)

  Sys.setFileTime(check_log, base_time + 20)
  wrong_order <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_true(wrong_order$TarballFresh)
  expect_true(wrong_order$CheckLogFresh)
  expect_false(wrong_order$CheckAfterTarball)
  expect_false(wrong_order$FreshnessOK)
  Sys.setFileTime(check_log, base_time + 60)

  Sys.setFileTime(file.path(root, "R", "fit.R"), base_time + 90)
  stale <- env$mfrmr_release_readiness_evidence_freshness(
    paths,
    tolerance_seconds = 0
  )
  expect_false(stale$FreshnessOK)
  expect_false(stale$TarballFresh)
  expect_false(stale$CheckLogFresh)
  expect_match(stale$StaleInputs, "R/fit.R", fixed = TRUE)

  parsed <- env$mfrmr_release_readiness_parse_check_log(
    check_log,
    target_version = "0.2.1"
  )
  gate <- release_readiness_gate_fixture(
    env,
    parsed,
    freshness_status = stale
  )
  expect_identical(
    gate$Status[gate$Gate == "release_evidence_freshness"],
    "concern"
  )
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
    "- name: Repository validation review",
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
  paths <- env$mfrmr_release_readiness_paths(pkg_root, target_version = "0.2.2")
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

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  expect_true(nzchar(pkg_root))
  review <- env$mfrmr_release_readiness_review(pkg_dir = pkg_root)
  expect_s3_class(review, "mfrmr_release_readiness_review")
  expect_true(all(c(
    "prompt_steps", "gate_summary", "release_decision",
    "version_status", "check_status", "freshness_status", "ci_workflow_status",
    "terminology_status",
    "checklist_status", "gpcm_scope_status", "external_recovery_status"
  ) %in% names(review)))
  expect_false(review$external_recovery_status$ExternalRecoveryRequested[1])
  description_version <- as.character(review$version_status$DescriptionVersion[1])
  if (grepl("\\.9000$", description_version)) {
    expect_false(isTRUE(review$version_status$VersionOK[1]))
    expect_true(isTRUE(review$version_status$DevelopmentLabelPresent[1]))
    expect_match(review$version_status$NewsHeading[1], "development version", fixed = TRUE)
  } else {
    expect_true(isTRUE(review$version_status$VersionOK[1]))
  }
  expect_true(file.exists(review$paths$gpcm_roadmap))
  expect_equal(review$gpcm_scope_status$GPCMScopeStatus[1], "ok")
  if (file.exists(file.path(pkg_root, ".github", "workflows", "R-CMD-check.yaml"))) {
    expect_true(isTRUE(review$ci_workflow_status$CIWorkflowOK[1]))
  }
  expect_true(isTRUE(review$terminology_status$TerminologyOK[1]))
  expect_true(isTRUE(review$checklist_status$ChecklistAvailable[1]))
})
