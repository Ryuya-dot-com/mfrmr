# Plot displacement diagnostics using base R

Plot displacement diagnostics using base R

## Usage

``` r
plot_displacement(
  x,
  diagnostics = NULL,
  anchored_only = FALSE,
  facets = NULL,
  plot_type = c("lollipop", "hist"),
  top_n = 40,
  show_ci = FALSE,
  ci_level = 0.95,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  or
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
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

  If `TRUE`, draw with base graphics.

- ...:

  Additional arguments passed to
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md)
  when `x` is `mfrm_fit`.

## Value

A plotting-data object of class `mfrm_plot_data`.

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
    [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md).

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## See also

[`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[`plot_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_fair_average.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
p <- plot_displacement(fit, anchored_only = FALSE, draw = FALSE)
if (interactive()) {
  plot_displacement(
    fit,
    anchored_only = FALSE,
    plot_type = "lollipop",
    preset = "publication"
  )
}
}
```
