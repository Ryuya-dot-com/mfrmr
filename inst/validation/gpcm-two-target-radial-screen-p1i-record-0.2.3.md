# GPCM two-target radial face P1i record (0.2.3)

## Scope

P1i is the first simultaneous two-random-target audit. It evaluates the six
criterion pairs C1+C2, C1+C3, C1+C4, C2+C3, C2+C4, and C3+C4 in the four
qualified exact/near Person-endpoint fixtures inherited from P1h. P1h is
frozen evidence; no single-target profile is refitted inside a supplied P1h
result.

P1i is deliberately not a complete two-target-face or source-solution
certificate. Frozen status remains:

- `CoefficientRatioBoundariesCertified = FALSE`;
- `ThreeTargetFacesEvaluated = FALSE`;
- `EmptyRandomProductHierarchyComplete = FALSE`;
- `GlobalJointBoundaryProfileCertified = FALSE`;
- `SelectionAuthorized = FALSE`;
- `ConfirmationAuthorized = FALSE`.

## Radial and relative coordinates

For a target pair `T={c1,c2}`, P1i writes

```text
lambda_c = tau * kappa_c,
tau = sqrt(lambda_c1 * lambda_c2),
kappa_c1 * kappa_c2 = 1,
(kappa_c1, kappa_c2) = (exp(d), exp(-d)).
```

With `B_r=tau*q_r`, `V_c=lambda_c*u_c`, and
`G_ck=lambda_c*H_ck`, the target logits are

```text
k * (V_c - kappa_c * B_r + tau * kappa_c * z) - G_ck.
```

This is an exact reparameterization of the P1f two-target canonical
likelihood for `tau>0`. At `tau=0` and finite `d`, it retains proportional
Rater effects `kappa_c*B_r` for both target criteria and removes latent-person
variation from both.

The coordinate chart does not contain `d=+/-infinity`. Such limits correspond
to coefficient-ratio boundaries and can require an additional scaling of
`B_r`. They are not the same claim as the finite-`d` paired deterministic-
Rater endpoint and are therefore left open rather than clipped to an arbitrary
finite coefficient ratio.

For positive `tau`, exact conversion to the P1f likelihood gives:

- maximum scaled-coordinate round-trip difference:
  `2.229119666630197e-16`;
- maximum radial-coefficient round-trip difference:
  `2.7755575615628914e-17`;
- maximum P1f/P1i objective difference:
  `1.1368683772161603e-13`;
- maximum analytic/numeric identity-gradient difference:
  `2.1066221471683917e-07`.

The maximum residual in `kappa_c1*kappa_c2=1` across the executed profiles is
`2.220446049250313e-16`.

## Execution

The design contains

```text
4 scenarios * 6 target pairs * 2 routes * 7 tau values = 336 fits.
```

The grid is

```text
0, 0.001, 0.003, 0.01, 0.03, 0.1, 0.2.
```

The descending route starts from the qualified P1h interior solution. The
reverse route starts at `tau=0` from the mean of the two corresponding P1h/P1g
singleton endpoint vectors with `d=0`. Hence route agreement tests both
traversal direction and materially different starts.

Of 336 nuisance fits, 318/336 are eligible. All 18 ineligible fits occur at
`tau=0`; 30/48 endpoint fits are eligible. The maximum q=61/91/121 objective
range is `5.6843418860808015e-13`, and the maximum direct conditional-oracle
endpoint discrepancy is `3.524291969370097e-12`.

The largest scheduled analytic/numeric profile-gradient discrepancy is
`0.003277096`. It belongs to a nonstationary endpoint and is not converted
into eligible evidence. Among positive-grid points, every natural radial
derivative is positive; the minimum is about `0.037756`. Endpoint radial
derivatives are within `5.76e-12` of zero, as expected from the symmetric
quadrature limit. These derivative facts do not repair a failed nuisance-
coordinate stationarity or route-agreement check.

The profile optimization uses about 720 seconds of summed single-process fit
time in the recorded run. Runtime is descriptive and does not enter a
statistical decision.

## Finite-ratio results and the unresolved branch

Ten of 24 scenario-by-pair radial grids are locally adjudicated. Their two
routes agree, all profile points are eligible, and their finite-ratio paired
endpoints remain above the qualified interior:

- exact fixtures: endpoint-minus-interior about `2.578242`;
- near fixtures: endpoint-minus-interior between about `2.065439` and
  `2.113173`.

Thus none of these ten finite-ratio radial grids supplies a competitive
boundary solution. This is local evidence only.

The other 14 grids are inconclusive. The maximum two-route objective
difference is about `0.0598974`. Along affected descending branches, `d`
moves increasingly negative as `tau` decreases; the most extreme returned
endpoint has `d=-7.095601`. The reverse route can remain near `d=0`, or enter
a different negative-`d` branch. This pattern is direct evidence that the
finite-relative-coordinate chart meets an unresolved coefficient-ratio
boundary; it is not evidence that one optimizer result should be preferred.

All returned endpoint objectives are descriptively above their corresponding
qualified interiors, with observed differences from about `2.065439` to
`2.638176`. This range includes non-eligible endpoints and therefore cannot be
used as a selection or closure statement.

## Decision

The recorded portfolio has:

```text
AllSixTwoTargetRadialGridsScreened = FALSE
AllSixPairedDeterministicRaterStrataScreened = FALSE
CoefficientRatioBoundariesCertified = FALSE
ThreeTargetFacesEvaluated = FALSE
EmptyRandomProductHierarchyComplete = FALSE
GlobalJointBoundaryProfileCertified = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

The correct conclusion is not “the two-target faces failed.” It is that P1i
separated a well-behaved finite-ratio subset (10/24) from a structurally open
ratio-boundary subset (14/24). Hessian inference, intervals, DFF, fit, rank,
separation, and broad simulation remain downstream because the source
solution is still unselected.

P1j subsequently supplies that coefficient-ratio boundary chart. It proves
the slower/faster Rater scaling, transports all positive P1i points, and makes
the zero-ratio edge exactly equal to the appropriate P1h/P1g singleton
likelihood. However, 392/672 singleton-grid natural-ratio derivatives are
negative, so the next gate is fixed-`mu` profiling of `rho` on `[0,1]` rather
than a denser `tau` grid, a larger iteration cap, or the three-target faces.

## Reproduction

Runner:

```text
inst/validation/gpcm-two-target-radial-screen-p1i-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-two-target-radial-screen-p1i.R
```

Frozen SHA-256 values:

- runner:
  `2208b7d8eb5da024de8ece28acba6f3b188e2d0e8d2bea0deccf0c031f275c1e`;
- test:
  `66806e2075d16a4b992b6dfaf55ed4e0c03ff5ac89e78a232dd85f71bc2c86aa`.

The focused lightweight suite tests the exact P1f coordinate identity,
analytic nuisance and radial derivatives, direct conditional endpoint oracle,
and fail-closed decision contract. It reports 93 passed expectations and one
intentional long-audit skip. With
`NOT_CRAN=true MFRMR_RUN_LONG_VALIDATION=true`, the dependency-complete suite
rebuilds P0--P1h and the 336 P1i fits, reporting 110 passed expectations with
no failure, warning, error, or skip. Documentation terminology, first-use
readiness, readiness propagation, release readiness, and results readiness
regression tests also pass; the first-use suite emits its prespecified sparse-
category review warning.
