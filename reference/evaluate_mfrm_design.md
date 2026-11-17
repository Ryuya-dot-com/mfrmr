# Evaluate MFRM design conditions by repeated simulation

Evaluate MFRM design conditions by repeated simulation

Summarize a design-simulation study

Plot a design-simulation study

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
  parallel = c("no", "future"),
  file = NULL,
  file_refit = c("never", "on_change", "always")
)

# S3 method for class 'mfrm_design_evaluation'
summary(object, digits = 3, ...)

# S3 method for class 'mfrm_design_evaluation'
plot(
  x,
  facet = c("Rater", "Criterion", "Person"),
  metric = c("separation", "reliability", "infit", "outfit", "misfitrate",
    "severityrmse", "severitybias", "convergencerate", "elapsedsec", "mincategorycount",
    "designdensity", "plannedmissingrate", "linkpersons", "linkfraction", "linkraters",
    "mincommonpersons", "zerocommonpairs", "pairsshorttarget"),
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
  `RSM` and `PCM` use the documented Rasch-family design-planning layer.
  `GPCM` is available as a caveated simulation/refit
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

  Optional `GPCM` generator slopes used when `sim_spec = NULL`. See
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
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
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
  back to serial execution with a single message. A fixed explicit
  `seed` preallocates the same per-cell simulation seeds before either
  route, so serial and future execution receive identical stochastic
  inputs for the same ordered design grid. Parallel dispatch applies to
  replications within each design row; actual worker concurrency depends
  on the active future plan.

- file:

  Optional RDS path for saving and reusing the simulation. A missing
  `.rds` extension is appended. Its parent directory must already exist.
  `NULL` (default) performs no file reads or writes.

- file_refit:

  File reuse policy. `"never"` (default) loads a matching completed
  result or resumes matching saved trials; incompatible files produce an
  error. `"on_change"` restarts when inputs or implementation/
  environment differ. `"always"` replaces the file with a new run.
  Unlike `brms::brm(file_refit = "never")`, this function checks
  compatibility even under `"never"`; it does not silently return a
  different analysis.

- object:

  Output from `evaluate_mfrm_design()`.

- digits:

  Number of digits used when printing the summary. Returned numeric
  tables retain full precision for plotting and design decisions.

- ...:

  Reserved for generic compatibility.

- x:

  Output from `evaluate_mfrm_design()`.

- facet:

  Facet to visualize.

- metric:

  Metric to plot.

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

  If `TRUE`, draw with base graphics; otherwise return plotting data.

## Value

An object of class `mfrm_design_evaluation` with components:

- `design_grid`: evaluated design conditions. When `sim_spec` carries
  custom public facet names, matching design-variable alias columns are
  included alongside the standard result columns.

- `results`: facet-level replicate results, with the same
  design-variable alias columns when applicable.

- `rep_overview`: run-level status and timing, with the same
  design-variable alias columns when applicable. `Observations` counts
  generated rating rows; `MaxRatingsPerRater` is the largest row count
  for a single rater-like facet level. One row is one
  person-rater-criterion rating, regardless of `Weight`. These workload
  counts are retained even when fitting or diagnostics fail.
  `RaterComponents` and `CriterionComponents` count connected components
  in each generated Person-facet assignment graph, using the same audit
  as
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).
  They refer to the rater-like and criterion-like roles even when custom
  facet names are used, and also survive failures. Failed fits retain
  the condition class, failure component, and category-support
  state/reason codes when available; a completely failed design still
  returns the documented zero-row `results` schema rather than a
  zero-column table.

- `design_descriptor`: role-based design-variable metadata used by
  planning summaries and plots

- `planning_scope`: explicit record of the current planning contract

- `planning_constraints`: explicit record of which design variables
  remain mutable under the current simulation specification

- `planning_schema`: structured planning metadata bundling the role
  descriptor, scope boundary, and current mutability map

- `gpcm_boundary`: `GPCM` caveat row when a `GPCM` design route is used

- `notes`: short interpretation notes

- `settings`: simulation settings

- `ademp`: simulation-study metadata (aims, DGM, estimands, methods,
  performance measures)

- `reproducibility`: file identity, original inputs and per-trial seeds
  when `file` is supplied.

An object of class `summary.mfrm_design_evaluation` with components:

- `overview`: run-level overview

- `design_summary`: aggregated design-by-facet metrics, with
  design-variable alias columns when applicable

- `sparse_review`: compact planned-missingness and rater-link review
  counts when sparse linked designs are active

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
  simulation performance

- `notes`: short interpretation notes

Invisibly, a `ggplot` object whose reusable payload (accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md))
includes resolved canonical variables (`x_var`, `group_var`) together
with public labels (`x_label`, `group_label`),
`design_variable_aliases`, and `design_descriptor`, plus
`planning_scope`, `planning_constraints`, and `planning_schema`.

## Details

Evaluates candidate person-by-rater-by-criterion designs by repeated
generation
([`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)),
fitting
([`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)),
and diagnostics
([`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)).
Serial runs checkpoint per trial and `"future"` runs per design row (see
[`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)).
Set `fit_method`, `model`, `step_facet`, `maxit`, and `quad_points`
explicitly rather than treating the fast exploratory defaults (`JML`,
`maxit = 25`, `quad_points = 7`) as operational accuracy settings.

