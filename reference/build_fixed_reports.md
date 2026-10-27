# Build legacy-compatible fixed-width text reports

Build legacy-compatible fixed-width text reports

## Usage

``` r
build_fixed_reports(
  bias_results,
  target_facet = NULL,
  branch = c("facets", "original"),
  df_method = c("facets", "classical")
)
```

## Arguments

- bias_results:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- target_facet:

  Optional target facet for pairwise contrast table.

- branch:

  Output branch: `"facets"` keeps the legacy-compatible fixed-width
  layout; `"original"` returns compact sectioned fixed-width text for
  report drafts.

- df_method:

  Pairwise df convention: `"facets"` (modified Rasch-Welch, integer
  part, matching FACETS 4.5.0) or `"classical"` (former continuous df).

## Value

A named list with class `mfrm_fixed_reports` (and a branch-specific
subclass `mfrm_fixed_reports_<branch>`):

- `bias_fixed`: fixed-width interaction table text

- `pairwise_fixed`: fixed-width pairwise contrast text

- `pairwise_table`: underlying pairwise data.frame

- `branch`: character scalar `"original"` or `"facets"` echoing which
  fixed-width style was rendered

- `style`: character scalar carrying the resolved style preset used when
  building the text artifact

- `interaction_label`: human-readable label for the interaction that
  drove the bias run (`"Rater x Criterion"`-style); `NA` when no bias
  rows are available

- `target_facet`: character scalar identifying which facet was used as
  the target facet for pairwise contrasts; `NA` when no pairwise
  contrasts were requested or available

## Details

This function generates plain-text, fixed-width output intended to be
read in console/log environments or exported into text reports.

The pairwise section (Table 14 style) is only generated for 2-way bias
runs. For higher-order interactions (`interaction_facets` length \>= 3),
the function returns the bias table text and a note explaining why
pairwise contrasts were skipped.

## Pairwise calculation

For each target element, compare its local measure in two contexts. If
the target has predictor sign `s`, its local measure is
`target + bias/s`; the contrast is Context1 minus Context2. A negatively
oriented rater therefore has local severity `severity - bias`.
`TargetSign` comes from the saved bias result's `orientation_review`.
Missing orientation withholds local measures, contrasts and tail areas;
it is not inferred from a facet name.

`SE1` and `SE2` are conditional cell-information SEs with baseline
calibration held fixed. The contrast SE is `sqrt(SE1^2 + SE2^2)` under
conditional independence of the two cells. Calibration uncertainty and
cross-cell covariance are not propagated. `Target S.E.` describes the
original target estimate separately and is not added to the conditional
local SE; a fixed target can still have uncertain local bias.

The default `df_method = "facets"` uses the modified Rasch-Welch formula
described in the FACETS t-statistics manual (von Davier, 2025). Writing
`v1 = SE1^2`, `v2 = SE2^2` and `n1`, `n2` for weighted counts, its df is
`(v1+v2)^2 * (n1+n2-2) / ((n1+n2+2) * (v1^2/(n1+1)+v2^2/(n2+1)))`. The
tail area uses its integer part, matching executed FACETS 4.5.0
unequal-count examples. Values are stabilized to ten decimal places
before truncation to avoid numerical noise at integer boundaries.
`DFUnrounded` retains the original continuous value.
`df_method = "classical"` retains the former Welch-Satterthwaite
reference with `n1-1`, `n2-1` and no integer truncation. `DFMethod` and
`DFBasis` identify the choice; equal counts alone cannot distinguish the
formulas. `ObsN1` and `ObsN2` are raw row counts. Both weighted counts
must exceed one, both SEs must be positive and finite, and the final df
must be positive. Otherwise the screen remains unavailable. Fractional
weights follow the same rule but are outside the executed comparison.
These are conditional screens, not calibrated fairness tests or general
FACETS equivalence.

## Saved pairwise results

