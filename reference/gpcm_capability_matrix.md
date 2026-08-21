# GPCM Workflow Availability

Check which bounded `GPCM` workflows can be used in `mfrmr`, the limits
that apply to each workflow, and the recommended alternative when a
route is not available.

The table is intended for route selection before or after fitting and is
limited to workflow availability, interpretive constraints, and the
route to use next.

## Usage

``` r
gpcm_capability_matrix(
  status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")
)
```

## Arguments

- status:

  Which rows to return: `"all"` (default), `"supported"`,
  `"supported_with_caveat"`, `"blocked"`, or `"deferred"`.

## Value

A data.frame of class `mfrmr_gpcm_capabilities` with one row per
workflow family and columns:

- `Area`

- `Helpers`

- `Status`

- `Boundary`

- `RecommendedRoute`

## Details

`Status` has the following user-facing meanings:

- `supported`: the helper is available within the stated boundary;

- `supported_with_caveat`: the helper runs, but its interpretation is
  restricted as described in `Boundary`;

- `blocked`: the helper intentionally stops for a bounded `GPCM` fit;

- `deferred`: no public `mfrmr` route is currently available.

Read `Boundary` before interpreting a caveated result. For a blocked or
deferred row, use `RecommendedRoute` to choose a supported analysis or a
Rasch-family alternative.

## Typical workflow

1.  Call `gpcm_capability_matrix()` before using `GPCM` in a new
    workflow.

2.  For `supported_with_caveat`, read `Boundary` before interpreting
    output.

3.  For `blocked` or `deferred`, follow `RecommendedRoute` instead.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)

## Examples

``` r
gpcm_capability_matrix()
#> mfrmr bounded-GPCM workflow availability
#> 
#>                 Status Routes
#>              supported      2
#>  supported_with_caveat     15
#>                blocked      1
#>               deferred      1
#> 
#> Route preview
#>                                            Area                Status
#>                      Core fitting and summaries supported_with_caveat
#>  Exploratory diagnostics and residual follow-up supported_with_caveat
#>       Fixed-calibration scoring and information             supported
#>                   Core curve and category views             supported
#>      Checklist and summary-table appendix route supported_with_caveat
#>                     Operational misfit casebook supported_with_caveat
#>        Weighting review and model-choice review supported_with_caveat
#>                   Operational linking synthesis supported_with_caveat
#> 
#> ... 11 more route(s).
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
gpcm_capability_matrix("supported")
#> mfrmr bounded-GPCM workflow availability
#> 
#>     Status Routes
#>  supported      2
#> 
#> Route preview
#>                                       Area    Status
#>  Fixed-calibration scoring and information supported
#>              Core curve and category views supported
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
gpcm_capability_matrix("blocked")
#> mfrmr bounded-GPCM workflow availability
#> 
#>   Status Routes
#>  blocked      1
#> 
#> Route preview
#>                                      Area  Status
#>  FACETS output-contract score-side review blocked
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
```
