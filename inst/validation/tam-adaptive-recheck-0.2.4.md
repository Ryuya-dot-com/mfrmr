# Adaptive MML against the retained TAM stress cases

Date: 2026-09-14. Development version: 0.2.4.9000.

## Question and answer

Do the previously problematic RSM/PCM comparisons become stable when mfrmr
uses adaptive integration and TAM uses a sufficiently dense, wide grid?
Within all 36 retained cases, yes: the 72 primary macOS comparisons meet the
predeclared numerical criteria. The preselected ten-case Linux subset also
passes all 20 primary comparisons. This answers a numerical question about
these models and data; it does not establish interval coverage or override
the fits' separate identification/readiness decisions.

The [plan](tam-adaptive-recheck-0.2.4-plan.md) fixed the datasets, starts,
orders, comparison quantities and bounds before the new results. The
[runner and adjudicator](tam-adaptive-recheck-0.2.4.R) reuse the historical
generators and match every input SHA-256. Historical failed contracts and
their result files remain unchanged.

## What was compared, and why

The macOS run retains 21 RSM and 15 criterion-step PCM cases: baseline,
sparse rater assignment, 20% MCAR missingness, forced extreme responses and
weak exposure, with three replications. Six RSM cases estimate the normal
population intercept and variance; the other 30 fix N(0,1). Each case has
80 Persons, six Criteria and five Raters. Actual integer responses are used;
forced-extreme modifications are stress conditions, not correctly specified
recovery replicates.

Each case has five mfrmr fits (fixed Q31/Q61; adaptive Q15/Q31/Q61) and four
TAM fits (historical Q31/Q61; Q181/Q301 over [-8,8]). The historical RSM TAM
range is [-6,6], and PCM is [-8,8]. The prior, model, constraints and response
weights are matched. The comparison uses the full 90-coordinate cumulative
difficulty surface, rather than relying on differently constrained individual
parameter labels. Zero-weight support rows preserve TAM's design/category
range; its raw deviance and the existing real-row normalization are retained.

Two further checks prevent circular validation. TAM Q181/Q301 must be stable
before Q301 is treated as the reference. A separately expressed continuous
integral evaluates likelihood and posterior moments for every Person at the
adaptive-Q61 and TAM-Q301 parameters. This also checks TAM's deviance scaling
independently of cross-program parameter agreement.

There are 324 engine fits and 72 original restart probes on macOS; Linux
repeats the first replication of every fixed-prior model/profile combination,
giving 90 fits and 20 restart probes. All planned runs are retained, with no
engine execution failures. TAM finishes within 131 iterations on macOS and
102 on Linux, below the 1,000-iteration ceiling.

## Primary results

Every primary pair must satisfy the 1e-4 absolute bound for all six comparison
quantities, converge, have an mfrmr terminal gradient below 1e-4, and pass the
TAM order and independent-reference checks. `PrimaryPass` in the
[92-row result ledger](tam-adaptive-recheck-0.2.4-results.csv) combines these
conditions. It does not incorporate or rename formal-inference readiness.

| Maximum absolute difference or diagnostic | macOS | Linux subset |
| --- | ---: | ---: |
| Primary pairs satisfying all numerical conditions | 72/72 | 20/20 |
| Deviance, adaptive Q31/Q61 vs TAM Q301 | 1.19e-9 | 1.19e-9 |
| Complete cumulative difficulty surface | 1.075e-5 | 1.077e-5 |
| Person EAP | 1.942e-6 | 1.939e-6 |
| Person posterior SD | 1.183e-7 | 9.290e-8 |
| Population mean | 4.394e-7 | 0 (fixed) |
| Population variance | 3.601e-7 | 0 (fixed) |
| Primary mfrmr terminal gradient | 9.435e-5 | 9.435e-5 |
| Independent total log-likelihood discrepancy, either reference engine | 2.727e-10 | 1.010e-10 |
| Independent EAP discrepancy, either reference engine | 1.976e-8 | 1.002e-8 |
| Independent posterior-SD discrepancy, either reference engine | 6.118e-9 | 4.140e-10 |

All 7,360 independent Person evaluations meet the planned likelihood/moment
bound of 1e-7. Relative integration error is below 9.55e-12 and the omitted
relative mass bound is below 1.27e-64, both stricter than their declared
1e-9 and 1e-12 limits. These numerical error estimates/bounds are not sampling
uncertainty estimates.

## Order sensitivity and optimizer starts

On macOS, the historical fixed-grid comparison meets the 1e-4 bound in only
6/36 cases at Q31 and 15/36 at Q61. The maximum fixed-Q31/Q61 movement is
1.85 in deviance, 0.0203 on the cumulative difficulty surface, 0.0722 in EAP
and 0.0848 in posterior SD. Only 9/36 meet the 1e-3 order-review bound.
Repairing tiny Hermite weights therefore did not make low fixed orders
sufficient for every concentrated posterior.

