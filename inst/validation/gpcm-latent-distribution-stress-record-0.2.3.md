# GPCM latent-distribution stress record for mfrmr 0.2.3

Date: 2026-08-14

Status: completed 12-replicate calibration pilot; descriptive numerical
evidence only. No estimator selection, Bayesian comparator, confirmation
design, capability promotion, or release decision is authorized.

## Execution

The guarded runner in `gpcm-latent-distribution-stress-0.2.3.R` was executed
with R 4.5.1 on Windows, a locally rebuilt mfrmr 0.2.3, lpSolve 5.6-23,
`quad_points=31`, and `maxit=300`. Twelve prespecified seeds crossed three
Person distributions, two exposure levels, and JML/MML, producing 144 fits.
The execution took 941 seconds.

- all 144 fit calls returned objects and optimizer convergence;
- no fit returned an error condition;
- 19 fits retained explicit optimizer-review warnings;
- all fits remained `InferenceReady=FALSE`; and
- all fits had `BoundaryState=not_evaluated`.

The uniform readiness result reflects the same incomplete free-slope GPCM
nonlinear-rank/boundary route seen in the estimator-asymptotics pilot. It is
not evidence that all 144 finite solutions failed empirically.

No SHA, MD5, file-byte, serialized-object, package-path, operating-system, or
machine identity was used as scientific evidence.

## Distribution coupling

The deterministic supports had mean zero and population variance one:

| Distribution | Support skewness | Support excess kurtosis |
|---|---:|---:|
| normal | 0.000 | -0.009 |
| skewed gamma(shape=2) | 1.404 | 2.882 |
| symmetric two-normal mixture | 0.000 | -1.620 |

Within every replicate, all distributions used the same seed and quantile
coupling. Design rows, Rater truth, Criterion truth, step truth, and slope truth
were exactly identical across distributions. Only Person ability shape and the
responses it generated differed. All 36 cross-distribution coupling audits and
all 72 exposure-cell design audits passed.

## Step recovery and paired estimator difference

The RMSE columns are means of replicate-specific component RMSE. A positive
JML-minus-MML difference means MML had lower numerical step-recovery error.

| Distribution | Observations/Person | JML RMSE | MML RMSE | JML - MML | 95% MC interval |
|---|---:|---:|---:|---:|---:|
| normal | 8 | .3223 | .1848 | .1375 | [.1045, .1705] |
| skewed gamma | 8 | .3255 | .2054 | .1201 | [.0743, .1659] |
| symmetric mixture | 8 | .2902 | .2026 | .0876 | [.0465, .1288] |
| normal | 24 | .1112 | .1042 | .0071 | [-.0064, .0205] |
| skewed gamma | 24 | .1259 | .1264 | -.0005 | [-.0146, .0135] |
| symmetric mixture | 24 | .1111 | .1035 | .0076 | [-.0081, .0233] |

The sparse-exposure MML advantage survived both forms of population
misspecification. At 24 observations per Person, JML and MML step recovery was
numerically indistinguishable. Nonnormality therefore did not reverse the
preceding pilot's central result: within-Person exposure mattered more than a
blanket estimator label.

## Stress-minus-normal contrasts

For normal-population MML step recovery:

| Stress | Observations/Person | Stress - normal RMSE | 95% MC interval |
|---|---:|---:|---:|
| skewed gamma | 8 | .0206 | [-.0328, .0741] |
| skewed gamma | 24 | .0222 | [.0089, .0355] |
| symmetric mixture | 8 | .0178 | [-.0426, .0782] |
| symmetric mixture | 24 | -.0007 | [-.0275, .0261] |

Only the dense skewed condition showed a clearly positive MML step penalty,
and its magnitude was small enough that JML and MML remained at parity in that
cell. Criterion and Rater facet recovery showed no general stress-related
degradation. Optimizer log-slope stress-minus-normal intervals all included
zero; these slope values remain numerical traces rather than primary
inferential estimates.

