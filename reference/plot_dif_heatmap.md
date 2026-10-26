# Plot a differential-functioning heatmap

Visualizes the interaction between a facet and a grouping variable as a
heatmap. Rows represent facet levels, columns represent group values,
and cell color indicates the selected metric.

## Usage

``` r
plot_dif_heatmap(
  x,
  metric = c("obs_exp", "t", "contrast"),
  draw = TRUE,
  show_values = TRUE,
  value_digits = 2L,
  flag_threshold = NULL,
  scale_limit = NULL,
  flag_color = "black",
  ...
)
```

## Arguments

- x:

  Output from
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  or
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).
  When an `mfrm_dff`/`mfrm_dif` object is passed, the `cell_table`
  element is used (requires `method = "residual"`).

- metric:

  Which metric to plot: `"obs_exp"` for observed-minus-expected average
  (default), `"t"` for the descriptive scaled residual (not a t-test),
  or `"contrast"` for pairwise differential-functioning contrast (only
  for `mfrm_dff` objects with `dif_table`).

- draw:

  If `TRUE` (default), draw the plot.

- show_values:

  Logical. If `TRUE` (default), print rounded cell values on top of the
  heatmap.

- value_digits:

  Non-negative integer number of digits after the decimal point for cell
  labels.

- flag_threshold:

  Optional non-negative absolute-value threshold. When supplied, cells
  with `abs(value) >= flag_threshold` are recorded in
  `$data$flag_matrix` and outlined on the drawn heatmap.

- scale_limit:

  Optional positive scalar for a symmetric color scale from
  `-scale_limit` to `+scale_limit`. Use this to make several heatmaps
  visually comparable.

- flag_color:

  Border color for cells meeting `flag_threshold`.

- ...:

  Additional graphical parameters passed to
  [`graphics::image()`](https://rdrr.io/r/graphics/image.html).

## Value

Invisibly, an `mfrm_plot_data` object whose `data` slot bundles the row
x column metric matrix (`$matrix`), the source long table (`$pairs`),
and the metric label. Earlier 0.1.x releases returned the bare matrix;
consume `$data$matrix` to keep code forward-compatible.

## Interpreting output

- Warm colors (red) indicate positive Obs-Exp values (the model
  underestimates the facet level for that group).

- Cool colors (blue) indicate negative Obs-Exp values (the model
  overestimates).

- White/neutral indicates no systematic difference.

- The `"contrast"` view is best for pairwise differential-functioning
  summaries, whereas `"obs_exp"` and `"t"` are best for cell-level
  diagnostics.

## Typical workflow

1.  Compute interaction with
    [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md)
    or differential- functioning contrasts with
    [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

2.  Plot with `plot(..., type = "heatmap")`.

3.  Identify extreme cells or contrasts for follow-up.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md)
