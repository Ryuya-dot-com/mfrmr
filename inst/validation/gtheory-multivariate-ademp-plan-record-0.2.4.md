# Draft.85c1 multivariate G-theory ADEMP plan record

Date: 2026-08-24
Scope: repository-only recovery-plan identity, atomic denominator, and
candidate-column-allowlist preflight
Result: plan mechanics recorded; external freeze and execution authorization
remain absent

## Outcome

Fourteen focused tests and 387 expectations pass without
failure, warning, error, or skip. The planning artifact enumerates 14 scenario
identities, four paired methods, 5,042 independent dataset identities, 20,168
atomic method rows, 20,168 registered pair rows, and 292,436 planned coordinate
rows. It reuses the
Draft.85c0 neutral design,
independent K/likelihood oracle, covariance-coordinate order, candidate
receipt, reference join, metric ledger, and local atomic-registry audit rather
than duplicating them.

The combined Draft.85a0, b0, b1, c0, and c1 multivariate suite passes 45 tests
and 741 expectations without failure, warning, error, or skip.

No recovery response was generated or inspected, no backend fit was executed,
no candidate estimate was joined to a reference, and no recovery summary was
computed for Draft.85c1. The candidate handoff is a direct-column allowlist
preview only.

The replayed content identities for this source are:

```text
PlanHash                       51f6d05a596cf05157b7599f48f29c144038e23b89cad045c47d8560d370cac2
PlanCoreHash                   c61ddfcf59dec2e169079ad0d9a35ff8281925c105d426919180553794f368b2
ImplementationIdentityHash     26d0f730e42e0386700531e8133c78051dee930d6c165511888eb6549921edf1
C0DerivativeReplayHash         ea0bb6a779813a2da68dc174740d11dc436fba81b4f96609a7083661316cd966
ReferenceRegistryHash          e0b9918b914eea0bf892bac82982bc9f48c965a0e903292295c40761e4683029
ScenarioRegistryHash           62caac834b73b7639a8e03762dbb367d476bbea090efd2af1e4ea0510dfc4ae4
StructuralPreflightHash        22ce4e5a8609247de4cb92a5c449d85d09afc250c32ead0e940de369a25ed957
MethodRegistryHash             d59f6e4471ec9c0e14320a33ab501c12b7b3974f8f1de5bdc2c0e0f46dea9059
PairRegistryHash               6134ec03047df0ef2b8f2b135cdec2959cae69959798e6ef30d60c00d25ecd55
MetricRegistryHash             e7bf3d3f35d1866ad2975195e2ea505d80b835f83f117647cc67983756ac15cb
MetricApplicabilityRegistryHash 5a8b57a7599ed4012ddc3745869ee3300edda25f6ece12900619d87b46e113b9
MetricAvailabilityTargetRegistryHash 0c1a9f3f7b760d8760f4ac582b672c977741643959de8dfca43ed0aecd842588
GenerationManifestHash         5c33571ea73e4f4dddfa7e7ada1c6d2371dfb6465f748b1ed68bc16dcf1dd2a6
CandidateUnitManifestHash      fd50018230259104f79fe6b59e4dc37e7b3d0da8c7f848b2463891f79ddd07f9
PairUnitManifestHash           904f99c73809fc8cf87c70ea6c1761cbee8e8872cbff8eac170215d027aa8a3b
ReferenceJoinMapHash           dafd56133fa411398037746ff103bb86ff42ef817c113fe2fdc7b105bd796f6c
SeedPartitionContentHash       7c39c3554cc144613c837d7825447870a17afd4039034a2fc63e4e1eec1c72ee
```

These are replay identities, not external timestamps or execution receipts.

Draft.85c1 introduces no exported symbol and adds no c1 material to package
help, vignettes, NEWS, the public roadmap, or the support envelope.
Multivariate G-theory remains repository-internal and unsupported on the
public surface.

## Registered portfolio

The plan uses an enumerated, nonfactorial scenario registry:

| Scenario role | Registered scenarios | Recovery replication role |
| --- | ---: | --- |
| regular interior | 8 | pilot and confirmation |
| PSD/rank boundary | 4 | pilot and confirmation, with nonregular state retained |
| D-rank negative control | 2 | one structural replay each |
| total | 14 | one sealed content identity |

The 12 interior and boundary scenarios are the finite-sample recovery cells.
The two D-rank controls are retained to verify fail-closed structural
adjudication. They do not enter bias, RMSE, or accuracy denominators.

