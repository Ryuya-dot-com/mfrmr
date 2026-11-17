test_that("QWK agrees with a hand contingency calculation and independent MSE", {
  # Marginals (13,27,60), (13,24,63); observed squared disagreement .11,
  # independent-marginal disagreement 1.02, hence QWK = 91/102.
  cells <- expand.grid(a = 0:2, h = 0:2)
  freq <- c(13, 0, 0, 0, 20, 4, 0, 7, 56)
  a <- rep(cells$a, freq); h <- rep(cells$h, freq)
  x <- score_comparison_table(scores = a, reference = h, reference2 = h, categories = 0:2, screen = "williamson2012")
  expect_equal(x$table$QWK, 91 / 102, tolerance = 1e-14)
  expect_equal(x$table$ReferenceQWK, 1)
  expect_equal(x$table$QWKDegradation, 11 / 102)
  expect_equal(x$table$SMDPooled, (mean(a) - mean(h)) /
    sqrt((var(a) + var(h)) / 2))
  expect_equal(x$table$SMDReference, (mean(a) - mean(h)) / sd(h))
  expect_identical(dim(x$counts$scores_reference), c(3L, 3L))

  # An independent response-pair sum implements note 1 directly. Uneven
  # categories distinguish actual score distances from category-rank distances.
  points <- c(0, 1, 5)
  a <- points[c(1, 1, 2, 2, 3, 3, 3)]
  h <- points[c(1, 2, 1, 3, 2, 3, 3)]
  expected <- 1 - mean((a - h)^2) / mean(outer(a, h, "-")^2)
  x <- score_comparison_table(scores = a, reference = h, categories = points, screen = "williamson2012")
  expect_equal(x$table$QWK, expected)
  expect_equal(score_comparison_table(scores = 2 + 3 * a, reference = 2 + 3 * h, categories = 2 + 3 * points, 
    screen = "williamson2012")$table$QWK, expected)
  expect_equal(score_comparison_table(scores = a, reference = h, categories = c(0, 1, 3, 5), screen = "williamson2012")$table$QWK, expected)
  expect_equal(score_comparison_table(scores = a, reference = h, categories = c(0, 1, 5, 1e+200), screen = "williamson2012")$table$QWK, expected)
  nearby <- c(1, 1 + .Machine$double.eps, 1 + 2 * .Machine$double.eps)
  z <- score_comparison_table(scores = nearby, reference = nearby, categories = nearby, screen = "williamson2012")
  expect_equal(z$table$QWK, 1)
  expect_equal(unname(diag(z$counts$scores_reference)), rep(1, 3))
})

test_that("rounding, SMD denominator and degradation have explicit meanings", {
  a <- c(.2, .9, 1.3, 2.1, 2.7, 2.8)
  ac <- c(0, 1, 1, 2, 3, 3)
  h <- c(0, 1, 1, 2, 3, 3); hr <- c(0, 1, 2, 2, 2, 3)
  x <- score_comparison_table(scores = a, reference = h, reference2 = hr, categories = 0:3, score_categories = ac, 
    screen = "williamson2012")
  expect_equal(x$table$QWK, 1)
  expect_equal(x$table$Correlation, cor(a, h))
  expect_equal(x$table$ReferenceCorrelation, cor(hr, h))
  expect_lt(x$table$QWKDegradation, 0)
  expect_equal(x$table$CorrelationDegradation, cor(hr, h) - cor(a, h))
  expect_equal(x$table$SMD, (mean(a) - mean(h)) / sqrt((var(a) + var(h)) / 2))
  y <- score_comparison_table(scores = a, reference = h, reference2 = hr, categories = 0:3, score_categories = ac, 
    smd = "reference", screen = "williamson2012")
  expect_equal(y$table$SMD, (mean(a) - mean(h)) / sd(h))
  expect_identical(y$table$SMDBasis, "reference")
  expect_identical(tail(y$criteria$Basis, 1), "unrounded_scores_smd_reference")
  expect_error(score_comparison_table(scores = a, reference = h, categories = 0:3, screen = "williamson2012"), "outside")
  # Exactly at the configured limits is included; display rounding must not
  # rescue a score just below the limit.
  z <- score_comparison_table(scores = a, reference = h, reference2 = hr, categories = 0:3, score_categories = ac, 
    qwk_min = x$table$QWK, correlation_min = x$table$Correlation, max_abs_smd = abs(x$table$SMD), 
    screen = "williamson2012")
  expect_true(all(z$criteria$Status[c(1, 2, 5)] == "within_threshold"))
  z <- score_comparison_table(scores = a, reference = h, reference2 = hr, categories = 0:3, score_categories = ac, 
    correlation_min = x$table$Correlation + 1e-05, screen = "williamson2012")
  expect_identical(z$criteria$Status[2], "review")
  expect_identical(z$settings$threshold_rounding, "none")
})

test_that("a single complete-case roster governs both baselines and comparisons", {
  a <- c(0, 1, 2, 3, NA, 1)
  h <- c(0, 2, 2, 3, 1, NA)
  hr <- c(0, 1, NA, 3, 2, 1)
  x <- score_comparison_table(scores = a, reference = h, reference2 = hr, categories = 0:3, screen = "williamson2012")
  y <- score_comparison_table(scores = a[c(1, 2, 4)], reference = h[c(1, 2, 4)], reference2 = hr[c(1, 
    2, 4)], categories = 0:3, screen = "williamson2012")
  expect_identical(x$cases$Included, c(TRUE, TRUE, FALSE, TRUE, FALSE, FALSE))
  expect_equal(x$table$NInput, 6)
  expect_equal(x$table$N, 3)
  expect_equal(x$table$NExcluded, 3)
  expect_identical(x$counts, y$counts)
  expect_equal(x$criteria, y$criteria)
  expect_equal(sum(x$counts$scores_reference), sum(x$counts$reference2_reference))
  ac <- a; ac[2] <- NA
  z <- score_comparison_table(scores = a, reference = h, reference2 = hr, categories = 0:3, score_categories = ac, 
    screen = "williamson2012")
  expect_equal(z$table$N, 2)
  expect_true(z$cases$MissingScoreCategory[2])
})

