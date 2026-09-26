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
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Optional
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  output.

- rater_facet:

  Facet name to use as the "rater" axis (default `"Rater"`).

- ci_level:

  Confidence level for the rater severity panel.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw the composite immediately with
  [`graphics::layout()`](https://rdrr.io/r/graphics/layout.html).

## Value

Invisibly, an `mfrm_plot_data` object whose `data` slot bundles the four
panel data objects under `wright`, `severity`, `threshold`, and
`summary`. Fit readiness is retained in `data$fit_readiness`,
`data$interpretation_status`, and `data$interpretation_note`.

## Interpreting output

Designed as a single-figure Methods or Results draft. The summary panel
prints the model class, sample size, log-likelihood, the canonical MML
IC panel or an explicit ineligibility/legacy label, and the largest
non-Person facet's separation / reliability if available. A fit that has
not passed its numerical, data, design, and stability checks produce one
warning and a visible `"REVIEW ONLY"` label. Resolve that review before
treating the composite as report-ready evidence.

## Session plot defaults

Set `options(mfrmr.plot_preset = "publication")` to choose a session
default for plotting functions that expose the common `preset` argument.
The supported values are `"standard"`, `"publication"`, `"compact"` and
`"monochrome"`. Precedence is an explicit call argument, then the
session option, then `"standard"`. For example, `preset = "standard"`
overrides a session set to `"monochrome"`. Explicit `preset = NULL`
retains the earlier package-default behavior; it does not read the
session option. Invalid session values cause an error only when that
option is needed.

The category-curve, data-quality, fit-review, connectivity and network
routes of [`plot()`](https://rdrr.io/r/graphics/plot.default.html) for
report bundles use the same option through `...`. Plots without a common
`preset` argument, including extended-model plots with their own
`palette` controls, keep their own settings. This option selects a
preset, not a universal theme or a guarantee that all renderers
implement every appearance control identically.

New plot payloads retain the resolved preset for supported saved-data
rendering. Converting an existing payload with
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
uses its saved appearance, even after the session option changes. A call
that creates a new plot from a fit or statistical result uses the
current default. For a reproducible script, supply `preset` explicitly
or set the option in that script. Saving only the fitted model does not
save a session option. No global ggplot theme is changed.

Restore previous settings with
`old <- options(mfrmr.plot_preset = "monochrome")` followed by
`options(old)`. Use `options(mfrmr.plot_preset = NULL)` to remove the
option. The preset changes appearance, not estimates, confidence levels
or diagnostic thresholds.

## See also

[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
(`type = "wright"`),
[`plot_rater_severity_profile()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_severity_profile.md),
[`plot_threshold_ladder()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_threshold_ladder.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300)
p <- plot_apa_figure_one(fit, draw = FALSE)
names(p$data)
#>  [1] "data"                  "title"                 "subtitle"             
#>  [4] "preset"                "plot_name"             "legend"               
#>  [7] "reference_lines"       "fit_readiness"         "interpretation_status"
#> [10] "interpretation_note"  
# }
```
