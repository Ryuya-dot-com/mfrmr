# Plot descriptive posterior predictive residual summaries

Compare residual summaries across selected groups without reference
cutoffs.

## Usage

``` r
# S3 method for class 'mfrm_response_diagnostics'
plot(
  x,
  facet = NULL,
  style = c("paired", "scatter"),
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

  Saved
  [`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
  output.

- facet:

  One recorded grouping column; default is the first.

- style:

  `"paired"` connects each group's Infit and Outfit on a common axis.
  `"scatter"` plots Infit against Outfit; labels identify groups.

- draw:

  `FALSE` returns plot data without opening a device.

- palette:

  `"accessible"` uses blue circles and orange triangles; `"mono"`
  retains distinct symbols in black. No red/green warning scale.

- title, caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title, show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show group labels. Unavailable groups keep their labels in the paired
  view; both views retain all rows in
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- ...:

  Unused; ordinary-model threshold arguments are not accepted.

## Value

Invisibly, `mfrm_plot_data` with selected measures, display settings,
notes and alternative text.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
converts either view.

## Details

The response probabilities integrate the latent effects conditional on
the same observed responses and fixed calibration. These are descriptive
summaries, not ordinary plug-in Infit/Outfit. Neither an expectation of
one nor a universal acceptable range is established. No interval,
warning region or statistical test is drawn. Hiding annotations changes
only the display;
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
retains the probability definition and limitations.
