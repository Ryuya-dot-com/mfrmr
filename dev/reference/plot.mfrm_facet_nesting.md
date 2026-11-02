# Plot the pairwise nesting index matrix

Renders the directed nesting index \\1 - H(B \mid A)/H(B)\\ as a heatmap
between facet pairs, highlighting fully nested relationships close to 1.
Colour scale runs from 0 (crossed, white / cold) to 1 (fully nested,
dark).

## Usage

``` r
# S3 method for class 'mfrm_facet_nesting'
plot(
  x,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  An `mfrm_facet_nesting` object.

- preset:

  Plot preset.

- draw:

  Logical; print the `ggplot` figure when `TRUE`.

- ...:

  Reserved.

## Value

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
extracts the rendered nesting matrix and pairwise summary table.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## See also

[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/detect_facet_nesting.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_hierarchical_structure.md).
