# Draft.85c1 multivariate G-theory ADEMP plan contract

Status: repository-only planning and candidate-column-allowlist preflight,
2026-08-24.

Draft.85c1 registers a finite-sample recovery portfolio and its complete atomic
denominator before any recovery response is generated, fitted, or inspected.
It is a planning-only layer. It does not authorize a pilot or confirmation
run, select an accuracy threshold, or convert the Draft.85c0 oracle mechanics
into estimator-recovery evidence.

The plan has a reproducible `PlanHash`, but that hash establishes content
identity only. No independently held, externally timestamped
`FreezeReceipt` currently binds the plan to a pre-outcome time point.
Consequently, a replayable plan is not called a frozen recovery design and no
execution phase is authorized.

## Upstream contracts and nonduplication

Draft.85c1 reuses the following Draft.85c0 contracts without replacing or
reimplementing their statistical core:

- the exact neutral-design schema and its `RowId`, stratum, fixed-design,
  component-group, structural-design, and neutral-design identities;
- the independent pairwise and component-design K constructions;
- the semantic lower-triangle covariance-coordinate order;
- the ML/REML objective and local expected-information oracle;
- the sealed candidate receipt, monotone fit/estimate/point-gate states, and
  post-receipt reference join;
- the coordinate-level signed, absolute, and squared error schema, with
  relative error available only away from zero; and
- the exact `DatasetId x MethodId` candidate-receipt audit used as a local
  atomic-accounting subaudit.

Draft.85c1 adds the phase, scenario, replicate, method, seed-role, and
plan-level identities needed to place those c0 mechanics in a prospective
ADEMP denominator. A compact equality-signature rank preflight hashes the
full deterministic structural rows without constructing K; it is a planning
check, not a second K oracle. Both registered negative-control ranks are also
replayed against the authoritative c0 derivative design; their c0 structural
and derivative result hashes and 17/19 and 9/10 ranks are plan content.
Draft.85c1 does not
create a second K implementation, covariance packer, likelihood oracle,
candidate-receipt schema, or reference-join path.
The Draft.85b1 backend specification and normalized fit schemas remain the
only matched-model adapters used by the four planned methods.

The c0 atomic audit is necessary but not sufficient at the plan level. Its
one-design `DatasetId x MethodId` check must be applied by a future runner
within the relevant sealed design identity. The c1 plan-level audit must
additionally retain every
phase, scenario, replicate, design, method, and upstream-generation state,
including rows for datasets or fits that cannot be produced.

## ADEMP portfolio

The portfolio contains 14 deliberately enumerated scenarios rather than an
implicit full factorial expansion.

| Scenario role | Scenarios | Purpose |
| --- | ---: | --- |
| regular interior | 8 | finite-sample covariance-coordinate recovery at regular positive-definite points |
| PSD/rank boundary | 4 | retain boundary and nonregular estimator states without relabelling them as regular recovery |
| D-rank negative control | 2 | verify that a covariance design lacking the required derivative rank is blocked before recovery interpretation |
| total | 14 | one registered portfolio |

The 12 interior or boundary scenarios are recovery scenarios. The two D-rank
negative controls are structural controls: each receives one dataset identity
and four planned method rows so that a correct pre-fit block remains in the
atomic denominator. They are not included in a sampling bias or RMSE
denominator.

Each registered scenario binds a deterministic structural-row hash, the c0
coordinate layout, and a prospective derivative-rank expectation. A later
generated neutral design must still obtain its own c0 structural and response
identities; the structural-row hash is not mislabelled as a c0 neutral-design
hash. Scenario role, covariance truth, boundary classification, generator
parameters, and reference hashes are assigned to the reference side of a
future isolated execution boundary. The c1 candidate allowlist excludes them,
but the root plan still contains the join map, so this assignment is not yet
process-level truth blindness. Reference values are never normalized,
reordered, or inferred from a candidate estimate after fitting.

