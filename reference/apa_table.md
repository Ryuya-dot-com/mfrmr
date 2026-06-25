# Build APA-style table output using base R structures

Build APA-style table output using base R structures

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
  an `mfrm_summary_table_bundle`, diagnostics list, or bias-result list.

- which:

  Optional table selector when `x` has multiple tables.

- diagnostics:

  Optional diagnostics from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used when `x` is `mfrm_fit` and `which` targets diagnostics tables).

- digits:

  Number of rounding digits for numeric columns.

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
`data.frame` plus metadata.

Supported `which` values:

- For `mfrm_fit`: `"summary"`, `"person"`, `"facets"`, `"steps"`

- For [`summary()`](https://rdrr.io/r/base/summary.html) outputs or
  `mfrm_summary_table_bundle`: names listed in
  `build_summary_table_bundle(x)$table_index`

- For diagnostics list: `"overall_fit"`, `"measures"`, `"fit"`,
  `"reliability"`, `"facets_chisq"`, `"bias"`, `"interactions"`,
  `"interrater_summary"`, `"interrater_pairs"`, `"obs"`

- For bias-result list: `"table"`, `"summary"`, `"chi_sq"`

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
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
tbl <- apa_table(fit, which = "summary", caption = "Model summary", note = "Toy example")
tbl_facets <- apa_table(fit, which = "summary", branch = "facets")
fit_bundle <- build_summary_table_bundle(summary(fit))
tbl_from_summary <- apa_table(fit_bundle, which = "facet_overview")
summary(tbl)
#> APA Table Summary
#>  Branch Style   Which Rows Columns NumericColumns MissingValues
#>     apa   apa summary    1      42             24             7
#> 
#> Caption
#>  - Model summary
#> 
#> Note
#>  - Toy example
#> 
#> Numeric profile
#>            Column N    Mean SD     Min     Max
#>               AIC 1 1753.90 NA 1753.90 1753.90
#>               BIC 1 2013.95 NA 2013.95 2013.95
#>        Categories 1    4.00 NA    4.00    4.00
#>   ConvergenceCode 1    0.00 NA    0.00    0.00
#>      EMIterations 0      NA NA      NA      NA
#>  EMRelativeChange 0      NA NA      NA      NA
#>      ExtremeHighN 1    0.00 NA    0.00    0.00
#>       ExtremeLowN 1    0.00 NA    0.00    0.00
p <- plot(tbl, draw = FALSE)
p_facets <- plot(tbl_facets, type = "numeric_profile", draw = FALSE)
p$data$plot
#> [1] "numeric_profile"
p_facets$data$plot
#> [1] "numeric_profile"
if (interactive()) {
  plot(
    tbl,
    type = "numeric_profile",
    main = "APA Table Numeric Profile (Customized)",
    palette = c(numeric_profile = "#2b8cbe", grid = "#d9d9d9"),
    label_angle = 45
  )
}
tbl$note
#> [1] "Toy example"
```
