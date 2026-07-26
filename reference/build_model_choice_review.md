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
  for AIC/BIC/log-likelihood comparison;

- model-role guidance for `RSM`, `PCM`, and bounded `GPCM`;

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

The word "bounded" is intentional: the package implements a bounded GPCM
route, not every possible generalized partial-credit many-facet
extension. The current route uses positive slopes, requires
`slope_facet == step_facet`, identifies slopes on the log scale with
geometric mean 1, and keeps several downstream score-side/reporting
helpers outside the documented boundary.

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
                    method = "MML", model = "RSM", quad_points = 7)
fit_pcm <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
                    method = "MML", model = "PCM", step_facet = "Criterion",
                    quad_points = 7)
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
#>  Label Model Method nobs WeightedN ICSampleSize ICSampleSizeBasis npar   LogLik
#>    RSM   RSM    MML  768       768          768         row_count    8 -903.080
#>    PCM   PCM    MML  768       768          768         row_count   14 -896.262
#>       AIC      BIC Converged InferenceReady ConvergenceSeverity ICComparable
#>  1822.161 1859.311      TRUE           TRUE                pass         TRUE
#>  1820.524 1885.537      TRUE           TRUE                pass         TRUE
#>  Delta_AIC AkaikeWeight Delta_BIC BICWeight
#>      1.637        0.306     0.000         1
#>      0.000        0.694    26.225         0
#> 
#> Model Roles
#>  Label Model           RecommendedRole
#>    RSM   RSM equal_weighting_reference
#>    PCM   PCM equal_weighting_reference
#>                                                                        ScoreContract
#>                         Common threshold structure; equal discrimination fixed at 1.
#>  Step thresholds vary by the designated step facet; equal discrimination fixed at 1.
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
