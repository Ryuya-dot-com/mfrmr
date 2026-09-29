# Corrected JML: allocation-dependent population challenge

Prespecified before this run. Research calculation, not a public estimator or
coverage qualification. The question is whether the correction-order decision
survives ability distributions that differ across assigned rosters, including
unequal exposure. This tests an unexamined limitation of the common-population
method-development cases without repeating their sampling study.

Use the existing five-coordinate, two-rater/two-criterion, three-category GPCM
truth and both shared slope/step owners. Two challenges:

- sparse: rosters (2,1,0,2)/(0,2,2,1), fractions .5/.5, ability supports
  (-2,-1,0)/(0,1,2);
- unequal: rosters (2,1,0,1)/(0,2,2,2), fractions .6/.4, ability supports
  (0,1,2)/(-2,-1,0).

Each support has probabilities (.25,.5,.25). Zero exposure remains unassigned.
Orders 0/1/2/4, both owners and both designs give 16 method/design cases. Retain
both original starts and all failures. Use the existing reviewed root policy;
on failure use the previously checked smaller-step Newton/double-dogleg policy
(stepmax=.25), from the original start, with unchanged residual/Jacobian/rank
tolerances. No truth starts, chosen best starts, probability pruning or wall-time
truncation. Population masses use truth only for generation and assessment.

Reuse exact count-pattern masses and exact owner-total score expectations;
check their score equivalence at truth for each roster before fitting. Report
all five population-root displacements and matching fixed-roster sandwich
scales for N=400/1600. Bias squared plus local variance is an asymptotic MSE
proxy, not empirical RMSE. Neither normal shift calculations nor this proxy
establish actual coverage. Report numerical failures in the full denominator,
not as zeros or successful estimates. No automatic data-dependent order selector
is implemented; order stability alone cannot detect common residual bias.

The output should determine whether a single tested order dominates across
coordinates and settings, where residual displacement remains material relative
to variability, and which independent sampling checks a chosen procedure still
needs. Broader facet structures, dependence and arbitrary ability populations
remain outside this calculation.

## Results and method decision

All 16 declared cases and both starts per case were attempted. Fifteen cases
passed two-start agreement, root/Jacobian review and covariance checks. All
12 corrected cases passed. Rater-owned raw JML on the sparse design did not:
both original starts retained residuals about 1.1e-4/1.4e-4, above the unchanged
1e-7 criterion, while smaller-step retries reached the exact calculation's
underflow refusal. This is an unresolved numerical case, not a proof of a
statistical boundary or of an infinite population optimum. It has no reported
root, covariance or MSE proxy. The opposing start at Rater/sparse/order 4 also
initially encountered underflow; its prespecified Newton fallback passed.
Initial and fallback attempts remain in the per-case RDS files.

Successful starts agree within 2.70e-10. Total-state scores and full enumeration
agree at each declared truth/roster/owner within 2.90e-12. At every successful
root, weighted within-roster influence outer products reproduce the nonsymmetric
Jacobian sandwich. Original derivative checks at two step sizes are retained.

For the relative log-slope coordinate, the following are population-root bias
and local fixed-roster SE at N=400, not finite-sample Monte Carlo estimates:

| Owner / assignment | Order 1 bias / SE | Order 2 bias / SE | Order 4 bias / SE |
| --- | ---: | ---: | ---: |
| Criterion / sparse | .01003 / .08330 | -.00406 / .07718 | -.00264 / .07696 |
| Criterion / unequal | .04153 / .07830 | .00773 / .07286 | .00108 / .07164 |
| Rater / sparse | .01731 / .10216 | -.01071 / .09250 | -.00728 / .09458 |
| Rater / unequal | .03631 / .07897 | .00600 / .07033 | .00018 / .06835 |

The maximum absolute displacement divided by local SE across all five
coordinates is .36-.63 for order 1 and .029-.077 for order 4 across the four
settings. These ratios double at N=1600 because the root displacement is
unchanged while the local SE scales by one half. Small current ratios do not
prove that residual bias vanishes with N.

