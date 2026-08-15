# ConQuest post-mechanics calibration review for mfrmr 0.2.3

Status: `ASP_G4R_calibration_hold_diagnostic_eligibility_addendum_required`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-post-mechanics-calibration-review-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_post_mechanics_calibration_review_v1`
- Completed gate: `ASP-G4R-POST-MECHANICS-CALIBRATION-REVIEW`
- Next gate: `ASP-G4N-DIAGNOSTIC-NUMERIC-ELIGIBILITY-ADDENDUM`

## Decision

Do not run the 190-fit calibration tranche A yet.

G4X established that both engine adapters, both family parsers, dimensions,
paired missingness, failure retention, and runtime/resource mechanics work. It
did not establish that the frozen calibration can populate its main numerical
denominators. All 16 mfrmr outcomes were finite, converged, parseable, and
dimension-matched, but all 16 retained `InferenceReady=FALSE` and therefore the
terminal class `optimizer_nonconvergence_or_readiness_hold`.

This state is not evidence of cross-engine disagreement. No coordinate,
deviance, likelihood, truth error, or cross-engine difference was read by G4R.
It is a deterministic boundary of the current conservative nonlinear MML
variance-coordinate estimability contract. The two explicit-missing rows also
retain `input_review_required`; no reason code is discarded.

## Why immediate calibration is locally busy but globally uninformative

Under the frozen terminal semantics, mfrmr has zero
`complete_numeric_eligible` mechanics outcomes. Consequently tranche A could
still estimate structural dispositions, engine execution/readiness rates,
joint numeric eligibility as zero, false-ready counts, runtime, and storage.
However, it cannot populate the mfrmr or joint lanes required by six active
numeric metrics (ConQuest-only lanes may remain observable):

- probability truth error;
- continuous-target oracle error;
- parameter bias;
- parameter RMSE;
- cross-engine coordinate difference;
- q61-to-q121 sensitivity.

The paired representation numeric summary is blocked for the same reason.
Spending 190 fits merely to reproduce a code-determined zero denominator would
not answer the main comparison question and would risk confusing mechanics
activity with scientific progress.

## Rejected shortcuts

G4R rejects relabelling readiness holds as complete, lowering or bypassing
`InferenceReady`, silently treating review-only output as inferentially ready,
or running tranche A unchanged and repairing its denominator after results are
seen. It also rejects changing seeds, DGPs, workload, attempt order, or the
paired representation denominator.

The scientifically strongest long-term route is to complete the nonlinear MML
estimability classification. A smaller next step can be defensible: freeze a
separate `DiagnosticNumericEligible` lane for finite, converged, parseable,
dimension-matched fits while preserving `InferenceReady=FALSE`. That lane may
support explicitly exploratory technical comparisons, but never confirmation,
inference, evidence promotion, or public claims.

## Required G4N addendum

Before any calibration response is generated, G4N must:

1. preserve the current inference-readiness decision and reason codes;
2. define diagnostic numeric eligibility separately and prospectively;
3. require completed, finite, parseable, dimension-matched, converged fits;
4. exclude identity, optimizer, nonfinite, parser, runtime, and semantic errors;
5. map every numeric metric to diagnostic versus inferential use;
6. retain unconditional failure companions and false-ready accounting;
7. forbid diagnostic results from confirmation and public promotion;
8. preserve all frozen seeds, DGPs, workloads, attempt order, and paired bridge;
9. add adversarial zero-denominator and false-ready tests; and
10. retain the fresh-sentinel and run-once execution boundary.

G4N completion will still require a separate calibration execution
authorization. The addendum alone cannot launch tranche A.

## Current state

- `MechanicsGateMet=TRUE`
- `MfrmrMechanicsOutcomes=16`
- `MfrmrCompleteNumericOutcomes=0`
- `MfrmrConvergedParseableDimensionMatched=16`
- `FrozenNumericMetricsWithMfrmrOrJointLaneBlocked=6`
- `RepresentationNumericSummaryBlocked=TRUE`
- `CalibrationPartiallyInformativeForCountsAndResources=TRUE`
- `CalibrationInformativeForFrozenNumericObjective=FALSE`
- `DiagnosticNumericEligibilityAddendumRequired=TRUE`
- `CalibrationResponseGenerationAuthorized=FALSE`
- `CalibrationExecutionAuthorized=FALSE`
- `EngineMechanicsRerunAuthorized=FALSE`
- `NumericAgreementInspected=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
