# Run from the development root after pkgload::load_all(). Numerical integration
# at fixed parameters only; this is not a recovery or coverage experiment.

aq_continuous_reference <- function(scores, base, steps, slopes, weights,
                                    mu = 0, sigma = 1, limit = 32) {
  # Independently expressed category logits, without the package probability
  # kernel or Gauss-Hermite rule. Integrate in local posterior coordinates so
  # a long response pattern's narrow peak is not missed by stats::integrate().
  cumulative <- t(apply(steps, 1L, function(x) c(0, cumsum(x))))
  categories <- 0:ncol(steps)
  observed <- cbind(seq_along(scores), scores + 1L)
  evaluate <- function(z) {
    vapply(z, function(value) {
      logits <- slopes * (outer(mu + sigma * value + base, categories) - cumulative)
      center <- apply(logits, 1L, max)
      exponent <- exp(logits - center)
      probability <- exponent / rowSums(exponent)
      expected <- as.vector(probability %*% categories)
      variance <- rowSums(probability *
        (matrix(categories, nrow(probability), length(categories), byrow = TRUE) - expected)^2)
      c(log = sum(weights * (logits[observed] - center - log(rowSums(exponent)))) +
          dnorm(value, log = TRUE),
        score = sigma * sum(weights * slopes * (scores - expected)) - value,
        information = 1 + sigma^2 * sum(weights * slopes^2 * variance))
    }, c(log = 0, score = 0, information = 0))
  }
  mode <- optimize(function(z) evaluate(z)["log", ], c(-256, 256),
                   maximum = TRUE, tol = 1e-10)$maximum
  peak <- evaluate(mode)
  scale <- 1 / sqrt(peak["information", ])
  integral <- function(multiplier) {
    integrand <- function(u) {
      exp(evaluate(mode + scale * u)["log", ] - peak["log", ]) * multiplier(u)
    }
    parts <- lapply(list(c(-limit, 0), c(0, limit)), function(bounds) {
      integrate(integrand, bounds[1], bounds[2], rel.tol = 1e-11,
                abs.tol = 1e-12, subdivisions = 1000L)
    })
    stopifnot(all(vapply(parts, function(part) part$message == "OK", TRUE)))
    c(value = sum(vapply(parts, `[[`, 0, "value")),
      error = sum(vapply(parts, `[[`, 0, "abs.error")))
  }
  mass <- integral(function(u) rep(1, length(u)))
  center <- integral(identity)[1L] / mass[1L]
  variance <- integral(function(u) (u - center)^2)[1L] / mass[1L]
  log_mass <- peak["log", ] + log(scale) + log(mass[1L])
  # Strict log concavity gives tangent-exponential bounds on omitted mass.
  ends <- evaluate(mode + scale * c(-limit, limit))
  stopifnot(ends["score", 1L] > 0, ends["score", 2L] < 0)
  tails <- ends["log", ] - log(abs(ends["score", ]))
  log_tail <- max(tails) + log(sum(exp(tails - max(tails))))
  c(log_marginal = unname(log_mass), eap = unname(mu + sigma * (mode + scale * center)),
    sd = unname(sigma * scale * sqrt(variance)),
    relative_error = unname(mass[2L] / mass[1L]),
    log_relative_tail_bound = unname(log_tail - log_mass))
}

