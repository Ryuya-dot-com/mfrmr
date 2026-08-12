# GPCM remaining single-target face P1h record (0.2.3)

## Scope

P1h applies the P1g exact coefficient-scaled construction to C1, C2, and C3.
The completed C4 result is consumed as frozen P1g evidence rather than fitted
again. Together, P1g and P1h screen all four single-random-target grids and all
four singleton deterministic-Rater endpoints.

This is not a multiple-target or global joint-boundary certificate. Frozen
status remains:

- `MultipleRandomTargetFacesEvaluated = FALSE`;
- `MultiCriterionDeterministicRaterStrataEvaluated = FALSE`;
- `EmptyRandomProductHierarchyComplete = FALSE`;
- `GlobalJointBoundaryProfileCertified = FALSE`;
- `SelectionAuthorized = FALSE`;
- `ConfirmationAuthorized = FALSE`.

## Common scale and starts

For each target `t` in C1--C3, P1h uses

```text
B_r = lambda_t q_r,
V_t = lambda_t u_t,
G_tk = lambda_t H_tk,
lambda_t = a_t * population SD.
```

The qualified-interior `lambda_t` values lie between about `0.163` and
`0.174`; all are inside the P1g grid

```text
0, 0.001, 0.003, 0.01, 0.03, 0.1, 0.2.
```

The descending route starts from slope-weighted qualified-interior locations,
steps, and target-Rater coordinates. The reverse route starts at `lambda=0`
from the previously optimized C4 endpoint and ascends. These routes differ in
both their starting boundary and traversal direction.

For positive `lambda_t`, exact conversion to the P1f canonical single-target
likelihood gives:

- maximum scaled-coordinate round-trip difference:
  `2.7755575615628914e-17`;
- maximum coefficient round-trip difference:
  `2.7755575615628914e-17`;
- maximum P1f/P1h objective difference:
  `2.2737367544323206e-13`;
- maximum analytic/numeric identity-gradient difference:
  `1.6799495616837135e-07`.

## C1--C3 profile execution

The design contains

```text
4 scenarios * 3 targets * 2 routes * 7 lambda values = 168 fits.
```

All 168/168 scaled nuisance fits are eligible. Every returned vector is
reevaluated at q=61/91/121. Independent finite-difference checks are reserved
for `lambda=0` and `lambda=0.2` rather than repeated at every interior grid
point.

- maximum route objective difference: `1.2103100743843243e-09`;
- maximum q=61/91/121 objective range: `5.6843418860808015e-13`;
- maximum scheduled analytic/numeric profile-gradient difference:
  `2.2816964918265509e-07`.

All positive-grid natural-coefficient derivatives are positive, ranging from
about `0.1135` to `18.142`. All endpoint derivatives are within
`6.17e-15` of zero. Both routes are monotonically nondecreasing from
`lambda=0` for every scenario and target.

## Direct singleton deterministic-Rater endpoints

At `lambda_t=0`, criterion `t` retains its finite Rater term while all latent-
person variation vanishes. Each endpoint is independently compared with an
observationwise conditional-GPCM oracle. The maximum objective discrepancy is
`2.5011104298755527e-12`.

The endpoint results from the descending route are:

| Fixture | Targets | Endpoint objective | Qualified interior | Endpoint minus interior |
| --- | --- | ---: | ---: | ---: |
| exact Person endpoints | C1, C2, C3 | about `641.745737965` | `639.167459978` | about `2.578277987` |
| near Person endpoints | C1, C2, C3 | about `641.932358060` | `639.819148202` | about `2.113209858` |

The high/low route and reflection differences are below the displayed
precision. All C1--C3 singleton endpoints remain above their qualified
interior candidates. P1g's C4 endpoint is also above the interior, with the
smallest four-target portfolio difference equal to about `2.077567422`.

## Decision

All 12 scenario-by-new-target decisions receive

```text
single_target_grid_descends_to_deterministic_rater_limit_above_interior
```

Combining them with P1g establishes:

- `AllFourSingleTargetGridsScreened = TRUE`;
- `AllFourSingletonDeterministicRaterStrataScreened = TRUE`;
- `AnySingletonEndpointBelowQualifiedInterior = FALSE`.

This does not mean that the interior solution is selected. The finite grids do
not exclude unseen within-face basins, and the six two-target plus four three-
target random faces remain. In the no-random-product hierarchy, Rater effects
can also be retained jointly for two, three, or all four criteria; those 11
multi-criterion strata remain untested. The upper variance boundary and
source-selection contract are also open, so Hessian, intervals, DFF, fit,
rank, separation, and broad simulation remain downstream.

The next efficient gate is the six two-random-target faces together with their
two-criterion deterministic-Rater endpoints. Their results can determine
whether the four three-target vertices need full profiling or can be entered
from well-qualified boundary starts. No denser single-target grid is justified
by the present evidence.

## Reproduction

Runner:

```text
inst/validation/gpcm-single-target-face-screen-p1h-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-single-target-face-screen-p1h.R
```

Frozen SHA-256 values:

- runner:
  `860d70528718414c6f8d63f2f92410ed5269ec0319c44db44f97d66b5685524a`;
- test:
  `497d6c9d53e2c0dfc09948cb79487a6b73e478018a0819f301100f625cf8d183`.

The focused lightweight suite reports 42 passed expectations and one
intentional dependency-complete skip. With
`NOT_CRAN=true MFRMR_RUN_LONG_VALIDATION=true`, the complete suite rebuilds
the P0--P1g dependency chain and reports 62 passed expectations with no
failure, error, warning, or skip. Documentation terminology, first-use
readiness, readiness propagation, release readiness, and results readiness
regression tests also pass; the first-use suite emits its prespecified sparse-
category review warning. Runtime is descriptive and does not enter any
statistical decision.
