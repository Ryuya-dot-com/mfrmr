#!/usr/bin/env Rscript

# Generate the serialized 0.2.2 migration fixture in an isolated child process.
# Usage:
# Rscript inst/validation/generate-legacy-0.2.2-fixture.R \
#   path/to/mfrmr_0.2.2.tar.gz \
#   tests/testthat/fixtures/mfrm-fit-0.2.2-pcm-jml.rds

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Expected exactly two arguments: 0.2.2 tarball and output RDS path.",
       call. = FALSE)
}

tarball <- normalizePath(args[[1]], winslash = "/", mustWork = TRUE)
output <- normalizePath(args[[2]], winslash = "/", mustWork = FALSE)
expected_sha256 <-
  "dddeaaba8d2d0684784fa774b349e8fa1d13570143341daad4aa31e2990e5d00"
if (!requireNamespace("digest", quietly = TRUE)) {
  stop("The fixture generator requires the suggested package `digest`.",
       call. = FALSE)
}
observed_sha256 <- digest::digest(
  file = tarball, algo = "sha256", serialize = FALSE
)
if (!identical(observed_sha256, expected_sha256)) {
  stop(
    "The supplied tarball does not match the frozen 0.2.2 SHA-256. Expected ",
    expected_sha256, ", observed ", observed_sha256, ".",
    call. = FALSE
  )
}

output_dir <- dirname(output)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
}
if (!dir.exists(output_dir)) {
  stop("Could not create fixture output directory: ", output_dir,
       call. = FALSE)
}

fixture_lib <- tempfile("mfrmr-0.2.2-library-")
dir.create(fixture_lib, recursive = TRUE, showWarnings = FALSE)
on.exit(unlink(fixture_lib, recursive = TRUE, force = TRUE), add = TRUE)

r_exe <- file.path(R.home("bin"), "R")
install_log <- system2(
  r_exe,
  c("CMD", "INSTALL", "-l", shQuote(fixture_lib), shQuote(tarball)),
  stdout = TRUE,
  stderr = TRUE
)
install_status <- attr(install_log, "status")
if (!is.null(install_status) && install_status != 0L) {
  stop(
    "Installation of the frozen 0.2.2 tarball failed:\n",
    paste(install_log, collapse = "\n"),
    call. = FALSE
  )
}

child_script <- tempfile("mfrmr-0.2.2-fixture-child-", fileext = ".R")
on.exit(unlink(child_script, force = TRUE), add = TRUE)
writeLines(
  c(
    "args <- commandArgs(trailingOnly = TRUE)",
    "fixture_lib <- args[[1]]",
    "output <- args[[2]]",
    "tarball_sha256 <- args[[3]]",
    ".libPaths(c(fixture_lib, .libPaths()))",
    "library(mfrmr)",
    "stopifnot(identical(as.character(utils::packageVersion('mfrmr')), '0.2.2'))",
    "data <- load_mfrmr_data('example_core')",
    "keep <- unique(data$Person)[seq_len(12L)]",
    "data <- data[data$Person %in% keep, , drop = FALSE]",
    "fit <- suppressWarnings(fit_mfrm(",
    "  data, 'Person', c('Rater', 'Criterion'), 'Score',",
    "  method = 'JML', model = 'PCM', step_facet = 'Criterion',",
    "  maxit = 120, reltol = 1e-9",
    "))",
    "stopifnot(is.null(fit$readiness))",
    "stopifnot(isTRUE(fit$summary$Converged[[1]]))",
    "stopifnot(isTRUE(fit$summary$InferenceReady[[1]]))",
    "stopifnot(identical(as.character(fit$summary$ConvergenceSeverity[[1]]), 'pass'))",
    "fixture <- list(",
    "  metadata = data.frame(",
    "    FixtureContract = 'mfrmr-saved-fit-migration-0.2.2-v1',",
    "    PackageVersion = '0.2.2',",
    "    TarballSHA256 = tarball_sha256,",
    "    Model = 'PCM', Method = 'JML',",
    "    Persons = length(unique(data$Person)),",
    "    Observations = nrow(data),",
    "    SourceData = 'mfrmr::example_core[first_12_persons]',",
    "    RVersion = as.character(getRversion()),",
    "    Platform = R.version$platform,",
    "    stringsAsFactors = FALSE",
    "  ),",
    "  fit = fit",
    ")",
    "saveRDS(fixture, output, version = 3L, compress = 'xz')"
  ),
  child_script,
  useBytes = TRUE
)

child_log <- system2(
  file.path(R.home("bin"), "Rscript"),
  c(
    "--vanilla",
    shQuote(child_script),
    shQuote(fixture_lib),
    shQuote(output),
    observed_sha256
  ),
  stdout = TRUE,
  stderr = TRUE
)
child_status <- attr(child_log, "status")
if (!is.null(child_status) && child_status != 0L) {
  stop(
    "The isolated 0.2.2 fixture child failed:\n",
    paste(child_log, collapse = "\n"),
    call. = FALSE
  )
}
if (!file.exists(output)) {
  stop("The isolated child did not create the requested fixture.",
       call. = FALSE)
}

cat(normalizePath(output, winslash = "/", mustWork = TRUE), "\n", sep = "")
