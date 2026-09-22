# Draft.85c4c multivariate G-theory isolation-integration contract

Date: 2026-08-24  
Scope: c3/c4a/c4b identity join and five-question fixture receipt  
Public status: unsupported

## Purpose and non-promotion rule

Draft.85c4c translates the runtime-bound c4b evidence into the five access
questions declared by c3. It joins the historical c3 admission manifest, the
c4a candidate/receipt manifest, and the c4b live evidence without changing any
of them.

The integration distinguishes two claims:

1. one nonreserved fixture completed a truth-blind process-boundary test; and
2. the planned pilot or confirmation execution boundary is ready.

Only the first claim is supported. All five planned-material questions require
a successor recheck after planned material and an independent confirmation
threshold exist. Therefore c4c records fixture evidence but leaves c3's
`truth_blind_process_boundary` prerequisite unsatisfied.

## Namespace and upstream identity

c4c owns the previously unused `mfrmr_gtvj_*` namespace. An initial `gtvi`
prototype collided with the existing incidence layer and changed the c1
implementation identity and `PlanHash`; it was rejected. The accepted
namespace leaves the sealed plan root
`51f6d05a596cf05157b7599f48f29c144038e23b89cad045c47d8560d370cac2`
unchanged.

The receipt requires exact joins on:

- c3, c4a, and c4b plan identities;
- c3, c4a, and c4b generator-manifest identities;
- fixture ordinal 1 opaque candidate, envelope, and candidate-data hashes; and
- the c4a non-attempt receipt and c4b normal receipt hash.

Every upstream object is validated before integration. A missing live c4b
object, changed vault hash with a recomputed evidence hash, changed schema,
changed receipt answer, or changed readiness state fails closed.

## Filled isolation identities

The c3 isolation-template fields are represented by a typed successor receipt:

| c3 identity | c4c source |
| --- | --- |
| `CandidateExecutorSHA256` | hash of c4b worker, c4a worker, runtime, and semantic profile hashes |
| `CandidateInputSchemaSHA256` | exact c4a envelope layout plus fixture candidate schema |
| `CandidateReceiptSchemaSHA256` | exact c4a receipt layout plus worker identity |
| `ReferenceVaultSHA256` | exact one-fixture c4b denied-read vault hash |
| `IsolationAuditId` | c4b runtime, evidence, control, and five-question roots |

The 12-fixture c4a registry-vault hash remains separate from the one-fixture
c4b vault hash. They are not interchangeable and both are carried in the
receipt.

## Five access questions

| Question | Fixture material | Evidence control | Fixture answer | Planned recheck |
| --- | --- | --- | --- | --- |
| scenario identity | present in c4b vault | vault read denied | cannot read | required |
| data seed | nonreserved fixture seed present | vault read denied | cannot read | required |
| reference identity | present in c4b vault | vault read denied | cannot read | required |
| truth | present in c4b vault | vault read denied | cannot read | required |
| accuracy threshold | not materialized | source read denied | cannot read current material | required |

The data-seed observation concerns only the c2 nonreserved fixture proxy. No c1
pilot, confirmation, or negative-control seed is opened. The missing accuracy
threshold cannot be treated as proof that a future materialized threshold is
isolated; `ConfirmationIsolationRecheckRequired` therefore remains true.

## Prerequisite and dispatch behavior

The successor prerequisite audit preserves all eight c3 rows. Only
`no_diagnostic_override` remains currently satisfied. The truth-blind row gains
`FixtureEvidenceAvailable=TRUE` but stays `CurrentSatisfied=FALSE` with the
state `fixture_only_runtime_bound_isolation_requires_planned_successor`.

The c3 manifest hash is retained as a historical identity and
`C3HistoricalManifestModified=FALSE`. c4c has its own dispatch guard, which
validates the complete canonical integration manifest and then rejects both
`authorize=FALSE` and `authorize=TRUE` before callback execution.

## Disposition

```text
C3IsolationQuestionIntegrationReady   = TRUE
ProcessCapabilityIsolationReady        = TRUE
FixtureTruthBlindProcessBoundaryReady  = TRUE
TruthBlindProcessBoundaryReady         = FALSE
PlannedExecutionIsolationReady         = FALSE
ConfirmationIsolationRecheckRequired   = TRUE
C3HistoricalManifestModified           = FALSE
CandidateCompletionSealed              = FALSE
TruthReleaseAuthorized                 = FALSE
ExternalFreezeReady                    = FALSE
CleanSourceIdentityReady               = FALSE
IndependentAccuracyRuleReady           = FALSE
BackendQualificationReady              = FALSE
PilotExecutionAuthorized               = FALSE
ConfirmationExecutionAuthorized        = FALSE
NegativeControlExecutionAuthorized     = FALSE
ExecutionGateClosed                    = TRUE
BackendExecutionOccurred               = FALSE
PlannedResponseGenerated               = FALSE
RecoveryExecuted                       = FALSE
RecoveryEvidenceReady                  = FALSE
EstimationReady                         = FALSE
InferenceReady                          = FALSE
DecisionReady                           = FALSE
PublicSupportReady                      = FALSE
```

c4c is an evidence-integration result, not an execution authorization or a
public multivariate capability.

