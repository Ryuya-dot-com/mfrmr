# GPCM extreme-response and central-surface audit for 0.2.3

Status: deterministic development audit, refined 2026-08-12. This record changes no
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

## Refined five-category endpoint roadmap

The next work must distinguish an observed endpoint pattern from a parameter
boundary. Throughout this section, "all 5" and "all 1" refer only to retained,
positive-weight contributing rows after missing-value processing. A 95% endpoint
rate is near-extreme weak information, not an exact extreme sufficient score.

For the implemented additive orientation, increasing a free Person measure
raises category probabilities, while increasing a Rater severity lowers them.
Consequently, a separately free JML Person with all 5 has a `+Inf` primary
measure and one with all 1 has a `-Inf` primary measure. An all-5 Rater suggests
the candidate leniency direction `severity -> -Inf`, and an all-1 Rater suggests
`severity -> +Inf`, but neither conclusion follows from the raw response rate
alone. Centering, anchors, crossed support, other facet coordinates, steps, and
interactions can couple or close the direction. A constrained structural or
joint likelihood-recession certificate is therefore required before a
non-Person primary value can be called unbounded.

MML has a different contract. An endpoint Person receives a finite
prior/population-regularized EAP, not a finite ordinary Person MLE. Integration
over Persons does not automatically regularize a fixed Rater, Criterion, step,
or interaction coordinate. JML recession certificates cannot be copied to the
marginal likelihood, and a finite MML optimizer coordinate is not proof of an
interior marginal maximum. Any finite extreme-score adjustment or finite-item
bias correction is a third, explicitly named estimator/display stratum; it is
not the maximizer of the unmodified JML likelihood.

### Deterministic scenario ladder

| ID | Five-category construction | Required conclusion | Current state |
| --- | --- | --- | --- |
| `EXT5-P-HI` | One independently free Person receives 5 from every assigned Rater on every Criterion; all other data retain categories 1--5. | JML primary `+Inf`; optimizer iterate trace-only; MML finite EAP with provenance. | JML is covered in the retained combined challenge. The reflected 20-response P0b MML microcase preserves finite-EAP provenance but exposes a materially better low-variance start; it remains review-only. |
| `EXT5-P-LO` | Sign-reversed all-1 Person with otherwise retained 1--5 support. | JML primary `-Inf`; the same SE/CI/ranking exclusions as the high endpoint; MML finite EAP. | The reflected five-category P0b MML case now covers sign and provenance, but also exposes start-sensitive population scale. Full JML surface/public propagation remains separate. |
| `EXT5-R-HI` | One Rater gives 5 on every retained Person-by-Criterion assignment, first without any extreme Person. | Record the support boundary; report `severity -> -Inf` only when the exact constrained audit certifies it. | The all-5 support and a relative joint direction are covered only in the combined challenge; isolated attribution remains. |
| `EXT5-R-LO` | Sign-reversed all-1 Rater. | Record the support boundary; report `severity -> +Inf` only when certified. | Structural sign behavior is tested outside the five-category GPCM surface; full parity remains. |
| `EXT5-PR-JOINT` | Cross the Person and Rater endpoints as high/high, low/low, and high/low on a connected design. | Separate the Person sufficient-score result from any compensating facet direction; do not count one joint geometry as several independent boundary facts. | High/high is covered; attribution contrasts remain. |
| `EXT5-CONST-NEG` | A response-constant Rater in a design where the constrained cone has no recession direction. | Support warning present, `finite_in_audited_subspace` when the exact audit is complete, and no automatic infinity. | Binary structural negative control exists; five-category GPCM control remains. |
| `EXT5-ANCHOR` | Repeat the isolated Rater endpoint with that level directly anchored, then with only a linked external anchor. | Directly fixed values stay `fixed`; linked anchors must be evaluated through the exact free-coordinate design and may not inherit the unanchored conclusion. | Additive direct-anchor behavior is tested; full GPCM and linked-anchor parity remain. |
| `EXT5-NEAR` | Endpoint proportions below 1, prespecified near 0.95, under balanced and unequal Rater workloads. | `weak_information` or finite audited status as appropriate; never an exact-boundary label from a heuristic rate cutoff. | Balanced 19/20 high and low Person cases are covered by P0b without an exact-boundary label; both expose start-sensitive population scale. Unequal workload remains pending. |
| `EXT5-CELL` | Make a Criterion and then one Rater-by-Criterion cell all 5/all 1, with the interaction disabled and enabled in separate models. | Attribute a candidate only to parameters present in the fitted model; use the exact parameter orientation and cone/path certificate. | Pending; interaction results must not be inferred from the additive Rater audit. |
| `EXT5-STEP` | Remove an internal category globally, within one Criterion, and within one Rater workload in separate cases. | Keep category/step support, Person boundary, and facet recession as distinct diagnoses. | Global and local support infrastructure exists; endpoint integration remains. |

