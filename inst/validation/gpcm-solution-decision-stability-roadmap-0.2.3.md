# GPCM solution, uncertainty, and decision-stability roadmap for 0.2.3

Status: repository-only roadmap refinement, 2026-08-12. This document changes
no capability or checklist evidence status, freezes no numerical tolerance,
and authorizes no confirmation, large simulation, or external-program run.

## Why this is a separate gate

Four statements that are often collapsed must remain distinct:

1. an optimizer returned a convergence code;
2. a retained vector is stationary for the reevaluated objective;
3. the fitted estimand is finite, locally identified, and has usable
   uncertainty; and
4. the substantive output is stable enough for its declared decision.

A fit may satisfy item 1 while failing any of items 2--4. A positive-definite
local Hessian cannot rule out a better remote local solution or a likelihood
supremum on a boundary. Close objective values cannot establish parameter,
Person-EAP, fit, DFF, or rank stability. Conversely, a small coordinate change
can reverse a classification when the result lies near a decision threshold.

The endpoint-response ladder in
`gpcm-extreme-and-surface-audit-0.2.3.md` owns the exact all-1/all-5 cases. This
record supplies the cross-cutting numerical, uncertainty, and downstream-
decision contract for those cases and for ordinary or near-boundary GPCM fits.

## Current baseline and unresolved claim

| Area | What exists now | What remains open |
| --- | --- | --- |
| Fitted Hessian | A bounded full-free-vector numerical Hessian, eigenvalue tolerance ladder, block summary, objective reevaluation, and gradient record for eligible modest-dimensional fits. | It is diagnostic-only; no eigenvalue cutoff currently establishes weak information or inference readiness. |
| MML covariance | Observed marginal-information covariance and delta-method facet/step/slope SEs; near-singular matrices can be regularized for a retained review value. | Regularized inversion, boundary behavior, parameter-class coverage, and common-basis stability are not closed as primary inference. |
| JML uncertainty | Observation-information-style structural SEs and typed extreme-Person exclusions. | Full profile/joint uncertainty and supported coverage remain incomplete; finite trace SEs cannot repair a nonattained JML maximum. |
| Slope boundary | Scoped JML log-slope and joint additive/log-slope path instruments with positive and negative controls. | General rate/curved paths, complete primary-value propagation, and separate marginal-MML boundary geometry remain open. |
| Variance boundary | Positive variance coordinates and transformation Jacobians are recorded. | A finite log-variance, local Hessian, or numerical lower value does not determine whether variance tends to zero; a marginal profile and boundary-aware inference rule remain open. |
| Quadrature | A paired historical fixed-standard-normal q=31/61/91 GPCM-MML calibration with common q=91 objective reevaluation. | No q tolerance is frozen and the result cannot be transported silently to the current free-population default. Objective proximity did not guarantee step, slope, EAP, posterior-SD, or gradient-state stability. |
| Multiple solutions | The P0 microcase fixes seven GPCM-MML starts, one canonical objective plus analytic/independent score, five free-dimension counts, semantic differences, and fail-closed signatures. P0b applies the same registry to reflected exact and 19/20 near Person endpoints. | The benign case is tightly clustered, but every P0b endpoint scenario has only one existing-rule pass (`variance_low`) with a materially lower objective and different population scale than the default. No tolerance, selected cluster, variance-boundary result, or q adjudication is frozen. |
| DFF | Residual and linked-refit screens, multiplicity adjustment, typed linking/sparsity fields, and explicit formal-inference exclusions. | P-values and labels remain screening-only; joint/replicate covariance, anchor uncertainty, calibrated null/alternative behavior, and consequence classification remain open. |
| Infit/outfit | Mean-square, ZSTD, engine/FACETS-style transformations, tables, plots, and consistency tests execute. | GPCM false-positive and attribution behavior by estimator, topology, category support, and boundary state is not calibrated; universal cutoffs are not supported. |
| Ranks/separation | Typed extreme-Person exclusions and exploratory facet separation are available. | Uncertainty-aware Person/Rater ranks, tie handling, q/start stability, and exclusion-safe facet-separation decisions remain open. |
| Readiness | The v3 contract separates input, estimability, category, boundary, numerical, parameter, fit, and comparison states. | Metric-specific DFF/fit/rank/interval readiness and complete cross-surface propagation remain open. |

## Mathematical uncertainty contract

