# Population/slope nuisance profiles: bounded current-source check

Protocol written before running profiles, 2026-09-26. This implements the next
P1 step in ROADMAP, not a new public interval or scoring-acceptance rule.

Question: does freeing nuisance parameters reveal competing or improving
solutions that the earlier fixed-nuisance paths could not assess?

Reuse two retained synthetic fits: shared Rater-owned slopes/steps from
`gpcm-probability-refit-20260925/refit-788.rds` (40 Persons), and separate
Criterion slopes/Rater steps from the 41-node fit in
`portable-gpcm-development-probe.rds` (120 Persons). These are the fixed-model
comparison family and current separate-owner probe, chosen for ownership
coverage, not because the new profile outcome is favorable. They are not
representative of all sparse or pathological data. Existing analytic binary
boundary controls and historical variance-boundary records remain separate.

For each fit, hold either log population variance or the first relative log
slope fixed. The first slope is exactly the first free log-slope coordinate;
the remaining expanded log slopes retain their sum-zero constraint. Reoptimize
all other free coordinates, including population mean and variance during
slope profiling and slopes during variance profiling. Use variance offsets
(-4,-2,-1,0,1,2,4) and slope offsets (-3,-1.5,-.5,0,.5,1.5,3) about the retained
coordinate. This is a finite diagnostic range, not either mathematical limit.

Each point starts independently at the retained and all-zero free vectors.
Also run both unconstrained starts as reference solutions. In total: 56
constrained and 4 unconstrained attempts. Use the current likelihood/analytic
derivatives, adaptive 31-node integration, BFGS with maxit 400 and reltol 1e-10;
if the existing 1e-4 nuisance-gradient rule fails, allow one BFGS refinement
at 1e-13, retaining both stages and objective/gradient comparisons. Invalid
numeric boundary proposals use the existing safe-objective wrapper; final
values/gradients use the unwrapped evaluator. No parameter bounds are added.

Reevaluate every returned vector at adaptive 61 nodes. A nuisance result is
qualified only with optimizer code zero, finite coordinates and nuisance
sup-gradient <=1e-4. Integration movement above 1e-5 NLL and two-start common-NLL
disagreement above 1e-5 require review, not post-hoc tolerance adjustment.
Check the fixed-coordinate derivative against a central difference (step 1e-5).
Retain all failures and starts; a lower finite value is not automatically a
qualified profile point. Derivative disagreement above 1e-5 requires review.

Before interpreting a profile, use the existing independent scalar continuous
integration reference at baseline and the two finite tails for both targets,
selecting the lower common-NLL *qualified* start at each point. Retain points
without a qualified start as unresolved. Reference range refinement and tail
bounds follow the existing continuous-reference criteria. No global maximum,
boundary exclusion, profile-LR interval or nominal coverage follows merely
from this grid. Do not connect unresolved points as a supported profile.

The run stops at a 600-second between-case computation budget and keeps any
unexecuted rows explicit. No automatic denser grid, new simulation, universal
boundary theorem or readiness promotion follows. A reproduced defect changes
the next action to repair; otherwise report what the bounded profiles resolve
and what additional mechanism remains untested. Source, inputs and this plan
are hashed before execution. The old P1a fixed-coordinate/nuisance decomposition
and current optimizer controls/diagnostics are reused conceptually; the old
row helper does not return parameter vectors, so the small current runner
retains them for independent common-objective checks.


## Completion amendment (before the remaining 19 attempts)

The initial 600-second checkpoint stopped after 41/60 attempts, leaving the
separate-owner comparison unbalanced. On user review, this is a checkpoint,
not an adequate completion criterion. Complete all 19 originally planned
attempts with the same inputs, likelihood, grid, starts, iteration limits and
qualification thresholds. Do not rerun the completed 41 or add grid points.
There is no additional total elapsed-time cutoff for this finite remainder;
per-optimizer iteration limits remain unchanged. Preserve the original
manifest, frozen protocol and result vectors, verify their input/source hashes,
and record the resumed runner separately. Existing one-step curvature results
remain a distinct follow-up and do not overwrite the original BFGS outcomes.

Apply the same one-step curvature follow-up to any newly returned failed
constrained points, preserving and reusing the eight completed follow-ups.
Complete this finite set without a second total-time cutoff. Reuse saved
independent reference integrals for unchanged parameter vectors; evaluate any
newly selected endpoint vectors by the same reference criteria.


## Completed finite-grid results

