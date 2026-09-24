# Summarize an `mfrm_fit` object in a user-friendly format

Summarize an `mfrm_fit` object in a user-friendly format

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
  include_person = FALSE
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

## Value

An object of class `summary.mfrm_fit` with:

- `overview`: global model/fit indicators

- `status`: concise front-door status block for quick review

- `decision`: plain-language interpretation, formal-inference status,
  reason, and highest-priority next action derived from the stored
  readiness contract plus supplied precision evidence; fit readiness
  alone never yields `FormalInference = "Yes"`

- `readiness`: the stored fit-level state plus numerical, data, design,
  stability, diagnostic, and reporting workflow states

- `data_review`: structured connectivity and facet-support evidence used
  by the non-numerical readiness requirements

- `key_warnings`: highest-priority warnings to review first

- `next_actions`: recommended follow-up helpers

- `population_overview`: current population-model basis, residual
  variance, and omission review

- `population_coefficients`: fitted latent-regression coefficients when
  a population model is active

- `population_design`: latent-regression design-matrix column check when
  a population model is active

- `population_coding`: categorical covariate levels and contrast
  provenance when a population model uses model-matrix coding

- `facet_overview`: per-facet estimate distribution summary

- `person_overview`: person-measure distribution summary with the actual
  aggregation denominator, blocked extreme-EAP exclusion count, and
  estimate use

- `targeting`: person-versus-non-person facet targeting overview
  (Wright-map-style mean/SD comparison)

- `step_overview`: threshold/step diagnostics by PCM/GPCM `StepFacet`
  ladder, or for the common RSM ladder

- `slope_overview`: parameter-readiness and explicitly labelled
  optimizer- trace summary for `GPCM` discriminations

- `inference_evidence`: for `GPCM` MML, a compact separation of
  optimizer stationarity, retained-point local rank,
  observed-information curvature, slope-boundary screening, and the
  final readiness decision. Supportive local evidence does not override
  an inconclusive boundary audit

- `interaction_overview`: model-estimated facet-interaction summary when
  the fit was specified with `facet_interactions`

- `settings_overview`: estimation-settings overview that pins the
  configuration that affects identification/scoring

- `attached_diagnostics`: logical flag indicating whether the `mfrm_fit`
  was returned with diagnostics already attached

- `attached_diagnostics_cols`: character vector of diagnostic columns
  attached to `fit$facets$person` when `attached_diagnostics = TRUE`

- `row_retention`: row counts before and after preparation filters

- `preparation_notes`: structured preparation notes retained from
  `fit$prep`

- `reporting_map`: routing map showing which companion summaries and
  tables should be used for the four manuscript-oriented reporting
  sections (data description, diagnostics, category checks, draft
  reporting)

- `person_high` / `person_low`: highest and lowest person measures

- `facet_extremes`: extreme facet-level estimates

- `facet_support_boundaries`: observed boundary-constant non-person
  facet levels, kept distinct from parameter-level recession conclusions

- `facet_recession_review`: certified JML additive facet recession
  directions, including review scope and completeness

- `caveats`: structured warning/review rows for score-support and
  latent-regression population-model issues

- `notes`: short interpretation notes

- `digits`: numeric-print precision threaded through to
  `print.summary.mfrm_fit()`

- `section_status`: availability and explicit non-computation boundaries

- `required_visual`: ordered Wright-map and Infit-pathway routes

- `provenance`: profile, diagnostic source, computation policy, and the
  FACETS-organization interpretation boundary

- `analysis`: compact fit/results indexes used for first-screen review

- `results`: the reused `mfrm_results` backend for expanded profiles, or
  `NULL` for the lightweight `"fit"` profile

## Details

Start with `results <- summary(fit)`. Use `results$person_overview` for
the distribution of person ability estimates and
`results$facet_overview` for the distribution of estimates within each
non-person facet. These are aggregate summaries; use
`as.data.frame(fit)` for individual person and facet-level estimates.
Read `results$decision` before interpreting results. Assignment with
`<-` saves the summary without printing it; enter `results` to print the
full summary or use `$` to display a selected table. In the example,
`person_overview` has one row for all persons and `facet_overview` has
one row for raters and one for criteria. Each non-person facet's mean is
constrained to zero in this fit; use its SD and range or individual
estimates to inspect differences among its levels.

This method provides a compact, human-readable summary oriented to
reporting. The expanded profiles use FACETS-style organization for
navigation, but do not claim that FACETS was executed or that estimates
are numerically equivalent to FACETS output. It returns a structured
object and prints:

- model fit overview (N, LogLik, the canonical/legacy IC status,
  convergence)

- estimation settings that affect identification/scoring interpretation

- facet-level estimate distribution (mean/SD/range)

