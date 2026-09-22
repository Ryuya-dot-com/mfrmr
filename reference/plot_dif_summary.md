# Summary plot of differential functioning effect sizes

Compact effect-size summary for a
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
/
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
result. Shows each contrast's signed effect size as a horizontal bar
with a vertical reference at zero and a neutral colour. Residual
comparisons do not provide differential-functioning tests or
classifications.

## Usage

``` r
plot_dif_summary(
  x,
  top_n = 30L,
  sort_by = c("abs_effect", "effect", "classification"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ci_level = NULL,
  effect_thresholds = NULL,
  effect_axis_label = NULL
)
```

## Arguments

- x:

  Output from
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
  or
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

- top_n:

  Maximum rows shown (default `30`).

- sort_by:

  `"abs_effect"` (default), `"effect"`, or `"classification"`.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

- ci_level:

  Optional confidence level for approximate normal intervals drawn from
  `Effect +/- z * SE` when finite standard errors are available for
  linked refits. Residual comparisons require `NULL` (default) because
  their interval uncertainty is not established.

- effect_thresholds:

  Optional numeric vector of absolute effect-size guide lines to draw at
  `+/- threshold`. These are display aids, not ETS classification
  boundaries.

- effect_axis_label:

  Optional x-axis label override. When `NULL`, the label is chosen from
  the DFF method.

## Value

An `mfrm_plot_data` object whose `data` slot contains columns `Pair`,
`Effect`, `SE`, `Classification`, `Color`.

## Interpreting output

Bars are anchored at zero. Width corresponds to effect size on the
contrast's native scale. For `method = "residual"`, this is the
observed-minus-expected average difference between groups, in score
units. For `method = "refit"`, this is the subgroup parameter difference
on the fitted logit scale when linking support allows a comparable
contrast. Residual differences do not isolate differential functioning.
Linked refit intervals omit estimated-anchor uncertainty and cross-refit
covariance.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md).

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
diag <- diagnose_mfrm(fit, residual_pca = "none")
dff <- analyze_dff(fit, diagnostics = diag,
                   facet = "Rater", group = "Group", data = toy)
unique(dff$dif_table$ClassificationSystem)
#> [1] "descriptive"
p <- plot_dif_summary(dff, draw = FALSE)
head(p$data$data)
#>          Pair      Effect SE CI_Lower CI_Upper    Classification
#> 1 R01 | A | B  0.16851952 NA       NA       NA Residual contrast
#> 2 R02 | A | B -0.13201751 NA       NA       NA Residual contrast
#> 3 R03 | A | B -0.11255952 NA       NA       NA Residual contrast
#> 4 R04 | A | B  0.07636974 NA       NA       NA Residual contrast
#>   ClassificationSystem   Color
#> 1          descriptive #6b7280
#> 2          descriptive #6b7280
#> 3          descriptive #6b7280
#> 4          descriptive #6b7280
# }
```
