# Reuse the retained data and fits; no new simulation or domain-specific API.
# Completed fits are loaded, not overwritten. The initial execution scripts
# and their hashes are retained beside the fit objects.
pkgload::load_all(".", quiet = TRUE)
source_file <- "validation-results/gmfrm-practitioner-20260930/quadrature-review.rds"
out <- "validation-results/gmfrm-adaptive-calibration-20260930"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
if (file.exists(file.path(out, "audit.rds"))) stop("Retain the completed calibration audit.")
original <- readRDS(source_file)$value$fits
refits <- list()
for (name in names(original)) {
  file <- file.path(out, paste0(name, "-adaptive31.rds"))
  if (!file.exists(file)) {
    fit <- original[[name]]
    problem <- do.call(mfrm_gmfrm_problem, fit$gmfrm$specification)
    setup <- problem$common
    setup$config$estimation_control <- list(mml_integration = "adaptive", mml_engine_requested = "direct")
    elapsed <- system.time(opt <- run_mfrm_direct_optimization(fit$opt$par, "MML",
      setup$idx, setup$config, setup$sizes, 31L, 500L, 1e-10, optimizer = "BFGS"))[["elapsed"]]
    saveRDS(list(opt = opt, elapsed = elapsed, specification = problem$specification,
      config = setup$config, source_hash = tools::md5sum(source_file)), file)
  }
  refits[[name]] <- readRDS(file)
}
file <- file.path(out, "public-adaptive61.rds")
if (!file.exists(file)) {
  args <- original$q61$config$replay_inputs
  args$package_version <- args$em_score_tol <- NULL
  args$data <- original$q61$gmfrm$specification$data
  args$mml_engine <- "direct"; args$mml_integration <- "adaptive"
  args$quad_points <- 61L; args$reltol <- 1e-10; args$optimizer <- "BFGS"
  elapsed <- system.time(fit <- do.call(fit_mfrm, args))[["elapsed"]]
  saveRDS(list(fit = fit, arguments = args, elapsed = elapsed), file)
}
public <- readRDS(file)
refits$neutral <- list(opt = public$fit$opt, specification = public$fit$gmfrm$specification,
  config = public$fit$config, elapsed = public$elapsed)

# Literal response equation, continuous integration and no package probability
# kernel or quadrature rule. The posterior mode/width only change coordinates.
continuous <- function(problem, par, review) {
  spec <- problem$specification; d <- spec$data; owners <- spec$slope_facets
  u <- problem$unpack(par)
  vapply(seq_len(nrow(review)), function(i) {
    rows <- which(as.character(d[[spec$person]]) == review$Person[i])
    first <- as.character(d[[owners[1]]][rows]); second <- as.character(d[[owners[2]]][rows])
    slope <- u$slopes[[1]][first] * u$slopes[[2]][second]
    location <- u$locations[[1]][first] + u$locations[[2]][second]
    steps <- t(vapply(second, function(r) c(0, cumsum(u$steps[r, ])), numeric(spec$max_score + 1L)))
    log_joint <- function(theta) {
      logits <- (outer(theta - location, 0:spec$max_score) - steps) * slope
      high <- apply(logits, 1, max)
      sum(logits[cbind(seq_along(rows), d[[spec$score]][rows] + 1L)] - high -
        log(rowSums(exp(logits - high)))) + dnorm(theta, log = TRUE)
    }
    mode <- review$PosteriorMode[i]; scale <- review$LocalPosteriorSD[i]
    height <- log_joint(mode)
    integral <- integrate(function(z) vapply(z, function(x)
      exp(log_joint(mode + scale * x) - height) * scale, 0), -Inf, Inf,
      rel.tol = 1e-10, abs.tol = 1e-12, subdivisions = 1000L)
    stopifnot(identical(integral$message, "OK"))
    height + log(integral$value)
  }, 0)
}
audits <- summaries <- list()
for (name in names(refits)) {
  x <- refits[[name]]
  problem <- do.call(mfrm_gmfrm_problem, x$specification); setup <- problem$common
  review <- mfrmr_adaptive_quadrature_review(setup$idx, setup$config,
    expand_params(x$opt$par, setup$sizes, setup$config), gauss_hermite_normal(31L),
    setup$prep$levels$Person, c(31L, 61L, 121L))
  stopifnot(all(review$Status == "computed"))
  continuous_log <- continuous(problem, x$opt$par, review[review$AdaptiveNodes == 121L, ])
  values <- lapply(c(31L, 61L, 121L), function(q)
    mfrmr_make_adaptive_mml_evaluator(setup$idx, setup$config, setup$sizes, q)(x$opt$par))
  summaries[[name]] <- data.frame(Start = name, FittedNodes = if (name == "neutral") 61L else 31L,
    FittedNLL = x$opt$value, ContinuousNLL = -sum(continuous_log),
    MaxLogError31 = max(abs(review$AdaptiveLogMarginal[review$AdaptiveNodes == 31L] - continuous_log)),
    MaxLogError61 = max(abs(review$AdaptiveLogMarginal[review$AdaptiveNodes == 61L] - continuous_log)),
    MaxLogError121 = max(abs(review$AdaptiveLogMarginal[review$AdaptiveNodes == 121L] - continuous_log)),
    MeanScore121 = max(abs(values[[3]]$gradient)) / problem$n_person,
    MaxScoreDifference61To121 = max(abs(values[[3]]$gradient - values[[2]]$gradient)),
    MaxParameterDifferenceFromNeutral = max(abs(x$opt$par - public$fit$opt$par)),
    Elapsed = x$elapsed)
  audits[[name]] <- list(review = review, continuous_log = continuous_log, evaluations = values)
}
# Local curvature of the accurate objective is a numerical check, not a
# boundary certificate or proof of global identification/coverage.
setup <- do.call(mfrm_gmfrm_problem, public$fit$gmfrm$specification)$common
evaluate <- mfrmr_make_adaptive_mml_evaluator(setup$idx, setup$config, setup$sizes, 61L)
hessian <- optimHess(public$fit$opt$par, function(x) evaluate(x)$value,
  function(x) evaluate(x)$gradient)
eigenvalues <- eigen(hessian, symmetric = TRUE, only.values = TRUE)$values
score <- evaluate(public$fit$opt$par)$gradient
newton_displacement <- if (min(eigenvalues) > 0)
  sqrt(drop(crossprod(score, solve(hessian, score)))) else NA_real_
summary <- do.call(rbind, summaries)
saveRDS(list(summary = summary, audits = audits, hessian = hessian,
  eigenvalues = eigenvalues, newton_displacement = newton_displacement,
  input_hashes = tools::md5sum(c(source_file, file.path(out,
    c("q61-adaptive31.rds", "q121-adaptive31.rds", "public-adaptive61.rds")))),
  script_hash = tools::md5sum("inst/validation/gmfrm-adaptive-calibration-20260930.R")),
  file.path(out, "audit.rds"))
write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
print(summary, row.names = FALSE, digits = 10)
cat("Curvature range:", range(eigenvalues), "; Newton displacement:", newton_displacement, "\n")
