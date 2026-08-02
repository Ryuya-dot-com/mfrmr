# mfrmr 0.2.3 TAM dimensionality pilot record

## Record state

| Field | Value |
| --- | --- |
| Evidence role | Pilot development evidence |
| Specification | `0.2.3-draft.6` |
| Contract | `mfrmr_tam_dimensionality_pilot_v1` |
| Run date | 2026-07-27 |
| Source identity | Commit `10cf3e8e8ff07f3ce1021ae28310ffcbd99d058c` plus uncommitted working-tree changes |
| Runtime | R 4.6.1; aarch64-apple-darwin23; TAM 4.3-25 |
| Fits | 32 registered matrix fits, 8 deterministic-QMC repeat-audit fits, and 16 stochastic-integration seed-audit fits |
| Hard failures | 0 |
| Warnings | 0 |
| Confirmation authorized | No |
| Model selection authorized | No |
| Status | `review` |

This is the first dimension-aware repository runner. It tests whether the
planned evidence machinery preserves prespecified Q matrices, distinguishes
one- and two-dimensional TAM objects, records integration drift, and fails
closed before a dimensionality or subscore conclusion. It is not release
evidence and does not add native multidimensional estimation to `mfrmr`.

## Registered synthetic controls

Both controls used 240 Persons, 12 binary Rasch items, six indicators per
prespecified dimension, fresh TAM default starts at every refit, the TAM
`cases` constraint, `maxiter = 1000`, `convD = 1e-4`, and `conv = 1e-4`.

| Scenario | Truth | Seed | Target correlation | Realized latent correlation | Response SHA-256 |
| --- | --- | ---: | ---: | ---: | --- |
| `DIM-SYN-TRUE-1D` | one dimension | 20260727 | 1.00 | 1.0000000 | `a80017866c8be66ef8663eb3165ede6bd07ad89c2f0bb90c2ea671693c67bbb5` |
| `DIM-SYN-TRUE-2D` | two dimensions | 20260728 | 0.45 | 0.3515455 | `7e618076a1f3e918a58b3d017c9472bc09b5b625061ac014bbe312fbbcc9548f` |

The one-dimensional Q hash was
`0a836af2dd98176e9c8f4f0b61089c547de15754f887a9f76c670be0c40079fd`;
the prespecified two-dimensional simple-structure Q hash was
`4669be6ccbd35dc98f47993ad3935998b0e359f2b5fede6ff1d07b081011f36b`.
The runner rejects cross-loading or empty-dimension Q matrices and never
derives this synthetic Q from the fitted responses.

## Integration design

The registered product-quadrature ladder used 15, 21, 31, and 41 nodes per
dimension over `[-6, 6]`. The deterministic QMC ladder used 512, 1024, 2048,
and 4096 `snodes`. `QMC = TRUE` is nonstochastic in TAM, so no operative seed
is recorded for the integration itself. The response generator seed remains
fixed and separate.

A preliminary calibration probe showed that very coarse two-dimensional
product grids can even return an impossible positive observed log likelihood
and negative deviance. The registered runner therefore checks the binary
observed-log-likelihood range explicitly. The 15-point row remains in the
registered matrix as a coarse challenge rather than being hidden after the
probe. No observed result below was used to authorize a threshold.

## Within-TAM 1D versus prespecified 2D results

Positive deviance gain means lower deviance for the 2D model. Negative
2D-minus-1D IC gaps mean the 2D model has the lower criterion. These are raw
pilot stability diagnostics; the normalizer keeps `ComparisonReady = FALSE`
and the runner emits no preferred-model label, IC weight, or regular LRT
p-value.

| Scenario | Integration | Deviance gain | Gain / Person | Gain / response | AIC gap | BIC gap | SABIC gap | Estimated dimension correlation |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| true 1D | product 15 | 65.265903 | 0.271941 | 0.022662 | -61.265903 | -54.304625 | -60.644135 | 0.976961 |
| true 1D | product 21 | 3.252981 | 0.013554 | 0.001130 | 0.747019 | 7.708297 | 1.368786 | 0.832609 |
| true 1D | product 31 | 3.252880 | 0.013554 | 0.001129 | 0.747120 | 7.708398 | 1.368888 | 0.832580 |
| true 1D | product 41 | 3.252880 | 0.013554 | 0.001129 | 0.747120 | 7.708398 | 1.368888 | 0.832580 |
| true 1D | QMC 512 | 3.102812 | 0.012928 | 0.001077 | 0.897188 | 7.858466 | 1.518956 | 0.810196 |
| true 1D | QMC 1024 | 3.194790 | 0.013312 | 0.001109 | 0.805210 | 7.766488 | 1.426978 | 0.836538 |
| true 1D | QMC 2048 | 3.258848 | 0.013579 | 0.001132 | 0.741152 | 7.702430 | 1.362920 | 0.823248 |
| true 1D | QMC 4096 | 3.233024 | 0.013471 | 0.001123 | 0.766976 | 7.728253 | 1.388743 | 0.829529 |
| true 2D | product 15 | 21.411086 | 0.089213 | 0.007434 | -17.411086 | -10.449808 | -16.789318 | 0.561411 |
| true 2D | product 21 | 21.385482 | 0.089106 | 0.007426 | -17.385482 | -10.424204 | -16.763714 | 0.561337 |
| true 2D | product 31 | 21.385405 | 0.089106 | 0.007425 | -17.385405 | -10.424127 | -16.763637 | 0.561337 |
| true 2D | product 41 | 21.385400 | 0.089106 | 0.007425 | -17.385400 | -10.424123 | -16.763633 | 0.561337 |
| true 2D | QMC 512 | 21.151578 | 0.088132 | 0.007344 | -17.151578 | -10.190300 | -16.529810 | 0.554066 |
| true 2D | QMC 1024 | 21.296189 | 0.088734 | 0.007395 | -17.296189 | -10.334911 | -16.674421 | 0.557951 |
| true 2D | QMC 2048 | 21.315692 | 0.088815 | 0.007401 | -17.315692 | -10.354414 | -16.693924 | 0.558158 |
| true 2D | QMC 4096 | 21.339710 | 0.088915 | 0.007410 | -17.339710 | -10.378433 | -16.717943 | 0.558882 |

