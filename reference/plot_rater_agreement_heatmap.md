# Pairwise rater-agreement heatmap

Summarizes inter-rater agreement as a symmetric rater x rater heatmap.
Cells are coloured by the chosen agreement metric: exact agreement
proportion by default, or the Pearson-style `Corr` column from
[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
when `metric = "correlation"`. The plot is a compact alternative to
[`plot_interrater_agreement()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_interrater_agreement.md)'s
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
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output; piped through to
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  when supplied.

- rater_facet:

  Name of the rater facet (default `"Rater"`).

- metric:

  Column to colour by: `"exact"` (default) or `"correlation"`.
  Quadratic-weighted kappa is not currently computed by
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
  and is therefore not offered here.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object whose `data` slot bundles the rater x rater
matrix and the raw pairwise rows.

## See also

[`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md)
for the underlying numeric table;
[`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md)
for a complementary person-by-element view of residual structure;
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
for the diagnostics bundle the heatmap reads from.

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_rater_agreement_heatmap(fit, draw = FALSE)
dim(p$data$matrix)
# Look for (default `metric = "exact"`):
# - Off-diagonal cells close to the corresponding entry of
#   `summary(diag)$interrater$ExactAgreement` indicate consistent
#   pair behaviour; cells well below the average mark a pair
#   that disagrees more than the rest.
# - With `metric = "correlation"` the colour scale switches to
#   `[-1, 1]`; positive cells = pairs agree on relative ordering,
#   negative cells = pairs systematically rank persons in opposite
#   directions and are the highest-priority review cases.
}
```
