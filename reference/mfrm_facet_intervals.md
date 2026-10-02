# Pointwise intervals for fixed facet estimates and contrasts

Describe uncertainty about a fixed facet estimate, such as rater
severity, or a specified difference between two raters. Start from a
supported fitted model; the point estimates stay the same when you
change the interval method.

## Usage

``` r
mfrm_facet_intervals(
  fit,
  facet,
  contrasts = NULL,
  method = c("model", "sandwich"),
  clusters = NULL,
  adjust = FALSE,
  level = 0.95
)

# S3 method for class 'mfrm_facet_intervals'
print(x, ...)

# S3 method for class 'mfrm_facet_intervals'
summary(object, ...)
```

## Arguments

- fit:

  An inference-ready RSM/PCM MML fit from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
  using a fixed standard-normal person distribution, fixed quadrature
  and unit observation weights. Experimental two-family GPCM MML also
  supports `method = "model"` with fixed-grid EM or direct adaptive
  integration; see "Two-family location targets" below. Experimental
  direct MML native locations additionally support estimated
  intercept-only normal RSM/PCM and one-family GPCM with fixed N(0,1) or
  an estimated intercept-only normal population, using fixed or adaptive
  integration; see "Native locations" below for their scope and separate
  numerical checks.

- facet:

  A non-person facet, for example `"Rater"`.

- contrasts:

  Optional numeric matrix with distinct target row names and columns
  named by every level of `facet`. Columns are aligned by name. A row
  with coefficients `c(1, -1, 0)` estimates the first level minus the
  second. By default, each level is reported.

- method:

  `"model"` (default) uses ordinary observed information; `"sandwich"`
  uses independent-cluster marginal-likelihood scores. The experimental
  native-location and two-family extensions support only `"model"`;
  sandwich support remains limited to the ordinary fixed-population
  RSM/PCM route.

- clusters:

  For sandwich inference, an optional data frame with exactly one row
  per fitted person and complete `Person` and `Cluster` identifiers.
  Without it, persons are the independent units. A larger cluster could
  be a school or clinic if different schools or clinics are independent.
  A person cannot be split across clusters. Supply original person
  labels, even when the input person column has another name.

- adjust:

  Logical; with `method = "sandwich"`, optionally multiply the
  covariance by `G/(G-1)`, where `G` is the cluster count. Default
  `FALSE`. This scaling does not guarantee small-sample coverage.

- level:

  Pointwise confidence level, strictly between zero and one.

- x, object:

  An object returned by `mfrm_facet_intervals()`.

- ...:

  Unused by print and summary methods.

## Value

An `mfrm_facet_intervals` object with `table`, selected target
`covariance`, `model_covariance`, free-parameter `parameter_covariance`,
`model_parameter_covariance`, `person_scores`, `cluster_scores`, the
`clusters` mapping, exact `contrasts`, `settings`, and source `fit`. The
model-based SE and interval remain alongside the selected method. Score
rows are derivatives of a person's marginal log likelihood, not observed
category scores or ability estimates. Scores are absent for
`method = "model"`. When weak information passes numerical refinement,
`cautions` and `information_review` retain the warning and checks.
`InferenceCaution` also accompanies the interval table when applicable.
Two-family results additionally retain `checks`, `numerical_checks`,
`score_rank`, source identity, scale references and interval refusal
reasons. Their table includes `CIEligible`; failed numerical checks
leave bounds and SEs missing while preserving the fitted point
estimates. Native-location results retain checks, numerical comparisons,
full and target covariance, target Jacobian and source identity, without
an empirical Person-score rank requirement.

## Details

Compare ordinary observed-information intervals with a sandwich
covariance that treats a person's complete response vector, or an
explicitly declared larger cluster, as the independent sampling unit.
Estimates are not refitted.

For cluster score `s_g` and observed negative-log-likelihood Hessian
`H`, the unadjusted sandwich is
`solve(H) %*% sum_g(s_g %*% t(s_g)) %*% solve(H)`. Scores aggregate all
responses of a person before forming the outer products; grouping
individual rating rows would be a different and incorrect calculation
for this marginal likelihood. The full covariance is transformed through
the fitted constraints and requested contrasts. Both methods use normal
critical values. No automatic method selection, multiplicity adjustment
or significance flag is supplied.

