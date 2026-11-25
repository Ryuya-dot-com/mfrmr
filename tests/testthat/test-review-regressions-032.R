test_that("slope intervals use log-scale covariance and remain positive", {
  d <- load_mfrmr_data("example_core")
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "GPCM",
                step_facet = "Criterion", slope_facet = "Criterion",
                spec = list(gpcm_mml_identification = "fixed_standard_normal"))
  idx <- grep("^LogSlope:", names(f$xi))
  for (kind in c("model", "sandwich")) {
    V <- vcov(f, se_type = kind)[idx, idx, drop = FALSE]
    # Last log-slope is the negative sum of the free coordinates.
    B <- rbind(diag(length(idx)), -1)
    se <- sqrt(diag(B %*% V %*% t(B)))
    expected <- exp(cbind(log(f$slopes$Estimate) - qnorm(.975) * se,
                          log(f$slopes$Estimate) + qnorm(.975) * se))
    ci <- confint(f, component = "slopes", se_type = kind)
    expect_equal(unname(ci), unname(expected), tolerance = 1e-10)
    expect_true(all(ci > 0))
    expect_equal(unname(confint(f, component = "slopes", se_type = kind, parm = 2)),
                 unname(expected[2, , drop = FALSE]))
  }
  p <- plot(f, type = "slopes")
  expect_equal(unname(as.matrix(p$data[c("Low", "High")])),
               unname(confint(f, component = "slopes")))
  f$converged <- FALSE
  for (type in c("slopes", "persons", "raters")) {
    p <- plot(f, type = type)
    expect_true(all(is.na(p$data$Low) & is.na(p$data$High)))
    expect_match(paste(attr(p, "mfrm_notes"), collapse = " "), "Intervals unavailable.*optimizer_not_converged")
    expect_gt(nrow(p$data), 0L)
  }
})

test_that("G-Study covariance agrees with Gaussian quadratic forms on unbalanced and replicated data", {
  set.seed(319)
  d <- expand.grid(Person = paste0("P", 1:8), Rater = paste0("R", 1:4))
  d$Score <- rep(rnorm(8, sd = 2), 4) + rep(rnorm(4), each = 8) + rnorm(32, sd = .5)
  unbalanced <- d[-c(1, 2, 3, 9, 10, 17, 25, 26, 27, 28), ]
  replicated <- rbind(unbalanced, transform(unbalanced[1:6, ], Score = Score + .2))
  for (x in list(d, unbalanced, replicated, replicated[sample(nrow(replicated)), ])) {
    g <- mfrm_g_study(x, scores = "Score", person = "Person", facets = "Rater", method = "urgenova")
    C <- lapply(c("Person", "Rater"), function(nm) outer(x[[nm]], x[[nm]], "==") * 1)
    C[[3L]] <- C[[1L]] * C[[2L]]
    if (anyDuplicated(x[c("Person", "Rater")])) C[[4L]] <- diag(nrow(x))
    A <- lapply(C, function(z) z / rowSums(z) - 1 / nrow(x))
    K <- sapply(C, function(z) vapply(A, function(a) sum(a * z), numeric(1)))
    inverse <- solve(K)
    raw <- drop(inverse %*% vapply(A, function(a) drop(crossprod(x$Score, a %*% x$Score)), numeric(1)))
    V <- Reduce(`+`, Map(function(z, v) z * v, C, pmax(0, raw)))
    Q <- outer(seq_along(A), seq_along(A), Vectorize(function(i, j) 2 * sum((A[[i]] %*% V) * t(A[[j]] %*% V))))
    expected <- inverse %*% Q %*% t(inverse)
    expect_equal(g$variance_components$RawEstimate, raw, tolerance = 1e-10)
    expect_equal(unname(vcov(g)), unname(expected), tolerance = 1e-10)
    expect_equal(g$variance_components$SE, sqrt(diag(expected)), tolerance = 1e-10)
  }
})

