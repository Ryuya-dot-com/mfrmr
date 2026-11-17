# Simulate parameter recovery by repeated generation and refitting

Runs a compact parameter-recovery simulation study: generate data from a
known ordered many-facet data-generating setup, refit the requested
model, align estimates to the known truth where location indeterminacy
requires it, and summarize bias, RMSE, MAE, correlation, and coverage of
available centered structural facet intervals. This function runs the
simulation and fits models. To review an already saved simulation result
without new data generation or fitting, use `assess_mfrm_recovery()`. In
0.2.4 this replaces `evaluate_mfrm_recovery()`; the old name remains an
alias. See the details for corrected recovery targets, Monte Carlo
uncertainty and migration of saved results.

Converts the numerical output from `simulate_mfrm_recovery()` into a
reviewer-facing adequacy checklist. The goal is not to impose one
universal pass/fail rule; it is to make the main user questions
explicit: Did the runs finish? Did the fitted models converge? Are
uncertainty summaries available? Are coverage and Monte Carlo precision
plausible? If practical RMSE or bias limits are supplied, which
parameter groups need follow-up? For `GPCM`, which slope-regime
generator condition frames the recovery evidence? This only reads an
existing simulation result. It does not generate data, refit models, add
replications or repair unavailable uncertainty estimates.

## Usage

``` r
simulate_mfrm_recovery(
  n_person = 50,
  n_rater = 4,
  n_criterion = 4,
  raters_per_person = n_rater,
  design = NULL,
  reps = 10,
  score_levels = 4,
  theta_sd = 1,
  rater_sd = 0.35,
  criterion_sd = 0.25,
  noise_sd = 0,
  step_span = 1.4,
  model = c("RSM", "PCM", "GPCM"),
  step_facet = NULL,
  slope_facet = NULL,
  thresholds = NULL,
  slopes = NULL,
  assignment = NULL,
  sparse_controls = NULL,
  sim_spec = NULL,
  fit_method = c("JML", "MML"),
  maxit = 25,
  quad_points = 7,
  include_person = TRUE,
  include_diagnostics = FALSE,
  diagnostic_fit_df_method = c("both", "engine", "facets"),
  seed = NULL,
  file = NULL,
  file_refit = c("never", "on_change", "always")
)

assess_mfrm_recovery(
  x,
  min_reps = 30,
  min_success_rate = 0.95,
  min_convergence_rate = 0.95,
  min_se_available = 0.8,
  coverage_target = 0.95,
  coverage_tolerance = 0.05,
  max_mcse_rmse_ratio = 0.25,
  max_rmse = NULL,
  max_abs_bias = NULL,
  top_n = 6,
  digits = 3,
  ...
)

# S3 method for class 'mfrm_recovery_assessment'
plot(
  x,
  y = NULL,
  type = c("status", "metrics"),
  metric = c("rmse", "bias", "coverage", "se_available", "mcse_rmse"),
  draw = TRUE,
  ...
)

# S3 method for class 'mfrm_recovery_simulation'
plot(
  x,
  y = NULL,
  type = c("summary", "coverage", "errors", "scatter", "replications"),
  metric = c("rmse", "bias", "mae", "correlation", "coverage", "mcse_bias", "mcse_rmse",
    "raw_rmse", "raw_bias", "mean_se", "se_available"),
  parameter_type = NULL,
  facet = NULL,
  comparison = c("aligned", "unaligned"),
  marginal = c("auto", "histogram", "none"),
  preset = c("standard", "publication", "compact", "monochrome"),
  draw = TRUE,
  ...
)
```

## Arguments

- n_person:

  Number of persons/respondents.

- n_rater:

  Number of rater facet levels.

- n_criterion:

  Number of criterion/item facet levels.

- raters_per_person:

  Number of raters assigned to each person.

- design:

  Optional named design override supplied as a named list, named vector,
  or one-row data frame. When `sim_spec = NULL`, names may use canonical
  variables (`n_person`, `n_rater`, `n_criterion`, `raters_per_person`)
  or role keywords (`person`, `rater`, `criterion`, `assignment`). A
  nested named-facet form,
  `design$facets = c(person = ..., rater = ..., criterion = ...)`, is
  also accepted for the supported person/rater/criterion design. Do not
  specify the same variable through both `design` and the scalar count
  arguments.

