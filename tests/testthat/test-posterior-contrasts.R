posterior_draws_example <- function(draws = "auto") {
  read_mfrm_posterior(
    system.file("extdata", "posterior-draws-example", package = "mfrmr"),
    draws = draws
  )
}


test_that("bundled joint posterior draws connect to contrasts, arbitrary levels, plots and reports", {
  x <- posterior_draws_example()
  expect_s3_class(x, "mfrm_posterior_summary")
  expect_false(is.null(x$draws))
  expect_identical(summary(x), x)
  expect_null(posterior_draws_example(draws = "none")$draws)
  expect_s3_class(posterior_draws_example(draws = "require"), "mfrm_posterior_summary")

  cx <- summary(x, contrasts = "Rater", level = 0.90)
  expect_s3_class(cx, "mfrm_posterior_summary")
  expect_equal(cx$level, 0.90)
  expect_equal(cx$source$Level, 0.90)
  expect_true(is.data.frame(cx$contrasts))
  expect_gt(nrow(cx$contrasts), 0L)

  # Independent direct draw-matrix verification (< 1e-12)
  M <- mfrmr:::.mfrm_flatten_draws_array(x$draws$array)
  p <- x$parameters[x$parameters$role == "reported_parameter", , drop = FALSE]
  for (i in seq_len(nrow(cx$contrasts))) {
    row <- cx$contrasts[i, ]
    v_lhs <- p$variable[p$facet == "Rater" & p$level == row$lhs]
    v_rhs <- p$variable[p$facet == "Rater" & p$level == row$rhs]
    diff_vec <- M[, v_lhs] - M[, v_rhs]
    expect_equal(as.numeric(cx$contrast_draws$array[, , i]), unname(diff_vec), tolerance = 1e-12)
    expect_equal(row$mean, mean(diff_vec), tolerance = 1e-12)
    expect_equal(row$median, stats::median(diff_vec), tolerance = 1e-12)
    if (row$value_role == "estimated") {
      expect_equal(row$sd, stats::sd(diff_vec), tolerance = 1e-12)
      expect_equal(
        c(row$lower, row$upper),
        unname(stats::quantile(diff_vec, c(0.05, 0.95))),
        tolerance = 1e-12
      )
      expect_equal(row$prob_gt_zero, mean(diff_vec > 0), tolerance = 1e-12)
      expect_equal(row$prob_lt_zero, mean(diff_vec < 0), tolerance = 1e-12)
    }
  }

  # Anchor conditioning note is retained when comparing against a fixed anchor
  expect_true(any(grepl("Conditional on fixed anchor", cx$contrasts$reference, fixed = TRUE)))

  # confint(), print(), as.data.frame(), plot(), and mfrm_report()
  expect_output(print(cx), "Attached contrasts", fixed = TRUE)
  ci_80 <- confint(x, level = 0.80)
  expect_equal(unique(ci_80$credible_level), 0.80)
  ci_c <- confint(x, contrasts = "Rater", level = 0.90)
  expect_equal(ci_c$lower, cx$contrasts$lower, tolerance = 1e-12)
  expect_equal(confint(cx, parm = "contrasts")$lower, cx$contrasts$lower, tolerance = 1e-12)

  df_p <- as.data.frame(cx, what = "parameters")
  df_c <- as.data.frame(cx, what = "contrasts")
  df_d <- as.data.frame(cx, what = "draws")
  df_cd <- as.data.frame(cx, what = "contrast_draws")
  expect_identical(df_p, cx$parameters)
  expect_identical(df_c, cx$contrasts)
  expect_equal(nrow(df_d), x$draws$iterations * x$chains * nrow(x$parameters))
  expect_equal(nrow(df_cd), x$draws$iterations * x$chains * nrow(cx$contrasts))

  p_int <- plot(cx, quantity = "contrast", draw = FALSE)
  expect_s3_class(p_int, "ggplot")
  expect_equal(plot_data(p_int)$reference, 0)
  expect_equal(plot_data(p_int, "table")$lower, cx$contrasts$lower, tolerance = 1e-12)

  p_drw <- plot(x, contrasts = "Rater", level = 0.90, view = "draws", draw = FALSE)
  expect_s3_class(p_drw, "ggplot")
  expect_true(is.data.frame(plot_data(p_drw, "draws")))
  built_drw <- ggplot2::ggplot_build(p_drw)
  expect_gte(length(built_drw$data), 3L)

  rep_obj <- mfrm_report(cx, style = "apa")
  expect_identical(rep_obj$tables$contrasts, cx$contrasts)
  expect_s3_class(apa_table(cx, which = "contrasts"), "apa_table")
  expect_error(mfrm_report(cx, intervals = confint(cx)), "only to G/D")

  app_dir <- tempfile("post-app-")
  dir.create(app_dir)
  on.exit(unlink(app_dir, recursive = TRUE), add = TRUE)
  export_summary_appendix(rep_obj, output_dir = app_dir, prefix = "joint")
  c_csv <- list.files(app_dir, "contrasts.*csv$", full.names = TRUE)
  expect_length(c_csv, 1L)
  expect_equal(utils::read.csv(c_csv)$lower, cx$contrasts$lower, tolerance = 1e-12)

  # Cross-directory RDS portability
  rds_path <- file.path(app_dir, "portable-contrasts.rds")
  saveRDS(cx, rds_path)
  reloaded <- readRDS(rds_path)
  expect_identical(summary(reloaded), cx)
  expect_equal(confint(reloaded, parm = "contrasts")$upper, cx$contrasts$upper, tolerance = 1e-12)
})