test_that("G-Study rejects unidentified designs, missing-error input and invalid D-Study counts", {
  d <- data.frame(Person = 1:8, Rater = 1:8, Score = 1:8)
  expect_error(mfrm_g_study(d, "Score", "Person", facets = "Rater", method = "urgenova"), "not identifiable")
  d <- expand.grid(Person = 1:8, Rater = 1:4)
  d$Score <- sin(seq_len(nrow(d))) + d$Person
  missing <- d; missing$Score[1] <- NA_real_
  expect_error(mfrm_g_study(missing, "Score", "Person", facets = "Rater", method = "urgenova", missing = "error"), "missing|Missing")
  g <- mfrm_g_study(d, "Score", "Person", facets = "Rater", method = "urgenova")
  for (n in c(0, -1, 1.5, Inf, NA_real_)) {
    expect_error(mfrm_d_study(g, data.frame(Rater = n)), "positive integer")
    expect_error(mfrm_g_study(d, "Score", "Person", facets = "Rater", method = "urgenova", d_study_grid = data.frame(Rater = n)), "positive integer")
  }
})

test_that("missing codes and documented category support reach the unified estimator", {
  d <- load_mfrmr_data("example_core")
  x <- d; x$Score[1] <- -1
  a <- fit_mfrm(x, "Person", c("Rater", "Criterion"), "Score", missing_codes = -1, rating_min = 1, rating_max = 4)
  b <- fit_mfrm(d[-1, ], "Person", c("Rater", "Criterion"), "Score")
  expect_equal(a$n_obs, nrow(d) - 1L)
  expect_equal(a$xi, b$xi)
  x <- d; x$Rater[1] <- NA
  expect_equal(fit_mfrm(x, "Person", c("Rater", "Criterion"), "Score")$n_obs, nrow(d) - 1L)
  support <- data.frame(Level = sort(unique(d$Criterion)), Min = 1, Max = 4)
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion", category_support = support)
  expect_equal(f$encoding$step_cat_max, rep(3L, 4))
})

test_that("nested comparisons require matching responses, weights and usable likelihood fits", {
  d <- load_mfrmr_data("example_core")
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score")
  p <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion")
  expect_identical(anova(f, p)$comparison_basis$lrt_status, "computed")
  set.seed(42)
  x <- d; x$Score <- sample(x$Score)
  other <- fit_mfrm(x, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion")
  stopped <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion", maxit = 1)
  weighted <- p; weighted$encoding$weight[1] <- 2
  for (bad in list(other, stopped, weighted)) {
    expect_warning(z <- anova(f, bad), "identical observations")
    expect_identical(z$comparison_basis$lrt_status, "ineligible")
    expect_null(z$lrt)
  }
  worse <- p; worse$loglik <- f$loglik - 1
  expect_warning(z <- anova(f, worse), "lower maximized likelihood")
  expect_null(z$lrt)
})

test_that("structural likelihood boundaries propagate into classification and saved fits", {
  skip_if_not_installed("lpSolve")
  d <- expand.grid(Person = paste0("P", 1:20), Rater = paste0("R", 1:3))
  d$Score <- ifelse(d$Rater == "R1", 3, rep(0:2, length.out = nrow(d)))
  expect_warning(f <- fit_mfrm(d, "Person", "Rater", "Score", rating_min = 0, rating_max = 3), "No finite structural MML")
  expect_true(f$boundary_audit$detected)
  expect_false(f$summary$InferenceReady)
  expect_error(classification_table(f), "review|ready|readiness")
  expect_error(confint(f), "not ready")
  expect_false(classification_table(f, readiness_policy = "review")$source$ready)
  path <- tempfile(fileext = ".rds"); on.exit(unlink(path))
  saveRDS(f, path)
  expect_identical(readRDS(path)$boundary_audit, f$boundary_audit)
  old <- f; old$boundary_audit <- old$readiness <- NULL
  expect_false(summary(old)$readiness$ready)
  expect_true("structural_likelihood_boundary" %in% summary(old)$readiness$reason_codes)
})

test_that("EAP reliability and WLE diagnostics use their stated score definitions", {
  d <- load_mfrmr_data("example_operational")
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score")
  r <- diagnose_mfrm(f)$reliability
  v <- var(f$person$EAP); s <- mean(f$person$PosteriorSD^2)
  expect_equal(r$ModelReliability[r$Facet == "Person"], v / (v + s))
  expect_equal(f$population$eap_reliability, v / (v + s))
  d <- load_mfrmr_data("example_core")
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = "PCM", step_facet = "Criterion", person_score = "WLE")
  pr <- predict(f, type = "probs")
  expected <- drop(pr %*% 1:4)
  variance <- drop(pr %*% (1:4)^2) - expected^2
  residual <- d$Score - expected
  for (p in seq_len(f$n_person)) {
    ii <- f$encoding$person0 + 1L == p
    expect_equal(f$person$ExpAvg[p], mean(expected[ii]), tolerance = 1e-10)
    expect_equal(f$person$InfitMnSq[p], sum(residual[ii]^2) / sum(variance[ii]), tolerance = 1e-10)
  }
  # On this centered balanced PCM, neutral facet locations give the fair score.
  neutral <- f; neutral$facets$Estimate[] <- 0
  fair <- predict(neutral)
  expected_fair <- vapply(seq_len(f$n_person), function(p) mean(fair[f$encoding$person0 + 1L == p]), numeric(1))
  expect_equal(f$person$FairM, expected_fair, tolerance = 1e-10)
  expect_equal(f$person$FairZ, expected_fair, tolerance = 1e-10)
  for (nm in unique(f$facets$Facet)) for (lev in unique(f$facets$Level[f$facets$Facet == nm])) {
    ii <- d[[nm]] == lev
    row <- f$facets[f$facets$Facet == nm & f$facets$Level == lev, ]
    expect_equal(row$InfitMnSq, sum(residual[ii]^2) / sum(variance[ii]), tolerance = 1e-10)
  }
})

