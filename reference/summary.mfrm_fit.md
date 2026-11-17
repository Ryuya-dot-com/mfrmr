# Inspect fitted estimates and interpretation status

Summarize a fitted model without changing its estimates. The default
returns fit-only tables; read `s$decision` after `s <- summary(fit)` for
interpretation limits and next actions. Individual estimates are
available separately through `as.data.frame(fit)`.

## Usage

``` r
# S3 method for class 'mfrm_fit'
summary(
  object,
  digits = 3,
  top_n = 5,
  ...,
  profile = c("fit", "facets", "reporting"),
  detail = NULL,
  diagnostics = NULL,
  compute = c("auto", "never"),
  include_person = FALSE,
  comparison_review = NULL
)
```

## Arguments

- object:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- digits:

  Number of digits for printed numeric values.

- top_n:

  Number of extreme facet/person rows shown in summaries.

- ...:

  Reserved for generic compatibility. The workflow arguments that follow
  `...` must be supplied by name.

- profile:

  Summary profile. `"fit"` preserves the lightweight fit-only contract
  and does not compute diagnostics. `"facets"` adds a comprehensive
  measurement review using familiar FACETS-style section organization;
  it does not require FACETS knowledge or software. `"reporting"` adds
  the reporting-oriented results profile.

- detail:

  Printed detail. When `NULL` (the default), the lightweight `"fit"`
  profile retains the legacy `"full"` print while expanded profiles use
  `"brief"`. Neither mode prints person identifiers unless
  `include_person = TRUE`; `"brief"` also reduces the number of
  fit-level sections shown in the console.

- diagnostics:

  Optional matching output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  It is reused by the `"facets"` and `"reporting"` profiles without
  recomputation.

- compute:

  Diagnostic computation policy for the expanded profiles. `"auto"`
  computes diagnostics once when they were not supplied; `"never"`
  returns the available fit-only portions and marks every requested
  dependent section as `"not_computed"`. The `"fit"` profile never
  computes diagnostics.

- include_person:

  Logical. Whether person identifiers may be printed in extreme-person
  tables and requested by the fit-pathway route. The default is `FALSE`
  for privacy-safe console output.

