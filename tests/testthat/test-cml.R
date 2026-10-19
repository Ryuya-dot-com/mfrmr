cml_example <- function() {
  patterns <- as.matrix(expand.grid(rep(list(0:2), 4L)))
  patterns <- patterns[rep(seq_len(nrow(patterns)), 1L + 2L * (patterns[, 1] == 2) +
    (patterns[, 2] == 0)), , drop = FALSE]
  data.frame(Person = rep(sprintf("P%03d", seq_len(nrow(patterns))), each = 4L),
    Rater = rep(c("A", "A", "B", "B"), nrow(patterns)),
    Item = rep(c("X", "Y", "X", "Y"), nrow(patterns)), Score = as.vector(t(patterns)))
}

cml_problem_for <- function(data, model = "RSM", owner = NULL, positive = NULL, interactions = NULL) {
  prep <- prepare_mfrm_data(data, "Person", c("Rater", "Item"), "Score",
    rating_min = 0, rating_max = 2, keep_original = TRUE)
  specs <- build_facet_interaction_specs(prep, interactions,
    min_obs_per_interaction = 1, interaction_policy = "silent")
  built <- build_estimation_config(prep, model, "CML", owner, NULL,
    interaction_specs = specs, weight_col = NULL,
    facet_signs = build_facet_signs(prep$facet_names, positive)$signs,
    positive_facets = positive, noncenter_facet = "Person", dummy_facets = NULL,
    anchor_df = NULL, group_anchor_df = NULL)
  idx <- build_indices(prep, owner, interaction_specs = specs)
  list(problem = mfrmr_cml_problem(prep, idx, built$config, built$sizes),
    prep = prep, idx = idx, config = built$config, sizes = built$sizes)
}

cml_enumerate <- function(features, par) {
  patterns <- as.matrix(expand.grid(lapply(features, function(x) seq_len(nrow(x)))))
  stats <- t(apply(patterns, 1L, function(row) {
    Reduce(`+`, lapply(seq_along(row), function(j) features[[j]][row[j], ]))
  }))
  total <- rowSums(patterns - 1L)
  lapply(0:max(total), function(s) {
    T <- stats[total == s, , drop = FALSE]
    eta <- drop(T %*% par); w <- exp(eta - max(eta)); w <- w / sum(w)
    mu <- drop(crossprod(w, T))
    list(logz = max(eta) + log(sum(exp(eta - max(eta)))), means = mu,
      covariance = crossprod(sweep(T, 2L, mu) * sqrt(w)))
  })
}

test_that("CML ESF, score and information agree with enumeration and finite differences", {
  d <- cml_example()
  for (model in c("RSM", "PCM")) for (positive in list(NULL, "Rater")) {
    b <- cml_problem_for(d, model, if (model == "PCM") "Item", positive)
    prob <- b$problem; par <- seq(-.4, .3, length.out = prob$parameters)
    x <- prob$groups[[1L]]$features
    actual <- mfrmr_cml_esf(x, par, TRUE); exact <- cml_enumerate(x, par)
    expect_equal(actual$logz, vapply(exact, `[[`, numeric(1), "logz"), tolerance = 1e-12)
    expect_equal(actual$means, do.call(rbind, lapply(exact, `[[`, "means")), tolerance = 1e-12)
    for (s in seq_along(exact)) expect_equal(actual$covariance[, , s], exact[[s]]$covariance, tolerance = 1e-12)
    at <- mfrmr_cml_evaluate(prob, par, TRUE)
    step <- diag(prob$parameters) * 1e-5
    gd <- vapply(seq_along(par), function(j)
      (mfrmr_cml_evaluate(prob, par + step[, j])$value -
         mfrmr_cml_evaluate(prob, par - step[, j])$value) / 2e-5, numeric(1))
    hd <- vapply(seq_along(par), function(j)
      (mfrmr_cml_evaluate(prob, par + step[, j])$gradient -
         mfrmr_cml_evaluate(prob, par - step[, j])$gradient) / 2e-5, numeric(length(par)))
    expect_equal(at$gradient, gd, tolerance = 1e-7)
    expect_equal(at$information, hd, tolerance = 1e-7)
    # Independent native category logits, rather than a second use of the map.
    expanded <- expand_params(par, b$sizes, b$config)
    for (j in seq_along(x)) {
      # Cell order is the native Rater:Item integer order, sorted by roster.
      at_row <- which(b$idx$facets$Rater == c(1, 1, 2, 2)[j] &
        b$idx$facets$Item == c(1, 2, 1, 2)[j])[1L]
      eta <- sum(vapply(b$config$facet_names, function(f)
        b$config$facet_signs[[f]] * expanded$facets[[f]][b$idx$facets[[f]][at_row]], numeric(1)))
      steps <- if (model == "RSM") expanded$steps else expanded$steps_mat[b$idx$step_idx[at_row], ]
      expect_equal(drop(x[[j]] %*% par), c(0, cumsum(eta - steps)), tolerance = 1e-12)
    }
  }
  # Log recursion stays finite where exponentiating category weights would overflow.
  stable <- mfrmr_cml_esf(list(matrix(c(0, 1, 2), ncol = 1), matrix(c(0, -1, 2), ncol = 1)), 1000, TRUE)
  expect_true(all(is.finite(unlist(stable))))
})

