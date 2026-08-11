# Weak-information guarded-shard-runner record

## Decision

The guarded single-shard implementation passes its nonreserved scientific
reduction and exact-resume audit. `RUNNER-01` is closed. This is not an
execution authorization: `AUTH-RECORD-01` remains the sole activation blocker,
replicate 201 remains sealed, and no reserved response or reserved output root
was created.

## Portable identities

| Artifact | Scientific hash |
|---|---|
| b1g18 hardened adapter | `0373db563cd16c63693b02b968dbbd49221a77e1f666b87cc63b17cb6f786e64` |
| b1g19 reserved lineage | `5075f23a5af8edb7d77ff3cd4c4efaad4d7a624995c3ee04a62ed04a2bee49f5` |
| b1g20 authorization kernel | `86a6015b1eebdb4c9cf8cfa57110d24354ec5999e62f477c82506d8cc6b1edce` |
| isolated runtime | `b32aca03814bd2ae12a7475e61caa338c464a46e4bd90209b186ccc1da9383b0` |
| guarded-runner policy | `ecdf55015369c04e9ec81549fe68a624d0c0a025a154f28eeedc3adbd41d86aa` |
| guarded-runner contract | `f6d932f5261b3816bd16afa820cc2c36acf188d5144277b22623a9b41245f552` |
| nonreserved fixture manifest | `0a515e0977774887094321284a723e058d9b1723f3d45f505245429dc93d6db3` |
| worker file | `8a7bfbe987a4178f83351508d29defeb631acb9f3cd9c1f724ae85d68fbf2df7` |
| R source file | `b179c44076107c64e0f7d030585d38dec11bffba5231dcf4a702631a11742e1c` |
| contract document | `ecdb4bb6d82bf947d1df991d1797d37a89a8e73611a90483e147674ef873cefa` |
| focused test file | `e04dc30191d6031555d4eab22eeb52853fcf935c0f3b8b557c1d3df85bfc407d` |

Run-receipt and audit hashes intentionally bind the disposable absolute target
and are site/run specific. They are validated in the focused tests but are not
presented as portable identities.

## Observed reduction

| Quantity | Direct b1g18 | Guarded child |
|---|---:|---:|
| datasets | 1 | 1 |
| atomic method units | 4 | 4 |
| candidate fits | 36 | 36 |
| candidate decisions | 192 | 192 |
| references | 8 | 8 |
| returned fits | 35 | 35 |
| retained typed fit failures | 1 | 1 |
| unresolved references | 0 | 0 |

Candidate fits and references have exact semantic parity after the registered
lineage exclusions; all candidate decisions are exactly equal. The initial
child computes four units. A second child observes `exact_resume`, computes
zero, reuses four, and reproduces the execution, checkpoint, and marker hashes.

Four focused tests with 54 explicit assertions pass. The recorded focused
suite is minutes rather than seconds because it executes the real four-lane
model-fitting and numerical-diagnostic path. Runtime is planning information,
not a validity gate and not a reason to enlarge the simulation.

## Negative controls

- reserved replicate 201 is rejected before response generation because no
  immutable authorization record exists;
- confirmation replicate 501 is rejected before response generation;
- a changed unit identity invalidates the manifest;
- a changed activation hash invalidates the job capsule;
- a changed worker file invalidates runner admission;
- a changed contract policy invalidates the contract; and
- a changed execution value invalidates the receipt.

The child also requires the exact held lock and activation marker, as inherited
from and independently reread under the b1g20 kernel.

## Gate result

| Gate | Result | Interpretation |
|---|---|---|
| `RNG-01` through `CONFIRM-01` | pass | inherited b1g20 kernel gates remain bound |
| `RUNNER-01` | pass | real nonreserved evaluator path passes isolated execution, complete accounting, semantic reduction, and exact resume |
| `AUTH-RECORD-01` | block | no immutable one-shard reserved execution record is issued |

## Frozen state

- `GuardedSingleShardRunnerReady=TRUE`.
- `Runner01Closed=TRUE`.
- `RemainingAuthorizationBlockerIds="AUTH-RECORD-01"`.
- `ReservedAdapterEntryPointReady=FALSE`.
- `AuthorizedSingleShardRunnerReady=FALSE`.
- `AuthorizationRecordIssued=FALSE`.
- `AuthorizationRNG01Closed=FALSE`.
- `AuthorizationActivationEligible=FALSE`.
- `LargeSimulationMayStart=FALSE`.
- `Replicate201MayBeOpened=FALSE`.
- Calibration, confirmation, inference, and decision readiness remain false.

## Next decision

The next work is not another preflight layer and not a large simulation. It is
an explicit go/no-go authorization record for one exact reserved shard. That
record must consume a fresh capacity receipt and freeze the runner, shard,
runtime, lock/root, denominator, and confirmation-exclusion identities. A
single-shard result must then be reviewed before any continuation.

Longer term, the central value remains scientific: calibrate the numerical
rule, then return to recovery, uncertainty, sparse/unbalanced D-study behavior,
and multivariate estimation rather than optimizing the execution framework for
its own sake.
