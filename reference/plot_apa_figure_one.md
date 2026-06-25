# Manuscript-ready four-panel composite (Wright + severity + threshold + summary)

Builds a 2x2 publication composite for an `mfrm_fit`, suitable for a
"Figure 1" in the Rasch-family `RSM`/`PCM` manuscript route. Panels: (1)
Wright map, (2) rater severity profile with CI whiskers, (3) threshold
ladder, (4) a one-line reliability / separation summary block. Each
panel reuses the standalone plot helper so the visual language is
consistent with the rest of the package.

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
`summary`.

## Interpreting output

Designed for a single-figure Methods or Results overview. The summary
panel prints the model class, sample size, log-likelihood, AIC/BIC, and
the largest non-Person facet's separation / reliability if available.

## See also

[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
(`type = "wright"`),
[`plot_rater_severity_profile()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_rater_severity_profile.md),
[`plot_threshold_ladder()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_threshold_ladder.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_apa_figure_one(fit, draw = FALSE)
names(p$data)
}
```
