# Draft.83d2b2b1g10 lme4 reference-coverage record

Status: completed repository-only nonreserved replay, 2026-08-10. Calibration
201--300 and confirmation 501--700 were not generated, read, summarized, or
used to choose a rule.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| upstream b1g9 contract | `20d6fb656ac2f2996e5881a07729a3e4fb2f417859f90efde7ee72784ba62092` |
| b1g10 analytic audit | `ec331fe2856fb42014c3bf1939079c90f195f2cfb9dcbcb195af55cc96599c0a` |
| b1g10 policy | `9e0031e200739c66bf2510c56068bbf4f3e1f9075669167becced7ec7f158a82` |
| b1g10 contract | `419fbf43fd1b86ab494aa96224916c0bfa9c1e1ef2668f8877d9d39659bcc7e0` |
| b1g10 manifest | `f26d4a2fe5670d9b9395f97669f0ef368f9c5067580394ff5b20acccf5e8580b` |
| b1g10 execution | `b84c1d53f8653bb5329a0a165e2249b36e5d12e10c26099ab15cbdfac4281e8a` |

The retained primary receipt is
`/private/tmp/mfrmr-gtwad-lme4-reference-replay-v4.rds`; the exact repeat is
`/private/tmp/mfrmr-gtwad-lme4-reference-replay-v5.rds`. These are local
validation caches, not package or release artifacts.

## Fail-closed development sequence

The first authorized nonreserved attempt returned all eight fits and passed
all solver-consensus checks, but only three derivative-agreement, six
numerical-KKT, and one complete profile gate. It remained false-ready. The
failure was traced to comparing two closure-based finite-difference gradients
and to omitting the already prespecified curvature-scaled first-order state.

No observed cutoff was enlarged. The correction instead added an independent
sparse implementation of the b1g9 analytic objective/gradient and restored
the separation of raw and Newton-scaled stationarity. A second replay passed
the numerical gates but retained raw-gradient failures. Analytic-gradient
Newton polishing was therefore added. On the diagnostic 901-ML full
objective, one analytic Newton step reduced the maximum gradient from
`3.20e-5` to `1.18e-11` while reducing the analytic objective by about
`4.55e-12`, consistent with the Newton prediction.

The final v3 contract requires raw KKT as well as the curvature-scaled state;
the preliminary receipts are not promoted.

## Final objective result

| Replicate | Method | Role | objective | maximum analytic gradient |
| ---: | --- | --- | ---: | ---: |
| 901 | lme4 ML | full | 4500.430452 | 1.18e-11 |
| 901 | lme4 ML | reduced | 4502.710288 | 2.06e-11 |
| 901 | lme4 REML | full | 4500.843333 | 8.03e-11 |
| 901 | lme4 REML | reduced | 4503.208311 | 3.96e-11 |
| 902 | lme4 ML | full | 4422.013266 | 8.21e-12 |
| 902 | lme4 ML | reduced | 4424.085295 | 3.83e-11 |
| 902 | lme4 REML | full | 4423.745195 | 2.39e-11 |
| 902 | lme4 REML | reduced | 4426.173277 | 5.02e-11 |

All eight objectives pass three-algorithm consensus, independent sparse
objective and gradient agreement, adaptive-difference agreement, raw KKT,
Newton decrement, positive-definite free curvature, and sidecar integrity.
Sparse-oracle versus closure objective differences are at most `7.28e-12`.

## Boundary profiles

All four seven-point full-model profiles are monotone upward toward theta zero
and support finite interiors. Their objective sequences are:

- 901 ML: 4500.430452, 4500.663888, 4501.429909, 4502.338582,
  4502.649222, 4502.706456, 4502.710288;
- 901 REML: 4500.843333, 4501.073599, 4501.854124, 4502.811605,
  4503.143050, 4503.204216, 4503.208311;
- 902 ML: 4422.013266, 4422.248010, 4422.969383, 4423.767686,
  4424.033301, 4424.082034, 4424.085295; and
- 902 REML: 4423.745195, 4423.978676, 4424.776511, 4425.763576,
  4426.105895, 4426.169048, 4426.173277.

Every nuisance fit passes consensus, numerical KKT, Newton decrement, and
positive curvature. Exact-zero endpoints differ from the separate reduced
objectives by at most `2.27e-11`. The finite-interior labels follow the
observed lme4 profiles and do not reinterpret the 901 generating zero as a
positive-variance recovery result.

## Repeatability and gate interpretation

The complete final replay was run twice. Atomic rows, sidecar hashes, and
execution hash reproduced exactly. Nine focused tests with 137 expectations
pass, including dense/sparse reduction, analytic active/even/escape boundary
fixtures, raw versus curvature-scaled KKT separation, manifest mutation,
profiles, retained replay, and exact identities.

`Lme4MLReferenceMechanicsReady=TRUE`,
`Lme4REMLReferenceMechanicsReady=TRUE`, and
`ReferenceMethodCoverageComplete=TRUE` close the four prespecified
nonreserved reference lanes. They do not select lme4 over glmmTMB or ML over
REML and do not establish estimator operating characteristics.

`CalibrationAuthorizationReady`, `CalibrationExecutionAuthorized`,
`StationarityCriterionReady`, confirmation, inference, coefficient, and
D-study readiness remain false. The next admissible work is to freeze the
truth-blind acceptance/indeterminate policy, production boundary probe, and
exact-resume runner before reconsidering immutable authorization of replicate
201.
