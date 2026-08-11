# Draft.83d2b2b1g9 lme4 objective-reference preflight contract

Status: completed repository-only analytic preflight, 2026-08-10. This
contract identifies the lme4 ML and REML reference surfaces before any lme4
nonreserved replay. It does not open replicates 901--902, implement the
high-accuracy box solver or boundary profile, authorize calibration 201--300,
inspect confirmation 501--700, select a stationarity rule, or authorize
inference.

## Supported model and coordinates

The preflight is deliberately narrower than all models accepted by `lmer()`.
It supports a zero-offset, unweighted Gaussian linear mixed model with
independent scalar random-intercept terms only. If `theta_j` is lme4's
relative standard-deviation coordinate for term `j`, `Z_j` is its incidence
matrix, `X` is the fixed-effect matrix, and `y` is the response, define

```text
A(theta) = I + sum_j theta_j^2 Z_j Z_j'
B(theta) = X' A(theta)^-1 X
```

Fixed effects and the residual scale are profiled out. The reference variable
is therefore lme4's nonnegative `theta`, not a variance, absolute standard
deviation, log-standard-deviation, or glmmTMB/TMB raw coordinate. Raw
stationarity magnitudes and absolute objective values must not be pooled
across backends.

## Independent dense Gaussian oracle

Let `beta_hat = B^-1 X' A^-1 y`, `e = y - X beta_hat`,
`RSS = e' A^-1 e`, `n = length(y)`, and `p = ncol(X)`. The independent dense
oracle evaluates the theta-only profiled ML deviance

```text
log|A| + n {1 + log(2 pi RSS / n)}
```

and the theta-only profiled REML criterion

```text
log|A| + log|B| + (n-p) {1 + log(2 pi RSS / (n-p))}.
```

For `P = A^-1 - A^-1 X B^-1 X' A^-1`, `q = P y`, and
`A_j = 2 theta_j Z_j Z_j'`, the independently coded gradients are

```text
ML:   tr(A^-1 A_j) - n q' A_j q / RSS
REML: tr(P A_j) - (n-p) q' A_j q / RSS.
```

These formulas are evaluated with dense Cholesky factorizations and are not
implemented by calling the lme4 deviance closure. They are compared with
`lmer(..., devFunOnly=TRUE)` at an off-optimum interior theta vector, with
Richardson differences supplying a second gradient route. At the fitted
theta, ML is cross-checked with `deviance(fit_ml)` and REML with
`REMLcrit(fit_reml)`; both are also cross-checked against
`-2*logLik(fit, REML=mode)`.

The objective tolerance is `2^12 eps` times objective scale. The gradient
tolerance is `2^12 eps^(2/3)` times the larger of one and the analytic or
Richardson gradient scale. The tolerance is fixed from floating-point scale,
not from the observed analytic/numeric discrepancy.

## Boundary identity

For identical fixed-effect matrices, setting the Rater relative SD in the
two-term full model exactly to zero must produce the same theta-only objective
as the fitted one-term reduced model. The identity is required separately for
ML and REML, both through lme4's deviance closure and through the independent
oracle. This is an algebra/implementation identity, not a boundary-inference
claim.

## Prohibited convenience routes

The installed lme4 2.0.6 namespace is source-hashed. Its `devfun2()` calls
`refitML()` and therefore does not preserve an input REML surface. In this
environment, it also does not reproduce its own `basedev` when evaluated at
the advertised `optimum`. It is excluded from all b1g9 reference mechanics.

The installed `deviance.merMod` implementation evaluates
`devCrit(object, REML=FALSE)` when a non-null `REML` argument is supplied.
Consequently `deviance(fit_reml, REML=TRUE)` is not an REML-criterion
accessor. b1g9 uses `REMLcrit(fit_reml)` and checks it against
`-2*logLik(fit_reml, REML=TRUE)`. Both exclusions are executable, namespace-
hash-bound gates rather than prose warnings.

## Readiness boundary

Passing this preflight establishes only:

- an independent Gaussian objective and analytic-gradient oracle;
- theta-only ML and REML objective identity;
- exact-zero full-to-reduced identity; and
- fail-closed accessor selection for the installed lme4 namespace.

It leaves `Lme4BoxConstrainedReferenceSolverReady`,
`Lme4BoundaryProfileReady`, `NonreservedLme4ReplayAuthorized`, lme4 ML/REML
reference-mechanics readiness, complete four-lane method coverage,
calibration authorization, stationarity, confirmation, inference,
coefficient, and decision readiness false. The next admissible gate is a
likelihood-mode-preserving, box-constrained lme4 solver and boundary-profile
contract, followed by a separately authorized replay on nonreserved
replicates 901--902.

## Sources

- lme4 `lmer` reference:
  https://lme4.github.io/lme4/reference/lmer.html
- lme4 linear mixed-model vignette:
  https://lme4.github.io/lme4/articles/lmer.pdf
- lme4 computational theory:
  https://lme4.github.io/lme4/articles/Theory.pdf
- lme4 optimizer controls:
  https://lme4.github.io/lme4/reference/lmerControl.html
- lme4 likelihood profiling:
  https://lme4.github.io/lme4/reference/profile-methods.html
- lme4 singularity reference:
  https://lme4.github.io/lme4/reference/isSingular.html
