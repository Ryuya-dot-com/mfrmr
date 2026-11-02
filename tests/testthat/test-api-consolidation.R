test_that("one clustering entry preserves method results and omitted PCA controls", {
  skip_if_not_installed("cluster")
  d <- data.frame(ID = letters[1:8], A = c(1, 2, 3, 4, 10, 11, 12, NA),
                  B = c(2, 1, 3, 4, 12, 11, 10, 13), Group = rep(c("X", "Y"), each = 4))
  mixed <- mfrm_features(d, "ID", c("A", "B", "Group"))
  numeric <- mfrm_features(d, "ID", c("A", "B"))
  expect_identical(mfrm_cluster(mixed, 2, missing = "omit"),
                   mfrm_cluster_pam(mixed, 2, missing = "omit"))
  for (linkage in c("average", "complete")) {
    result <- mfrm_cluster(mixed, 2, missing = "omit", method = "hierarchical", linkage = linkage)
    old <- mfrm_cluster_hierarchical(mixed, 2, missing = "omit", linkage = linkage)
    expect_identical(result, old)
    expect_identical(summary(result), summary(old))
    expect_true(is.na(result$membership$Cluster[8]))
  }
  expect_identical(mfrm_cluster(numeric, 2, missing = "omit", method = "kmeans", seed = 17),
                   mfrm_cluster_kmeans(numeric, 2, missing = "omit", seed = 17))
  pca <- mfrm_pca(numeric, components = 2, missing = "omit")
  result <- mfrm_cluster(pca, 2, method = "kmeans", seed = 17)
  expect_identical(result, mfrm_cluster_kmeans(pca, 2, seed = 17))
  expect_error(mfrm_cluster(pca, 2, missing = "omit", method = "kmeans"), "when fitting mfrm_pca")
  expect_error(mfrm_cluster(pca, 2, method = "kmeans", scale = TRUE), "when fitting mfrm_pca")
  expect_error(mfrm_cluster(mixed, 2, method = "pam", linkage = "complete"), "unused argument")
  expect_error(mfrm_cluster(mixed, 2, method = "hierarchical", seed = 3), "unused argument")
  expect_error(mfrm_cluster(mixed, 2, method = "unknown"), "arg")
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  saveRDS(result, path)
  expect_identical(summary(readRDS(path)), summary(result))
  expect_identical(plot_data(readRDS(path)), plot_data(result))
})

test_that("update preserves calibration transitions, identity and refusals", {
  fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))$fit
  draft <- mfrmr_extract_calibration_draft(fit, calibration_id = "consolidation",
    source_fit_id = "saved-operational", created_at_utc = "2026-10-29T00:00:00Z")
  validated <- update(draft, status = "validated", at_utc = "2026-10-29T00:01:00Z")
  expect_identical(validated, mfrmr_validate_calibration_draft(draft, "2026-10-29T00:01:00Z"))
  frozen <- update(validated, status = "frozen", at_utc = "2026-10-29T00:02:00Z")
  expect_identical(frozen, mfrmr_freeze_calibration(validated, "2026-10-29T00:02:00Z"))
  expect_identical(draft$lifecycle$state, "draft")
  expect_identical(validated$lifecycle$state, "validated")
  for (status in c("superseded", "retired")) {
    legacy <- if (status == "superseded") mfrmr_supersede_calibration else mfrmr_retire_calibration
    result <- update(frozen, status = status, record_id = "next-record", at_utc = "2026-10-29T00:03:00Z")
    expect_identical(result, legacy(frozen, "next-record", "2026-10-29T00:03:00Z"))
    expect_identical(frozen$lifecycle$state, "frozen")
  }
  expect_error(update(draft, status = "frozen"), class = "mfrm_calibration_error")
  expect_error(update(frozen, status = "validated"), class = "mfrm_calibration_error")
  expect_error(update(frozen, status = "retired"), class = "mfrm_calibration_error")
  expect_error(update(draft, status = "validated", record_id = "unused"), "only used")
  expect_error(update(draft, status = "validated", typo = TRUE), "Unused arguments")
  expect_error(update(draft, status = "draft"), "arg")
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  save_mfrm_calibration(frozen, path)
  expect_identical(load_mfrm_calibration(path), frozen)
})