test_that("prediction delta SE matches numerical perturbations for slopes and interactions", {
  d <- load_mfrmr_data("example_core")
  cases <- list(
    list(model = "PCM", step_facet = "Criterion"),
    list(model = "GPCM", step_facet = "Criterion", slope_facet = c("Criterion", "Rater"), spec = list(slope_reference = "Criterion")),
    list(model = "GPCM", step_facet = "Criterion", slope_facet = "Criterion", spec = list(slope_type = "ability_only")),
    list(model = "RSM", facet_interactions = list(c("Rater", "Criterion")))
  )
  for (args in cases) {
    f <- do.call(fit_mfrm, c(list(data = d, person = "Person", facets = c("Rater", "Criterion"), score = "Score"), args))
    nd <- expand.grid(theta = c(-1, 0, 1), Rater = c("R01", "R04"), Criterion = c("Content", "Language"))
    # Perturb the physical facet, step and log-slope parameters along each free coordinate.
    perturb <- function(j, h) {
      z <- f; e <- f$encoding; l <- f$xi_layout
      for (k in seq_along(e$facets)) {
        pos <- match(j, l$facet_start[k] + seq_len(l$facet_len[k]))
        if (!is.na(pos)) {
          delta <- mfrmr:::.mfrm_fast_facet_basis(e, k)[, pos] * h
          if (k <= length(e$base_facets)) {
            ii <- z$facets$Facet == e$facets[k]
            z$facets$Estimate[ii] <- z$facets$Estimate[ii] + delta
          } else z$interactions$Estimate[z$interactions$Interaction == e$facets[k]] <- z$interactions$Estimate[z$interactions$Interaction == e$facets[k]] + delta
        }
      }
      pos <- match(j, l$step_start + seq_len(l$step_len))
      if (!is.na(pos)) {
        B <- mfrmr:::.mfrm_fast_step_basis(e, l)
        K <- e$n_cat - 1L
        for (g in seq_len(e$n_step_groups)) z$step_cumulative[g, ] <- z$step_cumulative[g, ] + c(0, cumsum(B[(g - 1L) * K + seq_len(K), pos] * h))
      }
      for (s in seq_len(e$n_slope_facets)) {
        pos <- match(j, l$slope_offset[s] + seq_len(e$slope_q[s]))
        if (!is.na(pos)) {
          ii <- z$slopes$Facet == e$slope_facets[s]
          z$slopes$Estimate[ii] <- z$slopes$Estimate[ii] * exp(e$slope_B[[s]][, pos] * h)
        }
      }
      predict(z, nd)
    }
    G <- vapply(seq_along(f$xi), function(j) (perturb(j, 1e-5) - perturb(j, -1e-5)) / 2e-5, numeric(nrow(nd)))
    expected <- sqrt(rowSums((G %*% f$xi_covariance_model) * G))
    expect_true(all(is.finite(expected)))
    expect_equal(predict(f, nd, se.fit = TRUE)$se.fit, expected, tolerance = 1e-8)
  }
})