Every reference covariance is stored in the c0 coordinate order together with
a frozen generating factor. Positive-definite components use the stored lower
Cholesky factor; the rank-one, rank-two, and scaled controls use their explicit
registered loading matrices. Each factor reconstructs its matrix within
`1e-12`. The generator may consume the stored factor but may not recompute an
eigenbasis, add jitter, or apply nearest-PSD repair. The RNG content fixes
`L'Ecuyer-CMRG`, `Inversion`, `Rejection`, `set.seed(DataSeed)`, Object on the
initial stream, and each later component on the iterated
`parallel::nextRNGSubStream()` state. For component `c` and sorted union group
`g`, the future generator must draw `z_cg ~ N(0, I_r)`, with
`r = ncol(L_c)`, in stored factor-column order and set `b_cg = L_c z_cg`;
the residual draws once per canonical structural `RowId`. This resolves
rank-one/rank-two draw counts. Fixture RNG-state hashes and the generator
itself remain absent, so `GeneratorImplementationReady=FALSE` and no response
generation is authorized at c1.

## Four paired methods

Every independent generated dataset is assigned to exactly four matched
method routes:

| Method | Backend | Criterion |
| --- | --- | --- |
| `lme4_reml` | lme4 | REML |
| `glmmtmb_reml` | glmmTMB | REML |
| `lme4_ml` | lme4 | ML |
| `glmmtmb_ml` | glmmTMB | ML |

The four routes consume the same retained rows and the same response for a
given dataset. They are paired methods, not four independent Monte Carlo
replications. A method-specific failure, pre-fit block, extraction failure,
or point-gate failure remains an explicit atomic row and cannot be removed
from the denominator or replaced by a successful route.

The exact Draft.85b1 fixed-design, random-block, component-order, retained-row,
criterion, backend, dependency, and fit identities apply to every route. ML
and REML are not pooled. lme4 and glmmTMB results are not pooled. Paired
contrasts may be computed only from their shared dataset identity and do not
increase the independent dataset count.

The pair registry fixes four oriented comparative-recovery-loss contrasts
before execution: lme4
minus glmmTMB within REML, lme4 minus glmmTMB within ML, ML minus REML within
lme4, and ML minus REML within glmmTMB. Each comparison uses the difference
between the two methods' dataset-level mean normalized absolute coordinate
errors; this is not a claim of direct estimate agreement. The input coordinate
metric, complete-coordinate dataset-loss reduction, paired output metric, and
complete-pair availability metric are four validated registry foreign keys.
The pair manifest binds both candidate unit identities to the same
opaque dataset; a missing member is retained through a complete-pair
availability indicator and cannot silently redefine the paired denominator.

## Phase sizes and exact atomic denominator

Pilot and confirmation phases use distinct registered replicate identities.
Constructing either phase manifest does not authorize response generation.

| Phase | Eligible scenarios | Replicates/scenario | Independent datasets | Atomic method rows | Registered pair rows |
| --- | ---: | ---: | ---: | ---: | ---: |
| pilot | 12 recovery | 20 | 240 | 960 | 960 |
| confirmation | 12 recovery | 400 | 4,800 | 19,200 | 19,200 |
| D-rank negative | 2 structural | 1 | 2 | 8 | 8 |
| total | 14 distinct | -- | 5,042 | 20,168 | 20,168 |

Thus the exact planned atomic denominator is

```text
(12 x 20 x 4) + (12 x 400 x 4) + (2 x 1 x 4) = 20,168.
```

The pilot supplies 20 independent datasets per recovery scenario, and the
confirmation phase supplies 400 new independent datasets per recovery
scenario. Confirmation datasets may not reuse, extend, or condition on pilot
responses. The two D-rank controls each have one independent dataset identity
because their target is deterministic structural adjudication, not an
operating-characteristic estimate.

Every atomic row is planned before execution. Required accounting separates
at least `Planned`, dataset-generation state, structural eligibility,
`FitReturned`, estimate availability, `PointGatePassed`, and metric
availability. Failure rows remain in the appropriate denominator; success-
conditioned deletion is prohibited. A correct D-rank block is an observed
structural outcome, not a missing fit and not a successful covariance
estimate.

Draft.85c1 also registers a prospective c1-to-c0 receipt tuple catalog. Six
post-handoff outcome shapes map to legal existing c0 monotone tuples and typed
failure stages, with the exact b1 field names and expected Boolean gates
recorded where a normalized b1 fit would exist. Dataset-generation failure and
pre-fit structural/incidence
block cannot be represented by a c0 candidate receipt, so they require a
future c1 envelope. `ReceiptTupleCatalogReady=TRUE` means only that these
prospective tuples are internally legal; every
`MappingImplemented` value remains false; it is therefore not evidence that
the 20,168 candidate receipts can yet be completed.

