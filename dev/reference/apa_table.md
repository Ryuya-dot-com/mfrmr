# Build an APA-oriented table handoff using base R structures

Build an APA-oriented table handoff using base R structures

## Usage

``` r
apa_table(
  x,
  which = NULL,
  diagnostics = NULL,
  digits = 2,
  caption = NULL,
  note = NULL,
  bias_results = NULL,
  context = list(),
  whexact = FALSE,
  branch = c("apa", "facets")
)

# S3 method for class 'apa_table'
summary(object, digits = 3, top_n = 8, ...)

# S3 method for class 'apa_table'
plot(
  x,
  y = NULL,
  type = c("numeric_profile", "first_numeric"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  For `apa_table()`: A data.frame, `mfrm_fit`,
  [`summary()`](https://rdrr.io/r/base/summary.html) output supported by
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_summary_table_bundle.md),
  an `mfrm_summary_table_bundle`, diagnostics list, bias-result list,
  saved RSM/PCM fixed-facet intervals, or saved GPCM
  slope/curve/bootstrap inference. Ordinary Person-score results also
  support `which = "decisions"` when cut scores were requested.

  For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Output
  from `apa_table()`.

- which:

  Optional table selector when `x` has multiple tables.

- diagnostics:

  Optional diagnostics from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  (used when `x` is `mfrm_fit` and `which` targets diagnostics tables).

- digits:

  For `apa_table()`: Uniform number of rounding digits for numeric
  columns, except saved decision probabilities, boundaries and priors,
  which are retained at full precision in `table`.

  For [`summary()`](https://rdrr.io/r/base/summary.html): Number of
  digits used for numeric summaries.

- caption:

  Optional caption text.

- note:

  Optional note text.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md)
  used when auto-generating APA metadata for fit-based tables.

- context:

  Optional context list forwarded when auto-generating APA metadata for
  fit-based tables.

- whexact:

  Logical forwarded to APA metadata helpers.

- branch:

  Output branch: `"apa"` for manuscript-oriented labels, `"facets"` for
  FACETS-aligned labels.

- object:

  Output from `apa_table()`.

- top_n:

  Maximum numeric columns shown in `numeric_profile`.

- ...:

  Reserved for generic compatibility.

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"numeric_profile"` (column means) or `"first_numeric"`
  (distribution of the first numeric column).

- main:

  Optional title override.

- palette:

  Optional named color overrides.

- label_angle:

  Axis-label rotation angle for bar-type plots.

- draw:

  If `TRUE`, draw using base graphics.

## Value

A list of class `apa_table` with fields:

- `table` (`data.frame`)

- `which`

- `caption`

- `note`

- `digits`

- `branch`, `style`

