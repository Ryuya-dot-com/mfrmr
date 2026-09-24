# Plot testlet-model fixed-facet estimates

Plot testlet-model fixed-facet estimates

## Usage

``` r
# S3 method for class 'mfrm_testlet'
plot(
  x,
  facet = x$input$columns$facets[1],
  draw = TRUE,
  style = c("interval", "precision", "distribution"),
  sort = c("input", "estimate", "uncertainty"),
  palette = c("accessible", "mono"),
  title = NULL,
  caption = NULL,
  show_title = TRUE,
  show_notes = TRUE,
  show_labels = TRUE,
  reference = 0,
  text_scale = 1,
  point_size = 2.5,
  intervals = c("none", "normal"),
  level = 0.95,
  ...
)
```

## Arguments

- x:

  An object from
  [`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md).

- facet:

  A fixed facet to display; defaults to the first fixed facet.

- draw:

  `FALSE` returns plot data without opening a device.

- style:

  `"interval"` keeps every labeled row; `"precision"` plots estimates
  against interval width (upper minus lower bound); `"distribution"`
  shows the empirical cumulative distribution of finite point estimates,
  excluding prior-only and unavailable scores. No density is
  reconstructed.

- sort:

  Row order for interval plots: input order, increasing estimate, or
  increasing interval width. Missing values come last; ties retain input
  order. Sorting is descriptive, not a test of differences.

- palette:

  `"accessible"` uses blue and dark orange with filled/open symbols;
  `"mono"` uses dark grey with the same symbol distinctions.

- title, caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title, show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show IDs on interval and precision plots. Distribution plots summarize
  estimates and do not label individual IDs. For crowded precision plots
  use `FALSE` and consult the retained table.

- reference:

  Vertical reference line in logits; `NULL` omits it. This is an
  orientation aid, not a quality threshold.

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- intervals:

  `"none"` (default) shows points only; `"normal"` explicitly requests
  observed-information normal-approximation bounds. Interval-width views
  or sorting require this explicit selection.

- level:

  Nominal level of explicitly requested calibration intervals; default
  0.95. This does not establish finite-sample coverage.

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object; use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

## Details

Requested whiskers are observed-information normal approximations for
calibration parameters; finite-sample coverage is not established.
Missing intervals remain missing; points do not classify rater quality.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md)
provide the same table without drawing.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves the interval meaning and missing whiskers.

## See also

[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md),
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md),
[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet_scores.md)
