# Shared-rater inference with unknown calibration: bounded prior pilot

2026-09-18. This plan is fixed before generating responses or fitting models.
The question is whether joint inference is computationally usable at the
planned rating scale, and which conclusions change under specified prior
scales. This is one paired data realization, not a coverage experiment or
a comparison establishing a superior rating allocation.

## Data and targets

Reuse the saved A and D incidence tables: 240 people, 12 raters, 480 bundles
and three criteria per bundle, with 40 bundles per rater. A is connected by
an overlapping ring; D has few links between two reference groups. This
contrast checks computational and prior sensitivity in two relevant
structures without starting the proposed four-allocation performance study.

Use the existing Series R model, alpha=0, beta=(-.4,0,.4), tau=(-.6,.6),
theta_p independently N(0,1) and u_r independently N(0,.6^2). There is no
person-by-rater local effect. These are the existing research proposal's
parameters. Do not subtract the sample mean of theta or u. With R seed
262018201 (Mersenne-Twister, Inversion, Rejection), draw theta, then u,
then one uniform per entry in the full 240 by 12 by 3 grid (person varies
fastest, then rater, then criterion). Generate 0/1/2 scores with the existing
RSM probability kernel and inverse CDF. A and D take subsets of the same
potential responses. Do not regenerate a more favorable realization.

Fit the qualified brms adjacent-category mapping with Person SD fixed at 1.
Estimate criterion contrasts, both thresholds, Rater SD, and latent effects
jointly. Summarize alpha=-mean(thresholds), tau_1, all three beta values,
Rater SD and variance, all 12 rater severities, all 240 abilities and the
12 previously marked PilotSelected ability differences. Differences use
paired joint draws with the saved direction and person IDs. Group labels
are the existing C-based reference groups, not observed population attributes.

## Priors and fixed computation

| Prior ID | Orthonormal criterion coefficients and each threshold | Rater SD |
|---|---|---|
| baseline | independent N(0,2^2) | half-normal(0,1^2) |
| sd_tighter | same as baseline | half-normal(0,.5^2) |
| sd_wider | same as baseline | half-normal(0,2^2) |
| calibration_tighter | independent N(0,1^2) | same as baseline |

The SD alternatives halve/double only that prior scale; the fourth halves
the calibration prior scales together. These sensitivity contrasts are not
validated default priors or an exhaustive prior analysis. A half-normal
scale s puts 95% probability below 1.96*s; the beta and threshold priors
also permit substantial variation on the logit scale. The fixed ability
distribution and normal rater population remain assumptions in every fit.

Run the eight A/D by prior combinations in the table's prior order, A then D
within each prior, using seeds 262018211 through 262018218. Each fit uses
four parallel chains, 1,000 warmup and 2,000 retained draws per chain,
thin=1, init=2, adapt_delta=.95, max_treedepth=12, diagonal metric and
18-digit CSV output. Compile once per generated prior-specific model and
reuse for both allocations. Use the installed brms/Stan versions; retain
the original plan, data, source identities, generated code and run metadata.
No seed changes, extra draws, replacement fits or outcome-based retuning.
Retain failures and continue the other prespecified fits where possible.

