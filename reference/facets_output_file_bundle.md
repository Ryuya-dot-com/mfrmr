# Build a legacy-compatible output-file bundle (`GRAPH=` / `SCORE=`)

Build a legacy-compatible output-file bundle (`GRAPH=` / `SCORE=`)

## Usage

``` r
facets_output_file_bundle(
  fit,
  diagnostics = NULL,
  include = c("graph", "score"),
  theta_range = c(-6, 6),
  theta_points = 241,
  digits = 4,
  score_se_method = c("both", "native", "score_side", "none"),
  include_fixed = FALSE,
  fixed_max_rows = 400,
  write_files = FALSE,
  output_dir = NULL,
  file_prefix = "mfrmr_output",
  overwrite = FALSE
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (used for score file).

- include:

  Output components to include: `"graph"` and/or `"score"`.

- theta_range:

  Theta/logit range for graph coordinates.

- theta_points:

  Number of points on the theta grid for graph coordinates.

- digits:

  Rounding digits for numeric fields.

- score_se_method:

  For bounded `GPCM` scorefile exports, which observation-level score
  uncertainty columns to compute. `"both"` (default) includes native
  structural expected-score SEs and score-side delta-method SEs;
  `"native"` includes only the structural expected-score route;
  `"score_side"` includes only the score-side delta route; `"none"`
  records explicit `not_requested` status columns.

- include_fixed:

  If `TRUE`, include fixed-width text mirrors of output tables.

- fixed_max_rows:

  Maximum rows shown in fixed-width text blocks.

- write_files:

  If `TRUE`, write selected outputs to files in `output_dir`.

- output_dir:

  Output directory used when `write_files = TRUE`.

- file_prefix:

  Prefix used for output file names.

- overwrite:

  If `FALSE`, existing output files are not overwritten.

## Value

A named list including:

- `graphfile` / `graphfile_syntactic` when `"graph"` is requested

- `scorefile` when `"score"` is requested

- `graphfile_fixed` / `scorefile_fixed` when `include_fixed = TRUE`

- `written_files` when `write_files = TRUE`

- `settings`: applied options

## Details

Legacy-compatible output files often include:

- graph coordinates for Table 8 curves (`GRAPH=` / `Graphfile=`), and

- observation-level modeled score lines (`SCORE=`-style inspection).

This helper returns both as data frames and can optionally write
CSV/fixed-width text files to disk.

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_output_bundle` (`type = "graph_expected"`, `"score_residuals"`,
`"obs_probability"`, `"score_se"`).

## Interpreting output

- `graphfile`: legacy-compatible wide curve coordinates (human-readable
  labels).

- `graphfile_syntactic`: same curves with syntactic column names for
  programmatic use.

- `scorefile`: observation-level observed/expected/residual diagnostics.

- `written_files`: traceability record of files produced when
  `write_files = TRUE`.

For reproducible pipelines, prefer `graphfile_syntactic` and keep
`written_files` in run logs.

## Preferred route for new analyses

For new scripts, prefer
[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md)
or
[`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md)
for scale outputs, then use
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
for file handoff. Use `facets_output_file_bundle()` only when a
legacy-compatible graphfile or scorefile contract is required.

## Bounded GPCM boundary

For bounded `GPCM`, graph output and package-native scorefile output are
available with caveats. `include = "score"` returns observation-level
fitted expected score, residual, standardized residual,
observed-category probability, GPCM slope fields, and native structural
delta-method expected-score uncertainty and/or score-side delta-method
SEs when the required MML diagnostics are available. Use
`score_se_method` to choose `"both"` (default), `"native"`,
`"score_side"`, or `"none"`. The scorefile also carries explicit
score-side caveat columns. It is not a FACETS score-side equivalence
file, does not export FACETS-equivalent score-side standard errors, and
does not establish an operational score-scale decision. Use
[`gpcm_score_side_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_score_side_contract.md)
and
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
for the current scope.

## Typical workflow

1.  Fit and diagnose model.

2.  Generate bundle with `include = c("graph", "score")`.

3.  Validate with `summary(out)` / `plot(out)`.

4.  Export with `write_files = TRUE` for reporting handoff.

## See also

[`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
out <- facets_output_file_bundle(fit, diagnostics = diagnose_mfrm(fit, residual_pca = "none"))
summary(out)
p_out <- plot(out, draw = FALSE)
p_out$data$plot
}
```