test_that("FACETS guide topics retain their contracts and reject wrong controls", {
  terms <- facets_guide("terms")
  expect_true(all(c("FACETSTerm", "mfrmrTerm", "Boundary") %in% names(terms)))
  coverage <- facets_guide("coverage")
  for (status in unique(coverage$Status)) {
    expect_identical(facets_guide("coverage", status = status),
      coverage[coverage$Status == status, , drop = FALSE])
  }
  guide <- facets_guide("fit_df", include_references = FALSE)
  expect_s3_class(guide, "mfrm_facets_fit_df_guide")
  expect_identical(nrow(guide$references), 0L)
  expect_s3_class(summary(guide), "summary.mfrm_bundle")
  expect_error(facets_guide("unknown"), "arg")
  expect_error(facets_guide("terms", status = "partial"), "no additional")
  expect_error(facets_guide("coverage", include_references = FALSE), "unused argument")
  expect_error(facets_guide("fit_df", include_references = NA), "TRUE or FALSE")
  expect_false(any(c("mfrmRFacets", "facets_positioning_guide",
    "facets_feature_coverage", "facets_fit_df_guide", "facets_term_crosswalk",
    "facets_visual_contract") %in% getNamespaceExports("mfrmr")))
})

test_that("preset aggregation keeps separate denominators and drops empty groups", {
  catalog <- data.frame(Preset = c("all", "compact", "all", "compact", "all"),
    Selected = c(TRUE, TRUE, TRUE, FALSE, TRUE),
    Bundle = "one", AppendixSection = "results", Role = "fit",
    Table = letters[1:5], PlotReady = c(TRUE, FALSE, NA, TRUE, FALSE),
    NumericColumns = c(1, 0, NA, 2, 1))
  result <- structural_design_selection_by_preset(catalog,
    export_summary_table_selection_handoff_preset_summary,
    presets = c("compact", "all", "compact", "methods"))
  expect_identical(result$Preset, c("compact", "all"))
  expect_identical(result$Tables, c(1L, 3L))
  expect_equal(result$PlotReadyFraction, c(0, 1 / 3))
  expect_equal(result$NumericFraction, c(0, 2 / 3))
  expect_identical(rownames(result), c("1", "2"))
  expect_identical(structural_design_selection_by_preset(catalog[FALSE, ],
    export_summary_table_selection_handoff_preset_summary), data.frame())
})

test_that("table and file inputs retain ConQuest normalization and provenance", {
  population <- data.frame(Term = c("Intercept", "sigma2"), Est = c(0.2, 1))
  items <- data.frame(Item = c("I1", "I2"), Est = c(-0.3, 0.3))
  cases <- data.frame(Person = c("001", "1"), EAP = c(0.1, NA_real_))
  paths <- vapply(seq_len(3), function(i) tempfile(fileext = ".csv"), character(1))
  on.exit(unlink(paths), add = TRUE)
  for (i in seq_len(3)) utils::write.csv(list(population, items, cases)[[i]], paths[i], row.names = FALSE)
  old <- normalize_conquest_overlap_files(paths[1], paths[2], paths[3])
  current <- normalize_conquest_overlap_tables(paths[1], paths[2], paths[3], input = "files")
  expect_identical(current, old)
  tables <- normalize_conquest_overlap_tables(population, items, cases)
  explicit <- normalize_conquest_overlap_tables(population, items, cases, input = "tables")
  expect_identical(explicit, tables)
  expect_identical(current$conquest_case_eap$Person, c("001", "1"))
  expect_true(is.na(current$conquest_case_eap$Estimate[2]))
  expect_error(normalize_conquest_overlap_tables(population, items, cases, population_delimiter = "auto"), "require")
  expect_error(normalize_conquest_overlap_tables(paths[1], paths[2], tempfile(), input = "files"), "exist|found")
})

