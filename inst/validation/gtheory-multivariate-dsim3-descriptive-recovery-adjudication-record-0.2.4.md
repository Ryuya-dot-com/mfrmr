# D-SIM-3 Descriptive Recovery Adjudication Record (0.2.4)

Date: 2026-08-31
Scope: repository-internal, read-only analysis of immutable exploratory evidence
Disposition: `bounded_exploratory_descriptive_recovery_complete_nonconfirmatory`

## Frozen identity

- Contract: `MFRMR-GTHEORY-MV-DSIM3-DESCRIPTIVE-RECOVERY-V1`
- Contract hash: `e274e2a73934a94578b79af347b5643724c56b99490791b693cb2cc12edd98c5`
- Manifest hash: `ad97f0f48f382bd41c6353dab6ce1405453b6146ce3fd4dfbb4ea04406fb8f8f`
- Parent bounded-launch manifest:
  `84b89383d974f7a3a40df738b0ce618f86324d3b1ea54ea99ea2ed20a4019aea`
- Parent superseding plan:
  `58555b19309c20a3fe087065c21319f9567b36162e818fea37044e2461a0cb1a`
- Parent coverage manifest:
  `4c6958f00aac7598d777387ec113cd43474031430492e83e6183d19dcedf7197`
- Parent direct truth-metric manifest:
  `969afca1d3fb23a68d58500cd6959152b385b0e9b2e64c25cc75a3cd79feb37c`
- Source SHA-256:
  `9449e1fa9cbc65316d55bec7470964b8b0f6a4f7f9cb78e3ab9aba5398d416f8`
- Runner SHA-256:
  `74a0517aeb4033174d60e9233dd30d96e1517830a826cf4f01e0db0b810158db`
- Local manifest-RDS SHA-256:
  `4af81f367c3d4eebad89e85f60fd0f3a951eafbfdd85042e8de773894e66cb09`

The analysis verifies exact hashes for `launch-input.rds`,
`launch-result.rds`, and `run-complete.rds` before reading them. It performs no
response generation, backend call, refit, replacement-seed use, failure
exclusion, or route voting.

## Denominator and reference boundary

- All 420 route-estimand coordinates remain present: 82 completed coordinates
  have a directly qualified truth comparison, two are the preserved metric
  failure, 16 belong to the eight restricted multivariate routes and receive
  only a scenario-reference/within-backend parity description, and 320 are
  frozen no-call coordinates.
- The direct truth contract applies to 42 separate-univariate routes and 84
  route-estimand metric requests. Across their 94 planned route-stratum fits
  and two estimands, the scalar denominator is 188.
- Direct truth comparisons are available for 184/188 scalar values. The four
  unavailable values are both strata and both estimands of the already
  recorded `D3-S012` replicate-2 metric failure; none is dropped.
- The eight multivariate routes form 40 within-backend scalar parity
  comparisons with their shared-dataset separate-univariate route. These are
  not an independent reference and cannot establish reference validation.

## Descriptive G/Phi recovery

| Estimand | Available / planned | Mean error | MAE | RMSE | Median absolute error | Maximum absolute error |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `ABS-PHI` | 92 / 94 | -0.004780 | 0.028356 | 0.052406 | 0.014076 | 0.324044 |
| `REL-G` | 92 / 94 | -0.004462 | 0.023460 | 0.050089 | 0.010976 | 0.324044 |

These are raw coefficient-scale descriptions. With only two exploratory
replicates per scenario, no standardized-bias threshold, Monte Carlo standard
error, interval-coverage rule, or acceptance criterion is evaluated.

The three largest profile-level RMSEs are all prespecified boundary cells:

- `D3-S010`: RMSE 0.162177 for both estimands, maximum absolute error
  0.324044. This is a two-stratum, nested, severely unbalanced,
  one-repeat ordinal-aggregate cell with negative-PSD cross-stratum
  covariance.
- `D3-S005`: `REL-G` RMSE 0.109908 and `ABS-PHI` RMSE 0.096885. This is a
  three-stratum, severely unbalanced, structurally missing,
  near-singular-covariance ordinal-aggregate cell.
- `D3-S019`: `ABS-PHI` RMSE 0.096235 and `REL-G` RMSE 0.072154. This is a
  partially shared, moderately unbalanced, near-singular-covariance,
  heavy-tailed cell.

No boundary cell is excluded. By frozen scenario role, the 18 boundary cells
have RMSE 0.054789 (`ABS-PHI`) and 0.052824 (`REL-G`), with 82/84 scalar
values available per estimand. The full anchor has RMSE 0.033364 and 0.014113;
the closure cell 0.029360 and 0.019695; and the targeted structural cell
0.009291 and 0.010447, respectively. These role summaries are descriptive,
not confirmation strata selected for favorable results.

## Diagnostics and within-backend parity

For scalar values attached to fits without a singular or convergence message,
RMSE is 0.049008 (`ABS-PHI`) and 0.044915 (`REL-G`). For values attached to
fits with either diagnostic, RMSE is 0.060176 and 0.061290; 26/28 values per
estimand are available because the metric-failure route remains in this group.
This grouping is noncausal and no diagnostic group is excluded.

Within-backend multivariate-versus-separate parity is available for 40/40
scalar pairs. Only 1/20 pairs per estimand is within the descriptive 1e-6
tolerance. Mean absolute difference is 0.006314 (`ABS-PHI`) and 0.006190
(`REL-G`); maximum absolute difference is 0.029185 for both. Because the two
routes share data, backend, and much implementation, this does not count as an
independent-reference failure or success. It does show that the routes must not
be treated as numerically interchangeable.

## Adjudication

Descriptive recovery evidence is now computed, and every failure and
coordinate denominator is preserved. The evidence does **not** establish a
standardized-bias pass, interval coverage, independent-reference parity,
simulation validation, confirmation readiness, or public support. Feature
maturity remains `specified`.

D-SIM-4 is not automatically admitted. The next decision is whether the
scientific value of confirming the observed regular/boundary behavior warrants
a separate study. If it does, D-SIM-4 must freeze its scenario roles,
replication and MCSE rules, independent-reference overlap, source identity,
and new seeds before any confirmation response is generated. The exploratory
metric failure and large boundary errors must remain visible when that
decision is made.
