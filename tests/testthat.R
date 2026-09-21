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
  "adaptive-fitting",
  "adaptive-quadrature-review",
  "cran-smoke",
  "cluster-comparison",
  "cluster-plots",
  "compatibility-aliases",
  "compiled-header-contract",
  "data-and-citation",
  "example-datasets",
  "feature-clustering",
  "hierarchical-clustering",
  "gauss-hermite-weights",
  "generalizability-missing",
  "multivariate-gtheory",
  "multivariate-d-study-plots",
  "icc-ci-method",
  "icc-input",
  "posterior-intervals",
  "shrinkage-replay",
  "mml-cpp11-backend",
  "missing-codes-integration",
  "bundle-summary-privacy",
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
  # Exercise the public data -> declared-design review -> fit -> summary ->
  # Wright/pathway plot -> export route once, plus lightweight compatibility,
  # backend, privacy, and installed-artifact contracts. Detailed plotting,
  # repeated estimation/diagnostics, simulation/recovery, documentation scans,
  # and broad regression tests remain in the complete local/CI suite, which
  # must be run with NOT_CRAN=true.
  test_check("mfrmr", filter = cran_light_filter)
} else {
  test_check("mfrmr")
}
