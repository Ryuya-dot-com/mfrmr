# GPCM slope-action finite-sample MML refit

Status: completed repository-only direct-MML pilot; no public family,
model-selection, standard-error rule, readiness, or release change

Review date: 2026-08-14

## Question

After removing the known-ability advantage of the p3b oracle, why might a
GPCM-MML fit converge without supporting stable inference? This bounded pilot
separates three possibilities:

1. different optimizer basins or loose stopping;
2. weak identification of relative slopes and population scale;
3. a readiness threshold that is too strict when used alone.

## Model and identification

Both the implemented complete-predictor action and the loading-only comparison
were fitted by the same repository-only direct marginal likelihood. Each fit
has 19 free coordinates:

- four relative Criterion slopes with geometric mean one;
- four Rater severities with sum zero;
- twelve Criterion transition boundaries with overall mean zero;
- a normal population mean and standard deviation.

This identifies population location through the boundary constraint and
population scale through geometric-mean-one relative slopes. It follows the
logic of mfrmr's free-population GPCM scale, but it is an independent bounded
comparison kernel rather than the public estimator.

An analytic marginal-likelihood gradient was compared with central numerical
differences for both slope actions. The maximum absolute discrepancy was
`1.77e-8`.

## Fixed execution

- Truth parameters: the moderate crossed p3a condition.
- Designs: complete 16-edge crossing and the balanced eight-edge cycle.
- Training sample: 250 Persons, each observed on every retained edge.
- Independent validation sample: 500 Persons under the same design.
- Replications: 12 per design and truth action.
- Fit quadrature: q=31; evaluation quadrature: q=41.
- Candidates: complete-predictor and loading-only, with equal dimension.
- Starts: neutral and deterministic structured; the lower objective is kept.
- Polish: a stricter `nlminb` pass is attempted when the retained BFGS gradient
  exceeds `1e-4` and accepted only if it does not worsen the objective and
  reduces the gradient.
- Standard errors: inverse full 19-coordinate observed Hessian, only when the
  Hessian is positive definite. No generalized inverse or regularized SE is
  substituted.

This is actual finite-sample MML refitting, but it remains a small fixed pilot.
It is not a public automatic model comparison, a universal sample-size study,
or external TAM equivalence evidence.

## Optimization, curvature, and quadrature

All 96 retained candidate fits returned the primary BFGS convergence code
zero. All 96 full Hessians were positive definite with rank 19. Across the
true-family fits, median condition numbers ranged from 44.7 to 78.4.

The two deterministic starts ended within `7.88e-6` log-likelihood units in
the worst candidate fit. Before polish, the largest retained gradient sup-norm
was `4.44e-3`; after accepted polish the overall maximum was `4.88e-4`.
Polish changed objectives by at most a few times `1e-8`. Thus stopping precision
explains part of the gradient flag, while materially different local basins do
not explain this fixed result.

Changing q=31 to q=41 at retained coordinates changed an individual training
negative log likelihood by at most `0.00252` per Person. More importantly, the
largest change in the true-versus-wrong family advantage was `0.000350` per
Person and changed the selected family in 0 of 48 paired datasets.

## Model discrimination

Positive NLL advantage means that the true family predicts better.

| Design | Truth | Training truth selection | Validation truth selection | Mean training advantage / Person | Mean validation advantage / Person |
| --- | --- | ---: | ---: | ---: | ---: |
| complete | complete | 12/12 | 12/12 | 0.03557 | 0.02814 |
| complete | loading-only | 12/12 | 12/12 | 0.02805 | 0.02795 |
| balanced cycle | complete | 9/12 | 9/12 | 0.00479 | 0.00494 |
| balanced cycle | loading-only | 7/12 | 12/12 | 0.00342 | 0.00575 |

The balanced-cycle counts are too small to estimate a stable selection rate.
In particular, 12/12 validation selections under loading-only truth must not
be generalized. The result only establishes that the average holdout signal
has the expected sign and is much weaker than under complete crossing.

## Recovery and standard errors

These summaries use only fits of the true family.

| Design | Truth | Median relative-slope RMSE | Median absolute-slope RMSE | Median absolute population-SD error | Relative-slope 95% coverage | Population-SD 95% coverage |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| complete | complete | 0.0572 | 0.0699 | 0.0358 | 0.875 | 1.000 |
| complete | loading-only | 0.0594 | 0.0854 | 0.0451 | 0.958 | 1.000 |
| balanced cycle | complete | 0.1156 | 0.1220 | 0.0522 | 0.854 | 1.000 |
| balanced cycle | loading-only | 0.0772 | 0.1082 | 0.0282 | 0.958 | 1.000 |

Coverage denominators are only 48 slope coordinates and 12 population-SD
estimates per row. These observations do not freeze an SE calibration rule.

## Interpretation

1. In this moderate, well-supported condition, nonconvergence and distinct
   optimizer basins are not the primary problem.
2. Balanced cycle coverage materially reduces discrimination and worsens
   relative-slope recovery even though the Hessian remains full rank and
   positive definite.
3. A sole absolute gradient threshold of `1e-4` would reject some solutions
   whose two starts, curvature, quadrature comparison, and holdout behavior
   otherwise agree. This is evidence to review such a rule jointly with other
   diagnostics, not authority to weaken readiness.
4. Population-scale SEs were finite and conservative in this small pilot, but
   12 replications cannot establish coverage.
5. The next comparison should bind the complete-predictor arm to the actual
   public mfrmr MML fit and the loading-only arm to an independently specified
   external or repository kernel before expanding the simulation grid.

PublicFamilyAdded = FALSE

PublicModelSelectionEnabled = FALSE

ReadinessOverridden = FALSE

StandardErrorRuleFrozen = FALSE

PracticalThresholdFrozen = FALSE

ReleaseAuthorized = FALSE
