# Bounded-GPCM score-side external kernel comparison (0.2.2)
#
# This is a narrow external comparison harness. It does not claim many-facet
# equivalence to mirt, TAM, eRm, FACETS, or Winsteps, and it does not treat
# mirt, TAM, or eRm as many-facet MFRM comparators. It checks whether the
# adjacent-category GPCM probability kernel behind the mfrmr bounded-GPCM
# score-side contract reproduces external GPCM probability traces after each
# external package's documented parameterization is mapped onto
#   log(P_k / P_{k-1}) = a * (theta - tau_k).
#
# Run from the package root:
#   Rscript inst/validation/gpcm-score-side-external-comparison-0.2.2.R [out_dir]
# By default, generated files are written under validation-results/.

args <- commandArgs(trailingOnly = TRUE)
OUT_DIR <- if (length(args) >= 1L && nzchar(args[1])) {
  args[1]
} else {
  file.path("validation-results", "gpcm-score-side-external-comparison-0.2.2")
}

local_probs <- function(theta, a, tau) {
  cum <- c(0, cumsum(tau))
  k <- seq_along(cum) - 1
  z <- a * (k * theta - cum)
  z <- z - max(z)
  p <- exp(z)
  p / sum(p)
}

local_trace <- function(theta, a, tau) {
  t(vapply(theta, local_probs, numeric(length(tau) + 1L), a = a, tau = tau))
}

score_moments <- function(p) {
  scores <- seq_len(ncol(p)) - 1
  expected <- as.numeric(p %*% scores)
  centered <- sweep(
    matrix(scores, nrow = nrow(p), ncol = ncol(p), byrow = TRUE),
    1,
    expected,
    "-"
  )
  variance <- rowSums(p * centered^2)
  list(expected = expected, variance = variance)
}

derivative_check <- function(theta, a, tau) {
  h <- 1e-5
  p <- local_trace(theta, a, tau)
  mom <- score_moments(p)
  e_plus <- score_moments(local_trace(theta + h, a, tau))$expected
  e_minus <- score_moments(local_trace(theta - h, a, tau))$expected
  numeric_derivative <- (e_plus - e_minus) / (2 * h)
  max(abs(numeric_derivative - a * mom$variance))
}

make_fixture <- function(n = 600L, seed = 202622L) {
  set.seed(seed)
  item_pars <- data.frame(
    Item = paste0("I", 1:4),
    Alpha = c(0.70, 0.95, 1.25, 1.55),
    Step1 = c(-1.25, -0.70, -0.35, -1.10),
    Step2 = c(-0.10,  0.15,  0.25,  0.05),
    Step3 = c( 0.90,  1.05,  1.20,  0.85),
    stringsAsFactors = FALSE
  )
  theta <- stats::rnorm(n)
  resp <- matrix(NA_integer_, nrow = n, ncol = nrow(item_pars))
  colnames(resp) <- item_pars$Item
  for (j in seq_len(nrow(item_pars))) {
    tau <- as.numeric(item_pars[j, c("Step1", "Step2", "Step3")])
    for (i in seq_len(n)) {
      p <- local_probs(theta[i], item_pars$Alpha[j], tau)
      resp[i, j] <- sample.int(length(p), size = 1L, prob = p) - 1L
    }
  }
  list(resp = as.data.frame(resp), theta = theta, item_pars = item_pars)
}

safe_version <- function(pkg) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    as.character(utils::packageVersion(pkg))
  } else {
    NA_character_
  }
}

fixture <- make_fixture()
theta_grid <- seq(-3, 3, length.out = 17)
results <- list()
checks <- list()

add_result <- function(Package, Item, Comparison, MaxAbsDiff, Threshold,
                       Detail = "") {
  results[[length(results) + 1L]] <<- data.frame(
    Package = Package,
    Item = Item,
    Comparison = Comparison,
    MaxAbsDiff = MaxAbsDiff,
    Threshold = Threshold,
    Passed = is.finite(MaxAbsDiff) && MaxAbsDiff <= Threshold,
    Detail = Detail,
    stringsAsFactors = FALSE
  )
}

add_check <- function(Check, Value, Threshold, Passed, Detail = "") {
  checks[[length(checks) + 1L]] <<- data.frame(
    Check = Check,
    Value = Value,
    Threshold = Threshold,
    Passed = isTRUE(Passed),
    Detail = Detail,
    stringsAsFactors = FALSE
  )
}

