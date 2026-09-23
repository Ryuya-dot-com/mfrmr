# Assigned-score MI interval assessment

2026-09-23. M2 follow-through to the executed joint RSM example. This protocol
is fixed before new missingness/sampling results. Reuse the checked RSM
generator and Stan model; do not introduce an exported imputer or a new model.

## Question, design and preflight

Does the joint-RSM predictive completion plus MML/Rubin workflow retain
fixed-rater contrast inference under correctly specified ignorable score
missingness? How does it fail when low missing scores themselves influence
nonresponse? Compare direct observed-score MML and observed-score Bayes with
MI on each incomplete roster. The Bayesian interval is a credible interval;
its repeated-sampling coverage can be evaluated but is not a confidence
interval identity. Do not confuse congeniality with using the same likelihood.

Reuse the RSM generator from `facet-sandwich-0.2.4.R`: 80 independent N(0,1)
Persons, three fixed raters (.3,-.1,-.2), two criteria (.4,-.4), shared steps
(-.6,.6), categories 0:2. Primary target R1-minus-R3 = .5 logits. Each Person
initially has all six events. R2/C2 is unassigned for P0001--P0020, independently
of ability/response. No unassigned event is an imputation target. R1's two
scores remain observed and their mean is an available selection predictor.

Among R3's two ratings per Person, use the same uniform draws in two masks:

- MAR: `plogis(-.5 + .8 * (1 - mean_R1_score))`.
- MNAR challenge: add `1.5 * (1 - unobserved_score)` to that logit. This is
  deliberately analyzed using the same MAR imputer; it tests misspecification,
  not an MNAR correction. Missing rates may differ and are reported.

The generating design/parameter values are unchanged across masks, so
differences concern missingness in this design, not ability-distribution or
response-model misspecification. The same-parameter fully observed historical
study is contextual evidence, not a replacement for this missing-score check.

First run one dataset per mask, data seed 92391001 and mask seed 92392001,
excluded from the main sample. Measure full-chain, fit/pool runtime, storage,
numerical readiness and quadrature stability. Do not use point estimates,
coverage or method ranking to select the main design or number of trials.
Freeze the main replication count, MC precision and outcome interpretation
after that resource check and before any main missingness draws.

## Fixed analysis

Same Stan model and orthonormal calibration N(0,2.5^2) priors as the tutorial;
known N(0,1) Person distribution, unit discrimination and sum constraints.
Each completion retains joint calibration draws and shared Person abilities.
Four chains, 1,000 warmup plus 1,000 retained iterations, adapt_delta .9,
max_treedepth 10. Require all return codes zero, Rhat <1.01 and bulk/tail ESS
>=400 for every latent/calibration coordinate, no divergences/tree-depth hits
and E-BFMI >=.3. Also apply those moment diagnostics to the primary contrast.
No bad chain replacement. A failed sampler makes Bayes and MI unavailable;
observed-score MML can still be evaluated.

Select forty completion draws uniformly without replacement from all retained
chains, with a separate fixed seed; retain their chain/iteration identities.
Use `mfrm_response_imputations()`, `fit_mfrm_imputed()` and
`pool_mfrm_imputed()` without bypassing their readiness/covariance rules.
Every completion is fitted at Q61, maxit=400, reltol=1e-10. Direct observed MML
uses the same settings on explicitly reviewed observed assigned events.
Check direct MML at Q121; if a Q61/Q121 contrast or SE difference exceeds
1e-4, mark the direct comparison numerically unavailable. Preflight additionally
checks the first completed fit at Q121 against its Q61 parameter vector and
contrast SE. Main numerical review follows evidence rather than automatic
repetition of every fit. No imputation failure is deleted from a pool.

Retain full posterior latent/calibration chains, missing category draws,
sampler diagnostics, selected predictive completions, all fits, failures and
original rosters. Redundant generated probability columns need not be stored
in the coverage archive; the source model and latent draws reconstruct them.
Remove temporary CSV only after the equivalent required draws/diagnostics are
saved and their archive can be read. Failures retain their stage and messages.

## Outcome definitions

The independent Monte Carlo unit is the **dataset**, not a rater, imputation,
rating or MCMC draw. Per mask/method report planned n, available n and rate,
95% exact binomial MC bounds; coverage among available intervals and joint
available-and-covered rate with MCSE/bounds; bias and RMSE in logits, empirical
SD versus mean SE/posterior SD, mean width, and within/between/total MI variance.
Retain missing counts, MCMC failures, failed completions and warnings.

Paired comparisons use datasets where both compared methods are available;
report the common count, mean estimate/width differences, coverage differences
and their dataset-level MCSE. These are method comparisons, not interchangeable
confidence/credible interval definitions. Summarize MI point MCSE relative to
its inferential SE, separately from the study's MC uncertainty. Inconclusive
results remain inconclusive; no post-outcome replication top-up.

## References

Bartlett and Hughes (2020), Section 2.2, doi:10.1177/0962280220932189:
proper imputation, congeniality and complete-data inference are distinct.
The same-model MML covariance is an approximation to complete-data posterior
moments under the imputer's proper calibration prior.

## Frozen main workload and decision, after resource preflight

Both excluded preflight masks returned MML, Bayesian and MI intervals without
errors. Q61/Q121 differences for direct and first completed fits were below
1e-4. Whole-trial times were approximately 20 seconds and the archive about
5 MB per mask. This resource check, not preflight coverage/estimates, determines
the main workload: **200 independent datasets, each analyzed under both masks**
(400 incomplete rosters; forty imputations each, at most 16,000 completed-data
fits). Four independent process workers execute disjoint dataset IDs. Expected
archive size is approximately 2 GB; allow 3 GB and 3 hours wall time, including
contention. A resource interruption retains the fixed sample and all attempts;
it does not authorize replacing a replicate or reporting a partial main study
as complete.

Use seeds `92231000 + id`, id 1--200, exactly reusing the fully generated
normal RSM/N=80 data from the earlier fixed-facet study. Missingness seeds are
`92392000 + id`; MCMC seeds `92400000 + 2*id + I(MNAR)`; completion-selection
seeds `92500000 + 2*id + I(MNAR)`. The two preflight masks are excluded and
never added to the main denominator. No smaller subset is selected using
earlier point/coverage outcomes.

For a true coverage probability .95, the planning MCSE is 1.54 percentage
points at n=200, with a roughly three-point 95% half-width. This is a bounded
assessment with limited ability to establish a narrow coverage tolerance;
an inconclusive result is an anticipated valid outcome, not permission to
increase n after viewing it.

For each method and mask, use the same coverage tolerance as the prior testlet
assessment: bounded positive evidence requires the exact 95% MC lower bound
of available-interval coverage >=.925, coverage estimate <=.975, and exact
availability lower bound >=.95. Additionally the 95% t MC interval for bias
must lie wholly within [-.05,.05] logits. An upper coverage bound <.925 or a
bias interval wholly outside that band is adverse evidence. Other outcomes
are inconclusive (including insufficient precision or availability). Report
the separate coverage, availability and bias decisions rather than concealing
a failure behind a combined label. The MNAR condition is an assumption-failure
challenge, not a condition for advertising the MAR imputer as MNAR-capable.

These operational thresholds are fixed before main outcomes, not universal
guarantees. Neither favorable width nor closeness to direct MML compensates
for poor coverage/bias. Whatever the decision, update help with the actual
design, numerical failures and Monte Carlo uncertainty; do not claim general
coverage, automatic MNAR correction or arbitrary-design qualification.
