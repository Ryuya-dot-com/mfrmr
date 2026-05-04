empirical_fit_fixture <- local({
  toy <- load_mfrmr_data("example_core")
  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
             method = "JML", maxit = 25)
  ))
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "legacy")
  ))
  list(fit = fit, diag = diag)
})

test_that("fit_p_table returns TAM-style adjusted p columns", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag

  tab <- fit_p_table(fit, diagnostics = diag, scope = "element")

  expect_s3_class(tab, "data.frame")
  expect_true(all(c(
    "parameter", "Outfit", "Outfit_t", "Outfit_p", "Outfit_p_adj",
    "Outfit_pholm", "Infit", "Infit_t", "Infit_p", "Infit_p_adj",
    "Infit_pholm", "MisfitDirection", "PAdjustMethod"
  ) %in% names(tab)))
  expect_true(all(na.omit(tab$Outfit_p) >= 0 & na.omit(tab$Outfit_p) <= 1))
  expect_true(all(na.omit(tab$Infit_p_adj) >= 0 & na.omit(tab$Infit_p_adj) <= 1))
  expect_true(all(na.omit(tab$MisfitDirection) %in%
                    c("in_band", "underfit", "overfit", "mixed")))
  expect_identical(unique(tab$PAdjustMethod), "holm")
})

test_that("fit_p_table supports person and category scopes", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag

  person_tab <- fit_p_table(fit, diagnostics = diag, scope = "person")
  category_tab <- fit_p_table(fit, diagnostics = diag, scope = "category")

  expect_true(nrow(person_tab) > 0)
  expect_true(nrow(category_tab) > 0)
  expect_true(all(person_tab$Scope == "person"))
  expect_true(all(category_tab$Scope == "category"))
  expect_error(
    fit_p_table(fit, diagnostics = diag, p_adjust = "not_a_method"),
    "`p_adjust`"
  )
})

test_that("plot_empirical_fit returns mirt-style observed expected bins", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag
  target_level <- as.character(unique(diag$obs$Rater)[1])

  p <- plot_empirical_fit(
    fit,
    diagnostics = diag,
    facet = "Rater",
    level = target_level,
    bins = 5,
    draw = FALSE
  )

  expect_s3_class(p, "mfrm_plot_data")
  expect_identical(p$name, "empirical_fit")
  expect_true(all(c("bin_table", "raw_table", "fit_table", "target", "metric") %in%
                    names(p$data)))
  expect_identical(p$data$metric, "mean_score")
  expect_true(all(c("Observed", "Expected", "Residual", "SE", "StdResidual") %in%
                    names(p$data$bin_table)))
  expect_lte(nrow(p$data$bin_table), 5)
  expect_true(all(p$data$target$Facet == "Rater"))
})

test_that("plot_empirical_fit supports category-probability overlays and drawing", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag
  target_level <- as.character(unique(diag$obs$Rater)[1])
  category <- fit$prep$rating_max

  p <- plot_empirical_fit(
    fit,
    diagnostics = diag,
    facet = "Rater",
    level = target_level,
    category = category,
    bins = 4,
    draw = FALSE
  )

  expect_identical(p$data$metric, "category_probability")
  expect_equal(p$data$target$Category[1], category)
  expect_true(all(p$data$bin_table$Observed >= 0 & p$data$bin_table$Observed <= 1))
  expect_true(all(p$data$bin_table$Expected >= 0 & p$data$bin_table$Expected <= 1))

  pdf(NULL); on.exit(dev.off(), add = TRUE)
  expect_silent(plot_empirical_fit(
    fit,
    diagnostics = diag,
    facet = "Rater",
    level = target_level,
    bins = 4,
    draw = TRUE
  ))
})

test_that("plot_empirical_fit rejects ambiguous bin and category inputs", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag
  target_level <- as.character(unique(diag$obs$Rater)[1])

  expect_error(
    plot_empirical_fit(
      fit,
      diagnostics = diag,
      facet = "Rater",
      level = target_level,
      bins = NA,
      draw = FALSE
    ),
    "`bins`"
  )
  expect_error(
    plot_empirical_fit(
      fit,
      diagnostics = diag,
      facet = "Rater",
      level = target_level,
      category = fit$prep$rating_min + 0.5,
      draw = FALSE
    ),
    "`category`"
  )
})
