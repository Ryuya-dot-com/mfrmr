# Weak-information guarded-shard-runner contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g21`
- Parent b1g18 hardened adapter:
  `0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64`
- Parent b1g19 reserved lineage:
  `5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5`
- Parent b1g20 authorization kernel:
  `86a6015b1eebdb4c9cf8cfa57110d24354ec5999e62f477c82506d8cc6b1edce`
- Guarded-runner policy:
  `ecdf55015369c04e9ec81549fe68a624d0c0a025a154f28eeedc3adbd41d86aa`
- Guarded-runner contract:
  `f6d932f5261b3816bd16afa820cc2c36acf188d5144277b22623a9b41245f552`
- Nonreserved fixture manifest:
  `0a515e0977774887094321284a723e058d9b1723f3d45f505245429dc93d6db3`
- Guarded runner source:
  `b179c44076107c64e0f7d030585d38dec11bffba5231dcf4a702631a11742e1c`
- Isolated worker source:
  `8a7bfbe987a4178f83351508d29defeb631acb9f3cd9c1f724ae85d68fbf2df7`

## Scope decision

b1g21 implements one real scientific shard path instead of another narrow
preauthorization abstraction. It joins the b1g18 hardened candidate/reference
evaluators and b1g13 complete-denominator checkpoints to the b1g20 isolated
runtime, exclusive lock, and typed activation/resume root.

The executable reduction is exactly scenario
`GT-WI-baseline_complete-reference_1200`, nonreserved replicate 902, and all
four glmmTMB/lme4 x ML/REML lanes. It produces 36 candidate-fit rows, 192
candidate-decision rows, and eight reference rows. A failed fit remains in the
denominator. Timing and reuse state do not enter the scientific execution
hash.

## Reuse without evaluator drift

The b1g18 evaluator bodies are not copied. A narrow lexical bridge rebinds
only their preparation entry point to the b1g21 guard. Dependency hashes bind
the new guard and bridge, the unchanged parent evaluator bodies, the hardened
generator, the checkpoint runner, and the lock/root primitives. This keeps
the test scientifically meaningful while avoiding a second model-fitting
implementation that could drift.

## Child, lock, and activation contract

Every run requires:

1. the exact frozen fixture manifest and worker source;
2. an atomically acquired b1g20 directory lock;
3. an initial or exact-resume activation marker binding manifest and isolated
   runtime hashes;
4. a content-addressed job capsule binding target, lock owner, lock marker,
   activation marker, contract, and manifest; and
5. an `Rscript --vanilla` child under the b1g20 RNG, locale, timezone,
   startup, glmmTMB, and numerical-thread environment.

The child independently rereads and validates the lock and activation marker
before invoking the evaluator/checkpoint path. The controller accepts only a
complete, hash-valid ledger and releases the exact owner lock. Job, manifest,
contract, worker, execution, and activation-marker mutations fail closed.

The portable runner contract binds the stable b1g20 kernel, isolated runtime,
and lock/root mechanics, but deliberately excludes the point-in-time site
preflight hash. Available space belongs to a fresh future authorization
receipt; otherwise an unrelated change in free bytes would silently redefine
the scientific runner contract.

## Scientific reduction and exact resume

The guarded first run computes four atomic units. Its scientific rows have
exact semantic parity with a direct b1g18 hardened execution after excluding
only generator/pre-fit/reference-sidecar identity fields whose lineage is
expected to differ. Candidate decisions are exactly equal.

A second isolated child on the same marked root computes zero units, reuses
all four checkpoints, and reproduces the execution, unit-checkpoint, and
dataset-marker hashes. This closes `RUNNER-01` as an implementation and
reduction gate.

## Non-authorization boundary

Closing `RUNNER-01` does not authorize a reserved response. Replicates
201--300 are rejected with a requirement for a separately issued immutable
authorization record; confirmation replicates 501--700 are rejected before
generation. No issuance function exists in b1g21, no reserved manifest is
converted to executable form, and the reserved output root remains absent.

Therefore:

- `GuardedSingleShardRunnerReady=TRUE` and `Runner01Closed=TRUE`;
- `ReservedAdapterEntryPointReady=FALSE`;
- `AuthorizedSingleShardRunnerReady=FALSE`;
- `AuthorizationRecordIssued=FALSE`;
- `AuthorizationRNG01Closed=FALSE`;
- `LargeSimulationMayStart=FALSE`; and
- replicate 201 remains sealed.

The only remaining activation decision is `AUTH-RECORD-01`. Its future record
must bind one exact b1g19 shard, this runner contract, a fresh b1g20 site
receipt, and explicit one-shard scope. It must not reinterpret the nonreserved
reduction as calibration evidence.

## Long-horizon priority

No further execution-framework layer is justified before the authorization
decision. If authorization is not issued, the valid outcome is a documented
stop. If it is issued, only one reserved shard may run first; review precedes
any broader calibration.

After numerical stationarity calibration, work returns to the scientific
claim portfolio: G-study/D-study component and coefficient recovery across
sparse and unequal designs, full-refit uncertainty, and only then nested,
crossed, and multivariate promotion. Runtime optimization is subordinate to
those estimand and operating-characteristic goals.
