# Plot design-weighted precision curves

Visualize the design-weighted precision curve and optionally
per-facet-level contribution curves from
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

## Usage

``` r
plot_information(
  x,
  type = c("tif", "iif", "se", "sem", "csem", "both"),
  facet = NULL,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

- type:

  `"tif"` for the overall precision curve (default), `"iif"` for
  facet-level contribution curves, `"se"` / `"sem"` / `"csem"` for the
  conditional standard error of measurement implied by that curve, or
  `"both"` for precision with conditional SEM on a secondary axis.

- facet:

  For `type = "iif"`, which facet to plot. If `NULL`, the first facet is
  used.

- draw:

  If `TRUE` (default), draw the plot. If `FALSE`, return reusable
  `mfrm_plot_data` invisibly.

- ...:

  Additional graphical parameters.

## Value

Invisibly, an `mfrm_plot_data` object.

## Plot types

- `"tif"`: overall design-weighted precision across theta.

- `"se"` / `"sem"` / `"csem"`: conditional SEM across theta.

- `"both"`: precision and conditional SEM together, useful for
  presentations.

- `"iif"`: facet-level contribution curves for one selected facet in a
  supported `RSM`, `PCM`, or bounded `GPCM` fit.

## Which type should I use?

- Use `"tif"` for a quick overall read on precision.

- Use `"sem"` or `"csem"` when standard-error language is easier to
  communicate than precision.

- Use `"both"` when you want both views in one figure.

- Use `"iif"` when you want to see which facet levels are shaping the
  total precision curve.

## Interpreting output

- The total curve peaks where the realized design is most precise.

- Conditional SEM is derived as `1 / sqrt(precision)`; lower is better.

- Facet-level curves show which facet levels contribute most to that
  realized precision at each theta.

- For bounded `GPCM`, those contributions include the squared
  discrimination scaling implied by the fitted `slope_facet`.

- If the precision peak sits far from the bulk of person measures, the
  realized design may be poorly targeted.

## Returned data when draw = FALSE

`draw = FALSE` returns an `mfrm_plot_data` object. The underlying
plotting data are stored in `$data$plot`. For `type = "tif"`, `"se"`, or
`"both"`, those rows come from `x$tif`. For `type = "iif"`, the returned
rows come from `x$iif` filtered to the requested facet. The plot data
also include `plot_long`, `information_long`, `conditional_sem`,
`summary`, and `settings` so ggplot2, plotly, Quarto, and table
workflows can reuse the information and conditional-SEM series without
parsing the drawn figure.

## Typical workflow

1.  Compute information with
    [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md).

2.  Plot with `plot_information(info)` for the total precision curve.

3.  Use `plot_information(info, type = "iif", facet = "Rater")` for
    facet-level contributions.

4.  Use `draw = FALSE` when you want reusable plot data for custom
    graphics or reporting helpers.

## See also

[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 30)
info <- compute_information(fit)
tif_data <- plot_information(info, type = "tif", draw = FALSE)
head(tif_data$data$plot)
#> # A tibble: 6 × 3
#>   Theta Information    SE
#>   <dbl>       <dbl> <dbl>
#> 1 -6           7.61 0.363
#> 2 -5.94        8.07 0.352
#> 3 -5.88        8.56 0.342
#> 4 -5.82        9.09 0.332
#> 5 -5.76        9.64 0.322
#> 6 -5.7        10.2  0.313
iif_data <- plot_information(info, type = "iif", facet = "Rater", draw = FALSE)
head(iif_data$data$plot)
#> # A tibble: 6 × 5
#>   Theta Facet Level Information Exposure
#>   <dbl> <chr> <chr>       <dbl>    <dbl>
#> 1 -6    Rater R01          2.23      192
#> 2 -5.94 Rater R01          2.36      192
#> 3 -5.88 Rater R01          2.51      192
#> 4 -5.82 Rater R01          2.66      192
#> 5 -5.76 Rater R01          2.82      192
#> 6 -5.7  Rater R01          3.00      192
```
