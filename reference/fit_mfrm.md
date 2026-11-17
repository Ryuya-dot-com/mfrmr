# Fit many-facet models to ordered ratings

Estimate rater severity, task or criterion difficulty, and category
thresholds from a rating table. Person abilities are also returned when
supported by the estimator. Supply your column names through `person`,
`facets` and `score`; the Examples show one RSM analysis from data to
results.

## Usage

``` r
fit_mfrm(
  data,
  person = NULL,
  facets = NULL,
  score = NULL,
  model = c("RSM", "PCM", "GPCM"),
  method = c("MML", "JML", "JMLE", "CML"),
  step_facet = NULL,
  slope_facet = NULL,
  rating_min = NULL,
  rating_max = NULL,
  weight = NULL,
  anchors = NULL,
  group_anchors = NULL,
  population_formula = NULL,
  person_data = NULL,
  facet_interactions = NULL,
  spec = NULL,
  control = list(),
  ...
)

# S3 method for class 'mfrm_cml_fit'
summary(object, ...)

# S3 method for class 'mfrm_cml_fit'
print(x, ...)

# S3 method for class 'mfrm_comparison_fit'
print(x, ...)

# S3 method for class 'mfrm_comparison_fit'
summary(object, ...)
```

## Arguments

- data :

  A `data.frame` in long format with one row per observed rating event.
  Grouped or rowwise tibbles are analyzed as one table; dplyr grouping
  metadata is ignored. The named model columns define the design. Pass
  the rating table itself, not the result of
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).

- person :

  Column name for Person identifiers (character scalar; may be supplied
  via `spec$person`).

- facets :

  Character vector of one or more non-Person facet column names (may be
  supplied via `spec$facets`). Reserved internal names (`Person`,
  `Score`, `Weight`, `score_k`, `theta`, `steps`, `interactions`,
  `log_slopes`, `beta`, `log_sigma2`) cannot be used as facet names.

- score :

  Column name for observed integer category scores (character scalar;
  may be supplied via `spec$score`).

- model :

  Measurement model: `"RSM"` (default; shared category thresholds),
  `"PCM"` (facet-specific thresholds via `step_facet`), or `"GPCM"`
  (positive facet-level discriminations via `slope_facet`).

- method :

  Estimator: `"MML"` (default marginal maximum likelihood), `"JML"`
  (`"JMLE"` alias; joint maximum likelihood), or `"CML"` (conditional
  maximum likelihood on Person totals for unit-weight RSM/PCM with
  preserved categories).

- step_facet :

  Facet whose levels own separate step ladders in `PCM` and `GPCM` (omit
  for `RSM`; required explicitly for `GPCM` and `CML` `PCM`).

- slope_facet :

  Facet whose levels own positive discriminations in `GPCM` (single
  facet name for one-family `GPCM`, or ordered length-two character
  vector for the experimental two-family MML route). Use
  `spec$slope_reference` to name the geometric-mean-one family (default:
  first slope facet); `step_facet` and `noncenter_facet` select their
  roles independently among declared non-Person facets. See
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md).

- rating_min :

  Optional intended minimum category score (supply together with
  `rating_max` and `category_policy = "preserve"` when boundary
  categories may be unobserved).

- rating_max :

  Optional intended maximum category score (supply together with
  `rating_min` and `category_policy = "preserve"` when boundary
  categories may be unobserved).

- weight :

  Optional column name of positive observation weights.

- anchors :

  Optional direct-anchor `data.frame` with columns `Facet`, `Level`, and
  `Anchor` fixing logit coordinates (non-Person facets in MML; JML also
  permits Person anchors).

- group_anchors :

  Optional group-mean constraint `data.frame` with columns `Facet`,
  `Level`, `Group`, and `GroupValue`.

- population_formula :

  Optional one-sided Person-level latent-regression formula (e.g.,
  `~ group + pretest`) for unidimensional conditional-normal
  `method = "MML"`.

- person_data :

  Optional one-row-per-Person `data.frame` supplying covariates
  referenced by `population_formula`.

- facet_interactions :

  Optional confirmatory two-way non-Person interaction terms (e.g.,
  `"Rater:Criterion"`) for `RSM` and `PCM`.

- spec :

  Optional named list for reusing model, data and identification
  settings. Explicit top-level arguments override matching entries. See
  the specification entries in
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md).

- control :

  Named list of numerical and post-fit settings; for example,
  `list(quad_points = 31, maxit = 400)`. Supported entries and
  conditions are listed in
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md).

- ... :

  Fully named legacy flat arguments from the supported `spec` and
  `control` settings. Unnamed arguments, abbreviated or unknown names,
  and duplicate specifications across `spec`/`control` and `...` fail
  immediately. Unused by the CML and comparison-fit summary/print
  methods.

- object :

  A fitted CML result for its summary, print, covariance and
  log-likelihood methods, or a comparison-only result for its summary
  and print methods.

- x :

  A fitted CML result for its summary, print, covariance and
  log-likelihood methods, or a comparison-only result for its summary
  and print methods.

## Value

Ordinary MML/JML returns an `mfrm_fit` (a named list). Start with
`results <- summary(fit)`:

- `results$person_overview` summarizes Person ability estimates.

- `results$facet_overview` summarizes each non-Person facet.

- `results$decision` reports interpretation limits and suggested
  actions.

