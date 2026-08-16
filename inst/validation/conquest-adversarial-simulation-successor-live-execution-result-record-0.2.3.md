# ConQuest tranche-A G4O successor execution result for mfrmr 0.2.3

Status:
`ASP_G4M_tranche_A_execution_retained_review_complete_exploratory_only`,
2026-08-16.

- Frozen source commit at live launch: `2deeed6`
- Specification:
  `0.2.3-conquest-adversarial-simulation-successor-live-execution-v2`
- Final target:
  `validation-results/conquest-adversarial-simulation-calibration-tranche-a-20260816-v2`
- Pre-issue target:
  `validation-results/conquest-adversarial-simulation-calibration-tranche-a-20260816-v2.preissue`
- Approval identity:
  `user-2026-08-16-unsandboxed-conquest-successor-run`
- Runtime: ConQuest 5.47.5 Demonstration Version under
  `/usr/bin/arch -x86_64`, expiring 2026-09-01

## Execution disposition

The successor ran in one R process outside the restricted Codex filesystem
sandbox. Its data-free pre-issue probe completed semantically before authority
issue. The token was bound to that R PID, executable, launcher route, run date,
expiry window, and retained console, then consumed before the new v2 authority
was issued. The authority was consumed before the separate fresh sentinel,
which also completed semantically. No automatic retry occurred.

An earlier wrapper invocation in the same turn stopped before creating any v2
path or launching ConQuest because it had omitted `pkgload::load_all()` and the
upstream working-tree namespace gate failed. It did not open or consume the
G4O live boundary. The corrected invocation passed all 32 predecessor gates
before the pre-issue launch.

The retained execution contains:

- 90 generated datasets and all 230 scheduled outcome rows;
- 190/190 attempted fits: 150 at q61 and 40 at q121;
- 90/90 ConQuest and 100/100 mfrmr attempts;
- no global abort, peer suppression, dropped row, or retry;
- 245.495 seconds through retained finalization, of which the fit-attempt
  elapsed total was 159.886 seconds; and
- 63,908,021 retained bytes at finalization.

All 90 ConQuest attempts were parseable, dimension-matched
`complete_numeric_eligible` outcomes. All 100 mfrmr attempts converged with
`tolerance_met`, finite boundary state, adequate categories, and numerical
state `ready`, but retained the terminal class
`optimizer_nonconvergence_or_readiness_hold` because inference readiness was
not established. Ninety carried `design_rank_not_evaluated`; ten additionally
carried `input_review_required`. G4N made all 190 rows available for exploratory
diagnostic numeric summaries without changing those terminal or
inference-readiness states.

## Exploratory numerical observations

These are calibration observations, not acceptance thresholds or confirmation
decisions.

| Metric | N | Median | P90 | Maximum |
| --- | ---: | ---: | ---: | ---: |
| maximum absolute cross-engine coordinate difference | 90 | `2.1270e-6` | `6.9990e-6` | `3.278169e-3` |
| q61/q121 coordinate sensitivity | 40 | `1.9020e-12` | `3.2140e-6` | `8.500341e-5` |
| representation coordinate difference | 10 | `0` | `0` | `0` |
| fitted-coordinate continuous-oracle deviance difference | 180 | `1.6535e-7` | `2.1602e-6` | `3.515354e-4` |
| elapsed seconds per fit | 190 | `0.748` | `1.1651` | `2.773` |

The largest cross-engine difference is the
`ASP-SENS-EXTREME-PERSON::PCM::q61` row
`CQASP-CAL-A14-R03::PCM::q61::primary`. It is not attributed to floating-point
rounding and cannot be accepted or rejected without the next prospectively
set, metric-specific decision-loss and precision contract. Correlation is not
used as a pass rule and has not yet been added to this calibration summary.

## Retained-review correction

The live process completed all fits and wrote every finalization artifact, then
stopped in the retained reviewer because the predecessor G4M dependency guard
contained the v1 issuer string literally. A G4O-only binding now validates the
v2 issuer without changing the consumed output or rerunning a model.

The next review exposed two false exact-string holds after CSV round trips:

- storage-summary mean, SD, and P90 differed from recomputation by at most
  `5.820766091346741e-11` at a scale near `421844.8`; and
- 32 of 71,271 numeric-detail rows differed in `Reference` by more than the old
  absolute `1e-12`, with maximum `5.002220859751105e-12` and a scale-aware
  machine bound of `1.9340164070496896e-11`.

All nonnumeric detail fields matched exactly. G4O therefore uses
`64 * .Machine$double.eps * max(1, abs(left), abs(right))` only for retained
double-valued artifact reconstruction. A synthetic `1e-6` perturbation at the
same scale is rejected. This rule is not used for cross-engine scientific
agreement, likelihood evaluation, or threshold selection.

After that correction, plan, generation, semantic tables, artifacts, sentinel,
eligibility, metric contract, consumed authority, and independently
reconstructed 71,271-row numeric detail all pass retained review. The outcome
remains exploratory and does not establish scientific equivalence,
inference-readiness, confirmation use, evidence promotion, or a public claim.

## State

- `PreissueSemanticProbePassed=TRUE`
- `PostconsumptionFreshSentinelPassed=TRUE`
- `AuthorizationConsumed=TRUE`
- `FitAttempts=190`
- `RowsDropped=0`
- `AutomaticRetryPermitted=FALSE`
- `RetainedNumericDetailReconstructed=TRUE`
- `RetainedExecutionReviewComplete=TRUE`
- `ThresholdSelected=FALSE`
- `ConfirmationUseAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
- `PublicClaimAuthorized=FALSE`
