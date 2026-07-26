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
`"score_side"`, or `"none"`. The score-side route transforms a
logit-side standard error with the bounded GPCM expected-score
derivative \\dE\[X\]/d\eta = \alpha Var(X)\\, where `ScoreSlope` is
\\\alpha\\. `ScoreSideLogitSE` remains on the logit side; `ScoreSideSE`
and its interval columns are on the expected-score scale. The scorefile
also carries explicit score-side caveat columns. It is not a FACETS
score-side equivalence file, does not export FACETS-equivalent
score-side standard errors, and does not establish an operational
score-scale decision. Use
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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
out <- facets_output_file_bundle(fit, diagnostics = diagnose_mfrm(fit, residual_pca = "none"))
summary(out)
#> mfrmr Output File Bundle Summary 
#>   Class: mfrm_output_bundle
#>   Components: 4
#> 
#> Output overview
#>  GraphRows ScoreRows WrittenFiles IncludeFixed WriteFiles ScoreSEMethod
#>        241       768            0        FALSE      FALSE          both
#> 
#> Output preview rows: scorefile
#>  Rater Criterion Observed Expected Residual StdResidual   Var Weight score_k
#>    R01   Content        3    3.282   -0.282      -0.403 0.490      1       2
#>    R01   Content        3    3.662   -0.662      -1.247 0.282      1       2
#>    R01   Content        4    3.528    0.472       0.779 0.367      1       3
#>    R01   Content        3    3.384   -0.384      -0.576 0.444      1       2
#>    R01   Content        2    3.384   -1.384      -2.077 0.444      1       1
#>    R01   Content        3    1.930    1.070       1.398 0.586      1       2
#>    R01   Content        3    3.384   -0.384      -0.576 0.444      1       2
#>    R01   Content        3    1.848    1.152       1.540 0.560      1       2
#>    R01   Content        3    2.309    0.691       0.853 0.656      1       2
#>    R01   Content        2    3.282   -1.282      -1.832 0.490      1       1
#>  PersonMeasure ScoreSlope ScoreInformation ObservedScoreDerivative PrObserved
#>          0.684          1            0.490                  -0.282      0.456
#>          1.672          1            0.282                  -0.662      0.281
#>          1.257          1            0.367                   0.472      0.585
#>          0.901          1            0.444                  -0.384      0.424
#>          0.901          1            0.444                  -1.384      0.088
#>         -1.522          1            0.586                   1.070      0.200
#>          0.901          1            0.444                  -0.384      0.424
#>         -1.665          1            0.560                   1.152      0.171
#>         -0.918          1            0.656                   0.691      0.342
#>          0.684          1            0.490                  -1.282      0.118
#>  ObsProb
#>    0.456
#>    0.281
#>    0.585
#>    0.424
#>    0.088
#>    0.200
#>    0.424
#>    0.171
#>    0.342
#>    0.118
#> 
#> Settings
#>            Setting        Value
#>            include graph, score
#>        theta_range        -6, 6
#>       theta_points          241
#>             digits            4
#>      include_fixed        FALSE
#>     fixed_max_rows          400
#>        write_files        FALSE
#>         output_dir         NULL
#>        file_prefix mfrmr_output
#>          overwrite        FALSE
#>    score_se_method         both
#>  score_side_status     standard
#> 
#> Notes
#>  - Graphfile/SCORE-style export bundle (table output and optional file-write
#>    metadata).
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
p_out <- plot(out, draw = FALSE)
p_out$data$plot
#> [1] "graph_expected"
# }
```
