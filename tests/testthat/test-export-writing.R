test_that("appendix files retain all cells, selection counts and export order", {
  cells <- data.frame(FacetA_Level = c("日本語", "unavailable"), FacetB_Level = "c1",
    `Bias Size` = c(.123456789012345, NA_real_), `S.E.` = c(.2, NA_real_),
    t = c(.617283945, NA_real_), `Prob.` = c(.5, NA_real_),
    `Obs-Exp Average` = c(.1, NA_real_),
    BiasStatus = c("available", "unavailable"),
    ScreenStatus = c("screening_only", "unavailable"),
    FitStatus = c("available", "unavailable"), check.names = FALSE)
  bias <- structure(list(facet_a = "Rater", facet_b = "Criterion", table = cells),
    class = "mfrm_bias")
  report <- mfrm_report(bias)
  local_mocked_bindings(fit_mfrm = function(...) stop("Unexpected fitting"),
    estimate_bias = function(...) stop("Unexpected bias estimation"))
  out <- tempfile(); dir.create(out)
  on.exit(unlink(out, recursive = TRUE), add = TRUE)
  x <- export_summary_appendix(list(first = report, second = report),
    output_dir = out, prefix = "proof")
  expect_identical(names(x$written_files), c("Component", "Format", "Path"))
  expect_identical(x$selection_summary$TablesAvailable, c(8L, 8L))
  expect_identical(x$selection_summary$TablesSelected, c(8L, 8L))
  expect_identical(x$selection_summary$SelectionFraction, c(1, 1))
  expect_true(all(file.exists(x$written_files$Path)))
  csv <- read.csv(file.path(out, "proof_summary_first_bias_cells.csv"), check.names = FALSE)
  expect_identical(csv$FacetA_Level, cells$FacetA_Level)
  expect_equal(csv$`Bias Size`, cells$`Bias Size`, tolerance = 1e-14)
  expect_identical(csv$BiasStatus, cells$BiasStatus)
  selections <- x$written_files$Component[grepl("^appendix_selection_", x$written_files$Component)]
  expect_identical(selections, paste0("appendix_selection_", c("summary", "table_summary",
    "section_table_summary", "handoff_table_summary", "handoff_preset_summary",
    "handoff_summary", "handoff_bundle_summary", "handoff_role_summary",
    "handoff_role_section_summary", "catalog", "role_summary", "section_summary")))
  expect_identical(tail(x$written_files$Component, 1), "appendix_html")
  selection <- read.csv(file.path(out, "proof_appendix_selection_summary.csv"))
  expect_identical(selection$TablesSelected, c(8L, 8L))
  saveRDS(x, file.path(out, "export.rds"))
  expect_identical(readRDS(file.path(out, "export.rds")), x)
  expect_identical(summary(readRDS(file.path(out, "export.rds"))), summary(x))

  collision_dir <- file.path(out, "collision"); dir.create(collision_dir)
  protected <- file.path(collision_dir, "proof_appendix_selection_table_summary.csv")
  writeLines("Keep this content", protected)
  expect_error(export_summary_appendix(report, output_dir = collision_dir, prefix = "proof"),
    "File already exists:")
  expect_identical(readLines(protected), "Keep this content")
  expect_true(file.exists(file.path(collision_dir, "proof_appendix_selection_summary.csv")))
  expect_false(file.exists(file.path(collision_dir, "proof_appendix_selection_section_table_summary.csv")))
  replaced <- export_summary_appendix(report, output_dir = collision_dir, prefix = "proof", overwrite = TRUE)
  expect_true(all(file.exists(replaced$written_files$Path)))
  expect_false(identical(readLines(protected), "Keep this content"))
})

