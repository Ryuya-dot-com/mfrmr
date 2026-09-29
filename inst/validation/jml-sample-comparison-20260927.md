# Paired sample comparison of the JML score adjustment

Protocol fixed before generating any comparison sample (2026-09-27).
This is a local method-development decision, not release qualification of
formal JML intervals. The source estimator and public inference remain unchanged.

## Question and design

Does the one-step adjustment reduce finite-sample relative-log-slope error,
and does its Person sandwich describe variation around its own population root?
Separately, does residual bias affect intervals for the generating truth?
The previous single-sample improvement was not uniform. Reuse its Criterion
owner, 2-rater/2-criterion/3-category design with 8 ratings per Person rather
than start an additional factorial grid. Both estimators use each same sample.

Generate 200 independent datasets of 400 Persons each, using the existing
truth (.3, -.4, -.6, -.9, .25) and iid abilities from (-1, 0, 1) with
probabilities (.25, .5, .25). The exact response-pattern mixture is sampled
directly; this is equivalent to drawing ability then responses, and avoids
repeatedly evaluating the same probabilities. True abilities and population
roots are not estimator inputs. Seeds are the integer 27100000 + replicate.
The earlier engineering cases are not included. No replication is dropped by
an elapsed-time cutoff; checkpoints preserve every planned attempt.

200 replicates give an approximate Monte Carlo SE of .0154 for a .95
proportion (worst case .0354). This can expose large failures; it cannot
certify precise nominal coverage, uncommon solver failures, or performance
in other rating designs/populations. The calculation cost is estimated from
the retained sample, about 1.0 seconds per raw start and .8 per adjusted
start, before fallbacks and covariance; use two local worker processes.

## Frozen estimator and failure rules

Use the same sample-equation, full-Jacobian and Person-sandwich implementation
as the engineering check. Starts are neutral (0,0,-.8,-.8,0) and opposing
(-.3,.4,-.3,-1.1,-.25), never truth or oracle roots. Raw JML uses BFGS followed
by Newton/double-dogleg. Adjusted JML first uses Broyden/line-search; a failed
start is retried with Newton/double-dogleg from that original start, as in the
retained sample failure. Do not change algorithms or tolerance after inspecting
these data. Store all original/fallback attempts. Two reviewed roots must
agree within 1e-6; otherwise the method is unavailable for the dataset.

Root review requires residual <1e-7, minimum Jacobian singular value >1e-6,
and agreement of central differences at 1e-4 and 5e-5 within relative 1e-5.
Raw roots also require positive symmetric curvature. Covariance uses the
full adjusted Jacobian, centered Person contributions and N=400, with no ridge
or pseudoinverse; rank failure is retained. Standard errors must be finite and
positive. These are numerical checks, not general boundary certificates.
Errors, failed starts, disagreement and unavailable covariance remain distinct
from available intervals that miss truth. A correction can have a computable
root and still fail to supply a usable interval.

## Outcomes and decision

Primary parameter: relative log slope (truth .25); retain all five coordinates.
Report availability and fallback usage; bias/RMSE, empirical SD, root-mean
estimated variance, and interval width. Report pointwise 95% normal intervals
for (a) generating truth and (b) the method's previously calculated population
root. Root coverage evaluates variance/linear approximation separately from
residual bias. It is an oracle diagnostic unavailable to ordinary users,
not an alternative operational confidence target.

Report coverage conditional on an available interval with a Wilson 95% Monte
Carlo interval, and delivery-and-truth-inclusion over all 200 attempts under
that explicit name. Unavailable estimates are never treated as zeros. Report
bias MCSE, SD/SE ratios, directional misses and paired squared-error differences
on common available estimates with a paired MCSE; retain results over each
method's own available sample as well. Missingness can select the paired set.

Conclude evidence of reduced log-slope squared error in this design only if
the upper normal MC bound for the paired mean squared-error difference
(adjusted minus raw) is below zero. If failures prevent a meaningful paired
comparison, leave benefit unresolved. A truth-coverage Wilson upper bound
below .925 is evidence against acceptable 95% inference even for this design;
other coverage results do not by themselves qualify general JML intervals.
If root coverage is satisfactory but truth coverage is poor, prioritize residual
bias over replacing the variance formula. If both are poor, investigate variance,
finite-sample linearization and solver selection. These diagnoses are conditional,
not a rule to repair results after seeing them.

Do not automatically expand the grid or add replications after this study.
Record the decision, retain limitations, and continue package integration.
Any further estimator revision needs its own justification and held-out evaluation.
