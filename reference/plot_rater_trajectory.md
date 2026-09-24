# Rater-severity trajectory across an ordered wave / occasion variable

Plots each rater's severity estimate across a user-supplied ordering
variable (e.g. `Session`, `Wave`, `AdminDate`), producing one line per
rater. When the ordering column is time-like (numeric or date), the
x-axis is drawn on that scale; otherwise the values are rendered as
discrete ordered categories. Useful for rater training / drift feedback
loops.

## Usage

``` r
plot_rater_trajectory(
  fits,
  facet = "Rater",
  ci_level = 0.95,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fits:

  A named list of `mfrm_fit` objects, one per wave. Names become the
  x-axis labels in their supplied order. Fits are assumed to have been
  placed on a common scale via anchor-linking or an equivalent post-hoc
  transformation (see the caveat above).

- facet:

  Facet whose levels are tracked (default `"Rater"`).

- ci_level:

  Confidence level for the per-wave CI ribbons drawn around each
  trajectory (default `0.95`).

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object whose `data` slot is a long data.frame with
`Wave`, `Level`, `Estimate`, `SE`, `CI_Lower`, `CI_Upper` columns.

## Anchor-linking caveat

Each wave is fit independently under its own sum-to-zero identification,
so the per-wave severity logits live on separate scales unless you
actively link them. Before interpreting movement across waves as rater
drift, link the waves by either (i) holding common anchors fixed across
fits (see
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)
for the supported linking route), or (ii) harmonizing the scale post-hoc
with a Stocking-Lord type transformation and reviewing the result via
[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md).
The trajectory plot itself does not perform linking; it only visualizes
the supplied fits on their as-fit scales.

## See also

[`plot_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_anchor_drift.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit_a <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                  method = "JML", maxit = 300)
fit_b <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                  method = "JML", maxit = 300)
p <- plot_rater_trajectory(list(T1 = fit_a, T2 = fit_b), draw = FALSE)
head(p$data$data)
#>      Wave Level   Estimate         SE      CI_Lower     CI_Upper
#> T1.1   T1   R01 -0.1957463 0.09729871 -0.3864482600 -0.005044321
#> T2.1   T2   R01 -0.1957463 0.09729871 -0.3864482600 -0.005044321
#> T1.2   T1   R02 -0.3287812 0.09769555 -0.5202609108 -0.137301394
#> T2.2   T2   R02 -0.3287812 0.09769555 -0.5202609108 -0.137301394
#> T1.3   T1   R03  0.1910898 0.09724038  0.0005021609  0.381677427
#> T2.3   T2   R03  0.1910898 0.09724038  0.0005021609  0.381677427
# Look for: stable trajectories (small wave-to-wave shifts within
#   each rater's CI ribbon) once the waves are anchor-linked. A
#   rater whose line drifts >0.5 logits across waves is the typical
#   "calibration drift" signal. Without anchor linking the per-wave
#   logits are on different scales and the picture cannot be read
#   as drift; see the Anchor-linking caveat in the docstring.
# }
```
