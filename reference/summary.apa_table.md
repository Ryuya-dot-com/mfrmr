# Summarize an APA/FACETS table object

Summarize an APA/FACETS table object

## Usage

``` r
# S3 method for class 'apa_table'
summary(object, digits = 3, top_n = 8, ...)
```

## Arguments

- object:

  Output from
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

- digits:

  Number of digits used for numeric summaries.

- top_n:

  Maximum numeric columns shown in `numeric_profile`.

- ...:

  Reserved for generic compatibility.

## Value

An object of class `summary.apa_table`.

## Details

Compact summary helper for QA of table data before manuscript export.

## Interpreting output

- `overview`: table size/composition and missingness.

- `numeric_profile`: quick distribution summary of numeric columns.

- `caption`/`note`: text metadata readiness.

## Typical workflow

1.  Build table with
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

2.  Run `summary(tbl)` and inspect `overview`.

3.  Use
    [`plot.apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.apa_table.md)
    for quick numeric checks if needed.

## See also

[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`plot()`](https://rdrr.io/r/graphics/plot.default.html)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
tbl <- apa_table(fit, which = "summary")
summary(tbl)
}
```