For numerical readiness require four complete chains, zero divergences and
tree-depth hits, E-BFMI >=.3 in each chain, R-hat <1.01 and bulk/tail ESS
>=400 for all free/transformed effects and reported targets (excluding
constants). Inspect lp__ as well. For each reported target also require
mean MCSE / posterior SD <=.05 and each endpoint MCSE / 95% interval width
<=.03. Compute equal-tail quantiles with R type 7 and autocorrelation-aware
[quantile MCSE](https://mc-stan.org/posterior/reference/mcse_quantile.html).
These are numerical precision goals, not interval-coverage guarantees.
Sampler checks follow the [Stan diagnostic guide](https://mc-stan.org/learn-stan/diagnostics-warnings.html).

## Answers and limits

Report diagnostics and all eight fit times, separating compilation and
postprocessing. Report calibration and variance summaries and, for person
and pair targets, prior-induced mean shifts relative to baseline posterior
SD, interval-width ratios and endpoint shifts with their Monte Carlo errors.
Distinct sampling seeds allow root-sum-square MCSE for between-fit mean and
endpoint differences. These quantify simulation error, not data uncertainty.
Only numerically ready targets support interpretation; retain unavailable
rows and their reasons. Do not select priors for closeness to the known truth.

Report descriptive timing, not an operational service guarantee. If all
fits complete with acceptable diagnostics/precision, proceed to the already
planned within-Bayes joint-versus-fixed-calibration comparison. If not,
identify the numerical obstruction before scaling up. Report the magnitude
of prior sensitivity without inventing a post-hoc practical-acceptability
cutoff. One realization cannot establish variance recovery, coverage, a
default prior, new-rater prediction or the ranking of A and D. No public API,
package dependency, plots or unrelated package tests are added.

## Completed result: 2026-09-18

Joint estimation completed for all eight fits at the intended 240-person,
12-rater scale. The specified prior changes affected the rater population
SD more than the means of the selected ability differences in this one
realization. This supports a next comparison of joint and fixed-calibration
ability inference; it does not establish prior robustness or a default prior.

### Computation and uncertainty in the rater population

All 32 chains returned successfully, with no divergences or tree-depth hits.
Across all fitted effects and reported targets, maximum R-hat was 1.00421,
minimum bulk ESS was 1,244 and minimum tail ESS was 2,235. Minimum chain
E-BFMI was .912. These pass the prespecified sampler criteria.

| Design | Prior | Four-chain seconds | Rater SD mean [95% interval] | Targets meeting both diagnostic and precision criteria |
|---|---|---:|---|---:|
| A | baseline | 50.5 | .698 [.433, 1.108] | 271/271 |
| D | baseline | 48.9 | .670 [.413, 1.087] | 270/271 |
| A | sd_tighter | 49.9 | .644 [.420, .968] | 271/271 |
| D | sd_tighter | 47.8 | .620 [.402, .938] | 271/271 |
| A | sd_wider | 48.6 | .709 [.434, 1.153] | 271/271 |
| D | sd_wider | 49.7 | .690 [.418, 1.138] | 270/271 |
| A | calibration_tighter | 48.5 | .694 [.433, 1.112] | 271/271 |
| D | calibration_tighter | 51.0 | .670 [.413, 1.072] | 271/271 |

Halving the SD prior scale reduces the posterior mean rater SD by .0540
(MCSE .0041) in A and .0498 (MCSE .0039) in D. Doubling it increases these
means by .0114 (.0053) and .0204 (.0048). Thus the population SD is sensitive
to these prior choices with 12 raters. This does not select the tighter
prior: the true generating SD of .6 is not a criterion for choosing a prior
after observing this one realization. All calibration coordinates, individual
raters, people and selected contrasts are retained in the summary table.

The all-target precision goal was **not fully met**. In D, the upper endpoint
MCSE for RaterVariance was .03255 under baseline and .03548 under sd_wider:
3.221% and 3.168% of their interval widths, exceeding the 3% goal. Those two
target rows remain unavailable for interval interpretation. Their numerical
values are retained; chains were not extended. This is insufficient precision
for these variance-tail summaries, despite satisfactory chain diagnostics.
All individual ability, rater SD and selected ability-difference targets met
their precision goals. Sampling readiness and target precision are separate
fields in the saved results.

Total four-chain execution time across eight sequential fits was 394.9
seconds, excluding four compilations (29.3 seconds total) and postprocessing
(38.0 seconds). This is a feasible pilot cost on this machine for these data,
not a general time bound or evidence of repeated-simulation feasibility.

### Consequences for the intended ability comparisons

The following ranges include all three alternatives relative to baseline
within each allocation. They are observed differences, including Monte Carlo
error, rather than uncertainty bounds for true prior effects.

| Target set | Largest absolute mean change / baseline posterior SD | Range of interval-width ratios |
|---|---:|---:|
| 240 people in A | .0461 | .9376--1.0734 |
| 240 people in D | .0453 | .9316--1.0734 |
| 12 selected pairs in A | .0381 | .9689--1.0736 |
| 12 selected pairs in D | .0280 | .9539--1.0359 |

For example, the largest standardized pair-mean change is A's
P133-minus-P120 under calibration_tighter: +.03082 logits, MCSE .00937,
or .03807 baseline SD. This maximum was selected across the reported
comparisons; it is not a simultaneous significance test. The largest pair
width ratio, 1.07361, occurs for A's P212-minus-P127 under sd_wider. Its
endpoint changes are -.12626 and +.09333 logits, with MCSEs .04849 and .03667.
Endpoint noise is therefore relevant when interpreting changes of a few
percent in interval widths. The evidence does not establish unchanged tails
or an ordering of A and D. All 72 pair sensitivity comparisons, including
the preselected within-group and between-group strata, are retained.

### Records and next decision

The initial input preflight stopped before any fit because the bridge's
first-observed factor order differs from numerical person-ID order. Explicit
label-to-index maps repaired both truth lookup and reported-target lookup;
the original preflight source/log remain in the ignored execution directory.
The same fixed seed reproduces the same potential responses. No data seed,
prior, sampling setting or selected pair was changed. With the corrected
maps, category probabilities agree with brms within 3.33e-16. A read-only
audit verified source/input/chain hashes, stored CSV summaries, original ID
maps and all paired-mean identities. The pre-generation plan above remains
verbatim in the evidence. Previous numerical studies and package tests were
not rerun.

The [runner](shared-rater-prior-pilot-0.2.4.R),
[summary table](shared-rater-prior-pilot-0.2.4-summary.csv),
[sensitivity calculation](shared-rater-prior-pilot-0.2.4-summary.R) and
[sensitivity table](shared-rater-prior-pilot-0.2.4-sensitivity.csv) accompany
the [portable evidence](shared-rater-prior-pilot-0.2.4-evidence.rds), which
contains data/truth, the original plan, generated models and complete numerical
diagnostics. Raw chains remain in the ignored execution directory with hashes
in the evidence. Its MD5 is `aac0382e11b47758733f18b0b87a31f7`.

The computational obstruction is now located: the two variance upper tails
need a separate precision budget if they become decision targets. This is
not a reason to repeat the present eight fits or discard their resolved
ability summaries. The next bounded work can reuse these joint fits and
responses for the planned within-Bayes comparison with calibration fixed at
a declared posterior point. It must distinguish calibration integration
from prior/estimator changes. Repeated-data coverage, width, availability,
prior sensitivity near zero variance and design rankings remain open.
