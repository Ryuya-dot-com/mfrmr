# Convert an `apa_table` to a `flextable`

Produces a Word / PowerPoint-friendly `flextable` with the caption and
note wired in. Requires `flextable` (in Suggests).

## Usage

``` r
# S3 method for class 'apa_table'
as_flextable(x, ...)
```

## Arguments

- x:

  An `apa_table` object from
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

- ...:

  Additional arguments reserved for future use.

## Value

A `flextable` object, or a message when `flextable` is unavailable.

## See also

[`as_kable.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.apa_table.md),
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

## Examples

``` r
tbl <- structure(
  list(
    table = data.frame(Term = c("Rater A", "Rater B"), Estimate = c(-0.12, 0.18)),
    caption = "Facet estimates",
    note = "Toy values for formatting only."
  ),
  class = "apa_table"
)
if (requireNamespace("flextable", quietly = TRUE)) {
  invisible(as_flextable(tbl))
}
```
