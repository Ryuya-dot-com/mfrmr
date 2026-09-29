# GPCM population and boundary prerequisites

The user instructed on 2026-09-26 that population and boundary issues take
priority over portable calibration. The public portable prototype was therefore
removed from package source, documentation, NEWS and ordinary tests. Its patch,
new fixtures and focused-test log are preserved locally under
`validation-results/portable-gpcm-paused-20260926/`; it is not an available API.
Prior external comparison and roadmap work is retained.

## Findings from current code

1. `prediction_source_scoring_readiness()` in `R/api-prediction.R` requires
   `!population_active`. An estimated population therefore receives
   `population_scoring_validity_not_evaluated` regardless of its numerical
   values. This is an explicit unqualified-output policy, not a test finding
   that a particular fitted population is wrong.
2. `mfrmr_readiness_boundary_component()` in `R/core-readiness.R` assigns
   `not_evaluated` whenever an MML GPCM has free slopes. It is not a
   case-specific conclusion that a boundary exists.
3. `mfrm_gpcm_slope_inference_check()` in `R/api-gpcm-intervals.R` already uses
   output-specific local solution and unregularized joint information checks.
   Thus approximate slope intervals may be available while the broader
   scoring/global readiness remains false. Neither status can silently replace
   the other's meaning.
4. `audit_mfrm_mml_gpcm_slope_boundary()` in
   `R/core-mml-gpcm-slope-boundary.R` is explicitly instrumentation-only. Its
   sufficient path condition holds additive and population coordinates fixed
   and concerns the selected finite quadrature objective. It does not close a
   joint population/slope boundary or certify a continuous normal integral.

These are two different work items: replace inappropriate blanket rules with
justified output-specific rules, and address actual unresolved solution
geometry. Removing flags alone would address neither source validity nor the
consequences of using the calibration population for a different cohort.

## Current retained-case replay

The [replay](gpcm-population-scoring-audit-20260926.R) uses two saved fits from
one actual separate-owner 120-Person synthetic dataset, reviewed at 31 and
41 nodes during the paused development probe. It performs no refit or new
simulation. Fresh local slope-information checks and the existing source
scoring checks are retained together under
`validation-results/gpcm-population-scoring-audit-20260926/`.
Both source fits have numerical state `ready` and local slope-information
eligibility, while scoring readiness is false. Its reasons include the
estimated-population policy, unevaluated estimability and unevaluated boundary.
This reproduces the distinction in code. It does not prove that those fits
are global optima, that all scoring refusal is unnecessary, or that posterior
intervals have nominal repeated-sampling coverage.

The public extraction probe also found that the current quadrature-review
validator compares fitted population coefficients/variance as if they were
unchanged model settings. Those estimates are supposed to vary across grids.
A correction was included in the paused prototype and must be verified when
the final workflow is implemented, together with preservation of population
model/design checks. This is an integration defect exposed by GPCM extension,
not evidence that the estimated population is invalid.

## Existing evidence to reuse

* [Population-variance profiles](gpcm-population-variance-profile-p1a-record-0.2.3.md)
  found a locally stationary finite low-variance basin in the historical
  endpoint examples; other high-tail points did not pass nuisance stationarity.
  The finite-grid envelope was not a global profile.
* [Exact zero-variance work](gpcm-zero-variance-boundary-p1c-record-0.2.3.md)
  independently checked the fixed-nuisance limit. All 12 boundary nuisance
  runs remained ineligible under their stationarity rule, with very large
  fitted slopes in some cases. Increasing iteration count did not repair the
  diagnosed case. This motivates joint variance/slope treatment, not a claim
  that a fitted positive variance must be rejected.
* [Dense-grid boundary challenge](gpcm-mml-boundary-challenge-record-0.2.3.md)
  showed why the all-node sufficient ray condition misses its proposed
  positive examples as quadrature nodes extend into both tails. It must not
  be promoted to a general detection rule by repeating a larger grid.
* [Local turning-point checks](gpcm-profile-turning-point-p1m-record-0.2.3.md)
  and the [scope decision](gpcm-release-scope-disposition-p1p-record-0.2.3.md)
  preserve useful local numerical results without a continuous global theorem.
  The older source/model restrictions must be checked before reusing them for
  current separate-owner estimation.