The ladder is deliberately small. Each row is a deterministic algebraic or
microcase question. It should not be inflated into a factorial recovery study.
High/low symmetry is required because it detects orientation and recoding
errors that a one-sided all-5 case cannot detect.

### Endpoint solution-stability P0b result

The fixed P0b extension uses 20 Persons, five Raters, four Criteria, all five
categories within every Criterion, q=31, and the seven prespecified P0 starts.
Exact high/low and 19/20 near-high/near-low Person cases are exact score
reflections. All four source fits report finite posterior EAPs, but all four
have `PopulationConverged = FALSE`, `InferenceReady = FALSE`, and extremely
large fitted population variances. In every scenario only the `variance_low`
start passes the existing optimizer numerical rule and has a lower common
objective than the default by about 1.72--4.19. None of the 28 candidates is
P0-stability eligible because the population-boundary, solution-tolerance, and
continuous-integration rules are not frozen.

Thus the endpoint contract is working as provenance, while the current source
fit is not evidence of a stable finite population solution. The record is
`gpcm-endpoint-solution-stability-p0b-record-0.2.3.md`; it authorizes neither a
candidate replacement nor a large simulation.

The subsequent q=31 P1a nuisance-profile calibration reoptimizes the other 23
free coordinates at ten fixed log-variance values from both P0b basins. Its
diagnostic finite-grid minimum is the low-variance anchor in all four cases and
passes the existing nuisance-stationarity rule there. The high-variance tails
do not pass that rule, and the wider reflected curves retain numerical
high/low discrepancies. This supports carrying only the low-variance basin
forward as a qualified local candidate; it does not establish a global
profile, a variance-boundary limit, or solution selection.

The bounded P1b follow-up independently refits that qualified local candidate
at q=31, 61, and 91 and reevaluates all vectors at held-out q=121. All 12 low-
basin arms pass the existing native numerical rule and remain closely aligned
in common objective, labelled coordinates, Person EAP, and posterior SD. In
contrast, none of the 12 predesignated default/high-variance diagnostic arms
passes native stationarity, and several have enormous q=121 objective and
score discrepancies. This closes only the finite-q calibration of one local
basin. It neither supplies a continuous-integral certificate nor authorizes
source-solution replacement; population-boundary and selection contracts
remain ahead of Hessian, DFF, fit, and ranking work.

P1c then evaluates the lower population-variance boundary without substituting
a merely small positive variance. For fixed nuisance coordinates, bounded
continuous response likelihoods converge to the degenerate distribution, and
q=1 evaluates that limit exactly. The q=1 objective matches an independent
conditional-GPCM reconstruction and is invariant to the unused finite
log-variance placeholder. Nevertheless, none of the 12 three-start boundary
nuisance traces passes stationarity. Returned expanded slopes are highly start
sensitive, so finite objectives cannot be treated as a profiled zero-boundary
solution. The next deterministic lane must combine zero variance with explicit
log-slope paths; neither the finite interior nor the zero boundary is selected.

P1d implements that first combined lane along the C4 direction independently
observed in all four P1c scenarios. It decreases variance at twice the log rate
at which C4 slope grows and compensates the other slopes symmetrically, so the
C4 latent-noise scale remains nonzero and q=1 transport is invalid. Finite
q=61/91/121 objectives agree closely at the same vectors, but stationarity
degrades sharply: 14/48 points pass overall and zero of 32 points with
`t >= 4` passes. The worse terminal objectives therefore do not yet certify a
finite turnback. A coordinate-aware reduced-limit or reparameterized profile
must precede the separate upper-variance path and source-solution selection.

