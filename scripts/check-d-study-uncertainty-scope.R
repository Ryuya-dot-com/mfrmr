# Bounded assessment of the proposed interval method, not a public API.
# Run `Rscript scripts/check-d-study-uncertainty-scope.R pilot`, then `... assess`.
# Saved Gaussian fits and the first ten new pilot fits are reused without refitting.
args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(args)) args[1L] else 'pilot'
stopifnot(mode %in% c('pilot', 'assess'))
started <- proc.time()[['elapsed']]
root <- 'validation-results/multivariate-sparse-recovery-20260921'
out <- file.path(root, 'uncertainty-scope-20260921')
dir.create(out, showWarnings = FALSE)
if (file.exists(file.path(out, 'results.rds'))) stop('Assessment exists; reuse saved results.')
saved <- readRDS(file.path(root, 'results.rds'))
sources <- names(saved$components)
scores <- rownames(saved$weights)
subsets <- list(1L, 2L, 3L, c(1L, 2L), c(1L, 3L), c(2L, 3L), 1:3)
metrics <- c('G', 'Phi', 'RelativeSEM', 'AbsoluteSEM')
upper <- upper.tri(matrix(0, 7, 7), diag = TRUE)
indices <- which(upper, arr.ind = TRUE)
# Evaluate definitions only; never source the prior assessment's execution body.
for (file in c('scripts/check-d-study-contrast-uncertainty.R',
               'scripts/check-d-study-sparse-uncertainty.R')) {
  wanted <- c('project', 'extract_theta', 'products', 'as_covariance', 'psd',
              'build_operator', 'truth_for')
  for (e in parse(file)) if (is.call(e) && identical(e[[1L]], as.name('<-')) &&
      is.symbol(e[[2L]]) && as.character(e[[2L]]) %in% wanted) eval(e)
}
paths <- c(Raters6 = paste0(root, '-raters6-matched-tasks/results.rds'),
           Tasks4 = paste0(root, '-tasks4/results.rds'))
gaussian <- lapply(paths, readRDS)
stopifnot(all(vapply(gaussian, function(data)
  identical(data$components, saved$components) && identical(data$weights, saved$weights), logical(1))))
source_files <- c('scripts/check-d-study-uncertainty-scope.R',
  'scripts/check-d-study-contrast-uncertainty.R', 'scripts/check-d-study-sparse-uncertainty.R',
  'R/api-multivariate-gtheory.R', file.path(root, 'results.rds'), unname(paths),
  file.path(root, 'sparse-uncertainty-20260921/operators.rds'))
source_md5 <- tools::md5sum(source_files)
design_for <- function(data) {
  n <- data$dimensions
  expand.grid(Person = seq_len(n[1L]), Rater = seq_len(n[2L]), Task = seq_len(n[3L]))[
    data$rosters$Rotating, , drop = FALSE]
}
groups_for <- function(design) setNames(lapply(subsets,
  function(s) as.integer(interaction(design[s], drop = TRUE))), sources)
design <- design_for(saved)
groups <- groups_for(design)
roots <- lapply(saved$components, chol)
stopifnot(all(vapply(seq_along(roots), function(i)
  isTRUE(all.equal(crossprod(roots[[i]]), saved$components[[i]])), logical(1))))
plans <- data.frame(Raters = c(2L, 3L, 4L), Tasks = c(6L, 4L, 3L))
plan_names <- paste(plans$Raters, plans$Tasks, sep = 'x')
pairs <- combn(3L, 2L)
critical <- qnorm(.975)

