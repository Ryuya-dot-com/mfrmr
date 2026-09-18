# Same-sample calibration: main coverage results

Reviewed 2026-09-18. The fixed 1,200-dataset experiment is complete. Under
positive person-rater local variance, treating estimated calibration as known
reduced person-interval coverage relative to known calibration by 1.278
percentage points at N=24 and 0.380 points at N=120. The zero-variance cells
did not show this pattern. Ability differences have distinct results and must
be assessed separately. All planned primary Monte Carlo precision goals were
met; no additional replications are needed to meet those goals.

## Question and scope

When the same people supply the calibration data and receive scores, how much
does substituting estimated calibration change the coverage of nominal 95%
equal-tail intervals? Comparing both methods on the same generated people and
pairs isolates the effect of that substitution under the declared model.

The [frozen protocol](local-testlet-main-coverage-0.2.4-protocol.md) crosses
N=24/120 with local variance v=0/.49, with 300 independent datasets per cell.
Two fixed raters each score three criteria, giving six ordinal scores per
person. A normal local effect is shared by one person's three scores from
one rater. Both methods account for this dependence. The ability distribution
is fixed at N(0,1); the plug-in method estimates six calibration coordinates
from the same responses. Every person and 12 prespecified disjoint person
pairs per dataset are evaluated.

This comparison does not evaluate ignoring local dependence, shared random
rater effects across people, an uncertainty correction, or rating designs.
Its oracle 95% reference averages over the declared latent effects and
responses, rather than promising 95% coverage at each fixed ability.

## Completion and availability

The run started at 2026-09-17 20:54:52 JST. All datasets were attempted by
2026-09-18 04:03:10; final aggregation completed at 04:03:31. The final audit
retained all 1,200 datasets and 201,600 assigned method/target rows. The frozen
numerical sources, reporting sources and inputs still match their saved
hashes, as does the final evidence file. No failed case was replaced or retried.

| N | v | Attempted datasets | Fit/reference ready | Ready fits at estimated v=0 |
|---:|---:|---:|---:|---:|
| 24 | 0 | 300 | 300 | 171 |
| 120 | 0 | 300 | 294 | 153 |
| 24 | .49 | 300 | 300 | 33 |
| 120 | .49 | 300 | 298 | 0 |

The oracle supplies all 100,800 assigned targets. Plug-in scoring supplies
99,742: 85,439 person targets and 14,303 pairs. The following plug-in table separates
availability from coverage. Covered/assigned measures receiving an available
interval that covers; it does not relabel unavailable intervals as observed
noncoverage. Complete method-specific counts, coverage, MCSEs and intervals
are in the [summary table](local-testlet-main-coverage-0.2.4-summaries.csv).

| N | v | Target | Assigned | Available | Covered | Availability (%) | Covered/assigned (%) |
|---:|---:|:---|---:|---:|---:|---:|---:|
| 24 | 0 | Person | 7,200 | 7,200 | 6,856 | 100.000 | 95.222 |
| 120 | 0 | Person | 36,000 | 35,280 | 33,624 | 98.000 | 93.400 |
| 24 | .49 | Person | 7,200 | 7,200 | 6,763 | 100.000 | 93.931 |
| 120 | .49 | Person | 36,000 | 35,759 | 33,818 | 99.331 | 93.939 |
| 24 | 0 | Pair | 3,600 | 3,600 | 3,452 | 100.000 | 95.889 |
| 120 | 0 | Pair | 3,600 | 3,528 | 3,387 | 98.000 | 94.083 |
| 24 | .49 | Pair | 3,600 | 3,600 | 3,406 | 100.000 | 94.611 |
| 120 | .49 | Pair | 3,600 | 3,575 | 3,385 | 99.306 | 94.028 |

Eight fits returned native code 52, `ERROR: ABNORMAL_TERMINATION_IN_LNSRCH`:
cell 2 replications 3, 18, 21, 27, 234 and 244, and cell 4 replications 224
and 290. Although their projected scores were below 1e-5 and their reference
comparisons passed, the fixed policy also requires native code 0. All eight
remain unready, accounting for 1,056 unavailable plug-in targets. There were
no captured R fitting errors or warning trials; this does not negate native
optimizer failures. The [status table](local-testlet-main-coverage-0.2.4-status.csv)
retains every fit, including three additional returned zero-variance points
that were not ready.

