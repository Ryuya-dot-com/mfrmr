# Draft.85c4l multivariate G-theory backend-qualification integration contract

Date: 2026-08-25  
Scope: c4k trusted qualification projection into c4e/c3 admission state  
Public status: unsupported

## Purpose and boundary

Draft.85c4l creates a non-executing integration receipt. It revalidates the
complete c3 through c4k lineage, records completion of the six c4e repair-plan
rows, replaces the four empty c4e receipt lanes with trusted successor rows,
retains both matched-pair receipts, and changes exactly one c3 prerequisite:
`all_four_matched_backends_qualified`.

The historical c3 manifest and c4e manifest remain byte-for-byte inputs. c4l
does not edit, rehash, or reinterpret them as if they had been ready when
created. The receipt is a successor projection with its own contract and hash.

c4l does not generate a planned response, open a seed or truth vault, invoke a
backend fit, invoke ConQuest, execute recovery, compute a G coefficient,
authorize inference or decisions, or change any public package surface.

## Required lineage

Receipt construction requires successful revalidation of:

- the sealed c1 plan and c2 generator through the canonical c3 manifest;
- the current historical c4e environment/repair-plan manifest;
- the c4f four-route/two-pair qualification policy;
- the retained c4i repair receipt and fresh-process ABI identity;
- the retained c4j complete-object qualification receipt; and
- the c4k live capability evidence, including its normal run and five denial
  controls.

The c4i, c4j, and c4k hashes must join exactly. The c4e route order must equal
the four c4k trusted route IDs. A summary-only or rehashed self-report cannot
enter this receipt.

## Six-step repair projection

The c4e repair plan remains the governing row order:

1. isolated library created;
2. package sources pinned;
3. selected TMB installed;
4. glmmTMB rebuilt against the selected TMB;
5. fresh-process identity reobserved; and
6. four route receipts completed.

Rows 1--5 bind c4i overlay, source, build, and fresh-process identities. Row 6
binds the c4j qualification receipt plus the c4k trusted route and pair
registries. Every row records its mutation scope. All rows explicitly state
that the original R libraries were not mutated.

The c4e template's environment hash remains visible as historical lineage; it
is not relabelled as the repaired environment. Each successor route row binds
the separate c4i fresh-process repair receipt hash.

## Trusted route and pair projection

Exactly four route rows are admitted:

```text
lme4_ml
lme4_reml
glmmTMB_ml
glmmTMB_reml
```

Each row binds backend and criterion, the historical c4e template environment,
the repaired-environment receipt, the c4j revalidated route receipt, fit
specification/result hashes, the c4k sandbox full-object hash, and the c4k
capability-profile semantic hash. Fresh-process, dependency-ABI, full-object,
capability-isolation, diagnostic-override, and final receipt states must all
match the trusted evidence.

Exactly two pair rows are admitted: `matched_ml` and `matched_reml`. Each binds
both route IDs, c4j pair receipt, c4k sandbox parity object, model identities,
and all numerical, point-gate, dependency, and exact-model checks.

## c3 prerequisite projection

The eight c3 prerequisite IDs and their order remain fixed. c4l records prior
and projected states separately. Exactly one transition is allowed:

```text
all_four_matched_backends_qualified: FALSE -> TRUE
```

`no_diagnostic_override` remains the one previously satisfied prerequisite.
Thus the projected count is exactly 2 of 8. The other six stay false:

- external freeze receipt;
- clean source identity;
- truth-blind process boundary;
- lane-specific authority;
- candidate completion before truth release; and
- independent accuracy threshold before confirmation.

No prerequisite permits partial execution. A caller cannot convert backend
qualification evidence into study-lane authority.

## Readiness semantics

The accepted state is deliberately split:

```text
RepairPlanCompleted                 = TRUE
AllRouteReceiptsReady               = TRUE
AllPairReceiptsReady                = TRUE
BackendQualificationAdmissionReady  = TRUE
BackendQualificationReady           = TRUE
IntegrationReceiptReady             = TRUE

AllExecutionPrerequisitesReady      = FALSE
StudyOperationallyAdmissible        = FALSE
PilotExecutionAuthorized            = FALSE
ConfirmationExecutionAuthorized     = FALSE
NegativeControlExecutionAuthorized  = FALSE
ExecutionGateClosed                 = TRUE
RecoveryEvidenceReady               = FALSE
EstimationReady                     = FALSE
InferenceReady                      = FALSE
DecisionReady                       = FALSE
PublicSupportReady                  = FALSE
```

`QualificationBackendExecutionObserved=TRUE` refers only to the already
completed c4j/c4k qualification fits. `PlannedStudyBackendExecutionOccurred`
remains false.

## Fail-closed behavior

Changed parent objects, source or worker identities, route/pair order, fit or
parity hashes, repair evidence, prerequisite states, implementation identity,
payload hashes, or readiness flags are rejected. Rehashing a modified
prerequisite table cannot create a canonical receipt. The dispatch guard
rejects pilot, confirmation, negative-control, planned-response, recovery, and
public-promotion callbacks even when caller authorization is true.

The retained receipt is platform- and evidence-specific. It is internal
validation evidence, not a package input or public capability claim.
