# Evaluate DIF power and bias-screening behavior under known simulated signals

Evaluate DIF power and bias-screening behavior under known simulated
signals

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
  `assignment`). Values may be vectors. The schema-only future branch
  input `design$facets = c(person = ..., judge = ..., task = ...)` is
  also accepted for the currently exposed facet keys. Do not specify the
  same variable through both `design` and the scalar design-grid
  arguments.

- reps:

  Number of replications per design condition.

- group_levels:

  Group labels used for DIF simulation. The first two levels define the
  default reference and focal groups.

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

  True DIF effect size added to the focal group on the target criterion.

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
  cell.

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
  Bounded `GPCM` is supported with caveats as slope-aware
  signal-detection sensitivity evidence.

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

  Optional bounded-`GPCM` slope specification used by direct simulation
  calls when `sim_spec = NULL`.

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
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md)
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

  Optional seed for reproducible replications.

## Value

An object of class `mfrm_signal_detection` with:

- `design_grid`: evaluated design conditions. When `sim_spec` carries
  custom public facet names, matching design-variable alias columns are
  included alongside the canonical internal columns.

- `results`: replicate-level detection results, with the same
  design-variable alias columns when applicable.

- `rep_overview`: run-level status and timing, with the same
  design-variable alias columns when applicable.

- `design_descriptor`: role-based design-variable metadata used by
  planning summaries and plots

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of which design variables
  remain mutable under the current simulation specification

- `planning_schema`: combined planner-schema contract bundling the role
  descriptor, scope boundary, and current mutability map

- `gpcm_boundary`: bounded-`GPCM` caveat row when a `GPCM` screening
  route is used

- `settings`: signal-analysis settings

- `ademp`: simulation-study metadata (aims, DGM, estimands, methods,
  performance measures)

- `notes`: short interpretation notes

## Details

This function performs Monte Carlo design screening for two related
tasks: DIF detection via
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
and interaction-bias screening via
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md).

For each design condition (combination of `n_person`, `n_rater`,
`n_criterion`, `raters_per_person`), the function:

1.  Generates synthetic data with
    [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

2.  Injects one known Group \\\times\\ Criterion DIF effect
    (`dif_effect` logits added to the focal group on the target
    criterion)

3.  Injects one known Rater \\\times\\ Criterion interaction-bias effect
    (`bias_effect` logits)

4.  Fits and diagnoses the MFRM

5.  Runs
    [`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md)
    and
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)

6.  Records whether the injected signals were detected or
    screen-positive

Bounded-`GPCM` runs preserve the current package constraint
`slope_facet == step_facet` within the generator and fitted model. The
resulting DIF and bias rates are slope-aware screening summaries, not
formal inferential power, alpha calibration, operational scoring, or
arbitrary-facet planning evidence.

**Detection criteria**: A DIF signal is counted as "detected" when the
target contrast has \\p \<\\ `dif_p_cut` **and**, when an absolute
contrast cutoff is in force, \\\|\mathrm{Contrast}\| \ge\\
`dif_abs_cut`. For `dif_method = "refit"`, `dif_abs_cut` is interpreted
on the logit scale. For `dif_method = "residual"`, the residual-contrast
screening result is used and the default is to rely on the significance
test alone.

Bias results are different:
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
reports `t` and `Prob.` as screening metrics rather than formal
inferential quantities. Here, a bias cell is counted as
**screen-positive** only when those screening metrics are available and
satisfy

\\p \<\\ `bias_p_cut` **and** \\\|t\| \ge\\ `bias_abs_t`.

**Power** is the proportion of replications in which the target signal
was correctly detected. For DIF this is a conventional power summary.
For bias, the primary summary is `BiasScreenRate`, a screening hit rate
rather than formal inferential power.

**False-positive rate** is the proportion of non-target cells that were
incorrectly flagged. For DIF this is interpreted in the usual testing
sense. For bias, `BiasScreenFalsePositiveRate` is a screening rate and
should not be read as a calibrated inferential alpha level.

**Default effect sizes**: `dif_effect = 0.6` logits corresponds to a
moderate criterion-linked differential-functioning effect;
`bias_effect = -0.8` logits represents a substantial rater-criterion
interaction. Adjust these to match the smallest effect size of practical
concern for your application.

This is again a **parametric simulation study**. The function does not
estimate a new design directly from one observed dataset. Instead, it
evaluates detection or screening behavior under user-specified design
conditions and known injected signals.

If you want to approximate a real study, choose the design grid and
simulation settings so that they reflect the empirical context of
interest. For example, you may set `n_person`, `n_rater`, `n_criterion`,
`raters_per_person`, and the latent-spread arguments to values motivated
by an existing assessment program, then study how operating
characteristics change as those design settings vary.

When `sim_spec` is supplied, the function uses it as the explicit
data-generating mechanism for the latent spreads, thresholds, and
assignment archetype, while still injecting the requested target DIF and
bias effects for each design condition.

If that specification also stores a latent-regression population
generator, each replication carries simulated one-row-per-person
background data into the MML fit. This remains a screening-oriented
Monte Carlo study; it is not a person-level posterior prediction for one
observed sample.

## References

The simulation logic follows the general Monte Carlo /
operating-characteristic framework described by Morris, White, and
Crowther (2019) and the ADEMP-oriented planning/reporting guidance
summarized for psychology by Siepe et al. (2024). In `mfrmr`,
`evaluate_mfrm_signal_detection()` is a many-facet screening helper
specialized to DIF and interaction-bias use cases; it is not a direct
implementation of one published many-facet Rasch simulation design.

- Morris, T. P., White, I. R., & Crowther, M. J. (2019). *Using
  simulation studies to evaluate statistical methods*. Statistics in
  Medicine, 38(11), 2074-2102.

- Siepe, B. S., Bartos, F., Morris, T. P., Boulesteix, A.-L., Heck, D.
  W., & Pawel, S. (2024). *Simulation studies for methodological
  research in psychology: A standardized template for planning,
  preregistration, and reporting*. Psychological Methods.

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`analyze_dff()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`analyze_dif()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_dff.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)

## Examples

``` r
if (FALSE) { # \dontrun{
sig_eval <- suppressWarnings(evaluate_mfrm_signal_detection(
  design = list(person = 8, rater = 2, criterion = 2, assignment = 1),
  reps = 1,
  maxit = 30,
  bias_max_iter = 1,
  seed = 123
))
s_sig <- summary(sig_eval)
s_sig$overview
} # }
```
