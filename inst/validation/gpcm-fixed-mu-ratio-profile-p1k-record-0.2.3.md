# GPCM fixed-mu ordered-ratio P1k pilot record (0.2.3)

## Scope

P1k is a bounded optimization pilot motivated by P1j's negative natural-ratio
derivatives. It fixes the slower coefficient `mu`, frees the ordered ratio
`rho` on the closed interval `[0,1]`, and jointly optimizes every nuisance
coordinate. The pilot covers the exact-high and near-high Person endpoint
fixtures only. Their reflected low fixtures are deliberately not inferred or
run in this stage.

For each of 12 ordered fast/slow directions and seven frozen `mu` values, P1k
uses two starts:

1. the eligible P1h/P1g singleton solution at `rho=0`;
2. a P1i-derived equal-coefficient-side start at `rho=1`.

This is a solution-stability pilot, not a completed coefficient-ratio profile
or two-target-face certificate.

## Boundary KKT contract

P1k minimizes the P1j objective with natural `rho`, not an unbounded log-ratio.
It requires ordinary stationarity for the nuisance coordinates and the
following constrained first-order condition:

```text
rho = 0:  d objective / d rho >= 0,
0 < rho < 1: d objective / d rho = 0,
rho = 1:  d objective / d rho <= 0.
```

The reported KKT sup-norm is the maximum of the nuisance gradient sup-norm and
the appropriate one-sided ratio violation. Optimizer convergence code zero is
required but is not sufficient by itself.

During the first execution, seven equal-side starts triggered the strict P1j
domain assertion because L-BFGS-B evaluated a machine-level negative `rho`
near its declared lower bound. P1k now clamps only its bounded optimizer
wrapper to `[0,1]`; P1j's mathematical likelihood domain remains strict. The
same seven cells then return finite, KKT-eligible solutions. This numerical
representation repair is separate from the multiple-basin result below.

## Prespecified representative execution

The design contains

```text
2 scenarios * 12 ordered directions * 7 mu values * 2 starts = 336 fits.
```

All 336/336 fits are eligible. Across them:

- maximum q=61/91/121 objective range:
  `5.6843418860808015e-13`;
- maximum KKT sup-norm:
  `9.711041e-05`;
- maximum scheduled analytic/numeric nuisance or interior full-gradient
  difference:
  `2.186307e-08`;
- summed single-process optimization time:
  about `210.6` seconds.

The fitted ratio locations are:

| KKT location | Fit count |
| --- | ---: |
| lower (`rho=0`) | 113 |
| interior | 188 |
| upper (`rho=1`) | 35 |

Thus the bounded coordinate and KKT machinery work across all three possible
solution types.

## Two-start stability result

Every one of the 168 fixed-`mu` cells has two eligible KKT solutions, but their
relationship is not uniform:

| Route class | Cells |
| --- | ---: |
| same objective and same `rho` | 125/168 |
| same objective, different `rho` | 10/168 |
| different objective, competing KKT solutions | 33/168 |
| route ineligible | 0/168 |

The maximum two-route objective difference is about `0.0667082`; the maximum
ratio difference is `1`. The 33 objective-discordant cells occur at small
`mu`: 17 at `mu=0`, 14 at `mu=0.001`, one at `mu=0.003`, and one at
`mu=0.01`. None occurs at `mu>=0.03`.

Most discordant cells connect a singleton-side lower solution with a distinct
upper or near-upper solution. Six connect two interior tolerance-eligible KKT
candidates. P1l subsequently shows that both routes coalesce at common fixed
`rho`; P1k therefore must not be read as establishing 33 distinct nuisance
basins. Its `1e-4` numerical KKT rule admits near-stationary points and requires
the profile-mechanism audit recorded in P1l. The ten same-objective but
coordinate-distinct cells likewise remain an identifiability question until
that audit, not an automatic DFF/fit/rank split.

## Observed comparison with the qualified interior

For each representative scenario and unordered target pair, the best objective
among the 28 observed eligible candidates remains above the previously
qualified full-GPCM interior:

| Fixture | Best observed minus interior range |
| --- | ---: |
| exact-high | `2.578242` to `2.578278` |
| near-high | `2.065439` to `2.113210` |

The best observed candidates coincide, to the recorded precision, with
previously observed P1h/P1g singleton-boundary objectives. This is useful
descriptive evidence but not a face certificate: competing KKT basins and
unseen paths remain.

## Decision and next gate

The recorded status is

```text
AllRepresentativeFitsEligible = TRUE
AllRepresentativeCellsHaveTwoEligibleRoutes = TRUE
SameSolutionCellCount = 125
SameObjectiveCoordinateDistinctCellCount = 10
CompetingKktSolutionCellCount = 33
AnyCompetingKktSolutions = TRUE
AllObservedRepresentativeMinimaAboveInterior = TRUE
RepresentativeFixedMuRatioProfilesCompleted = FALSE
ReflectedFixturesEvaluated = FALSE
FullFourFixtureRatioProfilesCompleted = FALSE
CoefficientRatioProfilesCompleted = FALSE
AllSixTwoTargetFacesGloballyCertified = FALSE
ThreeTargetFacesEvaluated = FALSE
EmptyRandomProductHierarchyComplete = FALSE
GlobalJointBoundaryProfileCertified = FALSE
SelectionAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

P1l completes the next fixed-`rho` nuisance-continuation gate for all 43
nonmatching representative cells. It finds one nuisance solution at each
common `rho`, 22 profile-maximum brackets, six profile-minimum brackets, five
monotone-increasing grids, and ten additional minimum brackets in the
coordinate-only lane. The next efficient gate is a compact continuous
one-dimensional certificate for those mechanisms, followed by reflected
transport. There remains no justification for opening three-target faces or
running broad simulations first.

Hessian inference, intervals, DFF, fit, rank, separation, source selection,
and capability promotion remain downstream. In particular, “all 336 fits
converged” is not an inference-ready statement when 33 cells retain competing
objective values.

## Reproduction

Runner:

```text
inst/validation/gpcm-fixed-mu-ratio-profile-p1k-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-fixed-mu-ratio-profile-p1k.R
```

Frozen SHA-256 values:

- runner:
  `7dba1c95c26ea2de644ff16f06a1c64480b77f2d47896b54d856c86358a9d1f8`;
- test:
  `687c750b291b075434877ecf1030f311d16dbf57419dcc99937573ac65c1d7b7`.

The focused suite tests the plan and dependency hash, lower/interior/upper KKT
signs, bound clamping, independent convex boundary controls, ordered-pair
overlap at `rho=1`, and fail-closed multiple-solution decisions. It reports 95
passed expectations and one intentional chained-pilot skip. The chained P0--
P1k execution remains separately opt-in through
`MFRMR_RUN_P1K_PILOT=true`; it is not added to ordinary long-validation runs.
