# Convert draw-free mfrmr plot data to ggplot2

`as_ggplot()` is an optional renderer for an `mfrm_plot_data` object or
an object whose [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method supports `draw = FALSE`. Base graphics remain the default; the
returned `ggplot` can be restyled or composed downstream.

## Usage

``` r
as_ggplot(x, type = NULL, component = NULL, ...)

# Default S3 method
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_design_evaluation'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_design_evaluation_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_signal_detection'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_signal_detection_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_plot_data'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_slope_intervals'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_curve_intervals'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_gpcm_bootstrap'
as_ggplot(x, type = NULL, component = NULL, ...)

# S3 method for class 'mfrm_results'
as_ggplot(x, type = NULL, component = NULL, ...)
```

## Arguments

- x:

  An `mfrm_plot_data` object, or an mfrmr object with a draw-free plot
  method.

- type:

  Optional plot type passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for a
  non-plot-data input.

- component:

  Optional tabular payload component to convert.

- ...:

  Arguments passed to the draw-free plot method. CCC conversion
  additionally accepts `slope_aes`, `facet_by`, and `show_overlay`.

## Value

A `ggplot2` plot object, with a `mfrmr_notes` attribute when the source
plot payload contains a `notes` table. Paired Wright/CCC payloads from
[`plot_compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_compare_mfrm.md)
retain their selected comparison or difference view, group selection and
monochrome panel policy.

## Details

Dedicated conversions are provided for Wright maps,
theta-to-expected-score pathways, fit-statistic-to-measure pathways,
category characteristic curves, bubble charts, DIF/DFF summaries and
heatmaps, portable-calibration score review plots, testlet calibration,
shared-rater severity and bootstrap intervals, conditional Person
scores, and multivariate D-study comparisons. Matched ordinary/extended
facet comparisons preserve centered effects, paired/difference views,
excluded rows, display controls and alternative text; see
[`plot.mfrm_extended_comparison()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_extended_comparison.md).
Threshold-sensitivity tile and curve payloads also preserve their
selected view, display controls and text alternatives; see
[`plot.mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_screening_sensitivity.md).
Posterior predictive residual displays preserve their descriptive
meaning and lack of reference cutoffs; see
[`plot.mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_response_diagnostics.md).
Testlet conversions retain unavailable rows, prior-only symbols and the
conditional-interval note; they do not estimate diagnostics or add
calibration uncertainty. Extended-model interval, precision and
empirical-distribution views preserve display settings, data exclusions
and text alternatives; see
[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet_scores.md).
Bootstrap conversion retains infinite endpoints as arrows and ordinary
intervals as a dashed comparison. D-study conversions preserve G/Phi or
SEM panels, fixed-count groups, score units, and unavailable estimates.
They do not refit the model or add confidence intervals. For
multivariate D-study plots, an explicit `component = "series"` keeps
this dedicated conversion; use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for other tables. Difference-interval plots from
[`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md)
use their base [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method or
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md);
automatic conversion is not supported. Automatic conversion of
exploratory clustering plots is not supported. Use their
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods for
silhouettes, feature profiles, dendrograms and imputation co-membership
heatmaps, or
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics. For main-effects `mfrm_d_study` results, use the
base [`plot()`](https://rdrr.io/r/graphics/plot.default.html) method or
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics; automatic conversion is refused because generic
column selection does not preserve those design comparisons. Selecting
`component` does not enable unsupported conversions: it cannot preserve
PCA axes, clustering membership, MI intervals or D-study differences
through generic column selection. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to extract the table and specify the axes, intervals and grouping
explicitly in custom graphics. Other draw-free payloads use a
conservative tabular fallback; inspect
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
when automatic inference is not appropriate. Titles, subtitles, and
captions are wrapped at 72 text columns for ordinary figure widths;
missing text is omitted. For narrower exports or custom line breaks,
override these labels with
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
on the returned plot. Fit plots created with `show_title = FALSE` or
`show_notes = FALSE` retain those settings on conversion. To set them
when converting a fit directly, pass the flags through `...`.
Interpretation and display notes remain available in
`attr(plot, "mfrmr_notes")`, when present in the source payload. Wright,
pathway, and CCC conversions share the fit-family series palette, honour
monochrome presets and supplied palette overrides, and preserve
line-type or point-shape distinctions. CCC categories retain their
source order. When `slope_aes = "colour"`, slopes instead use a
continuous viridis scale (a grey gradient in monochrome); categories
still have line types.

Fixed-facet RSM/PCM intervals retain the selected covariance method,
level, status symbols and optional ordinary comparison. Titles,
subtitles, captions, reference lines and legends can be changed through
the source plot arguments. Methods use both line types and vertical
offsets, including in monochrome.

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
# A balanced slice retains every Rater and Criterion while running quickly.
toy <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
fit <- fit_mfrm(toy, "Person",
                c("Rater", "Criterion"), "Score", maxit = 30)
as_ggplot(fit, type = "wright")

as_ggplot(fit, type = "fit_pathway", include_person = TRUE)

as_ggplot(plot(fit, type = "ccc", draw = FALSE))

# }
```
