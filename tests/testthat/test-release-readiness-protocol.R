release_readiness_protocol_path <- function() {
  source_path <- testthat::test_path("..", "..", "inst", "validation", "release-readiness.R")
  if (file.exists(source_path)) {
    source_path
  } else {
    system.file("validation", "release-readiness.R", package = "mfrmr")
  }
}

release_readiness_gate_fixture <- function(env, check_status,
                                           freshness_status = NULL,
                                           example_policy_status = NULL,
                                           check_timing_scope = "cran") {
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
  if (is.null(example_policy_status)) {
    example_policy_status <- data.frame(
      DontrunSourceTargets = paste(
        c("normalize_conquest_overlap_exports", "review_conquest_overlap"),
        collapse = ", "
      ),
      ExamplesIfSourceTargets = "launch_mfrmr_viewer",
      DonttestRdPages = 147L,
      Detail = "",
      ExamplePolicyOK = TRUE,
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
    freshness_status = freshness_status,
    example_policy_status = example_policy_status,
    check_timing_scope = check_timing_scope
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
    "* using options ‘--run-donttest --as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking package namespace information ... OK",
    "* checking examples ... [3s/4s] OK",
    "* checking examples with --run-donttest ... [5s/6s] OK",
    "* checking tests ... [1s/1s] OK",
    "* checking re-building of vignette outputs ... [1s/1s] OK",
    "* checking PDF version of manual ... OK",
    "* checking HTML version of manual ... OK",
    "Status: 1 NOTE"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(log_file, target_version = "0.2.1")
  expect_identical(parsed$PackageVersion, "0.2.1")
  expect_true(parsed$VersionMatchesTarget)
  expect_true(parsed$StatusPresent)
  expect_true(parsed$AsCRAN)
  expect_true(parsed$RunDonttest)
  expect_true(parsed$ManualChecked)
  expect_true(parsed$CheckPassed)
  expect_true(parsed$NeedsExplanation)
  expect_equal(parsed$Errors, 0L)
  expect_equal(parsed$Warnings, 0L)
  expect_equal(parsed$Notes, 1L)
  expect_true(parsed$TimingAvailable)
  expect_equal(parsed$ComponentElapsedSeconds, 12)
  expect_equal(parsed$CranWorkloadElapsedSeconds, 12)
  expect_equal(parsed$ExamplesSeconds, 4)
  expect_equal(parsed$DonttestExamplesSeconds, 6)
  expect_equal(parsed$TestsSeconds, 1)
  expect_equal(parsed$VignetteRebuildSeconds, 1)
  expect_true(parsed$UnderTenMinutes)
})

test_that("release-readiness timing excludes check infrastructure overhead", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using options ‘--run-donttest --as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking package dependencies ... [1s/700s] OK",
    "* checking examples ... [90s/100s] OK",
    "* checking examples with --run-donttest ... [290s/300s] OK",
    "* checking tests ... [9s/10s] OK",
    "* checking re-building of vignette outputs ... [9s/10s] OK",
    "* checking PDF version of manual ... OK",
    "* checking HTML version of manual ... OK",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )

  expect_equal(parsed$ComponentElapsedSeconds, 1120)
  expect_equal(parsed$CranWorkloadElapsedSeconds, 420)
  expect_true(parsed$UnderTenMinutes)
  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(
    gate$Status[gate$Gate == "check_timing"],
    "ok"
  )
})

test_that("release-readiness protocol flags check timing above ten minutes", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using options ‘--run-donttest --as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "* checking examples ... [1s/601s] OK",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )

  expect_true(parsed$TimingAvailable)
  expect_equal(parsed$ComponentElapsedSeconds, 601)
  expect_equal(parsed$CranWorkloadElapsedSeconds, 601)
  expect_false(parsed$UnderTenMinutes)
  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(
    gate$Status[gate$Gate == "check_timing"],
    "concern"
  )
  full_gate <- release_readiness_gate_fixture(
    env,
    parsed,
    check_timing_scope = "full_non_cran"
  )
  expect_identical(
    full_gate$Status[full_gate$Gate == "check_timing"],
    "ok"
  )
  expect_identical(
    env$mfrmr_release_readiness_check_timing_scope("true"),
    "full_non_cran"
  )
  expect_identical(
    env$mfrmr_release_readiness_check_timing_scope("false"),
    "cran"
  )
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
  expect_false(parsed$AsCRAN)
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

