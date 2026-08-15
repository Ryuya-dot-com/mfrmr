# ConQuest P2 candidate-004 generation contract for mfrmr 0.2.3

Status: `candidate_004_generation_contract_frozen_audit_unopened`, 2026-08-15.

- Specification:
  `0.2.3-conquest-p2-candidate-004-coverage-conditioned-fixture-v1`
- Contract:
  `mfrmr_conquest_p2_candidate_004_coverage_conditioned_fixture_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-004`
- Frozen seed: `2026081504`
- Frozen complete-block draw ceiling: 10,000 per cell
- Generating family: PCM

## Prospective generation design

Candidate 004 uses the same 48-Person connected-multibridge assignment, 288
observed rows, common RSM/PCM data, PCM response probabilities, and
probability-weighted full-cell-support conditioning as candidate 003. Within
each of twelve Rater-by-Criterion cells, a complete 24-Person response block is
resampled until categories 0--3 are all represented. This is the declared
joint sampling design, not post-generation response repair.

The seed and identity are new and fixed before generation. Seed search,
candidate-003-output tuning, individual response editing, and a draw ceiling
change are forbidden. The same thirteen candidate-002 pre-fit gates are the
scientific/design denominator. Candidate identity, seed, and realized-data
disjointness from candidate 003 form a separate lineage gate and do not alter
that denominator.

## Dependency and scope

The 13/13 log-centered continuous-oracle qualification authorizes this new
fixture to be generated. It does not authorize a fit. The generated fixture
must pass all thirteen unchanged gates and the separate lineage gate before a
new mfrmr preflight contract may be written. A generation failure consumes
this candidate; it cannot trigger seed search, response repair, or threshold
changes.

## Current decision

- `GenerationContractReady=TRUE`
- `GenerationAuditOpened=FALSE`
- `SeedSearchPermitted=FALSE`
- `PostGenerationResponseRepairPermitted=FALSE`
- `MfrmrFitPreflightContractAuthorized=FALSE`
- `MfrmrFitAuthorized=FALSE`
- `Candidate003Reclassified=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`
