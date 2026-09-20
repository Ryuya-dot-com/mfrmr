marginal_pair_fixture <- function() {
  list(prep = list(data = data.frame(Person = c("P1", "P1", "P2", "P2"), Rater = c("A", "B", "A", "B"))),
       config = list(facet_names = "Rater"),
       logprob_bundle = list(prob_list = list(matrix(0.5, 4, 2))),
       posterior_bundle = list(obs_posterior = matrix(1, 4, 1)),
       observed_cat = c(0, 1, 0, 1), weights = rep(1, 4), categories = 0:1)
}

test_that("marginal cells do not omit missing probabilities or fabricate classifications", {
  cells <- function(p, w = c(1, 1), obs = c(0, 1)) summarize_marginal_fit_grid(NULL, obs, p, w, 0:1)
  good <- cells(matrix(0.5, 2, 2))
  expect_equal(good$cell_stats$ExpectedCount, c(1, 1))
  expect_equal(good$cell_stats$VarianceCount, c(0.5, 0.5))
  expect_false(good$summary_stats$Flagged)
  for (p in list(matrix(NA_real_, 2, 2), matrix(c(NA, 0.5, 0.5, 0.5), 2),
                 matrix(0.6, 2, 2), matrix(c(-0.1, 0.5, 1.1, 0.5), 2))) {
    bad <- cells(p)
    expect_true(all(is.na(bad$cell_stats$ExpectedCount)))
    expect_true(all(is.na(bad$cell_stats$FlaggedAbsZ)))
    expect_true(is.na(bad$summary_stats$RMSD))
    expect_true(is.na(bad$summary_stats$FlaggedCellCount))
    expect_true(is.na(bad$summary_stats$Flagged))
    expect_equal(bad$summary_stats$UnclassifiedCells, 2)
  }
  for (w in list(c(NA, 1), c(-1, 1))) {
    bad <- cells(matrix(0.5, 2, 2), w)
    expect_true(all(is.na(bad$cell_stats$ObservedCount)))
    expect_true(all(is.na(bad$cell_stats$FlaggedAbsZ)))
  }
  zero <- cells(rbind(c(NA, NA), c(0.5, 0.5)), c(0, 2))
  expect_equal(zero$cell_stats$ExpectedCount, c(1, 1))
  expect_equal(zero$summary_stats$UnavailableObservations, 0)
  expect_true(is.na(cells(matrix(0.5, 2, 2), c(0, 0))$summary_stats$Flagged))
  missing_score <- cells(matrix(0.5, 2, 2), obs = c(NA, 1))
  expect_true(all(is.na(missing_score$cell_stats$ObservedCount)))
  expect_equal(missing_score$cell_stats$ExpectedCount, c(1, 1))
  expect_error(cells(matrix(0.5, 1, 2)), "must match")
})

test_that("pairwise marginal screens keep unavailable context opportunities", {
  core <- marginal_pair_fixture()
  complete <- calc_marginal_pairwise_bundle(core)
  expect_equal(complete$pair_stats$LevelPairCount, 2)
  expect_equal(complete$pair_stats$ExpectedExactCount, 1)
  # Adjacent agreement is deterministic on a binary scale, so its z score is unavailable.
  expect_true(is.na(complete$pair_stats$AdjacentStdResidual))
  expect_true(is.na(complete$pair_stats$FlaggedAdjacent))
  expect_true(complete$pair_stats$FlaggedExact)
  expect_true(complete$pair_stats$Flagged)
  core$posterior_bundle$obs_posterior[3:4, ] <- NA_real_
  partial <- calc_marginal_pairwise_bundle(core)
  expect_equal(partial$pair_stats$LevelPairCount, 2)
  expect_equal(partial$pair_stats$AvailableContextPairs, 1)
  expect_equal(partial$pair_stats$UnavailableContextPairs, 1)
  expect_true(is.na(partial$pair_stats$ExpectedExactCount))
  expect_true(is.na(partial$pair_stats$Flagged))
  expect_true(is.na(partial$facet_summary$FlaggedLevelPairs))
  expect_equal(partial$coverage$Unclassified, 1)
  core <- marginal_pair_fixture()
  core$weights[1] <- NA_real_
  expect_equal(calc_marginal_pairwise_bundle(core)$pair_stats$UnavailableContextPairs, 1)
  core$weights[1:2] <- 0
  expect_equal(calc_marginal_pairwise_bundle(core)$pair_stats$LevelPairCount, 1)
  core <- marginal_pair_fixture()
  core$logprob_bundle$prob_list[[1]][3, 1] <- NA_real_
  expect_equal(calc_marginal_pairwise_bundle(core)$pair_stats$UnavailableContextPairs, 1)
})

