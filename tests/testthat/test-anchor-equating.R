# Tests for Phase 4: Anchoring & Equating Workflow

# ---------- shared fixtures (computed once) ----------
d1   <- load_mfrmr_data("study1")
d2   <- load_mfrmr_data("study2")
fit1 <- fit_mfrm(d1, person = "Person", facets = c("Rater", "Criterion"),
                 score = "Score", method = "JML")
fit2 <- fit_mfrm(d2, person = "Person", facets = c("Rater", "Criterion"),
                 score = "Score", method = "JML")

# ================================================================
# anchor_to_baseline
# ================================================================

test_that("anchor_to_baseline returns correct class and structure", {
  res <- anchor_to_baseline(d2, fit1, person = "Person",
                            facets = c("Rater", "Criterion"),
                            score = "Score")

  expect_s3_class(res, "mfrm_anchored_fit")
  expect_true(is.list(res))
  expect_named(res, c("fit", "diagnostics", "baseline_anchors", "drift"),
               ignore.order = TRUE)

  # fit is an mfrm_fit
  expect_s3_class(res$fit, "mfrm_fit")

  # baseline_anchors is a tibble with expected columns
  expect_true(is.data.frame(res$baseline_anchors))
  expect_true(all(c("Facet", "Level", "Anchor") %in% names(res$baseline_anchors)))
  expect_true(nrow(res$baseline_anchors) > 0)

  # drift is a tibble with expected columns
  expect_true(is.data.frame(res$drift))
  drift_cols <- c("Facet", "Level", "Baseline", "New", "Drift",
                  "SE_New", "Drift_SE_Ratio", "Flag")
  expect_true(all(drift_cols %in% names(res$drift)))
})

test_that("anchor_to_baseline self-anchoring yields near-zero drift", {
  # Anchor fit1 data to fit1 itself -> drift should be ~0
  res <- anchor_to_baseline(d1, fit1, person = "Person",
                            facets = c("Rater", "Criterion"),
                            score = "Score")

  expect_s3_class(res, "mfrm_anchored_fit")

  # All drifts should be very small (< 0.1 logits)
  if (nrow(res$drift) > 0) {
    expect_true(all(abs(res$drift$Drift) < 0.1),
                info = "Self-anchored drift should be near zero")
  }
})

test_that("anchor_to_baseline rejects non-mfrm_fit input", {
  expect_error(
    anchor_to_baseline(data.frame(), list(x = 1), "P", "F", "S"),
    "mfrm_fit"
  )
})

test_that("anchor_to_baseline S3 methods produce output", {
  res <- anchor_to_baseline(d2, fit1, person = "Person",
                            facets = c("Rater", "Criterion"),
                            score = "Score")

  # summary returns expected class
  s <- summary(res)
  expect_s3_class(s, "summary.mfrm_anchored_fit")
  expect_true(is.numeric(s$n_anchored))
  expect_true(is.numeric(s$n_common))
  expect_true(is.numeric(s$n_flagged))

  # print methods produce output without error
  expect_output(print(res), "Anchored Fit Summary")
  expect_output(print(s), "Anchored Fit Summary")
})

# ================================================================
# detect_anchor_drift
# ================================================================

test_that("detect_anchor_drift returns correct class and structure", {
  drift <- detect_anchor_drift(list(Wave1 = fit1, Wave2 = fit2))

  expect_s3_class(drift, "mfrm_anchor_drift")
  expect_named(drift, c("drift_table", "summary", "common_elements", "config"),
               ignore.order = TRUE)

  # drift_table is a tibble with expected columns
  expect_true(is.data.frame(drift$drift_table))
  dt_cols <- c("Facet", "Level", "Reference", "Wave",
               "Ref_Est", "Wave_Est", "Drift", "SE",
               "Drift_SE_Ratio", "Flag")
  expect_true(all(dt_cols %in% names(drift$drift_table)))

  # common_elements has expected columns
  expect_true(is.data.frame(drift$common_elements))
  expect_true(all(c("Wave1", "Wave2", "N_Common") %in% names(drift$common_elements)))

  # config preserves settings
  expect_equal(drift$config$reference, "Wave1")
  expect_equal(drift$config$drift_threshold, 0.5)
  expect_equal(drift$config$waves, c("Wave1", "Wave2"))
})

test_that("detect_anchor_drift finds common elements", {
  drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))

  # Should have at least some common elements
  expect_true(nrow(drift$common_elements) > 0)
  expect_true(all(drift$common_elements$N_Common >= 0))
})

test_that("detect_anchor_drift flagging logic works", {
  # Use a very small threshold to trigger flags
  drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2),
                               drift_threshold = 0.01,
                               flag_se_ratio = 0.01)

  # With such small thresholds, most elements should be flagged
  if (nrow(drift$drift_table) > 0) {
    expect_true(is.logical(drift$drift_table$Flag))
  }

  # Use a very large threshold to suppress flags
  drift_lax <- detect_anchor_drift(list(W1 = fit1, W2 = fit2),
                                   drift_threshold = 100,
                                   flag_se_ratio = 100)
  if (nrow(drift_lax$drift_table) > 0) {
    expect_equal(sum(drift_lax$drift_table$Flag), 0)
  }
})

