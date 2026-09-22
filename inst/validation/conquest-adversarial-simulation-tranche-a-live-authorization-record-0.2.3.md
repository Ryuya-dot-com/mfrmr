# ConQuest tranche-A G4L live-authorization freeze for mfrmr 0.2.3

Status:
`ASP_G4L_run_once_live_authorization_ready_for_same_process_issue`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-tranche-a-live-authorization-v1`
- Issuer contract:
  `mfrmr_conquest_adversarial_simulation_tranche_a_live_authorization_freeze_v1`
- Completed gate: `ASP-G4L-TRANCHE-A-LIVE-AUTHORIZATION-FREEZE`
- Next operation:
  `ASP-G4M-SAME-PROCESS-ISSUE-CONSUME-SENTINEL-AND-RUN`

## Decision

Freeze a target-bound, run-once authority issuer but do not issue a positive
authority in this review. Harness completeness, an existing executable, or the
approaching demonstration expiry cannot independently activate execution.

A future G4M process must explicitly call the issuer, consume the returned
mutable authority immediately, obtain a fresh data-free ConQuest sentinel in
that same process, and only then reach response generation or a fit. The output
target and its `.incomplete` sibling must still be absent at issue and
consumption. No static authorization file is reusable across processes.

## Frozen scope

The issuer is restricted to exactly:

- 90 disjoint tranche-A datasets and untouched registered seeds;
- 230 retained scheduled outcome rows;
- 190 one-attempt fit slots: 100 mfrmr and 90 ConQuest;
- 150 q61 attempts and 40 selective q121 attempts;
- 20 structural-negative datasets and 40 no-fit retained outcome rows;
- 90 cross-engine pairs, 40 quadrature pairs, and 10 representation pairs;
- `/Applications/ConQuest/ConQuest`;
- 2026-08-16 through 2026-08-31, before the 2026-09-01 demonstration expiry;
- 600 seconds per fit, 28,800 seconds cumulatively, and 2 GiB retained storage;
  and
- exploratory calibration of failure, variability, runtime, and storage only.

The resource evidence remains preliminary. Authorization accepts that
uncertainty only because hard total, q-specific, wall-time, storage, no-retry,
and global-abort accounting are already frozen. Reaching a global cap retains
later rows as unattempted; it does not justify extending the budget.

## Thirty-two fatal gates

All 32 issue-readiness gates pass in the no-execution review. They cover:

- G4C-P4 status and all 18 harness providers;
- exact plan, pair, schema, G4N, metric-observation reconstruction, and retained
  reviewer contracts;
- consumed, non-rerunnable G4X mechanics and retained G3 semantic bridges;
- ungenerated and unopened tranche-A seeds;
- exact absent `validation-results` target and absent incomplete sibling;
- exact executable identity, presence, executable permission, date window, and
  expiry;
- mandatory post-consumption same-process sentinel;
- clean source tree and external-runtime-free ordinary tests;
- exact hard resource caps and result-blind no-retry ordering; and
- an explicit exploratory, nonpromotional maintainer attestation with author
  overlap declared.

Every gate blocks authority issue and live execution. None may be waived for
expiry pressure, satisfied by file-byte or hash equality, or used to tune a
seed, DGP, metric, or threshold after results exist.

## Issuer/consumer boundary

P4 now requires the exact G4L issuer contract as a 28th authority field. G4L is
the only repository provider that constructs the exact mutable environment and
class accepted by the P4 consumer. The record binds the current process, target,
executable, dates, 90/230/190/150/40 counts, one-run state, clean-tree and
ordinary-test attestations, unopened result state, and the requirement for a
fresh sentinel after consumption.

Readiness review cannot itself prove a clean worktree. The issuer therefore
defaults to held, rejects every non-worktree gate before inspection, derives the
repository root from the retained G4X target, and runs exactly one fail-closed
`git status --porcelain=v1 --untracked-files=all` check immediately before
positive issue. A caller-supplied clean-tree Boolean cannot bypass that check.

The issuer defaults to held. Even `authorize=TRUE` fails if any fatal gate is
false. Ordinary tests exercise ready/blocked review states and negative issuer
paths only; they do not create a positive authority, consume one, run a
sentinel, generate a response, fit mfrmr, or launch ConQuest.

## Scientific boundary

Five replicates per scenario-family arm remain diagnostic, not a precision or
threshold claim. The run may estimate first operating characteristics and expose
failure modes, but it cannot select confirmation rules from its own output.
Conditional numeric summaries must remain beside unconditional denominators;
G4N cannot promote `InferenceReady`; and retained observation rows must
reconstruct every stored stratum aggregate.

Independent third-party recalculation is not a prerequisite for this bounded
exploratory run. That does not make ConQuest ground truth or permit agreement to
override internal oracle, structural, boundary, model-identity, or readiness
failures.

## Current state

- `AllThirtyTwoFatalGatesPassed=TRUE`
- `AuthorizationIssueReady=TRUE`
- `PositiveAuthorizationIssued=FALSE`
- `AuthorizationConsumed=FALSE`
- `FreshRuntimeSentinelObserved=FALSE`
- `ResponseGenerationAuthorizedByReview=FALSE`
- `ExecutionAuthorizedByReview=FALSE`
- `TrancheAResponsesGenerated=FALSE`
- `FitAttempts=0`
- `ConQuestExecutionAttempted=FALSE`
- `NumericAgreementInspected=FALSE`
- `ThresholdSelected=FALSE`
- `ConfirmationUseAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
