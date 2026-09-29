# Exact finite-response expectation, not a public bias correction or CI.
# Rscript inst/validation/jml-profile-bias-exact-20260927.R [output-directory]
pkgload::load_all('.', quiet = TRUE, compile = FALSE)
make_jml_exact_problem <- function(owner, repeats) {
  cells <- expand.grid(Rater = 1:2, Criterion = 1:2)
  own <- cells[[owner]]
  sign_r <- c(1, -1)[cells$Rater]; sign_c <- c(1, -1)[cells$Criterion]
  sign_a <- c(1, -1)[own]
  truth <- c(Rater = .3, Criterion = -.4, Step1 = -.6, Step2 = -.9, LogSlope = .25)
  possible <- expand.grid(n0 = 0:repeats, n1 = 0:repeats)
  possible <- possible[rowSums(possible) <= repeats, ]
  possible$n2 <- repeats - rowSums(possible)
  patterns <- as.matrix(expand.grid(rep(list(seq_len(nrow(possible))), 4)))
  counts <- lapply(1:4, function(j) as.matrix(possible[patterns[, j], ]))
  n <- nrow(patterns)
  totals <- vapply(counts, function(x) x[, 2] + 2*x[, 3], numeric(n))
  owner_totals <- sapply(1:2, function(j) rowSums(totals[, own == j, drop = FALSE]))
  keys <- paste(owner_totals[, 1], owner_totals[, 2], sep = ':')
  extreme <- rowSums(totals) == 0 | rowSums(totals) == 8*repeats
  log_multiplicity <- Reduce(`+`, lapply(counts, function(x)
    lgamma(repeats + 1) - rowSums(lgamma(x + 1))))

  evaluate <- function(beta, theta = NULL) {
    a <- exp(sign_a * beta[5])
    offset <- -sign_r * beta[1] - sign_c * beta[2]
    step <- beta[2 + own]
    probabilities <- function(t) {
      z <- a * (outer(t + offset, 0:2) - cbind(0, step, 0))
      z <- z - apply(z, 1, max)
      exp(z) / rowSums(exp(z))
    }
    profiled <- is.null(theta)
    root_residual <- 0
    if (profiled) {
      first <- which(!duplicated(keys) & !extreme)
      roots <- vapply(first, function(i) {
        target <- sum(a * totals[i, ])
        score <- function(t) repeats * sum(a * drop(probabilities(t) %*% (0:2))) - target
        bound <- 1
        while (score(-bound) >= 0 || score(bound) <= 0) {
          bound <- 2*bound
          if (bound > 1e6) stop('Unresolved finite Person root.')
        }
        uniroot(score, c(-bound, bound), tol = 1e-12)$root
      }, numeric(1))
      theta <- roots[match(keys, keys[first])]
      theta[extreme] <- 0 # Only a placeholder; exact limiting contributions follow.
    } else theta <- rep(theta, length.out = n)
    q <- numeric(n); G <- matrix(0, n, 5); person_score <- numeric(n)
    for (j in 1:4) {
      z <- a[j] * (outer(theta + offset[j], 0:2) -
        matrix(c(0, step[j], 0), n, 3, byrow = TRUE))
      shifted <- z - apply(z, 1, max)
      logp <- shifted - log(rowSums(exp(shifted)))
      p <- exp(logp)
      residual <- repeats*p - counts[[j]]
      score_residual <- drop(residual %*% (0:2))
      q <- q - rowSums(counts[[j]] * logp)
      G[, 1] <- G[, 1] - sign_r[j]*a[j]*score_residual
      G[, 2] <- G[, 2] - sign_c[j]*a[j]*score_residual
      G[, 2 + own[j]] <- G[, 2 + own[j]] - a[j]*residual[, 2]
      G[, 5] <- G[, 5] + sign_a[j]*rowSums(residual*z)
      person_score <- person_score + a[j]*score_residual
    }
    if (profiled) {
      root_residual <- max(abs(person_score[!extreme]))
      q[extreme] <- 0; G[extreme, ] <- 0
    }
    colnames(G) <- names(truth)
    list(q = q, gradient = G, root_residual = root_residual, theta = theta)
  }
  # Vectorized exact generating masses at a set of fixed abilities.
  count_matrix <- do.call(cbind, counts)
  mass <- function(beta, theta) {
    logp <- lapply(1:4, function(j) {
      a <- exp(sign_a[j] * beta[5])
      eta <- theta - sign_r[j]*beta[1] - sign_c[j]*beta[2]
      z <- a * (outer(eta, 0:2) -
        matrix(c(0, beta[2 + own[j]], 0), length(theta), 3, byrow = TRUE))
      z <- z - apply(z, 1, max)
      z - log(rowSums(exp(z)))
    })
    exp(count_matrix %*% t(do.call(cbind, logp)) + log_multiplicity)
  }
  first <- which(!duplicated(keys) & !extreme)
  group <- match(keys, keys[first])
  # Person contributions for the sample estimating equation and its sandwich.
  # Recompute both fitted abilities and plug-in expectations at each beta.
  scores <- function(beta, adjusted = FALSE) {
    prof <- evaluate(beta)
    if (!adjusted) return(prof$gradient)
    generated <- mass(beta, prof$theta[first])
    if (max(abs(colSums(generated) - 1)) > 1e-10)
      stop('Generating mass is not normalized.')
    bias <- crossprod(generated, prof$gradient)
    answer <- prof$gradient
    answer[!extreme, ] <- answer[!extreme, , drop = FALSE] -
      bias[group[!extreme], , drop = FALSE]
    answer
  }
  mean_score <- function(beta, weights, adjusted = FALSE) {
    prof <- evaluate(beta)
    if (adjusted) {
      group_mass <- vapply(seq_along(first), function(j)
        sum(weights[!is.na(group) & group == j]), numeric(1))
      generated <- mass(beta, prof$theta[first])
      if (max(abs(colSums(generated) - 1)) > 1e-10)
        stop('Generating mass is not normalized.')
      # Extreme-pattern plug-in limits have zero profile gradients.
      weights <- weights - drop(generated %*% group_mass)
    }
    drop(crossprod(weights, prof$gradient))
  }
  list(truth = truth, n = n, counts = counts, keys = keys, extreme = extreme,
    log_multiplicity = log_multiplicity, own = own, sign_r = sign_r,
    sign_c = sign_c, sign_a = sign_a, evaluate = evaluate, mass = mass,
    mean_score = mean_score, scores = scores)
}

