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
# \donttest{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
p <- plot_rater_severity_profile(fit, draw = FALSE)
head(p$data$data)
#>   Level   Estimate         SE      CI_Lower     CI_Upper   Band
#> 1   R02 -0.3287963 0.09769808 -0.5202810670 -0.137311629 gentle
#> 2   R01 -0.1957561 0.09730123 -0.3864630271 -0.005049222 gentle
#> 3   R03  0.1910876 0.09724282  0.0004951599  0.381680000 gentle
#> 4   R04  0.3334649 0.09763161  0.1421104554  0.524819330 gentle
# }
```
