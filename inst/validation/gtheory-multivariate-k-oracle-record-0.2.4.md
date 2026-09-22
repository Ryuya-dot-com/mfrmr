# Draft.85c0 independent multivariate G-theory K-oracle record

Date: 2026-08-24
Scope: repository-only neutral K, population-map, ML/REML objective, and
metric-mechanics preflight
Result: oracle mechanics passed; finite-sample recovery remains unexecuted

## Outcome

Nine focused tests and 131 expectations pass without failure, warning, error,
or skip. The statistical core takes only row IDs, integer stratum and group
codes, one-hot X, a finite response, semantic covariance matrices, and
residual variance. Its static audit finds no call to the Draft.85b1 parser,
either backend, their model parsers, or their covariance extractors.

The separate b1 bridge exactly reproduces the row, fixed-design, random-block,
coordinate-order, derivative-crossproduct, and structural-rank identities.
During this work, the b1 fixed-design hash was hardened to exclude
`model.matrix`-specific attributes: the numeric design and its column identity
are now hashed separately enough to be reconstructed by an independent
implementation. The bridge now consumes the b1 backend-binding routine rather
than maintaining a second hash implementation.

No exported function, package help page, vignette, NEWS entry, public roadmap,
or support-envelope row changed. Recovery, estimation, inference,
uncertainty, coefficient, decision, and public-support readiness remain false.

## Literal and population controls

A hand-checkable two-row microcase with one component uses

```text
Gamma = [2.0 0.5; 0.5 3.0]
sigma2 = 0.25
K     = [2.25 0.50; 0.50 3.25].
```

Both K constructions reproduce the literal matrix exactly. Its four free
coordinates have derivative rank three, so K construction is available while
population inversion is correctly blocked.

The identified controls are:

| Control | rows | free covariance coordinates | derivative rank |
| --- | ---: | ---: | ---: |
| two strata, 12 Objects x 4 Raters x 2 Items | 192 | 10 | 10 |
| three strata, 10 Objects x 4 Raters x 2 Items | 240 | 19 | 19 |

They use global `Object`, `Rater`, and `Object:Rater` covariance matrices plus
one residual variance. Results are:

| Control | max dual-K difference | max coordinate round-trip error | max K round-trip error |
| --- | ---: | ---: | ---: |
| two strata | 0 | 2.886580e-14 | 2.020606e-14 |
| three strata | 2.220446e-16 | 1.826317e-14 | 1.454392e-14 |

The three-stratum matrices use distinct AB, AC, and BC covariances. Swapping
AB and AC coordinates while retaining their identities changes K and is not
normalized away.

## Local expected information

Both truth-point local expected-information matrices have full rank. Their
observed diagnostics are:

| Control | ML minimum eigenvalue | ML condition | REML minimum eigenvalue | REML condition |
| --- | ---: | ---: | ---: | ---: |
| two strata | 3.726918 | 224.2007 | 3.618689 | 230.9016 |
| three strata | 2.705363 | 383.6016 | 2.593424 | 400.1503 |

These values establish only that the declared local information map is full
rank at the supplied points. They are not accuracy, precision, power, or
coverage thresholds.

For both controls, every ML and REML information entry also agrees with a
separately evaluated literal trace expression, and both matrices are symmetric
within `1e-12`. This validates the declared Fisher-block/restricted-
information mechanics; it is not an observed-Hessian or finite-sample profile-
ML precision result.

The aggregate information gate now additionally requires the independent K-
derivative design to be identified. A deliberately coarse derivative-rank
tolerance produces an unidentified design while leaving both raw information
matrices computable; the record retains `LocalExpectedInformationComputed=TRUE`
and correctly holds `LocalExpectedInformationReady=FALSE`.

## Independent lme4 objective binding

On the deterministic 480-row global-component response fixture, the dense
oracle independently reconstructs the backend fit point:

| Criterion | absolute log-likelihood difference | max fixed-mean difference | max absolute K-coordinate score |
| --- | ---: | ---: | ---: |
| REML | 1.136868e-13 | 1.018664e-13 | 0.002712137 |
| ML | 1.136868e-13 | 2.532419e-13 | 0.005770380 |

Analytic K-coordinate scores also agree with central finite differences at an
interior supplied point. The nonzero fit-point scores are retained as
optimizer-scale diagnostics and are not converted into a newly selected
stationarity threshold.

This objective agreement is independent likelihood wiring, not independent
estimator recovery: the covariance point still came from lme4. The local
glmmTMB/TMB version mismatch recorded by Draft.85b1 is not bypassed or
reclassified by the oracle.

## Fail-closed controls

The focused suite additionally verifies that:

- component covariance names/order and stratum dimnames are exact;
- asymmetric and indefinite covariance is rejected without PSD repair;
- a rank-one component remains boundary even when positive residual variance
  makes total K positive definite and the objective finite;
- a scaled positive-definite component with eigenvalues `1e4` and `5e-7` is
  operationally rank-deficient under the declared relative rank rule even
  though its minimum eigenvalue exceeds the absolute `1e-8` boundary cutoff;
  the `2e-6` control remains full rank and nonboundary;
- a positive residual variance at or below the boundary tolerance keeps local
  information computable but not ready, while zero residual variance is
  rejected;
- population-map round-trip does not override boundary regularity;
- a structural row subset gives exactly the corresponding principal K
  submatrix, and row permutation gives the corresponding `P K P'`;
- an `NA` response is rejected rather than silently completed;
- exact candidate/reference coordinates give zero deterministic error;
- component-value swaps give nonzero coordinate and K errors; and
- a failed fit retains every planned coordinate with
  `MetricAvailable=FALSE`, rather than disappearing from the atomic registry;
- candidate receipts accept only the four declared monotone fit/estimate/gate
  tuples, and an exact registry match does not promote denominator readiness;
- stale response/covariance/derivative hashes, attached metadata, unknown
  fields/attributes, mutated nested bridge audits, and false readiness flags
  are rejected before oracle evaluation;
- capacity-blocked derivative designs return a typed non-evaluated state and
  cannot enter projection or score calculations; and
- backend-fit component order, fixed-effect identity, criterion, observation
  count, point-gate state, and exact top-level schema are checked before the
  independent objective comparison.

## Disposition

Draft.85c0 establishes a neutral estimand map and independent objective
oracle. Its sealed-candidate/reference join proves receipt integrity, not
process-level truth blindness. It has not selected recovery cutoffs,
replication counts, seed bands, missingness assumptions, or a backend.
Draft.85c1 must preregister those choices and a frozen denominator before any
finite-sample recovery result is used. Composite G/Phi, local-diagonal
components, intervals, coverage, and public multivariate G-theory remain
downstream.
