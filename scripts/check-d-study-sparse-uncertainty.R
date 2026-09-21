# Saved-result assessment of paired delta intervals; not a public API.
# Run `Rscript scripts/check-d-study-sparse-uncertainty.R pilot`, then `... assess`.
# The pilot verifies/caches operators; assessment reuses them. No simulation/refits.
args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(args)) args[1L] else 'pilot'
stopifnot(mode %in% c('pilot', 'assess'))
started <- proc.time()[['elapsed']]
root <- 'validation-results/multivariate-sparse-recovery-20260921'
out <- file.path(root, 'sparse-uncertainty-20260921')
dir.create(out, showWarnings = FALSE)
cache_path <- file.path(out, 'operators.rds')
output_path <- file.path(out, 'results.rds')
if (file.exists(output_path)) stop('Assessment already exists; reuse its results.')
saved <- readRDS(file.path(root, 'results.rds'))
sources <- names(saved$components)
subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
metrics <- c('G', 'Phi', 'RelativeSEM', 'AbsoluteSEM')
# Reuse only the existing, independently checked function definitions.
functions <- c('ems_map', 'dfs', 'project', 'extract_theta')
for (e in parse('scripts/check-d-study-contrast-uncertainty.R')) {
  if (is.call(e) && identical(e[[1L]], as.name('<-')) &&
      is.symbol(e[[2L]]) && as.character(e[[2L]]) %in% functions) eval(e)
}
stopifnot(all(vapply(functions, function(n) is.function(get(n)), logical(1))))
upper <- upper.tri(matrix(0, 7, 7), diag = TRUE)
indices <- which(upper, arr.ind = TRUE)
products <- function(theta) theta[indices[, 1L]] * theta[indices[, 2L]]
as_covariance <- function(x) matrix(x, 7, 7, dimnames = list(sources, sources))
psd <- function(x) {
  eigenvalues <- eigen((x + t(x)) / 2, symmetric = TRUE, only.values = TRUE)$values
  min(eigenvalues) >= -sqrt(.Machine$double.eps) * max(abs(eigenvalues))
}
build_operator <- function(design, keep_matrices = FALSE) {
  start <- proc.time()[['elapsed']]
  n <- nrow(design)
  # Bounded dense reference; not the memory strategy for a future public API.
  stopifnot(n <= 960L)
  groups <- lapply(subsets, function(s) as.integer(interaction(design[s], drop = TRUE)))
  kernels <- lapply(groups, function(g) outer(g, g, '==') * 1)
  B <- lapply(kernels, function(K)
    sweep(sweep(K, 1L, rowMeans(K), '-'), 2L, colMeans(K), '-') + mean(K))
  S <- crossprod(vapply(B, as.vector, numeric(n^2)))
  scale <- sqrt(diag(S))
  normalized <- S / outer(scale, scale)
  values <- eigen(normalized, symmetric = TRUE, only.values = TRUE)$values
  stopifnot(min(values) > sqrt(.Machine$double.eps) * max(values))
  inverse <- solve(normalized) / outer(scale, scale)
  A <- lapply(1:7, function(i) Reduce('+', Map(function(b, c) b * c, B, inverse[i, ])))
  basis <- vapply(seq_len(nrow(indices)), function(p) {
    u <- indices[p, 1L]; v <- indices[p, 2L]
    # Z_u' A_s Z_v. Grouped sums avoid repeated cubic matrix products.
    compressed <- lapply(A, function(a)
      t(rowsum(t(rowsum(a, groups[[u]], reorder = FALSE)), groups[[v]], reorder = FALSE)))
    M <- vapply(compressed, as.vector, numeric(length(compressed[[1L]])))
    as.vector(2 * (if (u == v) 1 else 2) * crossprod(M))
  }, numeric(49))
  moment_map <- diag(28) + basis[which(upper), ]
  stopifnot(rcond(moment_map) > sqrt(.Machine$double.eps))
  corrected <- basis %*% solve(moment_map)
  result <- list(basis = basis, corrected = corrected, gram = S,
    condition = max(values) / min(values), moment_condition = kappa(moment_map, exact = TRUE),
    rows = n, seconds = proc.time()[['elapsed']] - start)
  if (keep_matrices) result$matrices <- list(A = A, K = kernels, groups = groups)
  result
}
truth_for <- function(data, composite) {
  rows <- matrix(data$truth, 1L, dimnames = list(NULL, names(data$truth)))
  as.numeric(extract_theta(rows, data$weights[, composite]))
}
source_files <- c('scripts/check-d-study-sparse-uncertainty.R',
  'scripts/check-d-study-contrast-uncertainty.R', 'R/api-multivariate-gtheory.R',
  file.path(root, 'results.rds'), paste0(root, c('-small_rt', '-zero_rt'), '/results.rds'))
