# Bounded-GPCM score-side design verification (0.2.2 program)
#
# Companion to gpcm-score-side-estimand-0.2.2.md. Two parts:
#
#   Part A: exact identity checks for the design-document mathematics,
#           using a script-local adjacent-category kernel implemented
#           independently of the package internals, anchored once against
#           a fitted package object.
#   Part B: Monte Carlo verification of the score-side uncertainty design:
#           empirical CI coverage of the legacy (|a| * eta_se) versus the
#           corrected (a * Var * eta_se) score-scale SE, the SE-ratio
#           prediction (1 / Var), and the raw-score non-sufficiency
#           tendency across slope regimes.
#
# Run from the package root:
#   Rscript inst/validation/gpcm-score-side-simulation-0.2.2.R [reps] [out_dir]
# By default, generated CSVs are written under validation-results/ so short
# smoke runs do not look like curated release evidence. For a release-evidence
# run, use adequate reps and pass inst/validation explicitly.
# Results: gpcm-score-side-sim-results-0.2.2.csv (per replication) and
#          gpcm-score-side-sim-summary-0.2.2.csv (per condition).

suppressMessages(pkgload::load_all(".", quiet = TRUE))

args <- commandArgs(trailingOnly = TRUE)
REPS <- if (length(args) >= 1) as.integer(args[1]) else 200L
OUT_DIR <- if (length(args) >= 2 && nzchar(args[2])) {
  args[2]
} else {
  file.path("validation-results", "gpcm-score-side-0.2.2")
}
Z <- stats::qnorm(0.975)

# ---------------------------------------------------------------------------
# Script-local adjacent-category kernel (independent reimplementation)
# ---------------------------------------------------------------------------
# Categories k = 0..K-1 carry scores rating_min + k. With slope a, linear
# predictor eta, and step thresholds tau (length K-1, cumulative form
# cum = c(0, cumsum(tau))):  log P(k) = a * (k * eta - cum_k) + const.
local_probs <- function(eta, a, tau) {
  cum <- c(0, cumsum(tau))
  k <- seq_along(cum) - 1
  log_num <- a * (k * eta - cum)
  log_num <- log_num - max(log_num)
  p <- exp(log_num)
  p / sum(p)
}
local_expected <- function(eta, a, tau, rating_min = 1) {
  p <- local_probs(eta, a, tau)
  k <- seq_along(p) - 1
  rating_min + sum(k * p)
}
local_var <- function(eta, a, tau) {
  p <- local_probs(eta, a, tau)
  k <- seq_along(p) - 1
  m <- sum(k * p)
  sum((k - m)^2 * p)
}

cat("== Part A: exact identity checks ==\n")

# A1. Anchor against the package: a small bounded-GPCM fit must reproduce
#     the script-local Expected and Var at the fitted parameters.
toy_spec <- build_mfrm_sim_spec(
  n_person = 30, n_rater = 3, n_criterion = 3,
  model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion",
  slopes = data.frame(SlopeFacet = c("C01", "C02", "C03"),
                      Estimate = c(0.7, 1.0, 1.43)),
  assignment = "crossed", score_levels = 4
)
toy <- simulate_mfrm_data(sim_spec = toy_spec, seed = 11)
toy_fit <- suppressWarnings(fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion",
  method = "MML", quad_points = 15
))
toy_diag <- diagnose_mfrm(toy_fit, residual_pca = "none")
obs <- as.data.frame(toy_diag$obs)
person_est <- setNames(toy_fit$facets$person$Estimate, toy_fit$facets$person$Person)
others <- as.data.frame(toy_fit$facets$others)
fac_est <- setNames(others$Estimate, paste(others$Facet, others$Level))
steps <- as.data.frame(toy_fit$steps)
slope_tbl <- as.data.frame(toy_fit$slopes)
slope_est <- setNames(slope_tbl$Estimate, slope_tbl$SlopeFacet)
tau_of <- function(criterion) steps$Estimate[steps$StepFacet == criterion]
rmin <- toy_fit$prep$rating_min

dev_e <- dev_v <- 0
for (i in seq_len(nrow(obs))) {
  eta_i <- person_est[[as.character(obs$Person[i])]] -
    fac_est[[paste("Rater", obs$Rater[i])]] -
    fac_est[[paste("Criterion", obs$Criterion[i])]]
  a_i <- slope_est[[as.character(obs$Criterion[i])]]
  tau_i <- tau_of(as.character(obs$Criterion[i]))
  dev_e <- max(dev_e, abs(local_expected(eta_i, a_i, tau_i, rmin) - obs$Expected[i]))
  dev_v <- max(dev_v, abs(local_var(eta_i, a_i, tau_i) - obs$Var[i]))
}
cat(sprintf("A1 package anchor: max|Expected dev| = %.2e, max|Var dev| = %.2e\n",
            dev_e, dev_v))
