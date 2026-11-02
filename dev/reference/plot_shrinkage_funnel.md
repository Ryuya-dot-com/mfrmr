# Empirical-Bayes shrinkage funnel / caterpillar

Visualizes empirical-Bayes shrinkage by drawing one row per facet level
with the raw (pre-shrinkage) and shrunken estimates plus the shrinkage
factor. Rows are ordered by absolute shrinkage so the levels that move
most under the prior appear at the top.

## Usage

``` r
plot_shrinkage_funnel(
  fit,
  facet = NULL,
  top_n = 30L,
  preset = c("standard", "publication", "compact", "monochrome"),
  show_ci = FALSE,
  ci_level = 0.95,
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` augmented with empirical-Bayes shrinkage.

- facet:

  Facet to draw (default: first non-person facet with shrinkage columns
  present).

- top_n:

  Maximum number of rows to draw (default 30).

- preset:

  Visual preset.

- show_ci:

  Logical. When `TRUE`, draw descriptive normal bands from raw and
  plug-in shrunken SEs. These omit prior-variance uncertainty and
  cross-level covariance; zero width after full pooling is not perfect
  precision.

- ci_level:

  Nominal normal-band level when `show_ci = TRUE`; default 0.95. This
  does not assert repeated-sampling coverage.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p, "table")` is the long
`Level`, `RawEstimate`, `ShrunkEstimate`, `ShrinkageFactor` table. When
`show_ci = TRUE`, the table also includes `RawCI_Lower`, `RawCI_Upper`,
`ShrunkCI_Lower`, `ShrunkCI_Upper`, and `CI_Level`.

## Details

Requires a fit produced via
[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apply_empirical_bayes_shrinkage.md)
or a `fit_mfrm(..., facet_shrinkage = "empirical_bayes")` run, so that
`fit$facets$others` carries `Estimate`, `ShrunkEstimate`, and
`ShrinkageFactor` columns.

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

[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/apply_empirical_bayes_shrinkage.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_shrinkage_funnel", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
fit_eb <- apply_empirical_bayes_shrinkage(fit)
p <- plot(fit_eb, type = "shrinkage", view = "funnel", draw = FALSE)
head(plot_data(p, "table"))
# Look for: short segments (Raw and Shrunken close together) =
#   little pooling. Long segments fanning toward the centre = the
#   prior pulled the estimate strongly; this is most pronounced for
#   small-N levels. ShrinkageFactor near 1 means most of the
#   movement was driven by the prior rather than the data.
} # }
```
