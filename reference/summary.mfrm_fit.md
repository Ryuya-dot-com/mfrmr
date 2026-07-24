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

- `readiness`: domain-specific numerical, data, design, stability,
  diagnostic, and reporting states

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

- `person_overview`: person-measure distribution summary

- `targeting`: person-versus-non-person facet targeting overview
  (Wright-map-style mean/SD comparison)

- `step_overview`: threshold/step diagnostics by PCM/GPCM `StepFacet`
  ladder, or for the common RSM ladder

- `slope_overview`: discrimination summary for `GPCM` fits

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

- model fit overview (N, LogLik, AIC/BIC, convergence)

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

- `overview`: convergence and information criteria.

- `readiness`: separate Numerical, Data, Design, Stability, Diagnostics,
  and Reporting states. `InferenceReady` contributes only to Numerical;
  a numerical pass cannot override a disconnected-design or boundary-
  separation hold.

- `data_review`: overall multi-facet connectivity, facet-level score
  support, boundary-constant levels, single-level facets, and retained
  preparation notes behind the readiness rows.

- `facet_overview`: per-facet spread and range of estimates.

- `person_overview`: distribution of person measures.

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
  "Model", "Method", "Converged", "InferenceReady",
  "ConvergenceSeverity"
)]
#> # A tibble: 1 × 5
#>   Model Method Converged InferenceReady ConvergenceSeverity
#>   <chr> <chr>  <lgl>     <lgl>          <chr>              
#> 1 RSM   MML    TRUE      TRUE           pass               
s$readiness
#>        Domain                                        Status
#> 1   Numerical                                          pass
#> 2        Data                                          pass
#> 3      Design                                   pass_linked
#> 4   Stability                                          pass
#> 5 Diagnostics                                  not_assessed
#> 6   Reporting ready_for_diagnostics_and_reporting_follow_up
#>                                                                                                                              Detail
#> 1                                                                                            Optimizer returned convergence code 0.
#> 2                                                                                No preparation warning or review row was retained.
#> 3 The observed graph satisfies the connectivity requirement; review the remaining design and identification assumptions separately.
#> 4                                                                         No boundary-constant non-person facet level was detected.
#> 5                                                             Diagnostics have not yet been incorporated into this fit-only status.
#> 6                                                             Reporting status is the strictest applicable upstream workflow state.
# `InferenceReady = TRUE` clears only the numerical gate. Also require the
# Data, Design, and Stability rows to support the intended interpretation.
# If Numerical is not a pass, inspect the retained polish stages; increasing
# `maxit` alone may not resolve the review.
s$person_overview
#> # A tibble: 1 × 8
#>   Persons   Mean    SD Median   Min   Max  Span MeanPosteriorSD
#>     <int>  <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>           <dbl>
#> 1      48 -0.141 0.811 -0.107 -1.71  1.45  3.15           0.463
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
