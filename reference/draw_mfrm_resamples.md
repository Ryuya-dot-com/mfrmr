# Draw observed-data MFRM resamples

Draw observed-data MFRM resamples

## Usage

``` r
draw_mfrm_resamples(spec, keep_data = TRUE)
```

## Arguments

- spec:

  Output from
  [`build_mfrm_resampling_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md).

- keep_data:

  Logical; if `TRUE`, return a list of replicate data frames. If
  `FALSE`, return manifest tables only.

## Value

An object of class `mfrm_resamples` with `samples`, `manifest`,
`stratum_manifest`, and `preserve_manifest`.

## See also

[`build_mfrm_resampling_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md)

## Examples

``` r
toy <- simulate_mfrm_data(n_person = 12, n_rater = 3, n_criterion = 2,
                          raters_per_person = 2, seed = 11)
region_map <- setNames(rep(c("A", "B", "C"),
                           length.out = length(unique(toy$Person))),
                       unique(toy$Person))
toy$Region <- unname(region_map[toy$Person])
spec <- build_mfrm_resampling_spec(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", strata = "Region", reps = 2,
  sample_fraction = 0.5, seed = 99
)
draws <- draw_mfrm_resamples(spec, keep_data = FALSE)
summary(draws)$overview
#>                 Design Reps SamplesReturned Replace
#> 1 stratified_subsample    2               0   FALSE
#>   PreserveCoverageCompleteRate TopupReps GapOrFallbackReps
#> 1                            1         0                 0
```
