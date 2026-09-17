# Same-sample calibration: main coverage protocol

## Status and purpose

Design fixed, 2026-09-17, after the retained-pilot pair-allocation analysis.
At freezing, no main-study data have been generated or fitted. The allocation,
new seed manifest and this protocol are saved by
`local-testlet-main-coverage-0.2.4-plan.R`. Pilot datasets will not enter the
main-study denominators. Execution requires the separate main-study runner;
the plan script only freezes the design.

When a small set of scored people is also used to estimate calibration, treating
those estimated values as known may misrepresent uncertainty in their abilities.
Differences between people can respond differently because the same calibration
is shared. The question is how much uncorrected plug-in 95% equal-tail coverage
changes relative to an oracle that knows the calibration, for these two targets.
The experiment estimates this effect under one specified model; it does not
evaluate a correction or rank rating designs.

## Conditions and targets

Use four cells in this fixed order: (N=24,v=0), (120,0), (24,.49), (120,.49).
Each person receives six scores: two fixed raters each rate three criteria,
with categories 0/1/2 and no missingness. For criterion j, rater r and category k,

`log[P(Y_prj=k)/P(Y_prj=k-1)] = alpha + theta_p - beta_j - d_r + gamma_pr - tau_k`.

Set alpha=.2, beta1=-.4, beta2=.1, beta3=.3, d1=-.25, d2=.25,
tau1=-.6, tau2=.6. Draw independent theta_p~N(0,1) and gamma_pr~N(0,v);
each gamma_pr is shared only by that person's three scores from that rater.
Do not sample-center or sort latent values. The ability distribution is fixed
in fitting. This is local person-rater dependence, not severity drawn once per
rater and shared across people.

The two methods use identical generated data: oracle true calibration and
six-coordinate same-sample maximum-likelihood calibration followed by plug-in
scoring. Target every person's theta and the selected prefix of consecutive,
nonoverlapping differences theta_1-theta_2, theta_3-theta_4, etc. Target selection
depends on identifiers only. Comparisons are paired within datasets.

The primary estimands are plug-in-minus-oracle marginal coverage differences
for persons and pairs in each cell (eight estimates). Report both methods'
coverage as well. The oracle's .95 reference averages over latent effects and
responses from the declared model; it is not a fixed-ability coverage claim.
True-ability bands theta<-1, -1<=theta<=1 and theta>1 are secondary conditional
summaries, not assessed against an assumed .95 property. Bias and RMSE of
posterior means are secondary descriptive outcomes, retaining their denominators.
No interval widths or uncertainty-corrected intervals are included.

## Allocation and independent generation

Use **12 fixed disjoint pairs and 300 independent datasets in each cell**:
1,200 datasets total. Thus all 24 people enter a pair at N=24; the first 24
people enter pairs at N=120. Every person is scored individually in both
conditions. Across the study this gives 86,400 person targets and 14,400 pair
targets per method, or 201,600 method/target rows.

This chooses the smallest estimated total serial cost among the 12 evaluated
allocations after the ideal-oracle precision check. The finite maximum
empirical projections at 12 pairs are 260/235/156/78 datasets in cell order;
rounding the largest up to 100 with a 200 floor gives 300 per cell. All six
planning metrics in each cell have nonzero empirical variance with 12 pairs.
The ideal full-availability oracle needs 159 datasets with 12 pairs, so that
supplementary benchmark does not increase the selected count. It also changes
none of the other 11 candidates in this particular pilot.

The measured-time projection is about 7.62 serial hours, versus 9.82 hours for
four pairs and 700 datasets per cell. Using 12/60 pairs at N=24/120 retains
the same 300-replication requirement but projects to 17.44 hours. These are
pilot-based estimates, not runtime promises or a proven optimum; the extra
normalizer setup in the allocation batches makes the time accounting somewhat
conservative. The ten-dataset variance estimates are also noisy.

The planning goal is MCSE <=.005 for each method's coverage and the matched
coverage difference, for persons and pairs. The largest empirical projected
MCSE at 300 datasets is approximately .00465. This is a precision goal, not an
acceptable-coverage margin or a guarantee; the achieved MCSE will be reported.

