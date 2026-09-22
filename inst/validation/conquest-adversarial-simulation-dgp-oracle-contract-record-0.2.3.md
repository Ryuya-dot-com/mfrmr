# ConQuest adversarial simulation DGP and oracle contract for mfrmr 0.2.3

Status: `ASP_G2_exact_DGP_and_separated_oracles_complete_execution_closed`,
2026-08-15.

- Specification:
  `0.2.3-conquest-adversarial-simulation-dgp-oracle-contract-v1`
- Contract: `mfrmr_conquest_adversarial_simulation_dgp_oracle_contract_v1`
- Completed gate: `ASP-G2-DGP-ORACLE-SEPARATION`
- Next gate: `ASP-G3-NONEVALUATIVE-SMOKE`

## Exact DGP profiles

Four profiles are frozen. All use population intercept `0.10`, population
slope `0.45`, variance `0.70`, Rater coordinates
`(-0.45,-0.15,0.20,0.40)`, and Criterion coordinates
`(-0.30,0.05,0.25)`.

The central RSM steps are `(-0.90,0.10,0.80)`. The central PCM step rows are
`C1=(-1.00,0.20,0.80)`, `C2=(-0.80,-0.10,0.90)`, and
`C3=(-1.20,0.40,0.80)`. The rare-boundary RSM steps are
`(-1.60,0,1.60)`; the corresponding PCM rows are
`C1=(-1.70,0.10,1.60)`, `C2=(-1.50,-0.10,1.60)`, and
`C3=(-1.80,0.20,1.60)`. Every Rater, Criterion, RSM-step, and PCM row-sum
constraint is zero to below `1e-15`.

The extreme-Person profile replaces the lowest- and highest-index Person
latent values by the normal `1e-5` and `1-1e-5` quantiles. It is a typed stress
condition, not an iid recovery sample. The unused-category profile recodes
generated category 1 to category 2 and is deliberately model-incompatible.
Neither contributes bias, RMSE, or coverage evidence. The disconnected arm
uses the central DGP but must stop at its already-proven rank failure.

## Code-path separation

Randomness is never created inside this contract. The latent primitive applies
base `qnorm` to caller-supplied values strictly inside `(0,1)`. The response
generator uses a direct cumulative-step log kernel and an inverse-CDF map. It
does not call the reconstructed-A oracle.

A second probability path independently reconstructs the constrained A matrix
and its free-coordinate vector. The log-centered continuous oracle may use
either probability path, splits its finite `[-12,12]` integration interval at
an independently located mode, and carries numerical plus omitted-normal-tail
error bounds. Neither path calls mfrmr fitting, a production coordinate mapper,
ConQuest, or a ConQuest parser. The A-matrix and continuous-oracle paths are not
permitted in the future response-generation path.

## Deterministic audits

Across 672 profile/family/theta/Rater/Criterion cases, the maximum absolute
difference between direct and reconstructed-A probabilities is
`4.4408920985e-16`; all probabilities are finite and positive.

G2 uses one Person per arm as a mechanics sentinel for complete and
rare-boundary RSM/PCM, with the RSM sentinel in the `X=-1` stratum and PCM
sentinel in `X=+1`. The two probability paths produce identical continuous
log likelihoods to the observed double precision; their maximum declared
deviance error bound is `5.52333797532e-13`. This is not a full-arm numerical
qualification. Full 48-Person continuous audits remain mandatory in G3 before
any fitted smoke result can be interpreted.

The declared numerical envelope is capped at `1e-8` deviance units for the G2
sentinels. The `integrate()` absolute-error component is a numerical estimate,
not a mathematical proof; only the omitted standard-normal tail component has
an analytic upper-bound interpretation. Consequently, the envelope is a
mechanics gate and cannot establish inferential accuracy by itself.

## Remaining generation blockers

Five fields remain closed:

1. non-evaluative smoke seed band;
2. calibration seed band;
3. untouched confirmation seed band;
4. metric-specific precision targets and replication counts; and
5. sequential stop/expand/abort rules plus runtime/storage cap.

## Current authorization state

- `ASPG1PrerequisiteComplete=TRUE`
- `ASPG2Complete=TRUE`
- `ExactDGPValuesFrozen=TRUE`
- `GeneratorProbabilityPathSeparateFromMatrixOracle=TRUE`
- `BothProbabilityPathsSeparateFromFitPaths=TRUE`
- `ContinuousOracleLogCentered=TRUE`
- `QuadratureErrorIsNumericalEstimateNotProof=TRUE`
- `OmittedNormalTailErrorIsAnalyticBound=TRUE`
- `MaximumSentinelDevianceErrorEnvelope=1e-8`
- `ContinuousG2AuditIsOnePersonPerArmSentinel=TRUE`
- `FullArmContinuousAuditDeferredToG3=TRUE`
- `InternalRandomnessCreated=FALSE`
- `PrototypeResponsesReclassifiedAsSimulation=FALSE`
- `RemainingGenerationBlockers=5`
- `AnyDataGenerationAuthorized=FALSE`
- `AnyFitAuthorized=FALSE`
- `ConQuestExecutionAuthorized=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