- reps:

  Number of Monte Carlo replications.

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

  Measurement model recorded in the simulation setup. The current public
  generator supports `RSM`, `PCM`, and `GPCM`.

- step_facet:

  Step facet used when `model = "PCM"` and threshold values vary across
  levels. Currently `"Criterion"` and `"Rater"` are supported.

- slope_facet:

  Slope facet used when `model = "GPCM"`. The current `GPCM` branch
  requires `slope_facet == step_facet`.

- thresholds:

  Optional threshold specification. Use a numeric vector of common
  thresholds; a named list such as `list(C01 = c(-1, 0, 1))`; a numeric
  matrix with one row per `StepFacet` and one column per step; or a long
  data frame with columns `StepFacet`, `Step`/`StepIndex`, and
  `Estimate`.

- slopes:

  Optional slope specification used when `model = "GPCM"`. Use either a
  numeric vector aligned to the generated slope-facet levels or a data
  frame with columns `SlopeFacet` and `Estimate`. Supplied slopes are
  treated as relative discriminations and normalized to the package's
  geometric-mean-one identification convention on the log scale. When
  omitted, slopes default to 1 for every slope-facet level, giving an
  exact `PCM` reduction.

- assignment:

  Assignment design. `"crossed"` means every person sees every rater;
  `"rotating"` uses a balanced rotating subset; `"resampled"` reuses
  person-level rater-assignment profiles stored in `sim_spec`;
  `"sparse_linked"` uses an incomplete rating design with optional
  linking persons; `"skeleton"` reuses an observed response skeleton
  stored in `sim_spec`, including optional `Group`/`Weight` columns when
  available. When omitted, the function chooses `"crossed"` if
  `raters_per_person == n_rater`, otherwise `"rotating"`.

- sparse_controls:

  Optional named list used when `assignment = "sparse_linked"`.
  Supported entries are `link_fraction`, `link_persons`,
  `link_raters_per_person`, `assignment_mode`, and
  `min_common_persons_per_rater_pair`. See
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  for the same contract.

- sim_spec:

  Optional output from
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
  or
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md).
  When supplied, it defines the generator setup; direct scalar arguments
  are treated as legacy inputs and should generally be left at their
  defaults except for `seed`. Any custom public two-facet names recorded
  in `sim_spec$facet_names` are also carried into the simulated output
  and downstream planning helpers. If `sim_spec` stores an active
  latent-regression population generator, the returned object also
  carries the generated one-row-per-person background-data table needed
  to refit that population model later.

- fit_method:

  `"JML"` or `"MML"`, passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- maxit:

  Maximum optimizer iterations passed to
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md).

- quad_points:

  Quadrature points used when `fit_method = "MML"`.

- include_person:

  Logical. When `TRUE`, include person-measure recovery rows when the
  fitted object exposes person estimates.

- include_diagnostics:

  Logical. When `TRUE`, run
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  after each successful refit and retain facet-level fit/separation
  operating characteristics. These diagnostics are reported separately
  from recovery metrics and are not parameter-recovery criteria by
  themselves.

- diagnostic_fit_df_method:

  Fit-ZSTD degrees-of-freedom convention used for optional diagnostic
  operating-characteristic summaries. Use `"both"` when reviewing
  FACETS-style df sensitivity.

- seed:

  Optional random seed.

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

- x:

  Output from `simulate_mfrm_recovery()`.

- min_reps:

  Minimum replication count expected before treating the simulation for
  inferential use.

- min_success_rate:

  Minimum acceptable proportion of replications that generated data and
  produced a fitted model.

- min_convergence_rate:

  Minimum acceptable proportion of replications whose fitted model
  reported convergence.

- min_se_available:

  Minimum acceptable proportion of all expected targets with matching
  structural standard errors in each parameter group, including targets
  in failed fits. Unknown target counts give `not_available`. Set to
  `NULL` to skip this check.

- coverage_target:

  Nominal coverage target, usually `0.95`.

- coverage_tolerance:

  Absolute tolerance around `coverage_target`.

- max_mcse_rmse_ratio:

  Maximum acceptable Monte Carlo SE of RMSE divided by RMSE. Set to
  `NULL` to skip this precision check.

