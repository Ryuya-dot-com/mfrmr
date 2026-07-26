# GPCM scope and current limitations

`mfrmr` includes a bounded implementation of the Generalized Partial
Credit Model (GPCM; Muraki 1992). The bounded estimator is available
under the documented constraints, while several downstream reporting
helpers remain restricted because score-side semantics under free
discrimination differ from the Rasch-family case. This vignette
documents which helpers are available, which are not, and what to use as
a substitute when a helper is restricted.

## Before fitting: model-choice triage

Do not choose `GPCM` only because it is the most flexible model in the
menu. Start with the score interpretation.

| Model | Use when | Main risk if over-used |
|----|----|----|
| `RSM` | The rating scale is intended to share one category-threshold structure across the step facet. | Real threshold differences can be hidden in residual diagnostics. |
| `PCM` | Thresholds may differ by item, criterion, task, or another designated step facet, but rating events should still contribute equally after conditioning on the modeled facets. | It can absorb threshold heterogeneity without asking whether some levels are more discriminating. |
| bounded `GPCM` | The analysis explicitly allows discrimination-based reweighting and treats slopes as part of the substantive sensitivity question. | Better statistical fit can be mistaken for a better operational scoring rule. |

This ordering matters for reporting. `RSM` and `PCM` are the package’s
equal-weighting reference route; bounded `GPCM` is a slope-aware
extension. If equal contribution of items, criteria, or raters is part
of the validity argument, a better-fitting bounded `GPCM` should be
reported as sensitivity evidence rather than as an automatic
replacement.

## Report wording templates

Use wording that matches the model actually fitted:

- `RSM`: “We fit a many-facet rating-scale Rasch model, treating
  category thresholds as common across the step facet.”
- `PCM`: “We fit a many-facet partial-credit Rasch model, allowing
  thresholds to vary by the designated step facet while retaining equal
  discrimination.”
- bounded `GPCM`: “We fit a bounded generalized partial-credit
  many-facet model as a slope-aware sensitivity analysis; interpretation
  focused on whether discrimination-based reweighting changed the
  substantive conclusions.”

Avoid wording that says bounded `GPCM` “improves the score” solely
because it improves log-likelihood, `AIC`, or `BIC`. The model can fit
better while changing the scoring contract.

## Checking the support boundary