review <- function(owner, repeats) {
  with(make_jml_exact_problem(owner, repeats), {
  profile <- evaluate(truth)
  # Independent central differences of every pattern's profiled criterion.
  numerical <- vapply(seq_along(truth), function(j) {
    lo <- hi <- truth; lo[j] <- lo[j] - 1e-5; hi[j] <- hi[j] + 1e-5
    (evaluate(hi)$q - evaluate(lo)$q) / 2e-5
  }, numeric(n))
  gradient_error <- max(abs(numerical - profile$gradient))
  # Test one plug-in recentering step at the true structural parameters:
  # subtract the profile-score expectation generated at each pattern's theta_hat.
  # Extreme theta limits generate only their matching extreme pattern, whose
  # profile gradient is zero. This is not a fitted corrected estimator.
  plugin_bias <- matrix(0, n, 5)
  for (key in unique(keys[!extreme])) {
    ii <- which(keys == key)
    generating <- evaluate(truth, profile$theta[ii[1]])
    mass <- exp(log_multiplicity - generating$q)
    stopifnot(abs(sum(mass) - 1) < 1e-12)
    bias <- drop(crossprod(mass, profile$gradient))
    plugin_bias[ii, ] <- matrix(bias, length(ii), 5, byrow = TRUE)
  }
  adjusted_gradient <- profile$gradient - plugin_bias
  summary <- do.call(rbind, lapply(c(-1, 0, 1), function(theta) {
    known <- evaluate(truth, theta)
    mass <- exp(log_multiplicity - known$q)
    expected <- drop(crossprod(mass, profile$gradient))
    known_score <- drop(crossprod(mass, known$gradient))
    adjusted <- drop(crossprod(mass, adjusted_gradient))
    # Confirm this is the package's whole-predictor GPCM response function.
    eta <- theta - sign_r*truth[1] - sign_c*truth[2]
    steps <- rbind(c(truth[3], -truth[3]), c(truth[4], -truth[4]))
    cum <- t(apply(steps, 1, function(x) c(0, cumsum(x))))
    native <- category_prob_gpcm(eta, cum, own, exp(c(truth[5], -truth[5])), own)
    z <- exp(sign_a*truth[5]) * (outer(eta, 0:2) - cum[own, ])
    z <- z - apply(z, 1, max); independent <- exp(z)/rowSums(exp(z))
    probability_error <- max(abs(native - independent))
    data.frame(Owner = owner, Ratings = 4*repeats, Patterns = n,
      OrderedPatterns = 3^(4*repeats), TrueAbility = theta,
      TotalMass = sum(mass), ExtremeMass = sum(mass[extreme]),
      KnownAbilityScoreSupNorm = max(abs(known_score)),
      ProfileScoreSupNorm = max(abs(expected)),
      ProfileLogSlopeScore = expected[5],
      PluginAdjustedLogSlopeScore = adjusted[5],
      PluginAdjustedScoreSupNorm = max(abs(adjusted)),
      RaterScore = expected[1], CriterionScore = expected[2],
      Step1Score = expected[3], Step2Score = expected[4],
      GradientError = gradient_error, ProbabilityError = probability_error,
      RootResidual = profile$root_residual)
  }))
  a <- exp(c(.25, -.25)); corrected <- a * (4*repeats - 1)/(4*repeats)
  corrected <- corrected/exp(mean(log(corrected)))
  checks <- c(probability_mass = max(abs(summary$TotalMass - 1)) < 1e-12,
    known_ability_score = max(summary$KnownAbilityScoreSupNorm) < 1e-12,
    analytic_gradient = gradient_error < 1e-7,
    package_response = max(summary$ProbabilityError) < 1e-12,
    roots = profile$root_residual < 1e-9,
    uniform_slope_multiplier_cancels = max(abs(a - corrected)) < 1e-12,
    extreme_limits = all(profile$q[extreme] == 0) && all(profile$gradient[extreme, ] == 0))
  list(summary = summary, checks = checks, truth = truth,
    profile_gradient = profile$gradient, profile_objective = profile$q,
    plugin_adjusted_gradient = adjusted_gradient,
    profile_theta_finite_placeholders = profile$theta,
    extreme = extreme, count_patterns = counts)
  })
}

run_jml_exact_review <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  out <- if (length(args)) args[[1]] else 'validation-results/jml-profile-bias-exact-20260927'
  if (file.exists(file.path(out, 'results.rds'))) stop('Refusing to overwrite completed evidence.')
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  conditions <- expand.grid(Owner = c('Criterion', 'Rater'), Repeats = 1:2,
    stringsAsFactors = FALSE)
  results <- lapply(seq_len(nrow(conditions)), function(i)
    review(conditions$Owner[i], conditions$Repeats[i]))
  summary <- do.call(rbind, lapply(results, `[[`, 'summary'))
  saveRDS(results, file.path(out, 'results.rds'))
  write.csv(summary, file.path(out, 'summary.csv'), row.names = FALSE)
  writeLines(digest::digest(file = 'inst/validation/jml-profile-bias-exact-20260927.R',
    algo = 'sha256'), file.path(out, 'runner-sha256.txt'))
  writeLines(capture.output(sessionInfo()), file.path(out, 'sessionInfo.txt'))
  print(summary, row.names = FALSE, digits = 7)
  stopifnot(all(vapply(results, function(x) all(x$checks), logical(1))))
}

if (sys.nframe() == 0L) run_jml_exact_review()
