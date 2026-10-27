# Plot saved bias-interaction results

Inspect the pattern of conditional interaction estimates from
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).
Start with ranked interactions, then use other views to understand the
pattern.

## Usage

``` r
# S3 method for class 'mfrm_bias'
plot(
  x,
  type = c("scatter", "ranked", "heatmap", "abs_t_hist", "facet_profile"),
  ...
)
```

## Arguments

- x:

  A result from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- type:

  `"scatter"`, `"ranked"`, `"heatmap"`, `"abs_t_hist"`, or
  `"facet_profile"`.

- ...:

  Named controls below. `draw = FALSE` returns the plot data without
  drawing. Controls do not change the fitted calibration.

## Value

An `mfrm_plot_data` object with view-specific tables, retained screening
rules and interpretation notes. Plot agreement across views is not
independent evidence of bias. Use `print(p)` or `plot_data(p, "notes")`
for the interaction definition, score-direction caveat, magnitude-only
facet-profile interpretation and conditional uncertainty qualifications
outside the figure.

## Details

Visualization front-end for
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
with multiple views. With `draw = FALSE`, the returned plot data include
`plot_long`, `plot_annotations`, `flag_summary`, and `plot_settings` in
addition to the view-specific `ranked_table`, `scatter_data`,
`facet_profile`, and heatmap components. Use these fields when
rebuilding the same screening view in ggplot2, plotly, Quarto, or a
dashboard. Saved report thresholds determine flags, reference lines and
returned notes; recreate
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md)
from the saved bias object to change them. Scatter and ranked views
support
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md);
the other views require their base renderer or custom graphics.
Conditional bounds and their status remain separate from
calibration-inclusive uncertainty.

## Controls

- `facet_a`, `facet_b`, or `interaction_facets` identify the
  interaction; `top_n = 40` and `sort_by = "abs_t"` (`"abs_bias"` or
  `"prob"` also accepted) select ranked interactions.

- `abs_t_warn = 2`, `abs_bias_warn = 0.5`, and `p_max = 0.05` set
  screening rules when preparing a report from the bias result. They are
  review aids, not guarantees of a calibrated error rate.

- `show_ci = FALSE` omits whiskers; `ci_level = 0.95` chooses their
  level for scatter/ranked views. GPCM rows retain conditional profile
  bounds, with dashed whiskers for search-limited or unverified bounds.
  Other rows use conditional per-cell SEs. Missing profile bounds are
  not replaced with another method. These intervals omit calibration
  uncertainty; endpoint completion is not evidence of coverage.

- `preset` selects `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`; `palette` overrides named colors (`normal`, `flag`,
  `hist`, `profile`); `label_angle` controls label rotation. `title`
  sets title metadata (`main` is a compatibility alias; supply only
  one).

## Plot types

- `"scatter"` (default):

  Observed-minus-expected score average (x) versus conditional bias size
  in logits (y). Points use the saved flag status; horizontal guides
  show the saved absolute-bias threshold and zero, with a vertical guide
  at zero score difference.

- `"ranked"`:

  Conditional bias size (x) for up to `top_n` saved ranked interactions
  (y). Points are colored by flag status; optional whiskers retain the
  conditional uncertainty and incomplete-bound status. A saved report
  retains the ranking chosen when it was constructed.

- `"heatmap"`:

  Facet A by facet B matrix of signed bias size. Cells retain reusable
  matrix and flag tables for dashboards. This is a Table 13 follow-up
  display: it supports pattern recognition but does not turn screening
  rows into confirmatory tests.

- `"abs_t_hist"`:

  Histogram of absolute screening t-statistics across all interaction
  cells. Dashed reference line at `abs_t_warn`. Use for assessing the
  overall distribution of interaction effect sizes.

- `"facet_profile"`:

  Per-facet-level aggregation showing mean absolute bias and flag rate.
  Useful for identifying which individual facet levels drive systematic
  interaction patterns.

## Interpreting output

Start with `"scatter"` or `"ranked"` for triage, then confirm pattern
shape using `"abs_t_hist"` and `"facet_profile"`.