test_that("bundle replay text retains its R format without fitting", {
  saved <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
  before <- serialize(saved, NULL)
  local_mocked_bindings(fit_mfrm = function(...) stop("Unexpected fitting"),
    diagnose_mfrm = function(...) stop("Unexpected diagnostics"),
    estimate_bias = function(...) stop("Unexpected bias estimation"))
  out <- tempfile(); dir.create(out)
  on.exit(unlink(out, recursive = TRUE), add = TRUE)
  x <- export_mfrm_bundle(saved$fit, diagnostics = saved$diagnostics,
    output_dir = out, include = "script", acknowledge_sensitive = TRUE)
  row <- x$written_files[x$written_files$Component == "replay_script", , drop = FALSE]
  expect_identical(row$Format, "r")
  expect_identical(basename(row$Path), "mfrmr_bundle_replay.R")
  expect_true(file.exists(row$Path))
  expect_gt(length(parse(row$Path)), 0)
  expect_identical(serialize(saved, NULL), before)
})

test_that("appendix count views keep row denominators and their distinct groups", {
  catalog <- data.frame(Preset = c("all", "all", "all", "compact", "all", "all"),
    Selected = c(TRUE, TRUE, TRUE, TRUE, FALSE, NA),
    Bundle = c("one", "two", "one", "one", "one", "two"),
    AppendixSection = c("results", "results", "methods", "results", "methods", "methods"),
    Role = c("fit", "fit", "precision", "fit", "fit", "precision"),
    Table = c("same", "same", "precision", "other", "ignored", "unselected"),
    PlotReady = c(TRUE, NA, FALSE, TRUE, TRUE, TRUE),
    NumericColumns = c(2L, NA, 0L, 1L, 4L, 2L))
  counts <- mfrmr:::export_summary_table_selection_counts
  preset <- counts(catalog, view = "preset")
  expect_identical(preset$Tables, 3L)
  expect_identical(preset$PlotReadyTables, 1L)
  expect_identical(preset$NumericTables, 1L)
  expect_identical(preset$BundlesCovered, 2L)
  expect_identical(preset$SectionsCovered, 2L)
  expect_equal(preset$PlotReadyFraction, 1 / 3)
  expect_equal(preset$NumericFraction, 1 / 3)
  section <- counts(catalog, view = "section")
  expect_identical(section$AppendixSection, c("methods", "results"))
  expect_identical(section$Tables, c(1L, 2L))
  expect_equal(section$PlotReadyFraction, c(0, .5))
  expect_type(section$RolesCovered, "character")
  bundles <- counts(catalog, view = "section_bundle")
  expect_identical(bundles$Bundle, c("one", "one", "two"))
  expect_identical(bundles$Tables, rep(1L, 3L))
  roles <- counts(catalog, view = "role")
  expect_identical(roles$Role, c("fit", "precision"))
  expect_identical(roles$Tables, c(2L, 1L))
  expect_equal(roles$PlotReadyFraction, c(.5, 0))
  role_sections <- counts(catalog, view = "role_section")
  expect_identical(role_sections$Role, c("precision", "fit"))
  expect_identical(role_sections$Tables, c(1L, 2L))
  appendix_role <- counts(catalog, view = "appendix_role")
  expect_identical(appendix_role$BundlesCovered, c(2L, 1L))
  appendix_section <- counts(catalog, view = "appendix_section")
  expect_identical(appendix_section$Tables, c(2L, 1L))
  expect_identical(appendix_section$BundlesCovered, c(2L, 1L))
  expect_identical(counts(catalog, preset = "compact", view = "preset")$Tables, 1L)
  expect_identical(counts(catalog, preset = "methods", view = "preset"), data.frame())
  empty <- catalog; empty$Selected <- FALSE
  expect_identical(counts(empty, view = "section"), data.frame())
  unlabelled <- catalog; unlabelled$Role <- NA_character_
  expect_error(counts(unlabelled, view = "role"), "^argument 1 is not a vector$")
  unlabelled$AppendixSection <- NA_character_
  expect_error(counts(unlabelled, view = "section"), "^argument 1 is not a vector$")
})