Order 4 does not uniformly dominate on precision. In Rater/sparse, the log-slope
MSE proxy at N=400 is .00867 for order 2 versus .00900 for order 4: the smaller
order-4 displacement is offset by larger variance. Across the full coordinate
tables, the proxy-minimizing order changes with parameter, owner, design and
sometimes N. This proxy uses the known generating truth and cannot be an
automatic selector for real data. The assignments/populations were changed
together in these challenges; their separate causal contributions are not
identified by this calculation.

Decision: retain orders 2 and 4 as prespecified candidates for independent
sampling validation; do not make either an automatic/public default. Assess
the full solver policy, availability and true-value coverage, with primary
targets and practical accuracy criteria declared first. Order 1 remains the
existing methodological comparator, not a generally qualified correction.
Neither population roots nor the one-sample numerical checks replace that
sampling gate. Full results and source hashes are retained in
`validation-results/jml-scope-challenge-20260927/`.

**Assignment-scope clarification:** every roster above has at least one rating
from each of the two raters for every Person. The Person-Rater projection is
therefore fully crossed, even though Person-Rater-Criterion cells are incomplete
and some cell counts differ. The subsequent 400-dataset study reuses two of
these rosters. Neither study tests scarce common-person links, chains of rater
panels, random allocation among many raters, or loss of a bridge. Calling these
cases "sparse" without naming the incomplete projection would overstate their
network coverage. No supplied fixed-parameter anchor was used.

## Relation to TAM and ConQuest

The existing [external JML-calibrated scoring comparison](gpcm-jml-external-scoring-20260927.md)
compares frozen response functions and post-hoc EAP priors in TAM and local
ConQuest. It does not compare free corrected structural estimation. The older
[TAM/immer pilot](tam-immer-jml-factor-pilot-record-0.2.3.md) separately retains
raw and classical item-factor corrections, including unequal-exposure
differences and unavailable cases. Those corrections are not this iterated
five-coordinate GPCM equation.

