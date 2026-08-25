# Draft.85c4f multivariate G-theory four-route qualification protocol contract

Date: 2026-08-24  
Scope: pre-fit route, pair, tolerance, and trust semantics  
Public status: unsupported

## Purpose and boundary

Draft.85c4f freezes the evidence protocol for the four matched-backend routes
before a repaired environment is used. It does not repair the environment,
implement a trusted worker, execute a backend, generate a planned response,
promote a receipt, invoke ConQuest, or authorize any lane.

The protocol distinguishes:

- a syntactically complete self-reported candidate summary;
- complete b1 fit and parity objects revalidated by a future trusted worker;
- a trusted qualification receipt; and
- operational admission.

These states are not interchangeable. Candidate readiness is deliberately
incapable of setting trusted or operational readiness.

## Four routes and two pairs

The route registry contains exactly:

```text
lme4_ml
lme4_reml
glmmTMB_ml
glmmTMB_reml
```

Every route requires a fresh process, an `identified_point_fit` status, fit
integrity, a passed point-estimation gate, exact backend-row retention, matched
dependency identity, zero warnings, and no diagnostic override.

The two pair identities are:

```text
matched_ml    = lme4_ml   + glmmTMB_ml
matched_reml  = lme4_reml + glmmTMB_reml
```

Each pair requires exact environment, specification, and semantic-model
identity; both point gates; glmmTMB dependency identity; and b1 numerical
parity.

## Frozen tolerance registry

```text
covariance absolute   1e-4
covariance relative   1e-4
fixed absolute        1e-4
log-likelihood        1e-5
```

These are the existing Draft.85b1 comparison defaults. They are retained to
avoid changing the overlap contract immediately before qualification. Because
b1 diagnostic results are already known, c4f explicitly records
`OutcomeIndependentThresholdClaimed=FALSE`. These thresholds qualify adapter
wiring only; they are not recovery, accuracy, or operational decision
thresholds.

The future trusted worker must retain and revalidate the complete b1 lme4 fit,
glmmTMB fit, and parity objects. A summary maximum or pass flag alone is
insufficient because it cannot reproduce cell-wise combined
absolute-plus-relative covariance comparisons, schema integrity, row binding,
or semantic-model identity.

## Candidate route receipts

A candidate route receipt binds:

- policy, route, backend, and ML/REML criterion;
- environment, process, worker-source, specification, semantic-model, and fit
  result identities;
- fit return/integrity/gate/row/dependency states;
- fresh-process and diagnostic-override states; and
- warning count, fit status, and error class.

When every declared condition is satisfied, `CandidateReceiptReady=TRUE`.
Nevertheless every candidate receipt remains:

```text
SelfReportedSummary            = TRUE
FullB1ObjectsRevalidated       = FALSE
TrustedReceiptReady            = FALSE
OperationallyAdmissible        = FALSE
BackendQualificationReady      = FALSE
ExecutionAuthorized            = FALSE
```

Diagnostic override, any warning, dependency mismatch, non-fresh execution,
non-identified fit, failed return, or error class independently makes candidate
readiness false.

## Candidate pair receipts

A candidate pair binds the two route-candidate hashes, parity-result hash,
tolerance registry, and shared environment/specification/semantic identities.
A fully positive self-report may set `CandidatePairReady=TRUE`, but it remains
untrusted and operationally inadmissible because the full b1 objects have not
been revalidated.

Mixing ML and REML routes or mismatching route identities is rejected.
Rehashing a changed field cannot promote trust because all trust and execution
states are fixed false by the typed schema.

## Current admission state

c4f binds the exact c4e manifest and environment identity. c4e currently
reports the glmmTMB/TMB build-runtime mismatch, so no qualification execution
is eligible. The route and pair objects in the c4f manifest are empty
templates, not candidate receipts.

## Disposition

```text
QualificationPolicyReady                = TRUE
ReceiptSchemaReady                      = TRUE
CandidateReceiptEvaluatorReady          = TRUE
EnvironmentReadyForBackendQualification = FALSE
RepairRequired                          = TRUE
TrustedWorkerImplemented                = FALSE
RouteReceiptsMaterialized               = FALSE
PairReceiptsMaterialized                = FALSE
AllRouteReceiptsReady                   = FALSE
AllPairReceiptsReady                    = FALSE
QualificationEvidenceReady              = FALSE
BackendQualificationAdmissionReady      = FALSE
BackendQualificationReady               = FALSE
DiagnosticOverrideAllowed               = FALSE
PilotExecutionAuthorized                = FALSE
ConfirmationExecutionAuthorized         = FALSE
NegativeControlExecutionAuthorized      = FALSE
ExecutionGateClosed                     = TRUE
BackendExecutionOccurred                = FALSE
PlannedResponseGenerated                = FALSE
RecoveryExecuted                        = FALSE
RecoveryEvidenceReady                   = FALSE
EstimationReady                          = FALSE
InferenceReady                           = FALSE
DecisionReady                            = FALSE
PublicSupportReady                       = FALSE
```

No environment mutation, trusted receipt, estimator execution, or public
multivariate G-theory capability is created.
