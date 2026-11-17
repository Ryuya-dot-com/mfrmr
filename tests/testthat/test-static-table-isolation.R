test_that("editing a guide cannot change subsequent guide or report output", {
  original <- mfrmr_output_guide("all")
  changed <- mfrmr_output_guide("all")
  changed$Question[1L] <- "caller annotation"
  changed$new_column <- TRUE
  expect_identical(mfrmr_output_guide("all"), original)
  plots <- mfrmr_output_guide("plots")
  modified <- plots
  modified[1L, 1L] <- "caller annotation"
  expect_identical(mfrmr_output_guide("plots"), plots)
})

test_that("empty schemas retain column types and isolate caller changes", {
  schema <- mfrmr:::.mfrmr_empty_table(c(Label = "character", Count = "integer",
    Estimate = "double", Available = "logical"))
  expected <- data.frame(Label = character(), Count = integer(),
    Estimate = double(), Available = logical())
  expect_identical(schema, expected)
  expect_identical(mfrmr:::.mfrmr_empty_table(c(Label = "character", Count = "integer",
    Estimate = "double", Available = "logical"), tbl = TRUE), tibble::as_tibble(expected))

  original <- mfrmr:::empty_data_quality_quality_flags
  changed <- original
  changed[1L, ] <- list("responses", "warning", "caller note", 1L,
    "annotation", 100, "review")
  names(changed)[1L] <- "CallerArea"
  attr(changed, "caller_note") <- TRUE
  expect_identical(mfrmr:::empty_data_quality_quality_flags, original)
  expect_identical(nrow(original), 0L)
  expect_identical(typeof(original$Count), "integer")
})

test_that("shared selection inputs preserve preset rows, zero counts and unavailable fractions", {
  rows <- data.frame(Preset = c("recommended", "compact", "recommended"),
    Role = c("A", "B", "C"), PlotReadyTables = c(2, 4, 0),
    PlotReadyFraction = c(.5, 1, NA_real_))
  sx <- list(selection_handoff_role_summary = rows)
  for (context in c("bundle", "structural", "export")) {
    expected <- if (context == "export") rows else rows[c(1L, 3L), , drop = FALSE]
    count <- mfrmr:::resolve_selection_plot_inputs(sx, "selection_handoff_roles",
      "count", "recommended", context)
    expect_identical(count$table, expected)
    expect_identical(count$labels, expected$Role)
    expect_identical(count$measure$values, expected$PlotReadyTables)
    fraction <- mfrmr:::resolve_selection_plot_inputs(sx, "selection_handoff_roles",
      "fraction", "recommended", context)
    expect_identical(fraction$measure$values, expected$PlotReadyFraction)
  }
  sx$selection_handoff_role_summary$PlotReadyTables <- NULL
  expect_error(mfrmr:::resolve_selection_plot_inputs(sx, "selection_handoff_roles",
    "count", "recommended", "bundle"), "appendix handoff-role rows")
  sx <- list(selection_table_summary = data.frame(Table = c("a", "b", "c"),
    Presets = c("compact", "recommended, compact", "recommended"), Rows = c(4L, 2L, 0L)))
  selected <- mfrmr:::resolve_selection_plot_inputs(sx, "selection_tables",
    "count", "recommended", "bundle")
  expect_identical(selected$labels, c("b", "c"))
  expect_identical(selected$measure$values, c(2, 0))
  expect_error(mfrmr:::resolve_selection_plot_inputs(sx, "selection_tables",
    "fraction", "recommended", "bundle"), "only exposes table row counts")
})

test_that("appendix-role plot data retain both named series colours", {
  data <- data.frame(Person = c("p1", "p2"), Rater = c("r1", "r1"), Score = 0:1)
  bundle <- build_summary_table_bundle(describe_mfrm_data(data,
    person = "Person", facets = "Rater", score = "Score"))
  p <- plot(bundle, type = "appendix_roles", draw = FALSE,
    palette = c(appendix_role_recommended = "#112233", appendix_role_compact = "#445566"))
  legend <- plot_data(p)$legend
  expect_identical(legend$label, c("Recommended", "Compact"))
  expect_identical(legend$value, c("#112233", "#445566"))
})


