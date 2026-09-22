# ConQuest minimum diagnostic harness record for mfrmr 0.2.3

Status: fail-closed harness implemented and dry-tested; no model fit launched,
2026-08-15.

- Specification: `0.2.3-conquest-minimum-diagnostic-harness-v1`
- Contract: `mfrmr_conquest_minimum_diagnostic_harness_v1`
- Live-authorization dependency:
  `mfrmr_conquest_minimum_diagnostic_live_authorization_v1`
- Execution identity: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-001`
- Executable path: `/Applications/ConQuest/ConQuest`

## Frozen execution surface

| Order | Registry row | Family | q | Expected free dimension | Native outputs |
| --- | --- | --- | ---: | ---: | ---: |
| 1 | `P2-RSM-CONNECTED-MULTIBRIDGE` | RSM | 31 | 10 | 8 |
| 2 | `P2-RSM-CONNECTED-MULTIBRIDGE` | RSM | 61 | 10 | 8 |
| 3 | `P2-PCM-CONNECTED-MULTIBRIDGE` | PCM | 31 | 14 | 8 |
| 4 | `P2-PCM-CONNECTED-MULTIBRIDGE` | PCM | 61 | 14 | 8 |

The four arms use the same sealed 48-person, 288-observation connected sparse
fixture. Each person has six observed and six structurally missing
Rater-by-Criterion responses. The wide response order varies Criterion fastest
within Rater and is bound to `facets=criterion(3) rater(4)`. The commands use
unique prefixes and request the parameter, A-matrix, regression, covariance,
case-EAP, history, internal-log, and parameter-review outputs.

The harness does not use a file hash as a scientific criterion. It validates
the fixture values, response layout, model statement, node count, output
registry, authority flags, and exact pre-execution file boundary directly.

## Run-once and failure behavior

- Preparation requires `authorize = TRUE`, an active dated live authorization,
  and a path that does not yet exist.
- A prepared bundle contains exactly fourteen files: six root control files and
  one input plus one command in each of four run directories.
- Any additional, missing, or opened candidate path invalidates execution.
- All four prespecified mfrmr fits are attempted once. A fit error or unexpected
  free dimension is retained and prevents ConQuest execution; lack of
  inference readiness is retained as an observed diagnostic state and does not
  silently redefine success.
- ConQuest arms are attempted once in frozen order. Exit status alone cannot
  pass: the terminal marker, absence of every registered semantic failure, and
  all eight nonempty native outputs are required. The first semantic failure
  stops later native arms and remains in the denominator as a retained failure.
- A started bundle cannot be reused or repaired in place. No deletion function
  exists in the harness.

This behavior avoids result-selected q expansion or opportunistic reruns while
preserving enough state to distinguish a model result from a command,
runtime, dimension, or output-completeness defect.

## Dry-test result

The runtime-free test constructs the bundle in a temporary directory and
checks the four-arm cap, 48-by-12 sparse mapping, 32 unique native paths,
semantic command identities, explicit opt-in, stale-authorization rejection,
existing-directory rejection, exact pre-execution boundary, run-once opening
rejection, status-zero semantic-failure rejection, and downstream false flags.
It calls neither `fit_mfrm()` nor ConQuest.

## Authority after execution

Even a complete 4+4 diagnostic may set only
`diagnostic_execution_complete_independent_review_required`.

| Authority | Value |
| --- | --- |
| `IndependentComprehensiveReviewPassed` | `FALSE` |
| `EvidencePromotionAuthorized` | `FALSE` |
| `WiderExecutionAuthorized` | `FALSE` |
| `P3ExecutionAuthorized` | `FALSE` |
| `PublicClaimAuthorized` | `FALSE` |
| `ScientificEquivalenceInferred` | `FALSE` |

The next admissible action is to commit this harness while the tree is clean,
prepare one new isolated candidate directory, and execute exactly this slice
before the live authorization expires. Native output then requires the separate
independent post-output review; it is not self-interpreting evidence.
