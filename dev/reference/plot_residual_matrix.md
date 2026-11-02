# Person x facet-level standardized-residual matrix

Visualizes the person x element matrix of standardized residuals from
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
as a heatmap. Complements [plot(x, type =
"guttman")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  output. Computed on demand when omitted.

- facet:

  Facet whose levels become the column axis (default `"Rater"`).

- top_n_persons:

  Cap on the number of rows. Defaults to 40 to keep the figure legible;
  persons are kept by largest absolute residual mean.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p)` bundles the residual
`matrix` (rows = Person, columns = facet level) and the long-form `obs`
table.

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[plot(x, type =
"guttman")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"unexpected")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_visual_diagnostics.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_residual_matrix", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "residual_matrix", top_n_persons = 12, draw = FALSE)
dim(plot_data(p, "matrix"))
# Look for: |residual| > 2 or > 3 crosses conventional two- or
#   three-standard-deviation review bands; these are heuristic screens,
#   not calibrated 5% or 1% tests (Wright & Linacre 1994). Repeated
#   high-magnitude cells at one facet level warrant pattern review but
#   do not by themselves establish scoring drift.
} # }
```