## Coordinate-specific step error

Signed errors were summarized by coordinate, never pooled across the 12
sum-zero step coordinates.

| Distribution | Obs./Person | Method | Mean absolute coordinate error | Maximum | Intervals excluding zero |
|---|---:|---|---:|---:|---:|
| normal | 8 | JML | .2275 | .3974 | 8/12 |
| normal | 8 | MML | .0586 | .1342 | 0/12 |
| skewed gamma | 8 | JML | .2064 | .3944 | 8/12 |
| skewed gamma | 8 | MML | .0621 | .1526 | 0/12 |
| symmetric mixture | 8 | JML | .1766 | .2908 | 8/12 |
| symmetric mixture | 8 | MML | .0254 | .0591 | 0/12 |
| normal | 24 | JML | .0427 | .1049 | 1/12 |
| normal | 24 | MML | .0260 | .0628 | 0/12 |
| skewed gamma | 24 | JML | .0323 | .0914 | 2/12 |
| skewed gamma | 24 | MML | .0336 | .0790 | 1/12 |
| symmetric mixture | 24 | JML | .0403 | .0866 | 2/12 |
| symmetric mixture | 24 | MML | .0286 | .0639 | 1/12 |

Sparse JML retained the same coordinate-specific step signal under all three
Person distributions. Increasing exposure reduced that signal for both
estimators and every distribution. The 24-minus-8 step-RMSE differences ranged
from -.179 to -.211 for JML and from -.079 to -.099 for MML; all six intervals
excluded zero.

## MML population moments

Under nonnormal generation, these are differences from generating mean zero
and variance one, not correctly specified normal-model parameter bias.

| Distribution | Obs./Person | Mean error | Mean RMSE | Variance error | Variance RMSE |
|---|---:|---:|---:|---:|---:|
| normal | 8 | -.0793 | .2978 | .1189 | .2142 |
| normal | 24 | -.0870 | .2715 | -.0186 | .1443 |
| skewed gamma | 8 | -.1068 | .2916 | -.0119 | .1684 |
| skewed gamma | 24 | -.0902 | .2572 | -.0886 | .1591 |
| symmetric mixture | 8 | -.0774 | .2888 | .1672 | .2353 |
| symmetric mixture | 24 | -.0838 | .2676 | .0227 | .1145 |

Population-mean error intervals all included zero. Variance error excluded zero
for normal sparse exposure (+.119), mixture sparse exposure (+.167), and skewed
dense exposure (-.089). The structural estimates were comparatively robust,
but the fitted normal population variance was shape- and exposure-sensitive.

## Adjudication

1. **Does the MML structural advantage survive misspecification?** Yes, within
   this calibration range and especially at eight observations per Person.
2. **Does correct normality cease to matter?** No. A small dense-skew step
   penalty and shape-sensitive population variance remained.
3. **Does JML become preferable under nonnormality?** No. Sparse JML retained
   substantially larger step error; dense JML and MML were approximately tied.
4. **Is Bayesian estimation now required?** No. This pilot provides no prior
   comparison and does not show a structural failure of normal MML that would
   by itself justify introducing prior-dependent estimates.
5. **What remains blocking?** The free-slope GPCM readiness route cannot yet
   convert local numerical evidence into a complete rank/boundary/SE decision.

```text
DistributionRobustnessDecision = pilot_completed_no_prespecified_decision_rule
EstimatorSelectionAuthorized = FALSE
BayesianComparatorAuthorized = FALSE
ConfirmationAuthorized = FALSE
CapabilityPromotionAuthorized = FALSE
```

The next essential task is not a larger estimator tournament. It is a bounded
readiness adjudication using representative normal, skewed, and mixture fits:
identify which nonlinear-rank and boundary evidence is already computable,
which remains mathematically unavailable, and whether any safe
`numerically_stable_but_inference_unresolved` state can replace the current
undifferentiated `InferenceReady=FALSE` presentation without weakening the
formal gate.
