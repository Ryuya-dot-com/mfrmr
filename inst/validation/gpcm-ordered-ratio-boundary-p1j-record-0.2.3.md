# GPCM ordered coefficient-ratio boundary P1j record (0.2.3)

## Scope

P1j resolves the coordinate question exposed by P1i. It does not run another
optimizer search. Instead, it proves and executes two exact transports:

1. every positive-radius P1i two-target point is expressed in a finite ordered
   slower/faster coefficient chart;
2. the zero-ratio edge of that chart is identified exactly with the frozen
   P1h/P1g singleton-target likelihood.

P1j then evaluates the natural coefficient-ratio derivative at every frozen
singleton grid point. This distinguishes an exact likelihood identity from a
completed ratio profile. It does not claim the latter.

## Ordered chart

For distinct fast and slow target criteria, define

```text
lambda_slow = mu,
lambda_fast = mu * rho,
B_r = mu * q_r,
mu > 0,
rho > 0.
```

With target-scaled locations and cumulative steps, the two adjacent-category
logits are

```text
slow: k * (V_slow - B_r + mu * z) - G_slow,
fast: k * (V_fast - rho * B_r + mu * rho * z) - G_fast.
```

For `rho>0`, this is an exact reparameterization of the P1f two-target
likelihood. It is also exactly equivalent to P1i under

```text
mu = tau * kappa_slow,
rho = kappa_fast / kappa_slow,
tau = mu * sqrt(rho).
```

Unlike P1i's finite-relative-coordinate endpoint, this chart remains finite
when the coefficient ratio tends to zero. At `rho=0`, the fast criterion loses
Rater and latent-person variation but retains its free location and steps. It
therefore becomes an ordinary P1f non-target criterion. The slow criterion is
exactly the corresponding P1h/P1g singleton target at coefficient `mu`.

This distinction corrects a tempting but invalid shortcut: the ratio boundary
is nested in the singleton likelihood, but it is not automatically locally or
globally optimal merely because the singleton grid has already been fitted.

## Positive P1i transport

P1i contains

```text
4 scenarios * 6 target pairs * 2 routes * 6 positive tau values = 288 points.
```

For each point P1j chooses the larger of the two coefficients as `mu`, so the
reported transported ratio satisfies `0 < rho <= 1`. All 288/288 eligible
positive points transport successfully.

- maximum P1i/P1j objective difference:
  `2.2737367544323206e-13`;
- maximum P1i-coordinate round-trip difference:
  `2.220446049250313e-16`;
- maximum `tau` round-trip difference:
  `2.7755575615628914e-17`.

On the P1i branches with visibly negative relative coordinate, the ordered
chart gives finite descriptive ranges of approximately

```text
mu  = 0.00137 to 0.03464,
rho = 0.0194  to 0.7500.
```

Thus the earlier apparent `d -> -infinity` is a regular approach to
`rho -> 0` in the ordered chart, not evidence that an arbitrary finite bound
should be placed on `d`.

## Singleton-boundary identity

The frozen singleton portfolio contains

```text
4 scenarios * 12 ordered fast/slow directions *
2 source routes * 7 mu values = 672 rows.
```

All 672/672 rows pass the exact nesting contract. Across those rows:

- maximum ordered/singleton objective difference: exactly `0` at recorded
  precision;
- maximum nuisance-gradient difference: exactly `0` at recorded precision;
- maximum natural-`mu` derivative difference:
  `7.105427357601002e-15`;
- maximum analytic/three-point-forward natural-`rho` derivative difference on
  the 192 scheduled `mu=0` and `mu=0.2` rows:
  `6.311586e-08`.

The equality includes C1--C3 via P1h and C4 via the separately derived P1g
likelihood. No target-label transport is assumed without direct evaluation.

## Boundary derivative result

The natural `rho` objective derivative ranges from about `-2.758578` to
`0.169782`. Only 280/672 derivatives are nonnegative; 392 are negative.

The sign pattern is structured:

| `mu` | Negative | Positive | Total |
| ---: | ---: | ---: | ---: |
| 0 | 28 | 68 | 96 |
| 0.001 | 28 | 68 | 96 |
| 0.003 | 48 | 48 | 96 |
| 0.01 | 48 | 48 | 96 |
| 0.03 | 48 | 48 | 96 |
| 0.1 | 96 | 0 | 96 |
| 0.2 | 96 | 0 | 96 |

Because the inherited singleton nuisance fits are eligible, a materially
negative derivative is local evidence that releasing the fast coefficient
improves the objective from that singleton point. At `mu=0.1` and `mu=0.2`,
all ordered directions have such an improving release. At smaller `mu`, the
direction depends on the ordered criterion pair and fixture.

This result explains why P1i could not close the two-target faces by endpoint
transport alone. It also prevents a false claim that the P1h/P1g singleton
screens certify all coefficient-ratio boundaries.

## Decision and next gate

The recorded status is

```text
AllPositiveP1iPointsTransported = TRUE
AllTwelveOrderedRatioBoundaryIdentitiesCertified = TRUE
CoefficientRatioBoundaryLikelihoodIdentityCertified = TRUE
AllBoundaryRhoDerivativesNonnegative = FALSE
CoefficientRatioLocalDerivativeGridScreened = FALSE
CoefficientRatioProfilesCompleted = FALSE
AllSixTwoTargetFacesGloballyCertified = FALSE
ThreeTargetFacesEvaluated = FALSE
EmptyRandomProductHierarchyComplete = FALSE
GlobalJointBoundaryProfileCertified = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

P1k subsequently runs this closed-interval optimizer on the exact-high and
near-high representatives. All 336 fits are eligible, but 33/168 cells retain
competing KKT objectives and another ten retain the same objective at distinct
coordinates. The next gate is therefore fixed-`rho` nuisance continuation for
those 43 cells, not immediate reflection expansion or three-target work.
Hessian inference, intervals, DFF, fit, rank, separation, broad simulation,
and source selection remain downstream.

## Reproduction

Runner:

```text
inst/validation/gpcm-ordered-ratio-boundary-p1j-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-ordered-ratio-boundary-p1j.R
```

Frozen SHA-256 values:

- runner:
  `b8438e014db1cfa55ea55669991b693f43a2ec8834a97ffb5505268774be6d26`;
- test:
  `3e007127fac547ec12776c8727ff96ccfadce4cf6de0936e4eb8a2c8e0c94927`.

The ordinary focused suite checks all 12 coordinate directions, P1f and P1i
round trips, analytic nuisance/`mu`/`rho` derivatives, the P1h/P1g singleton
identity at `mu=0` and positive `mu`, and fail-closed decisions. It reports
252 passed expectations and one intentional chained-audit skip. The full P0--
P1i rebuild is separately opt-in through
`MFRMR_RUN_P1J_DEPENDENCY_REBUILD=true`; ordinary long-validation runs do not
silently add that roughly 22-minute dependency cost.
