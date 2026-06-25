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

  Relative df-difference tolerance used to classify the internal
  engine-vs-FACETS-style df difference; for example, `0.05` means a 5
  percent df difference.

## Value

An `mfrm_facets_fit_review` bundle with:

- `summary`: one-row overview of internal and external comparison counts

- `standardization`: the fit-standardization guide from diagnostics

- `df_sensitivity`: engine-vs-FACETS-style df/ZSTD comparison using the
  same row-level status taxonomy as
  `fit_measures_table()$df_sensitivity`

- `df_sensitive`: subset of `df_sensitivity` whose df convention changes
  the \|ZSTD\| flag or materially changes ZSTD interpretation

- `df_sensitivity_summary`: counts by df-sensitivity status

- `external_table_quality`: completeness and duplicate-key review for
  the supplied FACETS fit table

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

Two upstream boundaries also apply. For `method = "MML"` fits, residuals
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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
review <- facets_fit_review(fit)
summary(review)
}
```
