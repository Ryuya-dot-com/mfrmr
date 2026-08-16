# ConQuest calibration-harness P1 plan record for mfrmr 0.2.3

Status: `ASP_G4C_P1_plan_schema_frozen_integrated_harness_incomplete`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-calibration-harness-v1-p1`
- Contract under construction:
  `mfrmr_conquest_adversarial_simulation_calibration_harness_v1`
- Completed subgate: `ASP-G4C-P1-PLAN-SCHEMA-LEDGERS`
- Next subgate: `ASP-G4C-P2-DETERMINISTIC-GENERATION-AND-BRIDGE`

## Decision

Freeze the complete tranche-A outcome plan before implementing or invoking any
response generator or engine adapter. G4C is not complete.

P1 converts the 90 frozen tranche-A seed rows into all 230 scheduled outcome
rows and all 190 possible fit attempts. This prevents a later generator,
engine failure, numerical result, or resource abort from deciding which rows
exist. The outcome denominator is now an input to execution rather than an
output of execution.

## Exact plan

The plan contains:

- 90 independent dataset IDs and seeds;
- 230 scheduled outcome rows with unique order 1--230;
- 190 attempted-fit slots with unique order 1--190;
- 100 mfrmr and 90 ConQuest attempt slots;
- 150 q61 and 40 q121 attempt slots;
- 20 expected-negative datasets represented by 40 retained prefit-stop rows;
- 10 paired-missingness datasets with two mfrmr representation rows and one
  canonical ConQuest bridge row;
- 90 cross-engine pair IDs, each appearing exactly twice;
- 40 engine-specific q61/q121 pair IDs, each appearing exactly twice; and
- 10 mfrmr representation pair IDs, each appearing exactly twice.

The explicit-missing mfrmr companion is excluded from primary truth and
cross-engine denominators, preventing one dataset from being counted twice.
It remains present in the unconditional outcome ledger and the dedicated
representation-invariance denominator.

Every row fixes family, engine, quadrature, representation role, expected free
dimension, expected model identity, structural disposition, G4N contract,
pairing keys, and failure-retention rules. Peer failure cannot suppress an
attempt, automatic retry is forbidden, and numerical results cannot alter
attempt order.

## Pre-execution schema

Fourteen result tables are registered. The generation journal has 90 empty
rows, the attempt journal has 190 empty rows, and the engine-outcome ledger has
all 230 rows before any fit. The 40 negative-control outcomes are already typed
`expected_structural_rejection`; the other 190 outcomes remain
`pending_not_executed`.

No row is droppable and results cannot change table schema. Conditional metric
use, confirmation use, and public claims are false in every empty ledger row.

## Adversarial checks

Tests reject duplicated scheduled order, a dropped attempt, a missing
cross-engine pair member, promotion of an invariance companion into a primary
truth denominator, retry permission, peer suppression, result-driven attempt
ordering, response-generation authority, or execution authority. Pair tests
also require exact engine, q, dataset, family, and representation membership;
matching a string label alone is insufficient.

P1 advances the G4A executable-capability count from five to six by providing
the exact plan materializer under the calibration-harness contract identity.
Twelve integrated capabilities remain missing.

## Deliberate incompleteness

P1 does not implement or pretend to implement:

- deterministic response generation;
- the four semantic bridge checks on generated paired data;
- mfrmr or ConQuest q61/q121 adapters;
- fresh-sentinel same-process execution;
- artifact inventory and unexpected-file rejection;
- per-fit/global resource control and unattempted-row finalization;
- prospective G4N application;
- conditional and unconditional metric summaries;
- target-bound authorization consumption; or
- retained execution review.

These remain separate G4C subgates. In particular, the presence of the final
harness contract name does not mean that the integrated harness is ready; the
capability audit still reports twelve missing providers.

## Current state

- `ScheduledOutcomeRows=230`
- `PlannedFitAttempts=190`
- `MfrmrAttempts=100`
- `ConQuestAttempts=90`
- `Q61Attempts=150`
- `Q121Attempts=40`
- `CrossEnginePairs=90`
- `QuadraturePairs=40`
- `RepresentationPairs=10`
- `UpstreamAndHarnessCapabilitiesAvailable=6`
- `HarnessCapabilitiesStillMissing=12`
- `ExactOutcomeLedgerMaterializationReady=TRUE`
- `DeterministicGenerationImplemented=FALSE`
- `EngineAdaptersImplemented=FALSE`
- `FinalizerAndMetricSummaryImplemented=FALSE`
- `ResponseGenerationAuthorized=FALSE`
- `ExecutionAuthorized=FALSE`
- `FreshTrancheASentinelObserved=FALSE`
- `NumericAgreementInspected=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