stopifnot(dev_e < 1e-6, dev_v < 1e-6)

# A2. Derivative identity dE/deta = a * Var (design document, section 3).
grid <- seq(-3, 3, by = 0.25)
h <- 1e-5
dev_d <- 0
for (a in c(0.5, 1, 1.7)) {
  for (eta in grid) {
    num <- (local_expected(eta + h, a, c(-1.1, 0.2, 0.9)) -
              local_expected(eta - h, a, c(-1.1, 0.2, 0.9))) / (2 * h)
    ana <- a * local_var(eta, a, c(-1.1, 0.2, 0.9))
    dev_d <- max(dev_d, abs(num - ana))
  }
}
cat(sprintf("A2 dE/deta = a*Var: max deviation = %.2e\n", dev_d))
stopifnot(dev_d < 1e-6)

# A3. Identification invariance: (a*c, eta/c, tau/c) leaves P, E, Var fixed.
dev_i <- 0
for (c_scale in c(0.5, 2)) {
  for (eta in grid) {
    p1 <- local_probs(eta, 1.3, c(-1.1, 0.2, 0.9))
    p2 <- local_probs(eta / c_scale, 1.3 * c_scale, c(-1.1, 0.2, 0.9) / c_scale)
    dev_i <- max(dev_i, max(abs(p1 - p2)))
  }
}
cat(sprintf("A3 rescaling invariance: max deviation = %.2e\n", dev_i))
stopifnot(dev_i < 1e-10)

# A4. Unit-slope reduction: the GPCM kernel at a = 1 is the PCM kernel.
pcm_probs <- function(eta, tau) {
  cum <- c(0, cumsum(tau))
  k <- seq_along(cum) - 1
  log_num <- k * eta - cum
  log_num <- log_num - max(log_num)
  p <- exp(log_num)
  p / sum(p)
}
dev_r <- max(vapply(grid, function(eta) {
  max(abs(local_probs(eta, 1, c(-1.1, 0.2, 0.9)) - pcm_probs(eta, c(-1.1, 0.2, 0.9))))
}, numeric(1)))
cat(sprintf("A4 unit-slope == PCM kernel: max deviation = %.2e\n", dev_r))
stopifnot(dev_r < 1e-12)
identity_checks <- data.frame(
  Check = c(
    "package_expected_anchor",
    "package_variance_anchor",
    "expected_score_derivative",
    "rescaling_invariance",
    "unit_slope_pcm_reduction"
  ),
  MaxDeviation = c(dev_e, dev_v, dev_d, dev_i, dev_r),
  Tolerance = c(1e-6, 1e-6, 1e-6, 1e-10, 1e-12),
  Passed = c(
    dev_e < 1e-6,
    dev_v < 1e-6,
    dev_d < 1e-6,
    dev_i < 1e-10,
    dev_r < 1e-12
  ),
  stringsAsFactors = FALSE
)
cat("Part A passed.\n\n")

# ---------------------------------------------------------------------------
# Part B: Monte Carlo
# ---------------------------------------------------------------------------
gm1 <- function(x) x / exp(mean(log(x)))
REGIMES <- list(
  unit = rep(1, 4),
  mild = gm1(c(0.80, 0.95, 1.10, 1.25)),
  strong = gm1(c(0.50, 0.80, 1.25, 2.00))
)
NS <- c(50L, 150L)
CRITERIA <- paste0("C0", 1:4)

