# Run automated quality control pipeline

Integrates convergence, model fit, reliability, separation, element
misfit, unexpected responses, category structure, connectivity,
inter-rater agreement, and DIF/bias into a single pass/warn/fail report.

## Usage

``` r
run_qc_pipeline(
  fit,
  diagnostics = NULL,
  threshold_profile = "standard",
  thresholds = NULL,
  rater_facet = NULL,
  include_bias = TRUE,
  bias_results = NULL
)
```

## Arguments

- fit:

  Output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).
  Computed automatically if NULL.

- threshold_profile:

  Threshold preset: `"strict"`, `"standard"` (default), or `"lenient"`.

- thresholds:

  Named list to override individual thresholds.

- rater_facet:

  Character name of the rater facet for inter-rater check (auto-detected
  if NULL).

- include_bias:

  If `TRUE` and bias available in diagnostics, check DIF/bias.

- bias_results:

  Optional pre-computed bias results from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

## Value

Object of class `mfrm_qc_pipeline` with verdicts, overall status,
details, and recommendations.

## Details

The pipeline evaluates 10 quality checks and assigns a verdict (Pass /
Warn / Fail) to each. The overall status is the most severe verdict
across all checks. Diagnostics are computed automatically via
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
if not supplied.

Reliability and separation are used here as QC signals. In `mfrmr`,
`Reliability` / `Separation` are model-based facet indices and
`RealReliability` / `RealSeparation` provide more conservative lower
bounds. For `MML`, these rely on model-based `ModelSE` values for
non-person facets; for `JML`, they remain exploratory approximations.

Three threshold presets are available via `threshold_profile`:

|                   |        |          |         |
|-------------------|--------|----------|---------|
| Aspect            | strict | standard | lenient |
| Global fit warn   | 1.3    | 1.5      | 1.7     |
| Global fit fail   | 1.5    | 2.0      | 2.5     |
| Reliability pass  | 0.90   | 0.80     | 0.70    |
| Separation pass   | 3.0    | 2.0      | 1.5     |
| Misfit warn (pct) | 3      | 5        | 10      |
| Unexpected fail   | 3      | 5        | 10      |
| Min cat count     | 15     | 10       | 5       |
| Agreement pass    | 60     | 50       | 40      |
| Bias fail (pct)   | 5      | 10       | 15      |

Individual thresholds can be overridden via the `thresholds` argument (a
named list keyed by the internal threshold names shown above).

For bounded `GPCM`, this pipeline is available as caveated operational
triage over supported diagnostics. Its pass/warn/fail labels remain
package QC policy overlays; they are not FACETS score-side equivalence,
operational scoring decisions, design-forecasting evidence, or automatic
fairness / validity decisions.

## QC checks

The 10 checks are:

1.  **Convergence**: Did the model converge?

2.  **Global fit**: Infit/Outfit MnSq within the current review band.

3.  **Reliability**: Minimum non-person facet model reliability index.

4.  **Separation**: Minimum non-person facet model separation index.

5.  **Element misfit**: Percentage of elements with Infit/Outfit outside
    the current review band.

6.  **Unexpected responses**: Percentage of observations with large
    standardized residuals.

7.  **Category structure**: Minimum category count and threshold
    ordering.

8.  **Connectivity**: All observations in a single connected subset.

9.  **Inter-rater agreement**: Exact agreement percentage for the rater
    facet (if applicable).

10. **Functioning/Bias screen**: Percentage of interaction cells that
    cross the screening threshold (if interaction results are
    available).

## Interpreting output

- `$overall`: character string `"Pass"`, `"Warn"`, or `"Fail"`.

- `$verdicts`: tibble with columns `Check`, `Verdict`, `Value`, and
  `Threshold` for each of the 10 checks.

- `$details`: character vector of human-readable detail strings.

- `$raw_details`: named list of per-check numeric details for
  programmatic access.

- `$recommendations`: character vector of actionable suggestions for
  checks that did not pass.

- `$config`: records the threshold profile and effective thresholds.

## Typical workflow

1.  Fit a model: `fit <- fit_mfrm(...)`.

2.  Optionally compute diagnostics and bias:
    `diag <- diagnose_mfrm(fit)`;
    `bias <- estimate_bias(fit, diag, ...)`.

3.  Run the pipeline:
    `qc <- run_qc_pipeline(fit, diag, bias_results = bias)`.

4.  Check `qc$overall` for the headline verdict.

5.  Review `qc$verdicts` for per-check details.

6.  Follow `qc$recommendations` for remediation.

