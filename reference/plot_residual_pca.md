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
#>                         label      role  aesthetic   value
#> 1        Residual eigenvalues component line-point #1f78b4
#> 2             Unit-eigenvalue reference       line #6b7280
#> 3      Critical minimum (1.4) reference       line #6b7280
#> 4 Noticeable second dim (2.0) reference       line #6b7280
#> 5     Strong second dim (3.0) reference       line #6b7280
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
#> [1] "Observed residual eigenvalues compared with the permutation null"
#> 
#> $legend
#>                                label            role  aesthetic   value
#> 1      Observed residual eigenvalues       component line-point #1f78b4
#> 2    95% residual-permutation cutoff parallel_cutoff line-point #d95f02
#> 3                      Parallel mean   parallel_mean       line #1b9e77
#> 4                    Unit-eigenvalue       reference       line #6b7280
#> 5             Critical minimum (1.4)       reference       line #6b7280
#> 6        Noticeable second dim (2.0)       reference       line #6b7280
#> 7            Strong second dim (3.0)       reference       line #6b7280
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
