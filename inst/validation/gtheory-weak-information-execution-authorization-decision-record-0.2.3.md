# Weak-information execution-authorization decision record

## Decision

The frozen b1g22 decision is `no_go_refused_not_issued`. Five gates pass and
three prerequisites are absent. No authorization record is issued, no
reserved response is generated, no reserved output root is created, and
replicate 201 remains sealed.

This is a corrective refinement of scope, not a reversal of b1g21. The b1g21
nonreserved runner reduction remains valid and `RUNNER-REDUCTION-01` passes.
What it did not establish was a record-bound reserved entry point or an active
one-shard manifest.

## Reproducible identities

| Artifact | SHA-256 / scientific hash |
|---|---|
| parent receipt | `2be44c3fdda1dc455a83eecdd6c0613240050db4b4aee8cb0cb47399b8d73818` |
| decision policy | `4d89c7235e9ae8537b8b9743ba356c8eaf0ad85308cd9c1cf5a4ec87cc562c04` |
| source audit | `d0a59e573ef9c6fba7af5a308a58bc974b04c0a87ca74dc70de1aca39c506b07` |
| decision | `3df37fa52c9ff688bd5110d4ae097a8fed10123eb898f9967fdcb5fd791c9ab6` |
| candidate `R0201` manifest | `dc8c2952e2246c807e1aa03c3752ab7b66ca87e3850b5c812a27df72a19d16c9` |
| decision source file | `805d03f19b577352e6665da8e49e5601b5433b39526a7fcf5296ec84284a82d8` |
| contract document | `ed9094c3ca7b27fdbd68921a96810fddd0fb7c2d6f3c8132a3c7107291b3ea54` |
| focused test file | `5647967fed03fae07709fffe5980624feb36b81f8d41068f1bdda976dc444e2c` |

## Observed gates

| Gate | Result |
|---|---|
| `LINEAGE-01` | pass |
| `RUNTIME-01` | pass |
| `RUNNER-REDUCTION-01` | pass |
| `RUNNER-SOURCE-01` | pass |
| `RESERVED-ENTRY-01` | block |
| `ACTIVE-MANIFEST-01` | block |
| `SITE-RECEIPT-01` | block |
| `CONFIRM-01` | pass |

The exact source audit finds both protective stops: b1g21 requires a separate
authorization record for reserved replicates, while b1g13 permits only its
exact nonreserved mechanics run. Neither source implements a record-bound
reserved entry point, and no prospective manifest is converted to executable
form.

## Focused verification

Four tests with 48 explicit assertions pass. They verify the frozen receipt,
policy, source audit, and decision hashes; the exact `R0201` denominators; the
five-pass/three-block gate partition; both source-level reserved stops; and
fail-closed receipt, policy, source-audit, gate, and issuance mutations.

The focused suite is response-free and fit-free. It uses no calibration or
confirmation observation.

## Frozen non-readiness state

- `AuthorizationDecisionComplete=TRUE`.
- `Runner01Closed=TRUE` in the narrow nonreserved-reduction sense.
- `AuthorizationIssuanceReady=FALSE`.
- `AuthorizationRecordIssued=FALSE`.
- `ReservedAdapterEntryPointReady=FALSE`.
- `AuthorizedReservedManifestReady=FALSE`.
- `FreshSiteReceiptBound=FALSE`.
- `AuthorizationRNG01Closed=FALSE`.
- `AuthorizationActivationEligible=FALSE`.
- `LargeSimulationMayStart=FALSE`.
- `Replicate201MayBeOpened=FALSE`.
- Calibration, confirmation, inference, and decision readiness remain false.

## Next implementation boundary

Implement and test the reserved-capable mechanics without generating a
reserved response: one record-bound reserved-only entry point, one exact
active-manifest conversion for `R0201`, full-denominator checkpoint behavior,
and fail-closed authorization/lock/runtime/confirmation checks. Reduce that
path against nonreserved evidence so it does not become an untested second
evaluator.

Only after those prerequisites exist should a fresh site receipt be consumed
by a separate issuance decision. If issuance remains no-go, stopping is the
correct result. If it becomes go, run exactly one shard and review it before
considering any enlargement. This sequencing protects the larger goal:
credible G-study/D-study recovery and uncertainty evidence, not simulation
volume or infrastructure completion for its own sake.
