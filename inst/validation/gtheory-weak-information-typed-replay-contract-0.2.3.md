# Draft.83d2b2b1f typed numerical-replay adjudication contract

Status: repository-only amendment on immutable viewed ledgers, 2026-08-10.

Draft.83d2b2b1e correctly failed its frozen default-replay gate because that
gate defined only a finite absolute difference no greater than 1e-10. Seven
baseline/default pairs were both non-finite, so `abs(NA - NA)` could not pass.
This successor does not relax or rewrite b1e. It prospectively defines a typed
comparison, applies it to the immutable b1d and b1e ledgers without any refit,
and records the result under a new contract and result hash.

## Frozen upstream identities

The only admissible inputs are:

- Draft.83d2b2b1d runner contract
  `c97b5d08c29e7a7537fe4669f938de9e978b4bb651596007af0b7ea7b9378df7`;
- Draft.83d2b2b1d execution
  `04ec60ab6d4351c0d8c6416543fa8ac46e15585bbe85680f829b341beb34a22b`;
- Draft.83d2b2b1e contract
  `0538eb1a7636d4d784f06c10bb17f65aa958f4e677005462d6309827292083c6`;
- Draft.83d2b2b1e manifest
  `53880242ed7441c93516defbd840c289df32bbc6d0677e4b441bc2543eda8d2f`;
  and
- Draft.83d2b2b1e execution
  `37be0b4dbac852454ced612b5f84706678f688f3f3ea7209793111ab6a706d94`.

The b1e input must retain exact 9,000-row accounting, its failed finite-only
replay gate, and all downstream readiness flags as false. The b1d input must
retain exact 3,000-row feasibility accounting. Hash mismatch, row duplication,
or a changed readiness state fails closed.

## Typed replay states

Each of the 3,000 original routes is matched to its b1e default profile by
`RouteId`. Exactly one of the following mutually exclusive states is assigned:

1. `finite_match`: both raw differences are finite and their absolute
   difference is no greater than 1e-10;
2. `same_typed_nonfinite_state`: both differences have the same exact
   non-finite kind (`NA_real`, `NaN`, `positive_infinity`,
   `negative_infinity`, or the fail-closed fallback `other_nonfinite`) and also
   agree on pair-return, likelihood-availability,
   within-tolerance flag, and typed comparison state;
3. `finite_mismatch`: both are finite but differ by more than 1e-10;
4. `nonfinite_state_mismatch`: both are non-finite but any kind or diagnostic
   state differs; or
5. `finite_nonfinite_mismatch`: exactly one is finite.

`NA_real` and `NaN` are distinct. Two missing values are never assigned a
numeric distance of zero. `same_typed_nonfinite_state` is equality of recorded
states, not numerical closeness and not an available likelihood comparison.
It cannot promote either row to finite, likelihood-available, or
comparison-available.

Finite material-negative status is derived independently as
`is.finite(raw) && raw < -1e-6`. A non-finite value is never material-negative.

## Execution prohibition and scientific identity

The adjudicator must not call a data generator, pre-fit function, lme4,
glmmTMB, TMB, an optimizer, a bootstrap, or a D-study. It reads only the two
exact ledgers. No start value, tolerance, objective, boundary state, or stored
fit is changed.

The result hash binds both upstream executions, the typed-state contract,
function hashes, all 3,000 atomic adjudication rows, and exact counts. Timing,
filesystem location, and read order are excluded because they do not affect
the adjudication.

`TypedReplayAdjudicationReady=TRUE` requires 3,000 unique matched routes and
zero mismatch states. This closes only the missing replay-state definition.
It does not retroactively change b1e's `DefaultReplayPassed=FALSE` or
`NumericalSensitivityEvidenceReady=FALSE`.

## Next numerical gate

Even a successful typed adjudication does not resolve the b1e glmmTMB result.
The current official glmmTMB troubleshooting guidance treats false-convergence
assessment as a combination of small gradients/positive-definite Hessian,
different starting conditions including restart at the current optimum, and
alternative optimizers:

<https://glmmtmb.github.io/glmmTMB/articles/troubleshooting.html>

The official `glmmTMB()` reference makes `start` an explicit list of internal
parameter blocks and therefore part of fit identity:

<https://glmmtmb.github.io/glmmTMB/reference/glmmTMB.html>

The official experimental `diagnose()` reference separately checks Hessian,
coefficient, Z-statistic, and predictor-scale problems:

<https://glmmtmb.github.io/glmmTMB/reference/diagnose.html>

A later viewed-data glmmTMB stabilization contract must therefore freeze
restart extraction, parameter-block identity, gradients, Hessian diagnostics,
and alternative algorithms separately. It may not choose BFGS, a start rule,
or an objective-spread threshold from successful rows only.

Calibration replicates 201--300, bootstrap operating characteristics,
threshold selection, inference, coefficient eligibility, and D-study decisions
remain prohibited.
