# Review fit standardization against FACETS-style ZSTD conventions

Review fit standardization against FACETS-style ZSTD conventions

## Usage

``` r
facets_fit_review(
  fit,
  diagnostics = NULL,
  facets_fit = NULL,
  facet_col = NULL,
  level_col = NULL,
  mnsq_tolerance = 0.01,
  external_zstd_tolerance = 0.05,
  df_tolerance = 0.5,
  df_zstd_tolerance = 0.05,
  df_zstd_large_shift = 0.5,
  df_ratio_tolerance = 0.05
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  If it does not contain FACETS-style fit columns, diagnostics are
  recomputed with `fit_df_method = "both"` and `residual_pca = "none"`.

- facets_fit:

  Optional external FACETS fit table, or a list of such tables. The
  helper matches rows by `Facet` and `Level`; a person-only table with a
  `Person` column is also accepted.

- facet_col, level_col:

  Optional explicit column names for the external FACETS table when
  automatic detection is not sufficient.

- mnsq_tolerance, external_zstd_tolerance, df_tolerance:

  Numeric tolerances used to classify external FACETS-vs-mfrmr
  differences.

- df_zstd_tolerance:

  Smallest absolute engine-vs-FACETS-style ZSTD difference treated as
  interpretively visible rather than rounding noise in `df_sensitivity`.
  Default `0.05`.

- df_zstd_large_shift:

  Absolute engine-vs-FACETS-style ZSTD difference labeled
  `large_zstd_shift` when the \|ZSTD\| flag status is unchanged. Default
  `0.5`.

- df_ratio_tolerance:

  Relative df-difference tolerance used to classify the within-mfrmr
  engine-vs-FACETS-style df difference; for example, `0.05` means a 5
  percent df difference.

## Value

An `mfrm_facets_fit_review` bundle with:

- `summary`: one-row overview of within-mfrmr and external comparison
  counts

- `standardization`: the fit-standardization guide from diagnostics

- `df_sensitivity`: engine-vs-FACETS-style df/ZSTD comparison using the
  same row-level status taxonomy as
  `fit_measures_table()$df_sensitivity`

- `df_sensitive`: subset of `df_sensitivity` whose df convention changes
  the \|ZSTD\| flag or materially changes ZSTD interpretation

- `df_sensitivity_summary`: counts by df-sensitivity status

- `external_table_quality`: completeness and duplicate-key review for
  the supplied FACETS fit table, including reported-token and
  displayed-ZSTD boundary counts

- `external_comparison`: optional external FACETS-vs-mfrmr comparison

- `df_conversion_guide`: formulas, column map, and comparison decisions
  for FACETS-style df/ZSTD review

- `guidance`: interpretation notes

- `settings`: tolerances and review metadata

## Details

This helper separates two questions that are often conflated when
comparing mfrmr output with FACETS:

- how much the package-native `engine` ZSTD changes when the same MnSq
  values are standardized with the FACETS/Wright-Masters fourth-moment
  df convention;

- when an external FACETS table is supplied, whether the FACETS-reported
  rows match mfrmr's FACETS-style companion columns closely enough for
  practical reporting.

The review is row-matched by `Facet` and `Level`. It treats MnSq, ZSTD,
and df differences separately because FACETS documentation makes the df
convention and Wilson-Hilferty/WHEXACT handling central to ZSTD
interpretation.

Two prior limitations also apply. For `method = "MML"` fits, residuals
are evaluated at shrunken EAP person measures while FACETS uses JMLE
estimates, so MnSq itself can differ before standardization; refit with
`method = "JML"` for a JMLE-style residual basis. And mfrmr withholds
ZSTD as `NA` when the applicable df falls below 1 (Wilson-Hilferty
instability), while FACETS under `WHEXACT` can report a value on the
same sparse cell; such NA-vs-finite pairs are availability differences,
not fit differences. Both notes are repeated in the returned `guidance`
table.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
review <- facets_fit_review(fit)
summary(review)
#> mfrmr FACETS Fit Review Summary
#>   Class: mfrm_facets_fit_review
#>   Components: 10
#> 
#> Review overview
#>  Model Elements DfComparedRows DfSensitiveRows DfSameOrRoundingRows
#>    RSM       56             56              56                    0
#>  LargeZSTDShiftRows DfConventionDifferenceRows FlagChangedByDf ExternalRows
#>                   4                         52               0            0
#>  ExternalDuplicateKeyRows ExternalCompleteMnSqRows ExternalCompleteZSTDRows
#>                         0                        0                        0
#>  ExternalCompleteDFRows ExternalReportedTokenRows ExternalNumericOnlyRows
#>                       0                         0                       0
#>  ExternalZSTDBoundaryRows ExternalMatched ExternalNeedsReview
#>                         0               0                   0
#>  ExternalComparison
#>        Not supplied
#> 
#> Fit-standardization rows requiring review
#>      Facet        Level Infit Outfit MaxAbsZDiff FlagChanged
#>  Criterion Organization 0.867  0.858       0.492       FALSE
#>           ReviewStatus
#>  DF convention differs
#> 
#> Interpretation
#>  - The df convention differs enough to affect ZSTD interpretation even if the
#>    flag status is unchanged.
#> 
#> Settings
#>                         Setting                          Value
#>                         Purpose     Fit standardization review
#>        External FACETS supplied                          FALSE
#>                   DF comparison        Engine and FACETS-style
#>                  MnSq tolerance                           0.01
#>         External ZSTD tolerance                           0.05
#>                    DF tolerance                            0.5
#>               DF/ZSTD tolerance                           0.05
#>      Large ZSTD-shift threshold                            0.5
#>              DF-ratio tolerance                           0.05
#>  external_zstd_threshold_policy display_equality_indeterminate
#> 
#> Notes
#>  - Engine-vs-FACETS-style df/ZSTD differences need review for 56 element(s).
#>  - Person-level fit-review rows: 9; identifiers suppressed. Use `include_person
#>    = TRUE` only under appropriate privacy controls.
#>  - Person identifiers are suppressed in this summary. Use `include_person =
#>    TRUE` only under appropriate privacy controls.
#> 
#> Further detail
#>  - Complete comparison rows remain in `$df_sensitivity` and `$df_sensitive`.
# }
```
