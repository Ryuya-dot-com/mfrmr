# Confidence intervals for native fit coefficients and GPCM slopes

By default, compute pointwise Wald intervals in the same free
coordinates as
[coef()](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
and
[vcov()](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md).
Explicit `parm = "slopes"` instead computes intervals for relative or
standardized discriminations and slope comparisons in a native GPCM MML
fit. Model/sandwich methods do not refit; an explicitly requested
profile reoptimizes nuisance parameters at each candidate value. Within
`parm = "slopes"`, the default is a pointwise model-based interval for
each relative slope in a one-family fit. Two-family fits use their fixed
standard-normal scale and the separately checked experimental
approximation described below. A relative slope above one means a
steeper response curve than the geometric-average slope; it is not a
measure of rater agreement or a recommended scoring weight.

## Usage

``` r
# S3 method for class 'mfrm_fit'
confint(
  object,
  parm = NULL,
  level = 0.95,
  scale = c("relative", "standardized"),
  contrasts = NULL,
  contrast_scale = c("ratio", "difference"),
  method = c("model", "sandwich", "profile"),
  clusters = NULL,
  adjust = FALSE,
  simultaneous = c("none", "bonferroni"),
  ...,
  slope = NULL,
  profile_control = list()
)

# S3 method for class 'mfrm_cml_fit'
confint(object, parm = NULL, level = 0.95, ...)

# S3 method for class 'mfrm_comparison_fit'
confint(object, parm = NULL, level = 0.95, ...)
```

## Arguments

- object :

  A native MML or CML result from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Comparison-only CML fits return intervals for their saved targets. JML
  structural-truth intervals are unsupported. Extended models have their
  own methods.

- parm :

  `NULL` (default) selects all entries of `coef(object)`; exact
  coefficient names or positive integer positions select a distinct
  subset in the requested order. `"slopes"` explicitly selects the
  separate GPCM slope interface described below. Inspect
  `names(coef(object))` before selecting coefficients: their names
  identify free parameter coordinates, not all displayed facet levels.

- level :

  Nominal confidence level strictly between zero and one.

- scale :

  `"relative"` (one-family default) keeps geometric mean one.
  `"standardized"` reports population-SD times slope, including
  uncertainty in estimated SD. With covariates, this SD is the residual
  population SD. Two-family fits require `"standardized"` and use it
  when omitted: SD is fixed at one, the first slope family has geometric
  mean one, and the second family is free on that scale.

- contrasts :

  Optional numeric matrix: one named comparison per row, all slope
  levels as named columns, finite nonzero rows summing to zero. For A
  versus B use coefficients 1 and -1, and zero for other levels.

- contrast_scale :

  `"ratio"` exponentiates log-slope contrasts (A/B); `"difference"`
  contrasts positive slopes (A-B) by the delta method.

- method :

  `"model"` uses joint observed information; `"sandwich"` uses Person
  marginal-likelihood scores, optionally grouped into larger clusters.
  Experimental `"profile"` reoptimizes nuisance parameters for one
  specified relative slope, or one two-family component, using a
  chi-square(1) likelihood-ratio cutoff.

- clusters :

  Optional data frame mapping each fitted `Person` once to a nonmissing
  `Cluster`, as in
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
  Persons are independent units by default. Shared random effects across
  clusters are not supported.

- adjust :

  For sandwich covariance only, multiply by G/(G-1) for G clusters;
  default FALSE. This is not a small-sample accuracy guarantee.

- simultaneous :

  `"none"` (default) gives pointwise intervals; `"bonferroni"` adjusts
  for all rows requested in this call. It does not adjust for other
  analyses or post-selection of targets.

- ... :

  Unused; additional arguments are rejected.

- slope :

  For `method = "profile"`, one exact level from
  `object$slopes$SlopeFacet`, selected for the research question.
  Required; profiling all levels implicitly is not supported. For two
  families use a named character value, e.g. `slope = c(Task = "t1")`:
  the name is the fitted owner column and the value is its level. This
  distinguishes equal level labels belonging to different facets.

- profile_control :

  Named list for profiling: `maxit` (400 iterations per optimizer
  stage), `max_steps` (8 bracketing trials per side, including
  contractions after failed trials), and `initial_step` (0.5 on the
  log-slope scale, multiplied by 1.5 during outward expansion). These
  limit numerical searches, not the mathematical parameter space.
  Numerical acceptance tolerances are not relaxed by these settings.

## Value

For coefficient intervals, a numeric matrix with percentage-labelled
lower/upper columns and row names matching the selected coefficients.
Attributes `level`, `method`, `target`, `diagnostics` (estimate, SE,
availability and reason), and available covariance checks/cautions
retain the interpretation. Unidentified CML comparisons remain missing
rows. For `parm = "slopes"`, a matrix of class `mfrm_slope_intervals`
with columns `Lower` and `Upper`, named by slope level. Printing shows
estimates, bounds and any explanations when a bound cannot be
calculated. Attributes `level`, `method`, `target`, and `diagnostics`
describe the result. The diagnostics table includes estimates, log-scale
and positive- scale SEs, `CIEligible`, `CIUse`, and an `InferenceReview`
explaining availability. Unavailable intervals have missing bounds.

## Details

**Coefficient intervals and migration.** Before this API revision,
`confint(fit)` was a GPCM slope-only interface. Use
`confint(fit, parm = "slopes", ...)` to retain that target, its plotting
and report attachments. Omitting `parm` now selects the same coordinates
as `coef(fit)`, including free step offsets, log slopes and estimated
population parameters. Log-variance intervals are not SD intervals;
log-slope intervals are not positive relative-slope intervals. Anchors
and dependent centered levels are absent from these free coordinates.
For labelled facet levels or contrasts, use
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md);
for population targets use
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md).

