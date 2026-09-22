# Draft.83d2b2b1g15 response-free one-way authorization preflight record

Status: completed repository-only authorization-readiness preflight,
2026-08-10. No execution authorization was issued. Calibration replicates
201--300 and confirmation replicates 501--700 were not generated, opened,
summarized, or used.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g14 adapter contract | `baf48a948b86c1769aba8a574619c6ce57be17b4b5747ae935f0e430392518a1` |
| upstream b1g14 reserved manifest | `019fedf063ce90c3492f9eb37f6dbec43a42474ce9096e7cc2891491d7a158c8` |
| upstream b1g14 nonreserved execution | `b9ad747a62b1e14cf1da1e0e4cee8a0a341db969596df3e2de87b25ba908caae` |
| upstream runtime | `94cb18393b87ef8409f231b2e62c507f43fb3294cdefeb0f3e8c19c8235e7753` |
| b1g15 authorization policy | `a04fcec16a9f109ed1ba4ad86213315b9d9eb71c5c4f6b314906ae094826be17` |
| b1g15 nonreserved measurement | `78067401672cb2d4759a0c7c0aee3f38a5c5454b86fb7605752f88ebf84aa5e9` |
| b1g15 function registry | `22275ab2165c2ea033393ec2c64313700196b7fcab3364bded0b1de382e94a96` |
| b1g15 preflight contract object | `44a6d4e2677af111e6eeeae8b7b3143ce8521db34da1769a86b85f32c63ca551` |
| prospective shard bundle | `dfd5099b84dc8ff64b605261d957173e63b8b04645b1f90cc7262b8120d54e82` |
| first prospective shard (`R0201`) | `cba0fd1c84119380b3806c09f7f924dc3f601707523be9fc2b236d94a073ae5c` |
| last prospective shard (`R0300`) | `1bf521859dc8ac60b49ab5108b1d2d994a76422c47212266cc0881e8e7d4beb8` |
| source artifact | `129702515176511a47ff2466f1176afcfb2430cf1fb04b392515dbfbf1c94559` |
| contract artifact | `0f4d99ba17300a70bab0861f33ce25e8fc973e09389e19374018e22282042c31` |
| focused test artifact | `9047c75ce2aa09d5949a87c588e5a75c2844979357af361be759793088d48c3a` |

The installed runtime is the same R 4.6.1 aarch64-apple-darwin23 / Darwin
25.5.0 environment and exact dependency set frozen by b1g14. This is an input
identity, not a portability claim. Activation must reconstruct it rather than
trust this prose record.

## Prospective shard result

All 100 manifests, `R0201` through `R0300`, validate independently. Each has
30 datasets, 120 atomic units, 1,080 candidate-fit rows, 5,760 candidate-
decision rows, and 240 reference rows. The bundle contains exactly 3,000
datasets, 12,000 unique atomic-unit identities, 108,000 fits, 576,000
decisions, and 24,000 references. The ordered union agrees with the exact
b1g14 reserved assignment.

Every manifest has `ExecutionAuthorized=FALSE`,
`CalibrationExecutionAuthorized=FALSE`,
`CalibrationDataGenerated=FALSE`, and
`CalibrationResultsViewed=FALSE`. Confirmation use and early stopping are
false. The objects are prospective planning manifests and are not accepted as
executable b1g13 runner manifests. Both production adapters still reject a
direct reserved-unit call without a later exact authorization-record hash.

## Frozen planning receipt

The one-dataset nonreserved b1g14 run contributed these observed sizes and
times:

| Quantity | Observation |
| --- | ---: |
| checkpoint bytes | 2,955; 2,969; 3,573; 3,588 |
| dataset marker bytes | 671 |
| combined ledger object bytes | 124,728 |
| glmmTMB ML seconds | 22.810 |
| glmmTMB REML seconds | 14.539 |
| lme4 ML seconds | 27.726 |
| lme4 REML seconds | 23.972 |
| four-method total seconds | 89.047 |

Raw disk extrapolation is 419,253,000 bytes. Applying the prespecified 32x
disk multiplier yields 13,416,096,000 bytes; preserving another 32 GiB gives a
minimum available-space requirement of 47,775,834,368 bytes. Applying the 4x
runtime multiplier gives a 296.823333-hour serial plan and a 2.968233-hour
plan for each 30-dataset shard. Both lie within the frozen 400-hour and
4-hour admission bounds, respectively. `MaxConcurrentShards=1`.

These extrapolations come from one nonreserved dataset. They are intentionally
conservative admission calculations, not runtime guarantees, accuracy claims,
or substitutes for complete calibration accounting.

## Point-in-time filesystem result

The probe was performed in the actual parent of
`validation-results/gtheory-stationarity-calibration-draft83d2b2b1g14`.
The output target was absent before and after the probe. A temporary directory
in that parent was created; an RDS sentinel was written, moved by a checked
same-directory `file.rename()`, read back identically, and removed. `df -Pk`
returned successfully.

| Dynamic site receipt | Value |
| --- | --- |
| observed available bytes | 119,322,955,776 |
| required available bytes | 47,775,834,368 |
| filesystem probe hash | `e7d89b42b03425e704f755f00049be4f4df97ff0a9e51ff8d9a6e83c4c190bf0` |
| resource projection hash | `f87b63757f71b5ee15541a684da38ff2d9739f973f3e4c5fccebe76eafc6126e` |
| authorization-readiness audit hash | `24ab19009ff2be1a68e7dbc25d09407b024865291903a061aa6f967deda8cf9e` |

All three dynamic objects revalidated when captured. These hashes record one
site snapshot and are expected to change when free space or command output
changes. They must not be substituted for the required activation-time probe.
The advisory `file.access()` result was not treated as sufficient; actual
write, rename, readback, and cleanup were required.

## Test result

Eight focused tests with 149 explicit assertions pass without failures,
errors, warnings, or skips. They verify contract and nested-hash recomputation,
all 100 shard identities and counts, exact bundle union, adapter firewalls,
reserved-call rejection, `df -Pk` parsing, the real output-parent probe,
non-destructive rejection of a pre-existing fake target, conservative
resource arithmetic, negative-capacity behavior, and recomputation of every
derived readiness flag after mutation.

## Readiness interpretation

The following narrow flags are true:

- `AuthorizationPreflightContractFrozen`;
- `ProspectiveShardManifestsFrozen`;
- `FilesystemPreflightReady`;
- `CapacityPreflightReady`;
- `SchedulingPlanFrozen`;
- `AuthorizationReadinessAuditReady`; and
- `AuthorizationActivationEligible`.

The following remain false:

- `ExecutionAuthorizationRecordIssued`;
- `CalibrationAuthorizationReady`;
- calibration execution, data generation, and result viewing;
- stationarity threshold and production-criterion readiness;
- confirmation authorization;
- inference, coefficient, decision, public-support, and D-study readiness; and
- every release-checklist promotion.

The next admissible step is a separately reviewed immutable b1g16 activation
artifact and authorized single-shard runner. It must bind the exact b1g15
contract and all prospective shard hashes, recheck runtime, target absence,
write/rename/readback behavior, cleanup, and capacity, and keep confirmation
inaccessible. Only then may replicate 201 be reconsidered. Calibration output
cannot be inspected while the activation decision is constructed, and a
completed first shard cannot authorize early stopping or threshold selection.
