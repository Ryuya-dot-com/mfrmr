# TAM item-only GPCM MML overlap for mfrmr 0.2.3

Status: bounded overlap complete, 2026-08-14. This comparison checks the
item-only GPCM kernel and its identified MML coordinates. It does not compare
the combined rater-plus-free-slope model, establish inferential readiness, or
set a release tolerance.

## Why the scope is item-only

TAM 4.3-25 estimates GPCM slopes through `tam.mml.2pl()`. Its documented
many-facet route, `tam.mml.mfr()`, does not estimate slopes. Combining a slope
from the first route with facet estimates from the second would not be one
jointly fitted likelihood. The comparison therefore uses TAM's `data.gpcm`
fixture as a three-item, 392-Person, four-category model without a rater facet.

Both programs target the same continuous standard-normal marginal likelihood,
but their finite integration rules differ. TAM uses equally spaced nodes from
-6 to 6; mfrmr uses its Gauss--Hermite rule. The q=31/q=41 ladder is therefore
an integration-sensitivity comparison, not an assertion that the node sets are
identical.

## Identification map

TAM fixes the latent variance to one and estimates absolute item slopes
`a_i`. mfrmr estimates the population variance while constraining the
geometric mean of its relative slopes to one. With
`g = exp(mean(log(a_i)))`, the exact map used here is:

- relative slope: `alpha_i = a_i / g`;
- mfrmr population variance: `g^2`;
- uncentered transition threshold: `g * xsi_ik / a_i`;
- population mean: the shift that makes the grand transition-threshold mean
  zero;
- criterion location: the within-item mean transition threshold;
- step: the transition threshold minus its criterion location.

Across a 33-point TAM theta grid from -4 to 4, the maximum difference between
TAM probabilities and probabilities reconstructed from this coordinate map
was `6.67e-16`. This checks the map algebra; it is distinct from comparing the
two separately optimized fits.

## Observed q=31/q=41 comparison

TAM used `conv=1e-6`, `convD=1e-8`, `convM=1e-6`, and 20 inner M steps. mfrmr
used `maxit=500` and `reltol=1e-10`. No fit warning or message was captured.

| Quantity | q=31 | q=41 |
| --- | ---: | ---: |
| TAM iterations | 485 | 485 |
| mfrmr iterations | 52 | 52 |
| TAM deviance | 2450.68965418 | 2450.68965463 |
| mfrmr deviance | 2450.68965367 | 2450.68965329 |
| mfrmr minus TAM deviance | -5.13e-7 | -1.33e-6 |
| maximum relative-slope difference | 1.72e-5 | 1.71e-5 |
| maximum transition-threshold difference | 1.26e-5 | 1.25e-5 |
| maximum fitted-probability difference | 5.90e-6 | 5.88e-6 |

The largest q=41-minus-q=31 changes were `1.54e-7` for an mfrmr relative
slope, `9.32e-8` for an mfrmr transition threshold, `2.58e-8` for the mfrmr
population variance, and `4.43e-7` for TAM deviance. These are observations on
one fixed fixture, not general comparison tolerances.

## Why the reported TAM SEs are not an exact coordinate comparison

