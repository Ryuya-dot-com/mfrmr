# Evaluate MFRM design conditions by repeated simulation

Evaluate MFRM design conditions by repeated simulation

## Usage

``` r
evaluate_mfrm_design(
  n_person = c(30, 50, 100),
  n_rater = c(3, 5),
  n_criterion = c(3, 5),
  raters_per_person = n_rater,
  design = NULL,
  reps = 10,
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
  assignment = NULL,
  sparse_controls = NULL,
  maxit = 25,
  quad_points = 7,
  residual_pca = c("none", "overall", "facet", "both"),
  sim_spec = NULL,
  seed = NULL,
  progress = interactive(),
  parallel = c("no", "future")
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
  `RSM` and `PCM` use the validated Rasch-family design-planning layer.
  Bounded `GPCM` is available as a caveated simulation/refit
  operating-characteristic route.

- step_facet:

  Step facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  when `model = "PCM"` or `model = "GPCM"`. When left `NULL`, the
  function inherits the generator step facet from `sim_spec` when
  available and otherwise defaults to `"Criterion"`.

- slope_facet:

  Slope facet passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
  when `model = "GPCM"`. The current bounded branch requires
  `slope_facet == step_facet`.

- slopes:

  Optional bounded-`GPCM` generator slopes used when `sim_spec = NULL`.
  See
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  for accepted formats.

- assignment:

  Optional assignment design used when `sim_spec = NULL`.
  `"sparse_linked"` activates planned-missing sparse rating designs; use
  `sparse_controls` to specify the linking set.

- sparse_controls:

  Optional named list used when `assignment = "sparse_linked"` and
  `sim_spec = NULL`, or retained from a sparse linked `sim_spec`. See
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md).

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
  `raters_per_person`, but latent-spread assumptions, thresholds, and
  other generator settings come from `sim_spec`. If `sim_spec` contains
  step-facet-specific thresholds, the design grid may not vary the
  number of levels for that step facet away from the specification. If
  `sim_spec` stores an active latent-regression population generator,
  this helper currently requires `fit_method = "MML"` so each
  replication can refit the population model.

- seed:

  Optional seed for reproducible replications.

- progress:

  Logical. Whether to show a progress bar across design-by-replication
  cells. Defaults to
  [`interactive()`](https://rdrr.io/r/base/interactive.html), so
  interactive exploratory runs show progress while non-interactive
  tests, scripts, and report rendering stay quiet. Set `TRUE` or `FALSE`
  explicitly to override.

- parallel:

  Parallelisation strategy for the rep loop within each design row.
  `"no"` (default) runs serially; `"future"` uses
  [`future.apply::future_lapply`](https://future.apply.futureverse.org/reference/future_lapply.html)
  and respects whatever
  [`future::plan()`](https://future.futureverse.org/reference/plan.html)
  is currently active. The Suggests package `future.apply` must be
  installed for the parallel path to activate; otherwise the call falls
  back to serial execution with a single message. Cross-design-row
  parallelism is planned for a future release.

## Value

An object of class `mfrm_design_evaluation` with components:

- `design_grid`: evaluated design conditions. When `sim_spec` carries
  custom public facet names, matching design-variable alias columns are
  included alongside the canonical internal columns.

- `results`: facet-level replicate results, with the same
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

- `gpcm_boundary`: bounded-`GPCM` caveat row when a `GPCM` design route
  is used

- `notes`: short interpretation notes

- `settings`: simulation settings

- `ademp`: simulation-study metadata (aims, DGM, estimands, methods,
  performance measures)

## Details

This helper runs a compact Monte Carlo design study for common
rater-by-item many-facet settings.

For each design condition, the function:

1.  generates synthetic data with
    [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)

2.  fits the requested MFRM with
    [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

3.  computes diagnostics with
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)

4.  stores recovery and precision summaries by facet

The result is intended for planning questions such as:

- how many raters are needed for stable rater separation?

- how does `raters_per_person` affect severity recovery?

- when do category counts become too sparse for comfortable
  interpretation?

This is a **parametric simulation study**. It does not take one observed
design (for example, 4 raters x 30 persons x 3 criteria) and
analytically extrapolate what would happen under a different design (for
example, 2 raters x 40 persons x 5 criteria). Instead, you specify a
design grid and data-generating assumptions (latent spread, facet
spread, thresholds, noise, and scoring structure), and the function
repeatedly generates synthetic data under those assumptions.

When you want the simulated conditions to resemble an existing study,
use substantive knowledge or estimates from that study to choose
`theta_sd`, `rater_sd`, `criterion_sd`, `score_levels`, and related
settings before running the design evaluation.

When `sim_spec` is supplied, the function uses it as the explicit
data-generating mechanism. This is the recommended route when you want a
design study to stay close to a previously fitted run while still
varying the candidate sample sizes or rater-assignment counts.

Sparse linked simulation specifications and direct
`assignment = "sparse_linked"` calls are carried into the
design-evaluation output. The resulting sparse-design columns report
planned-missingness and rater-link diagnostics (for example design
density and rater-pair common persons). They are design diagnostics, not
fit statistics or universal adequacy thresholds.

If that specification also stores a latent-regression population
generator, each replication carries forward the simulated
one-row-per-person background data and refits the MML population-model
branch. This remains a scenario study under explicit assumptions; it is
not a closed-form predictive distribution for one future administration.

Bounded `GPCM` design evaluation is available with caveats. It
repeatedly generates data from the supplied or fit-derived slope-aware
specification, refits bounded `GPCM`, and summarizes facet-level
operating characteristics. The route remains a role-based person x
rater-like x criterion-like planner: it does not validate
diagnostic-screening or signal-detection rules, does not provide a fully
arbitrary-facet planner, and does not replace
[`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
for slope-recovery adequacy review.

