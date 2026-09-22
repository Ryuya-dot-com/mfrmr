# ConQuest adversarial simulation calibration freeze for mfrmr 0.2.3

Status: `ASP_G4_calibration_contract_frozen_execution_closed`, 2026-08-15.

- Specification:
  `0.2.3-conquest-adversarial-simulation-calibration-freeze-v2`
- Contract:
  `mfrmr_conquest_adversarial_simulation_calibration_freeze_v2`
- Completed gate: `ASP-G4-CALIBRATION-FREEZE`
- Next gate: `ASP-G4E-ENGINE-MECHANICS-SMOKE-AUTHORIZATION`

## Why calibration does not run next

Before any engine-mechanics or calibration result was generated or opened, an
adversarial reread found that v1 scheduled only one mfrmr fit for each paired
planned-absence/explicit-missing dataset. That could not test mfrmr's two
representation paths against each other. Version 2 prospectively adds the
explicit-missing mfrmr companion fit. It does not duplicate the ConQuest fit:
both representations map to the same frozen canonical wide-missing ConQuest
input, so the one ConQuest outcome is accompanied by an explicit bridge check.
This correction is result-independent and changes no DGP, seed, numerical
threshold, or observed result; no such result existed when it was made.

G3 established response generation, semantic replay, table shape, and expected
prefit disposition for one retained dataset in each of eighteen arms. It did
not exercise either model-fitting path. Opening as many as 450 new calibration
datasets before testing those paths would multiply an adapter or command error
and could confuse implementation mechanics with scientific failure.

G4 therefore inserts a bounded engine-mechanics prerequisite. A later,
separately authorized run may use the already retained G3 datasets once. The
four expected structural negative controls remain prefit stops. Each of the
fourteen eligible datasets has one q61 mfrmr attempt and one q61 ConQuest
attempt. The two eligible paired-missingness datasets additionally have one
q61 explicit-missing mfrmr companion attempt, for a hard cap of 30 attempts and
38 retained dataset-engine-representation outcome rows. An ordinary failure in
one engine or representation cannot suppress another scheduled attempt;
the paired paths retain six outcomes in total, and the two canonical ConQuest
outcomes each retain their bridge check. Only a global safety/resource abort
may suppress later work. These results remain mechanics-only and cannot enter
calibration or confirmation.

Mechanics completion requires all 18 datasets, 38 outcome rows, and 30 attempt
outcomes to remain accounted for; all four negatives must reject with zero fit
attempts; and no eligible peer or companion attempt may be suppressed. It does
not require all 30 fits to succeed. It requires at least one semantically complete,
parseable q61 result in each of the four engine-by-family cells so that both
adapters and both model identities have actually been exercised, plus a
parseable explicit-missing mfrmr outcome and a canonical ConQuest bridge check
in each family. Fit quality, representation invariance, or cross-engine
numerical proximity is not a mechanics criterion.

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
Every eligible paired-missingness dataset also receives the q61
explicit-missing mfrmr companion fit; its planned-absence form receives the
ordinary mfrmr fit, while both forms share one canonical wide-missing ConQuest
fit and a recorded bridge check rather than a scientifically empty duplicate.
Expected or unexpected structural rejection stops both engines before fitting
that dataset and remains in the unconditional ledger.

This gives the following exact maximum workloads:

| stage | new datasets | q61 fits | selective q121 fits | fit attempts | retained outcome rows |
| --- | ---: | ---: | ---: | ---: | ---: |
| G3 engine mechanics | 0 (18 retained) | 30 | 0 | 30 | 38 |
| calibration tranche A | 90 | 150 | 40 | 190 | 230 |
| full calibration | 450 | 750 | 200 | 950 | 1,150 |

There is one attempt per scheduled
dataset-engine-representation-quadrature cell and no automatic retry.
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
all 90 datasets and all 230 scheduled outcome rows, all 20 negative controls
reject before fitting, no negative-control fit occurs, no generator/schema,
seed/DGP, systemic-adapter, sentinel, or global-abort defect occurs, and all
ten paired-missingness datasets retain their 30 scheduled outcomes, all ten
explicit-missing mfrmr attempts and ten ConQuest bridge checks are accounted
for without a representation-adapter failure, and all eight
engine-family-quadrature workload cells support a resource projection.
The projection method is frozen: within each of those eight cells, the maximum
retained elapsed seconds and artifact bytes are multiplied by that cell's full
planned attempt count; the maximum per-dataset generation time and retained
bytes are separately multiplied by 450; the components are then summed. The
result must remain within 80% of both full caps. Passing this operational gate
does not itself authorize tranche B.

A paired bridge check passes only when all four frozen semantic checks pass:
the observed response relations agree after typed-key sorting; explicit
missing keys are exactly the frozen-design complement of planned-absence
keys; expanding either representation against the design gives the same
typed key/observed-mask/response cell map; and parsing the rendered ConQuest
input reproduces that map. File bytes are not an acceptance criterion. A
bridge mismatch is retained as `representation_bridge_mismatch` under the
primary terminal class `generation_or_schema_failure` and stops that dataset
before fitting.

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
the mfrmr planned-absence-versus-explicit-missing coordinate/deviance summary
and engine-family-quadrature runtime and retained-storage summaries. Conditional
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
- `PairedMissingnessWorkloadCorrectedBeforeEngineExecution=TRUE`
- `NoEngineOrCalibrationResultsOpenedBeforeCorrection=TRUE`
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
