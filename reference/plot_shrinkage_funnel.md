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

  Logical. When `TRUE`, draw approximate confidence-interval whiskers
  for raw and shrunken estimates when `SE` / `ShrunkSE` evidence is
  available.

- ci_level:

  Confidence level used when `show_ci = TRUE`; default 0.95.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` whose `data` slot bundles the long `Level`,
`RawEstimate`, `ShrunkEstimate`, `ShrinkageFactor` table. When
`show_ci = TRUE`, the table also includes `RawCI_Lower`, `RawCI_Upper`,
`ShrunkCI_Lower`, `ShrunkCI_Upper`, and `CI_Level`.

## Details

Requires a fit produced via
[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)
or a `fit_mfrm(..., facet_shrinkage = "empirical_bayes")` run, so that
`fit$facets$others` carries `Estimate`, `ShrunkEstimate`, and
`ShrinkageFactor` columns.

## See also

[`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
fit_eb <- apply_empirical_bayes_shrinkage(fit)
p <- plot_shrinkage_funnel(fit_eb, draw = FALSE)
head(p$data$table)
# Look for: short segments (Raw and Shrunken close together) =
#   little pooling. Long segments fanning toward the centre = the
#   prior pulled the estimate strongly; this is most pronounced for
#   small-N levels. ShrinkageFactor near 1 means most of the
#   movement was driven by the prior rather than the data.
}
```
