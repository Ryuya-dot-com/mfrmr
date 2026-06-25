# Bounded GPCM Route-Boundary Coverage

Public table showing how blocked or deferred bounded-`GPCM` capability
rows are handled by the current release.

## Usage

``` r
gpcm_runtime_guard_coverage()
```

## Value

A data.frame with columns:

- `Area`

- `Helper`

- `Status`

- `GuardMode`

- `ExpectedConditionClass`

- `RecommendedRoute`

- `NextValidationStep`

- `TestRoute`

- `Notes`

## Details

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
is the user-facing support matrix. This helper records which public
helpers stop with `mfrmr_gpcm_scope_error` when called on a bounded
`GPCM` path and which capability rows have no public route yet and are
therefore documented as future-extension scope.

Package checks use this table to keep out-of-scope `GPCM` behavior
aligned with the capability matrix. A row with
`GuardMode = "runtime_error"` should have
`ExpectedConditionClass = "mfrmr_gpcm_scope_error"`. A row with
`GuardMode = "roadmap_only"` records a documented future-extension
target with no public helper to call in the current release.

## See also

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)

## Examples

``` r
gpcm_runtime_guard_coverage()
#>                                       Area                          Helper
#> 1 FACETS output-contract score-side review facets_output_contract_review()
#> 2        MCMC and heavy-backend extensions                            <NA>
#>     Status     GuardMode ExpectedConditionClass
#> 1  blocked runtime_error mfrmr_gpcm_scope_error
#> 2 deferred  roadmap_only                   <NA>
#>                                                                                                                                                                                                  RecommendedRoute
#> 1 Use direct fair-average tables and graph-only compatibility outputs; use `gpcm_score_side_contract()` to inspect the unblock criteria, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.
#> 2                                                                                                                         Keep this outside the current public GPCM route and track it as future-extension scope.
#>                                                                                                                                                                             NextValidationStep
#> 1 Complete the `gpcm_score_side_contract()` requirements, including a FACETS-compatible free-discrimination score metric and output contract, before enabling full score-side contract review.
#> 2                                                                                           Decide posterior-predictive, MCMC, and backend scope only after the score-side contract is stable.
#>                                  TestRoute
#> 1                         minimal mfrm_fit
#> 2 no public runtime helper in this release
#>                                                                                                                   Notes
#> 1 Full FACETS score-side contract review is intentionally unavailable for bounded GPCM; see gpcm_score_side_contract().
#> 2                                   Documented as future-extension scope until a public backend/MCMC helper is exposed.
```
