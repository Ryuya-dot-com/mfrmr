# Weak-information one-shard issuance record

## Result

The b1g24 response-free preflight passed all six gates on the observed site.
The issuance function constructed one exact R0201 production authorization
record and b1g23 derived a hash-valid active reserved manifest. The focused
test also forced `SITE-RECEIPT-01` to fail and confirmed that the resulting
no-go preflight remained hash-valid while record issuance was refused.

No reserved response, pre-fit, fit, checkpoint, output root, lock, or result
was created. R0201 has therefore been authorized in the tested issuance
instance but not executed. The large simulation and all confirmation data
remain sealed.

## Portable identities

| Artifact | SHA-256 / scientific hash |
|---|---|
| b1g23 entry source | `eec3a92a69aa1d1378137342094e536c4c71c3674b15c7a1260869cbcb0d1394` |
| b1g23 entry contract | `0dca57ff5546d49c2ef49b27e89bd571d19fbbe93ea3698dbdb7d87b69abfd3a` |
| R0201 prospective manifest | `dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9` |
| b1g24 issuance source | `c93287f1e813bb3dd7265179f6adbe8742486b1f32ec7235297f8b8820a5700f` |
| b1g24 issuance policy | `688b30494612169df6db370da5460b24f8606106acf695a5921aeab217eb186e` |
| b1g24 issuance contract | `b9af6f03b4b3f0a34d1e8e33c6feb5a8ff62ef6516b78f136772cae79eacc620` |
| contract document | `8e0b5f3fdea183a72f3105cea192002718dda1a73985d27255b64312e47c2da1` |
| focused test | `1a608234922993120d18d6cb9506ec7209440640c11fb8574871ecb92e38424b` |

## Observed issuance-instance identities

| Artifact | Observed hash |
|---|---|
| isolated-runtime receipt | `53a4b57eaf4556ede168f1e686e3be87697a2b3175f464cc88090d394693715e` |
| site receipt | `16959e2b0ab8c362e69307ded80a75a7a05c374f1c2ab7c728ac24ba54e4a862` |
| six-gate decision | `1b31942117aede0cc91ec4a0a4bdc8425c367d4b686be5a5a5b4f99bcbcbb3fd` |
| enclosing preflight | `0d7d53f319bf47e73792eadbf15f3c7e8356202cb933068c71fff1d20b779ccb` |
| authorization record | `97a7587ff553c78b7881ea988e0675d65bc92a39f58b10194c07208d2c19df15` |
| active reserved manifest | `c9b7a8158bb8d08e21f93fcf65b07a6e8710695ab3a4e9da603f3bf3473f2bce` |
| issuance audit | `4d9c507c9fc3a6dcf5acda7a08284b498bf4d68786f8711d9001732a8a99c035` |

These latter hashes document one successful observation. A downstream
execution must refresh the runtime/site evidence and validate the exact
objects it actually consumes; it must not treat these observed strings as a
permanent bearer token.

## Exact issued scope

| Quantity | Authorized count |
|---|---:|
| shards | 1 |
| replicate | 201 |
| datasets | 30 |
| atomic units | 120 |
| candidate fits | 1,080 |
| candidate decisions | 5,760 |
| references | 240 |

All denominators are mandatory. Early stopping and confirmation access are
false. An error or typed fit failure must remain in the complete ledger; it
cannot remove a method, dataset, decision row, or reference row from the
denominator.

## Controls exercised

Fifty-one focused assertions cover:

- portable source, policy, contract, and parent identities;
- all six recomputed GO gates and both the b1g24 and b1g23 decision validators;
- issued-record and active-manifest validation;
- exact R0201 counts and unit-level identity rebinding;
- no responses, pre-fits, checkpoints, root, or lock at issuance;
- a structurally valid, auditable site-failure NO-GO;
- refusal to issue from that NO-GO; and
- decision, record, active-manifest, and audit mutation rejection.

## Interpretation and next stop

The earlier blocker “there is no production issuance path” is closed. The
meaningful remaining uncertainty is now empirical and computational: whether
the exact one-shard runner completes R0201 under the real numerical path, with
acceptable failure patterns and exact resume.

The next bounded action is not a larger simulation. It is a persistent,
record-consuming R0201 run followed by a mandatory review of all
1,080/5,760/240 rows, typed failures, numerical diagnostics, elapsed time,
storage, root/lock state, and exact-resume evidence. No R0202 or broader
calibration is eligible before that review.
