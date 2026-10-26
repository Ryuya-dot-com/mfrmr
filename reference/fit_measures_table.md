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
  fit_df_method = "facets",
  df_zstd_tolerance = 0.05,
  df_zstd_large_shift = 0.5,
  df_ratio_tolerance = 0.05,
  sort_by = c("status", "abs_zstd", "facet", "level"),
  top_n = Inf,
  flag_basis = c("mnsq", "mnsq_or_zstd")
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- diagnostics:

  Optional diagnostics object. If supplied, `x` may be the matching
  supported fitted object; mismatched or outdated diagnostics are
  rejected. Alternatively, pass diagnostics alone as `x`. Supplying
  diagnostics does not enable ordinary fit measures for corrected JML,
  two-family GPCM, testlet or shared-rater models. Use
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  for their separately supported descriptive response residuals.

- facet:

  Optional facet-name filter, for example `"Rater"`.

- include_person:

  Logical; if `FALSE` (default), excludes the `Person` facet so
  operational facet elements are shown first.

- lower, upper:

  Optional mean-square review band. Defaults to
  [`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_misfit_thresholds.md).

- zstd_cut:

  Absolute ZSTD cutoff used for directional underfit/overfit flags when
  `flag_basis = "mnsq_or_zstd"`; also used for the separate ZSTD and
  df-sensitivity columns. Default `2`.

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
  inside the helper. `"facets"` is the default, matching
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  `"engine"` keeps the former package-native fit df, `"facets"` makes
  primary ZSTD columns use the FACETS/Wright-Masters fourth-moment df
  convention, and `"both"` keeps engine columns primary while adding
  FACETS-style companion df/ZSTD columns for comparison.

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

- flag_basis:

  `"mnsq"` (default) bases directional status on Infit/Outfit mean
  squares. `"mnsq_or_zstd"` also flags either large positive or negative
  ZSTD, reproducing the previous combined rule when all indices are
  available.

## Value

A bundle of class `mfrm_fit_measures` with:

- `fit_basis`: calculation target and interpretation by facet

- `diagnostic_basis`: saved diagnostic-path guide, when present

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
`Fixed` identifies values supplied by anchors or identification
constraints. Their sampling SEs and intervals are not applicable;
response-fit statistics remain available. Recompute older diagnostics to
obtain these labels. The table also retains `SE_Method`,
`PrecisionTier`, `SEUse`, `CIBasis`, `CIUse`, `CIEligible`, `CILabel`,
`CI_Method` and `SupportsFormalInference` from the diagnostics. For JML,
normal bands remain exploratory screening summaries, not qualified
confidence intervals for the true parameter. Changing `ci_level` changes
their width, not their inferential status. Older inputs without this
metadata are labelled as having an unrecorded basis; finite SEs alone do
not establish formal inference.

After `fm <- fit_measures_table(x)`, use
`p <- plot(fm, type = "measure_ci", draw = FALSE)` to inspect the bands.
`plot_data(p, "caption")` retains the explanation and
`plot_data(p, "table")` retains the interpretation fields. Titles and
notes are not drawn by default; `show_notes = TRUE` explicitly adds the
note. Fixed values use open diamonds without intervals; other finite
estimates without intervals use crosses.

Directional labels use the selected `flag_basis`. By default, high mean
squares are labeled `underfit` and low mean squares `overfit`;
conflicting directions are `mixed`. ZSTD values remain visible, and
`ZSTDOnly` identifies combined-rule flags when the mean-square screen is
known negative. These standardized values are sample-size and
df-convention dependent. A ZSTD-only departure is not automatically a
substantively important misfit.

Missing indices cannot establish a negative screen: one positive is
retained, but no positive plus an unavailable index is `not_available`.
`ScreenComplete` records whether all indices required by the selected
rule were available. Low mean squares indicate less residual variability
than expected. They do not diagnose misconduct, poor rater quality or
machine-learning overfitting, and are not an automatic reason for
exclusion. Investigate high mean squares and substantive consequences
first. Published bands are contextual heuristics, not calibrated error
probabilities or universal thresholds for all facets.

FACETS-style ZSTD comparison is controlled by `fit_df_method`. MnSq
values should be compared first; df and ZSTD columns explain how the
same MnSq values are standardized. Use `fit_df_method = "both"` when
preparing a table for FACETS users or when explaining why \|ZSTD\| flags
change across df conventions. The `df_zstd_tolerance`,
`df_zstd_large_shift`, and `df_ratio_tolerance` arguments make the
df-sensitivity screen explicit so the same table can be reproduced under
stricter or more permissive review rules.

Saved calculation definitions remain beside the fit values: `FitBasis`
and `FitInterpretation` distinguish residuals at saved EAPs, JML
optimizer coordinates, and imported source statistics. EAP plug-in MnSq
is descriptive; it is not posterior-averaged or posterior-predictive
fit, and same-response EAP scoring does not guarantee expectation one.
Missing definitions are marked as not recorded, without discarding
finite values. `diagnostic_basis` preserves the original guide to other
diagnostic paths; marginal category counts are not posterior-averaged
MnSq.

## References

Linacre, J. M. (2003). Size vs. significance: standardized chi-square
fit statistic. *Rasch Measurement Transactions*, 17(1), 918.
<https://www.rasch.org/rmt/rmt171n.htm>. Wright, B. D. and Linacre, J.
M. (1994). Reasonable mean-square fit values. *Rasch Measurement
Transactions*, 8(3), 370. <https://www.rasch.org/rmt/rmt83b.htm>.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`facets_fit_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_fit_review.md),
[plot(x, type =
"bubble")](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`mfrm_misfit_thresholds()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_misfit_thresholds.md),
[`mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_sensitivity.md)

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 7, maxit = 30
)
fm <- fit_measures_table(fit, facet = "Rater")
fm$facets_table
#>   Facet Level    Measure Fixed      S.E.   Lower CI    Upper CI CI Level
#> 1 Rater   R05  0.1348932 FALSE 0.2298500 -0.3156044  0.58539090     0.95
#> 2 Rater   R01 -0.5968433 FALSE 0.2231594 -1.0342276 -0.15945899     0.95
#> 3 Rater   R06  0.3677868 FALSE 0.2401725 -0.1029426  0.83851627     0.95
#> 4 Rater   R04  0.1692568 FALSE 0.2164848 -0.2550456  0.59355929     0.95
#> 5 Rater   R02 -0.3339430 FALSE 0.2066065 -0.7388843  0.07099831     0.95
#> 6 Rater   R03  0.2588494 FALSE 0.2123514 -0.1573516  0.67505041     0.95
#>       Interval interpretation                   SE basis Obs Infit MnSq
#> 1 Model-based normal interval Observed information (MML)  44  0.6437494
#> 2 Model-based normal interval Observed information (MML)  47  0.7558296
#> 3 Model-based normal interval Observed information (MML)  38  0.8062824
#> 4 Model-based normal interval Observed information (MML)  47  0.9195966
#> 5 Model-based normal interval Observed information (MML)  56  0.9659519
#> 6 Model-based normal interval Observed information (MML)  50  1.0003529
#>   Infit ZStd Outfit MnSq Outfit ZStd Infit df Outfit df         Fit df method
#> 1 -2.0209607   0.6364430  -2.0096758 51.88287  49.03268 facets_wright_masters
#> 2 -1.4432350   0.7419517  -1.4840655 63.20603  59.17353 facets_wright_masters
#> 3 -0.8846298   0.7890478  -0.9547509 42.42920  40.77036 facets_wright_masters
#> 4 -0.3893766   0.9036096  -0.4663254 59.41458  56.36934 facets_wright_masters
#> 5 -0.1555933   1.0267816   0.2145481 74.49979  71.60665 facets_wright_masters
#> 6  0.0613227   0.9692421  -0.1113085 63.10792  61.01441 facets_wright_masters
#>   Fit basis
#> 1 saved EAP
#> 2 saved EAP
#> 3 saved EAP
#> 4 saved EAP
#> 5 saved EAP
#> 6 saved EAP
#>                                                                                                                                                                                                                                                                                Fit interpretation
#> 1 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#> 2 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#> 3 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#> 4 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#> 5 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#> 6 Conditional residuals evaluated at saved EAP person measures; descriptive MnSq, not posterior-averaged residual statistics or posterior-predictive residuals. Person and calibration uncertainty are not propagated. Same-response EAP scoring does not establish an expectation-one reference.
#>   FACETS Infit df FACETS Outfit df FACETS Infit ZStd FACETS Outfit ZStd
#> 1        51.88287         49.03268        -2.0209607         -2.0096758
#> 2        63.20603         59.17353        -1.4432350         -1.4840655
#> 3        42.42920         40.77036        -0.8846298         -0.9547509
#> 4        59.41458         56.36934        -0.3893766         -0.4663254
#> 5        74.49979         71.60665        -0.1555933          0.2145481
#> 6        63.10792         61.01441         0.0613227         -0.1113085
#>   Max ZStd shift Flag changed by df Max df rel shift                df review
#> 1     0.64871108               TRUE        0.5066771       flag_changed_by_df
#> 2     0.47849778              FALSE        0.5120042 df_convention_difference
#> 3     0.30898811              FALSE        0.4983455 df_convention_difference
#> 4     0.15948863              FALSE        0.5054059 df_convention_difference
#> 5     0.08562633              FALSE        0.5063195 df_convention_difference
#> 6     0.02401090              FALSE        0.5001427 df_convention_difference
#>    Fit Status               Review Reason
#> 1 within_band Within selected review band
#> 2 within_band Within selected review band
#> 3 within_band Within selected review band
#> 4 within_band Within selected review band
#> 5 within_band Within selected review band
#> 6 within_band Within selected review band
fm$underfit
#>  [1] Facet                                   
#>  [2] Level                                   
#>  [3] Measure                                 
#>  [4] Fixed                                   
#>  [5] SE                                      
#>  [6] CI_Lower                                
#>  [7] CI_Upper                                
#>  [8] CI_Level                                
#>  [9] N                                       
#> [10] Infit                                   
#> [11] Outfit                                  
#> [12] InfitZSTD                               
#> [13] OutfitZSTD                              
#> [14] DF_Infit                                
#> [15] DF_Outfit                               
#> [16] DF_Infit_ENGINE                         
#> [17] DF_Outfit_ENGINE                        
#> [18] DF_Infit_FACETS                         
#> [19] DF_Outfit_FACETS                        
#> [20] InfitZSTD_ENGINE                        
#> [21] OutfitZSTD_ENGINE                       
#> [22] InfitZSTD_FACETS                        
#> [23] OutfitZSTD_FACETS                       
#> [24] FitDfMethod                             
#> [25] FitZSTDTransform                        
#> [26] InfitBand                               
#> [27] OutfitBand                              
#> [28] InfitZSTDBand                           
#> [29] OutfitZSTDBand                          
#> [30] Underfit                                
#> [31] Overfit                                 
#> [32] FitStatus                               
#> [33] ScreenComplete                          
#> [34] ZSTDOnly                                
#> [35] ReviewReason                            
#> [36] MaxAbsZSTD                              
#> [37] MaxMnSqDistance                         
#> [38] FitBasis                                
#> [39] FitInterpretation                       
#> [40] SE_Method                               
#> [41] PrecisionTier                           
#> [42] SupportsFormalInference                 
#> [43] SEUse                                   
#> [44] CIBasis                                 
#> [45] CIUse                                   
#> [46] CIEligible                              
#> [47] CILabel                                 
#> [48] CI_Method                               
#> [49] InfitZSTDDiff_FACETS_minus_ENGINE       
#> [50] OutfitZSTDDiff_FACETS_minus_ENGINE      
#> [51] MaxAbsZSTDDiff_FACETS_vs_ENGINE         
#> [52] MaxAbsLogDFRatio_ENGINE_over_FACETS     
#> [53] MaxDFRelativeDifference_ENGINE_vs_FACETS
#> [54] EngineFlagAbsZ                          
#> [55] FacetsStyleFlagAbsZ                     
#> [56] FlagChangedByDf                         
#> [57] DfSensitivityStatus                     
#> <0 rows> (or 0-length row.names)

# Include FACETS-style df/ZSTD companion columns for comparison.
fm_facets <- fit_measures_table(fit, facet = "Rater", fit_df_method = "both")
fm_facets$df_conversion_guide$decision_guide
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
