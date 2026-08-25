# Draft.85c4o fit-candidate envelope and dispatch contract

Status: internal preflight contract  
Scope: candidate-data release, four-route input schema, and denominator binding  
Public support: none

## Purpose

Draft.85c4o defines the object that a future fit-capable candidate process may
receive. It closes the gap between c4m's topology-only non-attempt request and
the wider input required to fit one candidate dataset. It does not implement
that fit worker, execute an estimator, generate a planned candidate, or
authorize a study lane.

A schema capable of describing an allowed backend dispatch is not evidence
that the backend implementation is correct or that its process lacks access to
protected material.

## Required ancestry

The controller reconstructs and validates:

- the c1 A-D-E-M-P plan and its 20,168-unit manifest;
- the c2 generator and nonreserved fixture registry;
- the c3 execution-admission manifest;
- c4e/c4f environment and qualification policy;
- c4i repair, c4j qualification, and c4k qualification-capability evidence;
- the c4l trusted backend integration receipt;
- the c4m three-lane topology adapter; and
- the c4n non-attempt adapter capability evidence.

The exact c4n evidence must still report the fit-capable truth-blind boundary
false. c4o cannot inherit that stronger claim from c4n's narrower program.

## Authority separation

The contract names three authorities:

1. `generator_vault` may use scenario, assignment, seed, reference, and truth
   material to generate candidate responses but may not fit a backend;
2. `candidate_release_transform` may read the generated candidate table and
   release only the candidate allowlist; and
3. `candidate_fit_contract` may consume released data and an allowlisted
   qualified route, but may not read protected generator material.

The first two are exercised inside the controller on a nonreserved fixture.
The third is a contract only. It is not implemented or process-isolated in
c4o. The authority registry therefore records schema separation but keeps
process-capability assessment false for every row.

## Candidate-data release

c2 candidate data have seven columns:

```text
RowId Stratum Object Rater ObjectRater Replicate Score
```

c4o releases exactly seven, replacing the raw within-cell ordinal with an
opaque observation link:

```text
RowId Stratum Object Rater ObjectRater ObservationLink Score
```

The c2 `Replicate` column is the within-Object-by-Rater observation ordinal,
not the planned dataset replicate. Removing it without replacement would make
the two observations in each cell indistinguishable and would violate the b1
unique observation-link contract. c4o therefore derives `ObservationLink`
from Object, Rater, and that within-cell ordinal under a separate namespace,
then removes the raw ordinal. The link is stable across strata for the same
observation unit, unique within each stratum, and cannot be joined to a
planned dataset replicate or seed. No stage, scenario, assignment, planned
replicate, seed, reference, generating value, truth audit, boundary class,
expected state, or accuracy threshold enters the released table.

The contract worker independently validates:

- exact fields, classes, attributes, and finite scores;
- nonempty, unique `RowId` values;
- the `OL-` plus 24-hex observation-link syntax, unique
  Stratum-by-Object-by-link identities, and one ObjectRater identity per link;
- exact A/B or A/B/C stratum support for the coordinate layout;
- `ObjectRater == paste(Object, Rater, sep = "\\036")` for every row;
- coordinate counts 10 or 19 for the two- or three-stratum layout;
- data and schema hashes; and
- the opaque exercise identity recomputed from data, schema, method,
  method-control, and c4l receipt roots.

A self-consistently rehashed table cannot retain a stale opaque ID. A mutated
grouping column is also rejected after its data and envelope hashes are
recomputed.

## Four-route envelope

The contract contains the c1 method identity and its c4l qualification route:

| c1 method | c4l route | backend | criterion |
| --- | --- | --- | --- |
| `lme4_reml` | `lme4_reml` | lme4 | REML |
| `glmmtmb_reml` | `glmmTMB_reml` | glmmTMB | REML |
| `lme4_ml` | `lme4_ml` | lme4 | ML |
| `glmmtmb_ml` | `glmmTMB_ml` | glmmTMB | ML |

Each envelope binds the exact c1 method-control hash, coordinate layout and
count, c4l receipt hash, and c4l trusted-route-registry hash. The route registry
also retains the trusted qualification receipt, fit specification, semantic
model, and qualification capability state.

The envelope's backend-execution authorization is false. The route contract
states what a successor worker may invoke after separate implementation and
capability gates; it does not make the c4o contract worker capable of doing so.

## Contract worker

The standalone worker has exactly five functions under `baseenv()`. A 13-call
audit excludes file, connection, process, lme4, and glmmTMB execution calls.
It validates each envelope and returns a typed non-attempt receipt with:

```text
EnvelopeAccepted            = TRUE
Attempted                   = FALSE
BackendInvoked              = FALSE
FitReturned                 = FALSE
FitCapableWorkerImplemented = FALSE
FailureCode                 = C4O-FIT-WORKER-NOT-IMPLEMENTED
```

Worker self-reported readiness values remain false and are not promotion
evidence.

## Planned topology

c4o does not create a new denominator. It projects the c1 candidate-unit
manifest and checks it against c4m:

| Lane | datasets | method units |
| --- | ---: | ---: |
| pilot | 240 | 960 |
| confirmation | 4,800 | 19,200 |
| negative control | 2 | 8 |
| total | 5,042 | 20,168 |

Every dataset has exactly four method units. The c4o nonreserved fixture is
not a member of these denominators, and its envelope, data, protected-source
audit content, and receipt objects are not retained in the manifest. Only
their schemas, hashes, and compact exercise rows are retained.

## Access questions

The exact envelope and candidate-data fields are checked against all five c3
access classes: scenario identity, data seed or replicate identity, reference
identity, truth or generating state, and accuracy threshold.

All are absent. Every row still requires a fit-worker capability recheck,
because c4o has not implemented the program that will read candidate data and
invoke a backend.

## Readiness and c3 projection

c4o may set these contract-level states true:

- candidate release transform ready;
- observation-linked candidate schema ready;
- raw within-cell ordinal removed and pair identity retained;
- four-route envelope and receipt contracts ready;
- backend qualification bound and inherited ready;
- planned denominator topology bound;
- second denominator absent;
- authority-separation contract ready; and
- payload protected-material exclusion ready.

It must keep these false:

- fit-capable worker implemented;
- fit-capable process capability isolation ready;
- truth-blind process boundary ready;
- every lane authorization;
- backend and candidate execution;
- completion, truth release, and denominator accounting; and
- recovery, estimation, inference, decision, and public support.

Exactly zero c3 prerequisites transition. The count remains 2 of 8 and partial
execution remains prohibited.

## Dispatch and successor

The dispatch guard validates the full manifest and always refuses, including
when `authorize=TRUE`.

The next slice should implement the exact fit-capable worker on nonreserved
fixture data only. It must consume this envelope, call one of the four bound
routes, and return a typed fit receipt while remaining outside every planned
denominator. That new worker must subsequently pass its own default-deny
capability run before c3's truth-blind prerequisite can transition.
