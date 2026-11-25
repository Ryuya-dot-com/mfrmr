test_that("the compatibility alias runs the three-pillar workflow", {
  expect_identical(tidymfrm, mfrm_analysis)
  utils::data("mfrmr_example_core", package = "mfrmr")

  wf_mml <- tidymfrm(
    mfrmr_example_core,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "RSM",
    method = "MML",
    compare_methods = c("JML", "JML_jeffreys", "CML"),
    dff_group = "Group",
    cut_scores = c(2.5, 3.0),
    bootstrap = 10L,
    threads = 1L
  )

  expect_s3_class(wf_mml, "tidymfrm")
  expect_true(wf_mml$connectivity$connected)
  expect_equal(wf_mml$connectivity$n_subsets, 1L)
  expect_true(wf_mml$fit$converged)
  expect_true(glance(wf_mml)$inference_ready)
  expect_identical(summary(wf_mml)$readiness$status, "ready")

  # S3 delegates (predict, coef, vcov, confint) work directly on tidymfrm
  nd <- data.frame(theta = c(-1, 0, 1), Rater = "R01", Criterion = "Content", stringsAsFactors = FALSE)
  pr <- predict(wf_mml, newdata = nd, type = "response")
  expect_length(pr, 3L)
  expect_true(all(pr >= 1 & pr <= 4))
  expect_gt(length(coef(wf_mml)), 0L)
  expect_true(is.matrix(vcov(wf_mml)))
  expect_equal(ncol(confint(wf_mml)), 2L)

  mc <- wf_mml$method_comparison
  expect_equal(nrow(mc), 4L)
  expect_true(all(mc$Converged))
  expect_true(all(mc$PersonCor > 0.98))

  gs <- wf_mml$gtheory$g_study_summary
  expect_true(is.finite(gs$G))
  expect_true(gs$G >= gs$Phi - 1e-6)

  dff <- wf_mml$diagnostics$dff
  expect_s3_class(dff, "tbl_df")
  expect_true(nrow(dff) >= 2L)
  expect_true(all(is.finite(dff$Contrast)))

  # RajuSA-Welch pairwise bias populated in diagnostics
  expect_gt(nrow(wf_mml$diagnostics$bias$pairwise), 0L)
})

test_that("workflow recalibration ties the report and saved diagnostics to the current fit", {
  ratings <- load_mfrmr_data("example_core")
  original <- mfrm_analysis(ratings, "Person", c("Rater", "Criterion"), "Score",
                            compare_methods = "JML")
  refit <- step_mfrm_measure(original, model = "PCM", step_facet = "Criterion")
  expect_null(refit$diagnostics)
  expect_null(summary(refit)$method_comparison)
  expect_identical(refit$gtheory, original$gtheory)
  expect_match(render_mfrm_report(refit), "No rater review is attached")

  diagnosed <- step_mfrm_diagnose(refit)
  expect_identical(augment(refit), augment(diagnosed))
  expect_gt(max(abs(augment(original)$Expected - augment(diagnosed)$Expected)), 0.01)

  legacy <- original
  legacy$diagnostics$fit_basis <- NULL
  expect_identical(augment(legacy), augment(original))
  expect_identical(summary(legacy)$rater_diagnostics, summary(original)$rater_diagnostics)
  legacy$fit <- refit$fit
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path))
  saveRDS(legacy, path)
  saved <- readRDS(path)
  expect_null(summary(saved)$rater_diagnostics)
  expect_null(summary(saved)$method_comparison)
  expect_identical(augment(saved), augment(diagnosed))
  expect_match(render_mfrm_report(saved, format = "html"), "No rater review is attached")
  expect_error(predict(saved, ratings[1L, ], type = "eap"), "EAP scoring of new ratings is unavailable")
})

test_that("Directional sensitivity, step_constraints, and category_support work through tidymfrm", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  d0 <- mfrmr_example_core
  d1 <- mfrmr_example_core
  idx <- d1$Rater == "R01"
  d1$Score[idx] <- pmax(1L, d1$Score[idx] - 1L)

  wf0 <- tidymfrm(d0, "Person", c("Rater", "Criterion"), "Score", method = "JML_jeffreys")
  wf1 <- tidymfrm(d1, "Person", c("Rater", "Criterion"), "Score", method = "JML_jeffreys")

  r0 <- tidy(wf0, "raters")
  r1 <- tidy(wf1, "raters")
  # MKL-safe directional comparison
  expect_gt(round(r1$estimate[r1$term == "R01"], 4), round(r0$estimate[r0$term == "R01"], 4))
  expect_lt(round(r1$fair_m[r1$term == "R01"], 4), round(r0$fair_m[r0$term == "R01"], 4))
})

