# Draft.85c4a multivariate G-theory candidate/receipt preflight contract

Date: 2026-08-24  
Scope: nonreserved fixture payload and namespace separation  
Public status: unsupported

## Purpose and claim boundary

Draft.85c4a implements the first executable shape behind the c3 isolation
template: a candidate envelope and a typed receipt returned by a standalone
worker. It uses only the 12 c2 nonreserved fixtures and never fits a model.

This gate distinguishes three levels that must not be collapsed:

1. candidate-column separation;
2. R namespace and payload separation; and
3. OS/process capability isolation.

c2 established the first level. c4a establishes the second by sourcing a
standalone worker into an environment whose parent is exactly `baseenv()` and
whose complete binding set contains four worker functions. It does not
establish the third: a same-user R environment is not an operating-system read
barrier. Therefore `ProcessCapabilityIsolationReady` and
`TruthBlindProcessBoundaryReady` remain false.

## Candidate envelope

The worker receives one exact object containing:

```text
Contract
OpaqueCandidateId
EvidenceUse
CandidateData
CandidateDataHash
CandidateSchemaHash
ExpectedRows
EnvelopeHash
CandidatePayloadOnly
BackendExecutionAuthorized
RecoveryDenominatorEligible
PublicSupportReady
```

`CandidateData` has exactly:

```text
RowId Stratum Object Rater ObjectRater Replicate Score
```

It contains no fixture, scenario, assignment, reference, seed, generating
factor, component effect, residual effect, truth, threshold, or backend-control
field. The opaque candidate identity is derived only from the candidate data
and schema hashes. Both controller and worker recompute it, preventing a
mutated and self-consistently rehashed data table from retaining a stale token.

Every envelope is fixture-only, ineligible for a recovery denominator, and
unauthorized for backend execution.

## Standalone worker

The worker file defines exactly four bindings:

```text
mfrmr_gtvgw_hash
mfrmr_gtvgw_exact_object
mfrmr_gtvgw_candidate_schema
mfrmr_gtvgw_receive
```

It is sourced with `baseenv()` as parent. No c1 plan function, c2 generator
function, truth/reference/seed/scenario-named object, callback, estimator, file
reader, or external process launcher is present. `digest` is the only namespace
resolved during receipt hashing.

The worker validates the exact object, column types, finite scores, row count,
data/schema/envelope hashes, opaque token, and closed readiness flags. Unknown
fields or attributes fail closed.

## Receipt semantics

The worker returns an exact non-attempt receipt. It binds the opaque candidate,
envelope, data, schema, and row-count identities, and reports:

```text
Attempted         = FALSE
FitReturned       = FALSE
EstimateAvailable = FALSE
PointGatePassed   = FALSE
FailureStage      = backend_not_invoked_fixture_schema_preflight
FailureCode       = C4A-CANDIDATE-RECEIPT-SCHEMA-ONLY
```

This is not a c1 recovery failure. The rows are nonreserved fixture preflights
and are not members of any pilot, confirmation, structural-control, or metric
denominator. The receipt demonstrates schema closure only.

## Reference-vault handling

For the controller audit, each opaque candidate is temporarily associated with
its fixture, scenario, reference, seed, generation, and truth-audit identities.
Only the SHA-256 hash and row count of that mapping enter the c4a manifest. The
mapping content is not retained, and no vault field enters an envelope or
receipt.

This proves content exclusion from the worker payload and final manifest. It
does not prove that a future worker process lacks filesystem capability to
discover a vault. A later OS-specific or containerized gate must demonstrate a
deny-by-default read boundary, sanitized arguments/environment, separated
output location, and failure controls before process truth blindness can turn
true.

## Disposition

```text
CandidateEnvelopeSchemaReady       = TRUE
CandidateReceiptSchemaReady        = TRUE
WorkerNamespaceSeparationReady     = TRUE
CandidatePayloadAllowlistReady     = TRUE
ReferenceVaultContentExcluded      = TRUE
ProcessCapabilityIsolationReady    = FALSE
TruthBlindProcessBoundaryReady     = FALSE
BackendQualificationReady          = FALSE
PilotExecutionAuthorized           = FALSE
ConfirmationExecutionAuthorized    = FALSE
BackendExecutionOccurred           = FALSE
PlannedResponseGenerated           = FALSE
RecoveryExecuted                   = FALSE
RecoveryEvidenceReady              = FALSE
EstimationReady                    = FALSE
InferenceReady                     = FALSE
DecisionReady                      = FALSE
PublicSupportReady                 = FALSE
```

No ConQuest, lme4, or glmmTMB process is invoked. c4a does not modify the c1,
c2, or c3 readiness objects and adds no public package surface.
