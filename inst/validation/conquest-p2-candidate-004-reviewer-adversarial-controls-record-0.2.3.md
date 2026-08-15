# Candidate-004 reviewer adversarial controls for mfrmr 0.2.3

Status: `candidate_004_reviewer_semantic_negative_controls_passed`,
2026-08-15.

These deterministic controls challenge the repository-only numerical reviewer;
they do not launch ConQuest, refit mfrmr, or reopen candidate 004.

| mutation or invariance | required result | observed |
| --- | --- | --- |
| Native A-matrix semantic row reorder with unchanged GIN/category meaning | accept | accepted for RSM and PCM |
| One native A-matrix coefficient mutation | reject | rejected for RSM and PCM |
| Fixture numeric storage-mode change (`-1/1` integer versus double) | accept | accepted |
| One fixture response-value mutation | reject | rejected |
| One native parameter-label mutation | reject before numerical adjudication | rejected |
| One iteration-sequence gap | reject before numerical adjudication | rejected |
| Any missing atomic row | retain denominator as incomplete/failed | enforced by exact expected counts |

The asymmetry is intentional: irrelevant serialization and row order do not
become scientific criteria, while changes to model coefficients, data values,
coordinate labels, history continuity, or denominator completeness fail
closed. No hash or byte identity is used as a scientific acceptance gate.

## Current decision

- `ReviewerAdversarialControlsPassed=TRUE`
- `Candidate004Reopened=FALSE`
- `ExternalRerunAuthorized=FALSE`
- `EvidencePromotionAuthorized=FALSE`
- `IndependentComprehensiveReviewPassed=FALSE`
- `ScientificEquivalenceInferred=FALSE`
