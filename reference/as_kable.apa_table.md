# Convert an `apa_table` to a `knitr::kable()` object

Renders the table data for direct inclusion in RMarkdown, Quarto, or
HTML reports, wiring the `caption` and `note` slots into the standard
APA placement (caption above, note below). When `kableExtra` is
installed the note is attached as a footer; otherwise the note is
appended as a
[`knitr::asis_output()`](https://rdrr.io/pkg/knitr/man/asis_output.html)
block.

## Usage

``` r
# S3 method for class 'apa_table'
as_kable(x, format = c("pipe", "html", "latex"), digits = 3L, ...)
```

## Arguments

- x:

  An `apa_table` object from
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

- format:

  One of `"pipe"` (default, Markdown), `"html"`, or `"latex"`, passed
  through to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html).

- digits:

  Numeric; passed to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html).

- ...:

  Additional arguments forwarded to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html).

## Value

A `knitr_kable` object ready to be printed inline in a report, or a
message when `knitr` is unavailable.

## See also

[`as_flextable.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_flextable.apa_table.md),
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
if (requireNamespace("knitr", quietly = TRUE)) {
  invisible(as_kable(tbl))
}
```
