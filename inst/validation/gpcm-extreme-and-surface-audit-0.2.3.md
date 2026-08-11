# GPCM extreme-response and central-surface audit for 0.2.3

Status: deterministic development audit, 2026-08-11. This record changes no
GPCM capability row and is not exact-candidate or external-validation evidence.

## Decision being checked

This audit separates three questions that must not be collapsed:

1. does the aligned single-owner relative-slope GPCM likelihood execute;
2. are extreme Persons and boundary-constant non-Person facet levels represented
   with mathematically honest point-estimate semantics; and
3. do central summaries, diagnostics, and figures preserve the source fit's
   readiness decision?

An object returning without error answers only the first part of question 3.
It does not establish global identification, an interior maximum, valid
covariance, or inferential readiness.

## Deterministic five-category challenge

The retained challenge has 20 Persons, four Raters, four Criteria, 320 observed
ratings, and the original score range 1--5. All categories remain represented
within the non-forced data. `P01` is then forced to score 5 on all 16 responses,
and `R1` is forced to assign 5 on all 80 responses. GPCM steps and positive
relative slopes are both owned by `Criterion`.

### JML result

- `P01` has `PrimaryEstimate = +Inf`, `ParameterStatus = unbounded_high`, and
  `PrimaryEstimateBasis = jml_extreme_sufficient_score_boundary`.
- The finite optimizer coordinate is retained only as `OptimizerEstimate` with
  `OptimizerEstimateUse = numerical_trace_only`; it is not a finite maximizer
  of the original JML likelihood.
- The data-support audit records `Rater:R1` as a boundary-constant level with 80
  observations, all at score 5.
- The joint Person-structural additive audit certifies `R1` as
  `unbounded_low`. Under sum-to-zero Rater identification, `R2`--`R4` are the
  compensating `unbounded_high` directions. These are one relative joint
  recession geometry, not four independent extreme-response conclusions.
- The GPCM audit remains incomplete because the additive certificate does not
  close the general joint additive/log-slope boundary. The fit therefore stays
  blocked or review-only according to its retained numerical state.

### MML result

- `P01` has a finite EAP and finite posterior SD, with
  `ReasonCodes = mml_extreme_response_prior_regularized`. This is a posterior
  summary under the fitted person distribution, not an ordinary finite
  person MLE.
- `R1` has a finite retained optimizer estimate in this challenge, but MML's
  person-distribution integration is not a general penalty on fixed Rater
  effects. The data-support audit therefore still records the all-5 Rater and
  holds reporting for stability review.
- JML additive recession conclusions are correctly marked not applicable on
  the MML branch. A boundary-constant Rater warning must not be relabelled as a
  proved infinite MML estimate, and a finite MML coordinate must not be
  relabelled as proof of interiority.

## Central result-surface audit

On the five-category JML challenge, the following routes returned their
documented object classes: `print(fit)`, `print(summary(fit))`,
`diagnose_mfrm(..., diagnostic_mode = "legacy")`, Wright, pathway, CCC, and
CCC-surface plots, `compute_information()`, `category_structure_report()`, and
`category_curves_report()`.

The fit-derived plot routes carry `interpretation_status = review_only`, retain
the fit/data/design/stability readiness table, and emit a review-only warning.
Fit summary now exposes two distinct tables:

- `facet_support_boundaries`, for observed boundary-constant support; and
- `facet_recession_review`, for certified JML additive recession directions,
  with optimizer traces, audit scope, and audit completeness.

Standalone diagnostic objects now retain `fit_readiness`,
`fit_readiness_components`, and `fit_readiness_parameters`. Their summaries
state that a blocked or review-only source fit remains non-inference-ready;
diagnostic flags cannot override the source fit gate.

The focused GPCM verification file passed 56 expectations. A separate
capability, summary/plot, fair-average, information, and marginal-fit batch
passed 600 expectations, and the related console/workflow/summary compatibility
batch also remained green after normalizing one test-only tibble/data-frame
class comparison. Three warnings in the focused GPCM file are the intended
review-only plot warnings, not unexpected numerical warnings.

## Completion judgment

The implemented likelihood and central descriptive/review surfaces are
substantial, but the statistical claim is not complete. The executable
capability registry contains 19 rows: two `supported`, 15
`supported_with_caveat`, one `blocked`, and one `deferred`. The accurate label
remains **bounded aligned single-owner relative-slope GPCM**, not unrestricted
GPCM and not a generic generalized MFRM.

Remaining release-relevant work is ordered as follows:

1. finish prespecified independent score/Jacobian checks and global
   additive/log-slope boundary semantics for the exact implemented model;
2. finish parameter-level readiness/covariance/SE/CI propagation for the
   retained GPCM parameter classes;
3. bind criterion-owned and rater-owned evidence as separate strata;
4. perform small raw-token-preserving ConQuest/FACETS overlap microcases only
   after an exact probability/constraint map is fixed; and
5. run recovery or sparse-design simulation only for claims whose release
   decision cannot be resolved by algebra, deterministic reductions, or the
   matched microcases.

Secondary category/information artifacts compute on review-only fits but do not
yet all embed the complete readiness record. That adapter propagation remains a
bounded row-23 follow-up; it does not justify expanding this audit into an
inventory-wide visualization rewrite or a large simulation.