test_that("algebraic basis constraints classify fixed anchors and sum-to-zero combinations without sample-variance heuristics", {
  fit <- readRDS(test_path("fixtures", "anchored-gpcm.rds"))$fixed_population$fit
  fc_r <- fit$config$facet_names[1L]
  lvls_r <- fit$config$facet_levels[[fc_r]]
  # Set two element anchors and a group anchor if enough levels exist
  fit$config$facet_specs[[fc_r]] <- mfrmr:::build_facet_constraint(
    lvls_r,
    anchors = stats::setNames(c(0.4, -0.1), lvls_r[1:2]),
    centered = TRUE,
    centering_scope = "remainder"
  )
  dir <- tempfile("post-alg-")
  dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  build_synthetic_joint_bundle(fit, dir, chains = 4L, iterations = 120L, backend = "Stan")

  x <- read_mfrm_posterior(dir)
  p <- x$parameters[x$parameters$role == "reported_parameter", , drop = FALSE]

  # 1. Difference of two fixed anchors -> fixed_anchor (exact 0.5, NA interval)
  v_a1 <- p$variable[p$facet == fc_r & p$level == lvls_r[1L]]
  v_a2 <- p$variable[p$facet == fc_r & p$level == lvls_r[2L]]
  # 2. Remainder sum of free levels -> fixed_by_constraint (exact 0, NA interval) if centered remainder
  rem_vars <- p$variable[p$facet == fc_r & !p$level %in% lvls_r[1:2]]
  # 3. Uncentered second facet sum (Criterion is centered = FALSE in this fixture) -> estimated!
  fc_2 <- fit$config$facet_names[2L]
  fc2_vars <- p$variable[p$facet == fc_2 & p$quantity == "location"]
  # 4. Step sum within owner 1 -> fixed_by_constraint (exact 0)
  st1_vars <- grep("^steps\\[1,", p$variable, value = TRUE)
  # 5. Log-slope sum within owner -> fixed_by_constraint (exact 0)
  ls_vars <- p$variable[p$quantity == "log_slope"]

  custom <- list(
    anchor_diff = stats::setNames(c(1, -1), c(v_a1, v_a2)),
    uncentered_facet_sum = stats::setNames(rep(1, length(fc2_vars)), fc2_vars),
    step_owner_sum = stats::setNames(rep(1, length(st1_vars)), st1_vars),
    log_slope_sum = stats::setNames(rep(1, length(ls_vars)), ls_vars)
  )
  if (length(rem_vars) >= 2L) {
    custom$remainder_sum <- stats::setNames(rep(1, length(rem_vars)), rem_vars)
  }

  cx <- summary(x, contrasts = custom)
  ct <- cx$contrasts
  expect_identical(ct$value_role[ct$label == "anchor_diff"], "fixed_anchor")
  expect_equal(ct$fixed_value[ct$label == "anchor_diff"], 0.5, tolerance = 1e-12)
  expect_true(is.na(ct$sd[ct$label == "anchor_diff"]) && is.na(ct$lower[ct$label == "anchor_diff"]))

  # Uncentered Criterion sum is genuinely free ("estimated"), while step/log_slope/remainder sums are fixed_by_constraint
  expect_identical(ct$value_role[ct$label == "uncentered_facet_sum"], "estimated")
  expect_true(is.finite(ct$sd[ct$label == "uncentered_facet_sum"]))

  for (nm in intersect(c("step_owner_sum", "log_slope_sum", "remainder_sum"), ct$label)) {
    row <- ct[ct$label == nm, ]
    expect_identical(row$value_role, "fixed_by_constraint")
    expect_equal(row$fixed_value, 0, tolerance = 1e-12)
    expect_true(is.na(row$sd) && is.na(row$lower) && is.na(row$upper))
    expect_identical(row$interval_status, "fixed_value_no_interval")
  }

  # Under centered unanchored Criterion (bundled posterior-draws-example), Criterion sum IS fixed_by_constraint
  x_pop <- posterior_draws_example()
  p_pop <- x_pop$parameters[x_pop$parameters$role == "reported_parameter", , drop = FALSE]
  crit_pop <- p_pop$variable[p_pop$facet == "Criterion" & p_pop$quantity == "location"]
  cx_pop <- summary(x_pop, contrasts = list(centered_criterion_sum = stats::setNames(rep(1, length(crit_pop)), crit_pop)))
  expect_identical(cx_pop$contrasts$value_role, "fixed_by_constraint")
  expect_equal(cx_pop$contrasts$fixed_value, 0, tolerance = 1e-12)
  expect_identical(cx_pop$contrasts$interval_status, "fixed_value_no_interval")

  # Step-owner pairwise contrasts and slope ratio contrast
  cs <- summary(x, contrasts = "Step owner")
  expect_true(all(cs$contrasts$quantity == "step_offset"))
  expect_true(all(cs$contrasts$value_role == "estimated"))

  sl_lvls <- p$level[p$quantity == "slope"]
  sl_owner <- unique(p$facet[p$quantity == "slope"])
  cr <- summary(x, contrasts = data.frame(
    facet = sl_owner, quantity = "slope",
    lhs = sl_lvls[1L], rhs = sl_lvls[2L], scale = "ratio"
  ))
  expect_identical(cr$contrasts$scale, "ratio")
  expect_gt(cr$contrasts$lower, 0)
  p_rat <- plot(cr, quantity = "contrast", draw = FALSE)
  expect_equal(plot_data(p_rat)$reference, 1)

  # Fixed-value rows in view = "draws" never receive fabricated violin slabs
  p_mix <- plot(x, quantity = "location", facet = fc_r, view = "draws", draw = FALSE)
  built_mix <- ggplot2::ggplot_build(p_mix)
  slab_data <- built_mix$data[[1L]]
  fixed_y <- plot_data(p_mix, "table")$Y[plot_data(p_mix, "table")$Display == "Fixed value"]
  expect_false(any(slab_data$y %in% fixed_y))
})

