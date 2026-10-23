# Calibration design arithmetic and self-checks; no GMFRM refitting or new data.
options(warn = 2)
directory <- "validation-results/gmfrm-regularized-feasibility-20261012"
script <- "inst/validation/gmfrm-null-calibration-20261012.R"
check <- function(h) stopifnot(length(h) > 0L, !anyNA(h), identical(h, tools::md5sum(names(h))))
old <- readRDS(file.path(directory, "replay.rds")); check(old$outputs)
m <- readRDS(file.path(directory, "manifest.rds")); check(m$inputs); check(m$source)
stopifnot(identical(old$manifest, tools::md5sum(file.path(directory, "manifest.rds"))),
  all(old$summary$Qualified))
blocked <- function(...) stop("No random generation or optimization in this calibration review.")
for (n in c("rnorm", "runif", "rbinom", "optim", "nlminb")) assignInNamespace(n, blocked, "stats")

# Conditional on a fixed generating law: retain ambiguous/failed comparisons.
# Input envelopes must actually bound the statistic for a bound interpretation;
# quadrature-rule differences alone supply diagnostic sensitivity, not a proof.
mc_envelope <- function(observed, draws, alpha = .05, confidence = .95) {
  stopifnot(is.numeric(observed), length(observed) == 2L,
    is.matrix(draws), is.numeric(draws), ncol(draws) == 2L, nrow(draws) > 0L,
    length(alpha) == 1L, is.finite(alpha), alpha > 0, alpha < 1,
    length(confidence) == 1L, is.finite(confidence), confidence > 0, confidence < 1)
  B <- nrow(draws)
  valid <- complete.cases(draws)
  stopifnot(all(draws[valid, 1L] <= draws[valid, 2L]))
  if (anyNA(observed)) return(list(B = B, status = "observed_unavailable",
    definite_exceed = 0L, unresolved = B, p_range = c(1 / (B + 1), 1),
    tail_probability_interval = c(0, 1)))
  stopifnot(all(is.finite(observed)), observed[1L] <= observed[2L])
  yes <- valid & draws[, 1L] >= observed[2L]
  no <- valid & draws[, 2L] < observed[1L]
  a <- sum(yes); u <- sum(!yes & !no)
  p <- (1 + c(a, a + u)) / (B + 1)
  delta <- 1 - confidence
  ci <- c(if (a == 0L) 0 else qbeta(delta / 2, a, B - a + 1),
    if (a + u == B) 1 else qbeta(1 - delta / 2, a + u + 1, B - a - u))
  list(B = B, status = if (p[2L] <= alpha) "reject" else if (p[1L] > alpha)
    "do_not_reject" else "unresolved", definite_exceed = a, unresolved = u,
    p_range = p, tail_probability_interval = ci)
}

# Exhaust every completion of three unknown comparisons; no missing-at-random assumption.
observed <- c(2, 2)
draws <- rbind(c(2, 2), c(3, 3), c(1, 1), c(0, 0), c(1, 3), c(NA, NA), c(NA, NA))
envelope <- mc_envelope(observed, draws)
completion <- expand.grid(rep(list(c(0L, 1L)), 3L))
ps <- (1 + 2 + rowSums(completion)) / 8
stopifnot(identical(envelope$definite_exceed, 2L), envelope$unresolved == 3L,
  all(ps >= envelope$p_range[1L]), all(ps <= envelope$p_range[2L]))
for (k in unique(2 + rowSums(completion))) {
  ci <- binom.test(k, 7)$conf.int
  stopifnot(ci[1L] >= envelope$tail_probability_interval[1L],
    ci[2L] <= envelope$tail_probability_interval[2L])
}
for (a in 0:19) {
  exact <- mc_envelope(c(1, 1), cbind(c(rep(1, a), rep(0, 19 - a)),
    c(rep(1, a), rep(0, 19 - a))))
  stopifnot(max(abs(exact$tail_probability_interval - binom.test(a, 19)$conf.int)) < 1e-12,
    all(exact$p_range == (1 + a) / 20))
}
stopifnot(mc_envelope(c(NA_real_, NA_real_), draws)$status == "observed_unavailable",
  mc_envelope(c(2, 2), matrix(NA_real_, 19, 2))$status == "unresolved")

