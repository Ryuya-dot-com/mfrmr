# Population full-solution score and information review

Date: 2026-09-10. Bounded review complete; the original design was fixed before
execution and is retained in the archive. This numerical review does
not relax the [population-output contract](population-output-contract-record-0.2.4.md).

## Question and bounded design

At the actual free-population estimates, are *all* likelihood derivatives small,
including the derivative with respect to log residual variance? Is the inverse
observed information, including nuisance covariances, stable across quadrature
and consistent with an independently integrated likelihood?

Reuse the four datasets in the identification/profile reviews: the RSM/PCM
latent-regression examples, paired binary control and exactly unidentified
single-rating control. Refit each through the current public direct-MML path at
q31, q61 and q121 (12 fits), with maxit 300 and reltol 1e-10 and the package's
ordinary initialization. These are not independent statistical replications or
a global multistart search. Preserve all warnings, failures and returned fits.

At each returned vector, evaluate the independent continuous-normal objective
and its full central gradient at relative steps 1e-4 and 5e-5. Compute full
central Hessians at absolute steps .001 and .0005 using the existing independent
probability kernel, adaptive integral and Hessian helper. These include both
population regression coefficients and log variance. For each *same* vector,
evaluate the package objective, analytic score and raw observed-information
Hessian at q31, q61, q121 and q241. This separates integration error from movement
in the refitted parameters. Do not alter the source fit's retained grid or flags;
use a local copy to request each covariance evaluation.

Retain the preceding bounds: objective difference 1e-6, gradient-step and
analytic/independent gradient difference 1e-7, full gradient norm 1e-4;
Hessian-step relative, scaled Hessian/covariance entry, and relative SE agreement
1e-5. These are diagnostic audit comparisons, not production thresholds.
Record all failures without changing bounds or selecting away unfavorable rows.

Compare inverse observed information only when both independent Hessians are
positive definite and the model has no known exact ridge. Never regularize the
reference matrix or interpret clipped package eigenvalues as finite precision
for the negative control. Retain raw eigenvalues, condition numbers and package
regularization status. Report free-coordinate SEs and independent expanded
facet/step maps; the natural-variance SE uses the delta derivative `exp(lambda)`
and is a numerical transformation, not a calibrated interval. The full inverse
is required: nuisance parameters must not be held fixed when calculating these
SEs. No Person EAP/interval calibration or joint Wald/TOST validation follows.

Compare q31/q61 refits with the q121 refit in common coordinates, reporting
parameter movement in q121 reference-SE units and maximum relative free/expanded
SE changes. Retain the previous .001 diagnostic drift bounds. Finally, evaluate
full independent gradients at the two q961 variance-16 RSM/PCM profile vectors
that passed nuisance-only checks. This tests the distinction between a fixed-
variance profile solution and a fully stationary free-population estimate;
do not compute inferential SEs at these off-solution probes or repeat tail fitting.

Preserve source/input identities and current scoring/inference restrictions.
No optimization, likelihood, Hessian or readiness production code is changed by
this review. Existing independent information fixtures already cover the basic
algebra; this review specifically binds full stationarity and grid sensitivity
to the retained population examples and negative control.

## Full-solution and information results

All 12 fits returned with native convergence passing. All 12 independent full
gradient norms are below 1e-4, with gradient-step differences below 1e-7. This
includes log variance; it is not the nuisance-only stationarity of the preceding
profile study. The largest independent full gradient is 6.6824e-5.

The RSM, PCM and paired control have positive-definite independent Hessians at
all three fitted vectors. All 36 same-vector information/SE comparisons for
these three cases meet the original 1e-5 bounds without regularization.

| Case | Fitted variance (q121) | Largest full gradient over three fits | Independent SE of log variance (q121) | Delta-method SE of variance (q121) |
| --- | ---: | ---: | ---: | ---: |
| RSM latent regression | 0.673962 | 6.6824e-5 | 0.325972 | 0.219693 |
| PCM latent regression | 0.582496 | 6.4750e-5 | 0.327555 | 0.190799 |
| Paired binary control | 1.561533 | 2.9366e-6 | 0.761564 | 1.189207 |

The smallest information eigenvalues are approximately 8.905, 8.764 and 1.652;
condition numbers are approximately 22.06, 24.39 and 20.15, respectively. These
describe observed information for the retained data/parameterization, not
sampling coverage or a generally safe condition-number threshold. All SEs above
use the full inverse Hessian, including nuisance covariances. They remain
diagnostic numerical results under the population-output restriction.

Across the 36 comparisons, the maximum scaled Hessian-entry discrepancy is
6.1761e-7 and the covariance-entry discrepancy is 7.9489e-7. The maximum relative
free/expanded SE discrepancy is 3.9745e-7, or about **0.000040%**. The maximum
Hessian-step relative difference is 4.1653e-8. These support the numerical
calculation at these fitted interior points, not the finite-sample calibration
of a normal interval or of the variance-scale delta method.

