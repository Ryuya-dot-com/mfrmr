# Independent same-sample calibration pilot

2026-09-17. Prespecified before generation or fitting. The optimizer controls
selected on the earlier 23 datasets are fixed for all new datasets. This is
an independent pipeline/performance pilot with ten replications per cell,
not a confirmatory coverage experiment.

## Question and design

Does the selected optimization policy retain numerical readiness on new
datasets, and how does uncorrected plug-in equal-tail coverage compare with
known-calibration oracle coverage for abilities and differences between people?
The same responses estimate calibration and score people. Compare the methods
on the same generated targets so calibration estimation is the relevant change.

Use the earlier four cells: N=24/120 crossed with true person-rater local
variance v=0/.49, ten independent datasets each. Two fixed raters each rate
three criteria with categories 0/1/2 and no missing entries. Keep alpha=.2,
beta1=-.4, beta2=.1, rater1=-.25, tau1=-.6, the existing sum constraints, and
the fixed N(0,1) ability distribution. Reuse the qualified generator: iid
normal abilities and local effects without sample centering/sorting; each
local effect is shared only within its person-rater pair. This remains the
person-local dependence model, not a shared random-rater severity model.

Use seeds `261017000 + 1000*Cell + Replicate` and the generator's fixed
Mersenne-Twister/Inversion/Rejection configuration. The seed set is disjoint
from the original pilot. Generate all 40 datasets before fitting, check their
probability/ownership identities and exact regeneration, and freeze their
hashes. Preserve latent values, uniforms, response probabilities and responses.
No original or optimizer-selection dataset is pooled with this pilot.

## Fixed fitting and scoring policy

Use the selected driver with the same start `(0,0,0,0,-.5,.25)` in every
dataset and controls `maxit=250`, `fnscale=N`, `factr=0`, `pgtol=5e-6/N`.
Keep its bounds and adaptive GH orders 61/121/181/241. No new start, automatic
retry, dataset-specific control change or extra optimizer variant is allowed
within this pilot. Preserve every stop and failed trial history.

Fit readiness requires native code 0, total projected score <=1e-5, no
artificial-bound solution, and no captured errors/warnings. Exact v=0 is
allowed. Every returned point gets one higher-order reference evaluation
(terminal order +60): require likelihood/moment differences <=1e-7, gradient
difference <=1e-6 and reference projected score <=1e-5, with no reference
error/warning. Plug-in scoring is unavailable unless both fitting and reference
requirements pass; the recorded `FitReady` includes this combined gate.

Reuse the existing continuous-CDF scorer, unchanged, for every person and the
four prespecified disjoint differences P1-P2, P3-P4, P5-P6, P7-P8. Oracle
scoring runs even if refitting fails. Coverage means .025<=F(truth)<=.975.
Use the same local/midpoint quadrature refinement, integration tolerances,
mass/CDF/mean checks and cutoff-ambiguity rule as the original pilot. All
attempts are retained. No interval widths or calibration-uncertainty correction
are introduced. Availability and marginal prior-predictive coverage are
different outcomes; true-ability-band coverage is a separate conditional target.

## Reporting and decisions

Keep all 40 fits and 6,080 method/target rows (2,880 people and 160 pairs per
method). Report numerical availability, coverage among available targets,
covered/attempted, bias and RMSE, separately for all persons, theta<-1,
-1<=theta<=1, theta>1, and pairs. Unavailable coverage stays NA. Compare
oracle and plug-in coverage on common available targets. Reuse the existing
dataset-cluster ratio MCSE, retaining all ten clusters including zero-count
ones. No binomial SE treating people as independent simulation replications.

Do not declare coverage acceptable from ten datasets, or infer general
reliability from a zero observed failure rate. Any failure remains part of
this pilot and is inspected separately without changing its result. If the
new numerical path has an unresolved issue, address that before a larger run.

For replication planning, use a provisional MCSE goal of .005 (0.5 percentage
points) for both coverage and the paired plug-in-minus-oracle difference,
for all persons and for the four pairs. Report
`ceil(10 * (observed_MCSE / .005)^2)` per cell/metric. This inverse-square
projection assumes stable variance and availability; ten clusters give a
noisy planning variance. A zero MCSE is uninformative for planning, not a
recommendation of zero replications. Use a provisional minimum of 200 datasets
per cell when forming a candidate count from the maximum projected requirement
for oracle coverage, plug-in coverage and the paired difference, across persons
and pairs. This minimum is a planning floor, not proof of the precision target.
Do not start that main study here; final sample size and stopping rules require
their own frozen protocol. Ability bands remain exploratory in this pilot.

Reuse numerical helpers and the common aggregation function; generalize only
the latter's input/output locations and return its evidence object. Record
new aggregation-source hashes without rewriting earlier evidence. No repeated
optimizer bridges, TAM comparisons, FairZ runs or full-package tests are needed
unless a new discrepancy appears. Audit new controls, data/source provenance,
saved numerical gates, complete denominators and errors without rerunning fits.

