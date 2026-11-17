test_that("ZSTD cannot turn tiny-df mean squares into positive misfit flags", {
  df <- c(0, 1e-6, .5, 1, 2, NA_real_, Inf)
  for (method in list(FALSE, TRUE, "legacy_linear")) {
    z <- zstd_from_mnsq_facets(.01, df, whexact = method)
    expect_true(all(is.na(z[c(1:3, 6:7)])))
    q <- sqrt(2 / df[4:5])
    expected <- if (identical(method, "legacy_linear")) (.01 - 1) / q else
      3 * (.01^(1 / 3) - 1) / q + if (identical(method, FALSE)) q / 3 else 0
    expect_equal(z[4:5], pmax(-9, pmin(9, expected)))
  }
  expect_true(is.na(zstd_from_mnsq_facets(-1, 2)))
  expect_true(is.na(zstd_from_mnsq_facets(NA_real_, 2)))
})

test_that("boundary safeguards retain weighted mean squares and complete scopes", {
  obs <- data.frame(Person = c("P1", "P2", "P3", "P4"),
    Rater = c("A", "A", "B", "B"),
    PrimaryPersonMeasure = c(-Inf, 0, 1, 2), PersonMeasureBasis = "JML optimizer",
    StdSq = c(.01, 2, 1, .5), Var = c(.5, 1, .5, 1),
    FourthCentralMoment = c(.75, 3, .75, 3), Weight = c(1, 2, 1, 3))
  for (direction in c(-Inf, Inf)) for (method in c("engine", "facets", "both")) {
    obs$PrimaryPersonMeasure[1] <- direction
    out <- calc_facet_fit(obs, c("Person", "Rater"), fit_df_method = method)
    rater <- out[out$Facet == "Rater", ]
    columns <- grep("^(Infit|Outfit)ZSTD($|_)", names(out), value = TRUE)
    expect_true(all(is.na(as.matrix(rater[rater$Level == "A", columns]))))
    expect_true(all(is.na(as.matrix(out[out$Facet == "Person" & out$Level == "P1", columns]))))
    expect_identical(rater$FitBoundaryRows, c(1L, 0L))
    expect_identical(rater$FitResponseRows, c(2L, 2L))
    expect_identical(rater$FitUnavailableRows, c(0L, 0L))
    expect_equal(rater$N, c(3, 4))
    expect_equal(rater$Infit[1], (.01 * .5 + 2 * 2) / (.5 + 2))
    expect_equal(rater$Outfit[1], (.01 + 2 * 2) / 3)
    expect_match(rater$FitReason[1], "no rows were excluded")
    expect_equal(rater$FitStatus[1], "available_descriptive")
    ordinary <- obs; ordinary$PrimaryPersonMeasure[1] <- 0
    ref <- calc_facet_fit(ordinary, c("Person", "Rater"), fit_df_method = method)
    expect_identical(out[out$Facet == "Rater" & out$Level == "B", ],
      ref[ref$Facet == "Rater" & ref$Level == "B", ])
    total <- calc_overall_fit(obs, fit_df_method = method)
    expect_true(all(is.na(as.matrix(total[, columns]))))
    expect_equal(total$Outfit, sum(obs$StdSq * obs$Weight) / sum(obs$Weight))
    expect_equal(total$FitBoundaryRows, 1L)
  }
  # Finite estimates with ill-conditioned fourth-moment df need their own guard.
  obs$PrimaryPersonMeasure[1] <- 0
  obs$Var[1] <- 1e-7; obs$FourthCentralMoment[1] <- 1e-7
  out <- calc_overall_fit(obs, fit_df_method = "facets")
  expect_lt(out$DF_Outfit, 1)
  expect_true(is.na(out$OutfitZSTD))
  expect_true(is.finite(out$Outfit))
  expect_match(out$FitReason, "Outfit ZSTD is unavailable.*below 1")
  both <- calc_overall_fit(obs, fit_df_method = "both")
  expect_true(is.finite(both$OutfitZSTD))
  expect_true(is.na(both$OutfitZSTD_FACETS))
  expect_match(both$FitReason, "FACETS-style ZSTD is unavailable")
  obs$StdSq[2] <- NA_real_
  incomplete <- calc_overall_fit(obs)
  expect_true(is.na(incomplete$Infit) && is.na(incomplete$Outfit))
  expect_equal(incomplete$FitUnavailableRows, 1L)
})

test_that("public saved JML fits recompute guarded diagnostics without refitting", {
  pattern <- rbind(c(0, 0), c(1, 1), c(0, 1), c(1, 0))
  x <- pattern[rep(seq_len(4L), c(2, 2, 4, 6)), ]
  ratings <- data.frame(Person = rep(seq_len(nrow(x)), each = 2),
    Rater = rep(c("A", "B"), nrow(x)), Score = as.vector(t(x)))
  for (model in c("RSM", "PCM")) {
    f <- fit_mfrm(ratings, "Person", "Rater", "Score", method = "JML",
      model = model, step_facet = if (model == "PCM") "Rater" else NULL,
      maxit = 300, category_policy = "preserve")
    path <- tempfile(fileext = ".rds")
    saveRDS(f, path); saved <- readRDS(path); unlink(path)
    d <- diagnose_mfrm(saved, diagnostic_mode = "legacy", fit_df_method = "both")
    extreme <- d$measures$Facet == "Person" & is.infinite(d$measures$Estimate)
    expect_equal(sum(extreme), 4L)
    expect_identical(saved, f)
    expect_true(all(d$fit$FitBoundaryRows[d$fit$Facet == "Rater"] == 4L))
    affected <- d$measures$FitBoundaryRows > 0
    zcols <- grep("^(Infit|Outfit)ZSTD($|_)", names(d$measures), value = TRUE)
    expect_true(all(is.na(as.matrix(d$measures[affected, zcols]))))
    expect_true(all(d$measures$FitBoundaryRows[extreme] == 2L))
    expect_true(all(is.finite(d$measures$OutfitZSTD[!affected])))
    expect_no_error(summary(d))
    tab <- fit_measures_table(d, include_person = TRUE)$table
    expect_true(all(is.na(tab$OutfitZSTD[tab$FitBoundaryRows > 0])))
    expect_true(all(grepl("ZSTD is unavailable", tab$FitReason[tab$FitBoundaryRows > 0])))
    # Only affected old bundles require recomputation; finite old analyses stay readable.
    old <- d; old$measures$FitBoundaryRows <- NULL
    expect_error(summary(old), "Recompute diagnose_mfrm")
    expect_error(fit_measures_table(old), "Recompute diagnose_mfrm")
    result <- mfrm_results(saved, diagnostics = d, compute = "never")
    result$diagnostics <- old
    for (consumer in list(summary, mfrm_report, plot,
                         function(x) export_mfrm_results(x, include = "tables")))
      expect_error(consumer(result), "Recompute diagnose_mfrm")
    old$measures <- old$measures[!extreme, ]
    expect_no_error(validate_diagnostics_precision(old))
    d$measures$DF_Outfit[1] <- .01; d$measures$OutfitZSTD[1] <- 9
    expect_error(validate_diagnostics_precision(d), "small-df ZSTD safeguards")
  }
})
