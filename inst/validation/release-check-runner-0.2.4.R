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
  profile <- Sys.getenv("MFRMR_CHECK_PROFILE", "standard")
  mfrmr_release_check_assert(profile %in% c("standard", "cran-timing"),
    "MFRMR_CHECK_PROFILE must be standard or cran-timing.")
  timed <- identical(profile, "cran-timing")
  if (timed) {
    withr::local_envvar(c(NOT_CRAN = "false", `_R_CHECK_TIMINGS_` = "0",
      `_R_CHECK_DONTTEST_EXAMPLES_` = "false", OMP_NUM_THREADS = "1",
      OPENBLAS_NUM_THREADS = "1", VECLIB_MAXIMUM_THREADS = "1"))
    mfrmr_release_check_assert(
      requireNamespace("RTMB", quietly = TRUE) && utils::packageVersion("RTMB") >= "2.0" &&
        requireNamespace("nleqslv", quietly = TRUE),
      "The timing profile must exercise RTMB >= 2.0 and nleqslv features.")
  }
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

  build_started <- proc.time()
  tarball <- pkgbuild::build(
    path = package_root,
    dest_path = output_directory,
    binary = FALSE,
    vignettes = TRUE,
    manual = FALSE,
    args = c("--no-manual", "--compact-vignettes=gs+qpdf"),
    quiet = FALSE
  )
  build_time <- proc.time() - build_started
  tarball <- normalizePath(tarball, winslash = "/", mustWork = TRUE)
  check_directory <- file.path(output_directory, "check")
  error_on <- Sys.getenv("MFRMR_CHECK_ERROR_ON", unset = "warning")
  mfrmr_release_check_assert(
    error_on %in% c("never", "note", "warning", "error"),
    "MFRMR_CHECK_ERROR_ON has an unsupported value."
  )
  check_args <- if (timed) c("--as-cran", "--timings") else "--no-manual"
  check <- rcmdcheck::rcmdcheck(
    path = tarball,
    args = check_args,
    build_args = character(),
    check_dir = check_directory,
    error_on = if (timed) "never" else error_on
  )
  check_log <- file.path(check_directory, "mfrmr.Rcheck", "00check.log")
  if (timed) {
    protocol <- new.env(parent = globalenv())
    sys.source(file.path(package_root, "inst/validation/release-readiness.R"), protocol)
    lines <- if (file.exists(check_log)) readLines(check_log, warn = FALSE) else character()
    timing <- protocol$mfrmr_release_readiness_check_timing(lines, check$duration)
    # Use this source's declared optional dependencies, not the CRAN version.
    suggests <- read.dcf(file.path(package_root, "DESCRIPTION"))[1, "Suggests"]
    packages <- c("codetools", trimws(gsub("\\([^)]*\\)", "", strsplit(suggests, ",")[[1]])))
    versions <- vapply(packages, function(p) {
      tryCatch(as.character(utils::packageVersion(p)), error = function(e) NA_character_)
    }, "")
    utils::write.csv(attr(timing, "phases"), file.path(output_directory, "check-phases.csv"), row.names = FALSE)
    utils::write.csv(timing, file.path(output_directory, "check-timing.csv"), row.names = FALSE)
    utils::write.csv(data.frame(Package = packages, Version = unname(versions)),
      file.path(output_directory, "dependency-versions.csv"), row.names = FALSE)
    writeLines(capture.output(sessionInfo()), file.path(output_directory, "session-info.txt"))
    saveRDS(list(Commit = commit, Tree = tree,
      TarballSHA256 = digest::digest(file = tarball, algo = "sha256", serialize = FALSE),
      Profile = profile, CheckArgs = check_args, BuildTime = build_time,
      CheckCommandElapsed = check$duration, Timing = timing,
      Errors = check$errors, Warnings = check$warnings, Notes = check$notes,
      Platform = Sys.info(), Versions = versions,
      Environment = Sys.getenv(c("NOT_CRAN", "_R_CHECK_TIMINGS_", "_R_CHECK_DONTTEST_EXAMPLES_",
        "OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "VECLIB_MAXIMUM_THREADS"))),
      file.path(output_directory, "check-timing.rds"))
    print(timing)
  }
  mfrmr_release_check_assert(
    length(check$errors) == 0L && length(check$warnings) == 0L,
    "The exact source tarball did not pass R CMD check."
  )
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
    CheckProfile = profile,
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
  if (timed) mfrmr_release_check_assert(isTRUE(timing$UnderTenMinutes),
    "The complete check has not demonstrated check-only elapsed time below 600 seconds; see check-timing.rds.")
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
