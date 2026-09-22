# Draft.83d2b2b1g4 scale-aware stationarity instrumentation contract

Status: prospective repository-only replay of the exact 120-pair b1g2
covering smoke, 2026-08-10. This contract freezes measurement before the
replay. It does not freeze a stationarity cutoff, select an optimizer, authorize
the full manifest, calibrate a test, or support D-study decisions.

## Source basis and limits

The current [lme4 convergence
reference](https://lme4.github.io/lme4/reference/convergence.html) frames
gradient zero and positive-definite curvature as KKT conditions, describes
Richardson extrapolation as a more reliable but expensive finite-difference
check, lists alternative gradient scalings, and treats agreement across
optimizers as strong practical evidence. Its installed `checkConv()`
implementation, corresponding to
[`R/checkConv.R`](https://github.com/lme4/lme4/blob/master/R/checkConv.R), uses
`solve(chol(H), g)` and compares its absolute components with the unscaled
gradient. The local lme4 version is 2.0.6 and the installed function
body/formals hash is
`43b4605c2f8077b0f24c454594604f008e84cce2333062a7ee156d6fe0dc4c50`.
Neither its default tolerance nor any glmmTMB diagnostic default is adopted as
an mfrmr release rule.

The [TMB introduction](https://kaskr.github.io/adcomp/Introduction.html) and
[model-object reference](https://kaskr.github.io/adcomp/ModelObject.html)
provide the basis for treating `obj$fn` and `obj$gr` as the objective and its
automatic-differentiation gradient at an explicit parameter vector. The
[numDeriv manual](https://cran.r-project.org/web/packages/numDeriv/numDeriv.pdf)
provides the independent Richardson Jacobian mechanism. The frozen method and
arguments remain those of b1g1--b1g3. Current
[glmmTMB troubleshooting guidance](https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html)
continues to require gradients, curvature, restarts, and optimizer messages to
be interpreted separately.

## Exact evaluation point and retained sidecar

For every returned full and reduced fit, instrumentation occurs after the
existing b1g2 aligned-start snapshot and existing diagnostics. At

\[
  p = \texttt{fit\$fit\$par}, \qquad f=f(p), \qquad g=\nabla f(p),
\]

the runner retains the named parameter vector, raw TMB outer gradient,
`sdreport` fixed gradient, raw Richardson Jacobian of `obj$gr`, its symmetric
part, its eigenvalues, and every derived vector below. It retains the actual
numeric objects in a hashed list column, not only scalar summaries or hashes.
The prior diagnostic gradient and Richardson calculation is repeated at the
same point; repeat hashes are recorded rather than silently assumed equal.

The sidecar contains only fitted numerical coordinates and derivatives. It
does not retain response rows or person, rater, item, or occasion identifiers.

## Separate observables

Let

\[
  H = \tfrac12(J_g + J_g^\top).
\]

The following quantities remain separate because they answer different
questions and have different coordinate behavior.

1. Raw norms: `max(abs(g))` and \(\lVert g\rVert_2\). These are directly tied
   to optimizer coordinates and are not invariant to rescaling.
2. Project-defined objective/parameter relative vector:
   \[
     r_i = g_i\,\frac{\max(1,|p_i|)}{\max(1,|f|)}.
   \]
   This is dimensionless under the stated convention but is not claimed to be
   a universal KKT statistic.
3. lme4-compatible vector, available only for strictly PD \(H\):
   \[
     s_L=\operatorname{solve}(\operatorname{chol}(H),g).
   \]
   The componentwise diagnostic vector
   \(\min(|s_{L,i}|,|g_i|)\) is retained separately.
4. Newton-whitened vector:
   \[
     s_N=\operatorname{solve}(\operatorname{chol}(H)^\top,g),
   \]
   whose squared Euclidean norm is
   \[
     \lambda_N^2=g^\top H^{-1}g.
   \]
   This is the Newton-decrement-type quantity. It is not numerically or
   conceptually relabeled as the lme4-compatible vector.
5. Newton step \(d=H^{-1}g\) and
   \(\max_i |d_i|/\max(1,|p_i|)\).
6. Reciprocal condition estimate for \(H\), plus raw-outer versus `sdreport`
   gradient differences.

Cholesky-dependent observables are unavailable—not zero—when the symmetric
Richardson Hessian is not strictly positive definite or when a numerical
Cholesky factor cannot be formed. Spectral positivity and numerical Cholesky
availability are retained as separate flags. Positive curvature is a necessary
local condition here; it is not a sufficient stationarity or global optimality
claim. Boundary targets remain in the closure of the finite log-standard-
deviation parameter space and require separate treatment.

## Frozen denominator and cross-profile summaries

The replay retains the b1g2 denominator: five designs, exact-zero and reference
target variances, replicate 101, ML and REML, six prespecified optimizer/start
profiles, 120 full/reduced pairs, and 240 fits. No row may be omitted because a
gradient scale or Hessian is unavailable.

For each of 20 route strata and each model role, all six profiles are retained.
The adjudicator records metric ranges, the profile attaining the observed
minimum of each metric, agreement with the smallest observed objective, and
within-stratum Spearman associations where defined. These summaries describe
cross-optimizer behavior. They neither select a preferred profile nor establish
a global maximum.

## Prospective prohibitions

Observed b1g4 values may not be used to choose a cutoff. The runner has no
early stopping, adaptive fallback, optimizer selection, bootstrap, calibration
generation, or full-manifest authorization. Every fit-level stationarity state
is `not_calibrated`, even when its raw or scaled gradient is small.

A successor may use this measurement schema to design an independently
calibrated rule. It must prespecify how raw and scaled quantities combine,
handle non-PD/boundary cases explicitly, and evaluate false-ready and
false-unready behavior on simulations not used to choose the rule. Only after
that step may full stabilization execution be reconsidered, separately from
bootstrap inference.

## Fail-closed state

The narrow intended claims are raw-derivative retention, scale-aware
measurement-schema readiness, reproducible no-fit resume, and descriptive
cross-profile measurement. The following remain false:

- `StationarityThresholdFrozen` and `StationarityCriterionReady`;
- `NumericalEligibilitySufficientRuleFrozen`;
- `FullExecutionAuthorized`;
- numerical stabilization/sensitivity readiness;
- calibration, threshold, confirmation, and bootstrap readiness; and
- inference, coefficient, and D-study decision readiness.