test_that("detect_anchor_drift rejects invalid input", {
  expect_error(detect_anchor_drift(list()), "length")
  expect_error(detect_anchor_drift(list(a = 1, b = 2)), "mfrm_fit")
})

test_that("detect_anchor_drift S3 methods produce output", {
  drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))

  s <- summary(drift)
  expect_s3_class(s, "summary.mfrm_anchor_drift")
  expect_true(is.numeric(s$n_comparisons))
  expect_true(is.numeric(s$n_flagged))

  expect_output(print(drift), "Anchor Drift Detection")
  expect_output(print(s), "Anchor Drift Detection")
})

# ================================================================
# build_equating_chain
# ================================================================

test_that("build_equating_chain returns correct class and structure", {
  chain <- build_equating_chain(list(Form1 = fit1, Form2 = fit2))

  expect_s3_class(chain, "mfrm_equating_chain")
  expect_named(chain, c("links", "cumulative", "element_detail", "config"),
               ignore.order = TRUE)

  # links is a tibble with expected columns
  expect_true(is.data.frame(chain$links))
  link_cols <- c("Link", "From", "To", "N_Common", "Offset", "Offset_SD",
                 "Max_Residual")
  expect_true(all(link_cols %in% names(chain$links)))
  expect_equal(nrow(chain$links), 1)  # 2 fits -> 1 link

  # cumulative has one row per wave
  expect_true(is.data.frame(chain$cumulative))
  expect_equal(nrow(chain$cumulative), 2)
  expect_true(all(c("Wave", "Cumulative_Offset") %in% names(chain$cumulative)))

  # First wave offset is always 0
  expect_equal(chain$cumulative$Cumulative_Offset[1], 0)
})

test_that("build_equating_chain with 3 fits produces 2 links", {
  # Use fit1 three times (artificial but tests chain logic)
  chain <- build_equating_chain(list(A = fit1, B = fit2, C = fit1))

  expect_equal(nrow(chain$links), 2)
  expect_equal(nrow(chain$cumulative), 3)
  expect_equal(chain$cumulative$Wave, c("A", "B", "C"))

  # Cumulative offset of first wave is 0
  expect_equal(chain$cumulative$Cumulative_Offset[1], 0)
})

test_that("build_equating_chain rejects invalid input", {
  expect_error(build_equating_chain(list()), "length")
  expect_error(build_equating_chain(list(a = 1, b = 2)), "mfrm_fit")
})

test_that("build_equating_chain S3 methods produce output", {
  chain <- build_equating_chain(list(F1 = fit1, F2 = fit2))

  s <- summary(chain)
  expect_s3_class(s, "summary.mfrm_equating_chain")
  expect_true(is.numeric(s$n_flagged))

  expect_output(print(chain), "Equating Chain")
  expect_output(print(s), "Equating Chain")
})

# ================================================================
# plot_anchor_drift
# ================================================================

# Precompute drift and chain objects for all plot tests
drift_obj <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))
chain_obj <- build_equating_chain(list(F1 = fit1, F2 = fit2))

test_that("plot_anchor_drift drift type returns data with draw=FALSE", {
  result <- plot_anchor_drift(drift_obj, type = "drift", draw = FALSE)

  expect_true(is.data.frame(result) || is.null(result))
  if (is.data.frame(result)) {
    expect_true(nrow(result) > 0)
  }
})

test_that("plot_anchor_drift heatmap type returns data with draw=FALSE", {
  result <- plot_anchor_drift(drift_obj, type = "heatmap", draw = FALSE)

  # Returns matrix or NULL
  expect_true(is.matrix(result) || is.null(result))
})

test_that("plot_anchor_drift chain type returns data with draw=FALSE", {
  result <- plot_anchor_drift(chain_obj, type = "chain", draw = FALSE)

  expect_true(is.data.frame(result))
  expect_true(all(c("Wave", "Cumulative_Offset") %in% names(result)))
})

test_that("plot_anchor_drift drift type draws without error", {
  pdf(NULL)  # suppress graphical output
  on.exit(dev.off(), add = TRUE)

  expect_no_error(plot_anchor_drift(drift_obj, type = "drift"))
})

test_that("plot_anchor_drift chain type draws without error", {
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_no_error(plot_anchor_drift(chain_obj, type = "chain"))
})

test_that("plot_anchor_drift heatmap type draws without error", {
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)

  expect_no_error(plot_anchor_drift(drift_obj, type = "heatmap"))
})

test_that("plot_anchor_drift rejects unsupported type/class combo", {
  # chain object with drift type should error
  expect_error(plot_anchor_drift(chain_obj, type = "drift"),
               "Unsupported")
})

test_that("plot_anchor_drift facet filter works", {
  result <- plot_anchor_drift(drift_obj, type = "drift", facet = "Rater",
                              draw = FALSE)

  if (is.data.frame(result) && nrow(result) > 0) {
    expect_true(all(result$Facet == "Rater"))
  }
})
