# Plot outputs from a legacy-compatible workflow run

Plot outputs from a legacy-compatible workflow run

## Usage

``` r
# S3 method for class 'mfrm_facets_run'
plot(x, y = NULL, type = c("fit", "qc"), ...)
```

## Arguments

- x:

  A `mfrm_facets_run` object from
  [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).

- y:

  Unused.

- type:

  Plot route: `"fit"` delegates to
  [`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
  and `"qc"` delegates to
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md).

- ...:

  Additional arguments passed to the selected plot function.

## Value

A plotting object from the delegated plot route.

## Details

This method is a router for fast visualization from a one-shot workflow
result:

- `type = "fit"` for model-level displays.

- `type = "qc"` for multi-panel quality-control diagnostics.

## Interpreting output

Returns the plotting object produced by the delegated route:
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `"fit"` and
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md)
for `"qc"`.

## Typical workflow

1.  Run
    [`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md).

2.  Start with `plot(out, type = "fit", draw = FALSE)`.

3.  Continue with `plot(out, type = "qc", draw = FALSE)` for
    diagnostics.

## See also

[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy_small <- toy[toy$Person %in% unique(toy$Person)[1:12], , drop = FALSE]
out <- run_mfrm_facets(
  data = toy_small,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  maxit = 30
)
p_fit <- plot(out, type = "fit", draw = FALSE)
p_fit$wright_map$data$plot
p_qc <- plot(out, type = "qc", draw = FALSE)
p_qc$data$plot
} # }
```
