# Simulate parameter recovery by repeated generation and refitting

Runs a compact parameter-recovery simulation study: generate data from a
known ordered many-facet data-generating setup, refit the requested
model, align estimates to the known truth where location indeterminacy
requires it, and summarize bias, RMSE, MAE, correlation, and coverage of
available centered structural facet intervals. This function runs the
simulation and fits models. To review an already saved simulation result
without new data generation or fitting, use
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md).
In 0.2.4 this replaces `evaluate_mfrm_recovery()`; the old name remains
an alias. See the details for corrected recovery targets, Monte Carlo
uncertainty and migration of saved results.

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
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md).
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

## Details

This helper is deliberately narrower than
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).
Design evaluation asks which design condition is operationally adequate;
recovery simulation asks whether the fitted model recovers the known
parameters under one explicit data-generating setup.

Location-like parameters (`Person`, non-person facets, and steps) are
summarized after mean alignment within each replication and parameter
group. These errors describe relative locations within the matched
group. Their average `Bias` is zero by construction, so it cannot
establish absence of bias for individual parameters. `BiasBasis`
identifies this restriction;
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
leaves its bias check `not_assessed`. Inspect RMSE and row-level errors
for relative recovery instead.

PCM/GPCM step vectors are centered within their owning facet level.
Their generating step means are therefore added to the corresponding
facet truth before comparison. A generated population intercept, when
fitted, is shifted consistently with the fitted facet/step
identification. `RawTruth` retains the original generator parameter.
`Truth` is the comparison-coordinate truth; `ErrorRaw`, `RawBias` and
`RawRMSE` use this truth before the additional within-group mean
alignment, not necessarily `RawTruth`.

For `GPCM`, supplied generator slopes are treated as relative
discriminations and normalized to the same geometric-mean-one log-slope
identification used by the fitter. Slope recovery is therefore
summarized on the identified log-slope scale without an additional
mean-alignment step. Average bias over a complete log-slope block is
also zero by identification and is not an automatic adequacy criterion.
Direct data generation and refitting are supported, but broader GPCM
design- planning claims remain outside the current package boundary.

Sparse linked generators are supported through `sim_spec` or direct
`assignment = "sparse_linked"` plus `sparse_controls`. Their
design-density and rater-link diagnostics are retained in
`rep_overview`; recovery metrics remain parameter-recovery summaries and
should not be read as evidence that a sparse linking design is adequate
by itself.

The returned `ademp` component follows the simulation-study framing of
Morris, White, and Crowther (2019) and the ADEMP planning/reporting
template used in later simulation-study guidance.

## Saving and resuming simulations

Pass the same `file` and analysis arguments on a subsequent call to
reuse the completed result without generation or fitting, or to resume
an interrupted run. The identity includes generator
inputs/specification, fitting controls, requested replications, seed,
RNG kind, package R code and native library fingerprints, relevant
numerical/diagnostic R options, R/platform, numerical libraries and
dependency versions. Changing `reps` starts a different study; extension
of an existing study is not supported. `progress` and `parallel` do not
change the identity. Cached results retain the settings of their
original run.

Recovery runs and serial design evaluations save after every finished
trial. Future design evaluations save after a whole design row returns;
an interrupted row may need to run again. A partially completed
optimizer is not resumed. Fit failures are completed attempts and are
saved too; resuming does not redraw failures until they succeed. An
unexpected error outside the recorded fit/diagnostic failure routes
stops the call and leaves earlier checkpoints available. These files do
not change the interpretation or eligibility of the underlying estimates
and intervals.

Per-trial seeds are allocated before computation and retained even when
`seed = NULL`; an explicit seed is preferable for reproducing a new run
in another file. Each trial controls generation, fitting and diagnostics
with its own seed. A matching environment is required for automatic
reuse; recorded seeds alone do not guarantee identical floating-point
results on other systems. Keep the analysis script and software
environment as well.

After completion, `readRDS(file)` returns the usual result object with
an additional `reproducibility` component containing identity, inputs
and trial seeds. Before completion the file is an internal checkpoint;
resume through the same public function. Writes use a temporary file in
the same directory and checked replacement. A `.lock` directory prevents
concurrent writers. Normal returns/errors release it; after process
termination, remove a remaining lock only after checking that no writer
is active. Unreadable files are never silently reused or replaced by
`"on_change"`.

## Monte Carlo uncertainty and missing results

Replications, not parameter rows within a replication, are independent.
For a pooled available-row mean, let \\S_r\\ be the sum of values in
trial \\r\\, \\n_r\\ its available-row count and \\m = \sum_r S_r /
\sum_r n_r\\. With \\R\\ recorded trials, the ratio-linearization MCSE
is \$\$\mathrm{MCSE}(m) = \frac{\sqrt{R/(R-1)\sum_r(S_r-m
n_r)^2}}{\sum_r n_r}.\$\$ Failed trials contribute zero sums and counts.
RMSE uses squared errors and the delta-method factor \\1/(2\sqrt{m})\\;
`McseCoverage95` applies the same ratio calculation to coverage
indicators. Fewer than two contributing trials gives `NA`, as does the
RMSE delta MCSE at zero RMSE. These are large-replication
approximations; small examples do not qualify performance.

`recovery_targets` records expected target counts after generation,
before fitting. Summaries retain `AttemptedReps`, `FailedReps`,
`ExpectedRows`, `EstimateRows`, `SEAvailableRows`, `CoverageRows` and
`CoverageReps`. `Coverage95` is conditional on an available interval:
report it with `CoverageAvailabilityRate` and failures. Unavailable
intervals are not counted as noncoverage. Availability rates use all
expected targets, including failed fits. A generation failure or legacy
result can leave the roster unknown; then `ExpectedRows` and
full-denominator availability rates are `NA`, while `KnownTargetRows`
and `KnownTargetReps` remain visible.

## Interval targets

For non-Person facets, coverage concerns each level minus its facet
mean. With \\P = I - 11^T/m\\, its covariance is \\P V P^T\\; the
original marginal SE cannot be reused after alignment. The runner
obtains model-based 95\\ its numerical/source checks. A complete matched
facet roster is required. The row table retains `CoverageEstimate`,
`CoverageTruth`, `SE`, `Lower95`, `Upper95`, `CIEligible` and
`CIReason`. `RawSE` separately preserves the source uncertainty. A valid
target SE can remain available when its interval bounds cannot be
represented.

JML remains a point-recovery route. Person-score uncertainty is
conditional or posterior score uncertainty, not the centered structural
interval above. Their coverage is unavailable with an explicit reason;
step, slope and population recovery also retain point comparisons
without a matching interval implementation here. This does not alter
uncertainty available through other model-specific APIs. Numerical
eligibility alone does not establish finite-sample coverage or
robustness to model misspecification.

## Previously saved recovery results

[`summary()`](https://rdrr.io/r/base/summary.html),
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md)
and summary/coverage
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) routes
recompute aggregates from saved rows without fitting. They correct trial
MCSEs and withhold old coverage whose centered covariance was not
retained. They cannot repair the identified PCM/population truth from
old row tables; start a new study to obtain those corrections and
matched interval evidence. Read `summary(x)$notes` and the new
availability/reason columns. Directly reading an old
`x$recovery_summary` does not update that stored table. The default file
reuse policy rejects the changed implementation identity; use a new file
path to preserve the old study.

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
[`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md),
[mfrmr_compatibility_layer](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_compatibility_layer.md)

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
```
