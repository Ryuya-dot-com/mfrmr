# Bounded numerical qualification on retained calibrations, not sampling evidence.
# Prespecified checks: full observed information versus independent Louis formula,
# q versus 2q-1 changes, all source failures retained, saved output round trip.
# No optimization, new response generation or data-dependent target selection.
pkgload::load_all(".", quiet = TRUE)
source("tests/testthat/helper-gmfrm-information.R")
out <- "validation-results/gmfrm-adaptive-information-20260930"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
if (file.exists(file.path(out, "audit.rds"))) stop("Retain the completed information audit.")
input <- "validation-results/gmfrm-adaptive-calibration-20260930/public-adaptive61.rds"
fit <- readRDS(input)$fit
setup <- do.call(mfrm_gmfrm_problem, fit$gmfrm$specification)$common
params <- expand_params(fit$opt$par, setup$sizes, fit$config)
elapsed <- system.time({
  information <- compute_mml_parameter_covariance(fit)
  fine <- fit; fine$config$estimation_control$quad_points <- 121L
  finer_information <- compute_mml_parameter_covariance(fine)
  basis <- mfrmr_adaptive_quadrature_basis(setup$idx, fit$config, params,
    gauss_hermite_normal(121L), compute_base_eta(setup$idx, params, fit$config))
  reference <- gmfrm_louis_reference(fit$gmfrm$specification, fit$opt$par,
    basis$nodes, basis$log_weights)
  root <- chol(reference$information)
  covariance <- solve(reference$information)
  relative <- function(x) norm(solve(t(root), t(solve(t(root), x))), "2")
  numeric_scores <- mfrm_mml_person_scores_numeric(fine)
  warnings <- character()
  ci <- withCallingHandlers(confint(fit), warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
  })
  results <- mfrm_results(fit, include = "fit", compute = "never", intervals = list(slopes = ci))
  report <- mfrm_report(results)
  saveRDS(results, file.path(out, "results.rds"))
  restored <- readRDS(file.path(out, "results.rds"))
  summary <- data.frame(Persons = nrow(reference$scores), FreeParameters = length(fit$opt$par),
    SmallestLouisEigenvalue = min(eigen(reference$information, symmetric = TRUE)$values),
    Hessian61RelativeError = relative(information$hessian - reference$information),
    Hessian121RelativeError = relative(finer_information$hessian - reference$information),
    Covariance61RelativeError = norm(root %*% (information$cov - covariance) %*% t(root), "2"),
    MaxPersonScoreError = max(abs(numeric_scores - reference$scores)),
    NLLDifference = abs(-sum(reference$log_marginal) - fit$opt$value),
    AvailableIntervals = sum(attr(ci, "diagnostics")$CIEligible),
    RequestedIntervals = nrow(ci),
    SavedIntervalsIdentical = identical(restored$gpcm_inference$slopes, ci),
    SavedReportIdentical = identical(mfrm_report(restored)$markdown, report$markdown))
})[["elapsed"]]
saveRDS(list(summary = summary, reference = reference, information = information,
  finer_information = finer_information, intervals = ci, warnings = warnings, elapsed = elapsed,
  input_hash = tools::md5sum(input), source_hashes = tools::md5sum(c(
    "R/core-gpcm-product-slopes.R", "R/core-gpcm-inference.R", "R/core-adaptive-quadrature.R",
    "R/mfrm_core.R", "tests/testthat/helper-gmfrm-information.R",
    "inst/validation/gmfrm-adaptive-information-20260930.R"))), file.path(out, "audit.rds"))
write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
write.csv(attr(ci, "numerical_checks"), file.path(out, "numerical-checks.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(summary, row.names = FALSE, digits = 10)
print(attr(ci, "checks"), row.names = FALSE)
cat("Elapsed:", elapsed, "seconds\n")
stopifnot(summary$Hessian61RelativeError < 1e-4, summary$Hessian121RelativeError < 1e-4,
  summary$Covariance61RelativeError < 1e-4, summary$MaxPersonScoreError < 1e-5,
  summary$NLLDifference < 1e-6, summary$SavedIntervalsIdentical, summary$SavedReportIdentical)
