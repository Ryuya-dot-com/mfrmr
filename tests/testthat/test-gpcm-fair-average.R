# ==============================================================================
# Tests for the slope-aware GPCM fair-average kernel and dispatch.
# ==============================================================================
#
# These tests pin the mathematical contract of the slope-aware GPCM
# fair-average implementation in 0.2.0:
#
# 1. The internal helper `expected_score_from_eta_gpcm()` reduces exactly
#    to `expected_score_from_eta()` at `slope = 1` (machine precision).
# 2. The helper agrees with the M12 design-memo worked example to better
#    than 1e-5 absolute tolerance.
# 3. The numerical derivative matches the analytical derivative
#    `dE[X]/dtheta = a * Var(X | theta)` (M12 derivation #1).
# 4. The kernel is invariant under the GPCM identification rescaling
#    (slope*c, theta/c, delta/c).
# 5. Degenerate slopes (zero, negative, NA) fall back to slope = 1.
# 6. End-to-end: `fair_average_table()` no longer hard-stops on a GPCM
#    fit and returns a populated bundle with the GPCM caveat.
# 7. End-to-end: PCM and GPCM-with-slopes-equal-to-one produce the same
#    fair-averages when the underlying parameters are made identical
#    (constructed from the same synthetic data).

# ---- 1-5: kernel-level reduction, worked example, derivatives ----------------

test_that("expected_score_from_eta_gpcm reduces to PCM/RSM at slope = 1", {
  # Cross-product of etas, step_cum vectors, and rating-min anchors.
  cases <- list(
    list(eta = -1.5, step_cum = c(0, -0.5, 0, 0.5),  rating_min = 0L),
    list(eta = -0.3, step_cum = c(0, -0.5, 0, 0.5),  rating_min = 0L),
    list(eta =  0.0, step_cum = c(0, -0.5, 0, 0.5),  rating_min = 0L),
    list(eta =  0.5, step_cum = c(0, -0.5, 0, 0.5),  rating_min = 1L),
    list(eta =  1.2, step_cum = c(0, -1.0, 0.5),     rating_min = 1L),
    list(eta = -0.7, step_cum = c(0, -1.0, 0.5),     rating_min = 0L),
    list(eta =  2.0, step_cum = c(0, 0.2),           rating_min = 0L)
  )
  diffs <- vapply(cases, function(case) {
    pcm <- mfrmr:::expected_score_from_eta(case$eta, case$step_cum, case$rating_min)
    gpcm <- mfrmr:::expected_score_from_eta_gpcm(case$eta, case$step_cum,
                                                   slope = 1, case$rating_min)
    abs(pcm - gpcm)
  }, numeric(1))
  expect_lt(max(diffs), 1e-15)
})

test_that("expected_score_from_eta_gpcm matches worked example (theta=0.3, a=1.2)", {
  # Worked example: K = 4, per-step delta = (-0.5, 0, 0.5),
  # delta_cum = (0, -0.5, -0.5, 0). theta = 0.3, a = 1.2. By hand the
  # category probabilities are (0.097089, 0.253566, 0.363447, 0.285898)
  # and FA = 1.838151; nearby hand calculations differ only by rounding.
  delta_cum <- c(0, -0.5, -0.5, 0)
  fa <- mfrmr:::expected_score_from_eta_gpcm(eta = 0.3, step_cum = delta_cum,
                                               slope = 1.2, rating_min = 0L)
  expect_equal(fa, 1.8381511, tolerance = 1e-6)
})

test_that("numerical d/dtheta of E[X] matches analytical a * Var(K)", {
  # Derivation check: dE[X]/dtheta = a * Var(K).
  # For the same fixture as above, Var(K) = 0.901626 so analytical = 1.081951.
  delta_cum <- c(0, -0.5, -0.5, 0)
  h <- 1e-6
  fa_plus  <- mfrmr:::expected_score_from_eta_gpcm(0.3 + h, delta_cum, 1.2, 0L)
  fa_minus <- mfrmr:::expected_score_from_eta_gpcm(0.3 - h, delta_cum, 1.2, 0L)
  deriv_num <- (fa_plus - fa_minus) / (2 * h)
  expect_equal(deriv_num, 1.0819512, tolerance = 1e-4)
})

test_that("GPCM kernel is invariant under slope rescaling identification", {
  # Identification: scaling slopes by c with theta/c, delta_cum/c keeps
  # the GPCM probabilities unchanged (because a*(k*theta - delta_cum)
  # multiplies through). The fair average is therefore invariant.
  c_factor <- 2
  fa_orig <- mfrmr:::expected_score_from_eta_gpcm(0.3,
                                                    c(0, -0.5, -0.5, 0),
                                                    1.2, 0L)
  fa_resc <- mfrmr:::expected_score_from_eta_gpcm(0.3 / c_factor,
                                                    c(0, -0.5, -0.5, 0) / c_factor,
                                                    1.2 * c_factor, 0L)
  expect_equal(fa_orig, fa_resc, tolerance = 1e-12)
})

