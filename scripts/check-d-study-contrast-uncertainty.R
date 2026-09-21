# Bounded method assessment; not a public interval API or a release test.
# Run from the package root. Reuse Complete rows only; no RNG or data refits.
# The prespecified assessment and acceptance screen are in the current internal roadmap.
started <- proc.time()[['elapsed']]
root <- 'validation-results/multivariate-sparse-recovery-20260921'
saved <- readRDS(file.path(root, 'results.rds'))
idx <- which(saved$trials$Case == 'Complete')
stopifnot(length(idx) == 1000L, all(saved$trials$FitReturned[idx]))
sources <- names(saved$components)
subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
plans <- data.frame(Raters = c(2L, 3L, 4L), Tasks = c(6L, 4L, 3L))
plan_names <- paste(plans$Raters, plans$Tasks, sep = 'x')
pairs <- combn(3L, 2L)
metrics <- c('G', 'Phi', 'RelativeSEM', 'AbsoluteSEM')
critical <- qnorm(.975)

ems_map <- function(n) {
  out <- matrix(0, 7, 7, dimnames = list(sources, sources))
  for (i in 1:7) for (j in 1:7) {
    if (all(subsets[[i]] %in% subsets[[j]])) {
      out[i, j] <- prod(n[setdiff(1:3, subsets[[j]])])
    }
  }
  out
}
dfs <- function(n) vapply(subsets, function(s) prod(n[s] - 1), numeric(1))
project <- function(theta, plan) {
  relative <- c(0, 0, 0, 1 / plan$Raters, 1 / plan$Tasks, 0,
                1 / (plan$Raters * plan$Tasks))
  absolute <- relative + c(0, 1 / plan$Raters, 1 / plan$Tasks, 0, 0,
                           1 / (plan$Raters * plan$Tasks), 0)
  u <- theta[1L]
  error <- c(sum(relative * theta), sum(absolute * theta))
  value <- setNames(rep(NA_real_, 4), metrics)
  gradient <- matrix(NA_real_, 4, 7, dimnames = list(metrics, sources))
  for (j in 1:2) {
    e <- error[j]
    c <- if (j == 1L) relative else absolute
    if (is.finite(u) && is.finite(e) && u >= 0 && e >= 0 && u + e > 0) {
      value[j] <- u / (u + e)
      # Interior-only delta assessment; do not qualify boundary inference.
      if (u > 0 && e > 0) {
        gradient[j, ] <- -u * c / (u + e)^2
        gradient[j, 1L] <- e / (u + e)^2
      }
    }
    if (is.finite(e) && e >= 0) value[j + 2L] <- sqrt(e)
    if (is.finite(e) && e > 0) gradient[j + 2L, ] <- c / (2 * sqrt(e))
  }
  list(value = value, gradient = gradient)
}
extract_theta <- function(rows, w) {
  vapply(sources, function(s) {
    columns <- paste('Component', s, c('Content', 'Content,Organization', 'Organization'), sep = '/')
    drop(rows[, columns, drop = FALSE] %*% c(w[1]^2, 2 * w[1] * w[2], w[2]^2))
  }, numeric(nrow(rows)))
}
truth_rows <- matrix(saved$truth, 1L, dimnames = list(NULL, names(saved$truth)))
truth <- lapply(seq_len(ncol(saved$weights)), function(j)
  as.numeric(extract_theta(truth_rows, saved$weights[, j])))
names(truth) <- colnames(saved$weights)

# Independent Gaussian quadratic-form covariance check on 48 cells.
n <- c(4L, 3L, 4L)
design <- expand.grid(Person = seq_len(n[1]), Rater = seq_len(n[2]), Task = seq_len(n[3]))
N <- nrow(design)
kernels <- lapply(subsets, function(s) {
  g <- as.integer(interaction(design[s], drop = TRUE))
  outer(g, g, '==') * 1
})
H <- diag(N) - 1 / N
B <- lapply(kernels, function(K) H %*% K %*% H)
gram <- outer(1:7, 1:7, Vectorize(function(i, j) sum(B[[i]] * B[[j]])))
inverse <- solve(gram)
Aq <- lapply(1:7, function(i) Reduce('+', Map(function(b, c) b * c, B, inverse[i, ])))
L <- ems_map(n)
A <- solve(L)
for (v in truth) {
  V <- Reduce('+', Map(function(K, c) K * c, kernels, v))
  AV <- lapply(Aq, function(a) a %*% V)
  exact <- outer(1:7, 1:7, Vectorize(function(i, j) 2 * sum(AV[[i]] * t(AV[[j]]))))
  from_ms <- A %*% diag(2 * drop(L %*% v)^2 / dfs(n)) %*% t(A)
  stopifnot(max(abs(exact - from_ms)) < 1e-10)
  for (i in 1:3) {
    numerical <- vapply(1:7, function(j) {
      step <- rep(0, 7); step[j] <- 1e-6
      (project(v + step, plans[i, ])$value - project(v - step, plans[i, ])$value) / 2e-6
    }, numeric(4))
    stopifnot(max(abs(numerical - project(v, plans[i, ])$gradient)) < 1e-8)
  }
}