test_that("release-readiness protocol requires --as-cran provenance", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* this is package ‘mfrmr’ version ‘0.2.1’",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.1"
  )
  expect_true(parsed$CheckPassed)
  expect_false(parsed$AsCRAN)

  gate <- release_readiness_gate_fixture(env, parsed)
  expect_identical(gate$Status[gate$Gate == "package_check"], "concern")
})

test_that("release-readiness binds a 0.2.3 candidate to frozen hashed inputs", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)
  skip_if_not_installed("digest")

  root <- tempfile("candidate-identity")
  dir.create(root, recursive = TRUE)
  tarball <- file.path(root, "mfrmr_0.2.3.tar.gz")
  check_log <- file.path(root, "00check.log")
  specification <- file.path(root, "release-gate-spec-0.2.3.md")
  checklist <- file.path(root, "release-evidence-checklist-0.2.3.csv")
  manifest <- file.path(root, "release-candidate-manifest-0.2.3.csv")
  writeLines("candidate tarball fixture", tarball)
  writeLines(c(
    "* using options '--run-donttest --as-cran'",
    "* this is package 'mfrmr' version '0.2.3'",
    "Status: OK"
  ), check_log)
  writeLines(c(
    "# gate specification fixture",
    "",
    "| Field | Value |",
    "| --- | --- |",
    "| Specification ID | `0.2.3-frozen.1` |",
    "| Confirmation authorized | Yes |"
  ), specification)
  utils::write.csv(data.frame(
    ReleaseDecision = "blocker_if_failed",
    CriterionState = "frozen_structural",
    AcceptanceRule = "Exact identity fields and hashes agree",
    stringsAsFactors = FALSE
  ), checklist, row.names = FALSE)

  manifest_values <- c(
    CandidateId = "mfrmr-0.2.3-fixture",
    PackageVersion = "0.2.3",
    SourceCommit = strrep("a", 40L),
    SourceTreeHash = strrep("b", 40L),
    TarballSHA256 = env$mfrmr_release_readiness_file_sha256(tarball),
    CheckLogSHA256 = env$mfrmr_release_readiness_file_sha256(check_log),
    SpecificationId = "0.2.3-frozen.1",
    SpecificationSHA256 = env$mfrmr_release_readiness_file_sha256(specification),
    ChecklistSHA256 = env$mfrmr_release_readiness_file_sha256(checklist),
    RVersion = R.version.string,
    Platform = R.version$platform,
    DependencyIdentity = "fixture-lock-sha256",
    Compiler = "fixture-compiler",
    EnvironmentFlags = "NOT_CRAN=false",
    DataRegistryIdentity = "fixture-data-registry",
    ModelRegistryIdentity = "fixture-model-registry",
    IntegrationRegistryIdentity = "fixture-integration-registry",
    ExternalRegistryIdentity = "not_applicable",
    SeedRegistryIdentity = "fixture-seed-registry"
  )
  utils::write.csv(data.frame(
    Field = names(manifest_values),
    Value = unname(manifest_values),
    stringsAsFactors = FALSE
  ), manifest, row.names = FALSE)
  paths <- list(
    target_version = "0.2.3",
    candidate_manifest = manifest,
    tarball = tarball,
    check_log = check_log,
    gate_specification = specification,
    evidence_checklist = checklist
  )

  status <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(status$CandidateIdentityStatus, "ok")
  expect_true(status$CandidateIdentityOK)
  expect_true(status$ManifestSchemaOK)
  expect_true(status$PackageVersionMatches)
  expect_true(status$TarballHashMatches)
  expect_true(status$CheckLogHashMatches)
  expect_true(status$SpecificationIdMatches)
  expect_true(status$SpecificationHashMatches)
  expect_true(status$ChecklistHashMatches)
  expect_true(status$SpecificationFrozen)
  expect_true(status$ConfirmationAuthorized)
  expect_true(status$BlockerCriteriaFrozen)

  writeLines(c(
    "# gate specification fixture",
    "",
    "| Field | Value |",
    "| --- | --- |",
    "| Specification ID | `0.2.3-draft.14` |",
    "| Confirmation authorized | No |"
  ), specification)
  manifest_values[["SpecificationId"]] <- "0.2.3-draft.14"
  manifest_values[["SpecificationSHA256"]] <-
    env$mfrmr_release_readiness_file_sha256(specification)
  utils::write.csv(data.frame(
    Field = names(manifest_values),
    Value = unname(manifest_values),
    stringsAsFactors = FALSE
  ), manifest, row.names = FALSE)
  draft <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(draft$CandidateIdentityStatus, "concern")
  expect_true(draft$SpecificationIdMatches)
  expect_true(draft$SpecificationHashMatches)
  expect_false(draft$SpecificationFrozen)
  expect_false(draft$ConfirmationAuthorized)

  writeLines("mutated candidate tarball fixture", tarball)
  mutated <- env$mfrmr_release_readiness_candidate_identity_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(mutated$CandidateIdentityStatus, "concern")
  expect_false(mutated$CandidateIdentityOK)
  expect_false(mutated$TarballHashMatches)
  expect_match(mutated$Detail, "tarball SHA-256 mismatch", fixed = TRUE)
})

