# Plot saved residual associations and exploratory groups

Compare the full matrix with its thresholded network, then inspect the
clustering tree when requested. Network positions are a deterministic
circle: distance on the page is not a statistical distance. Positive
edges are solid red and negative edges dashed blue; thickness represents
\|r\|. Gray matrix cells denote unavailable correlations. Node colors do
not encode quality. Dendrogram labels append the chosen group number in
square brackets; these numbers are labels, not ranks. Titles and
cautions are retained in
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md),
not printed into the figure.

## Usage

``` r
# S3 method for class 'mfrm_residual_network'
plot(
  x,
  type = c("network", "matrix", "dendrogram"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  A result from
  [`mfrm_residual_network()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_residual_network.md).

- type:

  `"network"`, `"matrix"` or `"dendrogram"`.

- preset:

  Visual preset; see
  [mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md).

- draw:

  Whether to draw with base graphics.

- ...:

  Reserved; unused arguments are rejected.

## Value

Invisibly, an `mfrm_plot_data` containing the selected view, saved
matrix, nodes, pairs, edges, clustering, settings and interpretation
notes. Plotting does not recompute residuals or clustering. Save the
analysis object to redraw every view. The matrix supports
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md).