test_that("constant, missing and insufficient ratings remain unavailable", {
  x <- score_comparison_table(scores = rep(1, 3), reference = rep(1, 3), categories = 0:2, screen = "williamson2012")
  expect_true(all(is.na(x$criteria$Value)))
  expect_true(all(x$criteria$Status == "unavailable"))
  expect_match(x$criteria$Reason[1], "zero")
  expect_match(x$criteria$Reason[3], "not supplied")
  expect_false(x$table$Reference2Supplied)
  y <- score_comparison_table(scores = rep(2, 3), reference = rep(1, 3), categories = 0:2, screen = "williamson2012")
  expect_equal(y$table$QWK, 0)
  expect_true(is.na(y$table$SMD))
  for (a in list(numeric(), NA_real_, 1, c(NA_real_, NA_real_))) {
    z <- score_comparison_table(scores = a, reference = a, reference2 = a, categories = 0:2, screen = "williamson2012")
    expect_true(all(z$criteria$Status == "unavailable"))
    expect_true(all(nzchar(z$criteria$Reason)))
  }
  z <- score_comparison_table(scores = 0:3, reference = 3:0, reference2 = 0:3, categories = 0:3, screen = "williamson2012")
  expect_equal(z$table$QWK, -1)
  expect_equal(z$table$Correlation, -1)
  expect_identical(z$criteria$Status[1], "review")
  expect_error(score_comparison_table(scores = 0:2, reference = 0:1, categories = 0:2, screen = "williamson2012"), "same length")
  expect_error(score_comparison_table(scores = c(0, Inf), reference = 0:1, categories = 0:2, screen = "williamson2012"), "finite")
  expect_error(score_comparison_table(scores = factor(0:2), reference = 0:2, categories = 0:2, screen = "williamson2012"), "numeric")
  expect_error(score_comparison_table(scores = 0:2, reference = 0:2, categories = c(0, 2, 1), screen = "williamson2012"), "increasing")
  expect_error(score_comparison_table(scores = 0:2, reference = 0:2, categories = 0:1, screen = "williamson2012"), "outside")
  expect_error(score_comparison_table(scores = 0:2, reference = 0:2, categories = 0:2, max_abs_smd = -1, screen = "williamson2012"), "threshold")
  expect_error(score_comparison_table(scores = 0:2, reference = 0:2, categories = 0:2, qwk_min = NA, screen = "williamson2012"), "threshold")
})

test_that("optional MFRM values reuse matching saved diagnostics and retain scope", {
  saved <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
  fit <- saved$fit
  diag <- saved$diagnostics
  local_mocked_bindings(fit_mfrm = function(...) stop("Unexpected fit"),
    diagnose_mfrm = function(...) stop("Unexpected diagnostics"))
  build <- function(...) score_comparison_table(scores = 0:3, reference = 0:3, reference2 = 0:3, categories = 0:3, screen = "williamson2012", 
    ...)
  x <- build(fit = fit, diagnostics = diag, rater_facet = "Rater", rater = "R01")
  r <- which(fit$facets$others$Facet == "Rater" & fit$facets$others$Level == "R01")
  d <- which(diag$measures$Facet == "Rater" & diag$measures$Level == "R01")
  expect_equal(x$table$MFRMSeverity,
    unname(-fit$config$facet_signs["Rater"] * fit$facets$others$Estimate[r]))
  expect_equal(x$table$MFRMInfit, diag$measures$Infit[d])
  expect_equal(x$table$MFRMOutfit, diag$measures$Outfit[d])
  expect_equal(x$table$MFRMRatingRows, sum(fit$prep$data$Rater == "R01"))
  expect_identical(x$table$MFRMScope, "all_retained_source_ratings_for_selected_rater")
  expect_identical(x$mfrm$config, fit$config)
  expect_identical(x$table$MFRMRater, "R01")
  expect_equal(x$table$N, 4)
  y <- build(fit = fit, rater_facet = "Rater", rater = "R01")
  expect_true(is.na(y$table$MFRMInfit))
  expect_match(y$mfrm$notes[["fit"]], "not supplied")
  expect_identical(y$criteria, x$criteria)
  bad <- diag; bad$measures$Estimate[d] <- bad$measures$Estimate[d] + .1
  expect_error(build(fit = fit, diagnostics = bad, rater_facet = "Rater",
    rater = "R01"), "mismatch")
  expect_error(build(fit = fit, rater_facet = "Rater", rater = "absent"), "exactly one")
  expect_error(build(diagnostics = diag), "require `fit`", fixed = TRUE)
})

test_that("saved tables replay and export without invoking model work", {
  x <- score_comparison_table(scores = c(0, 1, 1, 2), reference = c(0, 0, 1, 2), reference2 = c(0, 
    1, 2, 2), categories = 0:2, screen = "williamson2012")
  rds <- tempfile(fileext = ".rds"); csv <- tempfile(fileext = ".csv")
  on.exit(unlink(c(rds, csv)))
  saveRDS(x, rds)
  expect_identical(readRDS(rds), x)
  utils::write.csv(x$criteria, csv, row.names = FALSE)
  expect_equal(utils::read.csv(csv, colClasses = vapply(x$criteria, class, "")), x$criteria)
})