- person measure distribution

- step/threshold checks

- a reporting map showing which companion summaries/tables should be
  used for manuscript-oriented data description, diagnostics, category
  checks, and draft reporting

- extreme facet levels and, when explicitly requested, high/low person
  measures

## Interpreting output

- `overview`: convergence plus the versioned information-criterion
  contract. For eligible fixed-facet MML fits, BIC/SABIC use unique
  Persons, not response rows; JML, non-unit observation weights, and
  legacy objects do not enter the common MML ranking panel.
  `ICSelectable` additionally distinguishes raw screening/review
  criteria at q\<31 from criteria that may enter automatic same-grid
  comparison at q\>=31; close decisions still require a denser
  common-grid sensitivity check.

- `readiness`: the stored fit-readiness result followed by Numerical,
  Data, Design, Stability, Diagnostics, and Reporting workflow states.
  `InferenceReady` is a conservative compatibility scalar and is `TRUE`
  only when the stored `FitReadiness` is `ready`; numerical convergence
  cannot override input, estimability, category, or boundary review.

- `decision`: separates fit readiness from formal precision support. A
  fit-only summary returns `FormalInference = "No"` until a matching
  `mfrm_diagnostics` object is supplied through `diagnostics =`; use
  `summary(diagnostics)$decision` for the equivalent precision-aware
  view. The console uses this single decision throughout; a converged
  optimizer or a passed fit check does not independently authorize
  formal inference. Printed workflow, population and GPCM descriptions
  use readable labels. The returned tables retain their numerical values
  and structured status fields for programmatic use. Reprinting an
  existing summary updates its display without refitting or changing its
  stored results.

- `data_review`: overall multi-facet connectivity, facet-level score
  support, boundary-constant levels, single-level facets, and retained
  preparation notes behind the readiness rows.

- `facet_overview`: per-facet spread and range of estimates.

- `person_overview`: distribution of person measures. For a blocked
  source fit, a prior-regularized extreme MML EAP is retained in
  `person_high` / `person_low` but excluded from this aggregate and
  `targeting`; the table records its distribution denominator, exclusion
  count, and estimate use.

- `step_overview`: threshold spread and monotonicity checks, reported by
  `StepFacet` ladder for PCM/GPCM fits and as one common ladder for RSM
  fits.

- `settings_overview`: estimation settings that affect interpretation.
  For MML fits, the printed fit and summary also state the engine, fixed
  or adaptive Gauss–Hermite rule and order, one-dimensional latent
  structure, population identification, and discrimination constraint.

- `population_coding`: fitted categorical levels and contrasts that must
  be reused when scoring new persons under the population-model
  posterior.

- `key_warnings` / `notes`: short triage subset of retained zero-count
  score categories and latent-regression population-model caveats such
  as complete-case omissions, zero-variance design columns, missing
  coefficients, or unstable residual variance when present. Incomplete
  or non-finite covariates are normally handled before fitting as input
  errors or complete-case omissions; they appear here only if retained
  in a population-design check row.

- `caveats`: structured rows behind those warnings for appendix/export
  use; `print(summary(fit))` shows a compact `Caveats` block when rows
  are present.

- `reporting_map`: where to get companion outputs for manuscript
  reporting.

- `person_high` / `person_low` (opt-in for printing) and
  `facet_extremes`: extreme estimates for focused review.

- `facet_support_boundaries`: observed non-person facet levels whose
  retained responses are constant at the minimum or maximum score. This
  is a data- support warning, not by itself a proof that a parameter MLE
  is infinite.

- `facet_recession_review`: non-person facet directions certified as
  unbounded in an evaluated JML additive recession subspace. Joint rows
  are relative directions under the fitted identification constraints.

## Typical workflow

1.  Review data and score support with
    [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).

2.  Fit with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
    and read `summary(fit, profile = "fit")`.

3.  Request `summary(fit, profile = "facets")` for the comprehensive
    measurement review. The historical profile name does not mean that
    FACETS is run.

4.  Draw the required native Wright map with
    `plot(fit, type = "wright", show_ci = TRUE)`; add the FACETS
    renderer or Infit pathway only when they answer a specific follow-up
    question.

5.  For `RSM` / `PCM`, continue with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    for element-level fit checks. For bounded `GPCM`, continue with
    [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
    /
    [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md)
    or the fitted-object posterior scoring helpers.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
# \donttest{
# Load the package
library(mfrmr)

# Load example ratings and look at the first six rows
toy <- load_mfrmr_data("example_operational")
head(toy)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# Fit the model
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM"
)

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
#>   FormalInference FitReadiness                                              Why
#> 1              No        ready Formal precision support has not been evaluated.
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
# }
```
