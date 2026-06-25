# Summarize an `mfrm_diagnostics` object in a user-friendly format

Summarize an `mfrm_diagnostics` object in a user-friendly format

## Usage

``` r
# S3 method for class 'mfrm_diagnostics'
summary(object, digits = 3, top_n = 10, ...)
```

## Arguments

- object:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of highest-absolute-Z fit rows to keep.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_diagnostics` with:

- `overview`: design-level counts and residual-PCA mode

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
toy <- toy[toy$Person %in% unique(toy$Person)[1:4], ]
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
s <- summary(diag, top_n = 3)
s$key_warnings
# Look for: lines beginning with "MnSq misfit:" name the worst
#   element + Infit / Outfit values; "Unexpected responses flagged"
#   counts how many cell-level surprises the screen returned.
s$top_fit
# Look for: rows with |InfitZSTD| or |OutfitZSTD| > 2 are misfitting
#   at the 5% level; > 3 is misfitting at the 1% level. Investigate
#   in order of the AbsZ column.
s$facets_chisq
# Look for: FixedProb < 0.05 in each non-Person facet means the
#   facet contributes meaningful spread; FixedProb >= 0.05 means
#   that facet is statistically indistinguishable.
}
```
