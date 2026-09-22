# JML extreme-Person paired recovery contract for mfrmr 0.2.3

Status: repository-only Draft.74 calibration contract, 2026-08-09.

## Purpose and estimator identities

This contract compares two separately named structural estimators on the same
generated data:

1. `raw_finite_jml` is the finite optimizer trace returned by the current JML
   fit; and
2. `extended_profile_limit` reoptimizes the structural and retained-Person
   coordinates after removing only independently free typed extreme-Person
   contributions under the Draft.73 boundary-supremum identity.

The profile result is not a finite full-vector maximum of the original JML
likelihood. It is also not an extreme-score adjustment or a finite-item bias
correction. The frozen factors `ExtremeAdjustment = "none"` and
`BiasCorrection = "none"` prevent either convention from being inferred from
the profile operation.

## Recovery estimands

Recovery is evaluated only for structural coordinates:

- Rater and Criterion facet locations after within-facet location alignment;
- common RSM steps or Criterion-owned PCM/GPCM steps after within-step-ladder
  alignment; and
- positive GPCM Criterion slopes on the identified geometric-mean-one
  log-slope scale.

Person recovery is ineligible. Forced all-minimum/all-maximum Person truth is
retained for data provenance but is never compared with an infinite primary
estimate or with a finite optimizer display. Profile structural standard
errors and coverage are `NA` until a separately derived uncertainty contract
exists; raw uncertainty is never copied onto the profile result.

## Frozen calibration design

`jml-extreme-profile-recovery-pilot-0.2.3.R` uses
`simulate_mfrm_data()` and preserves its `mfrm_truth` attribute before forcing
signed extreme response patterns.

| Factor | Pilot levels |
| --- | --- |
| Model | RSM, Criterion-step PCM, aligned Criterion-owned GPCM |
| Information | low: 3 Raters x 2 Criteria; high: 5 Raters x 4 Criteria |
| Persons | 80 |
| Responses per Person | low: 6; high: 20 |
| Score categories | 4 |
| Forced extreme fraction | 0, 0.10, 0.25, split equally high/low |
| Replicates | 5 fixed seeds per cell |
| Fits | 90 paired datasets |
| Optimization | JML, BFGS, `maxit = 400`, `reltol = 1e-10` |
| GPCM slope truth | positive, nonconstant, geometric mean one |

The three-dataset smoke tier uses 48 Persons, 3 Raters, 2 Criteria, a forced
fraction of 0.125, and `maxit = 240`.

The original-likelihood limit path is evaluated at signed ability caps
4, 8, 12, 16, 24, 32, 48, and 64 with tolerance `1e-8`. The larger caps are
needed because the GPCM tail rate depends on the smallest fitted positive
slope; cap 32 is not uniformly adequate when a fitted relative slope is below
one.

## Feasibility rule

The calibration contract passes only when:

- all declared datasets return a raw fit;
- every forced Person receives the correct `unbounded_high` or
  `unbounded_low` direction;
- every nontrivial profile run is `profile_limit_refit_verified`, while a
  dataset with no free extreme Persons is an explicit no-op;
- raw and profile structural recovery keys pair completely;
- no free-extreme fit is marked inference-ready; and
- all run errors and profile uncertainty claims remain explicit.

This is a runner/estimand feasibility rule, not a numeric recovery acceptance
threshold. RMSE, bias, failure, uncertainty, or sample-size values observed in
these five-replicate cells cannot be frozen as confirmation criteria.

## Output and promotion prohibitions

The runner returns the complete manifest, per-run diagnostics, paired
structural recovery rows, descriptive summaries, and underlying fit/profile
objects. Every recovery row retains the source raw convergence severity,
fit-readiness state, inference-ready flag, profile state, and forced/actual
extreme counts; review rows cannot disappear from denominators. The runner
always returns `EvidenceReady = FALSE` and
`ReadinessEffect = "none_pilot_only"`.

No result may:

- overwrite the raw fit or call the profile value a finite original-JML MLE;
- interpret near-equality of raw and profile structural estimates as removal
  of incidental-parameter bias;
- report Person recovery or profile coverage;
- select a preferred JML convention after inspecting these outcomes; or
- promote a checklist row, public estimator, default, or confirmation state.

## Remaining estimator-maturity grid

The next grid must cross raw/profile identity with separately labelled
external extreme-score adjustments and finite-item bias corrections. It must
expand replication and vary Person exposure, weights, planned missingness,
sparse and weak-link topology, workload, category support, anchor/constraint
structure, interactions, and both supported GPCM owners. Supported interval
definitions, external FACETS/TAM/immer normalization, Monte Carlo precision,
candidate-linked runtime, and untouched confirmation seeds remain open.