- comparison_review:

  Optional prospective interaction review from
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).
  Explicitly requests fitted contrasts and retained- point numerical
  checks through
  [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
  saved as `$interaction_comparisons`. It does not fit a model or supply
  intervals.

## Value

A `summary.mfrm_fit` list. Components are grouped below by purpose;
model-specific components are populated only where supported.

**Interpretation and availability**

- `decision`: interpretation, `FormalInference`, `Why` and `NextAction`,
  combining source-fit readiness with supplied precision evidence.
  `"No"` can mean that precision has not been assessed, rather than that
  point estimation failed. `"Yes"` is conditional on the fitted model
  and checked method; it does not establish model adequacy or
  finite-sample coverage.

- `status`, `readiness`, `data_review`: compact status, separate
  workflow states and their connectivity/category-support evidence.
  `InferenceReady` is a compatibility indicator for stored
  `FitReadiness = "ready"`; numerical convergence cannot override data,
  estimability or boundary issues.

- `key_warnings`, `notes`, `next_actions`: issues and follow-up calls.
  `caveats` retains the detailed score-support and population-design
  rows, including omissions or unstable residual variance where
  recorded.

- `section_status`: availability, including requested but `not_computed`
  sections. An unassessed check is not a passed check.

**Estimates and model settings**

- `overview`: counts, likelihood, information criteria and convergence.
  `MMLEngineUsed`, `IterationsBasis` and `ConvergenceBasis` identify the
  algorithm and stopping record. See
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  and the information-criterion section of
  [fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md)
  for eligibility, MML denominators based on Persons and quadrature
  requirements before ranking models.

- `person_overview`, `facet_overview`, `targeting`: distributions and
  Person-versus-facet targeting. For the meaning and direction of
  individual `Estimate` values, see
  [`as.data.frame.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md).
  A blocked source fit's extreme MML EAPs are excluded from aggregate
  Person/targeting summaries but retained in the extreme tables; counts,
  exclusions and estimate use are reported.

- `person_high`, `person_low`, `facet_extremes`: extreme estimates;
  Person identifiers are printed only with `include_person = TRUE`.

- `step_overview`: spread and monotonicity by PCM/GPCM `StepFacet`
  ladder, or the common RSM ladder.

- `settings_overview`: identification, category and numerical settings.
  `CenteringScope` distinguishes whole-facet and remainder centering
  from `NoncenterFacet`. `CategoryPolicy` is the declared choice;
  `ScoreRecoded` records actual value changes. An unchanged score map
  does not identify the policy. Missing historical metadata retain
  legacy centering and `"not_recorded"`/`NA` category fields. Regenerate
  the summary from its fit to obtain new fields; reading an old summary
  does not update stored results.

- `population_overview`, `population_coefficients`, `population_design`,
  `population_coding`: population basis/variance/omissions, active
  regression coefficients, design checks, and categorical
  levels/contrasts needed when scoring new Persons.

- `interaction_overview`: fitted interactions. `interaction_comparisons`
  appears only when requested through `comparison_review`, preserving
  unavailable contrasts, the review and numerical checks without new
  fitting.

**Numerical and boundary evidence**

- `numerical_review`: optimization, curvature, starting-value,
  integration and reproducible-refit checks with next actions; does not
  change readiness.

- `starting_values`, `starting_value_notes`: all attempted starts,
  selection, failures and cautions after `fit_mfrm(mml_starts = ...)`.
  These concern numerical sensitivity, not sampling uncertainty.

- `facet_support_boundaries`: observed boundary-constant facet levels;
  these alone do not prove infinite MLEs. `facet_recession_review`
  records certified JML additive recession directions, their scope and
  completeness. Joint rows are relative directions under the fitted
  constraints.

- `slope_overview`: GPCM slope-owner and parameter-status summary.
  `Min`, `Max` and `GeometricMean` use primary estimates; `Optimizer*`
  fields retain numerical iterates where primary estimates are
  unavailable. An identification constraint does not establish
  precision.

- `inference_evidence`: GPCM MML stationarity, local rank, information,
  slope-boundary screening and final decision. Local evidence does not
  override an inconclusive boundary audit.

- `point_estimation`: for two-family GPCM and supported endpoint
  reductions, the point-estimate status and separate integration,
  local-maximum and limited boundary reviews. This does not qualify SEs
  or intervals. Older fits are labelled unreviewed

- `point_targets`, `step_targets`, `point_limit`, and optional
  `category_map`: target status, refit counts and original score labels
  for supported GPCM limiting-likelihood estimates; see
  [mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md)
  for the distinction between deliberately skipped optimization,
  numerical failure and available limiting estimates

- `rating_support`, `rating_crossings`, `rating_categories`,
  `rating_support_notes`: two-family per-level persons, rating rows,
  per-person exposure, marginal crossings and category counts.
  `DataBasis` separates full-model and limiting-fit data. Counts do not
  qualify precision

**Preparation and reporting**

- `row_retention`, `preparation_notes`: retained rows and preparation
  records.

- `attached_diagnostics`, `attached_diagnostics_cols`: whether
  diagnostics were attached to the fit, and which columns were attached
  to Person rows.

- `reporting_map`, `required_visual`: companion tables and ordered
  Wright-map/ fit-pathway routes for reporting. Figure availability does
  not qualify intervals.

- `provenance`, `analysis`: profile, diagnostic source, computation
  policy and compact fit/results indexes. `results` is the reused
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  object for expanded profiles, or `NULL` for the default fit-only
  profile.

- `digits`: numeric print precision. Printing does not refit or change
  the stored tables.

## Details

Keep the fitted object for further analysis. `s <- summary(fit)` saves
tables; print `s` or select a component with `$`. Start with
`s$decision`, then `s$person_overview` and `s$facet_overview`. These
describe distributions of estimates; use `as.data.frame(fit)` for
individual Person and facet-level rows. Centered facet means can be zero
by constraint, so compare levels or their spread rather than
interpreting the mean as an empirical finding.

The default `profile = "fit"` does not compute diagnostics. For an
ordinary RSM/PCM precision review, pass matching
`diagnostics = diagnose_mfrm(fit)`; reuse existing diagnostics when
available. Read `decision$Why` together with the parameter-specific
status; the Value section explains the decision fields.

Expanded profiles use FACETS-style organization without running FACETS
or claiming numerical equivalence. Reuse their `$results` and
`$results$diagnostics` for further reporting.

## Corrected JML

Corrected JML returns a separate summary of saved `tables`, numerical
`attempts`, correction order and RootSE interpretation. All profiles use
that same saved summary without ordinary diagnostics.
`include_person = TRUE` adds conditional Person profiles without Person
SEs. See
[fit_mfrm_technical_details](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm_technical_details.md);
the Value section describes uncorrected fits.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
library(mfrmr)

# Saved synthetic MML/RSM analysis of example_operational.
# For your own data, fit a model first; see ?fit_mfrm.
example_fit <- readRDS(system.file("examples", "operational-mml.rds", package = "mfrmr"))
fit <- example_fit$fit

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
#> 1 Criterion      3     4.62e-18      0.302      -0.344       0.224 0.568
#> 2 Rater          6     0             0.399      -0.606       0.412 1.02 

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

# Extract estimates and select the rows to display
estimates <- as.data.frame(fit)
head(subset(estimates, Facet == "Person")) # First six persons
#>    Facet Level    Estimate Extreme
#> 1 Person  P001  0.28429588    none
#> 2 Person  P002  0.66118004    none
#> 3 Person  P003  0.02177773    none
#> 4 Person  P004  0.22410785    none
#> 5 Person  P005 -0.17496065    none
#> 6 Person  P006  0.67681003    none
subset(estimates, Facet == "Rater")       # All raters
#>    Facet Level   Estimate Extreme
#> 49 Rater   R01 -0.6059776    <NA>
#> 50 Rater   R02 -0.3820356    <NA>
#> 51 Rater   R03  0.2120388    <NA>
#> 52 Rater   R04  0.1799462    <NA>
#> 53 Rater   R05  0.1842365    <NA>
#> 54 Rater   R06  0.4117917    <NA>
subset(estimates, Facet == "Criterion")   # All criteria
#>        Facet        Level   Estimate Extreme
#> 55 Criterion      Content -0.3441471    <NA>
#> 56 Criterion     Language  0.1204520    <NA>
#> 57 Criterion Organization  0.2236950    <NA>
```
