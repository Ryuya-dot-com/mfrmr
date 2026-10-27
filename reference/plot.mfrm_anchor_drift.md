# Plot a saved anchor-drift review

Inspect relative changes after the common-element offset used by
[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md).
Read `summary(x)` and link support alongside the plot.

## Usage

``` r
# S3 method for class 'mfrm_anchor_drift'
plot(x, type = c("drift", "heatmap", "forest"), ...)
```

## Arguments

- x:

  A saved result from
  [`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md).

- type:

  `"drift"` for relative changes with screening flags, `"heatmap"` for
  wave-by-element patterns, or `"forest"` for per-wave estimates with
  approximate normal whiskers. A linking chain is a different result:
  use `plot(chain, type = "chain")` after
  [`build_equating_chain()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_equating_chain.md).

- ...:

  `facet` optionally selects facets; `ci_level = 0.95` controls forest
  whiskers only; `preset` selects `"standard"`, `"publication"`,
  `"compact"`, or `"monochrome"`; `draw = FALSE` returns data without
  drawing. Additional base-graphics arguments depend on the selected
  view.

## Value

An `mfrm_plot_data` object, or `NULL` when no drift rows remain.
Drift/heatmap data use `data$table` (and `data$matrix` for a heatmap);
forest rows use `data$data`, including `CI_Lower` and `CI_Upper`.

## Interpretation

Drift and heatmap views show the saved relative drift. Flags use the
screening rules chosen during analysis; changing the display does not
recalibrate these rules. Subtracting the common-element offset can
remove a panel-wide shift, so unflagged elements do not establish
absence of annual drift.

Forest whiskers describe individual wave estimates, not uncertainty in
their differences. They do not include linking-offset uncertainty or
cross-wave covariance, and their overlap is not a test of change.
Missing standard errors produce no whisker, not a zero-width interval.

## See also

[`detect_anchor_drift()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_anchor_drift.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_anchor_drift", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("example_core")
people <- unique(ratings$Person)
d1 <- ratings[ratings$Person %in% people[1:12], , drop = FALSE]
d2 <- ratings[ratings$Person %in% people[13:24], , drop = FALSE]
fit1 <- fit_mfrm(d1, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
fit2 <- fit_mfrm(d2, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML")
# Review convergence and common-element support before interpreting changes.
summary(fit1)
summary(fit2)
drift <- detect_anchor_drift(list(W1 = fit1, W2 = fit2))
drift_plot <- plot(drift, type = "drift", draw = FALSE)
class(drift_plot)
names(drift_plot$data)
chain <- build_equating_chain(list(F1 = fit1, F2 = fit2))
chain_plot <- plot(chain, type = "chain", draw = FALSE)
head(chain_plot$data$table)
if (interactive()) {
  plot(drift, type = "heatmap", preset = "publication")
}
} # }
```
