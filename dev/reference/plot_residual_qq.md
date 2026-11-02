# Normal quantile-quantile plot of person standardized residuals

Produces a Q-Q plot of per-person standardized residuals. Under the
fitted Rasch-family model the residuals are approximately N(0, 1), so
deviations from the reference line diagnose distributional misfit that
mean-square summaries may miss.

## Usage

``` r
plot_residual_qq(
  fit,
  diagnostics = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit`.

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  output; required entries are generated internally when absent.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p, "data")` contains `Person`,
`Theoretical`, `Sample` columns.

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

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_residual_qq", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "residual_qq", draw = FALSE)
head(plot_data(p, "data"))
# Look for: points hugging the y = x reference line. Heavy upper-
#   right tails indicate persons whose residual aggregates exceed
#   the standard normal expectation; pair with `plot()`
#   for case-level follow-up. This is an exploratory screen; do
#   not treat tail behaviour as a definitive normality test.
} # }
```
