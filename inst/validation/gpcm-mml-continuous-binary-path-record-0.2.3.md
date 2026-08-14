# Continuous-normal binary GPCM slope-path microcase for mfrmr 0.2.3

Status: an exact half-line result is proved for one deliberately minimal
continuous-normal GPCM microcase. It is not a certificate for a fitted object,
a general GPCM boundary theorem, or a readiness change.

Run date: 2026-08-14 JST. The record uses semantic formulas and numerical
values only; it has no file-hash or machine-identity gate.

## Declared microcase

Let ability have the standard-normal density `phi`. Consider two binary GPCM
items with zero thresholds and slopes

`alpha_1(t) = exp(t)` and `alpha_2(t) = exp(-t)`, for `t >= 0`.

Their geometric mean is one at every distance, matching the relative-slope
identification. No additive, threshold, population-location, or population-
scale coordinate moves along the path.

For the discordant response `(1, 0)`, the conditional pattern probability is

`p_t(theta) = logistic(exp(t) * theta) * logistic(-exp(-t) * theta)`.

This is a continuous integral under the standard-normal density. It does not
replace that density by a finite quadrature grid.

## Exact paired identity and derivative sign

For `x > 0`, pair the integrand at `x` and `-x`. Write `c = cosh(t)` and
`s = sinh(t)`. Direct algebra gives

`p_t(x) + p_t(-x) = cosh(x*s) / {cosh(x*c) + cosh(x*s)} = h_t(x)`.

For every finite `t > 0`, `c > s >= 0`. The function
`tanh(z) / z` is strictly decreasing for `z > 0`: its derivative has the sign
of `z - sinh(z)*cosh(z)`, which is negative because `sinh(2z) > 2z`.
Therefore

`c*tanh(x*s) - s*tanh(x*c) > 0`.

Consequently `d h_t(x) / dt > 0` for every `x > 0` and `t > 0`.
Integrating against the positive symmetric normal density proves that the
discordant Person-marginal probability is strictly increasing over the entire
half-line, not merely at sampled distances.

The paired probability remains below `1/2` at every finite distance. As
`t` tends to infinity it converges pointwise to `1/2`; dominated convergence
therefore gives the unattained Person-marginal limit

`integral_0^Inf phi(x) / 2 dx = 1/4`.

Thus this restricted continuous-normal likelihood has a genuine increasing
boundary path and no finite maximizer on the declared half-line.

For the concordant response `(1, 1)`, the paired probability is exactly
`1 - h_t(x)`. Its marginal probability therefore decreases strictly to
`1/4`. This supplies a genuine direction-sign counterexample: the same slope
path is not automatically favorable for every response pattern.

## Exact sample-level count condition

By symmetry, both discordant patterns `(1, 0)` and `(0, 1)` have marginal
probability `m(t)`, while both concordant patterns `(1, 1)` and `(0, 0)` have
probability `1/2 - m(t)`. If a sample contains `n_D` discordant Persons and
`n_C` concordant Persons, its path derivative is

`m'(t) * {n_D / m(t) - n_C / (1/2 - m(t))}`.

At every finite distance, `m(t) < 1/4 < 1/2 - m(t)`. Therefore the entire
sample likelihood increases strictly for every `t > 0` whenever
`n_D >= n_C`. This includes a balanced sample, not only an all-discordant
sample. If `n_D < n_C`, no such half-line conclusion follows; the derivative
can change sign. In the fixed audit, a 5-discordant/7-concordant sample was
increasing at `t=0.25` but decreasing by `t=0.5`, while an all-concordant
sample decreased throughout. This is the required counterweight to the
positive construction and prevents response-independent promotion.

## Numerical audit

The repository runner independently evaluates both the paired integral and the
original integral over the whole real line using adaptive integration. It also
integrates the analytic derivative and compares it with central differences.
These calculations audit the implementation of the identities; the theorem
above does not depend on their numerical tolerances.

The fixed audit uses distances `0, 0.25, 0.5, 1, 2, 4, 8`. Numerical values are
shown below. The original whole-line integral and the paired half-line integral
agreed to a maximum absolute difference of about `1.01e-14`; the largest
reported adaptive-integration error was about `7.96e-12`. The analytic
derivative and its central-difference audit differed by at most about
`1.04e-10`.

| t | Discordant `(1,0)` marginal | Its derivative | Concordant `(1,1)` marginal | Its derivative |
| ---: | ---: | ---: | ---: | ---: |
| 0.00 | 0.2066209641 | 0 | 0.2933790359 | 0 |
| 0.25 | 0.2076771626 | 0.0082980939 | 0.2923228374 | -0.0082980939 |
| 0.50 | 0.2106290756 | 0.0149305122 | 0.2893709244 | -0.0149305122 |
| 1.00 | 0.2198678009 | 0.0202404579 | 0.2801321991 | -0.0202404579 |
| 2.00 | 0.2369262067 | 0.0122699487 | 0.2630737933 | -0.0122699487 |
| 4.00 | 0.2481743883 | 0.0018233962 | 0.2518256117 | -0.0018233962 |
| 8.00 | 0.2499665424 | 0.0000334575 | 0.2500334576 | -0.0000334575 |

The two pattern marginals sum to `1/2` at every distance, as required by the
paired identities. At `t=8`, both remain finite and on opposite sides of the
unattained `1/4` boundary.

## Scope boundary

This result proves that the adverse-outer-region mechanism survives the move
from finite quadrature to an exact continuous-normal integral in at least one
GPCM microcase and gives an exact pattern-count condition for samples within
that same zero-threshold two-item model. It does not yet cover fitted
thresholds, more than two slope levels, Rater facets, moving
additive or population coordinates, or a fitted solution's competitive
boundary value. It therefore cannot alter slope SE eligibility, comparison,
fit, DFF, or readiness.

```text
MicrocaseContinuousHalfLineProved = TRUE
SampleHalfLineCondition = discordant_count_greater_than_or_equal_to_concordant_count
ProductionHalfLineCertified = FALSE
TheoremDependsOnNumericalIntegration = FALSE
FullGPCMFitCovered = FALSE
MovingAdditiveCoordinatesCovered = FALSE
PopulationScalePathCovered = FALSE
ReadinessOverridden = FALSE
ReleaseAuthorized = FALSE
```
