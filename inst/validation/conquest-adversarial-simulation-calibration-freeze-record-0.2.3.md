# ConQuest adversarial simulation calibration freeze for mfrmr 0.2.3

Status: `ASP_G4_calibration_contract_frozen_execution_closed`, 2026-08-15.

- Specification:
  `0.2.3-conquest-adversarial-simulation-calibration-freeze-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_calibration_freeze_v1`
- Completed gate: `ASP-G4-CALIBRATION-FREEZE`
- Next gate: `ASP-G4E-ENGINE-MECHANICS-SMOKE-AUTHORIZATION`

## Why calibration does not run next

G3 established response generation, semantic replay, table shape, and expected
prefit disposition for one retained dataset in each of eighteen arms. It did
not exercise either model-fitting path. Opening as many as 450 new calibration
datasets before testing those paths would multiply an adapter or command error
and could confuse implementation mechanics with scientific failure.

G4 therefore inserts a bounded engine-mechanics prerequisite. A later,
separately authorized run may use the already retained G3 datasets once. The
four expected structural negative controls remain prefit stops. Each of the
fourteen eligible datasets has one q61 mfrmr attempt and one q61 ConQuest
attempt, for a hard cap of 28 attempts and 36 retained dataset-engine outcome
rows. An ordinary failure in one engine cannot suppress the peer-engine
attempt; only a global safety/resource abort may do so. These results remain
mechanics-only and cannot enter calibration or confirmation.

Mechanics completion requires all 18 datasets, 36 outcome rows, and 28 attempt
outcomes to remain accounted for; all four negatives must reject with zero fit
attempts; and no eligible peer attempt may be suppressed. It does not require
all 28 fits to succeed. It requires at least one semantically complete,
parseable q61 result in each of the four engine-by-family cells so that both
adapters and both model identities have actually been exercised. Fit quality
or cross-engine numerical proximity is not a mechanics criterion.

This freeze authorizes neither that engine smoke nor calibration generation.

## Disjoint seed allocation

Calibration owns namespace `988000:989999`; the frozen seed formula is
`988000 + 100 * ArmIndex + Replicate`. Eighteen arm indices and replicates
1--25 therefore define exactly 450 unique identities, from `988101` through
`989825`. None overlaps smoke seeds `987001:987018`.

- Tranche A is replicates 1--5: 90 datasets, including 70 structurally
  eligible datasets and 20 expected negative controls.
- Tranche B is replicates 6--25: 360 additional datasets.
- Full calibration is at most 25 replicates per arm: 450 datasets, including
  350 structurally eligible datasets and 100 expected negative controls.

All generated identities and failures must be retained. Calibration rows may
inform only a later confirmation design; no smoke or calibration row may be
reused as a confirmation sampling unit. Confirmation seeds remain unfrozen.

## Frozen fit workload

The primary fit is q61 for both engines in every structurally eligible RSM and
PCM dataset. q121 is a numerical-sensitivity fit only for the prospectively
selected complete and rare-boundary-category scenarios in both families.
Expected or unexpected structural rejection stops both engines before fitting
that dataset and remains in the unconditional ledger.

This gives the following exact maximum workloads:

| stage | new datasets | q61 fits | selective q121 fits | fit attempts | retained outcome rows |
| --- | ---: | ---: | ---: | ---: | ---: |
| G3 engine mechanics | 0 (18 retained) | 28 | 0 | 28 | 36 |
| calibration tranche A | 90 | 140 | 40 | 180 | 220 |
| full calibration | 450 | 700 | 200 | 900 | 1,100 |

There is one attempt per dataset-engine-quadrature cell and no automatic retry.
The model identities remain additive Rater plus Criterion with shared steps for
RSM and Criterion-specific steps for PCM, each with population regression on
`X`. Expected free dimensions remain 10 and 14 respectively.

## Runtime and resource boundary

ConQuest is bound to `/Applications/ConQuest/ConQuest`, self-reported version
5.47.5 Demonstration Version, thin x86_64 execution through
`/usr/bin/arch -x86_64`, and reported expiry 2026-09-01. Every execution
session requires a fresh data-free semantic sentinel before any new
calibration response is generated. The frozen run-not-after date is
2026-08-31. Runtime replacement, renewal, version drift, or route drift needs a
new authorization addendum but cannot change seeds, DGP values, metrics, or
denominators.

Each fit has a 600-second timeout. Engine mechanics and tranche A each have an
eight-hour cumulative wall-time cap and a 2 GiB retained-storage cap. Full
calibration has a 36-hour cap and an 8 GiB cap. Hitting a global cap stops new
work and requires explicit unattempted rows; it does not permit deletion or
silent retry.

Tranche B can reach a separate authorization review only if tranche A retains
all 90 datasets and all 220 scheduled outcome rows, all 20 negative controls
reject before fitting, no negative-control fit occurs, no generator/schema,
seed/DGP, systemic-adapter, sentinel, or global-abort defect occurs, and all
eight engine-family-quadrature workload cells support a resource projection.
The projection method is frozen: within each of those eight cells, the maximum
retained elapsed seconds and artifact bytes are multiplied by that cell's full
planned attempt count; the maximum per-dataset generation time and retained
bytes are separately multiplied by 450; the components are then summed. The
result must remain within 80% of both full caps. Passing this operational gate
does not itself authorize tranche B.

## Failure and summary semantics

Each retained outcome receives one terminal code under an ordered taxonomy,
with lower-level ConQuest messages retained as secondary codes, line numbers,
and matched text. Both regex-detected messages and synthetic host/runtime codes
such as missing executables, nonzero exits, incomplete output sets, and expiry
by date have an explicit primary mapping. Expected structural rejection is a
successful negative-control disposition, not an engine failure. Runtime
expiry, timeout, process,
terminal-marker, registered semantic, native-output, parser, model-identity,
optimizer, nonfinite, estimability, and continuous-oracle outcomes remain
distinct. No failed or ineligible row may be dropped.

Permitted calibration summaries are scenario-class-by-family structural,
engine, joint-eligibility, truth-error, independent-oracle, bias, RMSE,
cross-engine, q-sensitivity, and false-ready/false-pass summaries, plus
engine-family-quadrature runtime and retained-storage summaries. Conditional
numeric summaries require their frozen unconditional companions. Pooled
results are not a primary analysis.

Calibration may not select a DGP, metric threshold, confirmation decision
rule, or public claim. In particular, favorable or unfavorable numerical
agreement has no stop, expansion, retry, deletion, or tuning effect.
Uncertainty coverage remains deferred until its common estimand and interval
rule are proven.

## Current state

- `G3PrerequisiteComplete=TRUE`
- `G4CalibrationFreezeComplete=TRUE`
- `CalibrationSeedBandFrozen=TRUE`
- `FailureTaxonomyFrozen=TRUE`
- `PermittedExploratorySummariesFrozen=TRUE`
- `SequentialAndResourceRulesFrozen=TRUE`
- `EngineMechanicsPrerequisiteFrozen=TRUE`
- `EngineMechanicsExecutionAuthorized=FALSE`
- `CalibrationResponseGenerationAuthorized=FALSE`
- `CalibrationExecutionAuthorized=FALSE`
- `CalibrationResultsOpened=FALSE`
- `ConfirmationSeedBandFrozen=FALSE`
- `AnySampledResponseGenerated=FALSE`
- `AnyFitAttempted=FALSE`
- `ConQuestExecutionAttempted=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
