# Summary plot of differential functioning effect sizes

Compact effect-size summary for a
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
/
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
result. Shows each contrast's signed effect size as a horizontal bar
with a vertical reference at zero, coloured by the method-appropriate
classification. ETS-style A / B / C colours are used only when they are
actually available; residual-method screening labels otherwise use the
neutral colour.

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
  `Effect +/- z * SE` when finite standard errors are available. Use
  `NULL` (default) to omit intervals.

- effect_thresholds:

  Optional numeric vector of absolute effect-size guide lines to draw at
  `+/- threshold`. These are display aids; only use ETS-like values when
  the source rows support ETS interpretation.

- effect_axis_label:

  Optional x-axis label override. When `NULL`, the label is chosen from
  the DFF method.

## Value

An `mfrm_plot_data` object whose `data` slot contains columns `Pair`,
`Effect`, `SE`, `Classification`, `Color`.

## Interpreting output

Bars are anchored at zero. Width corresponds to effect size on the
contrast's native scale. For `method = "residual"`, this is the
observed-minus-expected average screening contrast between groups. For
`method = "refit"`, this is the subgroup parameter difference on the
fitted logit scale when linking support allows a comparable contrast.
The ETS classification (A negligible, B moderate, C large) drives bar
colour only when `ClassificationSystem == "ETS"`; otherwise the bar uses
the preset's neutral.

## See also

[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md).

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_bias")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
diag <- diagnose_mfrm(fit, residual_pca = "none")
dff <- analyze_dff(fit, diagnostics = diag,
                   facet = "Rater", group = "Group", data = toy)
unique(dff$dif_table$ClassificationSystem)
p <- plot_dif_summary(dff, draw = FALSE)
head(p$data$data)
}
```