Let `xi` be the identified free optimizer coordinate and let `g(xi)` be the
reported constrained/natural coordinate. At an interior stationary solution,
the local observed-information approximation is

```text
H_xi = d2[-log L(xi)] / d xi d xi'
Cov(xi_hat) approximately H_xi^(-1)
Cov(g(xi_hat)) approximately J_g H_xi^(-1) J_g'
```

This route is eligible for ordinary two-sided Wald uncertainty only when all of
the following hold:

- the retained vector passes the canonical gradient and objective-
  reevaluation rules;
- the free dimension and coordinate map agree with the optimizer vector;
- the solution is interior in the estimand-relevant geometry and no superior
  certified boundary path exists;
- the symmetric information is full rank and positive definite under a frozen,
  parameterization-aware rule;
- inversion requires no eigenvalue flooring or other regularization;
- the analytic transformation Jacobian agrees with an independent derivative;
  and
- the interval method has acceptable coverage for that estimator, parameter
  class, and design stratum.

An eigenvalue-floored inverse may remain a numerical sensitivity display. The
proposed typed state is `SE_Status = regularized_review`; it must not silently
receive the same status as an unregularized covariance. Regularization of the
covariance does not change the retained likelihood point estimate, but the
resulting SE is not the ordinary inverse-Hessian SE and does not establish its
coverage.

At a boundary, usual quadratic and normal approximations can fail. Required
alternatives depend on the estimand:

- a free extreme JML Person retains signed infinity and no ordinary SE/CI;
- a positive relative slope approaching zero is a log-slope direction toward
  `-Inf`, usually coupled to compensating slopes by geometric-mean-one
  identification;
- a variance approaching zero is a natural-scale boundary corresponding to a
  log-variance direction toward `-Inf`; and
- an additive facet, step, or interaction needs its constrained likelihood-
  recession result rather than a rate or magnitude heuristic.

Profile, one-sided, bootstrap, mixture-reference, or posterior intervals may be
studied only under an explicitly matched boundary model. A generic half-
chi-square or ordinary Wald rule must not be transported across slope,
variance, facet, and extreme-Person cases. A bootstrap must repeat the full
fitting, boundary classification, quadrature, and failed-run policy. Coverage
denominators include unavailable and failed intervals explicitly; results are
reported by parameter class rather than pooled.

## Prespecified stability panel

| ID | Perturbation | Common evaluation required | Fail-closed result |
| --- | --- | --- | --- |
| `STAB-CORE` | Reevaluate the retained vector and an independent derivative point. | Same likelihood constants, retained rows/weights, free-coordinate order, constraints, quadrature, objective, analytic gradient, independent numerical score, and independently counted free dimension. | `numerical_review` or `failed`; no Hessian inference. |
| `STAB-START` | Deterministic default, zero/null, dispersed low/high slope, low/high variance, and fixed seeded free-coordinate starts. | Every returned vector is reevaluated by one canonical evaluator; objective and canonical transformed parameters define solution clusters. | Multiple materially different eligible clusters, or tied objectives with different estimands, produce `multiple_solution_review`. |
| `STAB-BOUND` | Interior fit versus certified additive, slope, variance, and joint boundary paths. | Finite path points and limiting objective are evaluated under the same model, constraints, and scale. | A better/equal nonattained boundary solution suppresses finite primary inference even if all starts converge to the same trace. |
| `STAB-Q` | Prespecified increasing quadrature ladder plus one common dense evaluation grid. | Compare adjacent-q fits and reevaluate every candidate on the common grid; retain structural parameters, EAPs, posterior SDs, gradients, Hessian state, and decisions. | No automatic selection by largest q; unresolved drift gives `integration_review` for affected metrics. |
| `STAB-HESS` | Difference-step ladder, analytic/numeric Jacobians, and coordinate-scale changes at the same candidate. | Hessian inertia/rank, covariance, SE, and transformed SE are compared on explicitly related bases. | Step- or coordinate-sensitive curvature, regularization, or boundary nonregularity keeps uncertainty review-only. |
| `STAB-COORD` | Free, expanded constrained, natural slope/variance, and externally normalized coordinates. | Semantic keys, signs, centering, scale factors, and Jacobians are fixed before differences are computed. | Raw-vector agreement alone is ineligible; a failed map blocks parameter and rank comparison. |
| `STAB-DFF` | Recompute DFF over eligible starts and q values under fixed grouping, linking, multiplicity family, and threshold rules. | Retain raw and adjusted p-values, effect metric, classification system, anchor/link state, and the exact flagged semantic keys. | Any changed eligible/flagged/classification state is `decision_sensitive`; non-ready source fits cannot yield a formal decision. |
| `STAB-FIT` | Recompute infit/outfit and standardized variants over eligible starts/q values. | Fix residual definition, expected variance, DF/ZSTD convention, boundary exclusions, and cutoff family. | Changed flag sets or unavailable boundary-affected rows remain diagnostic sensitivity, not model acceptance/rejection. |
| `STAB-RANK` | Recompute Person and Rater ordering after canonical mapping. | Compare only declared finite estimable targets; record severity orientation, ties, top-k membership, and pairwise order changes. | Infinity is a typed endpoint rather than an arbitrary finite rank; unstable or uncertainty-overlapping orders remain `rank_review`. |
| `STAB-READY` | Replay fit, summary, print, diagnose, plot, export, report, and saved-object routes. | Compare the exact component states, parameter states, reason codes, metric eligibility, and decision signatures. | No downstream route may improve the source state or infer readiness from a finite display. |

