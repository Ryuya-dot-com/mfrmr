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
  bias_results = NULL,
  separation_facets = NULL
)

# S3 method for class 'mfrm_qc_pipeline'
plot(x, type = c("traffic_light", "detail"), draw = TRUE, ...)
```

## Arguments

- fit:

  Native output from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/fit_mfrm.md).
  Imported measurement tables do not contain the response-level
  information required by this pipeline.

- diagnostics:

  Output from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md).
  Computed automatically if NULL.

- threshold_profile:

  Threshold preset: `"strict"`, `"standard"` (default), or `"lenient"`.

- thresholds:

  Named list to override individual thresholds.

- rater_facet:

  Character name of the rater facet for inter-rater check (detected from
  rater-like facet names if NULL; otherwise supply it explicitly).

- include_bias:

  If `TRUE` and bias available in diagnostics, check DIF/bias.

- bias_results:

  Optional pre-computed bias results from
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md).

- separation_facets:

  Character names of non-Person facets whose levels you intend to
  distinguish. Reliability/separation thresholds apply only to these
  facets. With the default `NULL`, these two checks are not requested;
  they do not affect the overall verdict. For example, use `"Criterion"`
  only when distinguishing criterion difficulties is a substantive goal.

- x:

  Output from `run_qc_pipeline()`.

- type:

  Plot type: `"traffic_light"` (default) or `"detail"`.

- draw:

  If `FALSE`, return plot data invisibly without drawing.

- ...:

  Additional plotting arguments for the selected view.

## Value

Object of class `mfrm_qc_pipeline` with verdicts, overall status,
details, and recommendations.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object carrying the QC verdicts in
`plot_data(p, "verdicts")`.

## Details

The pipeline evaluates 10 quality checks and assigns a verdict (Pass /
Warn / Fail / Skip) to each. The overall status is the most severe
verdict among checks marked `AffectsOverall`. Unrequested
differentiation and bias checks, and inapplicable rater-agreement
checks, are excluded. Missing information for an applicable check cannot
produce Pass. Diagnostics are computed automatically via
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md)
if not supplied.

All thresholds are screening rules, not universal statistical acceptance
criteria. High rater separation indicates distinguishable rater
measures, not high agreement; low separation may reflect similar rater
severity. Select `separation_facets` only when differentiation is the
intended target. A Pass does not establish model validity, adequate SEs,
or anchor invariance.

Reliability and separation are used here as QC signals. In `mfrmr`,
`Reliability` / `Separation` are model-based facet indices and
`RealReliability` / `RealSeparation` use fit-inflated SEs. They are
smaller or equal on the same levels; they are not statistical confidence
bounds. For `MML`, these rely on model-based `ModelSE` values for
non-person facets; for `JML`, they remain exploratory approximations.
Reliability and separation come from the same variance decomposition;
they are not independent evidence.

Category counts are sums of observation weights when weights are used.
Threshold ordering compares adjacent numbered steps within each
threshold family; missing steps or families require review. Equal
estimates are nondecreasing within numerical tolerance. A binary scale
has no adjacent threshold comparison, so its category screen evaluates
counts only. These checks do not establish category adequacy or justify
automatic merging.

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
named list using entries such as `global_fit_warn` or
`reliability_pass`).

For `GPCM`, this pipeline is available as caveated operational triage
over supported diagnostics. Its pass/warn/fail labels remain package QC
policy overlays; they are not FACETS score-side equivalence, operational
scoring decisions, design-forecasting evidence, or automatic fairness /
validity decisions.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot a
saved QC pipeline

Display the checks already returned by `run_qc_pipeline()`. Use the
colored verdicts for triage, then read the returned detail for the
reason and next review.

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Two plot
types are provided for visual triage of QC results:

- **`"traffic_light"`** (default): A horizontal bar chart with one row
  per QC check. Bars are coloured green (Pass), amber (Warn), or red
  (Fail). Provides an at-a-glance summary of the current QC review
  state.

- **`"detail"`**: A panel showing the saved `Detail` text beside each
  verdict. Read this explanation and the returned table to understand
  why a check was flagged or unavailable.

## QC checks

The 10 checks are:

1.  **Convergence**: Did the model converge?

2.  **Global fit**: Infit/Outfit MnSq within the current review band.

3.  **Reliability**: Minimum index across explicitly selected
    differentiation facets.

4.  **Separation**: Minimum index across those same selected facets.

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

- `$verdicts$Detail`: human-readable explanation of each assessment.

- `$verdicts$AffectsOverall`: whether a check contributes to the overall
  result.

- `$details`: named list of per-check numeric details for programmatic
  access.

- `$recommendations`: character vector of actionable suggestions for
  checks that need review; suggestions do not prescribe deleting raters
  or collapsing categories automatically.

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

7.  Visualize with plot(x).

## Saved-result reuse

Supplied screening results must describe this fitted analysis. Results
from another fit or older results without identity metadata are refused.
See
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_compatibility_layer.md)
to recreate them from the saved fit and matching diagnostics without
refitting the model.

## Interpretation

The rows are the actual checks returned by `run_qc_pipeline()`:
convergence, global fit, selected-facet reliability and separation,
element misfit, unexpected responses, category structure, connectivity,
inter-rater agreement, and the functioning/bias screen. Element misfit
uses the configured mean-square band; it is not a ZSTD test. PCA and
displacement are separate diagnostics and are not checks in this
pipeline.

Green (Pass), amber (Warn), and red (Fail) describe the selected
screening rules. Grey (Skip) marks unrequested or unavailable checks;
`AffectsOverall` in the returned data distinguishes their contribution
to the overall result. A missing result is not evidence of acceptable
fit. High rater separation is not high agreement, and no colour
establishes statistical validity or justifies deleting raters or
collapsing categories without further review.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/estimate_bias.md),
[`mfrm_threshold_profiles()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrm_threshold_profiles.md),
plot(x), [plot(x, type =
"qc")](https://ryuya-dot-com.github.io/mfrmr/dev/reference/plot.mfrm_fit.md),
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/dev/reference/build_visual_summaries.md)

`run_qc_pipeline()`,
[mfrmr_plot_migration](https://ryuya-dot-com.github.io/mfrmr/dev/reference/mfrmr_plot_migration.md)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("run_qc_pipeline", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
toy <- load_mfrmr_data("study1")
fit <- fit_mfrm(toy, "Person", c("Rater", "Criterion"), "Score",
  method = "JML", maxit = 300
)
qc <- run_qc_pipeline(fit)
qc
summary(qc)
qc$verdicts
} # }
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_qc_pipeline", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
ratings <- load_mfrmr_data("study1")
# These observed data trigger a category-support warning: the QC plot
# displays that review requirement; convergence does not remove it.
fit <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
                method = "JML", maxit = 300)
qc <- run_qc_pipeline(fit)
qc_plot <- plot(qc, draw = FALSE)
head(plot_data(qc_plot, "verdicts"))
} # }
```
