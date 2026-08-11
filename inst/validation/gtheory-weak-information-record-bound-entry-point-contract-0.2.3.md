# Weak-information record-bound entry-point contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g23`
- Entry policy:
  `61ee07c4ea86087a7ad8731ef374b38ec7f12621cc8e818501f4e4bab85abd07`
- Entry contract:
  `0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a`
- Nonreserved reduction record:
  `c1c08749050445743e6938357b64aed921fc6b620fdbec31c3586ea40c2f0af0`
- Active nonreserved reduction manifest:
  `2221cc38bf526b1cf7d0f66d59090b1af7b1c8b9cbdc6f144caaa06c57399f3a`
- Base checkpoint manifest:
  `f19fae6e4aab925e84416ef1f58d9435e07c5d22af70438dcb291c95481f620a`
- Entry source:
  `eec3a92a69aa1d1378137342094e536c4c71c3674b15c7a1260869cbcb0d1394`
- Isolated worker:
  `a2ed1788b2ad96f3feb298beee67bff2aa99e8d97f3a874f6ed2bd32c3e799cd`
- Focused test:
  `0c843684516767cd875bd1c9a092c56864c4211c425d63cdca2b36aaa78cb7c0`

## Scope

b1g23 implements the two response-free prerequisites identified by the b1g22
no-go decision:

1. a reserved-capable entry point that cannot reach generation without an
   exact issued record, active manifest, runtime/site receipts, lock, marker,
   and ephemeral execution capability; and
2. a deterministic prospective-to-active manifest conversion for exactly
   `R0201`.

It does not issue the production record and does not construct a production
active manifest. No reserved response, fit, checkpoint, target, or lock is
created. `SITE-RECEIPT-01` and separate issuance remain downstream.

## Three-level admission repair

Exact-source inspection found three independent nonreserved admissions in the
scientific path:

| Parent | Admission retained in parent | Reused core hash |
|---|---|---|
| b1g17 hardened generator | rejects calibration 201--300 and confirmation 501--700 | `8c5a59ac392fe048cf437a7c36f021ecc1f4dbccb69d7df365306acd7059d170` |
| b1g18 preparation adapter | rejects both reserved bands | `94d55cb209c99959adf772f9e92329a1e42c6e806921b32a833ecf604dbc073d` |
| b1g13 checkpoint runner | permits only its nonreserved mechanics run | `d718ee9d716d81d8dc4149a8d2dd3a337c98c8d5d299ebdea895487204d0bd25` |

The parent function hashes are respectively
`8a644cf5b512d3e66bcd729ff00e64db3801ab741490092697dc5b170c445986`,
`5e786d135a50fcbeb01fedb168d0f86cdb6986187db0e355a6d3aac6601de6e7`,
and
`1e2b73c4e26c44586a859b6dda9dd2343ed0d435cec416cbc4982accaf7a2e02`.

b1g23 does not copy those scientific bodies. It locates exactly one expected
admission expression in each parent abstract syntax tree, removes it, and
binds the remaining body to the new record check. Missing, duplicated, or
changed admission text fails closed. Parent and reused-core function hashes,
as well as complete entry and worker source hashes, enter the policy identity.

## Ephemeral capability

An active capability is process-local and short-lived. It binds:

- the b1g23 contract hash;
- active-manifest hash;
- authorization/reduction-record hash; and
- execution mode.

Capability creation revalidates the contract, active manifest, and mode-
specific record. Preparation and generation revalidate the capability hash
again. The capability is released on success and on error. A direct call to
the adapter or generator without it fails before generation.

For a future production run, the regenerated data receive a new identity that
binds the issued record and active manifest while retaining the complete b1g17
parent generator identity and data hashes. Confirmation replicates remain
inaccessible. The nonreserved reduction continues to use the unchanged b1g17
identity.

## Production record schema

No production issuance function exists in b1g23. A later record is admissible
only if it contains:

- a hash-valid `one_shard_issuance_decision_b1g24_v1` object with all six
  gates (`ENTRY-01`, `ACTIVE-CONVERSION-01`, `RUNTIME-01`,
  `SITE-RECEIPT-01`, `SCOPE-01`, `CONFIRM-01`) passing;
- the exact R0201 prospective manifest;
- fresh hash-valid b1g20 runtime and site receipts for the exact target;
- one-shard scope, complete denominators, no early stopping, and no
  confirmation access; and
- `AuthorizationRecordIssued=TRUE` inside the record hash.

The decision object, runtime/site objects, record, active manifest, child job,
lock owner, activation marker, execution, and receipt form a one-way chain.
An arbitrary nonempty “decision hash” is insufficient.

## Manifest conversion

The frozen R0201 source remains
`dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9`
with exact denominators:

| Quantity | Count |
|---|---:|
| datasets | 30 |
| atomic units | 120 |
| candidate fits | 1,080 |
| candidate decisions | 5,760 |
| references | 240 |

Conversion retains every prior atomic identity as provenance, adds the record
hash and execution flags, recomputes every active atomic identity, and creates
both a base checkpoint manifest hash and an extended active-manifest hash.
The conversion cannot be called with the nonreserved reduction record.

## Scientific reduction

The only executable b1g23 fixture is nonreserved replicate 902. One isolated
child under the inherited serial runtime, exclusive lock, and activation
marker runs four method units. Its 36 candidate-fit rows, 192 decisions, and
eight references are exactly equal to b1g21; 35 fits return and the same one
typed failure remains. A second child computes zero and reuses all four
checkpoints under exact resume.

This reduction validates reuse and control flow. It is not calibration
evidence and cannot estimate the production runtime of all 120 R0201 units by
itself.

## Remaining boundary

Implementation readiness is narrower than activation readiness:

- `ReservedEntryPointImplementationReady=TRUE`;
- `ActiveManifestConversionImplementationReady=TRUE`;
- `AuthorizationRecordIssued=FALSE`;
- `ActiveReservedManifestIssued=FALSE`;
- `FreshSiteReceiptBound=FALSE`;
- `AuthorizationRNG01Closed=FALSE`;
- `LargeSimulationMayStart=FALSE`; and
- `Replicate201MayBeOpened=FALSE`.

The next decision must collect fresh runtime/site receipts, construct and
validate the separate six-gate issuance object, and either issue or refuse one
R0201 record. No larger calibration is eligible before complete review of that
single shard.