The panel is staged, not fully factorial. `STAB-CORE`, `STAB-BOUND`, and a
small deterministic `STAB-START`/`STAB-Q` cross come first. Hessian and
downstream metrics are evaluated only for candidates that survive those gates.
This prevents spending most of the runtime computing invalid uncertainty or
diagnostics for a dominated or nonidentified solution.

### P0 execution snapshot

The first P0 instrumentation slice is recorded in
`gpcm-solution-stability-p0-record-0.2.3.md`. Seven fixed starts returned under
the 60-Person/four-Item, four-category, item-owned, free-population GPCM-MML
microcase. The five independent dimension counts all equal 16; the canonical
objective range was about `1.20e-9`, the maximum analytic/central-difference
gradient difference about `6.31e-9`, and the maximum expanded semantic
difference about `1.46e-5`. These are observations, not acceptance cutoffs.
Boundary, Hessian, interval, DFF, fit, rank, and separation states remain
explicitly unevaluated, so every candidate remains review-only and no solution
is selected.

The bounded P0b extension is recorded in
`gpcm-endpoint-solution-stability-p0b-record-0.2.3.md`. It applies the same
seven starts to reflected exact-high, exact-low, 19/20 near-high, and 19/20
near-low Person patterns with five categories retained within every Criterion.
All 28 optimizations returned finite vectors, but in each scenario only the
`variance_low` start passed the existing numerical rule. That start improved
the common objective over the default by about 1.72--4.19 and occupied a
qualitatively different population-variance basin. The source EAPs remained
finite but were paired with enormous variances and nonconverged population
states. Therefore zero candidates are stability eligible; this is evidence to
profile variance and integration, not permission to select the lowest observed
candidate.

The next P1a record,
`gpcm-population-variance-profile-p1a-record-0.2.3.md`, fixes q=31 and
reoptimizes the 23 nuisance coordinates at ten log-variance values from both
P0b basins. All four reflected scenarios attain their diagnostic finite-grid
minimum at the low-variance anchor, and that minimum passes the existing
nuisance-stationarity rule. The high-variance tails do not. Across the full
curves, exact and near high/low reflections retain objective discrepancies,
so the result is a qualified local basin rather than a global, boundary, or
reflection-invariant profile. The broad two-basin q cross is therefore not
authorized.

The P1b record,
`gpcm-low-basin-quadrature-p1b-record-0.2.3.md`, then performs only the
admissible cross: independent q=31/61/91 refits of the qualified low basin,
with a predesignated but comparison-ineligible default diagnostic lane and one
held-out q=121 evaluator. All 12 qualified arms pass the existing native rule;
their common objectives, labelled coordinates, EAPs, and posterior SDs remain
closely aligned across q. Zero of 12 default diagnostic arms passes native
stationarity, and common evaluation exposes severe node/path sensitivity.
Finite-q stability is therefore conditionally supported for one local basin,
but no observed difference is converted into a tolerance, no continuous
integral is certified, and no package solution is selected.

The P1c record,
`gpcm-zero-variance-boundary-p1c-record-0.2.3.md`, implements the fixed-
nuisance lower-variance limit exactly using node-zero/weight-one q=1 and an
independent conditional-GPCM oracle. All 12 boundary nuisance fits return, but
zero pass the existing stationarity rule. Their expanded slopes are strongly
start sensitive, and some diagnostic traces reach very large ratios; these are
observables rather than a slope-boundary cutoff. P1c consequently compares no
boundary objective with the qualified interior and selects no solution. It
narrows the next boundary work to a prespecified joint zero-variance/log-slope
path instead of treating population variance as an isolated regular parameter.

