# 0.2.4 fixed-calibration G4 hosted execution and aggregation runner.
#
# Repository-internal and fail-closed. In `cell` mode this script builds one
# source tarball from a clean checkout, binds that exact tarball, checks it,
# and runs the complete current-source worker against the package installed by
# that check. In `aggregate` mode it verifies the five retained cell receipts.

mfrmr_fc_g4h_contract <-
  "mfrmr_fixed_calibration_g4_hosted_execution_v1"

mfrmr_fc_g4h_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
  invisible(TRUE)
}

mfrmr_fc_g4h_file_hash <- function(path) {
  mfrmr_fc_g4h_assert(
    requireNamespace("digest", quietly = TRUE),
    "Hosted G4 execution requires `digest`."
  )
  mfrmr_fc_g4h_assert(
    file.exists(path) && !dir.exists(path),
    "A hosted G4 evidence file is absent."
  )
  digest::digest(file = path, algo = "sha256", serialize = FALSE)
}

mfrmr_fc_g4h_context <- function(package_root) {
  package_root <- normalizePath(
    package_root, winslash = "/", mustWork = TRUE
  )
  validation <- file.path(package_root, "inst", "validation")
  contract_path <- file.path(
    validation, "fixed-calibration-g4-current-source-contract-0.2.4.R"
  )
  preflight_path <- file.path(
    validation,
    "fixed-calibration-g4-candidate-binding-preflight-0.2.4.R"
  )
  worker_path <- file.path(
    validation, "fixed-calibration-g4-confirmation-worker-0.2.4.R"
  )
  mfrmr_fc_g4h_assert(
    all(file.exists(c(contract_path, preflight_path, worker_path))),
    "The hosted G4 contract, preflight, or worker is absent."
  )
  contract <- new.env(parent = globalenv())
  preflight <- new.env(parent = globalenv())
  sys.source(contract_path, envir = contract)
  sys.source(preflight_path, envir = preflight)
  list(
    PackageRoot = package_root, Validation = validation,
    Contract = contract, Preflight = preflight,
    WorkerPath = normalizePath(worker_path, winslash = "/", mustWork = TRUE)
  )
}

mfrmr_fc_g4h_cell_environment <- function(contract) {
  cell_id <- Sys.getenv("MFRMR_G4_CELL_ID", unset = "")
  selector <- Sys.getenv("MFRMR_G4_R_SELECTOR", unset = "")
  runner_os <- Sys.getenv("RUNNER_OS", unset = Sys.info()[["sysname"]])
  matrix <- contract$mfrmr_fc_g4_current_platform_matrix()
  index <- match(cell_id, matrix$CellId)
  mfrmr_fc_g4h_assert(
    !is.na(index), "MFRMR_G4_CELL_ID is not in the frozen platform matrix."
  )
  expected_selector <- matrix$R[index]
  mfrmr_fc_g4h_assert(
    identical(selector, expected_selector),
    "The hosted R selector differs from the frozen platform cell."
  )
  expected_os <- matrix$OS[index]
  normalized_runner <- switch(
    tolower(runner_os),
    macos = "macOS", windows = "Windows", linux = "Linux", runner_os
  )
  mfrmr_fc_g4h_assert(
    identical(normalized_runner, expected_os),
    "The hosted runner OS differs from the frozen platform cell."
  )
  list(
    CellId = cell_id, RSelector = selector, ExpectedOS = expected_os,
    RunnerOS = runner_os, MatrixRow = matrix[index, , drop = FALSE]
  )
}

