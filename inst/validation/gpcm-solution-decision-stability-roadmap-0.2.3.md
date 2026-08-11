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
| Multiple solutions | Optimizer and engine sensitivity records exist for selected common starts. | A prespecified GPCM multiple-initial-value basin audit and unique selected-cluster rule are not complete. |
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

1. **P0 -- deterministic identity and solution audit.** Implement the common
   candidate registry, canonical reevaluator, independent free-dimension count,
   transformed class-wise differences, fixed multiple-start panel, and compact
   decision signature. Join it to the endpoint high/low and negative controls.
2. **P1 -- boundary and integration adjudication.** Complete the retained JML
   joint additive/log-slope scope, add the separate MML fixed-facet/slope and
   variance-profile scopes, and run the bounded start-by-q panel. Do not freeze
   q or a local-solution tolerance from the historical five-replicate panel.
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