The P1d record,
`gpcm-zero-variance-log-slope-path-p1d-record-0.2.3.md`, now evaluates the
observed C4 joint ray. Its slope rates sum to zero and C4
`slope * population SD` remains constant, which makes the path a non-uniform
limit and explicitly blocks reuse of the fixed-nuisance q=1 identity. Both
forward and reverse routes return at all six declared path values. Same-vector
q=61/91/121 objectives are coherent, but only 14/48 points pass nuisance
stationarity and none with `t >= 4` passes. Higher terminal objectives are
therefore evidence against simple monotone recession on this ray, not a
certified finite turnback or a selected interior solution. The next lower-
boundary work is a coordinate-aware reduced limit or reparameterization, not
more grid points or a retrospective stationarity tolerance.

The P1e record,
`gpcm-coordinate-scaled-joint-limit-p1e-record-0.2.3.md`, derives the required
coordinate rates and implements both an exact finite affine transform and a
direct reduced-limit likelihood. Round trips are at machine precision and
chain-rule gradients agree with independent finite differences. All 32 finite
transformed fits and all eight direct-limit fits pass their declared numerical
rules. The two limit routes agree within about `3.41e-13`; their objectives are
3.38--4.15 above the qualified interior conditional on the fixed
`a_C4 * sigma` coefficient. P1f subsequently recovers these objectives exactly
inside a canonical free-coefficient model and shows that the released
coefficient direction is nonstationary. Thus P1e adjudicates its declared
fixed-coefficient path, not the full C4 face.

The P1f record, `gpcm-slope-rate-cone-p1f-record-0.2.3.md`, proves that the
normalized finite-random-product rate polytope is affinely a standard simplex.
It enumerates all 14 nonempty proper four-criterion target faces and derives
their shared canonical likelihood with one free positive coefficient per
target. Its analytic gradient agrees with independent differences to about
`1.51e-7`. The next admissible lower-boundary work is multistart optimization
of those finite faces, not an arbitrary denser path grid. P1g now completes
the first C4 screen: exact scaled coordinates connect its positive coefficient
face to a stationary deterministic-Rater endpoint, and all declared grid
values lie above that endpoint. The endpoint remains above the qualified
interior. C1--C3 single-target screens and the rest of the empty-target
deterministic-Rater hierarchy remain unresolved.

P1h now completes C1--C3 using the same exact coordinate and endpoint
contract. All 168 new fits pass, both routes agree to about `1.21e-9`, and the
singleton endpoints remain above the interior. Combined with P1g, all four
single-target grids and singleton deterministic-Rater strata are screened.
P1i then evaluates all six two-target radial charts. It obtains 318/336
eligible fits and locally adjudicates 10/24 scenario-by-pair grids, whose
finite-ratio endpoints remain above the interior. The remaining 14 grids show
route-dependent coefficient-ratio recession, with objective differences up to
about `0.0599` and endpoint `d` below `-7`. The next admissible work is an
explicit coefficient-ratio boundary chart for that slower/faster-rate limit;
the four three-target vertices remain deferred until the two-target closure is
mathematically complete.

P1j now provides that exact ordered chart. All 288 positive P1i points
transport to `lambda_slow=mu`, `lambda_fast=mu*rho`, and all 672 `rho=0`
rows equal their frozen P1h/P1g singleton likelihoods and gradients. Yet only
280/672 natural-`rho` derivatives are nonnegative; releasing the fast
coefficient improves every ordered direction at `mu=0.1` and `0.2`. This
certifies the likelihood nesting but not the ratio profile. The next
admissible work is a closed-interval `rho` profile at fixed `mu`, using both
singleton and transported-P1i starts.

P1k executes that profile as a two-fixture pilot. Every one of 336 fits is KKT
eligible, but only 125/168 cells reproduce the same objective and coordinate.
Ten match only in objective and 33 retain competing eligible KKT objectives,
with gaps up to about `0.0667`. Best observed objectives remain above the
qualified interior, but P1k alone does not distinguish profile geometry from
nuisance basins or tolerance-admitted near-stationarity.