- max_rmse:

  Optional practical RMSE limit. Use a scalar for all parameter groups
  or a named vector/list with names such as `"facet"`, `"step"`,
  `"slope"`, `"Rater"`, or `"facet:Rater:logit"`.

- max_abs_bias:

  Optional practical absolute-bias limit. Naming follows `max_rmse`.
  Mean-aligned location groups and complete identified log-slope blocks
  have zero average bias by construction and remain `not_assessed`.

- top_n:

  Number of next-action lines retained in the compact output.

- digits:

  Digits used by the print method.

- ...:

  Reserved for generic compatibility.

- y:

  Reserved for S3 generic compatibility.

- type:

  Plot route: `"summary"` draws a metric from
  `summary(x)$recovery_summary`, `"coverage"` draws 95% coverage by
  parameter group, `"errors"` draws row-level recovery-error
  distributions, `"scatter"` draws truth against estimated values, and
  `"replications"` summarizes run status.

- metric:

  Summary metric used when `type = "summary"`. Supported values are
  `"rmse"`, `"bias"`, `"mae"`, `"correlation"`, `"coverage"`,
  `"mcse_bias"`, `"mcse_rmse"`, `"raw_rmse"`, `"raw_bias"`, `"mean_se"`,
  and `"se_available"`.

- draw:

  If `TRUE`, print the `ggplot` object. If `FALSE`, return the `ggplot`
  object invisibly without drawing.

- parameter_type:

  Optional parameter type filter, such as `"person"`, `"facet"`,
  `"step"`, `"slope"`, or `"population"`.

- facet:

  Optional facet filter.

- comparison:

  Error/estimate scale for row-level routes. `"aligned"` uses
  `EstimateAligned` / `ErrorAligned`; `"unaligned"` uses `Estimate` /
  `ErrorRaw` on the same comparison scale.

- marginal:

  Marginal histogram display for `type = "scatter"`: `"auto"` (default;
  shown when at least 8 finite pairs are plotted), `"histogram"`, or
  `"none"`.

- preset:

  Visual preset (`"standard"`, `"publication"`, `"compact"`, or
  `"monochrome"`).

## Value

An object of class `mfrm_recovery_simulation` with components:

- `recovery`: row-level truth/estimate comparisons and interval
  availability by replication.

- `recovery_summary`: parameter-group metrics, trial MCSEs,
  denominators, availability rates and interval reasons.

- `recovery_targets`: target counts by replication and parameter group,
  recorded before fitting.

- `rep_overview`: replication-level convergence, timing, error status,
  and sparse-design diagnostics when applicable.

- `diagnostic_oc`: optional replication-by-facet fit/separation
  operating characteristics when `include_diagnostics = TRUE`.

- `diagnostic_oc_summary`: optional facet-level diagnostic operating-
  characteristic summary.

- `settings`: fitting and simulation settings.

- `ademp`: simulation-study metadata.

- `reproducibility`: file identity, original inputs and per-trial seeds
  when `file` is supplied.

An object of class `mfrm_recovery_assessment` with:

- `overview`: compact run-level status.

- `checklist`: reviewer-facing adequacy checks.

- `condition_review`: generator-condition metadata, including `GPCM`
  slope-regime interpretation and generated score-category support when
  available.

- `condition_reporting_notes`: reporter-facing generator-condition
  caveats separated from parameter-recovery conclusions.

- `diagnostic_reporting_notes`: reporter-facing fit/separation caveats
  retained as diagnostic context rather than recovery criteria.

- `diagnostic_review`: optional fit/separation operating-characteristic
  context when retained by `simulate_mfrm_recovery()`.

- `metric_review`: parameter-group metric checks.

- `uncertainty_review`: coverage / SE availability interpretation with
  expected/available counts, coverage MCSE and unavailable reasons.

- `reading_order`: recommended first-read order for the summary,
  condition, plot, and row-level recovery outputs.

- `next_actions`: short action list sorted by severity.

- `thresholds`: thresholds used for the assessment.

Invisibly, a `ggplot` object carrying reusable plot tables and metadata
accessible via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md).

## Details

**Checkpointing (`file`)**: Reuses or trial-checkpoints runs matching
full generator/fitter inputs, `reps`, seeds, RNG kind, and
package/platform fingerprints via atomic temp-file writes and a `.lock`
directory. Failed fits are saved as completed attempts rather than
redrawn.

