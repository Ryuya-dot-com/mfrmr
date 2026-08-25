# Draft.85c4m multivariate G-theory truth-blind planned-adapter contract

Date: 2026-08-25  
Scope: opaque c1 planned-unit request and non-attempt receipt transport  
Public status: unsupported

## Purpose and boundary

Draft.85c4m binds the trusted c4l backend-qualification receipt to the three
canonical c1 candidate-handoff previews. It creates one opaque adapter request
per lane, passes each request through a sealed standalone worker, and records
a typed non-attempt receipt.

c4m proves payload and namespace separation. It does not prove operating-
system process-capability isolation. Consequently
`PayloadTruthBlindReady=TRUE`, while `TruthBlindProcessBoundaryReady=FALSE`.
The c3 prerequisite must not transition until the exact c4m worker and its
larger planned-request surface pass a separate capability-isolation gate.

c4m generates no response, candidate data, seed, truth, threshold, fit,
coefficient, recovery result, or execution authority. It does not invoke
ConQuest or modify a public package surface.

## Parent lineage

Manifest construction revalidates:

- the sealed c1 plan and c2 generator manifest;
- the canonical c3 admission manifest;
- c4e/c4f backend-admission and qualification-policy identities;
- the c4i repair, c4j full-object qualification, and c4k capability evidence;
  and
- the c4l backend-qualification integration receipt.

The c1/c2 hashes must join the c3 manifest, and the c3 hash must join c4l.
c4l must report backend qualification ready. Hash-only caller assertions cannot
replace parent revalidation.

## Three opaque lane requests

The controller creates requests for the three c1 lanes but does not expose the
stage name to the worker:

| Controller lane | Expected opaque units | Stage name visible to worker |
| --- | ---: | --- |
| pilot | 960 | no |
| confirmation | 19,200 | no |
| negative control | 8 | no |

Each request carries only:

- an opaque request ID and opaque lane ID;
- plan and c1 handoff hashes;
- the canonical c1 candidate-unit topology;
- candidate-unit schema and content hashes;
- expected unit count;
- the c4l receipt and trusted-route registry hashes; and
- a constant schema-only purpose.

The candidate-unit columns are exactly:

```text
OpaqueUnitId
OpaqueDatasetId
MethodId
MethodControlHash
CoordinateLayoutId
CoordinateCount
```

No request contains `StageId`, scenario identity, replicate, seed, assignment,
reference identity, expected pre-fit state, truth, generating parameter,
accuracy threshold, or candidate response data. The opaque IDs and hashes are
commitments; the worker receives no lookup table that reverses them.

## Standalone refusal worker

The worker source byte hash is bound before use. Its environment has
`baseenv()` as its parent and exactly four sealed functions. It validates the
exact request class, field order, candidate-unit
schema, identifier forms, hashes, counts, and closed readiness flags. It then
returns a typed receipt with:

```text
Attempted              = FALSE
CandidateDataReceived  = FALSE
BackendInvoked         = FALSE
CandidateExecutionOccurred = FALSE
CandidateCompletionSealed  = FALSE
TruthReleaseAuthorized     = FALSE
```

The controller statically rejects worker bodies containing calls to source,
file-reading, connection, download, or system-execution primitives. This is a
sealed-code and namespace property, not an OS sandbox result.

## Five access questions

The manifest answers the c3 isolation questions only at the payload level:

```text
scenario_identity   -> not present in request
data_seed           -> not present in request
reference_identity  -> not present in request
truth               -> not present in request
accuracy_threshold  -> not present in request
```

All rows descend exactly from the canonical c1 handoff projection and require
a process-capability recheck. `CandidateCanRead=FALSE` means the material is
absent from the request; it does not claim the current in-process worker is
unable to inspect unrelated host resources.

## c3 prerequisite semantics

c4m starts from c4l's 2-of-8 projection. It records adapter-schema evidence on
the `truth_blind_process_boundary` row but leaves that row false. No c3
prerequisite changes in c4m. External freeze, clean source, process isolation,
lane authority, candidate completion, and the independent confirmation
threshold remain missing.

The accepted readiness split is:

```text
BackendQualificationReady          = TRUE
AdapterRequestSchemaReady          = TRUE
AdapterReceiptSchemaReady          = TRUE
PayloadTruthBlindReady              = TRUE
RefusalTransportExercised           = TRUE

ProcessCapabilityIsolationAssessed = FALSE
ProcessCapabilityIsolationReady    = FALSE
TruthBlindProcessBoundaryReady      = FALSE
AllExecutionPrerequisitesReady     = FALSE
PilotExecutionAuthorized           = FALSE
ConfirmationExecutionAuthorized    = FALSE
NegativeControlExecutionAuthorized = FALSE
ExecutionGateClosed                = TRUE
```

## Fail-closed behavior

Changed parents, handoff rows, request or receipt fields, unit counts, hashes,
worker bindings, forbidden-call audit, access answers, prerequisite states,
implementation identity, or readiness flags are rejected. Request objects are
not retained in the final manifest; their canonical c1 source and per-lane
hashes remain reproducible.

The dispatch guard rejects candidate execution, every study lane, planned
response generation, recovery, and public promotion even when caller
authorization is true. A future capability-isolation result must be a new
successor receipt and cannot backdate c4m.