# Known-law rank level is different from conditional tail-probability precision.
B <- c(19L, 99L, 199L, 999L, 1999L, 7999L)
alpha <- .05
precision <- do.call(rbind, lapply(B, function(b) {
  k <- round(alpha * b)
  ci <- binom.test(k, b)$conf.int
  data.frame(B = b, MinimumP = 1 / (b + 1), TailMCSEAt05 = sqrt(.05 * .95 / b),
    ExampleExceedances = k, CP95Lower = ci[1L], CP95Upper = ci[2L],
    KnownLawContinuousLevel = floor(alpha * (b + 1) + 1e-12) / (b + 1))
}))
for (b in B) {
  # Exact enumeration by binomial counts for a tied Bernoulli statistic.
  q <- seq(0, 1, length.out = 101L)
  size <- q * pbinom(floor(alpha * (b + 1) - 1 + 1e-12), b, q)
  stopifnot(all(size <= alpha + 1e-12))
}

# Closed-form penalized profile in a bivariate normal experiment:
# X ~ N((0, eta), Sigma), Sigma diagonal 1 and correlation rho, penalty ||theta||^2/2.
# No Monte Carlo error and no numerical optimizer enter this counterexample.
ridge_size <- function(eta, rho, quantile = c("noncentral", "folded")) {
  quantile <- match.arg(quantile)
  d <- 4 - rho^2; a <- 2 - rho^2
  sd <- sqrt(4 - 3 * rho^2) / d
  f <- function(e) {
    u <- eta + sqrt(1 - rho^2) * e
    mu <- -rho * u / d
    plugin_mu <- mu / a
    cutoff <- if (quantile == "noncentral")
      sd * sqrt(qchisq(.95, 1, ncp = (plugin_mu / sd)^2)) else
      vapply(plugin_mu, function(v) uniroot(function(h)
        pnorm((h - v) / sd) - pnorm((-h - v) / sd) - .95,
        c(0, abs(v) + 9 * sd), tol = 1e-12)$root, 0)
    (pnorm((-cutoff - mu) / (a / d)) +
      pnorm((cutoff - mu) / (a / d), lower.tail = FALSE)) * dnorm(e)
  }
  # Outside +/-9 the integrand is bounded by the normal density.
  at <- integrate(f, -9, 9, rel.tol = 1e-10, abs.tol = 1e-11, subdivisions = 1000L)
  c(rejection = at$value, integration_error = at$abs.error, tail_bound = 2 * pnorm(-9))
}
rho <- .8; Sigma <- matrix(c(1, rho, rho, 1), 2)
I <- solve(Sigma); H <- I + diag(2); A <- solve(H, I)
x <- c(.3, 2.1); hat <- drop(A %*% x)
null <- c(0, (x[2L] - rho * x[1L]) / (2 - rho^2))
Q <- function(theta) drop(crossprod(x - theta, I %*% (x - theta))) / 2 + sum(theta^2) / 2
stopifnot(abs(2 * (Q(null) - Q(hat)) - hat[1L]^2 / solve(H)[1L, 1L]) < 1e-12,
  max(abs(H %*% hat - I %*% x)) < 1e-12,
  abs((H %*% null - I %*% x)[2L]) < 1e-12)
sizes <- do.call(rbind, lapply(c(0, 2, 4, 8), function(eta) {
  a <- ridge_size(eta, .8); b <- ridge_size(eta, .8, "folded")
  stopifnot(abs(a[1L] - b[1L]) < 1e-9)
  data.frame(Eta = eta, Correlation = .8, Rejection = a[1L],
    IntegrationError = a[2L], TailBound = a[3L], IndependentDifference = abs(a[1L] - b[1L]))
}))
stopifnot(abs(ridge_size(4, 0)[1L] - .05) < 1e-10)

