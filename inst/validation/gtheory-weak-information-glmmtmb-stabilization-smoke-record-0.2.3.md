# Draft.83d2b2b1g1 glmmTMB stabilization covering-smoke record

Status: authorized viewed-data smoke completed and exactly resumed;
full-manifest execution remains unauthorized, 2026-08-10.

## Identity

| Object | SHA-256 / scientific identity |
| --- | --- |
| corrected b1g contract | `8feb8695c655c0621d61863e00d82fffe7fd5d7b619761decefaed6e89b0c326` |
| corrected b1g manifest | `92435f41b0dab7e13bf1febcf6e043fc1ae8d4a2cb7d159401dd1d78b4c9ff3e` |
| b1g1 runner contract | `3ae866b7b7179917400e6c5e5b9dd3fcf01b6ff70c6fc914564b80836c83f192` |
| b1g1 smoke execution | `c743de38ec7d5ff6606c5b1df7960caea4bca149b470063e8496db83b5ab439d` |
| runner contract artifact | `a7eab6f455d28a8e908ff9022d8ea015ff8f124547d344ef695c5f92c659a23d` |
| runner source | `b67b640ecd092d440859c11406980d07c180c0a44593a6bc0ed891b145e95ea5` |
| focused test source | `f9717b10b8227bc0c9f6dd4ffee1fd1f77e4f7f6a3aad49996740c65bdd8a8d5` |

The scientific execution hash binds all 120 atomic rows, 20 base-route
checkpoint hashes, 10 dataset-marker hashes, state counts, and profile
summaries. Timing, checkpoint path, execution order, and computed/reused state
are excluded.

## Exact accounting and resume

| Quantity | Result |
| --- | ---: |
| selected datasets | 10 / 10 |
| base routes | 20 / 20 |
| planned profile pairs | 120 / 120 |
| planned backend fits before dependency failure | 240 |
| pair rows with both fits returned and snapshotted | 116 |
| full fits returned and snapshotted | 117 |
| reduced fits returned and snapshotted | 119 |
| valid base-route checkpoints | 20 / 20 |
| valid dataset markers | 10 / 10 |
| first run computed/reused base routes | 20 / 0 |
| resume computed/reused base routes | 0 / 20 |

The resume reproduces every atomic row and execution hash without fitting.
Four focused tests and 59 expectations pass, including mutation rejection for
checkpoints and dataset markers.

Two child full fits are not attempted because their cold-BFGS parent's full
start snapshot is unavailable; all other planned model roles reach the
backend. Thus 238 backend calls are inferable from the atomic ledger. This is
not silently relabelled as 240 successful fits.

## Mutually exclusive primary states

| State | Count |
| --- | ---: |
| `returned_diagnostic_complete` | 84 |
| `finite_material_negative_drop` | 21 |
| `nonfinite_objective_or_likelihood` | 11 |
| `parent_fit_or_start_unavailable` | 2 |
| `full_fit_failure` | 1 |
| `reduced_fit_failure` | 1 |
| all other registered states | 0 |
| **Total** | **120** |

All 21 finite material-negative rows occur under the exact-zero generating
variance; none occurs in `reference_1200`. Complete rows number 34/60 for
exact-zero and 50/60 for reference-positive routes. Non-finite objective or
likelihood states number 5 and 6 respectively. These are viewed covering-
smoke descriptions, not operating characteristics.

By profile, both nlminb cold/self-restart and BFGS-warm-from-nlminb return all
20 pairs. Cold BFGS, BFGS self-restart, and nlminb-warm-from-BFGS return 19,
18, and 19 pairs. Their material-negative counts are 5, 5, and 5, compared
with 2 for each of the three nlminb-rooted profiles. The smoke therefore does
not support a universal optimizer or start rule.

## Start-state audit and negative result

All 117 snapshotted full fits and all 119 snapshotted reduced fits have exact
equality between the stored joint-state fixed coordinates and
`fit$fit$par`. Among dependent model fits that return, parent final and child
input signature hashes agree for 78/78 full and 79/79 reduced fits.

Two BFGS fits return from the backend but fail the pre-registered strict start
snapshot rule: `last.par.best` fixed coordinates are not bitwise identical to
`fit$fit$par`. One is the cold-BFGS full REML fit for
`baseline_complete/reference_1200`; its two child full models are retained as
parent-unavailable. The other is a BFGS self-restart reduced ML fit for
`imbalanced_hub/reference_1200`.

A post-result diagnostic on the first route finds a maximum fixed-coordinate
difference about 2.80e-10. Explicitly evaluating the objective at
`fit$fit$par` leaves both this difference and the random coordinates unchanged,
while the objective agrees at displayed precision. This does not authorize a
post hoc tolerance. It shows that bitwise equality and deterministic fixed-
coordinate overwrite/alignment are different contracts. A successor must
prospectively specify and test the alignment operation before the strict
snapshot failures can be reconsidered.

## Derivative and runtime telemetry

The maximum observed outer-gradient absolute values are about 0.0280 for full
and 0.0172 for reduced fits. Minimum signed Richardson relative eigenvalues
reach about -7.09e-7 and -3.11e-7. Profile summaries retain individual
full/reduced Richardson availability and positive-definiteness even when an
earlier mutually exclusive state, such as a non-finite likelihood, controls
the primary row label.

The 20 base routes take about 144.6 seconds in total, with median 3.30 and
maximum 27.3 seconds per six-profile base route on this local run. A linear
240-to-18,000-fit extrapolation is approximately three serial hours, but is
planning telemetry only and excludes unrepresented variance/replicate cells,
platform variation, and failure-pattern changes.

## Readiness adjudication

- `SmokeRunnerMechanicsReady = TRUE`;
- `FullExecutionAuthorized = FALSE`;
- `NumericalStabilizationReady = FALSE`;
- `NumericalSensitivityEvidenceReady = FALSE`;
- `CalibrationEvidenceReady = FALSE`;
- `ThresholdFrozen = FALSE`;
- `InferenceReady = FALSE`; and
- `DecisionReady = FALSE`.

The full 18,000-fit manifest is not authorized. Next comes a prospective
joint-state alignment amendment with negative controls, followed by a new
covering smoke or paired adjudication. Only after that succeeds may full
execution authorization be considered. Calibration replicates 201--300,
bootstrap operating characteristics, coefficient reporting, and D-study
decisions remain prohibited.
