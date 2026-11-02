# Plot inter-rater agreement diagnostics with ggplot2

Plot inter-rater agreement diagnostics with ggplot2

## Usage

``` r
plot_interrater_agreement(
  x,
  diagnostics = NULL,
  rater_facet = NULL,
  context_facets = NULL,
  exact_warn = 0.5,
  corr_warn = 0.3,
  plot_type = c("exact", "corr", "difference"),
  top_n = 20,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  title = NULL
)
```

## Arguments

- x:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  or
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  when `x` is `mfrm_fit`.

- rater_facet:

  Name of the rater facet when `x` is `mfrm_fit`.

- context_facets:

  Optional context facets when `x` is `mfrm_fit`.

- exact_warn:

  Warning threshold for exact agreement when `x` is a fit. Saved
  agreement results use their own thresholds; conflicting overrides are
  rejected. Recreate the agreement result to change its flag rules.

- corr_warn:

  Warning threshold for pairwise correlation when `x` is a fit. Saved
  agreement results use their own threshold.

- plot_type:

  `"exact"`, `"corr"`, or `"difference"`.

- top_n:

  Maximum pairs displayed for bar-style plots.

- main:

  Compatibility title argument. Omitted or `NULL` keeps the default
  title. Existing calls remain supported without a deprecation warning.
  For new code, prefer `title`; do not supply both arguments.

- palette:

  Optional named color overrides (`ok`, `flag`, `expected`).

- label_angle:

  X-axis label angle for bar-style plots.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, print the `ggplot` object.

- title:

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
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
preserves the selected metric, pair order, model-expected values,
unavailable comparisons and saved review thresholds. Notes remain in
`plot_data(p, "notes")`, outside the default figure. `top_n` limits the
two bar views; the difference view uses all pairs in the input bundle.

## Details

Inter-rater agreement plots describe matched scores for a chosen rater
facet. The default matches Person and all other non-rater facets; custom
`context_facets` change the comparison unit. Inspect the saved settings
before interpreting agreement. Repeated ratings within a rater/context
cell are averaged as described in
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md).

**Exact agreement** is the proportion of matched observations where both
raters assigned the same category score. The **expected agreement** line
shows the proportion expected under the fitted model, averaging products
of category probabilities over matched rating contexts. It is a
model-based baseline, not a chance-corrected agreement coefficient.

**Pairwise correlation** is the Pearson correlation between scores
assigned by each rater pair on matched observations.

The **difference plot** describes directional score differences (mean
signed difference on x-axis: positive = Rater 1 assigned higher scores)
and total inconsistency (mean absolute difference on y-axis). Points
near the origin indicate both small mean differences and low
inconsistency.

The `context_facets` parameter specifies which facets define "the same
rating target" (e.g., Criterion). When `NULL`, all non-rater facets are
used as context.

## Plot types

- `"exact"` (default):

  Bar chart of exact agreement proportion by rater pair. Expected
  agreement overlaid as connected circles. Horizontal reference line at
  the saved `exact_warn`. Bar colors follow the combined
  exact/correlation flag, not only the displayed metric.

- `"corr"`:

  Bar chart of pairwise Pearson correlation by rater pair. Reference
  line at `corr_warn`. Ordered by correlation (lowest first). Low
  correlations suggest inconsistent rank ordering of persons between
  raters.

- `"difference"`:

  Scatter plot. X-axis: mean signed score difference (Rater 1 \\-\\
  Rater 2); positive values indicate Rater 1 assigned higher scores.
  This observed-score contrast is distinct from the fitted
  rater-severity parameter. Y-axis: mean absolute difference (overall
  disagreement magnitude). Points colored red when flagged. Vertical
  reference at 0.

## Interpreting output

Colors retain the saved combined flag: either known cutoff crossing
flags a pair; an incomplete decision is neutral. These are descriptive
review rules, not automatic rater-quality or training-priority
decisions. On the difference plot, points far from the origin along the
x-axis indicate directional score differences; points high on the y-axis
indicate large inconsistency regardless of direction.

## Typical workflow

1.  Select rater facet and run `"exact"` view.

2.  Confirm with `"corr"` view.

3.  Use `"difference"` to inspect directional disagreement.

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

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md),
[plot(x, type =
"facets_chisq")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot_interrater_agreement", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

# Compare observed exact agreement with its model-expected baseline
plot(fit, type = "agreement", rater_facet = "Rater")
# Bars show observed agreement; connected circles show model-expected agreement

# Optional: compare the direction and magnitude of observed-score differences
plot(fit, type = "agreement", rater_facet = "Rater", metric = "difference")
# Positive horizontal values mean Rater1 assigned higher scores than Rater2
} # }
```
