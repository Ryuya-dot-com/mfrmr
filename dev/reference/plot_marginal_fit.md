# Plot strict marginal-fit follow-up cells with ggplot2

Plot strict marginal-fit follow-up cells with ggplot2

## Usage

``` r
plot_marginal_fit(
  x,
  diagnostics = NULL,
  plot_type = c("std_residual", "prop_diff"),
  top_n = 20,
  facet = NULL,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  title = NULL
)
```

## Arguments

- x :

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).

- diagnostics :

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- plot_type :

  `"std_residual"` or `"prop_diff"`.

- top_n :

  Maximum cells shown.

- facet :

  Optional facet name used to keep only matching facet-level rows. When
  `NULL`, the plot uses the mixed top-cell table returned by the strict
  marginal screen.

- main :

  Compatibility title argument. Omitted or `NULL` keeps the default
  title. Existing calls remain supported without a deprecation warning.
  For new code, prefer `title`; do not supply both arguments.

- palette :

  Optional named color overrides. Recognized names: `positive`,
  `negative`, `flag`.

- label_angle :

  X-axis label angle.

- preset :

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw :

  If `TRUE`, print the `ggplot` object.

- title :

  Plot title. Omit it to keep the default, supply one character string
  to replace it, or use `NULL` (or `""`) to suppress it. This changes
  only the heading; numerical results, reference lines, subtitles and
  interpretation notes remain. Both `main` and `title` explicitly
  supplied is an error, even if equal or `NULL`. Positional legacy
  arguments retain their order; use the exact name `title`.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
to retrieve its reusable plotting data and notes.

## Details

This helper visualizes the largest first-order strict marginal-fit cells
from `diagnose_mfrm(..., diagnostic_mode = "both")` or
`diagnostic_mode = "marginal_fit"`.

The `"std_residual"` view ranks cells by the absolute standardized
residual from posterior-integrated expected category counts. The
`"prop_diff"` view ranks cells by the absolute observed-minus-expected
proportion gap and plots their signed gaps. Both views apply the facet
filter before ranking all cells. The returned `full_table` retains all
candidate rows; `retention` records available/unavailable values for the
selected metric. Undefined values are not zero residuals, and grey
bars/labels indicate unavailable values or flags.

Use this plot after `summary(diagnostics)` indicates strict marginal
flags. The display is exploratory: it highlights which facet/category
cells deserve follow-up, but it is not a standalone inferential test.

## Interpreting output

- Positive bars mean the observed category usage exceeded the posterior-
  expected marginal usage for that cell.

- Negative bars mean the observed usage fell below the
  posterior-expected marginal usage.

- Red bars indicate the current strict marginal warning rule was
  triggered by `|StdResidual| >= abs_z_warn`.

## Typical workflow

1.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
    using `method = "MML"` for `RSM` / `PCM`.

2.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
    with `diagnostic_mode = "both"`.

3.  Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html) to
    inspect the largest strict marginal cells.

4.  Follow up with
    [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rating_scale_table.md)
    or substantive design review.

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

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/rating_scale_table.md),
[plot(x, type =
"marginal_pairwise")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Use the diagnostics saved with this fit
diagnostics <- example_fit$diagnostics

# Which score categories occur more or less often than the model expects?
plot(diagnostics, type = "marginal_fit")

# Positive bars: more frequent than expected; negative bars: less frequent

# Optional: show observed-minus-expected proportions instead
# Run this command separately to inspect the second figure
plot(diagnostics, type = "marginal_fit", view = "prop_diff")
```
