# Generalizability-theory variance decomposition for an MFRM design

Re-fits the rating data underlying an `mfrm_fit` as a crossed
random-effects model
`Score ~ 1 + (1 | Person) + (1 | Facet1) + ... + Residual` via
[`lme4::lmer`](https://rdrr.io/pkg/lme4/man/lmer.html), and returns the
canonical G-theory variance components plus G / Phi coefficients. Useful
when reviewers ask for a generalizability-theory complement to the
Rasch-style separation / reliability statistics that
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
already emits.

## Usage

``` r
mfrm_generalizability(
  fit,
  data = NULL,
  object_facet = "Person",
  random_facets = NULL,
  reml = TRUE
)
```

## Arguments

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- data:

  Optional data frame. When `NULL`, the rating data stored on
  `fit$prep$data` is used.

- object_facet:

  Facet that plays the role of the "object of measurement" – typically
  `"Person"` (default).

- random_facets:

  Character vector of non-person facets to treat as random conditions of
  measurement. Default uses every facet other than `object_facet`.

- reml:

  Logical, passed to
  [`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html) (default
  `TRUE`).

## Value

An object of class `mfrm_generalizability` with:

- `variance_components`:

  One row per random effect plus residual, with columns `Source`,
  `Variance`, and `ProportionVariance`.

- `coefficients`:

  One-row data frame with `G` (generalizability coefficient, relative
  decision) and `Phi` (dependability coefficient, absolute decision),
  coefficient status labels, and the identification status of the fitted
  random-effects model.

- `design`:

  Description of the crossed-random model.

## Interpretation

- `G` is appropriate for **relative** decisions (rank-ordering persons):
  `G = sigma2(p) / (sigma2(p) + sigma2(Residual))`.

- The reported `Phi` is appropriate for **absolute** decisions
  (cut-score classification):
  `Phi = sigma2(p) / (sigma2(p) + sigma2(facet main effects) + sigma2(Residual))`,
  before D-study scaling.

- Use
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  to project `G` / `Phi` under planned numbers of raters, items,
  criteria, or other random measurement facets.

- Reporting bands follow Brennan (2001): G / Phi \>= 0.8 for high-stakes
  decisions, \>= 0.7 for routine reporting.

## Limitations

This helper formulates the random-effects model with main effects only
(`Score ~ 1 + (1|Person) + (1|Facet1) + ... + Residual`); no explicit
`(1 | Person:Rater)`, `(1 | Person:Criterion)`, or
`(1 | Rater:Criterion)` interaction terms are estimated. All two-way and
higher interaction variance is therefore folded into the `Residual` term
– the standard one-observation-per-cell approximation – which can bias
`G` downward when person x facet interactions are substantively large.
This function reports the one-observation-per-cell baseline.
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
applies D-study scaling, including residual-scaling sensitivity checks,
to the same simplified variance-component decomposition. Because
person-by-facet interaction terms are not estimated separately, D-study
projections remain practical planning evidence rather than a replacement
for a fully specified G-theory design. Boundary or singular `lme4` fits
are retained as diagnostic evidence but are not treated as
high-stakes-ready G/D-study evidence.

## References

- Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972).
  *The dependability of behavioral measurements: Theory of
  generalizability for scores and profiles*. Wiley.

- Brennan, R. L. (2001). *Generalizability theory*. Springer.

## See also

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 30)
if (requireNamespace("lme4", quietly = TRUE)) {
  gt <- mfrm_generalizability(fit)
  gt$variance_components
  # Look for: a Person variance component well above any single
  #   non-person facet's variance share. Large rater or criterion
  #   variance shares mean those conditions add measurement error
  #   relative to person spread.
  gt$coefficients
  # Look for: G >= 0.7 for routine reporting, >= 0.8 for high-stakes.
  #   G < Phi means absolute decisions are noisier than relative
  #   decisions; review whether facet main effects need anchoring.
  # Always check IdentificationStatus before using the bands:
  gt$coefficients[, c("G", "Phi", "GStatus", "PhiStatus",
                      "IdentificationStatus")]
  gt$design$identification_note
  # If IdentificationStatus is not "identified", treat G/Phi as
  # design-review evidence rather than high-stakes-ready reliability.
}
} # }
```