test_that("release-readiness reconstructs checklist decisions from hashed result rows", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)
  skip_if_not_installed("digest")

  root <- tempfile("gate-results")
  dir.create(root, recursive = TRUE)
  evidence <- file.path(root, "evidence.txt")
  checklist <- file.path(root, "release-evidence-checklist-0.2.3.csv")
  manifest <- file.path(root, "release-candidate-manifest-0.2.3.csv")
  results_path <- file.path(root, "release-gate-results-0.2.3.csv")
  writeLines("candidate-linked aggregate evidence", evidence)
  utils::write.csv(data.frame(
    Gate = c("G1", "G6", "G4"),
    Item = c("structural_contract", "future_guard", "replication_scope"),
    ScenarioId = c(
      "NUM-BIN-REDUCE; NUM-RSM-CORE",
      "ALL",
      "DIM-EMP-CONFIRM"
    ),
    ReleaseDecision = c(
      "blocker_if_failed",
      "roadmap_if_missing",
      "caveat_if_incomplete"
    ),
    stringsAsFactors = FALSE
  ), checklist, row.names = FALSE)
  commit <- strrep("a", 40L)
  spec_id <- "0.2.3-frozen.1"
  utils::write.csv(data.frame(
    Field = c("SourceCommit", "SpecificationId"),
    Value = c(commit, spec_id),
    stringsAsFactors = FALSE
  ), manifest, row.names = FALSE)
  evidence_hash <- env$mfrmr_release_readiness_file_sha256(evidence)
  results <- data.frame(
    Gate = c("G1", "G1", "G6", "G4"),
    Item = c(
      "structural_contract", "structural_contract", "future_guard",
      "replication_scope"
    ),
    ScenarioId = c(
      "NUM-BIN-REDUCE", "NUM-RSM-CORE", "ALL", "DIM-EMP-CONFIRM"
    ),
    CandidateCommit = commit,
    SpecId = spec_id,
    EvidenceRole = "unit",
    Metric = "exact structural rule",
    Estimate = NA_character_,
    Threshold = "all required assertions true",
    Direction = "exact",
    MonteCarloSE = NA_character_,
    NumericalSE = NA_character_,
    ReplicatesPlanned = NA_character_,
    ReplicatesRetained = NA_character_,
    FailedReplicates = NA_character_,
    Status = "ok",
    EvidencePath = "evidence.txt",
    EvidenceHash = evidence_hash,
    stringsAsFactors = FALSE
  )
  write_results <- function(value) {
    utils::write.csv(value, results_path, row.names = FALSE, na = "")
  }
  write_results(results)
  paths <- list(
    target_version = "0.2.3",
    pkg_dir = root,
    gate_results = results_path,
    evidence_checklist = checklist,
    candidate_manifest = manifest
  )
  identity <- data.frame(
    CandidateIdentityStatus = "ok",
    CandidateIdentityOK = TRUE,
    stringsAsFactors = FALSE
  )

  status <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(status$GateResultsStatus, "ok")
  expect_true(status$GateResultsOK)
  expect_true(status$IdentityRowsOK)
  expect_true(status$EvidenceRowsOK)
  expect_identical(status$MissingItems, "")
  expect_identical(status$MissingScenarios, "")
  expect_identical(status$BlockingItemsNotOK, "")

  write_results(results[results$ScenarioId != "NUM-RSM-CORE", , drop = FALSE])
  missing <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(missing$GateResultsStatus, "concern")
  expect_match(missing$MissingScenarios, "NUM-RSM-CORE", fixed = TRUE)

  wrong_identity <- results
  wrong_identity$CandidateCommit[1] <- strrep("b", 40L)
  write_results(wrong_identity)
  mismatched <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(mismatched$GateResultsStatus, "concern")
  expect_false(mismatched$IdentityRowsOK)

  wrong_hash <- results
  wrong_hash$EvidenceHash[1] <- strrep("0", 64L)
  write_results(wrong_hash)
  tampered <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(tampered$GateResultsStatus, "concern")
  expect_false(tampered$EvidenceRowsOK)

  caveated <- results
  caveated$Status[caveated$Item == "replication_scope"] <- "review"
  write_results(caveated)
  review <- env$mfrmr_release_readiness_gate_results_status(
    paths,
    candidate_identity_status = identity,
    target_version = "0.2.3"
  )
  expect_identical(review$GateResultsStatus, "review")
  expect_false(review$GateResultsOK)
  expect_match(review$CaveatItemsForReview, "G4::replication_scope", fixed = TRUE)
})