All 60 planned attempts were executed: 56 constrained profiles and four
unconstrained fits. There are no unexecuted rows. The original 41 result files
were verified unchanged against the resumption manifest. The remaining 19
used 345.002 seconds of summed per-case elapsed time (all 60: 957.418 seconds),
excluding reference integration and follow-ups. A ten-minute checkpoint was
useful for cost review but did not justify ending an unbalanced two-start
comparison. Completion now refers to the declared grid, not elapsed time.

| Result from the original BFGS attempts | Count |
| --- | ---: |
| Attempted | 60 |
| Returned a finite evaluated result | 59 |
| Passed the optimizer-code/nuisance-gradient rule | 43 |
| Returned but failed that rule | 16 |
| No returned solution (local posterior scale error) | 1 |
| Integration movement above 1e-5 NLL (overlaps the 43 passes) | 6 |

The additional 19 contain ten original stationarity passes, eight stationarity
failures, and one error. The prespecified single curvature proposal resolves
14/16 returned stationarity failures, including all eight additional ones,
without relaxing either threshold; their adaptive-31/61 movements pass.
The shared-owner positive-slope tail from both starts remains unresolved
(`profile-14`, `profile-42`): the existing proposal did not improve the gradient
without worsening the objective. Original outcomes remain separate from the
follow-up. This is evidence about constrained-search stopping precision, not
proof of a public fitter defect or completed profile-interval implementation.

Both unconstrained starts agree closely: common negative log likelihoods are
212.909402644 (shared) and 700.877851640 (separate), with within-owner differences
below 9e-11. Among original constrained pairs with two stationarity-qualified
results, the maximum common-NLL difference is 4.25e-7, below the declared 1e-5.
No qualified sampled point improves on its unconstrained baseline beyond that
tolerance. Maximum fixed-coordinate derivative error is 3.36e-8. These are
finite-range local checks, not exclusion of remote or limiting solutions.

Six original attempts exceed the integration-movement criterion: shared
log-variance offset +4 at both starts, and separate offsets +2 and +4 at both
starts. Independent continuous references meet their own refinement/error/tail
criteria at seven selected baseline/tail vectors. At separate variance +4,
adaptive-61 differs from the reference by 0.00263593 NLL; using 61 nodes alone
therefore does not resolve that integration failure. The corresponding shared
+4 difference is 6.07e-7. Baseline differences are below 3e-13. Three selected
slope-tail points have no qualified original result and remain explicitly
unresolved in the reference table; a successful curvature proposal is not
silently substituted for the original vector.

One previously unexecuted attempt, separate log-variance offset -2 from the
neutral start (`profile-44`), fails twice with `Invalid local posterior scale.`
This is a numerical evaluation failure during constrained search, not evidence
that the fitted population is invalid. It would have been missed by stopping
at 41 attempts. The targeted replay reproduces the error at the same trial
vector in both BFGS stages: population variance 0.214155, population mean
101.893773, and slopes 3.681082e-255 and 2.716593e+254. Slopes themselves are
finite and positive but their squares are not representable. The current
adaptive person kernel forms `slope^2` when calculating local information,
while the safe objective catches typed slope/variance errors only. This
identifies a numerical trial-evaluation failure requiring explicit handling;
it does not prove a mathematical boundary optimum or justify a finite fitted
slope cap. Preserve the failed original search and `failure-replay-profile-44.rds`.

P1 remains open. Next resolve constrained-search trial handling and the two
remaining tail searches, and verify integration where high variance changes
the objective materially. Do not expand the grid before addressing these
observed mechanisms. Population-assumption sensitivity (P3), output-specific
acceptance (P2/P4), profile-interval coverage and portability are not completed
by this experiment. No public readiness/default, help or NEWS change is claimed.

Evidence is under `validation-results/gpcm-joint-profile-20260926/`: original
and resumption manifests, original per-attempt vectors/stages, `rows.csv`,
`paired.csv`, `continuous-reference.csv`, and separate `curvature-review.csv`.
The focused coupled-quadratic/failure-retention test passes ten expectations;
no full test suite or new simulation was run for this investigation.

## Repair protocol (before targeted reruns)

After typing nonfinite adaptive calculations and making the objective cache
transactional, rerun only failed `profile-44` from its original neutral start
with unchanged BFGS controls and thresholds. For `profile-14` and `profile-42`,
reuse the existing curvature-coordinate transform, then perform one constrained
BFGS search (the same two tolerances/maxit) from each retained vector. Check
stationarity in native coordinates, not transformed gradient units. Preserve
all originals and new errors/results separately. This transform is numerical
preconditioning, not an estimated covariance matrix or a parameter bound.

