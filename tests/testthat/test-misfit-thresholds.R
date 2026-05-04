# Tests for the package-level MnSq misfit threshold pair
# (`mfrm_misfit_thresholds()`) and its propagation to summary,
# build_misfit_casebook, build_apa_outputs, and facet_quality_dashboard.

test_that("mfrm_misfit_thresholds() defaults to Linacre 0.5-1.5", {
  thr <- mfrm_misfit_thresholds()
  expect_named(thr, c("lower", "upper"))
  expect_equal(unname(thr), c(0.5, 1.5))
})

test_that("mfrm_misfit_thresholds() respects R options", {
  old <- options(
    mfrmr.misfit_lower = 0.7,
    mfrmr.misfit_upper = 1.3
  )
  on.exit(options(old), add = TRUE)
  thr <- mfrm_misfit_thresholds()
  expect_equal(unname(thr), c(0.7, 1.3))
})

test_that("mfrm_misfit_thresholds() respects per-call overrides", {
  thr <- mfrm_misfit_thresholds(lower = 0.6, upper = 1.4)
  expect_equal(unname(thr), c(0.6, 1.4))
})

test_that("mfrm_misfit_thresholds() rejects invalid bounds", {
  expect_error(mfrm_misfit_thresholds(lower = 1.5, upper = 0.5),
               "0 < lower < upper")
  expect_error(mfrm_misfit_thresholds(lower = -0.1, upper = 1.5),
               "0 < lower < upper")
})

test_that("MnSq direction classifier separates underfit and overfit", {
  direction <- mfrmr:::mfrm_classify_mnsq_direction(
    infit = c(1.0, 1.6, 0.4, 1.6),
    outfit = c(1.0, 1.2, 0.8, 0.4),
    lower = 0.5,
    upper = 1.5
  )
  expect_equal(direction, c("in_band", "underfit", "overfit", "mixed"))
  expect_equal(
    mfrmr:::mfrm_misfit_direction_label(direction),
    c(
      "inside active band",
      "underfit (above upper band)",
      "overfit (below lower band)",
      "mixed underfit/overfit"
    )
  )
})

test_that("summary(diag) inherits the option-driven band", {
  toy <- load_mfrmr_data("example_core")
  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 25)
  ))
  diag <- suppressMessages(diagnose_mfrm(fit, residual_pca = "none",
                                          diagnostic_mode = "legacy"))
  old <- options(
    mfrmr.misfit_lower = 0.7,
    mfrmr.misfit_upper = 1.3
  )
  on.exit(options(old), add = TRUE)
  s <- summary(diag)
  expect_equal(unname(s$misfit_thresholds), c(0.7, 1.3))
  expect_match(s$misfit_threshold_label, "custom active screening band", fixed = TRUE)
  expect_match(s$misfit_threshold_note, "custom/configured band", fixed = TRUE)
  expect_match(s$misfit_threshold_note, "universal misfit definition", fixed = TRUE)
  out <- capture.output(print(s))
  expect_true(any(grepl("Misfit threshold policy", out, fixed = TRUE)))
  expect_true(any(grepl("0.7-1.3", out, fixed = TRUE)))
  expect_false(any(grepl("Linacre threshold", out, fixed = TRUE)))
})

test_that("build_apa_outputs states active misfit-band convention", {
  toy <- load_mfrmr_data("example_core")
  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 25)
  ))
  diag <- suppressMessages(diagnose_mfrm(fit, residual_pca = "none",
                                          diagnostic_mode = "legacy"))

  apa_default <- build_apa_outputs(fit, diag)
  expect_match(apa_default$report_text, "active 0.5-1.5 MnSq screening band", fixed = TRUE)
  expect_match(
    apa_default$report_text,
    "screening evidence rather than a\\s+universal misfit definition"
  )
  expect_true("Misfit threshold caveat alignment" %in%
                summary(apa_default)$content_checks$Check)

  old <- options(
    mfrmr.misfit_lower = 0.7,
    mfrmr.misfit_upper = 1.3
  )
  on.exit(options(old), add = TRUE)
  apa_custom <- build_apa_outputs(fit, diag)
  expect_match(apa_custom$report_text, "active 0.7-1.3 MnSq screening band", fixed = TRUE)
  expect_match(apa_custom$report_text, "custom threshold settings", fixed = TRUE)
})

test_that("casebook and facet dashboard inherit the active misfit band", {
  toy <- load_mfrmr_data("example_core")
  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 25)
  ))
  diag <- suppressMessages(diagnose_mfrm(fit, residual_pca = "none",
                                          diagnostic_mode = "legacy"))
  diag$fit$Infit[1] <- 1.4
  diag$fit$Outfit[1] <- 1.4

  old <- options(
    mfrmr.misfit_lower = 0.7,
    mfrmr.misfit_upper = 1.3
  )
  on.exit(options(old), add = TRUE)

  casebook <- build_misfit_casebook(fit, diagnostics = diag, top_n = 500)
  expect_true(any(grepl("MnSq misfit \\(band 0.7-1.3\\)", casebook$top_cases$Signal)))
  expect_true(any(grepl("underfit", casebook$top_cases$Direction, fixed = TRUE)))

  dash <- facet_quality_dashboard(fit, diagnostics = diag, facet = "Rater")
  settings <- as.data.frame(dash$settings, stringsAsFactors = FALSE)
  expect_equal(as.numeric(settings$Value[settings$Setting == "misfit_lower"]), 0.7)
  expect_equal(as.numeric(settings$Value[settings$Setting == "misfit_warn"]), 1.3)
  expect_true("MisfitDirection" %in% names(dash$detail))
})
