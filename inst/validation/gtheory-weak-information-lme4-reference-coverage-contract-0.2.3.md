# Draft.83d2b2b1g10 lme4 reference-coverage contract

Status: completed repository-only nonreserved ML/REML replay contract,
2026-08-10. This contract opens only lme4 ML and REML on nonreserved
replicates 901 and 902. It does not open calibration 201--300 or confirmation
501--700, freeze a production stationarity rule, implement the production
runner, authorize inference, or validate a D-study coefficient.

## Objective and coordinate identity

b1g10 inherits the exact b1g9 theta-only objective contract. The optimized
coordinate is lme4's nonnegative relative standard deviation `theta`; fixed
effects and residual scale are profiled out. ML is the profiled deviance and
REML is the profiled REML criterion. The fitted-objective accessors remain
`deviance(fit_ml)` and `REMLcrit(fit_reml)`, cross-checked by
`-2*logLik(fit, REML=mode)`. `devfun2()` and
`deviance(fit_reml, REML=TRUE)` remain prohibited.

Raw lme4 theta gradients, glmmTMB log-SD gradients, and absolute ML/REML
objectives are not pooled. Passing both backends does not make their
coordinates, numerical tolerances, likelihood modes, or absolute objectives
exchangeable.

## Box-constrained solver ladder

Every objective is evaluated from three deterministic starts by three
independent lower-bound-aware algorithms:

- `nlminb`;
- `optim(method="L-BFGS-B")`; and
- `minqa::bobyqa`.

This gives nine main solver runs per objective. Algorithm-wise best objectives
must agree under a floating-point-scale tolerance before polishing. Numerical
projected Newton polishing retains the raw gradient, active set, free Hessian,
Newton decrement, backtracking trace, and both raw and curvature-scaled
first-order states.

## Independent sparse Gaussian oracle

For the zero-offset, unweighted independent-random-intercept structure, b1g10
implements the b1g9 Gaussian formulas with a sparse Cholesky factorization of

```text
A(theta) = I + sum_j theta_j^2 Z_j Z_j'.
```

Sparse solves produce the profiled ML/REML objective and analytic gradient.
On the small b1g9 fixture, the sparse result must reduce to the independent
dense oracle. On every n=1600 nonreserved objective, the sparse objective and
gradient must agree with the lme4 closure and adaptive finite differences.

The analytic gradient also drives at most three final Newton iterations.
Acceptance requires the raw free-coordinate KKT condition after this polish;
the curvature-scaled Newton condition is retained separately and cannot hide
a raw failure in the final reference label.

## Boundary semantics

For a scalar random-intercept term, the objective is locally even in theta.
Consequently the first derivative at theta zero may vanish structurally,
regardless of whether the variance boundary is supported. b1g10 explicitly
sets `BoundaryFirstOrderSufficiencyClaim=FALSE`.

Each full model therefore receives a seven-point target-theta profile at
fractions `1, .75, .5, .25, .1, .025, 0`. At every point the other theta
coordinates are reoptimized by all three algorithms and must pass numerical
KKT, Newton-decrement, and free-curvature gates. The exact-zero endpoint must
match the separately optimized reduced-model objective. A monotone material
objective increase toward zero supports a finite interior; a material
decrease can support a boundary limit only if the reduced objective also
matches.

This profile is numerical reference evidence. It is not a calibrated
production decision rule, likelihood-ratio test, confidence interval, or
claim that the generating variance is recovered.

## Nonreserved manifest and readiness

| Scenario | Replicate | Methods | Model roles |
| --- | ---: | --- | --- |
| exact-zero Rater variance | 901 | lme4 ML, REML | full, reduced |
| Rater variance 0.12 | 902 | lme4 ML, REML | full, reduced |

The manifest contains two datasets, four method routes, eight objectives, 72
main solver runs, and 84 profile solver runs. Passing all eight objectives and
four profiles closes the lme4 ML and REML reference lanes. Together with b1g6
and b1g8, `ReferenceMethodCoverageComplete=TRUE` then means exactly four of
four prespecified backend-likelihood lanes have passed nonreserved reference
mechanics.

It does not imply `CalibrationAuthorizationReady`. The acceptance and
indeterminate policy, production boundary probe, and exact-resume calibration
runner remain independent missing gates. Stationarity, calibration execution,
confirmation, inference, coefficients, and D-study decisions remain false.

## Sources

- lme4 `lmer` reference:
  https://lme4.github.io/lme4/reference/lmer.html
- lme4 modular fitting and computational vignette:
  https://lme4.github.io/lme4/articles/lmer.pdf
- lme4 optimizer controls:
  https://lme4.github.io/lme4/reference/lmerControl.html
- lme4 convergence guidance:
  https://lme4.github.io/lme4/reference/convergence.html
- lme4 singularity reference:
  https://lme4.github.io/lme4/reference/isSingular.html
- minqa package:
  https://cran.r-project.org/package=minqa