Recovery metrics are reported only when the generator and fitted model
target the same facet-parameter contract. In practice this means the
same `model`, and for `PCM`, the same `step_facet`. When these do not
align, recovery fields are set to `NA` and the output records the
reason. Even when these contract checks pass, the recovery summaries
still assume compatible orientation and anchoring conventions across the
generator and fitted model.

## Reported metrics

Facet-level simulation results include:

- `Separation` (\\G = \mathrm{SD\_{adj}} / \mathrm{RMSE}\\): how many
  statistically distinct strata the facet resolves.

- `Reliability` (\\G^2 / (1 + G^2)\\): analogous to Cronbach's
  \\\alpha\\ for the reproducibility of element ordering.

- `Strata` (\\(4G + 1) / 3\\): number of distinguishable groups.

- Mean `Infit` and `Outfit`: average fit mean-squares across elements.

- `MisfitRate`: share of elements with \\\|\mathrm{ZSTD}\| \> 2\\.

- Sparse-design diagnostics when `assignment = "sparse_linked"`:
  `MeanDesignDensity`, `MeanPlannedMissingRate`, `MeanLinkPersons`,
  `MeanMinCommonPersonsPerRaterPair`, `MaxZeroCommonRaterPairs`, and
  `MaxRaterPairsBelowTarget`.

- `SeverityRMSE`: root-mean-square error of recovered parameters vs the
  known truth **after facet-wise mean alignment**, so that the usual
  Rasch/MFRM location indeterminacy does not inflate recovery error.
  This quantity is reported only when the generator and fitted model
  target the same facet-parameter contract.

- `SeverityBias`: mean signed recovery error after the same alignment;
  values near zero are expected. This is likewise omitted when the
  generator/fitted-model contract does not align.

## Interpreting output

Start with `summary(x)$design_summary`, then plot one focal metric at a
time (for example rater `Separation` or criterion `SeverityRMSE`).

Higher separation/reliability is generally better, whereas lower
`SeverityRMSE`, `MeanMisfitRate`, and `MeanElapsedSec` are preferable.

When choosing among designs, look for the point where increasing
`n_person` or `raters_per_person` yields diminishing returns in
separation and RMSE—this identifies the cost-effective design frontier.
`ConvergedRuns / reps` should be near 1.0; low convergence rates
indicate the design is too small for the chosen estimation method.

This is a Monte Carlo design-evaluation helper. It can visualize how
separation, reliability, strata, RMSE, and fit-screen rates change when
you vary person, rater, criterion, or assignment counts. For analytic
generalizability-theory planning, pair observed variance-component
review from
[`mfrm_generalizability()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_generalizability.md)
with D-study projections from
[`mfrm_d_study()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_d_study.md).
Read `IdentificationStatus`, `GStatus`, and `PhiStatus` before using the
projected coefficients: boundary or singular mixed-model fits are
design-identification warnings rather than high-stakes-ready reliability
evidence.

## References

The simulation logic follows the general Monte Carlo /
operating-characteristic framework described by Morris, White, and
Crowther (2019) and the ADEMP-oriented planning/reporting guidance
summarized for psychology by Siepe et al. (2024). In `mfrmr`,
`evaluate_mfrm_design()` is a practical many-facet design-planning
wrapper rather than a direct reproduction of one published simulation
study.

- Morris, T. P., White, I. R., & Crowther, M. J. (2019). *Using
  simulation studies to evaluate statistical methods*. Statistics in
  Medicine, 38(11), 2074-2102.

- Siepe, B. S., Bartos, F., Morris, T. P., Boulesteix, A.-L., Heck, D.
  W., & Pawel, S. (2024). *Simulation studies for methodological
  research in psychology: A standardized template for planning,
  preregistration, and reporting*. Psychological Methods.

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[summary.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_design_evaluation.md),
[plot.mfrm_design_evaluation](https://ryuya-dot-com.github.io/mfrmr/reference/plot.mfrm_design_evaluation.md)

## Examples

``` r
if (FALSE) { # \dontrun{
sim_eval <- suppressWarnings(evaluate_mfrm_design(
  design = list(person = c(8, 12), rater = 2, criterion = 2, assignment = 1),
  reps = 1,
  maxit = 30,
  seed = 123
))
s_eval <- summary(sim_eval)
s_eval$design_summary[, c("Facet", "n_person", "MeanSeparation", "MeanSeverityRMSE")]
p_eval <- plot(sim_eval, facet = "Rater", metric = "separation", x_var = "n_person", draw = FALSE)
names(p_eval)
} # }
```
