# Exact-model reduction structural closure for 0.2.3

Status: release-spine row 9 structural closure, 2026-08-11. This record closes
only `exact_model_reductions`. It does not freeze the general canonical-score
tolerance, close the GPCM transformed-score gate, establish engine agreement,
authorize confirmation, or bind the eventual 0.2.3 candidate.

## Mathematical identities

For a two-category RSM, the single expanded step is zero under the package's
sum-to-zero identification. For every linear predictor `eta`,

`P(X = 1 | eta) = exp(eta) / (1 + exp(eta))`.

A two-category PCM has one zero identified step for every step-facet level, so
it has the same category kernel, marginal objective, and free-coordinate score
as the binary RSM when their common free coordinates agree.

For the supported GPCM parameterization,

`log(P_k / P_(k-1)) = a_c * (eta - tau_(c,k))`.

The free slope coordinates are `u[1:(C-1)]`, expanded as
`log(a) = (u, -sum(u))`. At `u = 0`, every expanded log slope is zero and
every `a_c = 1`; with the same expanded step matrix the GPCM therefore reduces
to the PCM category by category. The Jacobian and non-unit-slope behavior are
separate tests; this row asserts only the exact special case.

## Independent-oracle boundary

The strengthened repository audit does not merely compare two package model
branches. It independently recomputes:

1. category log kernels and their log-sum-exp normalization;
2. full category probabilities and observed-response log probabilities;
3. person-wise Gaussian--Hermite marginalization; and
4. the common-coordinate score by central differences of that independent
   marginal objective.

The oracle intentionally consumes the declared package parameter expansion
and person-specific quadrature basis. Their algebra is audited separately.
Consequently this is an independent likelihood calculation within a shared
identification contract, not an external-engine comparison.

## Deterministic results

The fixed binary and four-category fixtures retain 60 persons, four items, and
31 quadrature points. No simulation grid or external software is involved.

| Reduction | Route log probability | Route full probability | Route objective | Route common score | Oracle log probability | Oracle full probability | Oracle objective | Oracle common score | Transform residual |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| binary RSM = binary PCM | 0 | 0 | 0 | 0 | 0 | 7.7716e-16 | 0 | 2.4454e-9 | 0 |
| unit-slope GPCM = PCM | 0 | 1.6653e-15 | 0 | 4.4131e-15 | 0 | 1.6653e-15 | 0 | 3.6040e-9 | 0 |

The structural limits are `1e-12` for route/oracle log probabilities, full
probabilities, free-coordinate identity, steps, and slopes; `1e-10` for the
marginal objective and analytic route-to-route score; and `1e-6` for the
central-difference oracle score. These are machine-appropriate deterministic
unit-test limits, not statistically calibrated recovery or external-comparison
tolerances.

The targeted test passed 115 expectations with zero failures, warnings, or
skips. Fail-closed mutations show that changing a stored oracle objective
difference or a unit-slope transformation residual beyond its limit makes the
global reduction decision false even if the precomputed success flag is left
unchanged.

## Bound implementation

| Artifact | SHA-256 |
| --- | --- |
| `numerical-stationarity-pilot-0.2.3.R` | `68df33bc1c114309f875a0cf8056ac720254740633fe55ca909535d032663344` |
| `../../tests/testthat/test-numerical-stationarity-pilot.R` | `5a165396faa2ed7ac5f4a3db329b3be3612013bccb8793762346cdef8807df74` |
| `../../R/core-likelihood.R` | `8fd4495b7c778eaae401cdd69618ab5f815806b2e71ec1f3b4d54bbf4cba4bbc` |
| `../../R/mfrm_core.R` | `f18acb7f77b6166d8a2a6afe95630663588922d512294929d3a8b2cc9e0a9ec2` |

These are development-source identities. Wave E must still bind and rerun the
unit test against the exact candidate, but it need not recalibrate this
algebraic equality after observing candidate results.

## Decision

Checklist row 9 changes from `review` to `ok`. Its `frozen_structural`
acceptance rule is satisfied: both prespecified reductions pass at the stated
machine-appropriate limits, the likelihood is checked by a separate oracle,
the free and expanded transformations are explicit, and adversarial numeric
mutations fail closed.

Rows 5 `canonical_score_reference` and 6 `gpcm_transformed_score` remain
`review`. They require a broader prespecified point/parameter grid and a frozen
general stationarity tolerance; this exact-reduction closure cannot be used as
a substitute for those pilot and confirmation obligations.
