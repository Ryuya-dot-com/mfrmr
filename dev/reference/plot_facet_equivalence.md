# Plot facet-equivalence results

Plot facet-equivalence results

## Usage

``` r
plot_facet_equivalence(
  x,
  diagnostics = NULL,
  facet = NULL,
  type = c("forest", "rope"),
  draw = TRUE,
  ...
)
```

## Arguments

- x:

  Output from
  [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_facet_equivalence.md)
  or an eligible MML
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md)
  object. Legacy equivalence bundles must be recomputed.

- diagnostics:

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
  when `x` is an `mfrm_fit` object.

- facet:

  Facet to analyze when `x` is an `mfrm_fit` object.

- type:

  Plot type: `"forest"` (default) or `"rope"`.

- draw:

  If `TRUE` (default), draw the plot. If `FALSE`, return the prepared
  plotting data.

- ...:

  Reserved for compatibility; use the named plot controls.

## Value

Invisibly, a `ggplot` object. Use
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot_data.md)
for the plotting data and inference/covariance basis. `draw = FALSE`
returns the plot without printing.

## Details

Fit inputs use the same eligibility checks as
[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_facet_equivalence.md).
Bundle inputs display the already calculated results. Both routes
require the current inference and covariance basis, including when
`draw = FALSE`.

## Plot types

- `"forest"` shows each level's deviation from the equally weighted
  facet mean, with covariance-aware deviation intervals and the
  practical region around zero. The raw marginal measure intervals
  remain in the data table.

- `"rope"` shows the normal confidence-distribution mass within that
  region.

## Interpreting output

Both plots describe grand-mean proximity. Colors in the forest plot
indicate whether the deviation interval is inside, outside, or overlaps
the practical region. Neither plot establishes pairwise equivalence or a
Bayesian probability. Read the pairwise TOST results for pair-specific
conclusions.

## Typical workflow

1.  Run
    [`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_facet_equivalence.md)
    with a prespecified practical bound.

2.  Use `type = "forest"` to inspect deviations and their uncertainty.

3.  Use `type = "rope"` for a descriptive proximity view.

## Migration in 0.2.4

This renderer is internal. Use the corresponding
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) route in
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md);
the former exported name is no longer available.

## See also

[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/analyze_facet_equivalence.md)

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_facet_equivalence", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "MML", quad_points = 31, maxit = 150)
eq <- analyze_facet_equivalence(fit, facet = "Rater")
p <- plot(eq, type = "facet_equivalence", view = "forest", draw = FALSE)
pdat <- plot_data(p)
c(pdat$facet, pdat$type)
} # }
```
