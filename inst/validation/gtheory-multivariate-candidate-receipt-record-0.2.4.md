# Draft.85c4a multivariate G-theory candidate/receipt preflight record

Date: 2026-08-24  
Scope: fixture-only candidate envelope, standalone worker, and non-attempt
receipt  
Result: namespace/payload separation ready; process capability isolation false

## Outcome

Draft.85c4a passes all 12 c2 nonreserved fixture responses through the exact
candidate envelope. A standalone four-function worker validates each envelope
and returns a typed schema-only receipt without invoking a backend.

Nine focused tests and 85 expectations pass without failure, error, warning,
or skip. The combined Draft.85a0 through c4a suite passes 73 tests and 1,014
expectations with the same clean disposition.

No c1 pilot, confirmation, or negative-control seed was opened. No planned
response, backend estimate, recovery metric, or evidence denominator was
created. lme4, glmmTMB, and ConQuest at `/Applications/ConQuest` were not
launched.

## Fixture and receipt coverage

The receipt registry contains 12 distinct opaque candidate identities. Its row
counts reproduce the c2 fixtures:

```text
two-stratum regular/boundary    720 240 240 576 720 720
three-stratum regular/boundary  1080 360 360 864 1080 1080
```

Every receipt has `Attempted=FALSE`, `FitReturned=FALSE`,
`EstimateAvailable=FALSE`, and `PointGatePassed=FALSE`, with the common code
`C4A-CANDIDATE-RECEIPT-SCHEMA-ONLY`. These are deliberately outside every c1
denominator.

Unknown envelope fields, stale opaque tokens, changed scores with recomputed
data/envelope hashes, opened backend flags, changed receipts, and additional
worker bindings all fail closed.

## Separation audit

The worker environment has `baseenv()` as parent and exactly four bindings.
It contains no c1/c2 function or truth/reference/seed/scenario-named binding.
The candidate envelope contains only identifiers needed by the backend design
and the generated score. The final manifest retains a reference-vault hash and
row count, but not the mapping content.

This is a namespace and payload result. It is not a claim that a same-user
worker lacks operating-system permission to inspect unrelated files. The
strong process-isolation and truth-blind states remain false.

## Replay identities

```text
CoreHash                         9226fa5d8b425705337ef337bc384bd942abb3142ea19ce3adffcda1ab495bb3
CandidateReceiptRegistryHash     976bc07b0441bda2c9eecd9f6ac56042934503a75ed56d61a68160520a00c81c
NamespaceAuditHash               fbdc8cd1b9719618420fc2d54d3d755c3d82953619f31a0c558b784cd8d964a8
ReferenceVaultHash               40a8a33734d12a3cd3facf9da4c38848a95dacfdcb02e046e3e3dab8f860653a
WorkerIdentityHash               1dc35fb4a2cb48330232d9b1ab80fd9b1c462ffb04c958457d9a4611da5e7683
ControllerIdentityHash           5bdcf56ee2dc663bc2e5b9f889def6435630c5cf88fc1785a13eac63f55a66bd
ManifestHash                     aa0a3e95103e3d694b89fbba97a570668d5fd462bde75ca28df5dc6fdbe0e7ee
```

These identities bind the local fixture replay and implementation. They are
not an external freeze receipt, a process sandbox certificate, execution
authority, or recovery evidence.

## Disposition

Candidate-envelope schema, receipt schema, worker namespace separation,
payload allowlisting, and vault-content exclusion are ready. OS capability
isolation, external freeze, clean source identity, ABI-consistent four-route
qualification, independent accuracy thresholds, and every execution authority
remain incomplete.

Draft.85c4a adds no export, help topic, vignette, NEWS entry, or public-roadmap
claim. Multivariate G-theory remains unsupported publicly.
