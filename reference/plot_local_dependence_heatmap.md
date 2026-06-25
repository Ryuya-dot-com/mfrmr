# Pairwise standardized-residual heatmap for local-dependence review

Builds an N x N heatmap of pairwise standardized residuals between facet
levels, computed from the diagnostics observation table. Cells with
large absolute values flag pairs of facet elements (e.g. two raters, two
items) whose residuals co-move more than the main-effects MFRM expects,
which is the standard Yen Q3-style indicator of local response
dependence.

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

  Minimum number of shared response opportunities required to retain a
  pair. Pairs below the threshold are shown as `NA`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` whose `data` slot bundles the symmetric residual
`matrix`, the long-form `pairs` table, and the threshold used.

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
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
p <- plot_local_dependence_heatmap(fit, draw = FALSE)
dim(p$data$matrix)
# Look for: |off-diagonal correlation| < 0.2 is the typical
#   acceptable regime; values >= 0.3 (Yen 1984 / Marais 2013
#   guideline) flag pairs that may share dependence beyond the
#   main-effects MFRM. Inspect those cells in `diag$obs`.
}
```