* The [80-fit separate-owner pilot](gpcm-separated-owner-pilot-record-20260926.md)
  completed numerical/interval calculations in all cases. Its 20 datasets per
  cell do not qualify coverage, informative assignment or general boundaries.
* The retained [TAM](gpcm-fixed-scoring-tam-20260926.md) and
  [ConQuest](gpcm-fixed-scoring-conquest-20260926.md) comparisons support fixed
  response-function mapping and conditional-score calculations within their
  stated precision. They do not validate an estimated calibration or transfer
  to another population.

## Next method decision and completion boundary

Follow P1--P4 in ROADMAP before portable API integration. First reuse the
nuisance-profile machinery on retained representative solutions, freeing the
population during slope profiling and freeing slopes during variance profiling.
Use common-objective reevaluation, nuisance gradients, starts and integration
checks to distinguish locally stable, competing, boundary-approaching and
unresolved results. A constrained search returning a finite number is not
itself a boundary classification or a valid likelihood-ratio interval.

Define conditional-score numerical eligibility separately from calibration
intervals and from the assumption that a future cohort shares the stored prior.
The latter needs a declared use case and sensitivity evidence; it cannot be
certified by optimizer status or software agreement. Do not launch another
large simulation before the method and the target claim are fixed. Completion
requires implemented, tested handling of the admitted conditions and clear
remaining exclusions, not simply preservation of a warning in a saved file.

## Conditional posterior existence versus calibration validity

For a supplied finite calibration, positive finite slopes `a_j`, nonnegative
weights `w_j` and a fixed normal prior with finite `mu` and `0 < sigma < Inf`,
the current full-predictor GPCM has linear-in-theta category logits with
coefficient `k * a_j`. Consequently its log posterior satisfies

```
d2 log p(theta | responses, calibration) / d theta2
  = -1/sigma^2 - sum_j w_j * a_j^2 * Var(K_j | theta) < 0.
```

Each observed category probability is positive and at most one at finite
coordinates. Their nonnegatively weighted product times the normal prior has
positive, finite integral and finite posterior moments. Thus the conditional
posterior is proper and strictly log-concave, including extreme response
patterns. This is a direct property of the implemented model, not a simulation
finding or evidence that its calibration is well estimated. The existing
posterior-mode and tail-bound integration routines use this structure.

An estimated prior becomes a fixed normal distribution for this calculation
only after its estimates are supplied. Its conditional validity does not
establish calibration-parameter uncertainty, repeated-sampling coverage,
correct population shape, or suitability for a future cohort. Conversely,
an unevaluated *calibration* boundary does not mathematically imply that the
posterior conditional on finite supplied coordinates is undefined. The P2
rule must preserve both facts rather than conflate them in one Boolean.

At zero population variance the distribution is degenerate and requires a
separate boundary representation; at infinite variance or nonfinite slopes
the above conditions no longer apply. A tiny positive variance or very large
finite slope must not be silently substituted for an established limiting
model. Numerical representability, source-solution stability and the scope of
reported uncertainty remain separately checked.


## P2 implementation: conditional source and score checks

The preceding code audit records the pre-change behavior. A local implementation
now uses `conditional_scoring_checks_v3` within the existing fitted-object APIs,
without reintroducing the paused artifact or changing global fit readiness.

| Situation | Default behavior | Explicit review |
| --- | --- | --- |
| Existing ordinary source checks pass | Existing fitted-object scoring | Same source qualification |
| GPCM MML or an intercept-only estimated normal population passes fresh local solution and source-integration checks | Conditional scoring, followed by per-Person numerical checks | Same checks retained |
| Calibration identification/category/boundary or numerical findings require review; required local checks are unavailable or fail | Stop with a reason | Finite fixed-parameter exploratory calculations retain source review labels |
| Conditional source passes but a scored Person fails the numerical comparison | Stop; request finer scoring integration | Retain and flag the affected scores, without changing source eligibility |
| Invalid/nonrepresentable calibration or inconsistent stored population parameters | Unavailable | Still unavailable |

Source qualification reuses `mfrm_ic_fit_check()` and its fresh unregularized
joint-information evaluation. This is not a second inferential method. The
current fitting objective, native gradient and local curvature must pass;
recorded actual rank deficiencies cannot be overridden by editing the summary
identification label. Known inadequate categories, failed numerical state and
boundary exclusions cannot enter the conditional route. A missing global
identification/boundary audit stays missing, rather than being silently marked
identified/finite. Covariate-dependent populations retain explicit review in
this first scope.

