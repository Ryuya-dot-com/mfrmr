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
  overwrite = FALSE,
  acknowledge_sensitive = FALSE
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

- acknowledge_sensitive:

  Logical; set to `TRUE` only after acknowledging that these tables can
  contain direct person identifiers, person-level estimates, and
  original facet labels. This suppresses the privacy warning; it does
  not deidentify any file.

## Value

Invisibly, a data.frame listing written files, their paths, and explicit
privacy/data-handling metadata. `Deidentified` and
`ShareableWithoutReview` are always `FALSE`.

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
directory is created on the fly. The files are analysis tables, not a
deidentified sharing package; review each file under the applicable
data-handling policy before sharing it.

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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", model = "RSM", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
out <- export_mfrm(
  fit,
  diagnostics = diag,
  output_dir = tempdir(),
  prefix = "mfrmr_example",
  overwrite = TRUE,
  acknowledge_sensitive = TRUE
)
out$Table
#> [1] "person"   "facets"   "summary"  "steps"    "measures"
# }
```
