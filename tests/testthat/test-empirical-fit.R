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
    "Infit_pholm", "DF_Outfit", "DF_Infit", "DFMethod", "FitReference",
    "ZSTDCap", "MisfitDirection", "PAdjustMethod"
  ) %in% names(tab)))
  expect_true(all(na.omit(tab$Outfit_p) >= 0 & na.omit(tab$Outfit_p) <= 1))
  expect_true(all(na.omit(tab$Infit_p_adj) >= 0 & na.omit(tab$Infit_p_adj) <= 1))
  expect_equal(tab$Outfit_p, 2 * stats::pnorm(-abs(tab$Outfit_t)))
  expect_equal(tab$Infit_p, 2 * stats::pnorm(-abs(tab$Infit_t)))
  expect_false(any(tab$Facet == "Person"))
  expect_true(all(na.omit(tab$MisfitDirection) %in%
                    c("in_band", "underfit", "overfit", "mixed")))
  expect_identical(unique(tab$PAdjustMethod), "holm")
  expect_identical(unique(tab$FitReference), "mfrmr")
  expect_identical(unique(tab$DFMethod), "mfrmr_information")
})

test_that("fit_p_table can use FACETS-style moment df for ZSTD and p values", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag

  tab <- fit_p_table(fit, diagnostics = diag, scope = "element",
                     reference = "facets")

  expect_s3_class(tab, "data.frame")
  expect_true(nrow(tab) > 0)
  expect_identical(unique(tab$FitReference), "facets")
  expect_identical(unique(tab$DFMethod), "facets_moment")
  expect_true(all(is.na(tab$ZSTDCap) | tab$ZSTDCap == 9))
  expect_true(all(abs(na.omit(tab$Outfit_t)) <= 9))
  expect_equal(tab$Outfit_p, 2 * stats::pnorm(-abs(tab$Outfit_t)))
  expect_equal(tab$Infit_p, 2 * stats::pnorm(-abs(tab$Infit_t)))

  target <- tab[is.finite(tab$DF_Outfit) & is.finite(tab$DF_Infit), , drop = FALSE][1, ]
  obs <- as.data.frame(diag$obs, stringsAsFactors = FALSE)
  probs <- mfrmr:::compute_prob_matrix(fit)
  k_vals <- 0:(ncol(probs) - 1L)
  expected <- as.vector(probs %*% k_vals)
  diff <- sweep(
    matrix(k_vals, nrow = nrow(probs), ncol = ncol(probs), byrow = TRUE),
    1L,
    expected,
    "-"
  )
  obs$.FourthMoment <- rowSums(probs * diff^4)
  sub <- obs[as.character(obs[[target$Facet]]) == as.character(target$Level), , drop = FALSE]
  w <- mfrmr:::get_weights(sub)
  var <- as.numeric(sub$Var)
  fourth <- as.numeric(sub$.FourthMoment)
  ok <- is.finite(w) & w > 0 & is.finite(var) & var > 0 & is.finite(fourth)
  n_w <- sum(w[ok])
  info <- sum(w[ok] * var[ok])
  df_out <- 2 * n_w^2 / sum(w[ok] * (fourth[ok] / var[ok]^2 - 1))
  df_in <- 2 * info^2 / sum(w[ok] * (fourth[ok] - var[ok]^2))

  expect_equal(target$DF_Outfit, df_out, tolerance = 1e-8)
  expect_equal(target$DF_Infit, df_in, tolerance = 1e-8)
  expect_error(
    fit_p_table(fit, diagnostics = diag, scope = "category", reference = "facets"),
    "score-category"
  )
})

test_that("fit_direction_summary separates underfit and overfit rates", {
  fit <- empirical_fit_fixture$fit
  diag <- empirical_fit_fixture$diag

  dir_tab <- fit_direction_summary(fit, diagnostics = diag, scope = "element")

  expect_s3_class(dir_tab, "mfrm_fit_direction_summary")
  expect_true(all(c(
    "Facet", "UnderfitN", "OverfitN", "MixedN", "InBandN",
    "UnderfitRate", "OverfitRate", "MixedRate", "InBandRate",
    "AnyMisfitRate", "PFlagRate"
  ) %in% names(dir_tab)))
  expect_true(all(na.omit(dir_tab$UnderfitRate) >= 0 & na.omit(dir_tab$UnderfitRate) <= 1))
  expect_true(all(na.omit(dir_tab$OverfitRate) >= 0 & na.omit(dir_tab$OverfitRate) <= 1))
  expect_equal(
    dir_tab$AnyMisfitN,
    dir_tab$UnderfitN + dir_tab$OverfitN + dir_tab$MixedN
  )
  expect_equal(
    dir_tab$AnyMisfitRate,
    dir_tab$AnyMisfitN / dir_tab$Classified
  )

  p <- plot_fit_direction_summary(dir_tab, draw = FALSE)
  expect_s3_class(p, "mfrm_plot_data")
  expect_identical(p$name, "fit_direction_summary")
  expect_true(all(c("Direction", "Value") %in% names(p$data$data)))

  facets_dir <- fit_direction_summary(
    fit,
    diagnostics = diag,
    scope = "element",
    reference = "facets"
  )
  expect_identical(unique(facets_dir$FitReference), "facets")
  expect_identical(unique(facets_dir$DFMethod), "facets_moment")
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