The sandwich requires many independent sampling units and appropriate
regularity. It permits dependence within the declared unit but does not
establish independence between units. A small number of units can give
poor intervals even with nonsingular covariance. If their scores do not
span the free-parameter space, sandwich intervals are unavailable; point
estimates and the reason remain. For ordinary fixed-population RSM/PCM,
singular/regularized observed information or an ineligible source fit
causes an error. Targets fixed by constraints have no inferential
interval. Known anchors exclude anchor uncertainty. An ill-conditioned
but numerically verified unregularized inverse can be used with a
warning. Successful inversion does not establish reliable normal
intervals. Review interval width, boundary proximity and quadrature
sensitivity; changing to sandwich covariance does not remove this
concern.

## Native locations

For estimated intercept-only normal RSM/PCM and one-family GPCM MML,
`method = "model"` supplies experimental pointwise normal intervals for
locations or contrasts on the model's native ability scale. One-family
GPCM also admits the explicit fixed-N(0,1) restriction
(`gpcm_mml_identification = "fixed_standard_normal"`). Shared or
separate slope/step owners are supported, with geometric-mean-one
relative slopes. Use direct MML, fixed or adaptive integration, unit
weights, additive centered facets and centered steps. Anchors,
interactions, latent regression and sandwich covariance are unavailable
in this added route.

The covariance transforms the inverse full joint marginal information,
including all estimated population, slope and step coordinates. A
location-only inverse or independent printed SEs cannot replace it. The
source, category support, local solution and unregularized information
must pass checks; covariance and score changes are also checked at a
finer integration order at the same fitted parameter vector. This
model-information procedure has no empirical Person-score rank
requirement. A numerical refusal preserves the native point and its
reason with unavailable SE/bounds. Constraint-fixed targets have no
inferential interval.

These numerical checks do not establish sampling coverage, global
identification or robustness to misspecification. Native locations are
not divided by the estimated population SD; standardized targets would
additionally need that SD's uncertainty and cross-covariances. A
location difference need not produce a uniform rating difference with
unequal slopes or steps. The calculation does not refit or change the
saved fit/readiness. Save and attach `ci` with
`mfrm_results(fit, intervals = list(locations = ci), compute = "never")`;
select `plot(res, type = "facet_locations")` for RSM/PCM or
`"gpcm_locations"` for one-family GPCM. Reports and exports retain the
native scale, experimental status and unavailable outputs.

## Two-family location targets

For native two-family GPCM MML, select either modeled non-Person facet.
The first slope owner's locations sum to zero; the second owner's
locations are uncentered on the fixed N(0,1) ability scale. These
locations are measured before multiplication by both slope components.
Increasing a location lowers expected ratings when ability, slopes and
other effects stay fixed. A contrast between actual raters need not
imply a uniform difference in expected ratings: their slopes and
category-step offsets may also differ. Neither zero nor a location
difference defines rater quality or accuracy.

Let `J` expand the free location coordinates under their fitted
constraints and `C` be the requested contrast matrix. The target
covariance is `C J V J' C'`, where `V` is the location block extracted
*after inverting the full joint marginal information*. Slopes, steps and
the other facet remain estimated nuisance parameters. Inverting a
location-only Hessian, adding independent printed SEs, or using the EM
conditional-objective Hessian would omit their joint estimation
uncertainty.

The source fit must pass the same identity, category support, local
score rank, stationarity, full-information and finer-quadrature checks
used for experimental two-family slope intervals in
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).
The full covariance is checked, but passing these numerical checks does
not establish repeated-sample coverage for locations or contrasts.
Evidence for component slope intervals does not qualify these different
targets. These are experimental pointwise normal approximations, with no
sandwich, profile, multiplicity or automatic significance decision. A
failed check retains estimates and reasons with unavailable intervals,
even if the coarse-grid information could be inverted. Constraint-fixed
targets have no interval. The calculation does not refit or change
quadrature in the saved fit.

For example, use `ci <- mfrm_facet_intervals(fit, "Rater")`, or supply a
named zero-sum row of `contrasts` for a difference. Plot and save `ci`
directly, or attach it with
`mfrm_results(fit, intervals = list(locations = ci))` and select
`plot(res, type = "gpcm_locations")`. The model must actually contain
the specified facet. Location intervals do not add category-step/curve
bands, Person uncertainty, Wright maps or tests of rater competence.
Individual two-family rater sheets currently display component-slope
intervals only; use the analyst report for these location and contrast
results.

