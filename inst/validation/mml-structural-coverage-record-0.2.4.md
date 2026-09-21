# RSM/PCM structural uncertainty: execution record

Date: 2026-09-09. Status: all 20,000 confirmation datasets completed and
adjudicated under the original criteria. Five cells are supported in their
evaluated scope; three require bias review. C05 and release remain open.

## Question and execution basis

This study asks whether structural SEs match sampling variation and whether
95% normal intervals cover the true constrained parameters. Its
[prespecified protocol](mml-structural-coverage-protocol-0.2.4.md) separates
Person count from within-Person response exposure in eight RSM/PCM cells.
The [runner](mml-structural-coverage-0.2.4.R) retains every planned seed,
estimate, SE, interval-availability state, numerical check and warning.
There are 2,500 independent datasets per cell, 20,000 in total, and 96
coordinate-by-cell summaries. Coordinate rows are not extra replications.

The source and protocol were fingerprinted before confirmation. Estimation
and SE formulas were not modified in this work. The prior independent
generator gained optional Person-count and exposure arguments; all 13
original fixture datasets were reproduced exactly with the defaults.
The existing production MCSE-of-mean and MCSE-of-RMSE helpers are reused.
The old pooled-coordinate recovery summary is not used to make a
coordinate-specific coverage or SE-calibration claim.

## Preflight and aggregation checks

All 40 preflight datasets completed with zero errors, zero warnings and no
q61/q121 numerical conflicts. The SE builders agreed with the public
diagnostic and equivalence outputs. All 40 fits were inference ready.
These five datasets per cell supply execution evidence only; their
performance summaries are labeled `preflight_only` and are excluded from
confirmation. A timing-field-only revision was followed by replay of the
same 40 preflight seeds before confirmation started.

The aggregation self-check uses known normal quantiles with correct,
undersized and oversized SEs, shifted estimates, no available intervals,
a numerical counterexample and an incomplete run. It verifies that correct
inputs can support the specified criteria while those counterexamples do
not become support. Exact binomial limits retain a positive upper bound
when zero numerical conflicts are seen.

A separate check used 2,500 skewed synthetic errors and correlated SEs,
then 2,000 paired bootstrap resamples, preserving each error/SE pair.
The influence-function MCSEs were compared with bootstrap SDs; a ratio
between 0.9 and 1.1 was required before seeing these results.

| Performance statistic | Influence MCSE | Bootstrap SD | Bootstrap / influence |
| --- | ---: | ---: | ---: |
| RMS-SE / empirical SD | 0.0421083 | 0.0411205 | 0.97654 |
| Standardized bias | 0.0171128 | 0.0172162 | 1.00604 |

Both checks passed. This checks the performance-summary calculation; it
does not add MFRM recovery replications. Bootstrap-check seed: 5200909.

## Supplemental check of three-rating numerical information

The new three-rating assignment was checked using the first excluded
preflight seed in each of cells 1, 3, 5 and 7. Whole-line adaptive integration
and central-difference information at steps 0.001 and 0.0005 were independent
of the package objective/derivative implementation. This used the earlier
independent-information tolerances, without changing the confirmation protocol
or its criteria. All four checks passed: maximum objective discrepancy was
1.21e-11, normalized Hessian discrepancy 9.21e-8, covariance-entry scaled
discrepancy 1.36e-7, and expanded facet/threshold/contrast SE relative discrepancy
6.78e-8. The maximum Hessian step-size discrepancy was 5.53e-8.

These four numerical checks use preflight data, not additional recovery
replications. They support the numerical calculation on those datasets;
they neither remove a finite-sample bias finding nor certify every assignment.

## Resources and execution

Preflight measured approximately 0.28--1.11 seconds per core pipeline,
with a first-cell mean of 0.54 seconds affected by startup/warmup. The
public diagnostic cross-checks add time only in preflight. The confirmation
uses three local processes with cell groups `(8,2,5)`, `(4,7)` and `(3,1,6)`.
The initial projected wall time was about one to two hours. Log creation was
19:00:15 JST and final confirmation output was 20:17:47 JST: approximately
78 minutes for the main run, excluding preflight and final adjudication.
All three processes exited successfully. Checkpoints were written after every
50 completed datasets; source/protocol payloads agree across all eight cells
and the final preflight. No early stopping or replacement seeds were used.

## Confirmation results and answer

Each row below contains 2,500 independent datasets. Coverage is conditional
on interval availability. Ranges are across the declared coordinates within
the cell; the SE ratio is RMS-SE divided by empirical SD on the same available
repetitions. Decisions use the Monte Carlo intervals, not rounded point
estimates in this table.

| Cell | Model | Persons | Ratings per Person | Available / assigned | Coverage range (%) | RMS-SE / SD range | Overall decision |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | RSM | 80 | 3 | 2500 / 2500 | 94.96--95.48 | 0.9823--1.0033 | Review: shared threshold bias |
| 2 | RSM | 80 | 6 | 2500 / 2500 | 95.04--95.60 | 0.9854--1.0083 | Supported in cell |
| 3 | RSM | 320 | 3 | 2499 / 2500 | 94.80--95.60 | 0.9839--1.0089 | Supported in cell |
| 4 | RSM | 320 | 6 | 2500 / 2500 | 94.44--95.64 | 0.9842--1.0238 | Supported in cell |
| 5 | PCM | 80 | 3 | 2500 / 2500 | 94.36--95.64 | 0.9856--1.0097 | Review: C1 threshold bias |
| 6 | PCM | 80 | 6 | 2500 / 2500 | 94.08--96.08 | 0.9770--1.0326 | Supported in cell |
| 7 | PCM | 320 | 3 | 2495 / 2500 | 94.51--95.71 | 0.9845--1.0088 | Review: Criterion bias |
| 8 | PCM | 320 | 6 | 2500 / 2500 | 94.44--95.44 | 0.9782--1.0018 | Supported in cell |

