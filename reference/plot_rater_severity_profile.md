# Plot per-rater severity ranking with confidence interval whiskers

Ranks the levels of a chosen rater facet by estimated severity and draws
each level as a horizontal CI whisker around the point estimate.
Optional gentle / strict guidance bands at `+/-0.5` and `+/-1.0` logit
relative to the centred mean make rater calibration easy to read for
training feedback.

## Usage

``` r
plot_rater_severity_profile(
  fit,
  diagnostics = NULL,
  facet = "Rater",
  ci_level = 0.95,
  show_bands = TRUE,
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
  output. When omitted, `diagnose_mfrm(fit, residual_pca = "none")` is
  run internally.

- facet:

  Facet name to plot (default `"Rater"`). Any non-Person facet name is
  accepted.

- ci_level:

  Confidence level used for the whiskers (default `0.95`). Bounds use
  `+/- z * ModelSE`.

- show_bands:

  Logical. When `TRUE` (default) draw shaded `+/-0.5` (gentle) and
  `+/-1.0` (strict) logit guidance bands.

- preset:

  Visual preset.

- draw:

  If `TRUE`, draw with base graphics.

## Value

An `mfrm_plot_data` object whose `data` slot contains columns `Level`,
`Estimate`, `SE`, `CI_Lower`, `CI_Upper`, `Band`.

## Interpreting output

The vertical reference line at zero is the sum-to-zero centring point.
Levels well within `+/- 0.5 logit` (gentle band) are typically
interchangeable in operational scoring; levels outside `+/- 1.0 logit`
(strict band) deserve targeted training or anchoring.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md),
[`plot_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_facet_equivalence.md).

## Examples

``` r
if (FALSE) { # interactive()
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
p <- plot_rater_severity_profile(fit, draw = FALSE)
head(p$data$data)
}
```
