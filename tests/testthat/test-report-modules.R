test_that("anchor, linking and bias reports keep complete evidence without fitting", {
  dat <- load_mfrmr_data("example_core")
  anchors <- data.frame(Facet = "Criterion", Level = unique(dat$Criterion)[1], Value = .123456789)
  a <- review_mfrm_anchors(dat, "Person", c("Rater", "Criterion"), "Score", anchors = anchors)
  linking <- build_linking_review(anchor_review = a)
  bias <- structure(list(facet_a = "Rater", facet_b = "Criterion",
    table = data.frame(FacetA_Level = paste0("r", 1:12), FacetB_Level = "c1",
      `Bias Size` = seq(-.5, .6, .1), `S.E.` = .2, t = c(NA, 1:11),
      `Prob.` = c(NA, rep(.04, 11)), `Obs-Exp Average` = .1,
      BiasStatus = "available", ScreenStatus = "screening_only", FitStatus = "available",
      check.names = FALSE)), class = "mfrm_bias")
  before <- serialize(list(a, linking, bias), NULL)
  local_mocked_bindings(fit_mfrm = function(...) stop("Unexpected fitting"),
    estimate_bias = function(...) stop("Unexpected bias estimation"))
  ar <- mfrm_report(a)
  expect_identical(ar$tables$anchors, as.data.frame(a$anchors))
  expect_identical(ar$tables$anchor_issues, as.data.frame(a$issues))
  expect_match(paste(ar$notes, collapse = " "), "does not establish invariance")
  lr <- mfrm_report(linking)
  expect_identical(lr$tables$status, as.data.frame(linking$status))
  expect_false(linking$overview$DriftAvailable)
  expect_match(paste(lr$notes, collapse = " "), "Missing drift")
  br <- mfrm_report(bias)
  expect_identical(br$tables$bias_cells, bias$table)
  expect_equal(nrow(br$tables$top_rows), 12)
  expect_true(is.na(br$tables$bias_cells$`Prob.`[1]))
  expect_false(br$tables$overview$SupportsFormalInference)
  for (r in list(ar, lr, br)) {
    expect_identical(build_summary_table_bundle(summary(r, top_n = 1), include_empty = TRUE)$tables, r$tables)
    expect_true(all(build_summary_table_bundle(r)$table_index$Role %in%
      mfrmr:::summary_table_bundle_appendix_role_registry()$Role))
    expect_match(r$markdown, r$title, fixed = TRUE)
  }
  expect_identical(serialize(list(a, linking, bias), NULL), before)
  expect_error(mfrm_report(a, intervals = TRUE), "only to G/D")
  expect_error(mfrm_report(a, style = "rater"), "requires mfrm_results")
})

test_that("declarations survive G/D reports, appendix export and saving", {
  data("mfrmr_example_gtheory_crossed", package = "mfrmr", envir = environment())
  g <- mfrm_g_study(mfrmr_example_gtheory_crossed, c("Content", "Organization"))
  d <- mfrm_d_study(g, data.frame(Raters = 2, Tasks = 3))
  context <- c(question = "Compare scoring plans", score_direction = "Higher means harder to understand",
    transformation = "No reversal; do not infer favorable performance from the variable name")
  plain <- mfrm_report(d)
  r <- mfrm_report(d, study_context = context)
  expect_identical(r$tables[names(plain$tables)], plain$tables)
  expect_identical(r$study_context$Value, unname(context))
  expect_identical(mfrm_report(d, output = "tables", study_context = context), r$tables)
  expect_match(mfrm_report(d, output = "markdown", study_context = context), context[2], fixed = TRUE)
  h <- mfrm_report(d, output = "html", study_context = context)
  expect_match(paste(readLines(h$path, warn = FALSE), collapse = ""), context[2], fixed = TRUE)
  expect_identical(build_summary_table_bundle(summary(r, top_n = 1))$tables$study_context, r$study_context)
  out <- tempfile(); dir.create(out)
  export_summary_appendix(r, output_dir = out)
  files <- list.files(out, "study_context.*csv$", full.names = TRUE)
  expect_length(files, 1)
  expect_identical(read.csv(files)$Value, unname(context))
  saveRDS(r, file.path(out, "report.rds"))
  expect_identical(readRDS(file.path(out, "report.rds")), r)
  for (bad in list(character(), "unnamed", c(a = NA_character_), c(a = " "),
      c(a = "one", a = "two"), stats::setNames("value", ""), list(a = "text")))
    expect_error(mfrm_report(d, study_context = bad), "study_context")
})
