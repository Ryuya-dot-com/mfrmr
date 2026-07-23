library(testthat)
library(mfrmr)

is_cran_check <- local({
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) {
    !interactive()
  } else {
    !isTRUE(as.logical(env))
  }
})

cran_light_tests <- c(
  "cran-smoke",
  "compatibility-aliases",
  "data-and-citation",
  "example-datasets",
  "data-processing",
  "estimation-core",
  "mml-cpp11-backend",
  "facets-summary-profile",
  "wright-facets-style",
  "fit-pathway",
  "marginal-fit-diagnostics",
  "missing-codes-integration",
  "bundle-summary-privacy",
  "console-output-contract",
  "output-guide",
  "gpcm-capability-matrix",
  "namespace-contract",
  "vignette-artifacts"
)

cran_light_filter <- paste0(
  "(^|/)(test-)?(",
  paste(cran_light_tests, collapse = "|"),
  ")$"
)

if (is_cran_check) {
  # Exercise the public data -> fit -> summary -> plot -> export route plus
  # lightweight model and installed-artifact contracts. Source-tree policy,
  # documentation scans, repeated simulation,
  # recovery, and broad regression tests remain in the complete local/CI suite,
  # which must be run with NOT_CRAN=true.
  test_check("mfrmr", filter = cran_light_filter)
} else {
  test_check("mfrmr")
}
