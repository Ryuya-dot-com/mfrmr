# Draft.83d2b2b1g6 high-accuracy stationarity-reference calibration contract

Status: completed repository-only analytic and nonreserved replay contract,
2026-08-10. It authorized only two new nonreserved datasets at replicate IDs
901 and 902; the completed result is recorded in the adjacent b1g6 record.
Calibration IDs 201--300, confirmation IDs 501--700, the full stabilization
manifest, bootstrap, inference, and D-study decisions remain unauthorized.

## What is frozen

Draft.83d2b2b1g6 freezes the numerical tolerances used to construct the
high-accuracy reference labels. It does not freeze an application
stationarity threshold. This distinction is essential: reference construction
asks whether a much more intensive deterministic solver/derivative procedure
can adjudicate a local numerical state; the later candidate rule asks whether
a production diagnostic predicts that state at acceptable false-ready and
false-unready rates.

Let machine double precision be `epsilon`. The binary64 derivative floor is
`2^12 epsilon^(2/3)`, the leading central-difference error order. A composed
Laplace objective also has objective-scale cancellation and numerical
inner-mode error, so that floor cannot be its sole comparison tolerance.
The independent audit evaluates a symmetric central-difference ladder at
`epsilon^(1/3) * 2^(-4:8)` times each parameter scale. It selects an interior
step solely from stability between adjacent finite-difference gradients. The
AD gradient is not consulted. A componentwise resolution envelope retains
both neighboring-step changes and the explicit
`2 epsilon max(1, |f|) / h` roundoff term. Agreement uses the larger of the
binary64 floor and four times this independently estimated resolution.
Ordinary numDeriv Richardson output remains a supplemental diagnostic.

Solver objective consensus uses `2^8 epsilon^(2/3)`. The terminal raw
gradient and Newton decrement use `2^10 sqrt(epsilon)`. Hessian inertia and
numerical Hessian symmetry use relative zones of `2^12 epsilon^(2/3)`.

On the retained R 4.6.1 binary64 environment these are approximately:

| Quantity | Tolerance |
| --- | ---: |
| derivative binary64 floor | `1.501943e-7` |
| solver objective relative consensus | `9.386e-9` |
| raw-gradient absolute reference stop | `1.525879e-5` |
| Newton-decrement reference stop | `1.525879e-5` |
| curvature relative eigenvalue zone | `1.501943e-7` |

The lme4 default `2e-3` convergence value is not used by this reference. It
remains a source-anchored candidate comparator in b1g5. TMB's
`last.par.best` is reset to one hashed anchor before every objective and
gradient evaluation, so the default random-effect warm start cannot make the
finite-difference result depend on evaluation order. Each sidecar also binds
the actual TMB inner method, inner-control list, and random-start expression.

## Analytic calibration suite

Six analytic objectives are frozen before the mixed-model replay:

- a correlated positive-definite quadratic with nonzero additive objective;
- an ill-conditioned, mathematically positive-definite quadratic spanning
  twelve eigenvalue orders, expected to be numerically unresolved as a strict
  positive-definite curvature state;
- a stationary quartic with a zero Hessian direction;
- an exact stationary saddle;
- the Rosenbrock minimum; and
- a log-SD boundary-escape objective whose infimum occurs only as the first
  coordinate tends to minus infinity.

The suite must recover `finite_local_minimum`, `finite_stationary_flat`,
`finite_saddle_or_max`, and `boundary_limit` distinctly. TMB-style analytic
gradients must agree with the independently selected adaptive central
differences, and numerical gradient Jacobians must pass symmetry.
Analytic truth checks tolerance mechanics only; it is not mixed-model
operating-characteristic evidence.

## High-accuracy solver ladder

Each mixed-model objective receives three deterministic starts: the reported
point and fixed plus/minus perturbations. Each start is passed to strict
`nlminb`, BFGS, and Nelder--Mead, giving nine solver runs per objective. The
best returned point receives at most 25 damped Newton steps using the retained
automatic gradient, a numerical Richardson Jacobian of that gradient, and Armijo
backtracking.

All three algorithm families must return best objectives within the frozen
consensus tolerance. The polished automatic gradient must pass the
AD-independent adaptive central-difference comparison. Positive-definite,
near-semidefinite, indefinite,
nonstationary, and unresolved outcomes remain distinct. Any missing algorithm,
derivative disagreement, or material objective disagreement produces
`reference_unresolved`; no majority vote repairs it.

## Boundary profiling

For a full model, the semantic Rater random intercept is mapped to its exact
top-level `theta` coordinate through glmmTMB's ordered random-effect term map.
At log-SD offsets 0, 2, 4, 8, 12, and 16, every other top-level parameter is
reoptimized by strict `nlminb` and damped Newton polishing. Every profile
point must pass free-coordinate curvature and stationarity checks. A boundary
limit requires monotone material
improvement toward smaller log-SD and agreement of the final profiled full
objective with the separately polished reduced-model objective. Otherwise the
finite and boundary states remain separate or unresolved.

## Nonreserved replay

The replay fixes two baseline-complete scenarios:

| Scenario | Replicate | Method | Model roles |
| --- | ---: | --- | --- |
| exact-zero Rater variance | 901 | glmmTMB REML | full, reduced |
| Rater variance 0.12 | 902 | glmmTMB REML | full, reduced |

These IDs do not overlap schema 2--3, feasibility 101--125, calibration
201--300, or confirmation 501--700. The four objectives require 36 solver
runs plus polishing and two full-model boundary profiles. The replay is a
numerical mechanics control, not a design-stratified power or recovery study.

## Evidence boundary

All four fits returned, all reference states resolved as finite local minima,
every algorithm consensus and adaptive derivative check passed, both
full-model nuisance-stationary boundary profiles supported a finite interior,
and every content-addressed sidecar validated. Therefore the narrow
`NonreservedReplayReady` and `ReferenceToleranceFrozen` states are true in the
recorded execution. `StationarityThresholdFrozen`,
`StationarityCriterionReady`, reserved numerical calibration execution, full
stabilization execution, bootstrap, inference, coefficient, and decision
readiness remain false.