test_that("native CML fits expose conditional covariance and reusable facet intervals", {
  skip_if_not_installed("lpSolve")
  d <- cml_example()
  for (model in c("RSM", "PCM")) {
    fit <- fit_mfrm(d, "Person", c("Rater", "Item"), "Score", method = "CML",
      model = model, step_facet = if (model == "PCM") "Item", category_policy = "preserve")
    expect_s3_class(fit, "mfrm_cml_fit")
    expect_false(inherits(fit, "mfrm_fit"))
    expect_equal(fit$checks$boundary$state, "no_recession_detected")
    expect_lt(fit$checks$gradient_max, 1e-4)
    expect_equal(unname(fit$information %*% vcov(fit)), diag(length(fit$opt$par)), tolerance = 1e-9)
    expect_equal(as.numeric(logLik(fit)), -fit$opt$value)
    s <- summary(fit)
    expect_true(all(is.finite(s$locations$SE)))
    expect_true(all(is.finite(s$steps$SE)))
    C <- matrix(c(1, -1), 1, dimnames = list("A_minus_B", c("A", "B")))
    ci <- mfrm_facet_intervals(fit, "Rater", C)
    expect_error(mfrm_results(fit), "does not support CML fits.*summary\\(fit\\)")
    expect_error(mfrm_results(fit, intervals = ci), "plot\\(ci\\).*saveRDS")
    expect_equal(ci$table$Estimate, unname(2 * fit$facets$others$Estimate[1L]))
    expect_equal(ci$covariance, ci$target_jacobian %*% vcov(fit) %*% t(ci$target_jacobian))
    expect_s3_class(plot(ci, draw = FALSE), "mfrm_plot_data")
    notes <- plot(ci, draw = FALSE)$data$subtitle
    expect_match(notes, "Conditional information")
    expect_false(grepl("Weak information", notes))
    if (requireNamespace("ggplot2", quietly = TRUE)) {
      graphic <- ggplot2::ggplot_build(as_ggplot(plot(ci, draw = FALSE)))
      expect_true(all(!is.na(graphic$data[[1L]]$colour)))
      expect_true(all(!is.na(graphic$data[[1L]]$linetype)))
    }
    path <- tempfile(fileext = ".rds"); on.exit(unlink(path), add = TRUE)
    saveRDS(list(fit = fit, ci = ci), path)
    saved <- readRDS(path)
    expect_identical(summary(saved$fit), s)
    expect_identical(mfrm_facet_intervals(saved$fit, "Rater", C)$table, ci$table)
    expect_error(mfrm_facet_intervals(fit, "Rater", C, scale = "standardized"), "does not estimate a population SD")
    expect_error(mfrm_facet_intervals(fit, "Rater", method = "sandwich"), "require method")
    expect_error(mfrm_facet_intervals(fit, "Rater", level = 1), "0 < level")
    for (level in list(matrix(.95), structure(.95, class = "confidence")))
      expect_error(mfrm_facet_intervals(fit, "Rater", level = level), "0 < level")
    expect_identical(mfrm_facet_intervals(fit, "Rater", C, level = c(confidence = .95)), ci)
    high_level <- 1 - .Machine$double.eps / 2
    high <- mfrm_facet_intervals(fit, "Rater", C, level = high_level)$table
    critical <- (high$Upper - high$Estimate) / high$SE
    expect_equal(pnorm(critical, lower.tail = FALSE, log.p = TRUE), log1p(-high_level) - log(2))
    expect_true(is.finite(high$Lower) && is.finite(high$Upper))
    scaled <- mfrm_facet_intervals(fit, "Rater", C * 1e-100)$table
    expect_equal(scaled$SE / 1e-100, ci$table$SE, tolerance = 1e-12)
    expect_equal(scaled$Lower / 1e-100, ci$table$Lower, tolerance = 1e-12)
    expect_error(mfrm_facet_intervals(fit, "Rater", C * 1e-200), "positive representable variance")
    fixed <- mfrm_facet_intervals(fit, "Rater", C * 0 + 1)$table
    expect_equal(fixed$Status, "fixed")
    expect_equal(fixed$SE, 0)
    expect_true(is.na(fixed$Lower))
    expect_error(mfrm_facet_intervals(fit, "Rater", C * 1e308), "must be finite")
  }
})