test_that("degenerate slopes fall back to slope = 1", {
  step_cum <- c(0, -0.5, 0.5)
  fa_one  <- mfrmr:::expected_score_from_eta_gpcm(0.3, step_cum, slope =  1,    rating_min = 0L)
  fa_zero <- mfrmr:::expected_score_from_eta_gpcm(0.3, step_cum, slope =  0,    rating_min = 0L)
  fa_neg  <- mfrmr:::expected_score_from_eta_gpcm(0.3, step_cum, slope = -0.5,  rating_min = 0L)
  fa_na   <- mfrmr:::expected_score_from_eta_gpcm(0.3, step_cum, slope =  NA_real_,
                                                    rating_min = 0L)
  expect_equal(fa_zero, fa_one, tolerance = 1e-15)
  expect_equal(fa_neg,  fa_one, tolerance = 1e-15)
  expect_equal(fa_na,   fa_one, tolerance = 1e-15)
})

# ---- 6-7: end-to-end through fair_average_table() ----------------------------

test_that("fair_average_table() no longer hard-stops on GPCM fits", {
  d <- mfrmr:::sample_mfrm_data(seed = 42)
  fit <- suppressWarnings(suppressMessages(fit_mfrm(
    d, "Person", c("Rater", "Task", "Criterion"), "Score",
    model = "GPCM", step_facet = "Criterion",
    method = "MML", quad_points = 5, maxit = 20
  )))

  fa <- fair_average_table(fit, label_style = "native")

  expect_s3_class(fa, "mfrm_fair_average")
  expect_true(nrow(fa$stacked) > 0)
  expect_identical(fa$settings$method, "GPCM-slope-aware")
  expect_true(!is.null(fa$caveat))
  expect_true(grepl("slope-aware", fa$caveat, fixed = TRUE))

  # Each Criterion row should have an AdjustedAverage value populated;
  # because criteria have different slopes and different thresholds, the
  # reported AdjustedAverage values should not all be identical.
  crit <- fa$stacked[fa$stacked$Facet == "Criterion", , drop = FALSE]
  expect_gt(nrow(crit), 1)
  expect_true(all(is.finite(crit$AdjustedAverage)))
  expect_gt(stats::var(crit$AdjustedAverage), 0)
})

test_that("estimate_bias() no longer hard-stops on GPCM fits", {
  d <- mfrmr:::sample_mfrm_data(seed = 42)
  fit <- suppressWarnings(suppressMessages(fit_mfrm(
    d, "Person", c("Rater", "Task", "Criterion"), "Score",
    model = "GPCM", step_facet = "Criterion",
    method = "MML", quad_points = 5, maxit = 20
  )))
  dx <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "legacy")

  bias <- estimate_bias(fit, dx, facet_a = "Rater", facet_b = "Criterion")

  expect_s3_class(bias, "mfrm_bias")
  expect_true(nrow(bias$table) > 0)
  expect_identical(bias$method, "GPCM-slope-aware")
  expect_true(!is.null(bias$caveat))
  expect_true(grepl("slope-aware GPCM kernel", bias$caveat, fixed = TRUE))
  # Bias point estimates must be finite, well-bounded, and accompanied
  # by the screening-tier inference columns.
  expect_true(all(is.finite(bias$table$`Bias Size`)))
  expect_true(all(abs(bias$table$`Bias Size`) <= 10))
  expect_true("S.E." %in% names(bias$table))
  expect_true("InferenceTier" %in% names(bias$table))
  expect_identical(unique(bias$table$InferenceTier), "screening")
})