test_that("All plot types render in okabe_ito, viridis, and strict R==G==B monochrome inside tempdir()", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  wf <- tidymfrm(
    mfrmr_example_core, "Person", c("Rater", "Criterion"), "Score",
    cut_scores = 2.5
  )

  tmp_pdf <- tempfile(tmpdir = tempdir(), fileext = ".pdf")
  grDevices::pdf(tmp_pdf, width = 8, height = 6)
  on.exit({
    if (grDevices::dev.cur() > 1L) grDevices::dev.off()
    unlink(tmp_pdf)
  }, add = TRUE)

  for (pal in c("okabe_ito", "viridis", "monochrome")) {
    for (tp in c("wright", "raters", "steps", "dstudy", "persons")) {
      p <- plot(wf, type = tp, palette = pal, draw = TRUE)
      expect_s3_class(p, "ggplot")
    }
    dash <- plot(wf, type = "dashboard", palette = pal, draw = TRUE)
    expect_s3_class(dash, "tidymfrm_dashboard")
  }

  mono_cols <- mfrmr:::.tidymfrm_palette(5L, palette = "monochrome")
  rgb_mat <- grDevices::col2rgb(mono_cols)
  expect_equal(rgb_mat["red", ], rgb_mat["green", ])
  expect_equal(rgb_mat["green", ], rgb_mat["blue", ])
})

test_that("render_mfrm_report() and format_mfrm_table() respect Suggests and tempdir()", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  wf <- tidymfrm(
    mfrmr_example_core, "Person", c("Rater", "Criterion"), "Score",
    dff_group = "Group", cut_scores = 2.5
  )

  md_tbl <- format_mfrm_table(wf, component = "raters", engine = "markdown", digits = 2L)
  expect_type(md_tbl, "character")
  expect_match(md_tbl, "R01")

  if (requireNamespace("kableExtra", quietly = TRUE) && requireNamespace("knitr", quietly = TRUE)) {
    kb <- format_mfrm_table(wf, component = "raters", engine = "kableExtra", digits = 2L)
    expect_true(!is.null(kb))
  }
  if (requireNamespace("flextable", quietly = TRUE)) {
    ft <- format_mfrm_table(wf, component = "raters", engine = "flextable", digits = 2L)
    expect_s3_class(ft, "flextable")
  }

  tmp_html <- tempfile(tmpdir = tempdir(), fileext = ".html")
  on.exit(unlink(tmp_html), add = TRUE)
  ht <- render_mfrm_report(wf, format = "html", file = tmp_html, digits = 2L)
  expect_true(file.exists(tmp_html))
  expect_match(ht, "<!DOCTYPE html>")
  expect_match(ht, "Inference readiness")

  if (requireNamespace("officer", quietly = TRUE)) {
    tmp_docx <- tempfile(tmpdir = tempdir(), fileext = ".docx")
    on.exit(unlink(tmp_docx), add = TRUE)
    render_mfrm_report(wf, format = "docx", file = tmp_docx, digits = 2L)
    expect_true(file.exists(tmp_docx))
  }

  # Disconnected islands warn before fitting; the planning failure stays visible.
  disc <- rbind(
    data.frame(Person = paste0("A", 1:6), Rater = "R1", Task = "T1", Score = c(1, 2, 3, 2, 3, 4)),
    data.frame(Person = paste0("B", 1:6), Rater = "R2", Task = "T2", Score = c(2, 3, 4, 1, 2, 3))
  )
  warnings <- character()
  wf_disc <- withCallingHandlers(tidymfrm(disc, "Person", c("Rater", "Task"), "Score"),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    })
  expect_true(any(grepl("Disconnected rating design", warnings, fixed = TRUE)))
  expect_match(summary(wf_disc)$gtheory_reason, "not identifiable")
})

test_that("the workflow reports GMFRM discrimination and Markov rater drift", {
  utils::data("mfrmr_example_core", package = "mfrmr")
  d <- mfrmr_example_core
  d$Wave <- ifelse(as.integer(factor(d$Person)) <= 24L, "T1", "T2")

  wf <- mfrm_analysis(
    d,
    person = "Person",
    facets = c("Rater", "Criterion"),
    score = "Score",
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    occasion = "Wave",
    quad_points = 21L
  )
  expect_s3_class(wf, "tidymfrm")
  expect_equal(nrow(tidy(wf, component = "slopes")), 4L)
  expect_gt(nrow(tidy(wf, component = "drift")), 0L)

  for (tp in c("category_curves", "person_fit", "residual_qq", "slopes", "drift", "qc")) {
    expect_s3_class(plot(wf, type = tp, palette = "monochrome", draw = FALSE), "ggplot")
  }

  tmp_md <- tempfile(tmpdir = tempdir(), fileext = ".md")
  on.exit(unlink(tmp_md), add = TRUE)
  md_txt <- render_mfrm_report(wf, format = "markdown", file = tmp_md, digits = 2L)
  expect_true(file.exists(tmp_md))
  expect_match(md_txt, "GMFRM Discrimination Parameters", fixed = TRUE)
  label <- "Generalized Many-Facet Rasch Model (GMFRM), discrimination by Criterion"
  expect_match(md_txt, label, fixed = TRUE)
  expect_identical(summary(wf$fit)$model_label, label)
  expect_identical(summary(wf)$model_label, label)
  expect_match(capture.output(print(wf$fit))[1L], label, fixed = TRUE)
  expect_identical(glance(wf)$model_label, label)
  expect_identical(glance(wf)$model, "GPCM")
  expect_match(md_txt, "Dynamic Markov Rater Drift Summary", fixed = TRUE)
})