test_that("CML refuses unidentified, boundary, unsupported and unconverged models", {
  skip_if_not_installed("lpSolve")
  d <- cml_example()
  fit <- function(data = d, ...) fit_mfrm(data, "Person", c("Rater", "Item"), "Score",
    method = "CML", category_policy = "preserve", ...)
  expect_error(fit(model = "GPCM"), "RSM/PCM")
  expect_error(fit(population_formula = ~1), "does not accept.*population_formula")
  expect_error(fit(anchors = NULL), "does not accept.*anchors")
  expect_error(fit(fit_scope = "comparisons"), "Supply the comparison_review")
  expect_error(fit(model = "PCM"), "requires .step_facet.")
  expect_error(fit(maxit = 1), "stationary")
  weighted <- d; weighted$W <- 2
  expect_error(fit(weighted, weight = "W"), "unit weights")
  repeated <- rbind(d, d)
  expect_error(suppressWarnings(fit(repeated)), "resolution of repeated rating cells")
  independent <- fit(repeated, repeated_ratings = "independent")
  expect_s3_class(independent, "mfrm_cml_fit")
  expect_equal(nrow(independent$prep$data), nrow(repeated))
  nested <- d; nested$Rater <- ifelse(as.integer(factor(nested$Person)) %% 2 == 0, "A", "B")
  expect_error(suppressWarnings(fit(nested, repeated_ratings = "independent")), "conditioned CML model is unidentified")
  separated <- d; separated$Score[separated$Rater == "A"] <- 2
  expect_error(fit(separated), "recession_detected")
  extreme <- d; extreme$Score <- 2 * (as.integer(factor(d$Person)) %% 2)
  expect_error(fit(extreme, rating_min = 0, rating_max = 2), "conditioned CML model is unidentified")
})

