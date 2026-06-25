# Write standalone subset-connectivity files

Write standalone subset-connectivity files

## Usage

``` r
write_mfrm_subset_file(
  fit,
  diagnostics = NULL,
  path,
  node_path = NULL,
  format = c("csv", "tsv"),
  digits = 4,
  overwrite = FALSE,
  include_nodes = TRUE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Supplying it avoids recomputing subset connectivity.

- path:

  Output file path for the subset summary table.

- node_path:

  Optional output file path for the node-level subset table. When `NULL`
  and `include_nodes = TRUE`, a sibling file ending in `_nodes.csv` or
  `_nodes.tsv` is created.

- format:

  File format: `"csv"` or `"tsv"`. If omitted, inferred from `path` when
  the extension is `.csv` or `.tsv`, otherwise `"csv"`.

- digits:

  Rounding digits for numeric columns.

- overwrite:

  If `FALSE`, existing files are not overwritten.

- include_nodes:

  If `TRUE`, also write the node-level facet/level to subset membership
  table.

## Value

A bundle with `table`, `nodes`, `summary`, `written_files`, and
`settings`.

## Details

Subsets are connected components in the observation design graph. The
graph links `Person` and all modeled facet levels that co-occur in an
observation. Multiple subsets mean the scale is not fully connected
unless external anchoring or a deliberate separate-calibration design
justifies it.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
[`write_mfrm_residual_file()`](https://ryuya-dot-com.github.io/mfrmr/reference/write_mfrm_residual_file.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
path <- tempfile(fileext = ".csv")
out <- write_mfrm_subset_file(fit, diag, path, overwrite = TRUE)
out$written_files
} # }
```
