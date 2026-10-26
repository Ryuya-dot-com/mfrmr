# Intervals for common-plan Person expected scores

Fixed-Person parametric refit intervals or a local delta approximation
for a declared common rating plan. Both preserve the
calibration-to-anchor-to-scoring estimator and account for explicitly
shared response events. A separate conservative bounded-response method
uses the scoring observations directly.

## Usage

``` r
# S3 method for class 'mfrm_fair_average'
confint(
  object,
  parm = NULL,
  level = 0.95,
  nsim,
  seed,
  contrasts = NULL,
  anchor_source = NULL,
  generating_fit = NULL,
  response_map = NULL,
  anchor_uncertainty = c("estimated", "fixed"),
  gradient_tol = 1e-04,
  method = c("refit", "delta", "bounded"),
  generator_method = c("ordinary", "jeffreys"),
  mc_level = 0.95,
  ...
)

# S3 method for class 'mfrm_fair_intervals'
summary(object, ...)

# S3 method for class 'mfrm_fair_intervals'
print(x, ...)
```

## Arguments

- object:

  For [`confint()`](https://rdrr.io/r/stats/confint.html), output from
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  with `reference_plan`. For
  [`summary()`](https://rdrr.io/r/base/summary.html), a saved
  `mfrm_fair_intervals` result.

- parm:

  Character Person identifiers. Default selects all Persons.

- level:

  Pointwise confidence level in (0, 1).

- nsim:

  For `method = "refit"`, required integer number of replications, at
  least two. Small values are useful for checking the procedure, not
  precise tail estimation. Omit for `method = "delta"` or `"bounded"`.

- seed:

  For `method = "refit"`, required nonnegative integer seed. The
  caller's RNG state is restored and the RNG kind is recorded. Omit for
  `method = "delta"` or `"bounded"`, which do not simulate or change the
  RNG state.

- contrasts:

  Optional numeric matrix with named rows and columns equal to `parm`
  (order may differ). Rows must sum to zero and define differences of
  common-plan expected scores. Without it, return individual scores.

- anchor_source:

  Native ordinary or explicit Jeffreys JML fit that supplied every
  direct anchor in `object`. Values must match the unrounded primary
  estimates. Its own anchors are not supported in this initial two-stage
  route. Omit calibration/generator inputs, `response_map`,
  `anchor_uncertainty` and `gradient_tol` for `method = "bounded"`: its
  bounds do not use fitted anchors or an estimated generating model.

- generating_fit:

  Fit on the union of calibration and scoring response events, supplying
  the fitted response model. Defaults to `anchor_source` for estimated
  anchors and the scoring fit otherwise. A separate union fit is needed
  when scoring includes events outside the calibration data.

- response_map:

  For estimated anchors, a required list with numeric vectors
  `calibration` and `scoring`. Each maps rows of that fit's `prep$data`
  to rows of `generating_fit$prep$data`. Indices identify actual
  response events, not just equal Person/facet labels. Shared indices
  mean the same observation; distinct occasions require distinct
  generating rows. Identifiers and observed scores must agree, and the
  maps must cover the union. Providing these maps asserts the event
  correspondence.

- anchor_uncertainty:

  `"estimated"` (default) requires `anchor_source` when direct anchors
  are present. `"fixed"` explicitly conditions on them. It does not
  propagate estimated-anchor uncertainty.

- gradient_tol:

  Positive tolerance for the maximum absolute estimating gradient
  (ordinary or penalized according to the fitted estimator), default
  `1e-4`, applied to sources and every refit. Optimizer convergence,
  identification and boundary checks are also required.

- method:

  `"refit"` (default) for empirical basic limits from whole-pipeline
  refits; `"delta"` for pointwise normal-reference limits using the
  local derivative of the same estimator. These two methods are
  experimental. `"bounded"` gives conservative pointwise Hoeffding
  bounds for the same true expected-score target from independent
  bounded scoring responses, retaining the full score range for
  unobserved reference-plan cells.

- generator_method:

  For `method = "refit"` only, `"ordinary"` (default) uses the supplied
  ordinary-JML generating estimates. Explicit `"jeffreys"` re-estimates
  that generating model with a canonical Jeffreys information penalty.
  It retains ordinary JML for the original point and every refit. This
  experimental option can provide a finite generator when Person MLEs
  are infinite; it does not qualify coverage or correct the reported
  points. For a score result from `fit_mfrm(jml_penalty = "jeffreys")`,
  the default is instead `"jeffreys"`: use that already fitted
  generating model, and retain Jeffreys estimation for original points
  and every refit. Explicit `"ordinary"` is refused for these results.

- mc_level:

  For `method = "refit"`, confidence level in (0, 1) for Monte Carlo
  enclosures of both interval endpoints together, per target. Default
  `.95`. This measures finite-replication error, separately from
  `level`, and does not qualify sampling coverage. Omit for other
  methods.

- ...:

  Must be empty.

- x:

  A saved `mfrm_fair_intervals` result.

## Value

An `mfrm_fair_intervals` data frame with estimates, numerical bounds,
availability and interpretation columns. Refit attributes retain
`draws`, `person_draws`, `anchor_draws`, `trials`, `settings`,
`reference_plan`, `generating_target`, `response_map`, `source_checks`
and source identities. Refit results also retain `MCLevel`, four
endpoint-enclosure columns, `MCFinite` and the `monte_carlo` rank table,
without changing `Available` or promoting `CIEligible` on the strength
of numerical precision. The explicit Jeffreys route additionally retains
`generating_model`, with free parameters, probabilities, numerical
checks and optimization controls. Delta results additionally have `SE`
and `Reason` columns and attributes `covariance` (ordered by Target),
`covariance_components` and `linearization` (target/anchor derivatives,
selected solve loadings, parameter coordinates and solve residuals). The
source/plan/settings attributes are shared by both methods. Unavailable
delta covariance is `NA`, not zero. Bounded results instead retain
`Informative`, `DesignEstimate`, `ObservedContribution`,
`SamplingRadius`, unobserved-cell and target-support limits, a
per-Person `support` attribute and sparse `person_event_weights`. Their
`settings$score_support` retains the declared limits and coding basis.
Their SE and simulation-count columns are missing; the radius is not an
SE. [`summary()`](https://rdrr.io/r/base/summary.html) reports the same
table without recalculation;
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) supports
export and [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) preserves
the full evidence. See
[`plot.mfrm_fair_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fair_intervals.md)
for display and interpretation.

## Details

For refit and delta intervals, each Person is fixed at the generating
fit's primary estimate. Responses are locally independent under its
RSM/PCM model, with the retained assignment and missingness pattern. The
procedure does not draw a new Person population or resample rows.
Calibration and scoring must share the same model, category coding,
facet signs, estimator and parameter meanings. Only unit-weight additive
RSM/PCM JML without shrinkage or group anchors is supported. Score
recoding must be the identity; transformed category labels are not
accepted here. Ordinary points and Jeffreys points cannot be mixed
across stages. With explicit Jeffreys fits, `method = "refit"` uses the
same penalty for original calibration, anchor extraction, scoring and
every replication. Numerical checks evaluate the penalized equations;
ordinary likelihood recession does not turn these penalized points into
infinities. Rank deficiency and numerical failures still stop or remain
unresolved in the planned denominator. No failed replicate is redrawn or
replaced by an ordinary estimate. `method = "delta"` uses the analytic
penalized score Jacobian, including the penalty's dependence on
estimated anchors. It does not use ordinary information or inverse
penalized curvature as covariance. `method = "bounded"` retains its
separate response-based assumptions and fitted-point display. The
penalty changes the points; it does not qualify score bias or coverage.

With `method = "refit"`, the original two-stage estimator is preserved:
first refit calibration, extract the specified anchors, then refit the
scoring data under those anchors and compute scores on the saved common
plan. The generator is a plug-in response model, not a replacement joint
estimator for the data. The bootstrap error is replicate score minus the
common-plan score under the **generating** model; this need not equal
the original two-stage estimate. Basic limits subtract its empirical
quantiles from the original estimate. Contrasts use paired scores from
each whole replication, retaining covariance.

Unresolved refits remain in the planned denominator. Replacing their
unknown errors by minus/plus infinity gives outer empirical-quantile
bounds; the function does not silently condition on successful refits.
Nonfinite bounds are returned as missing with
`Status = "unresolved_tail"`. Finite bounds outside the score range are
retained, not clipped to disguise approximation error. Type-1 empirical
quantiles and expected observations per tail are recorded. These are
pointwise intervals, without multiplicity adjustment. Inspect
`LowerMCLower`, `LowerMCUpper`, `UpperMCLower` and `UpperMCUpper` for
Monte Carlo enclosures of the lower and upper basic endpoints. Unlike
the reported empirical interval, these enclosures retain infinite limits
when replication counts or unresolved refits cannot bound an endpoint.
`MCFinite` means all four limits are finite, not sufficiently precise.
The `monte_carlo` attribute retains quantile probabilities and order
ranks. For each error quantile p, the ranks are `qbinom(a, nsim, p)` and
`qbinom(1-a, nsim, p)+1`, where `a = (1-mc_level)/4`. Ranks zero and
`nsim+1` denote infinities. The four one-sided allocations jointly cover
both infinite-replication basic endpoints for one target at least at
`mc_level`, conditional on a fixed generating model and independent
draws. They are conservative for discrete errors/ties. There is no
simultaneous guarantee across targets, reruns or adaptively chosen
stopping times. Unknown errors retain their minus/plus-infinity
envelopes; the enclosures include every completion of failed draws. If
the estimator is not defined on some outcomes, this does not create a
sampling distribution for it. Increasing `nsim` cannot repair structural
nonidentification or qualify bias. With finite qualified structural
calibration, a replicate Person at minus or plus infinity has a
well-defined limiting expected score (the scale endpoint). That limit is
retained and counted in `trials$BoundaryPersons`, without using a finite
optimizer proxy. An infinite estimated anchor cannot be passed into the
next fitting stage and remains unresolved. The generating fit and
originally selected Persons must have finite primary estimates for the
default ordinary generator. The explicit Jeffreys option below also
accepts original selected limiting expected scores under finite
structural calibration; its own generating parameters must be finite and
qualified.

With `method = "delta"`, the derivative is evaluated at the observed
calibration and scoring fits. Each stage's information uses that stage's
fitted category probabilities; the variance and cross-covariance of
response events use the declared generating fit. Shared events
contribute to both stages before their categorical covariance is taken.
Distinct occasions with identical labels are independent under this
fixed-Person model unless their event indices are shared. The target
covariance retains cross-Person and cross-stage terms, which can
increase or decrease a contrast's variance. A direct anchor changes both
its own location and any dependent centering coordinate; the derivative
includes that affine change. This is model-based propagation, not an
empirical robust/cluster sandwich estimate.

Delta propagation requires finite primary Person estimates throughout
the generating, calibration and scoring fits and numerically
positive-definite score Jacobians. Selected-target solves use diagonal
scaling without regularization. For ordinary JML no full parameter
inverse is formed. The Jeffreys derivative additionally solves for
centered category designs and processes one derivative direction at a
time, without event-squared or parameter-cubed arrays. Its scaled
Jacobian reciprocal condition must exceed `sqrt(.Machine$double.eps)`;
numerical availability can fail in weak designs. Information,
conditioning or boundary failures preserve the point estimates, return
missing SEs/limits and a `Reason`, and set
`Status = "unavailable_information"`. Normal limits are not clipped to
the score support; large widths or impossible endpoints can expose a
poor local approximation. No simulations, resolved-replication counts or
tail counts are implied by this method (those count columns are `NA`).
Even an unselected extreme Person in the generating fit can make
uncertainty unavailable for otherwise finite selected targets; their
point estimates and the reason are retained. Do not remove that Person
merely to obtain intervals. Delta limits are centered on the observed
estimate and do not perform a bootstrap bias correction or correct a
discrepancy between stage models.

Refit and delta are experimental fitted-model approximations. Neither
removes JML incidental-parameter bias, certify nominal coverage, include
uncertainty in the chosen plan, predict a future observed score, or
establish fairness. Model misspecification, dependence beyond the model
and changing Persons or calibrations across occasions require different
procedures. `CIEligible` remains false pending finite-sample
qualification; `Available` describes numerical availability only. No
external-software coverage guarantee is implied. Correct local
covariance does not guarantee adequate normal limits. In the supported
binary special case with six independent responses, the Jeffreys
expected-score estimate is \\(S+0.5)/7\\. At true success probability
0.5, the plug-in delta 95% interval covers only for \\S=2,3,4\\: exact
coverage is 0.78125, despite an unbiased point at that probability. At
probability 0.25, exact coverage is 0.784423828125. These are exhaustive
binomial calculations, not Monte Carlo estimates. They also hold when
the estimated Person anchor is passed to fully fixed scoring on the same
responses. The normal-reference approximation, including plug-in
standard errors and discrete outcomes, therefore has a demonstrated
small-sample limitation. More Persons do not necessarily increase the
responses for each focal Person. The basic refit route is not a general
remedy: exact, infinite-replication binomial refit quantiles for the
same estimator give coverage 0.78125 at probability 0.5 and 0.452709 at
probability 0.1. For an all-zero sample, its upper basic limit equals
the fitted score \\0.5/7\\; the bootstrap estimator cannot fall below
its own score floor. This is an interval-method limitation, not inner
Monte Carlo error, and more refits do not remove it.

## Explicit Jeffreys generating model

`generator_method = "jeffreys"` minimizes
\\-\ell(b)-\tfrac12\log\|I(b)\|\\ in the generating fit's actual affine
free coordinates, where \\I\\ is the ordinary categorical model
information. Direct anchor values enter as fixed offsets in this
generating model. The calibrated anchors used by the scoring estimator
are still re-estimated on every replication, with shared response events
generated only once. This option requires declared rubric endpoints and
unchanged full score coding; it is unavailable for delta and
bounded-response intervals.

Computation starts at the free-coordinate origin and uses BFGS, the
generating fit's `maxit`, and the stricter of its `reltol` and `1e-14`.
The analytic penalized gradient must pass `gradient_tol`. Information
must be numerically positive definite; scaled sparse solves must pass a
`1e-8` residual check. There is no ridge, finite parameter box or
probability clipping. Optimization, rank or numerically noninterior
probability failures stop with a reason; success is not a certificate of
a global optimum. Ordinary source fits and every refit retain their
existing stationarity and structural checks.

The original ordinary-JML point and its estimator are unchanged. Basic
limits use replicate ordinary-JML errors relative to the Jeffreys
generating expected score, not the original fitted generating score.
Finite expected-score limits for original extreme Persons are retained;
unresolved structural calibration or an infinite anchor passed between
stages remains unsupported. Inspect `generating_model` and
`generating_target` attributes for the distinct generating parameters,
probabilities, target and numerical diagnostics.

Firth's first-order bias reduction concerns canonical parameters in
regular fixed-dimensional asymptotics. It does not establish bias
reduction for nonlinear expected scores, fixed-short-exposure JML as
Person count increases, or this two-stage interval procedure. For
example, with \\S\sim Bin(n,p)\\, the induced estimate \\(S+1/2)/(n+1)\\
has bias \\(1/2-p)/(n+1)\\, whereas \\S/n\\ is unbiased for \\p\\. Thus
a finite generator can worsen a score bias. Sparse/weak-link coverage
and the bias/variance tradeoff require separate qualification;
`CIEligible` remains false. This is distinct from FACETS Xtreme and from
the corrected-GPCM `jml_correction_order` estimator.

## Conservative bounded-response intervals

`method = "bounded"` targets the same true common-plan expected score or
contrast, using the original scoring rows. It does not propagate a
fitted covariance or generate responses from extreme Person estimates. A
finite-sample probability inequality applies under independent
responses, a fixed assignment, plan and contrast chosen independently of
the observed scores, known score bounds, and stable expected scores
within each Person-by-plan cell. Repeated rows must represent
independent observations, not copied ratings. Dependence, adaptive
allocation and response-dependent missingness require other methods.
Both `rating_min` and `rating_max` must have been explicitly declared
from the rubric when fitting, with an unchanged full `score_map`. Use
`category_policy = "preserve"` to retain that scoring rule. Limits
inferred from observed minima/maxima, missing range provenance and
internally collapsed categories are rejected: a small sample can omit a
valid category, and its observed range is not known population support.
Declaring the sample extrema after seeing the data does not satisfy this
assumption. If a retained empty category prevents fitting, that failure
remains in an end-to-end denominator; do not collapse the category
merely to obtain an interval.

Each observed cell contributes its sample mean times its normalized plan
weight; cells outside the plan receive zero weight. An unobserved cell
retains the full declared score range. For a contrast, signed event
weights preserve its definition. Bounds are intersected with the
target's mathematically known range. This preserves the coverage
inequality and is not clipping a normal approximation. Sparse plans can
produce very wide or uninformative bounds; the full range has
`Informative = FALSE`, even though it is a valid bound.
`Informative = TRUE` means only narrower than the full target range, not
necessarily precise enough for a substantive decision.

`Estimate` retains the original JML score, including an endpoint limit
or missing estimate. The interval need not be centered on or contain
that point. `DesignEstimate` is a separate unbiased weighted-mean
estimate when every relevant Person has all reference-plan cells
observed; otherwise it is missing. It is not a corrected JML estimate.
The confidence statement concerns the true expected score, not the
accuracy or bias of the retained JML point.

Estimated anchors, even from the same sample, affect the retained JML
point but are not inputs to these bounds. Their uncertainty is therefore
neither conditioned away nor approximated by a fixed-anchor SE. The
price is foregoing model-based extrapolation to unobserved plan cells.
`CIEligible = TRUE` here denotes the finite-sample inequality under the
stated assumptions, not empirical qualification of JML or guaranteed
usefulness. Bounds are pointwise; inspecting many Persons or selecting a
contrast after seeing results is not covered. The inequality is
unconditional over the prespecified response experiment. It does not
imply nominal coverage conditional on successful model fitting, an
extreme-score subgroup or another response-dependent selection. This API
requires an existing common-plan result: if fitting cannot create that
result, retain the failure in the planned denominator of an end-to-end
evaluation.

If \\a_e\\ is a signed event weight and scores lie in \\\[l,u\]\\, write
\\T=\sum_e a_eY_e\\ for the observed contribution. With
\\\alpha=1-\mathrm{level}\\, the sampling radius is
\$\$r=\sqrt{\tfrac12\log(2/\alpha)\sum_e a_e^2(u-l)^2}.\$\$ Each missing
cell with signed plan weight \\b\\ contributes between \\\min(bl,bu)\\
and \\\max(bl,bu)\\. Add these lower/upper sums to \\T-r,T+r\\.
Hoeffding's two tails bound the probability of missing the true
expected-score target by at most \\\alpha\\, uniformly over those
missing means. Extreme observed totals do not invalidate this argument.

## Local two-stage derivative

Let \\b_c, b_s\\ be the actual free calibration/scoring coordinates,
\\a(b_c)\\ the extracted direct anchors, and \\t(b_s,a)\\ the selected
expected scores or contrasts. Category-logit coefficients in the scoring
stage are \\X_s\\ for free coordinates and \\O_s\\ for anchors,
including centering changes. Write \\H_c,H_s\\ for stage information,
\\B = \sum_e \operatorname{Cov}\_s(X_s,O_s)\\, \\A = \partial a/\partial
b_c\\, and \\G_s,G_a\\ for target derivatives. For explicit Jeffreys
estimation replace each \\H\\ by the Hessian of
\\-\ell-\tfrac12\log\|I\|\\ in its stage's free coordinates, and replace
\\B\\ by the mixed free-coordinate/anchor derivative of that same
objective. This includes the anchor dependence of \\I\\; holding the
penalty fixed during anchor propagation would give a different
derivative. The penalty does not depend on response outcomes at fixed
design/parameters, so the response-event coefficients \\X_s,X_c\\ remain
unchanged. Differentiating the two score equations gives event-category
coefficients \$\$U_s = X_s H_s^{-1}G_s^T,\qquad U_c = X_c H_c^{-1} A^T
(G_a-G_s H_s^{-1}B)^T.\$\$ Put both coefficients on their explicit
union-event indices (zero when an event is absent from a stage), then
compute \\V = \sum_e \operatorname{Cov}\_{p\_{g,e}}(U_s+U_c)\\ over
categories. Centering under the generating probabilities matters when
stage and generator fits differ. The saved decomposition is direct
scoring, propagation through calibration, and the signed shared-event
cross term. Their sum is the target covariance; the cross term alone
need not be positive semidefinite. This local derivation does not
establish fixed-item JML asymptotics or finite-sample normality.
Estimated plans and unmodelled dependence are excluded.

## References

Murphy, K. M., and Topel, R. H. (1985). Estimation and inference in
two-step econometric models. Journal of Business & Economic Statistics,
3(4), 370–379.
[doi:10.1080/07350015.1985.10509471](https://doi.org/10.1080/07350015.1985.10509471)
. Related estimating-equation framework: Hardin, J. W. (2002). The
robust variance estimator for two-stage models. The Stata Journal, 2(3),
253–266.
[doi:10.1177/1536867X0200200302](https://doi.org/10.1177/1536867X0200200302)
. The present method uses a model-based event covariance and does not
claim the robust estimator described there. Hoeffding, W. (1963).
Probability inequalities for sums of bounded random variables. Journal
of the American Statistical Association, 58(301), 13–30, Theorem 2.
[doi:10.1080/01621459.1963.10500830](https://doi.org/10.1080/01621459.1963.10500830)
. Firth, D. (1993). Bias reduction of maximum likelihood estimates.
Biometrika, 80(1), 27–38.
[doi:10.1093/biomet/80.1.27](https://doi.org/10.1093/biomet/80.1.27) .
Burke, S. (2016, revised 2018). Confidence Intervals for the Median and
Other Percentiles. STAT COE-Report-08-2016. Binomial order-statistic
construction; the present Monte Carlo diagnostic additionally allocates
errors across both endpoints and retains unresolved-draw envelopes.

## Examples

``` r
d <- load_mfrmr_data("example_core")
# Calibrate the observed ratings with ordinary joint maximum likelihood.
f <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", rating_min = 1, rating_max = 4, category_policy = "preserve",
  optimizer = "BFGS", maxit = 500, reltol = 1e-11)
# The bundled example's rubric is 1--4; declare it independently of sample extrema.
# Every Person is evaluated against these same Rater-Criterion cells.
plan <- unique(d[c("Rater", "Criterion")])
fair <- fair_average_table(f, reference_plan = plan)
head(fair$reference_scores) # Expected average, in internal score units.
#>   Person Estimate         Status                       Target          Units
#> 1   P001 2.937500 point_estimate common_plan_expected_average internal_score
#> 2   P002 3.437499 point_estimate common_plan_expected_average internal_score
#> 3   P003 3.249999 point_estimate common_plan_expected_average internal_score
#> 4   P004 3.062501 point_estimate common_plan_expected_average internal_score
#> 5   P005 3.062501 point_estimate common_plan_expected_average internal_score
#> 6   P006 1.625000 point_estimate common_plan_expected_average internal_score
#>    Uncertainty
#> 1 not_computed
#> 2 not_computed
#> 3 not_computed
#> 4 not_computed
#> 5 not_computed
#> 6 not_computed
# Two replications exercise the API only; they cannot qualify coverage.
# Explicit experimental generator; points and every refit remain ordinary JML.
ci <- confint(fair, parm = c("P001", "P002"), nsim = 2, seed = 71,
  generator_method = "jeffreys",
  contrasts = matrix(c(1, -1), 1,
    dimnames = list("P001 minus P002", c("P001", "P002"))))
summary(ci) # Read Status and Available alongside the limits.
#> Common-plan expected-score intervals (experimental)
#>            Target   Estimate   CI_Lower   CI_Upper Level Available       Status
#> 1 P001 minus P002 -0.4999991 -0.6153476 -0.2403474  0.95      TRUE experimental
#>   Planned Resolved Unresolved ExpectedTailDraws CIEligible LowerMCLower
#> 1       2        2          0              0.05      FALSE         -Inf
#>   LowerMCUpper UpperMCLower UpperMCUpper MCLevel MCFinite
#> 1   -0.2403474   -0.6153476          Inf    0.95    FALSE
#>                          Uncertainty
#> 1 joint_calibration_and_person_refit
#>                                                                                                                                                                            InferenceReview
#> 1 Experimental pointwise fitted-model approximation; finite-sample coverage and JML bias remain unqualified. Jeffreys generating model; the reported point and refits remain ordinary JML.
#> Numerical availability is separate from coverage qualification.
#> Jeffreys generating model; displayed points and refits retain ordinary JML.
#> Endpoint Monte Carlo enclosures measure simulation precision, not sampling coverage; MCFinite alone does not establish precision.
attr(ci, "trials") # Includes unresolved refits and their reasons.
#>   Replication CalibrationGradient ScoringGradient BoundaryPersons Available
#> 1           1                  NA    4.202793e-05               0      TRUE
#> 2           2                  NA    4.030392e-05               0      TRUE
#>   Reason Warnings Seconds
#> 1                   0.685
#> 2                   0.699
attr(ci, "monte_carlo") # Infinite enclosures expose the two-draw tail uncertainty.
#>            Target Endpoint Probability RankLower RankUpper      Lower
#> 1 P001 minus P002    lower       0.975         1         3       -Inf
#> 2 P001 minus P002    upper       0.025         0         2 -0.6153476
#>        Upper MCLevel Planned Unresolved RankLimited
#> 1 -0.2403474    0.95       2          0        TRUE
#> 2        Inf    0.95       2          0        TRUE
plot(ci, draw = FALSE) # Saved plotting data, including the cautions.
# Deterministic local approximation to the same expected-score target:
delta <- confint(fair, parm = c("P001", "P002"), method = "delta")
delta[, c("Target", "Estimate", "SE", "Available", "CIEligible")]
#> Common-plan expected-score intervals (experimental)
#>   Target Estimate        SE Available CIEligible
#> 1   P001 2.937500 0.1921590      TRUE      FALSE
#> 2   P002 3.437499 0.1599923      TRUE      FALSE
#> Numerical availability is separate from coverage qualification.
attr(delta, "covariance") # Includes the covariance between Persons.
#>            P001       P002
#> P001 0.03692507 0.00000000
#> P002 0.00000000 0.02559753
# Conservative alternative with explicit observed/unobserved plan support:
bounded <- confint(fair, parm = c("P001", "P002"), method = "bounded")
bounded[, c("Target", "Estimate", "DesignEstimate", "CI_Lower", "CI_Upper", "Informative")]
#> Common-plan expected-score intervals (experimental)
#>   Target Estimate DesignEstimate CI_Lower CI_Upper Informative
#> 1   P001 2.937500         2.9375 1.918924 3.956076        TRUE
#> 2   P002 3.437499         3.4375 2.418924 4.000000        TRUE
#> Numerical availability is separate from coverage qualification.
attr(bounded, "support") # Check how much of the plan was actually observed.
#>   Person ObservedPlanWeight UnobservedPlanWeight RelevantResponses CompletePlan
#> 1   P001                  1                    0                16         TRUE
#> 2   P002                  1                    0                16         TRUE
```
