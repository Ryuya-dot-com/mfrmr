# Unavailable GPCM Routes and Alternatives

List bounded-`GPCM` routes that are not currently available and show the
supported alternative for each route.

## Usage

``` r
gpcm_runtime_guard_coverage()
```

## Value

A data.frame with columns:

- `Area`

- `Helper`

- `Status`

- `Boundary`

- `RecommendedRoute`

## Details

A `blocked` row names a helper that intentionally stops instead of
returning an unsupported bounded-`GPCM` result. A `deferred` row has no
public helper. In either case, read `Boundary` for the reason and
`RecommendedRoute` for a currently available analysis route.

## See also

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)

## Examples

``` r
gpcm_runtime_guard_coverage()
#>                                          Area                          Helper
#> 1    FACETS output-contract score-side review facets_output_contract_review()
#> 2 Posterior-predictive and Bayesian workflows                            <NA>
#>     Status
#> 1  blocked
#> 2 deferred
#>                                                                                                                                                                                                                                                               Boundary
#> 1 Limited to direct scorefile export rather than the full FACETS-style output-contract review. Direct scorefile export is available with caveats, but contract-wide coverage and metric claims still require a broader free-discrimination score-side review contract.
#> 2                                                                                                                                                                    mfrmr does not currently provide posterior-predictive checks or MCMC estimation for bounded GPCM.
#>                                                                                                                                                                                             RecommendedRoute
#> 1 Use direct fair-average tables and graph-only compatibility outputs; use package-native scorefile export with its stated caveats, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.
#> 2                                                                   Use the current MML fitting and fixed-calibration scoring routes, or use external Bayesian software when posterior sampling is required.
```
