# Pairwise standardized-residual heatmap for local-dependence review

Builds an N x N heatmap of pairwise standardized residuals between facet
levels, computed from the diagnostics observation table. Cells with
large absolute values flag pairs of facet elements (e.g. two raters, two
items) whose residuals co-move more than the main-effects MFRM expects.
Residuals are averaged within each Person and facet level before
correlation. This is a Q3-style screen, distinct from raw-residual Yen
Q3; no fixed correlation cutoff establishes local independence for this
standardized, aggregated index.

## Usage

``` r
plot_local_dependence_heatmap(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  min_pairs = 5L,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- facet:

  Facet whose levels are placed on both axes (default `"Rater"`).

- min_pairs:

  Minimum number of persons with finite aggregated residuals at both
  levels; an integer of at least three. Unavailable pairs remain in the
  table with their overlap count and reason, and appear as `NA` in the
  matrix.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p)` bundles the symmetric
residual `matrix`, one row per unordered pair in `pairs`, and the
minimum overlap `min_pairs`. Interpretation notes are available through
`plot_data(p, "notes")`. Save the complete payload with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html);
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
converts its saved matrix without recalculating residuals.

## Details

This helper complements [plot(x, type =
"marginal_pairwise")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md):
the marginal version uses posterior-integrated agreement residuals on a
top-N pair list, while this view shows every pair on a shared color
scale so an analyst can scan for diagonal blocks or hotspots.

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

[plot(x, type =
"marginal_pairwise")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_local_dependence_heatmap", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "local_dependence", draw = FALSE)
dim(plot_data(p, "matrix"))
# Inspect large absolute correlations alongside shared-person counts.
# Unavailable pairs are not evidence of local independence.
} # }
```