The TAM 4.3-25 fit retained finite marginal slope SEs in `se.B` and marginal
intercept SEs in `xsi$se.xsi`. It retained no joint parameter-covariance or
Hessian component, and no TAM `vcov()` method was registered. This matches the
documented boundary of `TAM::tam.se()`: that numerical procedure ignores
covariances between parameter estimates and does not implement variance-
component SEs. See the official
[`tam.se()` reference](https://alexanderrobitzsch.github.io/TAM/reference/tam.se.html).

Those omissions matter because mfrmr's relative slopes and population SD are
nonlinear functions of *all* TAM absolute slopes. The runner now carries a
constructive non-identifiability witness. It builds two positive-definite
covariance matrices with exactly the same TAM marginal slope SEs: one has zero
off-diagonal correlations and the other has correlation 0.5. Delta-method
transformation gives different answers even though both matrices are
compatible with the reported marginals:

| q | Mapped parameter | SE with zero off-diagonals | SE with correlation 0.5 | Absolute difference |
| ---: | --- | ---: | ---: | ---: |
| 31 | Relative slope: Comfort | 0.119841 | 0.091596 | 0.028245 |
| 31 | Relative slope: Work | 0.054010 | 0.044088 | 0.009922 |
| 31 | Relative slope: Benefit | 0.116667 | 0.091626 | 0.025041 |
| 31 | Population SD | 0.056961 | 0.074867 | 0.017906 |

The q=41 witness agrees to the displayed precision. The minimum eigenvalues of
the two q=31 covariance witnesses were `0.00434` and `0.00250`, so this is not
an invalid-covariance construction. Threshold SE transformation additionally
requires the unavailable slope--intercept cross-covariances. Consequently,
directly comparing TAM's marginal SE columns with mfrmr's observed-information
SEs would compare different quantities. No such comparison is reported.

## Why TAM's documented multifacet slope example is not the exact overlap

The TAM manual also documents a multifacet slope construction (Example 14,
Model 14c): obtain generalized pseudo-items and an intercept design `A` from a
facet model, then pass them with a slope design `E` to
`tam.mml.2pl(..., irtmodel="GPCM.design")`. This route was checked on
`example_core` using 16 Criterion-by-Rater pseudo-items, the 15-column
`~ item + rater + item:step` intercept design, and four Criterion slope groups.

It is a valid TAM model, but it is not the current mfrmr GPCM kernel. Ignoring
sign convention, its adjacent-category predictor has the form

`a_c * theta - (xsi_c + xsi_r + xsi_ck)`.

The mfrmr predictor has the form

`alpha_c * (theta - d_c - r_r - tau_ck)`.

TAM's shared Rater intercept therefore remains `xsi_r` for every Criterion,
whereas the effective mfrmr Rater contribution is `alpha_c * r_r`. A fixed
linear `A` design and an independently estimated slope design `E` do not impose
that product of two estimated parameter blocks. The two formulations coincide
under reductions such as unit slopes or zero Rater severity, but not in the
general free-slope fit.

The q=31 diagnostic reflected the algebraic difference. TAM returned deviance
`1892.47461002` and normalized Criterion slopes
`1.033684, 1.003033, 0.866574, 1.112990`; mfrmr returned deviance
`1785.21998597` and slopes `0.915203, 0.921404, 1.067231, 1.111154`. Both slope
vectors are ordered Accuracy, Content, Language, Organization. Those
differences are not an equivalence failure because the models are different.
They are evidence against silently treating Model 14c as the full mfrmr
comparator. A q=41 repetition was unnecessary once the formula mismatch was
established.

## Interpretation

The result is strong external evidence that, in the exact item-only overlap,
mfrmr and TAM implement the same GPCM response surface and continuous MML
target after identification is aligned. It makes an optimizer or basic GPCM
kernel defect an implausible explanation for the earlier q=31/q=41 mfrmr
stability result.

It does not resolve the remaining inference question. The item-only mfrmr fit
still reports `InferenceReady = FALSE`, and its nonlinear local-estimability
row is not evaluated for this reduced design. TAM's reported standard errors
cannot substitute for mfrmr's global slope-boundary/readiness contract. The
new feasibility audit establishes why a cross-engine SE comparison is not
identified by TAM's retained marginal SEs; it does not treat that absence as
evidence for or against mfrmr's local Hessian.

```text
ComparisonScope = item_only_gpcm_mml_projection
FullManyFacetGPCMCompared = FALSE
CommonContinuousLikelihoodTarget = TRUE
IdenticalFiniteQuadratureRule = FALSE
CrossEngineSEComparisonAvailable = FALSE
SEFeasibilityAudit = marginal_SEs_insufficient_without_joint_covariance
InferenceReadinessOverridden = FALSE
ComparisonToleranceFrozen = FALSE
ReleaseAuthorized = FALSE
```