fourth_operator <- function(design, gram) {
  groups <- groups_for(design)
  kernels <- lapply(groups, function(g) outer(g, g, '==') * 1)
  centered <- lapply(kernels, function(K)
    sweep(sweep(K, 1L, rowMeans(K), '-'), 2L, colMeans(K), '-') + mean(K))
  scale <- sqrt(diag(gram))
  inverse <- solve(gram / outer(scale, scale)) / outer(scale, scale)
  A <- lapply(1:7, function(i) Reduce('+', Map('*', centered, inverse[i, ])))
  basis <- vapply(1:7, function(u) {
    # Diagonal of Z_u' A_i Z_u via within-group sums; no fourth-order tensor.
    D <- vapply(A, function(a) as.vector(rowsum(rowSums(a * kernels[[u]]), groups[[u]])),
      numeric(length(unique(groups[[u]]))))
    as.vector(crossprod(D))
  }, numeric(49))
  if (nrow(design) <= 48L) for (u in 1:7) {
    Z <- model.matrix(~ factor(groups[[u]]) - 1)
    D <- vapply(A, function(a) diag(crossprod(Z, a %*% Z)), numeric(ncol(Z)))
    stopifnot(max(abs(basis[, u] - as.vector(crossprod(D)))) < 1e-10)
  }
  basis
}

pkgload::load_all(quiet = TRUE, compile = FALSE)
draw_new <- function(distribution, target) {
  path <- file.path(out, paste0('draws-', distribution, '.rds'))
  seed_base <- if (distribution == 'T6') 921290000L else 921300000L
  columns <- names(saved$truth)[seq_len(21L)]
  result <- if (file.exists(path)) readRDS(path) else list(
    estimates = matrix(NA_real_, 1000L, 21L, dimnames = list(NULL, columns)),
    trials = data.frame(Replicate = 1:1000, Seed = seed_base + 1:1000,
      Attempted = FALSE, FitReturned = FALSE, Error = NA_character_),
    distribution = distribution, dimensions = saved$dimensions, source_md5 = source_md5)
  stopifnot(identical(result$source_md5, source_md5))
  RNGkind("L'Ecuyer-CMRG", 'Inversion', 'Rejection')
  for (b in which(!result$trials$Attempted & seq_len(1000L) <= target)) {
    set.seed(result$trials$Seed[b])
    y <- matrix(0, nrow(design), 2L)
    for (u in 1:7) {
      n <- max(groups[[u]]) * 2L
      z <- if (distribution == 'T6') rt(n, 6) * sqrt(2 / 3) else (rgamma(n, 2) - 2) / sqrt(2)
      effects <- matrix(z, ncol = 2L) %*% roots[[u]]
      y <- y + effects[groups[[u]], , drop = FALSE]
    }
    data <- design
    data[scores] <- sweep(y, 2L, c(10, 20), '+')
    g <- tryCatch(mfrm_multivariate_gstudy(data, scores, method = 'minque0'), error = identity)
    result$trials$Attempted[b] <- TRUE
    result$trials$FitReturned[b] <- !inherits(g, 'error')
    result$trials$Error[b] <- if (inherits(g, 'error')) conditionMessage(g) else ''
    if (!inherits(g, 'error')) {
      result$estimates[b, ] <- unlist(lapply(g$components, function(a) a[upper.tri(a, diag = TRUE)]))
      if (b == 1L) {
        d <- mfrm_multivariate_d_study(g, plans, saved$weights)$coefficients
        for (composite in colnames(saved$weights)) {
          theta <- as.numeric(extract_theta(result$estimates[b, , drop = FALSE], saved$weights[, composite]))
          reference <- t(vapply(1:3, function(i) project(theta, plans[i, ])$value, numeric(4)))
          actual <- as.matrix(d[d$Kind == 'Composite' & d$Score == composite, metrics])
          stopifnot(isTRUE(all.equal(unname(actual), unname(reference), tolerance = 1e-10)))
        }
      }
    }
    if (b %% 100L == 0L || b == target) {
      saveRDS(result, path)
      cat(distribution, ': retained attempts', sum(result$trials$Attempted), '\n'); flush.console()
      if (proc.time()[['elapsed']] - started > 300) stop('Budget reached; saved attempts retained.')
    }
  }
  result
}

