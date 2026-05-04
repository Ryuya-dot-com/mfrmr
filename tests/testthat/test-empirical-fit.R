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
  expect_equal(tab$Outfit_p, 2 * stats::pnorm(-abs(tab$Outfit_t)))
  expect_equal(tab$Infit_p, 2 * stats::pnorm(-abs(tab$Infit_t)))
  expect_false(any(tab$Facet == "Person"))
  expect_true(all(na.omit(tab$MisfitDirection) %in%
                    c("in_band", "underfit", "overfit", "mixed")))
  expect_identical(unique(tab$PAdjustMethod), "holm")
})

test_that("fit_p_table cross-package orientation is high agreement but not identity", {
  skip_on_cran()
  if (!requireNamespace("mirt", quietly = TRUE) ||
      !requireNamespace("TAM", quietly = TRUE)) {
    skip("mirt and TAM are needed for the cross-package orientation test.")
  }

  toy <- load_mfrmr_data("example_core")
  toy$Score0 <- toy$Score - 1L
  toy$Item <- paste(toy$Rater, toy$Criterion, sep = "__")
  wide <- reshape(
    toy[, c("Person", "Item", "Score0")],
    idvar = "Person",
    timevar = "Item",
    direction = "wide"
  )
  rownames(wide) <- wide$Person
  resp <- wide[, setdiff(names(wide), "Person"), drop = FALSE]
  names(resp) <- sub("^Score0\\.", "", names(resp))

  fit <- suppressMessages(suppressWarnings(
    fit_mfrm(toy, "Person", "Item", "Score0",
             method = "MML", model = "PCM", maxit = 60,
             rating_min = 0, rating_max = 3)
  ))
  diag <- suppressMessages(suppressWarnings(
    diagnose_mfrm(fit, residual_pca = "none")
  ))
  mfr_tab <- fit_p_table(fit, diagnostics = diag)
  mfr_tab$item <- sub("^Item:", "", mfr_tab$parameter)

  tam_fit <- suppressMessages(suppressWarnings(
    TAM::tam.mml(resp = resp, irtmodel = "PCM2",
                 control = list(maxiter = 60), verbose = FALSE)
  ))
  tam_item <- data.frame(
    item = rownames(tam_fit$item),
    TAM = tam_fit$item$xsi.item,
    stringsAsFactors = FALSE
  )
  tam_tab <- as.data.frame(
    suppressMessages(suppressWarnings(
      TAM::tam.fit(tam_fit, progress = FALSE, seed = 1)
    ))$itemfit,
    stringsAsFactors = FALSE
  )
  tam_tab$item <- as.character(tam_tab$parameter)

  mirt_fit <- suppressMessages(suppressWarnings(
    mirt::mirt(as.data.frame(resp), 1,
               itemtype = rep("Rasch", ncol(resp)),
               verbose = FALSE,
               technical = list(NCYCLES = 60))
  ))
  mirt_coef <- mirt::coef(mirt_fit, IRTpars = TRUE, simplify = TRUE)$items
  mirt_item <- data.frame(
    item = rownames(mirt_coef),
    mirt = rowMeans(mirt_coef[, c("b1", "b2", "b3"), drop = FALSE]),
    stringsAsFactors = FALSE
  )
  mirt_infit <- as.data.frame(
    mirt::itemfit(mirt_fit, fit_stats = "infit", method = "ML"),
    stringsAsFactors = FALSE
  )
  mirt_infit$item <- as.character(mirt_infit$item)
  mirt_sx2 <- as.data.frame(
    mirt::itemfit(mirt_fit, fit_stats = "S_X2"),
    stringsAsFactors = FALSE
  )

  mfr_item <- data.frame(
    item = fit$facets$others$Level,
    mfrmr = fit$facets$others$Estimate,
    stringsAsFactors = FALSE
  )
  estimate_join <- Reduce(function(x, y) merge(x, y, by = "item"),
                          list(mfr_item, tam_item, mirt_item))
  estimate_join$mfrmr <- as.numeric(scale(estimate_join$mfrmr, scale = FALSE))
  estimate_join$TAM <- as.numeric(scale(estimate_join$TAM, scale = FALSE))
  estimate_join$mirt <- as.numeric(scale(estimate_join$mirt, scale = FALSE))
  expect_gt(stats::cor(estimate_join$mfrmr, estimate_join$TAM), 0.999)
  expect_gt(stats::cor(estimate_join$mfrmr, estimate_join$mirt), 0.999)

  fit_join <- Reduce(function(x, y) merge(x, y, by = "item"),
                     list(
                       mfr_tab[, c("item", "Outfit", "Infit")],
                       tam_tab[, c("item", "Outfit", "Infit")],
                       mirt_infit[, c("item", "outfit", "infit")]
                     ))
  names(fit_join) <- c("item", "mfr_Outfit", "mfr_Infit",
                       "tam_Outfit", "tam_Infit",
                       "mirt_Outfit", "mirt_Infit")
  expect_gt(stats::cor(fit_join$mfr_Outfit, fit_join$tam_Outfit), 0.95)
  expect_gt(stats::cor(fit_join$mfr_Infit, fit_join$mirt_Infit), 0.95)
  expect_gt(mean(abs(fit_join$mfr_Outfit - fit_join$tam_Outfit)), 0.001)
  expect_false(any(c("S_X2", "p.S_X2", "RMSEA.S_X2") %in% names(mfr_tab)))
  expect_true(all(c("S_X2", "p.S_X2", "RMSEA.S_X2") %in% names(mirt_sx2)))
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
