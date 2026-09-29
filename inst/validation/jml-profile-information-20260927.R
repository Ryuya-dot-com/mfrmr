# Repository-only derivation check. No public covariance or interval is added.
# Run from the package root after the portable JML source fixtures exist:
# Rscript inst/validation/jml-profile-information-20260927.R [output-directory]
pkgload::load_all('.', quiet = TRUE, compile = FALSE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1L]] else
  'validation-results/jml-profile-information-20260927'
if (file.exists(file.path(out, 'results.rds'))) stop('Refusing to overwrite completed evidence.')
dir.create(out, recursive = TRUE, showWarnings = FALSE)

review <- function(path, owner) {
  fit <- readRDS(path)
  cfg <- fit$config
  sizes <- build_param_sizes(cfg)
  d <- fit$prep$data
  stopifnot(cfg$method == 'JML', cfg$model == 'GPCM',
    identical(cfg$step_facet, cfg$slope_facet),
    identical(cfg$step_facet, owner), all(get_weights(d) == 1),
    !length(cfg$interaction_specs), !cfg$theta_spec$centered,
    all(is.na(cfg$theta_spec$anchors)), !length(cfg$theta_spec$group_values),
    all(is.na(cfg$theta_spec$groups)))
  np <- sizes$theta
  ti <- seq_len(np)
  si <- seq.int(np + 1L, length(fit$opt$par))
  stopifnot(isTRUE(all.equal(unname(constraint_jacobian(cfg$theta_spec)), diag(np))))
  rows <- split(seq_len(nrow(d)), factor(as.integer(d$Person), levels = ti))
  k <- seq_len(cfg$n_cat) - 1L
  idx <- build_indices(fit$prep, cfg$step_facet, cfg$slope_facet, cfg$interaction_specs)
  ev <- make_mfrm_direct_evaluator('JML',
    make_param_cache(sizes, cfg, idx, is_mml = FALSE), idx, cfg, sizes)

  # Independent adjacent-category probabilities, using only the package's
  # identified parameter expansion. No package likelihood or optimizer here.
  profile <- function(beta) {
    p <- expand_params(c(rep(0, np), beta), sizes, cfg)
    offset <- rep(0, nrow(d))
    for (facet in cfg$facet_names) {
      offset <- offset + cfg$facet_signs[[facet]] *
        p$facets[[facet]][as.integer(d[[facet]])]
    }
    level <- as.integer(d[[owner]])
    a <- p$slopes[level]
    cumul <- t(apply(p$steps_mat, 1, function(x) c(0, cumsum(x))))
    intercept <- a * (outer(offset, k) - cumul[level, , drop = FALSE])
    result <- lapply(rows, function(rr) {
      y <- d$score_k[rr]
      if (all(y == 0) || all(y == max(k))) {
        stop('Finite-profile check does not admit extreme Persons.')
      }
      moments <- function(theta) {
        z <- intercept[rr, , drop = FALSE] + outer(a[rr] * theta, k)
        z <- z - apply(z, 1, max)
        denom <- rowSums(exp(z))
        prob <- exp(z) / denom
        list(nll = -sum(z[cbind(seq_along(rr), y + 1L)] - log(denom)),
          score = sum(a[rr] * (y - drop(prob %*% k))))
      }
      bound <- 1
      while (moments(-bound)$score <= 0 || moments(bound)$score >= 0) {
        bound <- 2 * bound
        if (!is.finite(bound) || bound > 1e6) stop('Finite Person root unresolved.')
      }
      theta <- uniroot(function(x) moments(x)$score, c(-bound, bound),
        tol = 1e-11)$root
      value <- moments(theta)
      c(theta = theta, nll = value$nll, score = value$score)
    })
    do.call(rbind, result)
  }
  beta <- fit$opt$par[si]
  base <- profile(beta)
  par <- c(base[, 'theta'], beta)
  H <- optimHess(par, ev$value, ev$gradient)
  Hpp <- H[ti, ti, drop = FALSE]
  Hss <- H[si, si, drop = FALSE]
  Hps <- H[ti, si, drop = FALSE]
  S <- Hss - t(Hps) %*% solve(Hpp, Hps)
  inverse_profile <- solve(S)
  inverse_conditional <- solve(Hss)
  block_error <- max(abs(inverse_profile - solve(H)[si, si]))
  objective_error <- abs(sum(base[, 'nll']) - ev$value(par))

  # The profile envelope score must sum to the structural joint score after
  # profiling Persons. This also supplies per-Person estimating functions.
  h <- 1e-5
  G <- vapply(seq_along(beta), function(j) {
    lo <- hi <- beta; lo[j] <- lo[j] - h; hi[j] <- hi[j] + h
    (profile(hi)[, 'nll'] - profile(lo)[, 'nll']) / (2 * h)
  }, numeric(np))
  score_error <- max(abs(colSums(G) - ev$gradient(par)[si]))
  directions <- do.call(rbind, lapply(1:4, function(j) {
    v <- sin(seq_along(beta) * j); v <- v / sqrt(sum(v^2))
    expected <- drop(crossprod(v, S %*% v))
    do.call(rbind, lapply(c(1e-3, 5e-4), function(h) {
      observed <- (sum(profile(beta + h*v)[, 'nll']) -
        2*sum(base[, 'nll']) + sum(profile(beta - h*v)[, 'nll'])) / h^2
      data.frame(Direction = j, Step = h, Schur = expected, Reprofiled = observed,
        RelativeError = abs(observed - expected) / max(1, abs(expected)))
    }))
  }))
  # Centering describes empirical variability for an iid Person/profile-score
  # target. It is not a proof for fixed heterogeneous Persons or other designs.
  centered <- scale(G, center = TRUE, scale = FALSE)
  singular <- svd(centered, nu = 0, nv = 0)$d
  rank <- sum(singular > max(singular) * 1e-7)
  sandwich <- inverse_profile %*% crossprod(centered) %*% inverse_profile
  slope_cols <- tail(seq_along(si), sizes$log_slopes)
  J <- matrix(0, length(cfg$gpcm_spec$levels), length(si))
  J[, slope_cols] <- sum_zero_jacobian(nrow(J))
  slope_profile <- sqrt(diag(J %*% inverse_profile %*% t(J)))
  slope_conditional <- sqrt(diag(J %*% inverse_conditional %*% t(J)))
  ratio <- slope_profile / slope_conditional
  slope_review <- data.frame(Owner = owner, Level = cfg$gpcm_spec$levels,
    ConditionalCurvatureScale = slope_conditional,
    ProfileCurvatureScale = slope_profile, Ratio = ratio)
  checks <- c(objective = objective_error < 1e-9,
    person_roots = max(abs(base[, 'score'])) < 1e-7,
    envelope_score = score_error < 1e-6,
    inverse_block = block_error < 1e-9,
    profile_curvature = max(directions$RelativeError) < 1e-5,
    positive_joint_curvature = min(eigen(H, symmetric = TRUE)$values) > 0,
    rank_bound = rank <= min(np - 1, length(si)))
  summary <- data.frame(Owner = owner, Persons = np, StructuralParameters = length(si),
    ProfileScoreRank = rank, ObjectiveError = objective_error,
    EnvelopeScoreError = score_error, InverseBlockError = block_error,
    MaxCurvatureRelativeError = max(directions$RelativeError),
    PersonScoreSupNorm = max(abs(base[, 'score'])),
    StructuralScoreSupNorm = max(abs(ev$gradient(par)[si])),
    SlopeCurvatureSERatioMin = min(ratio),
    SlopeCurvatureSERatioMax = max(ratio),
    AllChecksPass = all(checks))
  list(summary = summary, checks = checks, directions = directions,
    slope_review = slope_review,
    joint_curvature = H, profile_curvature = S, person_profile_gradients = G,
    centered_score_singular_values = singular,
    exploratory_sandwich = sandwich,
    source_sha256 = digest::digest(file = path, algo = 'sha256'))
}
paths <- c(Criterion = 'source.rds', Rater = 'rater-source.rds')
results <- lapply(names(paths), function(owner) review(file.path(
  'validation-results/portable-gpcm-jml-20260927', paths[[owner]]), owner))
names(results) <- names(paths)
saveRDS(results, file.path(out, 'results.rds'))
summary <- do.call(rbind, lapply(results, `[[`, 'summary'))
write.csv(summary, file.path(out, 'summary.csv'), row.names = FALSE)
write.csv(do.call(rbind, lapply(results, `[[`, 'slope_review')),
  file.path(out, 'slope-review.csv'), row.names = FALSE)
writeLines(digest::digest(file = 'inst/validation/jml-profile-information-20260927.R',
  algo = 'sha256'), file.path(out, 'runner-sha256.txt'))
writeLines(capture.output(sessionInfo()), file.path(out, 'sessionInfo.txt'))
print(summary, row.names = FALSE, digits = 8)
stopifnot(all(summary$AllChecksPass))
