# Generic for converting objects to a `flextable`

Generic for converting objects to a `flextable`

## Usage

``` r
as_flextable(x, ...)
```

## Arguments

- x:

  Object to convert.

- ...:

  Passed to methods.

## Value

A `flextable` object (concrete return type from the underlying method,
e.g. `[as_flextable.apa_table()]` returns a `flextable` ready for
[`flextable::save_as_docx()`](https://davidgohel.github.io/flextable/reference/save_as_docx.html)).

## See also

[`as_flextable.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_flextable.apa_table.md)
for the `apa_table` method;
[`as_kable()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.md)
for a
[`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html)-targeted
alternative;
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for constructing an `apa_table` in the first place.

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
