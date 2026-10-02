# Approximate confidence intervals and comparisons for GPCM slopes

Compute confidence intervals for relative or standardized
discriminations and specified slope comparisons in a native GPCM MML
fit. Model/sandwich methods do not refit; an explicitly requested
profile reoptimizes nuisance parameters at each candidate value. The
default is a pointwise model-based interval for each relative slope in a
one-family fit. Two-family fits use their fixed standard-normal scale
and the separately checked experimental approximation described below. A
relative slope above one means a steeper response curve than the
geometric-average slope; it is not a measure of rater agreement or a
recommended scoring weight.

## Usage

``` r
# S3 method for class 'mfrm_fit'
confint(
  object,
  parm = "slopes",
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
```

## Arguments

- object:

  A GPCM MML result from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- parm:

  Must be `"slopes"`; other parameter families are not included.

- level:

  Nominal confidence level strictly between zero and one.

- scale:

  `"relative"` (one-family default) keeps geometric mean one.
  `"standardized"` reports population-SD times slope, including
  uncertainty in estimated SD. With covariates, this SD is the residual
  population SD. Two-family fits require `"standardized"` and use it
  when omitted: SD is fixed at one, the first slope family has geometric
  mean one, and the second family is free on that scale.

- contrasts:

  Optional numeric matrix: one named comparison per row, all slope
  levels as named columns, finite nonzero rows summing to zero. For A
  versus B use coefficients 1 and -1, and zero for other levels.

- contrast_scale:

  `"ratio"` exponentiates log-slope contrasts (A/B); `"difference"`
  contrasts positive slopes (A-B) by the delta method.

- method:

  `"model"` uses joint observed information; `"sandwich"` uses Person
  marginal-likelihood scores, optionally grouped into larger clusters.
  Experimental `"profile"` reoptimizes nuisance parameters for one
  specified relative slope, or one two-family component, using a
  chi-square(1) likelihood-ratio cutoff.

- clusters:

  Optional data frame mapping each fitted `Person` once to a nonmissing
  `Cluster`, as in
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
  Persons are independent units by default. Shared random effects across
  clusters are not supported.

- adjust:

  For sandwich covariance only, multiply by G/(G-1) for G clusters;
  default FALSE. This is not a small-sample accuracy guarantee.

- simultaneous:

  `"none"` (default) gives pointwise intervals; `"bonferroni"` adjusts
  for all rows requested in this call. It does not adjust for other
  analyses or post-selection of targets.

- ...:

  Unused.

- slope:

  For `method = "profile"`, one exact level from
  `object$slopes$SlopeFacet`, selected for the research question.
  Required; profiling all levels implicitly is not supported. For two
  families use a named character value, e.g. `slope = c(Task = "t1")`:
  the name is the fitted owner column and the value is its level. This
  distinguishes equal level labels belonging to different facets.

- profile_control:

  Named list for profiling: `maxit` (400 iterations per optimizer
  stage), `max_steps` (8 bracketing trials per side, including
  contractions after failed trials), and `initial_step` (0.5 on the
  log-slope scale, multiplied by 1.5 during outward expansion). These
  limit numerical searches, not the mathematical parameter space.
  Numerical acceptance tolerances are not relaxed by these settings.

## Value

A matrix of class `mfrm_slope_intervals` with columns `Lower` and
`Upper`, named by slope level. Printing shows estimates, bounds and any
explanations when a bound cannot be calculated. Attributes `level`,
`method`, `target`, and `diagnostics` describe the result. The
diagnostics table includes estimates, log-scale and positive- scale SEs,
`CIEligible`, `CIUse`, and an `InferenceReview` explaining availability.
Unavailable intervals have missing bounds.

## Details

Relative slopes have geometric mean one. If \\\eta\\ denotes the G-1
free log-slope coordinates and \\J\\ expands them to G sum-zero log
slopes, their covariance is \\J V\_{\eta} J^T\\. Here \\V\_{\eta}\\ is
the slope block of the inverse **full joint** observed information,
including estimated population parameters, rather than the inverse of
the slope information block alone. Each interval is \\\exp(\log(a_g)
\mathbin{\pm} z SE(\log(a_g)))\\.

The current likelihood, gradient and joint information must pass the MML
solution checks. The fit also needs supported score categories,
consistent likelihood metadata, unit observation weights, and at least
31 quadrature points. Regularized, singular, nonconverged or mismatched
results do not receive intervals. These one-family rules differ from the
two-family checks below. Positive curvature is a local check, not a
proof of a global maximum or accurate integration. Use
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
and different starts for consequential results. A positive but
ill-conditioned information matrix can be used with a warning when two
refined numerical Hessians agree, inversion without regularization is
accurate and a curvature-scaled gradient is small. Failure of any check
keeps inference unavailable. Passing these numerical checks does not
resolve weak information in the data: an interval may still be extremely
wide or unreliable near a boundary. Warnings are saved in the `cautions`
attribute and `InferenceReview`, and follow printing, default plot
subtitles and reports.

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
`confint(fit)` requests log-Wald intervals for both sets of component
slopes. Fixed-grid EM and direct adaptive fits use their own fitted
marginal objective. For adaptive fits, differentiation includes movement
of the quadrature nodes, their scale and the integration Jacobian; it
does not freeze the fitted nodes. It uses the inverse full observed
marginal information, including all locations, steps and cross-family
covariance; it does not invert the frozen EM Q function or the slope
block alone. The first family's log slopes sum to zero; the second
family's slopes are free. The result retains `SlopeOwner`, `SlopeLevel`
and `ScaleReference` separately. A slope of one has different reference
meanings across these families, so no individual unit-slope p-values are
supplied.

