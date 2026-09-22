# ConQuest minimum diagnostic authorization record for mfrmr 0.2.3

Status: review sequencing split and smallest meaningful P2 diagnostic slice
frozen; construction ready, current runtime and maintainer attestation unbound;
no execution authorized, 2026-08-15.

- Specification: `0.2.3-conquest-minimum-diagnostic-authorization-v1`
- Contract: `mfrmr_conquest_minimum_diagnostic_authorization_v1`
- Execution identity: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-001`
- Construction status:
  `minimum_diagnostic_contract_ready_runtime_and_attestation_unbound`

This repository-only contract was created without launching ConQuest, fitting
mfrmr, or opening candidate output. It corrects review sequencing; it does not
weaken model-identity, denominator, failure, or claim boundaries.

## Decision

A monolithic independent review before any new native output has poor value of
information. It can detect specification mistakes but cannot show whether the
current ConQuest runtime accepts the control syntax, emits the required raw
tokens and matrices, or reaches the declared q states. It also risks consuming
the remaining lifetime of the 5.47.5 Demonstration Version without collecting
the otherwise unrecoverable native observation.

Review is therefore split into two non-substitutable tiers:

| Tier | Who may perform it | Blocks first sealed diagnostic? | Blocks evidence promotion, widening, and public claims? |
| --- | --- | --- | --- |
| Minimum pre-execution fatal-gate audit | maintainer or independent reviewer, with author overlap explicitly declared | yes | yes |
| Independent post-output evidence review | reviewer independent of artifact authorship and execution adjudication | no | yes |

The first tier permits only execution of the exact sealed diagnostic. A
same-author maintainer audit is acceptable because the resulting output cannot
be interpreted as confirmation, used to widen the design, authorize P3, or
support a public claim. Independence remains mandatory before any such evidence
promotion.

## Frozen minimum P2 slice

The smallest meaningful slice is a paired RSM/PCM comparison on exactly the
same connected-multibridge data. One arm alone would not exercise both shared
and Criterion-specific transition paths; adding weak-link, workload,
missingness, boundary, or extreme cases would answer a wider question before
the execution infrastructure is known to work.

| Sequence | Registry row | Family | q ladder | Free dimension | Native outputs per ConQuest fit |
| ---: | --- | --- | --- | ---: | ---: |
| 1 | `P2-RSM-CONNECTED-MULTIBRIDGE` | RSM | `31;61` | 10 | 8 |
| 2 | `P2-PCM-CONNECTED-MULTIBRIDGE` | PCM | `31;61` | 14 | 8 |

| Execution cap | Count |
| --- | ---: |
| ConQuest fits | 4 |
| mfrmr fits | 4 |
| Registry rows | 2 |
| q snapshots per row and engine | 2 |

The two fixture data frames are semantically identical. Each family is fitted
at q31 and q61 in each engine. The cap is exact, not a target or maximum that
can be filled with substitute rows. P3, replication, adaptive q values, and
wider P2 cases remain unauthorized.

## Fifteen fatal gates

Every gate blocks the smallest diagnostic and none can be waived because the
runtime is nearing expiry:

1. a current data-free semantic sentinel passes;
2. the runtime is not expired on the authorization date;
3. the sentinel path equals the explicitly requested executable path;
4. P1 semantic signatures and negative-control construction remain valid;
5. P2 fixture, matrix, and oracle construction remains valid;
6. P2 metric, denominator, and stop-rule construction remains valid;
7. the request contains exactly the two frozen registry rows;
8. the isolated candidate-output boundary is empty;
9. ordinary tests remain external-runtime-free;
10. the worktree is clean before execution;
11. q=`31;61` and the 4+4 fit cap are accepted exactly;
12. the auditor identity is present;
13. author overlap is explicitly declared, including `FALSE` when independent;
14. the auditor accepts that the run creates no interpretive claim; and
15. the minimum fatal-gate checklist is completed.

The runtime sentinel may be at most one day old. An expired, path-mismatched,
semantically failed, incomplete, dirty, over-cap, or undeclared request remains
blocked. Expiry pressure cannot convert a failed gate into a pass.

## Machine review

The repository-only construction review confirms that the semantic registry,
P2 fixtures, P2 metric contract, exact slice, review tiers, and fatal-gate
definitions are internally ready. It intentionally leaves the live bindings
false:

| Gate | Value |
| --- | --- |
| `CurrentRuntimeBound` | `FALSE` |
| `MinimumAuditAttested` | `FALSE` |
| `SmallestP2DiagnosticExecutionAuthorized` | `FALSE` |
| `P0Closed` | `FALSE` |
| `P1Closed` | `FALSE` |
| `IndependentComprehensiveReviewPassed` | `FALSE` |
| `EvidencePromotionAuthorized` | `FALSE` |
| `WiderExecutionAuthorized` | `FALSE` |
| `P3ExecutionAuthorized` | `FALSE` |
| `PublicClaimAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

Tests prove that the exact sealed diagnostic can become execution-eligible
under a current clean runtime result and a disclosed maintainer attestation,
while every downstream authority remains false. Extra rows, q121, a fifth fit,
pre-existing output, runtime-dependent ordinary tests, a dirty tree, path
mismatch, stale/expired runtime evidence, undeclared overlap, or a refused
no-claim condition each blocks execution.

## Subsequent binding

The separate
`conquest-minimum-diagnostic-live-authorization-record-0.2.3.md` now binds a
fresh data-free sentinel, clean-tree/empty-boundary observation, and disclosed
maintainer attestation. That later layer authorizes only the four ConQuest and
four mfrmr diagnostic fits; it does not retroactively change this construction
record's false live-binding fields. The next action is a fail-closed execution
harness and dry test, not more comprehensive pre-run documentation.

After every expected output is classified, an independent reviewer must inspect
the native transcripts, A/C orientation, raw-token handling, q states, complete
denominator, failure classification, and claim ceiling. Until that review
passes, the native results are diagnostic observations only.

No executable or artifact hash is a scientific acceptance criterion. No public
README or NEWS claim follows from this sequencing correction.