## Candidate handoff column-allowlist preview

Draft.85c1 permits only a preview of the future candidate-facing handoff. The
current preview contains only opaque unit and dataset tokens, method and
method-control hashes, and coordinate-layout identity/count. It contains no
neutral data, response, seed, backend fit, or executable command. A later
authorized handoff may add a separately sealed neutral retained-row/response
payload and exact Draft.85b1 specification only under a revised, externally
anchored execution contract.

The candidate-facing columns directly exclude:

- scenario role and any interior, boundary, or D-rank label;
- an explicit `StageId` or replicate identity, source seed, or generator
  parameter values (although lane size and `LaneOpaqueId` are observable and
  can reveal which stage-shaped handoff was supplied);
- covariance truth, latent effects, reference coordinates, or reference
  covariance hashes;
- truth-side derivative-rank disposition beyond a typed pre-fit eligibility
  result released by the structural adjudicator; and
- recovery differences, accuracy classifications, thresholds, or aggregate
  results.

Candidate state must be sealed in a c0 receipt before the reference side is
joined. An opaque token is resolved to scenario, phase, replicate, truth, and
reference identities only after the complete candidate receipt has been
accepted. The c0 before/after candidate-receipt hash equality remains the
local reference-join guard.

This preview demonstrates only a direct-column allowlist. Its opaque dataset
token is intentionally the key needed for later reference joining; a caller
that also holds the root plan can therefore join the preview back to the
reference map. The tests preserve that adversarial join as a positive probe.
Accordingly, the preview does not prove that an upstream process was truth
blind, does not create a response, does not execute a backend, and does not
authorize access to pilot or confirmation seeds. Process-level truth
blindness requires a separately isolated candidate executor, a withheld
reference vault, the future execution record, and an externally anchored
freeze receipt.

## Plan identity and external freeze

`PlanCoreHash` binds scientific plan content but deliberately excludes
implementation identity. Literal canonical roots independently pin that core,
the reference and scenario registries, and every generated manifest; the
validator reconstructs their hashes from the supplied object and does not
trust a mutable cached canonical payload. `ImplementationIdentity` separately
hashes all functions defined by the c1, c0, and b1 prototype layers and the
selected a0/b0/Draft.81 internal
dependencies they consume. This includes derivative/K construction,
covariance packing, likelihood, score, expected information, bridge,
specification, fit, receipt, join, and denominator functions. It is an
internal-function identity, not a hash of base R or installed package source.

`PlanHash` binds the resulting scientific, manifest, and implementation
payload, including the scenario registry, phase sizes, paired-method registry,
atomic method manifest, handoff implementation identity, and upstream contract
identities.
The exact top-level validator separately pins every readiness suffix to its
derived value; readiness suffixes are not presented as timestamp evidence.
Replaying the same canonical payload must reproduce the same hash; altering a
bound plan field or a pinned readiness state fails canonical validation even
if an attacker recomputes the visible hash.

`PlanHash` does not establish when the payload was created, whether a prior
version existed, or whether outcomes were viewed before it was computed. It
is therefore not a preregistration or authorization receipt. A future
`FreezeReceipt` must be external to the plan payload and bind at least the
`PlanHash`, immutable repository/artifact identity, UTC time, and an
independently auditable issuer or record identity. The receipt must not be
silently regenerated after any response or result is viewed.

No such `FreezeReceipt` exists in Draft.85c1. The following distinctions are
mandatory:

```text
PlanContentSealed                  = TRUE
PreOutcomeFreezeExternallyAnchored = FALSE
RecoveryDesignFrozen               = FALSE
PilotExecutionAuthorized           = FALSE
ConfirmationExecutionAuthorized    = FALSE
```

Creating, printing, replaying, or validating the plan cannot change any of
the false states.

## Accuracy, metrics, and denominator limits

