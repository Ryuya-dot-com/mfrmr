# Weak-information execution-authorization decision contract

## Identity

- Version: `0.2.3-draft.83d2b2b1g22`
- Parent receipt:
  `2be44c3fdda1dc455a83eecdd6c0613240050db4b4aee8cb0cb47399b8d73818`
- Decision policy:
  `4d89c7235e9ae8537b8b9743ba356c8eaf0ad85308cd9c1cf5a4ec87cc562c04`
- Source audit:
  `d0a59e573ef9c6fba7af5a308a58bc974b04c0a87ca74dc70de1aca39c506b07`
- Decision:
  `3df37fa52c9ff688bd5110d4ae097a8fed10123eb898f9967fdcb5fd791c9ab6`
- Decision source:
  `805d03f19b577352e6665da8e49e5601b5433b39526a7fcf5296ec84284a82d8`
- Focused test:
  `5647967fed03fae07709fffe5980624feb36b81f8d41068f1bdda976dc444e2c`

## Purpose

b1g22 is an executable go/no-go decision, not an authorization record and not
another execution framework. It asks whether the existing b1g19--b1g21
evidence is sufficient to issue one immutable authorization for reserved
shard `R0201` (replicate 201) without opening a response.

The answer is `no_go_refused_not_issued`. The decision is deliberately useful:
it prevents a nonreserved scientific reduction from being misread as proof
that the reserved execution boundary exists.

## Frozen candidate scope

Only prospective shard `R0201` is eligible for a later decision. Its b1g19
manifest hash is
`dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9`
and its complete planned denominators are:

| Quantity | Required count |
|---|---:|
| datasets | 30 |
| atomic units | 120 |
| candidate fits | 1,080 |
| candidate decisions | 5,760 |
| references | 240 |

At most one shard may be authorized. Early stopping and confirmation access
are prohibited. The candidate manifest remains prospective and inert.

## Gate decomposition

The decision separates five established facts from three missing execution
facts:

| Gate | Result | Meaning |
|---|---|---|
| `LINEAGE-01` | pass | exact b1g19 `R0201` identity and denominators are frozen |
| `RUNTIME-01` | pass | the b1g20 isolated runtime contract is bound |
| `RUNNER-REDUCTION-01` | pass | b1g21 passed its nonreserved scientific reduction and exact resume |
| `RUNNER-SOURCE-01` | pass | exact b1g21 and b1g13 runner sources are audited |
| `RESERVED-ENTRY-01` | block | no record-bound reserved-only entry point exists |
| `ACTIVE-MANIFEST-01` | block | no one-shard prospective-to-executable conversion exists |
| `SITE-RECEIPT-01` | block | no fresh site/capacity receipt has been bound at issuance |
| `CONFIRM-01` | pass | confirmation access remains prohibited and unused |

The earlier b1g21 phrase “`AUTH-RECORD-01` alone blocks” was correct only as a
coarse activation label. b1g22 expands that label into the three concrete
prerequisites above. In particular, the exact b1g21 preparation guard rejects
reserved replicates, and the exact b1g13 execution loop is explicitly
nonreserved-only. A record naming those sources would therefore be
non-executable rather than an honest authorization.

## Fail-closed issuance rule

Issuance is prohibited whenever any required gate fails. The decision cannot:

- generate responses or fit models;
- mutate the prospective shard manifest into an executable manifest;
- create the reserved output root;
- authorize replicate 201 or any larger calibration run; or
- inspect confirmation responses 501--700.

A future reserved entry point must require a separately frozen authorization
record, exact one-shard manifest, held exclusive lock, full activation marker,
fresh site receipt, exact runtime receipt, and complete failure denominators.
Defining an entry point does not itself issue that record.

## Priority decision

The next smallest scientifically necessary implementation is a response-free,
record-bound reserved entry point plus an exact one-shard executable manifest.
It should reuse the established evaluator and checkpoint semantics and be
reduced against nonreserved evidence. It must not open replicate 201 during
its own construction or tests.

Once those mechanics pass, a fresh site receipt and a separate immutable
authorization decision may be considered. If and only if that later decision
passes may one reserved shard run. Review of its complete denominators must
precede any continuation. Large-scale calibration remains downstream, and
the long-horizon scientific priority remains recovery and uncertainty under
sparse, unequal, nested/crossed, and multivariate designs.