test_that("release-readiness keeps the 0.2.3 current/future API truth explicit", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  paths <- env$mfrmr_release_readiness_paths(
    pkg_root,
    target_version = "0.2.3"
  )
  status <- env$mfrmr_release_readiness_public_scope_status(
    paths,
    target_version = "0.2.3"
  )

  expect_identical(status$PublicScopeStatus, "ok")
  expect_true(status$PublicScopeOK)
  expect_equal(status$BoundaryRows, status$RequiredBoundaryRows)
  expect_true(status$FutureRoutesBlocked)
  expect_true(status$VisualClaimSeparated)
  expect_true(status$ReadmeBoundaryExplicit)
  expect_true(status$FutureArgumentsAbsent)
})

test_that("release-readiness rejects stale numeric pass counts in current prose", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("prose-counts")
  dir.create(root, recursive = TRUE)
  readme <- file.path(root, "README.md")
  news <- file.path(root, "NEWS.md")
  cran_comments <- file.path(root, "cran-comments.md")
  writeLines("Current package guide without fixed test counts.", readme)
  writeLines(c(
    "# mfrmr 0.2.3",
    "",
    "Current changes use candidate-linked release evidence.",
    "",
    "# mfrmr 0.2.2",
    "Historical release record: 300 checks passed."
  ), news)
  writeLines(c(
    "## R CMD check results",
    "The installed-package selection completed with 392 passes."
  ), cran_comments)
  paths <- list(
    target_version = "0.2.3",
    readme = readme,
    news = news,
    cran_comments = cran_comments
  )

  stale <- env$mfrmr_release_readiness_prose_count_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(stale$ProseCountStatus, "concern")
  expect_false(stale$ProseCountsOK)
  expect_equal(stale$PassCountClaims, 1L)
  expect_match(stale$Examples, "392 passes", fixed = TRUE)
  expect_false(grepl("300 checks", stale$Examples, fixed = TRUE))

  writeLines(c(
    "## R CMD check results",
    "The exact candidate logs and hashes are retained in release evidence."
  ), cran_comments)
  current <- env$mfrmr_release_readiness_prose_count_status(
    paths,
    target_version = "0.2.3"
  )
  expect_identical(current$ProseCountStatus, "ok")
  expect_true(current$ProseCountsOK)
  expect_equal(current$PassCountClaims, 0L)
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

test_that("release-readiness prefers candidate check logs over newer archives", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  candidate_dir <- file.path(root, "release-candidates", "checked")
  archive_dir <- file.path(root, "release-candidates", "win-builder")
  dir.create(candidate_dir, recursive = TRUE)
  dir.create(archive_dir, recursive = TRUE)

  candidate_log <- file.path(candidate_dir, "00check.log")
  archive_log <- file.path(archive_dir, "00check.log")
  writeLines(c(
    "* using options '--run-donttest --as-cran'",
    "* this is package 'mfrmr' version '0.2.2'",
    "Status: OK"
  ), candidate_log)
  writeLines(c(
    "* this is package 'mfrmr' version '0.2.2'",
    "Status: OK"
  ), archive_log)
  writeLines(
    "checked candidate",
    file.path(candidate_dir, "mfrmr_0.2.2.tar.gz")
  )

  base_time <- Sys.time() - 60
  Sys.setFileTime(candidate_log, base_time)
  Sys.setFileTime(archive_log, base_time + 30)

  found <- env$mfrmr_release_readiness_find_check_log(
    root,
    target_version = "0.2.2"
  )
  expect_identical(
    normalizePath(found, winslash = "/", mustWork = TRUE),
    normalizePath(candidate_log, winslash = "/", mustWork = TRUE)
  )
})

