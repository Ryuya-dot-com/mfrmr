# mfrmr 0.2.3 common-GHQ IC integration pilot record

## Record state

| Field | Value |
| --- | --- |
| Evidence role | Pilot development evidence |
| First fixed-vector run | `0.2.3-draft.2` |
| Six-scenario fixed-vector matrix | `0.2.3-draft.3` |
| First refit matrix and public q-tier policy | `0.2.3-draft.4` |
| Common-formula replay and follow-on planning specification | `0.2.3-draft.5` |
| Run date | 2026-07-27 |
| Source identity | Commit `10cf3e8e8ff07f3ce1021ae28310ffcbd99d058c` plus uncommitted working-tree changes |
| Runtime | R 4.6.1; pkgload 1.5.3 |
| Evaluators | `ic-integration-pilot-0.2.3.R`; `ic-integration-pilot-matrix-0.2.3.R`; `ic-integration-refit-pilot-0.2.3.R` |
| Evaluation policies | `fixed_retained_vector_common_ghq_v1`; `independent_refit_then_common_ghq_v1` |
| Status | `review` |
| Confirmation authorized | No |

This record checks how common GHQ evaluation and independent refitting change
deviance and information-criterion differences in deterministic development
examples. It is not candidate-linked release evidence, does not freeze a
tolerance, and does not cover TAM QMC or cross-platform replication.

## Design

- Data: packaged `example_core`, 48 Persons, 768 responses, four Raters, four
  Criteria, and scores 1--4.
- Candidate 1: MML RSM, 8 free coordinates.
- Candidate 2: MML PCM with Criterion-specific steps, 14 free coordinates.
- Both candidates used q=31 for estimation, `maxit = 400`, and
  `reltol = 1e-10`; both were inference-ready.
- Fixed-vector evaluation ladder: q = 7, 15, 31, 61, 91, and 121.
- Reference: q=121. Candidate core review: q=31, 61, 91, and 121. q=7 and
  q=15 are coarse-grid stress points.
- Each q=31 reevaluation reproduced the stored objective exactly at displayed
  precision.

## Observed integration drift

`Raw deviance drift` is the largest absolute candidate-specific difference
from q=121. `Pairwise gap drift` is the absolute change in the RSM-minus-PCM
criterion difference from q=121.

| q | Maximum raw deviance drift | Pairwise gap drift | Role |
| ---: | ---: | ---: | --- |
| 7 | 6.772577 | 0.108248 | Coarse diagnostic |
| 15 | 1.557688 | 0.008503 | Coarse diagnostic |
| 31 | 0.034032 | 0.000996 | Candidate core |
| 61 | 0.0000955 | 0.0000227 | Candidate core |
| 91 | 0.00000175 | 0.000000102 | Candidate core |
| 121 | 0 | 0 | Reference |

Across q=31--121, all four tracked orderings were unchanged. The maximum
pairwise-gap drift was the same `0.000995239` additive likelihood component
for deviance, AIC, BIC, and SABIC. Relative to the q=121 gaps, the largest
ratio was:

| Criterion | Maximum gap-drift ratio | Ordering over q=31--121 |
| --- | ---: | --- |
| Deviance | 0.0000736 | Stable; PCM lower |
| AIC | 0.0006523 | Stable; PCM lower |
| BIC | 0.0001026 | Stable; RSM lower |
| SABIC | 0.0001091 | Stable; PCM lower |

The disagreement among AIC, BIC, and SABIC is substantive penalty behavior,
not integration-induced switching. This pilot therefore supports reporting
criterion-specific evidence rather than manufacturing one automatic winner.

## Draft.3 deterministic matrix extension

The repository runner `ic-integration-pilot-matrix-0.2.3.R` repeated the same
policy for six deterministic scenarios. All twelve source fits were
inference-ready. No fit warning or scenario failure was captured.

| Scenario | Rows | Persons | Candidates (k) | Maximum core raw drift | Maximum core gap drift | Maximum core gap-drift ratio | Core ordering |
| --- | ---: | ---: | --- | ---: | ---: | ---: | --- |
| Packaged core | 768 | 48 | RSM (8); PCM (14) | 0.0340318 | 0.0009952 | 0.0006523 | Stable |
| Bounded-GPCM slope | 480 | 60 | PCM (14); GPCM (17) | 0.0000573 | 0.0001097 | 0.0002138 | Stable |
| Sparse linked | 270 | 48 | RSM (11); PCM (15) | 0.0169400 | 0.0012400 | 0.0010338 | Stable |
| Rater-by-Criterion interaction | 768 | 48 | Additive (8); interaction (17) | 0.0330366 | 0.0046241 | 0.0020332 | Stable |
| Latent-regression signal | 540 | 90 | Intercept (7); X (8) | 0.000000168 | 0.000000168 | 0.00000000351 | Stable |
| Wide-latent near-tie | 960 | 120 | Null (9); noise X (10) | 0.0397363 | 0.0092436 | 0.0160086 | Stable |