test_that("CML preserves missing rosters, score origins, interactions and extreme accounting", {
  skip_if_not_installed("lpSolve")
  d <- cml_example()
  fit <- function(data, ...) fit_mfrm(data, "Person", c("Rater", "Item"), "Score",
    method = "CML", category_policy = "preserve", ...)
  missing <- d
  missing$Score[seq(4L, nrow(d), by = 28L)] <- NA
  a <- fit(missing, model = "PCM", step_facet = "Rater")
  b <- fit(missing[nrow(missing):1L, ], model = "PCM", step_facet = "Rater")
  expect_equal(a$opt$par, b$opt$par, tolerance = 1e-8)
  shifted <- missing; shifted$Score <- shifted$Score + 1
  c <- fit(shifted, model = "PCM", step_facet = "Rater", rating_min = 1, rating_max = 3)
  expect_equal(a$opt$par, c$opt$par, tolerance = 1e-8)
  expect_equal(a$covariance, c$covariance, tolerance = 1e-8)
  extreme <- with(a$person_totals, Person[Extreme])
  removed <- fit(missing[!missing$Person %in% extreme, ], model = "PCM", step_facet = "Rater")
  expect_equal(a$opt$par, removed$opt$par, tolerance = 1e-8)
  expect_equal(a$covariance, removed$covariance, tolerance = 1e-8)
  interaction <- fit(d, facet_interactions = list(c("Rater", "Item")))
  expect_true(all(is.finite(summary(interaction)$interactions$SE)))
  expect_equal(sum(interaction$interactions$effects$Estimate), 0, tolerance = 1e-12)
  expect_equal(sort(a$person_totals$Person), sort(unique(d$Person)))
  if (requireNamespace("eRm", quietly = TRUE)) {
    full <- cml_problem_for(d, "PCM", "Rater")
    W <- do.call(rbind, lapply(full$problem$groups[[1L]]$features, function(x) x[-1L, , drop = FALSE]))
    reference <- eRm::LPCM(matrix(missing$Score, ncol = 4L, byrow = TRUE), W = W, sum0 = FALSE)
    expect_lt(abs(-a$opt$value - reference$loglik), 1e-7)
    expect_lt(max(abs(a$opt$par - reference$etapar)), 1e-5)
    expect_lt(max(abs(a$covariance - solve(reference$hessian))), 1e-6)
  }
})

test_that("conditional DAG recession checks agree with enumerated support", {
  skip_if_not_installed("lpSolve")
  d <- cml_example()
  separated <- d; separated$Score[separated$Rater == "A"] <- 2
  for (data in list(d, separated)) {
    prob <- cml_problem_for(data)$problem
    zero <- mfrmr_cml_evaluate(prob, numeric(prob$parameters), TRUE)
    actual <- mfrmr_cml_boundary(prob, zero$gradient)
    features <- prob$groups[[1L]]$features
    patterns <- as.matrix(expand.grid(rep(list(0:2), 4L)))
    stats <- t(apply(patterns, 1, function(y)
      Reduce(`+`, lapply(seq_along(y), function(j) features[[j]][y[j] + 1L, ]))))
    obs <- matrix(data$Score, ncol = 4L, byrow = TRUE)
    constraints <- do.call(rbind, lapply(seq_len(nrow(obs)), function(i) {
      z <- Reduce(`+`, lapply(seq_len(4L), function(j) features[[j]][obs[i, j] + 1L, ]))
      sweep(stats[rowSums(patterns) == sum(obs[i, ]), , drop = FALSE], 2, z, function(a, b) b - a)
    }))
    reference <- lpSolve::lp("max", c(-zero$gradient, zero$gradient),
      rbind(cbind(constraints, -constraints), 1),
      c(rep(">=", nrow(constraints)), "<="), c(rep(0, nrow(constraints)), 1))
    expect_equal(reference$status, 0)
    expect_equal(actual$objective, reference$objval, tolerance = 1e-8)
    expect_equal(actual$state, if (reference$objval > 1e-7) "recession_detected" else "no_recession_detected")
  }
})

test_that("matched eRm LPCM independently reproduces multifacet CML fits and information", {
  skip_if_not_installed("lpSolve"); skip_if_not_installed("eRm")
  d <- cml_example()
  for (model in c("RSM", "PCM")) {
    fit <- fit_mfrm(d, "Person", c("Rater", "Item"), "Score", method = "CML",
      model = model, step_facet = if (model == "PCM") "Item", category_policy = "preserve")
    b <- cml_problem_for(d, model, if (model == "PCM") "Item")
    W <- do.call(rbind, lapply(b$problem$groups[[1L]]$features, function(x) x[-1L, , drop = FALSE]))
    X <- matrix(d$Score, ncol = 4L, byrow = TRUE)
    reference <- eRm::LPCM(X, W = W, sum0 = FALSE)
    expect_equal(unname(reference$W), W)
    expect_equal(-fit$opt$value, reference$loglik, tolerance = 1e-8)
    expect_lt(max(abs(fit$opt$par - reference$etapar)), 1e-5)
    # eRm 1.0-10 uses nlm's finite-difference Hessian; the exact information
    # above is separately checked against enumeration and score derivatives.
    expect_lt(max(abs(vcov(fit) - solve(reference$hessian))), 1e-6)
  }
})
