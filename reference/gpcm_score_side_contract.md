# Bounded GPCM Score-Side Availability

Show which bounded-`GPCM` score-side quantities are available, the
limits on their interpretation, and the alternative route when a
quantity is not available.

## Usage

``` r
gpcm_score_side_contract(status = "all")
```

## Arguments

- status:

  Which rows to return: `"all"` (default), `"available_with_caveat"`,
  `"supporting_route"`, or `"unavailable"`.

## Value

A data.frame with columns:

- `Capability`

- `Status`

- `Limitation`

- `Alternative`

## Details

Package-native expected-score and uncertainty fields are not FACETS
score-side equivalents. A row marked `available_with_caveat` can be used
within its stated `Limitation`; `supporting_route` identifies a related
output that can inform interpretation; and `unavailable` identifies a
route that should be replaced by the listed `Alternative`.

## See also

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`gpcm_runtime_guard_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_runtime_guard_coverage.md),
[`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md),
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)

## Examples

``` r
gpcm_score_side_contract()
#>                            Capability                Status
#> 1       Package-native score estimand available_with_caveat
#> 2   Slope-aware expected-score fields available_with_caveat
#> 3            Native score uncertainty available_with_caveat
#> 4 FACETS-compatible score uncertainty           unavailable
#> 5 Structural fair-average uncertainty      supporting_route
#> 6  Equal-discrimination PCM reference      supporting_route
#> 7     Package-native scorefile export available_with_caveat
#> 8       Full FACETS score-side review           unavailable
#> 9            Reporting interpretation available_with_caveat
#>                                                                                                                                    Limitation
#> 1 Expected-score and residual quantities are package-native bounded-GPCM outputs, not Rasch measure-to-score or FACETS-equivalent quantities.
#> 2                            Expected-score fields use the fitted slope structure and therefore depend on the declared step and slope facets.
#> 3                    Uncertainty fields require the relevant MML diagnostics; otherwise the scorefile reports an explicit unavailable status.
#> 4                                          No FACETS-compatible free-discrimination score-side uncertainty definition is currently available.
#> 5                                  Structural fair-average SEs are a separate table route and do not establish FACETS score-side equivalence.
#> 6        Unit-slope agreement with PCM is an interpretation reference, not evidence that every free-slope score quantity is Rasch-equivalent.
#> 7                                                    The exported scorefile is package-native and must retain its bounded-GPCM caveat fields.
#> 8                                                The full FACETS-style score-side review is unavailable for free-discrimination bounded GPCM.
#> 9                                      Bounded-GPCM score-side output is sensitivity evidence, not an automatic operational scoring decision.
#>                                                                                                                  Alternative
#> 1                      Use `facets_output_file_bundle(include = "score")` and report the package-native estimand explicitly.
#> 2                     Inspect the fitted step and slope summaries before interpreting exported expected scores or residuals.
#> 3    Use an MML fit when uncertainty is required, or report the explicit unavailable status without substituting another SE.
#> 4 Use the package-native scorefile with caveats; use an `RSM` or `PCM` fit when a full FACETS score-side review is required.
#> 5                 Use `fair_average_table(fair_se = TRUE)` directly and label the result as slope-aware element-conditional.
#> 6                               Fit a `PCM` reference when equal-discrimination score semantics are required for comparison.
#> 7                               Use `facets_output_file_bundle(include = "score")` and retain all status and caveat columns.
#> 8                                              Keep full `facets_output_contract_review()` work on the `RSM` or `PCM` route.
#> 9                            Report bounded GPCM as a slope-aware sensitivity analysis and keep operational claims separate.
gpcm_score_side_contract("unavailable")
#>                            Capability      Status
#> 1 FACETS-compatible score uncertainty unavailable
#> 2       Full FACETS score-side review unavailable
#>                                                                                           Limitation
#> 1 No FACETS-compatible free-discrimination score-side uncertainty definition is currently available.
#> 2       The full FACETS-style score-side review is unavailable for free-discrimination bounded GPCM.
#>                                                                                                                  Alternative
#> 1 Use the package-native scorefile with caveats; use an `RSM` or `PCM` fit when a full FACETS score-side review is required.
#> 2                                              Keep full `facets_output_contract_review()` work on the `RSM` or `PCM` route.
```
