# Draft.83d2b2b1g glmmTMB stabilization design contract

Status: prospective repository-only design contract on viewed b1e routes,
2026-08-10. No stabilization fit is authorized by this artifact.

## Purpose and upstream boundary

Draft.83d2b2b1f closes the typed replay-definition gap but deliberately leaves
`NumericalStabilizationReady=FALSE` and
`NumericalSensitivityEvidenceReady=FALSE`. Draft.83d2b2b1g designs the next
glmmTMB-only viewed-data audit. It neither changes b1e/b1f nor generates
calibration replicates 201--300.

Only these exact upstream scientific identities are admissible:

- b1e contract
  `0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6`;
- b1e manifest
  `53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f`;
- b1e execution
  `37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94`;
- b1f typed-replay contract
  `8a18d59548ab5d8523e29f7089d2ea70620f51b38e2444e133a2e78974ff0d4a`;
  and
- b1f typed-replay result
  `e200a9ee7984bbc3be32ab5ef209ce2eb26c0b42c8df3ad758bab7baf559f8c1`.

The b1e execution must retain its failed finite-only replay and numerical-
sensitivity flags. The b1f result must retain exact 3,000-route accounting,
2,993 finite matches, seven same-typed non-finite states, zero mismatches, and
no non-finite availability promotion.

## Frozen routes and symmetric profile graph

The base population is the 1,500 unique glmmTMB default routes already present
in b1e: 750 datasets by ML and REML. Each route receives the same six profiles:

| Profile | Target algorithm | Start source | Role |
| --- | --- | --- | --- |
| `glmmTMB_cold_nlminb` | `nlminb` | `NULL` | cold root |
| `glmmTMB_restart_nlminb_from_nlminb` | `nlminb` | cold nlminb | self restart |
| `glmmTMB_warm_bfgs_from_nlminb` | `optim/BFGS` | cold nlminb | cross-algorithm warm start |
| `glmmTMB_cold_bfgs` | `optim/BFGS` | `NULL` | cold root |
| `glmmTMB_restart_bfgs_from_bfgs` | `optim/BFGS` | cold BFGS | self restart |
| `glmmTMB_warm_nlminb_from_bfgs` | `nlminb` | cold BFGS | cross-algorithm warm start |

This is a two-root directed acyclic graph, not a tournament. It yields 9,000
full/reduced pairs and 18,000 fits. A parent start is transferred only to the
same dataset, method, likelihood identity, and model role (`full` to `full`,
`reduced` to `reduced`). Full/reduced transfer, route transfer, and adaptive
fallback are forbidden.

If a parent fit or its start signature is unavailable, the dependent profile
emits `parent_fit_or_start_unavailable` and remains in every denominator. It
does not fall back to a cold start.

## Start identity

The official `glmmTMB()` interface defines these ten possible internal start
blocks, all of which are retained in canonical order even when length zero:

`beta`, `betazi`, `betadisp`, `b`, `bzi`, `bdisp`, `theta`, `thetazi`,
`thetadisp`, and `psi`.

A warm start is extracted from an immediate post-fit snapshot
`joint_best <- fit$obj$env$last.par.best`, followed by
`fit$obj$env$parList(x=fit$fit$par, par=joint_best)`. Both arguments are
mandatory. Supplying only `fit$fit$par` is insufficient for the full start:
the installed TMB closure otherwise fills random coordinates from its mutable
`last.par` default. The snapshot's fixed coordinates must exactly match
`fit$fit$par` before extraction. Each signature binds the joint-state hash,
fixed-coordinate equality, block order, length, names, values, finiteness, and
a hash. The corresponding parent final signature and child input signature
must be identical before the child fit begins.

Random-effect conditional modes (`b`, `bzi`, and `bdisp`) are part of the
declared start identity because the public interface permits them. Empty
zero-inflation or dispersion random-effect blocks remain explicit zero-length
blocks rather than being silently removed.

## Frozen diagnostics, without eligibility cutoffs

Full and reduced fits are recorded separately. Every returned fit retains:

- optimizer convergence code, message, warnings, and objective;
- immediate joint-best snapshot hash, fixed-coordinate equality, final
  ten-block signature, and top-level parameter-vector hash;
- `fit$obj$gr(fit$fit$par)` and `fit$sdr$gradient.fixed` dimensions, hashes,
  maximum absolute norm, and Euclidean norm;
- `fit$sdr$pdHess` and the existing inverse-covariance Hessian diagnostic;
- a Richardson Jacobian of the TMB gradient, its pre-symmetrization residual,
  symmetrized eigenvalue vector, minimum, maximum, and minimum-to-maximum-
  absolute eigenvalue ratio; and
- boundary component counts, row identity, likelihood degrees of freedom, and
  full/reduced likelihood difference.

The Richardson calculation is frozen as `numDeriv::jacobian(...,
method="Richardson", method.args=list(eps=1e-4, d=1e-4, r=4, v=2,
zero.tol=sqrt(.Machine$double.eps)))`. Its package version is part of execution
identity. The experimental `glmmTMB::diagnose()` output may be captured as
supplementary text but cannot define eligibility: its return type can differ
when it recomputes a Hessian.

The following are reporting grids, not pass/fail rules:

- maximum absolute gradient: `1e-6`, `1e-5`, `1e-4`, `1e-3`;
- absolute relative Hessian eigenvalue: `1e-10`, `1e-8`, `1e-6`, `1e-4`; and
- paired objective change: `1e-8`, `1e-6`, `1e-4`, `1e-2`.

No gradient, Hessian, or objective-spread eligibility cutoff is selected from
these viewed routes.

## Denominators and non-claims

All 9,000 planned pairs remain in route-, profile-, scenario-, likelihood-,
and parent-state denominators. At minimum, returned, parent-unavailable,
optimizer-failed, non-finite objective, non-finite gradient, unavailable
Hessian, non-positive Hessian, likelihood-identity failure, finite material-
negative difference, and available comparison states are disjointly counted.

`ManifestReady=TRUE` means only that the route/profile graph and denominators
are exact. In this design slice:

- `StabilizationRunnerImplemented=FALSE`;
- `StabilizationExecutionAuthorized=FALSE`;
- `NumericalStabilizationReady=FALSE`;
- `NumericalSensitivityEvidenceReady=FALSE`;
- `CalibrationEvidenceReady=FALSE`;
- `ThresholdFrozen=FALSE`;
- `InferenceReady=FALSE`; and
- `DecisionReady=FALSE`.

No optimizer winner, start rule, bootstrap method, variance-component rule,
coefficient, or D-study decision is selected.

## Source basis

- glmmTMB troubleshooting: restart at the current optimum, gradients/Hessian,
  and alternative optimizers are complementary diagnostics:
  <https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html>
- `glmmTMB()` reference: named `start` blocks and control are explicit model-
  fitting inputs:
  <https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html>
- `diagnose()` reference: experimental coefficient, scale, and Hessian
  diagnostics are supplementary:
  <https://glmmtmb.github.io/glmmTMB/reference/diagnose.html>
- numDeriv Jacobian reference:
  <https://cran.r-project.org/package=numDeriv>