At saved high-variance vectors `profile-07`, `profile-20`, `profile-21`, evaluate
adaptive orders 61, 121, 201, 301 without refitting. They represent the three
failed integration conditions; their two original starts already have
matching objectives. Compare with the existing independent continuous
reference, supplying the same reference calculation for offset +2 if needed.
Keep 1e-5 NLL and 1e-4 nuisance-gradient criteria. Higher-order agreement alone
cannot establish nuisance stationarity at that order. Determine any targeted
refit only from these observed discrepancies; no larger condition grid or
repeated simulation is part of this repair check.

Higher-order evaluation reveals a remaining native nuisance gradient of
0.0783 at the separate +4 variance point, despite NLL agreement with the
independent integral within 1.4e-7 at order 301. The other two high-variance
points also exceed the gradient criterion when reevaluated. Therefore refit
these three existing conditions at order 301 from their retained vectors,
with the same BFGS controls and at most one existing curvature proposal if
the native gradient fails. Compare to order 201 at the resulting parameters
and to independent continuous integrals (ranges 32/64, original criteria).
Check the newly repaired three search vectors by that independent reference
as well. This repairs the diagnosed objective approximation; agreement of
likelihood values alone is insufficient. Preserve both new and old results.

Once the repaired searches have been reviewed, also check the previously
unqualified negative slope endpoints using their saved one-step curvature
vectors (`profile-08`, `profile-22`). This finishes the original baseline/tail
reference coverage; it adds no optimizations or profile conditions. Keep
original, curvature-corrected and higher-order results distinguishable.


## Repair results and current disposition

The package now emits a specific numeric condition for nonfinite adaptive
moments, integration terms and adaptive objective/gradient calculations. The
direct optimizer rejects only that condition (plus the existing typed slope
and population-variance conditions), allowing its line search to shorten the
step. Other errors are still propagated. Starting parameters are evaluated
without the penalty, and terminal gradients still use the unwrapped evaluator.
The direct objective cache publishes a parameter key only after a successful
evaluation, preventing repeated rejected trials from returning a stale value.
A separate adaptive-rejection count is retained in optimizer diagnostics.
No slope bound, readiness relaxation or changed likelihood formula was added.

The failed neutral-start search (`profile-44`) now returns NLL 729.005258816226
and nuisance gradient 6.61e-6, matching the other start's solution. The two
shared-owner positive-slope tails, after the existing curvature-coordinate
rescaling, both reach NLL 223.812329821015 with native gradients 8.09e-6 and
4.91e-6. Their independent continuous NLL discrepancies are below 2.64e-9.
This resolves the observed search failures for these cases; it is not a
certificate about every start or an infinite-slope limit.

| High-variance condition | Order-301 nuisance gradient after refit | Absolute NLL discrepancy from independent integration |
| --- | ---: | ---: |
| Shared owner, log-variance offset +4 | 1.53e-5 | below printed precision |
| Separate owners, offset +2 | 9.66e-5 | below printed precision |
| Separate owners, offset +4 | 4.75e-6 | 1.37e-7 |

The 201/301 NLL discrepancy is at most 1.51e-6 and nuisance-gradient discrepancy
at most 3.61e-5. These are warm-start refits of the three diagnosed conditions,
not a new independent two-start study at order 301. Raising the default
quadrature order for all users is not justified by these constrained extremes.
The independent reference checks also pass for the corrected negative-slope
tails (`profile-08`, `profile-22`). All eight new reference evaluations pass
the original reference criteria and the 1e-5 NLL agreement criterion; all eight
vectors meet the unchanged native 1e-4 stationarity criterion. Original failures
remain intact in the parent directory; corrected results are in `repairs/`.

Targeted regression checks pass in `test-gpcm-optimizer-boundary.R`,
`test-adaptive-fitting.R`, and `test-adaptive-quadrature-review.R`, covering
repeated invalid trials/cache recovery, invalid starts, RSM/PCM/GPCM adaptive
fitting and supported scoring/replay. Help parses successfully and NEWS/help
now describe the delivered trial-handling fix. No full-suite repetition was
needed. The source manifests and test/run logs are retained with the repair
results; the original 60-attempt evidence is not overwritten.

The numerical investigation of these two representatives has reached its
planned decision point. The observed computational defects are resolved in
this scope, with the qualifications above. The next development task is the
P2/P4 output-specific acceptance rule, reconciling this evidence with retained
weak-information/boundary examples; population-assumption sensitivity (P3)
still needs its own decision-relevant comparison. P1 is not a theorem about
global existence for all data, and these repairs do not make the paused
portable GPCM artifact a supported API or certify frequentist interval coverage.