Reference matrices are stored in the exact c0 coordinate order. Frozen lower-
Cholesky or explicit rank-one/rank-two/scaled loading factors reconstruct all
component matrices within `1e-12`; jitter, eigenbasis recomputation, and PSD
repair are prohibited. The seed policy also fixes the L'Ecuyer-CMRG normal and
sample kinds, `set.seed` initialization, component substream starts, stored-
factor-column order, union-group draw counts, and canonical row order. Each
group will use `z ~ N(0,I_r)`, `r=ncol(L)`, and `b=Lz`. Fixture RNG-state
hashes remain absent. These are generator inputs only:
`GeneratorImplementationReady=FALSE`, and c1 does not run the response
generator.

Every recovery dataset is shared by the same four planned routes:
`lme4_reml`, `glmmtmb_reml`, `lme4_ml`, and `glmmtmb_ml`. Those routes are
paired method results. They are not counted as independent Monte Carlo
datasets and cannot be separated by regenerating a response for one backend
or criterion.

## Atomic manifest arithmetic

The exact plan expansion is:

| Phase | Scenarios | Replicates/scenario | Independent datasets | Atomic method rows | Pair rows |
| --- | ---: | ---: | ---: | ---: | ---: |
| pilot | 12 | 20 | 240 | 960 | 960 |
| confirmation | 12 | 400 | 4,800 | 19,200 | 19,200 |
| D-rank negative | 2 | 1 | 2 | 8 | 8 |
| total | 14 distinct | -- | 5,042 | 20,168 | 20,168 |

The total follows exactly from

```text
12 x 20 x 4    =    960
12 x 400 x 4   = 19,200
 2 x 1 x 4     =      8
                         ------
                         20,168 atomic method rows
```

The manifest retains a row for every method even when dataset generation,
structural qualification, backend fitting, component extraction, optimizer
qualification, or point qualification fails. No failure row may disappear
from the registered denominator. A D-rank negative control that is blocked as
designed remains a planned and accounted row, not an unrecorded fit.

The separate pair manifest registers four oriented comparisons for every
dataset: backend differences within ML and REML and criterion differences
within lme4 and glmmTMB. Both opaque candidate-unit identities are bound to the
same dataset. Incomplete pairs remain in the planned pair denominator and are
reported through complete-pair availability rather than being dropped.

## c0 reuse and exact binding

The future runner must delegate statistical mechanics to Draft.85c0:

- c0 neutral `RowId` and retained-row identities bind the candidate data;
- c0 structural and neutral design hashes bind fixed and random designs;
- c0 semantic covariance packing fixes the component-coordinate order;
- c0 candidate receipts seal the monotone fit/estimate/point-gate state;
- c0 reference joining releases truth only after candidate receipt; and
- c0 atomic registry matching checks the local `DatasetId x MethodId`
  inventory within each bound design.

The c1 planning layer additionally hashes every full deterministic structural
row table and computes a compact equality-signature rank preflight. The two
negative-control results, 17/19 for no direct A-C object overlap and 9/10 for
no within-cell replication, are cross-checked against c0's authoritative
derivative design. This compact preflight is not a second K oracle and its row
hash is not labelled as a c0 neutral-design hash.

The plan now also contains the two authoritative c0 negative-control replay
receipts. Their structural-design and derivative-result hashes bind ranks
17/19 for `A3-NOAC` and 9/10 for `A2-NOREP`; both are oracle-ready,
unidentified as intended, and explicitly not recovery evidence. The zero
response passed to c0 is labelled a structural placeholder and is not a
generated recovery response.

Draft.85c1 adds the global plan, phase, scenario, replicate, method, and
generation-state inventory. It does not reinterpret a c0 exact local match as
a completed denominator. The atomic manifest and metric-routing plans are
ready, but `DenominatorAccountingReady` remains false until a future authorized
run returns an exact receipt for all 20,168 atomic rows.

The prospective receipt tuple catalog proves that six post-handoff outcome
shapes are legal c0 monotone receipt tuples and records the exact b1 gate field
names for normalized-fit rows. The two earlier states--dataset
generation failure and pre-fit structural/incidence block--are intentionally
outside the c0 receipt schema and require a future c1 envelope. All eight
`MappingImplemented` flags remain false, so schema consistency is not
misreported as end-to-end receipt completion.

The four future backend routes must use the exact Draft.85b1
retained-row, fixed-design, random-block, component-order, criterion,
dependency, and normalized-fit schemas. No alternate parser or covariance
extraction path was introduced for the ADEMP plan.

## Candidate handoff allowlist preview

