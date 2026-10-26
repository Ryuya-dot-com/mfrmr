# Estimate bias across multiple facet pairs

Estimate bias across multiple facet pairs

## Usage

``` r
estimate_all_bias(
  fit,
  diagnostics = NULL,
  pairs = NULL,
  include_person = FALSE,
  drop_empty = TRUE,
  keep_errors = TRUE,
  max_abs = 10,
  omit_extreme = TRUE,
  max_iter = 4,
  tol = 0.001
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  When `NULL`, diagnostics are computed with `residual_pca = "none"`.
  Must match this fitted analysis; see
  [mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
  for migration of saved diagnostics.

- pairs:

  Optional list of facet specifications. Each element should be a
  character vector of length 2 or more, for example
  `list(c("Rater", "Criterion"), c("Task", "Criterion"))`. Explicit
  specifications may include canonical `"Person"` regardless of
  `include_person`. When `NULL`, all 2-way combinations of modeled
  facets are used. Each combination may appear only once, regardless of
  facet order.

- include_person:

  If `TRUE` and `pairs = NULL`, include `"Person"` in the automatically
  generated pair set. `"Person"` denotes the source column supplied as
  `person` to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  and remains opt-in because these cells condition on fitted JML person
  measures or MML EAP scores.

- drop_empty:

  If `TRUE`, omit empty bias tables from `by_pair` while still recording
  them in the summary table.

- keep_errors:

  If `TRUE`, also retain per-pair error rows in the returned `errors`
  table. Either way, errors remain in `summary$Error` and do not stop
  the batch.

- max_abs:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- omit_extreme:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- max_iter:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- tol:

  Passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Value

A named list with class `mfrm_bias_collection`.

## Details

This function orchestrates repeated calls to
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
across multiple facet pairs and returns a consolidated bundle.

**Bias/interaction** in MFRM refers to a systematic departure from the
additive model for a specific combination of facet elements (e.g., a
particular rater is unexpectedly harsh on a particular criterion). See
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
for the mathematical formulation.

When `pairs = NULL`, the function builds all 2-way combinations of
modelled facets automatically. For a model with facets Rater, Criterion,
and Task, this yields Rater\\\times\\Criterion, Rater\\\times\\Task, and
Criterion\\\times\\Task. With `include_person = TRUE`,
Person\\\times\\facet pairs are prepended in the fit's facet order. They
are conditional plug-in likelihood screens, not jointly fitted
Person\\\times\\facet terms. A single warning records this boundary for
the batch.

The `summary` table aggregates results across pairs:

- `Rows`: number of interaction cells estimated

- `Points`: cells with an available bias estimate (including bounded
  optima; inspect `BiasStatus` in the combined cells)

- `ScreenAvailable`, `ScreenUnavailable`: cells with/without a usable
  conditional screening statistic

- `ScreenPositive`: count of available cells with \\\|t\| \ge 2\\; `NA`
  when no screening statistic is available, including failed pairs

- `Significant`: backward-compatible alias for `ScreenPositive`

- `MeanAbsBias`: average absolute available bias magnitude (native
  ability units)

- `Status`: `available`, `partial`, `unavailable`, `empty`, or `failed`;
  `available` refers to conditional screening, not formal inference

- `FormalInferenceEligible` / `PrimaryReportingEligible`: always
  `FALSE`; these conditional plug-in interaction statistics are
  screening evidence

Per-pair failures (e.g., insufficient data for a sparse pair) are
captured in `errors` rather than stopping the entire batch. There is no
collection-wide multiplicity correction. Cells and pairs reuse the same
observations and fitted calibration. Adjusting their screening tail
areas would not establish formal family-wise error or false-discovery
control. A screen-positive result is a prompt for review, not proof of
unfairness; no screen-positive cells does not establish absence of
interaction. Search-boundary points remain visible, with missing
screening statistics and the `ScreenStatus`/`ScreenReason` returned by
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Output

The returned object is a bundle-like list with class
`mfrm_bias_collection` and components such as:

- `summary`: one row per requested interaction

- `by_pair`: named list of successful
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  outputs

- `errors`: per-pair error log

- `settings`: resolved execution settings

- `primary`: first successful bias bundle, useful for downstream helpers

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and diagnose with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
    For `RSM` / `PCM` reporting runs, prefer `method = "MML"` plus
    `diagnostic_mode = "both"` in the diagnostics call.

2.  Run `estimate_all_bias()` to compute the requested multi-pair
    interactions.

3.  Inspect `summary(bias_all)$overview` for availability and magnitude,
    then `summary(bias_all)$cells` for all retained cells and their
    observed counts. Use
    [`plot.mfrm_bias_collection()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_bias_collection.md)
    for the overview or a named pair.

