# Plot observed-rater severity under a shared-rater RSM

Plot observed-rater severity under a shared-rater RSM

## Usage

``` r
# S3 method for class 'mfrm_random_rater'
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
  intervals = c("none", "normal"),
  ...
)
```

## Arguments

- x:

  A result from
  [`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md).

- draw:

  Logical; `FALSE` returns plot data without opening a device.

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

  `"none"` (default) displays point estimates without automatic
  prediction intervals. `"normal"` explicitly requests the first-order
  approximation from `confint(x, parm = "raters")`; nominal coverage is
  not established. Required for the interval-width precision view and
  sorting by interval width (`sort = "uncertainty"`).

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object with the rater table and settings.
Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
for custom graphics.

## Details

Points are conditional modes of severity relative to the rater
population mean zero; positive values mean stricter ratings. No
individual rater intervals are supplied automatically, including for
earlier saved fits. Explicit normal whiskers are approximate 95%
prediction intervals, not qualified rater classifications. At an
estimated zero variance or with unresolved numerical checks, even
requested whiskers are unavailable.

## See also

[`plot.mfrm_testlet_scores()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_testlet_scores.md)
for view selection and accessible output. The distribution view
summarizes the observed conditional modes, not the assumed rater
population.