Reports facet `Separation` (\\G = \mathrm{SD\_{adj}} / \mathrm{RMSE}\\),
`Reliability` (\\G^2 / (1 + G^2)\\, distinguishing facet levels rather
than rater agreement), `Strata` (\\(4G + 1) / 3\\), mean
`Infit`/`Outfit`, `MisfitRate` (\\\|\mathrm{ZSTD}\| \> 2\\),
sparse-design overlap summaries, and mean-aligned `SeverityRMSE` /
`SeverityBias` when generator and fitted models match (`NA` with reason
otherwise; legacy unverified step-truth files report
`RecoveryBasis = "legacy_step_location_truth_unverified"`).

The summary emphasizes condition-level averages that are useful for
practical design planning, especially:

- convergence rate

- separation and reliability by facet

- severity recovery RMSE

- mean misfit rate

`Reps`, `ConvergenceRate`, and `McseConvergenceRate` use all recorded
replications for each design, including fit and diagnostic failures.
Only a recorded `Converged = TRUE` counts as converged. `AvailableReps`
counts the replications with returned results for that facet;
performance means still use the available metric values. Designs with no
returned facet results have no performance-summary rows and cannot be
recommended. To update an older saved summary, call
[`summary()`](https://rdrr.io/r/base/summary.html) again on the original
evaluation object; no simulation or refitting is needed. Rebuilding also
restores full precision when an older summary stored rounded metrics. It
also withholds legacy PCM/GPCM recovery metrics whose step-location
truth coordinates were not verified; those require a new evaluation for
corrected recovery, while other diagnostic metrics remain.
`RecoveryAvailableReps` reports the number of finite trial RMSEs.
Mean-aligned bias is zero by construction; see `evaluate_mfrm_design()`
for the comparison target.

`MaxRatings` and `MaxRatingsPerRater` are the largest total rating count
and individual rater workload across all recorded replications,
including failed runs. A rating is one generated person-rater-criterion
row; weights do not multiply workload. A maximum is `NA` when any
replication lacks that count, including older evaluations without
per-rater workload records.

`MaxRaterComponents` and `MaxCriterionComponents` give the largest
Person-facet component count across all recorded assignments; a missing
count makes its maximum `NA`. `DisconnectedReps` counts replications
with a recorded disconnection in either graph. Zero known disconnections
does not establish connectedness when records are missing. Sparse-design
summaries also use all run records, including failures.

This method is designed for quick design-planning scans rather than
polished publication graphics.

Useful first plots are:

- rater `metric = "separation"` against `x_var = "n_person"`

- criterion `metric = "severityrmse"` against `x_var = "n_person"` when
  you want aligned recovery error rather than raw location shifts

- rater `metric = "convergencerate"` against
  `x_var = "raters_per_person"`

- sparse linked `metric = "plannedmissingrate"`, `"mincommonpersons"`,
  `"zerocommonpairs"`, or `"pairsshorttarget"` to review planned
  missingness and rater-pair linkage separately from recovery metrics

## References

Morris, White, and Crowther (2019) and Siepe et al. (2024) provide the
Monte Carlo/ADEMP planning and reporting framework. This helper is a
many-facet application, not a reproduction of one published simulation
design.

- Morris, T. P., White, I. R., & Crowther, M. J. (2019). *Using
  simulation studies to evaluate statistical methods*. Statistics in
  Medicine, 38(11), 2074-2102.

- Siepe, B. S., Bartos, F., Morris, T. P., Boulesteix, A.-L., Heck, D.
  W., & Pawel, S. (2024). *Simulation studies for methodological
  research in psychology: A standardized template for planning,
  preregistration, and reporting*. Psychological Methods.

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
summary.mfrm_design_evaluation, plot.mfrm_design_evaluation

`evaluate_mfrm_design()`, plot.mfrm_design_evaluation

`evaluate_mfrm_design()`, summary.mfrm_design_evaluation

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("evaluate_mfrm_design", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
sim_eval <- suppressWarnings(evaluate_mfrm_design(
  design = list(person = c(8, 12), rater = 2, criterion = 2, assignment = 2),
  reps = 1,
  maxit = 30,
  seed = 123
))
s_eval <- summary(sim_eval)
s_eval$design_summary[, c("Facet", "n_person", "MeanSeparation", "MeanSeverityRMSE")]
p_eval <- plot(sim_eval, facet = "Rater", metric = "separation", x_var = "n_person", draw = FALSE)
names(p_eval)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("summary.mfrm_design_evaluation", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-design.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sim_eval <- saved$result
s <- summary(sim_eval)
s$overview
head(s$design_summary)
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_design_evaluation", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-design.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
sim_eval <- saved$result
p <- plot(sim_eval, facet = "Rater", metric = "separation", x_var = "n_person", draw = FALSE)
pd <- plot_data(p)
c(pd$facet, pd$x_var)
} # }
```
