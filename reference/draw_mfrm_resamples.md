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

An object of class `mfrm_resamples` with:

- `samples`: replicate data frames with original Person, draw-unit,
  stratum and top-up metadata, or an empty list when
  `keep_data = FALSE`.

- `manifest`: replicate seeds, sampling scheme, base/added/final cluster
  counts, original Person counts, rating-row counts and coverage checks.

- `stratum_manifest`: `BasePersonClusters` before top-up,
  `TopupPersonClusters`, final `SelectedPersonClusters` and
  `SelectedOriginalPersons`, and final `Rows` for each stratum.

- `preserve_manifest`: observed coverage of requested facet levels.

- `spec` and `terminology`: inputs, sampling assumptions and
  interpretation. [`summary()`](https://rdrr.io/r/base/summary.html)
  retains full manifests as well as compact tables. For older results
  with top-up, pre-top-up stratum counts are retained as base counts;
  unrecorded final cluster counts are `NA`, with a note, while final row
  counts remain available. This does not redraw old samples.

## Details

See
[`build_mfrm_resampling_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md)
for sampling assumptions, top-up, label handling and saved-specification
compatibility. Sampling keeps each selected Person's entire rating
cluster and re-keys every instance when drawing with replacement. Other
facet labels are retained.

## See also

[`build_mfrm_resampling_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_resampling_spec.md)

## Examples

``` r
# Same-size Person-cluster bootstrap within the observed Group strata.
ratings <- load_mfrmr_data("example_operational")
spec <- build_mfrm_resampling_spec(
  ratings, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", strata = "Group", reps = 2,
  design = "stratified_bootstrap", sample_fraction = 1,
  topup_preserve_facets = FALSE, seed = 99
)
draws <- draw_mfrm_resamples(spec, keep_data = FALSE)
summary(draws)$overview
#>                 Design              SamplingScheme Reps SamplesReturned Replace
#> 1 stratified_bootstrap stratified_person_bootstrap    2               0    TRUE
#>   PreserveCoverageCompleteRate TopupReps GapOrFallbackReps
#> 1                            1         0                 0
```
