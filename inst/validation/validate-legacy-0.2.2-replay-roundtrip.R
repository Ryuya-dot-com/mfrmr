#!/usr/bin/env Rscript

# Repository-only fresh-session migration/replay check. This script installs
# the current source tree into a temporary library, replays the real 0.2.2
# serialized fixture, and verifies that source readiness is provenance rather
# than a status copied into the new fit.

args <- commandArgs(trailingOnly = TRUE)
pkg_root <- normalizePath(
  if (length(args) >= 1L) args[[1]] else ".",
  winslash = "/",
  mustWork = TRUE
)
fixture_path <- normalizePath(
  if (length(args) >= 2L) args[[2]] else
    file.path(
      pkg_root, "tests", "testthat", "fixtures",
      "mfrm-fit-0.2.2-pcm-jml.rds"
    ),
  winslash = "/",
  mustWork = TRUE
)

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("This repository validator requires the suggested package `devtools`.",
       call. = FALSE)
}
devtools::load_all(pkg_root, quiet = TRUE)

fixture <- readRDS(fixture_path)
stopifnot(
  identical(
    fixture$metadata$FixtureContract[[1]],
    "mfrmr-saved-fit-migration-0.2.2-v1"
  ),
  identical(fixture$metadata$PackageVersion[[1]], "0.2.2"),
  is.null(fixture$fit$readiness),
  isTRUE(fixture$fit$summary$InferenceReady[[1]])
)

source_record <- mfrmr:::mfrmr_get_readiness_record(fixture$fit)
stopifnot(
  identical(source_record$fit$FitReadiness[[1]], "legacy_unknown"),
  identical(source_record$fit$InferenceReady[[1]], FALSE),
  identical(source_record$fit$ReasonCodes[[1]], "legacy_contract_missing")
)

diagnostics <- suppressWarnings(mfrmr::diagnose_mfrm(
  fixture$fit, residual_pca = "none"
))

roundtrip_dir <- tempfile("mfrmr-legacy-roundtrip-")
dir.create(roundtrip_dir, recursive = TRUE, showWarnings = FALSE)
on.exit(unlink(roundtrip_dir, recursive = TRUE, force = TRUE), add = TRUE)
data_path <- file.path(roundtrip_dir, "analysis_data.csv")
script_path <- file.path(roundtrip_dir, "replay.R")
result_path <- file.path(roundtrip_dir, "roundtrip-result.rds")

data <- mfrmr::load_mfrmr_data("example_core")
keep <- unique(data$Person)[seq_len(12L)]
data <- data[data$Person %in% keep, , drop = FALSE]
utils::write.csv(data, data_path, row.names = FALSE, na = "")

replay <- mfrmr::build_mfrm_replay_script(
  fixture$fit,
  diagnostics = diagnostics,
  data_file = data_path,
  include_bundle = FALSE
)
writeLines(
  c(
    replay$script,
    "",
    paste0(
      "saveRDS(list(package_version = as.character(utils::packageVersion('mfrmr')), ",
      "source = source_readiness, replay = replay_readiness, ",
      "matches = replay_readiness_matches_source), ",
      deparse(result_path), ", version = 3L)"
    )
  ),
  script_path,
  useBytes = TRUE
)

current_lib <- tempfile("mfrmr-current-library-")
dir.create(current_lib, recursive = TRUE, showWarnings = FALSE)
on.exit(unlink(current_lib, recursive = TRUE, force = TRUE), add = TRUE)
install_log <- system2(
  file.path(R.home("bin"), "R"),
  c("CMD", "INSTALL", "-l", shQuote(current_lib), shQuote(pkg_root)),
  stdout = TRUE,
  stderr = TRUE
)
install_status <- attr(install_log, "status")
if (!is.null(install_status) && install_status != 0L) {
  stop(
    "Installation of the current source tree failed:\n",
    paste(install_log, collapse = "\n"),
    call. = FALSE
  )
}

child_log <- system2(
  file.path(R.home("bin"), "Rscript"),
  c("--vanilla", shQuote(script_path)),
  stdout = TRUE,
  stderr = TRUE,
  env = paste0("R_LIBS=", shQuote(current_lib))
)
child_status <- attr(child_log, "status")
if (!is.null(child_status) && child_status != 0L) {
  stop(
    "Fresh-session replay failed:\n",
    paste(child_log, collapse = "\n"),
    call. = FALSE
  )
}
if (!file.exists(result_path)) {
  stop("Fresh-session replay did not write its round-trip result.",
       call. = FALSE)
}
if (!any(grepl(
  "Replayed fit readiness differs from the source readiness provenance",
  child_log,
  fixed = TRUE
))) {
  stop("Fresh-session replay did not emit the required readiness mismatch warning.",
       call. = FALSE)
}

result <- readRDS(result_path)
stopifnot(
  identical(result$package_version, "0.2.3"),
  identical(result$source$FitReadiness[[1]], "legacy_unknown"),
  identical(result$source$InferenceReady[[1]], FALSE),
  identical(result$replay$ReadinessContractVersion[[1]],
            "mfrmr-readiness-0.2.3-v3"),
  identical(result$replay$FitReadiness[[1]], "ready"),
  identical(result$replay$InferenceReady[[1]], TRUE),
  identical(result$matches, FALSE)
)

print(data.frame(
  Contract = "mfrmr-legacy-0.2.2-replay-roundtrip-v1",
  InstalledVersion = result$package_version,
  SourceFitReadiness = result$source$FitReadiness[[1]],
  SourceInferenceReady = result$source$InferenceReady[[1]],
  ReplayFitReadiness = result$replay$FitReadiness[[1]],
  ReplayInferenceReady = result$replay$InferenceReady[[1]],
  ReadinessMatches = result$matches,
  RequiredWarningObserved = TRUE,
  stringsAsFactors = FALSE
), row.names = FALSE)