source_md5 <- tools::md5sum(source_files)
full <- expand.grid(Person = seq_len(saved$dimensions[1L]),
  Rater = seq_len(saved$dimensions[2L]), Task = seq_len(saved$dimensions[3L]))

if (mode == 'pilot') {
  if (file.exists(cache_path)) stop('Pilot already exists; use assess to reuse it.')
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  small <- expand.grid(Person = 1:4, Rater = 1:3, Task = 1:4)
  for (design in list(small, small[-c(1, 8, 23), ])) {
    operator <- build_operator(design, keep_matrices = TRUE)
    A <- operator$matrices$A; K <- operator$matrices$K
    y <- matrix(sin(seq_len(nrow(design))), ncol = 1L)
    y <- y - mean(y)
    fitted <- mfrmr:::.mfrm_mvgt_minque0(y, setNames(operator$matrices$groups, sources))
    stopifnot(isTRUE(all.equal(unname(fitted$estimation$kernel_gram), operator$gram, tolerance = 1e-10)))
    quadratic <- vapply(A, function(a) drop(crossprod(y, a %*% y)), numeric(1))
    stopifnot(max(abs(quadratic - unlist(fitted$components))) < 1e-10)
    for (composite in colnames(saved$weights)) {
      theta <- truth_for(saved, composite)
      V <- Reduce('+', Map(function(k, v) k * v, K, theta))
      AV <- lapply(A, function(a) a %*% V)
      direct <- outer(1:7, 1:7, Vectorize(function(i, j) 2 * sum(AV[[i]] * t(AV[[j]]))))
      stopifnot(max(abs(direct - as_covariance(operator$basis %*% products(theta)))) < 1e-10)
    }
    if (nrow(design) == nrow(small)) {
      L <- ems_map(c(4, 3, 4)); inverse <- solve(L)
      # 28 spanning evaluations establish the quadratic identity with df+2.
      for (p in seq_len(nrow(indices))) {
        theta <- numeric(7); theta[indices[p, ]] <- 1
        expected <- inverse %*% diag(2 * drop(L %*% theta)^2 / (dfs(c(4, 3, 4)) + 2)) %*% t(inverse)
        actual <- as_covariance(operator$corrected %*% products(theta))
        stopifnot(max(abs(actual - expected)) < 1e-10)
      }
    }
  }
  operator <- build_operator(full[saved$rosters$Rotating, ])
  saveRDS(list(operators = list(Rotating = operator), source_md5 = source_md5), cache_path)
  cat('Independent traces, current MINQUE, and balanced df+2 identity passed.\n')
  cat('960-row operator seconds:', operator$seconds, '; moment-map condition:', operator$moment_condition, '\n')
  quit(save = 'no')
}

stopifnot(file.exists(cache_path))
cache <- readRDS(cache_path)
stopifnot(identical(cache$source_md5, source_md5))
for (name in c('RepeatedPair', 'Concentrated')) {
  cache$operators[[name]] <- build_operator(full[saved$rosters[[name]], ])
  saveRDS(cache, cache_path)
  cat('Operator:', name, 'seconds:', cache$operators[[name]]$seconds, '\n'); flush.console()
}
datasets <- list(Baseline = saved,
  SmallRT = readRDS(paste0(root, '-small_rt/results.rds')),
  ZeroRT = readRDS(paste0(root, '-zero_rt/results.rds')))
cases <- data.frame(Label = c('Rotating', 'RepeatedPair', 'Concentrated', 'SmallRT', 'ZeroRT'),
  Dataset = c(rep('Baseline', 3), 'SmallRT', 'ZeroRT'),
  Roster = c('Rotating', 'RepeatedPair', 'Concentrated', 'Rotating', 'Rotating'))