**Alignment, MCSE, and intervals**: Location groups (`Person`, facets,
steps) are mean-aligned within each trial (PCM/GPCM step means shift
into owning facet `Truth`, while `RawTruth` keeps raw generator values;
mean `Bias` is zero by construction), and `GPCM` log-slopes use
geometric-mean-one identification. Across \\R\\ trials with trial sums
\\S_r\\, counts \\n_r\\, and pooled mean \\m = \sum_r S_r / \sum_r
n_r\\, the ratio-linearization MCSE is \$\$\mathrm{MCSE}(m) =
\frac{\sqrt{R/(R-1)\sum_r(S_r-m n_r)^2}}{\sum_r n_r}\$\$ (delta factor
\\1/(2\sqrt{m})\\ for RMSE). Non-Person MML facet coverage uses centered
covariance \\P V P^T\\ (\\P = I - 11^T/m\\) via
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md);
`Coverage95` conditions on available intervals and must be read
alongside `CoverageAvailabilityRate` and `FailedReps`.

RMSE and bias adequacy depends on the substantive scale and the use
case, so the function does not mark them as failed unless the user
supplies `max_rmse` or `max_abs_bias`. Without those limits, the
corresponding rows are marked `not_assessed` and the next action asks
the user to set practical thresholds when a decision depends on the
metric. `BiasBasis` explains groups whose mean bias is fixed at zero by
identification; even a supplied bias limit cannot turn that identity
into recovery evidence. Threshold names are matched from the most
specific group to its type or `default`; see `max_rmse` for examples.

Metrics are recomputed from row-level evidence. Coverage is conditional
on the available centered facet intervals, not all planned targets.
`uncertainty_review` retains counts, `CoverageAvailabilityRate`,
`McseCoverage95` and `CIReasons` alongside its descriptive checklist.
See `simulate_mfrm_recovery()` for the estimands, independent-trial
MCSE, unsupported interval groups and handling of legacy saved results.
Checklist tolerances do not replace the Monte Carlo uncertainty or
qualify an estimator.

The `condition_review` table is generator metadata for interpreting the
recovery run. For `GPCM`, `GPCMSlopeRegime`, `StressLevel`, and
generated score-category support describe the data-generating condition;
they are not model-fit tests and they are not literature-derived
adequacy cut points. `condition_reporting_notes` turns those generator
conditions into reporter-facing caveats, such as high-dispersion slope
stress or sparse generated score support.

The optional `diagnostic_review` table is available when
`simulate_mfrm_recovery()` was called with `include_diagnostics = TRUE`.
It summarizes fit and separation operating characteristics as diagnostic
context only. Its availability fields do not mean that fit or separation
values are adequate, and those rows do not enter the recovery adequacy
status. `diagnostic_reporting_notes` should be read first when drafting
fit/separation language because it separates zero
separation/reliability, absolute fit-ZSTD flags, and df-sensitive ZSTD
flags from recovery criteria.

`plot.mfrm_recovery_assessment()` summarizes recovery checks visually.
Use `type = "status"` first to see where checklist attention is needed,
then `type = "metrics"` to inspect the parameter groups behind RMSE,
bias, coverage, standard-error availability, or Monte Carlo precision
statuses. The intended reading order is `summary(recovery_review)`, then
`condition_reporting_notes` and `condition_review`, then
`diagnostic_reporting_notes` and `diagnostic_review`, then the status
plot, then the metric plot, then the row-level recovery table for the
parameter groups that need follow-up. When `draw = FALSE`, the plot data
also include `reading_order`, `guidance`, condition/diagnostic handoff
tables, and structured plot tables such as `section_status` for status
plots and `metric_review` for metric plots.