These views reuse the same estimates and flags. Agreement between views
is not independent corroborating evidence of bias. Review exposure,
calibration uncertainty and substantive explanations before drawing
conclusions about a rater.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`bias_interaction_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/bias_interaction_report.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_bias.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "bias-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
diagnostics <- example_fit$diagnostics
bias <- estimate_bias(fit, diagnostics = diagnostics,
  facet_a = "Rater", facet_b = "Criterion")
p <- plot(bias, type = "ranked", preset = "publication", draw = FALSE)
head(plot_data(p, "ranked_table"))
#>           InteractionFacets InteractionOrder InteractionMode FacetA    FacetB
#> Facet1.12 Rater x Criterion                2        pairwise  Rater Criterion
#> Facet1    Rater x Criterion                2        pairwise  Rater Criterion
#> Facet1.15 Rater x Criterion                2        pairwise  Rater Criterion
#> Facet1.3  Rater x Criterion                2        pairwise  Rater Criterion
#> Facet1.11 Rater x Criterion                2        pairwise  Rater Criterion
#> Facet1.1  Rater x Criterion                2        pairwise  Rater Criterion
#>           Level1       Level2 ObsExpAverage   BiasSize        SE          t
#> Facet1.12    R04     Accuracy    -0.4689232 -1.1021401 0.3329693 -3.3100348
#> Facet1       R01     Accuracy     0.3709018  0.7770299 0.3082115  2.5210933
#> Facet1.15    R04 Organization     0.3263647  0.6831918 0.2995061  2.2810613
#> Facet1.3     R01 Organization    -0.1692308 -0.3620943 0.2932037 -1.2349582
#> Facet1.11    R03 Organization    -0.1462019 -0.3130757 0.2957046 -1.0587450
#> Facet1.1     R01      Content    -0.1231041 -0.2773740 0.3012434 -0.9207637
#>                  Prob ObservedCount LRChiSq LRDF LRProb ProfileCILower
#> Facet1.12 0.003055479            24      NA   NA     NA             NA
#> Facet1    0.019083764            24      NA   NA     NA             NA
#> Facet1.15 0.032129533            24      NA   NA     NA             NA
#> Facet1.3  0.229313837            24      NA   NA     NA             NA
#> Facet1.11 0.300709046            24      NA   NA     NA             NA
#> Facet1.1  0.366731299            24      NA   NA     NA             NA
#>           ProfileCIUpper ProfileCILevel ProfileCIStatus LikelihoodBasis
#> Facet1.12             NA             NA            <NA>            <NA>
#> Facet1                NA             NA            <NA>            <NA>
#> Facet1.15             NA             NA            <NA>            <NA>
#> Facet1.3              NA             NA            <NA>            <NA>
#> Facet1.11             NA             NA            <NA>            <NA>
#> Facet1.1              NA             NA            <NA>            <NA>
#>                         Pair      AbsT   AbsBias TFlag BiasFlag PFlag  Flag
#> Facet1.12     R04 | Accuracy 3.3100348 1.1021401  TRUE     TRUE  TRUE  TRUE
#> Facet1        R01 | Accuracy 2.5210933 0.7770299  TRUE     TRUE  TRUE  TRUE
#> Facet1.15 R04 | Organization 2.2810613 0.6831918  TRUE     TRUE  TRUE  TRUE
#> Facet1.3  R01 | Organization 1.2349582 0.3620943 FALSE    FALSE FALSE FALSE
#> Facet1.11 R03 | Organization 1.0587450 0.3130757 FALSE    FALSE FALSE FALSE
#> Facet1.1       R01 | Content 0.9207637 0.2773740 FALSE    FALSE FALSE FALSE
#>           Facet1 Facet1_Level    Facet2 Facet2_Level FacetA_Level FacetB_Level
#> Facet1.12  Rater          R04 Criterion     Accuracy          R04     Accuracy
#> Facet1     Rater          R01 Criterion     Accuracy          R01     Accuracy
#> Facet1.15  Rater          R04 Criterion Organization          R04 Organization
#> Facet1.3   Rater          R01 Criterion Organization          R01 Organization
#> Facet1.11  Rater          R03 Criterion Organization          R03 Organization
#> Facet1.1   Rater          R01 Criterion      Content          R01      Content
```
