# Bounded retained-calibration check; no fitting, new simulation or threshold tuning.
# Compare every row with literal continuous integrals and retain all unavailable
# outputs at the prespecified orders 7, 61 and 121 (checks at 2q+1).
pkgload::load_all(".", quiet = TRUE)
source("tests/testthat/helper-gmfrm-response.R")
out <- "validation-results/gmfrm-adaptive-residuals-20260930"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
if (file.exists(file.path(out, "audit.rds"))) stop("Retain the completed residual audit.")
input_file <- "validation-results/gmfrm-adaptive-calibration-20260930/public-adaptive61.rds"
fit <- readRDS(input_file)$fit
source_files <- c("R/api-response-diagnostics-gmfrm.R", "R/api-response-diagnostics.R",
  "R/api-response-diagnostics-ordinary.R", "R/core-adaptive-quadrature.R",
  "tests/testthat/helper-gmfrm-response.R", "inst/validation/gmfrm-adaptive-residuals-20260930.R")
hashes <- tools::md5sum(c(input_file, source_files))
manifest <- file.path(out, "source-hashes.rds")
if (file.exists(manifest)) stopifnot(identical(readRDS(manifest), hashes)) else saveRDS(hashes, manifest)
elapsed <- system.time({
  orders <- c(7L, 61L, 121L)
  diagnostics <- setNames(lapply(orders, function(q)
    mfrm_response_diagnostics(fit, group_by = fit$config$slope_facet, quad_points = q)), paste0("q", orders))
  data <- fit$gmfrm$specification$data; columns <- fit$prep$source_columns
  groups <- split(seq_len(nrow(data)), as.character(data[[columns$person]]))
  nc <- fit$config$n_cat
  probabilities <- matrix(NA_real_, nrow(data), nc)
  means <- variances <- conditional_variances <- numeric(nrow(data))
  fixed_probabilities <- matrix(NA_real_, nrow(data), nc)
  fixed_difference <- numeric(nrow(data))
  # Numerical fixed-grid comparison at exactly the same calibration. This is
  # an integrand input, not a relabelled fitted object or an admitted public fit.
  fixed_input <- mfrm_gmfrm_response_input(fit)
  fixed_input$config$estimation_control$mml_integration <- "fixed"
  for (i in seq_along(groups)) {
    rows <- groups[[i]]
    file <- file.path(out, paste0("reference-", i, ".rds"))
    if (!file.exists(file)) saveRDS(gmfrm_response_reference(fit, rows), file)
    reference <- readRDS(file)
    probabilities[rows, ] <- reference$probabilities
    means[rows] <- reference$mean; variances[rows] <- reference$variance
    conditional_variances[rows] <- reference$conditional_variance
    low <- mfrm_gmfrm_response_probabilities(fixed_input, rows, 121L)$probabilities
    high <- mfrm_gmfrm_response_probabilities(fixed_input, rows, 243L)$probabilities
    fixed_probabilities[rows, ] <- high
    fixed_difference[rows] <- apply(abs(high - low), 1L, max)
    if (i %% 25L == 0L) cat(i, "of", length(groups), "Persons checked\n")
  }
  summary <- do.call(rbind, lapply(seq_along(diagnostics), function(i) {
    d <- diagnostics[[i]]; available <- d$rows$Status == "available_conditional"
    data.frame(QuadraturePoints = orders[i], CheckPoints = 2L * orders[i] + 1L,
      Requested = nrow(data), Available = sum(available),
      Groups = nrow(d$measures), AvailableGroups = sum(d$measures$Status == "descriptive_only"),
      MaximumIntegrationDifference = max(d$rows$IntegrationDifference),
      MaximumProbabilityError = max(abs(d$probabilities[available, , drop = FALSE] - probabilities[available, , drop = FALSE])),
      MaximumMeanError = max(abs(d$rows$ExpectedScore[available] - means[available])),
      MaximumVarianceError = max(abs(d$rows$PredictiveVariance[available] - variances[available])))
  }))
  fine <- diagnostics$q121
  results <- mfrm_results(fit, include = c("fit", "plots"), compute = "never", response_diagnostics = fine)
  report <- mfrm_report(results)
  saveRDS(results, file.path(out, "results.rds"))
  restored <- readRDS(file.path(out, "results.rds"))
  stopifnot(identical(restored$response_diagnostics, fine),
    identical(mfrm_report(restored)$markdown, report$markdown))
  fixed <- data.frame(QuadraturePoints = 121L, CheckPoints = 243L,
    MaximumProbabilityError = max(abs(fixed_probabilities - probabilities)),
    MaximumIntegrationDifference = max(fixed_difference),
    PassingRows = sum(fixed_difference <= 1e-7), Requested = nrow(data))
  exposure <- vapply(groups, function(rows) length(unique(data[[fit$config$slope_facet[2]]][rows])), 0L)
  by_exposure <- do.call(rbind, lapply(sort(unique(exposure)), function(n) {
    rows <- unlist(groups[exposure == n], use.names = FALSE)
    data.frame(RatersPerPerson = n, Rows = length(rows),
      AdaptiveAvailable61 = sum(diagnostics$q61$rows$Status[rows] == "available_conditional"),
      AdaptiveAvailable121 = sum(fine$rows$Status[rows] == "available_conditional"),
      FixedPassing121 = sum(fixed_difference[rows] <= 1e-7),
      MaximumFixedProbabilityError = max(abs(fixed_probabilities[rows, ] - probabilities[rows, ])),
      MaximumAdaptiveProbabilityError = max(abs(fine$probabilities[rows, ] - probabilities[rows, ])))
  }))
})[["elapsed"]]
saveRDS(list(summary = summary, fixed = fixed, by_exposure = by_exposure, diagnostics = diagnostics,
  reference = list(probabilities = probabilities, means = means, variances = variances,
    conditional_variances = conditional_variances), fixed_probabilities = fixed_probabilities,
  fixed_difference = fixed_difference, elapsed = elapsed, source_hashes = hashes), file.path(out, "audit.rds"))
write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
write.csv(fixed, file.path(out, "fixed-comparison.csv"), row.names = FALSE)
write.csv(by_exposure, file.path(out, "exposure.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(summary, row.names = FALSE, digits = 10); print(fixed, row.names = FALSE, digits = 10)
print(by_exposure, row.names = FALSE, digits = 10)
cat("Elapsed:", elapsed, "seconds\n")
# Accuracy limits precede execution. Availability is reported separately;
# missing values cannot pass an accuracy check by being silently dropped.
stopifnot(all(summary$MaximumProbabilityError < 1e-8),
  all(summary$MaximumMeanError < 1e-8), all(summary$MaximumVarianceError < 1e-8),
  all(is.finite(probabilities)), max(abs(rowSums(probabilities) - 1)) < 1e-8,
  all(variances >= conditional_variances - 1e-8))