P1l performs that fixed-`rho` continuation in separate 33-cell objective and
ten-cell coordinate lanes. All 1026 scoped fits pass. The two routes coalesce
at every common `rho`, so no separate nuisance basin is observed. The 33-cell
lane contains 22 positive-to-negative derivative brackets (a profiled
maximum), six negative-to-positive brackets (a profiled minimum), and five
monotone-increasing grids. All ten coordinate-only cells bracket one profile
minimum. This reclassifies eleven P1k high-side candidates as tolerance/stopping
evidence rather than exact second minima, while retaining 22 endpoint-side
competitions separated by an observed profile maximum. Because P1l is a finite
grid, P1m next takes a compact local one-dimensional certificate before
reflected transport; three-target faces remain deferred.

P1m supplies a deliberately local version of that certificate. Four frozen
representatives cover the observed maximum, objective-minimum, monotone, and
coordinate-only-minimum lanes. All 87 points satisfy a `2e-6` nuisance-gradient
contract. Three roots are bracketed below `7.2e-8`, route starts coalesce, and
their nuisance Hessians are positive definite; the monotone representative has
positive derivatives at nine strict points. Local mechanism support is now
complete for the representatives. Continuous monotonicity and the global
profile remain false because point evaluation cannot exclude an unsampled
turn. The next admissible step is exact score/category reflection transport,
with refitting limited to any failed identities.

## Solution selection and coordinate agreement

Initial values are registered before fitting and expressed in the identified
free coordinate. Truth-near starts may diagnose a simulation but cannot be the
sole production start or be selected after seeing recovery. The selected
solution is the best canonical-objective cluster among candidates that pass the
same stationarity and boundary rules. Optimizer-native objective values,
messages, and gradients are retained but do not replace the common evaluator.

For every pair of eligible candidates, report at least:

- absolute and scaled objective difference on the common evaluator;
- maximum absolute and scaled gradient component;
- free-dimension and parameter-map identity;
- maximum absolute and scaled difference by semantic parameter class after
  transformation, plus the semantic key attaining the maximum;
- EAP and posterior-SD RMSE/maximum difference for common Persons where
  applicable; and
- boundary, Hessian, and readiness-state agreement.

One pooled maximum is insufficient. Additive locations, steps, expanded log
slopes, natural slopes, latent regression coefficients, variance, and Person
summaries have different scales and must remain separate. A small transformed
maximum difference is evidence about coordinates, not automatically about a
thresholded decision.

## Metric-specific decision contract

### DFF

Current residual and refit p-values remain screening quantities even after
multiplicity adjustment. Formal DFF significance requires a supported
estimand, common-scale linking, uncertainty that includes the required anchor
and cross-refit contribution, a frozen multiplicity family, and calibrated null
behavior. Statistical significance, effect magnitude, and substantive fairness
classification are separate fields. Uniform location-like DFF must not be used
to claim nonuniform slope, step-weight, or interaction DFF.

### Infit and outfit

The residual, expectation, variance, DF, and ZSTD conversion define the
statistic. Engine-style and FACETS-style standardized transformations remain
separate conventions. Fit flags are diagnostic hypotheses, not an automatic
accept/reject test of the whole model. Boundary-excluded or non-ready parameter
rows cannot become ordinary fit evidence through a finite residual proxy. Any
future cutoff must show false-positive and planted-alternative behavior in the
claimed estimator/design strata.

### Person and Rater ranks

Point ranks use canonical finite estimates only and must record whether higher
means more able, more severe, or more lenient. Exact extremes remain typed
endpoints. Point-order stability, top-k stability, and uncertainty-aware
pairwise distinguishability are different summaries; a high Spearman
correlation alone cannot establish any of them. Facet separation and rank
recovery use the same declared eligible target set and cannot include arbitrary
optimizer traces for unbounded coordinates.

### Convergence and inference readiness

`ConvergenceStatus` is numerical evidence. `FitReadiness` additionally depends
on input, estimability, category support, boundary, and numerical states.
`InferenceReady` remains true only for fully `ready` fits under the v3
compatibility contract; `ready_with_exclusions` is not silently promoted.
Finally, each interval, DFF, fit, rank, comparison, or information-criterion
decision needs its own metric eligibility. A ready fit is necessary but not
sufficient for every downstream claim.

## Decision-invariance signature

Each candidate fit should produce a canonical signature containing:

- model/estimator/data/constraint/quadrature/start and coordinate-map identity;
- objective, gradient, free dimension, boundary, Hessian, and fit-readiness
  states;
