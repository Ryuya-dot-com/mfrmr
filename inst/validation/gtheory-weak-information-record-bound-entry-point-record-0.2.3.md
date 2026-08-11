# Weak-information record-bound entry-point record

## Result

The b1g23 record-bound reserved-entry implementation passes its nonreserved
scientific reduction and exact-resume checks. The result closes the
implementation portions of `RESERVED-ENTRY-01` and `ACTIVE-MANIFEST-01`; it
does not issue a production authorization or active R0201 manifest.

R0201, calibration, confirmation, inference, and large simulation remain
sealed. The repository reserved root and its lock are absent.

## Portable identities

| Artifact | SHA-256 / scientific hash |
|---|---|
| b1g22 no-go decision | `3df37fa52c9ff688bd5110d4ae097a8fed10123eb898f9967fdcb5fd791c9ab6` |
| R0201 prospective manifest | `dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9` |
| entry policy | `61ee07c4ea86087a7ad8731ef374b38ec7f12621cc8e818501f4e4bab85abd07` |
| entry contract | `0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a` |
| reduction record | `c1c08749050445743e6938357b64aed921fc6b620fdbec31c3586ea40c2f0af0` |
| active reduction manifest | `2221cc38bf526b1cf7d0f66d59090b1af7b1c8b9cbdc6f144caaa06c57399f3a` |
| base checkpoint manifest | `f19fae6e4aab925e84416ef1f58d9435e07c5d22af70438dcb291c95481f620a` |
| entry source | `eec3a92a69aa1d1378137342094e536c4c71c3674b15c7a1260869cbcb0d1394` |
| isolated worker | `a2ed1788b2ad96f3feb298beee67bff2aa99e8d97f3a874f6ed2bd32c3e799cd` |
| contract document | `c57a0a7587aded046a0cf5b36fb1db9174100d09864d364ef23e1946eb6904ca` |
| focused test | `0c843684516767cd875bd1c9a092c56864c4211c425d63cdca2b36aaa78cb7c0` |

Run receipts bind disposable absolute paths and timing/output details, so they
are validated but not presented as portable identities.

## Parent-core evidence

| Layer | Parent hash | Admission-stripped core hash |
|---|---|---|
| b1g17 generator | `8a644cf5b512d3e66bcd729ff00e64db3801ab741490092697dc5b170c445986` | `8c5a59ac392fe048cf437a7c36f021ecc1f4dbccb69d7df365306acd7059d170` |
| b1g18 prepare | `5e786d135a50fcbeb01fedb168d0f86cdb6986187db0e355a6d3aac6601de6e7` | `94d55cb209c99959adf772f9e92329a1e42c6e806921b32a833ecf604dbc073d` |
| b1g13 execute | `1e2b73c4e26c44586a859b6dda9dd2343ed0d435cec416cbc4982accaf7a2e02` | `d718ee9d716d81d8dc4149a8d2dd3a337c98c8d5d299ebdea895487204d0bd25` |

Every transformation requires one and only one exact parent admission
expression. The scientific generator, preparation, fitting, reference,
candidate-decision, checkpoint, marker, and complete-ledger bodies are reused.

## Observed nonreserved reduction

| Quantity | b1g21 | b1g23 |
|---|---:|---:|
| datasets | 1 | 1 |
| atomic units | 4 | 4 |
| candidate fits | 36 | 36 |
| candidate decisions | 192 | 192 |
| references | 8 | 8 |
| returned fits | 35 | 35 |
| typed fit failures | 1 | 1 |

Candidate fits, candidate decisions, and references are exactly equal. The
initial isolated child computes four units. The second child observes
`exact_resume`, computes zero, reuses four, and reproduces the scientific
execution hash.

Four focused tests with 75 explicit assertions pass. They cover source and
scientific identities, full-row reduction, complete denominators, exact
resume, R0201 counts, generator/adapter/runner admission separation, no direct
capability-less generation, reduction-record rejection on R0201, absent
production issuer, and contract/record/capability/manifest/job/result mutation
controls.

The runtime is measured in minutes because this is the real 36-fit numerical
path. Runtime is planning information, not an acceptance threshold and not a
reason to enlarge the simulation.

## R0201 non-execution evidence

- The exact prospective R0201 manifest validates at 30 datasets, 120 units,
  1,080 fits, 5,760 decisions, and 240 references.
- A nonreserved reduction record cannot activate it.
- Direct reserved preparation without a validated ephemeral capability fails.
- The production entry point rejects the reduction record.
- No `mfrmr_gtwar_issue_authorization_record` function exists.
- The production validator requires a full six-gate issuance-decision object,
  not an arbitrary decision string.
- The repository reserved root and `.mfrmr-lock` remain absent.

## Gate interpretation

| State | Result |
|---|---|
| reserved entry implementation | ready |
| active-manifest conversion implementation | ready |
| production issuance decision | not run |
| fresh site receipt bound to record | false |
| production authorization record issued | false |
| active R0201 manifest issued | false |
| replicate 201 may open | false |
| large simulation may start | false |

Thus b1g23 converts the b1g22 no-go from three missing implementations to one
remaining issuance-time decision boundary. “Implementation ready” must not be
reported as “execution authorized.”

## Next bounded action

Run a response-free b1g24 issuance preflight that refreshes runtime and site
receipts, validates the six exact gates, and produces either:

- a no-go record with R0201 still sealed; or
- one immutable R0201 authorization record and its derived active manifest.

Only the latter permits one shard. Its 1,080/5,760/240 denominators and typed
failures must be reviewed before any continuation. Full 100-shard calibration
remains out of scope, preserving attention for the eventual scientific goals:
numerical-rule calibration, G-study/D-study recovery and uncertainty, then
sparse/unbalanced and multivariate evidence.
