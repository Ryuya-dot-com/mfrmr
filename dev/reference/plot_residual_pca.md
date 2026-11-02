# Visualize residual PCA results

Visualize residual PCA results

## Usage

``` r
plot_residual_pca(
  x,
  mode = c("overall", "facet"),
  facet = NULL,
  plot_type = c("scree", "parallel_scree", "parallel_excess", "loadings"),
  component = 1L,
  top_n = 20L,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- x:

  Output from
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_residual_pca.md),
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- mode:

  `"overall"` or `"facet"`.

- facet:

  Facet name for `mode = "facet"`.

- plot_type:

  `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or `"loadings"`.

- component:

  Component index for loadings plot.

- top_n:

  Maximum number of variables shown in loadings plot.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

- draw:

  If `TRUE`, prints the `ggplot` object.

## Value

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
returns a named list with:

- `plot`: `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or
  `"loadings"`

- `mode`: `"overall"` or `"facet"`

- `facet`: facet name (or `NULL`)

- `title`: plot title text

- `data`: underlying table used for plotting

- `InferenceTier`, `SupportsFormalInference`,
  `PrimaryReportingEligible`, `ReportingUse`, and `DecisionUse`:
  machine-readable exploratory-screening guards

## Details

`x` can be either:

- output of
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_residual_pca.md),
  or

- a diagnostics object from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  (PCA is computed internally), or

- a fitted object from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  (diagnostics and PCA are computed internally).

Plot types:

- `"scree"`: component vs eigenvalue line plot

- `"parallel_scree"`: observed eigenvalues with the selected reference's
  mean and upper cutoff (residual permutation or model bootstrap)

- `"parallel_excess"`: observed eigenvalue minus the parallel-analysis
  cutoff by component

- `"loadings"`: horizontal bar chart of top absolute loadings

For `mode = "facet"` and `facet = NULL`, the first available facet is
used.

## Interpreting output

- `plot_type = "scree"`: look for dominant early components relative to
  later components and the unit-eigenvalue reference line. Treat this as
  exploratory residual-structure screening, not a standalone
  unidimensionality test or a DIMTEST/UNIDIM substitute.

- `plot_type = "parallel_scree"` or `"parallel_excess"`: use only after
  running
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_residual_pca.md)
  with `parallel = TRUE`. Components above the selected reference cutoff
  are candidates for follow-up, not proof of multidimensionality.
  Model-bootstrap plots label the refitted reference explicitly;
  unavailable comparisons are explained in `parallel_status` and
  `bootstrap_trials`.

- `plot_type = "loadings"`: identifies variables/elements driving each
  component; inspect both sign and absolute magnitude.

Facet mode (`mode = "facet"`) helps localize residual structure to a
specific facet after global PCA review.

## Typical workflow

1.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
    with `residual_pca = "overall"` or `"both"`.

2.  Build PCA object via
    [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_residual_pca.md)
    (or pass diagnostics directly).

3.  Use scree plot first, then loadings plot for targeted
    interpretation.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_residual_pca.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
