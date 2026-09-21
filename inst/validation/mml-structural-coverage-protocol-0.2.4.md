# RSM/PCM structural uncertainty: first repeated-sampling protocol

Date: 2026-09-09. Status: fixed before new simulation outcomes; preflight
and confirmation execution pending. This is a bounded C05 study under the
[controlling roadmap](internal-roadmap-0.2.3.md), not complete release approval.

## Question and why this design answers it

When the response model and fixed standard-normal Person population are
correct, do the package's structural SEs describe repeated-sampling variation,
and do its normal intervals cover the actual constrained parameters?
The [independent information checks](mml-independent-information-conditions-record-0.2.4.md)
established scoped numerical agreement. They did not answer this sampling
question. We follow the separation of aims, generation, estimands, methods
and performance measures described by [Morris, White and Crowther (2019)](https://doi.org/10.1002/sim.8086),
including Monte Carlo uncertainty. The practical bounds below are this
study's explicit review choices, not thresholds supplied by that paper.

Eight cells cross RSM/PCM, 80/320 Persons, and 3/6 ratings per Person. Every
cell retains three Raters, two Criteria and categories 0--2. Keeping the
parameter dimension fixed separates the effect of more independent Persons
from the effect of additional responses within a Person. Three-rating
assignments alternate complementary Criterion patterns across Persons:
retain a row when `(person_index + rater_index) %% 2 == criterion_index - 1`.
Every Person has each Rater once, every Rater sees both Criteria across the
sample, and all structural levels remain linked. Six-rating assignments
are fully crossed. Missingness is planned independently of ability/response;
there is no response-based selection or regeneration of extreme patterns.

Rater effects are `(0.3, -0.1, -0.2)` and Criterion effects `(0.4, -0.4)`.
RSM thresholds are `(-0.6, 0.6)`; PCM Criterion ladders are `(-0.7, 0.7)` and
`(-0.2, 0.2)`. Each dataset draws independent standard-normal Persons and
conditionally independent ordinal ratings. The preceding independent
generator supplies the probabilities and explicit parameter maps; its
new optional Person-count/assignment arguments preserve the original default
fixture exactly. Unit weights, fixed population, no anchors/interactions,
and no post-hoc recentering or truth-dependent correction are used.

The targets are each expanded Rater and Criterion effect, each expanded
threshold, all three Rater differences, and the Criterion difference.
Signs or deterministic redundancies remain visible but do not add
independent replications. Person EAP/posterior-SD coverage, TOST operating
characteristics, heterogeneity-test size/power, estimated populations,
weights, anchors, GPCM/JML, population misspecification and long/sparse
designs beyond these assignments are outside this study.

## Estimation and numerical accounting

Use the current direct MML estimator, q61, maxit 200 and reltol 1e-10.
Reuse the production observed-information covariance and facet/step SE
builders. Form contrasts using the independently specified coordinate map;
verify their agreement with the public diagnosis/equivalence routes in
preflight. Main-run intervals use estimate +/- qnorm(0.975) * SE. They are
ordinary 95% normal intervals, not the 90% intervals used for TOST.

Every fit also evaluates the objective, score and information at the same
fitted coordinates using q121. Record absolute objective change, maximum
relative SE change and the maximum q121 Newton displacement divided by q61
SE. Numerical checks require respectively <= 1e-6, <= 0.001 and <= 0.001,
with unregularized positive-definite covariance at both grids. The Newton
quantity is a local stationarity diagnostic, not an actual refit movement.
These stringent numerical differences are intended to be negligible beside
sampling SE; they are not a universal quadrature certificate.

Preserve every assigned dataset, finite estimate, fit error, covariance
failure, readiness state and warning. Define interval availability by fit
inference readiness, unregularized q61 covariance and a finite positive SE;
numerical q121 discordance does not remove an otherwise available interval
from primary coverage. Report ready-but-numerically-discordant fits separately.
Any such reproducible counterexample prevents a supported cell conclusion.
Do not silently refit, change grids or replace datasets to erase it.

## Replications, precision and decision rules

Use 2,500 independent datasets per cell (20,000 total). At coverage 0.95,
MCSE is 0.00436, giving an approximate 95% half-width of 0.85 percentage
points. The worst-case rate MCSE is 0.01. This precision can distinguish
nominal coverage from the prespecified two-percentage-point review margin;
the actual interval, not the planning calculation, determines disposition.

For each coordinate, report all finite-estimate bias/RMSE and their MCSEs;
then, on the same interval-available repetitions, report bias, empirical SD,
mean SE, RMS SE, RMS-SE/SD ratio, standardized bias, coverage and mean width.
This avoids comparing SE from one subset with empirical SD from another.
Also report available-and-covered divided by all assigned datasets; it is
a joint usability rate, not conditional coverage.

Use exact two-sided 95% binomial intervals for availability, coverage and
ready-but-numerically-discordant rates, including zero-event cases. For
standardized bias and RMS-SE/SD, use first-order empirical influence-function
MCSEs and normal 95% MC intervals, retaining skewness/outliers for review.
For ratio `r = sqrt(A/V)`, `A = mean(SE^2)` and `V = var(error)`, the influence
values are `r/2 * ((SE^2-A)/A - ((error-mean(error))^2-V)/V)`.
For standardized bias `b/s`, use
`(error-b)/s - b*((error-b)^2-V)/(2*s^3)`.
These are MC intervals for performance estimates, not data-analysis CIs.

Per coordinate, a **supported-in-cell** result requires:

- The conditional-coverage MC interval lies wholly in [0.93, 0.97]. A two
  point shortfall would raise misses from 5% to 7%; excessive coverage also
  indicates miscalibrated width. This is a stated practical margin.
- The RMS-SE/SD MC interval lies wholly in [0.90, 1.10], and standardized
  bias's interval wholly in [-0.10, 0.10]. The former rejects material scale
  errors; the latter keeps mean error small relative to sampling uncertainty.
- Availability's exact lower bound is >= 0.99. With this regular design,
  failures in more than about 1% of intended analyses are a usability concern.
- No ready numerical counterexample is observed, and its exact upper rate
  bound is <= 0.002. At 0/2500 the upper bound is about 0.00147, not zero.

A performance MC interval wholly outside its acceptable range is **concern**;
overlap with a boundary is **review**, not pass. Availability uses analogous
one-sided range comparisons. An observed ready numerical counterexample is
concern regardless of its estimated rate. A cell is supported only when all
declared coordinates meet their criteria. MC intervals are coordinatewise;
no simultaneous interval claim or pooled-coefficient replication count is
made. Missing estimates or an incomplete run cannot produce support.
Criteria will not be tuned to these outcomes; any substantive redesign needs
a new stated protocol and fresh confirmation seeds.

## Preflight, seeds and resources

Preflight uses five separate datasets per cell only to check execution,
generation, API agreement, numerical diagnostics and timing. It supplies no
coverage conclusion and is excluded from confirmation summaries. Cell order
is RSM then PCM; within model use N=80 then 320, with exposure 3 then 6.
Preflight seeds are `51000000 + 10000*cell + replicate`; confirmation seeds
are `61000000 + 10000*cell + replicate`. These fixed, disjoint identities are
independent of execution order. There is no reuse of earlier pilot datasets.

Time the actual preflight pipeline before launching confirmation. Use at most
three local worker processes, preserving a full cell's replication order;
no agent delegation or external service is required. Save compact per-cell
results periodically, with seed, point estimates, SEs and status for every
attempt. Resume only the identical source/protocol payload. A four-hour
wall-clock ceiling is a resource stop, not a statistical stopping rule or a
pass; incomplete results remain incomplete. Do not stop early for apparently
good/bad coverage. A demonstrated implementation defect may pause execution
for correction; retained results then remain exploratory until source
applicability and a fresh confirmation plan are resolved.
