# Two-family profile availability and cost — 2026-09-29

## Fixed protocol, before generating the independent samples

**Question.** After the component profile implementation and its numerical
checks, does an explicitly selected profile procedure return usable intervals
across the two existing sparse assignment designs? Does its availability or
cost prevent a larger coverage comparison with the default log-Wald method?
This is a feasibility study, not qualification of 95% coverage.

Reuse the independent literal generator in
`gmfrm-sparse-intervals-20260928.R`: 240 Persons, three first-facet levels,
six second-facet levels, three score categories and 1,440 observed ratings.
Compare common-Person linking with rotating pairs, each at normal ability SD
1 and .5. The roster is independent of ability. Unassigned ratings are absent;
they are not missing assigned scores or fixed calibration anchors. Match
latent draws/uniforms across the four conditions within a replicate, as before.
Use new seed base **92960000**, IDs 1–20; none are previous development data.
First-family truth remains geometric-mean-one; second-family slope truth
multiplies by ability SD on the fitted fixed-N(0,1) scale.

**Targets, fixed before outcomes:** Task t3 (the dependent first-family
coordinate, previously showing low Wald coverage) and Rater r3 (a free
second-family component previously showing bias/SE coupling). These names
describe the generator, not restrictions on user facet names. Both methods
are evaluated for each target in every dataset, without selecting targets or
methods after observing results. Other slopes are nuisance parameters.

**Procedure:** neutral-start public `fit_mfrm()`, fixed standard-normal
MML–EM, 121 nodes, maximum 500 EM iterations, per-Person score tolerance 1e-7,
explicit 0:2 score ladder, unit weights, no anchors/interactions. No automatic
refit, higher-grid rescue or estimator switching. Profile calls use the
unchanged defaults: 95% pointwise chi-square(1) cutoff, two starts, 400 BFGS
iterations per stage, eight outward steps, initial log step .5, and 241-node
checks at constrained solutions. Use `confint(method="model")` on the same
source for log-Wald; no simultaneous limits. The cell-aggregated evaluator
has been checked against the original evaluator and saved endpoint searches;
it changes neither the objective nor the acceptance tolerances.

**Size and decision:** 20 datasets per condition, 80 fits and 160 planned
profile calls, completed without a time cutoff or outcome-based stopping.
If an individual target has a 15% failure probability, 20 independent
replicates have 1-.85^20 = 96.1% probability of seeing at least one failure.
This is a check for frequent operational problems, not precise estimation of
their rates. Even with complete availability, coverage MCSE near .95 is about
.049; exact binomial intervals must accompany proportions. Cross-condition
results share draws and must not be pooled as 80 independent replicates.
Low availability or recurrent numerical failures require reviewing their
stage before escalating computation. Clean results still require a separately
planned, adequately precise coverage study; no outcome promotes profile to a
routine replacement. Neither interval method corrects point-estimate bias.

**Accounting:** preserve every fit, source rejection, warning, failed endpoint,
search stage and total call time. Summarize planned/attempted counts, converged
fits, returned objects, both-endpoint availability, conditional coverage,
returned-and-covered proportion, interval width and CPU/elapsed time separately
by design, SD, target and method. Give paired availability counts and coverage
on the subset where both methods return an interval without treating that
selected subset as unconditional coverage. Source failure and one missing
endpoint count as unavailable, never as unbounded or as successful Wald rescue.
Resumption requires matching source/protocol and case identity; final summaries
require every planned case. Source hashes, native library identity, session and
complete results are saved before/through the run.

Runner: `gmfrm-profile-feasibility-20260929.R`.
Results: `validation-results/gmfrm-profile-feasibility-20260929/`.
