# Draft.85c4j multivariate G-theory full-object qualification contract

Date: 2026-08-24  
Scope: repaired-overlay four-route execution and complete-object revalidation  
Public status: unsupported

## Purpose and boundary

Draft.85c4j consumes the retained c4i ABI-repair receipt and executes the four
routes frozen by c4f: lme4 ML, lme4 REML, glmmTMB ML, and glmmTMB REML. A
standalone worker returns four complete b1 fit objects and the complete ML and
REML b1 parity objects. The controller independently validates every fit,
reconstructs both parity objects, and materializes four revalidated route
receipts and two revalidated pair receipts.

This is numerical backend-qualification evidence, not operational trust. The
worker is a fresh process but has not yet been run under a capability profile
qualified for full-object intake, package/DLL loading, model fitting, and
receipt output. Consequently `BackendQualificationNumericallyReady=TRUE` may
coexist with `QualificationEvidenceReady=FALSE`,
`BackendQualificationReady=FALSE`, and `OperationallyAdmissible=FALSE`.

c4j does not generate a planned response, open a protected seed, compute a
G-theory coefficient, invoke ConQuest, or modify the public package surface.

## Bound inputs

The qualification request binds:

- the exact c4i repair-receipt hash and retained overlay path;
- the c4f manifest, policy, route, pair, and tolerance identities;
- five staged a0/b0/b1/c4f source files and their byte hashes;
- the fifteen-function standalone worker identity and source hash;
- the fixed b1 synthetic fixture seed `85021`; and
- covariance absolute/relative tolerances `1e-4`, fixed-effect absolute
  tolerance `1e-4`, and log-likelihood absolute tolerance `1e-5`.

The worker uses no dependency-mismatch diagnostic override. Its package
registry must exactly equal the c4i fresh-process registry, including package
versions, paths, DESCRIPTION hashes, and native DLL hashes.

After fitting, the worker also captures the complete loaded-namespace and
loaded-native-binary closure. This prevents the later capability profile from
silently granting read access to an entire user library merely because five
primary packages were named in c4i.

## Complete-object contract

Summary-only status is insufficient. The child receipt retains these exact
objects:

```text
lme4_ml
lme4_reml
glmmTMB_ml
glmmTMB_reml
matched_ml
matched_reml
```

For every fit the parent reruns the b1 integrity assertion and verifies the
specification, semantic model, complete serialized object, result payload,
backend rows, point-estimation gate, fit status, warning count, ABI state, and
diagnostic-override state. For both pairs it reconstructs the full b1 parity
object from the two retained fits and requires exact object equality.

## Pair acceptance semantics

Covariance cells use the b1 combined rule

```text
absolute_difference <= 1e-4 + 1e-4 * scale
```

where `scale` is the larger absolute backend estimate, bounded below by
machine epsilon. The relative tolerance is therefore not an independent
requirement that every reported relative difference be at most `1e-4`.
Fixed effects use an absolute `1e-4` rule. Backend-reported Gaussian log
likelihoods, their degrees of freedom, and observation counts must match under
the `1e-5` rule.

Every pair also requires both route point gates, dependency identity, exact
specification identity, and exact criterion-specific semantic-model identity.
ML and REML are never compared as one pair.

## Fresh-process provenance and retention

The worker does not assert its own freshness. The controller launches a
separate `Rscript --vanilla` process, requires status zero and empty process
output, checks that the child PID differs from the controller PID, verifies
the R/Rscript executable hashes, and confirms that the repair overlay is first
in the library order.

The staged source, worker copy, request, complete worker receipt, and final
controller receipt remain under a deterministic child directory of the c4i
repair root. Exact reuse is allowed only after the current source, worker,
parents, complete objects, derived parity objects, receipts, and all readiness
states revalidate. The artifact is ephemeral validation evidence and is not a
package dependency.

## Trust boundary

The following distinction is mandatory:

- `CandidateQualificationEvidenceReady=TRUE` means all four complete route
  objects and both complete pair objects passed numerical revalidation in a
  separately launched process.
- `QualificationEvidenceReady=FALSE` means the process has not yet passed the
  full-object capability-isolation gate.
- `BackendQualificationReady=FALSE` and `OperationallyAdmissible=FALSE` mean
  no downstream execution or public claim may consume the candidate evidence.

Rehashing a worker self-report, a fit object, a route receipt, a pair receipt,
or a readiness flag cannot promote trust. The next gate needs a new runtime-
bound capability receipt for this exact worker and its larger access surface.

## Disposition

```text
QualificationWorkerImplemented             = TRUE
FreshProcessQualificationExecuted          = TRUE
FreshProcessVerified                       = TRUE
FreshProcessOutputEmpty                    = TRUE
FullB1FitObjectsReceived                   = TRUE
FullB1ParityObjectsReceived                = TRUE
FullB1ObjectsRevalidated                   = TRUE
RouteReceiptsMaterialized                  = TRUE
PairReceiptsMaterialized                   = TRUE
AllRouteRevalidatedReceiptsReady           = TRUE
AllPairRevalidatedReceiptsReady            = TRUE
BackendQualificationNumericallyReady       = TRUE
CandidateQualificationEvidenceReady        = TRUE
ProcessCapabilityIsolationAssessed         = FALSE
ProcessCapabilityIsolationReady            = FALSE
TrustedReceiptProduced                     = FALSE
QualificationEvidenceReady                 = FALSE
BackendQualificationReady                  = FALSE
OperationallyAdmissible                    = FALSE
DiagnosticOverrideAllowed                  = FALSE
ExecutionGateClosed                        = TRUE
BackendExecutionOccurred                   = TRUE
PlannedResponseGenerated                   = FALSE
RecoveryExecuted                           = FALSE
RecoveryEvidenceReady                      = FALSE
EstimationReady                            = FALSE
InferenceReady                             = FALSE
DecisionReady                              = FALSE
PublicSupportReady                         = FALSE
```