plans <- data.frame(Raters = c(2L, 3L, 4L), Tasks = c(6L, 4L, 3L))
plan_names <- paste(plans$Raters, plans$Tasks, sep = 'x')
pairs <- combn(3L, 2L)
critical <- qnorm(.975)
all_summaries <- component_checks <- list()
for (case in seq_len(nrow(cases))) {
  data <- datasets[[cases$Dataset[case]]]
  roster <- cases$Roster[case]
  idx <- which(data$trials$Case == roster)
  stopifnot(length(idx) == 1000L, all(data$trials$FitReturned[idx]),
    identical(data$dimensions, saved$dimensions), identical(data$rosters[[roster]], saved$rosters[[roster]]))
  operator <- cache$operators[[roster]]
  rows <- list()
  for (composite in colnames(data$weights)) {
    theta <- extract_theta(data$estimates[idx, , drop = FALSE], data$weights[, composite])
    truth <- truth_for(data, composite)
    oracle <- as_covariance(operator$basis %*% products(truth))
    stopifnot(psd(oracle))
    component_checks[[length(component_checks) + 1L]] <- data.frame(Case = cases$Label[case],
      Composite = composite, Source = sources, Truth = truth, Mean = colMeans(theta),
      EmpiricalVariance = apply(theta, 2L, var), OracleVariance = diag(oracle))
    mu <- t(vapply(1:3, function(i) project(truth, plans[i, ])$value, numeric(4)))
    for (b in seq_along(idx)) {
      v <- theta[b, ]
      covariances <- list(Oracle = oracle,
        PlugIn = as_covariance(operator$basis %*% products(v)),
        MomentCorrected = as_covariance(operator$corrected %*% products(v)))
      projections <- lapply(1:3, function(i) project(v, plans[i, ]))
      for (method in names(covariances)) {
        C <- covariances[[method]]
        covariance_psd <- psd(C)
        for (p in 1:3) {
          first <- pairs[1L, p]; second <- pairs[2L, p]
          difference <- projections[[second]]$value - projections[[first]]$value
          gradient <- projections[[second]]$gradient - projections[[first]]$gradient
          variance <- rowSums((gradient %*% C) * gradient)
          status <- ifelse(!is.finite(difference), 'Point unavailable',
            ifelse(rowSums(!is.finite(gradient)) > 0, 'Boundary derivative',
              ifelse(!is.finite(variance) | variance <= 0, 'Nonpositive or nonfinite contrast variance', 'Available')))
          ok <- status == 'Available'
          se <- sqrt(ifelse(ok, variance, NA_real_))
          actual <- mu[second, ] - mu[first, ]
          lower <- difference - critical * se; higher <- difference + critical * se
          rows[[length(rows) + 1L]] <- data.frame(Case = cases$Label[case], Composite = composite,
            Method = method, Pair = paste(plan_names[second], '-', plan_names[first]),
            Replicate = data$trials$Replicate[idx[b]], Metric = metrics,
            Truth = actual, Estimate = difference, SE = se, Lower = lower, Upper = higher,
            Available = ok, Status = status, SamplingCovariancePSD = covariance_psd,
            NegativeComponent = any(v < 0), Covered = ifelse(ok, lower <= actual & higher >= actual, NA))
        }
      }
    }
  }
  trials <- do.call(rbind, rows)
  groups <- split(trials, interaction(trials[c('Composite', 'Method', 'Pair', 'Metric')], drop = TRUE))
  summary <- do.call(rbind, lapply(groups, function(x) {
    ok <- x$Available; coverage <- mean(x$Covered[ok])
    data.frame(x[1L, c('Case', 'Composite', 'Method', 'Pair', 'Metric', 'Truth')],
      Attempts = nrow(x), Available = sum(ok), Unavailable = sum(!ok),
      ConditionalCoverage = coverage, AllAttemptCoverage = sum(x$Covered[ok]) / nrow(x),
      CoverageMCSE = sqrt(coverage * (1 - coverage) / sum(ok)),
      BelowTruth = mean(x$Upper[ok] < x$Truth[ok]), AboveTruth = mean(x$Lower[ok] > x$Truth[ok]),
      MeanWidth = mean(x$Upper[ok] - x$Lower[ok]), Bias = mean(x$Estimate[ok] - x$Truth[ok]),
      EmpiricalSD = sd(x$Estimate[ok]), MeanSE = mean(x$SE[ok]),
      NonPSDSamplingCovariance = sum(!x$SamplingCovariancePSD),
      NegativeComponents = sum(x$NegativeComponent),
      RevisionFlag = coverage < .925 || mean(ok) < .99)
  }))
  rownames(summary) <- NULL
  stopifnot(nrow(trials) == 72000L, nrow(summary) == 72L)
  saveRDS(list(trials = trials, summary = summary), file.path(out, paste0(cases$Label[case], '.rds')))
  all_summaries[[case]] <- summary
  cat('Completed', cases$Label[case], '; elapsed seconds:', proc.time()[['elapsed']] - started, '\n')
  flush.console()
  if (proc.time()[['elapsed']] - started > 300) stop('Five-minute assessment budget reached; completed cases retained.')
}
summary <- do.call(rbind, all_summaries)
checks <- do.call(rbind, component_checks)
saveRDS(list(summary = summary, component_checks = checks, cases = cases, plans = plans,
  weights = saved$weights, source_md5 = source_md5,
  seconds = proc.time()[['elapsed']] - started, session = sessionInfo()), output_path)
print(aggregate(cbind(ConditionalCoverage, Available, NonPSDSamplingCovariance) ~ Case + Method,
  summary, function(x) paste(range(x), collapse = ' to ')), row.names = FALSE)
cat('Saved all outcomes without random-data generation or original-data refits.\n')
