# ConQuest calibration-harness P4 finalization record for mfrmr 0.2.3

Status:
`ASP_G4C_P4_integrated_dry_run_harness_frozen_separate_live_authorization_required`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p4`
- Frozen contract:
  `mfrmr_conquest_adversarial_simulation_calibration_harness_v1`
- Completed subgate:
  `ASP-G4C-P4-ELIGIBILITY-METRICS-FINALIZATION-REVIEW`
- Next gate: `ASP-G4L-TRANCHE-A-LIVE-AUTHORIZATION-FREEZE`

## Decision

Freeze the integrated dry-run harness. All 18 required capability providers now
exist, but provider completeness is not live authority and is not evidence of
numeric agreement. P4 issues no positive authorization, creates no tranche-A
response, attempts no fit, and does not review a retained tranche-A result.

The next action is a separate, target-bound run-once authorization freeze. A
fresh same-process ConQuest sentinel must still follow authorization
consumption and precede response generation or any fit.

## Complete retained accounting

The finalizer accepts only the exact 230-row outcome plan and 190-attempt
journal. All 40 expected structural rejections remain explicit. Every eligible
attempt is either attempted exactly once or, after a registered global resource
abort, retained as `global_resource_abort_unattempted`. An ordinary failure or
single-fit timeout cannot suppress a peer. Pending eligible rows cannot be
silently converted into an authorization or operational failure.

G4N is applied after artifact and semantic-bridge evidence is joined. It writes
only the separate `DiagnosticNumericEligible` lane. Existing terminal codes and
`InferenceReady` values are compared before and after the classifier and must
remain identical. In particular, the bounded mfrmr rank-not-evaluated state may
enter exploratory diagnostic summaries while `InferenceReady=FALSE`; it is not
relabeled as inferentially ready.

## Denominators and metrics

The summarizer freezes 14 analysis rows and their analysis units:

- 90 generated datasets for structural accounting;
- 90 primary q61 units for each engine and 90 cross-engine pair units;
- 180 primary engine-fit units for truth/oracle/bias/RMSE diagnostics;
- 40 engine-specific q61/q121 pairs;
- 190 attempt rows for false-ready and runtime accounting;
- 10 representation pairs; and
- 1,511 registered execution artifacts for storage accounting.

Seven numeric summaries are conditional on G4N eligibility. Each retains its
unconditional denominator and explicit nonnumeric/failure count. Zero eligible
units produce no numeric statistic rather than a favorable zero. Numeric input
must be finite, registered, unique at the summary/unit level, and complete over
the eligible unit set before an aggregate is marked computed. The 14 accounting
rows never carry a pooled primary estimate; numeric estimates are emitted only
as explicit stratum rows, preserving the frozen prohibition on a primary pooled
summary. Every registered unit value is retained as a separate observation row
in the same metric ledger, and the retained reviewer reconstructs the complete
ledger from those rows instead of trusting stored aggregates. RMSE is computed
as a root mean square rather than a mean error. No threshold is selected; no
calibration statistic may enter confirmation or support a public claim.

## Run-once authority boundary

The consumer accepts only a separately issued mutable record bound to the
current process, exact absent output target, exact ConQuest path, 2026-08-16
through 2026-08-31 window, 90 datasets, 230 outcomes, 190 attempts, 150 q61
attempts, and 40 q121 attempts. It consumes the record before a sentinel or
generation authority can be derived. A widened, stale, opened, reused, already
consumed, or P4-self-issued record fails before mutation.

P4 defines the narrow bridge from a consumed run record plus a valid fresh
same-process sentinel to P2's one-dataset generation authority. This makes the
prospective control path connected without issuing such a record here.

## Retained review

The retained reviewer does not regenerate or refit. It requires all 14 root
ledgers, reconstructs the 230-row plan and 1,511-artifact inventory, rejects an
unexpected file, reapplies G4N from categorical readiness evidence, checks
metric denominators and complete numeric coverage, and verifies consumed
run-once authority. A successful review remains exploratory only and does not
authorize rerun, threshold selection, evidence promotion, or a scientific
equivalence claim.

Artifact presence, non-emptiness, typed identities, semantic bridges, and
ledger reconstruction are checked. The use of file-byte or hash equality is neither
inspected nor accepted as scientific evidence.

## Adversarial checks

Tests reject unattempted finalization without a real global abort, unknown
terminal codes, G4N terminal relabeling, missing mfrmr categorical readiness,
ineligible or duplicate metric units, denominator shrinkage, zero-denominator
numeric invention, widened authorization counts, target reuse, and repeated
authorization consumption. Static checks forbid destructive cleanup, digest
acceptance, and top-level generation or execution calls.

No test invokes ConQuest, fits mfrmr, generates a tranche-A response, or opens
the absent calibration output directory.

## Current state

- `UpstreamAndHarnessCapabilitiesAvailable=18`
- `HarnessCapabilitiesStillMissing=0`
- `CompleteOutcomeFinalizerImplemented=TRUE`
- `TerminalNonmutatingG4NApplicationImplemented=TRUE`
- `ConditionalAndUnconditionalMetricSummarizerImplemented=TRUE`
- `RunOnceAuthorizationConsumerImplemented=TRUE`
- `RetainedExecutionReviewerImplemented=TRUE`
- `RetainedExecutionReviewPerformed=FALSE`
- `TrancheAResponsesGenerated=FALSE`
- `FitAttempts=0`
- `ConQuestExecutionAttempted=FALSE`
- `PositiveLiveAuthorizationIssuedByP4=FALSE`
- `ResponseGenerationAuthorized=FALSE`
- `ExecutionAuthorized=FALSE`
- `NumericAgreementInspected=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
