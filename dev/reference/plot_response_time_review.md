# Plot response-time review summaries

Draw or return reusable plot data for a
[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/response_time_review.md)
object. Plot types are descriptive screening views and do not represent
a joint response-time model.

## Usage

``` r
plot_response_time_review(
  x,
  type = c("distribution", "person", "facet", "score"),
  facet = NULL,
  top_n = 25L,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  A `mfrm_response_time_review` object.

- type:

  Plot type: `"distribution"`, `"person"`, `"facet"`, or `"score"`.

- facet:

  Optional facet name when `type = "facet"`.

- top_n:

  Maximum number of person or facet rows to plot.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object. If `FALSE`, return the `ggplot`
  object invisibly without drawing.

- ...:

  Unused.

## Value

Invisibly, a `ggplot` object carrying reusable tables, thresholds,
overview, and interpretation notes accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md).

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/response_time_review.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data_components.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_output_guide.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_response_time_review", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
toy$ResponseTime <- 10 + seq_len(nrow(toy)) %% 6 + as.numeric(toy$Score)
rt <- response_time_review(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", time = "ResponseTime"
)
plot(rt, type = "distribution", draw = FALSE)
plot(rt, type = "person", draw = FALSE)
} # }
```
