# Generic for converting objects to a `knitr::kable`

Generic for converting objects to a
[`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html)

## Usage

``` r
as_kable(x, ...)
```

## Arguments

- x:

  Object to convert.

- ...:

  Passed to methods.

## Value

A [`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html) object
(concrete return type from the underlying method, e.g.
`[as_kable.apa_table()]` returns a `kableExtra` object when the package
is installed).

## See also

[`as_kable.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_kable.apa_table.md)
for the `apa_table` method;
[`as_flextable()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_flextable.md)
for a `flextable`-targeted alternative;
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
if (requireNamespace("knitr", quietly = TRUE)) {
  invisible(as_kable(tbl))
}
```
