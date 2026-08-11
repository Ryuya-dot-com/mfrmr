# Weak-information hardened reserved-lineage record

## Decision

The response-free reserved-lineage rebase passes. The complete historical
workload and shard partition are preserved, all 12,000 atomic-unit and all 100
shard identities are rederived under hardened adapter/generator lineage, and
no historical scientific identity appears in the active registry. This is not
an execution authorization: no reserved or confirmation response was
generated, no model was fit, and neither the old nor new output target exists.

## Reproduced scientific identities

| Artifact | Scientific hash |
|---|---|
| parent b1g18 evidence receipt | `3e7911686df046bc5fe507ab276194e463952c45b04230facbadb42120500313` |
| hardened-lineage policy | `6a68e71aa5cb30c7f1460b8c81ba76e135ed42dcf2d341a8f966d2e1783ea905` |
| hardened-lineage contract | `5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5` |
| hardened reserved manifest | `da3905e9b9a605f42e877f695226a0c5ee7089cc04f68ad7ee6350de25c9cbd6` |
| active atomic-unit registry | `9cb84a1344f5888028505f7f400c947598bcf2d7eeb59482a4b551dd0f0cc0da` |
| prospective 100-shard bundle | `634159d6d85ea04ecf9447330af122c01284644211aa2dd78d85ab34a92661df` |
| first shard (`R0201`) | `dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9` |
| last shard (`R0300`) | `20b2e3ec47caae7232d70ef5d6e848b0d368ed0cd2bcf31eb64e94016b162dbb` |
| lineage audit | `9bc4d4dafbeec602f7718c7249bf15f4aeb5a6dbd5862b46e4d8889dc2540d7a` |
| R source file | `d57ff0d4551de0e51c1307ca97e46cbdbeb155c36280a7881871bdd1b9461e11` |
| contract document | `07cd4682da5d59556a64f8d514b43d5b94eb41085e80f1358425f00e4538b835` |
| focused test file | `4721750ac173a980438b6868ec61b4ee968f9d85b56e4f8059aad7d3142a82bf` |

Four focused tests with 69 explicit assertions pass.

## Exact accounting result

| Quantity | Historical b1g14 | Hardened b1g19 |
|---|---:|---:|
| datasets | 3,000 | 3,000 |
| atomic method units | 12,000 | 12,000 |
| planned candidate fits | 108,000 | 108,000 |
| planned candidate decisions | 576,000 | 576,000 |
| planned references | 24,000 | 24,000 |
| shards | 100 | 100 |

All dataset and atomic-unit IDs retain the old shard assignment. All shard
count vectors are identical. Every active atomic-unit hash differs from its
historical hash, and the historical hash is reproduced exactly in the paired
provenance column; the same holds for every shard. The intersection of the
active registry with historical adapter, dependency, manifest, unit, and
shard hashes has cardinality zero.

Each of the 100 independently validated prospective shard manifests contains
30 datasets, 120 units, 1,080 planned candidate fits, 5,760 decisions, and 240
references. Their ordered union contains all 12,000 units exactly once and
matches the aggregate hardened assignment.

## Firewall and negative controls

- The aggregate and per-shard objects set response generation, model fitting,
  execution, result viewing, and confirmation use to false.
- A coherently rehashed outer manifest with a changed inner unit identity is
  rejected because its active registry and shard identity no longer agree.
- A coherently rehashed shard carrying `ResponseGenerated=TRUE` is rejected.
- A coherently rehashed aggregate manifest carrying `ConfirmationUse=TRUE` is
  rejected.
- Direct construction of shard `R0501` is rejected before any data access.
- The b1g19 output root and historical b1g14 output root are absent.

## Frozen state

- `HardenedReservedLineageAuditReady=TRUE`.
- `ReservedManifestRebaseReady=TRUE`.
- `ProspectiveShardManifestsFrozen=TRUE`.
- `ReservedAdapterEntryPointReady=FALSE`.
- `RuntimeContractExtensionReady=FALSE`.
- `AuthorizedSingleShardRunnerReady=FALSE`.
- `AuthorizationRNG01Closed=FALSE`.
- `AuthorizationActivationEligible=FALSE`.
- `LargeSimulationMayStart=FALSE`.
- `Replicate201MayBeOpened=FALSE`.
- Calibration, confirmation, inference, and decision readiness remain false.

## Interpretation and next work

This closes the manifest-lineage subproblem, not the operational authorization
gate. In particular, the old unit hash's missing contract binding has been
corrected prospectively, but b1g19 deliberately supplies no executable
reserved adapter. The next work is an inert reserved-entry/runtime contract,
followed by a locked single-shard runner and its failure-mode controls. Timing
and capacity remain secondary admission evidence; they do not establish
scientific accuracy or permit the large simulation.