run_rep <- function(regime_name, n_person, rep_id) {
  seed <- 7e5 + match(regime_name, names(REGIMES)) * 1e5 +
    match(n_person, NS) * 1e4 + rep_id
  slopes_true <- REGIMES[[regime_name]]
  spec <- build_mfrm_sim_spec(
    n_person = n_person, n_rater = 4, n_criterion = 4,
    model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion",
    slopes = data.frame(SlopeFacet = CRITERIA, Estimate = slopes_true),
    assignment = "crossed", score_levels = 4
  )
  sim <- simulate_mfrm_data(sim_spec = spec, seed = seed)
  truth <- attr(sim, "mfrm_truth")
  th_person <- truth$person
  th_rater <- truth$facets$Rater
  th_crit <- truth$facets$Criterion
  tau_true <- truth$steps
  a_true <- setNames(truth$slope_table$Estimate, truth$slope_table$SlopeFacet)

  fit <- suppressWarnings(fit_mfrm(
    sim, "Person", c("Rater", "Criterion"), "Score",
    model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion",
    method = "MML", quad_points = 15
  ))
  diag <- diagnose_mfrm(fit, residual_pca = "none")
  obs <- as.data.frame(diag$obs)
  meas <- as.data.frame(diag$measures)
  se_of <- function(facet, level) {
    v <- meas$ModelSE[meas$Facet == facet & meas$Level == level]
    if (length(v) == 0) NA_real_ else v[1]
  }
  person_est <- setNames(fit$facets$person$Estimate, fit$facets$person$Person)
  others <- as.data.frame(fit$facets$others)
  fac_est <- setNames(others$Estimate, paste(others$Facet, others$Level))
  steps <- as.data.frame(fit$steps)
  slope_tbl <- as.data.frame(fit$slopes)
  a_hat <- setNames(slope_tbl$Estimate, slope_tbl$SlopeFacet)
  tau_hat_of <- function(criterion) steps$Estimate[steps$StepFacet == criterion]
  rmin <- fit$prep$rating_min

  person_se <- vapply(as.character(obs$Person), function(p) se_of("Person", p), numeric(1))
  rater_se <- vapply(as.character(obs$Rater), function(r) se_of("Rater", r), numeric(1))
  crit_se <- vapply(as.character(obs$Criterion), function(cr) se_of("Criterion", cr), numeric(1))
  eta_se <- sqrt(person_se^2 + rater_se^2 + crit_se^2)

  n_obs <- nrow(obs)
  e_hat <- v_hat <- e_true <- a_obs <- th_true_obs <- numeric(n_obs)
  for (i in seq_len(n_obs)) {
    pid <- as.character(obs$Person[i])
    rid <- as.character(obs$Rater[i])
    cid <- as.character(obs$Criterion[i])
    eta_h <- person_est[[pid]] - fac_est[[paste("Rater", rid)]] -
      fac_est[[paste("Criterion", cid)]]
    a_h <- a_hat[[cid]]
    e_hat[i] <- local_expected(eta_h, a_h, tau_hat_of(cid), rmin)
    v_hat[i] <- local_var(eta_h, a_h, tau_hat_of(cid))
    a_obs[i] <- a_h
    eta_t <- th_person[[pid]] - th_rater[[rid]] - th_crit[[cid]]
    e_true[i] <- local_expected(eta_t, a_true[[cid]], tau_true, rmin)
    th_true_obs[i] <- th_person[[pid]]
  }

  se_legacy <- a_obs * eta_se
  se_cor <- a_obs * v_hat * eta_se
  err <- abs(e_hat - e_true)
  band <- cut(abs(th_true_obs), c(-Inf, 0.7, 1.4, Inf),
              labels = c("central", "mid", "tail"))

  cover_row <- function(sel, label) {
    data.frame(
      regime = regime_name, n_person = n_person, rep = rep_id, band = label,
      n_obs = sum(sel),
      coverage_legacy = mean(err[sel] <= Z * se_legacy[sel], na.rm = TRUE),
      coverage_corrected = mean(err[sel] <= Z * se_cor[sel], na.rm = TRUE),
      se_ratio_mean = mean((se_legacy / se_cor)[sel], na.rm = TRUE),
      inv_var_mean = mean(1 / v_hat[sel], na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  }
  out <- rbind(
    cover_row(rep(TRUE, n_obs), "all"),
    cover_row(band == "central", "central"),
    cover_row(band == "mid", "mid"),
    cover_row(band == "tail", "tail")
  )

  # Raw-score non-sufficiency: spread of EAP measures within raw-score groups
  # versus the slope-weighted-score grouping.
  raw_t <- tapply(obs$Observed, obs$Person, sum)
  wgt_t <- tapply(obs$Observed * a_obs, obs$Person, sum)
  eap <- as.numeric(person_est[names(raw_t)])
  raw <- as.numeric(raw_t)
  wgt <- as.numeric(wgt_t)
  # Pooled conditional spread of EAP measures: residual SD after
  # conditioning on the raw score (as a factor) versus on a smooth
  # function of the slope-weighted score. Under raw-score sufficiency the
  # two are equal; under GPCM the raw-score residual SD stays positive
  # while the weighted-score residual SD approaches zero.
  fit_raw <- stats::lm(eap ~ factor(round(raw, 6)))
  poly_df <- max(1L, min(3L, length(unique(wgt)) - 1L))
  fit_wgt <- stats::lm(eap ~ stats::poly(wgt, poly_df))
  out$within_raw_sd <- stats::sd(stats::resid(fit_raw))
  out$within_weighted_sd <- stats::sd(stats::resid(fit_wgt))
  out$cor_eap_raw <- stats::cor(eap, raw, use = "complete.obs")
  out$cor_eap_weighted <- stats::cor(eap, wgt, use = "complete.obs")
  out$converged <- isTRUE(fit$summary$Converged[1]) ||
    identical(as.character(fit$summary$Convergence[1] %||% ""), "converged")
  out
}

conditions <- expand.grid(regime = names(REGIMES), n_person = NS,
                          stringsAsFactors = FALSE)
cat(sprintf("== Part B: %d conditions x %d reps ==\n", nrow(conditions), REPS))

run_condition <- function(ci) {
  cond <- conditions[ci, ]
  reps <- lapply(seq_len(REPS), function(r) {
    tryCatch(run_rep(cond$regime, cond$n_person, r),
             error = function(e) {
               data.frame(regime = cond$regime, n_person = cond$n_person,
                          rep = r, band = "error", n_obs = NA_integer_,
                          coverage_legacy = NA_real_, coverage_corrected = NA_real_,
                          se_ratio_mean = NA_real_, inv_var_mean = NA_real_,
                          within_raw_sd = NA_real_, within_weighted_sd = NA_real_,
                          cor_eap_raw = NA_real_, cor_eap_weighted = NA_real_,
                          converged = FALSE, stringsAsFactors = FALSE)
             })
  })
  do.call(rbind, reps)
}

has_future <- requireNamespace("future.apply", quietly = TRUE)
if (has_future) {
  future::plan(future::multisession, workers = max(2L, parallel::detectCores() - 2L))
  results <- future.apply::future_lapply(
    seq_len(nrow(conditions)), run_condition, future.seed = TRUE
  )
  future::plan(future::sequential)
} else {
  results <- lapply(seq_len(nrow(conditions)), run_condition)
}
res <- do.call(rbind, results)

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(res, file.path(OUT_DIR, "gpcm-score-side-sim-results-0.2.2.csv"),
                 row.names = FALSE)

agg <- do.call(rbind, lapply(split(res[res$band != "error", ],
                                   interaction(res$regime[res$band != "error"],
                                               res$n_person[res$band != "error"],
                                               res$band[res$band != "error"],
                                               drop = TRUE)), function(d) {
  data.frame(
    regime = d$regime[1], n_person = d$n_person[1], band = d$band[1],
    reps = nrow(d),
    coverage_legacy = mean(d$coverage_legacy, na.rm = TRUE),
    coverage_corrected = mean(d$coverage_corrected, na.rm = TRUE),
    se_ratio_mean = mean(d$se_ratio_mean, na.rm = TRUE),
    inv_var_mean = mean(d$inv_var_mean, na.rm = TRUE),
    within_raw_sd = mean(d$within_raw_sd, na.rm = TRUE),
    within_weighted_sd = mean(d$within_weighted_sd, na.rm = TRUE),
    cor_eap_raw = mean(d$cor_eap_raw, na.rm = TRUE),
    cor_eap_weighted = mean(d$cor_eap_weighted, na.rm = TRUE),
    converged_rate = mean(d$converged, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}))
utils::write.csv(agg, file.path(OUT_DIR, "gpcm-score-side-sim-summary-0.2.2.csv"),
                 row.names = FALSE)
err_n <- sum(res$band == "error")
all_rows <- agg[agg$band == "all", , drop = FALSE]
max_se_ratio_diff <- max(abs(agg$se_ratio_mean - agg$inv_var_mean), na.rm = TRUE)
if (!is.finite(max_se_ratio_diff)) {
  max_se_ratio_diff <- NA_real_
}
min_converged_rate <- min(all_rows$converged_rate, na.rm = TRUE)
if (!is.finite(min_converged_rate)) {
  min_converged_rate <- NA_real_
}
expected_summary_rows <- length(REGIMES) * length(NS) * 4L
summary_rows_ok <- nrow(agg) >= expected_summary_rows
failed_checks <- sum(!identity_checks$Passed) +
  as.integer(err_n > 0L) +
  as.integer(!summary_rows_ok) +
  as.integer(!is.finite(max_se_ratio_diff) || max_se_ratio_diff > 1e-10) +
  as.integer(!is.finite(min_converged_rate) || min_converged_rate < 0.95)
simulation_status <- if (identical(failed_checks, 0L)) "ok" else "concern"
simulation_checks <- rbind(
  data.frame(
    Check = identity_checks$Check,
    Value = identity_checks$MaxDeviation,
    Threshold = identity_checks$Tolerance,
    Passed = identity_checks$Passed,
    stringsAsFactors = FALSE
  ),
  data.frame(
    Check = c(
      "errored_replications",
      "summary_rows",
      "se_ratio_identity",
      "minimum_convergence_rate"
    ),
    Value = c(err_n, nrow(agg), max_se_ratio_diff, min_converged_rate),
    Threshold = c(0, expected_summary_rows, 1e-10, 0.95),
    Passed = c(
      err_n == 0L,
      summary_rows_ok,
      is.finite(max_se_ratio_diff) && max_se_ratio_diff <= 1e-10,
      is.finite(min_converged_rate) && min_converged_rate >= 0.95
    ),
    stringsAsFactors = FALSE
  )
)
utils::write.csv(
  simulation_checks,
  file.path(OUT_DIR, "gpcm-score-side-sim-checks-0.2.2.csv"),
  row.names = FALSE
)

format_md_table <- function(x) {
  out <- utils::capture.output(print(x, row.names = FALSE, digits = 4))
  c("```", out, "```")
}
summary_all <- all_rows[, c(
  "regime", "n_person", "reps", "coverage_legacy", "coverage_corrected",
  "se_ratio_mean", "inv_var_mean", "within_raw_sd", "within_weighted_sd",
  "converged_rate"
), drop = FALSE]
md <- c(
  "# Bounded-GPCM score-side simulation evidence (0.2.2)",
  "",
  "This is a seeded smoke validation summary for the bounded-GPCM score-side",
  "estimand and uncertainty route. It checks the independent adjacent-category",
  "identities used by `gpcm-score-side-estimand-0.2.2.md` and records a compact",
  "Monte Carlo comparison of the legacy slope-scaled logit SE against the",
  "corrected score-scale delta SE. It is not calibrated power, Type-I-error,",
  "posterior-predictive, or operational score-scale evidence.",
  "",
  sprintf("- `GPCMScoreSideSimulationStatus = \"%s\"`;", simulation_status),
  sprintf("- `Replications = %d` per condition;", REPS),
  sprintf("- `Regimes = %s`;", paste(names(REGIMES), collapse = ", ")),
  sprintf("- `NPerson = %s`;", paste(NS, collapse = ", ")),
  sprintf("- `Conditions = %d`;", nrow(conditions)),
  sprintf("- `SummaryRows = %d`;", nrow(agg)),
  sprintf("- `ErroredReplications = %d`;", err_n),
  sprintf("- `MaxSERatioDiff = %.3e`;", max_se_ratio_diff),
  sprintf("- `MinConvergedRate = %.3f`;", min_converged_rate),
  sprintf("- `FailedChecks = %d`.", failed_checks),
  "",
  "## Interpretation boundary",
  "",
  "The release gate uses this artifact to verify formula-level consistency,",
  "score-side SE scale alignment, explicit bounded-GPCM caveat evidence, and",
  "error-free seeded execution. Coverage rows are retained for reviewer",
  "inspection only; they should not be reported as operating-characteristic",
  "evidence without a larger ADEMP-style simulation.",
  "",
  "## Identity and gate checks",
  "",
  format_md_table(simulation_checks),
  "",
  "## All-condition summary",
  "",
  format_md_table(summary_all),
  "",
  "## Files",
  "",
  "- `gpcm-score-side-sim-results-0.2.2.csv`",
  "- `gpcm-score-side-sim-summary-0.2.2.csv`",
  "- `gpcm-score-side-sim-checks-0.2.2.csv`"
)
writeLines(md, file.path(OUT_DIR, "gpcm-score-side-simulation-0.2.2.md"),
           useBytes = TRUE)
cat(sprintf("wrote: %s\n", normalizePath(OUT_DIR, winslash = "/", mustWork = FALSE)))
cat(sprintf("done: %d result rows, %d errored reps, status=%s, failed_checks=%d\n",
            nrow(res), err_n, simulation_status, failed_checks))
print(agg[agg$band == "all", c("regime", "n_person", "coverage_legacy",
                               "coverage_corrected", "se_ratio_mean",
                               "within_raw_sd", "within_weighted_sd")],
      digits = 3)
