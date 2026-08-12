# GPCM nonlinear local-estimability P1u record (0.2.3)

## Decision

P1u gives the existing nonlinear score/Jacobian instrumentation an estimator-
specific retained-point interpretation. It closes a semantic gap: a computed
rank is now typed as a sufficient local first-order certificate, a first-order
deficiency, a tolerance-sensitive result, or not evaluated. It does not turn
that result into global identification, boundary interiority, weak-information
classification, covariance eligibility, or inference readiness.

The admitted P1s bundle is not rerun. It retains route-level results but not
the complete fitted objects and nonlinear audit payloads needed for this new
classification. P1u therefore changes production instrumentation and future
evidence only; it does not retrospectively change P1s's zero-of-eight
`InferenceReady` result.

## Mathematical basis

### Conditional JML GPCM

Let `g(eta)` contain every retained adjacent-category logit in the exact
constrained optimizer coordinates `eta`, including Person, additive facet,
step, and free log-slope coordinates. If the Jacobian

```text
D g(eta_hat)
```

has full column rank `d`, the smooth response map has a sufficient local
first-order rank certificate at `eta_hat`. P1u records this as
`locally_full_rank_sufficient`. A rank-deficient Jacobian is recorded only as
`locally_first_order_rank_deficient`: higher-order terms may still distinguish
parameters, so local nonidentifiability is not asserted.

This conditional map holds retained JML Person coordinates as part of the
joint parameter vector. It is not the MML marginal response map and does not
address an unbounded likelihood path.

### Fixed-quadrature MML

For Person design `p`, finite response pattern `y`, fixed quadrature rule `q`,
and optimizer coordinate vector `eta`, define

```text
s_p,y(eta) = d log P_q(Y_p = y; eta) / d eta.
```

Under unit row weights and finite parameters, every finite category pattern
has strictly positive fixed-quadrature probability. The expected score
information for the independent retained Person designs is

```text
I_q(eta) = sum_p sum_y P_q(Y_p = y; eta) s_p,y(eta) s_p,y(eta)'.
```

Suppose the rows formed by only the actually observed pattern score vectors
`s_p,y_p(eta_hat)` span all `d` free coordinates. For every nonzero vector `v`,
at least one observed row has `v' s_p,y_p != 0`; its corresponding term has
positive probability. Therefore

```text
v' I_q(eta_hat) v > 0,
```

and `I_q(eta_hat)` is positive definite. Full observed-pattern score rank is
thus a sufficient subset-of-support certificate; exhaustive response-pattern
enumeration is unnecessary in this positive direction.

The converse is intentionally not used. A deficient observed subset may omit
informative unobserved patterns, so it cannot establish singular expected
information. P1u then uses exhaustive all-pattern information if the bounded
enumeration is available; otherwise the result is `not_evaluated`. Even an
exhaustive first-order deficiency does not by itself prove nonlinear
nonidentifiability through higher-order terms.

The MML claim is explicitly about the implemented fixed-quadrature model. It
does not establish identification of the exact continuous integral or
quadrature-limit stability.

## Typed contract

`fit$data_review$estimability$nonlinear_local_estimability` records:

- estimator, model, nonlinear blocks, probability-model scope, and quadrature
  points where applicable;
- evidence basis, free dimension, local rank, nullity, complete parameter-map
  identity, and tolerance sensitivity;
- separate flags for a sufficient local full-rank result and a complete
  first-order deficiency;
- invariant `FALSE` flags for global identification, continuous-integral
  identification, local nonidentifiability, weak information, and boundary
  classification; and
- `readiness_effect = none_local_property_only`.

The principal states are:

| State | Meaning |
| --- | --- |
| `locally_full_rank_sufficient` | The estimator-specific smooth map has a sufficient full-rank retained-point certificate. |
| `locally_first_order_rank_deficient` | A complete map is first-order rank deficient; higher-order and global conclusions remain open. |
| `indeterminate_tolerance_sensitive` | Rank changes across the recorded tolerance ladder. |
| `not_evaluated` | The required map, weight contract, parameter map, or bounded computation is unavailable. |
| `not_required` | No nonlinear optimizer block is present. |

Malformed or incomplete optimizer-index maps fail closed. Rank-tolerance
sensitivity cannot produce a positive certificate.

## Computational boundary