## Recorded results, 2026-09-17

**All 40 independently generated datasets meet the fixed fitting and scoring
requirements.** Every optimizer stops on its projected-gradient criterion;
the largest total score is 4.669062e-6. All 6,080 method/target combinations
are numerically available. No fitting, reference or scoring error/warning is
observed, and no retry or control adjustment is made.

The performance result differs by target and sample size: at N=24, plug-in
person coverage is about three percentage points lower than oracle coverage
in both variance conditions. At N=120 the observed differences are small.
Pair coverage is much less precisely estimated with only four pairs per
dataset. These are independent pilot results, with ten dataset clusters per
cell, rather than a coverage qualification or a general sample-size finding.

### Person coverage and estimation error

Every person is available for both methods, so the matched denominator equals
the planned denominator. Percentages below refer to nominal 95% equal-tail
intervals; difference and its dataset-cluster MCSE are in percentage points.

| N | True v | Persons | Oracle covered (%) | Plug-in covered (%) | Plug-in minus oracle (MCSE), pp |
|---|---|---|---|---|---|
| 24 | 0 | 240 | 230 (95.83) | 222 (92.50) | -3.33 (1.36) |
| 120 | 0 | 1,200 | 1,149 (95.75) | 1,153 (96.08) | +.33 (.33) |
| 24 | .49 | 240 | 234 (97.50) | 227 (94.58) | -2.92 (1.87) |
| 120 | .49 | 1,200 | 1,135 (94.58) | 1,134 (94.50) | -.08 (1.04) |

At N=24, these are eight and seven fewer covered abilities after refitting.
Person RMSE also increases from .6133 to .6737 at v=0 and from .5809 to .6332
at v=.49. At N=120, oracle/plug-in RMSEs are .5242/.5245 and .6392/.6413.
The common random targets make these comparisons interpretable without the
fit-selection problem of the earlier pilot. However, the small number of
independent datasets limits precision; this run does not establish that
plug-in coverage is acceptable at N=120 or that the N=24 differences generalize.

Availability and covered/attempted remain separate output columns. They happen
to be 100% and equal to coverage, respectively, because there are no unavailable
targets in this run. Zero observed failures is not a demonstrated population
failure rate of zero.

### Pair differences and ability bands

| N | True v | Pairs | Oracle covered (%) | Plug-in covered (%) | Difference (MCSE), pp |
|---|---|---|---|---|---|
| 24 | 0 | 40 | 37 (92.5) | 36 (90.0) | -2.5 (2.5) |
| 120 | 0 | 40 | 38 (95.0) | 39 (97.5) | +2.5 (2.5) |
| 24 | .49 | 40 | 40 (100.0) | 40 (100.0) | 0 (0) |
| 120 | .49 | 40 | 38 (95.0) | 38 (95.0) | 0 (0) |

The zero MCSEs arise from constant observed dataset differences; all-covered
pairs also produce zero empirical coverage variance in the N=24/v=.49 cell.
Neither observation establishes equivalence, perfect coverage or zero Monte
Carlo uncertainty in future samples. Person coverage cannot stand in for
pair-difference coverage: their observed calibration effects and simulation
precision are different.

The [full summaries](local-testlet-independent-pilot-0.2.4-summaries.csv) include
all true-ability bands, counts, MCSEs, bias and RMSE. For N=24/v=0, plug-in
coverage is 84.0% below -1, 97.37% in [-1,1], and 84.21% above 1; the outer
bands contain only 50 and 38 people. Oracle band coverage is already 90.0%,
99.34% and 89.47%, respectively. With known calibration, an exact equal-tail
posterior interval averages to its nominal level under the specified latent
population, not necessarily within
each true-ability band. These exploratory band results therefore require a
distinct interpretation from overall coverage and from fixed-ability repeated
sampling. They are not a stand-alone proof of a calibration-estimation defect.

### Numerical outcome and evidence checks

All four cells have 10/10 numerically ready fits. Exact-zero local-variance
estimates occur 5/10 and 8/10 times in the v=0 cells, and 2/10 and 0/10 times
in the v=.49 cells at N=24 and N=120. They remain valid boundary fits under
the declared rule; their occurrence does not qualify variance-parameter
intervals or establish accurate variance recovery.

Every fit uses GH121 at its terminal point and passes its GH181 reference.
The maximum log-likelihood, posterior-moment and gradient differences are
5.685e-13, 7.661e-15 and 6.056e-13; the maximum reference projected score is
4.669062e-6. These agree with the unchanged tolerances.