cache_path <- file.path(out, 'operators.rds')
if (mode == 'pilot') {
  if (file.exists(cache_path)) stop('Pilot exists; use assess.')
  # Exact fourth-cumulant covariance identity using 27 finite-support outcomes.
  # Each independent coordinate has variance 1 and fourth moment 6 (kurtosis 3).
  Z <- as.matrix(expand.grid(rep(list(c(-sqrt(6), 0, sqrt(6))), 3)))
  probability <- apply(as.matrix(expand.grid(rep(list(c(1/12, 5/6, 1/12)), 3))), 1, prod)
  A <- matrix(c(1, .2, -.1, .2, -2, .3, -.1, .3, .5), 3)
  B <- matrix(c(-.3, .1, .4, .1, .8, -.2, .4, -.2, 1), 3)
  qa <- rowSums((Z %*% A) * Z); qb <- rowSums((Z %*% B) * Z)
  actual <- sum(probability * qa * qb) - sum(probability * qa) * sum(probability * qb)
  stopifnot(abs(actual - (2 * sum(A * B) + 3 * sum(diag(A) * diag(B)))) < 1e-10)
  tiny <- expand.grid(Person = 1:4, Rater = 1:3, Task = 1:4)[-c(1, 8, 23), ]
  invisible(fourth_operator(tiny, build_operator(tiny)$gram))
  prior <- readRDS(file.path(root, 'sparse-uncertainty-20260921/operators.rds'))
  stopifnot(identical(prior$source_md5, tools::md5sum(names(prior$source_md5))))
  operators <- lapply(gaussian, function(data) build_operator(design_for(data)))
  operators$Baseline <- prior$operators$Rotating
  fourth <- fourth_operator(design, operators$Baseline$gram)
  saveRDS(list(operators = operators, fourth = fourth, source_md5 = source_md5), cache_path)
  invisible(draw_new('T6', 10L)); invisible(draw_new('Gamma2', 10L))
  cat('Fourth-moment identities and public projections passed; ten attempts per new distribution retained.\n')
  cat('Pilot seconds:', proc.time()[['elapsed']] - started, '\n')
  quit(save = 'no')
}

