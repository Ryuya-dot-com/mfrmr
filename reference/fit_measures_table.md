# Build a FACETS-style fit-measures review table

Build a FACETS-style fit-measures review table

## Usage

``` r
fit_measures_table(
  x,
  diagnostics = NULL,
  facet = NULL,
  include_person = FALSE,
  lower = NULL,
  upper = NULL,
  zstd_cut = 2,
  ci_level = 0.95,
  threshold_profiles = c("literature", "active", "all", "none"),
  fit_df_method = c("engine", "facets", "both"),
  df_zstd_tolerance = 0.05,
  df_zstd_large_shift = 0.5,
  df_ratio_tolerance = 0.05,
  sort_by = c("status", "abs_zstd", "facet", "level"),
  top_n = Inf
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- diagnostics:

  Optional diagnostics object. If supplied, `x` may be the fitted object
  used only for provenance.

- facet:

  Optional facet-name filter, for example `"Rater"`.

- include_person:

  Logical; if `FALSE` (default), excludes the `Person` facet so
  operational facet elements are shown first.

- lower, upper:

  Optional mean-square review band. Defaults to
  [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_misfit_thresholds.md).

- zstd_cut:

  Absolute ZSTD cutoff used for directional underfit/overfit flags.
  Default `2`.

- ci_level:

  Confidence level used to add approximate Wald intervals for facet
  measures. Default `0.95`.

- threshold_profiles:

  Which mean-square threshold profiles to summarize in addition to the
  active table band. `"literature"` (default) returns commonly cited
  bands from Linacre, Bond & Fox, and Wright & Linacre; `"active"`
  returns only the active band; `"all"` returns both; `"none"`
  suppresses profile summaries.

- fit_df_method:

  Degrees-of-freedom convention used when `diagnostics` is computed
  inside the helper. `"engine"` keeps the package-native fit df,
  `"facets"` makes primary ZSTD columns use the FACETS/Wright-Masters
  fourth-moment df convention, and `"both"` keeps engine columns primary
  while adding FACETS-style companion df/ZSTD columns for comparison.

- df_zstd_tolerance:

  Smallest absolute engine-vs-FACETS-style ZSTD difference treated as
  interpretively visible rather than rounding noise in `df_sensitivity`.
  Default `0.05`.

- df_zstd_large_shift:

  Absolute engine-vs-FACETS-style ZSTD difference labeled
  `large_zstd_shift` when the `zstd_cut` flag status is unchanged.
  Default `0.5`.

- df_ratio_tolerance:

  Relative df-difference threshold used to label
  `df_convention_difference`; for example, `0.05` means a 5 percent
  engine-vs-FACETS-style df difference. Default `0.05`.

- sort_by:

  Sorting rule: `"status"` prioritizes underfit/overfit rows,
  `"abs_zstd"` sorts by largest absolute ZSTD, and `"facet"` / `"level"`
  sort alphabetically.

- top_n:

  Optional maximum number of rows in the returned main table.

## Value

A bundle of class `mfrm_fit_measures` with:

- `table`: R-friendly fit-measure table with status columns

- `facets_table`: FACETS-style column labels for reporting/review

- `status_summary`: counts by facet and fit status

- `profile_summary_by_facet`: underfit/overfit rates for each threshold
  profile and facet

- `profile_summary_overall`: threshold-profile rates pooled over facets

- `df_sensitivity`: row-level engine-vs-FACETS-style df/ZSTD comparison

- `df_sensitive`: subset of rows where df convention changes the ZSTD
  flag or materially changes ZSTD interpretation

- `df_sensitivity_summary`: counts of df-sensitive rows

- `underfit`, `overfit`, `mixed`: filtered row subsets

- `df_conversion_guide`: FACETS-style df/ZSTD comparison guide

- `settings`: thresholds and filters used

## Details

This helper gives users a direct table route for the common FACETS-style
question: which raters, criteria, or other facet elements show underfit
or overfit? It uses the fit statistics already computed by
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

Directional labels are based on both mean-square and ZSTD evidence: high
MnSq or positive large ZSTD is labeled `underfit`; low MnSq or negative
large ZSTD is labeled `overfit`. Rows with conflicting directions are
labeled `mixed`. Treat the table as a review screen and inspect
substantive context before removing raters or changing an instrument.

FACETS-style ZSTD comparison is controlled by `fit_df_method`. MnSq
values should be compared first; df and ZSTD columns explain how the
same MnSq values are standardized. Use `fit_df_method = "both"` when
preparing a table for FACETS users or when explaining why \|ZSTD\| flags
change across df conventions. The `df_zstd_tolerance`,
`df_zstd_large_shift`, and `df_ratio_tolerance` arguments make the
df-sensitivity screen explicit so the same table can be reproduced under
stricter or more permissive review rules.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
[`plot_bubble()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_bubble.md),
[`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_misfit_thresholds.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
fm <- fit_measures_table(fit, facet = "Rater")
fm$facets_table
fm$underfit

# Include FACETS-style df/ZSTD companion columns for comparison.
fm_facets <- fit_measures_table(fit, facet = "Rater", fit_df_method = "both")
fm_facets$df_conversion_guide$decision_guide
} # }
```
