# Main-effects generalizability approximation for an MFRM design

Re-fits the rating data underlying an `mfrm_fit` as a crossed
random-effects model
`Score ~ 1 + (1 | Person) + (1 | Facet1) + ... + Residual` via
[`lme4::lmer`](https://rdrr.io/pkg/lme4/man/lmer.html), and returns
main-effect variance components, residual variance, and G / Phi
coefficients under this simplified model. Interactions are not estimated
separately. For a G-study including the supported interactions, use
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
with one or two common random facets; it also accepts a single score
column.

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
applies a practical D-study projection to the variance components from
`mfrm_generalizability()`. It answers questions such as "what happens to
`G` and `Phi` if we use 2, 3, or 4 raters?" without re-fitting the
Rasch/MFRM model.

Compare planned facet counts using an existing
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
result. G concerns relative ordering; Phi also includes shifts in
absolute score levels. Larger coefficients mean greater dependability
under the selected model and residual assumption, not proven pass/fail
accuracy.

## Usage

``` r
mfrm_generalizability(
  fit,
  data = NULL,
  object_facet = "Person",
  random_facets = NULL,
  reml = TRUE,
  missing = c("error", "omit")
)

# S3 method for class 'mfrm_generalizability'
mfrm_d_study(
  x,
  design_grid = NULL,
  residual_scaling = c("highest_order", "single_condition", "none", "sensitivity"),
  ...
)

# S3 method for class 'mfrm_d_study'
plot(
  x,
  y = NULL,
  type = c("coefficients", "error_variance", "heatmap", "contour", "surface3d"),
  x_var = NULL,
  y_var = NULL,
  group_var = NULL,
  panel_by = NULL,
  panel_grid = NULL,
  metric = NULL,
  draw = TRUE,
  main = NULL,
  palette = NULL,
  preset = c("standard", "publication", "compact", "monochrome"),
  reference = NULL,
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

- fit:

  An `mfrm_fit` from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- data:

  Optional data frame. When `NULL`, the rating data stored on
  `fit$prep$data` is used. Required columns are the selected facets and
  `Score`. Scores must be numeric or numeric character/factor labels;
  nonnumeric labels and infinite values are refused. Use `NA` for
  missing values. Facet labels must be nonblank; `Score` and `Residual`
  are reserved and cannot be facet names.

- object_facet:

  Passed to `mfrm_generalizability()` when `x` is an `mfrm_fit`.

- random_facets:

  Passed to `mfrm_generalizability()` when `x` is an `mfrm_fit`.

- reml:

  Logical, passed to
  [`lme4::lmer()`](https://rdrr.io/pkg/lme4/man/lmer.html) (default
  `TRUE`).

- missing:

  Either `"error"` (default) or `"omit"`. Missing scores or selected
  facet values stop the analysis by default. Explicit omission fits only
  complete rows and records the excluded row positions and missing
  columns. Missingness in unselected columns does not exclude a row.

- x:

  An
  [`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md)
  result.

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

  Reserved for method compatibility.

- y:

  Reserved for method compatibility.

- type:

  `"coefficients"` for G/Phi curves, `"error_variance"` for error
  variance curves, or `"heatmap"`, `"contour"`, or `"surface3d"` for one
  metric over two facet counts. Error variance is in squared score
  units, not SEM. Lower error variance is better.

- x_var:

  Planned-count columns such as `"n_Rater"`. The default horizontal axis
  is the first count column; surface plots use the next column on the
  other axis. The two axes must differ.

- y_var:

  Planned-count columns such as `"n_Rater"`. The default horizontal axis
  is the first count column; surface plots use the next column on the
  other axis. The two axes must differ.

- group_var:

  Optional additional column distinguishing curves. All non-horizontal
  facet counts and residual assumptions remain separate within each
  panel, including when `group_var` is supplied.

- panel_by:

  One column defining panels, or `NULL`.

- panel_grid:

  One or two columns defining panels. Use this or `panel_by`, not both.
  Surface plots require every other facet count and residual assumption
  to be constant within each panel. Subset the result or add panels when
  they vary; they cannot be silently averaged or overlaid.

- metric:

  Optional selection from `"G"`, `"Phi"`, `"RelativeErrorVariance"`, or
  `"AbsoluteErrorVariance"`, compatible with `type`. Surface plots
  require one metric and default to `"Phi"`.

- draw:

  Draw when `TRUE`; `FALSE` only returns plot data.

- main:

  Optional plot title.

- palette:

  Optional colors.

- preset:

  Plot style: `"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`.

- reference:

  Optional distinct finite numeric reference values for curves, between
  0 and 1 for coefficients or nonnegative for error variance. `NULL`
  draws no guides. Not supported for surface plots.

