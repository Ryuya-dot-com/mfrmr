# Draft.85c4e multivariate G-theory backend-qualification admission contract

Date: 2026-08-24  
Scope: read-only package/native identity, repair plan, and receipt templates  
Public status: unsupported

## Purpose and boundary

Draft.85c4e defines the evidence required before the four c3 matched-backend
routes may be qualified. It does not repair the R library, download or install
a package, rebuild native code, fit a model, generate a planned response,
invoke ConQuest, or authorize a lane.

The contract keeps four states separate:

1. the required packages are present;
2. the glmmTMB build-time and runtime TMB versions agree;
3. package DESCRIPTION and native DLL identities are available; and
4. all four fresh-process qualification receipts exist.

No state is inferred from another. Numerical agreement obtained under the b1
diagnostic override is not a qualification receipt.

## Upstream binding

The c4e manifest pins the unchanged c1 plan, c3 admission manifest, c4d
source-freeze admission manifest, c4d candidate-artifact digest, and current
matched-backend source digest. Binding the c4d admission object does not assert
that c4d obtained a clean source, immutable artifact, or external receipt.
Those readiness states remain false.

## Environment identity

The environment identity contains:

- the complete typed c3 snapshot;
- R version and platform inherited from that snapshot;
- lme4, glmmTMB, and TMB versions and installation paths;
- SHA-256 identities for each package DESCRIPTION and native DLL;
- the build-time TMB identity observed directly from the loaded glmmTMB
  namespace;
- the runtime TMB version; and
- the glmmTMB ABI version.

`BuildIdentityMatchesLoadedNamespace` requires the supplied c3 build identity
to equal the loaded namespace observation. `DependencyABIMatch` separately
requires build-time TMB to equal runtime TMB. Therefore a rehashed synthetic
ABI-match snapshot that contradicts the loaded binary is ineligible before it
can reach manifest readiness.

The manifest then reconstructs the complete environment identity a second
time. `EnvironmentReadyForBackendQualification` requires exact equality with
that live reconstruction and all environment eligibility conditions.

## Current mismatch

The observed environment is:

```text
lme4                 2.0.6
glmmTMB              1.1.14
glmmTMB build TMB    1.9.23
runtime TMB          1.9.25
glmmTMB ABI          2
```

All three package/native identities are available, and the c3 build identity
agrees with the loaded glmmTMB namespace. The build/runtime TMB versions do not
agree. Consequently:

```text
NativeBinaryIdentityReady                 = TRUE
BuildIdentityMatchesLoadedNamespace       = TRUE
DependencyABIMatch                        = FALSE
EnvironmentReadyForBackendQualification   = FALSE
RepairRequired                            = TRUE
```

This is an exact local evidence disposition, not a claim that these package
versions are generally incompatible.

## Declarative repair plan

The six required evidence steps are:

```text
isolated_library_created
package_sources_pinned
selected_tmb_installed
glmmtmb_rebuilt_against_selected_tmb
fresh_process_identity_reobserved
four_route_receipts_completed
```

All `CurrentSatisfied` and `MutatingActionExecuted` values are false. The plan
does not contain executable installation commands. A later authorized action
must materialize independently auditable receipts; editing these flags cannot
make the c4e object canonical.

## Four route receipts

The route registry is exactly:

```text
lme4_ml
lme4_reml
glmmTMB_ml
glmmTMB_reml
```

Each receipt template binds its route and environment identity but has missing
qualification-receipt, fit-specification, and fit-result identities.
`FreshProcess=FALSE`, `DiagnosticOverrideUsed=NA`, and `ReceiptReady=FALSE`.
All four receipts must ultimately exist, come from the same qualified
environment, use no diagnostic override, and pass the later numerical and
structural qualification policy. c4e does not define those completed receipts.

## Fail-closed behavior

Changed package or DLL hashes, a contradictory c3 snapshot, mutated upstream
roots, altered routes, manufactured receipts, or rehashed readiness fields are
rejected against newly reconstructed objects. Caller authorization cannot
dispatch either environment repair or route qualification.

## Disposition

```text
SourceFreezeAdmissionBound               = TRUE
CleanSourceIdentityReady                  = FALSE
ExternalFreezeReady                       = FALSE
EnvironmentIdentityMatchesCurrentProcess = TRUE
CandidateEnvironmentEligible             = FALSE
RequiredPackagesAvailable                 = TRUE
BuildIdentityMatchesLoadedNamespace       = TRUE
DependencyABIMatch                        = FALSE
NativeBinaryIdentityReady                 = TRUE
EnvironmentReadyForBackendQualification   = FALSE
RepairPlanConstructed                     = TRUE
RepairRequired                            = TRUE
RepairExecuted                            = FALSE
AllRouteReceiptsReady                     = FALSE
BackendQualificationAdmissionReady        = FALSE
BackendQualificationReady                 = FALSE
DiagnosticOverrideAllowed                 = FALSE
PilotExecutionAuthorized                  = FALSE
ConfirmationExecutionAuthorized           = FALSE
NegativeControlExecutionAuthorized        = FALSE
ExecutionGateClosed                       = TRUE
BackendExecutionOccurred                  = FALSE
PlannedResponseGenerated                  = FALSE
RecoveryExecuted                          = FALSE
RecoveryEvidenceReady                     = FALSE
EstimationReady                            = FALSE
InferenceReady                             = FALSE
DecisionReady                              = FALSE
PublicSupportReady                         = FALSE
```

No environment mutation, estimator execution, ConQuest route, or public
multivariate G-theory capability is created.
