# ConQuest prospective tolerance-freeze record for mfrmr 0.2.3

Status: canonical tolerance table frozen, candidate unbound, 2026-08-12. This
is a future-candidate-only engineering decision. It does not launch ConQuest,
evaluate candidate output, reclassify the opened calibration, infer scientific
equivalence, or authorize confirmation.

## Frozen decision

The canonical table contains all 57 rows required by the generic prospective
contract:

| Criterion | Units | Rows | Signed interval | Absolute tolerance |
| --- | --- | ---: | ---: | ---: |
| `EXT-CQ-TOL` | common model coordinate | 16 | `[-1e-5, 1e-5]` | `1e-5` |
| `EXT-CQ-TOL` | positive deviance | 3 | `[-2e-6, 2e-6]` | `2e-6` |
| `IC-INTEGRATION-TOL` | common model coordinate | 32 | `[-2e-6, 2e-6]` | `2e-6` |
| `IC-INTEGRATION-TOL` | positive deviance | 6 | `[-2e-6, 2e-6]` | `2e-6` |

The first two rows total 19 cross-engine rules. The last two total 38
within-engine q61-minus-q31 rules. Each rule remains separate by engine,
family, and estimand class; no pooled maximum can hide a missing or failing
class. The exact reported-decimal estimand is the target. Hidden optimizer
coordinates are outside this contract.

The serialized canonical table has SHA-256
`64ab3338dc5e5144d98a7a8775512b5665f407e4d8778972521ff5bfe8754521`.
Every row has rationale type
`opened_calibration_future_candidate_only`,
`CalibrationInformed = TRUE`, `OpenedCalibrationEligible = FALSE`, and
`Frozen = TRUE`.

## Why this is not retrospective passage

The opened calibration informed the engineering margin, so it cannot pass the
rule it helped create. The table is usable only for a disjoint six-arm
`Binary/RSM/PCM x q31/q61` candidate whose identity, sources, expected-empty
outputs, normalizer coverage, and reported-output precision policy are bound
before any candidate output exists or is opened.

The generic contract and the canonical freeze have distinct roles:

- `conquest-prospective-tolerance-contract-0.2.3.R` supplies the 57-row schema,
  candidate-binding schema, and fail-closed preflight. Its empty tolerance
  template deliberately remains an invalid fixture.
- `conquest-prospective-tolerance-freeze-0.2.3.R` fills that schema from the
  independently source-bound basis, reproduces the exact canonical table, and
  rejects any value, eligibility, rationale, or source-identity mutation.

## Current machine result

With the canonical table and the empty candidate-binding template, the review
status is `tolerance_frozen_candidate_binding_required`. The current fields
are:

| Field | Value |
| --- | --- |
| `ToleranceFrozen` | `TRUE` |
| `RequiredToleranceRows` | `57` |
| `CurrentCandidateBound` | `FALSE` |
| `CandidateCoreStructurallyAuthorized` | `FALSE` |
| `candidate_execution_authorized = FALSE` | invariant |
| `OpenedCalibrationReclassificationAuthorized` | `FALSE` |
| `HiddenSolutionEquivalenceEligible` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |
| `ConfirmationAuthorized` | `FALSE` |
| `SparseExtensionAuthorized` | `FALSE` |
| `LargeSimulationAuthorized` | `FALSE` |

A synthetic structurally complete future fixture reaches only
`tolerance_and_candidate_binding_structurally_ready`. That state demonstrates
schema completeness. It does not make execution, equivalence, or confirmation
true. Execution authorization belongs to the later exact binding and
expected-empty-output workflow, not to this freeze layer.

## Verification and identities

The focused tolerance-freeze test completed with 72 expectations, zero
failures, and zero skips. It covers typed budgets, the exact 57-row table
and table hash, default candidate-unbound closure, structural-readiness versus
execution-authorization separation, mutation failure, and this record's
source identities. The complete ConQuest-labelled slice completed with 666
expectations, zero failures, zero errors, zero skips, and zero warnings.
The source-loaded claim-disposition, release-readiness, P1p, and GPCM model-
identity slices passed; the P1p stored-result audit had its one declared
opt-in skip. A source tarball with built vignettes then passed
`R CMD check --no-manual` under R 4.6.1 with `Status: OK`. Repository network
restrictions prevented refreshing CRAN/Bioconductor indexes, but produced no
check error, warning, or note.

| Artifact | SHA-256 |
| --- | --- |
| `conquest-prospective-tolerance-basis-0.2.3.md` | `9b4c76add31061dcee532fcf2528e2614bd151dca75d3792fbde5364361279bd` |
| `conquest-prospective-tolerance-freeze-0.2.3.R` | `23bd8c5e4f439097afd546f3b726964d18b3438c085fb6cbdf549509e9b420b5` |
| `conquest-prospective-tolerance-contract-0.2.3.R` | `d00292ede7985ce36c936a38cebe744478fdb0bffee74b75df025b485ca7b605` |
| `tests/testthat/test-conquest-prospective-tolerance-freeze.R` | `8641877be59b82e7d3bde9b5f5837e9a6a81c790a2040e73808453d830362681` |
| `tests/testthat/test-conquest-prospective-tolerance-contract.R` | `ff4dbfad26faa9dea98792cdf56cee35cea691c5f7640623558b31ee02fd1699` |

## Next admissible action

Create an exact candidate binding against the clean source commit produced by
this slice and a six-arm expected-empty-output manifest. Validate all hashes
and coverage declarations before launching the candidate. Candidate results
must then be retained and adjudicated row by row. Only that later evidence can
change the three ConQuest release rows from `review`; tolerance passage alone
cannot do so.
