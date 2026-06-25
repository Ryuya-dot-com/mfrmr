# Plot a data-description object

Plot a data-description object

## Usage

``` r
# S3 method for class 'mfrm_data_description'
plot(
  x,
  y = NULL,
  type = c("score_distribution", "facet_levels", "missing"),
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
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"score_distribution"`, `"facet_levels"`, or `"missing"`.

- main:

  Optional title override.

- palette:

  Optional named colors (`score`, `facet`, `missing`).

- label_angle:

  X-axis label angle for bar plots.

- draw:

  If `TRUE`, draw using base graphics.

- ...:

  Reserved for generic compatibility.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

This method draws quick pre-fit quality views from
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md):

- score distribution balance

- facet-level structure size

- missingness by selected columns

## Interpreting output

- `"score_distribution"`: bar chart of weighted observation counts per
  score category. Y-axis is `WeightedN` (sum of weights for each
  category). Categories with very few observations (\< 10) may produce
  unstable threshold estimates. A roughly uniform or unimodal
  distribution is ideal; heavy floor/ceiling effects compress the
  measurement range.

- `"facet_levels"`: bar chart showing the number of distinct levels per
  facet. Useful for verifying that the design structure matches
  expectations (e.g., expected number of raters or criteria). Very large
  numbers of levels increase computation time and may require higher
  `maxit` in
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- `"missing"`: bar chart of missing-value counts per input column.
  Columns with non-zero counts should be investigated before
  fitting—rows with missing scores, persons, or facet IDs are dropped
  during estimation.

## Typical workflow

1.  Run
    [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
    before fitting.

2.  Inspect `summary(ds)` and `plot(ds, type = "missing")`.

3.  Check category/facet balance with other plot types.

4.  Fit model after resolving obvious data issues.

## See also

[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
toy <- load_mfrmr_data("example_core")
ds <- describe_mfrm_data(toy, "Person", c("Rater", "Criterion"), "Score")
p <- plot(ds, draw = FALSE)
```