test_that("marginal coverage reaches summaries, reports, exports and saved-result guards", {
  fit <- make_toy_fit(method = "MML")
  diag <- make_toy_diagnostics(fit, diagnostic_mode = "both")
  core <- compute_mml_expected_category_diagnostics(fit)
  core$expected_bundle$posterior_prob[,] <- NA_real_
  core$posterior_bundle$obs_posterior[,] <- NA_real_
  testthat::local_mocked_bindings(compute_mml_expected_category_diagnostics = function(...) core)
  diag$marginal_fit <- calc_marginal_fit_bundle(fit)
  expect_true(all(is.na(diag$marginal_fit$coverage$Flagged)))
  s <- summary(diag)
  expect_equal(s$marginal_coverage, diag$marginal_fit$coverage)
  expect_equal(build_summary_table_bundle(s)$tables$marginal_coverage, as.data.frame(s$marginal_coverage))
  expect_true(all(is.na(s$flags$Count[grepl("Marginal", s$flags$Metric)])))
  printed <- gsub("[[:space:]]+", " ", paste(capture.output(print(summary(diag, detail = "full"))), collapse = " "))
  expect_match(printed, "no classifications available")
  expect_match(printed, "some classifications unavailable")
  expect_false(grepl("partly_classified", printed))
  expect_false(grepl("limited_information_inspired|latent_integrated_first_order_counts|screening_only|generalized_residual_logic", printed))
  contract <- build_apa_reporting_contract(fit, diag)
  text <- gsub("[[:space:]]+", " ", paste(contract$report_text, collapse = " "))
  expect_match(text, "no classifications available")
  expect_false(grepl("largest strict marginal cell|largest strict pairwise signal", text))
  expect_true(is.na(rating_scale_table(fit, diag)$summary$MarginalFlaggedCategories))
  expect_equal(rating_scale_table(fit, diag)$summary$MarginalUnclassifiedCategories, fit$config$n_cat)
  expect_true(is.na(summary(category_structure_report(fit, diag))$summary$MarginalFlaggedCategories))
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  p <- plot_marginal_fit(diag, draw = TRUE)
  expect_equal(p$data$retention$Available, 0)
  expect_equal(p$data$retention$Unavailable, p$data$retention$Candidates)
  expect_true(all(is.na(p$data$table$StdResidual)))
  expect_match(p$data$subtitle, "unavailable")
  expect_no_error(plot_marginal_pairwise(diag, draw = TRUE))
  mismatch <- fit
  mismatch$facets$others$Estimate[1] <- mismatch$facets$others$Estimate[1] + 1
  expect_error(plot_marginal_fit(mismatch, diagnostics = diag, draw = FALSE), "fit/diagnostics mismatch", fixed = TRUE)
  diag$marginal_fit$coverage_version <- NULL
  expect_error(summary(diag), "Recreate diagnostics")
  expect_error(plot_marginal_fit(diag, draw = FALSE), "Recreate diagnostics")
  expect_error(rating_scale_table(fit, diag), "Recreate diagnostics")
  expect_error(build_apa_reporting_contract(fit, diag), "Recreate diagnostics")
  s$marginal_coverage <- NULL
  expect_error(print(s), "Recreate")
  expect_error(build_summary_table_bundle(s), "marginal_coverage")
})

test_that("marginal plots rank the full requested facet and metric", {
  fit <- make_toy_fit(method = "MML")
  diag <- make_toy_diagnostics(fit, diagnostic_mode = "both")
  diag$marginal_fit$top_cells <- diag$marginal_fit$top_cells[0, ]
  diag$marginal_fit$pairwise$top_pairs <- diag$marginal_fit$pairwise$top_pairs[0, ]
  p <- plot_marginal_fit(diag, plot_type = "prop_diff", facet = "Rater", top_n = 100, draw = FALSE)
  expect_true(all(p$data$table$Facet == "Rater"))
  expect_equal(nrow(p$data$table), sum(diag$marginal_fit$facet_level$cell_stats$Facet == "Rater"))
  pair <- plot_marginal_pairwise(diag, metric = "adjacent", facet = "Rater", top_n = 100, draw = FALSE)
  expect_equal(nrow(pair$data$table), sum(diag$marginal_fit$pairwise$pair_stats$Facet == "Rater"))
})
