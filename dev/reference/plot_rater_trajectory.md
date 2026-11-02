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

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p, "data")` is a long
data.frame with `Wave`, `Level`, `Estimate`, `SE`, `CI_Lower`,
`CI_Upper` columns.

## Anchor-linking caveat

Each wave is fit independently under its own sum-to-zero identification,
so the per-wave severity logits live on separate scales unless you
actively link them. Before interpreting movement across waves as rater
drift, link the waves by either (i) holding common anchors fixed across
fits (see
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_linking_and_dff.md)
for the supported linking route), or (ii) harmonizing the scale post-hoc
with a Stocking-Lord type transformation and reviewing the result via
[plot(x)](https://ryuya-dot-com.github.io/mfrmr/dev/reference/detect_anchor_drift.md).
The trajectory plot itself does not perform linking; it only visualizes
the supplied fits on their as-fit scales.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[plot(x)](https://ryuya-dot-com.github.io/mfrmr/dev/reference/detect_anchor_drift.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_linking_and_dff.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot_rater_trajectory", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit_a <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                  method = "JML", maxit = 300)
fit_b <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                  method = "JML", maxit = 300)
p <- plot(fit_a, type = "trajectory", comparison = list(T2 = fit_b),
  labels = c("T1", "T2"), draw = FALSE)
head(plot_data(p, "data"))
# Look for: stable trajectories (small wave-to-wave shifts within
#   each rater's CI ribbon) once the waves are anchor-linked. A
#   rater whose line drifts >0.5 logits across waves is the typical
#   "calibration drift" signal. Without anchor linking the per-wave
#   logits are on different scales and the picture cannot be read
#   as drift; see the Anchor-linking caveat in the docstring.
} # }
```