test_that("release-readiness prefers submission and checked tarballs over backups", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  checked_dir <- file.path(root, "release-candidates", "checked")
  backup_dir <- file.path(root, "release-candidates", "pre-replacement")
  dir.create(checked_dir, recursive = TRUE)
  dir.create(backup_dir, recursive = TRUE)

  checked_tarball <- file.path(checked_dir, "mfrmr_0.2.2.tar.gz")
  backup_tarball <- file.path(backup_dir, "mfrmr_0.2.2.tar.gz")
  writeLines("checked candidate", checked_tarball)
  writeLines("newer backup", backup_tarball)
  writeLines(c(
    "* this is package 'mfrmr' version '0.2.2'",
    "Status: OK"
  ), file.path(checked_dir, "00check.log"))

  base_time <- Sys.time() - 60
  Sys.setFileTime(checked_tarball, base_time)
  Sys.setFileTime(backup_tarball, base_time + 30)

  found_checked <- env$mfrmr_release_readiness_find_tarball(
    root,
    target_version = "0.2.2"
  )
  expect_identical(
    normalizePath(found_checked, winslash = "/", mustWork = TRUE),
    normalizePath(checked_tarball, winslash = "/", mustWork = TRUE)
  )

  root_tarball <- file.path(root, "mfrmr_0.2.2.tar.gz")
  writeLines("explicit submission tarball", root_tarball)
  Sys.setFileTime(root_tarball, base_time - 30)
  found_root <- env$mfrmr_release_readiness_find_tarball(
    root,
    target_version = "0.2.2"
  )
  expect_identical(
    normalizePath(found_root, winslash = "/", mustWork = TRUE),
    normalizePath(root_tarball, winslash = "/", mustWork = TRUE)
  )
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

test_that("release-readiness protocol checks source-truth alignment", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  root <- tempfile("pkg")
  dir.create(file.path(root, "inst", "validation"), recursive = TRUE)
  writeLines(c(
    "Package: mfrmr",
    "Version: 0.2.2",
    "Date: 2026-07-26"
  ), file.path(root, "DESCRIPTION"))
  writeLines(c(
    "cff-version: 1.2.0",
    "version: \"0.2.2\"",
    "date-released: \"2026-07-26\""
  ), file.path(root, "CITATION.cff"))
  writeLines("^ROADMAP\\.md$", file.path(root, ".Rbuildignore"))
  writeLines(c(
    "# Roadmap",
    "This file is the single source of truth."
  ), file.path(root, "ROADMAP.md"))
  writeLines(
    "Current contract: gpcm_capability_matrix().",
    file.path(root, "inst", "validation", "gpcm-post-0.2.2-roadmap.md")
  )
  paths <- env$mfrmr_release_readiness_paths(root, target_version = "0.2.2")
  status <- env$mfrmr_release_readiness_source_truth_status(paths)

  expect_true(status$VersionMatchesCFF)
  expect_true(status$DateMatchesCFF)
  expect_true(status$RoadmapAvailable)
  expect_true(status$RoadmapExcludedFromTarball)
  expect_true(status$RoadmapAuthoritative)
  expect_identical(status$DevelopmentOnlyCurrentClaims, "")
  expect_true(status$SourceTruthOK)

  writeLines(
    "The current API is mfrmr_model_family_scope().",
    paths$gpcm_roadmap
  )
  stale <- env$mfrmr_release_readiness_source_truth_status(paths)
  expect_false(stale$SourceTruthOK)
  expect_match(
    stale$DevelopmentOnlyCurrentClaims,
    "mfrmr_model_family_scope()",
    fixed = TRUE
  )
})

