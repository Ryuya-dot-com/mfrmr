library(testthat)
library(mfrmr)

is_cran_check <- local({
  env <- Sys.getenv("NOT_CRAN")
  if (identical(env, "")) !interactive() else !isTRUE(as.logical(env))
})

cran_light_tests <- c(
  "fast-engine-032",
  "review-regressions-032",
  "rating-design-display",
  "tidymfrm",
  "inference-display",
  "model-planning-plots",
  "workflow-design-display",
  "report-statistics",
  "feedback-contracts-032",
  "posterior-summary",
  "mml-population-boundary",
  "step-constraints",
  "adaptive-native",
  "classification",
  "bias-numerics",
  "markov-drift",
  "multivariate-gtheory",
  "gstudy-sampling-vcov",
  "mantel-haenszel",
  "ordinal-logistic",
  "krippendorff-alpha",
  "optimizer-curvature"
)

cran_light_filter <- paste0("(^|/)(test-)?(", paste(cran_light_tests, collapse = "|"), ")$")

if (is_cran_check) {
  local({
    withr::local_options(Ncpus = 1L)
    withr::local_envvar(c(
      TESTTHAT_PARALLEL = "false", TESTTHAT_CPUS = "1",
      OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1",
      MKL_NUM_THREADS = "1", VECLIB_MAXIMUM_THREADS = "1",
      BLIS_NUM_THREADS = "1"
    ))
    test_check("mfrmr", filter = cran_light_filter)
  })
} else {
  test_check("mfrmr")
}