cache <- readRDS(cache_path)
stopifnot(identical(cache$source_md5, source_md5))
fresh <- lapply(setNames(c('T6', 'Gamma2'), c('T6', 'Gamma2')), draw_new, target = 1000L)
all_summaries <- checks <- list()
for (case in c(names(gaussian), names(fresh))) {
  data <- if (case %in% names(gaussian)) gaussian[[case]] else fresh[[case]]
  idx <- if (case %in% names(gaussian)) which(data$trials$Case == 'Rotating') else 1:1000
  stopifnot(length(idx) == 1000L)
  operator <- cache$operators[[if (case %in% names(gaussian)) case else 'Baseline']]
  rows <- list()
  for (composite in colnames(saved$weights)) {
    w <- saved$weights[, composite]
    theta <- extract_theta(data$estimates[idx, , drop = FALSE], w)
    truth <- truth_for(saved, composite)
    oracle <- as_covariance(operator$basis %*% products(truth))
    oracle_fourth <- oracle
    if (case %in% names(fresh)) {
      cumulants <- vapply(roots, function(a) 3 * sum(drop(a %*% w)^4), numeric(1))
      oracle_fourth <- oracle + as_covariance(cache$fourth %*% cumulants)
    }
    stopifnot(psd(oracle), psd(oracle_fourth))
    checks[[length(checks) + 1L]] <- data.frame(Case = case, Composite = composite, Source = sources,
      Truth = truth, Mean = colMeans(theta, na.rm = TRUE),
      EmpiricalVariance = apply(theta, 2, var, na.rm = TRUE),
      GaussianVariance = diag(oracle), TrueVariance = diag(oracle_fourth))
    mu <- t(vapply(1:3, function(i) project(truth, plans[i, ])$value, numeric(4)))
    for (b in 1:1000) {
      v <- theta[b, ]; returned <- data$trials$FitReturned[idx[b]]
      covariances <- list(PlugIn = if (returned) as_covariance(operator$basis %*% products(v)) else
          matrix(NA_real_, 7, 7), OracleGaussian = oracle)
      if (case %in% names(fresh)) covariances$OracleFourth <- oracle_fourth
      projections <- lapply(1:3, function(i) project(v, plans[i, ]))
      for (method in names(covariances)) {
        C <- covariances[[method]]
        covariance_psd <- if (all(is.finite(C))) psd(C) else NA
        for (p in 1:3) {
          first <- pairs[1L, p]; second <- pairs[2L, p]
          difference <- projections[[second]]$value - projections[[first]]$value
          gradient <- projections[[second]]$gradient - projections[[first]]$gradient
          variance <- rowSums((gradient %*% C) * gradient)
          status <- if (!returned) rep('Fit failed', 4) else
            ifelse(!is.finite(difference), 'Point unavailable',
              ifelse(rowSums(!is.finite(gradient)) > 0, 'Boundary derivative',
                ifelse(!is.finite(variance) | variance <= 0, 'Nonpositive or nonfinite contrast variance', 'Available')))
          ok <- status == 'Available'
          se <- sqrt(ifelse(ok, variance, NA_real_))
          actual <- mu[second, ] - mu[first, ]
          lower <- difference - critical * se; higher <- difference + critical * se
          rows[[length(rows) + 1L]] <- data.frame(Case = case, Composite = composite, Method = method,
            Pair = paste(plan_names[second], '-', plan_names[first]), Replicate = data$trials$Replicate[idx[b]],
            Metric = metrics, Truth = actual, Estimate = difference, SE = se, Lower = lower, Upper = higher,
            Available = ok, Status = status, SamplingCovariancePSD = covariance_psd,
            NegativeComponent = any(v < 0), Covered = ifelse(ok, lower <= actual & higher >= actual, NA))
        }
      }
    }
  }
  trials <- do.call(rbind, rows)
  summaries <- split(trials, interaction(trials[c('Composite', 'Method', 'Pair', 'Metric')], drop = TRUE))
  summary <- do.call(rbind, lapply(summaries, function(x) {
    ok <- x$Available; coverage <- mean(x$Covered[ok])
    data.frame(x[1L, c('Case', 'Composite', 'Method', 'Pair', 'Metric', 'Truth')],
      Attempts = nrow(x), Available = sum(ok), Unavailable = sum(!ok),
      ConditionalCoverage = coverage, AllAttemptCoverage = sum(x$Covered[ok]) / nrow(x),
      CoverageMCSE = sqrt(coverage * (1 - coverage) / sum(ok)),
      BelowTruth = mean(x$Upper[ok] < x$Truth[ok]), AboveTruth = mean(x$Lower[ok] > x$Truth[ok]),
      MeanWidth = mean(x$Upper[ok] - x$Lower[ok]), Bias = mean(x$Estimate[ok] - x$Truth[ok]),
      EmpiricalSD = sd(x$Estimate[ok]), MeanSE = mean(x$SE[ok]),
      NonPSDSamplingCovariance = sum(!x$SamplingCovariancePSD, na.rm = TRUE),
      UnknownSamplingCovariance = sum(is.na(x$SamplingCovariancePSD)),
      NegativeComponents = sum(x$NegativeComponent, na.rm = TRUE),
      RevisionFlag = coverage < .925 || mean(ok) < .99, ConservativeFlag = coverage > .975)
  }))
  rownames(summary) <- NULL
  stopifnot(nrow(trials) == nrow(summary) * 1000L)
  saveRDS(list(trials = trials, summary = summary), file.path(out, paste0(case, '.rds')))
  all_summaries[[case]] <- summary
  cat('Completed', case, '; seconds:', proc.time()[['elapsed']] - started, '\n'); flush.console()
  if (proc.time()[['elapsed']] - started > 300) stop('Budget reached; completed cases retained.')
}
summary <- do.call(rbind, all_summaries)
saveRDS(list(summary = summary, component_checks = do.call(rbind, checks), plans = plans,
  weights = saved$weights, source_md5 = source_md5, seconds = proc.time()[['elapsed']] - started,
  session = sessionInfo()), file.path(out, 'results.rds'))
print(aggregate(cbind(ConditionalCoverage, Available, MeanWidth) ~ Case + Method, summary,
  function(x) paste(signif(range(x), 5), collapse = ' to ')), row.names = FALSE)
