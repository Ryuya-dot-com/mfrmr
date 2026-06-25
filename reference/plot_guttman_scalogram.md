# Guttman-style scalogram of person x item observed responses

Draws a person x item (or person x facet-level) matrix coloured by
observed category, with rows ordered by person measure and columns
ordered by location measure. Unexpected responses (those that fall far
from the expected category at a given theta) are highlighted with a
heavy border so the visual reads as a Rasch-convention Guttman
scalogram.

## Usage

``` r
plot_guttman_scalogram(
  fit,
  diagnostics = NULL,
  column_facet = NULL,
  top_n_persons = 40L,
  highlight_unexpected = TRUE,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output; used to pick up unexpected-response flags when available.

- column_facet:

  Facet name used for the columns. Default `"Criterion"` when the fit
  contains it, otherwise the last entry of `fit$config$facet_names`.

- top_n_persons:

  Maximum number of persons shown (default `40`). Persons closest to the
  median measure are retained when the population exceeds this cap.

- highlight_unexpected:

  Logical. When `TRUE` (default), draw a heavy border around cells
  flagged as unexpected by
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md).

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object whose `data` slot bundles the scalogram
matrix and the optional unexpected-response overlay.

## See also

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md)
for the case-level review of the cells flagged in the overlay;
[`plot_rater_agreement_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_agreement_heatmap.md)
for a complementary rater-pair view of the same residual structure;
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
for the underlying diagnostics bundle.

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_guttman_scalogram(fit, draw = FALSE)
dim(p$data$matrix)
# Look for: a clean monotone "staircase" of higher scores in the
#   upper-right triangle and lower scores in the lower-left, once
#   rows are sorted by person ability. Cells circled by the
#   unexpected-response overlay break the staircase and warrant
#   case-level review with `unexpected_response_table()`.
}
```