test_that("prediction SE includes estimated steps when every facet is anchored", {
  d <- load_mfrmr_data("example_core")
  anchors <- do.call(rbind, lapply(c("Rater", "Criterion"), function(nm) data.frame(Facet = nm, Level = unique(d[[nm]]), Anchor = 0)))
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", anchors = anchors)
  nd <- data.frame(theta = c(-1, 0, 1), Rater = d$Rater[1], Criterion = d$Criterion[1])
  grad <- vapply(seq_len(nrow(f$steps)), function(j) {
    plus <- minus <- f
    cols <- (j + 1L):ncol(f$step_cumulative)
    plus$step_cumulative[1, cols] <- plus$step_cumulative[1, cols] + 1e-5
    minus$step_cumulative[1, cols] <- minus$step_cumulative[1, cols] - 1e-5
    (predict(plus, nd) - predict(minus, nd)) / 2e-5
  }, numeric(nrow(nd)))
  V <- vcov(f, component = "steps", se_type = "model")
  expected <- sqrt(rowSums((grad %*% V) * grad))
  expect_equal(predict(f, nd, se.fit = TRUE)$se.fit, expected, tolerance = 1e-8)
  expect_true(all(expected > 0))
})

test_that("common reference plans affect scores and retain normalized weights", {
  d <- load_mfrmr_data("example_core")
  f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score")
  panel <- data.frame(Rater = c("R01", "R04"), Criterion = c("Content", "Language"), Weight = c(1, 3))
  a <- fair_average_table(f, reference_plan = panel)
  b <- fair_average_table(f, reference_plan = panel[1, ])
  expect_equal(a$reference_plan$NormalizedWeight, c(.25, .75))
  expected <- vapply(f$person$Estimate, function(theta) sum(predict(f, transform(panel, theta = theta)) * c(.25, .75)), numeric(1))
  expect_equal(a$reference_scores$Estimate, expected)
  expect_gt(max(abs(a$reference_scores$Estimate - b$reference_scores$Estimate)), .01)
  expect_true(all(a$reference_scores$Units == "original_score"))
  expect_error(fair_average_table(f, reference_plan = transform(panel, Rater = "unknown")), "Unknown")
  expect_error(fair_average_table(f, reference_plan = transform(panel, Weight = 0)), "positive")
})

test_that("agreement rejects repeated ratings instead of taking the last row", {
  d <- data.frame(Person = rep(1:4, each = 2), Rater = rep(c("A", "B"), 4), Score = rep(1:4, each = 2))
  x <- rbind(d, transform(d[1, ], Score = 4))
  expect_error(interrater_agreement(x, metric = "exact"), "Repeated ratings")
  expect_error(interrater_agreement(x[nrow(x):1, ], metric = "exact"), "Repeated ratings")
  x <- rbind(transform(d, Occasion = 1), transform(d, Occasion = 2))
  expect_no_error(interrater_agreement(x, unit = c("Person", "Occasion"), metric = "exact"))
})
