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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
fit_eb <- apply_empirical_bayes_shrinkage(fit)
p <- plot_shrinkage_funnel(fit_eb, draw = FALSE)
head(p$data$table)
#>   Facet Level RawEstimate         SE ShrunkEstimate   ShrunkSE ShrinkageFactor
#> 2 Rater   R02  -0.3287963 0.09769808     -0.2861443 0.09114128       0.1297216
#> 3 Rater   R01  -0.1957561 0.09730123     -0.1705417 0.09081883       0.1288054
#> 4 Rater   R03   0.1910876 0.09724282      0.1665002 0.09077133       0.1286707
#> 1 Rater   R04   0.3334649 0.09763161      0.2902585 0.09108731       0.1295680
#>      Movement RowOrder
#> 2  0.04265200        1
#> 3  0.02521444        2
#> 4 -0.02458737        3
#> 1 -0.04320639        4
# Look for: short segments (Raw and Shrunken close together) =
#   little pooling. Long segments fanning toward the centre = the
#   prior pulled the estimate strongly; this is most pronounced for
#   small-N levels. ShrinkageFactor near 1 means most of the
#   movement was driven by the prior rather than the data.
# }
```
