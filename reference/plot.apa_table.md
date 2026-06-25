# Plot an APA/FACETS table object using base R

Plot an APA/FACETS table object using base R

## Usage

``` r
# S3 method for class 'apa_table'
plot(
  x,
  y = NULL,
  type = c("numeric_profile", "first_numeric"),
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
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

- y:

  Reserved for generic compatibility.

- type:

  Plot type: `"numeric_profile"` (column means) or `"first_numeric"`
  (distribution of the first numeric column).

- main:

  Optional title override.

- palette:

  Optional named color overrides.

- label_angle:

  Axis-label rotation angle for bar-type plots.

- draw:

  If `TRUE`, draw using base graphics.

- ...:

  Reserved for generic compatibility.

## Value

A plotting-data object of class `mfrm_plot_data`.

## Details

Quick visualization helper for numeric columns in
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
output. It is intended for table QA and exploratory checks, not final
publication graphics.

## Interpreting output

- `"numeric_profile"`: compares column means to spot scale/centering
  mismatches.

- `"first_numeric"`: checks distribution shape of the first numeric
  column.

## Typical workflow

1.  Build table with
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md).

2.  Run `summary(tbl)` for metadata.

3.  Use `plot(tbl, type = "numeric_profile")` for quick numeric QC.

## See also

[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
[`summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score", method = "JML", maxit = 30)
tbl <- apa_table(fit, which = "summary")
p <- plot(tbl, draw = FALSE)
p2 <- plot(tbl, type = "first_numeric", draw = FALSE)
if (interactive()) {
  plot(
    tbl,
    type = "numeric_profile",
    main = "APA Numeric Profile (Customized)",
    palette = c(numeric_profile = "#2b8cbe", grid = "#d9d9d9"),
    label_angle = 45
  )
}
} # }
```
