# Draft.83d2b2b1g8 glmmTMB ML reference-coverage record

Status: completed repository-only nonreserved replay, 2026-08-10. Calibration
201--300 and confirmation 501--700 were not generated, read, summarized, or
used to choose a rule.

## Frozen identities

| Identity | SHA-256 |
| --- | --- |
| b1g6 reference contract | `60e04706736c0e7273dfa321d0d41a3a9ed4bb8362a0b7d428f8507653ecce9a` |
| b1g6 reference manifest | `87b42667d3dbeb2ecd045b23b32cf23a5f9919b0d26ac75c5771baf691770d3a` |
| b1g6 reference execution | `28f155c91065cb56ebe695234eab7867392e25fe413ab362717e760f5e775e72` |
| b1g7 preauthorization audit | `b293987e768ec0e998d3224a6df0689f0ab8b6f2268704ef422e333865d82765` |
| b1g8 ML coverage contract | `1216ae3591fc026a61b4fb6581ebe79e33d34e4e2b6bf04a969a4c93c3e06689` |
| b1g8 ML manifest | `2974db4aefd07636d286b8227edb6dd50b481764e9dd7060296bd379a2688434` |
| b1g8 ML execution | `46ea4be751a3c54904bac28da31f15e5e05f347b9e8f10a1194887f55557807d` |

The retained local replay is
`/private/tmp/mfrmr-gtwab-ml-reference-replay-v1.rds`. It is a validation
cache, not a package artifact or release result. The environment was R 4.6.1,
glmmTMB 1.1.14, TMB 1.9.23, and numDeriv 2016.8-1.1.

## Replay result

All four ML objectives resolve as finite local minima:

| Scenario | Role | objective | max raw gradient | Newton decrement | selected step exponent | max AD/FD tolerance ratio |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| exact zero, R0901 | full | 2250.2152257954 | 2.7679e-5 | 7.4916e-7 | 1 | 0.4325 |
| exact zero, R0901 | reduced | 2251.3551439188 | 5.2866e-5 | 2.3448e-6 | 2 | 0.2176 |
| variance 0.12, R0902 | full | 2211.0066328476 | 4.3357e-5 | 1.2960e-6 | 2 | 0.2864 |
| variance 0.12, R0902 | reduced | 2212.0426476528 | 2.0445e-5 | 1.0546e-6 | 2 | 0.1918 |

Every objective passes three-algorithm consensus, AD-independent derivative
agreement, numerical-Hessian symmetry, positive-definite curvature, and
content-addressed sidecar validation. Raw gradient and Newton decrement remain
separate diagnostics; the latter supplies the curvature-scaled local state
without rewriting the retained raw gradient.

Both six-point full-model boundary profiles are fully returned and all twelve
nuisance-coordinate fits pass stationarity. Objectives rise toward the
Rater-variance boundary, supporting finite interiors:

- exact-zero generator: 2250.21523, 2251.29942, 2251.35412, 2251.35514,
  2251.35514, 2251.35514;
- variance-0.12 generator: 2211.00663, 2211.99518, 2212.04177, 2212.04265,
  2212.04265, 2212.04265.

The finite-interior label follows the observed ML profile, not the generating
zero variance in R0901.

## ML/REML separation and repeatability

The ML and b1g6 REML executions have identical generator hashes and identical
dataset/model-role keys. All four polished objective values differ by more
than `1e-3`, confirming that b1g8 evaluated a distinct likelihood surface.
This difference is an identity check, not an estimator-performance ranking.

The complete b1g8 replay was run twice from the same source contract. Atomic
rows, sidecar hashes, and execution hash reproduced exactly on the second run.
Six focused tests with 64 expectations pass, including hash mutation,
reserved-band, ML-identity, sidecar, boundary-profile, method-coverage, and
paired ML/REML controls.

## Gate interpretation

`NonreservedMLReplayReady=TRUE` and
`GlmmTMBMethodCoverageReady=TRUE` establish high-accuracy mechanics for both
glmmTMB ML and REML. They do not establish a production diagnostic or prefer
ML over REML. Reference coverage is now two of four method lanes.

The following remain false:

- lme4 ML and REML reference-mechanics readiness;
- `ReferenceMethodCoverageComplete`;
- `CalibrationAuthorizationReady` and
  `CalibrationExecutionAuthorized`;
- production boundary-probe and runner readiness;
- `StationarityThresholdFrozen` and `StationarityCriterionReady`;
- confirmation, inference, coefficient, and decision readiness.

The next admissible gate is a likelihood-faithful lme4 reference-objective
contract and analytic/nonreserved validation. It must not treat lme4's
reported convergence check or `allFit()` agreement as automatically
equivalent to the b1g6/b1g8 high-accuracy reference label.