At the same calibration parameters, compare the fitting integration rule with
normally `max(q + 10, 2*q - 1)` nodes (`q + 10` if the larger Hermite rule is
unrepresentable). Require absolute NLL movement <=1e-5, gradient movement <=1e-4,
and higher-order native gradient <=1e-4. Failed/unavailable evaluations require
review, not an automatic higher-order refit. Dense information work respects
the existing allocation budget. No stale covariance is accepted as fresh evidence.

A passing source is not enough to authorize a coarse scoring rule. The actual
reported EAP/SD are compared with adaptive reference rules at the scoring order
(at least 3 for that reference) and a higher order selected as above, retaining
any additional user-requested orders. Absolute reported EAP/SD differences and
last-two-reference EAP/SD/log-marginal movements must each be <=1e-5. These
screening tolerances do not prove numerical accuracy for all possible inputs.
Continuous interval inversion keeps its existing algorithm, and finite posterior
summaries are required. The calibration and prior stay fixed in this calculation.

`source_scoring_status = "conditional"`, `local_calibration_review`, original
source audit states, and `score_integration_review` accompany the result. The
`SourceScoringReady` flag concerns calibration qualification;
`ScoreIntegrationReady` and `EstimateUse` distinguish per-Person integration
failures. Summaries, draw tables and exports retain the distinction. Legacy
population results without current evidence remain review-only; missing or
inconsistent new numerical review records are rejected at summary/export.
Human-readable messages distinguish an unevaluated boundary from an observed
boundary restriction. Population-parameter inconsistencies cannot be used as an
undocumented scoring-prior override.

### Checks and findings

* The saved fixed-41 separate-owner probe fails source integration: NLL movement
  to 81 nodes is 7.993573e-5 and gradient movement 7.560173e-4. The new rule
  therefore refuses default scoring, despite positive local information.
* An actual public-API adaptive-31 refit of the same 120-Person/720-rating
  synthetic data passes source checks (31/61 NLL movement 9.993073e-11,
  gradient movement 1.958876e-9, higher-order gradient 6.538224e-6). Scoring two
  retained response patterns passes the independent-order score checks with
  maximum EAP/SD discrepancy below 3e-14. The fit remains globally review-only.
* RSM and PCM intercept-only population fits on `example_operational` also
  pass the conditional route at adaptive 31/61, with higher-order gradients
  3.754993e-5 and 5.976472e-6 respectively. Two scored persons per model pass
  the score checks; maximum discrepancies are below 3e-15.
* A two-node scoring rule fails the per-Person check despite an eligible
  calibration; default refusal and explicitly flagged review outputs are tested.
* Regression tests cover invalid free parameters/variance, inconsistent stored
  prior means, detected identification failure, failed source convergence,
  category/boundary restrictions, changed retained parameters, preservation of
  global flags, plausible values, summary/export labels, and missing numerical
  review records. The existing prediction suite includes the actual disconnected,
  locally rank-deficient estimated-population example; it remains ineligible.

The native synthetic fit and input are retained as a small regression fixture
(`tests/testthat/fixtures/mfrm-conditional-scoring-gpcm.rds`) so routine tests
reuse the source while reevaluating its numerical evidence. Test provenance is
in the adjacent Markdown file. Dedicated and existing prediction tests pass;
no complete package test suite or repeated-sampling simulation was rerun.
Help for scoring/plausible values and NEWS describe the implemented scope.

P2 now has an implemented conditional-scoring rule in this scope. The subsequent
[P3 sensitivity comparison](gpcm-prior-sensitivity-20260926.md) completed its
declared 1,800 calculations and independent numerical checks. It demonstrated
material prior sensitivity, including all-lowest-category patterns with six
ratings; it does not establish that a new cohort shares the fitted prior or
account for estimating calibration/prior parameters. P4's fitted-object
implementation now accepts explicit scoring-prior selection with separate
retained/scoring identities in the existing API, preserving source qualification
and checking the actual scoring prior. Its implementation and focused checks
are recorded with P3. Next transfer these accepted rules into portable
extraction/replay; the paused artifact prototype is not yet restored or available.
Do not launch another large coverage study merely because conditional scoring
is available.