Coefficient intervals use \\\hat b_j \mathbin{\pm}
z\_{(1+\mathrm{level})/2}\sqrt{V\_{jj}}\\. MML reuses the qualified full
joint covariance from `vcov(fit)`, with the same model/design
restrictions and numerical checks; it can reevaluate information but
does not refit. CML reuses saved conditional information. Its
comparison-only method also respects saved target eligibility, retaining
unavailable targets and reasons. When only CML information fails, finite
numerical points remain in the fit; the default interval matrix contains
missing bounds and its `diagnostics` records the information failure.
The same missing-bound contract applies to eligible ordinary
fixed-population RSM/PCM MML fits whose information is unavailable,
provided the `NA` covariance matrix fits the information memory budget
(see
[mfrm_fit_extractors](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)).
Inspect `coef(fit)` and `summary(fit)` for the retained points and
limitations. No interval is inferred from a finite point alone. Neither
route scores Persons, supplies JML structural-truth inference,
guarantees finite-sample coverage, or includes uncertainty in fixed
anchors. Saved CML covariance is not a new evaluation of the likelihood
or information. Inspect `attr(ci, "diagnostics")` and the saved
checks/cautions before reporting.

All arguments after `level`, other than `...`, belong to
`parm = "slopes"`. Supplying them without that selection is an error, so
a request for a standardized slope, sandwich or profile interval cannot
silently return a free-coordinate Wald interval. Dedicated
extended-model, G/D-study and bootstrap-result
[`confint()`](https://rdrr.io/r/stats/confint.html) methods retain their
documented defaults.

**GPCM slope intervals (`parm = "slopes"`).** Relative slopes have
geometric mean one. If \\\eta\\ denotes the G-1 free log-slope
coordinates and \\J\\ expands them to G sum-zero log slopes, their
covariance is \\J V\_{\eta} J^T\\. Here \\V\_{\eta}\\ is the slope block
of the inverse **full joint** observed information, including estimated
population parameters, rather than the inverse of the slope information
block alone. Each interval is \\\exp(\log(a_g) \mathbin{\pm} z
SE(\log(a_g)))\\.

The current likelihood, gradient and joint information must pass the MML
solution checks. The fit also needs supported score categories,
consistent likelihood metadata, unit observation weights, and at least
31 quadrature points. Regularized, singular, nonconverged or mismatched
results do not receive intervals. These one-family rules differ from the
two-family checks below. Positive curvature is a local check, not a
proof of a global maximum or accurate integration. Use
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
and different starts for consequential results. A known deficit in the
marginal response-distribution dimension or a recorded complete-pattern
first-order rank failure prevents regular inference, even if numerical
differentiation produces a positive Hessian. For example, two binary
items answered once by every Person have only three independent response
probabilities, whereas the default one-family GPCM estimates four free
parameters. More Persons on that same design cannot identify this model.
Returned points are descriptive and unavailable intervals retain the
reason; this is not a general minimum sample-size rule. Absence of this
deficit is only a necessary condition, not proof of identification. A
positive but ill-conditioned information matrix can be used with a
warning when two refined numerical Hessians agree, inversion without
regularization is accurate and a curvature-scaled gradient is small.
Failure of any check keeps inference unavailable. Passing these
numerical checks does not resolve weak information in the data: an
interval may still be extremely wide or unreliable near a boundary.
Warnings are saved in the `cautions` attribute and `InferenceReview`,
and follow printing, default plot subtitles and reports.

Model intervals are asymptotic. Standardized slopes use the full
Jacobian for `log(slope) + log(sigma2)/2`, including cross-covariances.
Ratio contrasts cancel a common population scale. Difference contrasts
use the full joint positive-slope covariance. Extra output includes
`PValue` for zero log contrast (ratio one) or difference zero;
Bonferroni applies to these p-values too. Containment of one for an
individual relative slope is not a pairwise test. The matched
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
LRT tests all relative slopes equal jointly.

Sandwich inference concerns the working model's limiting parameter; it
does not correct bias, informative assignment or a wrong population
model. It needs many independent clusters. Rank-deficient cluster scores
withhold intervals. Scores aggregate complete Person response vectors,
including population-parameter derivatives and the fitted quadrature
method. Small, incomplete correctly specified samples already showed
undercoverage and extremely wide model intervals; see the GPCM scope
vignette. The added methods do not imply universal finite-sample
coverage. For an explicit model-based refit alternative use
[`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md).
Relative and standardized slope differences are different targets; their
interval performance need not be the same. See the GPCM scope vignette
for these distinctions and the observed limits of approximation.

## Fixed anchors in a one-family fit

Model and sandwich slope intervals can use fixed facet anchors and group
means when the joint-information and numerical checks pass. They
condition on the supplied values and do not propagate uncertainty from
their source calibration. A location anchor does not fix a slope or a
step threshold; a fixed group mean does not fix every group member. This
does not extend the separate profile-slope, native-location or
portable-GPCM routes to anchored fits. Those routes retain their own
exclusions.

## Information workspace

The joint-information calculation includes all estimated parameters.
Option `mfrmr.max_information_bytes` (default 256 MiB) budgets eight
dense p-by-p matrices before allocation, or twenty when weak-information
refinement is needed. The extra budget is checked before refinement.
This workspace estimate excludes response data, quadrature and other
allocations and is not a process memory guarantee. A budget refusal
retains unavailable results and a reason. There is no separate
80-parameter inference cutoff. Computation still grows with p.

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
returns the default relative/model 95% calculation in
`parameter_uncertainty$slopes`; `fit_mfrm(attach_diagnostics = TRUE)`
attaches it to `fit$slopes`. `CIEligible` refers to the requested slope
interval only. It does not establish that the fitted likelihood has no
boundary solutions or that intervals for other parameters are valid.
This method recomputes uncertainty for saved fits; it does not trust old
interval flags or alter the supplied object.

## Experimental two-family slope intervals

For the fixed-standard-normal MML model with two slope facets,
`confint(fit, parm = "slopes")` requests log-Wald intervals for both
sets of component slopes. Fixed-grid EM and direct adaptive fits use
their own fitted marginal objective. For adaptive fits, differentiation
includes movement of the quadrature nodes, their scale and the
integration Jacobian; it does not freeze the fitted nodes. It uses the
inverse full observed marginal information, including all locations,
steps and cross-family covariance; it does not invert the frozen EM Q
function or the slope block alone. The first family's log slopes sum to
zero; the second family's slopes are free. The result retains
`SlopeOwner`, `SlopeLevel` and `ScaleReference` separately. A slope of
one has different reference meanings across these families, so no
individual unit-slope p-values are supplied.

The default `method = "model"` uses `scale = "standardized"`, without
contrasts or cluster adjustments. Bonferroni adjusts for all component
slopes in that call. An explicit `method = "profile"` profiles one named
owner/level, retaining both families' scale constraints and reoptimizing
all remaining slopes, locations and steps. The N(0,1) population is
fixed, not an estimated nuisance parameter. Use, for example,
`confint(fit, parm = "slopes", method = "profile", slope = c(Task = "t1"))`.
Replace Task and t1 with your actual column and level names. Both
fixed-grid EM and adaptive direct fits retain their fitted integration
method. Adaptive nodes, scales and Jacobians are recalculated at every
trial; the source's posterior quadrature is not held fixed during
optimization. The interval uses the likelihood loss after nuisance
reoptimization for each constrained log slope. Its chi-square(1)
calibration remains asymptotic. The result preserves owner, level, scale
reference and the same-target Wald comparison through saved plots,
reports and exports. This is a component interval, not an interval for
the product of two slopes. Experimental location and within-facet
contrast intervals use
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
and have their own target-specific limitations. Effective slope-product
and curve intervals, sandwich intervals and model ranking are not
supplied for this model.

Checks reevaluate the source identity, category support, engine-specific
convergence and unregularized marginal information. Person
marginal-score derivatives use steps 1e-5 and 5e-6; after scaling both
by the first matrix's column lengths, their maximum difference must be
at most 1e-6. Empirical score rank is retained at relative SVD
tolerances 1e-10, 1e-8 and 1e-6, with minimum ranks for both derivative
steps in `ScoreRank` and `FineScoreRank`. `ScoreRankDeficient` and an
additional warning flag deficient rank. Full empirical score rank is not
required for the inverse observed Hessian used here: this Hessian is not
the empirical outer product of scores. Rank deficiency alone neither
proves structural nonidentifiability nor makes the model-based interval
unavailable. It does prevent a nonsingular full-parameter empirical
sandwich covariance. The other numerical checks remain necessary, and
small-sample coverage is not established.

The fresh mean marginal score must meet the smaller of `em_score_tol`
and 1e-6 for EM, or 1e-6 for adaptive direct fitting; the full score
scaled by its covariance must have length at most 0.01. Values above
1e-4 retain an additional warning and `OptimizationCaution = TRUE` in
the numerical checks. This length is \\\sqrt{g^T V g}\\, where g is the
full negative-log-likelihood gradient and V its inverse information.
Under a local quadratic approximation it bounds the Newton displacement
of any component log slope in its own SE units. A small residual does
not establish a global optimum or accurate coverage. The infinity-norm
inverse residual must be at most 1e-6. At the saved parameters, the
quadrature order is increased from q to 2q-1 without refitting,
preserving the fitted integration method. The change in the score,
measured with the original covariance, and the spectral norm of the
covariance change, standardized by the original information, must each
be at most 0.01. A failed integration check calls for refitting with
more points.
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
preserves the model, engine and integration controls while comparing
refits; its `intervals` entries retain each order's interval checks for
plotting and reporting. The score workspace is also subject to
`mfrmr.max_information_bytes`.

Integration failure and a slope-boundary problem need different
remedies. More quadrature points can repair inaccurate integration, but
do not ensure a stationary interior solution. For example, let a
second-family slope \\a_r\\ approach zero while keeping \\B_r=a_r b_r\\
and \\T\_{rk}=a_r\tau\_{rk}\\ fixed, where \\b_r\\ is its location and
\\\tau\_{rk}\\ its step. An adjacent logit \\a_t
a_r(\theta-b_t-b_r-\tau\_{rk})\\ then tends to \\-a_t(B_r+T\_{rk})\\.
Response probabilities can have finite limits even while the original
location and step diverge. This differs from setting the slope to zero
with all other parameters fixed. A small slope alone does not prove a
boundary optimum. If such a competing path improves the likelihood,
however, merely increasing quadrature order, relaxing stationarity
checks or regularizing the information does not justify local Wald
intervals at the retained point. Boundary-aware fitting and inference
require separate qualification; these intervals do not implement that
extension.

These are numerical safeguards, not thresholds calibrated for coverage.
Profiling additionally requires absolute low-versus-high quadrature NLL
agreement within 1e-5 and gradient agreement within 1e-4, including at
constrained solutions. A grid adequate for the local Wald approximation
may fail during profiling away from the estimate. Refine and refit the
calibration explicitly; no automatic grid change or Wald fallback
occurs. Source stationarity uses the two-family SE-scaled checks above;
every constrained nuisance solution must pass the absolute 1e-4 gradient
check at both quadrature orders. The shared profile algorithm and
failure rules described below also apply. No superiority to Wald or
general coverage is established, and this does not make a rejected
near-zero-slope source eligible. Two-family profile optimizers use a
per-Person objective scale internally; likelihood ratios and all
acceptance checks use the total likelihood. Passing adaptive log-Wald
checks does not by itself qualify the constrained profile searches;
every candidate still needs its own integration checks.

Every available two-family interval carries an experimental warning:
global identification, absence of boundary alternatives and sampling
coverage remain unestablished. Failed checks retain estimates, missing
bounds and reasons. Inspect `attr(ci, "checks")`,
`attr(ci, "numerical_checks")` and `attr(ci, "score_rank")`, or
`apa_table(ci, which = "checks")`. In `attr(ci, "diagnostics")`,
`CIEligible` records numerical interval availability;
`CoverageQualified = FALSE` separately records that nominal sampling
coverage has not been established for the target and design. This is
neither a coverage estimate of zero nor a numerical-failure flag. Both
fields persist in interval tables, saved results and exports, including
explicitly requested two-family profile intervals. Older saved results
may lack `CoverageQualified`; absence does not establish coverage. Plots
and saved results/reports retain the approximation and its checks. This
calculation does not change the original point estimates or resolve
other warnings about the fitted model.

For an unresolved two-family profile, distinguish the original fit from
the constrained searches. `maxit` in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
controls the original fit; `profile_control = list(maxit = ...)` in
[`confint()`](https://rdrr.io/r/stats/confint.html) controls each
constrained BFGS stage. Inspect
`apa_table(ci, which = "profile_checks")` and
`which = "profile_endpoints"`. Checks at the fitted slope can fail when
the two constrained starts disagree even though the original fit passed
its checks. Increasing `quad_points` requires refitting and addresses
integration discrepancies; it does not resolve disagreement between
starts.
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
compares refits while preserving the model, engine and integration
method. Its `intervals` entries are model-based Wald intervals; they do
not repeat a profile search. To assess a profile on a finer grid,
explicitly call [`confint()`](https://rdrr.io/r/stats/confint.html) with
`parm = "slopes", method = "profile"` on the corresponding entry in
`review$fits`. If the problem is instead a constrained optimizer
reaching its iteration limit, increase `profile_control$maxit`;
increasing the original fit's `maxit` does not change that profile
limit. A search limit or numerical failure does not establish an
infinite interval. With little information about a slope, the original
fit or a constrained search can fail to converge. Obtaining numerical
endpoints after changing search settings does not establish their
sampling coverage. The profile method remains an explicit sensitivity
analysis, not a routine replacement for log-Wald intervals; no coverage
advantage is established.

## One prespecified profile interval for one slope family

Use `confint(fit, parm = "slopes", method = "profile", slope = "R01")`
to investigate how well one relative discrimination is determined.
Choose a level that actually belongs to the fit's slope facet. At each
candidate log slope the sum-zero log-slope constraint is retained,
including when the selected level is the dependent last coordinate. All
remaining slopes, steps, facet locations and estimated population mean
and variance are reoptimized. The current scope requires an estimated
intercept-only normal population, unit weights, and no anchors or
interactions. Standardized slopes, contrasts, JML, covariate populations
and simultaneous profile intervals are not supplied.

The connected local interval solves twice the log-likelihood loss equal
to `qchisq(level, 1)`. This reference is asymptotic and requires a
regular model; replacing Wald intervals does not repair nonregularity or
misspecification. Profile coverage and superiority over Wald have not
been established in mfrmr. This experimental method is for explicit
sensitivity analysis. In small or incomplete datasets, profile limits
can remain unavailable even when Wald limits are returned. Evaluating
coverage only among successful searches can give a misleading impression
of accuracy. A failed search does not prove that a statistical interval
does not exist. See the GPCM scope vignette for examples and limits of
interpretation. This method is not recommended as a routine Wald
replacement.

Two starts (retained and neutral) must agree within 1e-5 NLL. Optimizer
codes, nuisance gradients (at most 1e-4) and higher-order integration
(NLL change at most 1e-5, gradient change and reference gradient at most
1e-4) are checked. The constrained negative-log-likelihood Hessian must
also be finite and positive definite at both quadrature orders: two
starts can otherwise agree at a stationary nuisance maximum or saddle.
The attempt table retains the smallest eigenvalues as
`NuisanceMinEigenvalue` and `ReferenceMinEigenvalue`. Failed or
unresolved curvature leaves the profile point unavailable; no eigenvalue
adjustment is used. This local check is not a global optimum test. For
two slope families, if the initial two optimization stages do not
converge, the search can retry in coordinates scaled by local curvature,
with at most `maxit` iterations in this additional stage. This changes
only how the optimizer moves through the parameter space; constraints
and acceptance checks remain unchanged. The additional stage is
available for up to 64 nuisance parameters; an unavailable or
unsuccessful retry leaves the earlier result and its reason. After two
BFGS tolerances, a stalled converged search may receive the single
curvature-based refinement. Its original optimization stages stay
recorded; the proposal must improve the gradient without worsening the
NLL. Both source and constrained calculations use the fit's integration
method; these checks do not establish that variance or slope boundary
solutions are absent. Endpoint likelihood-ratio residuals must be at
most 1e-4. A better likelihood than the source invalidates both bounds.
After a failed outward trial, the search contracts toward the last
passing point within the same `max_steps` budget. This can locate an
endpoint before the failed trial; it does not skip failed points inside
a bracket or change quadrature. All failed attempts remain saved,
including when both endpoints are found. Unresolved failures, observed
nonmonotonicity or an exhausted search retain missing bounds and
reasons, rather than falling back to Wald or declaring an infinite
interval. A finite search cannot exclude unsampled or disconnected
likelihood regions.

`attr(ci, "profile")` retains all evaluated points, both starts and
optimizer stages, parameter vectors, endpoint statuses and elapsed time.
`attr(ci, "wald")` retains the same-target model-based Wald comparison.
Printing, `plot(ci, type = "profile")`,
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
and saved-results reporting do not repeat fitting. The curve uses a log
slope axis, shows the likelihood cutoff and Wald limits, and does not
connect failed points. Inspect
`apa_table(ci, which = "profile_checks", digits = 8)` for numerical
checks and `which = "profile_endpoints"` for unresolved searches. Large
disagreement with Wald motivates investigating asymmetry and weak
information; it does not establish that either method has better
coverage. Search limits are reported separately from mathematical
unboundedness.

## References

Fischer, S. M., and Lewis, M. A. (2021). A robust and efficient
algorithm to find profile likelihood confidence intervals. Statistics
and Computing, 31, 38.
[doi:10.1007/s11222-021-10012-y](https://doi.org/10.1007/s11222-021-10012-y)
. This implementation uses constrained BFGS searches and root finding,
not their RVM algorithm.

Zeileis, A. (2006). Object-Oriented Computation of Sandwich Estimators.
Journal of Statistical Software, 16(9), 1–16.
[doi:10.18637/jss.v016.i09](https://doi.org/10.18637/jss.v016.i09) .

Zeileis, A., Koll, S., and Graham, N. (2020). Various Versatile
Variances: An Object-Oriented Implementation of Clustered Covariances in
R. Journal of Statistical Software, 95(1), 1–36.
[doi:10.18637/jss.v095.i01](https://doi.org/10.18637/jss.v095.i01) .

## See also

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)

## Examples

``` r
# Compare intervals for free coefficients and relative discriminations.
ratings <- load_mfrmr_data("example_core")
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
  model = "GPCM", method = "MML", step_facet = "Criterion",
  slope_facet = "Rater", rating_min = 1, rating_max = 4,
  category_policy = "preserve", quad_points = 61)
# The default matches coef(fit): steps, locations and log slopes.
coefficients_ci <- confint(fit, level = 0.95)
#> Warning: Native location intervals: pointwise Wald inference assumes a correctly specified, identified regular MML model; numerical eligibility does not guarantee finite-sample coverage. Native ability units are not standardized by the fitted population SD; unequal slopes or steps can make expected-rating differences vary with ability.
head(coefficients_ci)
#>                     2.5%       97.5%
#> Rater[1]     -0.35486952 -0.01858949
#> Rater[2]     -0.47092508 -0.14217597
#> Rater[3]      0.02064554  0.33160792
#> Criterion[1]  0.06913173  0.42192630
#> Criterion[2] -0.57646155 -0.21932332
#> Criterion[3] -0.04765366  0.27785378
attr(coefficients_ci, "diagnostics") # Availability and interpretation
#>        Parameter     Estimate         SE CIEligible    Status
#> 1       Rater[1] -0.186729507 0.08578730       TRUE available
#> 2       Rater[2] -0.306550523 0.08386611       TRUE available
#> 3       Rater[3]  0.176126730 0.07932860       TRUE available
#> 4   Criterion[1]  0.245529019 0.09000027       TRUE available
#> 5   Criterion[2] -0.397892434 0.09110836       TRUE available
#> 6   Criterion[3]  0.115100056 0.08303914       TRUE available
#> 7       steps[1] -1.343394474 0.19483937       TRUE available
#> 8       steps[2] -0.047545143 0.20001461       TRUE available
#> 9       steps[3] -1.283682697 0.21792014       TRUE available
#> 10      steps[4]  0.028934351 0.20157638       TRUE available
#> 11      steps[5] -0.666925136 0.20079137       TRUE available
#> 12      steps[6] -0.339995815 0.20977740       TRUE available
#> 13      steps[7] -1.601532688 0.20111062       TRUE available
#> 14      steps[8]  0.114816584 0.19688086       TRUE available
#> 15 log_slopes[1] -0.082633767 0.13052216       TRUE available
#> 16 log_slopes[2]  0.000937634 0.12718119       TRUE available
#> 17 log_slopes[3]  0.095880541 0.13041047       TRUE available
#> 18       beta[1]  0.002599413 0.14968581       TRUE available
#> 19 log_sigma2[1] -0.054077942 0.25411013       TRUE available
#>                                                                                                                InferenceReview
#> 1  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 2  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 3  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 4  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 5  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 6  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 7  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 8  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 9  Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 10 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 11 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 12 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 13 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 14 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 15 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 16 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 17 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 18 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
#> 19 Pointwise normal approximation in the coef() coordinates; numerical availability does not guarantee finite-sample coverage.
# Explicitly request positive relative slopes for rater comparison:
intervals <- confint(fit, parm = "slopes", level = 0.95)
intervals
#> Approximate 95% interval results: Relative GPCM slopes (geometric mean one)
#>  Level Estimate  Lower Upper    Status
#>    R01   0.9207 0.7129 1.189 Available
#>    R02   1.0009 0.7801 1.284 Available
#>    R03   1.1006 0.8524 1.421 Available
#>    R04   0.9859 0.7609 1.278 Available
#> Joint-information log-Wald approximation 
#> Pointwise intervals.
attr(intervals, "diagnostics")[, c("SlopeFacet", "Estimate",
  "CIEligible", "InferenceReview")]
#> # A tibble: 4 × 4
#>   SlopeFacet Estimate CIEligible InferenceReview                                
#>   <chr>         <dbl> <lgl>      <chr>                                          
#> 1 R01           0.921 TRUE       "Pointwise log-Wald approximation from the inv…
#> 2 R02           1.00  TRUE       "Pointwise log-Wald approximation from the inv…
#> 3 R03           1.10  TRUE       "Pointwise log-Wald approximation from the inv…
#> 4 R04           0.986 TRUE       "Pointwise log-Wald approximation from the inv…
# Relative slopes have geometric mean one. A value above one means a
# steeper response curve, not greater severity or better rater quality.
# Missing bounds need the saved reason; availability is not a coverage test.
plot(intervals)

file <- tempfile(fileext = ".rds")
saveRDS(intervals, file) # Use a lasting path for your analysis
saved <- readRDS(file)
apa_table(saved) # Reuse the intervals without fitting again
#> GPCM inference
#>  SlopeFacet Estimate   SE LogSE CI_Lower CI_Upper CIEligible
#>         R01     0.92 0.12  0.13     0.71     1.19       TRUE
#>         R02     1.00 0.13  0.13     0.78     1.28       TRUE
#>         R03     1.10 0.14  0.13     0.85     1.42       TRUE
#>         R04     0.99 0.13  0.13     0.76     1.28       TRUE
#>                  CIUse
#>  approximate_pointwise
#>  approximate_pointwise
#>  approximate_pointwise
#>  approximate_pointwise
#>                                                                                                                                                                                                                          InferenceReview
#>  Pointwise log-Wald approximation from the inverse full joint MML information. Relative slopes have geometric mean one. Assess starting-value and quadrature sensitivity; small samples and model misspecification can affect coverage. 
#>  Pointwise log-Wald approximation from the inverse full joint MML information. Relative slopes have geometric mean one. Assess starting-value and quadrature sensitivity; small samples and model misspecification can affect coverage. 
#>  Pointwise log-Wald approximation from the inverse full joint MML information. Relative slopes have geometric mean one. Assess starting-value and quadrature sensitivity; small samples and model misspecification can affect coverage. 
#>  Pointwise log-Wald approximation from the inverse full joint MML information. Relative slopes have geometric mean one. Assess starting-value and quadrature sensitivity; small samples and model misspecification can affect coverage. 
#>  IntervalStatus                                    Target
#>       Available Relative GPCM slopes (geometric mean one)
#>       Available Relative GPCM slopes (geometric mean one)
#>       Available Relative GPCM slopes (geometric mean one)
#>       Available Relative GPCM slopes (geometric mean one)
#>                                    Method ConfidenceLevel Adjustment
#>  Joint-information log-Wald approximation             95%  Pointwise
#>  Joint-information log-Wald approximation             95%  Pointwise
#>  Joint-information log-Wald approximation             95%  Pointwise
#>  Joint-information log-Wald approximation             95%  Pointwise
#> Note. Approximate inference under the stated target and method; unavailable outcomes remain present. No rater-quality or scoring-weight decision is implied.

# A separate, prespecified profile calculation can be requested with
# confint(fit, parm = "slopes", method = "profile", slope = chosen_rater).
# Choose chosen_rater from fit$slopes$SlopeFacet; see the profile section.
```
