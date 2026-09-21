test_that("G-study omission is explicit and D-study retains its source-row accounting", {
  skip_if_not_installed("lme4")
  fit <- make_toy_fit(maxit = 150)
  data <- as.data.frame(fit$prep$data)
  baseline <- mfrm_generalizability(fit, data = data)
  n <- nrow(data)
  extra <- data[1:3, ]
  extra$Score[c(1, 3)] <- NA_real_
  extra$Rater[c(2, 3)] <- NA
  input <- rbind(data, extra)
  input$Unselected <- NA_real_
  expect_error(mfrm_generalizability(fit, data = input), "3 row.*missing")
  out <- mfrm_generalizability(fit, data = input, missing = "omit")
  expect_identical(out$variance_components, baseline$variance_components)
  expect_identical(out$coefficients[c("G", "Phi")], baseline$coefficients[c("G", "Phi")])
  expect_identical(out$data_usage$source, "Supplied data")
  expect_identical(out$data_usage$missing, "omit")
  expect_equal(out$data_usage$counts, c(InputRows = n + 3L, UsedRows = n, ExcludedRows = 3L))
  expect_equal(out$data_usage$excluded_rows, n + 1:3)
  expect_equal(out$data_usage$missing_cells,
    data.frame(InputRow = n + c(2L, 3L, 1L, 3L), Column = c("Rater", "Rater", "Score", "Score")))
  expect_equal(unname(unlist(out$coefficients[c("InputRows", "UsedRows", "ExcludedRows")])),
               c(n + 3L, n, 3L))
  expect_output(print(out), "3 excluded")
  expect_output(print(out), "no missing values were imputed")

  ds <- mfrm_d_study(out, data.frame(Rater = c(2, 4), Criterion = 3))
  expect_equal(ds$InputRows, rep(n + 3L, 2))
  expect_equal(ds$UsedRows, rep(n, 2))
  expect_equal(ds$ExcludedRows, c(3L, 3L))
  expect_identical(attr(ds, "data_usage"), out$data_usage)
  expect_identical(attr(ds[1, c("G", "Phi"), drop = FALSE], "data_usage"), out$data_usage)
  expect_output(print(ds[1, c("G", "Phi"), drop = FALSE]), "3 excluded")
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv))
  utils::write.csv(ds, csv, row.names = FALSE)
  expect_equal(utils::read.csv(csv)$ExcludedRows, ds$ExcludedRows)
  expect_equal(utils::read.csv(csv)$GStudyDataSource, rep("Supplied data", 2))
  direct <- mfrm_d_study(fit, data = input, missing = "omit")
  expect_identical(attr(direct, "data_usage"), out$data_usage)
  expect_error(mfrm_d_study(fit, data = input), "missing.*omit")

  stored <- mfrm_generalizability(fit)
  expect_identical(stored$data_usage$source, "Stored fitted rows")
  expect_equal(stored$data_usage$counts, c(InputRows = n, UsedRows = n, ExcludedRows = 0L))
  expect_equal(nrow(stored$data_usage$missing_cells), 0L)
  expect_output(print(stored), "earlier MFRM filtering is not included")
  legacy <- baseline
  legacy$data_usage <- NULL
  legacy$coefficients[c("InputRows", "UsedRows", "ExcludedRows", "GStudyDataSource")] <- NULL
  legacy_ds <- mfrm_d_study(legacy)
  expect_true(all(is.na(legacy_ds[c("InputRows", "UsedRows", "ExcludedRows")])))
  expect_true(is.na(legacy_ds$GStudyDataSource))
  expect_output(print(legacy_ds), "accounting is unavailable")
  expect_output(print(legacy), "accounting is unavailable")
})

test_that("G-study refuses malformed scores instead of silently discarding them", {
  skip_if_not_installed("lme4")
  fit <- make_toy_fit(maxit = 150)
  data <- as.data.frame(fit$prep$data)
  invalid <- data
  invalid$Score <- as.character(invalid$Score)
  invalid$Score[1] <- "not recorded"
  expect_error(mfrm_generalizability(fit, invalid), "nonnumeric or infinite")
  expect_error(mfrm_generalizability(fit, invalid, missing = "omit"), "nonnumeric or infinite")
  invalid$Score[1] <- " "
  expect_error(mfrm_generalizability(fit, invalid, missing = "omit"), "use NA")
  invalid <- data
  invalid$Score[1] <- Inf
  expect_error(mfrm_generalizability(fit, invalid, missing = "omit"), "infinite")
  invalid$Score <- as.Date("2026-01-01") + seq_len(nrow(data))
  expect_error(mfrm_generalizability(fit, invalid), "must be numeric")
  invalid$Score <- rep(NA_real_, nrow(data))
  expect_error(mfrm_generalizability(fit, invalid, missing = "omit"), "No complete rows")
  invalid <- data
  invalid$Rater <- as.character(invalid$Rater)
  invalid$Rater[1] <- " "
  expect_error(mfrm_generalizability(fit, invalid, missing = "omit"), "blank labels")
  expect_error(mfrm_generalizability(fit, reml = "TRUE"), "TRUE or FALSE")
  expect_error(mfrm_generalizability(fit, data, object_facet = "Score"), "reserved")
  invalid <- data
  invalid$Rater <- as.numeric(invalid$Rater)
  invalid$Rater[1] <- NaN
  expect_error(mfrm_generalizability(fit, invalid), "1 row.*missing")

  # Numeric labels retain their values rather than becoming factor level codes.
  baseline <- mfrm_generalizability(fit, data)
  data$Score <- factor(data$Score, levels = rev(sort(unique(data$Score))))
  labelled <- mfrm_generalizability(fit, data)
  expect_identical(labelled$variance_components, baseline$variance_components)
  # Literal facet names must not be interpreted as formula expressions.
  names(data)[names(data) == "Rater"] <- "Rater group"
  named <- mfrm_generalizability(fit, data, random_facets = c("Rater group", "Criterion"))
  expect_equal(named$coefficients[c("G", "Phi")], baseline$coefficients[c("G", "Phi")])
  expect_true("Rater group" %in% named$variance_components$Source)
})
