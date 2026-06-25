# Project G-theory coefficients under alternative D-study designs

`mfrm_d_study()` applies a practical D-study projection to the variance
components from
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md).
It answers questions such as "what happens to `G` and `Phi` if we use 2,
3, or 4 raters?" without re-fitting the Rasch/MFRM model.

## Usage

``` r
mfrm_d_study(
  x,
  design_grid = NULL,
  object_facet = "Person",
  random_facets = NULL,
  residual_scaling = c("highest_order", "single_condition", "none", "sensitivity"),
  ...
)
```

## Arguments

- x:

  Output from
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  or an `mfrm_fit`. If an `mfrm_fit` is supplied,
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  is called first.

- design_grid:

  Data frame or named list giving planned counts for each random
  measurement facet. Column names may be the facet names themselves (for
  example `Rater`) or `n_` plus the facet name (for example `n_Rater`).
  When `NULL`, one row using the observed number of levels is returned.

- object_facet, random_facets:

  Passed to
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  when `x` is an `mfrm_fit`.

- residual_scaling:

  How the collapsed residual variance should be scaled when planned
  facet counts increase. `"highest_order"` treats the residual as
  highest-order person-by-all-conditions/error variance and divides by
  the product of planned counts. `"single_condition"` divides by the
  smallest planned facet count, a conservative sensitivity check when
  unmodeled person-by-one-facet interactions may dominate. `"none"`
  leaves the residual unscaled. `"sensitivity"` returns all three
  assumptions for each design row.

- ...:

  Additional arguments passed to
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  when `x` is an `mfrm_fit`.

## Value

An object of class `mfrm_d_study`, a data.frame with one row per design
scenario and columns for planned facet counts, variance terms, projected
`G`, projected `Phi`, interpretation bands, and identification status
inherited from
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md).

## Details

The projection uses the variance decomposition already estimated by
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md).
For a random measurement facet `j`, main-effect variance contributes
`sigma2_j / n_j` to the absolute-error denominator. The residual term
contains unmodeled person-by-facet and higher-order interaction variance
in the current simplified G-study, so the selected `residual_scaling`
assumption is reported explicitly. The relative-decision denominator
uses only this scaled residual term.

This is a pragmatic D-study planning layer, not a full p x r x i ANOVA
decomposition. If person-by-rater or person-by-item interactions are a
primary estimand, use `residual_scaling = "sensitivity"` and treat the
output as planning evidence; fit a fully crossed G-theory model
externally when those interaction components must be estimated
separately.

The `G` and `Phi` values returned here belong to the
generalizability-theory metric family. They should not be interpreted as
coefficient alpha, omega, KR-20, or IRT marginal/separation reliability,
even though all of those summaries may be displayed on a 0–1 scale in
broader reporting dashboards.

## References

Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972). *The
dependability of behavioral measurements: Theory of generalizability for
scores and profiles*. Wiley.

Brennan, R. L. (2001). *Generalizability theory*. Springer.

## See also

[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
if (requireNamespace("lme4", quietly = TRUE)) {
  gt <- mfrm_generalizability(fit)
  ds <- mfrm_d_study(gt, data.frame(Rater = c(2, 3, 4), Criterion = 4))
  ds[, c("n_Rater", "n_Criterion", "G", "Phi",
         "GStatus", "PhiStatus", "IdentificationStatus")]
  # If IdentificationStatus is not "identified", even large G/Phi
  # values remain identification warnings, not high-stakes evidence.
}
} # }
```
