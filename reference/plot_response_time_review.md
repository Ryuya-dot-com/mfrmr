# Plot response-time review summaries

Draw or return reusable plot data for a
[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md)
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

  If `TRUE`, draw with base graphics. If `FALSE`, return only an
  `mfrm_plot_data` object.

- ...:

  Unused.

## Value

Invisibly, an `mfrm_plot_data` object containing the plot table,
thresholds, overview, and interpretation notes.

## See also

[`response_time_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/response_time_review.md),
[`plot_data_components()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data_components.md),
[`mfrmr_output_guide()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_output_guide.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
toy$ResponseTime <- 10 + seq_len(nrow(toy)) %% 6 + as.numeric(toy$Score)
rt <- response_time_review(
  toy, person = "Person", facets = c("Rater", "Criterion"),
  score = "Score", time = "ResponseTime"
)
plot_response_time_review(rt, type = "distribution", draw = FALSE)
plot_response_time_review(rt, type = "person", draw = FALSE)
```
