# Interactively choose data-frame columns before calling `mfrm_results()`

Interactively choose data-frame columns before calling
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)

## Usage

``` r
mfrm_results_interactive(
  data,
  include = "standard",
  output = c("object", "summary", "tables", "html")
)
```

## Arguments

- data:

  A long-format data frame.

- include:

  Passed to
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).

- output:

  Passed to
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).

## Value

The selected
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
output.

## Details

This helper is deliberately opt-in and stops in non-interactive
sessions. It asks the user to choose the person, score, optional weight,
and facet columns, prints reproducible code for the selected roles, then
fits the default legacy-compatible `RSM`/`JML` route before calling
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md).
Use explicit
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
calls in scripts, Quarto documents, tests, and reproducible analyses.

## Why this helper is opt-in

Interactive prompts are useful at the console but are unsafe defaults
for reproducible analysis, package checks, batch scripts, and
manuscripts. The helper therefore prints replay code and leaves the
scripted route explicit.

## See also

[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`run_mfrm_facets()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_mfrm_facets.md)

## Examples

``` r
if (interactive()) {
  toy <- load_mfrmr_data("example_core")
  res <- mfrm_results_interactive(toy)
}
```
