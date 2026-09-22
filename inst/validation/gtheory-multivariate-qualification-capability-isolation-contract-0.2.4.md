# Draft.85c4h multivariate G-theory qualification-refusal capability contract

Date: 2026-08-24  
Scope: hash-only c4g refusal path under a runtime-bound macOS sandbox  
Public status: unsupported

## Purpose and claim boundary

Draft.85c4h places the exact c4g refusal worker and its hash-only request under
a default-deny operating-system profile. It proves that this one refusal path
can read the staged request and write its typed non-attempt receipt while
selected filesystem, environment, and executable capabilities remain absent.

The promoted claim is narrower than backend qualification. The current c4e
environment still has a glmmTMB build/runtime TMB mismatch. c4h neither repairs
that environment nor implements a qualification-capable worker. It receives no
fit specification, response table, full b1 object, planned seed, truth object,
reference result, route authority, or diagnostic override.

The claim applies only to the exact Darwin/R/Apple-profile and worker identity
sealed in the live evidence. It is not a portable Linux, container, future-
macOS, or production qualification certificate.

## Sealed worker path

The c4h runtime binds:

- the c4g manifest and c4f protocol roots;
- the exact c4g refusal request and seven-function refusal worker;
- the exact four-function c4h capability wrapper;
- `sandbox-exec`, `env`, the direct R executable, Apple `system.sb`, and the
  installed digest runtime; and
- the generated profile, policy audit, six control receipts, and controller
  implementation identity.

The c4g and c4h worker source hashes are fixed constants in the controller.
Source drift cannot become canonical merely by reconstructing a new runtime
identity.

## Default-deny boundary

The profile begins with `(deny default)` and imports the exact hashed Apple
`system.sb`. It permits the minimum R process/runtime reads, reads under the
staged input/worker/output/scratch directories, and writes only under staged
output/scratch. The repository validation directory, denied vault, and
forbidden-output directory are absent from allow rules.

The direct R process is launched through `env -i` with only `R_HOME`, `TMPDIR`,
`PATH`, `LANG`, `LC_ALL`, and `TZ`. A synthetic parent-only environment value
must not be visible. `ExternalNetworkPolicyClosed=TRUE` means that c4h adds no
general external-network allow and invokes no network operation; the imported
Apple profile may still permit selected local system IPC.

## Six controls

Each mode runs in a separate sandbox invocation:

| Mode | Required result |
| --- | --- |
| `normal` | exact c4g refusal receipt succeeds |
| `probe_vault_read` | synthetic denied-vault read fails |
| `probe_source_read` | repository c4g source read fails |
| `probe_outside_write` | write outside output/scratch fails |
| `probe_parent_environment` | parent secret is absent |
| `probe_unlisted_exec` | `/bin/cat` execution fails |

All six processes must exit normally after writing a typed control result. Only
the normal action succeeds. An unexpected exit, missing result, successful
negative action, visible parent secret, created outside file, changed denial
class, or altered hash/readiness field fails closed.

The vault is a deterministic synthetic token bound to the request hash. It
contains no planned seed, response, reference result, or truth. Its purpose is
only to prove that an unallowlisted file cannot be read.

## Disposition

```text
DefaultDenyProfileReady                   = TRUE
SanitizedEnvironmentReady                 = TRUE
HashOnlyInputReadReady                    = TRUE
RefusalReceiptWriteReady                  = TRUE
SyntheticVaultReadDenied                  = TRUE
SourceTreeReadDenied                      = TRUE
OutsideWriteDenied                        = TRUE
ParentEnvironmentSecretAbsent             = TRUE
UnlistedExecutableDenied                  = TRUE
ExternalNetworkPolicyClosed               = TRUE
ProcessCapabilityIsolationReady           = TRUE
HashOnlyRefusalBoundaryReady               = TRUE
FreshProcessRefusalObserved                = TRUE
RefusalOnlyWorkerReady                     = TRUE
EnvironmentReadyForBackendQualification   = FALSE
RepairRequired                             = TRUE
QualificationWorkerImplemented             = FALSE
FullB1ObjectsReceived                      = FALSE
RouteReceiptsMaterialized                  = FALSE
PairReceiptsMaterialized                   = FALSE
TrustedReceiptProduced                     = FALSE
QualificationEvidenceReady                 = FALSE
BackendQualificationReady                  = FALSE
DiagnosticOverrideAllowed                  = FALSE
PilotExecutionAuthorized                   = FALSE
ConfirmationExecutionAuthorized            = FALSE
NegativeControlExecutionAuthorized         = FALSE
ExecutionGateClosed                        = TRUE
BackendExecutionOccurred                   = FALSE
PlannedResponseGenerated                   = FALSE
RecoveryExecuted                           = FALSE
RecoveryEvidenceReady                      = FALSE
EstimationReady                             = FALSE
InferenceReady                              = FALSE
DecisionReady                               = FALSE
PublicSupportReady                          = FALSE
```

Capability isolation is ready only for the hash-only refusal path. It supplies
no evidence that a future full-object qualification worker is isolated or
statistically correct.