mirt_available <- requireNamespace("mirt", quietly = TRUE)
tam_available <- requireNamespace("TAM", quietly = TRUE)
erm_available <- requireNamespace("eRm", quietly = TRUE)
add_check("mirt_available", as.integer(mirt_available), 1L, mirt_available,
          paste0("version=", safe_version("mirt")))
add_check("TAM_available", as.integer(tam_available), 1L, tam_available,
          paste0("version=", safe_version("TAM")))
add_check("eRm_pcm_boundary_available", as.integer(erm_available), 1L,
          erm_available && exists("PCM", envir = asNamespace("eRm"), inherits = FALSE),
          paste0("version=", safe_version("eRm"),
                 "; eRm is used as PCM/CML boundary evidence, not free-slope GPCM evidence"))

if (mirt_available) {
  suppressPackageStartupMessages(library(mirt))
  mirt_fit <- mirt::mirt(
    fixture$resp, 1,
    itemtype = "gpcmIRT",
    verbose = FALSE,
    TOL = 1e-4,
    technical = list(NCYCLES = 120)
  )
  mirt_coef <- mirt::coef(mirt_fit, IRTpars = TRUE, simplify = TRUE)$items
  for (j in seq_len(ncol(fixture$resp))) {
    item_name <- colnames(fixture$resp)[j]
    item <- mirt::extract.item(mirt_fit, j)
    ext <- mirt::probtrace(item, matrix(theta_grid, ncol = 1))
    tau_cols <- grep("^b[0-9]+$", colnames(mirt_coef), value = TRUE)
    tau <- as.numeric(mirt_coef[j, tau_cols])
    loc <- local_trace(theta_grid, a = as.numeric(mirt_coef[j, "a1"]), tau = tau)
    ext_mom <- score_moments(ext)
    loc_mom <- score_moments(loc)
    add_result("mirt", item_name, "probtrace_vs_local_kernel",
               max(abs(ext - loc)), 1e-10,
               "mirt gpcmIRT IRTpars mapping: local tau_k = b_k")
    add_result("mirt", item_name, "expected_score_vs_local_kernel",
               max(abs(ext_mom$expected - loc_mom$expected)), 1e-10,
               "expected score from mirt::probtrace() probabilities")
    add_result("mirt", item_name, "variance_vs_local_kernel",
               max(abs(ext_mom$variance - loc_mom$variance)), 1e-10,
               "score variance from mirt::probtrace() probabilities")
    add_result("mirt", item_name, "derivative_identity_local",
               derivative_check(theta_grid, as.numeric(mirt_coef[j, "a1"]), tau),
               1e-6,
               "dE/dtheta = a * Var under the mapped external parameters")
  }
}

if (tam_available) {
  suppressPackageStartupMessages(library(TAM))
  tam_fit <- TAM::tam.mml.2pl(
    fixture$resp,
    irtmodel = "GPCM",
    control = list(maxiter = 120, conv = 1e-4, progress = FALSE)
  )
  tam_theta <- as.numeric(tam_fit$theta[, 1])
  tam_irt <- as.data.frame(tam_fit$item_irt)
  tau_cols <- startsWith(names(tam_irt), "tau.Cat")
  for (j in seq_len(nrow(tam_irt))) {
    item_name <- as.character(tam_irt$item[j])
    ext <- t(tam_fit$rprobs[j, , , drop = TRUE])
    tau <- as.numeric(tam_irt$beta[j]) +
      as.numeric(unlist(tam_irt[j, tau_cols], use.names = FALSE))
    loc <- local_trace(tam_theta, a = as.numeric(tam_irt$alpha[j]), tau = tau)
    ext_mom <- score_moments(ext)
    loc_mom <- score_moments(loc)
    add_result("TAM", item_name, "rprobs_vs_local_kernel",
               max(abs(ext - loc)), 5e-4,
               "TAM GPCM IRT mapping: local tau_k = beta + tau.Cat_k")
    add_result("TAM", item_name, "expected_score_vs_local_kernel",
               max(abs(ext_mom$expected - loc_mom$expected)), 5e-4,
               "expected score from TAM rprobs")
    add_result("TAM", item_name, "variance_vs_local_kernel",
               max(abs(ext_mom$variance - loc_mom$variance)), 5e-4,
               "score variance from TAM rprobs")
    add_result("TAM", item_name, "derivative_identity_local",
               derivative_check(tam_theta, as.numeric(tam_irt$alpha[j]), tau),
               1e-6,
               "dE/dtheta = a * Var under the mapped external parameters")
  }
}

