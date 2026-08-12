# GPCM fixed-rho basin-continuation P1l record (0.2.3)

## Scope

P1l follows the 43 P1k cells whose two bounded-optimization routes did not
return the same `rho`. It keeps the 33 objective-discordant cells and the ten
same-objective/coordinate-discordant cells in separate registries. This avoids
rerunning the priority lane when the identifiability lane is opened.

For each cell, P1l fixes `mu`, profiles natural `rho`, and reoptimizes every
nuisance coordinate from two directions:

1. `low_to_high`, initialized by the P1k singleton-side candidate;
2. `high_to_low`, initialized by the P1k equal-side candidate.

The base grid is prespecified as

```text
0, .01, .03, .10, .25, .50, .75, .90, .97, .99, 1.
```

The two P1k returned `rho` values are added per cell when they are not already
on that grid. Those additions are recovery checks, not retrospectively chosen
search points. All comparisons use unrounded objective values. A printed
decimal is never used as the comparison value.

P1l is a finite-grid mechanism audit. It does not certify continuity between
points, exclude an unseen narrow basin, certify a global profile, or close the
two-target face.

## Nuisance and derivative contract

At fixed `rho`, a candidate must have optimizer code zero, pass the shared
gradient-based optimizer diagnostic, have nuisance gradient sup-norm at most
`1e-4`, and remain stable at q=61/91/121. Scheduled analytic gradients are
compared with independent central differences at step `1e-5`.

The two routes are declared the same fixed-`rho` solution only when both
objective difference (`5e-6`) and nuisance-coordinate maximum difference
(`5e-5`) pass. The envelope derivative is the analytic natural-`rho`
derivative after nuisance optimization. Derivative signs within `5e-6` of
zero are left unclassified; this is larger than the observed two-route
derivative discrepancy and prevents a machine-level sign from defining a
turning point.

## Objective-discordant priority lane

The 33-cell plan contains 383 distinct cell/`rho` points and 766 fits. Results:

- 766/766 fits are eligible;
- all 383 points have two eligible routes;
- maximum q=61/91/121 objective range: `5.6843418860808015e-13`;
- maximum nuisance gradient sup-norm: `9.945027e-05`;
- maximum scheduled analytic/numeric gradient difference: `1.861536e-08`;
- maximum two-route objective difference at the same `rho`:
  `1.206217e-09`;
- maximum two-route nuisance-coordinate difference at the same `rho`:
  `1.354248e-05`;
- maximum two-route natural-`rho` derivative difference:
  `4.844174e-06`;
- maximum P1k stationary-candidate objective recovery difference:
  `1.210424e-09`;
- summed single-process optimization time: about `247.3` seconds.

Thus all 33 P1k route discrepancies coalesce to the same nuisance solution
when `rho` is held equal. Their finite-grid profile mechanisms are:

| Mechanism | Cells |
| --- | ---: |
| positive-to-negative derivative bracket (profile maximum) | 22/33 |
| negative-to-positive derivative bracket (profile minimum) | 6/33 |
| positive derivative throughout the scheduled grid | 5/33 |

All 33 lower-route P1k candidates have the smaller objective. The 22 maximum
brackets support a single profiled curve with two constrained endpoint-side
minima separated by an interior maximum on the observed grid. The six minimum
brackets support one interior minimum; the equal-side candidates near the
upper bound are not a second minimum. In the five monotone-increasing cases,
the lower endpoint is favored and the near-upper candidate is not stationary.

This refines the P1k phrase “competing KKT solutions.” P1k used a `1e-4` KKT
tolerance, so eleven high-side candidates could pass the numerical eligibility
rule without being exact constrained local minima. They remain valid evidence
about stopping tolerance and initialization, but not evidence for eleven
additional likelihood basins. The 22 maximum-bracket cells retain genuine
endpoint-side competition on the observed profile; their lower endpoint is
descriptively better, but the finite grid is not a global certificate.

## Coordinate-only identifiability lane

The ten-cell plan contains 130 distinct cell/`rho` points and 260 fits.
Results:

- 260/260 fits are eligible;
- all 130 points have two eligible routes;
- all 10/10 cells coalesce to the same fixed-`rho` nuisance solution;
- all 10/10 show a negative-to-positive profile-minimum bracket;
- maximum q=61/91/121 objective range: `4.547473508864641e-13`;
- maximum nuisance gradient sup-norm: `9.716580e-05`;
- maximum scheduled analytic/numeric gradient difference: `1.825998e-08`;
- maximum two-route objective difference: `1.046260e-09`;
- maximum two-route nuisance-coordinate difference: `1.001996e-05`;
- maximum two-route natural-`rho` derivative difference:
  `2.507159e-06`;
- maximum P1k candidate-objective recovery difference: `4.270078e-10`;
- summed single-process optimization time: about `82.7` seconds.

The P1k coordinate-only discrepancies therefore do not identify two nuisance
basins. They are shallow-profile/stopping-tolerance differences around one
observed minimum. This lowers, but does not eliminate, concern about DFF, fit,
or rank changing solely because the two P1k starts reached different nuisance
solutions. Downstream decision invariance remains unauthorized because the
full ratio face, reflected fixtures, and source solution are still open.

## Interior comparison and decision

Every best observed continuation objective remains above the previously
qualified full-GPCM interior. Across the objective-discordant registry's
represented scenario/pair portfolio, the difference remains about
`2.113208`--`2.578278` objective units. This is consistent with earlier
boundary screens but is not a proof over unsampled `rho`, `mu`, or higher
faces.

The two completed scoped decisions are

```text
ObjectiveDiscordantFixedRhoContinuationCompleted = TRUE
CoordinateOnlyFixedRhoContinuationCompleted = TRUE
AllObservedContinuationMinimaAboveInterior = TRUE
FiniteGridOnly = TRUE
ContinuousBarrierCertified = FALSE
ReflectedFixturesEvaluated = FALSE
FullFourFixtureRatioProfilesCompleted = FALSE
CoefficientRatioProfilesCompleted = FALSE
AllSixTwoTargetFacesGloballyCertified = FALSE
ThreeTargetFacesEvaluated = FALSE
EmptyRandomProductHierarchyComplete = FALSE
GlobalJointBoundaryProfileCertified = FALSE
HessianAuthorized = FALSE
DFFFitRankAuthorized = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

The efficient next gate is not a denser rectangular grid. It is a compact
one-dimensional profiled-`rho` certificate for the three observed mechanism
classes, including explicit endpoint comparison and turning-point bracketing.
Only after that contract is stable should it be transported to the reflected
fixtures. Three-target faces, Hessian inference, DFF/fit/rank confirmation,
and broad simulation remain downstream.

## Reproduction

Runner:

```text
inst/validation/gpcm-fixed-rho-basin-continuation-p1l-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-fixed-rho-basin-continuation-p1l.R
```

Frozen SHA-256 values:

- runner: `8c2feb1938d9055e17c796b1d85632235bbeaf875145dc94b7adfe465abba318`;
- test: `aa354b4cfd9ed5de96012b944f3fa3c907336bd5969b891f8f3e06bbd5810733`.

The focused suite freezes the P1k dependency and base grid, distinguishes
profile maximum/minimum brackets across a zero-sign band, checks scoped
fail-closed decisions, and preserves the no-global-certificate language. The
chained P0--P1l execution remains opt-in through
`MFRMR_RUN_P1L_PILOT=true`; it is not added to routine long-validation runs.