The true-1D 15-point product row reverses AIC, BIC, and SABIC relative to the
21--41 point rows. Its maximum criterion-gap drift from the 41-point reference
is 62.013024. Over 21--41 points, the maximum true-1D gap drift is only
0.000102. The true-2D product ladder retains all signs, with maximum full-
ladder gap drift 0.025685.

The deterministic-QMC ladders retain all criterion signs, but maximum gap
drift is 0.130212 in the true-1D control and 0.188133 in the true-2D control.
At the densest registered settings, QMC-minus-product deviance-gain differences
are -0.019855 and -0.045690, respectively. These values show why one QMC node
count cannot be treated as exact evidence; they do not freeze an acceptable
drift tolerance.

## Convergence and QMC replay

All 32 matrix fits had finite, internally consistent fit/IC objectives,
preserved all Persons and items, stopped before the iteration ceiling, and
retained a positive-definite latent covariance. Ten fits remained `review`
because TAM's final reported objective differed from the last value stored in
its iteration history; the runner preserves that distinction instead of
calling the fit objective inconsistent. No warning was suppressed from the
record.

At 1024 QMC nodes, two fresh independent refits were run for each model in
each synthetic control. Across all eight fits, both maximum absolute deviance
repeat difference and maximum absolute retained-parameter repeat difference
were exactly zero. This supports TAM 4.3-25's deterministic-QMC behavior for
these cells and attributes the ladder drift to the finite `snodes`
approximation rather than run-to-run random variation. Stochastic
`QMC = FALSE` is a separate integration contract.

## Stochastic integration seed audit

At `snodes = 1024` with `QMC = FALSE`, the runner repeated both models under
seeds 20260731--20260734. Every integration-evaluation identity includes its
operative seed. All 16 fits avoided hard failure and warnings, while remaining
`review`; no seed was promoted or selected after seeing its result.

| Scenario | Model | Maximum deviance seed difference | Maximum retained-parameter seed difference |
| --- | --- | ---: | ---: |
| true 1D | TAM 1D | 1.116919 | 0.032746 |
| true 1D | TAM 2D | 3.556406 | 0.283019 |
| true 2D | TAM 1D | 0.610052 | 0.015291 |
| true 2D | TAM 2D | 2.327426 | 0.213592 |

The maximum stochastic 2D-versus-1D gap difference was 3.965763 in the
true-1D control and 2.865980 in the true-2D control. True-1D deviance gain
ranged from -0.734788 to 3.230975, so even its sign changed, although AIC,
BIC, and SABIC signs remained stable at these four seeds. All four true-2D
deviance and IC signs remained stable. This seed sensitivity is much larger
than the deterministic-QMC same-node replay difference of zero and confirms
that one `QMC = FALSE` run cannot be treated as release evidence.

## What this pilot does and does not support

- It supports the repository runner's ability to retain dimension-aware TAM
  evidence while public `import_tam_fit()` rejects `ndim > 1`.
- It demonstrates one false-selection stress at coarse product integration and
  one successful true-2D sensitivity cell.
- It does not estimate a false-selection rate or power: each truth currently
  has only one seed.
- It does not establish an ordinary chi-square LRT reference. That output is
  deliberately absent because the 1D null can lie on a variance/correlation
  boundary.
- It does not implement the required parametric bootstrap, empirical
  discovery/confirmation split, PCAR/Q3-style hypothesis manifest,
  rater-by-criterion attribution grid, or score-consequence test.
- It does not establish mfrmr-versus-TAM one-dimensional likelihood equality.
  Cross-engine IC and LRT conclusions remain unauthorized.

## Unresolved before freeze

1. Add replicated true-1D, moderate/high-correlation true-2D, weak-dimension,
   large-N, and deliberately confounded rater-by-criterion cells; choose
   replication counts from Monte Carlo uncertainty targets.
2. Extend the first four-seed `QMC = FALSE` audit across node counts and
   required platforms, define its seed-aggregation/failure policy, and review
   TAM convergence; then freeze a TAM-specific integration ladder and
   `IC-INTEGRATION-TOL` before confirmation.
3. Implement the boundary-aware parametric-bootstrap protocol, including
   singular and failed-replicate handling, without using an ordinary
   chi-square p-value as the blocker.
4. Version empirical PCAR/Q3-style hypotheses and keep discovery Persons
   separate from confirmation Persons or label the result same-sample
   sensitivity.
5. Establish matched mfrmr-versus-TAM 1D observation likelihood, constants,
   constraints, and integration evaluation before any cross-engine common-IC
   comparison.
6. Add the four-model interaction/dimensionality attribution grid and the
   separate score-consequence classification. No dimension-specific score is
   part of 0.2.3.
