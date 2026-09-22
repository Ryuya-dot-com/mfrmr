args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop(
    "Usage: Rscript --vanilla fixed-calibration-g4-macos-installed-runner-0.2.4.R ",
    "PACKAGE_ROOT RESULT_RDS",
    call. = FALSE
  )
}

package_root <- normalizePath(args[1], mustWork = TRUE)
result_file <- args[2]
if (file.exists(result_file)) {
  stop("The result path must not already exist.", call. = FALSE)
}
installed_library <- Sys.getenv("MFRMR_G4_INSTALLED_LIBRARY", unset = "")
if (!nzchar(installed_library)) {
  stop("MFRMR_G4_INSTALLED_LIBRARY must identify the isolated library.",
       call. = FALSE)
}
installed_library <- normalizePath(installed_library, mustWork = TRUE)
.libPaths(c(installed_library, .libPaths()))

if (!identical(unname(Sys.info()[["sysname"]]), "Darwin")) {
  stop("This runner records only the native macOS platform cell.", call. = FALSE)
}
if (!identical(R.version$status, "")) {
  stop("This runner requires an R release build, not devel or patched status.",
       call. = FALSE)
}
if (!isTRUE(capabilities("profmem"))) {
  stop("The frozen allocation-memory rule requires Rprofmem support.",
       call. = FALSE)
}

suppressPackageStartupMessages(library(mfrmr))
loaded_package_path <- normalizePath(find.package("mfrmr"), mustWork = TRUE)
if (!identical(dirname(loaded_package_path), installed_library)) {
  stop("mfrmr was not loaded from the isolated library.", call. = FALSE)
}

test_file <- file.path(
  package_root, "tests", "testthat", "test-fixed-calibration-g4-evidence.R"
)
result <- testthat::test_file(test_file, reporter = "summary")
counts <- as.data.frame(result)
totals <- list(
  tests = as.integer(nrow(counts)),
  expectations = as.integer(sum(counts$nb)),
  failed = as.integer(sum(counts$failed)),
  errors = as.integer(sum(counts$error)),
  warnings = as.integer(sum(counts$warning)),
  skipped = as.integer(sum(counts$skipped))
)
if (totals$failed > 0L || totals$errors > 0L || totals$warnings > 0L ||
    totals$skipped > 0L) {
  stop("The native installed-package macOS G4 cell is incomplete.",
       call. = FALSE)
}

saveRDS(
  list(
    status = "pass",
    cell_id = "macos-release-native-preflight",
    prospective_workflow_cell = "macos-release",
    workflow_cell_complete = FALSE,
    evidence_scope = "native_macos_isolated_installed_source_tarball",
    package_version = as.character(utils::packageVersion("mfrmr")),
    loaded_package_path = loaded_package_path,
    installed_library = installed_library,
    R = R.version.string,
    R_status = R.version$status,
    platform = R.version$platform,
    system = as.list(Sys.info()),
    locale = Sys.getlocale(),
    profmem = capabilities("profmem"),
    test_totals = totals
  ),
  result_file,
  version = 3
)

cat(
  "G4 macOS installed-package preflight: pass; tests=", totals$tests,
  "; expectations=", totals$expectations, "\n", sep = ""
)
