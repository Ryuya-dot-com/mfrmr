# Export MFRM results to CSV files

Writes tidy CSV files suitable for import into spreadsheet software or
further analysis in other tools.

## Usage

``` r
export_mfrm(
  fit,
  diagnostics = NULL,
  output_dir = ".",
  prefix = "mfrm",
  tables = c("person", "facets", "summary", "steps", "measures"),
  overwrite = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When provided, enriches facet estimates with SE, fit statistics, and
  writes the full measures table.

- output_dir:

  Directory for CSV files. Created if it does not exist.

- prefix:

  Filename prefix (default `"mfrm"`).

- tables:

  Character vector of tables to export. Any subset of `"person"`,
  `"facets"`, `"summary"`, `"steps"`, `"measures"`. Default exports all
  available tables.

- overwrite:

  If `FALSE` (default), refuse to overwrite existing files.

## Value

Invisibly, a data.frame listing written files with columns `Table` and
`Path`.

## Exported files

- `{prefix}_person_estimates.csv`:

  Person ID, Estimate, SD.

- `{prefix}_facet_estimates.csv`:

  Facet, Level, Estimate, and optionally SE, Infit, Outfit, PTMEA when
  diagnostics supplied.

- `{prefix}_fit_summary.csv`:

  One-row model summary.

- `{prefix}_step_parameters.csv`:

  Step/threshold parameters.

- `{prefix}_measures.csv`:

  Full measures table (requires diagnostics).

## Interpreting output

The returned data.frame tells you exactly which files were written and
where. This is convenient for scripted pipelines where the output
directory is created on the fly.

## Typical workflow

1.  Fit a model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Optionally compute diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    when you want enriched facet or measures exports.

3.  Call `export_mfrm(...)` and inspect the returned `Path` column.

## See also

[`fit_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`as.data.frame.mfrm_fit`](https://ryuya-dot-com.github.io/mfrmr/reference/as.data.frame.mfrm_fit.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", model = "RSM", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
out <- export_mfrm(
  fit,
  diagnostics = diag,
  output_dir = tempdir(),
  prefix = "mfrmr_example",
  overwrite = TRUE
)
out$Table
}
```