test_that("summary-only bundles, tampered files, single-chain runs and invalid contrasts fail or flag cleanly", {
  s_only <- read_mfrm_posterior(system.file("extdata", "posterior-example", package = "mfrmr"))
  expect_error(
    read_mfrm_posterior(system.file("extdata", "posterior-example", package = "mfrmr"), draws = "require"),
    "posterior-draws.rds"
  )
  expect_error(summary(s_only, contrasts = "Rater"), "posterior-draws.rds")
  expect_error(summary(s_only, level = 0.90), "backend's draws")
  expect_error(confint(s_only, contrasts = "Rater"), "posterior-draws.rds")
  expect_error(plot(s_only, view = "draws", draw = FALSE), "never reconstructed")
  expect_error(as.data.frame(s_only, what = "draws"), "posterior-draws.rds")

  # Checksum and basis tampering fail closed
  src_dir <- system.file("extdata", "posterior-draws-example", package = "mfrmr")
  tmp <- tempfile("post-tamper-")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  file.copy(list.files(src_dir, full.names = TRUE), tmp)
  expect_s3_class(read_mfrm_posterior(tmp), "mfrm_posterior_summary")

  # Recompressing posterior-summary.rds breaks posterior_summary_md5 in posterior-draws.rds
  s_rds <- readRDS(file.path(tmp, "posterior-summary.rds"))
  saveRDS(s_rds, file.path(tmp, "posterior-summary.rds"), compress = FALSE)
  expect_error(read_mfrm_posterior(tmp), "checksum")

  # Restore summary, then tamper with basis alignment inside posterior-draws.rds
  file.copy(file.path(src_dir, "posterior-summary.rds"), tmp, overwrite = TRUE)
  d_rds <- readRDS(file.path(tmp, "posterior-draws.rds"))
  loc_col <- grep("^location_free\\[", dimnames(d_rds$draws)[[3L]])[1L]
  d_rds$draws[1L, 1L, loc_col] <- d_rds$draws[1L, 1L, loc_col] + 0.5
  saveRDS(d_rds, file.path(tmp, "posterior-draws.rds"))
  expect_error(read_mfrm_posterior(tmp), "Inconsistent")

  # In-memory mutations of attached contrasts fail closed everywhere
  x <- posterior_draws_example()
  cx <- summary(x, contrasts = "Rater")
  bad_list <- list(
    function(z) { z$contrasts$lower[z$contrasts$value_role == "estimated"][1L] <- 99; z },
    function(z) { z$contrasts$sampling_review[] <- "no_sampling_flags_detected"; z },
    function(z) { z$contrast_draws$array[1L, 1L, 1L] <- z$contrast_draws$array[1L, 1L, 1L] + 1; z },
    function(z) { z$level <- 0.80; z }
  )
  for (mut in bad_list) {
    bad <- mut(cx)
    expect_error(summary(bad), "Inconsistent")
    expect_error(confint(bad, parm = "contrasts"), "Inconsistent")
    expect_error(plot(bad, quantity = "contrast", draw = FALSE), "Inconsistent")
    expect_error(as.data.frame(bad, what = "contrasts"), "Inconsistent")
    expect_error(mfrm_report(bad), "Inconsistent")
  }

  # Invalid contrast specifications fail closed
  expect_error(summary(x, contrasts = "UnknownFacet"), "Unknown facet")
  expect_error(
    summary(x, contrasts = list(bad = c("theta[1]" = 1, "locations[1]" = -1))),
    "incompatible parameter quantities"
  )
  expect_error(
    summary(x, contrasts = list(self = c("theta[1]" = 0, "theta[2]" = 0))),
    "nonzero weight"
  )
  r0_lvl <- x$parameters$level[which(x$parameters$facet == "Rater")][1L]
  expect_error(
    summary(x, contrasts = data.frame(facet = "Rater", lhs = r0_lvl, rhs = r0_lvl)),
    "itself"
  )

  # Single-chain bundle still computes split-Rhat/ESS and flags Chains < 4
  fit1 <- readRDS(test_path("fixtures", "anchored-facet-information.rds"))$RSM$fit
  dir1 <- tempfile("post-1chain-")
  dir.create(dir1)
  on.exit(unlink(dir1, recursive = TRUE), add = TRUE)
  build_synthetic_joint_bundle(fit1, dir1, chains = 1L, iterations = 40L, backend = "brms")
  x1 <- read_mfrm_posterior(dir1)
  expect_identical(x1$chains, 1L)
  expect_identical(x1$decision$Status, "sampling_review_required")
  cx1 <- summary(x1, contrasts = fit1$config$facet_names[1L])
  expect_true(all(is.finite(cx1$contrasts$rhat[cx1$contrasts$value_role == "estimated"])))
  expect_true(all(cx1$contrasts$sampling_review == "sampling_review_required"))
})
