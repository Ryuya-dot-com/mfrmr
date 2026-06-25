# Bounded GPCM Score-Side Export Contract

Minimal contract table for the caveated bounded-`GPCM` scorefile route
and the still-blocked full FACETS-style score-side review route.

## Usage

``` r
gpcm_score_side_contract(
  status = c("all", "implemented_with_caveat", "required_for_full_facets_review",
    "validated_dependency")
)
```

## Arguments

- status:

  Which rows to return: `"all"` (default), `"implemented_with_caveat"`,
  `"required_for_full_facets_review"`, or `"validated_dependency"`.

## Value

A data.frame with columns:

- `ContractArea`

- `Requirement`

- `CurrentStatus`

- `ReleaseBoundary`

- `ValidationTarget`

- `ExitCriterion`

## Details

This helper does not enable full FACETS-style score-side review. It
records the requirements that separate the current caveated
`facets_output_file_bundle(include = "score")` route from a future
[`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
route for bounded `GPCM`.

Use it as a release-maintenance checklist. Rows marked
`implemented_with_caveat` support the current package-native
bounded-`GPCM` scorefile route. Rows marked
`required_for_full_facets_review` are still blockers for full
FACETS-style output-contract review. Rows marked `validated_dependency`
are already available in the package but are not sufficient by
themselves to justify full FACETS score-side equivalence.

## See also

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`gpcm_runtime_guard_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_runtime_guard_coverage.md),
[`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md),
[`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)

## Examples