test_that("consolidated entry points replace redundant exports", {
  old <- c("mfrm_cluster_pam", "mfrm_cluster_hierarchical", "mfrm_cluster_kmeans",
    "validate_mfrm_calibration", "freeze_mfrm_calibration", "supersede_mfrm_calibration",
    "retire_mfrm_calibration", "normalize_conquest_overlap_files",
    "gpcm_mml_quadrature_sensitivity", "import_facets_fit_table",
    "analyze_dif", "mfrm_response_imputations",
    "read_facets_fit_table", "import_mirt_fit", "import_tam_fit", "import_erm_fit",
    "mfrmr_interval_guide", "visual_reporting_template",
    "gpcm_capability_matrix", "mfrm_calibration_capabilities",
    "anchor_review", "precision_review")
  expect_false(any(old %in% getNamespaceExports("mfrmr")))
  expect_true(all(c("mfrm_cluster", "normalize_conquest_overlap_tables",
    "mml_quadrature_sensitivity", "read_facets_results", "import_irt_fit",
    "mfrmr_output_guide") %in% getNamespaceExports("mfrmr")))
  expect_true(is.function(getS3method("update", "mfrm_calibration")))

  aliases <- compatibility_alias_table("functions")
  retired_025 <- c(
    "read_facets_fit_table", "import_mirt_fit", "import_tam_fit", "import_erm_fit",
    "mfrmr_interval_guide", "visual_reporting_template",
    "gpcm_capability_matrix", "mfrm_calibration_capabilities",
    "anchor_review", "precision_review"
  )
  expect_true(all(retired_025 %in% aliases$Alias))
  expect_true(all(aliases$Lifecycle[match(retired_025, aliases$Alias)] == "removed_export"))
})

test_that("mfrmr_output_guide scopes preserve consolidated guides and capability matrices", {
  expect_identical(mfrmr_output_guide("intervals"), mfrmr:::mfrmr_interval_guide())
  for (cat_name in c("visual", "table", "fit", "gpcm", "shrinkage")) {
    expect_identical(mfrmr_output_guide("intervals", cat_name),
                     mfrmr:::mfrmr_interval_guide(cat_name))
    expect_identical(mfrmr_output_guide("intervals", category = cat_name),
                     mfrmr:::mfrmr_interval_guide(cat_name))
  }
  expect_error(mfrmr_output_guide("intervals", "visual", category = "fit"), "at most one")
  expect_error(mfrmr_output_guide("intervals", bad = TRUE), "at most one")

  expect_identical(mfrmr_output_guide("visual_templates"),
                   mfrmr:::visual_reporting_template())
  for (cat_name in c("manuscript", "appendix", "diagnostic", "surface")) {
    expect_identical(mfrmr_output_guide("visual_templates", cat_name),
                     mfrmr:::visual_reporting_template(cat_name))
    expect_identical(mfrmr_output_guide("visual_templates", category = cat_name),
                     mfrmr:::visual_reporting_template(cat_name))
  }
  expect_error(mfrmr_output_guide("visual_templates", "manuscript", category = "appendix"), "at most one")
  expect_error(mfrmr_output_guide("visual_templates", bad = TRUE), "at most one")

  gpcm_default <- mfrmr_output_guide("gpcm_capabilities")
  expect_s3_class(gpcm_default, "mfrmr_gpcm_capabilities")
  expect_identical(gpcm_default, mfrmr:::gpcm_capability_matrix())
  expect_identical(mfrmr_output_guide("gpcm_capabilities", view = "scores"),
                   mfrmr:::gpcm_capability_matrix(view = "scores"))
  expect_identical(mfrmr_output_guide("gpcm_capabilities", view = "unavailable"),
                   mfrmr:::gpcm_capability_matrix(view = "unavailable"))
  expect_identical(mfrmr_output_guide("gpcm_capabilities", status = "supported_with_caveat"),
                   mfrmr:::gpcm_capability_matrix(status = "supported_with_caveat"))
  expect_output(print(gpcm_default), "GPCM")
  expect_error(mfrmr_output_guide("gpcm_capabilities", bad = TRUE), "Unsupported argument")

  expect_identical(mfrmr_output_guide("calibration_capabilities"),
                   mfrmr:::mfrm_calibration_capabilities())
  expect_error(mfrmr_output_guide("calibration_capabilities", "extra"), "no additional")
  expect_error(mfrmr_output_guide("plots", "extra"), "no additional")
  expect_error(mfrmr_output_guide("all", "extra"), "no additional")
})

