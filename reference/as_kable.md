# Convert an `apa_table` to a `knitr::kable()` object

Renders the table data for direct inclusion in RMarkdown, Quarto, or
HTML reports, wiring the `caption` and `note` slots into the standard
APA placement (caption above, note below). When `kableExtra` is
installed the note is attached as a footer for HTML or LaTeX. Otherwise
the complete rendered table is collapsed to one `knitr_kable` string
before a single note is appended.

Produces a Word / PowerPoint-friendly `flextable` with the caption and
note wired in. Requires `flextable` (in Suggests).

## Usage

``` r
# S3 method for class 'apa_table'
as_kable(x, format = c("pipe", "html", "latex"), digits = 3L, ...)

# S3 method for class 'apa_table'
as_flextable(x, ...)

as_kable(x, ...)

as_flextable(x, ...)
```

## Arguments

- x:

  Object to convert.

- format:

  One of `"pipe"` (default, Markdown), `"html"`, or `"latex"`, passed
  through to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html).

- digits:

  Numeric; passed to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html).

- ...:

  Passed to methods.

## Value

A `knitr_kable` object ready to be printed inline in a report. If
`knitr` is unavailable, emits a message and returns `NULL` invisibly.

A `flextable` object. If `flextable` is unavailable, emits a message and
returns `NULL` invisibly.

The object returned by the selected method. For `as_kable.apa_table()`,
a `knitr_kable` table, with an additional `kableExtra` class for
supported HTML output when a note is attached through that package;
`NULL` if `knitr` is unavailable.

The object returned by the selected method. For
`as_flextable.apa_table()`, a `flextable` ready for
[`flextable::save_as_docx()`](https://davidgohel.github.io/flextable/reference/save_as_docx.html),
or `NULL` if `flextable` is unavailable.

## See also

`as_flextable.apa_table()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

`as_kable.apa_table()`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

`as_kable.apa_table()` for the `apa_table` method; `as_flextable()` for
a `flextable`-targeted alternative;
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for constructing an `apa_table` in the first place.

`as_flextable.apa_table()` for the `apa_table` method; `as_kable()` for
a [`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html)-targeted
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
if (requireNamespace("knitr", quietly = TRUE)) {
  invisible(as_kable(tbl))
}
# Optional workflow; run the example explicitly as shown below.
# example("as_flextable.apa_table", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
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
} # }
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
# Optional integration example (loads additional modelling or rendering packages).
# example("as_flextable", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
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
} # }
```
