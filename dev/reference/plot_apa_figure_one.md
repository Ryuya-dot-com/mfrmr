# Manuscript-oriented four-panel draft (Wright + severity + threshold + summary)

Builds a 2x2 draft composite for an `mfrm_fit`, suitable for reviewing a
possible "Figure 1" in the Rasch-family `RSM`/`PCM` manuscript route.
Panels: (1) single-panel FACETS-style Wright map (without CI whiskers),
(2) rater severity profile with CI whiskers, (3) threshold ladder, (4) a
one-line reliability / separation summary block. Each panel reuses the
standalone plot helper so the visual language is consistent with the
rest of the package.

## Usage

``` r
plot_apa_figure_one(
  fit,
  diagnostics = NULL,
  rater_facet = "Rater",
  ci_level = 0.95,
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
  output.

- rater_facet:

  Facet name to use as the "rater" axis (default `"Rater"`).

- ci_level:

  Confidence level for the rater severity panel.

- preset:

  Visual preset.

- draw:

  If `TRUE`, print the composite `ggplot` object.

## Value

Invisibly, a `ggplot` object. `plot_data(p, "data")` bundles the four
panel data objects under `wright`, `severity`, `threshold`, and
`summary`. Fit readiness is retained in `plot_data(p, "fit_readiness")`,
`plot_data(p, "interpretation_status")`, and
`plot_data(p, "interpretation_note")`.

## Interpreting output

Designed as a single-figure Methods or Results draft. The summary panel
prints the model class, sample size, log-likelihood, the canonical MML
IC panel or an explicit ineligibility/legacy label, and the largest
non-Person facet's separation / reliability if available. A fit that has
not passed its numerical, data, design, and stability checks produce one
warning and a visible `"REVIEW ONLY"` label. Resolve that review before
treating the composite as report-ready evidence.

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

[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md)
(`type = "wright"`), [plot(x, type =
"rater_severity")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[plot(x, type =
"thresholds")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_apa_outputs.md).

## Examples

``` r
# Supplementary workflow: run explicitly to keep routine checks brief.
# example("plot_apa_figure_one", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
p <- plot(fit, type = "apa_summary", draw = FALSE)
names(plot_data(p, "data"))
} # }
```