These plots are intended as simulation-review graphics. They do not
replace the row-level `x$recovery` table or the ADEMP metadata; they
make the main recovery estimands easier to inspect during
model-development and design checks. Coverage is displayed only for
groups with valid centered structural intervals, conditional on
availability. Summary/coverage routes refresh aggregates from saved
rows; their `availability_table` component preserves all selected
groups, including those omitted from drawing. Inspect counts,
availability rates, MCSEs and `CIReasons` via
[`plot_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/plot_data.md)
and in `summary(x)`. A wholly unavailable coverage plot gives an
informative error; it does not draw missing coverage as zero. See
`simulate_mfrm_recovery()` for the target and the treatment of legacy
saved intervals. A zero mean-aligned bias is an identification identity,
not evidence of unbiased estimation.

## Typical workflow

1.  Build a simulation specification with
    [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
    or pass scalar generator arguments directly.

2.  Run `simulate_mfrm_recovery(...)` with a modest `reps` value for an
    initial end-to-end review, then increase `reps` for stable Monte
    Carlo summaries.

3.  Inspect `summary(x)$recovery_summary` and the row-level `x$recovery`
    table.

## References

Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using
simulation studies to evaluate statistical methods. *Statistics in
Medicine*, 38(11), 2074–2102.
[doi:10.1002/sim.8086](https://doi.org/10.1002/sim.8086) .

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
`assess_mfrm_recovery()`,
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)

`simulate_mfrm_recovery()`, `plot.mfrm_recovery_simulation()`

`simulate_mfrm_recovery()`,
[`base::summary()`](https://rdrr.io/r/base/summary.html)

## Examples

``` r
# Long-running workflow; run explicitly when needed.
# example("simulate_mfrm_recovery", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
saved <- tempfile(fileext = ".rds")
rec <- simulate_mfrm_recovery(
  n_person = 12,
  n_rater = 2,
  n_criterion = 2,
  reps = 1,
  maxit = 30,
  seed = 123,
  file = saved
)
summary(rec)$recovery_summary[, c("ParameterType", "Facet", "RMSE",
  "McseRMSE", "ExpectedRows", "CoverageRows", "Coverage95")]

# A second identical call reads the result without fitting again.
again <- simulate_mfrm_recovery(n_person = 12, n_rater = 2, n_criterion = 2,
  reps = 1, maxit = 30, seed = 123, file = saved)
identical(rec, again)
unlink(saved)
} # }
# Long-running workflow; run explicitly when needed.
# example("assess_mfrm_recovery", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
rec <- simulate_mfrm_recovery(
  n_person = 12,
  n_rater = 2,
  n_criterion = 2,
  reps = 1,
  maxit = 30,
  seed = 123
)
assess_mfrm_recovery(rec, min_reps = 1, max_rmse = 1)

# Read the GPCM generator condition separately from recovery adequacy.
gpcm_spec <- build_mfrm_sim_spec(
  n_person = 14,
  n_rater = 2,
  n_criterion = 2,
  raters_per_person = 2,
  model = "GPCM",
  step_facet = "Criterion",
  slope_facet = "Criterion",
  slopes = c(0.85, 1.15),
  assignment = "crossed"
)
gpcm_rec <- suppressWarnings(simulate_mfrm_recovery(
  sim_spec = gpcm_spec,
  reps = 1,
  fit_method = "MML",
  quad_points = 5,
  maxit = 12,
  include_diagnostics = TRUE,
  include_person = FALSE,
  seed = 456
))
gpcm_review <- assess_mfrm_recovery(
  gpcm_rec,
  min_reps = 1,
  max_rmse = c(slope = 2),
  max_abs_bias = c(slope = 1),
  min_se_available = NULL,
  max_mcse_rmse_ratio = NULL
)
gpcm_review$condition_reporting_notes[, c(
  "ConditionArea", "ReportingAttention", "ConditionFinding"
)]
gpcm_review$condition_review[, c(
  "Model", "GPCMSlopeRegime", "StressLevel", "ScoreSupportStatus"
)]
gpcm_review$diagnostic_reporting_notes[, c(
  "Facet", "ReportingAttention", "DiagnosticFinding"
)]
summary(gpcm_review)$reading_order
} # }
# Optional workflow; run the example explicitly as shown below.
# example("plot.mfrm_recovery_simulation", run.dontrun = TRUE)
if (FALSE) { # \dontrun{
# One saved replication illustrates output structure, not precise rates.
# Regeneration recipe: examples/simulation-results.R in the package.
saved <- readRDS(system.file("examples", "simulation-recovery.rds",
  package = "mfrmr", mustWork = TRUE))
# Inspect saved$generation_warnings and the result's run/status tables.
rec <- saved$result
plot(rec, type = "summary", metric = "rmse", draw = FALSE)
} # }
```