P1e supplies that coordinate-aware representation for the declared symmetric
C4 ray. The finite map is affine and full rank, preserves the original
likelihood exactly, and separates `exp(-t)` target/Rater coordinates from
`exp(t/3)` non-target location/step coordinates. All 32 transformed fits pass
their declared scale-specific rule while raw gradients remain visible. The
independently coded direct limit retains C4 latent/Rater variation, removes it
from C1--C3, and passes from both starts in every reflection. Its objective is
3.38--4.15 above the interior candidate conditional on the fixed
`a_C4 * sigma` coefficient. P1f maps all finite-random-product linear rates to
a standard simplex and recovers P1e as a fixed-coefficient submodel. The
released coefficient has a resolved nonzero derivative, so P1e closes only
its declared path, not the C4 face. P1f enumerates the 14 nonempty proper
target faces and derives their canonical likelihood; optimizing them and
classifying the empty-target deterministic-Rater hierarchy remain ahead of
source-solution selection.

### Ordered work and exit criteria

1. **Close the 0.2.3 deterministic core.** Retain the completed reflected
   Person exact/near P0b slice, then add isolated `EXT5-R-HI/LO`,
   joint-attribution, constant-response negative, anchor, and unequal-workload
   near controls. Require exact statuses, audit scope,
   completeness, reason codes, and independent likelihood-path checks; do not
   accept optimizer convergence as a substitute.
2. **Propagate one state contract through the public surfaces.** `fit`,
   `summary`, `print`, `diagnose`, draw-free `plot`, export, report, and replay
   must agree on the primary estimate, optimizer-trace status, support warning,
   recession certificate, and readiness provenance. An endpoint Person or
   certified non-Person boundary must not acquire an ordinary SE/CI, arbitrary
   finite rank, or ordinary facet-separation contribution downstream.
3. **Close estimator-specific gaps.** Keep raw finite JML traces, JML
   extended-profile limits, named adjusted/bias-reduced estimates, and MML EAPs
   in separate fields and comparison strata. Develop a marginal-likelihood
   boundary audit for fixed facets rather than reusing the JML cone. Retain the
   P1a low-variance MML basin as a local q-sensitivity candidate and the
   nonstationary default/high basin as diagnostic-only. Extend the joint GPCM
   audit to the retained additive/log-slope parameterization before promoting
   slope uncertainty.
4. **Gate fit and DFF by estimand.** Fit indices and DFF may execute for
   diagnosis, but they cannot override a review-only source fit. Endpoint-
   affected rows need an explicit eligibility reason; location-like DFF,
   nonuniform slope/step DFF, and interaction DFF stay separate. Facet
   separation, rank recovery, and coverage are evaluated only on their declared
   estimable target sets.
5. **Use external programs only after identity matching.** A later licensed
   FACETS bundle must compare raw-JML boundary status separately from any
   adjusted finite display, with exact category map, constraints, anchors,
   correction mode, convergence rule, and raw printed precision retained.
   ConQuest/TAM/immer comparisons remain estimator- and model-specific; a
   finite result from a different integration, adjustment, or penalty contract
   is not endpoint equivalence evidence.
6. **Simulate only unresolved operating characteristics.** After steps 1--5,
   use a bounded prespecified grid only to estimate false-ready/false-boundary
   rates, bias/RMSE and coverage on estimable targets, finite-target rank
   recovery, facet separation, and convergence under exposure, sparsity,
   workload, category support, and missingness. Do not simulate to rediscover
   the analytic signed-infinity result or merely obtain runtime estimates.

The release-spine decision remains fail-closed until the deterministic core and
cross-surface propagation pass. Marginal fixed-facet boundary theory, nonuniform
DFF, and external FACETS numeric overlap may remain explicit conditional or
deferred claims; they need not expand into blockers for the retained supported
core if their public fallbacks are enforced.

The companion `gpcm-solution-decision-stability-roadmap-0.2.3.md` defines the
next cross-cutting gate for Hessian uncertainty, slope/variance boundaries,
multiple solutions, quadrature, canonical objective/gradient/free-dimension
agreement, transformed-coordinate differences, and exact DFF/fit/rank/
readiness decision signatures. P0b, P1a, and P1b now narrow the reflected
Person MML result to one finite-q-stable local low-variance candidate while
P1c closes only the fixed-nuisance zero-variance likelihood identity. The
profiled zero boundary is blocked by nonstationary, slope-sensitive nuisance
traces, while source-solution selection, the upper/joint boundary, and
continuous-integration questions remain open. None authorizes a large
simulation.
