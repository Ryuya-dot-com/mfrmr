# ConQuest adversarial simulation engine-mechanics harness for mfrmr 0.2.3

Status: `ASP_G4H_harness_frozen_live_execution_closed`, 2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-engine-mechanics-harness-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_engine_mechanics_harness_v1`
- Completed gate: `ASP-G4H-ENGINE-MECHANICS-HARNESS-FREEZE`
- Next gate: `ASP-G4X-ENGINE-MECHANICS-EXECUTION`

## What is now frozen

The fail-closed harness consumes the retained G3 tables and the G4E scope
authorization without sampling a new response. A dry preparation in a temporary
directory reconstructed and semantically validated exactly 72 pre-execution
files. It launched neither engine and created no production validation result.

The plan retains the corrected G4-v2 denominator:

- 38 scheduled outcome rows over all 18 retained datasets;
- 30 q61 run-once attempts: 16 mfrmr and 14 ConQuest;
- 8 prefit outcome rows for 4 structural negative controls and zero attempted
  fits for those controls;
- 6 paired-missingness outcome rows, including the two explicit-missing mfrmr
  companions and two canonical ConQuest bridge outcomes;
- RSM and PCM expected free dimensions 10 and 14 respectively.

Each attempted unit has a unique directory and prefix. A 239-row possible
artifact registry covers six success artifacts plus a retained failure record
for each mfrmr attempt, eight native outputs plus a complete console for each
ConQuest attempt, and the fresh runtime-sentinel console. Artifact presence is
reported semantically; hashes and byte identity are not acceptance criteria.
The final review reconstructs this inventory from the actual filesystem,
requires the appropriate success/failure route for every attempted row and no
artifact for every unattempted row, and rejects unregistered files anywhere in
the output root.

## Input and representation controls

Every prepared input is reconstructed from the retained response relation and
then read back and compared as typed tabular data. ConQuest receives one
48-person by 12-response canonical wide table per attempt. mfrmr receives its
declared long representation and Person/X table. For paired missingness, the
planned-absence mfrmr input has 288 observed rows; the explicit-missing
companion has all 576 design rows with 288 missing responses; and the ConQuest
wide input has the same 288 observed and 288 missing cells.

Before preparation can pass, both paired datasets must pass all four semantic
bridge checks: observed response relation, exact missing-design complement,
canonical cell map, and rendered-wide semantic roundtrip. Changing one observed
response in either representation fails the bridge. No byte comparison is used.

## Fresh runtime and run-once boundary

Live execution remains explicit opt-in and is currently closed. When invoked,
the harness first validates that every possible output is absent, then launches
the exact `/Applications/ConQuest/ConQuest` path through x86_64/Rosetta with the
single command `quit;`. It records and semantically assesses the newly returned
console, program version, edition, expiry, architecture, terminal marker, exit
status, and registered failures. A prior or supplied transcript cannot satisfy
this route. Failure blocks every model attempt and retains 30 classified
unattempted rows.

Only a successful same-call sentinel activates the attempt loop. Both engine
paths have the frozen 600-second per-fit timeout; the phase has an eight-hour
wall-time cap and 2 GiB retained-storage cap. The journal is written before and
after each attempt. Any opened output consumes the bundle; rerun and automatic
retry are false.

The mfrmr path also requires the loaded namespace path to equal the normalized
working-tree root inferred from the retained G3 source location, in addition to
version 0.2.3 and the required internal bindings. A same-version installed copy
cannot silently substitute for the reviewed source tree.

## Failure independence

An ordinary failure cannot suppress its peer or companion. mfrmr errors,
ConQuest semantic failures, native-output parse failures, dimension mismatch,
nonfinite output, readiness holds, and individual timeouts are classified and
retained, after which the loop continues to the next prospectively scheduled
attempt. Only a failed fresh sentinel or the global wall/storage cap can stop
later attempts. A global stop materializes every remaining row as
`global_resource_abort_unattempted`.

This corrects an older diagnostic-harness pattern that stopped all ConQuest
work after an mfrmr failure or stopped a slice after one ConQuest failure. That
pattern is unsuitable for the paired unconditional denominator required here.

## Mechanics-only review

The harness may parse model dimension, finite required outputs, terminal state,
adapter coverage, and readiness status. It never computes cross-engine
coordinate or deviance differences. Its final review feeds only the sixteen
frozen G4 mechanics-accounting criteria. Even a fully passing mechanics result
leaves `CalibrationAuthorized=FALSE` and requires a separate review.

## Current state

- `HarnessFrozen=TRUE`
- `DryPreparationPassed=TRUE`
- `PreparedFileCount=72`
- `ScheduledOutcomeRows=38`
- `FitAttemptCap=30`
- `MfrmrFitAttemptCap=16`
- `ConQuestFitAttemptCap=14`
- `PossibleArtifactRows=239`
- `SemanticBridgeRows=8`
- `FreshRuntimeSentinelObserved=FALSE`
- `LiveExecutionAuthorized=FALSE`
- `LiveExecutionAttempted=FALSE`
- `AnyFitAttempted=FALSE`
- `ConQuestExecutionAttempted=FALSE`
- `NumericAgreementInspected=FALSE`
- `CalibrationAuthorized=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
