# Reconcile a saved joint-model example; never resample or drop failed fits.
# Rscript inst/validation/response-mi-joint-0.2.4.R <output directory>
args <- commandArgs(TRUE)
directory <- if (length(args)) args[1] else "validation-results/response-mi-joint-20260923"
.libPaths(c(normalizePath(".r-library"), .libPaths()))
pkgload::load_all(".", quiet = TRUE)
example <- readRDS(file.path(directory, "sampling", "completions.rds"))
posterior_fit <- readRDS(file.path(directory, "sampling", "posterior.rds"))
spec <- example$imputation_model
draws <- as.matrix(posterior_fit$draws(format = "draws_matrix"))
take <- function(row, name, n) as.numeric(draws[row, paste0(name, "[", seq_len(n), "]")])
checks <- list()
check <- function(name, error, tolerance = 1e-9) {
  error <- as.numeric(error)
  checks[[length(checks) + 1L]] <<- data.frame(Check = name, Error = error,
    Tolerance = tolerance, Pass = is.finite(error) && error <= tolerance)
}
for (row in spec$draw_ids$.draw) {
  theta <- take(row, "theta", spec$data$P)
  r <- take(row, "severity", spec$data$R)
  c <- take(row, "difficulty", spec$data$C)
  s <- take(row, "step", spec$data$K - 1L)
  d <- spec$data
  eta <- theta[d$person_obs] - r[d$rater_obs] - c[d$criterion_obs]
  ll <- mfrmr:::loglik_rsm(eta, d$y_obs - 1L, c(0, cumsum(s)))
  check(paste0("conditional_log_likelihood_", row), abs(ll - draws[row, "log_likelihood"]))
  eta <- theta[d$person_mis] - r[d$rater_mis] - c[d$criterion_mis]
  prob <- mfrmr:::category_prob_rsm(eta, c(0, cumsum(s)))
  actual <- vapply(seq_len(d$K), function(k) as.numeric(draws[row,
    sprintf("probability_mis[%d,%d]", seq_len(d$N_mis), k)]), numeric(d$N_mis))
  check(paste0("predictive_probabilities_", row), max(abs(prob - actual)))
  check(paste0("sum_constraints_", row), max(abs(c(sum(r), sum(c), sum(s)))))
}
completed <- lapply(seq_len(ncol(example$scores)), function(i) {
  d <- example$ratings; d$Score[example$missing] <- example$scores[, i]; d
})
review <- mfrm_response_imputations(example$ratings, completed, "Person", c("Rater", "Criterion"),
  "Score", "Event", example$ratings$Event[example$missing], categories = 1:4,
  assigned = "Assigned", imputation_model = spec)
check("original_scores_preserved", max(vapply(completed, function(d)
  max(abs(d$Score - example$ratings$Score), na.rm = TRUE), numeric(1))))
check("unassigned_remain_missing", sum(vapply(completed,
  function(d) sum(!is.na(d$Score[example$unassigned])), integer(1))))
check("multiple_missing_responses_of_same_person", as.numeric(!any(table(
  example$ratings$Person[example$missing]) > 1L)), 0)
for (n in c("Q_rater", "Q_criterion", "Q_step")) {
  q <- spec$data[[n]]
  check(paste0(n, "_exchangeable_prior"), max(abs(tcrossprod(q) -
    (diag(nrow(q)) - 1 / nrow(q)))))
}
check("held_out_excluded", as.numeric(length(spec$data$y_obs) != sum(!is.na(example$ratings$Score))), 0)
contrast <- matrix(c(-1, 0, 0, 1), 1,
  dimnames = list("R04 minus R01", c("R01", "R02", "R03", "R04")))
fit_once <- function(path, expression) {
  path <- file.path(directory, path)
  if (file.exists(path)) return(readRDS(path))
  result <- force(expression)
  saveRDS(result, path)
  result
}
analyses <- fit_once("analyses.rds", fit_mfrm_imputed(review, model = "RSM", quad_points = 61))
pooled <- fit_once("pooled.rds", pool_mfrm_imputed(analyses, "Rater", contrasts = contrast))
# The full roster is retained above. NA-score input produces an input-review
# state; explicitly select the reviewed observed events, without changing a
# fitted object's readiness or dropping any observed evidence.
observed <- lapply(c(61L, 121L), function(q) fit_once(paste0("observed-selected-q", q, ".rds"),
  fit_mfrm(subset(example$ratings, Assigned & !is.na(Score)), "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", method = "MML", rating_min = 1, rating_max = 4,
    quad_points = q, keep_original = TRUE, attach_diagnostics = FALSE)))
