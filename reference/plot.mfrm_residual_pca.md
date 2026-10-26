# Plot saved residual PCA

Display a saved residual PCA or its saved parallel-analysis comparison.
Plotting does not generate a new parallel reference.

## Usage

``` r
# S3 method for class 'mfrm_residual_pca'
plot(x, type = "scree", mode = "overall", ...)
```

## Arguments

- x:

  A result from
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md).

- type:

  `"scree"`, `"parallel_scree"`, `"parallel_excess"`, or `"loadings"`.
  Existing `"overall_*"` and `"facet_*"` spellings remain supported.

- mode:

  `"overall"` (default) or `"facet"`. Do not also supply `mode` when
  using a prefixed `type` such as `"facet_scree"`.

- ...:

  `facet` selects a facet for `mode = "facet"` (default: the first
  available facet); `component = 1` selects a loading component;
  `top_n = 20` limits displayed loadings. `preset` is `"standard"`,
  `"publication"`, `"compact"`, or `"monochrome"`; `draw = FALSE`
  returns data without drawing.

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

## Interpretation

- `"scree"` shows component eigenvalues. A dominant early component is
  exploratory evidence of residual structure, not a standalone test of
  unidimensionality.

- `"parallel_scree"` shows the observed eigenvalues and saved reference
  mean/cutoff; `"parallel_excess"` shows the observed-minus-cutoff
  difference. Compute these references with `parallel = TRUE` in
  [`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md)
  first. Exceeding a cutoff suggests follow-up, not proof of
  multidimensionality. Inspect `parallel_status` and `bootstrap_trials`
  for unavailable comparisons and distinguish residual permutation from
  refitted model bootstrap.

- `"loadings"` shows the largest absolute loadings; inspect both signs
  and magnitudes to identify the contributing variables or elements.

Use overall mode before locating patterns within individual facets.
Repeated plots of a saved result reuse the same PCA and do not provide
independent evidence.

## See also

[`analyze_residual_pca()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_residual_pca.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)

## Examples

``` r
ratings_all <- load_mfrmr_data("example_core")
selected_people <- unique(ratings_all$Person)[1:24]
ratings <- ratings_all[
  ratings_all$Person %in% selected_people, , drop = FALSE]
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "JML")
diag <- diagnose_mfrm(fit, residual_pca = "overall")
pca <- analyze_residual_pca(diag, mode = "overall")
plt <- plot(pca, type = "scree", draw = FALSE)
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
# Ten replicates illustrate the display, not a stable reference cutoff.
pca_pa <- analyze_residual_pca(diag, mode = "overall", parallel = TRUE,
                               parallel_reps = 10, seed = 2026)
pa <- plot(pca_pa, type = "parallel_scree", draw = FALSE)
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
#> [1] "Conditional permutation reference; fitted-model uncertainty omitted.\nComponentwise cutoffs; no adjustment for scanning components"
#> 
#> $legend
#>                                     label            role  aesthetic   value
#> 1           Observed residual eigenvalues       component line-point #1f78b4
#> 2         95% residual-permutation cutoff parallel_cutoff line-point #d95f02
#> 3                           Parallel mean   parallel_mean       line #1b9e77
#> 4 Unit eigenvalue (descriptive reference)       reference       line #6b7280
#> 
plt_load <- plot(pca, type = "loadings", component = 1, draw = FALSE)
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
  plot(pca, type = "scree", preset = "publication")
}
```
