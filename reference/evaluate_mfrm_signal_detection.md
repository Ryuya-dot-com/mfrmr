# Evaluate differential-functioning contrasts and bias screens in simulations

Evaluate differential-functioning contrasts and bias screens in
simulations

Summarize a DIF/bias screening simulation

## Usage

``` r
evaluate_mfrm_signal_detection(
  n_person = c(30, 50, 100),
  n_rater = c(4),
  n_criterion = c(4),
  raters_per_person = n_rater,
  design = NULL,
  reps = 10,
  group_levels = c("A", "B"),
  reference_group = NULL,
  focal_group = NULL,
  dif_level = NULL,
  dif_effect = 0.6,
  bias_rater = NULL,
  bias_criterion = NULL,
  bias_effect = -0.8,
  score_levels = 4,
  theta_sd = 1,
  rater_sd = 0.35,
  criterion_sd = 0.25,
  noise_sd = 0,
  step_span = 1.4,
  fit_method = c("JML", "MML"),
  model = c("RSM", "PCM", "GPCM"),
  step_facet = NULL,
  slope_facet = NULL,
  slopes = NULL,
  maxit = 25,
  quad_points = 7,
  residual_pca = c("none", "overall", "facet", "both"),
  sim_spec = NULL,
  dif_method = c("residual", "refit"),
  dif_min_obs = 10,
  dif_p_adjust = "holm",
  dif_p_cut = 0.05,
  dif_abs_cut = 0.43,
  bias_max_iter = 2,
  bias_p_cut = 0.05,
  bias_abs_t = 2,
  seed = NULL
)

# S3 method for class 'mfrm_signal_detection'
summary(object, digits = 3, ...)

# S3 method for class 'mfrm_signal_detection'
plot(
  x,
  signal = c("dif", "bias"),
  metric = c("power", "false_positive", "estimate", "screen_rate",
    "screen_false_positive"),
  x_var = c("n_person", "n_rater", "n_criterion", "raters_per_person"),
  group_var = NULL,
  draw = TRUE,
  ...
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
  public aliases implied by `sim_spec` (for example `n_judge`, `n_task`,
  `judge_per_person`), or role keywords (`person`, `rater`, `criterion`,
  `assignment`). Values may be vectors. The nested named-facet form
  `design$facets = c(person = ..., judge = ..., task = ...)` is also
  accepted for the supported person/rater/criterion design. Do not
  specify the same variable through both `design` and the scalar
  design-grid arguments.

- reps:

  Number of replications per design condition.

- group_levels:

  Group labels used for DIF simulation. The first two levels define the
  default reference and focal groups. If omitted, inherits the groups
  stored in `sim_spec`, when present.

- reference_group:

  Optional reference group label used when extracting the target DIF
  contrast.

- focal_group:

  Optional focal group label used when extracting the target DIF
  contrast.

- dif_level:

  Target criterion level for the true DIF effect. Can be an integer
  index or a criterion label such as `"C04"`. Defaults to the last
  criterion level in each design.

- dif_effect:

  True DIF effect size added to the focal group on the target
  criterion's linear predictor. For GPCM, discrimination multiplies this
  shift in the adjacent-category log odds.

- bias_rater:

  Target rater level for the true interaction-bias effect. Can be an
  integer index or a label such as `"R04"`. Defaults to the last rater
  level in each design.

- bias_criterion:

  Target criterion level for the true interaction-bias effect. Can be an
  integer index or a criterion label. Defaults to the last criterion
  level in each design.

- bias_effect:

  True interaction-bias effect added to the target `Rater x Criterion`
  cell's linear predictor, with the same GPCM scaling.

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

- fit_method:

  Estimation method passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- model:

  Measurement model passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).
  `GPCM` is supported with caveats as slope-aware signal-detection
  sensitivity evidence.

- step_facet:

  Step facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  when `model = "PCM"` or `model = "GPCM"`. When left `NULL`, the
  function inherits the generator step facet from `sim_spec` when
  available and otherwise defaults to `"Criterion"`.

- slope_facet:

  Slope facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  when `model = "GPCM"`. Defaults to the fitted step facet.

- slopes:

  Optional `GPCM` slope specification used by direct simulation calls
  when `sim_spec = NULL`.

- maxit:

  Maximum iterations passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- quad_points:

  Quadrature points for `fit_method = "MML"`.

- residual_pca:

  Residual PCA mode passed to
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md).

- sim_spec:

  Optional output from
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  or
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  used as the base data-generating mechanism. When supplied, the design
  grid still varies `n_person`, `n_rater`, `n_criterion`, and
  `raters_per_person`, but latent spread, thresholds, and other
  generator settings come from `sim_spec`. The target DIF and
  interaction-bias signals specified in this function override any
  signal tables stored in `sim_spec`. If `sim_spec` stores an active
  latent-regression population generator, this helper currently requires
  `fit_method = "MML"` so each replication can refit the population
  model.

- dif_method:

  Differential-functioning method passed to
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

- dif_min_obs:

  Minimum observations per group cell for
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).

- dif_p_adjust:

  P-value adjustment method passed to
  [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md).
  Target and non-target screens use the returned adjusted tail areas; an
  unavailable adjusted value never falls back to an unadjusted one.

- dif_p_cut:

  P-value cutoff for counting a target DIF detection.

- dif_abs_cut:

  Optional absolute contrast cutoff used when counting a target DIF
  detection. When omitted, the effective default is `0.43` for
  `dif_method = "refit"` and `0` (no additional magnitude cutoff) for
  `dif_method = "residual"`.

- bias_max_iter:

  Maximum iterations passed to
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

- bias_p_cut:

  P-value cutoff for counting a target bias screen-positive result.

- bias_abs_t:

  Absolute t cutoff for counting a target bias screen-positive result.

- seed:

  Optional seed for reproducible replications. Trial seeds are allocated
  before execution and cover generation, fitting and diagnostics. A
  supplied seed preserves the caller's RNG state.

- object:

  Output from `evaluate_mfrm_signal_detection()`.

- digits:

  Number of digits used when printing numeric summaries.

- ...:

  Reserved for generic compatibility.

- x:

  Output from `evaluate_mfrm_signal_detection()`.

- signal:

  Whether to plot DIF or bias screening results.

- metric:

  Metric to plot. For `signal = "bias"`, prefer `metric = "screen_rate"`
  for the screening hit rate. The older `metric = "power"` spelling is
  retained as a backwards-compatible alias that maps to
  `BiasScreenRate`. `"estimate"` plots the signed reference-minus-focal
  DIF contrast or the additive bias shift. A refit contrast requires
  common-scale linking.

- x_var:

  Design variable used on the x-axis. When `x` was generated from a
  `sim_spec` with custom public facet names, the corresponding aliases
  (for example `n_judge`, `n_task`, `judge_per_person`) are also
  accepted. Role keywords (`person`, `rater`, `criterion`, `assignment`)
  are accepted as an abstraction over the current two-facet schema.

- group_var:

  Optional design variable used for separate lines. The same alias rules
  as `x_var` apply.

- draw:

  If `TRUE`, print the `ggplot` object; otherwise return the `ggplot`
  object invisibly without drawing.

## Value

An object of class `mfrm_signal_detection` with:

- `design_grid`: evaluated design conditions. When `sim_spec` carries
  custom public facet names, matching design-variable alias columns are
  included alongside the standard result columns.

- `results`: replicate-level detection results, with the same
  design-variable alias columns when applicable. `Seed` identifies the
  trial; `DIFReferenceGroup`, `DIFFocalGroup`, `DIFContrastDirection`
  and `DIFContrastScale` identify its contrast. `DIFScreenReason` and
  `BiasScreenReason` retain target-level unavailability explanations.

- `rep_overview`: run-level status and timing, with the same
  design-variable alias columns when applicable, including failed
  attempts and their stage.

- `design_descriptor`: role-based design-variable metadata used by
  planning summaries and plots

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of which design variables
  remain mutable under the current simulation specification

- `planning_schema`: structured planning metadata bundling the role
  descriptor, scope boundary, and current mutability map

- `gpcm_boundary`: `GPCM` caveat row when a `GPCM` screening route is
  used

- `settings`: signal-analysis settings

- `ademp`: simulation-study metadata (aims, DGM, estimands, methods,
  performance measures)

- `notes`: short interpretation notes

An object of class `summary.mfrm_signal_detection` with:

- `overview`: run-level overview

- `detection_summary`: full-precision rates by design, with
  design-variable aliases when applicable. `DIF*`, `DIFClass*` and
  `BiasScreen*` columns retain `Planned`, `Available`, `Unavailable`,
  `Positive`, `MCLower`, `MCUpper`, `AllTrialsLower` and
  `AllTrialsUpper` for target outcomes. Monte Carlo bounds are exact 95%
  binomial intervals conditional on availability; all-trial bounds
  describe unresolved outcomes, not confidence intervals.
  `DIFNonTarget*`/`BiasNonTarget*` retain summed `Planned` and
  `Available` cell counts and `AvailableReps`, the number of trials
  contributing a non-target proportion. Those proportions receive equal
  weight across contributing trials, even with unequal cell counts;
  their MCSE is the sample SD of the proportions divided by the square
  root of `AvailableReps`. `TargetContrastAvailable`,
  `TargetContrastAbsAvailable`, `TargetBiasAvailable` and
  `TargetBiasTAvailable` are denominators for the corresponding finite
  point summaries. All-missing means return `NA`.

- `ademp`: simulation-study metadata carried forward from the original
  object

- `facet_names`: public facet labels carried from the simulation
  specification

- `design_variable_aliases`: accepted public aliases for design
  variables

- `design_descriptor`: role-based design-variable metadata

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of mutable/locked design
  variables

- `planning_schema`: structured planning metadata

- `structural_design_review`: deterministic structural review of the
  named-facet design grid; it reports design bookkeeping rather than
  signal-detection performance

- `gpcm_boundary`: `GPCM` caveat row when present

- `notes`: short interpretation notes, including the bias-side screening
  caveat

For [`plot()`](https://rdrr.io/r/graphics/plot.default.html): Invisibly,
a `ggplot` object whose reusable payload (accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md))
includes resolved canonical variables (`x_var`, `group_var`) together
with public labels (`x_label`, `group_label`),
`design_variable_aliases`, `design_descriptor`, `planning_scope`,
`planning_constraints`, `planning_schema`, `display_metric`, and
`interpretation_note` so callers can label bias-side plots as screening
summaries rather than formal power/error-rate displays. `summary_table`
retains per-design means and availability denominators; `notes` retains
interpretation and legacy-result restrictions. If additional design
variables are collapsed, each plotted point is an equally weighted
average of available design-level means, not a pooled trial/cell rate.

## Details

Injects Group \\\times\\ Criterion `dif_effect` and Rater \\\times\\
Criterion `bias_effect` shifts (multiplied by slope in `GPCM` with
`slope_facet == step_facet`) and evaluates
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
and
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
across replications. Because current residual and refit
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
routes return descriptive contrasts (`DIFContrast` as reference minus
focal; `DIFContrastComparable` flags common-scale linking) without
calibrated p-values, DIF detection and false-positive rates remain `NA`.

Bias cells count as screen-positive (`BiasScreenRate`) when both
screening metrics are available and satisfy \\p \le\\ `bias_p_cut` and
\\\|t\| \ge\\ `bias_abs_t` (`NA` when unavailable, never coerced to
`FALSE`). Non-target false-positive averages (`BiasNonTarget*`) and
exact binomial Monte Carlo plus unresolved-outcome bounds describe
simulation replications rather than calibrated familywise alpha; see
[`mfrm_screening_performance()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_screening_performance.md)
for complete-roster per-target and any-target summaries.

[`plot()`](https://rdrr.io/r/graphics/plot.default.html) method: Plot
DIF/bias screening simulation results

## References

See "References" in
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md)
for the Monte Carlo/ADEMP framework (Morris et al., 2019; Siepe et al.,
2024). This helper applies that framework to DIF and interaction-bias
screens; it does not reproduce a published many-facet simulation design.

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)

`evaluate_mfrm_signal_detection()`, plot.mfrm_signal_detection

`evaluate_mfrm_signal_detection()`, summary.mfrm_signal_detection

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("evaluate_mfrm_signal_detection", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
sig_eval <- suppressWarnings(evaluate_mfrm_signal_detection(
  design = list(person = 8, rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  bias_max_iter = 1,
  seed = 123
))
s_sig <- summary(sig_eval)
s_sig$overview
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_signal_detection", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-signal-detection.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sig_eval <- saved$result
summary(sig_eval)
} # }
# Long-running workflow; run explicitly when needed.
# example("plot.mfrm_signal_detection", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-signal-detection.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sig_eval <- saved$result
plot(sig_eval, signal = "dif", metric = "power", x_var = "n_person", draw = FALSE)
} # }
```