``` r
gpcm_score_side_contract()
#>                        ContractArea
#> 1                    score_estimand
#> 2           measure_to_score_metric
#> 3                 score_uncertainty
#> 4 facets_score_uncertainty_contract
#> 5        structural_fair_average_se
#> 6                     pcm_reduction
#> 7                     export_schema
#> 8                     runtime_guard
#> 9                   release_wording
#>                                                                                                                                                           Requirement
#> 1                                                                Define the bounded-GPCM score-side estimand separately from Rasch-family measure-to-score semantics.
#> 2                                              Specify how free-discrimination slopes enter expected-score summaries, residual score-side fields, and caveat columns.
#> 3 Define native observation-level expected-score uncertainty and selectable score-side delta SEs under free discrimination before exporting bounded-GPCM score files.
#> 4                                                           Define the FACETS-compatible score-side uncertainty contract before enabling full output-contract review.
#> 5                                                                Use structural fair-average SEs where available and document when Hessian-based SEs are unavailable.
#> 6                                                  Preserve unit-slope bounded-GPCM reduction tests against the PCM route before any score-side export is advertised.
#> 7                                                                         Map each scorefile column to a bounded-GPCM source, caveat, or explicit unavailable status.
#> 8                                                       Keep full FACETS output-contract review blocked until all required_for_full_facets_review rows are satisfied.
#> 9                                                                      Keep sensitivity-model output separate from operational scoring and FACETS equivalence claims.
#>                     CurrentStatus
#> 1         implemented_with_caveat
#> 2         implemented_with_caveat
#> 3         implemented_with_caveat
#> 4 required_for_full_facets_review
#> 5            validated_dependency
#> 6            validated_dependency
#> 7         implemented_with_caveat
#> 8            validated_dependency
#> 9         implemented_with_caveat
#>                                                             ReleaseBoundary
#> 1                                           scorefile_supported_with_caveat
#> 2                                           scorefile_supported_with_caveat
#> 3                                           scorefile_supported_with_caveat
#> 4                                                full_facets_review_blocked
#> 5 available as fair_average_table(fair_se = TRUE), not as scorefile support
#> 6                 available as reduction evidence, not as scorefile support
#> 7                                           scorefile_supported_with_caveat
#> 8                                       active guard for full FACETS review
#> 9                                           scorefile_supported_with_caveat
#>                                                                                                                                                 ValidationTarget
#> 1                                                                   A named estimand and interpretation note for every exported bounded-GPCM scorefile quantity.
#> 2                                                                         A deterministic scorefile contract with slope handling and identification conventions.
#> 3 Native delta-method expected-score SEs and score-side delta SEs where MML diagnostics are available, with explicit not_requested/unavailable status otherwise.
#> 4                                                  A FACETS-compatible free-discrimination score metric plus uncertainty policy for contract-wide review fields.
#> 5                                                 Agreement checks that structural fair-average SE columns are present only when supported by the fitted object.
#> 6                                                      Numerical agreement checks showing bounded-GPCM unit-slope score-side quantities reduce to the PCM route.
#> 7                                                           A column contract that separates available, caveated, and unavailable bounded-GPCM scorefile fields.
#> 8                                                                       Structured mfrmr_gpcm_scope_error before full FACETS output-contract review work begins.
#> 9                                                                NEWS, README, help pages, and validation artifacts that prevent operational scoring overclaims.
#>                                                                                                                                            ExitCriterion
#> 1                                                        Scorefile help pages can name the bounded-GPCM estimand without borrowing Rasch-family wording.
#> 2                                           Tests cover slope variation, slope_facet identification, expected-score conversion, and boundary categories.
#> 3 Tests cover finite native expected-score and score-side delta SEs where available, plus explicit not_requested/unavailable status where not available.
#> 4                            facets_output_contract_review() can report bounded-GPCM score-side uncertainty without borrowing Rasch-family SE semantics.
#> 5                                                          The fair-average SE route remains traceable and does not imply FACETS score-side equivalence.
#> 6                                                                 Unit-slope bounded-GPCM fixtures match PCM score-side outputs within stated tolerance.
#> 7                                       facets_output_contract_review() can report bounded-GPCM score rows without silently emitting unsupported fields.
#> 8                                          gpcm_runtime_guard_coverage() and score-side helper errors remain synchronized with gpcm_capability_matrix().
#> 9                                                        Release wording states whether the route is supported, supported_with_caveat, or still blocked.
gpcm_score_side_contract("implemented_with_caveat")
#>              ContractArea
#> 1          score_estimand
#> 2 measure_to_score_metric
#> 3       score_uncertainty
#> 4           export_schema
#> 5         release_wording
#>                                                                                                                                                           Requirement
#> 1                                                                Define the bounded-GPCM score-side estimand separately from Rasch-family measure-to-score semantics.
#> 2                                              Specify how free-discrimination slopes enter expected-score summaries, residual score-side fields, and caveat columns.
#> 3 Define native observation-level expected-score uncertainty and selectable score-side delta SEs under free discrimination before exporting bounded-GPCM score files.
#> 4                                                                         Map each scorefile column to a bounded-GPCM source, caveat, or explicit unavailable status.
#> 5                                                                      Keep sensitivity-model output separate from operational scoring and FACETS equivalence claims.
#>             CurrentStatus                 ReleaseBoundary
#> 1 implemented_with_caveat scorefile_supported_with_caveat
#> 2 implemented_with_caveat scorefile_supported_with_caveat
#> 3 implemented_with_caveat scorefile_supported_with_caveat
#> 4 implemented_with_caveat scorefile_supported_with_caveat
#> 5 implemented_with_caveat scorefile_supported_with_caveat
#>                                                                                                                                                 ValidationTarget
#> 1                                                                   A named estimand and interpretation note for every exported bounded-GPCM scorefile quantity.
#> 2                                                                         A deterministic scorefile contract with slope handling and identification conventions.
#> 3 Native delta-method expected-score SEs and score-side delta SEs where MML diagnostics are available, with explicit not_requested/unavailable status otherwise.
#> 4                                                           A column contract that separates available, caveated, and unavailable bounded-GPCM scorefile fields.
#> 5                                                                NEWS, README, help pages, and validation artifacts that prevent operational scoring overclaims.
#>                                                                                                                                            ExitCriterion
#> 1                                                        Scorefile help pages can name the bounded-GPCM estimand without borrowing Rasch-family wording.
#> 2                                           Tests cover slope variation, slope_facet identification, expected-score conversion, and boundary categories.
#> 3 Tests cover finite native expected-score and score-side delta SEs where available, plus explicit not_requested/unavailable status where not available.
#> 4                                       facets_output_contract_review() can report bounded-GPCM score rows without silently emitting unsupported fields.
#> 5                                                        Release wording states whether the route is supported, supported_with_caveat, or still blocked.
```
