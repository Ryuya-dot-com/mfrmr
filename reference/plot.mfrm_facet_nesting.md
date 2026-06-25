# Plot the pairwise nesting index matrix

Renders the directed nesting index \\1 - H(B \mid A)/H(B)\\ as a heatmap
between facet pairs, highlighting fully nested relationships close to 1.
Colour scale runs from 0 (crossed, white / cold) to 1 (fully nested,
dark).

## Usage

``` r
# S3 method for class 'mfrm_facet_nesting'
plot(x, preset = c("standard", "publication", "compact", "monochrome"), ...)
```

## Arguments

- x:

  An `mfrm_facet_nesting` object.

- preset:

  Plot preset.

- ...:

  Reserved.

## Value

Invisibly, the matrix rendered.

## See also

[`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md),
[`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md).
