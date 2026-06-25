# Build a FACETS output-contract review

Build a FACETS output-contract review

## Usage

``` r
facets_output_contract_review(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  branch = c("facets", "original"),
  contract_file = NULL,
  include_metrics = TRUE,
  top_n_missing = 15L
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  If omitted, diagnostics are computed internally with
  `residual_pca = "none"`.

- bias_results:

  Optional output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).
  If omitted and at least two facets exist, a 2-way bias run is computed
  internally.

- branch:

  Contract branch. `"facets"` checks legacy-compatible columns.
  `"original"` adapts branch-sensitive contracts to the package's
  compact naming.

- contract_file:

  Optional path to a custom contract CSV.

- include_metrics:

  If `TRUE`, run additional numerical consistency checks.

- top_n_missing:

  Number of lowest-coverage contract rows to keep in `missing_preview`.

## Value

An object of class `mfrm_facets_contract_review` with:

- `overall`: one-row output-contract review summary

- `column_summary`: coverage summary by table ID

- `column_review`: row-level output-contract review

- `missing_preview`: lowest-coverage rows

- `metric_summary`: one-row metric-check summary

- `metric_by_table`: metric-check summary by table ID

- `metric_checks`: row-level metric checks

- `settings`: branch/contract metadata

## Details

This function checks produced report components against a FACETS-style
output-contract specification
(`inst/references/facets_column_contract.csv`) and returns:

- column-level coverage per contract row

- table-level coverage summaries

- optional metric-level consistency checks

It is intended for output-contract QA and regression review. It does not
establish external validity or software equivalence beyond the specific
schema/metric contract encoded in the contract file.

## Bounded GPCM boundary

This helper remains blocked for bounded `GPCM` fits in this release. The
FACETS output contract includes score-side rows whose measure-to-score
and uncertainty semantics are validated for the current Rasch-family
route, not for free-discrimination bounded `GPCM`. Use
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
before routing a bounded `GPCM` fit into score-side compatibility-output
helpers.

Coverage interpretation in `overall`:

- `MeanColumnCoverage` and `MinColumnCoverage` are computed across all
  contract rows (unavailable rows count as 0 coverage).

- `MeanColumnCoverageAvailable` and `MinColumnCoverageAvailable`
  summarize only rows whose source component is available.

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_facets_contract_review` (`type = "column_coverage"`,
`"table_coverage"`, `"metric_status"`, `"metric_by_table"`).

## Interpreting output

- `overall`: high-level output-contract coverage and metric-check pass
  rates.

- `column_summary` / `column_review`: where output-schema mismatches
  occur.

- `metric_summary` / `metric_checks`: numerical consistency checks tied
  to the current contract.

- `missing_preview`: direct path to unresolved output-contract gaps.

## Typical workflow

1.  Run `facets_output_contract_review(fit, branch = "facets")`.

2.  Inspect `summary(contract_review)` and `missing_preview`.

3.  Patch upstream table builders, then rerun the output-contract
    review.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
contract_review <- facets_output_contract_review(fit, diagnostics = diag, branch = "facets")
summary(contract_review)
p <- plot(contract_review, draw = FALSE)
} # }
```
