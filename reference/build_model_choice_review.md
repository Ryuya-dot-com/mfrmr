# Build a model-choice review across RSM, PCM, and bounded GPCM fits

Build a model-choice review across RSM, PCM, and bounded GPCM fits

## Usage

``` r
build_model_choice_review(
  ...,
  labels = NULL,
  run_weighting_review = NULL,
  theta_range = c(-6, 6),
  theta_points = 61L,
  top_n = 10L,
  warn_constraints = TRUE
)
```

## Arguments

- ...:

  Two or more fitted `mfrm_fit` objects from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- labels:

  Optional labels for the supplied fits. If omitted, names from `...`
  are used when available; otherwise labels are generated from
  model/method combinations.

- run_weighting_review:

  Logical. If `TRUE` and the supplied fits include at least one
  `RSM`/`PCM` reference plus one bounded `GPCM` fit, also run
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  for the first such pair.

- theta_range, theta_points, top_n:

  Passed to
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  when `run_weighting_review = TRUE`.

- warn_constraints:

  Passed to
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

## Value

An object of class `mfrm_model_choice_review`.

## Details

`build_model_choice_review()` is a user-facing synthesis helper. It does
not estimate new models. It bundles:

- [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  for verified AIC/Person-BIC/SABIC/log-likelihood comparison;

- comparison-boundary warnings captured from
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  and retained in `comparison_warnings` for printing and appendix
  export;

- model-role guidance for `RSM`, `PCM`, and bounded `GPCM`;

- reported step/slope coordinate counts, identified free-parameter
  counts, and the stored fit-readiness decision for every supplied
  model;

- downstream-route availability for APA output, score-side export,
  linking, recovery, fair averages, bias screening, and summary-appendix
  handoff;

- report wording templates that avoid treating better bounded-`GPCM` fit
  as an automatic operational-scoring decision;

- [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  when bounded `GPCM` is present;

- optionally,
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  for the first Rasch-family reference versus bounded-`GPCM` pair.

The word "bounded" describes the documented model and workflow scope:
the package does not implement every possible generalized partial-credit
many-facet extension. It does **not** mean that finite optimizer box
bounds define the estimator. The current route uses positive slopes,
requires `slope_facet == step_facet`, identifies slopes on the log scale
with geometric mean 1, and keeps several downstream score-side/reporting
helpers outside the documented boundary. Model-choice ranking also
requires the current selectable IC contract: q\<31 fits retain raw
criteria but produce a screening/review-only bundle.

## See also

[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md),
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md),
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("example_core")
fit_rsm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                    method = "MML", model = "RSM", quad_points = 31)
fit_pcm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                    method = "MML", model = "PCM", step_facet = "Criterion",
                    quad_points = 31)
review <- build_model_choice_review(RSM = fit_rsm, PCM = fit_pcm)
summary(review)
#> mfrm Model Choice Review
#> 
#> Overview
#>  FitCount   Models HasBoundedGPCM OperationalReference SensitivityModel
#>         2 RSM, PCM          FALSE                  RSM             <NA>
#>  ICComparable                     ReviewStatus
#>          TRUE rasch_family_model_choice_review
#> 
#> Next Actions
#>  - Read comparison_table for fit evidence, but decide operational use from the
#>    score interpretation.
#>  - Use downstream_routes before calling APA, score-side export, linking,
#>    recovery, fair-average, or bias-screening helpers.
#>  - Use report_templates when drafting methods text so the fitted model and
#>    score contract are described accurately.
#> 
#> Comparison Table
#>  Label Model Method Persons Npar   LogLik      AIC      BIC    SABIC Delta_AIC
#>    RSM   RSM    MML      48    8 -900.013 1816.025 1830.995 1805.897     1.527
#>    PCM   PCM    MML      48   14 -893.249 1814.498 1840.695 1796.774     0.000
#>  Delta_BIC Delta_SABIC ICStatus ICIntegrationTier ICSelectable ICComparable
#>        0.0       9.123       ok    standard_start         TRUE         TRUE
#>        9.7       0.000       ok    standard_start         TRUE         TRUE
#>  SABICComparable InferenceReady
#>             TRUE           TRUE
#>             TRUE           TRUE
#>   Full IC audit fields remain available in `$comparison_table`.
#> 
#> Model Contracts and Readiness
#> 
#> Step parameters (reported values versus independent parameters)
#>  Label Model          StepStructure Reported Free
#>    RSM   RSM          shared ladder        3    2
#>    PCM   PCM facet-specific ladders       12    8
#> 
#> Slope parameters (reported values versus independent parameters)
#>  Label Model SlopeStructure Reported Free
#>    RSM   RSM     fixed at 1        0    0
#>    PCM   PCM     fixed at 1        0    0
#> 
#> Fit readiness
#>  Label Model FitReadiness FormalInference
#>    RSM   RSM        ready              No
#>    PCM   PCM        ready              No
#>                                      Interpretation
#>  Fit gates passed; formal precision review required
#>  Fit gates passed; formal precision review required
#>   Full score contracts and readiness reasons remain in `$model_roles`.
#> 
#> Downstream Routes
#>  Label Model FullAPARoute ScoreSideExport LinkingSynthesis RecoveryChecks
#>    RSM   RSM    supported       supported        supported      supported
#>    PCM   PCM    supported       supported        supported      supported
#>  FairAverage BiasScreening SummaryAppendix
#>    supported     supported       supported
#>    supported     supported       supported
#> 
#> Weighting Review Status
#>  Requested Available
#>      FALSE     FALSE
#>                                                                                           Message
#>  Not requested; set `run_weighting_review = TRUE` for the first RSM/PCM versus bounded GPCM pair.
#> 
#> Notes
#>  - This review is a decision aid; it does not refit models or choose an
#>    operational model automatically.
#>  - Observation weights and GPCM discrimination-based reweighting are separate
#>    concepts.
#>  - Use bounded GPCM wording only for the current constrained implementation,
#>    not for an unrestricted GPCM family claim.
# }
```