test_that("facets_fit_review accepts read_facets_results objects and paths identically", {
  fit <- make_toy_fit()
  diag <- diagnose_mfrm(fit, residual_pca = "none")
  csv_path <- tempfile(fileext = ".csv")
  on.exit(unlink(csv_path), add = TRUE)
  src <- diag$measures[, c("Facet", "Level", "Estimate", "SE", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD", "PTMEA")]
  names(src)[names(src) == "Estimate"] <- "Measure"
  utils::write.csv(src, csv_path, row.names = FALSE)

  parsed <- read_facets_results(csv_path)
  legacy_tbl <- mfrmr:::read_facets_fit_table(csv_path)

  rev_results <- facets_fit_review(fit, facets_fit = parsed, diagnostics = diag)
  rev_path <- facets_fit_review(fit, facets_fit = csv_path, diagnostics = diag)
  rev_legacy <- facets_fit_review(fit, facets_fit = legacy_tbl, diagnostics = diag)

  expect_identical(rev_results, rev_legacy)
  expect_identical(rev_path, rev_legacy)

  empty_results <- parsed
  empty_results$table <- empty_results$table[0, , drop = FALSE]
  expect_error(facets_fit_review(fit, facets_fit = empty_results, diagnostics = diag),
               "Scorefile rows")
})

test_that("import_irt_fit dispatches identically across mirt, TAM, and eRm and guards unsupported modes", {
  wide <- data.frame(
    I1 = c(0L, 1L, 2L, 0L, 1L, 2L, 1L, 2L, 0L, 1L, 2L, 1L),
    I2 = c(0L, 0L, 1L, 1L, 2L, 2L, 0L, 1L, 2L, 1L, 1L, 2L),
    I3 = c(1L, 1L, 2L, 0L, 1L, 2L, 2L, 2L, 0L, 0L, 1L, 2L)
  )

  expect_error(import_irt_fit(list(a = 1), model = "PCM"), "supported external IRT result")
  fake_jml <- structure(list(), class = "tam.jml")
  expect_error(import_irt_fit(fake_jml, model = "PCM"), "tam\\.jml")

  if (requireNamespace("eRm", quietly = TRUE)) {
    erm_fit <- eRm::PCM(as.matrix(wide))
    auto_erm <- import_irt_fit(erm_fit, model = "PCM")
    explicit_erm <- import_irt_fit(erm_fit, model = "PCM", source = "erm")
    legacy_erm <- mfrmr:::import_erm_fit(erm_fit, model = "PCM")
    expect_identical(auto_erm, legacy_erm)
    expect_identical(explicit_erm, legacy_erm)
    expect_identical(summary(auto_erm), summary(legacy_erm))
    expect_error(import_irt_fit(erm_fit, model = "PCM", compute_fit = TRUE),
                 "compute_fit = TRUE")
    expect_error(import_irt_fit(erm_fit, model = "PCM", source = "tam"),
                 "tam\\.mml")
  }

  if (requireNamespace("TAM", quietly = TRUE)) {
    tam_fit <- TAM::tam.mml(wide, irtmodel = "PCM2",
                            control = list(progress = FALSE, maxiter = 25, snodes = 0, nodes = seq(-4, 4, length.out = 15)))
    auto_tam <- import_irt_fit(tam_fit, model = "PCM")
    explicit_tam <- import_irt_fit(tam_fit, model = "PCM", source = "tam")
    legacy_tam <- mfrmr:::import_tam_fit(tam_fit, model = "PCM")
    expect_identical(auto_tam, legacy_tam)
    expect_identical(explicit_tam, legacy_tam)
  }

  if (requireNamespace("mirt", quietly = TRUE)) {
    mirt_fit <- mirt::mirt(wide, 1, itemtype = "Rasch", verbose = FALSE, TOL = 1e-3)
    auto_mirt <- import_irt_fit(mirt_fit, model = "PCM")
    explicit_mirt <- import_irt_fit(mirt_fit, model = "PCM", source = "mirt")
    legacy_mirt <- mfrmr:::import_mirt_fit(mirt_fit, model = "PCM")
    expect_identical(auto_mirt, legacy_mirt)
    expect_identical(explicit_mirt, legacy_mirt)
  }
})

test_that("as_ggplot honors design_evaluation components and draw-free simulation lists", {
  skip_if_not_installed("ggplot2")
  # This test exercises plot dispatch. Full runs also regenerate its original
  # simulations; CRAN uses the bundled results and retains every plot check.
  full_simulation <- isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false")))
  des <- if (full_simulation) evaluate_mfrm_design(
    n_person = c(15, 25),
    n_rater = 3,
    n_criterion = 3,
    reps = 2,
    score_levels = 3,
    seed = 42
  ) else readRDS(system.file("examples", "simulation-design.rds",
                            package = "mfrmr", mustWork = TRUE))$result
  g_scan <- as_ggplot(des)
  g_tab <- as_ggplot(des, component = "data")
  expect_s3_class(g_scan, "ggplot")
  expect_s3_class(g_tab, "ggplot")
  expect_error(as_ggplot(des, component = "unknown"))

  payload_des <- plot(des, draw = FALSE)
  expect_s3_class(payload_des, "ggplot")
  expect_s3_class(as_ggplot(payload_des), "ggplot")
  expect_s3_class(as_ggplot(payload_des, component = "data"), "ggplot")
  saved_des <- structure(plot_data(payload_des), class = c("mfrm_design_evaluation_plot_data", "list"))
  expect_s3_class(as_ggplot(saved_des), "ggplot")
  expect_s3_class(as_ggplot(saved_des, component = "data"), "ggplot")
  expect_error(as_ggplot(saved_des, type = "scan"), "type")
  expect_error(as_ggplot(saved_des, unused = TRUE), "Unused")

  sig <- if (full_simulation) evaluate_mfrm_signal_detection(
    n_person = c(16, 24),
    n_rater = 3,
    n_criterion = 3,
    reps = 2,
    score_levels = 3,
    seed = 42
  ) else readRDS(system.file("examples", "simulation-signal-detection.rds",
                            package = "mfrmr", mustWork = TRUE))$result
  payload_sig <- plot(sig, draw = FALSE)
  expect_s3_class(payload_sig, "ggplot")
  expect_s3_class(as_ggplot(payload_sig), "ggplot")
  saved_sig <- structure(plot_data(payload_sig), class = c("mfrm_signal_detection_plot_data", "list"))
  expect_s3_class(as_ggplot(saved_sig), "ggplot")
  expect_s3_class(as_ggplot(saved_sig, component = "data"), "ggplot")
  expect_error(as_ggplot(saved_sig, type = "scan"), "type")
  expect_error(as_ggplot(saved_sig, unused = TRUE), "Unused")
})
