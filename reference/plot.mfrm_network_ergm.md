# Plot ERGM model checks or coefficient intervals

Plot ERGM model checks or coefficient intervals

## Usage

``` r
# S3 method for class 'mfrm_network_ergm'
plot(x, type = c("coefficients", "gof"), draw = TRUE, ...)
```

## Arguments

- x:

  Output from
  [`fit_rater_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_rater_network.md).

- type:

  `"coefficients"` or `"gof"` (requires saved GOF).

- draw:

  Whether to draw; `FALSE` returns plot data only.

- ...:

  For GOF, arguments passed to ergm's `plot.gof`; for coefficients,
  arguments passed to base
  [`graphics::plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

Invisibly, an `mfrm_plot_data` object containing coefficient rows or GOF
summaries and long-form simulation draws. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to export.

## Details

Coefficient intervals are approximate pointwise normal intervals. They
are not evidence of MCMC convergence. The GOF plot delegates to ergm;
its graphical options remain available through `...`.
