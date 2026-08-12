# GPCM C4 face-to-deterministic-Rater P1g record (0.2.3)

## Scope

P1g follows the free C4 coefficient exposed by P1f. It distinguishes a finite
stationary C4-face solution from apparent convergence caused by
`log(lambda_C4)` becoming very negative. The declared coefficient is

```text
lambda = a_C4 * population SD.
```

This is a bounded C4-face grid and direct-endpoint audit.
It is not a global C4-face certificate. It does not evaluate the other 13
nonempty random-target faces or complete the empty-random-product hierarchy.

Frozen status remains:

- `FullC4FaceGloballyCertified = FALSE`;
- `OtherRandomTargetFacesEvaluated = FALSE`;
- `EmptyRandomProductHierarchyComplete = FALSE`;
- `SelectionAuthorized = FALSE`;
- `ConfirmationAuthorized = FALSE`.

## Why the free-log-coefficient optimizer is insufficient

Starting from the P1e/P1f C4 coordinates and freeing `log(lambda)` sent all
four preliminary fits toward the lower boundary:

```text
lambda range = 2.34e-6 to 2.82e-5.
```

Those fits passed the existing absolute optimizer-gradient rule because

```text
d objective / d log(lambda)
  = lambda * d objective / d lambda
```

vanishes mechanically as `lambda -> 0`, even when the natural `lambda`
derivative is not small away from the endpoint. A pass in the unscaled log
coordinate therefore cannot by itself distinguish a finite optimum from this
boundary.

## Exact scaled coordinates

On the P1f C4 face the target-category numerator is

```text
lambda [k (u_4 - q_r + z) - H_4k].
```

P1g defines

```text
B_r = lambda q_r,
V_4 = lambda u_4,
G_4k = lambda H_4k.
```

For every `lambda > 0`, this is an exact full-rank coordinate change. The C4
numerator becomes

```text
k (V_4 - B_r + lambda z) - G_4k.
```

Non-target canonical coordinates remain unchanged. Unlike the free-log-
coefficient form, all 20 nuisance coordinates remain finite when
`lambda -> 0`.

The exact P1f-to-P1g conversion was checked for both P1e routes in all four
scenarios:

- maximum coordinate round-trip difference: `1.3877787807814457e-17`;
- maximum P1f/P1g objective difference: `0` at the tested vectors;
- maximum analytic/numeric scaled-gradient difference:
  `1.7027936142180279e-07`.

## Direct deterministic-Rater endpoint

At `lambda = 0`, latent-node variation disappears but C4 retains the finite
Rater term `B_r`:

```text
k (V_4 - B_r) - G_4k.
```

C1--C3 remain deterministic without Rater terms on this stratum. P1g
implements this endpoint both through the node-integrated formula and through
an independent observationwise conditional-GPCM oracle. Their maximum
objective difference across the eight fitted endpoints is
`1.9326762412674725e-12`. The analytic `lambda` derivatives at the endpoints
are within `5.89e-15` of zero, as required by the centered symmetric latent
distribution.

The two routes give the following endpoint objectives; their differences are
below the displayed precision.

| Scenario pair | Endpoint objective | Qualified interior objective | Endpoint minus interior |
| --- | ---: | ---: | ---: |
| exact Person endpoints | `641.7457379651` | `639.1674599777` | `2.5782779874` |
| near Person endpoints | `641.8967156239` | `639.8191482020` | `2.0775674218` |

The deterministic-Rater C4 endpoint is therefore worse than the qualified
interior candidate in every declared scenario. This comparison is local to
this stratum and does not select the interior package solution.

## Fixed-lambda profile

The prespecified grid is

```text
lambda = 0, 0.001, 0.003, 0.01, 0.03, 0.1, 0.2.
```

One route starts at `0.2` from the P1e forward solution and descends; the other
starts at the direct endpoint from the P1e reverse solution and ascends. All
56/56 scaled nuisance fits are eligible. Every fixed vector is reevaluated at
q=61/91/121.

- maximum route objective difference: `5.7582383305998519e-10`;
- maximum q=61/91/121 objective range: `4.5474735088646412e-13`;
- maximum scheduled analytic/numeric profile-gradient difference:
  `2.0566778287507465e-07`.

Both routes are monotonically nondecreasing from `lambda = 0` on the declared
grid. All positive-grid natural `lambda` derivatives are positive. For the
forward route they range from about `0.1135` at `lambda=0.001` to `18.14` or
`19.77` at `lambda=0.2` in the exact and near fixtures, respectively. The
profile therefore supports descent toward the deterministic-Rater endpoint,
not a finite stationary solution on the observed grid.

The endpoint and `lambda=0.2` fits receive independent finite-difference
checks. All intermediate grid points retain analytic score and optimizer
diagnostics but do not multiply derivative checks merely to increase a test
count.

## Decision

All four scenarios receive

```text
declared_c4_face_grid_descends_to_stationary_deterministic_rater_limit_above_interior
```

This supports the following bounded conclusions:

1. P1f and P1g are exactly identical for positive `lambda` after coordinate
   conversion.
2. The P1e fixed coefficient is on a descending C4-face direction.
3. The declared two-route grid continues to improve toward `lambda=0`.
4. The direct C4 deterministic-Rater endpoint is stationary in the scaled
   nuisance coordinates, matches the independent conditional oracle, and
   remains 2.08--2.58 objective units above the qualified interior.

It does not support the following broader conclusions:

- a finite grid cannot exclude an unobserved C4-face interior basin;
- the other single-target and multiple-target random faces are not evaluated;
- only the C4 maximal-slope deterministic-Rater stratum of the empty-target
  hierarchy is evaluated;
- the upper/joint variance boundary and source-selection contract remain
  open; and
- Hessian, intervals, DFF, fit, rank, separation, and broad simulation remain
  downstream.

The next efficient gate is to reuse the same scaled construction for the
remaining three single-random-target faces and their corresponding
deterministic-Rater endpoints. This is more informative than densifying the C4
grid. Multiple-target faces should follow only after those single-target
screens are complete.

## Reproduction

Runner:

```text
inst/validation/gpcm-c4-face-to-deterministic-rater-p1g-0.2.3.R
```

Test:

```text
tests/testthat/test-gpcm-c4-face-to-deterministic-rater-p1g.R
```

Frozen SHA-256 values:

- runner:
  `210bba683ab154d9684db9bb2fab67b7f56d8478cf950e0de742db2563f239f3`;
- test:
  `6f57c0bd18b8b0e86b21e5a0e6152c38bc1651bd5f1c4652dddc810cb749592b`.

The focused lightweight suite reports 49 passed expectations and one
intentional dependency-complete skip. With
`NOT_CRAN=true MFRMR_RUN_LONG_VALIDATION=true`, the complete suite rebuilds
the P0--P1f dependency chain and reports 63 passed expectations with no
failure, error, warning, or skip. Documentation terminology, first-use
readiness, readiness propagation, release readiness, and results readiness
regression tests also pass; the first-use suite emits its prespecified sparse-
category review warning. Runtime is descriptive and does not enter any
statistical decision.
