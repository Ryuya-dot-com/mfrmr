# Plot differences between prespecified D-study plans

Show each plan's change from a reference, with approximate pointwise
intervals. The vertical zero line represents no change; an interval
crossing it does not establish equivalence. Positive G/Phi differences
or negative SEM differences favor the comparison plan. The method
requires normal random effects.

## Usage

``` r
# S3 method for class 'mfrm_multivariate_d_comparison'
plot(x, type = c("coefficients", "sem"), draw = TRUE, preset = "standard", ...)
```

## Arguments

- x:

  A result from
  [`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md).

- type:

  `"coefficients"` for G/Phi or `"sem"` for SEM differences.

- draw:

  Draw the figure; `FALSE` returns its data only.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

- ...:

  Reserved; additional arguments are rejected.

## Value

Invisibly, an `mfrm_plot_data` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the exact plotted `table`, `unavailable` rows, `design_grid`,
`reference`, `weights`, title and labels. Base graphics are supported;
automatic ggplot conversion is not provided for this plot.

## Details

Plans and score weights must have been specified before inspecting the
results. Intervals are not simultaneous over plans or metrics. A point
without an interval is retained and marked as unavailable; missing
values are never replaced by zero. Each panel has its own horizontal
scale. Original score units apply to SEM differences. The figure
identifies the score/composite, its weights and the reference counts.

## See also

[`mfrm_multivariate_d_compare()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_multivariate_d_compare.md)
