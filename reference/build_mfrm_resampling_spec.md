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

  A long-format observed MFRM data set with distinct column names. The
  `.mfrm_*` metadata columns listed below are reserved and must not
  already be present. Numeric identifiers must retain distinct text
  labels.

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
  `sample_n = NULL`. Targets are rounded upward and respect
  `min_per_stratum`. The default is `0.5` for both designs; use `1` for
  a same-size bootstrap.

- sample_n:

  Optional target number of persons to draw per stratum. Supply either
  one scalar used for every stratum, or a named numeric vector whose
  names match `spec$target_plan$Stratum`. An unnamed vector of length
  equal to the number of strata follows that table's order. Targets are
  rounded upward and capped at available Persons when sampling without
  replacement.

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
  missing levels of `preserve_facets`. This changes the sampling
  distribution and can increase stratum sizes; it is not an ordinary
  bootstrap. Set `FALSE` for ordinary cluster-bootstrap draws.

## Value

An object of class `mfrm_resampling_spec` containing the input data,
columns, target plan, person/stratum rosters, `sampling_scheme` and
interpretation in `terminology`.

## Details

This helper defines a resampling design for observed-data stability
checks. It is intentionally separate from
[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
and
[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md).
The full-data estimates used with these draws are reference estimates,
not known truth, so downstream summaries should be described as
estimation stability, reproducibility, or agreement with a full-data
reference rather than strict parameter recovery.

The design is person-clustered: all rows for a selected person are kept
together. For bootstrap draws, duplicated person clusters are re-keyed
in the returned data while the original identifier is retained in
`.mfrm_original_person`.

## Sampling assumptions and interpretation

For ordinary stratified Person-cluster bootstrap draws, set
`design = "stratified_bootstrap"`, `sample_fraction = 1`,
`sample_n = NULL`, and `topup_preserve_facets = FALSE`. The unit is a
Person, not a rating row; unequal-sized clusters retain all their rows
on every draw. This targets variation across independent Persons within
strata, conditional on the observed non-Person facet levels and
assignment patterns. It does not reproduce sampling new raters or tasks,
or dependence across Persons induced by shared random effects or
peer-review networks. Crossed random effects require a resampling scheme
matched to that sampling target.

A reduced sample size or coverage top-up instead defines a stability
experiment. Top-up chooses an additional Person carrying a currently
absent preserved level, and can also bring other missing levels. It
changes inclusion probabilities and stratum totals. Use
`sampling_scheme`, the returned terminology and base/added/final counts
to report what was drawn. These helpers do not fit models or construct
confidence intervals; the presence of the word bootstrap does not
qualify downstream interval coverage. Reference estimates from the full
sample still have estimation uncertainty.

## Labels and saved specifications

Original Person keys and data values are retained. Stratum labels escape
percent signs and vertical bars, and distinguish missing values, empty
strings and literal `"(missing)"`/`"(empty)"` labels. Inspect
`target_plan` before supplying named `sample_n` values. Data column
names `.mfrm_original_person`, `.mfrm_draw_unit`, `.mfrm_stratum`,
`.mfrm_topup`, and `.mfrm_topup_reason` are reserved for returned
metadata.

[`draw_mfrm_resamples()`](https://ryuya-dot-com.github.io/mfrmr/reference/draw_mfrm_resamples.md)
rebuilds derived tables from the specification's declared inputs,
including saved older specifications. Corrected labels and top-up rules
can change old draws even with the same seed; retain old results
separately. `saveRDS(spec, ...)` preserves the input data and seed;
`saveRDS(draws, ...)` preserves the actual samples, per-replicate seeds
and manifests. Use an explicit seed to reproduce draws in a matching
R/RNG environment. Manifest-only results retain the specification and
input data but omit the materialized samples.

## References

Owen, A. B. and Eckles, D. (2012). Bootstrapping data arrays of
arbitrary order. *The Annals of Applied Statistics*, 6(3), 895–927.
[doi:10.1214/12-AOAS547](https://doi.org/10.1214/12-AOAS547) . This
discusses crossed-factor resampling; it is not the method implemented by
this Person-cluster helper.

## See also

[`draw_mfrm_resamples()`](https://ryuya-dot-com.github.io/mfrmr/reference/draw_mfrm_resamples.md),
[`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)

## Examples

``` r
# Bundled synthetic ratings: inspect stability in half-samples by Group.
ratings <- load_mfrmr_data("example_operational")
spec <- build_mfrm_resampling_spec(
  ratings, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", strata = "Group", preserve_facets = "Rater",
  reps = 2, sample_fraction = 0.5, seed = 99
)
draws <- draw_mfrm_resamples(spec)
summary(draws)$overview
#>                 Design                                 SamplingScheme Reps
#> 1 stratified_subsample coverage_augmented_stratified_person_subsample    2
#>   SamplesReturned Replace PreserveCoverageCompleteRate TopupReps
#> 1               2   FALSE                            1         0
#>   GapOrFallbackReps
#> 1                 0
draws$stratum_manifest  # Base, top-up and final Person-cluster counts.
#>     ResampleID Replicate Stratum AvailablePersons TargetPersons
#> 1 resample_001         1       A               24            12
#> 2 resample_001         1       B               24            12
#> 3 resample_002         2       A               24            12
#> 4 resample_002         2       B               24            12
#>   BasePersonClusters Rows TargetStatus SelectedPersonClusters
#> 1                 12   70           ok                     12
#> 2                 12   70           ok                     12
#> 3                 12   71           ok                     12
#> 4                 12   71           ok                     12
#>   SelectedOriginalPersons TopupPersonClusters
#> 1                      12                   0
#> 2                      12                   0
#> 3                      12                   0
#> 4                      12                   0
```
