# Weak-information hardened production-adapter rebase record

## Decision

The nonreserved production-adapter rebase passes. Historical and hardened
paths have exact semantic parity across all four real backend/likelihood lanes,
while generator, pre-fit, reference-sidecar, contract, manifest, checkpoint,
and execution lineage changes as required. The reserved adapter entry point and
manifest remain deferred, so authorization and large simulation remain false.

## Reproduced scientific identities

| Artifact | Scientific hash |
|---|---|
| adapter-rebase policy | `4a4d5ff4becc42e931806cc19d97449d8ec083b65b970d201230f4f4b5e19684` |
| candidate evaluator | `94713fabb2ba12301984912560ac8017d6d22c2c3d66525c67016326ff1ab7c9` |
| reference evaluator | `91770297261211cdca1eb9ad760e5ebc7b726a9bdb2730af9d3dd4633940e6db` |
| adapter-rebase contract | `0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64` |
| hardened dry manifest | `090b761a835098b037b3f65021ebe22eeae9df822628df6898685b1f84e99d15` |
| historical execution | `b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae` |
| hardened execution | `14a44a4382e50ba2819d57072288bd213789935d4ed6d78fba674a8081b62aeb` |
| paired semantic audit | `1e8461eca060b00215240d65c506873d6f082f66b6216fb1ff30761df7dfdb63` |
| R source file | `123a5dc0033e82b6dad7136c830acc6ee2d4e571871358369ad8454a4af8ce2b` |
| contract document | `98febe52eabbc0ccb458d04cb4da60d5c74d4638fc6a2e4412bad5bbb50932ff` |
| focused test file | `f618e2fd2eabd22ee78568d91045320343c3337118c288b6d87e9bb7e4f42b23` |

Four focused tests with 65 explicit assertions pass.

## Complete-denominator result

| Quantity | Historical | Hardened |
|---|---:|---:|
| datasets | 1 | 1 |
| atomic method units | 4 | 4 |
| candidate fits | 36 | 36 |
| returned candidate fits | 35 | 35 |
| typed candidate failures | 1 | 1 |
| candidate decisions | 192 | 192 |
| references | 8 | 8 |
| unresolved references | 0 | 0 |

The one failure remains the known glmmTMB ML `start_snapshot` failure. It is
retained in both denominators. Candidate numerical/state rows, all candidate
decisions, and reference state/failure rows agree exactly after excluding only
the identity fields that must change. Candidate and reference evaluator calls
independently reproduce the same hardened generator and pre-fit hashes.

A second call against the hardened checkpoint root reuses all four atomic
units, computes zero new units, and reproduces the hardened execution hash.

## Frozen state

- `HardenedAdapterRebaseAuditReady=TRUE`.
- `NonreservedAdapterRebaseReady=TRUE`.
- `RNGAdapterComponentProspectivelyResolved=TRUE`.
- `ReservedAdapterEntryPointReady=FALSE`.
- `AuthorizationRNG01Closed=FALSE`.
- `AuthorizationActivationEligible=FALSE`.
- `LargeSimulationMayStart=FALSE`.
- `Replicate201MayBeOpened=FALSE`.
- Calibration, confirmation, inference, and decision readiness remain false.

## Next work

The next response-free slice must construct a hardened prospective reserved
manifest without generating responses, rederive all 100 shard identities and
counts, and prove that no old generator, adapter, pre-fit, or checkpoint hash
can enter the new lineage. Runtime, explicit thread, isolated process,
single-writer lock, activation/resume root, and per-shard capacity gates remain
independent blockers after that manifest rebase.