The plan registers 22 exact metric rows and complete failure accounting, but
it does not set a numerical accuracy threshold. The primary continuous rows
cover normalized coordinate errors, component-coordinate RMSE, total-K
relative Frobenius error, and the oriented paired-method loss difference.
Component eigenvalue, effective-rank, and boundary-classification metrics are
explicitly component-level. Rate rows cover PSD/extraction failure, fit
return, estimate availability, point-gate pass, per-metric availability,
false readiness, and complete-pair availability. PSD/extraction failure uses
all planned atomic method rows, not only successfully extracted estimates.
The two structural-control metrics require an exact expected pre-fit-state
match and report any prohibited backend attempt, so a correct pre-fit block
cannot be confused with an erroneous attempt followed by fit failure.

Normalized errors use registered truth-side scale only. For stratum `s`,

```text
V_s0 = Object[s,s] + Rater[s,s] + Object:Rater[s,s] + ResidualVariance.
```

A non-residual coordinate `(s,t)` is divided by
`sqrt(V_s0 * V_t0)`; `Residual[I]` is divided by the mean of `V_s0` over the
registered strata. Every `V_s0` must be finite and strictly positive.
Component RMSE and the paired loss inherit this same normalizer. A dataset
loss is the equal-weight mean over every declared coordinate, including
`Residual[I]`; if any required coordinate is unavailable, the whole dataset
loss is unavailable and no partial-coordinate mean is formed.

Every metric definition maps to one registered precision or deterministic-
adjudication policy.
Continuous summaries use the independent dataset (or complete paired dataset)
as the sampling unit; component RMSE first averages equally weighted
normalized squared vech-coordinate errors within dataset/component and gates
the Monte Carlo error of that underlying MSE before taking the square root.
Confirmation-rate summaries use 400 independent datasets per scenario, for a
worst-case binomial MCSE of 0.025 and a zero-event one-sided 95% upper bound
of `1 - 0.05^(1/400)`. A precision shortfall requires a new prospective plan
and seed band; it cannot be repaired by deleting unavailable rows.

The registry contains seven stage-specific precision policies. The five
Monte Carlo policies apply only to confirmation rows. Pilot rows are routed to
`PILOT-DESCRIPTIVE`, which reports feasibility counts and rates but cannot
select a threshold or promote recovery. D-rank controls are routed to
`DET-STRUCTURAL`, which requires exact agreement for each registered control
and does not misrepresent one deterministic replay as a Monte Carlo sample.

No absolute-error, relative-error, bias, RMSE, boundary-frequency,
optimizer-success, point-gate, or comparative-loss *accuracy* cutoff has been
selected. Monte Carlo precision and scientific adequacy are different gates;
the 20- and 400-replication counts do not by themselves make an operating-
characteristic claim acceptable.

The 572-row applicability registry fixes every actual
`StageId x ScenarioId x MetricId` cell. Pilot rows are feasibility-only and
never threshold-selection evidence; confirmation rows are evaluated only
against an independently pre-frozen rule; negative controls use only the
structural-state, unexpected-attempt, and false-ready metrics. Per-metric
availability stores the target metric's natural-unit type and full aggregation
axes, preserving coordinate, component, or method identity rather than
collapsing them into one generic unit label. Pair identity is preserved by the
separate complete-pair availability route. A separate 288-row
availability-target registry explicitly expands the
12 confirmation-target metrics over every recovery scenario in pilot and
confirmation. Its pilot rows are availability-only feasibility targets, so
`metric_availability_rate` never has an empty implied target set. Each rate
uses its own registered planned natural-unit denominator rather than assuming
that every rate is method-row based. `AtomicManifestDenominatorPlanReady` and
`MetricDenominatorRoutingReady` are separate from observed
`DenominatorAccountingReady`, which remains false.

The c0 coordinate metric schema may be aggregated only within a registered
scenario, phase, method, and coordinate identity. Relative error remains
undefined at or sufficiently near a zero reference. Boundary scenarios must
retain rank, regularity, and metric-availability states rather than be forced
into an interior accuracy pass/fail rule. Estimated-state precedence is fixed
as unavailable/non-PSD or extraction failure, absolute boundary, scaled
relative-rank boundary, then regular interior; the residual uses its separate
scalar absolute-boundary rule. D-rank negative controls contribute to
structural-state and atomic accounting only.

