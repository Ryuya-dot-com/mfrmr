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
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("study1")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 30
)
qc <- run_qc_pipeline(fit)
qc
summary(qc)
qc$verdicts
} # }
```
