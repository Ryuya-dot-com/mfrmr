# GPCM Workflow Availability

Check which `GPCM` workflows can be used in `mfrmr`, the limits that
apply to each workflow, and the recommended alternative when a route is
not available.

The table is intended for route selection before or after fitting and is
limited to workflow availability, interpretive constraints, and the
route to use next. The fitted model uses one facet for both relative
discriminations and category steps (`slope_facet == step_facet`). It has
one substantive ability dimension. These structural choices are stated
separately from the availability of each output. An available
probability or descriptive comparison does not establish eligibility for
a confidence interval or model-selection rule.

## Usage

``` r
gpcm_capability_matrix(
  status = c("all", "supported", "supported_with_caveat", "blocked", "deferred")
)
```

## Arguments

- status:

  Which rows to return: `"all"` (default), `"supported"`,
  `"supported_with_caveat"`, `"blocked"`, or `"deferred"`.

## Value

A data.frame of class `mfrmr_gpcm_capabilities` with one row per
workflow family and columns:

- `Area`

- `Helpers`

- `Status`

- `Boundary`

- `RecommendedRoute`

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
  uses the inverse joint observed information, including estimated
  population parameters, and the sum-zero log-slope transformation. It
  checks likelihood consistency, convergence, positive unregularized
  information, unit weights and a grid of at least 31 points. The
  exponentiated log-Wald limits are pointwise model-based approximations
  for geometric-mean-one relative slopes by default. Explicit options
  add population-SD-standardized slopes, named ratios or differences,
  Bonferroni adjustment and independent-cluster sandwich covariance.
  Small samples and misspecification can still affect coverage. Failed
  checks retain missing limits and a reason.
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
reproduces mfrmr's single slope/step facet and complete-predictor
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
with `scale = "standardized"` for the full transformation; with
covariates the SD is the residual population SD. TAM's documented
`tam.se()` omits parameter covariances; ConQuest distinguishes the
covariance of parameter estimates from the latent-population covariance.
Neither marginal SEs nor a latent-population covariance matrix replace
the required joint matrix. Numerical replication requires matching data,
model and identification. IC selection can compare different, nonnested
models on compatible likelihoods; verify each model's free-parameter
count and integration accuracy. A likelihood-ratio test additionally
requires a nested null. Consult
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
#> One facet supplies both slopes and category steps.
#> MML IC comparison and PCM/GPCM tests have separate checks; relative-slope intervals use separate MML checks.
#> 
#>                 Status Routes
#>              supported      2
#>  supported_with_caveat     15
#>                blocked      1
#>               deferred      1
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
#> ... 11 more route(s).
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
gpcm_capability_matrix("supported")
#> mfrmr GPCM workflow availability
#> One facet supplies both slopes and category steps.
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
#> One facet supplies both slopes and category steps.
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
```
