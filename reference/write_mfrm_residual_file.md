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
  Supplying it avoids recomputing observation diagnostics.

- path:

  Output file path.

- format:

  File format: `"csv"` or `"tsv"`. If omitted, inferred from `path` when
  the extension is `.csv` or `.tsv`, otherwise `"csv"`.

- digits:

  Rounding digits for numeric columns.

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
person measure when those quantities are available.

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
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
path <- tempfile(fileext = ".csv")
out <- write_mfrm_residual_file(fit, diag, path, overwrite = TRUE)
out$written_files
} # }
```
