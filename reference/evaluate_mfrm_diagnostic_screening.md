# Evaluate legacy and strict marginal diagnostic screening under controlled misfit scenarios

Evaluate legacy and strict marginal diagnostic screening under
controlled misfit scenarios

## Usage

``` r
evaluate_mfrm_diagnostic_screening(
  n_person = c(30, 50, 100),
  n_rater = c(4),
  n_criterion = c(4),
  raters_per_person = n_rater,
  design = NULL,
  reps = 10,
  scenarios = c("well_specified", "local_dependence"),
  local_dependence_sd = 0.8,
  local_dependence_facet = NULL,
  score_levels = 4,
  theta_sd = 1,
  rater_sd = 0.35,
  criterion_sd = 0.25,
  noise_sd = 0,
  step_span = 1.4,
  model = c("RSM", "PCM", "GPCM"),
  step_facet = NULL,
  slope_facet = NULL,
  slopes = NULL,
  maxit = 25,
  quad_points = 7,
  residual_pca = c("none", "overall", "facet", "both"),
  sim_spec = NULL,
  include_report = FALSE,
  report_include = c("fit", "diagnostics", "tables", "precision", "reporting"),
  report_style = c("qc", "apa", "validation", "reviewer", "technical"),
  seed = NULL
)
```

## Arguments

- n_person:

  Vector of person counts to evaluate.

- n_rater:

  Vector of rater counts to evaluate.

- n_criterion:

  Vector of criterion counts to evaluate.

- raters_per_person:

  Vector of rater assignments per person.

- design:

  Optional named design-grid override supplied as a named list, named
  vector, or one-row data frame. Names may use canonical variables
  (`n_person`, `n_rater`, `n_criterion`, `raters_per_person`), current
  public aliases implied by `sim_spec`, or role keywords (`person`,
  `rater`, `criterion`, `assignment`). Values may be vectors.

- reps:

  Number of replications per design condition and scenario.

- scenarios:

  Screening scenarios to evaluate. The current first release supports
  `"well_specified"`, `"local_dependence"`, and
  `"latent_misspecification"`, plus `"step_structure_misspecification"`.

- local_dependence_sd:

  Standard deviation of the shared context effect injected in the
  `"local_dependence"` scenario.

- local_dependence_facet:

  Facet that receives the shared `Person x facet` dependence effect. Use
  `"criterion"`, `"rater"`, or an active public facet name. Defaults to
  the criterion-like facet.

- score_levels:

  Number of ordered score categories.

- theta_sd:

  Standard deviation of simulated person measures.

- rater_sd:

  Standard deviation of simulated rater severities.

- criterion_sd:

  Standard deviation of simulated criterion difficulties.

- noise_sd:

  Optional observation-level noise added to the linear predictor.

- step_span:

  Spread of step thresholds on the logit scale.

- model:

  Measurement model passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  Bounded `GPCM` is supported with caveats as slope-aware screening
  sensitivity evidence.

- step_facet:

  Step facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  when `model = "PCM"` or `model = "GPCM"`.

- slope_facet:

  Slope facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  when `model = "GPCM"`. Defaults to the fitted step facet.

- slopes:

  Optional bounded-`GPCM` slope specification used by direct simulation
  calls when `sim_spec = NULL`.

- maxit:

  Maximum iterations passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- quad_points:

  Quadrature points for the internal `MML` fit.

- residual_pca:

  Residual PCA mode passed to
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- sim_spec:

  Optional output from
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  or
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
  used as the base data-generating mechanism.

- include_report:

  Logical; if `TRUE`, each successful replicate also builds
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  and
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  and records the `report_index` readiness/signaling surface. This is
  intentionally opt-in because it repeats the comprehensive
  result-building workflow.

- report_include:

  `include` vector passed to
  [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
  when `include_report = TRUE`.

- report_style:

  Report style passed to
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  when `include_report = TRUE`.

- seed:

  Optional seed for reproducible replications.

## Value

An object of class `mfrm_diagnostic_screening` with:

- `design_grid`: evaluated design conditions, including public alias
  columns when applicable

- `results`: replicate-level screening metrics for each design and
  scenario

- `scenario_summary`: aggregated scenario-by-design screening summaries

- `performance_summary`: scenario-by-design screening-performance
  summary including runtime, agreement, Type I proxy, and sensitivity
  proxy columns

- `report_signal_summary`: optional scenario-by-design summary of
  [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
  `report_index` availability, readiness, and review-signal counts when
  `include_report = TRUE`

- `scenario_contrast`: each misspecification scenario minus the
  well-specified baseline when the baseline scenario was evaluated

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: combined planner-schema contract

- `gpcm_boundary`: bounded-`GPCM` caveat row when present

- `settings`: simulation and fitting settings

- `ademp`: simulation-study metadata

- `notes`: short interpretation notes

## Details

This helper performs a compact Monte Carlo validation study for the
package's current diagnostic architecture.

For each design condition and scenario, the function:

1.  generates synthetic data with
    [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

2.  fits the model with `method = "MML"`

3.  computes diagnostics with `diagnostic_mode = "both"`

4.  stores legacy residual-screen metrics and strict marginal-fit
    metrics

5.  optionally stores
    [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
    `report_index` readiness signals

6.  aggregates the results into `scenario_summary`,
    `performance_summary`, `report_signal_summary`, and
    `scenario_contrast`

The `"well_specified"` scenario uses the ordinary generator with no
injected extra structure. The `"local_dependence"` scenario adds a
shared `Person x facet` random effect, centered within the selected
facet levels, so responses in the same context become correlated without
changing the facet-level mean effect contract. The
`"latent_misspecification"` scenario keeps the same marginal spread
targets but replaces the normal person distribution with a centered
bimodal empirical support distribution, while leaving the non-person
facets on the original scale contract. The
`"step_structure_misspecification"` scenario uses a `PCM` or
bounded-`GPCM` generator with facet-specific threshold tables that
intentionally mismatch the fitted step contract: `RSM` fits receive
criterion-specific thresholds, and `PCM` / `GPCM` fits receive threshold
structures indexed by the opposite non-person facet. For bounded `GPCM`,
the generator and fit each keep `slope_facet == step_facet`; the
misspecification is the generator-versus-fit step/slope facet mismatch.

This function is intentionally screening-oriented. The strict marginal
branch remains exploratory in the current release, so the returned
summaries should be used to compare relative sensitivity across
scenarios rather than to claim calibrated inferential power.
Bounded-`GPCM` rows add explicit `gpcm_boundary` caveats and should be
read as slope-aware operating characteristics under the evaluated
role-based design.

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

## Examples

``` r
if (FALSE) { # \dontrun{
diag_eval <- evaluate_mfrm_diagnostic_screening(
  design = list(person = 10, rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  seed = 123
)
diag_eval$scenario_summary
diag_eval$scenario_contrast
} # }
```
