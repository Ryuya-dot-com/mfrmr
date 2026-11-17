# Write a standalone residual file

Write a standalone residual file

Write standalone subset-connectivity files

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
  Supplying it avoids recomputing subset connectivity. Must match this
  fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
  for migration of saved diagnostics.

- path:

  Output file path for the subset summary table.

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

- node_path:

  Optional output file path for the node-level subset table. When `NULL`
  and `include_nodes = TRUE`, a sibling file ending in `_nodes.csv` or
  `_nodes.tsv` is created.

- include_nodes:

  If `TRUE`, also write the node-level facet/level to subset membership
  table.

## Value

A bundle with `table`, `summary`, `written_files`, and `settings`.

A bundle with `table`, `nodes`, `summary`, `written_files`, and
`settings`.

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
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)
because it is a direct analysis handoff rather than a legacy graph/score
bundle.

Subsets are connected components in the observation design graph. The
graph links `Person` and all modeled facet levels that co-occur in an
observation. A single co-observation graph component does not prove
common-scale identification; shared other facets can conceal confounded
panels. Consult the fitted estimability audit. Disconnected graphs need
an explicit linking justification, such as defensible anchors or
population assumptions, or separate calibrations. The graph alone does
not assess those assumptions.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
`write_mfrm_subset_file()`

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`subset_connectivity_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/subset_connectivity_report.md),
`write_mfrm_residual_file()`

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
#>       Component                 File
#> 1 residual_file file1a67768a68e1.csv
# Full paths remain in out$written_files$Path.
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
path <- tempfile(fileext = ".csv")
out <- write_mfrm_subset_file(fit, diag, path, overwrite = TRUE)
data.frame(
  Component = out$written_files$Component,
  File = basename(out$written_files$Path)
)
#>        Component                       File
#> 1 subset_summary       file1a674e9b0118.csv
#> 2   subset_nodes file1a674e9b0118_nodes.csv
# Full paths remain in out$written_files$Path.
```
