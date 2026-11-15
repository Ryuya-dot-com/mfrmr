test_that("native adaptive mode limits retain the bracketed R solution", {
  config <- list(model = "GPCM", n_cat = 2L, n_person = 1L)
  for (score in 0:1) for (weight in c(1, 1e40)) {
    slope <- if (weight == 1) 1 else 1e-20
    native <- mfrmr:::mfrm_cpp_adaptive_quad_basis(
      2L, 2L, 1L, c(0L, 1L), 1L, as.integer(score), weight, 0,
      numeric(), matrix(c(0, 0), 1L), 1L, slope, 1L, 0, 1,
      0, 0, stats::dnorm(0, log = TRUE), matrix(0, 1L), matrix(0, 1L)
    )
    expect_identical(native$error_code, if (weight == 1) 0L else 5L)
    # This finite extreme input exercises bracket exhaustion, not a proposed
    # rating design. Solve in scaled coordinates to obtain an independent root.
    root <- stats::uniroot(function(t) weight * slope^2 *
      (score - stats::plogis(t)) - t, c(-2, 2), tol = 1e-14)$root / slope
    idx <- list(person = 1L, score_k = as.integer(score), weight = weight,
      step_idx = 1L, slope_idx = 1L)
    params <- list(steps_mat = matrix(0, 1L), slopes = slope)
    withr::local_options(mfrmr.use_cpp11_backend = FALSE)
    reference <- mfrmr:::mfrmr_adaptive_quadrature_basis(
      idx, config, params, list(nodes = 0, weights = 1), base_eta = 0)
    options(mfrmr.use_cpp11_backend = TRUE)
    actual <- mfrmr:::mfrmr_adaptive_quadrature_basis(
      idx, config, params, list(nodes = 0, weights = 1), base_eta = 0)
    expect_equal(actual$nodes, reference$nodes, tolerance = 1e-12)
    expect_equal(actual$log_weights, reference$log_weights, tolerance = 1e-12)
    expect_lt(abs(actual$nodes[1L] - root) / max(1, abs(root)), 1e-12)
  }
})

test_that("unfinished native adaptive evaluation falls back with all summaries", {
  fit <- make_toy_fit(method = "MML", maxit = 30L)
  config <- fit$config
  config$estimation_control$mml_integration <- "adaptive"
  sizes <- mfrmr:::build_param_sizes(config)
  idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet,
                               config$interaction_specs)
  withr::local_options(mfrmr.use_cpp11_backend = FALSE)
  expected <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(
    idx, config, sizes, 7L, include_person_summaries = TRUE)(fit$opt$par)
  calls <- 0L
  error_code <- 5L
  testthat::local_mocked_bindings(mfrm_cpp_adaptive_mml_eval = function(...) {
    calls <<- calls + 1L
    list(error_code = error_code, error_message = "Native evaluation failed.")
  }, .package = "mfrmr")
  options(mfrmr.use_cpp11_backend = TRUE)
  actual <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(
    idx, config, sizes, 7L, include_person_summaries = TRUE)(fit$opt$par)
  expect_identical(calls, 1L)
  expect_equal(actual, expected, tolerance = 1e-11)
  error_code <- 4L
  expect_error(mfrmr:::mfrmr_make_adaptive_mml_evaluator(
    idx, config, sizes, 7L)(fit$opt$par), class = "mfrmr_adaptive_quadrature_numeric_error")
})

