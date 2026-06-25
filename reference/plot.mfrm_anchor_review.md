# Plot an anchor-review object

Plot an anchor-review object

## Usage

``` r
# S3 method for class 'mfrm_anchor_review'
plot(
  x,
  y = NULL,
  type = c("issue_counts", "facet_constraints", "level_observations"),
  main = NULL,
  palette = NULL,
  label_angle = 45,
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"issue_counts"`, `"facet_constraints"`, or
  `"level_observations"`.

- main:

  Optional title override.

- palette:

  Optional named colors.

- label_angle:

  X-axis label angle for bar plots.

- draw:

  If `TRUE`, draw using base graphics.

- ...:

  Reserved for generic compatibility.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

Base-R visualization helper for anchor-review outputs.

## Interpreting output

- `"issue_counts"`: volume of each issue class.

- `"facet_constraints"`: anchored/grouped/free mix by facet.

- `"level_observations"`: observation support across levels.

## Typical workflow

1.  Run
    [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

2.  Start with `plot(review, type = "issue_counts")`.

3.  Inspect constraint and support plots before fitting.

## See also

[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
p <- plot(review, draw = FALSE)
```
