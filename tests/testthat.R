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

# Keep live estimation, independent numerical checks and representative public paths.
# Broader report/plot/portable-scoring combinations run in the complete suite.
# Always retain posterior-summary: archive encoding can break its public reader
# even when loaded values are identical. See CONTRIBUTING.md for coverage.
cran_light_tests <- c(
  "api-migration",
  "model-export",
  "model-export-affine",
  "model-export-summary",
  "posterior-summary",
  "adaptive-likelihood",
  "adaptive-quadrature-review",
  "calibration-public-api",
  "conditional-scoring",
  "decision-probabilities",
  "classification",
  "bias-numerics",
  "marginal-fit-availability",
  "mml-starts",
  "interaction-em",
  "facets-manual-consistency",
  "facets-results",
  "parameter-map-invariants",
  "likelihood-numerics",
  "source-posterior-numerics",
  "preparation-invariants",
  "anchor-centering",
  "anchor-migration",
  "anchored-calibration",
  "anchored-gpcm",
  "cran-smoke",
  "cml",
  "cml-comparisons",
  "comparison-review",
  "compiled-header-contract",
  "data-and-citation",
  "design-evaluation-denominators",
  "extended-example-replay",
  "simulation-example-replay",
  "results-csv-encoding",
  "feature-clustering",
  "response-imputation",
  "linking-numerics",
  "random-rater",
  "random-rater-profile",
  "testlet",
  "gauss-hermite-weights",
  "generalizability-missing",
  "multivariate-gtheory",
  "gstudy-sampling-vcov",
  "gstudy-example-replay",
  "dstudy-summary",
  "dstudy-delta",
  "multivariate-nested-gtheory",
  "icc-input",
  "mantel-haenszel",
  "ordinal-logistic",
  "mml-cpp11-backend",
  "missing-codes-integration",
  "bundle-summary-privacy",
  "gpcm-ic-eligibility",
  "gpcm-lrt",
  "gpcm-uncertainty-readiness",
  "gpcm-inference-extensions",
  "gpcm-pattern-cache",
  "gmfrm-public-workflow",
  "gmfrm-portable",
  "gmfrm-em",
  "jml-public-workflow",
  "study-report",
  "planning-report-connections",
  "report-modules",
  "residual-network",
  "network-inference",
  "prefit-network",
  "krippendorff-alpha",
  "namespace-contract",
  "optimizer-curvature",
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
  # backend, privacy, and installed-artifact contracts. Portable scoring,
  # dashboard restrictions, consolidated plot dispatch on saved results, and
  # guarded optimizer restarts are included.
  # Detailed plotting, repeated estimation/diagnostics, simulation/recovery,
  # documentation scans and broad regression tests remain in the complete
  # local/CI suite, which must be run with NOT_CRAN=true.
  local({
    # CRAN permits at most two concurrent cores. Keep each worker's numerical
    # libraries single-threaded, retain an explicit serial override, and leave
    # the complete regression suite below unchanged.
    requested <- suppressWarnings(as.integer(getOption(
      "Ncpus", Sys.getenv("TESTTHAT_CPUS", "2")
    )))
    if (length(requested) != 1L || is.na(requested) || requested < 1L) {
      stop("Ncpus / TESTTHAT_CPUS must specify a positive integer.")
    }
    withr::local_options(Ncpus = min(2L, requested))
    withr::local_envvar(c(
      TESTTHAT_PARALLEL = if (utils::packageVersion("testthat") >= "3.1.0") {
        Sys.getenv("TESTTHAT_PARALLEL", "true")
      } else "false",
      OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1",
      MKL_NUM_THREADS = "1", VECLIB_MAXIMUM_THREADS = "1",
      BLIS_NUM_THREADS = "1"
    ))
    test_check("mfrmr", filter = cran_light_filter)
  })
} else {
  test_check("mfrmr")
}
