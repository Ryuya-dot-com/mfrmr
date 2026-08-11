# GPCM joint zero-variance/log-slope P1d record for 0.2.3

Status: completed deterministic calibration, 2026-08-12.
Contract: `mfrmr_gpcm_zero_variance_log_slope_path_p1d_v1`.
Specification: `0.2.3-draft.1`.

P1c closed the exact `sigma2 -> 0+` likelihood identity only for fixed finite
nuisance coordinates. Its zero-boundary nuisance refits were nonstationary and
showed large, start-sensitive slopes. P1d therefore evaluates one explicit
joint variance/slope recession geometry rather than incorrectly transporting
the fixed-nuisance q=1 result. It is a bounded local path audit, not a global
joint-boundary profile, source-solution selection, or inference gate.

## Execution identity

- branch: `development/0.2.3`
- parent commit: `57f2f11a81c7ffc8d0bc2ec6552a4f694ef1409c`
- source-tree version: `0.2.3`
- P1d runner: `gpcm-zero-variance-log-slope-path-p1d-0.2.3.R`
- P1d runner SHA-256:
  `5480c1e9c1ff04e208df9e375dd54b99395b25df28b11b5ba96625259338af51`
- P1d test: `test-gpcm-zero-variance-log-slope-path-p1d.R`
- P1d test SHA-256:
  `390f64ee8cf2e72891e8c4bdd6f6b2f89f8168d4dd3ff40f1bc3d15a57d6b986`
- P1c dependency contract:
  `mfrmr_gpcm_zero_variance_boundary_p1c_v1`
- P1c dependency SHA-256:
  `9feeabfc715d32bc7056e116c58273dcc82363e2111363c1df42d485f6afd8f5`
- P1c controls retained exactly: `maxit = 800`, `reltol = 1e-12`
- P1d constrained-path controls: `maxit = 600`, `reltol = 1e-10`
- path quadrature: q=121 optimization, plus same-vector q=61/91/121
  evaluation
- path values: `t = 0, 2, 4, 6, 8, 10`
- routes: qualified-interior forward warm start and diagnostic P1c-boundary
  reverse warm start
- directional derivative steps: `1e-4`, `1e-5`, and `1e-6`

## Joint-path mathematics

Let `J` be the number of slope levels, `v0` the qualified P1b/P1c interior
population variance, and `ell_j(0)` its identified expanded log slopes. For a
declared target level `j*`, P1d fixes

```text
v(t)        = v0 exp(-2 t),
ell_j*(t)   = ell_j*(0) + t,
ell_j(t)    = ell_j(0) - t / (J - 1),  j != j*.
```

The log-slope rates sum to zero, so the geometric-mean-one slope
identification is preserved. Moreover,

```text
log[a_j*(t) sqrt(v(t))] = ell_j*(0) + 0.5 log(v0),
```

while every non-target `a_j(t) sqrt(v(t))` decreases at rate
`-J / (J - 1)`. The target latent-noise contribution therefore does not
vanish along this sequence. Dominated convergence at fixed finite nuisance,
used correctly in P1c, cannot justify replacing this non-uniform joint limit
by q=1. P1d retains standardized-normal quadrature at every finite point and
marks q=1 transport as prohibited.

The remaining nuisance coordinates are reoptimized at each path point. The
analytic derivative along the fixed joint direction is

```text
d f / d t = grad(f)' d,
```

where the free-coordinate direction has `-2` in `log_sigma2`, the first
`J - 1` identified log-slope rates in the free slope coordinates, and zero in
the reoptimized nuisance coordinates. A separate central-difference ladder
checks this derivative while holding nuisance fixed.

## Declared direction

The target direction is selected deterministically from the lowest finite P1c
boundary trace in each scenario. Because every P1c boundary trace is
comparison-ineligible, this is diagnostic geometry only and cannot select a
solution. All four scenarios independently point to Criterion C4.

| Scenario | P1c diagnostic start | P1c objective | Target | P1c target log slope |
| --- | --- | ---: | --- | ---: |
| `EXT5-P-HI` | `zero_nuisance` | `641.7459` | `Criterion::C4` | `4.381944` |
| `EXT5-P-LO` | `default` | `641.7457` | `Criterion::C4` | `7.217824` |
| `EXT5-P-NEAR-HI` | `zero_nuisance` | `641.8847` | `Criterion::C4` | `3.788653` |
| `EXT5-P-NEAR-LO` | `zero_nuisance` | `641.8847` | `Criterion::C4` | `3.730369` |

This agreement supports studying the same labelled ray across reflections; it
does not establish that the ray spans all asymmetric or curved joint-boundary
directions.

## Finite path geometry

The algebraic invariant is retained to machine precision: the maximum range
of target effective log scale across a route is about `1.78e-15`. At `t = 10`,
the prescribed population variance is about `6.18e-11` in the exact scenarios
and `5.24e-11` in the near scenarios. The target slope is about `22,104` and
`20,417`, respectively. Maximum prescribed slope ratios are about `6.22e5`
and `5.61e5`. These are path coordinates, not estimated boundary cutoffs.