Individual estimates are in `fit$facets$person`, `fit$facets$others`,
`fit$steps` and, for GPCM, `fit$slopes`. Check `EstimateUse` or
`ParameterStatus` for points, and `CIEligible` with its accompanying
reason for intervals, where provided. Unavailable uncertainty is not
zero. See
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md)
and
[mfrm_fit_extractors](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md)
for extraction.

CML returns an `mfrm_cml_fit`: `summary(fit)$locations` and `$steps`
contain structural estimates. Jeffreys-penalized JML returns an
`mfrm_jeffreys_fit`
([`summary.mfrm_jeffreys_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md));
comparison-only fitting returns an `mfrm_comparison_fit`
([`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)).
These classes have different supported outputs. Full field descriptions
are in
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md).

## Details

Each row represents one rating. Ordinary fitting omits rows missing
required model values; review
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
before fitting your own data. Repeated Person-by-facet cells are
retained and flagged for review. Declaring them independent does not
establish conditional independence.

Choose the intended category ladder explicitly. The default can collapse
gaps in observed categories, changing the fitted steps. The example
preserves a 1–4 rubric; a preserved, unobserved internal category
prevents ordinary fitting.

## Model and inference choices

`RSM` shares category thresholds; `PCM` gives each level of `step_facet`
its own ladder. `GPCM` also estimates relative discriminations for
`slope_facet`. The default RSM/PCM MML model fixes the Person
distribution to N(0,1). Together with centered non-Person facets and
steps, this fixes the overall ability-to-difficulty location as well as
the population SD. These are substantive assumptions, not just a
reporting scale. To estimate the mean and SD, use
`population_formula = ~ 1` and matching `person_data` (one row per
Person). One-family GPCM MML estimates them by default; two-family GPCM
requires different explicit settings. See
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
for population, anchoring and slope constraints before comparing models.

MML assumes the specified population distribution. JML estimates Person
and structural effects jointly; many Persons do not remove
incidental-parameter bias when each has few ratings. CML conditions on
Person totals and returns structural effects without Person abilities.
Its supported RSM/PCM route requires unit weights and preserved
categories.

Point estimates and intervals have separate availability checks. Failure
to obtain an interval does not by itself invalidate an available point
estimate; inspect the reported status and reason. A finite optimizer
value is not automatically an interpretable estimate, and a finite SE
does not establish interval coverage.
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
documents structural intervals;
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
gives estimator-specific conditions and references.

## References

Andrich, D. (1978). A rating formulation for ordered response
categories. *Psychometrika, 43*(4), 561–573.
[doi:10.1007/BF02293814](https://doi.org/10.1007/BF02293814)

Masters, G. N. (1982). A Rasch model for partial credit scoring.
*Psychometrika, 47*(2), 149–174.
[doi:10.1007/BF02296272](https://doi.org/10.1007/BF02296272)

Muraki, E. (1992). A generalized partial credit model: Application of an
EM algorithm. *Applied Psychological Measurement, 16*(2), 159–176.
[doi:10.1177/014662169201600206](https://doi.org/10.1177/014662169201600206)

Andersen, E. B. (1973). Conditional inference for multiple-choice
questionnaires. *British Journal of Mathematical and Statistical
Psychology, 26*(1), 31–44.
[doi:10.1111/j.2044-8317.1973.tb00504.x](https://doi.org/10.1111/j.2044-8317.1973.tb00504.x)

Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA Press.

## See also

[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`summary.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_fit.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`plot.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_fit.md)

## Examples

``` r
# Load the package
library(mfrmr)

# Load example ratings and look at the first six rows
ratings <- load_mfrmr_data("example_operational")
head(ratings)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# RSM with a preserved 1--4 rubric and fixed N(0,1) Person distribution
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
  method = "MML",
  model = "RSM"
)

# Wright map: Person abilities, facet effects and thresholds
plot(fit)


# Save the summary, then display its tables
results <- summary(fit)
results$person_overview # One row summarizing person ability estimates
#> # A tibble: 1 × 11
#>   Persons DistributionN ReviewExcludedExtremeE…¹ EstimateUse   Mean    SD Median
#>     <int>         <int>                    <int> <chr>        <dbl> <dbl>  <dbl>
#> 1      48            48                        0 source_fit… -0.155 0.824 -0.208
#> # ℹ abbreviated name: ¹​ReviewExcludedExtremeEAPs
#> # ℹ 4 more variables: Min <dbl>, Max <dbl>, Span <dbl>, MeanPosteriorSD <dbl>
results$facet_overview  # One row per facet: number of levels, mean, SD, range
#> # A tibble: 2 × 7
#>   Facet     Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>   <chr>      <int>        <dbl>      <dbl>       <dbl>       <dbl> <dbl>
#> 1 Criterion      3     0             0.302      -0.344       0.224 0.568
#> 2 Rater          6    -4.64e-18      0.399      -0.606       0.412 1.02 

# Check the interpretation status and recommended next step
results$decision
#>                                                           Interpretation
#> 1 Fit-readiness requirements satisfied; formal precision review required
#>   FormalInference FitReadiness
#> 1              No        ready
#>                                                                                                                                                                                                                                      Why
#> 1 Formal precision support has not been evaluated. These checks assess numerical readiness and the requested precision method under the specified model; they do not establish model adequacy or finite-sample coverage for this design.
#>                                                                                                                                                   NextAction
#> 1 Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate formal precision support; fit readiness alone is not a formal-inference decision.
```