Reserve seeds `262017000L + 10000L*Cell + Replicate`, with the generator's
Mersenne-Twister/Inversion/Rejection settings. Before any fit, freeze the full
manifest, verify unique seeds disjoint from both earlier pilots, and generate
all assigned datasets. Verify probability normalization, adjacent logits,
local-effect ownership and exact regeneration; save source/data hashes,
latent values, uniforms, probabilities, responses and session information.
No outcome-based seed replacement, replication top-up or pooling of pilot data.

## Fitting, scoring and failures

Reuse the selected driver with start (0,0,0,0,-.5,.25), bounds [-8,8] on the
first five coordinates and [0,16] on v, and controls maxit=250, fnscale=N,
factr=0, pgtol=5e-6/N. Keep adaptive GH orders 61/121/181/241 and the original
trial likelihood/moment/gradient tolerances. One fit per dataset, without new
starts or automatic retries. Native code 0 alone is insufficient: require
total projected score <=1e-5, no artificial-bound solution or captured
errors/warnings. Exact v=0 is permitted and reported separately.

Every returned point receives a terminal-order+60 reference evaluation. Require
likelihood and moment changes <=1e-7, gradient change <=1e-6 and reference
projected score <=1e-5, without errors/warnings. Plug-in scoring is unavailable
if fitting/reference fails. Oracle scoring still runs. Retain every failure,
stop, boundary state and trial history, including rows without usable intervals.

Reuse continuous-CDF scoring: covered iff .025<=F(truth)<=.975. Refine local/
midpoint orders 61/41,121/81,181/121,241/181 only until the retained acceptance
rules pass. Integrate with absolute/relative tolerance 1e-8 and subdivisions
200. Require mass error <=1e-7, consecutive CDF/mean changes <=1e-6, propagated
integration-error estimate <=1e-6 and valid CDF in [0,1]. A CDF within 1e-6 of
either coverage cutoff remains unresolved unless later refinement removes
the ambiguity. Save every attempt; do not force unresolved cases into coverage.
Score persons and selected pairs in a single method/dataset batch to reuse
normalizers. No repeated package suite or old numerical experiment is required
unless the new implementation changes their scope or uncovers a discrepancy.

## Reporting, stopping and interpretation

Retain all assigned independent datasets in aggregation. For each target/method
report assigned, available and covered counts; availability; coverage among
available targets; and available-and-covered/assigned. For method differences
use only common available targets, and report the matched oracle coverage too.
If failures occur, label the paired difference as conditional on numerical
availability; it cannot recover an unconditional difference for failed cases.

Use the existing dataset-cluster ratio influence-function MCSE, including
zero-available clusters, for coverage and paired differences. Do not count
people or pairs as independent simulation replications. Report approximate
pointwise 95% Monte Carlo intervals using estimate +/- t_(B-1,.975)*MCSE,
where B is the number of assigned independent datasets per cell. These are
simulation-precision intervals for aggregate estimates, distinct from the
individual 95% score intervals whose coverage is being studied. Zero observed
cluster variance is explicitly flagged; a zero-width empirical interval does
not establish certainty, equivalence or no possible failures. Report the eight
primary differences together, without a familywise testing or equivalence claim.

Stop after the fixed number of attempted datasets, including numerical failures.
Checkpoint/resume may continue interrupted work with unchanged source/data
identities; it may not replace a recorded failed fit with a successful retry.
Do not inspect interim coverage to alter pair counts, controls or sample size.
At completion, report achieved MCSE and any unmet precision goals. If further
precision or a numerical repair is needed, specify a separate follow-up and
preserve this experiment's original denominators and results. A source mismatch
or corrupted checkpoint pauses execution for investigation rather than mixing
versions in one study.

The final interpretation must connect each target's effect size and uncertainty
to the question. There is no prespecified binary coverage-acceptance threshold,
and normal convergence or a narrow Monte Carlo interval does not qualify a
public score interval. Conclusions apply to the stated model/conditions;
shared random-rater estimation, calibration-uncertainty correction and rating
design comparisons require their own studies.
