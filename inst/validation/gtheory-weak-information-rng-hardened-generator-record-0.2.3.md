# Weak-information RNG-hardened generator replay record

## Decision

Draft.83d2b2b1g17 completes the prospective generator repair but does not
activate it in the production adapter chain. The separately versioned wrapper
is deterministic across ambient RNG kinds for all 30 scenarios, preserves the
historical generator identity, restores caller state, and refuses reserved
replicates. `RNG-ADAPTER-01` therefore remains a blocker, as do all other
b1g16 runtime and execution blockers. No reserved response was opened.

## Reproduced identities

| Artifact | SHA-256 / scientific hash |
|---|---|
| RNG policy | `9d54aeee4e7cf9bc3b20e8e96fa99dfa79febf070cc0d732377287ce897e20a9` |
| function-hash registry | `8d7a998844dbb482b605915382ab0b3409f6d2caff0a4f37559a74f1fa5aa2c9` |
| hardened generator function | `428c98d225abc51e13b8e07e625d242d3a94c1e2a2d54e34f98b429b00785612` |
| 30-scenario replay manifest | `d3fe95bc5eae79dbc76e622fb2767eb3b0d14a378c767eaaf15872685ca351f7` |
| cross-ambient replay | `39054c3ef7b78783065134ee38303d73d3c6601edfddc8e68cebb8990949f955` |
| hardened-generator contract | `90869c6874e2884b7bf5bc96c1939bd95d1b41603ea76a1d2b1c617f32c700d2` |
| hardened-generator audit | `918e7da5e0ba484bbdef4251965c25ff31c5d4a39be237c3d218ed47fceae397` |
| R source file | `1c52cf15ba003928e35673ca376af8545ed3109543763ee3b06159c160b1ced9` |
| contract document | `30c2b4598738bd6c92fab89d073268f73d98ea76fa33b339ea67e8d43558e6f6` |
| focused test file | `84fdec08fed9d49eddf38ab281336c0e6a0a25102b4d0979290275dc41c0e8a8` |

Four focused tests with 67 explicit assertions pass.

## Replay result

- Registered scenarios: 30.
- Nonreserved replicate: 901.
- Ambient caller configurations per scenario: 2.
- Nonreserved engineering datasets generated: 60.
- Hardened generator-hash mismatches: 0.
- Analysis-data-hash mismatches: 0.
- Historical parent-hash mismatches inside the wrapper: 0.
- Caller-state restoration failures: 0.
- Calibration responses generated or used: 0.
- Confirmation responses generated or used: 0.

The last equality does not mean that the historical generator is safe in
arbitrary ambient state. It means that the wrapper sets the required state
before invoking the historical generator. The b1g16 unwrapped negative
control remains valid and intentionally differs across ambient states.

The parent function hash is taken from the frozen b1g16 contract rather than
recomputed after executing the historical closure. A local double-check found
that serialized body digests can be execution-state sensitive even while the R
language body remains `identical()`. b1g17 now hashes canonical deparsed syntax;
contract-before-replay and replay-before-contract builds reproduce exactly.
The separately recorded source-file SHA and cross-process scientific hashes
prevent that implementation detail from rewriting historical lineage.

## Boundary controls

The validation exercises three caller-state paths:

1. an existing alternate RNG kind and existing `.Random.seed`;
2. no pre-existing `.Random.seed`; and
3. a request for reserved replicate 201, which must error before generation.

All paths restore the caller's RNG kind and seed existence/value. Mutation of
the recorded required RNG kind is rejected even after recomputing the outer
generator hash. A forged policy with a coherently recomputed policy hash is
also rejected because the canonical version, RNG coordinates, replicate bands,
and safety flags are validated semantically. The wrapper retains both
`HistoricalGeneratorIdentity` and the new hardened identity, so past evidence
is not silently relabelled.

## Gate interpretation

Five component gates pass: explicit RNG, 30-scenario cross-ambient replay,
caller-state restoration, dual identity, and reserved-band exclusion. The
sixth component gate, `RNG-ADAPTER-01`, blocks because current production
candidate and reference adapters still call the historical generator and bind
its old hashes.

Thus:

- `HardenedGeneratorAuditReady=TRUE`;
- `HardenedGeneratorReady=TRUE`;
- `RNG01ProspectivelyResolved=TRUE`;
- `AuthorizationRNG01Closed=FALSE`;
- `DownstreamAdaptersRebased=FALSE`;
- `AuthorizationActivationEligible=FALSE`;
- `LargeSimulationMayStart=FALSE`; and
- `Replicate201MayBeOpened=FALSE`.

## Next work

The first static dependency inventory is:

| Layer | Old dependency | Required rebase |
|---|---|---|
| `mfrmr_gtwah_prepare_unit()` | direct call to `mfrmr_gtw_generate()` | replace with authorization-aware hardened preparation |
| candidate/reference evaluators | transitive call through old preparation | separately hash new evaluators; do not rewrite b1g14 |
| nonreserved dry manifest | old evaluator hashes and b1g14 contract hash | issue a new manifest and repeat all four lanes |
| checkpoints/markers/progress | runner, manifest, generator, pre-fit, fit, decision, and reference identities | rebuild and test cold/resume/tamper equality |
| reserved manifest/shards | old adapter/runtime/dependency identity | keep non-executable until runtime and runner hardening |
| b1g15--b1g16 evidence | historical descendants of b1g14 | preserve as historical evidence; create a new descendant chain |

Only `mfrmr_gtwah_prepare_unit()` directly invokes the historical generator in
the b1g14 production-adapter file. Both real evaluators invoke it transitively,
and the exact-resume runner then propagates their hashes into manifests,
checkpoints, dataset markers, progress, and execution identity. Therefore a
one-line function substitution would be scientifically incomplete.

The next slice must rebase the real nonreserved production adapters and all
descendant identities on the hardened generator, then repeat dry execution and
exact-resume integrity checks. It must not weaken the parent b1g16 blockers or
reuse old hashes. Runtime/process/thread and single-writer execution hardening
remain subsequent, independent gates before any authorization can be
considered.
