# ConQuest calibration-harness P3 adapter record for mfrmr 0.2.3

Status:
`ASP_G4C_P3_engine_adapters_artifacts_resources_frozen_integrated_harness_incomplete`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p3`
- Contract under construction:
  `mfrmr_conquest_adversarial_simulation_calibration_harness_v1`
- Completed subgate: `ASP-G4C-P3-ENGINE-ADAPTERS-ARTIFACTS-RESOURCES`
- Next subgate: `ASP-G4C-P4-ELIGIBILITY-METRICS-FINALIZATION-REVIEW`

## Decision

Freeze q61/q121 adapters, the same-process sentinel controller, the complete
attempt-artifact namespace, and resource/continuation rules without generating
a tranche-A response or attempting a fit. P3 provides a one-attempt controller;
P4 must still consume the integrated authorization, apply G4N, finalize every
scheduled row, summarize metrics, and review retained execution.

This separation keeps an ordinary adapter or parser failure local to one
attempt. It cannot alter the frozen attempt order, remove its peer, or silently
shrink a denominator.

## Exact adapter workload

The P1 plan is decorated into 190 unique run IDs and prefixes while retaining
all 230 scheduled outcome rows:

- 100 mfrmr attempts: 80 q61 and 20 q121;
- 90 ConQuest attempts: 70 q61 and 20 q121;
- 150 q61 attempts and 40 selective q121 attempts in total;
- RSM free dimension 10 and PCM free dimension 14; and
- one 600-second cap with no automatic retry for every attempt.

The mfrmr adapter fixes direct MML, `maxit=2000`, `reltol=1e-12`, the scheduled
61 or 121 quadrature points, a population regression on X, and criterion-specific
steps for PCM. The ConQuest adapter fixes the same RSM/PCM model identities,
the scheduled node count, iteration and convergence controls, and the eight
native output classes already exercised by G4H. Its parser remains independent
of q and requires the expected free dimension plus finite typed estimates.

Both execution adapters default to held. The ConQuest route additionally
requires the exact existing executable `/Applications/ConQuest/ConQuest`; a
different path cannot be substituted after sentinel validation. Neither
adapter accepts `authorize=TRUE` alone: the controller must issue an exact,
process-local, one-attempt permit after sentinel and resource admission. The
permit is consumed before fitting, including when the attempt later fails.

## Fresh same-process sentinel

P3 converts an exact, data-free ConQuest 5.47.5 Demonstration assessment into a
process-local token bound to:

- the current process ID;
- the frozen calibration output directory;
- the exact ConQuest executable;
- the 2026-08-16 through 2026-08-31 authorization window;
- the 2026-09-01 expiry date; and
- all 90 registered dataset/seed pairs.

The token asserts that no model estimation or numeric comparison occurred.
Changing the process, target, seed, runtime identity, or numeric-inspection flag
invalidates it. P2 generation now requires this validator; sentinel booleans
alone remain insufficient.

## Artifacts and unexpected-file guard

The prospective execution namespace registers 1,511 result artifacts:

- 700 conditional mfrmr success/failure artifacts;
- 810 ConQuest native/console artifacts; and
- one fresh-sentinel console.

Together with 380 typed attempt-input files and 18 root controls/ledgers, the
allowed-path registry contains 1,910 unique paths, including the retained
numeric-observation detail ledger required by G4M. Any file outside that set
fails the boundary audit. Presence and non-emptiness are tracked semantically;
file-byte or hash equality is neither inspected nor accepted as scientific
evidence. Outcome-specific success-versus-failure artifact completeness remains
for P4 finalization. Because the calibration output directory is still absent,
P3 records the guard implementation but does not claim that a live output
boundary was inspected.

## Resource and continuation policy

The controller fixes the tranche-A caps at:

- 190 total attempts;
- 150 q61 attempts;
- 40 q121 attempts;
- 600 seconds per fit;
- 28,800 cumulative seconds; and
- 2 GiB retained storage.

Reaching a total, quadrature-specific, wall-time, or storage cap stops later
attempts and requires P4 to retain them as global-abort-unattempted rows. An
ordinary mfrmr or ConQuest failure, parser failure, model-identity mismatch,
nonfinite result, readiness hold, or single-fit timeout does not stop a later
peer. Automatic retry and result-driven ordering remain false.

## Adversarial checks

Tests require exact engine-by-q counts, q-specific command syntax, family model
identity, direct-MML arguments, unique run paths, the full artifact namespace,
unexpected-file rejection, independent continuation after a fit timeout, and
global stopping at every frozen cap. They also reject q31, GPCM widening, a
601-second timeout, a substituted ConQuest path, an out-of-window sentinel, a
wrong seed, a different process, or a token marked as having inspected numeric
agreement.

No test calls ConQuest, fits mfrmr, generates a tranche-A response, or opens the
calibration result directory.

## Deliberate incompleteness

P3 advances the capability audit from eight to thirteen available providers.
Five providers remain missing:

- complete outcome-ledger finalizer;
- prospective G4N eligibility application without terminal relabelling;
- conditional and unconditional metric summarizer;
- integrated run-once authorization-record consumer; and
- retained execution reviewer.

## Current state

- `UpstreamAndHarnessCapabilitiesAvailable=13`
- `HarnessCapabilitiesStillMissing=5`
- `Q61Q121MfrmrAdapterImplemented=TRUE`
- `Q61Q121ConQuestAdapterAndParserImplemented=TRUE`
- `SameProcessSentinelControllerImplemented=TRUE`
- `ArtifactInventoryAndUnexpectedFileGuardImplemented=TRUE`
- `OutputBoundaryInspected=FALSE`
- `ResourceAndPeerContinuationControllerImplemented=TRUE`
- `TrancheAResponsesGenerated=FALSE`
- `FitAttempts=0`
- `ConQuestExecutionAttempted=FALSE`
- `ResponseGenerationAuthorized=FALSE`
- `ExecutionAuthorized=FALSE`
- `NumericAgreementInspected=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