test_that("release-readiness protocol enforces semantic example guards", {
  protocol <- release_readiness_protocol_path()
  env <- new.env(parent = globalenv())
  source(protocol, local = env)

  pkg_root <- normalizePath(test_path("..", ".."), winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(pkg_root, "DESCRIPTION"))) {
    pkg_root <- system.file(package = "mfrmr")
  }
  status <- env$mfrmr_release_readiness_example_policy_status(pkg_root)

  expect_true(status$SourceAvailable)
  expect_true(status$GeneratedRdAvailable)
  expect_identical(
    status$DontrunSourceTargets,
    "normalize_conquest_overlap_exports, review_conquest_overlap"
  )
  expect_identical(status$ExamplesIfSourceTargets, "launch_mfrmr_viewer")
  expect_gt(status$DonttestRdPages, 0L)
  expect_identical(status$Detail, "")
  expect_true(status$ExamplePolicyOK)

  status$ExamplePolicyOK <- FALSE
  status$Detail <- "unexpected dontrun target"
  log_file <- tempfile(fileext = ".log")
  writeLines(c(
    "* using option ‘--as-cran’",
    "* this is package ‘mfrmr’ version ‘0.2.2’",
    "Status: OK"
  ), log_file)
  parsed <- env$mfrmr_release_readiness_parse_check_log(
    log_file,
    target_version = "0.2.2"
  )
  gate <- release_readiness_gate_fixture(
    env,
    parsed,
    example_policy_status = status
  )
  expect_identical(
    gate$Status[gate$Gate == "example_policy"],
    "concern"
  )
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
    "source_truth_status", "candidate_identity_status", "public_scope_status",
    "gate_results_status", "prose_count_status",
    "terminology_status", "example_policy_status",
    "check_timing_scope",
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
  expect_true(isTRUE(review$source_truth_status$SourceTruthOK[1]))
  contract_applies <- utils::compareVersion(
    description_version,
    "0.2.3"
  ) >= 0L
  if (contract_applies) {
    expect_identical(
      review$candidate_identity_status$CandidateIdentityStatus[1],
      "concern"
    )
    expect_identical(
      review$gate_results_status$GateResultsStatus[1],
      "concern"
    )
    expect_identical(
      review$public_scope_status$PublicScopeStatus[1],
      "ok"
    )
    expect_identical(
      review$prose_count_status$ProseCountStatus[1],
      "ok"
    )
  } else {
    expect_identical(
      review$candidate_identity_status$CandidateIdentityStatus[1],
      "not_applicable"
    )
    expect_identical(
      review$gate_results_status$GateResultsStatus[1],
      "not_applicable"
    )
    expect_identical(
      review$public_scope_status$PublicScopeStatus[1],
      "not_applicable"
    )
    expect_identical(
      review$prose_count_status$ProseCountStatus[1],
      "not_applicable"
    )
  }
  expect_equal(review$gpcm_scope_status$GPCMScopeStatus[1], "ok")
  if (file.exists(file.path(pkg_root, ".github", "workflows", "R-CMD-check.yaml"))) {
    expect_true(isTRUE(review$ci_workflow_status$CIWorkflowOK[1]))
  }
  expect_true(isTRUE(review$terminology_status$TerminologyOK[1]))
  expect_true(isTRUE(review$example_policy_status$ExamplePolicyOK[1]))
  expect_identical(
    review$gate_summary$Status[review$gate_summary$Gate == "example_policy"],
    "ok"
  )
  expect_true(isTRUE(review$checklist_status$ChecklistAvailable[1]))
})
