# Compare bootstrap and ordinary random-rater intervals

Compare bootstrap and ordinary random-rater intervals

## Usage

``` r
# S3 method for class 'mfrm_random_rater_intervals'
plot(
  x,
  level = x$settings$level,
  method = c("studentized", "error"),
  comparison = TRUE,
  draw = TRUE,
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
  [`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md).

- level:

  Nominal pointwise coverage; defaults to the saved level.

- method:

  `"studentized"` or `"error"`; see
  [`mfrm_random_rater_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_random_rater_intervals.md).

- comparison:

  Show ordinary normal intervals from the same source fit.

- draw:

  `FALSE` returns plotted data without opening a device.

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

Invisibly, an `mfrm_plot_data` object with exact bounds, availability,
settings and the source estimates. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics.

## Details

Arrows identify unbounded bootstrap endpoints. Their displayed ends are
plot limits, not finite interval limits. Ordinary intervals never
replace an unbounded bootstrap interval. These are pointwise prediction
intervals for realized rater effects, not a rater-quality
classification.

## See also

[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet_scores.md)
for display controls and accessible output. Bootstrap comparisons retain
the interval view.
