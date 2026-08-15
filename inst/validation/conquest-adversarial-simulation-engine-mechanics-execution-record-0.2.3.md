# ConQuest adversarial simulation engine-mechanics execution for mfrmr 0.2.3

Status: `ASP_G4X_engine_mechanics_complete_calibration_review_required`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-engine-mechanics-harness-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_engine_mechanics_harness_v1`
- Completed gate: `ASP-G4X-ENGINE-MECHANICS-EXECUTION`
- Next gate: `ASP-G4R-POST-MECHANICS-CALIBRATION-REVIEW`

## Run-once execution

The exact prepared bundle was opened once. A newly executed data-free `quit;`
sentinel identified ConQuest 5.47.5 Demonstration Version at
`/Applications/ConQuest/ConQuest`, x86_64 through Rosetta, before attempt 1.
The sentinel passed on 2026-08-16, before its 2026-09-01 expiry.

The harness retained all 38 scheduled outcome rows:

- 30/30 eligible q61 attempts were started and completed;
- 16/16 mfrmr and 14/14 ConQuest attempts were retained;
- all 8 negative-control outcome rows remained prefit stops, representing four
  distinct structural negative datasets and zero negative-control fits;
- all 30 attempted results were parseable;
- all four engine-family parser cells were covered;
- both explicit-missing mfrmr family cells and both ConQuest representation
  bridges were covered;
- the expected dimensions were 10 for every RSM result and 14 for every PCM
  result, with zero model-identity mismatch;
- no peer attempt was suppressed, no row was dropped, no retry occurred, and
  no global resource abort occurred.

Elapsed phase time was 26.487 seconds and retained storage was 11,551,675 bytes,
against the frozen 28,800-second and 2-GiB caps. These resource observations do
not authorize changing either cap.

## Retained readiness states

All 14 ConQuest attempts ended `complete_numeric_eligible`. All 16 mfrmr fits
converged and were finite, parseable, and dimension-matched, but remained
`optimizer_nonconvergence_or_readiness_hold` because `InferenceReady=FALSE`.
Fourteen carried `design_rank_not_evaluated`; the two explicit-missing
companions additionally carried `input_review_required`. This is the package's
conservative nonlinear MML variance-coordinate readiness boundary, not an
optimizer failure and not a cross-engine numerical discrepancy.

The mechanics gate deliberately does not require every fit to be inference
ready. It requires that every scheduled result be retained and that the parser,
identity, representation, independence, sentinel, and resource mechanics are
observable. Whether the deterministic mfrmr readiness hold makes calibration
informative or wasteful is reserved for G4R; execution itself does not answer
that question.

## Lossless CSV type-inference incident

The in-memory finalizer reconstructed all 30 artifact rows as complete and
wrote `MechanicsGateMet=TRUE`. Its immediate CSV roundtrip reviewer initially
returned a hold because the entirely blank `UnexpectedArtifactKinds` column
was inferred by `read.csv()` as logical `NA`, while reconstruction represented
the same empty cells as character `""`.

No artifact was missing and no unregistered file was present. The reviewer was
corrected to normalize only the two optional artifact-list columns before
semantic comparison. A regression test reproduces the all-empty CSV inference.
The original execution files were not deleted, rewritten, or rerun. After this
lossless semantic normalization, accounting, artifact accounting, and all 16
frozen mechanics criteria pass.

This correction is not a tolerance change, result selection, numerical
comparison, or byte-identity exception. It changes no response, fit, estimate,
terminal state, denominator, artifact-presence decision, or mechanics
criterion.

## Decision boundary

- `FreshRuntimeSentinelPassed=TRUE`
- `FitAttemptCount=30`
- `RetainedOutcomeRows=38`
- `ParseableAttemptOutcomes=30`
- `ModelIdentityMismatches=0`
- `GlobalAbortTriggered=FALSE`
- `ArtifactAccountingComplete=TRUE`
- `MechanicsGateMet=TRUE`
- `RunOnceConsumed=TRUE`
- `RerunAuthorized=FALSE`
- `NumericAgreementInspected=FALSE`
- `CalibrationAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

The next action is not automatic calibration. G4R must decide prospectively
whether a calibration whose mfrmr outcomes are expected to retain the current
nonlinear-estimability review state can answer the frozen operational questions
without being misrepresented as inferential validation.
