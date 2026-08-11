# Draft.83d2b2b1g5 independent stationarity-calibration design contract

Status: repository-only mathematical design and sealed-manifest contract,
2026-08-10. No calibration data are generated, no candidate cutoff is selected,
and no full stabilization, bootstrap, inference, or D-study execution is
authorized.

## The estimands that must remain separate

Draft.83d2b2b1g5 separates four questions that earlier point gates could not
answer jointly:

1. **finite numerical stationarity**: is the gradient consistent with a finite
   local stationary point in the fitted coordinates?;
2. **local curvature**: is that point locally minimizing, flat/weakly
   identified, numerically unfactorable, or indefinite?;
3. **boundary behavior**: does the profiled objective improve as a target
   log-standard-deviation tends toward minus infinity?; and
4. **statistical component resolution**: is a variance component empirically
   distinguishable from zero for the intended application?

The fourth question is the existing `resolved / not_resolved` calibration
problem. It cannot label the first three. Generating truth also cannot label
numerical stationarity: a dataset generated with zero variance may have a
positive finite sample estimate, and a positive generating variance does not
guarantee a regular finite optimum.

For a glmmTMB log-standard-deviation coordinate, exact zero is at minus
infinity. A decreasing profiled objective along that direction is therefore a
`boundary_limit`, not a finite stationary point and not automatically an
optimizer failure. It is handed to the reduced-model/boundary lane rather than
silently recoded as either numerical success or statistical non-resolution.

## Reference adjudication is not an oracle proof

The independent reference is an eight-stage adjudication ladder: reconstruct
the exact fixed-coordinate objective; retain TMB automatic-differentiation and
independent Richardson derivatives; use frozen deterministic starts; compare
strict `nlminb`, BFGS, and derivative-free verification; apply a retained
damped-Newton polishing sequence; classify Hessian inertia separately from
factorability; profile nuisance coordinates along decreasing target log-SD;
then adjudicate all evidence.

No single optimizer code, gradient, Hessian, likelihood envelope, or
cross-profile agreement is sufficient. Any disagreement becomes
`reference_unresolved`; it is retained in accounting and excluded from both
binary error denominators. The eventual record must call the result a
high-accuracy numerical reference, not mathematical proof of a global optimum.

Reference tolerances are deliberately not frozen in this slice. They require a
separate floating-point and solver-ladder reproducibility contract before
replicates 201--300 may be generated. Those tolerances may not be chosen from
the viewed b1g4 magnitudes.

## Candidate metrics and coordinate behavior

Five first-order summaries are retained: raw maximum gradient, the project
objective/parameter-relative maximum, the lme4 componentwise-minimum scaled
gradient, Newton decrement, and relative Newton step. Missing curvature or a
failed solve is `not_evaluable`, never numerical zero.

For an invertible affine map `p = A z + b`, the exact transformations are

`g_z = A' g_p` and `H_z = A' H_p A`.

Consequently, Hessian inertia is preserved by congruence and
`g' H^{-1} g` (the squared Newton decrement) is invariant when `H` is positive
definite. Raw maximum gradient, parameter-relative maxima, Cholesky-ordered
lme4 scaling, and relative Newton-step maxima are generally coordinate
dependent. The source implements identity, extreme diagonal, shear, and
rotation fixtures so that invariance claims are tested rather than inferred
from one parameterization.

The systematic candidate zone grid consists of adjacent points in
`10^(-8), ..., 10^(-1)`, plus the documented lme4 `2e-3` anchor. This grid is
registered before any reserved calibration result is viewed. It is not a
selected rule. Raw gradient is a negative-control benchmark; Newton decrement
is the primary coordinate-invariant candidate; other summaries test practical
availability and false-unready tradeoffs.

## Calibration denominator and error accounting

The unchanged outer calibration reservation has 30 scenarios, 100 replicates
(201--300), four paired methods, and 3,000 independent datasets. Its existing
12,000 scenario x replicate x method units expand prospectively to two model
roles and six profiles: 144,000 candidate fits. Reference adjudication is
defined once per model role and method unit (24,000 reference problems), not
once per candidate metric.

Primary numerical error accounting is conditional on a resolved high-accuracy
reference within each scenario x method stratum:

- numerical false-ready: candidate `numerically_eligible` but reference
  `finite_nonstationary`, `finite_saddle_or_max`, or `boundary_limit`;
- numerical false-unready: candidate `numerically_ineligible` but reference
  `finite_local_minimum` or `finite_stationary_flat`;
- boundary handoff, candidate indeterminate, candidate non-evaluation, and
  reference unresolved remain separate counts.

These are numerical errors, not the statistical false-ready/false-block errors
of target-component resolution. Only after a numerical rule has been frozen
and independently checked may statistical-resolution calibration and the
nuisance-boundary bootstrap proceed.

## Evidence sources and library audit

The contract relies on Kristensen et al. (2016) and current TMB documentation
for the Laplace/automatic-differentiation objective, current lme4 documentation
and `checkConv` source for curvature-scaled gradients, current glmmTMB
troubleshooting guidance for restart/alternate-optimizer and Hessian checks,
Nash and Varadhan (2011) and Nash (2014) for multi-method optimization
diagnostics, `numDeriv` for the independent Richardson comparison, and Self and
Liang (1987) for nonregular boundary likelihoods.

The local Zotero 9.0.6 library was available through its read-only API. Exact
searches for the TMB, boundary-likelihood, and optimx numerical references
returned no items; primary publisher and official package sources therefore
fill that scoped library gap. The library did return ten generalizability-
theory records, including Jiang et al. (2020), Wind et al. (2023), and Jiang et
al. (2024), but they are contextual G-theory sources rather than numerical
stationarity references and do not label this gate.

## Authorization boundary

The b1g5 design binds the existing pilot plan
`427addf42c73047e184857f52e9aa126e6d5eb346ab105827d14b3affef38cbd`,
calibration registry
`8a1c165d5497519f14f9839a22eed7b9e918b5120da83985613d01fd76a8be01`,
sealed calibration manifest
`85d3ee963e93adfcc1d0bf505b1c34b1486f3eebfc605cf687a8e79240431676`,
and the retained b1g4 contract/execution/adjudication identities.

`DesignSchemaReady`, `CandidateArchitectureFrozen`,
`ReferenceArchitectureFrozen`, and `CoordinateAuditReady` may become true.
`ReferenceToleranceFrozen`, `StationarityThresholdFrozen`,
`StationarityCriterionReady`, `NumericalEligibilitySufficientRuleFrozen`,
calibration execution/data/results, full execution, numerical stabilization,
bootstrap, inference, coefficient, and decision readiness remain false.
