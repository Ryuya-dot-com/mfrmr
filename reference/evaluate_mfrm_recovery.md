# Evaluate parameter recovery by repeated simulation and refitting

Runs a compact parameter-recovery simulation study: generate data from a
known ordered many-facet data-generating setup, refit the requested
model, align estimates to the known truth where location indeterminacy
requires it, and summarize bias, RMSE, MAE, correlation, and
standard-error coverage.

## Usage

``` r
evaluate_mfrm_recovery(
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
  seed = NULL
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
  or role keywords (`person`, `rater`, `criterion`, `assignment`). For
  the currently exposed facet keys, the schema-only future branch input
  `design$facets = c(person = ..., rater = ..., criterion = ...)` is
  also accepted. Do not specify the same variable through both `design`
  and the scalar count arguments.

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
  generator supports `RSM`, `PCM`, and bounded `GPCM`.

- step_facet:

  Step facet used when `model = "PCM"` and threshold values vary across
  levels. Currently `"Criterion"` and `"Rater"` are supported.

- slope_facet:

  Slope facet used when `model = "GPCM"`. The current bounded `GPCM`
  branch requires `slope_facet == step_facet`.

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

  Estimation method passed to
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
  from recovery metrics and are not release-success criteria by
  themselves.

- diagnostic_fit_df_method:

  Fit-ZSTD degrees-of-freedom convention used for optional diagnostic
  operating-characteristic summaries. Use `"both"` when reviewing
  FACETS-style df sensitivity.

- seed:

  Optional random seed.

## Value

An object of class `mfrm_recovery_simulation` with components:

- `recovery`: row-level truth/estimate comparisons by replication.

- `recovery_summary`: parameter-type summaries across replications.

- `rep_overview`: replication-level convergence, timing, error status,
  and sparse-design diagnostics when applicable.

- `diagnostic_oc`: optional replication-by-facet fit/separation
  operating characteristics when `include_diagnostics = TRUE`.

- `diagnostic_oc_summary`: optional facet-level diagnostic operating-
  characteristic summary.

- `settings`: fitting and simulation settings.

- `ademp`: simulation-study metadata.

## Details

This helper is deliberately narrower than
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md).
Design evaluation asks which design condition is operationally adequate;
recovery simulation asks whether the fitted model recovers the known
parameters under one explicit data-generating setup.

Location-like parameters (`Person`, non-person facets, and steps) are
summarized after mean alignment within each replication and parameter
group. This follows the usual Rasch/MFRM identification convention:
adding a common constant to one location block should not be counted as
recovery failure. Raw, unaligned errors are retained in `recovery` and
summarized as `RawBias` / `RawRMSE`.

For bounded `GPCM`, supplied generator slopes are treated as relative
discriminations and normalized to the same geometric-mean-one log-slope
identification used by the fitter. Slope recovery is therefore
summarized on the identified log-slope scale without an additional
mean-alignment step. Direct data generation and refitting are supported,
but broader GPCM design- planning claims remain outside the current
package boundary.

Sparse linked generators are supported through `sim_spec` or direct
`assignment = "sparse_linked"` plus `sparse_controls`. Their
design-density and rater-link diagnostics are retained in
`rep_overview`; recovery metrics remain parameter-recovery summaries and
should not be read as evidence that a sparse linking design is adequate
by itself.

The returned `ademp` component follows the simulation-study framing of
Morris, White, and Crowther (2019) and the ADEMP planning/reporting
template used in later simulation-study guidance.

## Typical workflow

1.  Build a simulation specification with
    [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md)
    or pass scalar generator arguments directly.

2.  Run `evaluate_mfrm_recovery(...)` with a modest `reps` value for a
    smoke check, then increase `reps` for stable Monte Carlo summaries.

3.  Inspect `summary(x)$recovery_summary` and the row-level `x$recovery`
    table.

## See also

[`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md),
[`evaluate_mfrm_design()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_design.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)

## Examples

``` r
if (FALSE) { # \dontrun{
rec <- evaluate_mfrm_recovery(
  n_person = 12,
  n_rater = 2,
  n_criterion = 2,
  reps = 1,
  maxit = 30,
  seed = 123
)
summary(rec)$recovery_summary[, c("ParameterType", "Facet", "RMSE", "Bias")]
} # }
```
