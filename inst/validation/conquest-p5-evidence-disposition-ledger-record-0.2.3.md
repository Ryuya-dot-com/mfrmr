# ConQuest P5 evidence and disposition ledger for mfrmr 0.2.3

Status:
`conquest_P5_evidence_and_disposition_ledger_complete_promotion_blocked`,
2026-08-15.

- Specification: `0.2.3-conquest-p5-evidence-disposition-ledger-v1`
- Contract: `mfrmr_conquest_p5_evidence_disposition_ledger_v1`
- Independent promotion review: not passed

## Runtime scope

All live evidence described here is tied to ConQuest 5.47.5 Demonstration
Version, expiring 2026-09-01, using an x86_64 Mach-O executable through Rosetta
on an arm64 macOS host. The data-free semantic sentinel passed. No portability
claim is made for another ConQuest version, edition, architecture route, or
platform.

## Execution lineages

The early six-arm lineage and the later P2 minimum-diagnostic lineage use
overlapping candidate numbers but are not the same candidates.

| lineage | arm ceiling | authorized | attempted | semantically complete | bounded comparison state |
| --- | ---: | ---: | ---: | ---: | --- |
| additive calibration | 4 | 4 | 4 | 4 | no frozen threshold or candidate |
| six-arm candidate 002 | 6 | 6 | 1 | 0 | command incident; five arms withheld |
| six-arm candidate 003 | 6 | 6 | 6 | 6 | 57/57 reported-decimal rows passed; no promotion |
| P2 minimum candidate 001 | 4 | 4 | 1 | 0 | degenerate-signal fixture; three arms withheld |
| P2 replacement candidate 002 | 4 | 0 | 0 | 0 | 12/13 prefit gates; rejected before fit |
| P2 minimum candidate 003 | 4 | 0 | 0 | 0 | internal q31--q61 integration gate failed |
| P2 minimum candidate 004 | 4 | 4 | 4 | 4 | 886/886 required dispositions passed same-author review |

Every withheld or unattempted arm remains in its candidate denominator. No
consumed candidate is rerunnable.

## Exact matched overlap

The six-arm candidate-003 result covers item-only Binary and additive
RSM/criterion-step PCM MML with one numeric population covariate at q31/q61.
Its classes are population intercept, population slope, population variance,
item/facet/step coordinates, matched-constant deviance, and within-engine
quadrature movement. Its 57/57 pass is retained as bounded, versioned,
same-platform technical evidence; independent promotion was not established.

P2 candidate 004 covers a 48-Person, 288-row connected-multibridge design with
four Raters, three Criteria, four categories, and one numeric covariate. RSM
and PCM use identical observed data at q61/q121. Its classes are population,
Rater, Criterion, shared or Criterion-specific step coordinates,
matched-constant deviance, quadrature movement, the complete 480-cell q121
conditional-probability grid, and 18 facet-ordering decisions. The
same-author numerical core passed; independent review is pending.

Neither overlap includes GPCM, DFF, infit/outfit, missingness, unused
categories, extreme-score conventions, disconnected designs, general sparse
allocation, posterior equivalence, uncertainty coverage, or truth recovery.

## Adverse, ineligible, and unresolved denominator

| outcome | fixed denominator | retained result |
| --- | ---: | --- |
| Six-arm command incident | 6 arms | one semantic failure plus five withheld |
| P2 candidate-001 fixture signal | 4 arms | one semantic failure plus three withheld |
| P2 replacement candidate-002 prefit | 13 gates | 12 pass plus one required rejection |
| P2 candidate-003 integration | 4 coordinate/deviance family checks | all four above the frozen limit |
| Candidate-004 q31 diagnostic | 4 coordinate/deviance family checks | all four retained as integration-limited diagnostics |
| Candidate-004 EAP | 96 rows | 96 typed ineligible |
| Candidate-004 posterior SD | 96 rows | 96 typed ineligible |
| Candidate-004 readiness | 4 selected fits | 4 remain review/not inference-ready |
| Candidate-004 global/continuous identification | 4 selected fits | 4 unresolved |
| Six-arm Binary oracle/local rank | 2 evidence layers | both unresolved |
| P2 structural negative controls | 2 fixtures | unused-category and disconnected controls retain expected typed rejection |
| Candidate-004 reviewer controls | 7 classes | two invariances accept; five mutation/missing-row classes reject |
| Independent promotion review | 2 successful comparison lineages | neither completed |
| Full P2 portfolio | 5,073 planned atomic outcomes | unopened; candidate 004 does not substitute for this denominator |

No row is dropped because it failed, was ineligible, was not launched, reached
a boundary, or remains unresolved.

## Public-decision map

- **Supported:** retain the existing optional pure-R bundle, normalization, and
  review handoff boundary. This is software functionality, not an equivalence
  claim.
- **Caveated:** retain the six-arm candidate-003 result only as versioned
  same-platform technical evidence and name the exact 5.47.5 x86_64/Rosetta
  runtime whenever it is discussed internally.
- **Disabled:** hidden-solution equality, EAP/SD equivalence, inference
  readiness through external agreement, GPCM/DFF/fit-statistic inheritance,
  and general software interchangeability.
- **Deferred:** candidate-004 public promotion until independent review; wider
  P2/P3 execution until a retained decision and its own gates justify it.

This ledger authorizes no root README or NEWS edit. Independent review is a
necessary but not sufficient condition for any later public wording; the exact
release-spine/public-scope gate must still be updated separately.

## Current decision

- `ExactOverlapStated=TRUE`
- `AdverseAndUnresolvedDenominatorsStated=TRUE`
- `PublicDecisionsMapped=TRUE`
- `IndependentReviewPassed=FALSE`
- `ReleaseSpineUpdateAuthorized=FALSE`
- `PublicTextChangeAuthorized=FALSE`
- `GeneralSoftwareInterchangeabilityInferred=FALSE`
- `ScientificEquivalenceInferred=FALSE`
