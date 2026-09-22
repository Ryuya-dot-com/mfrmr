# ConQuest tranche-A authorization review for mfrmr 0.2.3

Status:
`ASP_G4A_scientific_value_retained_execution_hold_harness_freeze_required`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-tranche-a-authorization-review-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_tranche_a_authorization_review_v1`
- Completed gate: `ASP-G4A-TRANCHE-A-AUTHORIZATION-REVIEW`
- Next gate: `ASP-G4C-TRANCHE-A-HARNESS-FREEZE`

## Decision

Tranche A still has enough expected information value to justify building its
bounded calibration harness. It is not ready for response generation or live
execution.

G4N repaired the prospective numerical denominator without weakening
`InferenceReady`: the retained G4X state shows that all 16 mfrmr and 14
ConQuest mechanics attempts are categorically reachable under the separate
diagnostic contract. Tranche A can therefore answer questions that G4X could
not answer: truth error, parameter recovery, cross-engine coordinate
difference, q61-to-q121 sensitivity, representation invariance, and empirical
failure/resource behavior across disjoint simulated datasets.

This is a reason to implement the harness, not a reason to bypass it. The
repository currently has a frozen allocation, taxonomy, metric-use contract,
diagnostic classifier, and retained G4X reviewer. It does not have an
integrated calibration generator, q61/q121 runner, 230-row finalizer, metric
summarizer, run-once authorization consumer, or retained-execution reviewer.
Reusing the G4H mechanics runner would be unsafe because it is intentionally
bound to 18 retained G3 datasets, q61 mechanics, and no numerical comparison.

## Frozen tranche-A scope

- 90 newly generated datasets: five replicates in each of 18 scenario-family
  arms;
- 70 structurally eligible datasets and 20 expected prefit rejections;
- 10 paired-missingness datasets with an extra explicit-missing mfrmr fit;
- 20 datasets with the selective q121 ladder;
- 150 q61 attempts and 40 q121 attempts;
- 100 mfrmr and 90 ConQuest attempts;
- 190 total fit-attempt cap and 230 scheduled outcome rows;
- one attempt per fit cell, no automatic retry, no result-driven ordering;
- 600-second per-fit timeout, 28,800-second cumulative wall cap, and 2 GiB
  retained-storage cap; and
- an absent exact output target, with overwrite and reuse forbidden.

All seeds remain unopened, `Generated=FALSE`, and `ResultOpened=FALSE`.
Calibration data still cannot enter confirmation or support a public claim.

## Information-value judgment

The bounded tranche is useful for four reasons:

1. it supplies the first simulation operating-characteristic observations;
2. it opens the prespecified truth and independent-oracle lanes;
3. it supplies paired ConQuest/mfrmr and q61/q121 diagnostic comparisons; and
4. it preserves unconditional failure denominators when conditional numerical
   summaries are unavailable.

Five replicates per scenario-family arm are not enough to set a scientific
tolerance, make a precision claim, or freeze a confirmation decision rule.
Tranche A is a diagnostic calibration and operational checkpoint. Favorable
or unfavorable results cannot select new seeds, change the DGP, tune a metric,
or enter confirmation.

Independent third-party recalculation is not a prerequisite for this stage.
The higher-value protection is a prespecified, failure-retaining simulation
with semantic bridges, independent truth/oracle calculations, and explicit
conditional denominators. Independent recalculation can remain a later
targeted response to an unresolved attribution problem.

## Resource judgment

G4X completed 30 attempts in 26.487 seconds and retained 11,551,675 bytes. A
simple linear scale to 190 attempts is about 167.751 seconds and 73,160,608
bytes, far below the frozen 28,800-second and 2 GiB caps. This supports only a
preliminary feasibility judgment.

It is not execution-grade evidence because G4X did not observe q121 fits,
calibration data-generation cost, or runtime tails across all simulated
scenarios. In addition, 190 individual 600-second limits sum to 114,000
seconds, so the independent cumulative wall cap and complete unattempted-row
finalization are essential. Resource extrapolation cannot substitute for a
global-abort controller.

The fixed review date leaves 15 days until the 2026-08-31 run-not-after date
and 16 days until the ConQuest demonstration expiry. No fresh tranche-A
sentinel was run by G4A; a future live authorization must obtain one in the
same process immediately before generation and execution.

## Missing executable boundary

Five of 18 required capabilities are already supplied by upstream frozen
contracts. Thirteen integrated calibration capabilities are absent:

1. deterministic tranche-A dataset generation;
2. exact 230-row/190-attempt plan materialization;
3. per-dataset representation bridge validation;
4. mfrmr q61/q121 execution;
5. ConQuest q61/q121 rendering, execution, and parsing;
6. fresh-sentinel same-process control;
7. complete outcome-ledger finalization;
8. artifact registration and unexpected-file rejection;
9. per-fit and global resource-abort control;
10. application of G4N without terminal relabelling;
11. conditional and unconditional metric summarization;
12. run-once authorization-record consumption; and
13. retained execution review.

A same-named function is insufficient: each provider must also expose the
exact calibration-harness contract identity. This is an executable interface
boundary, not byte equality or a source hash.

## Required G4C work

G4C may implement and test the missing harness only. It must remain dry-run by
default and must not generate calibration responses during its own tests. It
must bind the exact seed rows and workload, materialize all outcome rows before
execution, keep engine failures independent, apply G4N prospectively, enforce
the semantic bridge, register every artifact, reject pre-existing output, and
finalize unattempted rows after a global abort.

After G4C passes, a separate target-bound live authorization is still required.
That later gate must confirm an absent output target, review-date validity,
the exact executable, and a fresh same-process data-free sentinel. Neither G4A
nor G4C can itself launch tranche A.

## Current state

- `ScientificValueGateMet=TRUE`
- `InformationGainExceedsHarnessInvestment=TRUE`
- `TrancheAPrecisionOrThresholdClaimSupported=FALSE`
- `ResourceFeasibilityPreliminary=TRUE`
- `ResourceEvidenceSufficientForExecution=FALSE`
- `HarnessCapabilitiesAvailable=5`
- `HarnessCapabilitiesMissing=13`
- `CalibrationHarnessReady=FALSE`
- `CalibrationHarnessImplementationAuthorized=TRUE`
- `CalibrationResponseGenerationAuthorized=FALSE`
- `CalibrationExecutionAuthorized=FALSE`
- `FreshTrancheASentinelObserved=FALSE`
- `NumericAgreementInspected=FALSE`
- `ConfirmationUseAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
