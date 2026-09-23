# Shared-rater calibration: local marginal-likelihood reference

2026-09-23. M2/M3. Fixed before evaluating the new likelihood-ratio results.
This checks whether the calibration Laplace likelihood changes correctly near
its fitted parameters. Reuse the eight full-roster cases in the completed
conditional-scoring reference, including first replicates and the previously
selected Person-quadrature challenges. No new datasets, latent draws, scoring,
calibration refits, exclusions or changed original coverage decisions.

## Target and planned comparisons

For each saved fit let a0 contain its two fixed-facet coefficients, two RSM
steps, rater SD and Person SD. Use the saved positive covariance V and its
lower Cholesky factor L. The six columns of L satisfy v' V^-1 v = 1.
Add three directions V*c/sqrt(c'V*c): the C3-minus-C1 contrast and the rater-
and Person-SD coordinates. These directions represent one local standard
error of movement with nuisance parameters moving according to V. They are
not refitted profile likelihoods. Evaluate a0 +/- v for all nine directions:
18 nonzero points per roster, 144 overall. Save zero-displacement controls.
Reject nonpositive SD points without moving them back into range.

The response model is the same adjacent-category three-category RSM, with
one ability per Person and one severity per rater shared over every response.
Let f_a(y,b,u) be its joint response/normal-prior density and Z(a) its marginal
likelihood. For a deterministic translation b' = b + d, u' = u, Jacobian one,

  Z(a)/Z(a0) = E_{b,u | y,a0}[ f_a(y,b+d,u) / f_a0(y,b,u) ].

Set d_p to that Person's mean fixed-facet offset change plus the mean step
change. This removes a common response-location shift from the importance
weights while preserving the integral exactly. The translation depends only
on the planned parameter displacement and observed design, not posterior
results; include its normal-prior density change. Use all 8,000 saved draws
per chain and all four chains. The reference uses direct ordinal logits and
normal densities, no Laplace formula, production probability helper or Person
quadrature. Its log of the raw mean weight estimates the log likelihood ratio;
do not replace weights by PSIS-smoothed values.

Check the vectorized validation calculation against a separate direct R joint
density at the first draw of each chain at every point (1e-8 log tolerance).
Zero displacement must return zero log weights within 1e-10. Verify saved-case,
original sampler-check and source identities. No class-dependent draw slicing.
Evaluate the production Laplace log likelihood at the same fixed parameter
points using 123 and 241 Person nodes. Require their relative log-likelihood
changes to agree within 1e-5; updating inner rater modes is part of evaluating
the existing objective, not a calibration refit. These order checks alone do
not test the rater approximation.

## Precision and frozen disposition

Keep iteration/chain axes for each raw weight function. Require finite positive
means, Rhat <1.01, bulk/tail ESS >=400, raw importance ESS >=1,000, Pareto k <.5,
and delta-method log-mean MCSE <=.01. Pareto k is a tail diagnostic, not proof
of reference reliability. Preserve every unresolved point and its reason.
Use log(mean +/- 4*MCSE_mean) as reference uncertainty allowances, requiring a
positive lower mean. These are numerical Monte Carlo allowances, not a
simultaneous confidence theorem across the 144 comparisons.

The practical tolerance is .05 log-likelihood units: one tenth of the .5-unit
quadratic drop for a one-information-unit direction. With precision and all
checks resolved, call a point bounded agreement only if the full reference
allowance is within +/- .05 of the 241-node Laplace change. Call material
discrepancy only if the full allowance is outside that band; otherwise retain
inconclusive. Report every direction, point and roster. Do not enlarge the
tolerance, extend chains or add favorable cases after seeing results.

Run one case at a time, within a 20-minute execution / 512-MiB new-artifact
budget; report unfinished cases if exceeded. Existing input archives do not
count as newly generated artifacts. The compiled helper is validation-only and
adds no package dependency or public API. Record timings and source hashes.

## What this can decide

This is a bounded local check of marginal-likelihood shape relevant to
calibration and regular information-based uncertainty. It does not estimate
an exact alternative MLE, absolute log-likelihood normalization, all Hessian
entries, a fully reoptimized SD profile or a boundary distribution. It does
not establish interval coverage, automatic model choice or accuracy for every
sparse/non-normal design. Adverse or unresolved results require an explicit
remaining numerical/output decision; they cannot be removed by favorable
Person-scoring results. Preserve the independent coverage evidence when
settling regular and population-variance interval outputs.

The likelihood-ratio identity follows directly by change of variables and
posterior normalization; it is a Monte Carlo likelihood calculation in the
sense of [Geyer (1994)](https://doi.org/10.1111/j.2517-6161.1994.tb01976.x).
The production approximation is distinguished from its automatic derivatives
by [Kristensen et al. (2016)](https://doi.org/10.18637/jss.v070.i05).
Use the official [posterior MCSE](https://mc-stan.org/posterior/reference/mcse_mean.html)
and [importance-tail diagnostic](https://mc-stan.org/loo/reference/pareto-k-diagnostic.html)
definitions; these sources do not qualify the present package's numerical error.
