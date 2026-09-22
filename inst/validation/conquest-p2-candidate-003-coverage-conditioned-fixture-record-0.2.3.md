# ConQuest P2 candidate-003 coverage-conditioned fixture record for mfrmr 0.2.3

Status: `candidate_003_prefit_fixture_ready_mfrmr_preflight_only`; the single
frozen design passed all 13 unchanged pre-fit gates without fitting either
engine, 2026-08-15.

- Specification: `0.2.3-conquest-p2-candidate-003-coverage-conditioned-fixture-v1`
- Contract: `mfrmr_conquest_p2_candidate_003_coverage_conditioned_fixture_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-003`
- Frozen seed: `2026081503`
- Generating family: PCM
- Coverage rule: resample a complete 24-Person response block within each
  Rater-by-Criterion cell until all four categories occur, with a frozen
  10,000-draw fail-closed ceiling

## Prospective design

The candidate preserves the 48-Person connected-multibridge assignment, 288
observed rows, common RSM/PCM data, frozen PCM probability model, and the same
thirteen gates that rejected candidate 002. One seed is allowed. It is not
searched. The generator neither edits individual responses nor repairs a
completed dataset after seeing its gate results.

Coverage conditioning is part of the generating rule: each complete
Rater-by-Criterion response block is accepted only when categories 0--3 all
occur. In the frozen realization, all twelve cells met this condition on their
first draw, so zero complete blocks were rejected. That observation does not
remove the conditioning rule or permit a different seed.

## Observation

| Gate family | Observed | Requirement | Result |
| --- | ---: | ---: | --- |
| Persons / rows | 48 / 288 | 48 / 288 | pass |
| Graph | connected, 4 edges, 0 bridges, minimum overlap 12 | exact | pass |
| Minimum Rater×Criterion×category count | 1 | at least 1 | pass |
| Unique Person total scores | 15 | at least 6 | pass |
| Person total-score range | 17 | at least 5 | pass |
| Absolute score-X correlation | 0.37149 | at least 0.20 | pass |
| X-group mean-score separation | 3.08333 | at least 0.75 | pass |
| Maximum centered Rater score | 17 | at least 1 | pass |
| Maximum centered Criterion score | 13.33333 | at least 1 | pass |
| Exact facet/category balance | false | false | pass |
| Generating-theta X separation | 0.9 | at least 0.8 | pass |
| Generating-theta variance | 0.85319 | at least 0.5 | pass |

## Claim boundary

Conditioning on full cell support changes the joint sampling law from an
unconditional product of independent PCM draws. This candidate can test
whether mfrmr and, after new authorization, ConQuest behave compatibly on the
same supported data. It cannot establish unbiased parameter recovery,
frequentist calibration, realistic prevalence, or transport beyond this
fixture. First-draw acceptance does not widen that claim.

Passing pre-fit gates authorizes only a separately implemented internal mfrmr
q=31/61 RSM/PCM preflight. That preflight must expose dimensions, readiness,
population-variance behavior, and failures before any new ConQuest execution
can be proposed.

## Decision

- `AllThirteenPrefitGatesPassed=TRUE`
- `SeedSearchPerformed=FALSE`
- `ResponseRepairPerformed=FALSE`
- `MfrmrFitPreflightAuthorized=TRUE`
- `TruthRecoveryAuthorized=FALSE`
- `ExternalExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

Candidate 001 remains consumed and candidate 002 remains rejected. Candidate
003 does not inherit either candidate's authorization. A clean mfrmr-only
preflight, a fresh data-free runtime sentinel, a new minimum audit, an empty
external output root, and independent post-output review remain separate
gates.
