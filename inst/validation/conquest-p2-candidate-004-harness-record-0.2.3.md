# ConQuest P2 candidate-004 run-once harness for mfrmr 0.2.3

Status: `candidate_004_harness_frozen_bundle_unopened`, 2026-08-15.

- Specification: `0.2.3-conquest-p2-candidate-004-harness-v1`
- Contract: `mfrmr_conquest_p2_candidate_004_harness_v1`
- Execution identity:
  `mfrmr-0.2.3-conquest-p2-dense-pair-004-external-001`
- External plan: RSM q61/q121, then PCM q61/q121
- Expected native outputs: eight per arm, thirty-two total
- New mfrmr fits: zero

The harness prepares candidate 004's identical 48-Person, 288-observation data
for both families in a 48-by-12 wide response layout. The RSM command declares
`rater + criterion + step`; PCM declares
`rater + criterion + criterion*step`. Both use MML quadrature at q61 and q121,
the frozen iteration/convergence controls, population regression on X, and
unique candidate-specific prefixes. This complete dense pair permits within-
ConQuest integration movement to be separated from cross-engine differences.

Preparation requires the live authorization and a nonexistent directory with
the frozen basename. Validation compares the full semantic plan, fixture
values, command lines, journal, authority snapshot, required-output registry,
and exact unopened file boundary. It does not use hashes as a scientific gate.

Execution requires an explicit opt-in and the exact ConQuest path. The journal
is written before each process. Status zero alone cannot pass: each arm also
requires `End of Program`, no registered semantic error, and all eight nonempty
native outputs. A failure stops the remaining arm and retains partial output.

## Current decision

- `BundlePrepared=FALSE`
- `ExecutionOpened=FALSE`
- `ConQuestFitCap=4`
- `NewMfrmrFitAuthorized=FALSE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `WiderExecutionAuthorized=FALSE`
- `P3ExecutionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
