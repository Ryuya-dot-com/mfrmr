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
# Broader report/plot/portable-scoring combinations run in the complete suite;
# see CONTRIBUTING.md for the remaining ordinary coverage of those families.
cran_light_tests <- c(
  "api-migration",
  "model-export",
  "model-export-affine",
  "model-export-summary",
  "posterior-summary",
  "adaptive-fitting",
  "adaptive-quadrature-review",
  "calibration-public-api",
  "appendix-table-collisions",
  "conditional-scoring",
  "decision-probabilities",
  "classification",
  "category-variance",
  "bias-numerics",
  "marginal-fit-availability",
  "mml-starts",
  "facets-manual-consistency",
  "facets-results",
  "fair-delta",
  "facet-centering",
  "parameter-map-invariants",
  "likelihood-numerics",
  "source-posterior-numerics",
  "preparation-invariants",
  "anchor-centering",
  "anchor-migration",
  "anchored-facet-intervals",
  "anchored-calibration",
  "anchored-gpcm",
  "fit-measures-scope",
  "portable-jml",
  "cran-smoke",
  "cml",
  "cml-comparisons",
  "cml-interval-display",
  "cluster-comparison",
  "comparison-review",
  "fitted-comparisons",
  "partial-comparisons",
  "cluster-plots",
  "compatibility-aliases",
  "compiled-header-contract",
  "data-and-citation",
  "design-evaluation-denominators",
  "d-study-plots",
  "example-datasets",
  "extended-example-replay",
  "simulation-example-replay",
  "results-replay",
  "results-csv-encoding",
  "feature-clustering",
  "numeric-feature-workflows",
  "response-imputation",
  "facet-intervals",
  "plot-population-intervals",
  "dff-plot-support",
  "dff-refit-availability",
  "linking-numerics",
  "plot-export-notes",
  "reliability-snapshot-scope",
  "shrinkage-numerics",
  "screening-performance",
  "random-rater",
  "random-rater-profile",
  "random-rater-intervals",
  "testlet",
  "testlet-integration",
  "hierarchical-clustering",
  "gauss-hermite-weights",
  "generalizability-missing",
  "multivariate-gtheory",
  "multivariate-gstudy-intervals",
  "gstudy-sampling-vcov",
  "gstudy-example-replay",
  "multivariate-dstudy-intervals",
  "dstudy-summary",
  "dstudy-delta",
  "dstudy-spectral-f",
  "dstudy-method-selection",
  "dstudy-mls-inversion",
  "dstudy-score-intervals",
  "multivariate-gstudy-plots",
  "multivariate-nested-gtheory",
  "multivariate-d-compare",
  "multivariate-d-study-plots",
  "icc-ci-method",
  "icc-input",
  "mantel-haenszel",
  "ordinal-logistic",
  "dff-row-matching",
  "posterior-intervals",
  "population-intervals",
  "shrinkage-replay",
  "mml-cpp11-backend",
  "missing-codes-integration",
  "bundle-summary-privacy",
  "gpcm-capability-matrix",
  "gpcm-ic-eligibility",
  "gpcm-lrt",
  "rsm-pcm-nesting",
  "gpcm-uncertainty-readiness",
  "gpcm-inference-extensions",
  "gpcm-profile-intervals",
  "gpcm-pattern-cache",
  "gmfrm-public-workflow",
  "gmfrm-scoring",
  "gmfrm-portable",
  "experimental-reporting",
  "agreement-reporting",
  "gmfrm-interval-status",
  "gmfrm-rank-deficient-source",
  "gmfrm-adaptive-profiles",
  "gmfrm-adaptive-start",
  "gmfrm-em",
  "jml-public-workflow",
  "study-report",
  "report-modules",
  "residual-network",
  "network-inference",
  "prefit-network",
  "descriptive-review-contract",
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