Two further targets remain unresolved after all four allowed scoring rules:

- `cell-04-rep-0237`, person P90: the final CDF at truth was
  0.974999546843, within 4.532e-7 of the .975 cutoff. This violates the
  prespecified 1e-6 ambiguity rule even though the numerical CDF stabilized.
- `cell-04-rep-0282`, P19 minus P20: the final CDF was 0.345674336476,
  but normalization mass error was 1.131e-7, above the 1e-7 limit.
  Stability between rules does not remove this normalization failure.

These are recorded as unavailable, not forced into either coverage category.

## Primary coverage comparison

The two coverage columns below use exactly the same available targets.
Differences are plug-in minus oracle, in percentage points (pp). With failures,
these comparisons are conditional on common numerical availability; they do
not recover coverage differences for unavailable cases.

| N | v | Target | Matched | Oracle (%) | Plug-in (%) | Difference (pp) | MCSE (pp) | Pointwise 95% MC interval (pp) |
|---:|---:|:---|---:|---:|---:|---:|---:|:---|
| 24 | 0 | Person | 7,200 | 94.806 | 95.222 | +0.417 | 0.252 | [-0.078, 0.912] |
| 120 | 0 | Person | 35,280 | 95.147 | 95.306 | +0.159 | 0.075 | [0.012, 0.306] |
| 24 | .49 | Person | 7,200 | 95.208 | 93.931 | -1.278 | 0.257 | [-1.784, -0.772] |
| 120 | .49 | Person | 35,759 | 94.952 | 94.572 | -0.380 | 0.100 | [-0.578, -0.183] |
| 24 | 0 | Pair | 3,600 | 94.917 | 95.889 | +0.972 | 0.224 | [0.531, 1.413] |
| 120 | 0 | Pair | 3,528 | 95.748 | 96.003 | +0.255 | 0.129 | [0.001, 0.509] |
| 24 | .49 | Pair | 3,600 | 95.194 | 94.611 | -0.583 | 0.266 | [-1.107, -0.059] |
| 120 | .49 | Pair | 3,575 | 94.741 | 94.685 | -0.056 | 0.194 | [-0.438, 0.326] |

For individual abilities, the positive-variance cells show reduced coverage,
with a larger observed reduction at N=24. At zero variance, the N=24 interval
for the difference includes zero and N=120 shows a small increase. Therefore,
same-sample plug-in calibration does not uniformly reduce coverage. In
particular, the small independent pilot's N=24 zero-variance reduction does
not persist in this main experiment; the pilot is not pooled into these results.

For ability differences, the reduction at N=24, v=.49 is 0.583 pp. At
N=120, v=.49, the estimate is close to zero but the MC interval allows changes
from -0.438 to +0.326 pp; this is not an equivalence finding. Zero-variance
pair coverage increases. Higher coverage alone does not establish a superior
interval procedure, because widths were not measured. Comparing which separate
intervals include zero is also not a test of interactions between targets or
sample sizes.

All eight primary differences are shown together. MCSEs use independent
datasets as clusters, retaining zero-available clusters; persons and pairs
are not treated as independent simulation replications. The MC intervals are
estimate +/- t(299,.975) times MCSE, describing simulation precision of the
aggregate estimates. They are distinct from the individual 95% score intervals
being evaluated, and are neither simultaneous intervals nor equivalence tests.
Unrounded values are in the [paired table](local-testlet-main-coverage-0.2.4-paired.csv).

## Secondary findings and precision

At N=24, v=.49, coverage varies substantially by true ability in both methods:

| True ability | Targets | Oracle (%) | Plug-in (%) |
|:---|---:|---:|---:|
| Below -1 | 1,089 | 89.256 | 89.164 |
| -1 through 1 | 4,955 | 98.002 | 96.609 |
| Above 1 | 1,156 | 88.841 | 86.938 |