## Integration error versus refitting movement

All 48 objective comparisons satisfy 1e-6. At evaluation q31, however, the
RSM/PCM analytic-versus-independent score differences (up to 4.2113e-7) exceed
the unchanged 1e-7 derivative-agreement bound at all six fitted vectors. These
six comparisons retain `NumericalAgreement = FALSE`; the small discrepancies
were not rounded away or accepted by widening the bound. At q61/q121/q241,
their largest score discrepancy is 2.0682e-8. Both binary controls meet the
score-agreement rule at all evaluated grids.

The q31-versus-q121 refit parameter movement is at most 4.2883e-8 in free
coordinates, or 1.3156e-7 q121 reference SEs. Across the positive-information
cases, the maximum package SE change after refitting is 2.0309e-7 relative
(0.000021% rounded upward); the independent-reference SE change is at most
2.2307e-7. Reference finite-difference SEs can move at this numerical scale
even when fitted vectors differ only around 1e-13. All six applicable refit
drift comparisons meet the previous .001 diagnostic bounds.

Thus the strict q31 score discrepancy and the extremely small SE movement
are distinct findings. These short response-pattern examples do not erase the
earlier long-pattern or large-variance integration failures, and do not select
61 or any other grid as a universal production default.

## Negative control and fixed-variance probes

The single-rating control is stationary and satisfies every objective/score
comparison, yet its exact variance/difficulty ridge still precludes a unique
full-parameter covariance. Its independently differenced smallest Hessian
eigenvalue varies from about -4.96e-8 to 1.49e-7 around the theoretical zero.
A tiny positive numerical eigenvalue is not evidence that the ridge vanished.
All 12 package covariance evaluations are explicitly `regularized`. The audit
therefore leaves the independent covariance/SE unavailable and records its
information comparisons as inapplicable to ordinary inverse-information
precision. At q121, for example, the clipped package result has a log-variance
SE around 2,074; this is retained as a regularized diagnostic, not a usable
sampling SE. Stable fitted parameters across grids also do not resolve exact
nonidentification.

The two retained variance-16 profile probes demonstrate why nuisance-only
qualification cannot be promoted:

| Probe | Nuisance gradient norm | Derivative with respect to log variance |
| --- | ---: | ---: |
| RSM, q961 profile | 7.9071e-8 | 31.28333 |
| PCM, q961 profile | 6.7758e-7 | 32.98074 |

Their finite-difference step discrepancies remain below 4.832e-8. Lowering
variance improves the objective locally even though the remaining parameters
are nearly stationary at fixed variance. These vectors are not free-population
solutions, and no inferential SEs were computed for these probes. The two
unqualified variance-64 profiles were not refitted or reclassified here.

## Verification, retained evidence and next work

The complete numerical run took 273.388 seconds (about 4 minutes 33 seconds).
There were no execution errors. Each of the three single-rating fits retains
the same five warnings as the earlier review: three Matrix notices and two
population-link/design warnings. Other fits have no warnings. The two focused
quadrature/stationarity test files pass 99 expectations, with no failures,
errors or warnings and one intentional historical-GPCM replay skip.
The documentation/readiness protocol adds 834 passing expectations; the total
is 933 across three files. Replay verification also checks full-coordinate
dimensions, raw `H V = I` residuals, singular-control covariance exclusion,
the two variance-direction probes, and unchanged production-source identities.

The [fit summary](population-full-information-summary-0.2.4.csv),
[same-vector comparisons](population-full-information-grids-0.2.4.csv),
[coordinate SEs](population-full-information-targets-0.2.4.csv),
[refit drift](population-full-information-drift-0.2.4.csv),
[test results](population-full-information-tests-0.2.4.csv),
[execution log](population-full-information-execution-0.2.4.log) and
[archive](population-full-information-evidence-0.2.4.rds) retain every fit,
warning, raw Hessian and covariance status, independent derivative step,
coordinate map, fixed-variance probe, source snapshot and input identity.
The negative control and the six q31 score disagreements remain in the archive.
Reproduce into a fresh directory without replacing the dated evidence:

```sh
Rscript inst/validation/population-full-information-0.2.4.R /tmp/population-full-information-replay
```

The answer is now bounded but concrete: at these interior RSM/PCM and paired
solutions, full stationarity and inverse-information SE calculations have
independent numerical support; exact ambiguity still defeats covariance in the
single-rating control. Next specify a narrowly scoped population-model
recovery/coverage study with explicit treatment of unidentified, boundary and
numerically unavailable fits. Do not discard such fits from reporting or use
simulation success as a global identification/boundary proof. Person-score and
joint-decision calibration remain separate. No production code, readiness
restriction, prior archive or default integration rule was changed. A full
package/OS release check was not repeated, and release review remains open.