run_adaptive_quadrature_audit <- function(output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  orders <- c(15L, 31L, 61L)
  basic <- expand.grid(n = c(4L, 100L, 1000L), difficulty = c(-16, 0, 8, 16),
                       pattern = c("balanced", "high", "low"), stringsAsFactors = FALSE)
  basic$model <- "RSM"
  basic$prior <- "standard"
  basic$weights <- "unit"
  basic$family <- "repeated"
  heterogeneous <- expand.grid(n = c(12L, 240L), difficulty = 0,
    pattern = c("balanced", "high"), model = c("RSM", "PCM", "GPCM"),
    prior = c("narrow", "wide"), weights = c("unit", "fractional"),
    stringsAsFactors = FALSE)
  heterogeneous$family <- "heterogeneous"
  cases <- rbind(basic, heterogeneous)
  results <- vector("list", nrow(cases))
  for (i in seq_len(nrow(cases))) {
    spec <- cases[i, ]
    n <- spec$n
    score <- switch(spec$pattern, balanced = rep(0:3, length.out = n),
                    high = rep(3L, n), low = rep(0L, n))
    owner <- rep(1:3, length.out = n)
    cfg <- list(model = spec$model, n_cat = 4L, n_person = 1L)
    owned <- matrix(c(-1.2, 0.3, 0.9, -0.4, -0.1, 0.5, -0.8, 0.7, 0.1),
                    nrow = 3L, byrow = TRUE)
    params <- list(steps = c(-1, 0.2, 0.8), steps_mat = owned, slopes = c(0.5, 1, 2))
    base <- rep(c(-2, 0.3, 1.7), length.out = n)
    if (spec$family == "repeated") {
      params$steps <- c(0, 0, 0)
      base <- rep(-spec$difficulty, n)
    }
    weight <- if (spec$weights == "unit") rep(1, n) else rep(c(0.25, 0, 1.75, 3), length.out = n)
    mu <- switch(spec$prior, standard = 0, narrow = -1.5, wide = 2)
    sigma <- switch(spec$prior, standard = 1, narrow = 0.4, wide = 2.5)
    population <- list(active = TRUE, design_matrix = matrix(1, 1L, 1L),
                       coefficients = mu, sigma2 = sigma^2, person_lookup = 1L)
    idx <- list(person = rep(1L, n), score_k = score, weight = weight,
                step_idx = owner, slope_idx = owner)
    steps <- if (spec$model == "RSM") matrix(params$steps, n, 3L, byrow = TRUE) else owned[owner, ]
    slope <- if (spec$model == "GPCM") params$slopes[owner] else rep(1, n)
    reference <- aq_continuous_reference(score, base, steps, slope, weight, mu, sigma)
    refinement <- aq_continuous_reference(score, base, steps, slope, weight, mu, sigma, limit = 64)
    stopifnot(max(abs(reference[1:3] - refinement[1:3])) < 1e-8,
              reference["relative_error"] < 1e-9,
              reference["log_relative_tail_bound"] < log(1e-12))
    review <- mfrmr:::mfrmr_adaptive_quadrature_review(
      idx, cfg, params, mfrmr:::gauss_hermite_normal(301L), "P", orders,
      population_spec = population, base_eta = base
    )
    results[[i]] <- data.frame(case = i, spec[rep(1L, nrow(review)), ], review,
      reference_log_marginal = reference["log_marginal"],
      reference_eap = reference["eap"], reference_sd = reference["sd"],
      adaptive_log_marginal_error = abs(review$AdaptiveLogMarginal - reference["log_marginal"]),
      adaptive_eap_error = abs(review$AdaptiveEAP - reference["eap"]),
      adaptive_sd_error = abs(review$AdaptivePosteriorSD - reference["sd"]),
      fixed_log_marginal_error = abs(review$FixedLogMarginal - reference["log_marginal"]),
      fixed_eap_error = abs(review$FixedEAP - reference["eap"]),
      fixed_sd_error = abs(review$FixedPosteriorSD - reference["sd"]),
      reference_refinement_change = max(abs(reference[1:3] - refinement[1:3])),
      reference_relative_error = reference["relative_error"],
      reference_log_relative_tail_bound = reference["log_relative_tail_bound"],
      row.names = NULL)
  }
  results <- do.call(rbind, results)
  write.csv(results, file.path(output_dir, "conditions.csv"), row.names = FALSE)
  stopifnot(all(results$Status == "computed"))
  print(aggregate(results[c("adaptive_log_marginal_error", "adaptive_eap_error", "adaptive_sd_error")],
                  results[c("family", "model", "AdaptiveNodes")], max), digits = 5)
  invisible(results)
}
