# Summarize an `mfrm_fit` object in a user-friendly format

Summarize an `mfrm_fit` object in a user-friendly format

## Usage

``` r
# S3 method for class 'mfrm_fit'
summary(object, digits = 3, top_n = 5, ...)
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

  Reserved for generic compatibility.

## Value

An object of class `summary.mfrm_fit` with:

- `overview`: global model/fit indicators

- `status`: concise front-door status block for quick review

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

- `step_overview`: threshold/step diagnostics

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

## Details

This method provides a compact, human-readable summary oriented to
reporting. It returns a structured object and prints:

- model fit overview (N, LogLik, AIC/BIC, convergence)

- estimation settings that affect identification/scoring interpretation

- facet-level estimate distribution (mean/SD/range)

- person measure distribution

- step/threshold checks

- a reporting map showing which companion summaries/tables should be
  used for manuscript-oriented data description, diagnostics, category
  checks, and draft reporting

- high/low person measures and extreme facet levels

## Interpreting output

- `overview`: convergence and information criteria.

- `facet_overview`: per-facet spread and range of estimates.

- `person_overview`: distribution of person measures.

- `step_overview`: threshold spread and monotonicity checks.

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

- `top_person` / `top_facet`: extreme estimates for quick triage.

## Typical workflow

1.  Fit model with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

2.  Run `summary(fit)` for first-pass diagnostics.

3.  For `RSM` / `PCM`, continue with
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
toy <- load_mfrmr_data("example_core")
fit <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", quad_points = 5
)
s <- summary(fit)
s$overview[, c("Model", "Method", "Converged")]
#> # A tibble: 1 × 3
#>   Model Method Converged
#>   <chr> <chr>  <lgl>    
#> 1 RSM   MML    TRUE     
# Look for: Converged = TRUE. If FALSE the fit is not safe to report;
#   raise `maxit`, relax `reltol`, or rerun with `quad_points = 31`.
s$person_overview
#> # A tibble: 1 × 8
#>   Persons   Mean    SD   Median   Min   Max  Span MeanPosteriorSD
#>     <int>  <dbl> <dbl>    <dbl> <dbl> <dbl> <dbl>           <dbl>
#> 1      48 0.0214  1.04 0.000215 -1.56  2.52  4.08           0.257
# Look for: Mean ~ 0 (logits) and SD ~ 1 are typical when the sample
#   is centred on the test difficulty. Min < -3 or Max > 3 with
#   `Extreme = "min"/"max"` rows indicates ceiling / floor cases.
s$targeting
#> # A tibble: 2 × 7
#>   Facet     PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>   <dbl>       <dbl>
#> 1 Criterion     0.0214         0    0.0214     1.04   0.290        3.59
#> 2 Rater         0.0214         0    0.0214     1.04   0.316        3.30
# Look for: |Targeting| < ~0.5 logits across non-person facets is
#   comfortable. Larger absolute values mean the test is systematically
#   easier or harder than the person sample. SpreadRatio > 2 means
#   persons dominate facet variability; < 0.5 means facets dominate.
```