mfrmr_fc_g4h_test_installed_evidence <- function(context, installed_library) {
  installed_library <- normalizePath(
    installed_library, winslash = "/", mustWork = TRUE
  )
  .libPaths(c(installed_library, .libPaths()))
  suppressPackageStartupMessages(library(mfrmr))
  loaded <- normalizePath(
    find.package("mfrmr"), winslash = "/", mustWork = TRUE
  )
  expected <- normalizePath(
    file.path(installed_library, "mfrmr"), winslash = "/", mustWork = TRUE
  )
  same <- if (.Platform$OS.type == "windows") {
    identical(tolower(loaded), tolower(expected))
  } else {
    identical(loaded, expected)
  }
  mfrmr_fc_g4h_assert(
    same, "Hosted G4 tests did not load the checked package."
  )
  result <- testthat::test_file(
    file.path(
      context$PackageRoot, "tests", "testthat",
      "test-fixed-calibration-g4-evidence.R"
    ),
    reporter = "summary"
  )
  counts <- as.data.frame(result)
  failed <- sum(counts$failed) + sum(counts$error) +
    sum(counts$warning) + sum(counts$skipped)
  mfrmr_fc_g4h_assert(
    identical(failed, 0L),
    "The repository G4 evidence test was incomplete on the hosted cell."
  )
  list(
    Tests = as.integer(nrow(counts)), Failed = as.integer(sum(counts$failed)),
    Errors = as.integer(sum(counts$error)),
    Warnings = as.integer(sum(counts$warning)),
    Skipped = as.integer(sum(counts$skipped)), LoadedPackagePath = loaded
  )
}

mfrmr_fc_g4h_repository_review <- function(context, readiness) {
  required_gates <- c(
    "source_truth", "public_scope", "evidence_counts", "example_policy",
    "release_evidence_freshness", "ci_workflow", "terminology",
    "evidence_artifacts"
  )
  gates <- readiness$gate_summary
  check <- readiness$check_status
  mfrmr_fc_g4h_assert(
    is.data.frame(gates) && all(c("Gate", "Status") %in% names(gates)) &&
      !anyDuplicated(gates$Gate) && all(required_gates %in% gates$Gate),
    "The repository readiness result lacks the hosted G4 gate registry."
  )
  required <- gates[match(required_gates, gates$Gate), , drop = FALSE]
  mfrmr_fc_g4h_assert(
    all(required$Status == "ok"),
    "A repository gate required for hosted G4 evidence is not OK."
  )
  check_fields <- c("CheckPassed", "StatusPresent", "VersionMatchesTarget")
  mfrmr_fc_g4h_assert(
    is.data.frame(check) && nrow(check) == 1L &&
      all(check_fields %in% names(check)) &&
      all(vapply(check[check_fields], isTRUE, logical(1L))),
    "The exact hosted G4 package check is not successful and version-matched."
  )
  deferred <- gates[setdiff(seq_len(nrow(gates)), match(
    required_gates, gates$Gate
  )), , drop = FALSE]
  list(
    Contract = "mfrmr_fixed_calibration_g4_repository_review_v1",
    RequiredGates = required,
    DeferredReleaseGates = deferred,
    ExactPackageCheckPassed = TRUE,
    G4RepositoryScopeComplete = TRUE,
    G6Authorized = FALSE,
    PublicAPIAuthorized = FALSE,
    Hash = context$Preflight$mfrmr_fc_g4b_hash(list(
      RequiredGates = required,
      ExactPackageCheckPassed = TRUE,
      G4RepositoryScopeComplete = TRUE,
      G6Authorized = FALSE,
      PublicAPIAuthorized = FALSE
    ))
  )
}