- object:

  A main-effects D-study result.

## Value

An object of class `mfrm_generalizability` with:

- `variance_components`:

  One row per random effect plus residual, with columns `Source`,
  `Variance`, `ProportionVariance`, and `Identified`. When `Identified`
  is false, the fitted allocation and its proportion are not uniquely
  determined by the source design.

- `coefficients`:

  One-row data frame with `G` (generalizability coefficient, relative
  decision) and `Phi` (dependability coefficient, absolute decision),
  coefficient status labels, and the identification status of the fitted
  random-effects model. `GReason` and `PhiReason` explain missing
  coefficients; an empty reason means the point is calculable.
  `ComponentIdentificationChecked` records the design check.

- `design`:

  Description of the crossed-random model. `component_identification`
  retains the covariance-kernel Gram matrix, rank, scaled eigenvalues,
  null space and numerical tolerance. `fit_status` retains the separate
  lme4 boundary/convergence assessment.

- `data_usage`:

  Input source, omission policy, named `counts` (`InputRows`,
  `UsedRows`, `ExcludedRows`), `excluded_rows`, and `missing_cells`
  (`InputRow`, `Column`). Row positions refer to the supplied data, or
  stored fitted rows when `data = NULL`. They cannot recover rows
  previously removed during MFRM fitting. Counts also accompany the
  coefficient table and D-study projections, including tabular exports;
  `GStudyDataSource` identifies the scope of those counts.

An object of class `mfrm_d_study`, a data.frame with one row per design
scenario and columns for planned facet counts, variance terms, projected
`G`, projected `Phi`, interpretation bands, and identification status
inherited from `mfrm_generalizability()`. `InputRows`, `UsedRows`, and
`ExcludedRows` describe the source G-study, not the planned D-study
sample; `GStudyDataSource` identifies their scope. The `data_usage`
attribute retains its row accounting, including after subsetting. Older
source results without accounting have `NA` counts; they are not assumed
to have used all rows. `summary(d)` returns the coefficient data frame
with these saved attributes, rather than generic per-column descriptive
statistics. No intervals or new variance-component estimates are
computed. `GReason`, `PhiReason`, `ObjectVarianceReason`,
`RelativeErrorReason`, `AbsoluteErrorReason` and `ResidualDivisorReason`
explain unavailable quantities; empty strings mean no calculation
failure. Reasons distinguish unidentified targets, missing/invalid
components, zero total variance and numerical range. Fit cautions remain
separate in `IdentificationStatus` and `IdentificationNote`.
`ComponentIdentificationChecked` and the `component_identification`
attribute retain the source design check.

Invisibly, a `ggplot` object.
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
extracts the scenario `table`, metric `series`, axis/group/panel
settings, and labels.

## Details

The decomposition is on the observed numeric `Score` scale. It does not
use the fitted MFRM latent scale or estimate a latent ordinal G/Phi
coefficient.

Fits the main-effects Gaussian linear mixed model
`Score ~ 1 + (1 | Person) + (1 | Facet1) + ... + Residual`
(`G = sigma2(p) / (sigma2(p) + sigma2(Residual))`; `Phi` adds facet
main-effect variances before D-study scaling). Person-by-facet and
facet-by-facet interactions are omitted and absorbed into `Residual`
(use
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
when interaction components are required).

**Component identification and boundaries**: Linear independence of
observation covariance kernels (after REML intercept projection)
determines `Identified` in `variance_components` and
`design$component_identification` separately from
[`lme4::isSingular()`](https://rdrr.io/pkg/lme4/man/isSingular.html)
(`design$fit_status`). Identified sums can still supply `Phi` when
individual confounded allocations cannot support unequal future D-study
counts (`GStatus`, `PhiStatus`, `IdentificationStatus`; zero total
variance gives `zero_total_variance`).

The projection uses the variance decomposition already estimated by
`mfrm_generalizability()`. For a random measurement facet `j`,
main-effect variance contributes `sigma2_j / n_j` to the absolute-error
denominator. Under the fitted additive model, residual errors are
independent across observations. For a complete future crossing with
common facet levels for all persons, their mean has variance
`sigma2_Residual / prod(n_j)`. Facet-wide shifts cancel from relative
comparisons but enter absolute error as `sum(sigma2_j / n_j)`. This
justifies `"highest_order"` within that model. If omitted interactions
actually exist, the fitted residual does not recover their separate
variances or correlations; dividing it by the product is then an
assumption. `"single_condition"` and `"none"` are alternative planning
assumptions, not estimates of these correlations, confidence bounds, or
a guarantee that the true projection lies between them. The
relative-decision denominator uses only this scaled residual term.
Missing or invalid required components leave the affected coefficient
unavailable; they are not zero variance. These are point projections
conditional on estimated components, not uncertainty bounds or automatic
recommendations for sample size. Returned G/Phi retain full precision,
as do the values used for their reference-status labels. Round only for
presentation, after any comparisons.

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
scale inherited from `mfrm_generalizability()`, not the fitted MFRM
latent scale.

Points represent requested scenarios; connecting lines and contours are
visual guides. Missing estimates remain missing and break curves. If
none are available, inspect the D-study table and source variance
components. No reference lines are drawn by default. Specify
`reference = c(0.70, 0.80)` to reproduce the earlier coefficient guides.
User-chosen guides are not universal acceptance criteria or confidence
bounds; their values and interpretation remain in the returned plot
data. Heatmaps include a numeric color key; exact values remain in the
table.

The main-effects G-study combines unmodeled interactions in its
residual. Different residual-scaling curves describe assumptions, not
confidence bounds. All projections hold estimated components fixed.
Check source fit warnings before interpreting even large coefficients.
For supported designs with separately estimated interactions, including
a single score, use
[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md)
and
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md).

