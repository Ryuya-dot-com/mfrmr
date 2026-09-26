# Separate-owner GPCM diagnostic pilot

Protocol fixed before generating the pilot datasets on 2026-09-26. Implements
roadmap D1; this is not a release or coverage-qualification study.

## Question and model

Can the connected MML workflow estimate criterion discrimination and
rater-specific steps when the rater assignment is incomplete? Compare complete
ratings with a connected rotating assignment at N=120 and N=400. Three fixed
raters have locations (-0.25,0,0.25); two criteria have locations (-0.15,0.15),
relative slopes (0.8,1.25), and one N(0,1.2^2) ability per Person. Rater steps are
(-0.8,0.8), (-0.45,0.45), (-1,1). Categories are 0,1,2. Scalar adjacent logits
are alpha[criterion]*(theta-rater-location-criterion-location-rater-step).
Normalize cumulative logits independently of the fitting probability helper.
This is the generating model already used for the fitted workflow check.

The incomplete design omits rater 1+(Person index mod 3), retaining two raters
and both criteria for each Person. Assignment is fixed independently of ability
and scores; unassigned rows are absent, not imputed. Complete and incomplete
conditions within a replicate share the full generated data and seed. Separate
replicates and sample sizes use distinct seeds (926800+100*N+replicate).
This paired comparison does not describe informative missingness or all sparse
assessment designs. Rater and criterion levels are fixed, not sampled effects.

## Estimation and targets

Use the connected source after commit 6bae178a, recording a hash of all R sources,
this protocol and the runner. Fit GPCM MML, step_facet=Rater,
slope_facet=Criterion, free_population identification, fixed 31-node integration,
maxit=400, reltol=1e-10, rating_min=0, rating_max=2 and preserved categories.
Use the existing output-specific numerical/information/quadrature eligibility
without changing any threshold, dropping categories or retrying selected failures.
Record the resolved integration settings; source changes invalidate this run.

* Two relative slopes: point bias/RMSE across finite fitted estimates and
  public confint() pointwise 95% log-Wald intervals where eligible.
* Six step parameters: point bias/RMSE only. No new step-interval claim.
* Category probabilities: public mfrm_curve_intervals() pointwise 95% intervals
  for all three categories at theta -1,0,1 in each of six rater/criterion
  contexts (54 targets). Truth includes both facet locations, unlike the
  zero-location reference CCC display. No simultaneous-coverage claim.

Each dataset, not each dependent target, is the repeated-sampling unit.
Summarize each target separately, and show the range across probability targets.
Retain errors, warnings, convergence code, information status, eligibility reasons
and elapsed time. Point-estimate error uses all finite estimates and reports its
count; it is not restricted to datasets with intervals. Distinguish availability,
coverage conditional on an available interval, and the proportion of all planned
datasets both reported and covered. Do not count an unavailable interval as a
known statistical miss: also report worst/best bounds allowing unresolved cases.
Exact binomial 95% Monte Carlo intervals describe each per-target empirical
proportion; they do not provide simultaneous inference over 54 targets.

## Size, computation and decision

Twenty replicates in each of four cells (80 fits) are fixed before execution.
The first replicate in each cell is included in the 80 and measures execution
cost and extraction correctness. Continue the remaining fits only if the
projected total is within a 15-minute local computation budget; interruption
retains every completed case and planned-but-unrun rows. No nested bootstrap,
new optimizer comparison, PCM LRT calibration or extra condition is part of
this pilot. Existing independent kernel/gradient, unit-slope PCM reduction and
confounded-design rejection checks are reused.

Twenty observations cannot establish 95% coverage. Even 20/20 covered has a
95% exact lower confidence bound near 0.83. Completion means a recorded numerical
and extraction check plus an explicit next decision: repair a reproducible
defect, narrow the scope, or design a separately registered confirmation with
Monte Carlo precision and measured cost. No automatic condition expansion,
optional result-driven continuation or generic coverage guarantee follows.
