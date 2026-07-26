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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
review <- reference_case_review(fit, diagnostics = diag)
summary(review)
#> mfrmr Reference Review Summary 
#>   Class: mfrm_reference_review
#>   Components: 7
#> 
#> Attention items: metric_checks
#>  Table                         Check Pass            Actual         Expected
#>     T4 UnexpectedPercent consistency TRUE  6.51041666666667 6.51041666666667
#>    T10         ReducedBy consistency TRUE               148              148
#>    T10    ReducedPercent consistency TRUE  74.7474747474748 74.7474747474748
#>    T11   LowCountPercent consistency TRUE                 0                0
#>     T7          ExactAgreement range TRUE 0.361979166666667            [0,1]
#>     T7  ExpectedExactAgreement range TRUE 0.374634703073567            [0,1]
#>     T7       AdjacentAgreement range TRUE 0.829861111111111            [0,1]
#>     T7               FixedProb range TRUE               all            [0,1]
#>     T7              RandomProb range TRUE               all            [0,1]
#>     T9      AnchoredLevels <= Levels TRUE                 0               56
#>  Note
#>      
#>      
#>      
#>      
#>      
#>      
#>      
#>      
#>      
#>      
#> 
#> Settings
#>              Setting                     Value
#>    reference_profile                      core
#>      contract_branch                  original
#>         intended_use reference_contract_review
#>  external_validation                     FALSE
#>      include_metrics                      TRUE
#>      top_n_attention                        15
#> 
#> Notes
#>  - No `summary` component found; showing preview rows from the main table.
# }
```