mfrmr_fc_g4h_cell_main <- function(package_root, evidence_directory) {
  mfrmr_fc_g4h_assert(
    requireNamespace("pkgbuild", quietly = TRUE) &&
      requireNamespace("rcmdcheck", quietly = TRUE) &&
      requireNamespace("testthat", quietly = TRUE),
    "Hosted G4 execution requires pkgbuild, rcmdcheck, and testthat."
  )
  context <- mfrmr_fc_g4h_context(package_root)
  cell <- mfrmr_fc_g4h_cell_environment(context$Contract)
  evidence_directory <- normalizePath(
    evidence_directory, winslash = "/", mustWork = FALSE
  )
  if (dir.exists(evidence_directory)) {
    existing <- list.files(
      evidence_directory, all.files = TRUE, no.. = TRUE
    )
    mfrmr_fc_g4h_assert(
      length(existing) == 0L,
      "The hosted G4 evidence directory must initially be empty."
    )
  } else {
    mfrmr_fc_g4h_assert(
      dir.create(evidence_directory, recursive = TRUE),
      "The hosted G4 evidence directory could not be created."
    )
  }
  started <- format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  git_before <- context$Preflight$mfrmr_fc_g4b_git_identity(
    context$PackageRoot
  )
  context$Preflight$mfrmr_fc_g4b_assert_git_identity(git_before)
  mfrmr_fc_g4h_assert(
    git_before$Clean, "Hosted G4 execution requires a clean checkout."
  )
  tarball <- pkgbuild::build(
    path = context$PackageRoot, dest_path = evidence_directory,
    binary = FALSE, vignettes = TRUE, manual = FALSE,
    args = c("--no-manual", "--compact-vignettes=gs+qpdf"), quiet = FALSE
  )
  tarball <- normalizePath(tarball, winslash = "/", mustWork = TRUE)
  manifest <- context$Preflight$mfrmr_fc_g4b_manifest(
    context$PackageRoot, tarball, git_identity = git_before
  )
  context$Preflight$mfrmr_fc_g4b_require_bound_candidate(
    manifest, context$PackageRoot, tarball
  )
  binding_path <- file.path(evidence_directory, "candidate-binding.rds")
  saveRDS(manifest, binding_path, version = 3)

  check_directory <- file.path(evidence_directory, "check")
  check <- rcmdcheck::rcmdcheck(
    path = tarball, args = c("--no-manual"), build_args = character(),
    check_dir = check_directory, error_on = "warning"
  )
  mfrmr_fc_g4h_assert(
    length(check$errors) == 0L && length(check$warnings) == 0L,
    "The exact bound tarball did not pass R CMD check."
  )
  check_log <- file.path(check_directory, "mfrmr.Rcheck", "00check.log")
  installed_library <- file.path(check_directory, "mfrmr.Rcheck")
  mfrmr_fc_g4h_assert(
    file.exists(check_log) && dir.exists(file.path(installed_library, "mfrmr")),
    "The exact check did not retain its log and installed package."
  )
  installed_library <- normalizePath(
    installed_library, winslash = "/", mustWork = TRUE
  )
  child_libraries <- unique(c(installed_library, .libPaths()))
  child_libraries <- normalizePath(
    child_libraries[dir.exists(child_libraries)],
    winslash = "/", mustWork = TRUE
  )
  old_r_libs <- Sys.getenv("R_LIBS", unset = NA_character_)
  old_dependency_libraries <- Sys.getenv(
    "MFRMR_G4_DEPENDENCY_LIBRARIES", unset = NA_character_
  )
  on.exit({
    if (is.na(old_r_libs)) {
      Sys.unsetenv("R_LIBS")
    } else {
      Sys.setenv(R_LIBS = old_r_libs)
    }
    if (is.na(old_dependency_libraries)) {
      Sys.unsetenv("MFRMR_G4_DEPENDENCY_LIBRARIES")
    } else {
      Sys.setenv(
        MFRMR_G4_DEPENDENCY_LIBRARIES = old_dependency_libraries
      )
    }
  }, add = TRUE)
  Sys.setenv(R_LIBS = paste(child_libraries, collapse = .Platform$path.sep))
  Sys.setenv(
    MFRMR_G4_DEPENDENCY_LIBRARIES = paste(
      child_libraries, collapse = .Platform$path.sep
    )
  )
  old_library <- Sys.getenv(
    "MFRMR_G4_INSTALLED_LIBRARY", unset = NA_character_
  )
  on.exit({
    if (is.na(old_library)) {
      Sys.unsetenv("MFRMR_G4_INSTALLED_LIBRARY")
    } else {
      Sys.setenv(MFRMR_G4_INSTALLED_LIBRARY = old_library)
    }
  }, add = TRUE)
  Sys.setenv(MFRMR_G4_INSTALLED_LIBRARY = installed_library)
  static <- mfrmr_fc_g4h_test_installed_evidence(
    context, installed_library
  )
  worker_output <- file.path(evidence_directory, "current-confirmation.rds")
  rscript <- file.path(R.home("bin"), "Rscript")
  if (.Platform$OS.type == "windows") rscript <- paste0(rscript, ".exe")
  worker_log <- system2(
    rscript,
    c(
      "--vanilla", context$WorkerPath, "current", context$PackageRoot,
      tarball, binding_path, worker_output
    ),
    stdout = TRUE, stderr = TRUE
  )
  worker_status <- attr(worker_log, "status")
  if (is.null(worker_status)) worker_status <- 0L
  writeLines(worker_log, file.path(evidence_directory, "worker.log"))
  mfrmr_fc_g4h_assert(
    identical(as.integer(worker_status), 0L) && file.exists(worker_output),
    paste(
      "The exact hosted G4 worker failed:", paste(worker_log, collapse = "\n")
    )
  )
  result <- readRDS(worker_output)
  expected_commit <- Sys.getenv("GITHUB_SHA", unset = git_before$HeadCommit)
  mfrmr_fc_g4h_assert(
    isTRUE(result$Complete) && identical(result$PassedCells, 49L) &&
      identical(result$FailedCells, 0L) &&
      identical(result$ResourceScalesPassed, 3L) &&
      identical(result$CandidateGitCommit, git_before$HeadCommit) &&
      identical(result$CandidateGitCommit, expected_commit) &&
      identical(result$ProspectiveContract,
                context$Contract$mfrmr_fc_g4_current_contract),
    "The hosted G4 result is incomplete or bound to another candidate."
  )
  receipt_payload <- list(
    Contract = mfrmr_fc_g4h_contract,
    CellId = cell$CellId, ExpectedOS = cell$ExpectedOS,
    RSelector = cell$RSelector, RunnerOS = cell$RunnerOS,
    CandidateGitCommit = result$CandidateGitCommit,
    CandidateTarballSHA256 = result$CandidateTarballSHA256,
    CandidateManifestHash = result$CandidateManifestHash,
    ProductionBoundaryRegistrySHA256 = manifest$ProductionRegistryHash,
    SupportRegistrySHA256 = manifest$SupportRegistryHash,
    Binding = manifest$Binding,
    CheckLogSHA256 = mfrmr_fc_g4h_file_hash(check_log),
    ChildLibraryCount = as.integer(length(child_libraries)),
    StaticEvidence = static,
    ConfirmationOutputSHA256 = mfrmr_fc_g4h_file_hash(worker_output),
    DenominatorCells = result$DenominatorCells,
    PassedCells = result$PassedCells, FailedCells = result$FailedCells,
    ResourceScalesPassed = result$ResourceScalesPassed,
    CellComplete = TRUE, HostedPlatformMatrixComplete = FALSE,
    G4ExitComplete = FALSE, G6Authorized = FALSE,
    PublicAPIAuthorized = FALSE,
    StartedAtUTC = started,
    FinishedAtUTC = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  )
  receipt <- c(receipt_payload, list(
    ReceiptHash = context$Preflight$mfrmr_fc_g4b_hash(receipt_payload)
  ))
  receipt_path <- file.path(evidence_directory, "hosted-cell-receipt.rds")
  saveRDS(receipt, receipt_path, version = 3)
  cat(
    "Hosted G4 cell complete: ", cell$CellId,
    "; commit=", result$CandidateGitCommit,
    "; tarball=", result$CandidateTarballSHA256, "\n", sep = ""
  )
  invisible(receipt)
}

