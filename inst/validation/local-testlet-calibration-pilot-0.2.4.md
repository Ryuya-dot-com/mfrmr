# Same-sample calibration and scoring: a bounded coverage pilot

2026-09-17. This specification precedes data generation and fitting. It is a
pipeline pilot, not the previously proposed multi-rater study or a confirmatory
coverage experiment. Existing numerical code and fitted examples are reused.

## Question and design

When the same responses estimate the calibration and score the people, how
does plug-in equal-tail coverage compare with an oracle using the true
calibration? Does the small prototype fit reliably beyond its six-person
examples? Separate individual abilities from differences between people.

Four cells cross N={24,120} and local variance v={0,.49}, with **10 independent
datasets per cell**. Every person is rated by the same two fixed raters on
three criteria, categories 0/1/2, with no missing observations. True structural
coordinates are alpha=.2, beta1=-.4, beta2=.1, rater1=-.25, tau1=-.6; the other
criterion, rater and threshold follow the existing sum constraints. The
ability prior is fixed N(0,1). Generate independent standard-normal theta and
two local normals per person, scaling the latter by sqrt(v). Do not sort or
sample-center these effects. One local effect is shared by the three criteria
within its person-rater pair, never across people. Draw response categories
using independent uniforms and the existing qualified probability function.

Cells use unique deterministic seeds `260917000 + 1000*Cell + Replicate`,
Mersenne-Twister/Inversion/Rejection. Both methods use the same generated
dataset; cells are not coupled through common random numbers. Keep all latent
effects, uniforms, probabilities and responses so generation can be audited.
Before fitting, check category normalization and adjacent logits, the
person-rater ownership identity, and exact regeneration from each saved seed.

The oracle uses the true calibration. The plug-in method refits all six
coordinates using the existing bounded L-BFGS-B path and then treats those
estimates as known when scoring. This intentionally tests the uncorrected
plug-in interval; it is not a calibration-uncertainty correction. Both methods
use continuous posterior CDFs, so a normal-interval approximation is not part
of the comparison.

## Fitting and failure policy

Use the same start `(0,0,0,0,-.5,.25)` in every dataset, independent of the
truth. Preserve existing bounds, adaptive quadrature and stopping controls.
One fit per dataset, with no automatic new start or retry. A fit is numerically
ready only with no capture error/warning, native code 0, projected score
<=1e-5, and no artificial search boundary. Exact v=0 is allowed and recorded
separately; it is not a failure or proof that the population variance is zero.
Save non-ready values, histories and reasons. Oracle evaluation still runs
when the plug-in fit is non-ready. All plugin target rows remain in the
attempted denominator, with unavailable numerical results indicated explicitly.

## Scoring and numerical qualification

Score every person's theta, plus four prespecified disjoint differences
P1-P2, P3-P4, P5-P6 and P7-P8. Pair choice is fixed before seeing responses or
latent values. An equal-tail 95% interval contains truth t exactly when its
continuous CDF satisfies .025<=F(t)<=.975. Use that identity to avoid computing
two quantiles per person when only coverage is needed. This pilot does not
estimate interval widths.

Reuse the qualified continuous person and rotated contrast density functions.
Within each method/dataset, reuse whole-fixture GH evaluations at the same
parameter vector to supply person normalizers and moments. For each target
evaluate continuous mass (split at its GH posterior mean) and the tail CDF at
truth, with `integrate()` absolute/relative tolerance 1e-8, subdivisions 200.
Start with local/midpoint orders 61/41 then 121/81; refine only unresolved
targets to 181/121 and 241/181. Require mass error <=1e-7, consecutive CDF
difference <=1e-6, posterior mean difference <=1e-6, and propagated integration
error estimate <=1e-6. Require CDF within [0,1]. If within 1e-6 of either
coverage cutoff, refine; if still ambiguous at the final rule, report an
unresolved event rather than force a covered/noncovered label. Preserve all
attempts, integration errors, captures and warnings.

## Reporting and Monte Carlo uncertainty

For each cell/method, report attempted, numerically available and covered
counts for all persons, true-ability bands theta<-1, -1<=theta<=1, theta>1,
and the four fixed pairs. Report availability, coverage among available
targets, and covered/attempted separately. Missing intervals are not silently
counted as ordinary noncoverage. Report bias and RMSE only among numerically
available targets, with those denominators. Preserve per-dataset rows.

For oracle-versus-plugin coverage differences, use targets available for both
methods and report the matched denominator. Never compare a selected plugin
subset with the entire oracle sample without stating the selection. Estimate
Monte Carlo standard errors at the **dataset** level. For a pooled ratio
r=sum(c_b)/sum(a_b), use `sd(c_b-r*a_b)/(sqrt(B)*mean(a_b))`; for the paired
difference substitute the within-dataset difference in covered counts.
The same principle applies to availability and covered/attempted ratios.
Do not use a binomial SE treating all people/pairs as independent replications.