7.  Visualize with
    [`plot_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_pipeline.md).

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_threshold_profiles.md),
[`plot_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_pipeline.md),
[`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)

## Examples

``` r
# \donttest{
toy <- load_mfrmr_data("study1")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
qc <- run_qc_pipeline(fit)
qc
#> --- QC Pipeline ---
#> Overall: Fail 
#> 
#>   [FAIL] Convergence               Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance.
#>   [PASS] Global Fit                Global Infit=0.999, Outfit=0.990
#>   [PASS] Reliability               Min non-person model reliability = 0.955
#>   [PASS] Separation                Min non-person model separation = 4.592
#>   [FAIL] Element Misfit            143 of 328 elements misfitting (43.6%)
#>   [FAIL] Unexpected Responses      5.4% unexpected responses
#>   [PASS] Category Structure        Thresholds ordered, min category count = 215
#>   [PASS] Connectivity              1 disjoint subset(s)
#>   [WARN] Inter-rater Agreement     Exact agreement = 36.2%
#>   [FAIL] Functioning/Bias Screen   80.0% of screened interactions crossed |screening t| > 2
#> 
#> Recommendations:
#>   - The fit reached its iteration ceiling and is not inference-ready. Do not interpret or select its estimates; refit the same specification with the next ceiling in a prespecified `maxit` sequence and accept it only after the numerical gate passes. 
#>   - Excessive element misfit detected. Review individual element fit statistics. 
#>   - High unexpected response rate. Inspect unexpected_response_table() for patterns. 
#>   - Many interaction cells were screen-positive. Review estimate_bias() or analyze_dff() before making substantive bias claims. 
summary(qc)
#> --- QC Pipeline Summary ---
#> Overall: Fail 
#> Pass: 5 | Warn: 1 | Fail: 4 | Skip: 0
#> 
#>                    Check Verdict                         Value
#>              Convergence    Fail Nonzero code; review required
#>               Global Fit    Pass       Infit=1.00, Outfit=0.99
#>              Reliability    Pass                          0.95
#>               Separation    Pass                          4.59
#>           Element Misfit    Fail               143/328 (43.6%)
#>     Unexpected Responses    Fail                          5.4%
#>       Category Structure    Pass     Ordered=Yes, MinCount=215
#>             Connectivity    Pass                             1
#>    Inter-rater Agreement    Warn                         36.2%
#>  Functioning/Bias Screen    Fail                         80.0%
#>                    Threshold
#>  Convergence severity = pass
#>                 [0.50, 1.50]
#>       Pass>=0.80, Warn>=0.50
#>       Pass>=2.00, Warn>=1.00
#>           Pass<=5%, Fail>15%
#>            Pass<=2%, Fail>5%
#>          Ordered + count>=10
#>      Pass=1, Warn=2, Fail>=3
#>         Pass>=50%, Warn>=30%
#>           Pass<=0%, Fail>10%
#>                                                                                                              Detail
#>  Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance.
#>                                                                                    Global Infit=0.999, Outfit=0.990
#>                                                                            Min non-person model reliability = 0.955
#>                                                                             Min non-person model separation = 4.592
#>                                                                              143 of 328 elements misfitting (43.6%)
#>                                                                                           5.4% unexpected responses
#>                                                                        Thresholds ordered, min category count = 215
#>                                                                                                1 disjoint subset(s)
#>                                                                                             Exact agreement = 36.2%
#>                                                            80.0% of screened interactions crossed |screening t| > 2
#> 
#> Recommendations:
#>   - The fit reached its iteration ceiling and is not inference-ready. Do not interpret or select its estimates; refit the same specification with the next ceiling in a prespecified `maxit` sequence and accept it only after the numerical gate passes. 
#>   - Excessive element misfit detected. Review individual element fit statistics. 
#>   - High unexpected response rate. Inspect unexpected_response_table() for patterns. 
#>   - Many interaction cells were screen-positive. Review estimate_bias() or analyze_dff() before making substantive bias claims. 
qc$verdicts
#> # A tibble: 10 × 5
#>    Check                   Verdict Value                        Threshold Detail
#>    <chr>                   <chr>   <chr>                        <chr>     <chr> 
#>  1 Convergence             Fail    Nonzero code; review requir… Converge… Optim…
#>  2 Global Fit              Pass    Infit=1.00, Outfit=0.99      [0.50, 1… Globa…
#>  3 Reliability             Pass    0.95                         Pass>=0.… Min n…
#>  4 Separation              Pass    4.59                         Pass>=2.… Min n…
#>  5 Element Misfit          Fail    143/328 (43.6%)              Pass<=5%… 143 o…
#>  6 Unexpected Responses    Fail    5.4%                         Pass<=2%… 5.4% …
#>  7 Category Structure      Pass    Ordered=Yes, MinCount=215    Ordered … Thres…
#>  8 Connectivity            Pass    1                            Pass=1, … 1 dis…
#>  9 Inter-rater Agreement   Warn    36.2%                        Pass>=50… Exact…
#> 10 Functioning/Bias Screen Fail    80.0%                        Pass<=0%… 80.0%…
# }
```
