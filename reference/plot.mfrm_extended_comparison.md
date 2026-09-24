# Plot matched facet effects or posterior predictions across MFRMs

Plot matched facet effects or posterior predictions across MFRMs

## Usage

``` r
# S3 method for class 'mfrm_extended_comparison'
plot(
  x,
  style = c("paired", "difference"),
  facet = NULL,
  draw = TRUE,
  palette = c("accessible", "mono"),
  title = NULL,
  caption = NULL,
  show_title = TRUE,
  show_notes = TRUE,
  show_labels = metric %in% c("effects", "infit", "outfit"),
  text_scale = 1,
  point_size = 2.5,
  metric = c("effects", "expected_score", "variance", "infit", "outfit", "probability",
    "person"),
  category = NULL,
  ...
)
```

## Arguments

- x:

  A descriptive extended-model result from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

- style:

  `"paired"` plots comparison against reference with an equality line.
  `"difference"` plots comparison minus reference against their mean.

- facet:

  Panels to display; `NULL` includes all. For effects and group indices
  these are facet names; for row moments the panel is
  `"Selected ratings"`; for probabilities it is `"Score k"` for category
  k.

- draw:

  `FALSE` returns plot data without opening a device.

- palette:

  `"accessible"` uses blue points and a dashed grey reference; `"mono"`
  uses dark grey points. Meaning does not depend on colour.

- title, caption:

  `NULL` uses the default text; a string replaces it; `""` removes it.
  Interpretation notes remain in the saved plot data.

- show_title, show_notes:

  Show the title and caption, respectively. `FALSE` hides text without
  deleting its metadata.

- show_labels:

  Show matched IDs beside the points. Defaults to `TRUE` for effects and
  group indices, `FALSE` for rating-level moments and probabilities.
  Consult the retained table when labels are hidden.

- text_scale:

  Positive multiplier for text size.

- point_size:

  Positive point size in ggplot millimetres; base graphics use the
  corresponding relative size (2.5 is the default).

- metric:

  `"effects"` compares centered facet locations (default).
  `"expected_score"`, `"variance"`, `"infit"`, `"outfit"` and
  `"probability"` require saved `response_diagnostics` in
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
  These compare the same posterior predictive target in original score
  units, squared score units, descriptive mean squares or probabilities.
  `"person"` requires saved `person_scores` and compares EAPs centered
  at each fitted population mean, in logits. No difference interval is
  drawn.

- category:

  Numeric score categories to display with `metric = "probability"`;
  `NULL` includes all categories.

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object with source effects, checks,
interpretation notes and a text alternative.
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
supports further styling without estimation. Both renderers respect the
display controls.

## Details

Points are centered at the unweighted mean within each complete matched
facet. These displays compare fitted summaries, including shrinkage,
rather than testing differences or choosing a better model. The
equality/zero line is a descriptive reference. No difference intervals
or limits of agreement are computed. Unavailable rows remain in plot
data. Select `facet` or use `show_labels = FALSE` for crowded displays.

Predictive quantities are not centered. Each row label maps through
`data$response_events` and the comparison's `responses$rows`, which
retain both original input row numbers. Infit/Outfit use selected rows
in each group; posterior conditioning retains all observed source
ratings. Smaller residual indices do not establish better prediction or
model adequacy. There are no ordinary fit cutoffs, tests or automatic
ranking.