All 96 coordinate-by-cell rows meet the prespecified coverage, SE-scale,
availability and numerical criteria. Their coverage MC intervals lie wholly
within [0.93, 0.97], and their RMS-SE/SD MC intervals wholly within [0.90, 1.10].
Eighty-nine rows meet every criterion. Seven rows remain review because the
standardized-bias MC interval overlaps a boundary of [-0.10, 0.10]. None is
classified as concern under the prespecified wholly-outside rule.

The seven review rows represent three directions, with constrained sign
copies and one proportional contrast. They are not seven independent findings.
The positive-direction examples are:

| Cell and target | Bias in parameter units | Bias / empirical SD | 95% MC interval for standardized bias |
| --- | ---: | ---: | ---: |
| 1: shared Step 2 | 0.011464 | 0.07936 | [0.04008, 0.11864] |
| 5: C1 Step 2 | 0.012189 | 0.06154 | [0.02227, 0.10082] |
| 7: Criterion C1 | 0.003892 | 0.07316 | [0.03394, 0.11238] |

Thus SE scale and 95% interval coverage are supported in these evaluated
conditions. There is also evidence of small nonzero bias in these three
directions, but insufficient MC precision to establish that it is wholly
inside the declared practical margin. Good coverage does not override that
separate criterion. The PCM C1 threshold upper limit is only slightly above
0.10; the decision still uses the unrounded value and remains review.

All four six-rating cells and the RSM 320-Person three-rating cell meet every
criterion. This does not establish a universal minimum Person count or number
of ratings, or prove that assignment alone caused the remaining bias. The
PCM Criterion review also occurs at 320 Persons, so the open question is not
adequately described as only a small-sample threshold issue.

## Numerical and unavailable-fit accounting

There were no execution errors, covariance failures or q61/q121 numerical
conflicts. Across all 20,000 fits, the maximum objective change was 7.92e-8,
maximum expanded-SE relative change 7.19e-9, and maximum scaled q121 Newton
displacement 2.06e-5. These are below the fixed numerical bounds. This and the
independent preflight calculations support numerical accuracy within the
tested scope, without resolving the sampling-bias reviews by themselves.

Six fits emitted an optimizer termination warning and remained unavailable
for ordinary inference under `terminal_gradient_review`, despite finite
estimates and passing numerical cross-checks. They were not silently refitted:

- Cell 3, replicate 467, seed 61030467.
- Cell 7, replicates 374, 900, 1097, 1686 and 2106; seeds 61070374,
  61070900, 61071097, 61071686 and 61072106.

All finite estimates remain in the all-estimate bias/RMSE summaries. Ordinary
interval availability is 99.8--100%; its lowest exact 95% lower bound is
99.534%. Available-and-covered counts divided by all 2,500 assigned datasets
are reported separately from conditional coverage. No available interval was
dropped because of a numerical cross-check. Zero observed ready numerical
conflicts yields an exact per-cell upper rate bound of 0.14745%, not zero.

## Retained evidence and next decision

- [Coordinate summaries](mml-structural-coverage-summary-0.2.4.csv): all 96
  rows, performance estimates, MC intervals, availability and dispositions.
- [Cell summaries](mml-structural-coverage-runs-0.2.4.csv): all eight cells,
  errors, warnings, runtime totals and coordinate ranges.
- [Evidence archive](mml-structural-coverage-evidence-0.2.4.rds): every
  confirmation result, the separate 40 preflight results, the MCSE check,
  four supplemental numerical checks, source/protocol fingerprints and
  helper text, source diff from base commit, session information, logs and
  the finalization script. The archive was read back and checked against
  both saved result tables. All planned replicate IDs and 20,000 confirmation
  seeds were verified, with no overlap with preflight seeds.

The controlling protocol is retained unchanged, including its original
pre-execution status text. This execution record supplies its final status.
The files are repository-only and excluded from source-package tarballs.
Final checks confirmed CSV/archive agreement, all 20,000 numerical checks,
the unchanged estimation payload, and the new document links. The existing
roadmap tests passed, and `git diff --check` was clean. These engineering
checks do not change the statistical dispositions above.

Next, resolve the three bias questions using a fresh prespecified targeted
confirmation, with replication count justified by the required bias precision,
or a separately justified and implemented support restriction. Do not append
repetitions until a favorable interval appears or relax the existing bounds.
Keep the current study as its own fixed result. Continue the existing claim
review for default q31, estimated populations, weights, anchors/interactions,
other response designs, Person uncertainty, full GPCM and estimator-specific
JML. This study supplies no new TAM comparison, full-GPCM equivalence result,
TOST calibration or release approval.

The subsequent [bias mechanism diagnostic](mml-structural-bias-diagnostic-record-0.2.4.md)
uses these same datasets and finds agreement between finite-sample curvature
predictions and score-decomposition remainders, with Monte Carlo imbalance
amplifying the selected review flags. This later explanatory analysis leaves
all original results and dispositions above unchanged.
