# Plot a facet-quality dashboard

Plot a facet-quality dashboard

## Usage

``` r
plot_facet_quality_dashboard(
  x,
  diagnostics = NULL,
  facet = NULL,
  bias_results = NULL,
  severity_warn = 1,
  misfit_warn = NULL,
  central_tendency_max = NULL,
  bias_count_warn = 1L,
  bias_abs_t_warn = 2,
  bias_abs_size_warn = 0.5,
  bias_p_max = 0.05,
  plot_type = c("severity", "flags"),
  top_n = 20,
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  when `x` is a fit.

- facet:

  Optional facet name.

- bias_results:

  Optional bias bundle or list of bundles.

- severity_warn:

  Absolute estimate cutoff used to flag severity outliers.

- misfit_warn:

  Mean-square cutoff used to flag misfit.

- central_tendency_max:

  Legacy opt-in absolute estimate cutoff for marking facet estimates
  near the fitted origin. Default `NULL`; use
  [`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md)
  for observed category-use screening.

- bias_count_warn:

  Minimum flagged-bias row count required to flag a level.

- bias_abs_t_warn:

  Absolute `t` cutoff used when deriving bias-row flags from a raw bias
  bundle.

- bias_abs_size_warn:

  Absolute bias-size cutoff used when deriving bias-row flags from a raw
  bias bundle.

- bias_p_max:

  Probability cutoff used when deriving bias-row flags from a raw bias
  bundle.

- plot_type:

  Plot type, `"severity"` or `"flags"`.

- top_n:

  Number of rows to keep in the plot data.

- main:

  Optional plot title.

- palette:

  Optional named color overrides.

- label_angle:

  Label angle hint for the `"flags"` plot.

- draw:

  If `TRUE`, draw with base graphics.

- ...:

  Reserved for generic compatibility.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

When `x` is a dashboard, its stored screening settings define both flags
and plot guides; threshold arguments apply only when `x` is a fit.
Returned plot data retain those settings, interpretation notes and fit
readiness. Restricted or older dashboards without readiness are labeled
`REVIEW ONLY`. Zero observed flags is not a complete diagnostic pass.

## See also

[`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
[`summary.mfrm_facet_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_facet_dashboard.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
p <- plot_facet_quality_dashboard(fit, diagnostics = diag, draw = FALSE)
p$data$plot
#> [1] "severity"
# }
```
