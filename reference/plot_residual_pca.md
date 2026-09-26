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
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  or
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

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

  If `TRUE`, draws the plot using base graphics.

## Value

A named list of plotting data (class `mfrm_plot_data`) with:

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
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
  or

- a diagnostics object from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  (PCA is computed internally), or

- a fitted object from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  (diagnostics and PCA are computed internally).

Plot types:

- `"scree"`: component vs eigenvalue line plot

- `"parallel_scree"`: observed eigenvalues with residual-permutation
  parallel-analysis mean and upper cutoff

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
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
  with `parallel = TRUE`. Components above the residual-permutation
  cutoff are candidates for follow-up, not proof of multidimensionality.

- `plot_type = "loadings"`: identifies variables/elements driving each
  component; inspect both sign and absolute magnitude.

Facet mode (`mode = "facet"`) helps localize residual structure to a
specific facet after global PCA review.

## Typical workflow

1.  Run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    with `residual_pca = "overall"` or `"both"`.

2.  Build PCA object via
    [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
    (or pass diagnostics directly).

3.  Use scree plot first, then loadings plot for targeted
    interpretation.

## Session plot defaults

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## See also

[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
# \donttest{
toy_full <- load_mfrmr_data("example_core")
toy_people <- unique(toy_full$Person)[1:24]
toy <- toy_full[match(toy_full$Person, toy_people, nomatch = 0L) > 0L, , drop = FALSE]
fit <- suppressWarnings(
  fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
)
diag <- diagnose_mfrm(fit, residual_pca = "overall")
pca <- analyze_residual_pca(diag, mode = "overall")
plt <- plot_residual_pca(pca, mode = "overall", plot_type = "scree", draw = FALSE)
head(plt$data)
#> $plot
#> [1] "scree"
#> 
#> $mode
#> [1] "overall"
#> 
#> $facet
#> NULL
#> 
#> $title
#> [1] "Overall Residual PCA (Scree)"
#> 
#> $subtitle
#> [1] "Variance explained by residual components"
#> 
#> $legend
#>                                     label      role  aesthetic   value
#> 1                    Residual eigenvalues component line-point #1f78b4
#> 2 Unit eigenvalue (descriptive reference) reference       line #6b7280
#> 
pca_pa <- analyze_residual_pca(diag, mode = "overall", parallel = TRUE, parallel_reps = 10)
pa <- plot_residual_pca(pca_pa, mode = "overall", plot_type = "parallel_scree", draw = FALSE)
head(pa$data)
#> $plot
#> [1] "parallel_scree"
#> 
#> $mode
#> [1] "overall"
#> 
#> $facet
#> NULL
#> 
#> $title
#> [1] "Overall Residual PCA (Parallel Scree)"
#> 
#> $subtitle
#> [1] "Conditional residual-permutation reference; fitted-model uncertainty omitted"
#> 
#> $legend
#>                                     label            role  aesthetic   value
#> 1           Observed residual eigenvalues       component line-point #1f78b4
#> 2         95% residual-permutation cutoff parallel_cutoff line-point #d95f02
#> 3                           Parallel mean   parallel_mean       line #1b9e77
#> 4 Unit eigenvalue (descriptive reference)       reference       line #6b7280
#> 
plt_load <- plot_residual_pca(
  pca, mode = "overall", plot_type = "loadings", component = 1, draw = FALSE
)
head(plt_load$data)
#> $plot
#> [1] "loadings"
#> 
#> $mode
#> [1] "overall"
#> 
#> $facet
#> NULL
#> 
#> $title
#> [1] "Overall Residual PCA (Loadings: PC1)"
#> 
#> $subtitle
#> [1] "Top 16 absolute loadings"
#> 
#> $legend
#>               label    role aesthetic   value
#> 1 Positive loadings loading       bar #1b9e77
#> 2 Negative loadings loading       bar #d95f02
#> 
if (interactive()) {
  plot_residual_pca(pca, mode = "overall", plot_type = "scree", preset = "publication")
}
# }
```
