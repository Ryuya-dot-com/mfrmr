# Main-effects D-study approximation

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
applies a practical D-study projection to the variance components from
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md).
It answers questions such as "what happens to `G` and `Phi` if we use 2,
3, or 4 raters?" without re-fitting the Rasch/MFRM model.

## Usage

``` r
# S3 method for class 'mfrm_generalizability'
mfrm_d_study(
  x,
  design_grid = NULL,
  residual_scaling = c("highest_order", "single_condition", "none", "sensitivity"),
  ...
)

# S3 method for class 'mfrm_fit'
mfrm_d_study(
  x,
  design_grid = NULL,
  object_facet = "Person",
  random_facets = NULL,
  residual_scaling = c("highest_order", "single_condition", "none", "sensitivity"),
  ...
)

# S3 method for class 'mfrm_d_study'
summary(object, ...)
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
  Supply exactly one count column per facet, with unique names and an
  unambiguous one-to-one correspondence. Extra columns, duplicate
  aliases for a facet, or a column serving two facets are refused.
  Counts must be positive integers. When `NULL`, one row using the
  observed number of levels is returned.

- residual_scaling:

  How the collapsed residual variance should be scaled when planned
  facet counts increase. `"highest_order"` treats the residual as
  highest-order person-by-all-conditions/error variance and divides by
  the product of planned counts. `"single_condition"` divides by the
  smallest planned facet count, a sensitivity assumption for variation
  associated with the least-replicated condition. It is not a confidence
  bound. `"none"` leaves the residual unscaled. `"sensitivity"` returns
  all three assumptions for each design row.

- ...:

  Additional arguments passed to
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  when `x` is an `mfrm_fit`. With an already estimated main-effects
  G-study or its D-study summary, unused arguments are rejected. In
  particular, composite `weights` are unsupported here; they require the
  score-component route from
  [`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md).

- object_facet, random_facets:

  Passed to
  [`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
  when `x` is an `mfrm_fit`.

- object:

  A main-effects D-study result.

## Value

An object of class `mfrm_d_study`, a data.frame with one row per design
scenario and columns for planned facet counts, variance terms, projected
`G`, projected `Phi`, interpretation bands, and identification status
inherited from
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md).
`InputRows`, `UsedRows`, and `ExcludedRows` describe the source G-study,
not the planned D-study sample; `GStudyDataSource` identifies their
scope. The `data_usage` attribute retains its row accounting, including
after subsetting. Older source results without accounting have `NA`
counts; they are not assumed to have used all rows. `summary(d)` returns
the coefficient data frame with these saved attributes, rather than
generic per-column descriptive statistics. No intervals or new
variance-component estimates are computed. `GReason`, `PhiReason`,
`ObjectVarianceReason`, `RelativeErrorReason`, `AbsoluteErrorReason` and
`ResidualDivisorReason` explain unavailable quantities; empty strings
mean no calculation failure. Reasons distinguish unidentified targets,
missing/invalid components, zero total variance and numerical range. Fit
cautions remain separate in `IdentificationStatus` and
`IdentificationNote`. `ComponentIdentificationChecked` and the
`component_identification` attribute retain the source design check.

## Details

The projection uses the variance decomposition already estimated by
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md).
For a random measurement facet `j`, main-effect variance contributes
`sigma2_j / n_j` to the absolute-error denominator. Under the fitted
additive model, residual errors are independent across observations. For
a complete future crossing with common facet levels for all persons,
their mean has variance `sigma2_Residual / prod(n_j)`. Facet-wide shifts
cancel from relative comparisons but enter absolute error as
`sum(sigma2_j / n_j)`. This justifies `"highest_order"` within that
model. If omitted interactions actually exist, the fitted residual does
not recover their separate variances or correlations; dividing it by the
product is then an assumption. `"single_condition"` and `"none"` are
alternative planning assumptions, not estimates of these correlations,
confidence bounds, or a guarantee that the true projection lies between
them. The relative-decision denominator uses only this scaled residual
term. Missing or invalid required components leave the affected
coefficient unavailable; they are not zero variance. These are point
projections conditional on estimated components, not uncertainty bounds
or automatic recommendations for sample size. Returned G/Phi retain full
precision, as do the values used for their reference-status labels.
Round only for presentation, after any comparisons.

Error variances are evaluated independently of object variance: they
remain available when object variance is zero or missing. Zero object
variance with positive error gives a coefficient of zero; zero total
variance is undefined. For checked sources, only identified variance
sums enter the output. For example, two confounded facet main effects
can still contribute their identified sum when their planned counts are
equal; unequal counts require the separate, unidentified components.
Coefficients use scaled sums to avoid overflow. A coefficient can
therefore remain calculable even when its error variance exceeds
floating-point range. Such unrepresentable quantities are returned as
`NA` with reasons.

This is a pragmatic D-study planning layer, not a full p x r x i ANOVA
decomposition. If person-by-rater or person-by-item interactions are a
primary estimand, consider
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
and
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
for one or two common random facets, including Person-by-Task,
Person-by-Rater, and Person-by-Rater-by-Task. Those functions also
accept a single score and estimate the corresponding interaction
components explicitly. Changing `residual_scaling` here only explores
assumptions; it does not estimate the omitted interactions.

Pass the result directly to
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
for full projection tables and their assumptions. Newly created results
retain source variance components, estimation settings and observed
facet counts. Reports of older compatible results mark missing source
details `not_recorded`; report creation never reconstructs components or
computes confidence intervals.

The `G` and `Phi` values returned here belong to the
generalizability-theory metric family. They should not be interpreted as
coefficient alpha, omega, KR-20, or IRT marginal/separation reliability,
even though all of those summaries may be displayed on a 0–1 scale in
broader reporting dashboards. They remain on the observed numeric score
scale inherited from
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md),
not the fitted MFRM latent scale.

## References

Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972). *The
dependability of behavioral measurements: Theory of generalizability for
scores and profiles*. Wiley.

Brennan, R. L. (2001). *Generalizability theory*. Springer.
[doi:10.1007/978-1-4757-3456-0](https://doi.org/10.1007/978-1-4757-3456-0)
. This framework does not recover the interaction components omitted by
the source main-effects model.

## See also

[`plot.mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_d_study.md),
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md),
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
if (requireNamespace("lme4", quietly = TRUE)) {
  gt <- mfrm_generalizability(fit)
  ds <- mfrm_d_study(gt, data.frame(Rater = c(2, 3, 4), Criterion = 4))
  ds[, c("n_Rater", "n_Criterion", "G", "Phi",
         "GStatus", "PhiStatus", "IdentificationStatus")]
  # If IdentificationStatus is not "identified", even large G/Phi
  # values remain identification warnings, not decision-ready evidence.
}
#> mfrmr D-study projection
#>   Object of measurement: Person 
#>   Random facets: Rater, Criterion 
#> 
#>   Estimand scale: observed numeric score
#>   G-study rows: 768 input; 768 used; 0 excluded.
#>   Counts start from stored fitted rows; earlier MFRM filtering is not included.
#>   Residual assumption: Divide residual by all facet counts 
#> 
#>  n_Rater n_Criterion         G       Phi
#>        2           4 0.8240540 0.7887498
#>        3           4 0.8753947 0.8447234
#>        4           4 0.9035412 0.8757990
#>   Observed-score planning projections hold estimated variance components fixed.
#>   They do not establish cut-score accuracy or an adequate rating design.
#> 
#>   Note: 0.70 and 0.80 are reference guides, not universal decision rules.
```