Truth-side boundary comparison uses a separate 24-row
`ReferenceId x ComponentId` registry, including `Residual`. It normalizes each
registered truth to the same comparison vocabulary and precedence used by the
estimated-state classifier: `absolute_boundary`,
`scaled_relative_rank_boundary`, or `regular_interior`. Scenario labels such
as `exact_psd_rank_boundary` remain design-role labels and are never compared
directly to estimated component classes.

The scaled-rank control is also a deliberate cross-rule stress: its c0
relative eigenvalue rule marks the `Object:Rater` component rank deficient,
while its maximum absolute correlation remains below the Draft.85b1
correlation boundary. It is eligible for an attempted point fit and must not
be pre-labelled as a backend hold. A later point-gate pass on this boundary
truth is counted by the prespecified false-ready rule.

Until a threshold-selection rule and its independent freeze are supplied,

```text
RecoveryThresholdFrozen      = FALSE
DenominatorAccountingReady   = FALSE
RecoveryExecuted             = FALSE
RecoveryEvidenceReady        = FALSE
EstimatorRecoveryReady       = FALSE
```

An exact manifest row count or successful c0 local atomic subaudit is a
mechanical prerequisite and cannot promote these states.

## Stage-wide dependency gate

The local environment currently reports `glmmTMB` built against TMB 1.9.23
and runtime TMB 1.9.25. Draft.85b1 classifies every diagnostic-override fit in
that state as `backend_dependency_version_mismatch` and keeps
`PointEstimationGatePassed=FALSE`.

Because all four paired methods are part of one content-sealed planned
comparison, the
dependency failure closes the stage-wide execution gate. Running only lme4,
discarding glmmTMB rows, or using the diagnostic override as readiness
evidence is prohibited under the same `PlanHash`. The environment must be
repaired and its exact dependency identity bound before execution
authorization. An external anchor may record the blocked plan before that
repair, but it cannot open an execution lane.

## Explicit exclusions

Draft.85c1 does not include or authorize:

- composite G coefficients, Phi coefficients, allocation optimization, or
  D-study decision operators;
- confidence intervals, standard errors, coverage, full-refit uncertainty,
  or interval-calibration claims;
- local-facet diagonal covariance structures or any reduction from the
  current global matched covariance model;
- missing responses, complete-case recovery, imputation, or MAR/MNAR/unknown
  missingness mechanisms; or
- public multivariate G-theory functions, exports, help, vignettes, NEWS,
  roadmap promotion, support-envelope changes, or release claims.

Structurally absent rows remain within the c0 principal-submatrix contract and
are distinct from a missing response. A response `NA` remains an error.

## Readiness boundary

Draft.85c1 may establish plan-schema, plan-hash, manifest-count, paired-method,
candidate-column-allowlist, and upstream-identity mechanics. It does not
establish an executable or evidentiary recovery stage. At this planning-only
checkpoint, the following states remain false:

```text
RecoveryDesignFrozen            = FALSE
RecoveryThresholdFrozen         = FALSE
PilotExecutionAuthorized        = FALSE
ConfirmationExecutionAuthorized = FALSE
CandidateCompletionSealed       = FALSE
TruthReleaseAuthorized          = FALSE
DenominatorAccountingReady      = FALSE
PilotEvaluationComplete         = FALSE
DecisionRuleFrozen              = FALSE
ConfirmationIsolationReady      = FALSE
GeneratorImplementationReady    = FALSE
RecoveryExecuted                = FALSE
RecoveryEvidenceReady           = FALSE
EstimatorRecoveryReady          = FALSE
EstimationReady                 = FALSE
InferenceReady                  = FALSE
UncertaintyReady                = FALSE
CoefficientEligible             = FALSE
DecisionReady                   = FALSE
PublicSupportReady              = FALSE
```

The next gate is external freeze and environment repair, followed by a
separately recorded generator implementation and pilot authorization.
Confirmation remains unavailable until the pilot is complete and an accuracy
rule has been selected from independent grounds without using any pilot or
confirmation truth, fit, availability, or recovery outcome. The final
candidate and threshold identities must then be frozen and a distinct
confirmation authorization issued.
