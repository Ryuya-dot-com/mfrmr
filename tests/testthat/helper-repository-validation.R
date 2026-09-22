# Helpers used only by repository validation tests excluded from the package
# tarball. They intentionally do not form part of the installed-package test
# or runtime dependency surface.

# Frozen GPCM score-calibration sources deliberately retain the pre-0.2.3
# implicit fixed-N(0, 1) identification. They must not be executed against an
# evolved package payload, because doing so would silently change the target
# likelihood.
skip_if_frozen_gpcm_payload_drifted <- function() {
  testthat::skip_if_not_installed("digest")
  root <- normalizePath(
    testthat::test_path("..", ".."),
    winslash = "/",
    mustWork = TRUE
  )
  contract <- file.path(
    root, "inst", "validation", "gpcm-score-v3-freeze-contract-0.2.3.R"
  )
  testthat::skip_if_not(
    file.exists(contract),
    "Repository-only frozen GPCM payload contract is unavailable."
  )
  env <- new.env(parent = globalenv())
  sys.source(contract, envir = env)
  current <- env$mfrmr_gsv3f_payload_identity(root)
  testthat::skip_if_not(
    identical(current, env$mfrmr_gsv3f_expected_payload),
    paste0(
      "Frozen fixed-standard-normal GPCM numerical evidence belongs to an ",
      "earlier package payload and is not replayed under the new default ",
      "identification."
    )
  )
  invisible(TRUE)
}
