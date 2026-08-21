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
  and does not compute diagnostics. `"facets"` adds a FACETS-organized
  measurement review, while `"reporting"` adds the reporting-oriented
  results profile.

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
  by the non-numerical readiness gates

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

- `decision`: separates that fit gate from formal precision support. A
  fit-only summary returns `FormalInference = "No"` until a matching
  `mfrm_diagnostics` object is supplied through `diagnostics =`; use
  `summary(diagnostics)$decision` for the equivalent precision-aware
  view.

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
    FACETS-organized review.

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
    or the fixed-calibration posterior scoring helpers.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
toy <- load_mfrmr_data("example_operational")
# Seven quadrature points keep this executable example short. For a final
# analysis, restore the default or a prespecified grid and review sensitivity.
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", model = "RSM", quad_points = 7, maxit = 30
)
s <- summary(fit)
s$overview[, c(
  "Model", "Method", "Converged", "FitReadiness", "InferenceReady",
  "ConvergenceSeverity"
)]
#> # A tibble: 1 × 6
#>   Model Method Converged FitReadiness InferenceReady ConvergenceSeverity
#>   <chr> <chr>  <lgl>     <chr>        <lgl>          <chr>              
#> 1 RSM   MML    TRUE      ready        TRUE           pass               
s$readiness
#>        Domain                                        Status
#> 1         Fit                                         ready
#> 2   Numerical                                          pass
#> 3        Data                                          pass
#> 4      Design                                   pass_linked
#> 5   Stability                                          pass
#> 6 Diagnostics                                  not_assessed
#> 7   Reporting ready_for_diagnostics_and_reporting_follow_up
#>                                                                                                                              Detail
#> 1                                                                                       All stored fit-readiness components passed.
#> 2                                                                                            Optimizer returned convergence code 0.
#> 3                                                                                No preparation warning or review row was retained.
#> 4 The observed graph satisfies the connectivity requirement; review the remaining design and identification assumptions separately.
#> 5                                                                         No boundary-constant non-person facet level was detected.
#> 6                                                             Diagnostics have not yet been incorporated into this fit-only status.
#> 7                                                             Reporting status is the strictest applicable upstream workflow state.
# `InferenceReady = TRUE` means all five stored fit components passed.
# It does not, by itself, support formal SE/CI or reliability.
diag <- diagnose_mfrm(fit, residual_pca = "none")
summary(fit, diagnostics = diag)$decision
#>               Interpretation FormalInference FitReadiness
#> 1 Ready for formal inference             Yes        ready
#>                                           Why
#> 1 All stored fit-readiness components passed.
#>                                                                                                                                               NextAction
#> 1 After reviewing convergence, run `review <- summary(fit, profile = "facets", detail = "brief")` for the comprehensive FACETS-organized result surface.
# Design, Stability, Diagnostics, and Reporting remain purpose-specific
# workflow reviews rather than alternative fit-readiness derivations.
# If Numerical is not a pass, inspect the retained polish stages; increasing
# `maxit` alone may not resolve the review.
s$person_overview
#> # A tibble: 1 × 11
#>   Persons DistributionN ReviewExcludedExtremeE…¹ EstimateUse   Mean    SD Median
#>     <int>         <int>                    <int> <chr>        <dbl> <dbl>  <dbl>
#> 1      48            48                        0 source_fit… -0.141 0.811 -0.107
#> # ℹ abbreviated name: ¹​ReviewExcludedExtremeEAPs
#> # ℹ 4 more variables: Min <dbl>, Max <dbl>, Span <dbl>, MeanPosteriorSD <dbl>
# Interpret location and spread on the fitted logit scale together with the
# score distribution and extreme-score counts.
s$targeting
#> # A tibble: 2 × 7
#>   Facet     PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>   <dbl>       <dbl>
#> 1 Criterion     -0.141  4.62e-18    -0.141    0.811   0.298        2.72
#> 2 Rater         -0.141  0           -0.141    0.811   0.379        2.14
# Targeting and spread are descriptive. Their practical importance depends
# on the assessment purpose, sample, and facet orientation.
facets_summary <- summary(fit, profile = "facets", compute = "never")
res <- facets_summary$results
native_map <- plot(
  fit, type = "wright", renderer = "native", show_ci = TRUE, draw = FALSE
)
facets_map <- plot(
  fit, type = "wright", renderer = "facets", show_ci = FALSE,
  category_labels = c(
    `1` = "Beginning", `2` = "Developing",
    `3` = "Secure", `4` = "Advanced"
  ),
  draw = FALSE
)
# For fit statistics and the optional person-inclusive pathway, rerun the
# FACETS profile with diagnostics available, then use its `results` object.
```
