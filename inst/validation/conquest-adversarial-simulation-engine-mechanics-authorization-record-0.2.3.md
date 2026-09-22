# ConQuest adversarial simulation engine-mechanics authorization for mfrmr 0.2.3

Status:
`ASP_G4E_engine_mechanics_scope_authorized_live_sentinel_pending`,
2026-08-16.

- Specification:
  `0.2.3-conquest-adversarial-simulation-engine-mechanics-authorization-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_engine_mechanics_authorization_v1`
- Execution identity: `mfrmr-0.2.3-conquest-asp-engine-mechanics-001`
- Completed gate: `ASP-G4E-ENGINE-MECHANICS-SMOKE-AUTHORIZATION`
- Next gate: `ASP-G4H-ENGINE-MECHANICS-HARNESS-FREEZE`

## Decision

The narrow mechanics scope is authorized for harness preparation. Live
execution is not. A future fail-closed harness must observe a fresh data-free
ConQuest semantic sentinel in the same execution session before the first
model attempt. This authorization neither replays an old console transcript as
fresh evidence nor launches ConQuest itself.

The authorization semantically revalidated the retained G3 output at
`validation-results/conquest-adversarial-simulation-smoke-20260815-v1`.
All eighteen datasets, 7,032 response-representation rows, eighteen structural
dispositions, and the lossless retained container passed the frozen replay and
schema checks. No fit existed in that source. File bytes and digests are not
scientific acceptance criteria.

## Exact bounded scope

The corrected G4-v2 denominator is authoritative:

- 18 retained G3 datasets; no new response sampling or retained output
  generation beyond deterministic semantic replay of the frozen G3 seeds;
- 38 scheduled outcome rows, all retained;
- 30 q61 fit attempts, each run at most once;
- 4 structural negative-control datasets represented by 8 prefit outcome rows
  and exactly 0 fit attempts;
- 14 eligible datasets with one mfrmr and one ConQuest attempt;
- 2 paired-missingness datasets with one additional explicit-missing mfrmr
  companion, giving 6 paired outcome rows;
- 2 canonical ConQuest wide-missing outcomes, each backed by the four-part
  semantic bridge rather than by a duplicate ConQuest fit.

An ordinary failure, timeout, or parse failure cannot suppress the peer engine
or paired companion. Only the global wall-time/storage safety abort can stop
later attempts, and every stopped attempt must remain as an explicit
unattempted outcome. Automatic retry is forbidden.

## Representation bridge

For each paired dataset, all four checks must pass before fitting:

1. observed response relations agree after typed Person/Rater/Criterion key
   sorting;
2. explicit missing keys are exactly the frozen-design complement of the
   planned-absence keys;
3. expanding either representation gives the same typed
   key/observed-mask/response cell map;
4. parsing the rendered ConQuest input reproduces that canonical cell map.

This is semantic equivalence, not byte equality. A failure is retained as
secondary code `representation_bridge_mismatch` under primary terminal class
`generation_or_schema_failure` and stops that dataset before fitting.

## Runtime and resource boundary

The only permitted external runtime remains
`/Applications/ConQuest/ConQuest`, ConQuest 5.47.5 Demonstration Version,
x86_64 through `/usr/bin/arch -x86_64`, with reported expiry 2026-09-01.
The authorization may be consumed no later than 2026-08-31. Runtime identity,
expiry, and the complete semantic failure registry must be checked again by a
fresh same-session sentinel; the prospective runtime contract is not itself a
live observation.

The mechanics slice has an eight-hour cumulative wall-time cap, a 2 GiB
retained-storage cap, and a 600-second per-fit timeout inherited from G4-v2.
The exact output root must be new and absent:
`conquest-adversarial-simulation-engine-mechanics-20260816-v1`.
No overwrite, retry, alternate executable, or widened output boundary is
authorized.

## Lossless output contract

Nine tables are frozen: authority snapshot, retained-source audit, eight-row
representation-bridge audit, 38-row execution plan, 30-row attempt journal,
38-row engine outcome, 30-row attempt-artifact inventory, resource summary,
and execution summary. Their closed-run denominator is 154 rows. Failure and
unattempted rows are mandatory; numeric-agreement columns are forbidden.

The mechanics completion audit may examine only accounting, semantic runtime,
adapter/parser coverage, model identity, representation bridge completion, and
resource state. It may not inspect coordinate differences, deviance proximity,
fit favorability, or any other cross-engine scientific result. Passing
mechanics requires a later separate calibration authorization review.

## Why no independent review is required here

G4E is a reversible, noninterpretive scope decision with exact denominators and
fail-closed gates. It does not promote evidence or decide equivalence. Requiring
an independent comprehensive review before this mechanics check would delay the
highest-information next step without reducing an interpretive risk, because
interpretation is explicitly unavailable. Independence remains a separate
question for later evidence promotion, not a proxy for basic adapter testing.

## Current state

- `AllNineteenFatalGatesPassed=TRUE`
- `EngineMechanicsScopeAuthorized=TRUE`
- `HarnessPreparationAuthorized=TRUE`
- `LiveExecutionAuthorized=FALSE`
- `FreshRuntimeSentinelObserved=FALSE`
- `FreshRuntimeSentinelRequiredAtExecution=TRUE`
- `NewResponseGenerationAuthorized=FALSE`
- `FitAttemptCap=30`
- `RetainedOutcomeRowCap=38`
- `NumericAgreementInspectionAuthorized=FALSE`
- `CalibrationGenerationAuthorized=FALSE`
- `CalibrationExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `AnyFitAttempted=FALSE`
- `ConQuestExecutionAttempted=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
