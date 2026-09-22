# Future Draft.85a0 multivariate G-theory algebra preflight record

Date: 2026-08-09
Scope: repository-only supplied-matrix and allocation algebra
Result: algebra preflight passed; estimation and public support remain absent

## Outcome

The future multivariate G-theory roadmap now has an executable mathematical
oracle rather than prose alone. The prototype preserves ordered strata,
effect-specific covariance matrices, universe/error roles, exact cross-
stratum allocation overlap, raw PSD/rank state, and weighted composite
quadratic forms.

Nine focused tests and 66 expectations pass with no warning, skip, failure, or
error. No data were generated, no covariance matrix was estimated, and no
public package function changed.

## What is now implemented

- exact stratum-order and component-role validation;
- symmetric/finite/PSD/rank audits for covariance, operator, contribution, and
  aggregate matrices;
- explicit allocation-weight Gram operators for common, partially shared, and
  independent condition samples;
- component contribution `Gamma_c o Lambda_c`;
- separate `Sigma_p`, `Sigma_delta`, and `Sigma_Delta` construction;
- named nonnegative composite and separately labelled linear-contrast weights;
- component-level quadratic contribution retention;
- exact one-stratum reduction; and
- two- and three-stratum structural fixtures.

The implementation deliberately does not contain a covariance estimator,
random-slope backend adapter, interval, PSD repair, public formula grammar, or
multivariate report class.

## Frozen overlap results

For weights A=0.6 and B=0.4:

| Rater sampling | Specification hash | G | Phi |
| --- | --- | ---: | ---: |
| Common | `af333d751f3bb04adf0d3e4af9fa8af413d11eb1c1c9bb61fac459eab4d91ae9` | 0.6719367589 | 0.6204379562 |
| One-of-two shared | `4ee5a35b675944ae81bd58d1e79dd72efef83f904ba8c858d40c8a3b59002dd6` | 0.6967213115 | 0.6488549618 |
| Independent | `5216fa312e8451484a317b62f6fae04ed415ad059e0bb9f2bdcc28a2c0400478` | 0.7234042553 | 0.6800000000 |

The common-support composite has universe, relative-error, and absolute-error
quadratic variances 0.680, 0.332, and 0.416. Its result hash is
`4413067822afc5486f4e9e1059b635362b83dcbcf44406c32435982401c0f488`.

The ordering changes only allocation overlap. It demonstrates why counts or
averaged univariate coefficients cannot identify a multivariate D-study.

## Sharing and reduction checks

Two equal-weight condition samples produce cross-stratum operator values 1/2,
1/4, and zero for common, one-of-two shared, and independent support. An
unequal two-versus-three allocation sharing one condition produces exactly
1/6 and is explicitly unequal to `1/sqrt(6)`.

The one-stratum fixture uses Person variance 1.2, Item variance 0.3 averaged
over two Items, and Residual variance 0.6 averaged over four observations. It
returns exactly:

```text
G   = 1.2 / (1.2 + 0.6/4)           = 0.8888889
Phi = 1.2 / (1.2 + 0.3/2 + 0.6/4)   = 0.8000000
```

This reduction is necessary but not evidence that a multivariate backend can
recover the input matrices.

## Negative controls

The preflight rejects:

- an indefinite Person covariance;
- changed stratum order despite otherwise equal values;
- asymmetric covariance beyond tolerance;
- an object operator that is not all ones;
- allocation weights that do not sum to one within every stratum;
- missing, extra, or mismatched component identities;
- invalid nonnegative-composite weights; and
- a zero linear contrast.

Rank-deficient PSD state remains visible in the audit. It is not silently
repaired or equated with an identified estimated covariance.

## Artifact identities

| Artifact | SHA-256 |
| --- | --- |
| `gtheory-multivariate-algebra-prototype-0.2.3.R` | `e8007aa09b18abd6a81cb691245d4abf522b2a9b50ff66d92989b9ce04a505ac` |
| `gtheory-multivariate-algebra-contract-0.2.3.md` | `d109f6fb4ef915f7245795d86d7af4f14cbfaff5dd76cf5aa957ecb72d00ff84` |
| `test-gtheory-multivariate-algebra-prototype.R` | `d253b6b87700e2e032f8323d9f1dbe885c6f73fc6fe26280f3ec72e9d91f0f6a` |

The record's own hash is omitted because recording it would change the file.

## Readiness and ordered next steps

`AlgebraReady=TRUE` applies only to validated supplied matrices.
`EstimationReady`, `InferenceReady`, `CoefficientEligible`, and
`DecisionReady` remain false. The multivariate checklist item remains
roadmap-only rather than validated support.

The active execution sequence does not jump to a multivariate estimator:

1. Draft.83d2 executes the registered univariate smoke and false-ready gates;
2. Draft.84 validates joint full-refit uncertainty;
3. future Draft.85b adds a long-form `Stratum` design/incidence contract and a
   covariance-estimation adapter;
4. future Draft.85c evaluates two-/three-stratum recovery, PSD/rank recovery,
   missing strata, sparse common links, and workload imbalance; and
5. only then can an experimental multivariate public object be considered.
