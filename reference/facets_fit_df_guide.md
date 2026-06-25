# Guide FACETS-style fit df and ZSTD standardization

`facets_fit_df_guide()` gives a compact user-facing guide to the degrees
of freedom and ZSTD standardization choices used when comparing mfrmr
fit output with FACETS-style fit tables.

## Usage

``` r
facets_fit_df_guide(include_references = TRUE)
```

## Arguments

- include_references:

  If `TRUE`, include source-reference rows for the FACETS/Winsteps
  documentation and Rasch measurement texts that motivate the guide.

## Value

A bundle of class `mfrm_facets_fit_df_guide` with:

- `summary`: one-row scope summary

- `formula_guide`: formulas and package columns

- `column_guide`: where engine and FACETS-style columns appear

- `decision_guide`: recommended comparison steps

- `interpretation_guide`: how to read common difference patterns

- `references`: optional source-reference rows

- `settings`: guide metadata

## Details

The guide separates mean-square size from ZSTD standardization. Infit
and outfit MnSq values answer how large the residual noise or
predictability signal is. ZSTD values standardize those MnSq values
using a degrees-of- freedom convention and a Wilson-Hilferty-style
transformation, so ZSTD can differ even when the underlying MnSq values
are nearly identical.

Two boundaries sit upstream of any df comparison. First, the residual
basis: `method = "MML"` fits evaluate residuals at shrunken EAP person
measures, whereas FACETS evaluates them at JMLE estimates, so MnSq
values themselves can differ before any standardization is applied;
refit with `method = "JML"` when the comparison requires a JMLE-style
residual basis. Second, small df: `mfrmr` returns `NA` ZSTD when
`df < 1` because the Wilson-Hilferty transformation is numerically
unstable there, while FACETS/Winsteps under `WHEXACT` can continue with
a linear approximation, so sparse cells can show `NA` against a finite
external value without indicating a fit difference.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`fit_measures_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_measures_table.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md)

## Examples

``` r
facets_fit_df_guide()
#> mfrmr FACETS Fit df Guide 
#>   Class: mfrm_facets_fit_df_guide
#>   Components (7): summary, formula_guide, column_guide, decision_guide, interpretation_guide, references, settings
#> 
#> Guide overview
#>                                    Scope
#>  FACETS-style fit df and ZSTD comparison
#>                                                                           PrimaryRule
#>  Compare MnSq first; compare ZSTD only after checking df and transformation settings.
#>                                              RecommendedRoute
#>  diagnose_mfrm(fit_df_method = "both") -> facets_fit_review()
#>                                     DefaultMfrmrPrimary
#>  engine df unless fit_df_method = "facets" is requested
#> 
#> Comparison steps: decision_guide
#>  Step                                                         Question
#>     1                                           Are MnSq values close?
#>     2                   Are df values close under the same convention?
#>     3                   Do ZSTD values differ after MnSq and df agree?
#>     4 Does |ZSTD| > 2 status change only after changing df convention?
#>     5                            Is an external FACETS table supplied?
#>                                                                                           RecommendedAction
#>  If MnSq differs materially, treat this as a fit-statistic or estimation difference before discussing ZSTD.
#>                     If df differs, classify the ZSTD gap as a df-convention issue unless MnSq also differs.
#>             Check WHEXACT/normalization settings and rounding/truncation before making a substantive claim.
#>          Report the flag as convention-sensitive; inspect MnSq and substantive context before acting on it.
#>                      Use read_facets_fit_table() or normalize_facets_fit_frame(), then facets_fit_review().
#> 
#> Settings
#>             Setting Value
#>  include_references  TRUE
#> 
#> Notes
#>  - FACETS-style fit df and ZSTD comparison guide. Compare MnSq first, then df and ZSTD.
facets_fit_df_guide()$decision_guide
#>   Step                                                         Question
#> 1    1                                           Are MnSq values close?
#> 2    2                   Are df values close under the same convention?
#> 3    3                   Do ZSTD values differ after MnSq and df agree?
#> 4    4 Does |ZSTD| > 2 status change only after changing df convention?
#> 5    5                            Is an external FACETS table supplied?
#>                                                                                            RecommendedAction
#> 1 If MnSq differs materially, treat this as a fit-statistic or estimation difference before discussing ZSTD.
#> 2                    If df differs, classify the ZSTD gap as a df-convention issue unless MnSq also differs.
#> 3            Check WHEXACT/normalization settings and rounding/truncation before making a substantive claim.
#> 4         Report the flag as convention-sensitive; inspect MnSq and substantive context before acting on it.
#> 5                     Use read_facets_fit_table() or normalize_facets_fit_frame(), then facets_fit_review().
```