The preview exposes only opaque unit and dataset tokens, method and method-
control hashes, and coordinate-layout identity/count. It contains no data,
response slot, seed, backend object, or executable command. It does not expose
scenario role, an explicit `StageId`, generator settings, covariance truth,
latent effects,
boundary label, reference coordinates, reference hashes, accuracy
classification, or aggregate recovery output.

The lane token and the exact expected unit counts (960, 19,200, or 8) remain
observable and are sufficient to infer the stage-shaped lane. The preview is
therefore not claimed to hide phase by inference; it only omits the direct
`StageId` and replicate columns.

The candidate/reference separation therefore has the intended direct-column
shape, but it has not yet been exercised as an isolated process. In fact, the
adversarial test confirms that a caller holding both the preview and the root
plan can join the opaque dataset key to the reference map. No claim is made
that a future caller cannot access truth outside this interface. That claim
requires a separately isolated executor and reference vault, an execution
record, candidate receipts sealed before reference release, and externally
anchored provenance.

## PlanHash and freeze disposition

The content-only `PlanCoreHash` excludes implementation identity. Literal
canonical roots pin that core and each generated manifest, so a caller cannot
replace a mutable closure cache with a forged reference plan. The separate
implementation registry replays every c1/c0/b1 prototype function. More
precisely, it hashes every function defined in the c1, c0, and b1 prototype
layers plus selected a0/b0/Draft.81 dependencies, including derivative/K,
packing, likelihood, score, expected-information, and backend extraction
helpers. It does not claim to hash base R or installed-package source.
`PlanHash` binds the
combined payload and detects a changed bound field on replay. It remains a
content identity, not evidence of when the plan was created or an independently
witnessed preregistration.

There is no external `FreezeReceipt` binding the `PlanHash`, immutable
repository or artifact identity, UTC timestamp, and independent issuer or
record identity. The current disposition is therefore:

```text
PlanContentSealed                  = TRUE
PreOutcomeFreezeExternallyAnchored = FALSE
RecoveryDesignFrozen               = FALSE
PilotExecutionAuthorized           = FALSE
ConfirmationExecutionAuthorized    = FALSE
CandidateCompletionSealed          = FALSE
TruthReleaseAuthorized             = FALSE
GeneratorImplementationReady       = FALSE
```

Plan replay, exact row arithmetic, and the direct-column allowlist preview do
not promote the false states. No pilot or confirmation seed may be opened
under the current record.

## Accuracy and evidence disposition

No numerical accuracy threshold is set. No maximum bias, RMSE, absolute or
relative coordinate error, boundary frequency, failure frequency, point-gate
rate, or comparative-recovery-loss cutoff has been chosen. The registered
replication counts are fixed plan content, not proof of adequate precision or
acceptable operating characteristics.

Twenty-two metric definitions now bind their level, natural unit,
within-dataset reduction, across-dataset aggregation axes, denominator,
availability companion, and precision or deterministic-adjudication policy.
Eigenvalue, rank, and boundary metrics are
component-level. PSD/extraction failure and the other rate metrics retain all
planned atomic rows. Component RMSE is based on equal-weight normalized
vech-coordinate MSE within dataset/component; its precision gate is placed on
that underlying MSE. The paired loss is an oriented difference of the two
methods' dataset-level mean normalized absolute coordinate errors and is
accompanied by complete-pair availability.

The normalizer is now explicit and truth-side only. For stratum `s`, `V_s0`
is the sum of the three random-component diagonal variances plus residual
variance. Non-residual `(s,t)` errors divide by
`sqrt(V_s0 * V_t0)`; `Residual[I]` divides by the mean `V_s0`. Dataset loss
uses every declared coordinate including residual, and any unavailable
coordinate makes the whole dataset loss unavailable. The pair registry binds
the input coordinate metric, complete-coordinate reduction, paired output,
and pair-availability metrics by valid foreign keys; the aim is comparative
recovery loss, not direct estimate agreement.

The 572 applicability rows cover every actual stage, scenario, and metric.
Pilot metrics are feasibility-only and cannot select a threshold;
confirmation metrics may only be judged against an independently pre-frozen
rule; negative controls use exact expected-state match, unexpected-attempt,
and false-ready metrics. Metric availability stores each target metric's
natural-unit type and full aggregation axes, preserving the actual coordinate,
component, or method dimensions. Pair identity is handled by the separate
complete-pair availability route.

