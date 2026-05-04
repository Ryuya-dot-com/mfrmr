# Tests for the 0.1.6 helpers introduced for local-dependence and
# person-fit reporting: q3_statistic(), compute_person_fit_indices(),
# and mfrm_generalizability().

local({
  .toy <<- load_mfrmr_data("example_core")
  .fit <<- make_toy_fit()
  .diag <<- make_toy_diagnostics(.fit)
})

# --- q3_statistic ---------------------------------------------------------

test_that("q3_statistic returns the documented shape", {
  q3 <- q3_statistic(.fit, diagnostics = .diag)
  expect_s3_class(q3, "mfrm_q3")
  expect_true(all(c("Level1", "Level2", "Q3", "N", "AbsQ3",
                    "YenFlag", "MaraisFlag", "RelativeFlag",
                    "Interpretation") %in% names(q3$pairs)))
  expect_named(q3$thresholds, c("yen", "marais", "relative_offset"))
})

test_that("q3_statistic respects custom thresholds", {
  q3_strict <- q3_statistic(.fit, diagnostics = .diag,
                             yen_threshold = 0.05,
                             marais_threshold = 0.10)
  expect_gte(q3_strict$summary$YenFlagged, 0L)
  q3_lax <- q3_statistic(.fit, diagnostics = .diag,
                         yen_threshold = 0.99,
                         marais_threshold = 0.99)
  expect_equal(q3_lax$summary$YenFlagged, 0L)
})

test_that("q3_statistic rejects unknown facet", {
  expect_error(
    q3_statistic(.fit, diagnostics = .diag, facet = "NotAFacet"),
    "must be one of"
  )
})

# --- compute_person_fit_indices ------------------------------------------

test_that("compute_person_fit_indices returns one row per person", {
  pf <- compute_person_fit_indices(.diag, fit = .fit)
  expect_true(is.data.frame(pf))
  expect_true(all(c("Person", "N", "LogLik", "lz", "lz_star",
                    "lz_finite_n", "lz_star_method")
                  %in% names(pf)))
  # ECI4 was removed in 0.2.0 — it was a misnamed duplicate of the
  # Outfit ZSTD (linear Smith form), not Tatsuoka & Tatsuoka (1983).
  expect_false("ECI4" %in% names(pf))
  expect_equal(length(unique(pf$Person)), nrow(pf))
})

test_that("compute_person_fit_indices works without fit (lz_star NA)", {
  pf <- compute_person_fit_indices(.diag, fit = NULL)
  expect_true(all(is.na(pf$lz_star)))
  expect_true(all(pf$lz_star_method == "unavailable_no_fit"))
  expect_true(any(is.finite(pf$lz_finite_n)))
})

test_that("compute_person_fit_indices computes Snijders-style JML correction", {
  pf <- compute_person_fit_indices(.diag, fit = .fit)
  expect_true(any(pf$lz_star_method == "snijders_score_projection_jml"))
  expect_true(any(is.finite(pf$lz_star)))
  expect_true(all(abs(pf$lz_finite_n[is.finite(pf$lz_finite_n)]) <=
                    abs(pf$lz[is.finite(pf$lz_finite_n)]) + 1e-12))
})

test_that("lz uses true Drasgow polytomous form via PrObserved", {
  # Closed-form check: build a tiny synthetic obs table directly with
  # PrObserved / ItemEntropy / ItemVarLogP populated and verify the
  # output matches the manual computation.
  P_item1 <- c(0.1, 0.2, 0.4, 0.3)
  P_item2 <- c(0.05, 0.15, 0.5, 0.3)
  log_p_item1 <- log(P_item1)
  log_p_item2 <- log(P_item2)

  ent1 <- sum(P_item1 * log_p_item1)
  ent2 <- sum(P_item2 * log_p_item2)
  var1 <- sum(P_item1 * log_p_item1^2) - ent1^2
  var2 <- sum(P_item2 * log_p_item2^2) - ent2^2

  fake_obs <- data.frame(
    Person = c("p1", "p1"),
    Observed = c(2, 3),
    Expected = c(2, 3),
    Residual = c(0, 0),
    PrObserved = c(P_item1[3], P_item2[4]),
    ItemEntropy = c(ent1, ent2),
    ItemVarLogP = c(var1, var2),
    stringsAsFactors = FALSE
  )
  fake_diag <- list(obs = fake_obs)

  pf <- compute_person_fit_indices(fake_diag, fit = NULL)
  expected_loglik <- log(P_item1[3]) + log(P_item2[4])
  expected_e_logp <- ent1 + ent2
  expected_var_logp <- var1 + var2
  expected_lz <- (expected_loglik - expected_e_logp) / sqrt(expected_var_logp)

  expect_equal(pf$LogLik, expected_loglik, tolerance = 1e-12)
  expect_equal(pf$lz, expected_lz, tolerance = 1e-12)
  expect_true(is.na(pf$lz_star))
  expect_equal(pf$lz_finite_n, expected_lz / sqrt(1 + 1 / 2), tolerance = 1e-12)
})

# --- mfrm_generalizability -----------------------------------------------

test_that("mfrm_generalizability returns variance components and G/Phi", {
  if (!requireNamespace("lme4", quietly = TRUE)) {
    skip("lme4 (Suggests) not installed.")
  }
  gt <- mfrm_generalizability(.fit)
  expect_s3_class(gt, "mfrm_generalizability")
  expect_true(all(c("Source", "Variance", "ProportionVariance")
                  %in% names(gt$variance_components)))
  expect_true(all(c("G", "Phi") %in% names(gt$coefficients)))
})
