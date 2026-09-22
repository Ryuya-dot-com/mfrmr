# Pairwise standardized-residual heatmap for local-dependence review

Builds an N x N heatmap of pairwise standardized residuals between facet
levels, computed from the diagnostics observation table. Cells with
large absolute values flag pairs of facet elements (e.g. two raters, two
items) whose residuals co-move more than the main-effects MFRM expects.
Residuals are averaged within each Person and facet level before
correlation. This is a Q3-style screen, distinct from raw-residual Yen
Q3; no fixed correlation cutoff establishes local independence for this
standardized, aggregated index.

## Usage

``` r
plot_local_dependence_heatmap(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  min_pairs = 5L,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- facet:

  Facet whose levels are placed on both axes (default `"Rater"`).

- min_pairs:

  Minimum number of persons with finite aggregated residuals at both
  levels; an integer of at least three. Unavailable pairs remain in the
  table with their overlap count and reason, and appear as `NA` in the
  matrix.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` whose `data` slot bundles the symmetric residual
`matrix`, one row per unordered pair in `pairs`, and the threshold used.

## Details

This helper complements
[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md):
the marginal version uses posterior-integrated agreement residuals on a
top-N pair list, while this view shows every pair on a shared color
scale so an analyst can scan for diagonal blocks or hotspots.

## See also

[`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
p <- plot_local_dependence_heatmap(fit, draw = FALSE)
dim(p$data$matrix)
#> [1] 4 4
# Inspect large absolute correlations alongside shared-person counts.
# Unavailable pairs are not evidence of local independence.
# }
```
