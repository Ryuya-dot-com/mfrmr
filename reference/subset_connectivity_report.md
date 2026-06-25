# Build a subset connectivity report (preferred alias)

Build a subset connectivity report (preferred alias)

## Usage

``` r
subset_connectivity_report(
  fit,
  diagnostics = NULL,
  top_n_subsets = NULL,
  min_observations = 0
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- top_n_subsets:

  Optional maximum number of subset rows to keep.

- min_observations:

  Minimum observations required to keep a subset row.

## Value

A named list with subset-connectivity components. Class:
`mfrm_subset_connectivity`.

## Details

`summary(out)` is supported through
[`summary()`](https://rdrr.io/r/base/summary.html). `plot(out)` is
dispatched through
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for class
`mfrm_subset_connectivity` (`type = "subset_observations"`,
`"facet_levels"`, or `"linking_matrix"` / `"coverage_matrix"` /
`"design_matrix"` / `"network"`). The network route returns reusable
node and edge tables with `draw = FALSE`; drawing uses `igraph` when
available.

## Interpreting output

- `summary`: number and size of connected subsets.

- subset table: whether data are fragmented into disconnected
  components.

- facet-level columns: where connectivity bottlenecks occur.

## Typical workflow

1.  Run `subset_connectivity_report(fit)`.

2.  Confirm near-single-subset structure when possible.

3.  Use results to justify linking/anchoring strategy.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_network_analysis()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_network_analysis.md),
[`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
[`data_quality_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/data_quality_report.md),
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
out <- subset_connectivity_report(fit)
summary(out)
p_sub <- plot(out, draw = FALSE)
p_design <- plot(out, type = "design_matrix", draw = FALSE)
p_net <- plot(out, type = "network", draw = FALSE)
p_sub$data$plot
p_design$data$plot
p_net$data$edges
out$summary[, c("Subset", "Observations", "ObservationPercent")]
}
```
