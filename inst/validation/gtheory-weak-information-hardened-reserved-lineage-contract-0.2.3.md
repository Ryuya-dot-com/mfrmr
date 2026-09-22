# Weak-information hardened reserved-lineage contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g19`
- Historical b1g14 adapter contract:
  `baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1`
- Historical b1g14 reserved manifest:
  `019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8`
- Parent b1g18 evidence receipt:
  `3e7911686df046bc5fe507ab276194e463952c45b04230facbadb42120500313`
- Hardened-lineage policy:
  `6a68e71aa5cb30c7f1460b8c81ba76e135ed42dcf2d341a8f966d2e1783ea905`
- Hardened-lineage contract:
  `5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5`

## Purpose

b1g19 rebuilds the prospective calibration manifest and all 100 shard
manifests against the b1g17 generator and b1g18 candidate/reference adapters.
It is a response-free identity and accounting exercise. It neither calls the
generator nor fits a model, and it does not create an output directory.

The historical b1g14 atomic-unit hash covered the unit row but not the adapter
or generator contract. Replacing only the top-level contract would therefore
leave the same 12,000 atomic-unit identities under scientifically different
code. b1g19 retains each old hash in an explicitly historical provenance field
and computes a new active hash from the complete unit row plus the hardened
adapter contract, hardened generator contract, and lineage policy. The same
rule forces all 100 shard identities to change.

## Exact reduction and required differences

The workload itself must reduce exactly to b1g14:

- replicates 201--300 and shards `R0201`--`R0300`;
- 30 scenarios and four backend/likelihood lanes per replicate;
- 3,000 datasets and 12,000 atomic units;
- 108,000 planned candidate fits, 576,000 candidate decisions, and 24,000
  references; and
- per shard, 30 datasets, 120 units, 1,080 fits, 5,760 decisions, and 240
  references.

Dataset IDs, atomic-unit IDs, shard assignment, and all planned-denominator
counts must agree exactly. Active atomic-unit and shard hashes must disagree
for every unit and shard, while their historical counterparts must be retained
exactly in provenance-only fields. The active scientific registry must have
empty intersection with the historical adapter, dependency, unit, shard, and
manifest identities.

## Non-execution boundary

Every aggregate and per-shard manifest fixes all of the following to false:

- response generation and model fitting permission;
- output-root creation permission;
- execution and calibration authorization;
- calibration data generation and result viewing;
- confirmation use; and
- early stopping.

The only registered shard IDs are `R0201`--`R0300`; confirmation replicates
501--700 are rejected. The new relative output identity is
`validation-results/gtheory-stationarity-calibration-draft83d2b2b1g19`, and
the audit requires it to be absent.

`ReservedManifestRebaseReady=TRUE` is deliberately narrower than an executable
reserved entry point. The current b1g18 preparation function still rejects
reserved replicates. The inherited b1g14 runtime also still omits the extended
RNG, BLAS/LAPACK, locale/timezone, thread, and isolated-process contract.
Consequently `ReservedAdapterEntryPointReady`,
`RuntimeContractExtensionReady`, `AuthorizedSingleShardRunnerReady`,
`AuthorizationRNG01Closed`, and every execution/readiness flag remain false.

## Next admissible work

The next slice may construct, but not activate, a reserved-only adapter entry
point and extended runtime receipt. It must preserve the response-free
firewall while adding explicit RNG/thread state, a vanilla-process boundary,
an exclusive single-writer lock, atomic activation/resume semantics, and
per-shard capacity rechecks. Separate contention, drift, corruption,
capacity-loss, and confirmation-access negative controls remain prerequisites
to any immutable authorization record.