Ten datasets give only nine degrees of freedom for these MCSE estimates; one
failure changes a cell's fit-ready rate by ten percentage points. There is no
acceptance threshold for a coverage rate or between-method difference in this
pilot. An apparent departure from .95 may be Monte Carlo variation, fit
selection, or a real calibration effect. This study cannot establish fixed-
ability coverage, a variance correction, or public interval eligibility.

Freeze the seeds and source hashes before fitting, checkpoint each completed
dataset, and resume only identical source/data identities. Existing completed
records, including failed fits, are read without rerunning them. Final checks
audit planned/completed denominators, generator identities, retained failures,
and source identity. No old full-package, FairZ or TAM experiments are rerun.

## Recorded results, 2026-09-17

All 40 planned datasets completed. **23 fits meet the prespecified numerical
requirements; 14 stop with native code 0 but an excessive projected score, and
three stop because quadrature is unresolved at a trial point.** Consequently,
this pilot identifies an optimization obstacle before a larger coverage study.
It does not qualify plug-in intervals or establish how their coverage changes
with sample size. The numerical scoring path itself resolves every attempted
oracle target and every target supplied with a ready estimated calibration.

### Fitting: the reason to defer a larger run

| N | True v | Fits ready / planned | Projected-score failures | Trial-integration errors | Returned exact-zero estimates / ready exact-zero estimates |
|---|---|---|---|---|---|
| 24 | 0 | 8/10 | 2 | 0 | 7 / 5 |
| 120 | 0 | 3/10 | 7 | 0 | 5 / 2 |
| 24 | .49 | 8/10 | 2 | 0 | 1 / 1 |
| 120 | .49 | 4/10 | 3 | 3 | 0 / 0 |

All 14 score failures have the native message
`CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH`. Their projected scores range
from 1.153283e-5 to 2.647283e-4, above the unchanged 1e-5 requirement. Across
the 37 returned fits, 36 use that function-reduction stop and one uses the
projected-gradient stop. None returns a nonzero native code; three other fits
abort before a native result is returned. There are no captured fit warnings.
The reference score is the gradient of the **total** log likelihood: applying
the same absolute threshold at both N values is not evidence that a larger
sample is statistically harder to estimate. Function-reduction and score
criteria need to be examined together with objective scaling.

The three integration errors are `cell-04-rep-06`, `cell-04-rep-08` and
`cell-04-rep-10`. Each retains the initial evaluation and the first distant
trial in its six-row quadrature history. In reps 06/08 the trial is
`(8,-8,-8,-8,8,16)`; in rep 10 it is
`(8,-8,-8,-8,.572744,16)`. At the final GH241 rule, score changes from GH181
are 5.821950e-5, 2.810215e-5 and 2.064098e-6, respectively, exceeding 1e-6.
The first two also exceed likelihood/moment tolerances. These are unresolved
exploratory trial points, not estimates at the bounds or evidence that no
interior optimum exists. The wrapper correctly retains the errors and
continues the other datasets; it cannot repair the search trajectory.

### Coverage: comparisons retain the same target subset

Person coverage below is in percent. The oracle-all column uses every planned
person; the other two coverage columns use the same people from ready fits.
The difference is plug-in minus oracle on that matched subset, with a
dataset-cluster MCSE in **percentage points**, not a confidence interval.

| N | True v | Oracle-all covered / attempted (%) | Matched persons | Oracle matched (%) | Plug-in matched (%) | Difference (MCSE), pp |
|---|---|---|---|---|---|---|
| 24 | 0 | 224/240 (93.33) | 192 | 92.71 | 94.27 | +1.56 (1.08) |
| 120 | 0 | 1147/1200 (95.58) | 360 | 96.94 | 95.56 | -1.39 (.86) |
| 24 | .49 | 222/240 (92.50) | 192 | 92.19 | 93.75 | +1.56 (1.33) |
| 120 | .49 | 1141/1200 (95.08) | 480 | 96.25 | 94.38 | -1.88 (.78) |

The plug-in person availability rates are 80%, 30%, 80% and 40%, respectively.
Covered/attempted rates are separately 75.42%, 28.67%, 75.00% and 37.75%.
Those last rates describe a combined availability-and-coverage outcome;
unavailable intervals retain `Covered=NA` in the target rows. In total,
2,880 oracle persons and 1,224 plug-in persons are numerically available.

The four prespecified pairs per dataset yield the following separate result.
The oracle resolves all 160 pairs, with cell-wise coverage of 90.0%, 92.5%,
92.5% and 97.5%. The table again restricts both methods to common available
pairs, of which there are 92 overall.

| N | True v | Matched / planned pairs | Oracle matched (%) | Plug-in matched (%) | Difference (MCSE), pp |
|---|---|---|---|---|---|
| 24 | 0 | 32/40 | 90.625 | 87.500 | -3.125 (3.081) |
| 120 | 0 | 12/40 | 91.667 | 91.667 | 0 (0) |
| 24 | .49 | 32/40 | 90.625 | 93.750 | +3.125 (3.081) |
| 120 | .49 | 16/40 | 100.000 | 93.750 | -6.250 (5.705) |