# Check point projections against the actual API, without refitting the saved data.
pkgload::load_all(quiet = TRUE, compile = FALSE)
for (row in c(0L, idx[1L], tail(idx, 1L))) {
  z <- if (row == 0L) saved$truth else saved$estimates[row, ]
  comps <- setNames(lapply(sources, function(s) {
    values <- z[paste('Component', s, c('Content', 'Content,Organization', 'Organization'), sep = '/')]
    matrix(values[c(1, 2, 2, 3)], 2, dimnames = list(rownames(saved$weights), rownames(saved$weights)))
  }), sources)
  g <- structure(list(components = comps, score_scale = setNames(c(1, 1), rownames(saved$weights)),
    design = list(scores = rownames(saved$weights), calculation_version = 2L,
                  counts = saved$dimensions)), class = 'mfrm_multivariate_gstudy')
  d <- mfrm_multivariate_d_study(g, plans, saved$weights)$coefficients
  for (composite in names(truth)) {
    v <- as.numeric(extract_theta(matrix(z, 1, dimnames = list(NULL, names(z))), saved$weights[, composite]))
    expected <- t(vapply(1:3, function(i) project(v, plans[i, ])$value, numeric(4)))
    actual <- as.matrix(d[d$Kind == 'Composite' & d$Score == composite, metrics])
    stopifnot(isTRUE(all.equal(unname(actual), unname(expected), tolerance = 1e-12)))
  }
}

# Assess both covariance conventions as declared, without picking a winner post hoc.
L <- ems_map(saved$dimensions)
A <- solve(L)
df <- dfs(saved$dimensions)
results <- list()
for (composite in names(truth)) {
  theta <- extract_theta(saved$estimates[idx, , drop = FALSE], saved$weights[, composite])
  mu <- t(vapply(1:3, function(i) project(truth[[composite]], plans[i, ])$value, numeric(4)))
  for (b in seq_along(idx)) {
    v <- theta[b, ]
    ms <- drop(L %*% v)
    stopifnot(all(is.finite(ms)), all(ms > 0))
    projections <- lapply(1:3, function(i) project(v, plans[i, ]))
    for (denominator in c('df+2', 'df')) {
      C <- A %*% diag(2 * ms^2 / (df + if (denominator == 'df+2') 2 else 0)) %*% t(A)
      for (p in 1:3) {
        first <- pairs[1L, p]; second <- pairs[2L, p]
        difference <- projections[[second]]$value - projections[[first]]$value
        gradient <- projections[[second]]$gradient - projections[[first]]$gradient
        variance <- rowSums((gradient %*% C) * gradient)
        ok <- is.finite(difference) & is.finite(variance) & variance > 0
        se <- sqrt(ifelse(ok, variance, NA_real_))
        actual <- mu[second, ] - mu[first, ]
        lower <- difference - critical * se
        upper <- difference + critical * se
        results[[length(results) + 1L]] <- data.frame(
          Composite = composite, Denominator = denominator,
          Pair = paste(plan_names[second], '-', plan_names[first]),
          Replicate = saved$trials$Replicate[idx[b]], Metric = metrics,
          Truth = actual, Estimate = difference, SE = se, Lower = lower, Upper = upper,
          Available = ok, Status = ifelse(ok, 'Available', 'Non-interior or nonfinite projection'),
          Covered = ifelse(ok, lower <= actual & upper >= actual, NA))
      }
    }
  }
}
results <- do.call(rbind, results)
groups <- split(results, interaction(results[c('Composite', 'Denominator', 'Pair', 'Metric')], drop = TRUE))
summary <- do.call(rbind, lapply(groups, function(x) {
  ok <- x$Available
  coverage <- mean(x$Covered[ok])
  data.frame(x[1L, c('Composite', 'Denominator', 'Pair', 'Metric', 'Truth')],
    Attempts = nrow(x), Available = sum(ok), Unavailable = sum(!ok),
    ConditionalCoverage = coverage, AllAttemptCoverage = sum(x$Covered[ok]) / nrow(x),
    CoverageMCSE = sqrt(coverage * (1 - coverage) / sum(ok)),
    BelowTruth = mean(x$Upper[ok] < x$Truth[ok]), AboveTruth = mean(x$Lower[ok] > x$Truth[ok]),
    MeanWidth = mean(x$Upper[ok] - x$Lower[ok]),
    Bias = mean(x$Estimate[ok] - x$Truth[ok]), EmpiricalSD = sd(x$Estimate[ok]),
    MeanSE = mean(x$SE[ok]), RevisionFlag = coverage < .925 || mean(ok) < .99)
}))
rownames(summary) <- NULL
stopifnot(nrow(summary) == 48L, nrow(results) == 48000L)
output <- file.path(root, 'd-study-contrast-uncertainty-20260921.rds')
saveRDS(list(summary = summary, trials = results, plans = plans, weights = saved$weights,
  method = 'Balanced Gaussian paired delta; primary df+2; nominal .95',
  source_md5 = tools::md5sum(c(file.path(root, 'results.rds'),
    'scripts/check-d-study-contrast-uncertainty.R', 'R/api-multivariate-gtheory.R')),
  seconds = proc.time()[['elapsed']] - started, session = sessionInfo()), output)
print(summary[summary$Denominator == 'df+2', c('Composite', 'Pair', 'Metric',
  'Available', 'ConditionalCoverage', 'CoverageMCSE', 'MeanWidth', 'RevisionFlag')], row.names = FALSE)
cat('Independent formula, gradient and public-projection checks passed.\n')
cat('Seconds:', proc.time()[['elapsed']] - started, '\nSaved:', output, '\n')