Every cell was inside the draft.3 candidate rules over q=31--121. This is a
feasibility observation, not an acceptance decision. In the wide-latent cell,
the fitted latent variance was approximately 9. When q=7 and q=15 were added
to the ordering requirement, AIC and SABIC switched order even though the
q=31--121 order was stable. Equal integration IDs at a coarse q therefore do
not establish numerical adequacy.

## Draft.4 independent-refit extension

The refit runner independently refitted each candidate from its ordinary
deterministic start at q = 7, 15, 31, 61, 91, and 121. It then evaluated every
retained solution at common q=121. `Native gap drift` therefore includes both
solution movement and source-grid integration movement; `common gap drift`
removes the latter by using one reference evaluation grid. All fits were
inference-ready and no warning was captured.

| Scenario | Maximum core native gap drift | Maximum core common-q gap drift | Maximum parameter drift | Maximum common-q deviance excess | Core ordering | Full-ladder ordering |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| Packaged core | 0.000963980 | 0.000031259 | 0.00286970 | 0.000506954 | Stable | Stable |
| Bounded-GPCM slope | 0.000109681 | 0.0000000124 | 0.000027336 | 0.0000000557 | Stable | Stable |
| Sparse linked | 0.00123636 | 0.000003625 | 0.000821735 | 0.00001806 | Stable | Stable |
| Rater-by-Criterion interaction | 0.00458779 | 0.000036327 | 0.00236849 | 0.000475695 | Stable | Stable |
| Latent-regression signal | 0.000000168 | 0.000000000000227 | 0.0000000820 | 0.000000000000227 | Stable | Stable |
| Wide-latent near-tie | 0.00944565 | 0.000202065 | 0.00484794 | 0.000734096 | Stable | Unstable |

For the wide-latent cell, native q=7 reversed the AIC/SABIC preference. The
same q=7 retained solutions evaluated at q=121 restored the reference
preference, while parameter and common-reference deviance movement remained
small. The principal observed failure was therefore coarse integration
evaluation rather than convergence to a substantively different solution.
At q=15 the ordering was stable, but native AIC gap drift was about 0.1501
against a reference gap of about 1.4228, or 10.5%. That is too close to the
candidate relative-drift boundary to support automatic selection.

## Draft.4 public integration tiers

Contract `mfrmr_ic_person_v2` uses the pilot as a safety boundary, while not
mistaking it for a frozen tolerance:

| GHQ points | Tier | Selection consequence |
| ---: | --- | --- |
| below 15 | `coarse_screening` | Raw canonical ICs only; automatic comparison output is suppressed. |
| 15--30 | `intermediate_review` | Raw canonical ICs are review-only; automatic comparison output is suppressed. |
| 31--60 | `standard_start` | Otherwise eligible same-basis comparisons may begin. |
| 61 or more | `dense_sensitivity` | Otherwise eligible comparisons may provide denser-grid sensitivity evidence. |

Below q=31, `ICEligible` can be true because the formula and Person-likelihood
basis are valid, while `ICSelectable` is false because the integration grid is
not adequate for automatic ranking. `compare_mfrm()` consequently suppresses
delta criteria, weights, preferred-model labels, evidence ratios, and LRT.
This does not certify q>=31: close, consequential, or wide-latent comparisons
still need a prespecified denser common-grid sensitivity analysis.

## Draft.5 common-formula replay

After the common AIC/Person-BIC/Sclove-SABIC arithmetic was centralized for
both package and external-normalization use, both six-scenario matrices were
rerun under `0.2.3-draft.5`. All twelve fixed-vector source fits and all 72
independent refits remained warning-free. Every displayed fixed-vector and
refit drift value above was unchanged at recorded precision, the q=31--121
core retained every ordering, and only the known wide-latent full-ladder
q=7 reversal remained. The formula refactor therefore introduced no observed
numerical change in this development matrix.

## Candidate rules for the broader pilot

Draft.3 carries forward the following calibration candidates:

- reproduce each retained source-grid objective within
  `1e-10 * max(1, abs(stored objective))`;
- retain ordering throughout the candidate core ladder;
- keep maximum absolute raw-deviance drift at or below 0.10;
- keep pairwise criterion-gap drift at or below both 0.10 and 10% of the
  non-tied q=121 reference gap; and
- withhold preference when the reference gap is inside the numerical tie
  tolerance.

These values are proposals, not frozen acceptance criteria. The absolute 0.10
anchor is one twentieth of the conventional delta-IC 2 screening scale; it
was not selected merely to sit immediately above the observed q=31 result.

## Unresolved before freeze

1. Add weak-link, boundary-adjacent bounded-GPCM, and further deliberately
   near-tied fixed-vector cells; repeat the matrix across required platforms.
2. Extend the draft.6 TAM product-quadrature/deterministic-QMC pilot with
   stochastic integration repeats, replicated controls, and cross-platform
   evaluation; the first ladder remains `review` and does not freeze a rule.
3. Challenge the draft public q tiers in those broader cells and determine
   whether q=121 is a stable, practical reference ceiling.
4. Review the complete pilot matrix, revise the specification identity if
   needed, and only then freeze `IC-INTEGRATION-TOL` before confirmation.
