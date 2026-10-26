# Plot a differential-functioning interaction grid

Display saved residual means by facet level and group. This is a
descriptive screen for follow-up; residual differences do not isolate
differential functioning.

## Usage

``` r
# S3 method for class 'mfrm_dif_interaction'
plot(x, type = "heatmap", ...)
```

## Arguments

- x:

  A result from
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md).

- type:

  The sole view, `"heatmap"`.

- ...:

  Heatmap controls below, plus `draw = FALSE` to return data without
  drawing. This input accepts `metric = "obs_exp"` or `"t"`;
  `"contrast"` requires a result from
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

## Value

An `mfrm_plot_data` object with `data$matrix`, `data$pairs`, the
selected metric and retained interpretation notes. Use
`plot_data(p, "matrix")` to extract the matrix from a saved plot `p`.

## Interpretation

Positive `"obs_exp"` values mean observed scores exceed model
expectations; negative values mean they fall below expectations. These
values are in score units, not logits. The `"t"` metric is a scaled
residual without a calibrated test or p-value. Color and optional
threshold outlines are descriptive; an unavailable cell is not a zero
residual.

## Heatmap appearance

- `show_values = TRUE` labels cells; `value_digits = 2` controls
  rounding.

- `flag_threshold = NULL` adds no flags. A non-negative value outlines
  cells at or above that absolute value; `flag_color = "black"` sets the
  border.

- `scale_limit = NULL` uses the observed range. A positive value fixes
  symmetric color limits for comparing plots. It does not change saved
  values.

## See also

[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[`plot.mfrm_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_dif.md),
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_bias")

fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", model = "RSM", maxit = 300)
diag <- diagnose_mfrm(fit, residual_pca = "none")
int <- dif_interaction_table(fit, diag, facet = "Rater",
                             group = "Group", data = ratings, min_obs = 2)
heat <- plot(int, type = "heatmap", metric = "obs_exp", draw = FALSE)
dim(heat$data$matrix)
#> [1] 4 2
# Obs-Exp is in score units, not logits. A scaled residual
# (metric = "t") is descriptive, not a calibrated t-test.
```
