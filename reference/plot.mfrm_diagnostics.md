# Plot saved ordinary-model diagnostics

Inspect an existing diagnostic result to locate cells or elements
needing follow-up. The selected display retains unavailable results and
screening limits.

## Usage

``` r
# S3 method for class 'mfrm_diagnostics'
plot(
  x,
  type = c("marginal_fit", "marginal_pairwise", "bubble", "residual_pca"),
  view = NULL,
  ...
)
```

## Arguments

- x:

  An `mfrm_diagnostics` result from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- type:

  `"marginal_fit"`, `"marginal_pairwise"`, `"bubble"`, or
  `"residual_pca"`.

- view:

  For marginal fit, `"std_residual"` (default) or `"prop_diff"`; for
  bubbles, `"measure"` (default) or `"infit_outfit"`; for PCA,
  `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or `"loadings"`.
  Omit it for `"marginal_pairwise"` and use `metric` instead.

- ...:

  All views accept `draw = FALSE`, `top_n`, and `preset`. Marginal views
  accept `facet`; pairwise plots additionally accept `metric = "exact"`
  or `"adjacent"`. Bubbles accept `fit_stat` (`"Infit"` or `"Outfit"`),
  `bubble_size` (`"SE"`, `"N"`, or `"equal"`), `facets`,
  `include_person = FALSE`, and the heuristic `fit_range = c(0.5, 1.5)`.
  PCA accepts `mode`, `facet`, and `component`, as described in
  [`plot.mfrm_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_residual_pca.md).
  Controls for other views are rejected.

## Value

An `mfrm_plot_data` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to inspect its tables and notes. The plot does not add unavailable
diagnostics or qualify intervals.

## Choosing a view

Marginal fit and pairwise plots require strict marginal diagnostics from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
with `diagnostic_mode = "both"` or `"marginal_fit"` for supported MML
RSM/PCM models. Positive residuals indicate more observed category usage
or agreement than expected; negative values indicate less. Returned
`full_table` and `retention` distinguish omitted and unavailable rows. A
flag is a descriptive review rule, not a calibrated test.

Bubble plots place measures against mean-square fit, or Infit against
Outfit. Bubble size can represent SE or observation count; neither a
review band nor bubble size alone justifies deleting an element.

The PCA convenience route can derive PCA from the diagnostic result. For
repeated PCA displays, first save
[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
and use its [`plot()`](https://rdrr.io/r/graphics/plot.default.html)
method. Parallel-reference generation remains an analysis step.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`plot.mfrm_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_residual_pca.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)
