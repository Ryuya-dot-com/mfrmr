# Plot conditional Person scores from a testlet model

Plot conditional Person scores from a testlet model

## Usage

``` r
# S3 method for class 'mfrm_testlet_scores'
plot(
  x,
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
  ...
)
```

## Arguments

- x:

  A result from
  [`predict.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict.mfrm_testlet.md).

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

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object retaining all requested Persons,
their statuses, interval endpoints and settings; use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

## Details

In the default interval view, empty rows remain labeled. Open circles
mark prior-only results; filled points are response-based conditional
scores. The intervals exclude calibration-estimation uncertainty and are
not tests of Person differences.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves all labeled rows, prior-only symbols and the
conditional-interval note.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains statuses and reasons for custom graphics or table export;
conversion does not rerun scoring.

## Choosing a view

Interval plots answer where estimates lie and how uncertain they are.
Precision plots help identify estimates with wider intervals; width is
neither a fit statistic nor a reliability coefficient. Finite intervals
are required and excluded rows remain in `display_data` with reasons.
Distribution plots summarize the selected point estimates, which are
affected by shrinkage and the selected roster. They do not estimate the
latent population distribution, show posterior densities, or imply
independent observations.

## Accessible and reusable output

Colours are supplemented by point shapes; open circles mean prior only.
Use `palette = "mono"` for monochrome reproduction.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains the complete source `table`, `display_data` with inclusion
reasons, `alt_text`, interpretation `notes`, and display settings.
Supply the text alternative and table alongside exported figures; image
files alone do not automatically expose that information to screen
readers.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
preserves the view and display controls, supplies `labs(alt = ...)`, and
allows further `labs()`, `theme()` and scale edits. Rendering does not
fit, score or resample. Use the same controls through
`plot(results, type = "scores", style = "precision")`.

## See also

[`plot.mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md),
[`mfrmr_interval_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_interval_guide.md)