The MML observed-pattern audit retains the free-dimension limit of 80 and the
score-matrix limit of 8,000 elements. Its analytic Person limit increases from
100 to 200 so a moderate dataset is not rejected solely by a redundant row-
count guard when the dimension/element limits already pass. Independent
central-difference checking remains capped at 100 Persons. Thus 101--200
Person cases may obtain the analytic score-rank certificate while retaining
`numerical_differentiation = not_evaluated_execution_limit`; this derivative-
check status is reported but is not silently treated as a readiness rule.

The exhaustive all-pattern audit is unchanged. It remains the fallback for a
deficient observed subset and is not attempted when the response-pattern grid
exceeds its bounded limits.

## Focused numerical checks

The retained integration fixtures show:

| Estimator/fixture | Evidence basis | Rank/free dimension | Local state | Fit readiness |
| --- | --- | ---: | --- | --- |
| JML GPCM, 8 Persons, 2 Raters, 2 Criteria | Conditional adjacent-logit Jacobian | 15/15 | Full-rank sufficient | `review` |
| MML GPCM, same 8-Person design | Exhaustive fixed-q all-pattern information | 9/9 | Full-rank sufficient | `review` |
| MML GPCM, 20-Person deterministic fixture | Observed-pattern subset score span | 9/9 | Full-rank sufficient | `review` |

All three remain `InferenceReady = FALSE`. The tests also cover deficient
observed subsets, exhaustive first-order deficiency, tolerance sensitivity,
malformed parameter maps, analytic-only derivative limits, and the invariant
absence of global, weak-information, boundary, or readiness promotion.

## P1s and portfolio consequence

P1u resolves the first item in the P1s next-work list at the level actually
supported by the mathematics: what the retained nonlinear maps can establish
locally. It does not resolve either terminal-gradient route and does not
complete the JML slope/joint boundary or MML marginal slope boundary.

The next substantive GPCM task is therefore boundary classification under the
fixed estimator-specific objectives, followed by terminal-gradient stability.
Recovery, coverage, fit-index, DFF, owner ranking, external comparison,
additional P1s replication, broad simulation, selection, and confirmation
remain unauthorized.

## Machine-readable disposition

```text
LocalClassifierImplemented = TRUE
JmlConditionalFullRankSufficientTyped = TRUE
MmlObservedSubsetFullRankSufficientTyped = TRUE
MmlObservedSubsetDeficiencyConclusive = FALSE
MmlAllPatternFallbackTyped = TRUE
GlobalIdentificationClassified = FALSE
ContinuousIntegralIdentificationClassified = FALSE
WeakInformationClassified = FALSE
BoundaryClassified = FALSE
ReadinessEffect = none_local_property_only
P1sRerun = FALSE
P1sInferenceReadyRoutes = 0
RecoveryClaimAuthorized = FALSE
ExternalComparisonAuthorized = FALSE
BroadSimulationAuthorized = FALSE
ConfirmationAuthorized = FALSE
```

## Identity and verification

| Artifact | SHA-256 |
| --- | --- |
| `R/core-estimability.R` | `a2d13aaa3b4f53e530751d3c8312dbf8f4f5f2ac8d1455a006d18b7c2295710f` |
| `R/mfrm_core.R` | `0583ef7d37b49e059b6adae99b579770c8bb76686aac38809ea2fe8a3c7b29b4` |
| `R/api-estimation.R` | `295ccf1027885c7b9bb65c16ee52cec856f561b9ee4e18dad6954c03b37229e2` |
| `man/fit_mfrm.Rd` | `79e208e6fe6764d9f35ca8309130339ca76f36f845e25b77740110d8c412a947` |
| `tests/testthat/test-estimability-audit.R` | `091d98ab5f93e57dc0f28a0c0136436fbb3387fae409a89f5b73f02d255a7e5b` |
| `tests/testthat/test-nonlinear-local-estimability-classification.R` | `0a219db2522daeb61e61547b7a45226c098c1cbea7d1e83595294ef1224ef24f` |

The focused estimability and classifier files pass 363 expectations with zero
warnings or skips. Readiness propagation also passes independently, confirming
that the local classifier does not upgrade the fit-level contract.

The built-package CRAN-light `R CMD check` passes with zero errors, warnings,
or notes. A separate non-CRAN full-tarball check reaches 12,669 passing tests
but fails 37 repository-only tests because `inst/validation` is intentionally
excluded from the tarball while those tests read its files unconditionally;
568 tests skip. None of the 37 failures occurs in the classifier,
estimability, readiness, public API, or documentation checks changed by P1u.
This package-test topology debt remains separate and is not counted as a P1u
pass or as evidence against the mathematical classifier.