results_df <- if (length(results)) do.call(rbind, results) else data.frame()
if (nrow(results_df) > 0L) {
  add_check("external_probability_trace_rows", nrow(results_df), 1L,
            nrow(results_df) > 0L, "mirt/TAM mapped-kernel comparison rows")
  add_check("external_probability_trace_max_diff",
            max(results_df$MaxAbsDiff[grepl("probtrace|rprobs", results_df$Comparison)],
                na.rm = TRUE),
            5e-4,
            all(results_df$Passed, na.rm = FALSE),
            "all external mapped-kernel comparisons pass their row thresholds")
} else {
  add_check("external_probability_trace_rows", 0L, 1L, FALSE,
            "no external comparison rows were produced")
  add_check("external_probability_trace_max_diff", NA_real_, 5e-4, FALSE,
            "no external comparison rows were produced")
}

checks_df <- if (length(checks)) do.call(rbind, checks) else data.frame()
failed_checks <- sum(!checks_df$Passed)
status <- if (failed_checks == 0L) "ok" else "concern"

dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(
  results_df,
  file.path(OUT_DIR, "gpcm-score-side-external-comparison-0.2.2-results.csv"),
  row.names = FALSE
)
utils::write.csv(
  checks_df,
  file.path(OUT_DIR, "gpcm-score-side-external-comparison-0.2.2-checks.csv"),
  row.names = FALSE
)

format_md_table <- function(x) {
  out <- utils::capture.output(print(x, row.names = FALSE, digits = 4))
  c("```", out, "```")
}

versions <- data.frame(
  Package = c("mfrmr", "mirt", "TAM", "eRm"),
  Version = c(
    as.character(read.dcf("DESCRIPTION")[1, "Version"]),
    safe_version("mirt"),
    safe_version("TAM"),
    safe_version("eRm")
  ),
  Role = c(
    "bounded-GPCM score-side contract under review",
    "external GPCM probability trace via gpcmIRT/probtrace",
    "external GPCM probability trace via tam.mml.2pl/rprobs",
    "PCM/CML boundary evidence; no free-slope GPCM comparison"
  ),
  stringsAsFactors = FALSE
)

md <- c(
  "# Bounded-GPCM score-side external comparison evidence (0.2.2)",
  "",
  "This fixed evidence artifact strengthens the bounded-GPCM score-side",
  "contract by comparing the package's adjacent-category probability kernel",
  "with external GPCM probability traces from `mirt` and `TAM`. The comparison",
  "is intentionally kernel-level: it does not claim full many-facet parameter",
  "equivalence, FACETS score-side equivalence, operational scoring equivalence,",
  "or calibrated uncertainty coverage.",
  "`mirt`, `TAM`, and `eRm` are not treated as many-facet MFRM comparators.",
  "",
  sprintf("- `GPCMScoreSideExternalComparisonStatus = \"%s\"`;", status),
  sprintf("- `ExternalComparisonRows = %d`;", nrow(results_df)),
  sprintf("- `FailedChecks = %d`.", failed_checks),
  "",
  "## Package Roles",
  "",
  format_md_table(versions),
  "",
  "## Gate Checks",
  "",
  format_md_table(checks_df),
  "",
  "## Comparison Rows",
  "",
  format_md_table(results_df),
  "",
  "## Interpretation boundary",
  "",
  "- `mirt`: `gpcmIRT` IRT parameters map to the local kernel with",
  "  `tau_k = b_k`; `mirt::probtrace()` is the external probability target.",
  "- `TAM`: `tam.mml.2pl(..., irtmodel = \"GPCM\")` IRT parameters map to",
  "  the local kernel with `tau_k = beta + tau.Cat_k`; `rprobs` is the",
  "  external probability target.",
  "- `eRm`: `PCM()` is retained as unit-slope/CML boundary evidence only.",
  "  It is not treated as a free-slope GPCM score-side comparator.",
  "- The comparison supports probability, expected-score, score-variance,",
  "  and `dE/dtheta = a * Var` contract rows. It does not validate FACETS",
  "  raw-score-to-measure scorefile semantics under free discrimination.",
  "",
  "## Files",
  "",
  "- `gpcm-score-side-external-comparison-0.2.2-results.csv`",
  "- `gpcm-score-side-external-comparison-0.2.2-checks.csv`"
)
writeLines(
  md,
  file.path(OUT_DIR, "gpcm-score-side-external-comparison-0.2.2.md"),
  useBytes = TRUE
)

cat(sprintf("wrote: %s\n", normalizePath(OUT_DIR, winslash = "/", mustWork = FALSE)))
cat(sprintf("status=%s; rows=%d; failed_checks=%d\n",
            status, nrow(results_df), failed_checks))
