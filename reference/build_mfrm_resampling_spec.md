# Build an observed-data resampling specification

Build an observed-data resampling specification

## Usage

``` r
build_mfrm_resampling_spec(
  data,
  person,
  facets,
  score,
  strata = NULL,
  preserve_facets = NULL,
  design = c("stratified_subsample", "stratified_bootstrap"),
  reps = 20,
  sample_fraction = 0.5,
  sample_n = NULL,
  replace = NULL,
  seed = NULL,
  min_per_stratum = 1,
  topup_preserve_facets = TRUE
)
```

## Arguments

- data:

  A long-format observed MFRM data set.

- person:

  Person/respondent identifier column.

- facets:

  Non-person facet columns used by the target MFRM fit.

- score:

  Ordered score column.

- strata:

  Optional person-level stratification columns, for example a `Region`
  or L1 group column. Each person must have at most one unique stratum
  combination.

- preserve_facets:

  Optional facet columns whose level coverage should be reviewed and,
  when possible, topped up after the stratified person draw. A common
  choice is the rater facet.

- design:

  Resampling design. `"stratified_subsample"` samples persons without
  replacement inside each stratum. `"stratified_bootstrap"` samples
  persons with replacement inside each stratum and re-keys duplicate
  person instances in the returned data.

- reps:

  Number of resampling replicates to draw.

- sample_fraction:

  Fraction of persons to draw within each stratum when
  `sample_n = NULL`.

- sample_n:

  Optional target number of persons to draw per stratum. Supply either
  one scalar used for every stratum, or a named numeric vector whose
  names match the computed stratum labels.

- replace:

  Optional logical override for replacement. By default, replacement is
  `FALSE` for `"stratified_subsample"` and `TRUE` for
  `"stratified_bootstrap"`.

- seed:

  Optional seed used by
  [`draw_mfrm_resamples()`](https://ryuya-dot-com.github.io/mfrmr/reference/draw_mfrm_resamples.md).

- min_per_stratum:

  Minimum target persons per represented stratum.

- topup_preserve_facets:

  Logical; if `TRUE`, add extra person clusters when possible to recover
  missing levels of `preserve_facets`.

## Value

An object of class `mfrm_resampling_spec`.

## Details

This helper defines a resampling design for observed-data stability
checks. It is intentionally separate from
[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
and
[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md).
The full-data estimates used with these draws are reference estimates,
not known truth, so downstream summaries should be described as
estimation stability, reproducibility, or agreement with a full-data
reference rather than strict parameter recovery.

The design is person-clustered: all rows for a selected person are kept
together. For bootstrap draws, duplicated person clusters are re-keyed
in the returned data while the original identifier is retained in
`.mfrm_original_person`.

## See also

[`draw_mfrm_resamples()`](https://ryuya-dot-com.github.io/mfrmr/reference/draw_mfrm_resamples.md),
[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)

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
  score = "Score", strata = "Region", preserve_facets = "Rater",
  reps = 2, sample_fraction = 0.5, seed = 99
)
draws <- draw_mfrm_resamples(spec)
summary(draws)$overview
#>                 Design Reps SamplesReturned Replace
#> 1 stratified_subsample    2               2   FALSE
#>   PreserveCoverageCompleteRate TopupReps GapOrFallbackReps
#> 1                            1         0                 0
```
