# Fixed-calibration integration audit. Reuses both retained fits; no refitting.
pkgload::load_all(".", quiet = TRUE)
source_file <- "validation-results/gmfrm-practitioner-20260930/quadrature-review.rds"
out <- "validation-results/gmfrm-fixed-integration-20260930"
if (file.exists(file.path(out, "audit.rds"))) stop("Retain the completed integration audit.")
fits <- readRDS(source_file)$value$fits
dir.create(out, recursive = TRUE, showWarnings = FALSE)

# Literal response equation and continuous integration, independently of the
# package probability kernel and GH rules. Mode/scale only change coordinates.
continuous_reference <- function(fit, person, mode, scale) {
  spec <- fit$gmfrm$specification
  data <- spec$data[as.character(spec$data[[spec$person]]) == person, ]
  owners <- spec$slope_facets
  location <- Reduce(`+`, lapply(owners, function(owner) {
    tab <- fit$facets$others[fit$facets$others$Facet == owner, ]
    tab$Estimate[match(as.character(data[[owner]]), tab$Level)]
  }))
  slope <- Reduce(`*`, lapply(owners, function(owner) {
    tab <- fit$slopes[fit$slopes$SlopeOwner == owner, ]
    tab$Estimate[match(as.character(data[[owner]]), tab$SlopeFacet)]
  }))
  cumulative <- t(vapply(as.character(data[[owners[2]]]), function(level) {
    tab <- fit$steps[fit$steps$StepFacet == level, ]
    c(0, cumsum(tab$Estimate[order(tab$Step)]))
  }, numeric(spec$max_score + 1L)))
  log_joint <- function(theta) {
    logits <- (outer(theta - location, 0:spec$max_score) - cumulative) * slope
    high <- apply(logits, 1, max)
    sum(logits[cbind(seq_len(nrow(data)), data[[spec$score]] + 1L)] - high -
      log(rowSums(exp(logits - high)))) + dnorm(theta, log = TRUE)
  }
  height <- log_joint(mode)
  values <- lapply(0:2, function(power) stats::integrate(function(z)
    vapply(z, function(x) x^power * exp(log_joint(mode + scale * x) - height) * scale,
      numeric(1)), -Inf, Inf, rel.tol = 1e-10, abs.tol = 1e-12, subdivisions = 1000L))
  stopifnot(all(vapply(values, function(x) identical(x$message, "OK"), logical(1))))
  moment <- vapply(values, `[[`, numeric(1), "value")
  c(LogMarginal = height + log(moment[1]), EAP = mode + scale * moment[2] / moment[1],
    SD = scale * sqrt(moment[3] / moment[1] - (moment[2] / moment[1])^2),
    MaxAbsoluteErrorEstimate = max(vapply(values, `[[`, numeric(1), "abs.error")))
}

reviews <- references <- summaries <- list()
elapsed <- system.time(for (name in names(fits)) {
  fit <- fits[[name]]; config <- fit$config
  idx <- build_indices(fit$prep, config$step_facet, config$slope_facet,
    config$interaction_specs, gpcm_spec = config$gpcm_spec)
  params <- expand_params(fit$opt$par, build_param_sizes(config), config)
  review <- mfrmr_adaptive_quadrature_review(idx, config, params,
    gauss_hermite_normal(config$estimation_control$quad_points),
    fit$prep$levels$Person, c(15L, 31L, 61L))
  stopifnot(all(review$Status == "computed"))
  finest <- review[review$AdaptiveNodes == 61L, ]
  stopifnot(abs(sum(finest$FixedLogMarginal) + fit$opt$value) < 1e-9)
  reference <- t(vapply(seq_len(nrow(finest)), function(i) continuous_reference(
    fit, finest$Person[i], finest$PosteriorMode[i], finest$LocalPosteriorSD[i]),
    c(LogMarginal = 0, EAP = 0, SD = 0, MaxAbsoluteErrorEstimate = 0)))
  reference <- data.frame(Person = finest$Person, reference)
  summaries[[name]] <- data.frame(Fit = name, Persons = nrow(finest),
    FixedNLL = fit$opt$value, AdaptiveNLL = -sum(finest$AdaptiveLogMarginal),
    ContinuousNLL = -sum(reference$LogMarginal),
    MaxFixedLogError = max(abs(finest$FixedLogMarginal - reference$LogMarginal)),
    MaxAdaptiveLogError = max(abs(finest$AdaptiveLogMarginal - reference$LogMarginal)),
    MaxAdaptiveEAPError = max(abs(finest$AdaptiveEAP - reference$EAP)),
    MaxAdaptiveSDError = max(abs(finest$AdaptivePosteriorSD - reference$SD)),
    MaxFixedEAPError = max(abs(finest$FixedEAP - reference$EAP)),
    MaxFixedSDError = max(abs(finest$FixedPosteriorSD - reference$SD)))
  reviews[[name]] <- review; references[[name]] <- reference
})[["elapsed"]]
summary <- do.call(rbind, summaries)
saveRDS(list(reviews = reviews, references = references, summary = summary,
  elapsed = elapsed, source_hash = tools::md5sum(source_file),
  script_hash = tools::md5sum("inst/validation/gmfrm-fixed-integration-20260930.R")),
  file.path(out, "audit.rds"))
write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(summary, row.names = FALSE, digits = 10)
cat("Elapsed:", elapsed, "seconds; fixed estimates retained.\n")