mfrmr_fc_g4h_aggregate_main <- function(package_root, evidence_root,
                                         output_file) {
  context <- mfrmr_fc_g4h_context(package_root)
  evidence_root <- normalizePath(
    evidence_root, winslash = "/", mustWork = TRUE
  )
  if (file.exists(output_file)) {
    stop("The hosted matrix output path must not already exist.", call. = FALSE)
  }
  paths <- list.files(
    evidence_root, pattern = "^hosted-cell-receipt[.]rds$",
    recursive = TRUE, full.names = TRUE
  )
  matrix <- context$Contract$mfrmr_fc_g4_current_platform_matrix()
  mfrmr_fc_g4h_assert(
    length(paths) == nrow(matrix),
    "The hosted matrix does not contain exactly five cell receipts."
  )
  receipts <- lapply(paths, readRDS)
  valid_hash <- vapply(receipts, function(receipt) {
    payload <- receipt[setdiff(names(receipt), "ReceiptHash")]
    identical(
      receipt$ReceiptHash,
      context$Preflight$mfrmr_fc_g4b_hash(payload)
    )
  }, logical(1L))
  ids <- vapply(receipts, `[[`, character(1L), "CellId")
  order_index <- match(matrix$CellId, ids)
  mfrmr_fc_g4h_assert(
    all(valid_hash) && identical(sort(ids), sort(matrix$CellId)) &&
      !anyNA(order_index) && anyDuplicated(ids) == 0L,
    "The hosted cell receipt registry is altered or incomplete."
  )
  receipts <- receipts[order_index]
  scalar <- function(field) {
    vapply(receipts, function(receipt) as.character(receipt[[field]]),
           character(1L))
  }
  same <- function(field) length(unique(scalar(field))) == 1L
  cell_complete <- vapply(
    receipts, function(receipt) isTRUE(receipt$CellComplete), logical(1L)
  )
  passed <- vapply(receipts, `[[`, integer(1L), "PassedCells")
  failed <- vapply(receipts, `[[`, integer(1L), "FailedCells")
  resources <- vapply(
    receipts, `[[`, integer(1L), "ResourceScalesPassed"
  )
  expected_commit <- Sys.getenv(
    "GITHUB_SHA", unset = receipts[[1L]]$CandidateGitCommit
  )
  complete <- all(cell_complete) && all(passed == 49L) &&
    all(failed == 0L) && all(resources == 3L) &&
    same("CandidateGitCommit") && same("ProductionBoundaryRegistrySHA256") &&
    same("SupportRegistrySHA256") &&
    identical(receipts[[1L]]$CandidateGitCommit, expected_commit)
  mfrmr_fc_g4h_assert(
    complete,
    "The five hosted receipts do not establish one complete current candidate."
  )
  registry <- data.frame(
    CellId = matrix$CellId,
    OS = matrix$OS, R = matrix$R,
    CandidateGitCommit = scalar("CandidateGitCommit"),
    CandidateTarballSHA256 = scalar("CandidateTarballSHA256"),
    CandidateManifestHash = scalar("CandidateManifestHash"),
    CheckLogSHA256 = scalar("CheckLogSHA256"),
    ConfirmationOutputSHA256 = scalar("ConfirmationOutputSHA256"),
    PassedCells = passed, FailedCells = failed,
    ResourceScalesPassed = resources, Complete = cell_complete,
    stringsAsFactors = FALSE
  )
  payload <- list(
    Contract = "mfrmr_fixed_calibration_g4_hosted_matrix_v1",
    ProspectiveContract = context$Contract$mfrmr_fc_g4_current_contract,
    CandidateGitCommit = receipts[[1L]]$CandidateGitCommit,
    ProductionBoundaryRegistrySHA256 =
      receipts[[1L]]$ProductionBoundaryRegistrySHA256,
    SupportRegistrySHA256 = receipts[[1L]]$SupportRegistrySHA256,
    PlatformRegistry = registry,
    PlatformCells = as.integer(nrow(registry)),
    CompletePlatformCells = as.integer(sum(registry$Complete)),
    HostedPlatformMatrixComplete = TRUE,
    CORE05Complete = TRUE, CORE06Complete = TRUE,
    G4ExitComplete = TRUE, G6Authorized = FALSE,
    PublicAPIAuthorized = FALSE,
    AggregatedAtUTC = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  )
  result <- c(payload, list(
    MatrixReceiptHash = context$Preflight$mfrmr_fc_g4b_hash(payload)
  ))
  saveRDS(result, output_file, version = 3)
  cat(
    "Hosted G4 matrix complete: cells=5; commit=",
    result$CandidateGitCommit, "\n", sep = ""
  )
  invisible(result)
}

mfrmr_fc_g4h_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) == 3L && identical(arguments[1L], "cell")) {
    return(mfrmr_fc_g4h_cell_main(arguments[2L], arguments[3L]))
  }
  if (length(arguments) == 4L && identical(arguments[1L], "aggregate")) {
    return(mfrmr_fc_g4h_aggregate_main(
      arguments[2L], arguments[3L], arguments[4L]
    ))
  }
  stop(
    "Usage: Rscript --vanilla fixed-calibration-g4-hosted-runner-0.2.4.R ",
    "cell PACKAGE_ROOT EVIDENCE_DIRECTORY\n",
    "   or: Rscript --vanilla fixed-calibration-g4-hosted-runner-0.2.4.R ",
    "aggregate PACKAGE_ROOT EVIDENCE_ROOT OUTPUT_RDS",
    call. = FALSE
  )
}

if (sys.nframe() == 0L) mfrmr_fc_g4h_main()
