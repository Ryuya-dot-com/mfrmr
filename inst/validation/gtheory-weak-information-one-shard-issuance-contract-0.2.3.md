# Weak-information one-shard issuance contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g24`
- Issuance source:
  `c93287f1e813bb3dd7265179f6adbe8742486b1f32ec7235297f8b8820a5700f`
- Issuance policy:
  `688b30494612169df6db370da5460b24f8606106acf695a5921aeab217eb186e`
- Issuance contract:
  `b9af6f03b4b3f0a34d1e8e33c6feb5a8ff62ef6516b78f136772cae79eacc620`
- Parent b1g23 entry contract:
  `0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a`
- R0201 prospective manifest:
  `dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9`

The source, policy, and contract identities are portable. Runtime receipt,
site receipt, decision, record, active-manifest, and audit identities bind the
observed machine state and target path; they are issuance-instance evidence,
not portable constants.

## Purpose and scope

b1g24 closes the response-free issuance boundary left by b1g23. It refreshes
the exact b1g20 isolated-runtime and site probes, recomputes six gates, and
either:

- returns a hash-valid no-go preflight from which no record can be issued; or
- issues one exact R0201 production record and converts the prospective
  manifest to an unexecuted active manifest.

Issuance does not create the reserved root or lock, generate a response,
compute a pre-fit, fit a model, create a checkpoint, inspect a result, or
authorize confirmation data. It cannot authorize a second shard or the large
simulation.

## Six-gate decision

| Gate | Exact condition |
|---|---|
| `ENTRY-01` | b1g23 reserved entry implementation is ready |
| `ACTIVE-CONVERSION-01` | b1g23 active-manifest conversion is ready |
| `RUNTIME-01` | fresh b1g20 isolated runtime is hash-valid, serial, startup-suppressed, and matches the entry runtime identity |
| `SITE-RECEIPT-01` | fresh b1g20 site receipt is hash-valid, target-bound, target-absent, writable/rename/readback/cleanup capable, and has the required free space |
| `SCOPE-01` | exact R0201 identity and 30/120/1,080/5,760/240 denominators match |
| `CONFIRM-01` | the shard is non-confirmatory and confirmation access remains prohibited |

Every row is required. The gate registry itself is inside the decision hash.
The validator recomputes the six rows from the supplied objects; it does not
trust stored booleans.

## Valid no-go versus admissible go

A failed gate produces `no_go_record_must_not_be_issued`. That decision and
its enclosing preflight remain hash-valid and auditable. This is deliberately
different from the b1g23 production-decision validator, which accepts only a
complete six-gate go object.

Record issuance additionally requires:

- a valid b1g24 preflight whose decision is
  `go_one_shard_record_may_be_issued`;
- the exact b1g23 entry contract and R0201 prospective manifest;
- the nested fresh runtime and site objects, not merely their hash strings;
- `MaximumShardCount=1`;
- complete failure denominators;
- no early stopping; and
- no confirmation use.

The issued record must also pass the independent b1g23 production-record
validator. Thus a locally self-consistent b1g24 object cannot bypass the
parent entry contract.

## Active-manifest conversion

The issued record activates exactly 30 datasets and 120 atomic units, with
1,080 candidate fits, 5,760 candidate decisions, and 240 references. Every
unit retains its prospective identity as provenance and receives a new
identity binding the authorization-record hash. At issuance:

- all 120 units are eligible for the exact record-bound entry;
- all `ResponseGenerated`, `PreFitComputed`, and `CheckpointCreated` flags
  remain false; and
- the output target and lock remain absent.

These statements mean that one shard may be opened by the downstream guarded
runner. They do not mean that it has been opened or that its evidence has been
reviewed.

## Execution boundary

`Replicate201MayBeOpened=TRUE` and
`OneShardExecutionAuthorized=TRUE` apply only to the exact issued record and
derived active manifest. `LargeSimulationMayStart=FALSE` remains invariant.
The next execution layer must consume a fresh valid issuance instance, acquire
the exclusive lock, create and validate the activation marker, execute only
R0201, preserve complete denominators and typed failures, and stop for review.
