# Write a standalone residual file

Write a standalone residual file

## Usage

``` r
write_mfrm_residual_file(
  fit,
  diagnostics = NULL,
  path,
  format = c("csv", "tsv"),
  digits = 4,
  overwrite = FALSE,
  include_probabilities = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Supplying it avoids recomputing observation diagnostics. Must match
  this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

- path:

  Output file path.

- format:

  File format: `"csv"` or `"tsv"`. If omitted, inferred from `path` when
  the extension is `.csv` or `.tsv`, otherwise `"csv"`.

- digits:

  Rounding digits for numeric columns. `ConditionalVariance` retains
  full precision so small positive variances are not exported as zero.

- overwrite:

  If `FALSE`, existing files are not overwritten.

- include_probabilities:

  If `TRUE`, append model probabilities for all response categories as
  `PrCategory_*` columns.

## Value

A bundle with `table`, `summary`, `written_files`, and `settings`.

## Details

The exported table is observation-level and model-native. It includes
the observed score, expected score, residual, standardized residual,
variance, score information, observed-category probability, and modeled
person measure when those quantities are available. Current diagnostics
also retain the primary Person estimate and diagnostic basis, the
unthresholded `ConditionalVariance`, `PearsonAvailable`,
`ResponseStatus` and `ResponseReason`; see
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
for their interpretation and the legacy small-variance cutoff.

This writer is separate from
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
because it is a direct analysis handoff rather than a legacy graph/score
bundle.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md),
[`write_mfrm_subset_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_subset_file.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
path <- tempfile(fileext = ".csv")
out <- write_mfrm_residual_file(fit, diag, path, overwrite = TRUE)
data.frame(
  Component = out$written_files$Component,
  File = basename(out$written_files$Path)
)
#>       Component                File
#> 1 residual_file file1d848a18231.csv
# Full paths remain in out$written_files$Path.
```
