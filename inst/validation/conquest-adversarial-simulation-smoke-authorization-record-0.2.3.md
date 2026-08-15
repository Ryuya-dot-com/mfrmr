# ConQuest adversarial simulation smoke authorization for mfrmr 0.2.3

Status: `ASP_G3_smoke_contract_frozen_generation_authorized_not_run`,
2026-08-15.

- Specification:
  `0.2.3-conquest-adversarial-simulation-smoke-authorization-v1`
- Contract:
  `mfrmr_conquest_adversarial_simulation_smoke_authorization_v1`
- Current subgate: `ASP-G3-NONEVALUATIVE-SMOKE-GENERATION`

## Prospective separation

This record freezes the smoke design before any seeded response is generated
or opened. Authorization and execution are deliberately separate: otherwise a
seed, schema, DGP value, or mechanics rule could be altered after viewing the
same results it is meant to govern. This contract creates no randomness,
sampled response, fit, ConQuest process, parsed external output, or public
claim.

The exact smoke seeds are `987001` through `987018`, one for each of the nine
scenario classes crossed with RSM and PCM. They lie inside the reserved smoke
namespace `987000:987099`. Calibration and confirmation bands remain unfrozen
and must exclude that entire namespace. A seed is an experimental coordinate
for replay; matching seeded bytes is neither a correctness criterion nor
scientific evidence.

Every future smoke dataset is mechanics-only. It may check generation,
replay, required columns, primary keys, and structural prefit disposition. It
may not estimate failure rates, bias, RMSE, recovery, cross-engine superiority,
or scientific agreement; tune DGP values or thresholds; enter calibration or
confirmation; or support a public equivalence claim. If generated, every arm
must remain in the unconditional ledger regardless of failure or ineligibility.

## Output topology

Six tables are frozen before execution:

1. `dataset_manifest`: one row per independently generated dataset;
2. `response_data`: one declared response opportunity per representation;
3. `structural_disposition`: expected and observed prefit disposition;
4. `engine_outcome`: one dataset-by-engine attempt or explicit non-attempt;
5. `metric_outcome`: one dataset-by-metric-engine-coordinate result; and
6. `continuous_oracle`: one dataset-by-engine-quadrature result.

The schema retains failed, ineligible, structurally rejected, and unattempted
rows. Conditional numeric and oracle rows require unconditional companion
counts. All twelve ASP metric layers map to a table, but none may be estimated
as an operating characteristic from smoke. Only structural disposition and
execution mechanics are active at smoke; their observed values cannot change
the frozen DGP or later decision rules.

## Algebraic and continuous qualification

The direct cumulative-step and reconstructed-A probability paths were reduced
to category-specific intercept and theta coefficients for four profiles,
RSM/PCM, four Raters, three Criteria, and four categories. Across 384
coefficients, the maximum observed coefficient difference is
`4.44089209850063e-16`. Equality of the coefficients establishes equality of
the log kernels for every finite theta, avoiding a slow duplicate numerical
integration path.

The optimized compiled integrand was then checked against the original G2
direct implementation at five latent values for every Person in complete and
rare-boundary RSM/PCM. Across 192 Persons and 960 evaluations, the maximum
absolute difference is `1.4210854715202e-14`.

Finally, all 48 Persons in each of those four deterministic prototype arms
were integrated: 192 Person integrals and 1,728 observed rows. Every mode is
interior and every integration reports convergence. The maximum arm-level
declared deviance-error envelope is `1.75458265678942e-10`, below the frozen
`1e-8` mechanics threshold. Its quadrature component remains a numerical error
estimate rather than a proof; only the omitted normal-tail component has an
analytic upper-bound interpretation. Prototype responses qualify mechanics
only and are not sampled simulation data.

## Authorization boundary

Successful review permits a later execution record to generate exactly one
seeded smoke dataset for each of the eighteen arms. It does not itself generate
those datasets. It also does not authorize mfrmr fitting, ConQuest execution,
calibration, confirmation, or inference. The execution record must consume the
frozen seeds and schema without revision and retain all generated arms.

Four later design blockers remain:

1. calibration seed band;
2. untouched confirmation seed band;
3. metric-specific precision targets and replication counts; and
4. sequential stop/expand/abort rules plus runtime and storage caps.

## Current authorization state

- `G2ExactDGPPrerequisiteFrozen=TRUE`
- `G3AuthorizationComplete=TRUE`
- `G3SmokeExecutionComplete=FALSE`
- `G3Complete=FALSE`
- `SmokeSeedBandFrozen=TRUE`
- `OutputSchemaFrozen=TRUE`
- `FullPersonContinuousOracleQualified=TRUE`
- `AlgebraicCoefficientIdentityQualified=TRUE`
- `SmokeResultsOpened=FALSE`
- `SmokeOperatingCharacteristicsPermitted=FALSE`
- `AuthorizedSmokeDatasets=18`
- `MaximumDatasetsPerArm=1`
- `SmokeDatasetGenerationAuthorized=TRUE`
- `AnySampledResponseGenerated=FALSE`
- `AnyFitAuthorized=FALSE`
- `ConQuestExecutionAuthorized=FALSE`
- `CalibrationSeedBandFrozen=FALSE`
- `ConfirmationSeedBandFrozen=FALSE`
- `MetricPrecisionAndReplicationCountsFrozen=FALSE`
- `SequentialAndResourceRulesFrozen=FALSE`
- `RemainingGenerationBlockers=4`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
