# Build a package-native reference review for report completeness

Build a package-native reference review for report completeness

## Usage

``` r
reference_case_review(
  fit,
  diagnostics = NULL,
  bias_results = NULL,
  reference_profile = c("core", "compatibility"),
  include_metrics = TRUE,
  top_n_attention = 15L
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
  If omitted and at least two facets exist, a 2-way interaction screen
  is computed internally.

- reference_profile:

  Review profile. `"core"` emphasizes package-native report contracts.
  `"compatibility"` exposes the manual-aligned compatibility layer used
  by `facets_output_contract_review(branch = "facets")`.

- include_metrics:

  If `TRUE`, run numerical consistency checks in addition to schema
  coverage checks.

- top_n_attention:

  Number of lowest-coverage components to keep in `attention_items`.

## Value

An object of class `mfrm_reference_review`.

## Details

This function repackages the output-contract review into package-native
terminology so users can review output completeness without needing
external manual/table numbering. It reports:

- component-level schema coverage

- numerical consistency checks for derived report tables

- the highest-priority attention items for follow-up

It is a package-output completeness review, not an external validation
study.

Use `reference_profile = "core"` for ordinary `mfrmr` workflows. Use
`reference_profile = "compatibility"` only when you explicitly want to
inspect the compatibility layer.

## Interpreting output

- `overall`: one-row review summary with schema coverage and metric pass
  rate.

- `component_summary`: per-component coverage summary.

- `attention_items`: direct list of components needing review.

- `metric_summary` / `metric_checks`: numerical consistency status.

## See also

[`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
review <- reference_case_review(fit, diagnostics = diag)
summary(review)
} # }
```