test_that("sparse adaptive bases retain prior-only Persons and independent moments", {
  withr::local_options(mfrmr.use_cpp11_backend = TRUE)
  rule <- mfrmr:::gauss_hermite_normal(121L)
  # Person 1 has no rows; Person 5 has only zero-weight rows. The others have
  # one or two ratings, extreme scores or missing local categories.
  idx <- list(person = c(2L, 3L, 4L, 4L, 5L, 5L, 6L, 6L),
    score_k = c(0L, 3L, 0L, 3L, 1L, 2L, 1L, 1L),
    weight = c(1, 1, .5, 1.75, 0, 0, .25, 1),
    step_idx = c(1L, 2L, 1L, 2L, 1L, 2L, 2L, 2L),
    slope_idx = c(1L, 2L, 1L, 2L, 1L, 2L, 2L, 2L))
  base <- c(-1, 1, -.5, .3, -2, 2, 0, .4)
  mu <- c(-.8, 0, .8, 1.4, -1.2, .3)
  params <- list(steps = c(-.8, 0, .8),
    steps_mat = rbind(c(-1.2, .3, .9), c(-.4, -.1, .5)), slopes = c(.6, 1.5))
  errors <- moment_errors <- numeric()
  for (model in c("RSM", "PCM", "GPCM")) for (sigma in c(.2, 1, 3)) {
    config <- list(model = model, n_cat = 4L, n_person = 6L)
    population <- list(active = TRUE, design_matrix = diag(6),
      coefficients = mu, sigma2 = sigma^2, person_lookup = 1:6)
    options(mfrmr.use_cpp11_backend = FALSE)
    ref <- mfrmr:::mfrmr_adaptive_quadrature_basis(idx, config, params, rule,
      base, population_spec = population)
    options(mfrmr.use_cpp11_backend = TRUE)
    got <- mfrmr:::mfrmr_adaptive_quadrature_basis(idx, config, params, rule,
      base, population_spec = population)
    for (field in c("nodes", "log_weights")) {
      expect_identical(attributes(got[[field]]), attributes(ref[[field]]))
      errors[paste(model, sigma, field)] <- max(abs(got[[field]] - ref[[field]]) /
        pmax(1, abs(ref[[field]])))
    }
    for (person in c(1L, 5L)) {
      errors[paste(model, sigma, person, "prior_nodes")] <- max(abs(
        got$nodes[person, ] - (mu[person] + sigma * rule$nodes)))
      errors[paste(model, sigma, person, "prior_weights")] <- max(abs(
        got$log_weights[person, ] - log(rule$weights)))
    }
    if (sigma != 1) next
    # Direct category probabilities and continuous integration are independent
    # of the package's likelihood, mode solver and moment formulas.
    for (person in 1:6) {
      rows <- which(idx$person == person & idx$weight > 0)
      loglik <- function(theta) vapply(theta, function(t) sum(vapply(rows, function(i) {
        steps <- if (model == "RSM") params$steps else params$steps_mat[idx$step_idx[i], ]
        slope <- if (model == "GPCM") params$slopes[idx$slope_idx[i]] else 1
        lp <- slope * ((0:3) * (base[i] + t) - c(0, cumsum(steps)))
        lp <- lp - max(lp)
        idx$weight[i] * (lp[idx$score_k[i] + 1L] - log(sum(exp(lp))))
      }, 0)), 0)
      density <- function(z) exp(loglik(mu[person] + z) + dnorm(z, log = TRUE))
      mass <- integrate(density, -Inf, Inf, rel.tol = 1e-11, abs.tol = 1e-12)$value
      mean_z <- integrate(function(z) z * density(z), -Inf, Inf,
                          rel.tol = 1e-11, abs.tol = 1e-12)$value / mass
      sd_z <- sqrt(integrate(function(z) (z - mean_z)^2 * density(z), -Inf, Inf,
                             rel.tol = 1e-11, abs.tol = 1e-12)$value / mass)
      nodes <- got$nodes[person, ]
      joint <- got$log_weights[person, ] + loglik(nodes)
      posterior <- exp(joint - max(joint))
      log_mass <- max(joint) + log(sum(posterior))
      posterior <- posterior / sum(posterior)
      eap <- sum(posterior * nodes)
      answer <- c(log_mass, eap, sqrt(sum(posterior * (nodes - eap)^2)))
      truth <- c(log(mass), mu[person] + mean_z, sd_z)
      moment_errors[paste(model, person)] <- max(abs(answer - truth) / pmax(1, abs(truth)))
    }
  }
  # Bound every coordinate, including zeros; do not average errors or round.
  expect_true(all(is.finite(errors)))
  expect_true(max(errors) <= 1e-12, info = names(errors)[which.max(errors)])
  expect_true(all(is.finite(moment_errors)))
  expect_true(max(moment_errors) <= 1e-8, info = names(moment_errors)[which.max(moment_errors)])
})

