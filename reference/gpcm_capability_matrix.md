# GPCM workflow and score availability

Check which `GPCM` workflows can be used in `mfrmr`, the limits that
apply to each workflow, and the recommended alternative when a route is
not available.

The table is intended for route selection before or after fitting and is
limited to workflow availability, interpretive constraints, and the
route to use next. Except for the multiple-slope and EM rows, the table
describes one facet supplying relative discriminations. The provisional
two-family route has a separate scope below. The one-family model uses
one slope facet. MML permits a different facet for category steps; JML
requires `slope_facet == step_facet`. It has one substantive ability
dimension. Separate-owner MML supports fitted-object scoring,
information, slope/curve uncertainty, matched PCM comparison and saved
inference. Weighting reviews and simulation/design workflows still
require the same owner; same-design
[`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
supports separate owners. Numerical eligibility is not a coverage
guarantee. These structural choices are stated separately from the
availability of each output. An available probability or descriptive
comparison does not establish eligibility for a confidence interval or
model-selection rule.

JML fits estimate relative slopes but do not support the MML slope
interval, bootstrap, curve-uncertainty or inferential comparison routes
described here. Their available facet/location SEs are exploratory
observation-table approximations, not slope SEs or nuisance-adjusted
joint-information SEs. Local curvature checks do not establish bias
control or interval coverage. Fitted-object JML scoring uses post-hoc
EAP with a default standard-normal reference prior or an explicit
`scoring_prior`; it is not ML/WLE scoring. Portable GPCM extraction
supports MML and shared-owner JML within their distinct source-check
scopes. JML local checks leave incomplete global audits unchanged. See
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for JML estimation and boundary conventions and
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
for conditional scoring.

## Usage

``` r
gpcm_capability_matrix(
  status = "all",
  view = c("workflows", "scores", "unavailable")
)
```

## Arguments

- status:

  Which rows to return. For `view = "workflows"` or `"unavailable"`, use
  `"all"` (default), `"supported"`, `"supported_with_caveat"`,
  `"blocked"`, or `"deferred"`. For `view = "scores"`, use `"all"`,
  `"available_with_caveat"`, `"supporting_route"`, or `"unavailable"`.

- view:

  The table to read: `"workflows"` (default) gives the general map;
  `"scores"` describes package-native versus FACETS-style score
  quantities; `"unavailable"` lists blocked/deferred routes and
  alternatives.

## Value

For `view = "workflows"`, a data.frame of class
`mfrmr_gpcm_capabilities` with one row per workflow family and columns:

- `Area`

- `Helpers`

- `Status`

- `Boundary`

- `RecommendedRoute`

For `view = "scores"`, an ordinary data.frame with `Capability`,
`Status`, `Limitation` and `Alternative`. For `view = "unavailable"`, an
ordinary data.frame with `Area`, `Helper`, `Status`, `Boundary` and
`RecommendedRoute`.

## Details

`Status` has the following user-facing meanings:

- `supported`: the helper is available within the stated boundary;

- `supported_with_caveat`: the helper runs, but its interpretation is
  restricted as described in `Boundary`;

- `blocked`: the helper intentionally stops for a `GPCM` fit;

- `deferred`: no public `mfrmr` route is currently available.

Read `Boundary` before interpreting a caveated result. For a blocked or
deferred row, use `RecommendedRoute` to choose a supported analysis or a
Rasch-family alternative.

In the score view, `available_with_caveat` denotes an available quantity
within its `Limitation`, `supporting_route` denotes related evidence or
a reference model rather than a replacement for that quantity, and
`unavailable` denotes a quantity not supplied. Package-native GPCM
scores and uncertainty are not FACETS score-side equivalents. These
statuses are kept separate from the general workflow statuses to
preserve their meaning.

In 0.2.4, this is the single public entry for all three tables. Replace
`gpcm_score_side_contract(status)` with
`gpcm_capability_matrix(status, view = "scores")`, and
`gpcm_runtime_guard_coverage()` with
`gpcm_capability_matrix(view = "unavailable")`. Each view retains its
former column schema and status meanings. These tables describe
supported routes; they do not inspect a particular fit or certify its
inferential eligibility.

## Connected outputs and unavailable extensions

For the current one-slope-family model, use `summary(fit)` to review the
model and numerical status, `plot(fit, type = ...)` for available
location, fit and category views, and
[`stats::confint()`](https://rdrr.io/r/stats/confint.html) /
[`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
for separately checked MML uncertainty. An interval result has its own
[`print()`](https://rdrr.io/r/base/print.html) and
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods; attach
selected results to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
for
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
and
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md).
A plot of locations or fit statistics is not a plot of slope
uncertainty.
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
separately supplies native-scale model-information Wald intervals for
one-family MML locations and within-facet contrasts. Direct
fixed/adaptive MML, centered additive facets/steps and unit weights are
required, with an estimated intercept-only normal population or the
explicit fixed-N(0,1) restriction. Shared/separate slope and step owners
are supported. Full-information and finer-grid checks preserve refusal
reasons; regular asymptotic validity assumes a correctly specified,
identified interior marginal model with nonsingular limiting
information. Finite-sample coverage is not guaranteed. Explicit zero-sum
contrasts can be standardized by the same fit's population SD using the
full delta method; individual standardized-location intervals are not
supplied.

Portable calibration has its own row and
[`mfrm_calibration_capabilities()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_capabilities.md)
gives estimator-specific source restrictions. Two slope families are
available provisionally through
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
with fixed-standard-normal MML, exactly two facets, no anchors and unit
weights. Choose fixed-grid EM or adaptive direct MML explicitly; see
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
Use `summary(fit)`, then inspect adaptive initialization in
`fit$opt$mml_initialization`: the default compares neutral and
EM-derived starts with the same adaptive likelihood, retaining failed
starts and the selected candidate's convergence status. The saved
initialization policy also follows quadrature-order refits. Use
`curves <- mfrm_curve_intervals(fit, newdata)` and `plot(curves)`.
Despite the function name, this route returns fitted values with
unavailable intervals. Attach them with
`mfrm_results(fit, intervals = curves)` for reports and saved exports.
Without attachments, `mfrm_results(fit)` collects the saved fit and its
numerical status; neither call calculates new diagnostics. Separately
use `ci <- confint(fit, parm = "slopes")` for experimental component
log-Wald intervals and attach
`intervals = list(slopes = ci, curves = curves)`. Local numerical checks
do not establish global identification or sampling coverage; failed
checks retain missing bounds. An explicit
`confint(fit, parm = "slopes", method = "profile", slope = c(Task = "t1"))`
profiles one two-family component, using the actual owner/level names.
It preserves the fitted fixed or adaptive integration method; adaptive
nodes, scales and Jacobians are recomputed throughout the constrained
searches. It retains nuisance reoptimization, numerical checks,
unavailable endpoints and a same-target Wald comparison. Neither method
has qualified coverage. Use
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
to compare refits with the same engine and integration method. Both
routes retain each order's experimental log-Wald checks. Optional
`adaptive_quad_points` also adds fixed-calibration integration checks
for two families; the posterior moments in that review are numerical
diagnostics, not a Person-scoring workflow. Person-score comparisons
remain unavailable for two families. For both engines,
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
supplies same-data posterior predictive residuals with fixed
calibration, including descriptive Infit/Outfit without reference
cutoffs. It retains the fitted integration method and complete Person
conditioning record, including when selecting output rows. Attach the
saved object through `response_diagnostics` to the results call above
for plots, reports and exports.
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
separately supplies experimental conditional new-Person EAP, posterior
SD and continuous posterior intervals under the retained N(0,1) prior,
with source/batch numerical checks and no calibration uncertainty.
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
provides portable two-family format 6 with the same fixed prior and
separate source/batch checks.
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
supplies separately checked experimental normal intervals for either
owner's locations or prespecified within-facet contrasts. It uses the
constrained location block of the inverse full marginal information;
failed numerical checks retain point estimates with missing intervals.
Attach the result as `intervals = list(locations = ci)` for saved
reports and plots. Coverage is unqualified; location differences are not
uniform rating differences when slopes or steps vary. Ordinary fit
diagnostics, step/curve intervals and model ranking remain unavailable.
Shared-owner corrected JML has an explicit experimental point-estimation
and reporting route through `jml_correction_order`; formal structural
intervals remain unavailable. Its descriptive response diagnostics and
conditional EAP scoring use their own saved identities and source
checks. Portable corrected calibration uses file format 5; no ordinary
JML likelihood checks or structural intervals are inherited. Separate
slope and step owners alone still define one slope family.

## Model, estimation and algorithm

RSM, PCM and GPCM describe response probabilities, not a particular
fitting algorithm. MML integrates over an ability distribution; JML
estimates the training persons' abilities jointly with the other
parameters. EM and direct optimization are numerical ways to fit an MML
model. RSM/PCM can therefore also use MML–EM. In this package, MML
defaults to direct optimization; RSM/PCM EM and hybrid support additive,
fixed-population models with fixed integration (`population = NULL`).
One-family GPCM EM/hybrid requests fall back to direct and record the
engine in `fit$summary`.

The provisional two-slope-family GMFRM route uses fixed-standard-normal
MML with fixed-grid generalized EM (`mml_engine = "em"`) or adaptive
direct optimization
(`mml_engine = "direct", mml_integration = "adaptive"`).
`mml_integration = "auto"` preserves the selected engine and increases
integration points up to
`mml_accuracy_control = list(max_points = ...)`, including reference
rules, while retaining the numerical and information checks. Fixed
integration remains the package default; two-family direct fitting
requires explicit adaptive or automatic integration. Adaptive EM and
two-family hybrid fitting are unavailable. EM is not a defining property
of GMFRM. See the GPCM scope vignette for the distinction between the
model, estimation method and algorithm, with links to Muraki, TAM and
sirt.

## Applications of two slope families

In a speaking assessment, task difficulty and assessor severity describe
shifts in ratings, whereas task and assessor slopes describe how
responses change with ability. Their product is the effective slope for
a rating. For example, 0.8 times 1.2 gives 0.96; it is a log-odds
multiplier, not an accuracy percentage or a score weight. The same roles
can use piece/judge or station/examiner labels, provided the
single-ability assumption is appropriate. Two slope families do not
create two latent abilities or a separate free slope for every
task-by-assessor pair.

Potential uses include task review and assessor feedback. A high
assessor slope is not a competence threshold, and a low task slope is
not a rule for deleting content. Read category and information curves
over the relevant ability range, inspect uncertainty and assignment
overlap, and bring in reference ratings or substantive evidence for
accuracy claims. The vignette explains these uses and a provisional
two-family fitting example. It does not yet provide a two-family model
comparison or qualified feedback decision. It also shows how to import
the empirical writing table `sirt::data.ratings1` from that separately
installed package, preserve its categories, and review unequal
assignment. The example distinguishes new fitted response curves from
evidence of predictive accuracy. The original fixed-grid fits had
integration-sensitive curves and incomplete residual summaries. A
subsequent adaptive fit resolved the retained numerical example; that
agreement does not validate model fit or feedback decisions. All score
datasets bundled with mfrmr are synthetic.

## Rankings and consequential decisions

An official competition result, highest latent ability and a future
winner are different targets. The scope vignette reviews actual
figure-skating score protocols, changing judge panels and advancement to
a final. Individual score intervals, high rank correlation or a high G
coefficient do not establish the probability of selecting the correct
champion. Differences need covariance and selection-aware uncertainty;
independently drawing from printed SEs omits shared calibration
uncertainty. There is no winner-probability or simultaneous Person-rank
confidence-set API. Available one-family and experimental two-family
new-Person EAP intervals condition on the calibration and prior; they do
not provide a validated winner-selection procedure. Preserve
competition-specific aggregation, rounding, tie rules and advancement
separately from modelled ability. Do not interpret sensitivity to a
judge's marks as proof of bias.

## Local independence, testlets and random effects

Two fixed slope families change response sensitivity; they do not by
themselves remove dependence between ratings from the same performance.
A testlet effect is itself a random effect, defined by its sharing unit.
A testlet model assumes independence conditional on ability and its
local effect, with dependence remaining after the effect is integrated
out. One substantive ability can therefore coexist with additional
latent dependence variables.

[`fit_mfrm_testlet()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_testlet.md)
supplies a Person-local RSM block effect; reusing a block label for
another Person creates a different effect.
[`fit_mfrm_random_rater()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_random_rater.md)
instead supplies a rater severity effect shared across persons. These
separate RSM routes neither add effects to GPCM nor jointly estimate
shared-rater and testlet effects. Random discrimination is also
different from estimating two fixed slope families. The GPCM scope
vignette explains effect-sharing units, observed versus new block/rater
prediction and the distinction from multivariate G-theory. A testlet
variance does not diagnose halo or enforce equal task weights.

## Interpreting the former bounded GPCM label

Use GPCM as the model name and state the structure and output
restrictions explicitly. The older label described limited
implementation scope, not a distinct unidimensional response model.
Positive log-parameterized relative slopes retain their
geometric-mean-one identification; there is no extra user-facing finite
slope box. Rejection of numerical overflow/underflow is not clipping to
a valid estimate. Separate owners, MML inference/comparison and portable
calibration are available within their respective scopes; two-family
fitting provides provisional estimates and conditional curves, with
separately checked experimental component-slope intervals. JML slope
intervals remain unavailable. A data-specific boundary or unbounded
interval is a separate statistical issue, and retirement of the label
does not certify interval coverage.

## Estimates, intervals and comparisons

For free slopes, these are different questions:

- **What did the numerical fit return?** `fit$slopes$OptimizerEstimate`
  retains the fitted relative slopes for descriptive sensitivity
  analysis. The compatibility column `Estimate` contains the same
  numerical values; it does not override `ParameterStatus` or
  `PrimaryEstimate`.

- **How uncertain is a slope?** `confint(fit, parm = "slopes")` returns
  approximate pointwise intervals for eligible GPCM MML fits.
  `diagnose_mfrm(fit)$parameter_uncertainty$slopes` supplies the same
  95% calculation with `CIEligible` and `InferenceReview`. Ineligible
  solutions retain missing ordinary bounds and explicitly labelled
  `Optimizer*` diagnostic quantities. Old eligibility flags do not
  authorize an interval.

- **Which model should be selected?** MML information criteria may be
  retained numerically.
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  ranks GPCM MML candidates when its separate solution and comparison
  checks pass. `ICSelectable` describes likelihood and integration
  requirements; `ICFitEligible` describes the fit's solution check;
  `ICComparable` is the final comparison decision. The weighting review
  preserves this decision without making an operational-scoring
  recommendation. With `nested = TRUE`, it can also request the
  separately checked PCM/GPCM equal-slope test.

The inference restrictions above concern the current package
implementation; they are not a claim that GPCM inference is impossible
in general. A local rank or curvature check does not by itself assess
competing solutions, numerical integration error or the performance of
an interval procedure. Relative-slope intervals have their own checks. A
PCM/GPCM LRT requires the matched comparison described below; more
iterations or quadrature points alone do not establish its structural
assumptions.

## Different requirements for intervals and model comparison

These decisions are separate, and do not follow from unidimensionality:

- **Slope intervals:**
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
  with `parm = "slopes"` uses the inverse joint observed information,
  including estimated population parameters, and the sum-zero log-slope
  transformation. It checks likelihood consistency, convergence,
  positive unregularized information, unit weights and a grid of at
  least 31 points. The exponentiated log-Wald limits are pointwise
  model-based approximations for geometric-mean-one relative slopes by
  default. Explicit options add population-SD-standardized slopes, named
  ratios or differences, Bonferroni adjustment and independent-cluster
  sandwich covariance. An experimental `method = "profile"` with one
  named `slope` reoptimizes all nuisance parameters, including the
  normal population, and retains endpoint failures and a saved
  likelihood plot. Its initial scope excludes anchors, interactions,
  covariates and standardized targets. Profile coverage and superiority
  over Wald have not been established. Small samples and
  misspecification can still affect coverage. Failed checks retain
  missing limits and a reason.
  [`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md)
  provides fitted-model bootstrap intervals or a matched PCM/GPCM test;
  [`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
  propagates calibration uncertainty to curves. Probability-curve
  intervals showed undercoverage in a saved-fit study of small
  incomplete designs, including finite-grid Bonferroni families.
  Numerical availability and multiplicity adjustment do not certify
  nominal coverage; bootstrap coverage requires separate evidence too.
  Saved results support
  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md),
  [`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
  and
  [`as_ggplot()`](https://ryuya-dot-com.github.io/mfrmr/reference/as_ggplot.md);
  attach selected intervals to
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  for reports and exports. Their targets remain separate from
  Wright/Pathway location and fit displays.

- **Information criteria:** AIC/BIC compare maximized likelihoods on the
  same response data, with appropriate free-parameter counts and
  numerical accuracy. They do not require a slope confidence interval or
  nested models. The GPCM MML solution check reevaluates the retained
  likelihood, terminal gradient and positive unregularized local
  information without refitting. It uses the existing numerical-gradient
  tolerance (at most \\10^{-4}\\) and information-inversion eigenvalue
  tolerance. The existing joint information calculation is shared with
  slope intervals and governed by
  `options(mfrmr.max_information_bytes = 256 * 1024^2)` rather than an
  80-coordinate cutoff. The budget estimates dense matrix workspace, not
  total process memory. An unavailable check gives a reason, not
  permission to rank. Local checks do not prove global optimality or
  integration accuracy; inspect different starts and
  [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
  when the decision is close.

- **PCM/GPCM likelihood-ratio test:** with the same population model,
  step structure and other constraints, setting all relative slopes to
  one gives PCM. One is an interior positive slope value, not a
  variance-zero boundary. With \\G\\ slope levels and no other differing
  free parameters, the null imposes \\G-1\\ independent log-slope
  restrictions. A chi-square reference additionally requires identified,
  regular solutions and adequate sample information.
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  with `nested = TRUE` checks the matched model settings, G-1 free
  dimensions and regular local MML solutions before reporting an
  asymptotic chi-square p-value. Default PCM and GPCM calls can use
  different population models: supply `population_formula = ~1` and the
  same person data to both fits to compare estimated-normal models.
  Small or sparse samples can give inaccurate asymptotic p-values;
  examine starting-value and quadrature sensitivity and report the
  test's assumptions.

The official [R AIC
documentation](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/AIC.html)
describes likelihood comparability. The [mirt model
documentation](https://philchalmers.github.io/mirt/reference/mirt.html)
documents GPCM and information-matrix SEs, and its [model-comparison
documentation](https://philchalmers.github.io/mirt/reference/anova-method.html)
describes likelihood-ratio and information-criterion comparisons. These
are examples of supported statistical methods, not validation of mfrmr's
many-facet implementation.

## Comparing models with ConQuest and TAM

Match the response formula before comparing estimates. In mfrmr, the
selected positive slope multiplies ability, facet locations and the
category step together. A slope multiplying ability alone, with
separately additive rater severity, generally specifies a different
many-facet model.

TAM's `tam.mml.mfr()` does not estimate slopes itself, but its
documented Example 14, Model 14c combines a facet intercept design with
grouped slopes in `tam.mml.2pl(irtmodel = "GPCM.design")`. ConQuest
estimates GPCM scores with `scoresfree`; its default slopes belong to
combinations of facets (generalized items), with further grouping
available through a scoring design. Neither construction automatically
reproduces mfrmr's single slope family and complete-predictor
multiplication. See the [TAM fitting
documentation](https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html)
and [ConQuest Note
8](https://www.acer.org/files/Note_8--The_ConQuest_4_Model.pdf).

A matched item-only, positive-slope GPCM with an estimated normal
population can be expressed on either scale. mfrmr fixes the geometric
mean of relative slopes \\\alpha_i\\ to one and estimates the population
SD \\\sigma\\ conditional on any population covariates. On the
unit-variance scale the slopes become \\a_i=\sigma\alpha_i\\. Locations,
steps and any population regression also need transformation. This
equivalence does not include imposing both unit variance and
geometric-mean-one slopes: together they impose an additional
restriction.

Transformed intervals require the joint parameter covariance.
Multiplying relative-slope interval endpoints by an estimated population
SD omits its uncertainty and covariance with the slopes. Use
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
with `parm = "slopes", scale = "standardized"` for the full
transformation; with covariates the SD is the residual population SD.
TAM's documented `tam.se()` omits parameter covariances; ConQuest
distinguishes the covariance of parameter estimates from the
latent-population covariance. Neither marginal SEs nor a
latent-population covariance matrix replace the required joint matrix.
Numerical replication requires matching data, model and identification.
IC selection can compare different, nonnested models on compatible
likelihoods; verify each model's free-parameter count and integration
accuracy. A likelihood-ratio test additionally requires a nested null.
Consult
[`vignette("mfrmr-gpcm-scope")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md)
for examples, sources and the scope of existing numerical comparisons.
These do not supply a general GPCM import or comparison API.

## Conditional Person uncertainty

Person posterior SDs and intervals, where returned, condition on the
fitted calibration; they are not slope intervals or calibration-aware
confidence intervals. An unstable calibration also limits their
interpretation.

## Typical workflow

1.  Call `gpcm_capability_matrix()` before using `GPCM` in a new
    workflow.

2.  For `supported_with_caveat`, read `Boundary` before interpreting
    output.

3.  For `blocked` or `deferred`, follow `RecommendedRoute` instead.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
[`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md),
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)

## Examples

``` r
gpcm_capability_matrix()
#> mfrmr GPCM workflow availability
#> Most rows describe one slope family; two-family MML has a separate provisional scope.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>                 Status Routes
#>              supported      2
#>  supported_with_caveat     19
#>                blocked      1
#>               deferred      2
#> 
#> Route preview
#>                                             Area                Status
#>                       Core fitting and summaries supported_with_caveat
#>   Exploratory diagnostics and residual follow-up supported_with_caveat
#>  Fitted-object posterior scoring and information             supported
#>                    Core curve and category views             supported
#>       Checklist and summary-table appendix route supported_with_caveat
#>                      Operational misfit casebook supported_with_caveat
#>         Weighting review and model-choice review supported_with_caveat
#>                    Operational linking synthesis supported_with_caveat
#> 
#> ... 16 more route(s).
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
gpcm_capability_matrix("supported")
#> mfrmr GPCM workflow availability
#> Most rows describe one slope family; two-family MML has a separate provisional scope.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>     Status Routes
#>  supported      2
#> 
#> Route preview
#>                                             Area    Status
#>  Fitted-object posterior scoring and information supported
#>                    Core curve and category views supported
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
gpcm_capability_matrix("blocked")
#> mfrmr GPCM workflow availability
#> Most rows describe one slope family; two-family MML has a separate provisional scope.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>   Status Routes
#>  blocked      1
#> 
#> Route preview
#>                                      Area  Status
#>  FACETS output-contract score-side review blocked
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
gpcm_capability_matrix(view = "scores")
#>                            Capability                Status
#> 1       Package-native score estimand available_with_caveat
#> 2   Slope-aware expected-score fields available_with_caveat
#> 3            Native score uncertainty available_with_caveat
#> 4 FACETS-compatible score uncertainty           unavailable
#> 5 Structural fair-average uncertainty      supporting_route
#> 6  Equal-discrimination PCM reference      supporting_route
#> 7     Package-native scorefile export available_with_caveat
#> 8       Full FACETS score-side review           unavailable
#> 9            Reporting interpretation available_with_caveat
#>                                                                                                                                                                                       Limitation
#> 1                                                            Expected-score and residual quantities are package-native GPCM outputs, not Rasch measure-to-score or FACETS-equivalent quantities.
#> 2                                                                               Expected-score fields use the fitted slope structure and therefore depend on the declared step and slope facets.
#> 3                                                                       Uncertainty fields require the relevant MML diagnostics; otherwise the scorefile reports an explicit unavailable status.
#> 4                                                                                             No FACETS-compatible free-discrimination score-side uncertainty definition is currently available.
#> 5 Structural fair-average SEs condition on Person EAP/reference means and remain diagnostic-only (FairCIEligible = FALSE); full-refit coverage and FACETS score-side equivalence are unverified.
#> 6                                                           Unit-slope agreement with PCM is an interpretation reference, not evidence that every free-slope score quantity is Rasch-equivalent.
#> 7                                                                                                               The exported scorefile is package-native and must retain its GPCM caveat fields.
#> 8                                                                                                           The full FACETS-style score-side review is unavailable for free-discrimination GPCM.
#> 9                                                                                                 GPCM score-side output is sensitivity evidence, not an automatic operational scoring decision.
#>                                                                                                                              Alternative
#> 1                                  Use `facets_output_file_bundle(include = "score")` and report the package-native estimand explicitly.
#> 2                                 Inspect the fitted step and slope summaries before interpreting exported expected scores or residuals.
#> 3                Use an MML fit when uncertainty is required, or report the explicit unavailable status without substituting another SE.
#> 4             Use the package-native scorefile with caveats; use an `RSM` or `PCM` fit when a full FACETS score-side review is required.
#> 5 Use `fair_average_table(fit, fair_se = TRUE)` directly and label the result as slope-aware element-conditional diagnostic uncertainty.
#> 6                                           Fit a `PCM` reference when equal-discrimination score semantics are required for comparison.
#> 7                                           Use `facets_output_file_bundle(include = "score")` and retain all status and caveat columns.
#> 8                                                          Keep full `facets_output_contract_review()` work on the `RSM` or `PCM` route.
#> 9                                                Report GPCM as a slope-aware sensitivity analysis and keep operational claims separate.
gpcm_capability_matrix("unavailable", view = "scores")
#>                            Capability      Status
#> 1 FACETS-compatible score uncertainty unavailable
#> 2       Full FACETS score-side review unavailable
#>                                                                                           Limitation
#> 1 No FACETS-compatible free-discrimination score-side uncertainty definition is currently available.
#> 2               The full FACETS-style score-side review is unavailable for free-discrimination GPCM.
#>                                                                                                                  Alternative
#> 1 Use the package-native scorefile with caveats; use an `RSM` or `PCM` fit when a full FACETS score-side review is required.
#> 2                                              Keep full `facets_output_contract_review()` work on the `RSM` or `PCM` route.
gpcm_capability_matrix(view = "unavailable")
#>                                                       Area
#> 1                 FACETS output-contract score-side review
#> 2            Native MCMC and posterior-predictive sampling
#> 3 Formal structural confidence intervals for corrected JML
#>                            Helper   Status
#> 1 facets_output_contract_review()  blocked
#> 2                            <NA> deferred
#> 3                            <NA> deferred
#>                                                                                                                                                                                                                                                                                                                                                   Boundary
#> 1                                                                                     Limited to direct scorefile export rather than the full FACETS-style output-contract review. Direct scorefile export is available with caveats, but contract-wide coverage and metric claims still require a broader free-discrimination score-side review contract.
#> 2 mfrmr does not run native GPCM MCMC or posterior-predictive sampling. export_mfrm_model() writes Stan/brms code for eligible one-family MML sources and Stan code for two-family sources, adding explicit structural priors and retaining supported fixed constraints. Conditional posterior response diagnostics are a different, non-MCMC calculation.
#> 3                                 Formal corrected-JML structural intervals are unavailable. The explicit corrected estimator reports local adjusted-equation RootSE, not established structural coverage. Uncorrected JML location SEs and post-hoc Person intervals answer different questions. None is a bias-corrected structural confidence interval.
#>                                                                                                                                                                                                                                                                                             RecommendedRoute
#> 1                                                                                                 Use direct fair-average tables and graph-only compatibility outputs; use package-native scorefile export with its stated caveats, and keep full FACETS output-contract reviews on the `RSM` / `PCM` route.
#> 2 Use MML and conditional posterior scoring for their stated targets. Use export_mfrm_model(format = 'stan' or 'brms') for eligible one-family sources, or format = 'stan' for two-family sources. Then review priors, sampler diagnostics and posterior fit; code export is not native Bayesian estimation.
#> 3                                                                                                                          Use current JML outputs within their descriptive scope, or explicitly choose MML inference if its population assumptions suit the analysis; do not transfer MML intervals to JML.
```