Current tables carry `CalculationVersion = 3`. Recreate older fixed or
pairwise reports using `build_fixed_reports()` or
[`bias_pairwise_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_pairwise_report.md).
If the bias bundle predates baseline-score corrections or lacks
orientation, recreate
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
from the saved fit and current diagnostics first. No main calibration
refit is needed. Keep historical values separately; summaries and
fixed-report plots reject older pairwise calculations.

## Interpreting output

- `bias_fixed`: fixed-width table of interaction effects.

- `pairwise_fixed`: pairwise contrast text (2-way only).

- `pairwise_table`: structured contrast table.

- `interaction_label`: facets used for the bias run.

## Typical workflow

1.  Run
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

2.  Build text bundle with `build_fixed_reports(...)`.

3.  Use
    [`summary()`](https://rdrr.io/r/base/summary.html)/[`plot()`](https://rdrr.io/r/graphics/plot.default.html)
    for quick checks, then export text blocks.

## Preferred route for new analyses

For new reporting workflows, prefer
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
and
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).
Use `build_fixed_reports()` when a fixed-width text artifact is
specifically required for a compatibility handoff.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
[mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diag <- example_fit$diagnostics
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
fixed <- build_fixed_reports(bias)
fixed_original <- build_fixed_reports(bias, branch = "original")
summary(fixed)
#> mfrmr Fixed-Report Bundle
#> 
#> Overview
#>  Branch         Style       Interaction PairwiseRows BiasTextLines
#>  facets facets_manual Rater x Criterion           24            26
#>  PairwiseTextLines
#>                 28
#> 
#> Pairwise preview
#>  Target TargetSign Target N Target Measure Target S.E. Context1 Context1 N
#>     R01         -1        1         -0.867       0.152 Accuracy          1
#>     R01         -1        1         -0.867       0.152 Accuracy          1
#>     R01         -1        1         -0.867       0.152 Accuracy          1
#>     R01         -1        1         -0.867       0.152  Content          2
#>     R01         -1        1         -0.867       0.152  Content          2
#>     R01         -1        1         -0.867       0.152 Language          3
#>     R02         -1        2          0.007       0.147 Accuracy          1
#>     R02         -1        2          0.007       0.147 Accuracy          1
#>     R02         -1        2          0.007       0.147 Accuracy          1
#>     R02         -1        2          0.007       0.147  Content          2
#>  Local Measure1   SE1 Obs-Exp Avg1 Count1 ObsN1     Context2 Context2 N
#>          -1.644 0.308        0.371     24    24      Content          2
#>          -1.644 0.308        0.371     24    24     Language          3
#>          -1.644 0.308        0.371     24    24 Organization          4
#>          -0.589 0.301       -0.123     24    24     Language          3
#>          -0.589 0.301       -0.123     24    24 Organization          4
#>          -0.683 0.308       -0.079     24    24 Organization          4
#>          -0.240 0.288        0.124     24    24      Content          2
#>          -0.240 0.288        0.124     24    24     Language          3
#>          -0.240 0.288        0.124     24    24 Organization          4
#>           0.036 0.296       -0.014     24    24     Language          3
#>  Local Measure2   SE2 Obs-Exp Avg2 Count2 ObsN2 Contrast    SE      t d.f.
#>          -0.589 0.301       -0.123     24    24   -1.054 0.431 -2.447   45
#>          -0.683 0.308       -0.079     24    24   -0.961 0.436 -2.204   46
#>          -0.505 0.293       -0.169     24    24   -1.139 0.425 -2.678   45
#>          -0.683 0.308       -0.079     24    24    0.094 0.431  0.217   45
#>          -0.505 0.293       -0.169     24    24   -0.085 0.420 -0.202   45
#>          -0.505 0.293       -0.169     24    24   -0.178 0.425 -0.419   45
#>           0.036 0.296       -0.014     24    24   -0.276 0.413 -0.670   45
#>           0.215 0.294       -0.099     24    24   -0.455 0.411 -1.106   45
#>           0.029 0.292       -0.011     24    24   -0.269 0.410 -0.656   45
#>           0.215 0.294       -0.099     24    24   -0.179 0.417 -0.429   45
#>  Prob. InferenceTier SupportsFormalInference FormalInferenceEligible
#>  0.018     screening                   FALSE                   FALSE
#>  0.033     screening                   FALSE                   FALSE
#>  0.010     screening                   FALSE                   FALSE
#>  0.829     screening                   FALSE                   FALSE
#>  0.841     screening                   FALSE                   FALSE
#>  0.677     screening                   FALSE                   FALSE
#>  0.506     screening                   FALSE                   FALSE
#>  0.275     screening                   FALSE                   FALSE
#>  0.515     screening                   FALSE                   FALSE
#>  0.670     screening                   FALSE                   FALSE
#>  PrimaryReportingEligible   ReportingUse CalculationVersion
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>                     FALSE screening_only                  3
#>           ScreenStatus ScreenReason
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>  available_conditional         <NA>
#>                                                            ContrastBasis
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>  local target measure in Context1 minus Context2, oriented by TargetSign
#>                                                   LocalSEBasis
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>  conditional cell information; baseline calibration held fixed
#>                                                                                   SEBasis
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  combined conditional bias SEs; cross-cell covariance and calibration uncertainty omitted
#>  DFUnrounded DFMethod                  StatisticLabel   ProbabilityMetric
#>       45.976   facets Bias-contrast Welch screening t screening tail area
#>       46.000   facets Bias-contrast Welch screening t screening tail area
#>       45.886   facets Bias-contrast Welch screening t screening tail area
#>       45.976   facets Bias-contrast Welch screening t screening tail area
#>       45.966   facets Bias-contrast Welch screening t screening tail area
#>       45.886   facets Bias-contrast Welch screening t screening tail area
#>       45.969   facets Bias-contrast Welch screening t screening tail area
#>       45.981   facets Bias-contrast Welch screening t screening tail area
#>       45.990   facets Bias-contrast Welch screening t screening tail area
#>       45.998   facets Bias-contrast Welch screening t screening tail area
#>                                                                   DFBasis
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#>  FACETS 4.5.0 modified Rasch-Welch using weighted counts; df rounded down
#> 
#> Notes
#>  - Legacy-compatible branch: fixed-width text follows the compatibility layout.
p <- plot(fixed, draw = FALSE)
p2 <- plot(fixed, type = "pvalue", draw = FALSE)
if (interactive()) {
  plot(
    fixed,
    type = "contrast",
    draw = TRUE,
    main = "Pairwise Contrasts (Customized)",
    palette = c(pos = "#1b9e77", neg = "#d95f02"),
    label_angle = 45
  )
}
```
