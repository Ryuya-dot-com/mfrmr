# Draft.85c3 multivariate G-theory execution-admission contract

Date: 2026-08-24  
Scope: repository-only closed execution gate  
Public status: unsupported

## Purpose

Draft.85c3 binds the sealed c1 ADEMP content and c2 fixture-tested generator
to an execution-admission boundary. It does not repair the R environment,
create an external receipt, open a planned seed, generate a planned response,
fit a backend, or authorize a pilot. Its result is deliberately a closed gate
whose blockers are typed and independently inspectable.

The gate addresses a common sequencing error: package availability, an ABI
match, a successful single-backend fit, or a caller-supplied `authorize=TRUE`
must not be mistaken for authority to execute the recovery plan.

## Environment identity

The read-only environment snapshot records:

- R version and platform;
- availability and versions of lme4, glmmTMB, and TMB;
- the TMB version against which glmmTMB was built;
- the runtime TMB version;
- the four permitted matched routes; and
- an explicit absence of a ConQuest route.

`EnvironmentReadyForBackendQualification` requires all three packages and an
exact glmmTMB build/runtime TMB version match. Even when it is true,
`BackendQualificationReady` remains false until separate acceptable receipts
exist for lme4 ML, lme4 REML, glmmTMB ML, and glmmTMB REML. No diagnostic ABI
override is allowed in an evidence route.

ConQuest at `/Applications/ConQuest` is not invoked. The c1 recovery estimand
contains only the four matched R backends; adding ConQuest would require a
separate semantic model, extraction, comparison, and authority contract.

## Independent evidence objects

The manifest contains four kinds of deliberately incomplete template:

1. The c1 external-freeze receipt template binds the plan, source commit/tree,
   artifact digest, timestamp, authority, and external anchor.
2. The accuracy-rule template reproduces all six c1 criteria with missing
   numeric thresholds. It records that neither pilot nor confirmation outcome
   was consulted. A real rule requires an independently cited and hashed basis.
3. The isolation template requires hashes for the candidate executor, input
   schema, receipt schema, and withheld reference vault. Its five information-
   access questions remain unanswered, so column separation is not promoted to
   process truth blindness.
4. Three lane-authority templates keep pilot, confirmation, and deterministic
   negative-control authority separate. No token, signer, timestamp, or expiry
   is populated.

Templates are evidence of a required schema, not evidence that the requirement
has been met. Rehashing a template after changing a readiness flag cannot make
it canonical.

## Eight prerequisite states

Draft.85c3 replays the eight c1 prerequisites in their original order:

```text
external freeze receipt
clean source identity
all four matched backends qualified
truth-blind process boundary
lane-specific authority
candidate completion before truth release
accuracy threshold before confirmation
no diagnostic override
```

Only the last policy statement is currently satisfied: diagnostic override is
prohibited. This does not make any lane partially executable. In particular,
an ABI repair can change only the environment-qualification state; it cannot
manufacture four fit receipts or satisfy any external, isolation, authority,
completion, or accuracy requirement.

Pilot results may evaluate feasibility, schema behavior, failure paths, and
resource use. They may not select accuracy thresholds. Confirmation requires a
separately frozen independent accuracy rule and separate authority, and its
rows may never be pooled with pilot rows.

## Dispatch boundary

The guarded dispatcher accepts only:

```text
lme4_ml
lme4_reml
glmmTMB_ml
glmmTMB_reml
```

It validates the complete canonical manifest before considering a stage,
backend, callback, or caller authorization flag. Under the c3 contract every
stage flag is false and `ExecutionGateClosed=TRUE`; therefore the callback is
unreachable. Tests use a side-effect counter to verify that rejection occurs
before response generation or backend dispatch. `authorize=TRUE` is necessary
in a future successor but is never sufficient by itself.

The c3 manifest contains no planned data seed, fixture seed, response,
candidate data, truth audit, scenario identity, or reference identity. It
binds upstream work only through content hashes. Consequently, evaluating the
admission object cannot accidentally consume a c1 RNG stream.

## Current disposition

```text
PlanIdentityReady                       = TRUE
GeneratorPreflightReady                 = TRUE
EnvironmentABIMatch                     = environment dependent
EnvironmentReadyForBackendQualification = environment dependent
ExternalFreezeReady                     = FALSE
CleanSourceIdentityReady                 = FALSE
IndependentAccuracyRuleReady            = FALSE
TruthBlindProcessBoundaryReady           = FALSE
BackendQualificationReady               = FALSE
PilotExecutionAuthorized                 = FALSE
ConfirmationExecutionAuthorized          = FALSE
NegativeControlExecutionAuthorized       = FALSE
ExecutionGateClosed                      = TRUE
BackendExecutionOccurred                 = FALSE
PlannedResponseGenerated                 = FALSE
RecoveryExecuted                         = FALSE
RecoveryEvidenceReady                    = FALSE
EstimationReady                          = FALSE
InferenceReady                           = FALSE
DecisionReady                            = FALSE
PublicSupportReady                       = FALSE
```

The next admissible operational step remains external to this repository-only
preflight: repair and freeze the glmmTMB/TMB environment, seal a clean source
identity and external plan receipt, then validate an actually isolated
candidate/receipt adapter. A pilot still requires an explicit, lane-specific
successor authorization after those conditions are met.