| `t` | Exact `sigma2` | Near `sigma2` | Exact maximum slope | Near maximum slope |
| ---: | ---: | ---: | ---: | ---: |
| `0` | `3.000e-2` | `2.544e-2` | `1.004` | `1.034` |
| `2` | `5.495e-4` | `4.660e-4` | `7.415` | `6.849` |
| `4` | `1.006e-5` | `8.535e-6` | `54.79` | `50.61` |
| `6` | `1.843e-7` | `1.563e-7` | `404.86` | `373.96` |
| `8` | `3.376e-9` | `2.863e-9` | `2991.5` | `2763.2` |
| `10` | `6.184e-11` | `5.244e-11` | `22104` | `20417` |

## Numerical result

All 48 constrained fits returned finite vectors. Existing nuisance
stationarity passes at all eight `t = 0` points and six of eight `t = 2`
points, but at none of the 32 points with `t >= 4`. In total, only 14/48 path
points are comparison-eligible. The other 34 return optimizer code zero with
a gradient too large for the existing rule. Maximum nuisance-gradient norms
increase from below `9.72e-5` at `t = 0` to as high as `0.0966` at `t = 10`.

Quadrature itself is not the observed failure mode. Same-vector q=61/91/121
objective ranges are at most `1.7394e-11`, including the stiffest terminal
points. The independent directional derivative ladder has maximum analytic/
numeric disagreement `4.9246e-6`; route-specific minima range from about
`2.13e-11` through `2.13e-9`. This supports the recorded path derivative as a
finite-point diagnostic but does not repair nuisance stationarity.

Every route has a larger terminal objective than at `t = 0`:

| Scenario | Route | Objective `t=0` | Objective `t=10` | Change |
| --- | --- | ---: | ---: | ---: |
| `EXT5-P-HI` | forward | `639.16746` | `643.32174` | `+4.15428` |
| `EXT5-P-HI` | reverse | `639.16746` | `643.32174` | `+4.15428` |
| `EXT5-P-LO` | forward | `639.16746` | `643.47577` | `+4.30831` |
| `EXT5-P-LO` | reverse | `639.16746` | `643.67297` | `+4.50551` |
| `EXT5-P-NEAR-HI` | forward | `639.81915` | `643.34657` | `+3.52743` |
| `EXT5-P-NEAR-HI` | reverse | `639.81915` | `643.33487` | `+3.51572` |
| `EXT5-P-NEAR-LO` | forward | `639.81915` | `643.42757` | `+3.60842` |
| `EXT5-P-NEAR-LO` | reverse | `639.81915` | `643.37928` | `+3.56013` |

That endpoint ordering is evidence against a simple monotone recession along
this declared ray. It is not a certified finite turnback: objectives are not
monotone at all intermediate points, terminal directional derivatives differ
in sign across scenarios/routes, and route objective differences reach about
`0.1972` at `t = 10`. Most importantly, the affected points are nonstationary.
No route receives a recession or turnback classification.

The fitted nuisance geometry also becomes stiff. Rater facet magnitudes shrink
toward roughly `2e-6`, while some step coordinates reach magnitudes above `8`
and route differences expand at large `t`. Raising the iteration ceiling or
adding more path points without addressing this coordinate geometry would be
repetition, not stronger evidence.

## Decision

P1d produces a fail-closed result:

- **implemented:** a sum-zero, scale-compensating joint path that retains the
  non-vanishing target `slope * population SD` term;
- **prohibited:** transport of the fixed-finite-nuisance q=1 identity onto this
  non-uniform sequence;
- **observed:** q=61/91/121 common evaluations are numerically coherent and the
  declared C4 path has a worse objective at `t = 10` than at `t = 0`;
- **NO-GO:** 34/48 nuisance fits fail the existing stationarity rule, so neither
  recession nor finite turnback is certified;
- **NO-GO:** one observed symmetric compensation ray is not a global joint
  boundary profile and cannot select the interior source solution; and
- **NO-GO:** the upper/joint variance boundary, Hessian, intervals, DFF, fit,
  rank, separation, and broad simulation remain downstream.

All four scenario decisions are
`bounded_joint_path_inconclusive`. Reflection-pair decision signatures remain
invariant because both sides retain the same fail-closed state.

The next efficient slice is not a denser `t` grid or a larger iteration ceiling.
It is a coordinate-aware limiting/reparameterization audit for the observed C4
ray: identify which step, facet, and population-location combinations must
shrink or diverge to keep category logits finite, then optimize that reduced
limit or a well-scaled finite representation. The separate upper-variance
joint path remains after this lower joint-boundary question. No large
simulation is authorized.

## Verification

The ordinary focused suite pins the P1c dependency and P1d runner; verifies
the sum-zero and effective-scale algebra, route classification, missing-route
fail-closed behavior, source-solution blockers, and signature mutation; and
keeps the four-scenario execution opt-in through
`MFRMR_RUN_LONG_VALIDATION=true`. The complete run retains 48 path fits, 144
directional-derivative rows, eight route summaries, 24 route-pair rows, four
decisions, and two reflection comparisons. A direct recorded execution took
about 416.8 seconds. The lightweight suite reports 68 passed expectations with
one intentional long-run skip. The complete opt-in suite reports 95 passed
expectations with no failure, error, warning, or skip. Runtime is descriptive
only.
