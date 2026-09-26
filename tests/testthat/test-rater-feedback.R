local({
  fit <- make_toy_fit(method = "MML", maxit = 500)
  diagnostics <- make_toy_diagnostics(fit)
  ci <- mfrm_facet_intervals(fit, "Rater")
  res <- mfrm_results(fit, diagnostics = diagnostics, intervals = list(raters = ci),
                      compute = "never", include = "standard")
  sheet <- function(x = res, ...) mfrm_report(x, style = "rater", facet = "Rater", rater = "R01", ...)

  test_that("individual sheets reuse saved estimates without invoking estimation", {
    local_mocked_bindings(fit_mfrm = function(...) stop("Unexpected refit"),
      diagnose_mfrm = function(...) stop("Unexpected diagnostics"),
      mfrm_facet_intervals = function(...) stop("Unexpected interval calculation"))
    s <- sheet()
    expect_s3_class(s, "mfrm_rater_feedback")
    expect_equal(s$tables$severity$Severity, ci$table$Estimate[1])
    expect_equal(s$tables$uncertainty$Lower, ci$table$Lower[1])
    expect_equal(s$tables$fit$Value, c(diagnostics$measures$Infit[diagnostics$measures$Facet == "Rater"][1],
      diagnostics$measures$Outfit[diagnostics$measures$Facet == "Rater"][1]))
    obs <- diagnostics$obs[diagnostics$obs$Rater == "R01", ]
    ord <- head(order(abs(obs$StdResidual), decreasing = TRUE), 5)
    expect_equal(s$tables$cases$Expected, obs$Expected[ord])
    expect_identical(s$tables$cases$Case, 1:5)
    expect_equal(sum(s$tables$categories$Percent), 100)
    expect_equal(s$tables$exposure$RatingRows, nrow(obs))
    expect_identical(sheet(output = "tables"), s$tables)
    expect_identical(sheet(output = "markdown"), s$markdown)
    expect_identical(sheet(audience = "researcher")$tables, s$tables)
    expect_match(sheet(audience = "researcher")$guidance, "plug-in")
    expect_output(print(s), "Rater feedback")
  })

  test_that("all distributed formats omit source identities, attributes and free text", {
    x <- res
    # Source strings may contain identifiers even outside the observations.
    x$notes <- "SECRET_PERSON_PRIVATE"
    x$diagnostics$approximation_notes <- "SECRET_OTHER_RATER_PRIVATE"
    x$facet_intervals$raters$cautions <- "SECRET_COMMENT_PRIVATE"
    attr(x$fit$facets$others$Estimate, "private") <- "SECRET_ATTRIBUTE_PRIVATE"
    x$fit$facets$others <- as.data.frame(x$fit$facets$others)
    rownames(x$fit$facets$others) <- paste0("SECRET_ROW_PRIVATE", seq_len(nrow(x$fit$facets$others)))
    h <- sheet(x, output = "html", label = "<script>alert(1)</script>")
    on.exit(unlink(h$path))
    text <- paste(capture.output(dput(h)), collapse = "\n")
    for (id in c(unique(as.character(fit$prep$data$Person)),
      unique(as.character(fit$prep$data$Rater)), unique(as.character(fit$prep$data$Criterion)),
      "SECRET_PERSON_PRIVATE", "SECRET_OTHER_RATER_PRIVATE", "SECRET_COMMENT_PRIVATE",
      "SECRET_ATTRIBUTE_PRIVATE", "SECRET_ROW_PRIVATE")) expect_false(grepl(id, text, fixed = TRUE), info = id)
    expect_false(grepl("<script>", h$html, fixed = TRUE))
    expect_match(h$html, "&lt;script&gt;", fixed = TRUE)
    expect_match(h$html, 'lang="en"', fixed = TRUE)
    expect_match(h$html, 'scope="col"', fixed = TRUE)
    expect_match(h$html, "@media print", fixed = TRUE)
    expect_false(grepl("src=|href=", h$html))
    expect_identical(paste(readLines(h$path, warn = FALSE), collapse = "\n"), h$html)
  })

  test_that("missing, ambiguous and wrong-target intervals do not silently become certainty", {
    x <- res; x$facet_intervals <- NULL; x$diagnostics <- NULL
    s <- sheet(x)
    expect_equal(nrow(s$tables$uncertainty), 0)
    expect_equal(nrow(s$tables$fit), 0)
    expect_match(s$notes[["uncertainty"]], "No saved")
    expect_match(s$notes[["fit"]], "not supplied")
    expect_match(sheet(max_cases = 0)$notes[["cases"]], "omitted")
    x <- res; x$facet_intervals$second <- ci
    expect_error(sheet(x), "Several saved intervals")
    expect_equal(sheet(x, interval = "second")$tables$uncertainty, sheet()$tables$uncertainty)
    x <- res
    x$facet_intervals$raters$contrasts[1, 2] <- -1
    expect_equal(nrow(sheet(x)$tables$uncertainty), 0)
    expect_error(sheet(x, interval = "raters"), "individual rater coefficient")
    x <- res; x$facet_intervals$raters$fit$opt$par[1] <- x$fit$opt$par[1] + .2
    expect_error(sheet(x), "must match")
    x <- res; x$facet_intervals$raters$table$Status[1] <- "unavailable"
    x$facet_intervals$raters$table$Lower[1] <- NA_real_
    expect_false(sheet(x)$tables$uncertainty$Available)
    expect_match(sheet(x)$notes[["uncertainty"]], "unavailable")
  })

  test_that("scale, direction and provisional fits retain their meanings", {
    x <- res; x$diagnostics <- NULL; x$facet_intervals <- NULL
    x$fit$config$facet_signs["Rater"] <- 1
    expect_equal(sheet(x)$tables$severity$Severity, -sheet()$tables$severity$Severity)
    x$fit$prep$score_map$OriginalScore <- c(0, 2, 5, 10)
    s <- sheet(x)
    expect_equal(s$tables$categories$OriginalScore, c(0, 2, 5, 10))
    expect_match(s$notes[["categories"]], "not converted")
    x$fit$readiness$fit$InferenceReady <- FALSE
    x$fit$readiness$fit$FitReadiness <- "review"
    expect_match(sheet(x)$review, "source fit needs review")
    x <- res; x$diagnostics$obs$Score[1] <- 99
    expect_error(sheet(x), "mismatch")
  })

  test_that("PCM and JML have descriptive sheets without implicit interval calculations", {
    for (spec in list(c("PCM", "MML"), c("RSM", "JML"))) {
      f <- make_toy_fit(model = spec[1], method = spec[2], maxit = 100)
      r <- mfrm_results(f, compute = "never", include = "fit")
      s <- sheet(r, audience = "researcher", max_cases = 0)
      expect_match(s$guidance, paste(spec[1], "model;", spec[2]), fixed = TRUE)
      expect_equal(nrow(s$tables$uncertainty), 0)
      expect_equal(sum(s$tables$categories$Ratings), sum(f$prep$data$Rater == "R01"))
    }
  })

  test_that("selection and model scope are explicit while other report styles remain intact", {
    expect_error(mfrm_report(res, style = "rater"), "facet")
    expect_error(mfrm_report(res, style = "rater", facet = "Person", rater = "P001"), "non-Person")
    expect_error(mfrm_report(res, style = "rater", facet = "Rater", rater = c("R01", "R02")), "one nonempty")
    expect_error(sheet(max_cases = -1), "nonnegative")
    expect_error(sheet(max_cases = 1.5), "nonnegative")
    expect_error(sheet(interval = "missing"), "individual rater coefficient")
    expect_error(mfrm_report(res, facet = NULL), "require")
    for (model in c("GPCM", "unknown")) {
      x <- res; x$fit$config$model <- model
      expect_error(sheet(x), "native additive RSM/PCM")
    }
    for (cl in c("mfrm_testlet", "mfrm_random_rater", "mfrm_imported_fit")) {
      x <- res; class(x$fit) <- cl
      expect_error(sheet(x), "native additive RSM/PCM")
    }
    x <- res; x$fit$config$interaction_specs <- list("Rater:Criterion")
    expect_error(sheet(x), "interaction")
    expect_s3_class(mfrm_report(res, "qc"), "mfrm_report")
    expect_identical(mfrm_report(res, "qc", "tables"), mfrm_report(res, "qc")$tables)
  })
})
