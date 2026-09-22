# ConQuest adversarial simulation smoke execution for mfrmr 0.2.3

Status: `ASP_G3_eighteen_smoke_datasets_generated_and_retained`, 2026-08-15.

- Specification:
  `0.2.3-conquest-adversarial-simulation-smoke-execution-v1`
- Contract: `mfrmr_conquest_adversarial_simulation_smoke_execution_v1`
- Completed gate: `ASP-G3-NONEVALUATIVE-SMOKE`
- Next gate: `ASP-G4-CALIBRATION-FREEZE`
- Retained local output:
  `validation-results/conquest-adversarial-simulation-smoke-20260815-v1`

## Prospective execution

The seed and schema authorization was committed before generator execution.
The generator itself was then committed as `34a8973` before any complete smoke
dataset set was opened. It consumes the frozen seeds `987001:987018`, restores
the caller RNG state, generates latent values and responses without reading the
prototype response vector, and rejects an existing output target. It contains
no mfrmr fit or external process launch.

The retained output contains the six frozen CSV tables plus one RDS container:

1. `dataset_manifest.csv`;
2. `response_data.csv`;
3. `structural_disposition.csv`;
4. `engine_outcome.csv`;
5. `metric_outcome.csv`;
6. `continuous_oracle.csv`; and
7. `smoke_result.rds`, a container for the same six tables and execution
   metadata.

These are local ignored validation results rather than public package data.
The review uses semantic keys and values, not file hashes or byte identity.

## Complete accounting

Exactly eighteen unique `DatasetId` and eighteen unique scenario-family arms
were generated and retained, one per frozen seed. The response table has 7,032
rows: 5,880 primary design rows plus 1,152 explicit-missing companion rows for
the two paired-missingness arms. The retained companion responses equal their
planned-absence counterparts on every observed Person-Rater-Criterion key.

All fourteen positive or sensitivity arms satisfy full-rank and declared-
category support mechanics. All four negative-control arms receive their
prospectively expected prefit rejection: two unused-intermediate-category arms
for category support, and two disconnected arms for full population-location
predictor rank. This is a structural mechanics check, not a failure-rate or
recovery estimate. All eighteen arms remain in the unconditional denominator.

No complete prototype response vector was reused. Every primary response is in
`0:3`; every generated uniform is strictly inside `(0,1)`; missing companion
responses and their response uniforms are `NA`; and manifest row, Person, and
category counts reconcile to response rows. Each dataset has two explicit
engine non-attempt rows, twelve non-evaluated metric rows, and two non-evaluated
continuous-oracle rows. Consequently there are 36 engine rows, 216 metric rows,
36 continuous rows, and zero fit attempts.

## Retained incidents

The first command stopped before creating either the target or staging
directory because a stale rank-field adapter requested `Rank` while the frozen
G1 audit exposes `RankAt1e10`. The adapter was corrected to the existing field;
no seed, DGP value, support rule, disposition rule, or output schema changed.
The same fixed seed identities therefore remain the only smoke sampling units.

The subsequent command generated and atomically retained all eighteen arms.
Its first post-write review reported a replay mismatch solely because lossless
CSV type inference read the `X=-1/1` column as integer whereas the in-memory
generator represented it as double. Column-by-column review showed identical
keys and values and numeric agreement at the frozen tolerance. The reviewer was
changed from R storage-type identity to value-level semantic equality with
zero tolerance for key coordinates. The saved results were neither deleted nor
regenerated. A strengthened review then validated the CSV tables, RDS
container, row-level response semantics, per-arm atomic counts, and replay.

These incidents are implementation-mechanics evidence. They cannot be omitted
from the smoke history, but neither incident supplies evidence about model
agreement or operating characteristics.

## Interpretation boundary

The smoke results may establish only generation, replay, schema, primary-key,
representation, and structural-prefit mechanics. Category counts were used
only to verify declared support. They were not used to tune the DGP, choose a
threshold, estimate bias or RMSE, compare engines, or choose calibration size.

Calibration remains unopened. G4 must prospectively freeze its disjoint seed
band, failure taxonomy, permitted exploratory summaries, and runtime/storage
cap before any calibration response is generated. ConQuest and mfrmr execution
also require a separate authorization boundary.

## Current state

- `FilesComplete=TRUE`
- `TablesValid=TRUE`
- `ContainerValid=TRUE`
- `SemanticReplayMatch=TRUE`
- `GeneratedDatasets=18`
- `UniqueArms=18`
- `ResponseTableRows=7032`
- `StructuralDispositionsMatch=TRUE`
- `EligibleStructuralArms=14`
- `RejectedStructuralArms=4`
- `PrototypeResponseVectorsReused=0`
- `RetainedUnconditionalArms=18`
- `FitAttempts=0`
- `ConQuestExecutionAttempted=FALSE`
- `OperatingCharacteristicsEstimated=FALSE`
- `ResultUsedToTuneDesign=FALSE`
- `G3SmokeExecutionComplete=TRUE`
- `G3Complete=TRUE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
