# Draft.85c4i multivariate G-theory isolated ABI-repair contract

Date: 2026-08-24  
Scope: pinned TMB/glmmTMB source rebuild in a retained temporary overlay  
Public status: unsupported

## Purpose and boundary

Draft.85c4i executes the first five steps of the six-step repair plan frozen by
c4e. It creates a separate write destination, validates two pinned CRAN source
artifacts, installs TMB 1.9.25, rebuilds glmmTMB 1.1.14 against that TMB, and
reobserves package/native identity in a fresh R process.

The sixth c4e step—four completed qualification receipts—is not part of repair
and remains false. c4i does not receive a b1 fit object, fit any model, apply a
diagnostic override, produce a trusted qualification receipt, invoke ConQuest,
open a planned seed, or authorize an execution lane.

The overlay is write-isolated, not a capability sandbox. TMB and glmmTMB are
written only beneath a deterministic `/private/tmp` repair root; lme4, Matrix,
RcppEigen, digest, and the R runtime are resolved read-only from the existing
library order and are content-addressed in the fresh-process receipt. Therefore
`RepairProcessCapabilityIsolationReady=FALSE` even when the ABI repair passes.

## Pinned source artifacts

The accepted source set is exactly:

| Package | Version | CRAN source SHA-256 |
| --- | --- | --- |
| TMB | 1.9.25 | `cf9663b29949cd5eaccb32e11900c9e07caec7d6ac4f17cfd938317dc33acff2` |
| glmmTMB | 1.1.14 | `623c81cfe4b3c6825db15d44781eccf7a357cf15b423fe9f00459f52beeffbbd` |

The controller checks the filename, byte hash, package, version, Repository,
and Date/Publication read from each tarball's internal DESCRIPTION. A mirror,
local cache, or later download is accepted only when the bytes are identical.
Neither package is downloaded by the controller.

## Toolchain repair

The installed R 4.6 configuration names `/opt/gfortran/bin/gfortran` and
`/opt/gfortran` runtime directories that are absent. A default source build
therefore fails at link time before installing TMB. c4i does not mutate R's
Makeconf or install a compiler.

Instead, one temporary `R_MAKEVARS_USER` file binds the already installed
Homebrew GCC 15.2.0_1 gfortran and exact `libemutls_w`, `libheapt_w`,
`libgfortran`, and `libquadmath` files. The compiler executable, runtime files,
R/Rscript executables, their hashes, R's original `FC`/`FLIBS`, generated
Makevars, and eight-rule audit are retained in the receipt.

The override is local to both source-build child processes. The existing user
and system R libraries and R Makeconf remain unchanged.

## Build diagnostics

Both installs must return status zero and leave exact DESCRIPTION and native
DLL identities in the overlay. TMB must have no compiler warning. The observed
three glmmTMB warnings must all be the prespecified RcppEigen
`unused-but-set-variable` class. Any additional warning, linker warning, error,
changed warning count, or unclassified diagnostic fails the repair.

Thus `BuildDiagnosticsAdmissible=TRUE` and
`SourceBuildWarningFree=FALSE` are simultaneously correct. Build warnings are
not silently converted into fit-time warnings or qualification evidence.

## Fresh-process observation

The five-function standalone identity worker runs under `Rscript --vanilla`
with the repaired overlay first in `R_LIBS_USER`. It records exact versions,
paths, DESCRIPTION hashes, and native DLL hashes for lme4, glmmTMB, TMB,
Matrix, and RcppEigen. TMB and glmmTMB must resolve from the overlay; the three
read-only dependencies must resolve outside it.

The required ABI observation is:

```text
glmmTMB build-time TMB   1.9.25
runtime TMB              1.9.25
glmmTMB ABI              2
```

The child does not claim its own freshness. The controller establishes fresh-
process provenance from the separate status-zero invocation and then validates
the complete typed receipt.

## Retention and reuse

The successful overlay, pinned sources, Makevars, build logs, identity-worker
copy, fresh-process receipt, and repair receipt remain under one deterministic
temporary root. Default execution rejects an occupied root. Exact reuse is
optional and succeeds only after full source, toolchain, log, installed-file,
worker, implementation, receipt, and readiness revalidation.

An incomplete build is removed automatically. A successful retained artifact
is ephemeral validation state, not a package dependency or distributable
binary.

## Disposition

```text
IsolatedLibraryCreated                         = TRUE
PackageSourcesPinned                           = TRUE
SelectedTMBInstalled                           = TRUE
GlmmTMBRebuiltAgainstSelectedTMB               = TRUE
FreshProcessIdentityReobserved                  = TRUE
FourRouteReceiptsCompleted                      = FALSE
RepairExecuted                                  = TRUE
RepairReceiptReady                              = TRUE
DefaultRFortranToolchainReady                   = FALSE
ToolchainOverrideReady                          = TRUE
SourceBuildWarningFree                          = FALSE
BuildDiagnosticsAdmissible                      = TRUE
RepairedEnvironmentABIMatch                     = TRUE
RepairedEnvironmentReadyForBackendQualification = TRUE
RepairProcessCapabilityIsolationReady           = FALSE
QualificationWorkerImplemented                  = FALSE
FullB1ObjectsReceived                           = FALSE
RouteReceiptsMaterialized                       = FALSE
PairReceiptsMaterialized                        = FALSE
TrustedReceiptProduced                          = FALSE
QualificationEvidenceReady                      = FALSE
BackendQualificationReady                       = FALSE
DiagnosticOverrideAllowed                       = FALSE
PilotExecutionAuthorized                        = FALSE
ConfirmationExecutionAuthorized                 = FALSE
NegativeControlExecutionAuthorized              = FALSE
ExecutionGateClosed                             = TRUE
BackendExecutionOccurred                        = FALSE
PlannedResponseGenerated                        = FALSE
RecoveryExecuted                                = FALSE
RecoveryEvidenceReady                           = FALSE
EstimationReady                                  = FALSE
InferenceReady                                   = FALSE
DecisionReady                                    = FALSE
PublicSupportReady                               = FALSE
```

Repair readiness is an environment-intake result. It is necessary but not
sufficient for any backend-qualification, estimation, or public claim.
