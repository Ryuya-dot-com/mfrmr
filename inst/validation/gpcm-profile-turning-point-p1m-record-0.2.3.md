# GPCM local profile turning-point P1m record (0.2.3)

## Purpose and stopping rule

P1m asks whether P1l's three observed natural-`rho` mechanisms survive a
stricter local numerical audit. It does not add another rectangular grid. Four
representatives are selected deterministically:

| Representative | Lane | Selection rule | Frozen cell |
| --- | --- | --- | --- |
| `objective_profile_maximum` | objective-discordant | largest P1k objective difference | `EXT5-P-NEAR-HI::C4_fast__C3_slow::0` |
| `objective_profile_minimum` | objective-discordant | largest P1k objective difference | `EXT5-P-HI::C1_fast__C4_slow::0` |
| `objective_monotone_increasing` | objective-discordant | largest P1k objective difference | `EXT5-P-HI::C1_fast__C2_slow::0` |
| `coordinate_profile_minimum` | coordinate-only | largest P1k `rho` difference | `EXT5-P-HI::C4_fast__C1_slow::0.003` |

Values within `1e-8` of the largest metric are tied and resolved by `CellId`.
This selection rule is frozen before the P1m turning-point results are used.

P1m has an explicit stopping rule: a local turning point may be supported, but
finite numerical evaluations cannot certify a continuous global profile or
strict monotonicity on every unsampled point. Those global flags remain false
even when every local check passes.

## Strict nuisance optimization

P1l used a `1e-4` nuisance-gradient eligibility threshold for screening. P1m
requires a nuisance-gradient sup-norm at most `2e-6`. BFGS and L-BFGS-B are
followed, only when necessary, by a Newton correction based on a Richardson
Jacobian of the analytic nuisance gradient. A Newton step is accepted only if
it decreases the gradient norm and does not raise the objective beyond
`100 * machine epsilon * max(1, abs(objective))`.

This correction was necessary because ordinary optimizers could stop near
gradient `1e-5` when the predicted objective improvement was around `1e-12`.
On a diagnosed point, one Newton step reduced the gradient from about
`1.26e-5` to `5.42e-12` while the nuisance Hessian minimum eigenvalue remained
about `5.64`. The eligibility threshold was not relaxed in response.

Across the final execution:

- 87/87 recorded points are eligible;
- maximum nuisance-gradient sup-norm: `1.966818e-06`;
- maximum q=61/91/121 objective range: `4.547473508864641e-13`;
- maximum two-route objective difference at a refined turning point:
  `1.136868e-13`;
- maximum two-route nuisance-coordinate difference:
  `2.528614e-07`;
- summed single-process optimization time: about `163.6` seconds.

## Turning-point results

The P1l robust derivative brackets are reoptimized at both ends and then
bisected. Each final midpoint is independently reoptimized from both P1l route
starts and receives a nuisance-Hessian audit.

| Representative | Type | Iterations | Final width | Refined `rho` | Envelope derivative |
| --- | --- | ---: | ---: | ---: | ---: |
| `objective_profile_maximum` | maximum | 21 | `7.152557e-08` | `0.8159349` | `-2.363731e-08` |
| `objective_profile_minimum` | minimum | 22 | `5.960464e-08` | `0.2576063` | `1.006527e-09` |
| `coordinate_profile_minimum` | minimum | 20 | `6.675720e-08` | `0.9084936` | `-1.138567e-08` |

All three retain the required raw derivative signs at the final bracket ends,
both routes coalesce at the refined midpoint, and their objective ordering
matches the claimed maximum or minimum relative to `rho=0` and `rho=1`.
Their nuisance-Hessian minimum eigenvalues are respectively approximately
`5.642938`, `5.642936`, and `5.642937`; condition numbers are approximately
`61.31`, `39.52`, and `67.68`. Thus the nuisance coordinates define a locally
regular minimum branch at each turning point.

For the maximum representative, an independent Richardson Hessian of the
objective is also computed. The analytic-gradient Jacobian and independent
Hessian have the same positive minimum eigenvalue to a relative difference of
about `4.51e-08`. Their difference has spectral norm about `0.0341`, or 0.60%
of the minimum eigenvalue. This passes the frozen perturbation contract of 1%
and leaves substantial positive-definiteness margin. Elementwise absolute
agreement is retained descriptively but is not used as a scale-free decision.

## Monotone representative

The monotone representative is strictly reoptimized at nine points from
`rho=0` to `rho=1` in increments of `0.125`. Its objective is nondecreasing;
all observed envelope derivatives are positive, ranging from approximately
`3.907109e-05` to `0.1196254`. The endpoint nuisance Hessian has minimum
eigenvalue about `5.642938` and condition number about `74.15`.

This supports monotonicity on the declared adaptive grid. It does not exclude
a narrow, unsampled derivative sign change. Therefore
`ContinuousMonotonicityCertified` remains false by construction.

## Decision and interpretation

The final status is

```text
AllThreeTurningPointRepresentativesLocallySupported = TRUE
MonotoneRepresentativeAdaptiveGridSupported = TRUE
AllRepresentativeLocalMechanismsSupported = TRUE
ContinuousMonotonicityCertified = FALSE
ContinuousGlobalProfileCertified = FALSE
ReflectedFixturesEvaluated = FALSE
FullFourFixtureRatioProfilesCompleted = FALSE
CoefficientRatioProfilesCompleted = FALSE
AllSixTwoTargetFacesGloballyCertified = FALSE
ThreeTargetFacesEvaluated = FALSE
EmptyRandomProductHierarchyComplete = FALSE
GlobalJointBoundaryProfileCertified = FALSE
HessianInferenceAuthorized = FALSE
DFFFitRankAuthorized = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

P1m validates P1l's local interpretation: the representative maximum really
is a locally regular profiled maximum, both minimum classes are locally regular
profile minima, and the monotone case remains increasing on a stricter grid.
It does not prove that these four representatives exhaust all behavior, nor
does it convert finite samples into a global lower bound over `rho`.

The next efficient step is algebraic reflection transport: derive the exact
category-reversal transformation from Person high fixtures to their low
counterparts and test likelihood, gradient, turning-point type, and endpoint
ordering invariance. That is preferable to duplicating the 87-point audit by
refitting reflected fixtures. If exact transport fails, only the failed cells
should be fitted. Three-target faces, source selection, Hessian inference,
DFF/fit/rank confirmation, and broad simulation remain downstream.

## Reproduction

Runner:

```text
inst/validation/gpcm-profile-turning-point-p1m-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-profile-turning-point-p1m.R
```

Frozen SHA-256 values:

- runner: `7056ea9d3e51aac91103aef570557a60dac018f989adaff4d6061d1425a1449c`;
- test: `a24ad3039688b3f076785343d92e398a822fe557bb074f2ae6b97b4808444e9c`.

The focused suite freezes the P1l dependency and four representatives, tests
deterministic tie handling and derivative-bracket choice, recovers an
independent convex Hessian control, and keeps local support distinct from
global authorization. The chained P0--P1m execution remains opt-in through
`MFRMR_RUN_P1M_PILOT=true` and is not part of routine validation.