## What robustness means here

Under model misspecification, the sandwich describes sampling variation
around the working model's limiting parameter (its pseudo-true target).
That target need not equal the generating rater severity or criterion
difficulty. Changing the SE does not correct a biased estimate,
informative assignment, unmodeled population differences or MNAR
nonresponse. Check the model and assignment before interpreting a
severity contrast.

These intervals condition on the observed fixed facet levels. They do
not generalize to replacement raters sampled from a rater population.
They are not multiway crossed-cluster, G/D-study, variance-boundary, EAP
or multiple-imputation intervals. Shared random rater/task effects
spanning the declared clusters violate this one-way independence
assumption. Numerical success is not a general coverage or
rater-diagnosis guarantee. Review quadrature sensitivity separately; the
helper reuses the fitted grid.

## Bounded evaluation

For the RSM/PCM route, a 1,600-dataset comparison used 80/320
independent persons, three fixed raters and two criteria. In its
combined skewed-ability/sparse-design scenario, sandwich coverage of
generating contrasts ranged from 87.0 to 95.5 percent despite all
intervals being available. Coverage of the independently calculated
working-model targets ranged from 93.0 to 97.5 percent. These are ranges
across conditions/contrasts, not uncertainty bounds or universal
operating characteristics. At 200 datasets per condition, MCSE near 95
percent is about 1.54 percentage points. See
[`vignette("mfrmr-facet-intervals", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-facet-intervals.md)
for the design, interpretation and a complete rater-feedback example.

## Save, display and report the selected intervals

Use [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
[`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md)
and
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
to display or extract the saved result, and
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
for tables. Set `title = NULL`, `subtitle = NULL` or `caption = NULL` in
the plot to omit that text. For RSM/PCM, attach one result or a named
list to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
for example
`mfrm_results(fit, intervals = list(raters = intervals), include = c("fit", "plots"), compute = "never")`.
The route `plot(res, type = "facet_raters")` shows the selected
intervals. For two-family GPCM, the corresponding plot type is
`"gpcm_raters"`.
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
retain the method, level, contrast coefficients, cluster mapping and
unavailable outcomes. The source fit must match; replay reloads the
saved results without refitting or recomputing covariance. These
intervals do not replace uncertainty in ordinary Wright maps, fit
diagnostics or Person scores.

## References

Zeileis, A. (2006). Object-oriented computation of sandwich estimators.
*Journal of Statistical Software*, 16(9), 1–16.
[doi:10.18637/jss.v016.i09](https://doi.org/10.18637/jss.v016.i09) .
Zeileis, A., Koell, S. and Graham, N. (2020). Various versatile
variances: An object-oriented implementation of clustered covariances in
R. *Journal of Statistical Software*, 95(1), 1–36.
[doi:10.18637/jss.v095.i01](https://doi.org/10.18637/jss.v095.i01) .

## See also

[`analyze_facet_equivalence()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_facet_equivalence.md),
[`pool_mfrm_imputed()`](https://ryuya-dot-com.github.io/mfrmr/reference/pool_mfrm_imputed.md),
[`plot.mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_facet_intervals.md)

## Examples

``` r
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score")
intervals <- mfrm_facet_intervals(fit, "Rater", method = "sandwich")
summary(intervals)
#>   Target   Estimate         SE       Lower       Upper    ModelSE  ModelLower
#> 1    R01 -0.1838153 0.08409258 -0.34863371 -0.01899684 0.08209147 -0.34471159
#> 2    R02 -0.3088478 0.07488878 -0.45562708 -0.16206847 0.08298771 -0.47150069
#> 3    R03  0.1795027 0.08434452  0.01419045  0.34481490 0.08202273  0.01874108
#> 4    R04  0.3131604 0.09478720  0.12738087  0.49893987 0.08294736  0.15058652
#>    ModelUpper    Status
#> 1 -0.02291895 available
#> 2 -0.14619486 available
#> 3  0.34026428 available
#> 4  0.47573421 available
plot(intervals)
```
