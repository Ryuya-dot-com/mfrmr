# ConQuest P2 replacement nondegenerate fixture record for mfrmr 0.2.3

Status: `replacement_fixture_rejected_before_fit`; the single frozen seed
passed 12 of 13 pre-fit gates but one Rater-by-Criterion-by-category cell was
empty; no seed search and no model fit, 2026-08-15.

- Specification: `0.2.3-conquest-p2-replacement-nondegenerate-fixture-v1`
- Contract: `mfrmr_conquest_p2_replacement_nondegenerate_fixture_v1`
- Candidate: `mfrmr-0.2.3-conquest-p2-minimum-diagnostic-002`
- Frozen seed: `2026081502`
- Generating family: PCM

## Design

The replacement preserves the 48-Person connected-multibridge assignment and
288 observed rows. The two X groups receive the same frozen residual multiset
in reverse order, so their generating-theta means differ by exactly 0.9 without
confounding group dispersion. Responses are sampled once from the frozen PCM
truth. RSM and PCM would receive exactly the same observed data.

Thirteen gates were frozen before inspecting this generated fixture. They cover
shape, graph connectivity, full Rater-by-Criterion category support, Person
score support/range, score-X correlation and mean separation, noncancelling
Rater/Criterion sufficient statistics, absence of exact facet/category balance,
and generating-theta separation/variance.

## Observation

| Gate family | Observed | Requirement | Result |
| --- | ---: | ---: | --- |
| Persons / rows | 48 / 288 | 48 / 288 | pass |
| Graph | connected, 4 edges, 0 bridges, minimum overlap 12 | exact | pass |
| Minimum Rater×Criterion×category count | 0 | at least 1 | **fail** |
| Unique Person total scores | 16 | at least 6 | pass |
| Person total-score range | 16 | at least 5 | pass |
| Absolute score-X correlation | 0.33844 | at least 0.20 | pass |
| X-group mean-score separation | 2.79167 | at least 0.75 | pass |
| Maximum centered Rater score | 19.75 | at least 1 | pass |
| Maximum centered Criterion score | 21.66667 | at least 1 | pass |
| Exact facet/category balance | false | false | pass |
| Generating-theta X separation | 0.9 | at least 0.8 | pass |
| Generating-theta variance | 0.70173 | at least 0.5 | pass |

The candidate repairs the population-signal collapse seen in candidate 001,
but it is rejected because it does not meet its own prospective full-cell
support condition. No mfrmr or ConQuest fit was used to reach this decision.

## Decision

- `AllThirteenPrefitGatesPassed=FALSE`
- `SeedSearchPerformed=FALSE`
- `MfrmrFitPreflightAuthorized=FALSE`
- `ReplacementCandidateExecutionAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `PublicClaimAuthorized=FALSE`
- `ScientificEquivalenceInferred=FALSE`

The failed seed remains visible and must not be replaced by trying seeds until
one passes. The next design should guarantee support by construction—for
example, a prospectively defined coverage-conditioned or stratified response
mechanism—while retaining probability weighting, the multibridge graph, common
RSM/PCM data, and the same nondegenerate-signal gates. That design requires a
new candidate identity and must pass before any fit preflight is considered.