# Cost anchors reuse the complete free/null, two-start fits and all recorded reviews.
cost <- do.call(rbind, lapply(names(m$cases), function(case) {
  rows <- old$summary[old$summary$Case == case, ]
  paths <- file.path(directory, paste0(case, c("-free.rds", "-null.rds")))
  candidate_seconds <- sum(vapply(paths, function(path)
    sum(vapply(readRDS(path)$candidates, `[[`, 0, "seconds")), 0))
  data.frame(Case = case, FitSeconds = sum(rows$FitSeconds),
    ReviewSeconds = sum(rows$ReviewSeconds + rows$ReferenceSeconds) + candidate_seconds)
}))
cost$RecordedPairSeconds <- cost$FitSeconds + cost$ReviewSeconds
cost_grid <- merge(cost, data.frame(B = B), by = NULL)
cost_grid$HoursOneNull <- cost_grid$RecordedPairSeconds * (cost_grid$B + 1) / 3600
cost_grid$Hours21Nulls <- 21 * cost_grid$HoursOneNull
cost_grid$Hours21Nulls56Targets <- 56 * cost_grid$Hours21Nulls
statistics <- do.call(rbind, lapply(names(m$cases), function(case) {
  rows <- old$summary[old$summary$Case == case, ]
  data.frame(Case = case, Null = m$controls$null,
    PenalizedDeviance = 2 * (rows$Q[rows$Kind == "null"] - rows$Q[rows$Kind == "free"]))
}))
stopifnot(all(statistics$PenalizedDeviance >= 0), nrow(cost_grid) == 30L)

# Exact reuse opportunity under the retained fixed-normal, unweighted model.
# A pattern includes the roster AND responses; a matching total score is insufficient.
patterns <- do.call(rbind, lapply(names(m$cases), function(case) {
  s <- m$cases[[case]]$specification; d <- s$data
  id <- lapply(d[c(s$person, s$slope_facets)], function(x)
    match(as.character(x), sort(unique(as.character(x)))))
  groups <- split(seq_len(nrow(d)), id[[1L]])
  codes <- cbind(id[[2L]], id[[3L]], d[[s$score]])
  keys <- vapply(groups, function(rows) {
    x <- codes[rows, , drop = FALSE]
    x <- x[do.call(order, as.data.frame(x)), , drop = FALSE]
    paste(as.vector(t(x)), collapse = ":")
  }, "")
  index <- match(keys, unique(keys)); first <- match(seq_len(max(index)), index)
  multiplicity <- tabulate(index)
  errors <- lapply(c("free", "null"), function(kind) {
    ref <- readRDS(file.path(directory, paste0(case, "-", kind, ".rds")))$reference$value$reference
    stopifnot(length(ref$people) == length(groups))
    nll <- -sum(multiplicity * vapply(ref$people[first], `[[`, 0, "log_marginal"))
    score <- Reduce(`+`, Map(function(p, w) w * p$score, ref$people[first], multiplicity))
    c(NLL = abs(nll - ref$nll), Score = max(abs(score - ref$score)))
  })
  error <- apply(do.call(rbind, errors), 2L, max)
  stopifnot(all(error < 1e-10))
  data.frame(Case = case, Persons = length(groups), Patterns = length(first),
    RepeatedFraction = 1 - length(first) / length(groups),
    NLLReplayError = error[1L], ScoreReplayError = error[2L])
}))
inputs <- tools::md5sum(c(file.path(directory, c("manifest.rds", "replay.rds")), names(old$outputs)))
saveRDS(list(source = tools::md5sum(script), inputs = inputs, session = sessionInfo(),
  precision = precision, counterexample = sizes, costs = cost_grid,
  statistics = statistics, patterns = patterns, missing_comparison_check = envelope,
  semantics = c("Finite-B rank test vs conditional tail probability are different outputs.",
    "Plug-in nuisance parameters are not known true parameters.",
    "CP intervals are pointwise fixed-B Monte Carlo intervals, not GMFRM confidence intervals.",
    "Cost multiplication is a scenario using observed timed blocks, not a runtime bound.",
    "No new GMFRM data, fits, interval search or resampling allocation.")),
  file.path(directory, "calibration-design.rds"))
print(precision, row.names = FALSE)
print(sizes, row.names = FALSE)
print(cost_grid[cost_grid$B %in% c(199L, 1999L), c("Case", "B", "HoursOneNull", "Hours21Nulls")], row.names = FALSE)
print(statistics, row.names = FALSE)
print(patterns, row.names = FALSE)
cat("Calibration arithmetic, failure accounting and analytic counterexample checks passed.\n")
