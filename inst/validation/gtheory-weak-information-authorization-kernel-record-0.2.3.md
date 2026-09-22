# Weak-information authorization-kernel record

## Decision

The reusable response-free authorization kernel passes. Nine shared
infrastructure gates now pass under one contract, leaving only the actual
reserved runner and a separate immutable authorization record unresolved. No
reserved response was generated, no model was fit, and no reserved output root
was created. Large simulation remains prohibited.

## Portable identities

| Artifact | Scientific hash |
|---|---|
| parent b1g19 lineage receipt | `4a453c9b44fd03ae456ba1fda2f8d65208c3ab63b23c6c51d1f6026dfe3e4e92` |
| authorization-kernel policy | `ca0b9691600d4aa1241741cb0fa8710de1ea892a8e243c323425c6b76047136c` |
| authorization-kernel contract | `86a6015b1eebdb4c9cf8cfa57110d24354ec5999e62f477c82506d8cc6b1edce` |
| isolated worker source | `6c1138afe41995a7a14fdb1fa6bf91e62cc4b667187a18f21bdf2a52860959f0` |
| isolated runtime | `b32aca03814bd2ae12a7475e61caa338c464a46e4bd90209b186ccc1da9383b0` |
| isolated runtime probe | `53a4b57eaf4556ede168f1e686e3be87697a2b3175f464cc88090d394693715e` |
| lock/root mechanics audit | `ec573bb5e939e4bd711ae267c41894db89b14d576a19d4ac7ac45c268b3071cf` |
| R source file | `2825e1fccaea0b48149e48f07080e9d73c742308e8cd873b47a2369e19dbc3d1` |
| worker file | `6c1138afe41995a7a14fdb1fa6bf91e62cc4b667187a18f21bdf2a52860959f0` |
| contract document | `a52be19f589f2f99dda726904adfa3f03c150ef3543309dbccf1961855b79cd0` |
| focused test file | `ce701cc7aa069ae0dabbf647707673c84b251d3fbfa8cafdc3c98242d749b555` |

Four focused tests with 54 explicit assertions pass. Two independent child
process probes reproduce the same runtime and probe hashes.

## Point-in-time site receipt

At the recorded probe, available space was 118,658,240,512 bytes against the
conservative 47,775,834,368-byte requirement. The actual target remained
absent. A temporary directory in its parent passed write, same-directory
rename, identical readback, and cleanup.

- site probe: `3d874f6e391978ecb717f1ddfafe71b055d39d374cdeed8df9b0a85d447dd75d`
- combined preflight:
  `d38f3ba356f8671319c3d4a25ab2234024eb54213cfc1abfbf3514632ddf64a2`

These two hashes are site snapshots. Free space and raw `df` output may change;
they are not expected to reproduce later and do not enter the portable
contract. A future shard must obtain a fresh passing receipt.

## Gate result

| Gate | Result | Interpretation |
|---|---|---|
| `RNG-01` | pass | hardened generator identity is bound |
| `LINEAGE-01` | pass | all reserved unit/shard identities use b1g19 lineage |
| `RUNTIME-01` | pass | extended child runtime identity validates |
| `THREAD-01` | pass | glmmTMB and numerical libraries are explicitly serial |
| `PROCESS-01` | pass | `Rscript --vanilla`, locale, timezone, and startup isolation validate |
| `LOCK-01` | pass | exclusive acquisition, contention rejection, and owner release validate |
| `ROOT-01` | pass | initial activation, exact resume, and unmarked-root rejection validate |
| `CAPACITY-01` | pass | fresh filesystem and conservative capacity checks validate |
| `CONFIRM-01` | pass | confirmation remains inaccessible |
| `RUNNER-01` | block | no reserved candidate/reference runner exists |
| `AUTH-RECORD-01` | block | no immutable execution record is issued |

Runtime drift to Wichmann-Hill and a one-byte capacity deficit are represented
as valid but non-ready receipts. A changed worker source is rejected at
contract construction. Marker mutation, concurrent lock acquisition, and an
unmarked existing root fail closed.

## Frozen state

- `AuthorizationKernelReady=TRUE`.
- `RuntimeContractExtensionReady=TRUE`.
- `LockRootKernelReady=TRUE`.
- `PerShardSitePreflightReady=TRUE`.
- `ReservedAdapterEntryPointReady=FALSE`.
- `AuthorizedSingleShardRunnerReady=FALSE`.
- `AuthorizationRecordIssued=FALSE`.
- `AuthorizationRNG01Closed=FALSE`.
- `AuthorizationActivationEligible=FALSE`.
- `LargeSimulationMayStart=FALSE`.
- `Replicate201MayBeOpened=FALSE`.
- Calibration, confirmation, inference, and decision readiness remain false.

## Long-horizon priority

b1g20 is the stopping point for infrastructure-only decomposition. The next
work is one guarded runner implementation, first reduced against nonreserved
evidence, followed by a separate authorization decision. Additional hash or
preflight layers are not warranted unless that runner exposes a genuinely new
failure mode.

Once the numerical stationarity calibration and threshold are complete, effort
must move back to scientific validation: component/coefficient recovery across
the registered sparse and unequal designs, full-refit uncertainty, and then
crossed/nested and multivariate support. Timing remains an admission input, not
the objective or a substitute for mathematical validity.
