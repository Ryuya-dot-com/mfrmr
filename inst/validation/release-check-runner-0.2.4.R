# Exact source-tarball package check for the 0.2.4 development line.
#
# This runner deliberately emits package-check evidence only. Fixed-calibration
# G4 confirmation is held until a post-maintenance successor contract is frozen.

mfrmr_release_check_assert <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
  invisible(TRUE)
}

mfrmr_release_check_git_scalar <- function(package_root, arguments) {
  output <- tryCatch(
    suppressWarnings(system2(
      "git", c("-C", shQuote(package_root), arguments),
      stdout = TRUE, stderr = TRUE
    )),
    error = function(condition) structure(
      conditionMessage(condition), status = 127L
    )
  )
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  if (identical(as.integer(status), 0L) && length(output) == 1L) {
    enc2utf8(as.character(output[[1L]]))
  } else {
    NA_character_
  }
}

mfrmr_release_check_main <- function(package_root = ".",
                                     output_directory) {
  mfrmr_release_check_assert(
    requireNamespace("pkgbuild", quietly = TRUE) &&
      requireNamespace("rcmdcheck", quietly = TRUE) &&
      requireNamespace("digest", quietly = TRUE),
    "The exact package check requires pkgbuild, rcmdcheck, and digest."
  )
  package_root <- normalizePath(
    package_root, winslash = "/", mustWork = TRUE
  )
  mfrmr_release_check_assert(
    file.exists(file.path(package_root, "DESCRIPTION")),
    "The package root does not contain DESCRIPTION."
  )
  output_directory <- normalizePath(
    output_directory, winslash = "/", mustWork = FALSE
  )
  if (dir.exists(output_directory)) {
    existing <- list.files(output_directory, all.files = TRUE, no.. = TRUE)
    mfrmr_release_check_assert(
      length(existing) == 0L,
      "The package-check output directory must initially be empty."
    )
  } else {
    mfrmr_release_check_assert(
      dir.create(output_directory, recursive = TRUE),
      "The package-check output directory could not be created."
    )
  }

  started <- format(Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  commit <- mfrmr_release_check_git_scalar(
    package_root, c("rev-parse", "HEAD")
  )
  tree <- mfrmr_release_check_git_scalar(
    package_root, c("rev-parse", "HEAD^{tree}")
  )
  expected_commit <- Sys.getenv("GITHUB_SHA", unset = commit)
  mfrmr_release_check_assert(
    is.character(commit) && length(commit) == 1L && !is.na(commit) &&
      grepl("^[0-9a-f]{40}$", commit) &&
      identical(commit, expected_commit),
    "The package check is not bound to the expected Git commit."
  )

  tarball <- pkgbuild::build(
    path = package_root,
    dest_path = output_directory,
    binary = FALSE,
    vignettes = TRUE,
    manual = FALSE,
    args = c("--no-manual", "--compact-vignettes=gs+qpdf"),
    quiet = FALSE
  )
  tarball <- normalizePath(tarball, winslash = "/", mustWork = TRUE)
  check_directory <- file.path(output_directory, "check")
  error_on <- Sys.getenv("MFRMR_CHECK_ERROR_ON", unset = "warning")
  mfrmr_release_check_assert(
    error_on %in% c("never", "note", "warning", "error"),
    "MFRMR_CHECK_ERROR_ON has an unsupported value."
  )
  check <- rcmdcheck::rcmdcheck(
    path = tarball,
    args = c("--no-manual"),
    build_args = character(),
    check_dir = check_directory,
    error_on = error_on
  )
  mfrmr_release_check_assert(
    length(check$errors) == 0L && length(check$warnings) == 0L,
    "The exact source tarball did not pass R CMD check."
  )
  check_log <- file.path(check_directory, "mfrmr.Rcheck", "00check.log")
  mfrmr_release_check_assert(
    file.exists(check_log),
    "The exact package check did not retain 00check.log."
  )

  description <- read.dcf(file.path(package_root, "DESCRIPTION"))
  receipt <- list(
    Contract = "mfrmr_release_check_receipt_v1",
    EvidenceRole = "package_check_only",
    CandidateGitCommit = commit,
    CandidateGitTree = tree,
    PackageVersion = as.character(description[1L, "Version"]),
    SourceTarballSHA256 = digest::digest(
      file = tarball, algo = "sha256", serialize = FALSE
    ),
    CheckLogSHA256 = digest::digest(
      file = check_log, algo = "sha256", serialize = FALSE
    ),
    Errors = as.integer(length(check$errors)),
    Warnings = as.integer(length(check$warnings)),
    Notes = as.integer(length(check$notes)),
    CheckComplete = TRUE,
    G4EvidenceIssued = FALSE,
    G4ExitComplete = FALSE,
    G6Authorized = FALSE,
    StartedAtUTC = started,
    FinishedAtUTC = format(
      Sys.time(), "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC"
    )
  )
  saveRDS(
    receipt,
    file.path(output_directory, "release-check-receipt.rds"),
    version = 3
  )
  cat(
    "Exact package check complete: commit=", commit,
    "; G4 evidence issued=FALSE\n",
    sep = ""
  )
  invisible(receipt)
}

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = TRUE)
  if (length(arguments) != 2L) {
    stop(
      "Usage: Rscript --vanilla release-check-runner-0.2.4.R ",
      "PACKAGE_ROOT OUTPUT_DIRECTORY",
      call. = FALSE
    )
  }
  mfrmr_release_check_main(arguments[[1L]], arguments[[2L]])
}
