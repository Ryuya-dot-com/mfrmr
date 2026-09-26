# Separate-owner GPCM: diagnostic pilot result

Question: can the implemented criterion-slope/rater-step MML workflow be used
numerically in complete and connected incomplete rating designs, and what does
a small repeated-sampling check reveal before a larger statistical claim?

Protocol and generation were fixed before the pilot:
[generation and target protocol](gpcm-separated-owner-pilot-20260926.md),
[runner](gpcm-separated-owner-pilot-20260926.R), and
[summary calculation](gpcm-separated-owner-pilot-summary-20260926.R).
The numeric R implementation is unchanged from the published development source
7699a05e; execution used the repository after CI-metadata repair 6bae178a.
The manifest hashes every R source, protocol and runner. A mismatch prevents
resume. The first four completed cases were retained in the final 80.

## Evidence and its meaning

All 80 fits returned optimizer code 0 and joint-information status `ok`.
Every planned slope and probability interval was available under the existing
output-specific checks; no fit/inference warnings or captured errors occurred.
This is numerical availability in this correctly specified four-cell design,
not a global-optimum proof, general identification result or coverage guarantee.
The rotating design omits one of three raters per Person independently of
scores/ability and retains links; it is not informative missingness.

| Persons | Assignment | Datasets with all target intervals | Slope coverage, each of C1/C2 | Per-probability-target coverage range | Mean 95% slope interval width, C1 / C2 |
| --- | --- | --- | --- | --- | --- |
| 120 | Complete | 20/20 | 18/20 | 16/20–20/20 | 0.322 / 0.515 |
| 120 | Incomplete | 20/20 | 18/20 | 16/20–20/20 | 0.492 / 0.749 |
| 400 | Complete | 20/20 | 20/20 | 18/20–20/20 | 0.169 / 0.265 |
| 400 | Incomplete | 20/20 | 20/20 | 17/20–20/20 | 0.248 / 0.383 |

The two relative slopes have geometric mean one and reciprocal log-Wald limits;
their coverage indicators are dependent, not 40 independent trials. The 54
probability targets are likewise dependent within a dataset. The displayed
range is descriptive, not a simultaneous confidence statement or a test based
on the selected minimum. With 18/20 covered, the exact 95% Monte Carlo interval
for a single target's coverage is about [0.683,0.988]; with 20/20 it is
[0.832,1]. Neither certifies nominal 0.95 coverage. No new claim of systematic
undercoverage is based solely on the selected minimum across 54 targets.

All finite point estimates, not just cases with available intervals, enter
bias/RMSE. Here the counts coincide because all fits and intervals returned.
C1/C2 slope RMSEs are 0.105/0.162 (120 complete), 0.121/0.185 (120 incomplete),
0.039/0.061 (400 complete) and 0.050/0.077 (400 incomplete). Absolute slope bias
is at most 0.026 across these targets. Step RMSE ranges are 0.144–0.168,
0.161–0.198, 0.068–0.083 and 0.069–0.115 in the same order. These describe
this pilot; no practical-accuracy threshold was retrospectively declared met.

Removing one rater's responses increases mean slope-interval width by about
45–53% in this design. The complete/incomplete comparisons use paired generated
datasets; individual paired errors and interval widths are retained. This shows
the precision cost of this particular assignment change, not an optimal-design
recommendation or a general sparse-design correction.

## Cost and next decision

Total recorded fit-and-inference time is 147.304 seconds for 80 cases, using a
sequential local R process. The preliminary four-case projection was 178.72
seconds, within the prespecified 15-minute budget. Session information, every
fit, interval, warning and target-level result are retained under
`validation-results/gpcm-separated-owner-pilot-20260926/`.

No reproduced numerical defect requires an estimator change in this pilot.
The decision is to retain the implemented approximate-output scope and leave
finite-sample qualification open. Do not repeat this same pilot or launch
bootstrap nesting. If a coverage claim is needed, first fix its target,
acceptable performance, reporting rule and Monte Carlo precision independently
of these observed successes.

For planning only, p(1-p)/MCSE^2 at p=0.95 gives 119 datasets per cell for MCSE
0.02, or 475 for MCSE 0.01. At the measured average cost, a new balanced four-cell
study would use about 15 or 58 minutes of fitting/inference respectively,
excluding additional validation, reporting and changes in failure cost. These
are plug-in planning estimates, not maximum error guarantees: coverage near
0.5 has larger variance, and simultaneous claims require a separate design.
No confirmation study has been authorized by a favorable pilot outcome or
started automatically. D2 interface integration can proceed without inventing
a stronger interval claim.

## Verification and records

The existing independent likelihood/gradient/unit-slope checks and confounded
assignment refusal were reused. All cases retain their original planned IDs;
a separate summary check includes one available interval, an unavailable
interval and an unexecuted dataset, verifying that unavailable cases are not
dropped and not treated as known statistical misses. The complete report lists
availability, conditional coverage, reported-and-covered frequency and
unresolved-case bounds; step targets are explicitly point-estimate-only.

Local outputs: `manifest.rds`, `plan.csv`, per-case RDS files, `results.rds`,
`dataset-checks.csv`, `target-results.csv`, `target-summary.csv`,
`paired-results.csv`, `engineering-review.log`, `summary.log`,
`summary-check.log`, and `session-info.rds`. The fixed protocol and scripts are
kept with this record; the generated synthetic fits are excluded from packages.
