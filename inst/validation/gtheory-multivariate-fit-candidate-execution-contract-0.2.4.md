# Draft.85c4p nonreserved fit-candidate execution contract

Status: completed internal implementation preflight  
Scope: one nonreserved fixture, four qualified routes, no recovery denominator  
Public support: none

## Purpose

Draft.85c4p implements the fit-capable process that c4o deliberately omitted.
It establishes that the released candidate schema is sufficient to construct
the exact Draft.85b1 matched Gaussian model and obtain normalized fit receipts
from lme4 and glmmTMB under ML and REML. It is implementation evidence, not a
planned pilot, recovery result, capability-isolation result, or public API.

## Corrected observation identity

The initial c4o design removed the c2 `Replicate` field outright. Review
against b1 showed that this field is a within-Object-by-Rater observation
ordinal, not the protected planned dataset replicate. Without an equivalent
link, the two observations in a cell have an ambiguous within-stratum pair
identity.

c4o was therefore revised before c4p. Its released data are:

```text
RowId Stratum Object Rater ObjectRater ObservationLink Score
```

`ObservationLink` is an opaque deterministic identity derived from Object,
Rater, and the raw within-cell ordinal. The raw ordinal is not released. On
the 720-row fixture, the b1 specification observes zero duplicate
within-stratum keys and 360 shared observation links across strata A and B.

## Exact model and route binding

Every route builds the same b1 specification:

- fixed effects: stratum-specific means without an intercept;
- Object, Rater, and Object:Rater: global unstructured stratum covariance
  matrices;
- Residual: one common homoskedastic independent variance;
- observation-link columns: Rater and ObservationLink;
- missingness: complete;
- no optimizer-control override; and
- no glmmTMB dependency diagnostic override.

The request binds the c4o envelope, c4l receipt, c4i repaired overlay, c1
method-control hash, trusted qualification-route receipt, qualification
specification hash, qualification semantic-model hash, source registry, worker
source, component map, and observation-link contract.

The c4l qualification specification and semantic-model hashes are ancestry
evidence from a separate qualification fixture. The candidate fit obtains its
own data-dependent specification and semantic-model identities; the two are
not falsely required to be equal.

## Process and source execution

The controller stages exactly five sources plus the standalone worker. It
launches one distinct fresh R process for each route with the c4i repair
overlay first in `.libPaths()`. Each worker returns the complete normalized b1
fit object and a compact receipt. The controller independently revalidates
the fit identity, row binding, specification, component order, coordinate
extraction, process identity, package registry, and receipt hash.

Package observation is route-minimal:

- lme4 routes load `digest` and `lme4`;
- glmmTMB routes load `digest`, `glmmTMB`, and `TMB`.

This reduces the future c4q capability surface. It does not itself prove that
unlisted packages, files, environment values, executables, or networks are
unreachable.

## Result contract

All four routes must report:

```text
Attempted                    = TRUE
BackendInvoked               = TRUE
FitReturned                  = TRUE
FitStatus                    = identified_point_fit
PointEstimationGatePassed    = TRUE
FitCapableWorkerImplemented  = TRUE
```

Each route extracts the exact ten-coordinate `T2-GLOBAL-3C-R1` layout in c1
order. The controller also applies the existing b1 backend comparison to the
ML and REML pairs. Both numerical-parity and both-point-gate conditions must
pass.

## Scope and readiness

The exercised fixture is a c2 nonreserved fixture and is absent from the c1
pilot, confirmation, negative-control, and recovery denominators. No planned
scenario, planned replicate, seed, reference, truth, boundary class, or
accuracy threshold is supplied to the worker.

c4p may set worker implementation, exact staging, four-route nonreserved fit,
coordinate extraction, and matched-backend parity ready. It must keep process
capability isolation, the c3 truth-blind boundary, every planned lane,
completion, truth release, denominator accounting, recovery, inference,
decision, and public support false. Exactly zero c3 prerequisites transition;
the count remains 2 of 8.

## Successor gate

Draft.85c4q should run this unchanged fit worker and exact request semantics
under default deny. Its normal modes must reproduce all four fit receipts, and
its denial modes must cover protected-vault and repository reads, outside
writes, parent-environment inheritance, unlisted execution, network access,
and any package/file capability added by the fit-capable program. Only that
evidence can be considered for the c3 truth-blind process prerequisite.
