# Draft.85c4g multivariate G-theory qualification-worker preflight contract

Date: 2026-08-24  
Scope: sealed worker bundle and fresh-process refusal receipt  
Public status: unsupported

## Purpose and boundary

Draft.85c4g builds and exercises only the refusal boundary needed before a
trusted four-route qualification worker can exist. A fresh R process receives
a hash-only request and returns a typed non-attempt receipt because the c4e
environment remains ineligible.

c4g does not repair the R library, receive a fit specification or response,
load full b1 fit objects, call lme4 or glmmTMB, use a diagnostic override,
produce a trusted receipt, invoke ConQuest, or authorize execution.

## Sealed source bundle

The exact eight-file future worker bundle contains:

```text
design/hash primitives
multivariate matrix-audit primitives
incidence validator
b1 fit/parity validator
c3 environment snapshot
c4e environment admission
c4f qualification protocol
c4g refusal-only worker
```

The c4f protocol manifest, complete bundle registry, and worker source roots
are fixed constants in the controller. Recalculating hashes after changing an
upstream source or worker cannot create a canonical c4g manifest.

The bundle is an inventory, not a claim that the current refusal worker has
implemented qualification. The standalone worker namespace contains exactly
seven functions for hashing, exact-schema checks, request validation, refusal
receipt construction/validation, and command-line RDS transport. It contains
no estimator or package-install call.

## Request boundary

The worker request carries only:

- c4f protocol and qualification-policy hashes;
- c4e environment identity;
- bundle, worker-source, route-registry, and pair-registry hashes;
- the four route identifiers; and
- fixed false execution, planned-seed, and ConQuest states.

It contains no fit specification, backend data, score, seed, candidate
response, truth audit, or reference payload. The mode is exactly
`environment_refusal_preflight`, and the worker rejects a rehashed request
whose environment-ready or backend-authorized state is changed to true.

## Fresh-process receipt

The controller writes the request to temporary staging and launches the exact
local `Rscript --vanilla` with the sealed worker source. The child process
validates the request and returns:

```text
Disposition                 environment_not_ready_no_backend_attempt
FullB1ObjectsReceived       FALSE
BackendAttempted            FALSE
DiagnosticOverrideUsed      FALSE
TrustedReceiptProduced      FALSE
RefusalReceiptReady         TRUE
QualificationEvidenceReady FALSE
BackendQualificationReady   FALSE
ExecutionAuthorized         FALSE
```

The child does not self-assert that it is fresh. The parent controller records
`FreshProcessRefusalObserved=TRUE` from the successful separate-process exit
and revalidates the complete receipt. This avoids treating a claim inside the
receipt as evidence of process provenance.

The process is not run under the c4b default-deny capability profile.
Therefore `ProcessCapabilityIsolationReady=FALSE`; this result establishes a
fresh process and exact transport only, not filesystem or environment
isolation.

## Fail-closed behavior

Changed source roots, added worker functions, altered request fields, rehashed
execution readiness, mutated receipts, trust promotion, or caller
`authorize=TRUE` are rejected. The worker is intentionally unable to accept a
ready environment: a future qualification-capable worker requires a distinct
contract and identity after the ABI repair.

## Disposition

```text
WorkerBundleRegistryReady               = TRUE
RequestSchemaReady                      = TRUE
RefusalOnlyWorkerReady                  = TRUE
FreshProcessRefusalObserved             = TRUE
EnvironmentReadyForBackendQualification = FALSE
RepairRequired                          = TRUE
ProcessCapabilityIsolationReady         = FALSE
QualificationWorkerImplemented          = FALSE
FullB1ObjectsReceived                    = FALSE
RouteReceiptsMaterialized               = FALSE
PairReceiptsMaterialized                = FALSE
TrustedReceiptProduced                  = FALSE
QualificationEvidenceReady              = FALSE
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

No environment mutation, backend attempt, trusted qualification receipt, or
public multivariate G-theory capability is created.