All 6,080 CDF events resolve at local GH121 and, for pairs, midpoint GH81 after
comparison with 61/41. The 12,160 saved scoring attempts have no captures of
errors or warnings. Maximum mass error is 1.971e-11, CDF change 1.198e-8,
posterior-mean change 1.818e-9 and propagated integration-error estimate
2.779e-8. The nearest coverage cutoff is 3.855e-6 away, above the frozen 1e-6
ambiguity limit. No event needs further refinement or becomes unavailable.

Twenty read-only audits pass: the 13 common accounting/scoring checks plus
seven independent-study checks for the old input artifacts, disjoint seeds,
record provenance, fixed controls/start and higher-order readiness. Existing
optimizer bridges, external TAM comparisons, FairZ and full-package suites
are reused rather than run again. These audits support the numerical/accounting
claims; they do not turn ten datasets into a precise performance study.

### Replication planning and next decision

The [planning table](local-testlet-independent-pilot-0.2.4-planning.csv) applies
the prespecified inverse-square MCSE projection to all six primary planning
metrics per cell (oracle coverage, plug-in coverage and their paired difference,
each for persons and pairs). The [cell-level projection](local-testlet-independent-pilot-0.2.4-replication.csv)
is:

| N | True v | Largest finite projection | Zero-variance metrics with no usable projection | Provisional count with 200 floor |
|---|---|---|---|---|
| 24 | 0 | 667 | 0 | 667 |
| 120 | 0 | 445 | 0 | 445 |
| 24 | .49 | 156 | 3 | 200 |
| 120 | .49 | 445 | 1 | 445 |

The target MCSE is .005 throughout. Pair coverage drives the largest finite
requirements in three cells. For example, N=24/v=0 plug-in pair coverage has
MCSE .040825, projecting to 667 datasets; plug-in person coverage projects to
90. The third cell's provisional 200 is especially tentative because all pair
metrics have zero observed variance; it is not evidence that 200 suffices.

If the four-pair design is retained, **700 datasets per cell (2,800 total)**
is a concrete fixed-size candidate obtained by rounding up the largest finite
projection and applying it across cells. It is a planning candidate, not a
guarantee of .005 MCSE, and the main study has not started. A final protocol
must declare its new seeds, primary claims, interval-assessment rules and
handling of achieved MCSE/availability before execution.

Before committing to that computational cost, the main-study design should
also consider the number of prespecified disjoint pairs evaluated from each
fitted dataset. Four pairs use only eight of the available people. More pairs
could reduce within-dataset sampling noise without additional calibration fits,
but shared calibration induces dependence, so the gain must be assessed using
dataset-cluster variance rather than assuming independent-pair scaling. This
is a design-efficiency question; the present four-pair result remains intact.

The numerical path needs no further adjustment on the evidence from this run.
The next research decision is the allocation of simulation effort and a frozen
main coverage protocol. The N=24 person result motivates evaluating calibration
uncertainty explicitly; this pilot does not implement or validate a correction.
It also does not introduce shared random-rater estimation or establish the
performance of alternative rating designs.

### Reproduction and source identities

The [runner](local-testlet-independent-pilot-0.2.4.R) calls the unchanged
generator, optimizer driver and CDF scorer. The [summary wrapper](local-testlet-independent-pilot-0.2.4-summary.R)
calls the common aggregator, which now accepts input/output locations and
returns its evidence object. Its statistical calculations are unchanged;
the old default locations remain available. New reporting-source hashes are
recorded, and earlier result/evidence files were not rewritten.

The [portable evidence](local-testlet-independent-pilot-0.2.4-evidence.rds),
approximately 2.51 MB, contains the pre-run plan, all 40 generated datasets,
latent variables and uniforms, every fit and reference evaluation, all scoring
attempts, tables and audits. The manifest, status, counts, target rows,
replicate rows, summaries, paired results, scoring audit, planning and
replication CSV companions provide inspectable versions of the corresponding
parts. Raw checkpoints are in
`validation-results/local-testlet-independent-pilot-20260917/`.

From the development repository root,
`Rscript inst/validation/local-testlet-independent-pilot-0.2.4-summary.R`
aggregates those checkpoints without fitting/scoring. The evidence RDS can
be inspected directly without the raw directory. The numerical runner checks
source, input and data identities before reusing any saved fit or result.

Runner MD5: `2b8ec78b632541d391a1017e9d93f86f`; optimizer-driver MD5:
`bf874cec3c9fd7538e531eba3544a69a`. The plan records all seven numerical source
hashes, all 40 new dataset hashes, and the two original input evidence hashes
(`217d865d64e122ad22165cd14124bd85` and `3fca4073561044a6603eddb62186fd71`).
Execution spans 19:18:33--19:27:01 JST with R 4.6.1 on
`aarch64-apple-darwin23`, parent commit `96e068e`. No production API,
dependency, public interval eligibility or 0.2.4 release requirement changes.
