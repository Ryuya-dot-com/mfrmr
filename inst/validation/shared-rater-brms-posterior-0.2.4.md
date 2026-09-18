# Shared-rater posterior: fixed-calibration external check

2026-09-18. Plan fixed before sampling. This checks whether the generated
brms/Stan model recovers the saved shared-rater posterior moments, including
dependence between people. It is a prerequisite for using this external
reference in calibration-uncertainty work, not a new coverage experiment.

## One saved case and one sampling budget

Reuse the two-person, two-rater, two-criterion responses in the
[model bridge](random-effects-brms-bridge-0.2.4.R). Fix alpha=0,
beta=(-.3,.3), thresholds=(-.6,.6), Person SD=1 and Rater SD=.7.
Only two Person and two shared Rater effects remain unknown. Each rater
effect is shared across both people. The reference is the saved JSON's
Q81 posterior mean/covariance, previously checked against Q41 and reversed
integration order within 1e-7. No quadrature or plots will be rerun.

Use brms constant priors to fix calibration, then compile and sample its
generated Stan code with CmdStanR. Use four chains, seed 262018101, 1,000
warmup and 8,000 retained iterations per chain, no thinning, random initial
values in [-2,2], adapt_delta=.9, max_treedepth=10, diagonal metric and
18-digit CSV output. This is one fixed run of 32,000 retained joint draws.
Retain failed chains and diagnostics; do not change seeds, extend chains or
tune settings in response to agreement with the reference.

## Checks and interpretation

Require all chains to return successfully, no post-warmup divergences or
maximum-tree-depth hits, and E-BFMI >=.3 in each chain. Require R-hat <1.01
and bulk/tail ESS >=400 for all four latent effects and the seven comparison
quantities below. These diagnostics follow the roles described by the
[Stan diagnostic guide](https://mc-stan.org/learn-stan/diagnostics-warnings.html);
passing them alone is not proof of a correct target distribution.

Compare E(theta1), E(theta2), E(theta1-theta2), the two variances, covariance,
and variance of the difference. For moment comparisons center each draw on
the **saved reference mean**, so each quantity is the mean of a known
function of the joint draw. Compute its autocorrelation-aware mean MCSE with
[posterior::mcse_mean](https://mc-stan.org/posterior/reference/mcse_mean.html),
preserving iteration and chain axes. Require positive finite MCSE <=.01 and
absolute discrepancy <=4*MCSE+1e-7 for each quantity. The .01 precision goal
is small relative to the saved covariance .07157 and its approximately .1431
contribution to difference variance; it prevents a very imprecise estimate
from passing just through a wide tolerance. The four-MCSE rule is a bounded
computational comparison, not a simultaneous confidence or equivalence claim.

Also report ordinary sample means/covariance, their induced difference SD,
and the SD obtained by dropping the same sample's covariance. Verify the
sample contrast variance identity within 1e-12. Differences use paired draws
from the same iteration and chain. Do not permute draws, form independent
marginals or add two marginal variances as the correct contrast uncertainty.

This checks moments at known calibration in one example. It does not check
tail quantiles, calibrated interval coverage, unknown variance estimation,
prior sensitivity, new-rater prediction or operational-scale performance.
Those require their own evidence before a public scoring/design API decision.

## Records

The [runner](shared-rater-brms-posterior-0.2.4.R) freezes this text, the saved
reference and bridge, software/source identities, generated code/data and
sampling settings before compilation. Raw chain CSVs, model source, executable
and fit checkpoints remain in the ignored execution directory. Portable
evidence retains joint latent draws, sampler diagnostics, comparison results
and provenance. A resumed invocation reuses the saved fit or raw chain files
under the same identities; it does not silently launch a replacement run.

## Completed result: 2026-09-18

The single planned run completed with all 32,000 retained draws. All seven
moments met the prespecified MCSE and agreement criteria; the largest
discrepancy was less than 0.651 MCSE. This supports using this brms/Stan mapping as a
joint-posterior reference for the saved known-calibration case.

| Quantity | Saved quadrature reference | MCMC estimate | MCSE |
|---|---:|---:|---:|
| Mean, person 1 | -0.668212 | -0.665888 | 0.003984 |
| Mean, person 2 | 0.089274 | 0.089260 | 0.003859 |
| Mean difference | -0.757486 | -0.755148 | 0.004629 |
| Variance, person 1 | 0.466322 | 0.464601 | 0.005101 |
| Variance, person 2 | 0.444257 | 0.447339 | 0.004738 |
| Covariance | 0.071568 | 0.070623 | 0.003492 |
| Variance of difference | 0.767444 | 0.770694 | 0.009008 |

As specified above, the variance/covariance estimates in this table use the
reference means for centering. The ordinary sample covariance is 0.070625,
and the paired difference SD is 0.877902 (reference 0.876039). Dropping that
same sample's covariance instead gives SD 0.954968. The contrast-variance
identity holds within 9.16e-16. Thus the relevant result for comparing two
people is their paired difference distribution; the two marginal SDs alone
lose information about the common rater effects.

All four chains returned code 0, with no divergences or tree-depth hits.
E-BFMI ranged from 1.032 to 1.087. Across the four latent effects and seven
comparison quantities, maximum R-hat was 1.000155, minimum bulk ESS was
16,584 and minimum tail ESS was 17,549. CmdStanR reports 0.396 seconds for
the parallel run, excluding compilation; this four-parameter example is not
an operational-scale timing benchmark.

The generated Stan parameter block contains only the two standardized Person
and two standardized Rater effects. Calibration coefficients, thresholds,
Person SD and Rater SD are constants. The saved data's person/rater ownership
and score coding match the bridge, and the criterion contribution matches
-beta within 3.89e-16. A read-only evidence audit confirmed source/input and
raw-chain hashes, complete diagnostic vectors, saved draws and CSV summaries.
One audit expression initially compared a named predictor vector with an
unnamed reference; removing row-name attributes resolved that metadata-only
mismatch without changing any values or rerunning sampling.

The [comparison](shared-rater-brms-posterior-0.2.4-comparison.csv),
[diagnostics](shared-rater-brms-posterior-0.2.4-diagnostics.csv) and
[checks](shared-rater-brms-posterior-0.2.4-checks.csv) are retained with the
[portable evidence](shared-rater-brms-posterior-0.2.4-evidence.rds).
The evidence includes the original pre-sampling plan text, generated code/data
and 32,000 joint latent draws; its MD5 is `133bea27d75c4a998a55d98ac5a8bddf`.
Software versions were brms 2.23.0, CmdStanR 0.9.0, CmdStan 2.39.0 and
posterior 1.7.0. No replacement run or extension of the sampling budget occurred.

This closes the known-calibration moment comparison. The next decision is
whether joint inference with **unknown calibration and rater variance** has
acceptable prior sensitivity and computational cost at a relevant rating
scale, before evaluating interval performance and rating allocations.
The present result does not establish tail accuracy, coverage or variance
recovery, and adds no public API or package dependency.