The default `method = "model"` uses `scale = "standardized"`, without
contrasts or cluster adjustments. Bonferroni adjusts for all component
slopes in that call. For fixed-grid EM only, an explicit
`method = "profile"` profiles one named owner/level, retaining both
families' scale constraints and reoptimizing all remaining slopes,
locations and steps. The N(0,1) population is fixed, not an estimated
nuisance parameter. Use, for example,
`confint(fit, method = "profile", slope = c(Task = "t1"))`. Replace Task
and t1 with your actual column and level names. The result preserves
owner, level, scale reference and the same-target Wald comparison
through saved plots, reports and exports. This is a component interval,
not an interval for the product of two slopes. Experimental location and
within-facet contrast intervals use
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
and have their own target-specific limitations. Effective slope-product
and curve intervals, sandwich intervals and model ranking are not
supplied for this model.

Checks reevaluate the source identity, category support, engine-specific
convergence and unregularized marginal information. The observed
Person-score Jacobian must span all free coordinates at relative SVD
tolerances 1e-10, 1e-8 and 1e-6, using numerical derivative steps 1e-5
and 5e-6. Columns are normalized to unit Euclidean length; their maximum
difference must be at most 1e-6. Full rank is evidence of local
separation at this fitted point for the quadrature model, not global
identification. Failure of this sufficient check does not prove
structural nonidentifiability.

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
near-zero-slope source eligible. The two-family EM optimizer uses a
per-Person objective scale internally; likelihood ratios and all
acceptance checks use the total likelihood. Adaptive two-family profiles
are unavailable; an adaptive log-Wald result does not qualify
constrained profile searches or their integration checks.

Every available two-family interval carries an experimental warning:
global identification, absence of boundary alternatives and sampling
coverage remain unestablished. Failed checks retain estimates, missing
bounds and reasons. Inspect `attr(ci, "checks")`,
`attr(ci, "numerical_checks")` and `attr(ci, "score_rank")`, or
`apa_table(ci, which = "checks")`. Plots and saved results/reports
retain the approximation and its checks. This calculation does not
change the original point estimates or resolve other warnings about the
fitted model.

For an unresolved two-family profile, distinguish the original fit from
the constrained searches. `maxit` in
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
controls the original EM fit; `profile_control = list(maxit = ...)` in
[`confint()`](https://rdrr.io/r/stats/confint.html) controls each
constrained BFGS stage. Inspect
`apa_table(ci, which = "profile_checks")` and
`which = "profile_endpoints"`. Checks at the fitted slope can fail when
the two constrained starts disagree even though the original fit passed
its checks. Increasing `quad_points` requires refitting and addresses
integration discrepancies; it does not resolve disagreement between
starts.
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
compares fixed-grid refits while preserving the model and EM settings.
Its `intervals` entries are model-based Wald intervals; they do not
repeat a profile search. To assess a profile on a finer grid, explicitly
call [`confint()`](https://rdrr.io/r/stats/confint.html) with
`method = "profile"` on the corresponding entry in `review$fits`. If the
problem is instead a constrained optimizer reaching its iteration limit,
increase `profile_control$maxit`; increasing the original fit's `maxit`
does not change that profile limit. A search limit or numerical failure
does not establish an infinite interval. With little information about a
slope, the original fit or a constrained search can fail to converge.
Obtaining numerical endpoints after changing search settings does not
establish their sampling coverage. The profile method remains an
explicit sensitivity analysis, not a routine replacement for log-Wald
intervals; no coverage advantage is established.

## One prespecified profile interval for one slope family

Use `confint(fit, method = "profile", slope = "R01")` to investigate how
well one relative discrimination is determined. Choose a level that
actually belongs to the fit's slope facet. At each candidate log slope
the sum-zero log-slope constraint is retained, including when the
selected level is the dependent last coordinate. All remaining slopes,
steps, facet locations and estimated population mean and variance are
reoptimized. The current scope requires an estimated intercept-only
normal population, unit weights, and no anchors or interactions.
Standardized slopes, contrasts, JML, covariate populations and
simultaneous profile intervals are not supplied.

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
1e-4) are checked. For two slope families, if the initial two
optimization stages do not converge, the search can retry in coordinates
scaled by local curvature, with at most `maxit` iterations in this
additional stage. This changes only how the optimizer moves through the
parameter space; constraints and acceptance checks remain unchanged. The
additional stage is available for up to 64 nuisance parameters; an
unavailable or unsuccessful retry leaves the earlier result and its
reason. After two BFGS tolerances, a stalled converged search may
receive the single curvature-based refinement. Its original optimization
stages stay recorded; the proposal must improve the gradient without
worsening the NLL. Both source and constrained calculations use the
fit's integration method; these checks do not establish that variance or
slope boundary solutions are absent. Endpoint likelihood-ratio residuals
must be at most 1e-4. A better likelihood than the source invalidates
both bounds. After a failed outward trial, the search contracts toward
the last passing point within the same `max_steps` budget. This can
locate an endpoint before the failed trial; it does not skip failed
points inside a bracket or change quadrature. All failed attempts remain
saved, including when both endpoints are found. Unresolved failures,
observed nonmonotonicity or an exhausted search retain missing bounds
and reasons, rather than falling back to Wald or declaring an infinite
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
# After fitting a GPCM with method = "MML":
# intervals <- confint(fit, parm = "slopes", level = 0.95)
# Inspect fit$slopes$SlopeFacet and choose one level before profiling:
# ci <- confint(fit, method = "profile", slope = "R01")
# plot(ci, type = "profile", title = NULL)
# apa_table(ci, which = "profile_endpoints")
# attr(intervals, "diagnostics")[, c("SlopeFacet", "Estimate",
#   "CIEligible", "InferenceReview")]
```
