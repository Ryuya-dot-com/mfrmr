# Build a bias-cell count report

Build a bias-cell count report

## Usage

``` r
bias_count_table(
  bias_results,
  min_count_warn = 10,
  branch = c("original", "facets"),
  fit = NULL
)
```

## Arguments

- bias_results:

  Output from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- min_count_warn:

  Minimum count threshold for flagging sparse bias cells.

- branch:

  Output branch: `"facets"` keeps legacy manual-aligned naming,
  `"original"` returns compact QC-oriented names.

- fit:

  Optional
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  result used to attach run context metadata.

## Value

A named list with:

- `table`: cell-level counts with low-count flags

- `by_facet`: named list of counts aggregated by each interaction facet

- `by_facet_a`, `by_facet_b`: first two facet summaries (legacy
  compatibility)

- `summary`: one-row summary

- `thresholds`: applied thresholds

- `branch`, `style`: output branch metadata

- `fit_overview`: optional one-row fit metadata when `fit` is supplied

## Details

This helper summarizes how many observations contribute to each
bias-cell estimate and flags sparse cells.

Branch behavior:

- `"facets"`: keeps legacy manual-aligned column labels (`Sq`,
  `Observd Count`, `Obs-Exp Average`, `Model S.E.`) for side-by-side
  comparison with external workflows.

- `"original"`: keeps compact field names (`Count`, `BiasSize`, `SE`)
  for custom QC workflows and scripting.

## Interpreting output

- `table`: cell-level contribution counts and low-count flags.

- `by_facet`: sparse-cell structure by each interaction facet.

- `summary`: overall low-count prevalence.

- `fit_overview`: optional run context (when `fit` is supplied).

Low-count cells should be interpreted cautiously because bias-size
estimates can become unstable with sparse support.

## Typical workflow

1.  Estimate bias with
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

2.  Build `bias_count_table(...)` in desired branch.

3.  Review low-count flags before interpreting bias magnitudes.

## Further guidance

For a plot-selection guide and a longer walkthrough, see
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)
and
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Output columns

The `table` data.frame contains, in the legacy-compatible branch:

- FacetA, FacetB:

  Interaction facet level identifiers; generic names for the two
  interaction facets.

- Sq:

  Sequential row number.

- Observd Count:

  Number of observations for this cell.

- Obs-Exp Average:

  Observed minus expected average for this cell.

- Model S.E.:

  Standard error of the bias estimate.

- Infit, Outfit:

  Fit statistics for this cell.

- LowCountFlag:

  Logical; `TRUE` when count \< `min_count_warn`.

The `summary` data.frame contains:

- InteractionFacets:

  Names of the interaction facets.

- Cells, TotalCount:

  Number of cells and total observations.

- LowCountCells, LowCountPercent:

  Number and share of low-count cells.

## See also

[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`unexpected_after_bias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_after_bias_table.md),
[`build_fixed_reports()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_fixed_reports.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
bias <- estimate_bias(fit, diag, facet_a = "Rater", facet_b = "Criterion", max_iter = 2)
t11 <- bias_count_table(bias)
t11_facets <- bias_count_table(bias, branch = "facets", fit = fit)
summary(t11)
p <- plot(t11, draw = FALSE)
p2 <- plot(t11, type = "lowcount_by_facet", draw = FALSE)
if (interactive()) {
  plot(
    t11,
    type = "cell_counts",
    draw = TRUE,
    main = "Bias Cell Counts (Customized)",
    palette = c(count = "#2b8cbe", low = "#cb181d"),
    label_angle = 45
  )
}
}
```
