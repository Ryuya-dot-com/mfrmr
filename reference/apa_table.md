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
```

## Arguments

- x:

  A data.frame, `mfrm_fit`,
  [`summary()`](https://rdrr.io/r/base/summary.html) output supported by
  [`build_summary_table_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_summary_table_bundle.md),
  an `mfrm_summary_table_bundle`, diagnostics list, bias-result list,
  saved RSM/PCM fixed-facet intervals, or saved GPCM
  slope/curve/bootstrap inference.

- which:

  Optional table selector when `x` has multiple tables.

- diagnostics:

  Optional diagnostics from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used when `x` is `mfrm_fit` and `which` targets diagnostics tables).

- digits:

  Uniform number of rounding digits for numeric columns.

- caption:

  Optional caption text.

- note:

  Optional note text.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  used when auto-generating APA metadata for fit-based tables.

- context:

  Optional context list forwarded when auto-generating APA metadata for
  fit-based tables.

- whexact:

  Logical forwarded to APA metadata helpers.

- branch:

  Output branch: `"apa"` for manuscript-oriented labels, `"facets"` for
  FACETS-aligned labels.

## Value

A list of class `apa_table` with fields:

- `table` (`data.frame`)

- `which`

- `caption`

- `note`

- `digits`

- `branch`, `style`

## Details

This helper avoids styling dependencies and returns a reproducible base
`data.frame` plus manuscript-oriented metadata. It does not claim
complete APA 7 or JARS compliance: `digits` applies the same rounding
rule to every numeric column, so statistic-specific formatting (for
example, exact *p*-value, confidence-interval, and effect-size
conventions) and the target journal's final typography still require
human review.

Supported `which` values:

- For `mfrm_fit`: `"summary"`, `"person"`, `"facets"`, `"steps"`

- For [`summary()`](https://rdrr.io/r/base/summary.html) outputs or
  `mfrm_summary_table_bundle`: names listed in
  `build_summary_table_bundle(x)$table_index`

- For diagnostics list: `"overall_fit"`, `"measures"`, `"fit"`,
  `"reliability"`, `"facets_chisq"`, `"bias"`, `"interactions"`,
  `"interrater_summary"`, `"interrater_pairs"`, `"obs"`

- For bias-result list: `"table"`, `"summary"`, `"chi_sq"`

- For RSM/PCM fixed-facet intervals: `"intervals"` (default),
  `"settings"`, `"contrasts"`, and `"clusters"` when present. Method,
  confidence level and unavailable reasons remain with the selected
  estimates and bounds.

- For GPCM inference: `"intervals"` or `"curves"`; bootstrap results
  also retain `"trials"`, `"checks"` and `"source_checks"` when
  recorded, `"sampling"`, and `"availability"` for slope intervals or
  `"test"` for a null-model LRT. Extended results also expose
  `"settings"`, and `"clusters"`/`"contrasts"` when present. Target and
  method columns are preserved.

## Interpreting output

- `table`: plain data.frame ready for export or further formatting.

- `which`: source component that produced the table.

- `caption`/`note`: manuscript-oriented metadata stored with the table.

## Typical workflow

1.  Build table object with `apa_table(...)`.

2.  Inspect quickly with `summary(tbl)`.

3.  Render base preview via `plot(tbl, ...)` or export `tbl$table`.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

## Examples

``` r
# \donttest{
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

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
# }
```
