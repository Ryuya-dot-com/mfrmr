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
                 method = "JML", maxit = 300)
fit_eb <- apply_empirical_bayes_shrinkage(fit)
p <- plot_shrinkage_funnel(fit_eb, draw = FALSE)
head(p$data$table)
#>   Facet Level RawEstimate         SE ShrunkEstimate   ShrunkSE ShrinkageFactor
#> 2 Rater   R02  -0.3287812 0.09769555     -0.2861288 0.09113855       0.1297287
#> 3 Rater   R01  -0.1957463 0.09729871     -0.1705317 0.09081612       0.1288124
#> 4 Rater   R03   0.1910898 0.09724038      0.1665008 0.09076868       0.1286778
#> 1 Rater   R04   0.3334376 0.09762913      0.2902324 0.09108462       0.1295752
#>      Movement RowOrder SupportsFormalInference
#> 2  0.04265234        1                   FALSE
#> 3  0.02521454        2                   FALSE
#> 4 -0.02458902        3                   FALSE
#> 1 -0.04320524        4                   FALSE
#>                                                                                                                                                             Interpretation
#> 2 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
#> 3 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
#> 4 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
#> 1 Descriptive zero-centered adjustment; plug-in SEs/bands omit prior-variance uncertainty and cross-level covariance. Zero SE after full pooling is not perfect precision.
# Look for: short segments (Raw and Shrunken close together) =
#   little pooling. Long segments fanning toward the centre = the
#   prior pulled the estimate strongly; this is most pronounced for
#   small-N levels. ShrinkageFactor near 1 means most of the
#   movement was driven by the prior rather than the data.
# }
```