## Session plot defaults

See
[mfrmr_visual_diagnostics](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)
for `options(mfrmr.plot_preset)`, argument precedence, and appearance
when saving or reusing a plot.

## References

Bates, D., Maechler, M., Bolker, B., & Walker, S. (2015). Fitting linear
mixed-effects models using lme4. *Journal of Statistical Software,
67*(1), 1–48.
[doi:10.18637/jss.v067.i01](https://doi.org/10.18637/jss.v067.i01) .
Gaussian ML/REML model and optimization. See also
[`lme4::isSingular()`](https://rdrr.io/pkg/lme4/man/isSingular.html) for
the meaning of a singular fitted covariance matrix.

Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972). *The
dependability of behavioral measurements: Theory of generalizability for
scores and profiles*. Wiley.

Brennan, R. L. (2001). *Generalizability theory*. Springer.
[doi:10.1007/978-1-4757-3456-0](https://doi.org/10.1007/978-1-4757-3456-0)
. General G/D framework; the main-effects restriction and
residual-scaling choices here are package-specific limits.

Cronbach, L. J., Gleser, G. C., Nanda, H., & Rajaratnam, N. (1972). *The
dependability of behavioral measurements: Theory of generalizability for
scores and profiles*. Wiley.

Brennan, R. L. (2001). *Generalizability theory*. Springer.
[doi:10.1007/978-1-4757-3456-0](https://doi.org/10.1007/978-1-4757-3456-0)
. This framework does not recover the interaction components omitted by
the source main-effects model.

## See also

[`mfrm_g_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_g_study.md),
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

`plot.mfrm_d_study()`, `mfrm_generalizability()`,
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`recommend_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/recommend_mfrm_design.md),
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)

[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md),
[`plot.mfrm_multivariate_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_multivariate_d_study.md)

## Examples

``` r
# Saved synthetic JML/RSM analysis of example_core.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "core-jml.rds", package = "mfrmr"))
fit <- example_fit$fit
if (requireNamespace("lme4", quietly = TRUE)) {
  gt <- mfrm_generalizability(fit)
  gt$variance_components
  # Look for: a Person variance component well above any single
  #   non-person facet's variance share. Large rater or criterion
  #   variance shares mean those conditions add measurement error
  #   relative to person spread.
  gt$coefficients
  # Compare G and Phi with study-specific requirements; 0.70 and 0.80
  #   are reference guides only. Phi < G means absolute decisions are noisier than relative
  #   decisions; review whether facet main effects need anchoring.
  # Always check IdentificationStatus before using the bands:
  gt$coefficients[, c("G", "Phi", "GStatus", "PhiStatus",
                      "IdentificationStatus")]
  gt$design$identification_note
  # If IdentificationStatus is not "identified", treat G/Phi as
  # design-review evidence rather than decision-ready reliability.
}
#> [1] "No lme4 boundary or singular fit was detected."
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
# After creating ds with mfrm_d_study():
# plot(ds, x_var = "n_Rater", panel_grid = c("Metric", "ResidualScaling"))
# For Rater x Task x Occasion scenarios, separate occasions explicitly:
# plot(ds, type = "heatmap", x_var = "n_Rater", y_var = "n_Task",
#      metric = "Phi", panel_by = "n_Occasion")
# With residual_scaling = "sensitivity", use
# panel_grid = c("n_Occasion", "ResidualScaling") instead.
```
