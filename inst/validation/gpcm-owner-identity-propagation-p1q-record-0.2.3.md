# GPCM owner-identity propagation P1q record (0.2.3)

## Question

P1q asks whether the completed Draft.66 owner-specific pilot can support the
current GPCM owner claim merely because all 120 rows ran, and whether any
identity-propagation defect requires more simulation. It performs no fitting,
changes no frozen artifact, freezes no threshold, and authorizes no public
promotion.

## Historical evidence boundary

The sealed Draft.66 bundle is one valid historical execution:

- execution SHA-256:
  `f96895c9325e15390c5fd896a687a47cf786f6b4f71af94c3481753991e38037`;
- runner SHA-256 used for that execution:
  `b71ee33aa39d07431f43505d70dc531f0abb9db2529ff9a433ea74b4b1dbfb16`;
- execution-contract SHA-256:
  `54d52c6a05b3fe98c0d19b54a66df8c8a83b21785f63a2300495f415f7733879`;
- 120 declared rows, 120 result rows, and 120 readable checkpoints;
- separate Criterion/JML, Criterion/MML, Rater/JML, and Rater/MML strata;
- one latent dimension, equal step and slope owners, and
  `single_owner_relative_gm1` slope composition.

Every manifest row, result row, and checkpoint payload retains the historical
slope owner, step owner, slope composition, dimension, estimator, ability-
scale, and runtime identity. All 120 checkpoint schemas and execution
identities agree with the sealed execution; all 120 row-manifest and result
payload hashes reproduce, and their scenario and identity fields agree.

This does not make the run current-default MML evidence. Its MML rows declare
`standard_normal_latent_distribution`. The historical runner did not pass
`gpcm_mml_identification` explicitly and its fitted-object identity check
examined the slope and step owners, not the ability-scale contract. The
runtime hash made the completed run interpretable at that time, but replaying
the same source under today's package default would fit a different scale
contract. The current default is `free_population`.

## Direct propagation audit

P1q inspected nine frozen tabular surfaces. None directly contains the full
identity, chiefly because exact declared category support is not represented
as `RatingMin`, `RatingMax`, and `DeclaredCategorySupport` columns.

| Surface | Rows | Historical identity fields present / 7 | Exact support direct | Full direct identity |
| --- | ---: | ---: | --- | --- |
| declared manifest | 120 | 7 | no | no |
| selected manifest | 120 | 7 | no | no |
| results | 120 | 7 | no | no |
| global summary | 1 | 0 | no | no |
| rate summary | 24 | 2 | no | no |
| numeric summary | 24 | 2 | no | no |
| execution identity | 1 | 1 | no | no |
| execution policy | 1 | 0 | no | no |
| checkpoint ledger | 120 | 0 | no | no |

Likewise, zero of 120 checkpoint manifest/result pairs directly contains the
three exact-support fields. A hash pointer to another artifact is valuable for
integrity, but it is not the same as each exported aggregate being
self-describing about the model it summarizes.

## Non-mutating derived envelope

P1q therefore constructs a derived identity envelope rather than editing the
sealed bundle. It accepts only the exact Draft.66 execution SHA, verifies
120-row manifest/result identity, and builds four owner/estimator registry
rows. The declared 1--4 support is recovered from the sealed execution
contract and carries that contract hash as provenance.

The envelope binds full identity fields to seven derived surfaces: results,
global summary, rate summary, numeric summary, execution identity, execution
policy, and checkpoint ledger. All seven pass complete-field checks. The
global aggregates expand to the four registered model strata and carry the
identity-registry SHA. The original bundle remains unchanged, and the
envelope explicitly records `substantive_evidence_added = FALSE`.

This repairs evidence transport only. It cannot turn historical fixed-
standard-normal MML results into current `free_population` results, improve
recovery, supply interval coverage, or pass a release gate.

## Current public path

The current package is better protected than the historical pilot runner:

- `fit_mfrm()` defaults GPCM MML to `free_population` and records
  `gpcm_mml_identification` in `replay_inputs`;
- replay generation emits `gpcm_mml_identification` explicitly;
- replay generation also retains resolved rating bounds; and
- current summary/settings surfaces report step owner, slope owner, GPCM MML
  identification, rating bounds, and population-scale role.

Thus no production replay fix is indicated by P1q. The remaining gap is the
evidence lineage: the existing 120-row run must be labelled historical, and a
future owner-specific run for the current default must declare its
identification branch explicitly before fitting.

## Portfolio decision

```text
HistoricalPilotMMLAbilityScale = standard_normal_latent_distribution
CurrentDefaultMMLAbilityScale = free_population
HistoricalRowIdentityRetained = TRUE
HistoricalCheckpointIdentityRetained = TRUE
FrozenDirectPropagationComplete = FALSE
DerivedEnvelopePropagationComplete = TRUE
HistoricalPilotRepresentsCurrentDefaultMML = FALSE
CurrentPublicReplayRetainsIdentification = TRUE
IdentityPropagationRequiresAdditionalSimulation = FALSE
CurrentDefaultOwnerEvidenceStillRequired = TRUE
OwnerEvidenceGatePass = FALSE
GPCMCorePromotionAuthorized = FALSE
BroadSimulationAuthorized = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

The result narrows, rather than enlarges, the next task. Before any expanded
replication, a prospective owner-evidence contract must make the ability-scale
branch and exact category support explicit in every row, checkpoint, aggregate,
and replay. A small paired common-data smoke may then test Criterion and Rater
owners under the current default. Only a decision-relevant failure or an
unresolved precision question would justify more replication.

## Reproduction

- runner:
  `inst/validation/gpcm-owner-identity-propagation-p1q-0.2.3.R`;
- routine and opt-in test:
  `tests/testthat/test-gpcm-owner-identity-propagation-p1q.R`;
- stored result: `/tmp/mfrmr-p1q-result-v1.rds` (local, not release evidence);
- runner SHA-256:
  `8216884cb08948ae3be3b4134dacc07bcb88a635a6c96dce7e25f26d793dea73`;
- test SHA-256:
  `f3a6dd15bafefa2b31364282153191b86c096dc7880843cfba34f129a9695fed`.

The stored Draft.66 audit is opt-in through
`MFRMR_RUN_P1Q_PILOT=true` and `MFRMR_P1Q_BUNDLE_DIR=<bundle directory>`.
Routine tests use a synthetic 120-row schema fixture, verify fail closure for
the wrong execution SHA, and scan the historical and current source contracts.