In contrast, adaptive Q31/Q61 meets the order-review bound in all 36 cases;
the maximum surface change is 1.85e-8, EAP change 6.23e-10 and SD change
5.82e-11. Adaptive Q15/Q31 also passes this diagnostic in all 36 cases, but
Q15 remains a diagnostic order, not a newly recommended default. TAM
Q181/Q301 passes in all 36 cases, with maximum surface movement 1.57e-7.

All 1,436 saved adaptive-Q31/Q61 free-coordinate covariance diagonals have
status `ok` and are finite and positive. The largest order change in their
square-root SEs is 8.56e-11 (relative 5.11e-10). This is numerical stability
of mfrmr's observed-information calculation, not cross-program SE equivalence
or evidence of nominal coverage.

The original standalone BFGS restarts reach nearly identical objectives and
parameters, but only **69/72 macOS and 19/20 Linux** restarts meet the gradient
criterion. The largest remaining gradient is 3.64e-4; maximum parameter
movement is 6.61e-6 and NLL movement 5.92e-10. A code-zero stop and a close
objective are thus insufficient to declare every optimizer trial stationary.

The explicitly post-hoc follow-up reruns all four failing trials from their
original starts using the existing public optimizer policy. All four then
meet the gradient criterion with L-BFGS-B (maximum 7.07e-5), without needing
additional polish stages. Original BFGS failures remain in the denominator.
This supports a stopping-policy explanation for these trials, not a proof
that arbitrary starts or larger models always find a global optimum.

## Readiness and platform limits

Only 48/72 macOS and 16/20 Linux primary fits have `InferenceReady=TRUE`.
The weak-exposure designs rely on a common latent population to connect
otherwise disconnected panels (`population_assumption_linked`); estimated-
population fits retain `design_rank_not_evaluated`. Neither restriction was
removed because the engines agree. The raw ledger preserves 45 macOS and ten
Linux warnings about population-assumption linking.

The [90 matched platform comparisons](tam-adaptive-recheck-0.2.4-platforms.csv)
cover all nine engines/orders in the ten selected cases. Across adaptive
fits, the maximum macOS/Linux surface difference is 1.17e-8 and EAP difference
3.94e-10. This is a two-platform check of the selected subset, not a Windows
or full OS-matrix result.

macOS uses R 4.6.1 and the current source-loaded package; Linux uses R 4.3.2,
the previously checked installed 0.2.4.9000 archive and TAM 4.3.25. The current
R/native implementation files are byte-identical to that checked archive.
The two mfrmr `fit_mfrm` formals/body text dumps match exactly, although their
serialized hashes differ. The TAM formals/body dumps differ only in the
rounding of the approximately 1e100 initial deviance sentinel; the two raw
runtime identities are recorded separately. No numerical acceptance bound
was changed to accommodate an installation difference.

## Reproduction and retained artifacts

From the development root, with mfrmr and TAM installed:

```r
library(mfrmr)
source("inst/validation/tam-adaptive-recheck-0.2.4.R")
run_tam_adaptive_recheck("/tmp/tam-recheck/macos", "macos")
# Run the analogous call in Linux with its registered TAM installation.
run_tam_adaptive_recheck("/tmp/tam-recheck/linux", "linux")
summarize_tam_adaptive_recheck("/tmp/tam-recheck", "/tmp/tam-recheck/summary")
followup_tam_adaptive_restarts("/tmp/tam-recheck/macos")
followup_tam_adaptive_restarts("/tmp/tam-recheck/linux")
```

The durable raw bundle is
`validation-results/adaptive-external-recheck-20260914/`: inputs, fit RDS
objects, all comparisons, Person scores, independent references, covariance
diagonals, restart/follow-up stages, runtime identities and logs. It is excluded
from the distributed package by the existing build rules. The
[source and evidence manifest](adaptive-external-recheck-0.2.4-source.csv)
binds the calculation sources and raw evidence. The macOS main run started
before the Linux-only hash guard and postprocessing functions were added;
its numerical loop was not changed during execution.

This increment also completes the separate
[ConQuest point-estimation and posterior-scoring review](conquest-adaptive-recheck-0.2.4.md).
The MML vignette now explains adaptive order review and separate ConQuest
posterior controls. Its executable example and documentation checks are
recorded in that shared verification record.

## What remains

The fixed integration default is unchanged. The
[Hermite-weight repair](gauss-hermite-weight-repair-0.2.4.md) and these adaptive
comparisons address different numerical mechanisms. Neither constitutes
scientific equivalence, GPCM identification/boundary certification, an
anchor/linking transport study, or a release decision.

The next statistical question is whether reported uncertainty has its claimed
meaning under repeated integer-response sampling. That needs predeclared
recovery and coverage experiments with enough replications, explicit handling
of failed/unsupported fits, and clearly separated calibration and Person
uncertainty. The present three-replication stress conditions cannot answer it.