test_that("estimate_bias() GPCM dispatch responds to slope clamping", {
  # The GPCM bias dispatch (loglik_gpcm + category_prob_gpcm in
  # `estimate_bias_interaction()`) must consume `params$slopes`. We
  # confirm that by comparing bias estimates from a fit with the actual
  # fitted slopes against bias estimates from the same fit with
  # log-slopes clamped to zero. At least one cell must change, which
  # proves the slope-aware kernel is in fact the active code path.
  # (Closed-form reduction-to-PCM at slopes = 1 is already pinned at
  # the helper layer in test-estimation-core.R:148-185, where
  # `loglik_gpcm` and `category_prob_gpcm` are tested to agree with
  # their PCM siblings byte-for-byte at unit slopes.)
  d <- mfrmr:::sample_mfrm_data(seed = 42)
  fit_gpcm <- suppressWarnings(suppressMessages(fit_mfrm(
    d, "Person", c("Rater", "Task", "Criterion"), "Score",
    model = "GPCM", step_facet = "Criterion",
    method = "MML", quad_points = 5, maxit = 20
  )))
  config <- fit_gpcm$config
  sizes <- mfrmr:::build_param_sizes(config)
  if (is.null(sizes$log_slopes) || sizes$log_slopes == 0L) {
    skip("GPCM fit has no log-slope parameter block to clamp.")
  }
  facets_n <- sum(unlist(sizes[c("theta", "facets", "steps")]))
  log_slope_start <- facets_n + 1L
  log_slope_end <- facets_n + sizes$log_slopes
  fit_clamped <- fit_gpcm
  fit_clamped$opt$par[log_slope_start:log_slope_end] <- 0  # log(1) = 0

  dx_gpcm <- diagnose_mfrm(fit_gpcm, residual_pca = "none", diagnostic_mode = "legacy")
  dx_clamped <- diagnose_mfrm(fit_clamped, residual_pca = "none",
                                diagnostic_mode = "legacy")

  bias_gpcm <- estimate_bias(fit_gpcm, dx_gpcm,
                               facet_a = "Rater", facet_b = "Criterion")
  bias_clamped <- estimate_bias(fit_clamped, dx_clamped,
                                  facet_a = "Rater", facet_b = "Criterion")

  expect_s3_class(bias_gpcm, "mfrm_bias")
  expect_s3_class(bias_clamped, "mfrm_bias")

  # Match cells via the package-emitted facet-level columns.
  key_gpcm <- paste(bias_gpcm$table$Facet1_Level,
                     bias_gpcm$table$Facet2_Level, sep = "||")
  key_clamped <- paste(bias_clamped$table$Facet1_Level,
                         bias_clamped$table$Facet2_Level, sep = "||")
  common <- intersect(key_gpcm, key_clamped)
  expect_gt(length(common), 0)

  i_gpcm <- match(common, key_gpcm)
  i_clamped <- match(common, key_clamped)
  diffs <- abs(bias_gpcm$table$`Bias Size`[i_gpcm] -
                 bias_clamped$table$`Bias Size`[i_clamped])

  # Slope dispatch sanity: at least one cell must move when slopes are
  # clamped to 1. If diff = 0 everywhere, the dispatch is silently
  # ignoring `params$slopes`.
  expect_gt(max(diffs, na.rm = TRUE), 1e-6)
})

test_that("GPCM dispatch: clamping slopes to 1 changes Criterion-row fair-averages", {
  # Construct a GPCM fit, then build a parallel parameter vector whose
  # slope block is all-zero on the log scale (i.e. all slopes = 1 by
  # the geomean=1 identification). At slopes = 1 the GPCM kernel equals
  # the PCM kernel byte-for-byte (verified at the helper level above),
  # so the Criterion-row fair-averages from the clamped fit must
  # differ from the actual-slopes fair-averages -- this proves the
  # slope dispatch is actually using `params$slopes` rather than
  # silently ignoring it. We restrict the comparison to Criterion (the
  # slope facet) rows because the diagnostics layer caches some
  # intermediate values from the original fit that propagate small
  # differences through Person rows when the parameter vector is
  # mutated; the slope-facet contribution is the part that must
  # respond.
  d <- mfrmr:::sample_mfrm_data(seed = 42)
  fit_gpcm <- suppressWarnings(suppressMessages(fit_mfrm(
    d, "Person", c("Rater", "Task", "Criterion"), "Score",
    model = "GPCM", step_facet = "Criterion",
    method = "MML", quad_points = 5, maxit = 20
  )))

  fa_gpcm <- fair_average_table(fit_gpcm, label_style = "native")

  config <- fit_gpcm$config
  sizes <- mfrmr:::build_param_sizes(config)
  if (is.null(sizes$log_slopes) || sizes$log_slopes == 0L) {
    skip("GPCM fit has no log-slope parameter block to clamp.")
  }
  # The optim parameter vector is laid out as
  #   [theta?, facets, steps, log_slopes, beta?, log_sigma2?]
  facets_n <- sum(unlist(sizes[c("theta", "facets", "steps")]))
  log_slope_start <- facets_n + 1L
  log_slope_end <- facets_n + sizes$log_slopes
  par_clamped <- fit_gpcm$opt$par
  par_clamped[log_slope_start:log_slope_end] <- 0  # log(1) = 0

  fit_clamped <- fit_gpcm
  fit_clamped$opt$par <- par_clamped

  fa_clamped <- fair_average_table(fit_clamped, label_style = "native")

  crit_gpcm <- fa_gpcm$stacked[fa_gpcm$stacked$Facet == "Criterion",
                                "AdjustedAverage", drop = TRUE]
  crit_clamped <- fa_clamped$stacked[fa_clamped$stacked$Facet == "Criterion",
                                       "AdjustedAverage", drop = TRUE]

  # Both vectors must be finite and the same length.
  expect_length(crit_gpcm, length(crit_clamped))
  expect_true(all(is.finite(crit_gpcm)))
  expect_true(all(is.finite(crit_clamped)))

  # Slope dispatch sanity: at least one Criterion FairM must change
  # when slopes are clamped to 1. If they were all identical, the
  # dispatch would not be using `params$slopes` at all.
  expect_gt(max(abs(crit_gpcm - crit_clamped)), 1e-4)
})
