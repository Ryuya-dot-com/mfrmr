# GPCM category-reflection transport P1n record (0.2.3)

## Purpose and scope

P1n asks whether the four P1m local mechanism representatives must be refitted
on the exact-low and near-low fixtures. The answer is no for the declared
representative scope: category reversal defines an exact likelihood
transport. P1n verifies that identity on both fixture pairs, three quadrature
schedules, all 87 stored P1m points, and the analytic nuisance gradient. It
does not call four representative mechanisms a complete continuous profile.

The frozen pairs are:

| Pair | High fixture | Low fixture |
| --- | --- | --- |
| exact | `EXT5-P-HI` | `EXT5-P-LO` |
| near | `EXT5-P-NEAR-HI` | `EXT5-P-NEAR-LO` |

All non-score row identities are preserved and the zero-based scores satisfy
`y_high + y_low = 4` on every row.

## Algebraic identity

For categories `k=0,...,M`, write the GPCM category log numerator as

```text
u_k(eta,d) = k * eta - D_k,
D_k = sum_{h=1}^k d_h, D_0 = 0.
```

Define the reflected step vector by `d'_h = -d_(M+1-h)` and use
`eta'=-eta`. Then

```text
D'_l = D_(M-l) - D_M,
u'_(M-k) = u_k - M*eta + D_M.
```

The final two terms do not depend on `k`, so softmax normalization removes
them and

```text
P_low(Y=M-k | eta',d') = P_high(Y=k | eta,d).
```

The repository's identified steps sum to zero, but the probability identity
does not rely on that special value. The free-coordinate implementation first
expands each criterion's step vector, reverses and negates the full vector,
and then returns to the identified free coordinates. Rater and location
coordinates are negated; positive coefficients `mu` and `rho` are unchanged.

For the marginal model, the reflected nuisance coordinate `T*x` satisfies

```text
eta_low(T*x, z) = -eta_high(x, -z).
```

The 61-, 91-, and 121-point Gaussian nodes and weights are mirror symmetric,
so reversing the node index gives the same person-marginal likelihood. The
free-coordinate map is linear, nonsingular, and involutive (`T*T=I`). Hence

```text
F_low(T*x, mu, rho) = F_high(x, mu, rho),
g_high(x) = t(T) * g_low(T*x),
dF_high/dmu = dF_low/dmu,
dF_high/drho = dF_low/drho.
```

For nuisance Hessians the correct statement is congruence,
`H_high=t(T)*H_low*T`. The free step map need not be orthogonal, so equal
eigenvalues are not claimed. Nonsingular congruence preserves inertia and
therefore transports positive definiteness and local regularity.

## Numerical audit

The final execution records:

- 6/6 fixture-by-quadrature context identities pass;
- both 20-dimensional free-coordinate maps have full rank, determinant 1,
  and exactly satisfy the stored involution check;
- all 87/87 stored representative points pass likelihood, posterior,
  gradient, and coordinate-involution checks;
- maximum marginal-objective difference: `2.273737e-13`;
- maximum mirrored observed-log-probability/posterior difference:
  `1.022793e-14`;
- maximum transported analytic-gradient difference: `2.169164e-13`;
- maximum twice-reflected coordinate difference: `2.081668e-17`.

An independent central-difference nuisance gradient is scheduled at the three
refined turning points and the middle monotone-grid point, on both the high and
low likelihoods. All four pass; the largest analytic-versus-numeric difference
is `1.854152e-08`, below the frozen `2e-5` audit threshold.

Consequently, the near-low representative inherits the local profiled maximum,
and the exact-low representatives inherit the objective minimum, monotone-grid
classification, and coordinate-only minimum. No reflected fallback fit is
required for these four local mechanisms.

## Decision and fail closure

The final status is

```text
ExactAndNearFixtureScoreReflectionVerified = TRUE
SymmetricQuadratureTransportVerified = TRUE
LinearCoordinateInvolutionVerified = TRUE
AllRepresentativePointLikelihoodAndGradientIdentitiesVerified = TRUE
AllFourLocalMechanismsTransported = TRUE
ReflectedRepresentativeFixturesEvaluated = TRUE
RefitFallbackRequired = FALSE
ReflectedFixturesEvaluated = FALSE
FullFourFixtureRatioProfilesCompleted = FALSE
ContinuousMonotonicityCertified = FALSE
ContinuousGlobalProfileCertified = FALSE
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

`ReflectedRepresentativeFixturesEvaluated` is deliberately narrower than
`ReflectedFixturesEvaluated`. The former covers the four frozen P1m local
mechanisms; the latter is reserved for the complete coefficient-ratio
portfolio and remains false. Likewise, Hessian congruence transports the
local nuisance-regularity result but does not authorize inferential standard
errors, DFF, fit, or rank decisions.

The next efficient gate is to materialize this exact map over the complete P1l
43-cell nonmatching registry and the already-agreeing P1k cells, without
refitting. That will distinguish complete reflected finite-grid transport from
the still-open continuous ratio profile. Three-target faces and broad
simulation remain later tasks.

## Reproduction

Runner:

```text
inst/validation/gpcm-category-reflection-transport-p1n-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-category-reflection-transport-p1n.R
```

Frozen SHA-256 values:

- runner: `8dba2f8393837fcb54c2124ea7a01eb90ad4051d8919ebc8f65b35f380e5b357`;
- test: `b685e4c555dc0fbad10223388590b02e9f4cec0adca0fcc72998cc6d3762eee8`.

Routine tests cover the category-kernel identity, sum-zero free-step
involution, mirrored context contract, fixed dependency, and local/global
decision separation. The 87-point stored-result audit is opt-in through
`MFRMR_RUN_P1N_PILOT=true` and `MFRMR_P1M_RESULT=<path>`.