test_that("summary bundles preserve nested sources and distinct text column names", {
  sx <- structure(list(overview = data.frame(), mapping = data.frame(), run_info = data.frame(),
    fit = list(overview = data.frame(Value = c(0, NA_real_))),
    diagnostics = list(flags = data.frame(Flagged = 2L))
  ), class = "summary.mfrm_facets_run")
  bundle <- build_summary_table_bundle(sx,
    which = c("diagnostic_flags", "fit_overview", "mapping"))
  expect_identical(names(bundle$tables), c("diagnostic_flags", "fit_overview", "mapping"))
  expect_identical(bundle$tables$fit_overview, sx$fit$overview)
  expect_identical(bundle$tables$diagnostic_flags, sx$diagnostics$flags)
  expect_identical(bundle$tables$mapping, data.frame())
  expect_identical(bundle$table_index$Role, c("flag_counts", "run_overview", "column_mapping"))
  expect_identical(bundle$table_index$Description[2L],
    "Nested model-fit overview routed from summary(out$fit).")
  bundle$tables$fit_overview$Value[1L] <- 99
  expect_identical(build_summary_table_bundle(sx, which = "fit_overview")$tables$fit_overview,
    sx$fit$overview)

  assessment <- structure(c(stats::setNames(rep(list(data.frame()), 9L),
    c("overview", "reading_order", "checklist", "condition_reporting_notes", "condition_review",
      "diagnostic_reporting_notes", "diagnostic_review", "metric_review", "uncertainty_review")),
    list(next_actions = c("Check coverage", NA_character_), notes = "Intervals remain unavailable")),
    class = "summary.mfrm_recovery_assessment")
  out <- build_summary_table_bundle(assessment, which = c("next_actions", "notes", "thresholds"))
  expect_identical(out$tables$next_actions,
    data.frame(Action = c("Check coverage", NA_character_)))
  expect_identical(out$tables$notes, data.frame(Note = "Intervals remain unavailable"))
  expect_identical(out$tables$thresholds, data.frame())
  expect_identical(out$table_index$Role,
    c("repair_recommendations", "interpretation_notes", "review_settings"))
  expect_error(build_summary_table_bundle(assessment, which = "not_a_table"),
    "received unknown `which` table name", fixed = TRUE)
})


test_that("summary table printing retains source reads and malformed-input refusals", {
  sections <- rbind(c(field = "Table", heading = "\nValues\n", cast = "frame",
    rounded = "yes", guard = "present"))
  reads <- 0L
  x <- new.env(parent = emptyenv())
  makeActiveBinding("Table", function() {
    reads <<- reads + 1L
    data.frame(Value = c(1.234, NA_real_))
  }, x)
  out <- capture.output(mfrmr:::print_summary_sections(x, sections, digits = 2L))
  expect_identical(reads, 3L)
  expect_true("Values" %in% out)
  expect_true(any(grepl("1.23", out, fixed = TRUE)))
  expect_true(any(grepl("NA", out, fixed = TRUE)))
  expect_identical(capture.output(mfrmr:::print_summary_sections(list(Table = NULL), sections)), character())
  expect_error(mfrmr:::print_summary_sections(list(Table = 1L), sections),
    "missing value where TRUE/FALSE needed", fixed = TRUE)
  sections[, "guard"] <- "required"
  expect_error(mfrmr:::print_summary_sections(list(Table = 1L), sections),
    "argument is of length zero", fixed = TRUE)
  sections[, "guard"] <- "present"
  withr::local_options(warnPartialMatchDollar = TRUE)
  warnings <- character()
  invisible(withCallingHandlers(capture.output(
    mfrmr:::print_summary_sections(list(Table_extra = data.frame(Value = 1)), sections)),
    warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }))
  expect_length(warnings, 3L)
  expect_true(all(grepl("partial match", warnings, fixed = TRUE)))
})

test_that("empty plot component indices preserve their schema and saved payloads", {
  expected <- data.frame(PlotName = character(), Component = character(),
    Role = character(), ObjectType = character(), Rows = integer(),
    Columns = integer(), Length = integer(), IsTabular = logical(),
    Accessor = character(), Notes = character(), ColumnNames = character())
  payloads <- list(list(), NULL, list(1L),
    setNames(list(1L, 2L), c("", NA_character_)))
  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)
  for (payload in payloads) {
    x <- structure(list(name = "empty", data = payload), class = "mfrm_plot_data")
    before <- serialize(x, NULL)
    saved_plot <- structure(list(), mfrmr_plot_data = x)
    saveRDS(x, path)
    for (obj in list(x, saved_plot, readRDS(path))) {
      expect_identical(plot_data_components(obj), expected)
      expect_identical(plot_data(obj), if (is.null(payload)) list() else payload)
    }
    expect_identical(serialize(x, NULL), before)
  }
  x <- structure(list(name = "tables", data = list(
    table = data.frame(ID = character(), Value = double()), vector = 1:2)),
    class = "mfrm_plot_data")
  index <- plot_data_components(x)
  expect_identical(names(index), names(expected))
  expect_identical(vapply(index, typeof, ""), vapply(expected, typeof, ""))
  expect_identical(index$PlotName, rep("tables", 2L))
  expect_identical(index$Component, c("table", "vector"))
  expect_identical(index$Rows, c(0L, NA_integer_))
  expect_identical(index$IsTabular, c(TRUE, FALSE))
  expect_identical(plot_data(x, "table"), x$data$table)
})