4.  Pass the resulting `by_pair` list into
    [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
    or
    [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

## Saved-result reuse

The returned `fit_identity` records the fitted analysis for reuse with
reports and exports. Recreate older results from the saved fit and
matching diagnostics using the original screening options; no model
refit is needed. See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)
for migration instructions.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML")
diag <- diagnose_mfrm(fit, residual_pca = "none", diagnostic_mode = "both")
bias_all <- estimate_all_bias(fit, diagnostics = diag)
summary(bias_all)
#> Exploratory bias screens
#>        Interaction Rows Points ScreenAvailable ScreenUnavailable ScreenPositive
#>  Rater x Criterion   16     16              16                 0              0
#>  MeanAbsBias    Status
#>       0.0797 available
#> 
#> Conditional plug-in screens: calibration and Person uncertainty are held fixed; no formal inference or collection-wide multiplicity control.
#> Positive bias increases expected coded scores. Review signed magnitude, observed counts and unavailable cells before interpreting a flag.
#> Pairs reuse observations. Do not sum cell counts across pairs as a study sample size; no flags does not establish no interaction.
head(summary(bias_all)$cells)
#>         Interaction Sq Observd Score Expctd Score Observd Count Obs-Exp Average
#> 1 Rater x Criterion  1           120     118.6394            48      0.02834529
#> 2 Rater x Criterion  2           134     136.3289            48     -0.04851837
#> 3 Rater x Criterion  3           126     122.7315            48      0.06809366
#> 4 Rater x Criterion  4           121     123.4956            48     -0.05199205
#> 5 Rater x Criterion  5           120     122.2386            48     -0.04663752
#> 6 Rater x Criterion  6           142     139.7255            48      0.04738465
#>                                 ExpectedScoreBasis AfterBiasExpectedScore
#> 1 Main-analysis expectations before the cell shift               120.0000
#> 2 Main-analysis expectations before the cell shift               134.0000
#> 3 Main-analysis expectations before the cell shift               126.0003
#> 4 Main-analysis expectations before the cell shift               121.0000
#> 5 Main-analysis expectations before the cell shift               120.0000
#> 6 Main-analysis expectations before the cell shift               142.0000
#>   AfterBiasObsExpAverage   Bias Size PrimaryBias ExtremeAdjustment      S.E.
#> 1          -3.443359e-08  0.04725162  0.04725162                 0 0.1863585
#> 2           5.523612e-08 -0.08427419 -0.08427419                 0 0.1896485
#> 3          -6.110577e-06  0.11397626  0.11397626                 0 0.1870010
#> 4          -3.077194e-07 -0.08678193 -0.08678193                 0 0.1863890
#> 5          -9.290138e-08 -0.07778079 -0.07778079                 0 0.1863585
#> 6           2.233726e-07  0.08541203  0.08541203                 0 0.1946505
#>            t d.f.     Prob. InferenceTier SupportsFormalInference
#> 1  0.2535522   47 0.8009474     screening                   FALSE
#> 2 -0.4443705   47 0.6588142     screening                   FALSE
#> 3  0.6094954   47 0.5451315     screening                   FALSE
#> 4 -0.4655958   47 0.6436552     screening                   FALSE
#> 5 -0.4173718   47 0.6783070     screening                   FALSE
#> 6  0.4387969   47 0.6628193     screening                   FALSE
#>   FormalInferenceEligible PrimaryReportingEligible   ReportingUse
#> 1                   FALSE                    FALSE screening_only
#> 2                   FALSE                    FALSE screening_only
#> 3                   FALSE                    FALSE screening_only
#> 4                   FALSE                    FALSE screening_only
#> 5                   FALSE                    FALSE screening_only
#> 6                   FALSE                    FALSE screening_only
#>                           SEBasis
#> 1 conditional plug-in information
#> 2 conditional plug-in information
#> 3 conditional plug-in information
#> 4 conditional plug-in information
#> 5 conditional plug-in information
#> 6 conditional plug-in information
#>                                                   DFBasis DFUnrounded DFDisplay
#> 1 frequency-weighted observed count minus 1 approximation          47        47
#> 2 frequency-weighted observed count minus 1 approximation          47        47
#> 3 frequency-weighted observed count minus 1 approximation          47        47
#> 4 frequency-weighted observed count minus 1 approximation          47        47
#> 5 frequency-weighted observed count minus 1 approximation          47        47
#> 6 frequency-weighted observed count minus 1 approximation          47        47
#>   StatisticLabel   ProbabilityMetric
#> 1    screening t screening tail area
#> 2    screening t screening tail area
#> 3    screening t screening tail area
#> 4    screening t screening tail area
#> 5    screening t screening tail area
#> 6    screening t screening tail area
#>                                                           ProbabilityReference
#> 1 Two-sided Student t at continuous count-minus-one df; calibration held fixed
#> 2 Two-sided Student t at continuous count-minus-one df; calibration held fixed
#> 3 Two-sided Student t at continuous count-minus-one df; calibration held fixed
#> 4 Two-sided Student t at continuous count-minus-one df; calibration held fixed
#> 5 Two-sided Student t at continuous count-minus-one df; calibration held fixed
#> 6 Two-sided Student t at continuous count-minus-one df; calibration held fixed
#>       ProbabilityStatus
#> 1 available_conditional
#> 2 available_conditional
#> 3 available_conditional
#> 4 available_conditional
#> 5 available_conditional
#> 6 available_conditional
#>                                                                                                     ProbabilityReason
#> 1 The tail conditions on the fitted calibration; count-minus-one is a screening approximation, not a calibrated test.
#> 2 The tail conditions on the fitted calibration; count-minus-one is a screening approximation, not a calibrated test.
#> 3 The tail conditions on the fitted calibration; count-minus-one is a screening approximation, not a calibrated test.
#> 4 The tail conditions on the fitted calibration; count-minus-one is a screening approximation, not a calibrated test.
#> 5 The tail conditions on the fitted calibration; count-minus-one is a screening approximation, not a calibrated test.
#> 6 The tail conditions on the fitted calibration; count-minus-one is a screening approximation, not a calibrated test.
#>       Infit    Outfit ObsN OptimizationStatus OptimizationDetail BiasStatus
#> 1 1.0488661 1.0256516   48                 ok               <NA>   interior
#> 2 0.7948752 0.7876311   48                 ok               <NA>   interior
#> 3 1.0859087 1.0895050   48                 ok               <NA>   interior
#> 4 0.9546214 0.9449286   48                 ok               <NA>   interior
#> 5 0.8723443 0.8524407   48                 ok               <NA>   interior
#> 6 0.9824756 1.2850242   48                 ok               <NA>   interior
#>   ConditionalInformation          ScreenStatus
#> 1               28.79396 available_conditional
#> 2               27.80361 available_conditional
#> 3               28.59645 available_conditional
#> 4               28.78455 available_conditional
#> 5               28.79396 available_conditional
#> 6               26.39301 available_conditional
#>                                                                                   ScreenReason
#> 1 Conditional information uses all cell rows; calibration and Person uncertainty are excluded.
#> 2 Conditional information uses all cell rows; calibration and Person uncertainty are excluded.
#> 3 Conditional information uses all cell rows; calibration and Person uncertainty are excluded.
#> 4 Conditional information uses all cell rows; calibration and Person uncertainty are excluded.
#> 5 Conditional information uses all cell rows; calibration and Person uncertainty are excluded.
#> 6 Conditional information uses all cell rows; calibration and Person uncertainty are excluded.
#>   FitResponseRows FitAvailableRows FitUnavailableRows             FitStatus
#> 1              48               48                  0 available_descriptive
#> 2              48               48                  0 available_descriptive
#> 3              48               48                  0 available_descriptive
#> 4              48               48                  0 available_descriptive
#> 5              48               48                  0 available_descriptive
#> 6              48               48                  0 available_descriptive
#>                                                                              FitReason
#> 1 Descriptive mean squares; their calculation does not establish inferential validity.
#> 2 Descriptive mean squares; their calculation does not establish inferential validity.
#> 3 Descriptive mean squares; their calculation does not establish inferential validity.
#> 4 Descriptive mean squares; their calculation does not establish inferential validity.
#> 5 Descriptive mean squares; their calculation does not establish inferential validity.
#> 6 Descriptive mean squares; their calculation does not establish inferential validity.
#>   InteractionFacets InteractionOrder InteractionMode Facet1 Facet1_Level
#> 1 Rater x Criterion                2        pairwise  Rater          R01
#> 2 Rater x Criterion                2        pairwise  Rater          R01
#> 3 Rater x Criterion                2        pairwise  Rater          R01
#> 4 Rater x Criterion                2        pairwise  Rater          R01
#> 5 Rater x Criterion                2        pairwise  Rater          R02
#> 6 Rater x Criterion                2        pairwise  Rater          R02
#>   Facet1_Index Facet1_Measure  Facet1_SE    Facet2 Facet2_Level Facet2_Index
#> 1            1     -0.1838153 0.08209147 Criterion     Accuracy            1
#> 2            1     -0.1838153 0.08209147 Criterion      Content            2
#> 3            1     -0.1838153 0.08209147 Criterion     Language            3
#> 4            1     -0.1838153 0.08209147 Criterion Organization            4
#> 5            2     -0.3088478 0.08298771 Criterion     Accuracy            1
#> 6            2     -0.3088478 0.08298771 Criterion      Content            2
#>   Facet2_Measure  Facet2_SE FacetA FacetA_Level FacetA_Index FacetA_Measure
#> 1     0.23363879 0.08237044  Rater          R01            1     -0.1838153
#> 2    -0.38997303 0.08384145  Rater          R01            1     -0.1838153
#> 3     0.09146368 0.08172648  Rater          R01            1     -0.1838153
#> 4     0.06487055 0.08167028  Rater          R01            1     -0.1838153
#> 5     0.23363879 0.08237044  Rater          R02            2     -0.3088478
#> 6    -0.38997303 0.08384145  Rater          R02            2     -0.3088478
#>    FacetA_SE    FacetB FacetB_Level FacetB_Index FacetB_Measure  FacetB_SE
#> 1 0.08209147 Criterion     Accuracy            1     0.23363879 0.08237044
#> 2 0.08209147 Criterion      Content            2    -0.38997303 0.08384145
#> 3 0.08209147 Criterion     Language            3     0.09146368 0.08172648
#> 4 0.08209147 Criterion Organization            4     0.06487055 0.08167028
#> 5 0.08298771 Criterion     Accuracy            1     0.23363879 0.08237044
#> 6 0.08298771 Criterion      Content            2    -0.38997303 0.08384145
#>   PointAvailable ScreenAvailable ScreenPositive
#> 1           TRUE            TRUE          FALSE
#> 2           TRUE            TRUE          FALSE
#> 3           TRUE            TRUE          FALSE
#> 4           TRUE            TRUE          FALSE
#> 5           TRUE            TRUE          FALSE
#> 6           TRUE            TRUE          FALSE
```
