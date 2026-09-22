# ConQuest P2 candidate-004 fixture observation for mfrmr 0.2.3

Status: `candidate_004_prefit_fixture_ready_mfrmr_preflight_contract_required`;
the single frozen generation passed all 13 unchanged pre-fit gates and the
separate candidate-003 lineage gate, 2026-08-15.

- Specification: `0.2.3-conquest-p2-candidate-004-fixture-observation-v1`
- Contract: `mfrmr_conquest_p2_candidate_004_fixture_observation_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004`
- Frozen seed: `2026081504`
- Generating family: PCM

## Observation

| Gate family | Observed | Requirement | Result |
| --- | ---: | ---: | --- |
| Persons / rows | 48 / 288 | 48 / 288 | pass |
| Graph | connected, 4 edges, 0 bridges, minimum overlap 12 | exact | pass |
| Minimum Rater×Criterion×category count | 1 | at least 1 | pass |
| Unique Person total scores | 15 | at least 6 | pass |
| Person total-score range | 15 | at least 5 | pass |
| Absolute score-X correlation | 0.30871 | at least 0.20 | pass |
| X-group mean-score separation | 2.45833 | at least 0.75 | pass |
| Maximum centered Rater score | 19.75 | at least 1 | pass |
| Maximum centered Criterion score | 17.33333 | at least 1 | pass |
| Exact facet/category balance | false | false | pass |
| Generating-theta X separation | 0.9 | at least 0.8 | pass |
| Generating-theta variance | 0.71635 | at least 0.5 | pass |

All twelve Rater-by-Criterion cells contained all four categories. Every cell
accepted its first complete 24-Person block, so no block was rejected. The
probability-weighted conditioning rule remains part of the design despite this
realization. Candidate identity, seed, realized response data, and Person
generating values differ from candidate 003.

## Claim boundary

This is a fixture-shape and signal result only. The full-support conditioning
changes the joint data-generating law, so the fixture is not calibration or
truth-recovery evidence. Passing generation gates authorizes a new prospective
mfrmr preflight contract, not a fit, external execution, or comparison claim.

## Decision

- `AllThirteenPrefitGatesPassed=TRUE`
- `DisjointCandidate003IdentitySeedAndData=TRUE`
- `SeedSearchPerformed=FALSE`
- `ResponseRepairPerformed=FALSE`
- `MfrmrFitPreflightContractAuthorized=TRUE`
- `MfrmrFitAuthorized=FALSE`
- `Candidate003Reclassified=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

The next contract must freeze candidate 004's mfrmr fitting arms, expected
dimensions, variance/readiness gates, and bounded adaptive integration rule
before any fit is opened. External output roots, runtime sentinel, minimum
audit, and ConQuest execution remain later and separate gates.
