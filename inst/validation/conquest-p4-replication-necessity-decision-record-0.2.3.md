# ConQuest P4 replication-necessity decision for mfrmr 0.2.3

Status: `P4_closed_replication_not_needed_for_selected_bounded_claim`,
2026-08-15.

- Specification: `0.2.3-conquest-p4-replication-necessity-decision-v1`
- Contract: `mfrmr_conquest_p4_replication_necessity_decision_v1`
- Selected claim: candidate-004 fixed-artifact bounded comparison

## Decision

Replication is not needed for the selected claim. Candidate 004 asks whether
two implementations agree, under frozen budgets, for one fixed data set,
model, quadrature pair, runtime, and set of reported output tokens. A new
sampled data set would answer a broader cross-data-set question and cannot
change the already retained fixed-artifact calculation.

Independent human review is not necessary for this bounded internal result or
for the 0.2.3 release. It could still ask whether another person can reconstruct
the mapping and denominators, but that is optional assurance rather than a
mathematical, CRAN, or claim-identification requirement. Repeating the same-
author pipeline on many data sets would not create that assurance and is also
unnecessary.

## Claim-specific dispositions

| claim | current disposition |
| --- | --- |
| Candidate-004 fixed-artifact bounded comparison | `replication_not_needed`; retain as bounded internal evidence without a human-review release gate |
| Six-arm candidate-003 historical result | no replication for historical retention; no current promotion target |
| Full P2 design portfolio | deterministic execution and classification first |
| P3 item-only GPCM | C0--C5 and one deterministic external candidate first |
| Cross-data-set disagreement/failure rate | claim not selected |
| Recovery bias or RMSE | claim not selected |
| Uncertainty coverage | claim not selected |
| Cross-runtime/platform portability | claim not selected |

## Why no replication design is frozen

The independent sampling unit, target rate, confidence or MCSE precision,
replication count, sequential rule, failed-fit policy, and maximum generalized
claim are all typed `not_applicable_replication_not_needed_for_selected_claim`.
Inventing values for them now would quietly broaden the claim and turn expiry
pressure into scientific scope.

If a future decision genuinely requires a disagreement rate, recovery,
coverage, or portability claim, it must receive a new prospective contract
covering all seven fields before data generation. It cannot inherit candidate
004's fixed-artifact pass or this non-necessity decision.

## Current decision

- `SelectedClaimReplicationNeeded=FALSE`
- `IndependentReviewStillRequired=FALSE`
- `IndependentReviewRequiredBeforePublicPromotion=FALSE`
- `IndependentReviewBlocks0.2.3Release=FALSE`
- `IndependentReviewOptionalQualityEnhancement=TRUE`
- `IndependentReviewIsSamplingReplication=FALSE`
- `NewDataGenerated=FALSE`
- `NewFitAttempted=FALSE`
- `ConQuestExecutionAttempted=FALSE`
- `LargeSimulationAuthorized=FALSE`
- `Candidate004RerunAuthorized=FALSE`
- `WiderP2Authorized=FALSE`
- `P3Authorized=FALSE`
- `ReleaseSpineUpdateAuthorized=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
