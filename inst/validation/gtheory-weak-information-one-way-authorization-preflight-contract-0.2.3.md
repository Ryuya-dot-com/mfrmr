# Draft.83d2b2b1g15 response-free one-way authorization preflight contract

Status: completed repository-only authorization-readiness slice, 2026-08-10.
This contract tests whether the already sealed stationarity-calibration work
could be activated safely. It does not issue an authorization record, make a
prospective shard executable, generate or inspect calibration replicates
201--300, or access confirmation replicates 501--700.

## Logical separation

The gate deliberately separates three propositions:

1. the workload, code, runtime, and prospective shard identities are frozen;
2. the current output site and conservative resource plan pass a response-free
   preflight; and
3. an immutable execution authorization has been issued.

b1g15 can establish the first two propositions but cannot establish the
third. Consequently `AuthorizationReadinessAuditReady=TRUE` and
`AuthorizationActivationEligible=TRUE` coexist with
`ExecutionAuthorizationRecordIssued=FALSE`,
`CalibrationAuthorizationReady=FALSE`, and
`CalibrationExecutionAuthorized=FALSE`. This is intentional, not a partially
updated state.

## Exact inherited identity

The preflight accepts only the b1g14 adapter contract
`baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1`,
reserved manifest
`019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8`,
preflight audit
`eddbe9cb3e1ab56d3389f9f896524f0bf0ae92b224b2997f4e5f6014219a31cf`,
nonreserved execution
`b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae`,
and runtime
`94cb18393b87ef8409f231b2e62c507f43fb3294cdefeb0f3e8c19c8235e7753`.
Hash or runtime drift fails closed.

The authorization-preflight contract separately hashes its policy, frozen
nonreserved measurement receipt, source registry, all 19 b1g15 functions,
adapter identities, dependency identities, output root, and inherited
receipts. Validating a hash never changes an authorization flag.

## Prospective shard manifests

The exact b1g14 unit assignment is recast as 100 content-addressed prospective
manifests, `R0201` through `R0300`. Each manifest contains one replicate over
all 30 scenarios and all four methods:

| Ledger | Per shard | Total |
| --- | ---: | ---: |
| independent datasets | 30 | 3,000 |
| atomic dataset-method units | 120 | 12,000 |
| candidate-fit rows | 1,080 | 108,000 |
| candidate-decision rows | 5,760 | 576,000 |
| high-accuracy reference rows | 240 | 24,000 |

The bundle validator checks ordered shard coverage, unique output
subdirectories and hashes, exact union of all 12,000 unit identities, all
per-shard counts, and all aggregate counts. These objects are planning
manifests, not runner manifests: every shard and unit remains
`ExecutionAuthorized=FALSE`, and the b1g14 production adapters reject direct
reserved-unit calls without a later immutable authorization hash.

## Filesystem preflight

The probe resolves the repository root and the parent of the exact frozen
output target. It rejects a filesystem root, home directory, absolute or
parent-traversing output path, missing parent, target that already exists, or
target outside the package root.

`file.access(..., mode = 2)` is retained only as advisory evidence because an
access result can become stale and does not prove that the intended operation
will succeed. The decisive probe therefore creates a temporary directory in
the actual output parent, writes an RDS sentinel, installs it with a checked
same-directory `file.rename()`, reads the identical sentinel back, and verifies
cleanup. The output target itself is never created. Same-directory placement
avoids relying on nonportable cross-filesystem rename behavior. A checked
`system2()` call to `df -Pk` supplies a site-specific free-space observation;
command status, output hash, filesystem, mount point, and available bytes are
part of the dynamic probe identity.

The probe is a point-in-time observation. It is neither a portability claim
nor permission to execute. Runtime identity, target absence, write/rename/
readback behavior, and free space must all be rechecked at activation.

## Conservative resource plan

Planning uses one real nonreserved b1g14 four-lane run, not a synthetic timing
fixture. Its frozen measurement receipt contains four checkpoint sizes
(2,955, 2,969, 3,573, and 3,588 bytes), a 671-byte dataset marker, a 124,728-
byte combined ledger object, and 89.047 seconds across all four methods.

Raw storage extrapolation is

`12,000 * max(checkpoint bytes) + 3,000 * marker bytes +
3,000 * ledger bytes = 419,253,000 bytes`.

The admission bound multiplies this by 32 and then preserves 32 GiB of free
space, requiring 47,775,834,368 available bytes. This deliberately absorbs
serialization, logs, filesystem allocation, checkpoint replacement, and
unmodeled overhead. Runtime planning multiplies the one-dataset observation by
3,000 datasets and a factor of four: 296.823333 serial hours, or 2.968233
hours for one 30-dataset shard. At most one shard may run concurrently; early
stopping is prohibited.

These are conservative admission rules, not performance guarantees or
statistical evidence. An activation review must reject or revise the plan if
the current site no longer satisfies either bound.

## Confirmation and analysis firewall

No calibration response, generated truth, fitted result, candidate cutoff, or
diagnostic result is an input to this preflight. Confirmation access is false.
Prospective shard ordering and capacity are fixed without looking at an
outcome, and execution cannot stop early. The full calibration denominator
must be completed and integrity-checked before any global candidate analysis.

The following remain false or unauthorized:

- execution authorization, calibration generation, and result viewing;
- stationarity threshold and production-criterion readiness;
- bootstrap and confirmation authorization;
- inference, coefficient, decision, public-support, and D-study readiness; and
- release-checklist promotion.

## Acceptance rule

`AuthorizationReadinessAuditReady=TRUE` requires all of the following at once:

- exact upstream and b1g15 contract identities and current runtime match;
- exactly 100 non-executable prospective manifests and the exact six workload
  totals above;
- an absent output target and successful actual write, same-directory rename,
  identical readback, cleanup, and `df -Pk` observation in its parent;
- current available bytes at least 47,775,834,368;
- the frozen 296.823333-hour serial and 2.968233-hour per-shard planning bounds,
  with one concurrent shard;
- no early stopping or confirmation access; and
- no authorization, data-generation, result-viewing, inference, or decision
  flag becoming true.

Mutation of any contract, manifest, shard, filesystem, resource, or derived
readiness field must invalidate the object rather than be accepted because a
stored Boolean remains true.

## Next admissible gate

A separately reviewed Draft.83d2b2b1g16 artifact may bind the exact b1g15
contract and shard hashes, repeat the runtime/filesystem/resource checks, and
issue an immutable activation record. The authorized runner must accept only
the activated prospective shard, preserve single-shard scheduling, complete
failure denominators and exact resume, and keep confirmation inaccessible.
Authorization must be one-way: the activation decision is made from sealed
identities and preflight state, not from calibration outcomes.

Only after that separate artifact exists may opening replicate 201 be
reconsidered. Completing a shard still cannot select or report a threshold;
global aggregation, complete-denominator integrity, candidate evaluation, and
confirmation authorization remain later gates.

## Sources

- Morris, T. P., White, I. R., and Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. *Statistics in Medicine*, 38,
  2074--2102. https://doi.org/10.1002/sim.8086
- R Core Team. `file.access` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/base/help/file.access.html
- R Core Team. File manipulation and `file.rename` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/base/html/files.html
- R Core Team. `system2` documentation:
  https://stat.ethz.ch/R-manual/R-devel/library/base/html/system2.html
