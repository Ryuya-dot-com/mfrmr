# Plot a saved facet-quality dashboard

Plot a saved facet-quality dashboard

## Usage

``` r
# S3 method for class 'mfrm_facet_dashboard'
plot(x, y = NULL, type = c("severity", "flags"), ...)
```

## Arguments

- x:

  A result from
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md).

- y:

  Ignored; present for generic compatibility.

- type:

  `"severity"` or `"flags"`.

- ...:

  Display controls from
  [`plot_facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_quality_dashboard.md).

## Value

The existing plot payload, including screening cautions.

## See also

[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)