test_that("sparse adaptive scores preserve zero-weight and incomplete-pattern summaries", {
  withr::local_options(mfrmr.use_cpp11_backend = TRUE)
  errors <- numeric()
  for (model in c("RSM", "PCM", "GPCM")) {
    fit <- adaptive_api_fixture(model)$fit
    config <- fit$config
    prep <- fit$prep
    # Evaluate retained parameters on a sparse subdesign. This is not a claim
    # that the subdesign identifies all of the original free parameters.
    groups <- split(seq_len(nrow(prep$data)), prep$data$Person)
    rows <- unlist(lapply(seq_along(groups), function(i) {
      if (i == length(groups)) integer() else head(groups[[i]], 1L + i %% 2L)
    }), use.names = FALSE)
    prep$data <- prep$data[rows, , drop = FALSE]
    idx <- mfrmr:::build_indices(prep, config$step_facet, config$slope_facet,
                                 config$interaction_specs)
    idx$weight <- rep(c(.25, 1.75), length.out = length(idx$score_k))
    idx$weight[idx$person == 1L] <- 0
    sizes <- mfrmr:::build_param_sizes(config)
    for (reuse in c(FALSE, TRUE)) {
      ev <- mfrmr:::mfrmr_make_adaptive_mml_evaluator(idx, config, sizes, 7L,
        reuse_identical_patterns = reuse, include_person_summaries = TRUE)
      options(mfrmr.use_cpp11_backend = FALSE)
      ref <- ev(fit$opt$par)
      options(mfrmr.use_cpp11_backend = TRUE)
      got <- ev(fit$opt$par)
      expect_identical(got$per_person$PersonIndex, ref$per_person$PersonIndex)
      expect_identical(is.na(got$per_person), is.na(ref$per_person))
      for (field in c("value", "gradient", "per_person")) {
        a <- if (field == "per_person") as.matrix(got[[field]][, -1L]) else got[[field]]
        b <- if (field == "per_person") as.matrix(ref[[field]][, -1L]) else ref[[field]]
        expect_identical(attributes(a), attributes(b))
        errors[paste(model, reuse, field)] <- max(abs(a - b) / pmax(1, abs(b)))
      }
    }
  }
  expect_true(all(is.finite(errors)))
  expect_true(max(errors) <= 1e-12, info = names(errors)[which.max(errors)])
})

test_that("native adaptive bases resolve narrow and tail posteriors", {
  withr::local_options(mfrmr.use_cpp11_backend = TRUE)
  errors <- moment_errors <- numeric()
  rule <- mfrmr:::gauss_hermite_normal(61L)
  for (case in c("narrow", "tail")) for (model in c("RSM", "PCM", "GPCM")) {
    scores <- if (case == "narrow") rep(0:3, 250L) else rep(3L, 100L)
    difficulty <- if (case == "narrow") 0 else 16
    # Independent reference values also used by the original R-only review test.
    truth <- if (case == "narrow") c(-1389.8600406660846, 0, .028282562846515886) else
      c(-177.87927093394117, 17.903577120328180, .21878638089256411)
    idx <- list(person = rep(1L, length(scores)), score_k = scores,
      step_idx = rep(1L, length(scores)), slope_idx = rep(1L, length(scores)))
    config <- list(model = model, n_cat = 4L, n_person = 1L)
    params <- list(steps = c(0, 0, 0), steps_mat = matrix(0, 1L, 3L), slopes = 1)
    options(mfrmr.use_cpp11_backend = FALSE)
    ref <- mfrmr:::mfrmr_adaptive_quadrature_basis(idx, config, params, rule,
      rep(-difficulty, length(scores)))
    options(mfrmr.use_cpp11_backend = TRUE)
    got <- mfrmr:::mfrmr_adaptive_quadrature_basis(idx, config, params, rule,
      rep(-difficulty, length(scores)))
    for (field in c("nodes", "log_weights")) errors[paste(case, model, field)] <-
      max(abs(got[[field]] - ref[[field]]) / pmax(1, abs(ref[[field]])))
    ll <- vapply(as.vector(got$nodes), function(theta) {
      lp <- (0:3) * (theta - difficulty)
      lp <- lp - max(lp)
      sum(tabulate(scores + 1L, nbins = 4L) * lp) - length(scores) * log(sum(exp(lp)))
    }, 0)
    joint <- as.vector(got$log_weights) + ll
    w <- exp(joint - max(joint))
    log_mass <- max(joint) + log(sum(w))
    w <- w / sum(w)
    eap <- sum(w * got$nodes)
    moments <- c(log_mass, eap, sqrt(sum(w * (got$nodes - eap)^2)))
    moment_errors[paste(case, model)] <- max(abs(moments - truth))
  }
  expect_true(all(is.finite(errors)) && all(is.finite(moment_errors)))
  expect_true(max(errors) <= 1e-12, info = names(errors)[which.max(errors)])
  expect_true(max(moment_errors) <= 1e-8, info = names(moment_errors)[which.max(moment_errors)])
})