For [`summary()`](https://rdrr.io/r/base/summary.html): An object of
class `summary.apa_table`.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying its saved plot payload accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Details

This helper avoids styling dependencies and returns a reproducible base
`data.frame` plus manuscript-oriented metadata. It does not claim
complete APA 7 or JARS compliance: outside the saved `decisions` table,
`digits` applies the same rounding rule to every numeric column, so
statistic-specific formatting (for example, exact *p*-value,
confidence-interval, and effect-size conventions) and the target
journal's final typography still require human review.

Supported `which` values:

- For `mfrm_fit`: `"summary"`, `"person"`, `"facets"`, `"steps"`

- For [`summary()`](https://rdrr.io/r/base/summary.html) outputs or
  `mfrm_summary_table_bundle`: names listed in
  `build_summary_table_bundle(x)$table_index`

- For diagnostics list: `"overall_fit"`, `"measures"`, `"fit"`,
  `"reliability"`, `"facets_chisq"`, `"bias"`, `"interactions"`,
  `"interrater_summary"`, `"interrater_pairs"`, `"obs"`

- For bias-result list: `"table"`, `"summary"`, `"chi_sq"`

- For ordinary
  [`score_mfrm_persons()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/score_mfrm_persons.md)
  output: `"decisions"`.
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_units.md)
  and
  [`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_calibration_workflow.md)
  results and their summaries also accept this selector. Cuts must have
  been requested.

- For RSM/PCM fixed-facet intervals: `"intervals"` (default),
  `"settings"`, `"contrasts"`, and `"clusters"` when present. Method,
  confidence level and unavailable reasons remain with the selected
  estimates and bounds.

- For GPCM inference: `"intervals"` or `"curves"`; bootstrap results
  also retain `"trials"`, `"checks"` and `"source_checks"` when
  recorded, `"sampling"`, and `"availability"` for slope intervals or
  `"test"` for a null-model LRT. Extended results also expose
  `"settings"`, and `"clusters"`/`"contrasts"` when present. Saved
  profile intervals also expose `"profile"`, `"profile_endpoints"`,
  `"profile_checks"` and `"wald"`. Target and method columns are
  preserved.

[`summary()`](https://rdrr.io/r/base/summary.html) method: Summarize an
APA/FACETS table object

For [`summary()`](https://rdrr.io/r/base/summary.html): Compact summary
helper for QA of table data before manuscript export.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot an
APA/FACETS table object using base R

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Quick
visualization helper for numeric columns in `apa_table()` output. It is
intended for table QA and exploratory checks, not final publication
graphics.

## Interpreting output

Saved ordinary Person-score, unit-prediction and portable-score results
with cut probabilities support `which = "decisions"`. Numeric
probabilities, cut boundaries and priors are retained without decimal
rounding in the table. They condition on calibration and the scoring
prior; the cut labels do not establish CEFR alignment or a decision
rule.

- `table`: plain data.frame ready for export or further formatting.

- `which`: source component that produced the table.

- `caption`/`note`: manuscript-oriented metadata stored with the table.

For [`summary()`](https://rdrr.io/r/base/summary.html):

- `overview`: table size/composition and missingness.

- `numeric_profile`: quick distribution summary of numeric columns.

- `caption`/`note`: text metadata readiness.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

- `"numeric_profile"`: compares column means to spot scale/centering
  mismatches.

- `"first_numeric"`: checks distribution shape of the first numeric
  column.

## Typical workflow

1.  Build table object with `apa_table(...)`.

2.  Inspect quickly with `summary(tbl)`.

3.  Render base preview via `plot(tbl, ...)` or export `tbl$table`.

For [`summary()`](https://rdrr.io/r/base/summary.html):

1.  Build table with `apa_table()`.

2.  Run `summary(tbl)` and inspect `overview`.

3.  Use `plot.apa_table()` for quick numeric checks if needed.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html):

1.  Build table with `apa_table()`.

2.  Run `summary(tbl)` for metadata.

3.  Use `plot(tbl, type = "numeric_profile")` for quick numeric QC.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_apa_outputs.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/reporting_checklist.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_reporting_and_apa.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/predict_mfrm_units.md)

`apa_table()`, [`plot()`](https://rdrr.io/r/graphics/plot.default.html)

`apa_table()`, [`base::summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Turn one summary table into a table with a caption and note
results <- summary(fit)
tbl <- apa_table(results, which = "facet_overview",
                 caption = "Distribution of estimates within each facet")
tbl # Prints the table, caption, and note
#> Distribution of estimates within each facet
#>      Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate Span
#>  Criterion      3            0        0.3       -0.34        0.22 0.57
#>      Rater      6            0        0.4       -0.61        0.41 1.02
#> Note. No population model was requested; MML used an unconditional normal person distribution.

# Extract the ordinary data frame for further formatting or export
tbl$table
#>       Facet Levels MeanEstimate SDEstimate MinEstimate MaxEstimate Span
#> 1 Criterion      3            0        0.3       -0.34        0.22 0.57
#> 2     Rater      6            0        0.4       -0.61        0.41 1.02
# This table summarizes facets; use as.data.frame(fit) for individual estimates
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("summary.apa_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
tbl <- apa_table(fit, which = "summary")
summary(tbl)
} # }
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot.apa_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
tbl <- apa_table(fit, which = "summary")
p <- plot(tbl, draw = FALSE)
p2 <- plot(tbl, type = "first_numeric", draw = FALSE)
if (interactive()) {
  plot(
    tbl,
    type = "numeric_profile",
    main = "APA Numeric Profile (Customized)",
    palette = c(numeric_profile = "#2b8cbe", grid = "#d9d9d9"),
    label_angle = 45
  )
}
} # }
```