The oracle already has lower tail coverage, so the entire tail deficit cannot
be attributed to calibration estimation. The greater plug-in loss in the upper
band is a secondary conditional result, not evidence of a uniform effect at
every ability or a breach of a prespecified 95% conditional oracle property.

The saved summaries retain posterior-mean bias and RMSE for both methods and
all ability bands. For example, at N=24, v=.49, person RMSE increases from
0.6404 to 0.6653 and pair RMSE from 0.9069 to 0.9099. These descriptive outcomes
do not replace interval coverage. At N=120, method-specific error summaries
also have different availability denominators and are not paired comparisons.

All 24 planned precision measures (two coverages and their difference, for
two targets in four cells) meet MCSE <=0.005. The largest observed MCSE is
0.003685, or 0.3685 pp; the largest paired-difference MCSE is 0.2662 pp.
None has zero empirical variance. This goal applies to primary coverage
measures, not every secondary band or availability estimate. All eight
oracle marginal coverage MC intervals include .95, consistent with the
declared reference, without proving implementation correctness by itself.

## Development decision

This experiment answers the effect-of-substitution question for the specified
model and conditions. It supports investigating calibration-aware intervals
for positive local dependence, especially with small samples. It supplies no
prespecified binary acceptance verdict and does not qualify an uncorrected
local-dependence interval for a new public API. Existing public fixed-facet
MFRM claims, shared-rater inference and design rankings are unchanged.

The next numerical work should be bounded to the eight saved optimizer stops
and two unresolved scoring cases. Any revised stopping or scoring policy needs
separate evidence and a versioned follow-up; this experiment's failures and
denominators must remain intact. Additional datasets solely to meet the achieved
precision goal are unnecessary.

Before implementing a correction, choose an inferential target and method:
same-sample repeated-sampling prediction error with an explicit refitting
scheme, or posterior uncertainty with explicit calibration priors and joint
integration. The existing [calibration sensitivity calculation](local-testlet-person-uncertainty-0.2.4.md)
does not justify adding only the diagonal of J C J' to conditional variances.
Pair differences require shared calibration covariance, and zero-variance
boundary behavior must be addressed. Correction selection remains a separate
inferential decision.

The subsequent [bounded numerical follow-up](local-testlet-main-failures-0.2.4.md)
is now complete. Aligning the optimizer's stopping target with the existing
final score criterion resolves the eight stops and preserves four successful
controls. Tighter outer integration resolves the pair's mass discrepancy;
P90 remains intentionally unresolved under the original cutoff band. These
selected-case diagnostics leave every main-study result above unchanged.

## Evidence and review

The reviewed CSVs are byte-for-byte copies of the completed runner outputs:
[counts](local-testlet-main-coverage-0.2.4-counts.csv),
[fit status](local-testlet-main-coverage-0.2.4-status.csv),
[method summaries](local-testlet-main-coverage-0.2.4-summaries.csv),
[paired comparisons](local-testlet-main-coverage-0.2.4-paired.csv),
[precision](local-testlet-main-coverage-0.2.4-precision.csv),
[scoring diagnostics](local-testlet-main-coverage-0.2.4-scoring.csv), and
[final audit](local-testlet-main-coverage-0.2.4-audit.csv).

The full evidence RDS, target and replicate rows, generated data and all stage
records remain under `validation-results/local-testlet-main-coverage-20260917/`.
The final `summary/local-testlet-main-coverage-0.2.4-evidence.rds` has MD5
`a7082d56f7d0e4d5b88654adddf07d8d`, matching `summary-complete.rds`.
These larger execution files are local and ignored by Git; the compact tables
preserve the reviewed aggregate results in version control. Raw-record
reanalysis still requires the retained execution directory.

Review used the saved final audit, current source/input/evidence identities,
fit records and the two unresolved scoring histories. No fit, scoring run,
aggregation rerun, full-package test, FairZ experiment or TAM comparison was
repeated. The report and copied evidence remain excluded from the CRAN source
package by the existing `^inst/validation$` build rule.
