# Plot directional screening rates across threshold profiles

Plot directional screening rates across threshold profiles

## Usage

``` r
# S3 method for class 'mfrm_screening_sensitivity'
plot(
  x,
  style = c("tiles", "curves"),
  direction = "either",
  metric = c("false_flags", "detection"),
  condition = NULL,
  quantity = c("rate", "unavailable"),
  draw = TRUE,
  palette = c("accessible", "mono"),
  title = NULL,
  caption = NULL,
  show_title = TRUE,
  show_notes = TRUE,
  show_labels = TRUE,
  text_scale = 1,
  point_size = 2.5,
  ...
)
```

## Arguments

- x:

  Output from
  [`mfrm_screening_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_sensitivity.md).

- style:

  `"tiles"` shows a labelled rate matrix. `"curves"` shows profile
  comparisons with pointwise Monte Carlo intervals by condition.

- direction:

  One or more of `"either"`, `"underfit"`, `"overfit"`.

- metric:

  `"false_flags"` or `"detection"` chooses the family event.

- condition:

  Optional condition labels to display.

- quantity:

  `"rate"` (default) or `"unavailable"`, the proportion of planned
  family events whose outcome is unresolved.

- draw:

  `FALSE` returns plot data without opening a device.

- palette:

  `"accessible"` uses a sequential blue scale for tiles and
  blue/orange/purple lines with different symbols. `"mono"` uses greys.

- title, caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title, show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show percentages and known/planned counts in tiles.

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- ...:

  Unused.

## Value

Invisibly, `mfrm_plot_data` with exact selected tables, settings, notes
and alternative text.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
supports either style.

## Details

Tile shading is supplemented by numeric labels; missing estimates are
labelled NA. Profile order is supplied order, not an optimized ranking.
Curves connect discrete profile choices, not a continuous threshold
scale. Tile plots do not display uncertainty intervals: consult the
retained table or curve view. Exact intervals are pointwise and
conditional on known outcomes; all-trial bounds are retained, not
confidence intervals.
