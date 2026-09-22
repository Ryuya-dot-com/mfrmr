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

- `misfit_flagged`: rows flagged by the Infit / Outfit mean-square band

- `fit_screening`: counts of all, classified and unclassified elements
  for the mean-square band and each ZSTD cutoff. Either available
  statistic crossing a cutoff flags the element; otherwise a missing
  statistic leaves it unclassified. Rates require every element to be
  classified. Nonfinite statistics and negative mean squares are
  unavailable, not passing values.

- `misfit_thresholds`: named numeric vector with the misfit `lower` /
  `upper` thresholds used to populate `misfit_flagged`

- `category_usage`: per-category response-frequency summary used to flag
  empty / collapsed categories

- `top_fit`: top maximum `|ZSTD|` rows with both statistics available

- `marginal_coverage`: classified, unclassified and flagged category
  cells, groups and level pairs; counts of available flags do not
  describe missing results

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

- `fit_screening`: available classifications and unclassified elements
  for each mean-square/ZSTD rule. A known threshold crossing remains
  flagged even if the other statistic is missing. Recreate older
  summaries and reports from existing diagnostics; no MFRM refit is
  required.

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
# Load the package and example ratings
library(mfrmr)
toy <- load_mfrmr_data("example_operational")

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

# Check model fit and the support for standard errors and intervals
diagnostics <- diagnose_mfrm(fit)
diagnostic_summary <- summary(diagnostics)
diagnostic_summary$decision
#>               Interpretation FormalInference FitReadiness
#> 1 Ready for formal inference             Yes        ready
#>                                           Why
#> 1 All stored fit-readiness components passed.
#>                                                                                            NextAction
#> 1 Inspect `diagnostic_basis` before comparing legacy residual evidence with strict marginal evidence.

diagnostic_summary$key_warnings # Issues to investigate, if present
#> [1] "Unexpected responses flagged: 60."                                                                                                 
#> [2] "Flagged displacement levels: 1."                                                                                                   
#> [3] "MnSq screening flagged 18 element(s) outside the configured 0.5-1.5 band."                                                         
#> [4] "Person-level fit warnings: 18 row(s); identifiers suppressed. Use `include_person = TRUE` only under appropriate privacy controls."
#> [5] "Strict marginal fit flagged 1 group-level summaries."                                                                              
diagnostic_summary$top_fit      # Most unusual residual-based fit statistics
#> # A tibble: 10 × 9
#>    Facet     Level   Infit Outfit InfitZSTD OutfitZSTD DF_Infit DF_Outfit  AbsZ
#>    <chr>     <fct>   <dbl>  <dbl>     <dbl>      <dbl>    <dbl>     <dbl> <dbl>
#>  1 Person    P026    0.126  0.117     -1.90      -2.46     4.06         6  2.46
#>  2 Person    P022    0.126  0.123     -1.94      -2.42     4.23         6  2.42
#>  3 Person    P016    2.66   2.53       1.68       2.08     2.94         6  2.08
#>  4 Criterion Content 0.730  0.743     -1.56      -1.89    58.5         94  1.89
#>  5 Rater     R05     0.648  0.640     -1.34      -1.87    25.1         44  1.87
#>  6 Person    P035    0.239  0.237     -1.45      -1.79     4.36         6  1.79
#>  7 Person    P008    0.251  0.250     -1.40      -1.73     4.34         6  1.73
#>  8 Person    P025    2.22   2.18       1.55       1.73     4.18         6  1.73
#>  9 Person    P012    2.01   2.17       1.35       1.72     4.05         6  1.72
#> 10 Person    P017    0.265  0.285     -1.25      -1.59     3.85         6  1.59

# Distinguish residual-based checks from marginal model checks
diagnostic_summary$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]
#> # A tibble: 4 × 3
#>   DiagnosticPath                   Status        Basis                          
#>   <chr>                            <chr>         <chr>                          
#> 1 legacy_residual_fit              computed      plugin_residuals_and_eap_tables
#> 2 strict_marginal_fit              computed      latent_integrated_first_order_…
#> 3 strict_pairwise_local_dependence computed      latent_integrated_second_order…
#> 4 posterior_predictive_follow_up   not_available posterior_predictive_replicati…
# }
```