intervals <- lapply(observed, mfrm_facet_intervals, facet = "Rater", contrasts = contrast)
for (j in seq_along(observed)) {
  old_path <- file.path(directory, paste0("observed-q", c(61L, 121L)[j], ".rds"))
  if (file.exists(old_path)) {
    old <- readRDS(old_path)
    check(paste0("explicit_observed_selection_same_estimates_q", c(61L, 121L)[j]),
      max(abs(old$opt$par - observed[[j]]$opt$par)))
  }
}
obs <- lapply(intervals, summary)
check("observed_grid_estimate", abs(obs[[1]]$Estimate - obs[[2]]$Estimate), 1e-4)
check("observed_grid_se", abs(obs[[1]]$SE - obs[[2]]$SE), 1e-4)
lower_scores <- lapply(completed, function(d) {
  d$Score[example$missing] <- pmax(1L, d$Score[example$missing] - 1L); d
})
lower_review <- mfrm_response_imputations(example$ratings, lower_scores, "Person",
  c("Rater", "Criterion"), "Score", "Event", example$ratings$Event[example$missing],
  categories = 1:4, assigned = "Assigned", imputation_model = list(baseline = spec,
    assumption = "Missing scores one category lower, floored at 1"))
lower_analyses <- fit_once("lower-analyses.rds", fit_mfrm_imputed(lower_review,
  model = "RSM", quad_points = 61))
lower_pooled <- fit_once("lower-pooled.rds", pool_mfrm_imputed(lower_analyses, "Rater", contrasts = contrast))
bayes <- draws[, "severity[4]"] - draws[, "severity[1]"]
comparison <- rbind(
  data.frame(Method = "Observed-score MML", obs[[2]][c("Estimate", "SE", "Lower", "Upper")]),
  data.frame(Method = "Observed-score Bayes", Estimate = mean(bayes), SE = sd(bayes),
    Lower = unname(quantile(bayes, .025)), Upper = unname(quantile(bayes, .975))),
  data.frame(Method = "Joint-model MI", summary(pooled)[c("Estimate", "SE", "Lower", "Upper")]),
  data.frame(Method = "Missing scores one category lower",
    summary(lower_pooled)[c("Estimate", "SE", "Lower", "Upper")]))
prob <- example$probability_mean
prediction <- data.frame(Event = example$ratings$Event[example$missing],
  HeldOutScore = example$held_out, PredictedMean = drop(prob %*% (1:4)),
  Brier = rowSums((prob - outer(example$held_out, 1:4, "=="))^2))
paired <- drop(lower_pooled$estimates - pooled$estimates)
result <- list(comparison = comparison, prediction = prediction, pooled = pooled,
  lower_pooled = lower_pooled, intervals = intervals,
  paired = c(Change = mean(paired), MonteCarloSE = sd(paired) / sqrt(length(paired))),
  checks = do.call(rbind, checks), sources = tools::md5sum(c(
    "inst/examples/response-imputation.R", "inst/examples/response-imputation.stan",
    "inst/validation/response-mi-joint-0.2.4.md", "inst/validation/response-mi-joint-0.2.4.R",
    "R/api-response-imputation.R", "R/api-imputed-estimation.R", "R/mfrm_core.R")))
saveRDS(result, file.path(directory, "results.rds"))
stopifnot(identical(readRDS(file.path(directory, "results.rds")), result))
write.csv(comparison, file.path(directory, "comparison.csv"), row.names = FALSE)
write.csv(prediction, file.path(directory, "prediction.csv"), row.names = FALSE)
write.csv(result$checks, file.path(directory, "checks.csv"), row.names = FALSE)
print(comparison); print(result$paired); print(summary(pooled))
print(c(Missing = length(example$missing), HeldOutMean = mean(example$held_out),
  PredictedMean = mean(prediction$PredictedMean), Brier = mean(prediction$Brier)))
stopifnot(all(result$checks$Pass))
