# Public GPCM-MML to independent-likelihood bridge

Status: completed repository-only numerical bridge; no public family,
readiness, standard-error eligibility, or release change

Review date: 2026-08-14

## Question

Does the current public `fit_mfrm()` GPCM-MML implementation optimize the same
complete-predictor marginal likelihood as the independent p3c kernel? This is
the necessary implementation check before attributing a converged but
non-inference-ready fit to weak identification, quadrature sensitivity, or the
formal readiness contract.

## Fixed comparison

- Truth: the moderate crossed p3a complete-predictor condition.
- Designs: complete 16-edge crossing and the balanced eight-edge cycle.
- Persons: 80 per design; the same simulated rows are used at q=31 and q=41.
- Public fit: `fit_mfrm(method = "MML", model = "GPCM")`, with Criterion as
  both step and slope owner and a free normal population.
- Independent fit: the p3c direct marginal likelihood with two deterministic
  starts and the same quadrature order.
- Identification: four Criterion slopes with geometric mean one, four Rater
  severities with sum zero, twelve transition boundaries with overall mean
  zero, and a free population mean and standard deviation; 19 coordinates.

The public estimates were mapped into the independent coordinates. The bridge
then compared the public stored likelihood, the independent likelihood at the
public coordinates, the independently optimized likelihood, all parameters,
category probabilities on 161 ability points, and raw observed-information
standard errors. No serialized object, file byte sequence, SHA, MD5, or other
machine-specific identity is part of the comparison.

## Numerical agreement

| Design | q | Absolute NLL difference | Public NLL remap difference | Maximum parameter difference | Maximum probability difference | Maximum slope-SE difference | Population-SD SE difference |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| complete | 31 | 4.21e-11 | 0 | 1.75e-6 | 3.31e-7 | 3.21e-8 | 2.94e-7 |
| complete | 41 | 1.86e-11 | 0 | 2.65e-6 | 5.95e-7 | 6.37e-8 | 1.53e-8 |
| balanced cycle | 31 | 1.36e-9 | 0 | 8.41e-6 | 2.70e-6 | 4.79e-7 | 1.57e-7 |
| balanced cycle | 41 | 1.03e-9 | 2.27e-13 | 3.75e-6 | 1.37e-6 | 3.88e-7 | 3.73e-8 |

The maximum parameter difference in the table is the largest of the slope,
Rater severity, transition-boundary, population-mean, and population-SD
differences. Both implementations returned full-rank positive-definite
19-dimensional observed Hessians in all four fits. The public covariance was
unregularized (`status = "ok"`), and both optimizers returned convergence code
zero. Public terminal gradient sup-norms ranged from `1.57e-5` to `7.46e-5`;
independent values ranged from `5.40e-6` to `2.40e-4`.

These continuous differences are the evidence. The script also applies a
documented regression guard with deliberately looser numerical tolerances to
detect a future implementation drift. That guard is not a practical-effect,
model-selection, readiness, or release threshold.

## Quadrature stability

| Design | Public maximum slope change, q41-q31 | Independent maximum slope change | Public population-SD change | Independent population-SD change |
| --- | ---: | ---: | ---: | ---: |
| complete | 0.0045745 | 0.0045752 | 0.0235360 | 0.0235356 |
| balanced cycle | 0.0008625 | 0.0008627 | 0.0007039 | 0.0007027 |

The two implementations reproduce the same q sensitivity. The complete-design
population-SD movement is large enough to keep q=31/q=41 comparison visible;
this bounded run does not freeze an acceptable sensitivity cutoff or change
the package default.

## Numerical evidence versus readiness

All public fits recorded `estimation_converged = TRUE`, but all retained
`FitReadiness = "review"` and `InferenceReady = FALSE`. Their reasons were:

`design_rank_not_evaluated;boundary_audit_incomplete;mml_gpcm_slope_boundary_not_evaluated`

Therefore the fixed discrepancy is not evidence of a wrong public optimizer,
a singular local Hessian, or disagreement between two implementations. It is
also not enough to call the readiness contract overly strict. The readiness
hold concerns unfinished structural and global boundary evidence, whereas the
bridge establishes only local finite-quadrature numerical agreement.

The raw covariance comparison is diagnostic only. It does not turn the
optimizer-trace slope SEs into publicly eligible inferential SEs.

## Interpretation

1. The public GPCM-MML complete-predictor kernel, parameterization, likelihood,
   fitted probabilities, and local observed information agree with an
   independent implementation on the fixed complete and sparse designs.
2. A public-optimizer implementation error is not the primary explanation for
   the readiness hold in these fixtures.
3. Local curvature is informative but cannot prove absence of a remote
   likelihood-recession path. Positive-definite Hessians do not close the
   global boundary question.
4. q sensitivity is model- and sample-dependent; the complete design moved
   more than the sparse balanced-cycle fixture here. Density alone is not a
   sufficient proxy for integration stability.
5. The next public-facing diagnostic should expose a bounded same-data
   quadrature sensitivity result alongside, but separate from, optimizer,
   curvature, and formal readiness evidence. It should not silently promote
   inference readiness.
6. This bridge says nothing about the loading-only family or TAM's many-facet
   route. Those remain different model families rather than alternate engines
   for the same public many-facet GPCM.

PublicKernelMatchedWithinRegressionGuard = TRUE

LoadingOnlyPublicFamilyAdded = FALSE

TAMManyFacetEquivalenceClaimed = FALSE

PublicSEEligibilityOverridden = FALSE

ReadinessOverridden = FALSE

ComparisonToleranceFrozen = FALSE

ReleaseAuthorized = FALSE