The 288-row metric-availability target registry expands all 12
confirmation-target metrics across pilot and confirmation for every recovery
scenario. Pilot target rows are explicitly feasibility-only; this prevents
`metric_availability_rate` from being declared applicable with an empty target
set. Rate denominators follow their registered planned natural unit: method,
target-metric unit, pair, boundary/structural subset, or negative-control unit
as applicable.

Seven precision policies are stage-specific. Only the five confirmation
policies make Monte Carlo precision statements. Pilot rows use
`PILOT-DESCRIPTIVE` and cannot pass an MCSE or accuracy gate; negative-control
rows use `DET-STRUCTURAL` and require an exact registered-state match rather
than treating their single replay as a Monte Carlo sample.

For confirmation rates, 400 independent datasets per scenario imply a
worst-case binomial MCSE of 0.025 and a zero-event one-sided 95% upper bound of
`1 - 0.05^(1/400)`. Those are precision rules, not scientific accuracy
cutoffs. A shortfall requires a new prospective plan version and seed band.

Boundary rows retain their regularity, rank, fit, estimate, point-gate, and
metric-availability states. Relative error is unavailable at a zero or
sufficiently near-zero reference. The D-rank negative controls contribute
only to structural and atomic accounting.

Negative controls additionally require the observed pre-fit state to match the
registered block and record any prohibited fit attempt, so an erroneous
attempt followed by failure cannot masquerade as a correct structural block.
Estimated boundary classification uses the fixed precedence unavailable/non-
PSD, absolute boundary, scaled relative-rank boundary, then regular interior,
with a separate residual-scalar rule.

A 24-row reference boundary-class registry covers every
`ReferenceId x ComponentId`, including residual. It converts rank-one,
rank-two, residual, and scaled-rank truth to the same component-level
comparison classes used on the estimated side. The broader scenario-role
labels are retained for design interpretation but are not used as equality
targets.

The scaled-rank control deliberately separates rules: c0's relative
eigenvalue rule marks the interaction matrix rank deficient, but its maximum
absolute correlation is below b1's correlation-boundary cutoff. It remains an
eligible attempted fit rather than an automatic hold, so a later point-gate
pass is observable as a false-ready event.

Accordingly,

```text
RecoveryThresholdFrozen      = FALSE
DenominatorAccountingReady   = FALSE
PilotEvaluationComplete      = FALSE
DecisionRuleFrozen           = FALSE
ConfirmationIsolationReady   = FALSE
RecoveryExecuted             = FALSE
RecoveryEvidenceReady        = FALSE
EstimatorRecoveryReady       = FALSE
```

## Stage-wide dependency blocker

The local dependency identity remains the Draft.85b1 identity:

```text
glmmTMB              1.1.14
glmmTMB build TMB    1.9.23
runtime TMB          1.9.25
TMB ABI              2
```

The build-time and runtime TMB versions differ. Draft.85b1 therefore labels
diagnostic-override glmmTMB results
`backend_dependency_version_mismatch` and keeps
`PointEstimationGatePassed=FALSE`.

Because glmmTMB ML and REML are two of the four paired methods, this mismatch
closes the stage-wide gate. The lme4 routes cannot be run alone and promoted
under the same plan, failed glmmTMB rows cannot be deleted, and diagnostic-
override output cannot authorize pilot execution. The dependency environment
must be repaired and rebound before execution is authorized. An external
anchor can record the blocked plan, but cannot turn a failed dependency gate
into authority to run it.

## Exclusions and public-scope isolation

The plan explicitly excludes:

- G and Phi coefficients, composite reliability, allocation decisions, and
  D-study optimization;
- intervals, standard errors, coverage, and full-refit uncertainty;
- local-facet diagonal covariance structures and their reduction behavior;
- missing responses, complete-case analysis, imputation, and missingness-
  mechanism claims; and
- any public API, documentation, NEWS, roadmap, support-envelope, or release
  promotion.

Structural row absence remains only the Draft.85c0 retained-row principal-
submatrix case. It is not missing-response support, and an `NA` response
remains rejected.

## Disposition

Draft.85c1 records a reproducible ADEMP plan identity, its exact 20,168-row
atomic denominator, and a candidate-column-allowlist preview. It does not
record a chronologically external freeze, an accuracy threshold, an executable
dependency environment, or authorization for either data phase.

Recovery, estimation, inference, uncertainty, coefficient, decision, and
public-support readiness all remain false. The next admissible steps are to
obtain an external `FreezeReceipt` for the unchanged plan and repair the
glmmTMB/TMB environment, then implement the generator and bind its fixture/RNG-
state identities. A separately recorded pilot authorization must precede any
response generation; confirmation remains independently unauthorized.