The zero observed difference MCSE in the second pair cell means the few
available dataset differences are all zero; it does not establish no sampling
uncertainty or equivalence. Only three or four datasets supply plug-in results
in the N=120 cells. Keeping all ten clusters in the ratio calculation preserves
the declared denominator but does not resolve this information shortage or
selection by fit readiness. No formal coverage acceptance or rejection is made.

The [full summaries](local-testlet-calibration-pilot-0.2.4-summaries.csv) retain
ability-band coverage, bias and RMSE with their actual available denominators.
Oracle coverage targets .95 when averaging over the specified latent ability
distribution and responses. Conditioning instead on a true-ability band need
not preserve that target: oracle upper-band estimates here range from 82.35%
to 92.70%. Such band results are relevant to measurement users but cannot be
interpreted using the marginal .95 property alone. This pilot neither fixes
ability values across repeated samples nor evaluates a boundary-aware
calibration-uncertainty correction.

### Numerical evidence and retained records

All 4,356 available method/target combinations resolve at local GH121 and,
for contrasts, midpoint GH81 after comparison with 61/41. Their 8,712 saved
attempts contain no scoring errors or warnings. Maximum final discrepancies:

| Quantity | Observed maximum | Prespecified tolerance |
|---|---|---|
| Continuous posterior mass error | 6.126e-11 | 1e-7 |
| CDF change across rules | 6.980e-9 | 1e-6 |
| Posterior mean change across rules | 2.927e-9 | 1e-6 |
| Propagated CDF integration error estimate | 2.933e-8 | 1e-6 |

The smallest distance to either coverage cutoff is 6.042e-5, above the 1e-6
ambiguity limit. No CDF event needs a higher rule or remains unresolved.
There are 6,080 retained target rows, including 1,724 unavailable plug-in rows.
Thirteen read-only audits pass for lineage, generation identities, target and
cluster denominators, preserved failures, coverage labels and saved numerical
gates. These audits verify this run's accounting and scoring tolerances;
they do not convert the 17 non-ready fits into successes.

The [runner](local-testlet-calibration-pilot-0.2.4.R),
[manifest](local-testlet-calibration-pilot-0.2.4-manifest.csv) and
[aggregator](local-testlet-calibration-pilot-0.2.4-summary.R) reproduce the
procedure. The [portable evidence](local-testlet-calibration-pilot-0.2.4-evidence.rds)
contains all 40 generated datasets, latent values and uniforms, the frozen plan,
all fit histories, every scoring attempt, the aggregate tables and audits.
It is approximately 2.03 MB. The `-status.csv`, `-counts.csv`, `-rows.csv`,
`-paired.csv`, `-replicate_rows.csv`, `-scoring.csv` and `-audit.csv` companions
make the corresponding summaries directly inspectable.

Raw checkpoints are in
`validation-results/local-testlet-calibration-pilot-20260917/`. From the
development repository root, run
`Rscript inst/validation/local-testlet-calibration-pilot-0.2.4-summary.R`
to aggregate them without fitting or
scoring. Existing result/fit checkpoints are reusable only after identity
checks. The evidence RDS can be inspected directly without those raw files.

Before any fitting, four manifest row-name warnings were removed, pair IDs
were kept integer, and empty captured-error strings were kept empty. All 40
generated data hashes remained unchanged. The initial generation plan and
source are retained both in the raw directory and the portable evidence;
`plan$preflight_note` records that preparation. The full prespecified text is
stored in `plan$design`, before this results section was added. An aggregation
syntax correction and the subsequent saved-attempt audit changed only the
read-only reporting code; no dataset was regenerated or fit retried.

The numerical source identities remained unchanged throughout fitting/scoring:

| Source | MD5 |
|---|---|
| Pilot runner | `e03d756810702a20349f7b4652463997` |
| Conditional quantile helper | `75fe9d28ea7c38b283fdf93bacb13d9f` |
| Joint-estimation helper | `e599de0ca8fed081da0b3f519505d690` |
| Stress/reference kernel | `812999e7da7ecbbdbb654974529058aa` |
| Fixed-parameter reference | `6bacb70c9d4c0fba27bef70a508f0f88` |

The evidence also records the aggregation sources and all 40 data hashes.
Parent commit: `b96047612ec4959e6e8a594e3718a1e3c906a973`;
R 4.6.1, `aarch64-apple-darwin23`. Frozen plan creation through final checkpoint
spanned 18:26:06--18:34:03 JST, including preparation. No public source, API,
dependency or release eligibility changed; existing full-package, TAM and
FairZ evidence was reused.

### Next decision

Work next on the 17 saved non-ready fits, with successful saved cases as
controls, rather than increase replication of this stopping policy. Examine
scaling the optimizer's objective and gradient together by person count and
aligning its function/gradient stopping controls with the unchanged final
total-score requirement. Scaling may help avoid the first distant trial; its
benefit is a hypothesis to check, not a demonstrated remedy. Validate any
change in a separate follow-up with declared comparisons and preserved original
outcomes. A larger recovery/coverage study follows only after that path is
reliable enough to avoid this degree of fit selection. Shared random-rater
estimation and equal-budget rating-design comparisons remain later, distinct
research steps.
