# GPCM reflected finite-grid registry P1o record (0.2.3)

## Purpose

P1o applies the exact P1n map to the complete stored P1k/P1l finite-grid
portfolio. It performs no optimization. The source high-side portfolio has
168 cells: 125 P1k route-agreeing cells and 43 P1l continuation cells. The
latter comprise 33 objective-discordant and ten coordinate-only cells.

The point-level identity audit covers all stored evidence:

| Layer | Stored high-side points |
| --- | ---: |
| P1k two-route fits | 336 |
| P1l objective-discordant continuation | 766 |
| P1l coordinate-only continuation | 260 |
| Total | 1,362 |

Each stored nuisance vector is reflected, then the low-fixture marginal
objective and analytic gradient are evaluated at the transported point. This
is an identity check, not a refit or a new solution search.

## Results

All 1,362 point identities pass:

- maximum marginal-objective difference: `3.410605e-13`;
- maximum transported-gradient difference, including `mu` and `rho`:
  `8.899548e-13`;
- fallback reflected fits required: zero.

The resulting cell registry contains 84 cells for each of
`EXT5-P-HI`, `EXT5-P-LO`, `EXT5-P-NEAR-HI`, and `EXT5-P-NEAR-LO`, for 336
four-fixture finite-grid cells. The 168 high-side classifications are:

| Finite-grid class | Cells |
| --- | ---: |
| P1k routes agree within tolerance | 125 |
| P1l profiled maximum bracket | 22 |
| P1l profiled minimum bracket | 16 |
| P1l monotone-increasing grid | 5 |

Every classification and stored point is transported to its corresponding
low fixture. This completes a finite-grid registry; it does not exclude an
unsampled turn between `rho` points or establish a global lower bound on a
two-target face.

## Decision

```text
SourceStoredPointCount = 1362
SourceHighCellCount = 168
ReflectedLowCellCount = 168
FourFixtureFiniteGridCellCount = 336
P1kAgreeingHighCellCount = 125
P1lContinuationHighCellCount = 43
AllStoredPointReflectionIdentitiesVerified = TRUE
AllHighFiniteGridCellsClassified = TRUE
AllReflectedFiniteGridCellsTransported = TRUE
FullFourFixtureFiniteGridRegistryCompleted = TRUE
RefitFallbackRequired = FALSE
ReflectedFiniteGridFixturesEvaluated = TRUE
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

The narrow `ReflectedFiniteGridFixturesEvaluated` flag is true. The broader
`ReflectedFixturesEvaluated` and ratio-profile flags remain false because a
finite registry is not a continuous profile theorem. This distinction avoids
turning numerical completeness into mathematical overclaiming.

The next question is no longer whether to duplicate high/low fitting. It is
whether continuous certification is necessary for the 0.2.3 claim portfolio,
or whether the finite-grid evidence should remain explicitly bounded while
work moves to a different open structural gate. That decision should precede
three-target enumeration or simulation.

## Reproduction

- runner: `inst/validation/gpcm-reflected-finite-grid-registry-p1o-0.2.3.R`;
- test: `tests/testthat/test-gpcm-reflected-finite-grid-registry-p1o.R`;
- runner SHA-256:
  `d65d94c6e8ac2df8a94091dfcf849d556e6a9736e3798bb70f6ccbaa42342e57`;
- test SHA-256:
  `a4cce0e4c3dcbf2777726109ba9c68376bed1cc0362ef8e9ec12862c51c17866`.

Routine tests freeze the dependency and decision separation. The 1,362-point
stored-result audit is opt-in through `MFRMR_RUN_P1O_PILOT=true` and
`MFRMR_P1N_RESULT=<path>`.
