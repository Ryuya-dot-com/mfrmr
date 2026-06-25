# Person x facet-level standardized-residual matrix

Visualizes the person x element matrix of standardized residuals from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
as a heatmap. Complements
[`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md)
(which shows raw responses) by exposing the residual structure directly:
large positive cells show under-prediction, negative cells
over-prediction.

## Usage

``` r
plot_residual_matrix(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  top_n_persons = 40L,
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
  output. Computed on demand when omitted.

- facet:

  Facet whose levels become the column axis (default `"Rater"`).

- top_n_persons:

  Cap on the number of rows. Defaults to 40 to keep the figure legible;
  persons are kept by largest absolute residual mean.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` whose `data` slot bundles the residual `matrix`
(rows = Person, columns = facet level) and the long-form `obs` table.

## See also

[`plot_guttman_scalogram()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_guttman_scalogram.md),
[`plot_unexpected()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_unexpected.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                 method = "JML", maxit = 30)
p <- plot_residual_matrix(fit, top_n_persons = 12, draw = FALSE)
dim(p$data$matrix)
# Look for: cell values within ~|2| are routine; |residual| > 2 is
#   misfit at the 5% level and |residual| > 3 at the 1% level
#   (Wright & Linacre 1994). Persons with multiple high-magnitude
#   cells across the same facet level point at scoring drift.
}
```
