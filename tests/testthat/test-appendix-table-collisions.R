test_that("appendix export retains analysis tables with metadata names", {
  tables <- list(
    overview = data.frame(Persons = 3L, NotScored = 1L),
    reporting_map = data.frame(Source = "Stored scoring results"),
    table_overview = data.frame(Other = 7L),
    estimates = data.frame(Person = c("001", "NA"), Estimate = c(.25, NA_real_)),
    table_index = data.frame(AnalysisIndex = "Retain this source table")
  )
  roles <- setNames(rep("unit_estimates", length(tables)), names(tables))
  bundle <- structure(list(
    overview = data.frame(Title = "Saved scores", SourceClass = "fixture",
      SummaryClass = "summary.fixture", TablesAvailable = length(tables),
      TablesReturned = length(tables), AppendixPreset = "none"),
    table_index = build_summary_table_index(tables, roles, roles),
    plot_index = summary_table_bundle_plot_index(tables),
    tables = tables, notes = "Conditional on the saved calibration.",
    source_class = "fixture", summary_class = "summary.fixture",
    appendix_preset = "none"
  ), class = "mfrm_summary_table_bundle")
  local_mocked_bindings(fit_mfrm = function(...) stop("No fitting"),
    score_mfrm_calibration = function(...) stop("No scoring"))
  path <- tempfile("appendix-")
  on.exit(unlink(path, recursive = TRUE), add = TRUE)
  result <- export_summary_appendix(list(saved = bundle), path, include_html = TRUE)
  files <- result$written_files
  expect_false(anyDuplicated(files$Path) > 0L)
  tags <- c("table_overview", "table_reporting_map", "table_overview_1",
    "estimates", "table_table_index")
  for(i in seq_along(tables)) {
    f <- files$Path[files$Component == paste0("summary_saved_", tags[[i]]) & files$Format == "csv"]
    expect_length(f, 1L)
    expected <- tables[[i]]
    actual <- read.csv(f, colClasses = vapply(expected, function(x) class(x)[1], ""),
      na.strings = "", check.names = FALSE)
    expect_identical(actual, expected)
  }
  metadata <- read.csv(files$Path[files$Component == "summary_saved_overview"],
    check.names = FALSE)
  expect_identical(metadata$Title, "Saved scores")
  html <- paste(readLines(files$Path[files$Format == "html"], warn = FALSE), collapse = "\n")
  expect_match(html, "NotScored", fixed = TRUE)
  expect_match(html, "Stored scoring results", fixed = TRUE)
  expect_match(html, "Retain this source table", fixed = TRUE)
  expect_error(export_summary_appendix(list(saved = bundle), path), "already exists")
})