- interval availability and method by parameter class;
- DFF eligible-row keys, adjusted classifications, and exclusion reasons;
- infit/outfit eligible-row keys and flag classifications by convention;
- Person/Rater eligible sets, tie groups, pairwise-order or top-k changes, and
  facet-separation eligibility; and
- the final metric-specific `ready`, `review`, `blocked`, `unsupported`, or
  `not_applicable` decision.

Categorical signatures must match exactly across candidates declared
equivalent. Numerical tolerances cannot erase a changed decision. If a small
coordinate change crosses a frozen threshold, the correct result is
`decision_sensitive`, followed by sensitivity reporting or a review state,
not retrospective widening of the tolerance.

## Ordered implementation and release effect

1. **P0 -- deterministic identity and solution audit.** The common candidate
   registry, canonical objective plus analytic/independent score reevaluator,
   five-way free-dimension count, transformed class-wise differences, fixed
   seven-start microcase, and compact fail-closed decision signature are now
   implemented. Reflected exact and 19/20 near Person endpoints are now joined
   through P0b without freezing a tolerance. Next retain isolated Rater,
   constant-response, anchor, and unequal-workload negative controls as a
   separate fixed-facet boundary lane.
2. **P1 -- boundary and integration adjudication.** Complete the retained JML
   joint additive/log-slope scope, add the separate MML fixed-facet/slope and
   variance-profile scopes. P1a admitted the low-variance basin to a bounded
   q=31/61/91 refit, and P1b now conditionally closes that finite-q calibration
   under a held-out q=121 evaluator. P1c closes the fixed-nuisance lower-limit
   identity but finds no stationary zero-boundary nuisance candidate. Retain
   the default/high basin only as a diagnostic trace. P1d shows that the first
   declared C4 joint ray is quadrature-coherent but nuisance-nonstationary
   beyond `t = 2`. P1e closes only its coordinate-aware fixed-coefficient C4
   path. P1f maps the finite-random-product rates to a simplex, enumerates 14
   target faces, and shows that P1e is nonstationary in its newly released
   coefficient. P1g follows C4 to its direct deterministic-Rater endpoint and
   finds the entire declared grid above both that endpoint and the qualified
   interior. Next screen C1--C3 with the same construction before multiple-
   target faces. P1h completes C1--C3 and therefore all four singleton screens.
   P1i evaluates the six two-target radial charts but leaves 14/24 grids open
   at a coefficient-ratio boundary. Derive and audit that slower/faster-rate
   chart next. P1j completes the likelihood identity and shows that fixed-`mu`
   ratio profiling is necessary. P1k's representative bounded profile exposes
   43 nonmatching multi-start cells. P1l completes their scoped fixed-`rho`
   continuation and reduces them to 22 maximum brackets, 16 minimum brackets
   across both lanes, and five monotone-increasing grids, with no observed
   common-`rho` nuisance split. P1m locally certifies four frozen mechanism
   representatives while retaining global fail closure. Next derive exact
   reflection transport, then evaluate the four three-target vertices as
   needed. Complete the remaining empty-target hierarchy and address the
   separate upper/joint variance path and source-solution contract. Do not add
   q or path points by default, freeze an observed slope or solution tolerance,
   or call finite-grid agreement a continuous-integral certificate.
3. **P2 -- uncertainty eligibility.** Separate unregularized, regularized,
   profile, bootstrap, and posterior intervals; propagate typed status through
   all public surfaces; then run parameter-class coverage pilots with explicit
   failed/unavailable denominators and Monte Carlo precision.
4. **P3 -- downstream operating characteristics.** Calibrate DFF null/
   alternative behavior, infit/outfit attribution, finite-target rank/top-k
   recovery, and facet separation only after P0--P2 establish eligible source
   fits. Freeze rules before untouched confirmation data.
5. **P4 -- external and consequence stability.** Compare only estimator-,
   coordinate-, category-, correction-, integration-, precision-, and rounding-
   matched external strata. Confirm that any numerical agreement also preserves
   the declared DFF, fit, rank, and readiness consequence.

P0 and the fail-closed public propagation are retained-core priorities. Slope
and variance inference, formal GPCM DFF, universal fit classification, and
uncertainty-aware ranking remain conditional claims that may ship disabled or
review-only. Large simulation is justified only for interval coverage and
operating-characteristic error rates that deterministic algebra and microcases
cannot determine.
