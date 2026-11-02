# Plot displacement diagnostics with ggplot2

Plot displacement diagnostics with ggplot2

## Usage

``` r
plot_displacement(
  x,
  diagnostics = NULL,
  anchored_only = FALSE,
  facets = NULL,
  plot_type = c("lollipop", "hist", "scatter"),
  top_n = 40,
  show_ci = FALSE,
  ci_level = 0.95,
  preset = c("standard", "publication", "compact", "monochrome"),
  marginal = c("auto", "histogram", "none"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/displacement_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- anchored_only:

  Keep only anchored/group-anchored levels.

- facets:

  Optional subset of facets.

- plot_type:

  `"lollipop"` or `"hist"`.

- top_n:

  Maximum levels shown in `"lollipop"` mode.

- show_ci:

  Logical. When `TRUE` and `plot_type = "lollipop"`, draw approximate
  confidence-interval whiskers from `DisplacementSE` (ignored for
  `"hist"`).

- ci_level:

  Confidence level used when `show_ci = TRUE`; default `0.95`. The
  returned plot-data object gains `CI_Lower` / `CI_Upper` / `CI_Level`
  columns on the `table` element for downstream reuse.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, print the `ggplot` object.

- ...:

  Additional arguments passed to
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/displacement_table.md)
  when `x` is `mfrm_fit`.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to retrieve its reusable plotting data and notes.

## Details

**Displacement** quantifies how much a single element's calibration
would shift the overall model if it were allowed to move freely. It is
computed as:

\$\$\mathrm{Displacement}\_j = \frac{\sum_i (X\_{ij} - E\_{ij})} {\sum_i
\mathrm{Var}\_{ij}}\$\$

where the sums run over all observations involving element \\j\\. The
standard error is \\1 / \sqrt{\sum_i \mathrm{Var}\_{ij}}\\, and a
t-statistic \\t = \mathrm{Displacement} / \mathrm{SE}\\ flags elements
whose observed residual pattern is inconsistent with the current anchor
structure.

Displacement is most informative after anchoring: large values suggest
that anchored values may be drifting from the current sample. For
non-anchored analyses, displacement reflects residual calibration
tension.

## Plot types

- `"lollipop"` (default):

  Dot-and-line chart of displacement values. X-axis: displacement
  (logits). Y-axis: element labels. Points colored red when flagged
  (default: \\\|\mathrm{Disp.}\| \> 0.5\\ logits). Dashed lines at
  \\\pm\\ threshold. Ordered by absolute displacement.

- `"hist"`:

  Histogram of displacement values with Freedman-Diaconis breaks. Dashed
  reference lines at \\\pm\\ threshold. Use for inspecting the overall
  distribution shape.

## Interpreting output

Lollipop: top absolute displacement levels; flagged points indicate
larger movement from anchor expectations.

Histogram: overall displacement distribution and threshold lines. A
symmetric distribution centred near zero indicates good anchor
stability; heavy tails or skew suggest systematic drift.

Use `anchored_only = TRUE` when your main question is anchor robustness.

## Typical workflow

1.  Run with `plot_type = "lollipop"` and `anchored_only = TRUE`.

2.  Inspect distribution with `plot_type = "hist"`.

3.  Drill into flagged rows via
    [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/displacement_table.md).

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-visual-diagnostics.md).

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

[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/displacement_table.md),
[plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"fair_average")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_displacement", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "displacement", anchored_only = FALSE, draw = FALSE)
if (interactive()) {
  plot(fit, type = "displacement", anchored_only = FALSE, view = "lollipop", preset = "publication")
}
} # }
```
