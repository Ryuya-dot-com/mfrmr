# Summarize an `mfrm_diagnostics` object in a user-friendly format

Summarize an `mfrm_diagnostics` object in a user-friendly format

## Usage

``` r
# S3 method for class 'mfrm_diagnostics'
summary(
  object,
  digits = 3,
  top_n = 10,
  detail = c("brief", "full"),
  include_person = FALSE,
  ...
)
```

## Arguments

- object:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of highest-absolute-Z fit rows to keep.

- detail:

  Console detail: `"brief"` (default) prints the first-screen review;
  `"full"` prints the additional structured tables.

- include_person:

  If `TRUE`, person-level identifiers may be printed in fit-review
  tables. The default keeps identifiers out of console output;
  person-level rows remain available in the returned object.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_diagnostics` with:

- `overview`: design-level counts and residual-PCA mode

- `decision`: the same plain-language fit-readiness decision used by
  `summary(fit)`, retained ahead of diagnostic screening results

- `fit_readiness`, `fit_readiness_components`, and
  `fit_readiness_parameters`: readiness provenance inherited from the
  source fit and retained separately from diagnostic-screening status

- `status`: concise front-door status block for quick review

- `key_warnings`: highest-priority warnings to review first

- `next_actions`: recommended follow-up helpers

- `diagnostic_basis`: guide to legacy versus strict diagnostic targets

- `fit_standardization`: guide to the df convention used for fit ZSTD

- `overall_fit`: global fit block

- `precision_profile`: design-weighted precision summary across the
  information curve at decile theta points

- `precision_review`: separation / reliability / strata review for the
  sample- and population-basis modes (paired with `precision_profile`)

- `reliability`: facet-level separation/reliability summary

- `facets_chisq`: facets-style fixed-effect chi-square heterogeneity
  screen across non-person facets

- `interrater`: inter-rater agreement / pairwise correlation / rater
  separation overview when a Rater facet is present

- `misfit_flagged`: rows flagged by the Infit / Outfit / ZSTD misfit
  thresholds active for this fit

- `misfit_thresholds`: named numeric vector with the misfit `lower` /
  `upper` thresholds used to populate `misfit_flagged`

- `category_usage`: per-category response-frequency summary used to flag
  empty / collapsed categories

- `top_fit`: top `|ZSTD|` rows

- `marginal_fit`: optional strict marginal-fit overview when requested

- `top_marginal_cells`: largest strict marginal residual cells when
  requested

- `marginal_pairwise`: optional strict pairwise local-dependence
  overview

- `top_marginal_pairs`: largest strict pairwise residual summaries

- `marginal_guidance`: interpretation labels for strict marginal
  diagnostics

- `reporting_map`: manuscript-oriented guide to what is covered here
  versus which companion outputs should be consulted

- `flags`: compact flag counts for major diagnostics

- `notes`: short interpretation notes

- `digits`: numeric-print precision threaded through to
  `print.summary.mfrm_diagnostics()`

## Details

This method returns a compact diagnostics summary designed for quick
review:

- design overview (observations, persons, facets, categories, subsets)

- diagnostic-basis guide for legacy versus strict fit paths

- global fit statistics

- approximate reliability/separation by facet

- top facet/person fit rows by absolute ZSTD

- counts of flagged diagnostics (unexpected, displacement, interactions)

## Interpreting output

- `overview`: analysis scale, subset count, and residual-PCA mode.

- `fit_readiness`: the source fit's versioned readiness row. Diagnostics
  do not promote a blocked or review-only fit to inferential use.

- `diagnostic_basis`: plain-language map of which fit path was computed
  and what each path means statistically.

- `overall_fit`: global fit indices.

- `reliability`: facet separation/reliability block, including model and
  real bounds when available.

- `top_fit`: highest `|ZSTD|` elements for immediate inspection.

- `flags`: compact counts for key warning domains.

## Typical workflow

1.  Run diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
    using `diagnostic_mode = "both"` for `RSM` / `PCM` when you want
    legacy continuity plus strict marginal screening.

2.  Review `summary(diag)` for major warnings and inspect
    `diagnostic_basis` before comparing legacy and strict outputs.

3.  Follow up with dedicated tables/plots for flagged domains.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
toy <- toy[toy$Person %in% unique(toy$Person)[1:4], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
#> Warning: Category support is retained but requires review: at least one fitted or local scope contains an empty or singleton category/transition cell. The fit may be inspected, but category-information strength has not been certified; inspect `fit$data_review$category_support` before inference.
diag <- diagnose_mfrm(fit, residual_pca = "none")
s <- summary(diag, top_n = 3)
s$key_warnings
#> [1] "The source fit is review and is not inference-ready; all diagnostic outputs remain review-only."                 
#> [2] "Precision review flagged 2 review/warn checks."                                                                  
#> [3] "Unexpected responses flagged: 15."                                                                               
#> [4] "MnSq screening flagged 1 element(s) outside the configured 0.5-1.5 band."                                        
#> [5] "MnSq follow-up: Criterion:Organization (Infit=0.48, Outfit=0.49; outside the configured 0.5-1.5 screening band)."
# Look for: lines beginning with "MnSq misfit:" name the worst
#   element + Infit / Outfit values; "Unexpected responses flagged"
#   counts how many cell-level surprises the screen returned.
s$top_fit
#> # A tibble: 3 × 9
#>   Facet     Level     Infit Outfit InfitZSTD OutfitZSTD DF_Infit DF_Outfit  AbsZ
#>   <chr>     <fct>     <dbl>  <dbl>     <dbl>      <dbl>    <dbl>     <dbl> <dbl>
#> 1 Criterion Organiza… 0.481  0.493    -1.18      -1.67      8.48        16 1.67 
#> 2 Criterion Accuracy  1.34   1.35      0.818      1.00      9.29        16 1.00 
#> 3 Criterion Language  1.21   1.27      0.542      0.821     7.14        16 0.821
# Large absolute standardized values identify rows for follow-up; they do
# not create a universal accept/reject rule.
s$facets_chisq
#> # A tibble: 3 × 10
#>   Facet     Levels MeanMeasure    SD FixedChiSq FixedDF FixedProb RandomChiSq
#>   <chr>      <int>       <dbl> <dbl>      <dbl>   <dbl>     <dbl>       <dbl>
#> 1 Criterion      4       0     0.270       1.80       3     0.616       NA   
#> 2 Person         4       0.974 0.443       4.41       3     0.220        2.89
#> 3 Rater          4       0     0.323       2.52       3     0.471       NA   
#> # ℹ 2 more variables: RandomDF <dbl>, RandomProb <dbl>
# Read the fixed-effect chi-square as a heterogeneity screen in the context
# of the design and intended score use.
# }
```