[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
is the canonical reference. It returns one row per helper family with a
`Status` column drawn from `supported`, `supported_with_caveat`,
`blocked`, and `deferred`. Read `Boundary` for the interpretive limit
and `RecommendedRoute` for the route to use next. The default print is
deliberately compact; subset by status to inspect a focused set of rows.

``` r

library(mfrmr)
gpcm_capability_matrix("supported")[, c("Area", "Status")]
#> mfrmr bounded-GPCM workflow availability
#> 
#>     Status Routes
#>  supported      3
#> 
#> Route preview
#>                                       Area    Status
#>                 Core fitting and summaries supported
#>  Fixed-calibration scoring and information supported
#>              Core curve and category views supported
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
```

``` r

gpcm_capability_matrix("supported_with_caveat")[, c("Area", "Status")]
#> mfrmr bounded-GPCM workflow availability
#> 
#>                 Status Routes
#>  supported_with_caveat     14
#> 
#> Route preview
#>                                                     Area                Status
#>           Exploratory diagnostics and residual follow-up supported_with_caveat
#>               Checklist and summary-table appendix route supported_with_caveat
#>                              Operational misfit casebook supported_with_caveat
#>                 Weighting review and model-choice review supported_with_caveat
#>                            Operational linking synthesis supported_with_caveat
#>           Direct simulation-spec generation and recovery supported_with_caveat
#>                  APA writer and fit-based export bundles supported_with_caveat
#>  Fair-average semantics under bounded GPCM (slope-aware) supported_with_caveat
#> 
#> ... 6 more route(s).
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
```

``` r

gpcm_capability_matrix("blocked")[, c("Area", "Status", "RecommendedRoute")]
#> mfrmr bounded-GPCM workflow availability
#> 
#>   Status Routes
#>  blocked      1
#> 
#> Route preview
#>                                      Area  Status
#>  FACETS output-contract score-side review blocked
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
```

``` r

gpcm_capability_matrix("deferred")[, c("Area", "Status", "Boundary", "RecommendedRoute")]
#> mfrmr bounded-GPCM workflow availability
#> 
#>    Status Routes
#>  deferred      1
#> 
#> Route preview
#>                                         Area   Status
#>  Posterior-predictive and Bayesian workflows deferred
#> 
#> Filter by status, for example gpcm_capability_matrix("supported_with_caveat").
#> Read Boundary and RecommendedRoute before interpreting a caveated or unavailable route.
```

The matrix is intentionally conservative. A row stays in `blocked` or
`deferred` even when some individual computation is already available,
because the scope statement includes the interpretation needed for a
complete public workflow rather than only checking whether code
executes.

## Source-grounded recovery interpretation

The bounded `GPCM` route follows Muraki’s generalized partial credit
model and its information-function extension. The package-specific
`slope_regime` labels are narrower than that model theory: they
summarize the centered log-slope spread of the simulation generator so
recovery evidence can be read against a declared stress condition. They
are not model-fit tests and they are not literature-derived adequacy cut
points.

For simulation reporting, read direct recovery checks in an ADEMP-style
order: the data-generating mechanism first, then the estimands and
performance measures, and only then the row-level recovery diagnostics.
In practice, this means:

1.  Build or extract an explicit `mfrm_sim_spec`.
2.  Run
    [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
    for the direct parameter-recovery question.
3.  Run
    [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
    with practical RMSE/bias limits.
4.  Read `summary(recovery_review)`, then
    `recovery_review$condition_reporting_notes` and
    `recovery_review$condition_review`, then
    `recovery_review$diagnostic_reporting_notes` and
    `recovery_review$diagnostic_review` when optional diagnostics were
    retained, then `plot(recovery_review, type = "status")`, then
    `plot(recovery_review, type = "metrics", metric = "rmse")`.

## Supported routes and verification evidence

The following bounded-`GPCM` routes are documented and verified within
the stated constraints:

- **Fitting and core summaries** via
  `fit_mfrm(model = "GPCM", step_facet = ...)`. The documented default
  keeps `slope_facet == step_facet`, with the direct `MML` engine.
- **Posterior scoring and information** via
  [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md),
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md),
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
  and
  [`plot_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_information.md).
- **Curve and category views** via
  `plot(fit, type = c("wright", "pathway", "ccc", "ccc_surface"))`,
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
  and
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md).
- **Slope-aware simulation specifications** via
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  and
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md).
- **Direct recovery checks** via
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  and
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md),
  including fitted bounded-GPCM slope recovery on the log-slope scale.

## What works with caveats

The following are exposed for `GPCM` but should be read as exploratory
screens rather than as Rasch-style invariance evidence:

- [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  and the residual and unexpected-response stack:
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
  [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
  [`plot_qc_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_qc_dashboard.md),
  [`plot_marginal_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_fit.md),
  [`plot_marginal_pairwise()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_marginal_pairwise.md).
- [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
  and
  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
  route to the supported direct tables and plots. The broader
  APA/QC/export family is available as caveated sensitivity-reporting
  output with explicit `gpcm_boundary` rows.
- [`build_misfit_casebook()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_misfit_casebook.md)
  inherits the exploratory screening framing of its underlying sources.
- [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  now provides bounded-GPCM conditional screening rows with slope-aware
  information and profile-likelihood columns. Treat these rows as
  screening evidence for follow-up, not as standalone confirmatory
  fairness tests.
  [`unexpected_after_bias_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_after_bias_table.md)
  provides a descriptive in-sample before/after flag comparison; a lower
  flag count does not show that bias has been removed.
- [`estimation_iteration_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimation_iteration_report.md)
  provides a slope-aware reconstructed optimization trajectory. It is a
  diagnostic replay, not the exact optimizer history or an additional
  convergence test.
- [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
  [`dif_interaction_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_interaction_table.md),
  [`dif_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/dif_report.md),
  [`plot_dif_heatmap()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_heatmap.md),
  and
  [`plot_dif_summary()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_dif_summary.md)
  provide bounded-GPCM DFF/DIF screening and reporting surfaces with
  explicit `gpcm_boundary` rows.
- [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md),
  [`run_qc_pipeline()`](https://ryuya-dot-com.github.io/mfrmr/reference/run_qc_pipeline.md),
  [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md),
  [`build_mfrm_replay_script()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_replay_script.md),
  [`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md),
  package-native scorefile export, and
  [`build_linking_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_linking_review.md)
  return caveated bounded-`GPCM` reporting or exploratory-review objects
  with explicit `gpcm_boundary` rows. The package-native scorefile can
  include native structural delta-method expected-score SEs and
  score-side delta SEs selected by `score_se_method` when the required
  MML diagnostics are available, but those SEs are not FACETS-equivalent
  score-side uncertainty.
- [`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
  [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md),
  [`evaluate_mfrm_diagnostic_screening()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_diagnostic_screening.md),
  and
  [`evaluate_mfrm_signal_detection()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_signal_detection.md)
  are available as caveated role-based repeated simulation/refit routes.
  Treat their outputs as design-level or screening sensitivity evidence,
  not as operational scoring, calibrated inferential testing, or
  arbitrary-facet planning validation.

The dashboard marks the fair-average panel unavailable under `GPCM`; use
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
directly for the slope-aware element-conditional table and
`fair_average_table(fair_se = TRUE)` when you need structural
fair-average SEs for non-person rows.

## What is intentionally restricted

The slope-aware
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
route and package-native scorefile route are available under `GPCM`,
including native expected-score uncertainty and score-side delta SEs
where the required MML diagnostics support them. Full FACETS-style
score-side compatibility remains restricted because free discrimination
changes the relationship between the latent measure and operational
score-side summaries. Specifically:

- [`facets_output_contract_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_contract_review.md)
  still depends on FACETS-style compatibility semantics that are not
  generalized to free discrimination.
- posterior-predictive checks and MCMC estimation are not available in
  mfrmr; use external Bayesian software when those analyses are
  required.
- Caveated reporting, export, linking, design-forecast, and screening
  helpers must keep their `gpcm_boundary` wording visible and must not
  imply FACETS-equivalent score-side uncertainty, operational scoring,
  calibrated screening gates, or arbitrary-facet planning validation.

## Recommended substitutes

When a restricted helper is needed for a `GPCM` report, the practical
paths are:

- Refit with `model = "PCM"` if the discrimination-free assumption is
  defensible for the data and a full FACETS score-side review is
  required;
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  quantifies the loss in fit.
- Keep the report on the `GPCM` fit itself but draft the manuscript
  section manually around the supported tables: `summary(fit)` for
  parameters,
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  for residual fit,
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md)
  for the per-facet quality summary, and
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
  for precision evidence.
- When a Rasch-family baseline comparison is substantively useful,
  optionally generate a second manifest from a parallel `RSM` or `PCM`
  fit. The two fits can be reported side by side, with the `GPCM` fit
  identified as the discrimination-aware counterpart. This is not
  required to use the caveated bounded-`GPCM` manifest/replay/export
  route.

Restricted helpers use the capability matrix at runtime. An unsupported
bounded-`GPCM` call stops with the relevant limitation and a supported
alternative instead of producing a partial score-side or backend result.
Use
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
or `mfrmr_output_guide("gpcm")` before choosing a downstream route.

## A worked example

The `example_core` dataset includes a small synthetic block that
supports a bounded `GPCM` fit. This example uses compact quadrature and
iteration settings to keep optional local execution short; for final
evidence, rerun with the package default or a higher quadrature setting
and a larger recovery design.

``` r

library(mfrmr)
toy <- load_mfrmr_data("example_core")

fit_gpcm <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  step_facet = "Criterion",
  score = "Score",
  model = "GPCM",
  method = "MML",
  quad_points = 7,
  maxit = 20
)

summary(fit_gpcm)

diag_gpcm <- diagnose_mfrm(fit_gpcm)
summary(diag_gpcm)

info <- compute_information(fit_gpcm)
plot_information(info)

rec_gpcm <- evaluate_mfrm_recovery(
  sim_spec = build_mfrm_sim_spec(
    n_person = 30,
    n_rater = 3,
    n_criterion = 4,
    raters_per_person = 2,
    model = "GPCM",
    step_facet = "Criterion",
    slope_facet = "Criterion",
    slopes = c(0.8, 1.0, 1.15, 1.05)
  ),
  reps = 10,
  model = "GPCM",
  fit_method = "MML",
  quad_points = 7,
  maxit = 20,
  include_diagnostics = TRUE,
  diagnostic_fit_df_method = "both",
  seed = 1
)
review_gpcm <- assess_mfrm_recovery(
  rec_gpcm,
  max_rmse = c(facet = 0.5, step = 0.5, slope = 0.25),
  max_abs_bias = c(default = 0.25)
)

summary(review_gpcm)$overview
summary(review_gpcm)$reading_order
review_gpcm$condition_reporting_notes[, c(
  "ConditionArea", "ReportingAttention", "ConditionFinding"
)]
review_gpcm$condition_review[, c(
  "Model", "GPCMSlopeRegime", "StressLevel", "ScoreSupportStatus"
)]
review_gpcm$diagnostic_reporting_notes[, c(
  "Facet", "ReportingAttention", "DiagnosticFinding"
)]
summary(review_gpcm)$diagnostic_review
plot(review_gpcm, type = "status")
plot(review_gpcm, type = "metrics", metric = "rmse")
```

The fit, summary, residual diagnostics, information, recovery,
fair-average, and conditional bias-screening helpers all run under
`GPCM` with the caveats listed above. `build_apa_outputs(fit_gpcm)`
returns a caveated sensitivity-reporting object with a `gpcm_boundary`;
full FACETS score-side review remains on the `RSM` / `PCM` route.

## Current boundary

Score-side semantics for free-discrimination polytomous models differ
from the Rasch-family route. Use the current matrix returned by
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
as the workflow contract and
[`gpcm_score_side_contract()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_score_side_contract.md)
for score-side alternatives.