[TAM's official `tam.jml` help](https://alexanderrobitzsch.github.io/TAM/reference/tam.jml.html)
describes an extreme-score adjustment `adj`, a classical item-parameter factor
under `bias`, supplied category loadings `B`, and item-intercept SEs `errorP`.
It does not document this freely estimated relative-slope adjustment or its
matching sandwich. [ConQuest's technical manual](https://conquestmanual.acer.org/s3-00.html)
describes JML quick SEs using an independence approximation for unconstrained
parameters. These are useful reference conventions, not proof of corrected-JML
truth coverage. Sources were checked on 2026-09-27; no new ConQuest process was
run for this increment.

A separate [local TAM anchor convention check](tam-anchor-convention-20260927.R)
uses its bundled Rasch responses (200 persons, eight items), fixes the first
item at .2 and records JML (`adj=.3`, `bias=FALSE`) and MML output in TAM 4.3.25.
Both retain .2 and report anchor SE zero. This establishes the observed constant
representation only; free estimates, bias correction and coverage are not
compared. Evidence is in `validation-results/tam-anchor-convention-20260927/`.
An exact constant's zero conditional covariance is compatible with reporting
its sampling SE/CI as not applicable. It does not justify presenting a
zero-width interval as precision learned from the current sample.

## Independent order-2/order-4 sampling decision

The subsequent [sampling protocol](jml-order-sampling-20260927.md) selected the
two contrasting population cases before generating any samples: Criterion /
unequal and Rater / sparse. Its [runner](jml-order-sampling-20260927.R) completed
200 independent N=400 datasets per case, with both orders fitted to the same
data. All 400 datasets and all 800 fits are retained. Each fit passes both-start
agreement, the unchanged root/Jacobian checks and positive full sandwich
covariance. Thus interval availability is 200/200 in each method/case (Wilson
95% Monte Carlo interval 98.1%-100%), not a guarantee of failure-free operation.

The primary relative-log-slope results are:

| Owner / assignment | Order | Sample bias (MCSE) | RMSE | Truth coverage (95% MC interval) | Population-root coverage |
| --- | ---: | ---: | ---: | ---: | ---: |
| Criterion / unequal | 2 | .00992 (.00496) | .07064 | 94.5% (90.4%-96.9%) | 94.0% |
| Criterion / unequal | 4 | .00359 (.00491) | .06933 | 93.5% (89.2%-96.2%) | 93.0% |
| Rater / sparse | 2 | -.00635 (.00642) | .09084 | 94.5% (90.4%-96.9%) | 95.5% |
| Rater / sparse | 4 | -.00158 (.00664) | .09372 | 94.5% (90.4%-96.9%) | 95.5% |

Because all intervals are available, delivery-and-truth-inclusion equals
conditional coverage here; both quantities are still recorded separately.
Population-root coverage is an oracle variance diagnostic, not the real-data
target. All five coordinates are retained in the detailed results: truth
coverage ranges from 93% to 98%, and empirical SD / root-mean estimated variance
ranges from .893 to 1.057. This does not establish that the sandwich always
describes finite-sample variation adequately. In particular, a low estimated
bias in this one study does not eliminate the known population displacement.

The prespecified paired comparison gives order-4 minus order-2 log-slope MSE
of -.0001833 (MCSE .0000689; 95% normal MC interval -.0003182 to -.0000483)
for Criterion / unequal, and +.0005310 (MCSE .0001460; interval .0002449 to
.0008171) for Rater / sparse. Both directional intervals exclude zero. This
supports a small improvement from order 4 in the first condition and a loss
in the second, despite smaller absolute sample-bias estimates in both. It
does not establish which order is best under an unknown ability distribution
or for another structural parameter. The additional coordinate comparisons
are descriptive; no multiplicity-adjusted family claim is made.

No case meets the protocol's evidence-of-deficiency rule (truth-coverage
Wilson upper bound below .925). That is not an equivalence or noninferiority
test, and does not qualify nominal 95% intervals. The broad Monte Carlo
intervals explicitly limit what the 200 replications can establish. Order 4
also does not improve the observed coverage uniformly: Criterion / unequal
log-slope inclusion is lower, not higher, in this run.

Numerical cost remains part of the method assessment. Criterion / unequal
needed no fallback. Rater / sparse needed a fallback for one original start
in 22/200 order-2 fits and 34/200 order-4 fits. Of these 56 initial failures,
47 failed the unchanged root review and nine encountered owner-total mass
underflow. One fit needed the prespecified smaller-step retry after the
ordinary Newton fallback. All ultimately passed; original attempts remain
in the records. This is evidence about the complete stated solver policy,
not about the initial solver alone or global uniqueness.

The completed study rules out a universal preference for order 4 across even
these two tested settings. Keep orders explicit and do not implement a
data-driven selector from lower SEs, overlapping estimates or known-truth
MSE. No corrected estimator or formal JML interval has been added to the
public API. The public help already distinguishes the current uncorrected
JML estimator and its exploratory location SEs; research results do not
belong in NEWS as a newly available feature.

The next implementation decision is to specify the supported observed-data
input, parameter identification, correction equation and matching covariance
as one estimator contract, including failure output, before integrating it
with `fit_mfrm()` or existing inference/reporting APIs. The current reference
is restricted to two raters, two criteria, three categories, shared ownership,
unit weights, independent responses conditional on ability and no anchors.
General facet counts, anchors, dependent ratings and adaptive-order inference
remain unqualified. Do not automatically add a larger simulation grid or
repetitions to turn this finite decision into an indefinite study.

Evidence: `validation-results/jml-order-sampling-20260927/` contains all 400
per-dataset records, source hashes, complete parameter summaries, paired
comparisons, dispositions and session information. A separate record-based
aggregation check independently reproduced all 20 parameter/method/case
summaries and ten paired comparisons, verified fixed roster sizes, source
hashes, interval formulas and positive stored covariances. Its script is
retained beside the results. The protocol and executed sources were not
modified after sampling began. Work was split across local R processes; when
the original Rater worker reached the range already assigned to a second
worker, its overwrite guard stopped it before duplicate replicate 143. This
was a scheduling stop, not a failed fit or a lost replication; the final
ID/hash audit requires every declared dataset exactly once. No external engine,
whole-package test, remote upload or release check was rerun.
