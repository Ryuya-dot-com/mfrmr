# Fixed-calibration amended G4 current-source v5 contract record

Status: `v5_rules_frozen_candidate_unbound_confirmation_unopened`, 2026-08-25.

- Specification:
  `0.2.4-fixed-calibration-g4-current-source-boundary-evidence-v5`
- Contract: `mfrmr_fixed_calibration_g4_current_source_evidence_v5`
- Rules frozen before v5 execution: `TRUE`
- V5 disjoint fixture identities frozen: `TRUE`
- V5 execution opened: `FALSE`
- V5 candidate source identity bound: `FALSE`
- CORE-05 complete for current source: `FALSE`
- CORE-06 complete for current source: `FALSE`
- G4 exit complete for current source: `FALSE`
- G6 authorized: `FALSE`
- Public API authorized: `FALSE`

## Why v5 is required

Hosted run `32822833138` opened and completed v4 results on macOS release,
Windows release, Ubuntu devel, and Ubuntu oldrel-1. The Ubuntu release full
package suite then exposed a production integration defect before its G4 worker
ran: the public reference benchmark attempted an ordinary posterior-shift score
from a source fit whose numerical readiness was `review`. The scoring API
correctly refused it.

The repair keeps the scoring boundary fail-closed. A non-scoring-ready
benchmark fit produces no review-only posterior score and retains its
posterior-shift recovery row as `Warn` with an explicit not-evaluated reason.
This changes `R/api-reference-benchmark.R`, which is now part of the bound
production registry. Since four v4 results had already been observed, v4 is
consumed. Its receipts remain immutable failure-history evidence and cannot be
combined with v5.

## Disjoint v5 identities

The 49-cell denominator, eleven numerical rules, default 31-node scoring basis,
one-node source-fit adversary, historical nine-node non-authorizing controls,
three resource scales, and five-platform order are unchanged. The four
authoritative confirmation identities are new:

- RSM/PCM default-31: modular-1039, source offset 271, confirmation offset
  919, 58 source Persons, and 11 confirmation Persons;
- RSM/PCM source-one/default-31: modular-1049, source offset 431,
  confirmation offset 977, 50 source Persons, and 9 confirmation Persons.

The historical modular-997 controls remain previously used and cannot
authorize v5. Modular-1009/1013, modular-1019/1021, and modular-1031/1033 are
all consumed. The v5 rules are frozen before candidate binding or execution.

- `V4HostedRunRetained=32822833138`
- `V4CompletedReceipts=4`
- `V4UbuntuReleaseReceiptCreated=FALSE`
- `V4IdentityReuseAuthorized=FALSE`
- `V5ContractFrozen=TRUE`
- `V5CurrentExecutionOpened=FALSE`
- `V5CandidateBound=FALSE`
- `V5DenominatorCells=49`
- `V5NumericalRules=11`
- `V5ProductionBoundaryFiles=6`
- `V5HostedPlatformCells=5`
- `CORE05Complete=FALSE`
- `CORE06Complete=FALSE`
- `G4ExitComplete=FALSE`
- `G6Authorized=FALSE`
- `PublicAPIAuthorized=FALSE`
- `NextGate=bind-clean-v5-candidate-and-run-complete-matrix`
