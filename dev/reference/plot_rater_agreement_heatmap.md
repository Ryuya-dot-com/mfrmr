# Pairwise rater-agreement heatmap

Summarizes inter-rater agreement as a symmetric rater x rater heatmap.
Cells are coloured by the chosen agreement metric: exact agreement
proportion by default, or the Pearson-style `Corr` column from
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md)
when `metric = "correlation"`. The plot is a compact alternative to
[plot(x, type =
"agreement")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)'s
bar chart when the rater count exceeds ~6 pairs.

## Usage

``` r
plot_rater_agreement_heatmap(
  fit,
  diagnostics = NULL,
  rater_facet = "Rater",
  metric = c("exact", "correlation"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit`.

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  output; piped through to
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md)
  when supplied.

- rater_facet:

  Name of the rater facet (default `"Rater"`).

- metric:

  Column to colour by: `"exact"` (default) or `"correlation"`.
  Quadratic-weighted kappa is not currently computed by
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md)
  and is therefore not offered here.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p)` bundles the rater x rater
matrix, raw pairwise rows, matching settings and palette.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/as_ggplot.md)
preserves the selected metric, facet labels and unavailable cells, with
a fixed 0–1 exact-agreement or -1–1 correlation scale. The
`"monochrome"` preset applies to both renderers. Self comparisons are
unavailable, not estimated perfect agreement. Save the plot payload with
[`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) to convert it
without recomputing diagnostics; interpretation notes remain in
`plot_data(p, "notes")`.

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

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/interrater_agreement_table.md)
for the underlying numeric table; [plot(x, type =
"guttman")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
for a complementary person-by-element view of residual structure;
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
for the diagnostics bundle the heatmap reads from.

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_rater_agreement_heatmap", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "agreement", view = "heatmap", draw = FALSE)
dim(plot_data(p, "matrix"))
# Look for (default `metric = "exact"`):
# - Off-diagonal cells close to the corresponding entry of
#   `summary(diag)$interrater$ExactAgreement` indicate consistent
#   pair behaviour; cells well below the average mark a pair
#   that disagrees more than the rest.
# - With `metric = "correlation"` the colour scale switches to
#   `[-1, 1]`; positive cells = pairs agree on relative ordering,
#   negative cells = pairs systematically rank persons in opposite
#   directions. Review context, exposure and sample size before deciding
#   whether any rater needs follow-up.
} # }
```
