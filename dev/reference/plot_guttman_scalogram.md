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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
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
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md).

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p)` bundles the scalogram
matrix and the optional unexpected-response overlay.

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

[`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/unexpected_response_table.md)
for the case-level review of the cells flagged in the overlay; [plot(x,
type = "agreement", view =
"heatmap")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
for a complementary rater-pair view of the same residual structure;
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
for the underlying diagnostics bundle.

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_guttman_scalogram", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "guttman", draw = FALSE)
dim(plot_data(p, "matrix"))
# Look for: a clean monotone "staircase" of higher scores in the
#   upper-right triangle and lower scores in the lower-left, once
#   rows are sorted by person ability. Cells circled by the
#   unexpected-response overlay break the staircase and warrant
#   case-level review with `unexpected_response_table()`.
} # }
```
