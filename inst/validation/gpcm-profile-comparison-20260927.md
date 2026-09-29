# One-target profile/Wald comparison — 2026-09-27

## Protocol fixed before evaluating the 100 profile outcomes

Question: does the new experimental profile procedure provide usable intervals
for the first relative rater slope in an existing small, linked incomplete
assessment design, and what tradeoff appears against the matched log-Wald
procedure? This is a retrospective diagnostic reanalysis of a complete saved
simulation cell, not unseen confirmation or a comparison of current estimators.
The cell was already examined for probability undercoverage; one of its fits
(index 788) was used in profile implementation. Neither that fit nor any other
is excluded or substituted. Interval outcomes do not select the cases.

Use all 100 rows, Rep 1:100, from
`validation-results/gpcm-probability-refit-20260925/plan.csv`: N=40, shared Rater
slope/step owner, rotating two-of-three raters, three criteria, spread slopes.
The first relative slope R01 has truth exp(-0.4); the other two are 1 and
exp(0.4), with geometric mean one. Each source keeps its original normal-ability
sample, facet effects, steps, category ladder and independent assignment.
Read each truth from its original saved data and verify against the declared
target. The original generator draws facet effects too: this is not a study
conditional on one fixed set of nuisance facet effects. Reuse the earlier
800-case truth/scale audit; do not regenerate data, refit the source or replace
failed intervals by higher-order refits. Source estimates use fixed Q61 MML,
an estimated intercept-only normal population and the September 25 estimator.

Evaluate public `confint()` on each same saved fit with method `model` and
`profile`, nominal level .95, relative scale, no multiplicity adjustment, and
R01 selected before evaluation. Profile controls remain their shipped defaults
(maxit 400, eight outward steps, initial log step .5), including both starts
and Q121 reference checks. No threshold tuning, endpoint cache from the earlier
example, selective rescue, or implementation changes within the comparison.
Save returned objects, warnings, errors, endpoint statuses and full elapsed/CPU
time for both calls. A refused source and a returned unresolved profile both
remain in the assigned denominator, but have distinct recorded reasons.

Report availability, coverage conditional on availability, reported-and-covered
per assigned dataset, and unresolved-case bounds [covered/N,
(covered+unavailable)/N]. These bounds do not classify missing intervals as
known coverage failures. Exact binomial 95% Monte Carlo intervals accompany
the three proportions; they are per-measure, not simultaneous. Report matched
availability and reported-and-covered differences with paired dataset-level
MCSE, plus common-available coverage/width only as a secondary comparison.
Keep lower and upper misses distinct and retain all individual rows. Summarize
median/p90 times and interval width; full fit time is excluded because sources
are reused. Profile time includes its own source/information checks.

At N=100, binomial MCSE near .95 is .0218, not enough to certify nominal .95
performance. A conditional-coverage upper MC bound below .925 or availability
upper MC bound below .90 is a concern; support against each margin requires
its lower bound to clear the margin; overlap is inconclusive. These diagnostic
thresholds reuse the prior confirmation protocol. Selection/history and the
single cell prevent general confirmation even if both margins clear.
Retain the experimental designation unless separate supporting evidence exists;
do not promote profile because its interval is asymmetric or automatically
extend this to probability intervals, separate owners or operational decisions.

All 100 cases are attempted; no total-time cutoff removes planned cases. Use
two worker processes at most, one native math thread each, saving every case.
Both methods run under that same concurrency; elapsed times describe this
local workload, not an isolated machine benchmark. Record CPU times separately.
The representative shared-owner complete call previously took about 8 seconds;
100 such calls suggest roughly 7 minutes with two workers, but failures and
different profiles can take longer. The runner retains source/data/protocol
hashes and refuses mixed-source resume. A completed finite diagnostic and an
explicit disposition end this comparison; adverse or inconclusive outcomes do
not trigger automatic extra simulation.

Runner: [gpcm-profile-comparison-20260927.R](gpcm-profile-comparison-20260927.R).
Generated evidence stays outside the package in
`validation-results/gpcm-profile-comparison-20260927/`.
